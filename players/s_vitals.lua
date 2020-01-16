function InitFoodVitalsDepleting(player) -- Initialize a timer to deplete the vitals of a player on time
    
    local char = GetPlayerDatasFromPlayer(player)
    char.ActiveCharacter.TimerFoodDeplete = CreateTimer(function(player)
        local char = GetPlayerDatasFromPlayer(player)
        char.ActiveCharacter.Hunger = char.ActiveCharacter.Hunger - 1
        char.ActiveCharacter.Thirst = char.ActiveCharacter.Thirst - 2

        if char.ActiveCharacter.Hunger <= 20  then
            AddPlayerChat(player, "You are hungry")
        end

        if char.ActiveCharacter.Thirst <= 20  then
            AddPlayerChat(player, "You are thirsty")
        end

        if char.ActiveCharacter.Hunger <= 0 or char.ActiveCharacter.Thirst <= 0 then
            SetPlayerHealth(player, 0) -- When the player has no enough hunger or thirst, he die
            DestroyFoodVitalsTimer(player) -- We have to destroy the timer
            char.ActiveCharacter.Hunger = 100 -- Then we have to reinit his vitals
            char.ActiveCharacter.Thirst = 100
        end
    end, CHAR_TIMER_VITALS_DEPLETING * 1000 , player)    
    print('[ORPCORE - Vitals] Food vitals timer initialized for '..player)
end

function DestroyFoodVitalsTimer(player)  -- Destroy the timer when the player log out
    local char = GetPlayerDatasFromPlayer(player)
    DestroyTimer(char.ActiveCharacter.TimerFoodDeplete)  
    char.ActiveCharacter.TimerFoodDeplete = nil
    print('[ORPCORE - Vitals] Food vitals timer destroyed for '..player)  
end

AddEvent("OnPlayerSpawn", function(player) -- When the player spawn, start the food vitals timer if none is set
    local char = GetPlayerDatasFromPlayer(player)
    if char ~= nil and char.ActiveCharacter.TimerFoodDeplete == nil then InitFoodVitalsDepleting(player) end
end)

function GetVitalsForPlayer(player)  -- Get the vitals for a player
    local char = GetPlayerDatasFromPlayer(player)
    return { health= char.ActiveCharacter.Health, hunger= char.ActiveCharacter.Hunger, thirst= char.ActiveCharacter.Thirst }
end

-- Commands
if DEV_MODE == 1 then
    AddCommand("getvitals", function(player) -- HUD
        local vitals = GetVitalsForPlayer(player)
        AddPlayerChat(player, "Health: " .. vitals.health .. " Hunger: " .. vitals.hunger .. " Thirst: " .. vitals.thirst)
    end)

    AddCommand("resetvitals", function(player) -- because atm we can't eat :D
        local char = GetPlayerDatasFromPlayer(player)
        char.ActiveCharacter.Hunger = 100
        char.ActiveCharacter.Thirst = 100
        AddPlayerChat(player, 'hunger and thirst reseted')        
    end)
end

-- EXPORTS
AddFunctionExport("ORCGetVitalsForPlayer", GetVitalsForPlayer)-- To get the vitals for a player