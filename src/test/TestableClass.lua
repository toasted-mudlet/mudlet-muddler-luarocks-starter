local TestableClass = {}
TestableClass.__index = TestableClass

function TestableClass:new()
    local self = setmetatable({}, TestableClass)
    return self
end

function TestableClass:sum(a, b)
    return a + b
end

return TestableClass
