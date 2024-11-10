local packageName = '@PKGNAME@'

cecho('<yellow>[ INFO ]  - ' .. packageName .. ': Booting...\n')

local scriptPath = getMudletHomeDir() .. '/' .. packageName .. '/lua/scripts/boot.lua'

local ok, bootFuncOrErr = pcall(dofile, scriptPath)
if not ok then
    cecho('<red>[ FAILED ] - ' .. packageName .. ': ... ' .. tostring(bootFuncOrErr) .. '  \n')
elseif type(bootFuncOrErr) == "function" then
    local ok2, err2 = pcall(bootFuncOrErr, packageName)
    if not ok2 then
        cecho('<red>[ FAILED ] - ' .. packageName .. ': ... ' .. tostring(err2) .. '  \n')
    else
        cecho('<yellow>[ INFO ]  - ' .. packageName .. ': Booted successfully.\n')
    end
else
    cecho('<red>[ FAILED ] - ' .. packageName .. ': ... "boot.lua" did not return a function\n')
end
