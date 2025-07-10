local version = _VERSION:match("%d+%.%d+")
local path_sep = package.config and package.config:sub(3,3) or ';'

local paths = {
    "./src/?.lua",
    "./src/?/init.lua",
    "lua_modules/share/lua/" .. version .. "/?.lua",
    "lua_modules/share/lua/" .. version .. "/?/init.lua",
    package.path
}
package.path = table.concat(paths, path_sep)

local cpaths = {
    "lua_modules/lib/lua/" .. version .. "/?.so",
    package.cpath
}
package.cpath = table.concat(cpaths, path_sep)
