;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - LUA Runtime                     ;;;
;;;                                                                         ;;;
;;;   Created from AHK code by Delta Pythagorean                            ;;;
;;;   (https://www.autohotkey.com/boards/viewtopic.php?style=10&t=122655)   ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
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
;;;                    Global Functions Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

luaAvailable() {
	return (DllCall("GetModuleHandle", "str", "lua54.dll") != 0)
}

luaL_loadfilex(L, filename, mode) => DllCall("lua54.dll\luaL_loadfilex", "ptr", L, "astr", String(filename)
																	   , (mode == LUA_NULL) ? "int" : "str", mode == LUA_NULL ? 0 : String(mode))
luaL_newstate() => DllCall("lua54.dll\luaL_newstate", "ptr")
luaL_openlibs(L) => DllCall("lua54.dll\luaL_openlibs", "ptr", L)
luaL_checktype(L, arg, t) => DllCall("lua54.dll\luaL_checktype", "ptr", L, "int", Integer(arg), "int", Integer(t))

luaL_ref(L, t) => DllCall("lua54.dll\luaL_ref", "ptr", L, "int", t)
luaL_unref(L, t) => DllCall("lua54.dll\luaL_unref", "ptr", L, "int", t)

lua_absindex(L, idx) => DllCall("lua54.dll\lua_absindex", "ptr", L, "int", idx)
lua_close(L) => DllCall("lua54.dll\lua_close", "ptr", L)
lua_copy(L, fromidx, toidx) => DllCall("lua54.dll\lua_copy", "ptr", L, "int", Integer(fromidx), , "int", Integer(toidx))
lua_createtable(L, narr, nrec) => DllCall("lua54.dll\lua_createtable", "ptr", L, "int", Integer(narr), "int", Integer(nrec))
lua_error(L) => DllCall("lua54.dll\lua_error", "ptr", L)
lua_getglobal(L, name) => DllCall("lua54.dll\lua_getglobal", "ptr", L, "astr", name)
lua_getupvalue(L, funcindex, n) => DllCall("lua54.dll\lua_getupvalue", "ptr", L, "int", funcindex, "int", n)
lua_gettable(L, index) => DllCall("lua54.dll\lua_gettable", "ptr", L, "int", Integer(index))
lua_gettop(L) => DllCall("lua54.dll\lua_gettop", "ptr", L)
lua_iscfunction(L, index) => DllCall("lua54.dll\lua_iscfunction", "ptr", L, "int", Integer(index))
lua_pcallk(L, nargs, nresults, msgh, ctx, k) => DllCall("lua54.dll\lua_pcallk", "ptr", L, "int", Integer(nargs), "int", Integer(nresults)
																			  , "int", Integer(msgh)
																			  , "int", ctx, (k == LUA_NULL) ? "int" : "ptr", k || 0)
lua_pushcclosure(L, f, n) => DllCall("lua54.dll\lua_pushcclosure", "ptr", L, "ptr", f, "int", Integer(n))
lua_pushnumber(L, n) => DllCall("lua54.dll\lua_pushnumber", "ptr", L, "double", Float(n))
lua_pushinteger(L, n) => DllCall("lua54.dll\lua_pushinteger", "ptr", L, "int", Integer(n))
lua_pushliteral(L, s) => DllCall("lua54.dll\lua_pushliteral", "ptr", L, "astr", String(s))
lua_pushnil(L) => DllCall("lua54.dll\lua_pushnil", "ptr", L)
lua_pushstring(L, s) => DllCall("lua54.dll\lua_pushstring", "ptr", L, "astr", String(s))
lua_rawget(L, index) => DllCall("lua54.dll\lua_rawget", "ptr", L, "int", Integer(index))
lua_rawgeti(L, index, n) => DllCall("lua54.dll\lua_rawgeti", "ptr", L, "int", Integer(index), "int", Integer(n))
lua_rawlen(L, index) => DllCall("lua54.dll\lua_rawlen", "ptr", L, "int", index)
lua_rawset(L, index) => DllCall("lua54.dll\lua_rawset", "ptr", L, "int", Integer(index))
lua_rawseti(L, index, i) => DllCall("lua54.dll\lua_rawseti", "ptr", L, "int", Integer(index), "int", Integer(i))
lua_requiref(L, modname, openf, glb) => DllCall("lua54.dll\lua_rawseti", "ptr", L, "str", String(modname), "ptr", openf, "int", Integer(glb))
lua_rotate(L, idx, n) => DllCall("lua54.dll\lua_rotate", "ptr", L, "int", Integer(idx), "int", Integer(n))
lua_setfield(L, index, k) => DllCall("lua54.dll\lua_setfield", "ptr", L, "int", Integer(index), "astr", String(k))
lua_setglobal(L, name) => DllCall("lua54.dll\lua_setglobal", "ptr", L, "astr", name)
lua_setupvalue(L, funcindex, n) => DllCall("lua54.dll\lua_setupvalue", "ptr", L, "int", funcindex, "int", n)
lua_settable(L, index) => DllCall("lua54.dll\lua_settable", "ptr", L, "int", Integer(index))
lua_settop(L, index) => DllCall("lua54.dll\lua_settop", "ptr", L, "int", Integer(index))
lua_toboolean(L, index) => DllCall("lua54.dll\lua_toboolean", "ptr", L, "int", Integer(index))
lua_tointeger(L, index) => DllCall("lua54.dll\lua_tointegerx", "ptr", L, "int", Integer(index), "int", 0)

lua_tolstring(L, index, len) {
	result := DllCall("lua54.dll\lua_tolstring", "ptr", L, "int", Integer(index)
											   , (len == LUA_NULL) ? "int" : "int*", (len == LUA_NULL) ? 0 : Integer(len))

	return ((result == 0) ? "" : StrGet(result, "UTF-8"))
}

lua_tonumberx(L, index, &isnum?) => DllCall("lua54.dll\lua_tonumberx", "ptr", L, "int", Integer(index)
																	 , !IsSet(isnum) ? "int" : "int*"
																	 , !IsSet(isnum) ? 0 : &isnum, "double")
lua_topointer(L, index) => Format("<pointer: {:#x}>", DllCall("lua54.dll\lua_topointer", "ptr", L, "int", Integer(index)))
lua_type(L, index) => DllCall("lua54.dll\lua_type", "ptr", L, "int", Integer(index))
lua_typename(L, tp) => StrGet(DllCall("lua54.dll\lua_typename", "ptr", L, "int", Integer(tp)), "UTF-8")
lua_callk(L, nargs, nresults, ctx, k) => DllCall("lua54.dll\lua_typename", "ptr", L, "int", Integer(nargs), "int", Integer(nresults)
																		 , "int", ctx, (k == LUA_NULL) ? "int" : "ptr", k || 0)
luaopen_base(L) => DllCall("lua54.dll\luaopen_base", "ptr", L)
luaopen_package(L) => DllCall("lua54.dll\luaopen_package", "ptr", L)
luaopen_coroutine(L) => DllCall("lua54.dll\luaopen_coroutine", "ptr", L)
luaopen_table(L) => DllCall("lua54.dll\luaopen_table", "ptr", L)
luaopen_io(L) => DllCall("lua54.dll\luaopen_io", "ptr", L)
luaopen_os(L) => DllCall("lua54.dll\luaopen_os", "ptr", L)
luaopen_string(L) => DllCall("lua54.dll\luaopen_string", "ptr", L)
luaopen_math(L) => DllCall("lua54.dll\luaopen_math", "ptr", L)
luaopen_utf8(L) => DllCall("lua54.dll\luaopen_utf8", "ptr", L)
luaopen_debug(L) => DllCall("lua54.dll\luaopen_debug", "ptr", L)

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


;;;-------------------------------------------------------------------------;;;
;;;                    Private Functions Declaration Section                ;;;
;;;-------------------------------------------------------------------------;;;

initializeLua() {
	if FileExist(kUserHomeDirectory . "Programs\Lua Runtime\lua54.dll")
		DllCall("LoadLibrary", "Str", kUserHomeDirectory . "Programs\Lua Runtime\lua54.dll", "Ptr")
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeLua()