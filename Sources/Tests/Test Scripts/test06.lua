-- test06
-- Test to see if we:
-- * can use HTTP in Lua.


local lunajson = require("lunajson")

httpGet = extern("httpGet")
httpPost = extern("httpPost")

text = lunajson.decode(httpGet("https://api.chucknorris.io/jokes/random")).value

extern("MsgBox")(text)

print("Success")
