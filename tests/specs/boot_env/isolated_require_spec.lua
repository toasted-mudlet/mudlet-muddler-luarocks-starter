local isolated_require = require('boot_env.isolated_require')

local base = './tests/test_modules'
local packageId = '__isolated__'

local scriptPathLua = base .. '/?.lua'
local scriptPathInit = base .. '/?/init.lua'
local luaModulesPathLua = ''
local luaModulesPathInit = ''

describe('isolated_require (basic)', function()
    local require_
    local namespace = {}

    setup(function()
        require_ = isolated_require(packageId, scriptPathLua, scriptPathInit, luaModulesPathLua,
            luaModulesPathInit, namespace)
    end)

    it('loads a simple module', function()
        local foo = require_('foo')
        assert.is_table(foo)
        assert.are.equal('foo value', foo.foo)
        assert.is_truthy(package.loaded[packageId .. 'foo'])
    end)

    it('loads an init.lua module', function()
        local bar = require_('bar')
        assert.is_table(bar)
        assert.are.equal('bar value', bar.bar)
        assert.is_truthy(package.loaded[packageId .. 'bar'])
    end)

    it('returns error for missing module', function()
        assert.has_error(function()
            require_('notfound')
        end)
    end)

    it('does not leak modules globally', function()
        assert.is_nil(package.loaded['foo'])
        assert.is_nil(package.loaded['bar'])
    end)
end)

describe('isolated_require (advanced)', function()
    local require_
    local namespace

    before_each(function()
        namespace = {}
        require_ = isolated_require(packageId, scriptPathLua, scriptPathInit, luaModulesPathLua,
            luaModulesPathInit, namespace)
        namespace.require = require_
    end)

    it('handles nested requires', function()
        local nested = require_('nested')
        assert.is_table(nested)
        assert.are.equal('nested', nested.value)
        assert.is_table(nested.inner)
        assert.are.equal('inner', nested.inner.value)
        assert.is_truthy(package.loaded[packageId .. 'nested'])
        assert.is_truthy(package.loaded[packageId .. 'inner'])
    end)

    it('handles circular dependencies', function()
        local a = require_('circular_a')
        local b = require_('circular_b')

        assert.is_table(a)
        assert.is_table(b)
        assert.are.equal('a', a.name)
        assert.are.equal('b', b.name)

        assert.is_table(a.b)
        assert.is_table(b.a)
    end)
end)
