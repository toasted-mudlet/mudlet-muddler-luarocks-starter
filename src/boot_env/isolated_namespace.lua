--- Creates a new isolated namespace table.
-- The namespace inherits from the global environment (_G) but protects its metatable.
-- @return table An isolated namespace table with _G as its __index.
return function()
    local namespace = {}
    setmetatable(namespace, {
        __index = _G,
        __metatable = false,
        __newindex = function(t, k, v)
            rawset(t, k, v)
        end
    })

    return namespace
end
