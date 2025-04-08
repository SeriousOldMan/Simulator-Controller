-- test04
-- Test to see if we:
-- * load custom modules.

package.path = package.path .. ";" .. modulesFolder

require("module04")

module.success()
