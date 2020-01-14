function CheckCharacters(player)-- #1 Entry point : Check if the player has characters
    local playerDatas = GetPlayerDatasFromPlayer(player)
    
    local query = mariadb_prepare(sql, "SELECT c.*, p.pos_x, p.pos_y, p.pos_z, p.pos_h FROM orpcore_character c LEFT JOIN orpcore_position p ON p._character_id = c.id WHERE player_id = ? ",
        playerDatas.id)
    
    mariadb_async_query(sql, query, OnCharactersLoaded, player)
    print('[ORPCORE - Character] Retrieving characters for ' .. GetPlayerName(player) .. ' (' .. player .. ')')
end

function OnCharactersLoaded(player)-- #2 We got characters from player,
    if mariadb_get_row_count() > 0 then
        -- In the futur, we'll be able to manage many characters for one player.
        -- for i=1, mariadb_get_row_count() do
        -- 	local character = mariadb_get_assoc(i)
        --     for k,v in pairs(character) do
        --         print(k,v)
        --     end
        -- end
        GetLoadedCharacterAndSetActive(player)
    else
        if DEV_MODE == 1 then
            AddPlayerChat(player, "You don't have any character. Start by creating one by taping '/register firstname lastname'.")
        --else -- TODO : Make the equivalent with an UI
        -- To continue : CreateNewCharacter
        end
    end
end

function GetLoadedCharacterAndSetActive(player) -- #3 Let's set the character as active and set his position if there is none
    local character = mariadb_get_assoc(1)
    if character.pos_x == nil then -- If we don't have character pos, let's create them
        local query = mariadb_prepare(sql, "INSERT INTO orpcore_position VALUES (NULL, ?, ?, ?, ?, ?)",
            character.id,
            CHAR_DEFAULT_SPAWN.x,
            CHAR_DEFAULT_SPAWN.y,
            CHAR_DEFAULT_SPAWN.z,
            CHAR_DEFAULT_SPAWN.h)
        
        mariadb_async_query(sql, query)
        character.pos_x = CHAR_DEFAULT_SPAWN.x
        character.pos_y = CHAR_DEFAULT_SPAWN.y
        character.pos_z = CHAR_DEFAULT_SPAWN.z
        character.pos_h = CHAR_DEFAULT_SPAWN.h
    end
    print('[ORPCORE - Character] Set active characters → ' .. character.firstname .. ' ' .. character.lastname .. ' for ' .. GetPlayerName(player) .. ' (' .. player .. ')')
    SetActiveCharacter(player, character)-- → Player - Let's define the character as active in Player datas
end

function OnPackageStart()-- Save characters automatically
    CreateTimer(function()
        local nb = 0
        for k, v in pairs(GetAllPlayers()) do
            SavePlayerDatas(v)
            nb = nb + 1
        end
        print("[ORPCORE - Player] Saving player datas " .. tostring(os.date('%Y-%m-%d %H:%M:%S')) .. ' (' .. nb .. ')')
    end, CHAR_TIMER_AUTOSAVE * 1000)
end
AddEvent("OnPackageStart", OnPackageStart)

function SavePlayerDatas(player)
    local char = GetPlayerDatasFromPlayer(player)
    
    if char ~= nil and char.ActiveCharacter ~= nil and char.ActiveCharacter.id ~= nil then -- Save player datas only if the active character is defined
        local query = mariadb_prepare(sql, "UPDATE orpcore_character SET health = ?, hunger = ?, thirst = ? WHERE id = ?",
            char.ActiveCharacter.Health,
            char.ActiveCharacter.Hunger,
            char.ActiveCharacter.Thirst,
            char.ActiveCharacter.id)
        
        mariadb_async_query(sql, query)
        
        local x, y, z = GetPlayerLocation(player)
        local h = GetPlayerHeading(player)
        local query_pos = mariadb_prepare(sql, "UPDATE orpcore_position SET pos_x = ?, pos_y = ?, pos_z = ?, pos_h = ? WHERE _character_id = ?",
            x, y, z, h, char.ActiveCharacter.id)
        
        mariadb_async_query(sql, query_pos)
    end

end

function CreateNewCharacter(player, firstname, lastname) -- To create a new character from scratch
    local playerDatas = GetPlayerDatasFromPlayer(player)
    
    local query = mariadb_prepare(sql, "INSERT INTO orpcore_character VALUES(NULL, ?, '?', '?', 100, 100, 100, '?');",
        playerDatas.id,
        tostring(firstname),
        tostring(lastname),
        tostring(os.date('%Y-%m-%d %H:%M:%S')))
    
    mariadb_async_query(sql, query, LoadNewCharacter, player)
    print("[ORPCORE - Player] Creating new character for " .. GetPlayerName(player) .. " → " .. firstname .. " " .. lastname)
end

function LoadNewCharacter(player) -- Load the previously created character from db for security purposes
    local query = mariadb_prepare(sql, "SELECT * FROM orpcore_character WHERE id = ? LIMIT 1;",
        mariadb_get_insert_id())
    
    mariadb_async_query(sql, query, OnNewCharacterLoaded, player)
    print("[ORPCORE - Player] Loading just added character for " .. GetPlayerName(player))
end

function OnNewCharacterLoaded(player) -- Set the new character as active in → Player
    GetLoadedCharacterAndSetActive(player)
end


-- Commands
if DEV_MODE == 1 then
    AddCommand("getvitals", function(player) -- HUD
        local playerDatas = GetPlayerDatasFromPlayer(player)
        AddPlayerChat(player, "Health: " .. playerDatas.ActiveCharacter.Health .. " Hunger: " .. playerDatas.ActiveCharacter.Hunger .. " Thirst: " .. playerDatas.ActiveCharacter.Thirst)
    end)
    
    AddCommand("register", function(player, firstname, lastname) -- Create new character
        if GetPlayerDatasFromPlayer(player).ActiveCharacter ~= nil then
            AddPlayerChat(player, "You already have a character. You can't create a new one.")          
        else
            if firstname ~= nil and lastname ~= nil then
                CreateNewCharacter(player, firstname, lastname)
            else
                AddPlayerChat(player, "You have to specify a firstname and a lastname !")
            end
        end        
    end)

end
