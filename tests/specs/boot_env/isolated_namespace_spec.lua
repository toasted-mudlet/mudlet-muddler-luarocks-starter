local isolatedRequireCreator = require('boot_env.isolated_require')
local isolatedNamespaceCreator = require('boot_env.isolated_namespace')

local base = './tests/test_modules'
local dunderPackageName = '__isolated__'

local scriptPathLua = base .. '/?.lua'
local scriptPathInit = base .. '/?/init.lua'
local luaModulesPathLua = ''
local luaModulesPathInit = ''

describe('isolated_namespace', function()
    local require_
    local namespace

    local setupIsolatedNamespace = function()
        namespace = isolatedNamespaceCreator()
        require_ = isolatedRequireCreator(dunderPackageName, scriptPathLua, scriptPathInit, luaModulesPathLua,
            luaModulesPathInit, namespace)
        namespace.require = require_
        setfenv(1, namespace)
    end

    local tearDownIsolatedNamespace = function()
        setfenv(1, _G)
        require_ = nil
        namespace = {}
    end

    before_each(function()
        _G.attempted = nil
        package.loaded['lfs'] = nil
    end)

    after_each(function()
        package.loaded['lfs'] = nil
        _G.attempted = nil
    end)

    it("locks the namespace metatable", function()
        setupIsolatedNamespace()

        local mt = getmetatable(namespace)
        assert.is_false(mt)

        tearDownIsolatedNamespace()
    end)

    it('does not fallback to global require', function()
        setupIsolatedNamespace()

        package.loaded['lfs'] = function()
            return 'should not be loaded'
        end

        assert.has_error(function()
            require_('lfs')
        end)
        assert.is_nil(package.loaded[dunderPackageName .. 'lfs'])

        tearDownIsolatedNamespace()
    end)

    it('does not leak bare global assignment into _G, but sets it in the namespace', function()
        setupIsolatedNamespace()

        assert.is_nil(_G.polluted)
        assert.is_nil(namespace.polluted)

        require_('global_polluter')

        assert.is_nil(_G.polluted)
        assert.is_true(namespace.polluted)

        tearDownIsolatedNamespace()
    end)

    it("directly writing to _G is still possible", function()
        setupIsolatedNamespace()

        _G.my_global = "original"
        assert.are.equal("original", _G.my_global)

        _G.my_global = "overwritten"
        assert.are.equal("overwritten", _G.my_global)

        _G.my_global = nil

        tearDownIsolatedNamespace()
    end)

end)

