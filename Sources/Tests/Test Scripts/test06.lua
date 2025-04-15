-- test05
-- Test to see if we:
-- * can use HTTP in Lua.

httpGet = foreign("httpGet")
httpPost = foreign("httpPost")

text = httpGet("https://api.chucknorris.io/jokes/random")

foreign("showMessage")(text)

print("Success")
