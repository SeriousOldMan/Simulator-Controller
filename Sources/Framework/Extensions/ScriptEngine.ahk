;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Script Runtime                  ;;;
;;;                                                                         ;;;
;;;   Created from AHK code by Delta Pythagorean                            ;;;
;;;   (https://www.autohotkey.com/boards/viewtopic.php?style=10&t=122655)   ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                    Global Constants Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

global LUA_NULL                 := ""

global LUA_MULTRET              := -1

global LUA_OK                   := 0
global LUA_YIELD                := 1
global LUA_ERRRUN               := 2
global LUA_ERRSYNTAX            := 3
global LUA_ERRMEM               := 4
global LUA_ERRERR               := 5

global LUAI_MAXSTACK            := 1000000 ; A_PtrSize == 4 ? 1000000 : 15000
global LUA_MINSTACK             := 20

global LUA_REGISTRYINDEX        := (-LUAI_MAXSTACK - 1000)

global LUA_TNONE                := -1

global LUA_TNIL                 := 0
global LUA_TBOOLEAN             := 1
global LUA_TLIGHTUSERDATA       := 2
global LUA_TNUMBER              := 3
global LUA_TSTRING              := 4
global LUA_TTABLE               := 5
global LUA_TFUNCTION            := 6
global LUA_TUSERDATA            := 7
global LUA_TTHREAD              := 8

global LUA_NUMTYPES             := 9

global LUA_RIDX_MAINTHREAD      := 1
global LUA_RIDX_GLOBALS         := 2
global LUA_RIDX_LAST            := LUA_RIDX_GLOBALS

global LUA_NOREF                := -2
global LUA_REFNIL               := -1


;;;-------------------------------------------------------------------------;;;
;;;                    Private Variables Declaration Section                ;;;
;;;-------------------------------------------------------------------------;;;

global kLUALibrary := getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))
									 , "Script Engine", "Engine", "lua54.dll")
global kLUAEnvironment := Map()


;;;-------------------------------------------------------------------------;;;
;;;                    Private Functions Declaration Section                ;;;
;;;-------------------------------------------------------------------------;;;

luaL_loadfilex(L, filename, mode) => DllCall(kLUALibrary . "\luaL_loadfilex", "ptr", L, "astr", String(filename)
																			, (mode == LUA_NULL) ? "int" : "str", mode == LUA_NULL ? 0 : String(mode))
luaL_newstate() => DllCall(kLUALibrary . "\luaL_newstate", "ptr")
luaL_openlibs(L) => DllCall(kLUALibrary . "\luaL_openlibs", "ptr", L)
luaL_checktype(L, arg, t) => DllCall(kLUALibrary . "\luaL_checktype", "ptr", L, "int", Integer(arg), "int", Integer(t))

luaL_ref(L, t) => DllCall(kLUALibrary . "\luaL_ref", "ptr", L, "int", t)
luaL_unref(L, t) => DllCall(kLUALibrary . "\luaL_unref", "ptr", L, "int", t)

lua_absindex(L, idx) => DllCall(kLUALibrary . "\lua_absindex", "ptr", L, "int", idx)
lua_close(L) => DllCall(kLUALibrary . "\lua_close", "ptr", L)
lua_copy(L, fromidx, toidx) => DllCall(kLUALibrary . "\lua_copy", "ptr", L, "int", Integer(fromidx), , "int", Integer(toidx))
lua_createtable(L, narr, nrec) => DllCall(kLUALibrary . "\lua_createtable", "ptr", L, "int", Integer(narr), "int", Integer(nrec))
lua_error(L) => DllCall(kLUALibrary . "\lua_error", "ptr", L)
lua_getglobal(L, name) => DllCall(kLUALibrary . "\lua_getglobal", "ptr", L, "astr", name)
lua_getupvalue(L, funcindex, n) => DllCall(kLUALibrary . "\lua_getupvalue", "ptr", L, "int", funcindex, "int", n)
lua_gettable(L, index) => DllCall(kLUALibrary . "\lua_gettable", "ptr", L, "int", Integer(index))
lua_gettop(L) => DllCall(kLUALibrary . "\lua_gettop", "ptr", L)
lua_iscfunction(L, index) => DllCall(kLUALibrary . "\lua_iscfunction", "ptr", L, "int", Integer(index))
lua_pcallk(L, nargs, nresults, msgh, ctx, k) => DllCall(kLUALibrary . "\lua_pcallk", "ptr", L, "int", Integer(nargs), "int", Integer(nresults)
																				   , "int", Integer(msgh)
																				   , "int", ctx, (k == LUA_NULL) ? "int" : "ptr", k || 0)
lua_pushcclosure(L, f, n) => DllCall(kLUALibrary . "\lua_pushcclosure", "ptr", L, "ptr", f, "int", Integer(n))
lua_pushnumber(L, n) => DllCall(kLUALibrary . "\lua_pushnumber", "ptr", L, "double", Float(n))
lua_pushinteger(L, n) => DllCall(kLUALibrary . "\lua_pushinteger", "ptr", L, "int", Integer(n))
lua_pushliteral(L, s) => DllCall(kLUALibrary . "\lua_pushliteral", "ptr", L, "astr", String(s))
lua_pushnil(L) => DllCall(kLUALibrary . "\lua_pushnil", "ptr", L)
lua_pushstring(L, s) => DllCall(kLUALibrary . "\lua_pushstring", "ptr", L, "astr", String(s))
lua_rawget(L, index) => DllCall(kLUALibrary . "\lua_rawget", "ptr", L, "int", Integer(index))
lua_rawgeti(L, index, n) => DllCall(kLUALibrary . "\lua_rawgeti", "ptr", L, "int", Integer(index), "int", Integer(n))
lua_rawlen(L, index) => DllCall(kLUALibrary . "\lua_rawlen", "ptr", L, "int", index)
lua_rawset(L, index) => DllCall(kLUALibrary . "\lua_rawset", "ptr", L, "int", Integer(index))
lua_rawseti(L, index, i) => DllCall(kLUALibrary . "\lua_rawseti", "ptr", L, "int", Integer(index), "int", Integer(i))
lua_requiref(L, modname, openf, glb) => DllCall(kLUALibrary . "\lua_rawseti", "ptr", L, "str", String(modname), "ptr", openf, "int", Integer(glb))
lua_rotate(L, idx, n) => DllCall(kLUALibrary . "\lua_rotate", "ptr", L, "int", Integer(idx), "int", Integer(n))
lua_setfield(L, index, k) => DllCall(kLUALibrary . "\lua_setfield", "ptr", L, "int", Integer(index), "astr", String(k))
lua_setglobal(L, name) => DllCall(kLUALibrary . "\lua_setglobal", "ptr", L, "astr", name)
lua_setupvalue(L, funcindex, n) => DllCall(kLUALibrary . "\lua_setupvalue", "ptr", L, "int", funcindex, "int", n)
lua_settable(L, index) => DllCall(kLUALibrary . "\lua_settable", "ptr", L, "int", Integer(index))
lua_settop(L, index) => DllCall(kLUALibrary . "\lua_settop", "ptr", L, "int", Integer(index))
lua_toboolean(L, index) => DllCall(kLUALibrary . "\lua_toboolean", "ptr", L, "int", Integer(index))
lua_tointeger(L, index) => DllCall(kLUALibrary . "\lua_tointegerx", "ptr", L, "int", Integer(index), "int", 0)

lua_tolstring(L, index, len) {
	result := DllCall(kLUALibrary . "\lua_tolstring", "ptr", L, "int", Integer(index)
													, (len == LUA_NULL) ? "int" : "int*", (len == LUA_NULL) ? 0 : Integer(len))

	return ((result == 0) ? "" : StrGet(result, "UTF-8"))
}

lua_tonumberx(L, index, &isnum?) => DllCall(kLUALibrary . "\lua_tonumberx", "ptr", L, "int", Integer(index)
																		  , !IsSet(isnum) ? "int" : "int*"
																		  , !IsSet(isnum) ? 0 : &isnum, "double")
lua_topointer(L, index) => Format("<pointer: {:#x}>", DllCall(kLUALibrary . "\lua_topointer", "ptr", L, "int", Integer(index)))
lua_type(L, index) => DllCall(kLUALibrary . "\lua_type", "ptr", L, "int", Integer(index))
lua_typename(L, tp) => StrGet(DllCall(kLUALibrary . "\lua_typename", "ptr", L, "int", Integer(tp)), "UTF-8")
lua_callk(L, nargs, nresults, ctx, k) => DllCall(kLUALibrary . "\lua_typename", "ptr", L, "int", Integer(nargs), "int", Integer(nresults)
																			  , "int", ctx, (k == LUA_NULL) ? "int" : "ptr", k || 0)
luaopen_base(L) => DllCall(kLUALibrary . "\luaopen_base", "ptr", L)
luaopen_package(L) => DllCall(kLUALibrary . "\luaopen_package", "ptr", L)
luaopen_coroutine(L) => DllCall(kLUALibrary . "\luaopen_coroutine", "ptr", L)
luaopen_table(L) => DllCall(kLUALibrary . "\luaopen_table", "ptr", L)
luaopen_io(L) => DllCall(kLUALibrary . "\luaopen_io", "ptr", L)
luaopen_os(L) => DllCall(kLUALibrary . "\luaopen_os", "ptr", L)
luaopen_string(L) => DllCall(kLUALibrary . "\luaopen_string", "ptr", L)
luaopen_math(L) => DllCall(kLUALibrary . "\luaopen_math", "ptr", L)
luaopen_utf8(L) => DllCall(kLUALibrary . "\luaopen_utf8", "ptr", L)
luaopen_debug(L) => DllCall(kLUALibrary . "\luaopen_debug", "ptr", L)

luaL_loadfile(L, filename) => luaL_loadfilex(L, filename, LUA_NULL)
luaL_dofile(L, filename) => (luaL_loadfile(L, filename) || lua_pcallk(L, 0, LUA_MULTRET, 0, 0, LUA_NULL))
lua_call(L, n, r) => lua_callk(L, n, r, 0, LUA_NULL)
lua_pcall(L, n, r, f) => lua_pcallk(L, n, r, f, 0, LUA_NULL)
lua_tostring(L, index) => lua_tolstring(L, index, LUA_NULL)
lua_tonumber(L, index) => lua_tonumberx(L, index)
lua_newtable(L) => lua_createtable(L, 0, 0)
lua_pop(L, n) => lua_settop(L, 0 - n - 1)
lua_register(L, n, f) => (lua_pushcfunction(L, f), lua_setglobal(L, n))
lua_pushcfunction(L, f) => lua_pushcclosure(L, f, 0)
lua_isnil(L, n) => (lua_type(L, n) == LUA_TNIL)
lua_isboolean(L, n) => (lua_type(L, n) == LUA_TBOOLEAN)
lua_islightuserdata(L, n) => (lua_type(L, n) == LUA_TLIGHTUSERDATA)
lua_isnumber(L, n) => (lua_type(L, n) == LUA_TNUMBER)
lua_isstring(L, n) => (lua_type(L, n) == LUA_TSTRING)
lua_istable(L, n) => (lua_type(L, n) == LUA_TTABLE)
lua_isfunction(L, n) => (lua_type(L, n) == LUA_TFUNCTION)
lua_isuserdata(L, n) => (lua_type(L, n) == LUA_TUSERDATA)
lua_isthread(L, n) => (lua_type(L, n) == LUA_TTHREAD)
lua_isnone(L, n) => (lua_type(L, n) == LUA_TNONE)
lua_isnoneornil(L,  n) => (lua_type(L, n) <= 0)
lua_pushglobaltable(L) => lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS)
lua_insert(L, idx) => lua_rotate(L, idx, 1)
lua_remove(L, idx) => (lua_rotate(L, idx, -1), lua_pop(L, 1))
lua_replace(L, idx) => (lua_copy(L, -1, idx), lua_pop(L, 1))
lua_upvalueindex(i) => (LUA_REGISTRYINDEX - (i))

initializeScriptEngine() {
	if !DllCall("LoadLibrary", "Str", kBinariesDirectory . "Code Runtime\" . kLUALibrary, "Ptr") {
		logMessage(kLogCritical, translate("Error while initializing script engine - please rebuild the applications"))

		if (!kSilentMode)
			showMessage(translate("Error while initializing script engine - please rebuild the applications") . translate("...")
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

table2Array(context, index) {
	local result := []
	local type

	loop {
		lua_pushinteger(context, Integer(A_Index))

		type := lua_gettable(context, index)

		try {
			switch type {
				case LUA_TNIL:
					break
				case LUA_TNUMBER:
					result.Push(scriptGetNumber(context, -1))
				case LUA_TBOOLEAN:
					result.Push(scriptGetBoolean(context, -1))
				case LUA_TSTRING:
					result.Push(scriptGetString(context, -1))
				case LUA_TTABLE:
					result.Push(scriptGetArray(context, -1))
				default:
					throw "Unknown type detected in table2Array..."
			}
		}
		finally {
			lua_pop(context, 1)
		}
	}

	return result
}

array2Table(context, array) {
	lua_createtable(context, array.Length, 0)

	loop array.Length {
		lua_pushinteger(context, Integer(A_Index))

		scriptPushValue(context, array[A_Index])

		lua_settable(context, -3)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Functions Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

envSetGlobal(name, value) {
	kLUAEnvironment[name] := value

	return value
}

envGetGlobal(name, default := kUndefined) {
	return (kLUAEnvironment.Has(name) ? kLUAEnvironment[name] : default)
}

scriptExternHandler(context) {
	local value := %scriptGetString(context, 1)%
	local ignore, theValue

	if isInstance(value, Func)
		scriptPushValue(context, (c) {
			local result := value(scriptGetArguments(c)*)

			if isInstance(result, Values) {
				for ignore, theValue in result
					scriptPushValue(context, theValue)

				result := result.Length
			}
			else {
				scriptPushValue(c, result)

				result := 1
			}

			return Integer(result)
		})
	else
		scriptPushValue(context, value)

	return Integer(1)
}

scriptEngineAvailable() {
	return (DllCall("GetModuleHandle", "str", kLUALibrary) != 0)
}

scriptOpenContext() {
	local context := luaL_newstate()
	local path

	static libPath := getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))
									 , "Script Engine", "Modules Path", A_AppData . "\luarocks\share\lua\5.4\?.lua")
	static libCPath := getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))
									  , "Script Engine", "Libraries Path", A_AppData . "\luarocks\lib\lua\5.4\?.dll")

	luaL_openlibs(context)

	lua_getglobal(context, "package")
	lua_pushstring(context, "path")
	lua_gettable(context, -2)

	path := (kUserHomeDirectory . "Scripts\?.script;" . kResourcesDirectory . "Scripts\?.script;"
			 kUserHomeDirectory . "Scripts\?.lua;" . kResourcesDirectory . "Scripts\?.lua;"
												   . libPath . ";" . lua_tostring(context, -1))

	lua_pop(context, 1)

	lua_pushstring(context, "path")
	lua_pushstring(context, path)
	lua_settable(context, -3)

	lua_pushstring(context, "cpath")
	lua_gettable(context, -2)

	path := (kUserHomeDirectory . "Scripts\?.dll;" . kResourcesDirectory . "Scripts\?.dll;"
												   . libCPath . ";" . lua_tostring(context, -1))

	lua_pop(context, 1)

	lua_pushstring(context, "cpath")
	lua_pushstring(context, path)
	lua_settable(context, -3)

	lua_pop(context, 1)

	scriptPushValue(context, scriptExternHandler)
	scriptSetGlobal(context, "extern")

	return context
}

scriptCloseContext(context) {
	lua_close(context)
}

scriptCheck(scriptFileName, &errors) {
	local context, message, ignore

	if (kLUALibrary = "lua54.dll") {
		context := scriptOpenContext()

		try {
			errors := []

			if scriptLoad(context, scriptFileName, &message)
				return true
			else {
				for ignore, message in string2Values("`n", message)
					if (Trim(message) != "")
						errors.Push(message)

				return false
			}
		}
		finally {
			scriptCloseContext(context)
		}
	}
	else {
		deleteFile(kTempDirectory . "ScriptCompiler.out")

		result := RunWait(A_ComSpec . " /c `"`"" . kBinariesDirectory . "Code Runtime\luac55.exe" . "`" -p `"" . scriptFileName . "`" 2> `""
												. kTempDirectory . "ScriptCompiler.out`"`"", , "Hide")

		if FileExist(kTempDirectory . "ScriptCompiler.out") {
			errors := Trim(FileRead(kTempDirectory . "ScriptCompiler.out"))

			if (errors != "") {
				errors := choose(string2Values("`n", errors), (e) => (Trim(e) != ""))

				return false
			}
		}

		errors := []

		return true
	}
}

scriptLoad(context, fileName, &errorMessage?) {
	if (luaL_loadfile(context, fileName) != LUA_OK) {
		errorMessage := lua_tostring(context, -1)

		return false
	}
	else
		return true
}

scriptExecute(context, &message?) {
	if (lua_pcall(context, 0, LUA_MULTRET, 0) != LUA_OK) {
		message := lua_tostring(context, -1)

		return false
	}
	else
		return true
}

scriptPushArray(context, array) {
	array2Table(context, array)
}

scriptPushValue(context, value) {
	if !isSet(value)
		lua_pushnil(context)
	else if isInteger(value)
		lua_pushinteger(context, Integer(value))
	else if isNumber(value)
		lua_pushnumber(context, Number(value))
	else if (isInstance(value, Func) || isInstance(value, Closure))
		lua_pushcclosure(context, CallbackCreate(value, , 1), 0)
	else if ((value = kNull) || (value = kUndefined))
		lua_pushnil(context)
	else if (value = kTrue)
		lua_pushinteger(context, Integer(1))
	else if (value = kFalse)
		lua_pushnil(context)
	else if isInstance(value, Array)
		scriptPushArray(context, value)
	else
		lua_pushstring(context, String(value))
}

scriptGetGlobal(context, name) {
	local value

	lua_getglobal(context, name)

	value := scriptGetValue(context, -1)

	lua_pop(context, 1)

	return value
}

scriptSetGlobal(context, name) {
	lua_setglobal(context, name)
}

scriptGetArgsCount(context) {
	return lua_gettop(context)
}

scriptGetArguments(context) {
	local arguments := []

	loop scriptGetArgsCount(context)
		if (lua_type(context, A_Index) = LUA_TNIL)
			arguments.Push(unset)
		else
			arguments.Push(scriptGetValue(context, A_Index))

	return arguments
}

scriptGetValue(context, index := 1) {
	local number

	switch lua_type(context, index) {
		case LUA_TNIL:
			return unset
		case LUA_TNUMBER:
			return scriptGetNumber(context, index)
		case LUA_TBOOLEAN:
			return scriptGetBoolean(context, index)
		case LUA_TSTRING:
			return scriptGetString(context, index)
		case LUA_TTABLE:
			return scriptGetArray(context, index)
		default:
			throw "Unknown type detected in scriptGetValue..."
	}

	return lua_toboolean(context, index)
}

scriptGetBoolean(context, index := 1) {
	return lua_toboolean(context, index)
}

scriptGetString(context, index := 1) {
	return lua_tostring(context, index)
}

scriptGetInteger(context, index := 1) {
	return lua_tointeger(context, index)
}

scriptGetNumber(context, index := 1) {
	local number := lua_tonumber(context, index)

	return ((Round(number) = number) ? Integer(number) : number)
}

scriptGetArray(context, index := 1) {
	return table2Array(context, index)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeScriptEngine()