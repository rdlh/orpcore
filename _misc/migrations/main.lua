availableMigrations = { }
alreadyMigrated = { }
doneMigrations = 0
migratedFile = io.open('./migrated.txt', "r+")

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

function RunMigration(version)
  PrintRunningMigration(version)

  local migrationFile = io.open("./"..version..".sql", "r+")

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
    searchCmd = "ls ./"
  else
    searchCmd = "Get-ChildItem -Name"
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
  print("\27[33mOnsetRP\27[0m::\27[36mDatabase\27[0m → \27[32m Database up to date ✓ (version "..GetCurrentDatabaseVersion()..")\27[0m")
  print("")
end

function PrintRunningMigration(version)
  print("")
  print("\27[33mOnsetRP\27[0m::\27[36mDatabase\27[0m → Running "..version)
  print("")
end

function PrintSqlWithDecorationAndReturn(migrationFile)
  local lines = migrationFile:lines()

  print("    ┌─────────")
  print("    | ")
  for line in lines do
    print("    |   "..line)
  end
  print("    | ")
  print("    └─────────")
  print("")

  table.concat(lines, " ")
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

MigrateIdNeeded()
