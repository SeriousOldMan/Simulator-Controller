;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Multi Map Functions             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Constants.ahk"
#Include "Variables.ahk"
#Include "Debug.ahk"
#Include "Files.ahk"
#Include "Strings.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                    Public Classes Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

class MultiMap extends CaseInsenseWeakMap {
	static read(multiMapFile) {
		return readMultiMap(multiMapFile)
	}

	static parse(text) {
		return parseMultiMap(text)
	}

	Clone() {
		local newMultiMap := super.Clone()

		for key, values in this
			if isInstance(values, Map)
				newMultiMap[key] := values.Clone()

		return newMultiMap
	}

	include(path, directory?) {
		local curWorkingDir := A_WorkingDir

		if isSet(directory)
			SetWorkingDir(directory)

		try {
			addMultiMapValues(this, readMultiMap(path))
		}
		finally {
			SetWorkingDir(curWorkingDir)
		}
	}

	write(multiMapFile, symbolic := true) {
		writeMultiMap(multiMapFile, this, symbolic := true)
	}

	print(symbolic := true) {
		return printMultiMap(this, symbolic := true)
	}

	getValue(section, key, default?) {
		return getMultiMapValue(this, section, key, default?)
	}

	getValues(multiMap, section, default?) {
		return getMultiMapValues(this, section, default?)
	}

	setValue(section, key, value) {
		return setMultiMapValue(this, section, key, value)
	}

	setValues(section, values) {
		return setMultiMapValues(this, section, values)
	}

	addValues(otherMultiMap) {
		return addMultiMapValues(this, otherMultiMap)
	}

	removeValue(section, key) {
		return removeMultiMapValue(this, section, key)
	}

	removeValues(multiMap, section) {
		return removeMultiMapValues(this, section)
	}
}

class SectionMap extends CaseInsenseWeakMap {
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

newMultiMap(arguments*) {
	return MultiMap(arguments*)
}

newSectionMap(arguments*) {
	return SectionMap(arguments*)
}

readMultiMap(multiMapFile, class?) {
	local file := false
	local tries := 20
	local data := false

	if !FileExist(multiMapFile)
		if (isSet(kUserConfigDirectory) && isSet(kConfigDirectory))
			multiMapFile := getFileName(multiMapFile, kUserConfigDirectory, kConfigDirectory)
		else
			multiMapFile := getFileName(multiMapFile, A_MyDocuments . "\Simulator Controller\Config\"
													, normalizeFilePath(A_ScriptDir . (A_IsCompiled ? "\..\Config\" : "\..\..\Config\")))


	if FileExist(multiMapFile) {
		loop
			try {
				file := FileOpen(multiMapFile, "r-wd")

				if file {
					data := FileRead(multiMapFile)

					file.Close()

					break
				}
				else
					throw "File not found..."
			}
			catch Any as exception {
				if (tries-- <= 0) {
					if isDevelopment()
						logMessage(kLogWarn, "Waiting for file `"" . multiMapFile . "`"...")

					return isSet(class) ? class() : newMultiMap()
				}
				else
					Sleep(10)
			}

		if (data && (data != "")) {
			SplitPath(multiMapFile, , &directory)

			return parseMultiMap(data, class?, directory)
		}
	}

	return newMultiMap()
}

parseMultiMap(text, class?, directory?) {
	local multiMap := (isSet(class) ? class() : newMultiMap())
	local section := false
	local currentLine, firstChar, keyValue, key, value

	loop Parse, text, "`n", "`r" {
		currentLine := LTrim(A_LoopField)

		if (StrLen(currentLine) == 0)
			continue

		firstChar := SubStr(currentLine, 1, 1)

		if (firstChar = ";")
			continue
		else if (firstChar = "[") {
			section := StrReplace(StrReplace(RTrim(currentLine), "[", ""), "]", "")

			if !multiMap.Has(section)
				multiMap[section] := newSectionMap()
		}
		else if ((firstChar = "#") && (InStr(currentLine, "#Include") = 1))
			multiMap.include(substituteVariables(Trim(SubStr(currentLine, 9))), directory?)
		else if section {
			keyValue := LTrim(currentLine)

			if ((SubStr(keyValue, 1, 2) != "//") && (SubStr(keyValue, 1, 1) != ";")) {
				keyValue := StrSplit(StrReplace(StrReplace(StrReplace(keyValue, "\=", "_#_EQ-#_"), "\\", "_#_AC-#_"), "\n", "_#_CR-#_"), "=", "", 2)

				key := StrReplace(StrReplace(StrReplace(keyValue[1], "_#_EQ-#_", "="), "_#_AC-#_", "\\"), "_#_CR-#_", "`n")
				value := ((keyValue.Length > 1) ? StrReplace(StrReplace(StrReplace(keyValue[2], "_#_EQ-#_", "="), "_#_AC-#_", "\"), "_#_CR-#_", "`n") : "")

				multiMap[section][key] := ((value = "true") ? true : ((value = "false") ? false : value))
			}
		}
	}

	return multiMap
}

writeMultiMap(multiMapFile, multiMap, symbolic := true) {
	local tempFile := temporaryFileName("Config", "ini")
	local empty := (multiMap.Count = 0)
	local directory, section, keyValues, key, value, pairs, tries

	deleteFile(tempFile)

	FileAppend(printMultiMap(multiMap, symbolic), tempFile, "UTF-16")

	multiMapFile := getFileName(multiMapFile, kUserConfigDirectory)

	SplitPath(multiMapFile, , &directory)
	DirCreate(directory)

	tries := 10

	loop
		try {
			if empty {
				if !FileExist(multiMapFile)
					break
				else if deleteFile(multiMapFile)
					break
				else {
					Sleep(200)

					tries -= 1
				}
			}
			else {
				FileMove(tempFile, multiMapFile, 1)

				break
			}
		}
		catch Any as exception {
			logError(exception, false, (tries = 1))

			if (tries-- <= 0) {
				if isDevelopment()
					logMessage(kLogWarn, "Waiting for file `"" . multiMapFile . "`"...")

				break
			}
		}
}

printMultiMap(multiMap, symbolic := true) {
	local result := ""
	local pairs

	for section, keyValues in multiMap
		if (keyValues.Count > 0) {
			pairs := ""

			for key, value in keyValues {
				value := encode(value)

				pairs .= ("`n" . key . "=" . (symbolic ? ((value == true) ? kTrue : ((value == false) ? kFalse : value)) : value))
			}

			result .= ("[" . section . "]" . pairs . "`n")
		}

	return result
}

getMultiMapValue(multiMap, section, key, default := false) {
	local value

	if multiMap.Has(section) {
		value := multiMap[section]

		if value.Has(key)
			return value[key]
	}

	return default
}

getMultiMapValues(multiMap, section, default?) {
	return multiMap.Has(section) ? multiMap[section].Clone() : (isSet(default) ? default : newSectionMap())
}

setMultiMapValue(multiMap, section, key, value) {
	if !multiMap.Has(section)
		multiMap[section] := newSectionMap()

	multiMap[section][key] := value
}

setMultiMapValues(multiMap, section, values, clear := true) {
	local key, value

	if clear
		removeMultiMapValues(multiMap, section)

	for key, value in values
		setMultiMapValue(multiMap, section, key, value)
}

addMultiMapValues(multiMap, otherMultiMap, clear := false) {
	local section, values

	for section, values in otherMultiMap
		setMultiMapValues(multiMap, section, values, clear)
}

removeMultiMapValue(multiMap, section, key) {
	if (multiMap.Has(section) && multiMap[section].Has(key))
		multiMap[section].Delete(key)
}

removeMultiMapValues(multiMap, section) {
	if multiMap.Has(section)
		multiMap.Delete(section)
}