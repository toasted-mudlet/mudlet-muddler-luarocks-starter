local pathSep = ';'

local function addPath(existingPaths, newPath, pathSep)
    if existingPaths == '' then
        return newPath
    elseif not string.find(existingPaths, newPath, 1, true) then
        return newPath .. pathSep .. existingPaths
    end
    return existingPaths
end

return function(dunderPackageName, scriptPathLua, scriptPathInit, luaModulesPathLua, luaModulesPathInit, env)
    return function(modname)
        local ns_modname = dunderPackageName .. modname

        -- 1. cached namespaced module
        if package.loaded[ns_modname] then
            return package.loaded[ns_modname]
        end

        -- 2. namespaced module preload
        local loader = package.preload[ns_modname]
        if loader then
            local placeholder = {}
            package.loaded[ns_modname] = placeholder
            local ok, res = pcall(loader, ns_modname)
            if not ok then
                package.loaded[ns_modname] = nil
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
                package.loaded[ns_modname] = res
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
        for path in string.gmatch(package.path, '[^;]+') do
            local f = path:gsub('?', (modname:gsub('%.', '/')))
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
            error('module "' .. modname .. '" not found:' .. errmsg)
        end

        -- 4. Insert placeholder for circular dependencies
        local placeholder = {}
        package.loaded[ns_modname] = placeholder

        -- 5. Load and run the chunk, with error handling and guaranteed path restoration
        local ok, res
        local chunk = assert(loadfile(fname))
        setfenv(chunk, env)
        ok, res = pcall(chunk)
        package.path = old_path

        if not ok then
            package.loaded[ns_modname] = nil
            error(res)
        end

        if type(res) == 'table' then
            for k, v in pairs(res) do
                placeholder[k] = v
            end
            setmetatable(placeholder, getmetatable(res))
            return placeholder
        elseif res ~= nil then
            package.loaded[ns_modname] = res
            return res
        else
            return placeholder
        end
    end
end
