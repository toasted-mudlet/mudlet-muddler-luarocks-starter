local boot_env = require 'boot_env.intercept_callback_registrations'

describe('Mudlet callback environment wrapper', function()
    local called_args

    local function create_namespace()
        local ns = {}
        boot_env(ns)
        return ns
    end

    after_each(function()
        _G.tempTrigger = nil
        _G.tempKey = nil
        _G.tempAnsiColorTrigger = nil
        _G.tempMouseEvent = nil
    end)

    describe('common callback wrappers', function()
        it('wraps tempTrigger handler as function', function()
            -- Mock tempTrigger to capture the arguments it receives for later inspection
            _G.tempTrigger = function(pattern, handler)
                called_args = {pattern, handler}
                return 'tempTriggerReturn'
            end

            -- Create a new namespace for the handler to write into
            local namespace = create_namespace()

            local handler_called = false
            -- The handler writes a unique value into its global environment
            local handler = function()
                test_magic_value = 42
                handler_called = true
            end

            -- Register the handler with the (mocked) tempTrigger via the wrapper
            local ret = namespace.tempTrigger('foo', handler)

            -- Confirm that tempTrigger returns the expected value
            assert.are.equal('tempTriggerReturn', ret)
            -- Confirm the first argument (the pattern) is correct
            assert.are.same('foo', called_args[1])
            -- Confirm the handler passed to tempTrigger is the wrapped version, not the original
            assert.not_same(called_args[2], handler)
            assert.is_function(called_args[2])

            -- Call the handler tempTimer received and confirm the original handler is called
            called_args[2]()
            assert.is_true(handler_called)

            -- Validate that the handler wrote into the correct namespace
            assert.are.equal(42, namespace.test_magic_value)
        end)

        it('wraps tempTrigger handler as string', function()
            _G.tempTrigger = function(pattern, handler)
                called_args = {pattern, handler}
                return 'tempTriggerReturn'
            end

            local namespace = create_namespace()
            local ret = namespace.tempTrigger('foo', 'test_magic_value = 99')
            assert.are.equal('tempTriggerReturn', ret)
            assert.are.same('foo', called_args[1])
            assert.is_function(called_args[2])

            called_args[2]()
            assert.are.equal(99, namespace.test_magic_value)
        end)
    end)

    describe('special-case wrappers', function()
        it('handles tempKey (key, code)', function()
            _G.tempKey = function(key, code)
                called_args = {key, code}
                return 'tempKeyReturn'
            end

            local namespace = create_namespace()
            local handler_called = false
            local handler = function()
                handler_called = true
            end
            local ret = namespace.tempKey(1, handler)
            assert.are.equal('tempKeyReturn', ret)
            assert.are.same(1, called_args[1])
            assert.is_function(called_args[2])
            called_args[2]()
            assert.is_true(handler_called)
        end)

        it('handles tempKey (mod, key, code)', function()
            _G.tempKey = function(mod, key, code)
                called_args = {mod, key, code}
                return 'tempKeyReturn'
            end

            local namespace = create_namespace()
            local handler_called = false
            local handler = function()
                handler_called = true
            end
            local ret = namespace.tempKey(1, 2, handler)
            assert.are.equal('tempKeyReturn', ret)
            assert.are.same(1, called_args[1])
            assert.are.same(2, called_args[2])
            assert.is_function(called_args[3])
            called_args[3]()
            assert.is_true(handler_called)
        end)

        it('handles tempAnsiColorTrigger (fg, code[, expire])', function()
            _G.tempAnsiColorTrigger = function(fg, code, expire)
                called_args = {fg, code, expire}
                return 'ansiReturn'
            end

            local namespace = create_namespace()
            local handler_called = false
            local handler = function()
                handler_called = true
            end
            local ret = namespace.tempAnsiColorTrigger(7, handler, 2)
            assert.are.equal('ansiReturn', ret)
            assert.are.same(7, called_args[1])
            assert.is_function(called_args[2])
            assert.are.equal(2, called_args[3])
            called_args[2]()
            assert.is_true(handler_called)
        end)

        it('handles tempAnsiColorTrigger (fg, bg, code[, expire])', function()
            _G.tempAnsiColorTrigger = function(fg, bg, code, expire)
                called_args = {fg, bg, code, expire}
                return 'ansiReturn'
            end

            local namespace = create_namespace()
            local handler_called = false
            local handler = function()
                handler_called = true
            end
            local ret = namespace.tempAnsiColorTrigger(7, 0, handler, 5)
            assert.are.equal('ansiReturn', ret)
            assert.are.same(7, called_args[1])
            assert.are.same(0, called_args[2])
            assert.is_function(called_args[3])
            assert.are.equal(5, called_args[4])
            called_args[3]()
            assert.is_true(handler_called)
        end)
    end)
end)
