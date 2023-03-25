;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - JSON Parser                     ;;;
;;;                                                                         ;;;
;;;   This code is based on work of teadrinker. See                         ;;;
;;;   https://www.autohotkey.com/boards/viewtopic.php?f=76&t=65631&start=40 ;;;
;;;   for more information and also some sample usage code. The class JSON  ;;;
;;;   also shows, how to embed JavaScript code into AHK programs.           ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Framework.ahk"

global kBuildConfiguration := "Development"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Class Section                           ;;;
;;;-------------------------------------------------------------------------;;;

class JSON {
	static JS := JSON._GetJScriptObject(), true := {}, false := {}, null := {}

	static parse(script, js := false)  {
		local jsObject

		if jsObject := JSON.verify(script)
			return js ? jsObject : JSON._CreateMap(jsObject)
		else
			return false
	}

	static print(obj, js := false, indent := "") {
		local text

		if js
			text := JSON.JS.JSON.stringify(obj, "", indent)
		else
			text := JSON.JS.eval("JSON.stringify(" . JSON._ObjToString(obj) . ",'','" . indent . "')")

		if !js
			text := StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(text, "\n", "`n"), "\r", "`r"), "\t", "`t"), "\`"", "`""), "\\", "\")

		return text
	}

	static stringify(obj, js := false, indent := "") {
		if js
			return JSON.JS.JSON.stringify(obj, "", indent)
		else
			return JSON.JS.eval("JSON.stringify(" . JSON._ObjToString(obj) . ",'','" . indent . "')")
	}

	static getKey(script, key, indent := "") {
		if !JSON.verify(script)
			return false

		try {
			return JSON.JS.eval("JSON.stringify((" . script . ")" . ((SubStr(key, 1, 1) = "[") ? "" : ".") . key . ",'','" . indent . "')")
		}
		catch Any as exception {
			return false
		}
	}

	static setKey(script, key, value, indent := "") {
		local result

		if (!JSON.verify(script) || !JSON.verify(value))
			return false

		try {
			result := JSON.JS.eval("var obj = (" . script . ");"
								 . "obj" . ((SubStr(key, 1, 1) = "[") ? "" : ".") . key . "=" . value . ";"
								 . "JSON.stringify(obj,'','" . indent . "')")

			JSON.JS.eval("obj = ''")

			return result
		}
		catch Any as exception {
			return false
		}
	}

	static removeKey(script, key, indent := "") {
		local sign, result, match

		if !JSON.verify(script)
			return false

		sign := ((SubStr(key, 1, 1) = "[") ? "" : ".")

		try {
			if !RegExMatch(key, "(.*)\[(\d+)]$", &match)
				result := JSON.JS.eval("var obj = (" . script . "); delete obj" . sign . key . "; JSON.stringify(obj,'','" . indent . "')")
			else
				result := JSON.JS.eval("var obj = (" . script . ");"
									 . "obj" . (match[1] != "" ? sign . match[1] : "") . ".splice(" . match[2] . ", 1);"
									 . "JSON.stringify(obj,'','" . indent . "')")

			JSON.JS.eval("obj = ''")

			return result
		}
		catch Any as exception {
			return false
		}
	}

	static enum(script, key := "", indent := "") {
		local jsObject, obj, result, concatenated, keys, k

		if !JSON.verify(script)
			return false

		concatenated := (key ? ((SubStr(key, 1, 1) = "[" ? "" : ".") . key) : "")

		try {
			jsObject := JSON.JS.eval("(" . script . ")" . concatenated)
			result := jsObject.IsArray()

			if (result = "")
				return false

			obj := Map()

			if (result = -1) {
				loop jsObject.length
					obj[A_Index - 1] := JSON.JS.eval("JSON.stringify((" . script . ")" . concatenated . "[" . (A_Index - 1) . "],'','" . indent . "')")
			}
			else if (result = 0) {
				keys := jsObject.GetKeys()

				loop keys.length
					k := keys[A_Index - 1], obj[k] := JSON.JS.eval("JSON.stringify((" . script . ")" . concatenated . "['" . k . "'],'','" . indent . "')")
			}

			return obj
		}
		catch Any as exception {
			return false
		}
	}

	static verify(script) {
		local jsObject

		try
			jsObject := JSON.JS.eval("(" . script . ")")
		catch {
			return false
		}

		return (IsObject(jsObject) ? jsObject : true)
	}

	static _ObjToString(obj) {
		local key, value, isArray, result

		if obj is Map {
			for key, value in ["true", "false", "null"]
				if (obj = JSON.%value%)
					return value

			isArray := true

			for key, value in obj.OwnProps() {
				if (IsObject(key) || (key is Map))
					throw "Invalid key detected in JSON._ObjToString..."

				if !((key = A_Index) || (isArray := false))
					break
			}

			result := ""

			for key, value in obj.OwnProps()
				result .= ((A_Index = 1) ? "" : "," ) . (isArray ? "" : ("`"" . key . "`":")) . JSON._ObjToString(value)

			return (isArray ? ("[" . result . "]") : ("{" . result . "}"))
		}
		else if !(((obj * 1) = "") || RegExMatch(obj, "\s"))
			return obj

		for key, value in [["\", "\\"], [A_Tab, "\t"], ["`"", "\`""], ["/", "\/"], ["`n", "\n"], ["`r", "\r"], [Chr(12), "\f"], [Chr(08), "\b"]]
			obj := StrReplace(obj, value[1], value[2])

		return "`"" . obj . "`""
	}

	static _GetJScriptObject() {
		local JS

		static document

		document := ComObject("htmlfile")

		document.write("<meta http-equiv=`"X-UA-Compatible`" content=`"IE=9`">")

		JS := document.parentWindow

		JSON._AddMethods(JS)

		return JS
	}

	static _AddMethods(JS) {
		local script

		script := "
		(
			Object.prototype.GetKeys = function () {
				var keys = []

				for (var k in this)
					if (this.hasOwnProperty(k))
						keys.push(k)

				return keys
			}
			Object.prototype.IsArray = function () {
				var toStandardString = {}.toString

				return toStandardString.call(this) == '[object Array]'
			}
		)"

		JS.eval(script)
	}
https://github.com/Chunjee/json.ahk
	static _CreateMap(jsObject) {
		local result, obj, keys, k

		if !IsObject(jsObject)
			return jsObject

		result := jsObject.IsArray()

		if (result = "")
			return jsObject
		else if (result = -1) {
			obj := []

			loop jsObject.length
				obj[A_Index] := JSON._CreateMap(jsObject[A_Index - 1])
		}
		else if (result = 0) {
			obj := CaseInsenseMap()
			keys := jsObject.GetKeys()
			type := ComObjType(keys)

			loop keys.length
				k := keys[A_Index - 1], obj[k] := JSON._CreateMap(jsObject[k])
		}

		return obj
	}
}

data := JSON.parse(FileRead(A_MyDocuments . "\Assetto Corsa Competizione\Debug\swap_dump_carjson.json"))

msgbox "INspect"

data := JSON.print(data)

msgbox "Inspect"