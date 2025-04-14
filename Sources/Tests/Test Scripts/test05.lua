-- test05
-- Test to see if we:
-- * call foreign functions in AHK.

foreign("showMessage")("Hello World!")

print("Success")
