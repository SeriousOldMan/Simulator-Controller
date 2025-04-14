-- test05
-- Test to see if we:
-- * call foreign functions in AHK.

function __normalizeArguments(arguments)
	for i = 1, #arguments do
		arguments[i] = tostring(arguments[i])
	end
	
	return arguments
end

-- function foreign(name)
	-- local handler = __Foreign(name)
	
	-- return function(...)
			   -- return handler(table.unpack(__normalizeArguments(table.pack(...))))
		   -- end
-- end

foreign = __Foreign

foreign("showMessage")("Hello World!")

print("Success")
