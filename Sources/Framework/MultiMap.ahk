;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Multi Map Functions             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Constants.ahk"
#Include "..\Framework\Variables.ahk"
#Include "..\Framework\Debug.ahk"
#Include "..\Framework\Files.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                    Public Classes Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

class MultiMap extends CaseInsenseSafeMap {
	static read(multiMapFile) {
		return readMultiMap(multiMapFile)
	}

	static parse(text) {
		return parseMultiMap(text)
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


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

newMultiMap() {
	return MultiMap()
}

newSectionMap() {
	return MultiMap()
}

readMultiMap(multiMapFile) {
	local multiMap := newMultiMap()
	local section := false
	local file := false
	local tries := 20
	local data := false
	local currentLine, firstChar, keyValue, key, value

	multiMapFile := getFileName(multiMapFile, kUserConfigDirectory, kConfigDirectory)

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
				if (tries-- <= 0)
					return multiMap
				else
					Sleep(10)
			}

		if (data && (data != "")) {
			loop Parse, data, "`n", "`r" {
				currentLine := LTrim(A_LoopField)

				if (StrLen(currentLine) == 0)
					continue

				firstChar := SubStr(currentLine, 1, 1)

				if (firstChar = ";")
					continue
				else if (firstChar = "[") {
					section := StrReplace(StrReplace(RTrim(currentLine), "[", ""), "]", "")

					multiMap[section] := newSectionMap()
				}
				else if section {
					keyValue := LTrim(currentLine)

					if ((SubStr(keyValue, 1, 2) != "//") && (SubStr(keyValue, 1, 1) != ";")) {
						keyValue := StrSplit(StrReplace(StrReplace(StrReplace(keyValue, "\=", "_#_EQ-#_"), "\\", "_#_AC-#_"), "\n", "_#_CR-#_"), "=", "", 2)

						key := StrReplace(StrReplace(StrReplace(keyValue[1], "_#_EQ-#_", "="), "_#_AC-#_", "\\"), "_#_CR-#_", "`n")
						value := ((keyValue.Length > 1) ? StrReplace(StrReplace(StrReplace(keyValue[2], "_#_EQ-#_", "="), "_#_AC-#_", "\"), "_#_CR-#_", "`n") : "")

						multiMap[section][key] := ((value = kTrue) ? true : ((value = kFalse) ? false : value))
					}
				}
			}
		}
	}

	return multiMap
}

parseMultiMap(text) {
	local fileName := temporaryFileName("Config", "ini")
	local multiMap

	FileAppend(text, fileName, "UTF-16")

	multiMap := readMultiMap(fileName)

	deleteFile(fileName)

	return multiMap
}

writeMultiMap(multiMapFile, multiMap, symbolic := true) {
	local tempFile := temporaryFileName("Config", "ini")
	local empty := (multiMap.Count = 0)
	local directory, section, keyValues, key, value, pairs, tries

	deleteFile(tempFile)

	for section, keyValues in multiMap {
		pairs := ""

		for key, value in keyValues {
			value := StrReplace(value, "\", "\\")
			value := StrReplace(value, "=", "\=")
			value := StrReplace(value, "`n", "\n")

			pairs := (pairs . "`n" . key . "=" . (symbolic ? ((value == true) ? kTrue : ((value == false) ? kFalse : value)) : value))
		}

		section := "[" . section . "]" . pairs . "`n"

		FileAppend(section, tempFile, "UTF-16")
	}

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

			if (tries-- <= 0)
				break
		}
}

printMultiMap(multiMap, symbolic := true) {
	local fileName := temporaryFileName("Config", "ini")
	local text

	writeMultiMap(fileName, multiMap, symbolic)

	try {
		text := FileRead(fileName)
	}
	catch Any as exception {
		text := ""
	}

	deleteFile(fileName)

	return text
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

setMultiMapValues(multiMap, section, values) {
	local key, value

	removeMultiMapValues(multiMap, section)

	for key, value in values
		setMultiMapValue(multiMap, section, key, value)
}

addMultiMapValues(multiMap, otherMultiMap) {
	local section, values

	for section, values in otherMultiMap
		setMultiMapValues(multiMap, section, values)
}

removeMultiMapValue(multiMap, section, key) {
	if (multiMap.Has(section) && multiMap[section].Has(key))
		multiMap[section].Delete(key)
}

removeMultiMapValues(multiMap, section) {
	if multiMap.Has(section)
		multiMap.Delete(section)
}