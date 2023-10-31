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
#Include "..\Libraries\Messages.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

doApplications(applications, callback) {
	local ignore, application, pid

	for ignore, application in applications {
		pid := ProcessExist(InStr(application, ".exe") ? application : (application . ".exe"))

		if pid
			callback.Call(pid)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

getControllerState(configuration?, force := false) {
	local load := true
	local pid, tries, options, exePath, fileName

	if !isSet(configuration)
		configuration := false
	else if (configuration == false)
		load := false
	else if (configuration == true)
		configuration := false

	pid := ProcessExist("Simulator Controller.exe")

	if force
		deleteFile(kTempDirectory . "Simulator Controller.state")

	if (isProperInstallation() && load && FileExist(kUserConfigDirectory . "Simulator Controller.install"))
		if (!pid && (configuration || !FileExist(kTempDirectory . "Simulator Controller.state"))) {
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

				while (tries-- > 0) {
					if !ProcessExist(pid)
						break

					Sleep(200)
				}

				if configuration
					deleteFile(fileName)

				pid := false
			}
			catch Any as exception {
				logMessage(kLogCritical, translate("Cannot start Simulator Controller (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

				return newMultiMap()
			}
		}
		else if (!FileExist(kTempDirectory . "Simulator Controller.state") && pid && (StrSplit(A_ScriptName, ".")[1] != "Simulator Controller")) {
			if (pid != ProcessExist())
				messageSend(kFileMessage, "Controller", "writeControllerState", pid)

			Sleep(1000)

			tries := 30

			while (tries-- > 0) {
				if FileExist(kTempDirectory . "Simulator Controller.state")
					break

				Sleep(200)
			}
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

			data := parseMultiMap(connector.Call(options))
		}
		else if (protocol = "EXE") {
			exePath := (kBinariesDirectory . simulator . " SHM Provider.exe")

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
		if (protocol = "EXE") {
			logError(exception, true)

			logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider (")
													   , {simulator: simulator, protocol: protocol})
								   . exePath . translate(") - please rebuild the applications in the binaries folder (")
								   . kBinariesDirectory . translate(")"))

			showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration...")
										  , {exePath: exePath, simulator: simulator, protocol: "SHM"})
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

			return newMultiMap()
		}
		else {
			logError(exception)

			return callSimulator(simulator, options, "EXE")
		}
	}
}

broadcastMessage(applications, message, arguments*) {
	if (arguments.Length > 0)
		doApplications(applications, messageSend.Bind(kFileMessage, "Core", message . ":" . values2String(";", arguments*)))
	else
		doApplications(applications, messageSend.Bind(kFileMessage, "Core", message))

}

exitProcess() {
	ExitApp(0)
}

exitProcesses(title, message, silent := false, force := false, excludes := []) {
	local pid, hasFGProcesses, hasBGProcesses, ignore, app, translator, msgResult, processes

	computeTargets(targets) {
		local ignore, exclude

		for ignore, exclude in excludes
			targets := remove(targets, exclude)

		return targets
	}

	pid := ProcessExist()

	while true {
		hasFGProcesses := false
		hasBGProcesses := false

		for ignore, app in kForegroundApps
			if (ProcessExist(app . ".exe") && !inList(excludes, app)) {
				hasFGProcesses := true

				break
			}

		for ignore, app in kBackgroundApps
			if (ProcessExist(app ".exe") && (ProcessExist(app ".exe") != pid) && !inList(excludes, app)) {
				hasBGProcesses := true

				break
			}

		if (hasFGProcesses && !silent) {
			translator := translateMsgBoxButtons.Bind(["Continue", "Cancel"])

			OnMessage(0x44, translator)
			msgResult := MsgBox(translate(message), translate(title), 8500)
			OnMessage(0x44, translator, 0)

			if (msgResult = "Yes") {
				if !force
					continue
			}
			else
				return false
		}

		if hasFGProcesses
			if force
				broadcastMessage(computeTargets(kForegroundApps), "exitProcess")
			else
				return false

		if hasBGProcesses
			broadcastMessage(computeTargets(kBackgroundApps), "exitProcess")

		return true
	}
}