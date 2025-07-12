local pathSep = package.config and package.config:sub(3,3) or ';'

local function escapePattern(s)
    return (s:gsub("([^%w])", "%%%1"))
end

local function addPath(existingPaths, newPath, pathSep)
    if existingPaths == '' then
        return newPath
    elseif not string.find(existingPaths, newPath, 1, true) then
        return newPath .. pathSep .. existingPaths
    end
    return existingPaths
end

--- Creates a namespaced module loader with isolated environment and search paths.
-- @param namespaceId string: The namespace prefix for module IDs.
-- @param scriptPathLua string: Path for Lua scripts.
-- @param scriptPathInit string: Path for Lua init scripts.
-- @param luaModulesPathLua string: Path for Lua modules.
-- @param luaModulesPathInit string: Path for Lua module init scripts.
-- @param env table: The environment table for loaded modules.
-- @return function: A loader function that takes a module name and returns the loaded module.
return function(namespaceId, scriptPathLua, scriptPathInit, luaModulesPathLua, luaModulesPathInit, env)

    --- Loads a module in the configured namespace, searching in the configured paths and using the configured environment.
    -- @param moduleName string The name of the module to load (without namespace prefix).
    -- @return any The loaded module (table or value), or raises an error if not found.
    return function(moduleName)
        local namespacedModuleId = namespaceId .. "." .. moduleName

        -- 1. cached namespaced module
        if package.loaded[namespacedModuleId] then
            return package.loaded[namespacedModuleId]
        end

        -- 2. namespaced module preload
        local loader = package.preload[namespacedModuleId]
        if loader then
            local placeholder = {}
            package.loaded[namespacedModuleId] = placeholder
            local ok, res = pcall(loader, namespacedModuleId)
            if not ok then
                package.loaded[namespacedModuleId] = nil
                error(res)
            end
            if type(res) == 'table' then
                -- Copy fields into the placeholder
                for k, v in pairs(res) do
                    placeholder[k] = v
                end
                setmetatable(placeholder, getmetatable(res))
                return placeholder
            elseif res ~= nil then
                package.loaded[namespacedModuleId] = res
                return res
            else
                return placeholder
            end
        end

        -- 3. Search for file
        local old_path = package.path
        package.path = addPath(addPath(addPath(addPath(package.path, scriptPathLua, pathSep), scriptPathInit, pathSep),
                luaModulesPathLua, pathSep), luaModulesPathInit, pathSep)

        local errmsg = ''
        local fname
        local sepPattern = escapePattern(pathSep)
        for path in string.gmatch(package.path, '[^' .. sepPattern .. ']+') do
            local f = path:gsub('?', (moduleName:gsub('%.', '/')))
            local file = io.open(f, 'r')
            if file then
                fname = f
                file:close()
                break
            else
                errmsg = errmsg .. '\n\tno file "' .. f .. '"'
            end
        end
        if not fname then
            package.path = old_path
            error('module "' .. moduleName .. '" not found:' .. errmsg)
        end

        -- 4. Insert placeholder for circular dependencies
        local placeholder = {}
        package.loaded[namespacedModuleId] = placeholder

        -- 5. Load and run the chunk, with error handling and guaranteed path restoration
        local ok, res
        local chunk = assert(loadfile(fname))
        setfenv(chunk, env)
        ok, res = pcall(chunk)
        package.path = old_path

        if not ok then
            package.loaded[namespacedModuleId] = nil
            error(res)
        end

        if type(res) == 'table' then
            for k, v in pairs(res) do
                placeholder[k] = v
            end
            setmetatable(placeholder, getmetatable(res))
            return placeholder
        elseif res ~= nil then
            package.loaded[namespacedModuleId] = res
            return res
        else
            return placeholder
        end
    end
end
