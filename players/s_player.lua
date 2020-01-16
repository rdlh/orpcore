local Players = {} -- Our logged on players. Protect this.

function OnPlayerQuit(player)-- Let's destroy the player to save some space
    if Players[player] == nil then return end
    
    SavePlayerDatas(player) -- Save player infos before leave
    SavePlayerInventory(player) -- → Inventory
    DestroyFoodVitalsTimer(player) -- → Vitals
    Players[player] = nil
    print('[ORPCORE - Player] Data destroyed → ' .. GetPlayerName(player) .. ' (' .. player .. ')')
end
AddEvent("OnPlayerQuit", OnPlayerQuit)

function OnPlayerSteamAuth(player)-- #1 Steam auth → Load player ID
    local query = mariadb_prepare(sql, "SELECT id FROM orpcore_player WHERE steam_id = '?' LIMIT 1;",
        tostring(GetPlayerSteamId(player)))
    
    mariadb_async_query(sql, query, OnPlayerLoadId, player)
end
AddEvent("OnPlayerSteamAuth", OnPlayerSteamAuth)

function OnPlayerLoadId(player)-- #2 We got player ID, let's check player
    Players[player] = {}
    if mariadb_get_row_count() < 1 then -- there's no player, let's initialize one
        print('[ORPCORE - Player] New player ! Initialization for ' .. GetPlayerName(player) .. ' (' .. player .. ')')
    else
        Players[player].id = mariadb_get_value_index(1, 1)
        print('[ORPCORE - Player] ' .. GetPlayerName(player) .. ' (' .. player .. ') has just connected')
    end
    
    local query = mariadb_prepare(sql, "SELECT release_date, reason FROM orpcore_bans WHERE steam_id = '?' OR ipaddress = '?' LIMIT 1;",
        tostring(GetPlayerSteamId(player)),
        tostring(GetPlayerIP(player)))
    
    mariadb_async_query(sql, query, OnAccountCheckBan, player)
end

function OnAccountCheckBan(player)-- #3 We got bans history, let's check if the player is banned
    if mariadb_get_row_count() > 0 then
        local result = mariadb_get_assoc(1)
        KickPlayer(player, 'You are banned : ' .. result.reason .. ' .Release date : ' .. result.release_date)
        print('[ORPCORE - Player] Kicking player ' .. GetPlayerName(player) .. ' (' .. player .. ') ' .. 'because there\'s a ban on his Steam ID or IP Address')
        return
    end
    
    ProcessPlayer(player)
end

function ProcessPlayer(player)-- #4 Now we're done checking stuff, let's process the player
    if Players[player] ~= nil and Players[player].id ~= nil then -- The player already exist
        LoadPlayerDatas(player)
    else -- The player is new
        local query = mariadb_prepare(sql, "INSERT INTO orpcore_player VALUES(NULL, '?', '?', SYSDATE());",
            tostring(GetPlayerSteamId(player)),
            tostring(GetPlayerIP(player)))
        
        mariadb_query(sql, query, OnAccountCreated, player)
    end
end

function OnAccountCreated(player)-- #5 We just created the new player, let's load his stuff
    Players[player].id = mariadb_get_insert_id()
    print('[ORPCORE - Player] Added new player ' .. player .. ' → ' .. tostring(GetPlayerSteamId(player)) .. ' ip: ' .. tostring(GetPlayerIP(player)) .. ' on id : ' .. Players[player].id)
    LoadPlayerDatas(player)
end

function LoadPlayerDatas(player)-- #6 Loading player
    print('[ORPCORE - Player] Loading player infos → ' .. GetPlayerName(player) .. ' (' .. player .. ')')
    local query = mariadb_prepare(sql, "SELECT * FROM orpcore_player WHERE id = ?;",
        Players[player].id)
    
    mariadb_async_query(sql, query, OnPlayerDatasLoaded, player)
end

function OnPlayerDatasLoaded(player)-- #7 Account loaded, let's add it in our players datas
    if mariadb_get_row_count() == 0 then
        KickPlayer(player, "An error occured while loading your account 😨")
    else
        -- Loading player infos in players array
        local result = mariadb_get_assoc(1)
        Players[player].SteamID = tostring(result['steam_id'])
        Players[player].LastIpAddress = tostring(result['last_ipaddress'])
        Players[player].LastLoggedIn = tostring(result['last_logged_in'])
        
        print('[ORPCORE - Player] Player fully loaded → ' .. GetPlayerName(player) .. ' (' .. player .. ')')
        
        -- Updating player infos with current ip address and datetime
        local query = mariadb_prepare(sql, "UPDATE orpcore_player SET last_ipaddress = '?', last_logged_in = '?' WHERE id = ?;",
            tostring(GetPlayerIP(player)),
            tostring(os.date('%Y-%m-%d %H:%M:%S')),
            Players[player].id)
        
        mariadb_async_query(sql, query)
        print('[ORPCORE - Player] Player infos updated → ' .. GetPlayerName(player) .. ' (' .. player .. ')')
        
        -- Now we're done for the player, let's check for the characters he may have
        CheckCharacters(player) -- → Character
    end
end

function GetPlayerDatasFromPlayer(player)-- To use externally to get player datas
    return Players[player]
end

function SetActiveCharacter(player, character)-- #8 We got the active character, let's define it in our Player datas
    if tonumber(Players[player].id) ~= tonumber(character.player_id) then -- just in case something broken happend
        KickPlayer(player, "An error occured while retrieving your character. Please try again later.")
    end

    -- Player datas payload. New datas have to be initialized here.
    Players[player].ActiveCharacter = {}
    Players[player].ActiveCharacter.id = character.id
    Players[player].ActiveCharacter.Firstname = character.firstname
    Players[player].ActiveCharacter.Lastname = character.lastname
    Players[player].ActiveCharacter.Health = character.health
    Players[player].ActiveCharacter.Hunger = character.hunger
    Players[player].ActiveCharacter.Thirst = character.thirst
    Players[player].ActiveCharacter.CreatedAd = character.created_at
    Players[player].ActiveCharacter.Position = {x = character.pos_x, y = character.pos_y, z = character.pos_z, h = character.pos_h}
    Players[player].ActiveCharacter.Inventory = LoadInventoryFromPlayer(player, character.id) -- → Inventory

    -- Things that will happen when a character is loaded. Typically, tp on last known position.
    SetPlayerLocation(player, Players[player].ActiveCharacter.Position.x, Players[player].ActiveCharacter.Position.y, Players[player].ActiveCharacter.Position.z + 200)
    SetPlayerHeading(player, Players[player].ActiveCharacter.Position.h)

    -- Initialize some stuffs
    if Players[player].ActiveCharacter.TimerFoodDeplete == nil then InitFoodVitalsDepleting(player) end -- → Vitals 
    
    -- TODO : Trigger something client side to hide the loading screen we should have :)
    AddPlayerChat(player, "Welcome "..Players[player].ActiveCharacter.Firstname.." "..Players[player].ActiveCharacter.Lastname)    
    
    print('[ORPCORE - Player] Active character defined → ' .. GetPlayerName(player) .. ' (' .. player .. ')')
end


-- EXPORTS
AddFunctionExport("ORCGetPlayerDatasFromPlayer", GetPlayerDatasFromPlayer)-- To get player datas

-- TODO : Add functions to update the player datas from external package or protect it in some ways by adding specific data function like AddMoney()