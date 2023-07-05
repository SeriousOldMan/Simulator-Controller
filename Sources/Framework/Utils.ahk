;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Utility Functions               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Constants.ahk"
#Include "Variables.ahk"
#Include "Debug.ahk"
#Include "MultiMap.ahk"
#Include "Files.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\CLR.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

getControllerState(configuration := kUndefined) {
	local load := true
	local pid, tries, options, exePath, fileName

	if (configuration == false)
		load := false
	else if (configuration = kUndefined)
		configuration := false

	pid := ProcessExist("Simulator Controller.exe")

	if (load && !pid && (configuration || !FileExist(kTempDirectory . "Simulator Controller.state")))
		if FileExist(kUserConfigDirectory . "Simulator Controller.install")
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

callSimulator(simulator, options := "", protocol?) {
	local exePath, dataFile, data
	local connector, curWorkingDir, buf
	local dllName, dllFile

	static defaultProtocol := getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory)), "Simulator", "Data Provider", "DLL")
	static protocols := CaseInsenseMap("AC", "CLR", "ACC", "DLL", "R3E", "DLL", "IRC", "DLL"
									 , "AMS2", "DLL", "PCARS2", "DLL", "RF2", "CLR")
	static connectors := CaseInsenseMap()

	if (defaultProtocol = "EXE")
		protocol := "EXE"
	else if (!isSet(protocol) && protocols.Has(simulator))
		protocol := protocols[simulator]

	try {
		if (protocol = "DLL") {
			if connectors.Has(simulator . ".DLL")
				connector := connectors[simulator . ".DLL"]
			else {
				curWorkingDir := A_WorkingDir

				SetWorkingDir(kBinariesDirectory)

				try {
					connector := DllCall("LoadLibrary", "Str", simulator . " SHM Connector.dll", "Ptr")

					DLLCall(simulator . " SHM Connector\open")

					connectors[simulator . ".DLL"] := connector
				}
				finally {
					SetWorkingDir(curWorkingDir)
				}
			}

			buf := Buffer(1024 * 1024)

			DllCall(simulator . " SHM Connector\call", "AStr", options, "Ptr", buf, "Int", buf.Size)

			data := parseMultiMap(StrGet(buf, "UTF-8"))
		}
		else if (protocol = "CLR") {
			if connectors.Has(simulator . ".CLR")
				connector := connectors[simulator . ".CLR"]
			else {
				dllName := (simulator . " SHM Connector.dll")
				dllFile := (kBinariesDirectory . dllName)

				if (!FileExist(dllFile))
					throw "Unable to find " . dllName . " in " . kBinariesDirectory . "..."

				connector := CLR_LoadLibrary(dllFile).CreateInstance("SHMConnector.SHMConnector")

				if (!connector.Open() && !isDebug())
					throw "Cannot startup " . dllName . " in " . kBinariesDirectory . "..."

				connectors[simulator . ".CLR"] := connector
			}

			data := connector.Call(options)
			data := parseMultiMap(data)
		}
		else if (protocol = "EXE") {
			exePath := (kBinariesDirectory . simulator . A_Space . " SHM Provider.exe")

			if !FileExist(exePath)
				throw "File not found..."

			DirCreate(kTempDirectory . simulator . " Data")

			dataFile := temporaryFileName(simulator . " Data\SHM", "data")

			RunWait(A_ComSpec . " /c `"`"" . exePath . "`" `"" . options . "`" > `"" . dataFile . "`"`"", , "Hide")

			data := readMultiMap(dataFile)

			deleteFile(dataFile)
		}

		setMultiMapValue(data, "Session Data", "Simulator", simulator)

		return data
	}
	catch Any as exception {
		logError(exception, true)

		if (protocol = "EXE") {
			logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider (")
													   , {simulator: simulator, protocol: protocol})
								   . exePath . translate(") - please rebuild the applications in the binaries folder (")
								   . kBinariesDirectory . translate(")"))

			showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration...")
										  , {exePath: exePath, simulator: simulator, protocol: "SHM"})
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

			return newMultiMap()
		}
		else
			return callSimulator(simulator, options, "EXE")
	}
}