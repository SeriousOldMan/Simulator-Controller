-- test03
-- Test to see if we:
-- * Can create custom tables from AHK into Lua.


-- checkExists(obj: Object, prop: String) -> Boolean
function checkExists(obj, prop)
	return pcall(function() return obj[prop] end)
end

-- Read properties.
print(globs.name .. " - " .. globs.version .. "\n")

-- Check if the function "test" exists, if so then run it.
if checkExists(globs, "test") then
	globs.test("Hello world")
else
	print("The function is missing or mispelled.")
end
