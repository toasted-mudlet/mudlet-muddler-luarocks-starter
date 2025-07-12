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
    local packageId = '__' .. safePackageName .. '__'

    -- Path setup
    local sep = package.config:sub(1, 1)
    local mudletHomeDir = getMudletHomeDir()
    local basePath = mudletHomeDir .. sep .. packageName .. sep .. 'lua'

    -- Compose package-local paths
    local scriptPathLua = basePath .. sep .. 'scripts' .. sep .. '?.lua'
    local scriptPathInit = basePath .. sep .. 'scripts' .. sep .. '?' .. sep .. 'init.lua'
    local luaVersion = _VERSION:match('%d+%.%d+')
    local basePathLuaModules = basePath .. sep .. 'lua_modules' .. sep .. 'share' .. sep .. 'lua' .. sep .. luaVersion
    local luaModulesPathLua = basePathLuaModules .. sep .. '?.lua'
    local luaModulesPathInit = basePathLuaModules .. sep .. '?' .. sep .. 'init.lua'

    -- Load isolation helpers
    local isolatedNamespacePath = basePath .. sep .. 'scripts' .. sep .. 'boot_env' .. sep .. 'isolated_namespace.lua'
    local isolatedNamespaceCreator = assert(loadfile(isolatedNamespacePath))()

    local isolatedRequirePath = basePath .. sep .. 'scripts' .. sep .. 'boot_env' .. sep .. 'isolated_require.lua'
    local isolatedRequireCreator = assert(loadfile(isolatedRequirePath))()

    local interceptorPath = basePath .. sep .. 'scripts' .. sep .. 'boot_env' .. sep .. 'intercept_callback_registrations.lua'
    local interceptor = assert(loadfile(interceptorPath))()

    -- Create isolated namespace and runtime environment
    local namespace = isolatedNamespaceCreator()
    local require_ = isolatedRequireCreator(packageId, scriptPathLua, scriptPathInit, luaModulesPathLua,
            luaModulesPathInit, namespace)
    interceptor(namespace)

    namespace.require = require_
    _G[packageId] = namespace
    setfenv(1, namespace)

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
