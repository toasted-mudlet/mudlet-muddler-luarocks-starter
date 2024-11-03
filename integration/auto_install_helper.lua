--[[
    Automatic reinstall helper for Mudlet/muddler

    Adapted from examples by https://github.com/demonnic/muddler/wiki/CI.

    -- Usage --
    1. Set MUDLET_PACKAGE_NAME to your Mudlet package name.
    2. Set PACKAGE_PATH to the muddler directory (where it creates .output)
    3. Add Lua module patterns to UNCACHE_MODULES for auto reinstall support.
    4. Install or update this script in your Mudlet profile.

    Tested with Mudlet 4.18.5 and muddler 1.1.0

    -- Important --
    After installing or updating this script, you must reload your profile for
    changes to take effect.

    For more information on muddler see: https://github.com/demonnic/muddler
]]

-- Configuration
local MUDLET_PACKAGE_NAME = 'muddler_luarocks_starter'
local PACKAGE_PATH = '/home/user/projects/my-mudlet-package/muddler'
local UNCACHE_MODULES = {MUDLET_PACKAGE_NAME -- Always uncache your own Lua module
-- 'my_lib',
-- 'another_lib',
}

-- Main
local SAFE_PACKAGE_NAME = MUDLET_PACKAGE_NAME:gsub('[^%w_]', '_')
local HELPER_VAR = '__' ..  SAFE_PACKAGE_NAME .. '__muddler_reinstall_helper__'

local function validate_path()
    if not lfs or not lfs.attributes(PACKAGE_PATH, 'mode') then
        debugc('[muddler-support] ERROR: path not found: ' .. PACKAGE_PATH)
        return false
    end
    return true
end

local function validate_muddler_installed()
    if not Muddler then
        debugc('[muddler-support] ERROR: required Muddler package is not installed')
        return false
    end
    return true
end

local function uncache_modules()
    for moduleName, _ in pairs(package.loaded) do
        for _, pattern in ipairs(UNCACHE_MODULES) do
            if moduleName:find(pattern) then
                debugc('[muddler-support] uncaching Lua module "' .. moduleName .. '"')
                package.loaded[moduleName] = nil
                break
            end
        end
    end
end

local function install_helper()
    debugc('[muddler-support] initializing for "' .. MUDLET_PACKAGE_NAME .. '"')

    if not validate_path() then return end
    if not validate_muddler_installed() then return end

    if _G[HELPER_VAR] and _G[HELPER_VAR].muddler then
        _G[HELPER_VAR].muddler:stop()
    end

    local status, muddler = pcall(function()
        return Muddler:new({
            path = PACKAGE_PATH,
            postremove = uncache_modules
        })
    end)
    if not status then
        debugc('[muddler-support] ERROR: failed to initialize Muddler: ' .. tostring(muddler))
        return
    end

    _G[HELPER_VAR] = _G[HELPER_VAR] or {}
    _G[HELPER_VAR].muddler = muddler
end

_G[HELPER_VAR] = _G[HELPER_VAR] or {}
if _G[HELPER_VAR].handlerID then
    killAnonymousEventHandler(_G[HELPER_VAR].handlerID)
end
_G[HELPER_VAR].handlerID = registerAnonymousEventHandler('sysLoadEvent', install_helper)

debugc('[muddler-support] active for "' .. MUDLET_PACKAGE_NAME .. '", see variable "' .. HELPER_VAR .. '"')

