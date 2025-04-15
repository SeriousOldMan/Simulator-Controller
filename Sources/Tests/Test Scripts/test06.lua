-- test05
-- Test to see if we:
-- * can use HTTP in Lua.

httpGet = foreign("httpGet")
httpPut = foreign("httpPut")

text := httpGet("https://api.chucknorris.io/jokes/random")

foreign("MsgBox")(text)

print("Success")
