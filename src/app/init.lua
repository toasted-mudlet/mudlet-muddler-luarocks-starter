local inspect = require('inspect')

local Application = {}
Application.__index = Application

function Application:new(opts)
    local self = setmetatable({}, Application)
    return self
end

function Application:start(packageId, packageName)
    debugc('[' .. packageId .. '] Application started')
    cecho('<yellow>[ INFO ]  - ' ..  packageName .. ': Application started!\n')
end

return Application
