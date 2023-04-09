;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Utility Functions               ;;;
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
#Include "..\Framework\MultiMap.ahk"
#Include "..\Framework\Files.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

getControllerState(configuration := "__Undefined__") {
	local load := true
	local pid, tries, options, exePath, fileName

	if (configuration == false)
		load := false
	else if (configuration = kUndefined)
		configuration := false

	pid := ProcessExist("Simulator Controller.exe")

	if (load && !pid && (configuration || !FileExist(kTempDirectory . "Simulator Controller.state")))
		try {
			if configuration {
				fileName := temporaryFileName("Config", "ini")

				writeMultiMap(fileName, configuration)

				options := (" -Configuration `"" . fileName . "`"")
			}
			else
				options := ""

			exePath := ("`"" . kBinariesDirectory . "Simulator Controller.exe`" -NoStartup -NoUpdate" .  options)

			Run(exePath, kBinariesDirectory, , &pid)

			Sleep(1000)

			tries := 30

			while (tries > 0) {
				Sleep(200)

				if !ProcessExist(pid)
					break
			}

			if configuration
				deleteFile(fileName)
		}
		catch Any as exception {
			logMessage(kLogCritical, translate("Cannot start Simulator Controller (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

			return newMultiMap()
		}


	return readMultiMap(kTempDirectory . "Simulator Controller.state")
}

createGUID() {
	local guid, pGuid, sGuid, size

    pGuid := Buffer(16, 0)

	if !DllCall("ole32.dll\CoCreateGuid", "ptr", pGuid) {
		sGuid := Buffer((38 + 1) * 2, 0)

        if (DllCall("ole32.dll\StringFromGUID2", "ptr", pGuid, "ptr", sGuid, "int", sGuid.Size)) {
			guid := StrGet(sGuid)

            return SubStr(SubStr(guid, 1, StrLen(guid) - 1), 2)
		}
    }

    return ""
}

isNull(value) {
	return ((value = kNull) || (value == "__Null__"))
}

toObject(candidate, class := Object) {
	local key, value

	if !isInstance(candidate, class) {
		local result := class()

		for key, value in candidate
			result.%key% := value

		return result
	}
	else
		return candidate
}

toMap(candidate, class := Map) {
	local key, value

	if !isInstance(candidate, class) {
		local result := class()

		if !isInstance(candidate, Map) {
			for key, value in candidate.OwnProps()
				result[key] := value
		}
		else {
			for key, value in candidate
				result[key] := value
		}

		return result
	}
	else
		return candidate
}

isInstance(object, root) {
	return (object is root)
}