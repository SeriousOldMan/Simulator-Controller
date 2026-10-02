-- test05
-- Test to see if we:
-- * call foreign functions in AHK.


assert(foreign("add")(1, 2) == 3)

foreign("showMessage")("Hello World!")

print("Success")
