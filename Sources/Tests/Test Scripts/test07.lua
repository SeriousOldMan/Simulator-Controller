-- test07
-- Test to see if we:
-- * can use a JSON module.

local lunajson = require 'lunajson'
local jsonstr = '{"Hello":["lunajson",1.5]}'
local t = lunajson.decode(jsonstr)

print(t.Hello[2])         -- => 1.5
print(lunajson.encode(t)) -- => {"Hello":["lunajson",1.5]}

print("Success")
