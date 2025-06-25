-- Main Mudlet Lua API Reference: https://wiki.mudlet.org/w/Manual:Lua_Functions
local CALLBACK_FUNCTIONS = {
    --
    -- ++++ Event handling ++++
    --

    -- registerAnonymousEventHandler(eventName, handler)
    -- https://wiki.mudlet.org/w/Manual:Lua_Functions#registerAnonymousEventHandler
    { name = "registerAnonymousEventHandler", wrapArgs = {2} },

    -- registerNamedEventHandler(userName, handlerName, eventName, handler)
    -- https://wiki.mudlet.org/w/Manual:Lua_Functions#registerNamedEventHandler
    { name = "registerNamedEventHandler", wrapArgs = {4} },

    --
    -- ++++ Timers ++++
    --

    -- tempTimer(delayInSeconds, handler)
    -- https://wiki.mudlet.org/w/Manual:Lua_Functions#tempTimer
    { name = "tempTimer", wrapArgs = {2} },

    -- registerNamedTimer(userName, timerName, delayInSeconds, handler)
    -- https://wiki.mudlet.org/w/Manual:Lua_Functions#registerNamedTimer
    { name = "registerNamedTimer", wrapArgs = {4} },

    --
    -- ++++ Triggers ++++
    --

    -- tempTrigger(pattern, handler)
    -- https://wiki.mudlet.org/w/Manual:Lua_Functions#tempTrigger
    { name = "tempTrigger", wrapArgs = {2} },

    -- tempRegexTrigger(pattern, handler)
    -- https://wiki.mudlet.org/w/Manual:Lua_Functions#tempRegexTrigger
    { name = "tempRegexTrigger", wrapArgs = {2} },

    -- tempExactMatchTrigger(pattern, handler)
    -- https://wiki.mudlet.org/w/Manual:Lua_Functions#tempExactMatchTrigger
    { name = "tempExactMatchTrigger", wrapArgs = {2} },

    -- tempBeginOfLineTrigger(pattern, handler)
    -- https://wiki.mudlet.org/w/Manual:Lua_Functions#tempBeginOfLineTrigger
    { name = "tempBeginOfLineTrigger", wrapArgs = {2} },

    -- tempLineTrigger(lineNumber, handler)
    -- https://wiki.mudlet.org/w/Manual:Lua_Functions#tempLineTrigger
    { name = "tempLineTrigger", wrapArgs = {2} },

    -- tempComplexRegexTrigger(patternsTable, handler)
    -- https://wiki.mudlet.org/w/Manual:Lua_Functions#tempComplexRegexTrigger
    { name = "tempComplexRegexTrigger", wrapArgs = {2} },

    -- tempPromptTrigger(handler)
    -- https://wiki.mudlet.org/w/Manual:Lua_Functions#tempPromptTrigger
    { name = "tempPromptTrigger", wrapArgs = {1} },

    --
    -- ++++ Aliases ++++
    --

    -- tempAlias(pattern, handler)
    -- https://wiki.mudlet.org/w/Manual:Lua_Functions#tempAlias
    { name = "tempAlias", wrapArgs = {2} },

    --
    -- ++++ UI callbacks ++++
    --

    -- setLabelClickCallback(labelName, handler)
    -- https://wiki.mudlet.org/w/Manual:Lua_Functions#setLabelClickCallback
    { name = "setLabelClickCallback", wrapArgs = {2} },
}

return function(namespace)
      --[[
           Wraps a handler so it always runs in the correct environment.
           - If handler is a function: returns a closure that sets its environment to `namespace` at call time.
           - If handler is a string: compiles it and sets its environment to `namespace`.
           - Otherwise, returns the handler as-is.
       ]]
       local function wrapHandler(handler)
           if type(handler) == "function" then
               return function(...)
                   setfenv(handler, namespace)
                   return handler(...)
               end
           elseif type(handler) == "string" then
               local f, err = loadstring(handler)
               if not f then error("Invalid Lua code: " .. err) end
               setfenv(f, namespace)
               return f
           end
           return handler
       end

    local function createWrapper(originalFunc, wrapArgs)
        return function(...)
            local args = {...}
            for _, idx in ipairs(wrapArgs) do
                if args[idx] then
                    args[idx] = wrapHandler(args[idx])
                end
            end
            return originalFunc(unpack(args))
        end
    end

    -- Special case: tempAnsiColorTrigger
    -- https://wiki.mudlet.org/w/Manual:Lua_Functions#tempAnsiColorTrigger
    -- Signature: tempAnsiColorTrigger(fgColor[, bgColor], code[, expireAfter])
    local orig_tempAnsiColorTrigger = _G.tempAnsiColorTrigger
    if orig_tempAnsiColorTrigger then
        namespace.tempAnsiColorTrigger = function(fg, bg_or_code, code_or_expire, expireAfter)
            if type(bg_or_code) == "function" or type(bg_or_code) == "string" then
                -- Called as tempAnsiColorTrigger(fg, code[, expireAfter])
                local code = wrapHandler(bg_or_code)
                return orig_tempAnsiColorTrigger(fg, code, code_or_expire)
            else
                -- Called as tempAnsiColorTrigger(fg, bg, code[, expireAfter])
                local code = wrapHandler(code_or_expire)
                return orig_tempAnsiColorTrigger(fg, bg_or_code, code, expireAfter)
            end
        end
    end

    -- Special case: tempKey
    -- https://wiki.mudlet.org/w/Manual:Lua_Functions#tempKey
    -- Signature: tempKey([modifiers,] key, code)
    local orig_tempKey = _G.tempKey
    if orig_tempKey then
        namespace.tempKey = function(mod_or_key, key_or_code, code)
            if type(key_or_code) == "function" or type(key_or_code) == "string" then
                -- Called as tempKey(key, code)
                code = wrapHandler(key_or_code)
                return orig_tempKey(mod_or_key, code)
            else
                -- Called as tempKey(modifiers, key, code)
                code = wrapHandler(code)
                return orig_tempKey(mod_or_key, key_or_code, code)
            end
        end
    end

    -- Wrap all other functions as usual
    for _, entry in ipairs(CALLBACK_FUNCTIONS) do
        local orig = _G[entry.name]
        if orig then
            namespace[entry.name] = createWrapper(orig, entry.wrapArgs)
        end
    end

    if not getmetatable(namespace) then
        setmetatable(namespace, { __index = _G })
    end
end
