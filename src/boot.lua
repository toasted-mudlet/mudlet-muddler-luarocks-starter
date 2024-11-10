--[[
    Basic Package Environment Bootstrapper

    This module adjusts Lua's package.path to include package-specific script and module directories.
]]

local function addPath(existingPaths, newPath, pathSep)
    if existingPaths == '' then
        return newPath
    elseif not string.find(existingPaths, newPath, 1, true) then
        return newPath .. pathSep .. existingPaths
    end
    return existingPaths
end

return function(packageName)
    local safePackageName = packageName:gsub("[^%w_]", "_")
    local packageId = "__" .. safePackageName .. "__"
    local namespace = _G[packageId]

    if not namespace then
        namespace = {
            packageName = packageName,
            bootCount = 1
        }

        local sep = package.config:sub(1, 1)
        local pathSep = ';'
        local mudletHomeDir = getMudletHomeDir()
        local basePath = mudletHomeDir .. sep .. namespace.packageName .. sep .. 'lua'
        namespace.basePath = basePath

        local scriptPathLua = basePath .. sep .. 'scripts' .. sep .. '?.lua'
        local scriptPathInit = basePath .. sep .. 'scripts' .. sep .. '?' .. sep .. 'init.lua'
        local luaVersion = _VERSION:match('%d+%.%d+')

        package.path = addPath(package.path, scriptPathLua, pathSep)
        package.path = addPath(package.path, scriptPathInit, pathSep)

        local basePathLuaModules = basePath .. sep .. 'lua_modules' .. sep .. 'share' .. sep .. 'lua' .. sep .. luaVersion
        local luaModulesPathLua = basePathLuaModules .. sep .. '?.lua'
        local luaModulesPathInit = basePathLuaModules .. sep .. '?' .. sep .. 'init.lua'

        package.path = addPath(package.path, luaModulesPathLua, pathSep)
        package.path = addPath(package.path, luaModulesPathInit, pathSep)

        namespace.path = package.path
        namespace.cpath = package.cpath

        _G[packageId] = namespace
    else
        namespace.bootCount = namespace.bootCount + 1
    end

     debugc('[' .. packageId .. '] booting ...')

        local ok, err = pcall(function()
            local app = require('app')
            app:start(packageId, packageName)
        end)

        if not ok then
            debugc('[' .. packageId .. '] boot failed: ' .. tostring(err) .. "\n" .. debug.traceback())
            error(tostring(err))
        else
            debugc('[' .. packageId .. '] booted successfully')
        end
end

