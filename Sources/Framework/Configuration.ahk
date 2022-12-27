;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Configuration Functions         ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Framework\Constants.ahk
#Include ..\Framework\Variables.ahk
#Include ..\Framework\Debug.ahk
#Include ..\Framework\Files.ahk


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

newConfiguration() {
	return {}
}

readConfiguration(configFile) {
	local configuration := {}
	local section := false
	local file := false
	local tries := 20
	local data := false
	local currentLine, firstChar, keyValue, key, value

	configFile := getFileName(configFile, kUserConfigDirectory, kConfigDirectory)

	if FileExist(configFile) {
		loop
			try {
				file := FileOpen(configFile, "r-wd")

				if file {
					FileRead data, %configFile%

					file.Close()

					break
				}
				else
					throw "File not found..."
			}
			catch exception {
				if (tries-- <= 0)
					return configuration
				else
					Sleep 10
			}

		if (data && (data != "")) {
			loop Parse, data, `n, `r
			{
				currentLine := LTrim(A_LoopField)

				if (StrLen(currentLine) == 0)
					continue

				firstChar := SubStr(currentLine, 1, 1)

				if (firstChar = ";")
					continue
				else if (firstChar = "[") {
					section := StrReplace(StrReplace(RTrim(currentLine), "[", ""), "]", "")

					configuration[section] := {}
				}
				else if section {
					keyValue := LTrim(currentLine)

					if ((SubStr(keyValue, 1, 2) != "//") && (SubStr(keyValue, 1, 1) != ";")) {
						keyValue := StrSplit(StrReplace(StrReplace(StrReplace(keyValue, "\=", "_#_EQ-#_"), "\\", "_#_AC-#_"), "\n", "_#_CR-#_")
										   , "=", "", 2)

						key := StrReplace(StrReplace(StrReplace(keyValue[1], "_#_EQ-#_", "="), "_#_AC-#_", "\\"), "_#_CR-#_", "`n")
						value := StrReplace(StrReplace(StrReplace(keyValue[2], "_#_EQ-#_", "="), "_#_AC-#_", "\"), "_#_CR-#_", "`n")

						configuration[section][keyValue[1]] := ((value = kTrue) ? true : ((value = kFalse) ? false : value))
					}
				}
			}
		}
	}

	return configuration
}

parseConfiguration(text) {
	local fileName := temporaryFileName("Config", "ini")
	local configuration

	FileAppend %text%, %fileName%, UTF-16

	configuration := readConfiguration(fileName)

	deleteFile(fileName)

	return configuration
}

writeConfiguration(configFile, configuration, symbolic := true) {
	local tempFile := temporaryFileName("Config", "ini")
	local directory, section, keyValues, key, value, pairs, tries

	deleteFile(tempFile)

	for section, keyValues in configuration {
		pairs := ""

		for key, value in keyValues {
			value := StrReplace(value, "\", "\\")
			value := StrReplace(value, "=", "\=")
			value := StrReplace(value, "`n", "\n")

			pairs := (pairs . "`n" . key . "=" . (symbolic ? ((value == true) ? kTrue : ((value == false) ? kFalse : value)) : value))
		}

		section := "[" . section . "]" . pairs . "`n"

		FileAppend %section%, %tempFile%, UTF-16
	}

	configFile := getFileName(configFile, kUserConfigDirectory)

	SplitPath configFile, , directory
	FileCreateDir %directory%

	tries := 10

	loop
		try {
			FileMove %tempFile%, %configFile%, 1

			break
		}
		catch exception {
			logError(exception)

			if (tries-- <= 0)
				break
		}
}

printConfiguration(configuration, symbolic := true) {
	local fileName := temporaryFileName("Config", "ini")
	local text

	writeConfiguration(fileName, configuration, symbolic)

	try {
		FileRead text, %fileName%
	}
	catch exception {
		text := ""
	}

	deleteFile(fileName)

	return text
}

getConfigurationValue(configuration, section, key, default := false) {
	local value

	if configuration.HasKey(section) {
		value := configuration[section]

		if value.HasKey(key)
			return value[key]
	}

	return default
}

getConfigurationSectionValues(configuration, section, default := false) {
	return configuration.HasKey(section) ? configuration[section].Clone() : default
}

setConfigurationValue(configuration, section, key, value) {
	configuration[section, key] := value
}

setConfigurationSectionValues(configuration, section, values) {
	local key, value

	removeConfigurationSection(configuration, section)

	for key, value in values
		setConfigurationValue(configuration, section, key, value)
}

setConfigurationValues(configuration, otherConfiguration) {
	local section, values

	for section, values in otherConfiguration
		setConfigurationSectionValues(configuration, section, values)
}

removeConfigurationValue(configuration, section, key) {
	if configuration.HasKey(section)
		configuration[section].Delete(key)
}

removeConfigurationSection(configuration, section) {
	if configuration.HasKey(section)
		configuration.Delete(section)
}