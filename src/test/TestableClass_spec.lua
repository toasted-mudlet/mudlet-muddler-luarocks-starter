local TestableClass = require 'test.TestableClass'

describe('TestableClass', function()
    local obj

    before_each(function()
        obj = TestableClass:new()
    end)

    it('sums two positive numbers', function()
        assert.are.equal(7, obj:sum(3, 4))
    end)

    it('sums negative and positive numbers', function()
        assert.are.equal(0, obj:sum(-1, 1))
    end)

    it('sums two zeros', function()
        assert.are.equal(0, obj:sum(0, 0))
    end)
end)
