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

return function(namespaceId, scriptPathLua, scriptPathInit, luaModulesPathLua, luaModulesPathInit, env)
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
