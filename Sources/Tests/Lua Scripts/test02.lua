-- test02
-- Test to see if we:
-- * Can run Lua through AHK.
-- * Can work with objects within itself smoothly.
-- * Can test if assert works.


local M = {}

function M.func1()
  return 1
end

function M.func2()
  return 2
end

-- this is a test function for the module function `M.func1()`
local function test_func1()
  assert( M.func1() == 1, "func1() should always return 1" )
  assert( M.func1() ~= 2, "func1() should never return 2" )
  assert( type( M.func1() ) == "number" )
end

-- this is a test function for the module function `M.func2()`
local function test_func2()
  assert( M.func2() == 2 )
  assert( M.func2() ~= M.func1() )
end

-- this is a provoked assertion failure`
local function test_func2_fail()
  assert( M.func2() == 1, "func2() may return 1" )
end

test_func1()
test_func2()

print("Success")

test_func2_fail()

print("Fail")