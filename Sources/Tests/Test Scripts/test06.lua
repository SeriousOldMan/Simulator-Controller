-- test06
-- Test to see if we:
-- * can use HTTP in Lua.

package.path = package.path .. ";" .. __LRepository
package.cpath = package.cpath .. ";" .. __CRepository

local lunajson = require 'lunajson'

httpGet = foreign("httpGet")
httpPost = foreign("httpPost")

text = lunajson.decode(httpGet("https://api.chucknorris.io/jokes/random")).value

foreign("MsgBox")(text)

print("Success")
