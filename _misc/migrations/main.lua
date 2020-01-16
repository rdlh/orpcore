local availableMigrations = { }
local alreadyMigrated = { }
local doneMigrations = 0
local migrationPath = ""
local migratedFile

function MigrateIdNeeded()
    LoadAvailableMigrations()
    LoadAlreadyMigrated()

    for availableIndex, availableMigration in ipairs(availableMigrations) do
        local done = false
        for migratedIndex, migrated in ipairs(alreadyMigrated) do
            if availableMigration == migrated then
                done = true
            end
        end
        if not done then
            RunMigration(availableMigration)
        end
    end

    if doneMigrations > 0 then
        PrintDoneMigrations()
    else
        PrintUpToDateMigrations()
    end

  migratedFile:close()
end

AddEvent("database:connected", MigrateIdNeeded)

function RunMigration(version)
    local migrationFile = io.open(migrationPath..version..".sql", "r+")

    local migrationName = migrationFile:read()

    if string.sub(migrationName, 1, 2) == "--" then
        migrationName = string.gsub(migrationName, "-- ", "", 1)
        migrationName = "\""..migrationName.."\""
    else
        migrationName = version
    end

    PrintRunningMigration(migrationName)

    local queryString = PrintSqlWithDecorationAndReturn(migrationFile)
    local query = mariadb_prepare(sql, queryString)

    mariadb_await_query(sql, query)

    doneMigrations = doneMigrations + 1

    migratedFile:write(version, "\n")
end


-- HELPERS


function LoadAvailableMigrations()
    local searchCmd

    if GetOS() == 'unix' then
        migrationPath = "./packages/orpcore/_misc/migrations/"
        searchCmd = "ls "..migrationPath
    else
        migrationPath = ".\\packages\\orpcore\\_misc\\migrations\\"
        searchCmd = "dir "..migrationPath.." /b"
    end

    migratedFile = io.open('./migrated.txt', "a+")

    if migratedFile == nil then
        migratedFile = io.open('./migrated.txt', "w+")
    end

    for migrationName in io.popen(searchCmd):lines() do
        if string.find(migrationName, "%.sql$") then
            migrationName = string.gsub(migrationName, ".sql", "")
            table.insert(availableMigrations, migrationName)
        end
    end
end

function GetCurrentDatabaseVersion()
    return availableMigrations[#availableMigrations]
end

function PrintDoneMigrations()
    print("\27[33mOnsetRP\27[0m::\27[36mDatabase\27[0m → \27[32m"..doneMigrations.." migrations DONE ✓ (version "..GetCurrentDatabaseVersion()..")\27[0m")
    print("")
end

function PrintUpToDateMigrations()
    print("")
    print("\27[33mOnsetRP\27[0m::\27[36mDatabase\27[0m → \27[32m Database up to date ✓ (version "..GetCurrentDatabaseVersion()..")\27[0m")
    print("")
end

function PrintRunningMigration(name)
    print("")
    print("\27[33mOnsetRP\27[0m::\27[36mDatabase\27[0m → Running "..name)
    print("")
end

function PrintSqlWithDecorationAndReturn(migrationFile)
    local lines = migrationFile:lines()
    local linesTable = { }

    -- print("    ┌─────────")
    -- print("    | ")
    for line in lines do
        -- print("    |   "..line)
        table.insert(linesTable, line)
    end
    -- print("    | ")
    -- print("    └─────────")
    -- print("")

    return table.concat(linesTable, " ")
end

function GetOS()
    if package.cpath:match("%p[\\|/]?%p(%a+)") == "so" then
        return "unix"
    else
        return "windows"
    end
end

function LoadAlreadyMigrated()
    if not migratedFile then
        migratedFile = io.open('./migrated.txt', "w")
    else
        for line in migratedFile:lines() do
            table.insert(alreadyMigrated, line)
        end
    end
end
