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
#Include "AHKUnit\AHKUnit.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Private Variables Section                       ;;;
;;;-------------------------------------------------------------------------;;;

global vLuaResult := false


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

	vTestResult := msg

	; showMessage(msg)
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

		vTestResult := false

		L := luaL_newstate()

		luaL_openlibs(L)

		username := "Peter Hugendubel"

		lua_pushstring(L, String(username))

		lua_setglobal(L, "username")

		setPrint(L, lua_print)

		luaL_dofile(L, kSourcesDirectory . "Tests\Test Scripts\test01.lua")

		this.AssertEqual(userName, vTestResult, "Global variable binding failed...")
	}
}

class BasicTest extends Assert {
	Assert_Test() {
		global vTestResult

		vTestResult := false

		L := luaL_newstate()

		luaL_openlibs(L)

		setPrint(L, lua_print)

		luaL_dofile(L, kSourcesDirectory . "Tests\Test Scripts\test02.lua")

		this.AssertEqual(vTestResult, "Success", "Assert handling failed...")
	}
}

class SharedDataTest extends Assert {
	Table_Test() {
		global vTestResult

		vTestResult := false

		L := luaL_newstate()

		luaL_openlibs(L)

		setPrint(L, lua_print)

		tab := LuaTable(L, 0, 3)
			.add("name",    "str",  A_ScriptName)
			.add("version", "str",  A_AhkVersion)
			.add("test",    "func", lua_test)
			.finish("globs")

		luaL_dofile(L, kSourcesDirectory . "Tests\Test Scripts\test03.lua")

		this.AssertTrue(vTestResult, "Table handling failed...")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

AHKUnit.AddTestClass(IntegrationTest)
AHKUnit.AddTestClass(BasicTest)
AHKUnit.AddTestClass(SharedDataTest)

AHKUnit.Run()