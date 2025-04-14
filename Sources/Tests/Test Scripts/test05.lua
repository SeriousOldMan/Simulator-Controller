-- test05
-- Test to see if we:
-- * call foreign functions in AHK.

local show = foreign("showMessage")

show("Hello World!")

print("Success")
