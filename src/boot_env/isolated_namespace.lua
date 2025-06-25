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
