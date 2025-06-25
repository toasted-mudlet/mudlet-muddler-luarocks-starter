--[[
    Mudlet Package Bootstrapper

    Sets up practical, package-level isolation for your package's runtime environment.
    - Keeps your globals and dependencies separate from other packages.
    - Ensures event handlers run in your package's environment.
    - Not a security sandbox—just pragmatic isolation.

    See the main README for details on namespace naming, event-driven integration, and
    best practices for direct API calls.
]]

return function(packageName)
    local safePackageName = packageName:gsub('[^%w_]', '_')
    local dunderPackageName = '__' .. safePackageName .. '__'

    -- Path setup
    local sep = package.config:sub(1, 1)
    local pathSep = ';'
    local mudletHomeDir = getMudletHomeDir()
    local basePath = mudletHomeDir .. sep .. packageName .. sep .. 'lua'

    -- Compose package-local paths
    local scriptPathLua = basePath .. sep .. 'scripts' .. sep .. '?.lua'
    local scriptPathInit = basePath .. sep .. 'scripts' .. sep .. '?' .. sep .. 'init.lua'
    local luaVersion = _VERSION:match('%d+%.%d+')
    local basePathLuaModules = basePath .. sep .. 'lua_modules' .. sep .. 'share' .. sep .. 'lua' .. sep .. luaVersion
    local luaModulesPathLua = basePathLuaModules .. sep .. '?.lua'
    local luaModulesPathInit = basePathLuaModules .. sep .. '?' .. sep .. 'init.lua'

    -- Load isolated namespace
    local isolatedNamespacePath = basePath .. sep .. 'scripts' .. sep .. 'boot_env' .. sep .. 'isolated_namespace.lua'
    local isolatedNamespaceCreator = assert(loadfile(isolatedNamespacePath))()

    -- Load isolated require
    local isolatedRequirePath = basePath .. sep .. 'scripts' .. sep .. 'boot_env' .. sep .. 'isolated_require.lua'
    local isolatedRequireCreator = assert(loadfile(isolatedRequirePath))()

    -- Create namespace and runtime env
    local namespace = isolatedNamespaceCreator()
    local require_ = isolatedRequireCreator(dunderPackageName, scriptPathLua, scriptPathInit, luaModulesPathLua,
        luaModulesPathInit, namespace)

    namespace.require = require_
    _G[dunderPackageName] = namespace
    setfenv(1, namespace)

    debugc('[' .. dunderPackageName .. '] booting ...')

    local ok, err = pcall(function()
        local app = require('app')
        app:start()
    end)

    if not ok then
        debugc('[' .. dunderPackageName .. '] boot failed: ' .. tostring(err) .. "\n" .. debug.traceback())
        error(tostring(err))
    else
        debugc('[' .. dunderPackageName .. '] booted successfully')
    end

    print("=== Loaded Lua Packages ===")
    for k in pairs(package.loaded) do
        if tostring(k):find(dunderPackageName, 1, true) then
            print("* " .. k)
        else
            print("  " .. k)
        end
    end
    print("=== End of Loaded Packages ===")
end
