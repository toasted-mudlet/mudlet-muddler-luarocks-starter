print("Testing Lua Environment")
print("=======================")

print("Lua Version: " .. _VERSION)

print("\npackage.path:")
for path in package.path:gmatch("[^;]+") do
    print("  " .. path)
end

print("\npackage.cpath:")
for path in package.cpath:gmatch("[^;]+") do
    print("  " .. path)
end

print("\nTrying to load an internal module from src ('test'):")
local status, module = pcall(require, "test")
if status then
    print("  Successfully loaded 'test'")
else
    print("  Failed to load 'test': " .. tostring(module))
end

print("\nTrying to load a LuaRocks module 'inspect':")
local status, inspect = pcall(require, "inspect")
if status then
    local test = {1, 2, 3}
    print("  Successfully loaded 'inspect'")
    print("  Inspect test table: " .. inspect(test))
else
    print("  Failed to load 'inspect': " .. tostring(inspect))
end

print("\nEnvironment test completed.")
