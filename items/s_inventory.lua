function LoadInventoryFromPlayer(player, characterId)-- Load the inventory of the player from database (Used at character loading)
    local query = mariadb_prepare(sql, "SELECT it.name, i.quantity, it.weight FROM orpcore_character c " ..
        "LEFT JOIN orpcore_inventory i ON i._character_id = c.id LEFT JOIN orpcore_item it ON it.id = i.item_id " ..
        "WHERE c.id = ? AND i.id IS NOT NULL GROUP BY it.id", characterId)
    
    local result = mariadb_await_query(sql, query)
    
    local inventories = {}
    
    if result ~= 1 then
        print('[ORPCORE - Inventory] Failed to load inventory for character ' .. characterId .. ' (' .. player .. ')')
    else
        for i = 1, mariadb_get_row_count() do
            local inventory = {
                name = mariadb_get_value_name(i, "name"),
                quantity = mariadb_get_value_name_int(i, "quantity"),
                weight = mariadb_get_value_name_int(i, "weight")
            }
            table.insert(inventories, inventory)
        end
    end
    mariadb_delete_result(result)
    return inventories
end

function SavePlayerInventory(player)-- Save automatically the inventory of the player
    local char = GetPlayerDatasFromPlayer(player)
    if char ~= nil and char.ActiveCharacter ~= nil and char.ActiveCharacter.id ~= nil and char.ActiveCharacter.Inventory ~= nil then
        local queryReset = mariadb_prepare(sql, "DELETE FROM orpcore_inventory WHERE _character_id = ?", char.ActiveCharacter.id)
        local result = mariadb_await_query(sql, queryReset)
        if result ~= 1 then
            print('[ORPCORE - Inventory] Failed to save inventory for character ' .. char.ActiveCharacter.id .. ' (' .. player .. ')')
        end
        mariadb_delete_result(result)
        for k, v in pairs(char.ActiveCharacter.Inventory) do
            local queryAdd = mariadb_prepare(sql, "INSERT INTO orpcore_inventory VALUES (NULL, ?, (SELECT id FROM orpcore_item WHERE NAME = '?'), ?)",
                char.ActiveCharacter.id, tostring(v.name), tonumber(v.quantity))
            mariadb_async_query(sql, queryAdd)
        end
    end
end

function AddItemToPlayerInventory(player, item, quantity) -- To add an item with quantity to a player
    local char = GetPlayerDatasFromPlayer(player)
    
    local query = mariadb_prepare(sql, "SELECT * FROM orpcore_item WHERE name = '?' LIMIT 1;", tostring(item))
    local result = mariadb_await_query(sql, query)
    local weight = mariadb_get_value_name_int(1, "weight")-- We need the base weight of the item
    mariadb_delete_result(result)
    
    local totalWeightToAdd = weight * quantity
    local actualWeight = 0
    for i = 1, count(char.ActiveCharacter.Inventory) do
        actualWeight = actualWeight + (tonumber(char.ActiveCharacter.Inventory[i].weight) * tonumber(char.ActiveCharacter.Inventory[i].quantity))
    end
    
    if totalWeightToAdd + actualWeight > (INVENTORY_MAX_BASE_WEIGHT * 1000) then -- If the weight will get too high we stop
        return false
    end
    
    local found = false
    for i = 1, count(char.ActiveCharacter.Inventory) do -- Search in inventory array if there is already this item
        if char.ActiveCharacter.Inventory[i].name == item then -- If found, update it
            char.ActiveCharacter.Inventory[i].quantity = char.ActiveCharacter.Inventory[i].quantity + quantity
            found = true
        end
    end
    
    if found == false then -- If not found, let's add an item
        table.insert(char.ActiveCharacter.Inventory, {
            weight = weight,
            quantity = quantity,
            name = item
        })
    end
    
    return true
end

function RemoveItemFromPlayerInventory(player, item, quantity)-- To remove an item with quantity to a player
    local char = GetPlayerDatasFromPlayer(player)
    
    local found = false
    for i = 1, count(char.ActiveCharacter.Inventory) do -- Search in inventory array if there is already this item
        if char.ActiveCharacter.Inventory[i].name == item and tonumber(char.ActiveCharacter.Inventory[i].quantity) >= tonumber(quantity) then -- If found, update it
            local futurValue = char.ActiveCharacter.Inventory[i].quantity - quantity
            if futurValue > 0 then -- If it will last at least one item of this type we keep it
                char.ActiveCharacter.Inventory[i].quantity = futurValue
            else -- else we don't
                char.ActiveCharacter.Inventory[i] = nil
            end
            return true
        end
    end
    return false
end

function GetCurrentInventoryFromPlayer(player)-- To get the current inventory of a player
    local char = GetPlayerDatasFromPlayer(player)
    return char.ActiveCharacter.Inventory
end

if DEV_MODE == 1 then
    AddCommand("inventory", function(player)
        --GetInventoryFromPlayer(player)
        end)
    
    AddCommand("addinventory", function(player, name, quantity)
        local char = GetPlayerDatasFromPlayer(player)
        local result = AddItemToPlayerInventory(player, name, quantity)
        if result == true then
            AddPlayerChat(player, quantity .. ' of ' .. name .. ' has been added to ' .. char.ActiveCharacter.Firstname .. ' ' .. char.ActiveCharacter.Lastname)
        else
            AddPlayerChat(player, 'Impossible to add those items')
        end
    end)

    AddCommand("delinventory", function(player, name, quantity)
        local char = GetPlayerDatasFromPlayer(player)
        local result = RemoveItemFromPlayerInventory(player, name, quantity)
        if result == true then
            AddPlayerChat(player, quantity .. ' of ' .. name .. ' has been removed from ' .. char.ActiveCharacter.Firstname .. ' ' .. char.ActiveCharacter.Lastname)
        else
            AddPlayerChat(player, 'Impossible to remove those items')
        end
    end)
    

end

-- EXPORTS
AddFunctionExport("ORCAddItemToPlayerInventory", AddItemToPlayerInventory)-- To add an item with quantity to a player
AddFunctionExport("ORCRemoveItemFromPlayerInventory", RemoveItemFromPlayerInventory)-- To remove an item with quantity from a player
AddFunctionExport("ORCGetCurrentInventoryFromPlayer", GetCurrentInventoryFromPlayer)-- To get the current inventory of a player
