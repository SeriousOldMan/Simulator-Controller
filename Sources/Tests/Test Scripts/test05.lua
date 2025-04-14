-- test05
-- Test to see if we:
-- * call foreign functions in AHK.

function foreign(name)
	local handler = __Foreign(name)
	
	return function(...)
			   return handler(table.unpack(__normalizeArguments(table.pack(...))))
		   end
end

foreign("showMessage")("Hello World!")

print("Success")
