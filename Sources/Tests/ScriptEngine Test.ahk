;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - ScriptEngine Test               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#Requires AutoHotkey >=2.0
#SingleInstance Force			; Ony one instance allowed
#Warn							; Enable warnings to assist with detecting common errors.
#Warn LocalSameAsGlobal, Off

SendMode("Input")				; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir)		; Ensures a consistent starting directory.


global kBuildConfiguration := "Development"


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Extensions\ScriptEngine.ahk"
#Include "..\Framework\Extensions\HTTP.ahk"
#Include "AHKUnit\AHKUnit.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Private Variables Section                       ;;;
;;;-------------------------------------------------------------------------;;;

global vTestResult := []
global vTestExports := []


;;;-------------------------------------------------------------------------;;;
;;;                         Private Function Section                        ;;;
;;;-------------------------------------------------------------------------;;;

setPrint(L, fn) {
	lua_pushcclosure(L, CallbackCreate(fn, , 1), 0)

	lua_setglobal(L, "print")
}

lua_test(L) {
	msg := lua_tolstring(L, 1, 0)

	; showMessage("TEST: " . msg . "`n")
}

lua_print(L) {
	global vTestResult

	msg := lua_tolstring(L, 1, 0)

	vTestResult.Push(msg)
}

intern(value) {
	global vTestExports

	vTestExports.Push(value)
}

add(v1, v2) {
	return (v1 + v2)
}

arraysEqual(a1, a2) {
	if (isInstance(a1, Array) && isInstance(a2, Array) && (a1.Length = a2.Length)) {
		loop a1.Length {
			v1 := a1[A_Index]
			v2 := a2[A_Index]

			if (isInstance(v1, Array) || isInstance(v2, Array)) {
				if !arraysEqual(v1, v2)
					return false
			}
			else if (v1 != v2)
				return false
		}

		return true
	}
	else
		return false
}


;;;-------------------------------------------------------------------------;;;
;;;                         Private Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class LuaTable {
	__New(L, narr, nrec) {
		this.L := L

		lua_createtable(this.L, narr, nrec)
	}

	add(key, form, value := unset) {
		lua_pushstring(this.L, key)

		switch form, false {
			case "str":
				if !IsSet(value)
					throw Error("Value was not set", -1)

				lua_pushstring(this.L, String(value))
			case "int":
				if !IsSet(value)
					throw Error("Value was not set", -1)

				lua_pushinteger(this.L, Integer(value))
			case "null", "nil":
				lua_pushnil(this.L)
			case "func", "fn":
				if !IsSet(value)
					throw Error("Value was not set", -1)

				lua_pushcclosure(this.L, CallbackCreate(value,, 1), 0)
			default:
				throw Error("Unknown value type", -1, String(form))
		}

		lua_settable(this.L, -3)

		return this
	}

	finish(table_name) {
		lua_setglobal(this.L, table_name)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                              Test Section                               ;;;
;;;-------------------------------------------------------------------------;;;

class IntegrationTest extends Assert {
	Print_Test() {
		global vTestResult

		vTestResult := []

		L := luaL_newstate()

		luaL_openlibs(L)

		username := "Peter Hugendubel"

		lua_pushstring(L, String(username))

		lua_setglobal(L, "username")

		setPrint(L, lua_print)

		luaL_dofile(L, kSourcesDirectory . "Tests\Test Scripts\test01.lua")

		this.AssertTrue(vTestResult.Length > 0, "Global variable binding failed...")
		this.AssertEqual(userName, vTestResult[1], "Global variable binding failed...")

		lua_close(L)
	}
}

class BasicTest extends Assert {
	Assert_Test() {
		global vTestResult

		vTestResult := []

		L := luaL_newstate()

		luaL_openlibs(L)

		setPrint(L, lua_print)

		luaL_dofile(L, kSourcesDirectory . "Tests\Test Scripts\test02.lua")

		this.AssertTrue(vTestResult.Length > 0, "Assert handling failed...")
		this.AssertEqual(vTestResult[1], "Success", "Assert handling failed...")

		lua_close(L)
	}

	Foreign_Test() {
		global vTestResult

		vTestResult := []

		L := luaL_newstate()

		luaL_openlibs(L)

		setPrint(L, lua_print)

		scriptPushValue(L, (c) {
			local function := %scriptGetString(c, 1)%

			scriptPushValue(c, (c) {
				scriptPushValue(c, function(scriptGetArguments(c)*))

				return Integer(1)
			})

			return Integer(1)
		})
		scriptSetGlobal(L, "foreign")

		luaL_dofile(L, kSourcesDirectory . "Tests\Test Scripts\test05.lua")

		this.AssertTrue(vTestResult.Length > 0, "Foreign function calling failed...")
		this.AssertEqual(vTestResult[1], "Success", "Foreign function calling failed...")

		lua_close(L)
	}

	JSON_Test() {
		global vTestResult

		vTestResult := []

		RunWait(A_ComSpec . " /c `"luarocks install lunajson`"")

		L := scriptOpenContext()

		setPrint(L, lua_print)

		luaL_dofile(L, kSourcesDirectory . "Tests\Test Scripts\test07.lua")

		this.AssertTrue(vTestResult.Length = 3, "Library loading failed...")
		this.AssertEqual(vTestResult[1], 1.5, "Library loading failed...")
		this.AssertEqual(vTestResult[2], "{`"Hello`":[`"lunajson`",1.5]}", "Library loading failed...")
		this.AssertEqual(vTestResult[3], "Success", "Library loading failed...")

		scriptCloseContext(L)
	}

	Http_Test() {
		global vTestResult

		vTestResult := []

		RunWait(A_ComSpec . " /c `"luarocks install lunajson`"")

		L := scriptOpenContext()

		setPrint(L, lua_print)

		luaL_dofile(L, kSourcesDirectory . "Tests\Test Scripts\test06.lua")

		this.AssertTrue(vTestResult.Length > 0, "HTTP integration failed...")
		this.AssertEqual(vTestResult[1], "Success", "HTTP integration failed...")

		scriptCloseContext(L)
	}
}

class SharedDataTest extends Assert {
	Table_Test() {
		global vTestResult

		vTestResult := []

		L := luaL_newstate()

		luaL_openlibs(L)

		setPrint(L, lua_print)

		tab := LuaTable(L, 0, 3)
			.add("name",    "str",  A_ScriptName)
			.add("version", "str",  A_AhkVersion)
			.add("test",    "func", lua_test)
			.finish("globs")

		luaL_dofile(L, kSourcesDirectory . "Tests\Test Scripts\test03.lua")

		this.AssertTrue(vTestResult.Length > 0, "Table handling failed...")
		this.AssertEqual(vTestResult[vTestResult.Length], "Success", "Table handling failed...")

		lua_close(L)
	}

	Builtin_Table_Test() {
		global vTestResult
		global vTestExports

		vTestResult := []
		vTestExports := []

		L := scriptOpenContext()

		setPrint(L, lua_print)

		scriptPushArray(L, ["One", "Two", ["Three", 4]])
		scriptSetGlobal(L, "Arguments")

		luaL_dofile(L, kSourcesDirectory . "Tests\Test Scripts\test08.lua")

		this.AssertTrue(vTestResult.Length > 0, "Table handling failed...")
		this.AssertTrue(vTestResult[1], "Table handling failed...")
		this.AssertEqual(vTestExports[1], "One", "Table handling failed...")
		this.AssertEqual(vTestExports[2], "Two", "Table handling failed...")
		this.AssertTrue(arraysEqual(vTestExports[3], ["Three", 4]), "Table handling failed...")

		scriptCloseContext(L)
	}
}

class LibraryTest extends Assert {
	Module_Test() {
		global vTestResult

		vTestResult := []

		L := luaL_newstate()

		luaL_openlibs(L)

		setPrint(L, lua_print)

		lua_pushstring(L, kSourcesDirectory . "Tests\Test Scripts\?.lua")

		lua_setglobal(L, "modulesFolder")

		luaL_dofile(L, kSourcesDirectory . "Tests\Test Scripts\test04.lua")

		this.AssertTrue(vTestResult.Length > 0, "Module loading failed...")
		this.AssertTrue(vTestResult[1], "Module loading failed...")

		lua_close(L)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

AHKUnit.AddTestClass(IntegrationTest)
AHKUnit.AddTestClass(BasicTest)
AHKUnit.AddTestClass(SharedDataTest)
AHKUnit.AddTestClass(LibraryTest)

AHKUnit.Run()