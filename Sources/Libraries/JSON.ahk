;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - JSON Parser                     ;;;
;;;                                                                         ;;;
;;;   This code is based on work of teadrinker. See                         ;;;
;;;   https://www.autohotkey.com/boards/viewtopic.php?f=76&t=65631&start=40 ;;;
;;;   for more information and also some sample usage code. The class JSON  ;;;
;;;   also shows, how to embed JavaScript code into AHK programs.           ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Class Section                           ;;;
;;;-------------------------------------------------------------------------;;;

class JSON {
	static JS := JSON._GetJScriptObject(), true := {}, false := {}, null := {}
	
	parse(script, js := false)  {
		if jsObject := this.verify(script)
			return js ? jsObject : this._CreateObject(jsObject)
		else
			return false
	}
	
	print(object, js := false, indent := "") {
		if js
			text := this.JS.JSON.stringify(object, "", indent)
		else
			text := this.JS.eval("JSON.stringify(" . this._ObjToString(object) . ",'','" . indent . "')")
		
		if !js
			text := StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(text, "\n", "`n"), "\r", "`r"), "\t", "`t"), "\""", """"), "\\", "\")
		
		return text
	}
	
	stringify(object, js := false, indent := "") {
		if js
			return this.JS.JSON.stringify(object, "", indent)
		else
			return this.JS.eval("JSON.stringify(" . this._ObjToString(object) . ",'','" . indent . "')")
	}
	
	getKey(script, key, indent := "") {
		if !this.verify(script)
			return false
		
		try {
			return this.JS.eval("JSON.stringify((" . script . ")" . ((SubStr(key, 1, 1) = "[") ? "" : ".") . key . ",'','" . indent . "')")
		}
		catch exception {
			return false
		}
	}
	
	setKey(script, key, value, indent := "") {
		if (!this.verify(script) || !this.verify(value))
			return false
		
		try {
			result := this.JS.eval("var obj = (" . script . ");"
								 . "obj" . ((SubStr(key, 1, 1) = "[") ? "" : ".") . key . "=" . value . ";"
								 . "JSON.stringify(obj,'','" . indent . "')")
			
			this.JS.eval("obj = ''")
			
			return result
		}
		catch exception {
			return false
		}
	}
	
	removeKey(script, key, indent := "") {
		if !this.verify(script)
			return false
		
		sign := ((SubStr(key, 1, 1) = "[") ? "" : ".")
		
		try {
			if !RegExMatch(key, "(.*)\[(\d+)]$", match)
				result := this.JS.eval("var obj = (" . script . "); delete obj" . sign . key . "; JSON.stringify(obj,'','" . indent . "')")
			else
				result := this.JS.eval("var obj = (" . script . ");" 
									 . "obj" . (match1 != "" ? sign . match1 : "") . ".splice(" . match2 . ", 1);"
									 . "JSON.stringify(obj,'','" . indent . "')")
		
			this.JS.eval("obj = ''")
			
			return result
		}
		catch exception {
			return false
		}
	}
	
	enum(script, key := "", indent := "") {
		if !this.verify(script)
			return false
		
		concateneted := (key ? ((SubStr(key, 1, 1) = "[" ? "" : ".") . key) : "")
		
		try {
			jsObject := this.JS.eval("(" . script . ")" . concateneted)
			result := jsObject.IsArray()
			
			if (result = "")
				return false
			
			object := {}
			
			if (result = -1) {
				Loop % jsObject.length
					object[A_Index - 1] := this.JS.eval("JSON.stringify((" . script . ")" . concateneted . "[" . (A_Index - 1) . "],'','" . indent . "')")
			}
			else if (result = 0) {
				keys := jsObject.GetKeys()
			
				Loop % keys.length
					k := keys[A_Index - 1], object[k] := this.JS.eval("JSON.stringify((" . script . ")" . concateneted . "['" . k . "'],'','" . indent . "')")
			}
			
			return object
		}
		catch exception {
			return false
		}
	}
	
	verify(script) {
		try
			jsObject := this.JS.eval("(" . script . ")")
		catch {
			return false
		}
		
		return (IsObject(jsObject) ? jsObject : true)
	}
	
	_ObjToString(object) {
		if IsObject(object) {
			for key, value in ["true", "false", "null"]
				if (object = this[value])
					return value
				
			isArray := true
			
			for key in object {
				if IsObject(key)
					Throw "Invalid key detected in JSON._ObjToString..."
				
				if !((key = A_Index) || (isArray := false))
					break
			}
			
			string := ""
			
			for key, value in object
				string .= ((A_Index = 1) ? "" : "," ) . (isArray ? "" : ("""" . key . """:")) . this._ObjToString(value)

			return (isArray ? ("[" . string . "]") : ("{" . string . "}"))
		}
		else if !(((object * 1) = "") || RegExMatch(object, "\s"))
			return object
		
		for key, value in [["\", "\\"], [A_Tab, "\t"], ["""", "\"""], ["/", "\/"], ["`n", "\n"], ["`r", "\r"], [Chr(12), "\f"], [Chr(08), "\b"]]
			object := StrReplace(object, value[1], value[2])

		return """" . object . """"
	}

	_GetJScriptObject() {
		static document
		
		document := ComObjCreate("htmlfile")
		
		document.write("<meta http-equiv=""X-UA-Compatible"" content=""IE=9"">")
		
		JS := document.parentWindow
		
		JSON._AddMethods(JS)
		
		return JS
	}

	_AddMethods(ByRef JS) {
		script =
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
		)
		
		JS.eval(script)
	}

	_CreateObject(jsObject) {
		if !IsObject(jsObject)
			return jsObject
		
		result := jsObject.IsArray()
		
		if (result = "")
			return jsObject
		else if (result = -1) {
			object := []
			
			Loop % jsObject.length
				object[A_Index] := this._CreateObject(jsObject[A_Index - 1])
		}
		else if (result = 0) {
			object := {}
			keys := jsObject.GetKeys()
			
			Loop % keys.length
				k := keys[A_Index - 1], object[k] := this._CreateObject(jsObject[k])
		}
		
		return object
	}
}