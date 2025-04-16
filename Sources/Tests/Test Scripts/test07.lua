-- test07
-- Test to see if we:
-- * can use a JSON module.

package.path = package.path .. ";" .. __LRepository
package.cpath = package.cpath .. ";" .. __CRepository

local lunajson = require 'lunajson'
local jsonstr = '{"Hello":["lunajson",1.5]}'
local t = lunajson.decode(jsonstr)

foreign("showMessage")(t.Hello[2])         -- shows 1.5
foreign("showMessage")(lunajson.encode(t)) -- shows {"Hello":["lunajson",1.5]}

print("Success")
