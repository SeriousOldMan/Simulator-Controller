;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Utility Functions               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Constants.ahk"
#Include "Variables.ahk"
#Include "Configuration.ahk"
#Include "Debug.ahk"
#Include "MultiMap.ahk"
#Include "Files.ahk"
#Include "Startup.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\CLR.ahk"
#Include "..\Libraries\Messages.ahk"
#Include "..\Libraries\Task.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                    Private Classes Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

class TriggerDetectorTask extends Task {
	iCallback := false
	iOptions := []
	iJoysticks := []

	Options {
		Get {
			return this.iOptions
		}
	}

	CallBack {
		Get {
			return this.iCallback
		}
	}

	Stopped {
		Get {
			return super.Stopped
		}

		Set {
			if value
				ToolTip(, , 1)

			return (super.Stopped := value)
		}
	}

	Joysticks[key?] {
		Get {
			return (isSet(key) ? this.iJoysticks[key] : this.iJoysticks)
		}
	}

	__New(callback, options, arguments*) {
		this.iOptions := options
		this.iCallback := callback

		super.__New(false, arguments*)
	}

	run() {
		local joysticks := []
		local joyName

		loop 16 { ; Query each joystick number to find out which ones exist.
			joyName := (GetKeyState(A_Index . "JoyName") ? "D" : "")

			if (joyName != "")
				joysticks.Push(A_Index)
		}

		this.iJoysticks := joysticks

		return TriggerDetectorContinuation(Task.CurrentTask)
	}
}

class TriggerDetectorContinuation extends Continuation {
	__New(task, arguments*) {
		super.__New(task, false, arguments*)
	}

	run() {
		local key := false
		local found, joysticks, joystickNumber, joy_buttons, joy_name, joy_state, buttons_down, joy_info
		local axis_info, buttonsDown, callback

		if !this.Task.Stopped {
			found := false

			if GetKeyState("Esc") {
				this.stop()

				return false
			}

			key := (inList(this.Task.Options, "Key") ? this.detectKey(inList(this.Task.Options, "Multi")) : false)

			if key {
				if InStr(key, "Esc") {
					this.stop()

					return false
				}

				found := true

				ToolTip(key, , , 1)
			}
			else if inList(this.Task.Options, "Joy") {
				joysticks := this.Task.Joysticks

				loop joysticks.Length {
					joystickNumber := joysticks[1]

					joysticks.RemoveAt(1)
					joysticks.Push(joystickNumber)

					; SetFormat Float, 03  ; Omit decimal point from axis position percentages.

					joy_buttons := GetKeyState(joystickNumber . "JoyButtons")
					joy_name := GetKeyState(joystickNumber . "JoyName")
					joy_info := GetKeyState(joystickNumber . "JoyInfo")

					buttons_down := ""
					buttons := []

					loop joy_buttons {
						if GetKeyState(joystickNumber . "joy" . A_Index) {
							buttons_down := (buttons_down . A_Space . A_Index)

							found := A_Index
						}
					}

					axis_info := ("X" . (GetKeyState(joystickNumber . "JoyX") ? "D" : "U"))

					axis_info := (axis_info . A_Space . A_Space . "Y" .  (GetKeyState(joystickNumber . "JoyY") ? "D" : "U"))

					if InStr(joy_info, "Z")
						axis_info := (axis_info . A_Space . A_Space . "Z" . (GetKeyState(joystickNumber . "JoyZ") ? "D" : "U"))

					if InStr(joy_info, "R")
						axis_info := (axis_info . A_Space . A_Space . "R" . (GetKeyState(joystickNumber . "JoyR") ? "D" : "U"))

					if InStr(joy_info, "U")
						axis_info := (axis_info . A_Space . A_Space . "U" . (GetKeyState(joystickNumber . "JoyU") ? "D" : "U"))

					if InStr(joy_info, "V")
						axis_info := (axis_info . "" . A_Space . "" . A_Space . "V" . (GetKeyState(joystickNumber "JoyV", ) ? "D" : "U"))

					if InStr(joy_info, "P")
						axis_info := (axis_info . A_Space . A_Space . "POV" . (GetKeyState(joystickNumber "JoyPOV") ? "D" : "U"))

					buttonsDown := translate("Buttons Down:")
				}
				until found

				if found
					ToolTip(joy_name . " (#" joystickNumber "):`n" . axis_info . "`n" . buttonsDown . A_Space . buttons_down, , , 1)
			}

			if found {
				if !key
					key := (joystickNumber . "Joy" . found)

				A_Clipboard := key

				if this.Task.Callback {
					this.Task.Callback.Call(key)

					this.stop()

					return false
				}
				else
					return TriggerDetectorContinuation(this.Task, 2000)
			}
			else
				ToolTip(translate("Waiting..."), , , 1)

			return TriggerDetectorContinuation(this.Task, 0)
		}
		else {
			this.stop()

			return false
		}
	}

	detectKey(multi) {
		local input := InputHook("T0.1")
		local key, expired

		static lastTicks := false
		static lastKeys := []

		expired := (lastTicks ? ((A_TickCount - lastTicks) > 500) : false)

		if !multi
			lastKeys := []

		input.KeyOpt("{All}", "IE")

		input.VisibleText := false
		input.VisibleNonText := false

		input.Start()

		input.Wait()

		key := input.EndKey

		input.Stop()

		if (key && (key != ""))
			if multi {
				if !expired {
					if (lastKeys.Length = 0)
						lastTicks := A_TickCount

					if !inList(lastKeys, key)
						lastKeys.Push(key)
				}
			}
			else
				return key

		if (multi && expired) {
			lastTicks := false

			if (lastKeys.Length > 0) {
				key := this.createHotkey(lastKeys)

				lastKeys := []

				return key
			}
			else
				return false
		}

		return false
	}

	createHotkey(keys) {
		local baseKeys := []
		local baseKey := kUndefined
		local ignore, key, modifiers

		loop 26
			baseKeys.Push(Chr(Ord("a") + A_Index - 1))

		loop 10 {
			baseKeys.Push(String(A_Index - 1))
			baseKeys.Push("Numpad" . (A_Index - 1))
		}

		loop 24
			baseKeys.Push("F" . A_Index)

		for ignore, key in ["Space", "BackSpace", "Tab", "Enter", "Up", "Down", "Left", "Right"
						  , "Home", "End", "Delete", "Insert", "PgUp", "PgDn"]
			baseKeys.Push(key)

		for ignore, key in keys.Clone()
			if inList(baseKeys, key) {
				if (baseKey == kUndefined)
					baseKey := key

				keys := remove(keys, key)
			}

		if (baseKey != kUndefined) {
			modifiers := ""

			for ignore, key in keys
				switch key, false {
					case "LShift":
						modifiers .= "<+"
					case "RShift":
						modifiers .= ">+"
					case "LControl":
						modifiers .= "<^"
					case "RControl":
						modifiers .= ">^"
					case "LAlt":
						modifiers .= "<!"
					case "RAlt":
						modifiers .= ">!"
					case "AltGr":
						modifiers .= "<^>!"
					case "Win":
						modifiers .= "#"
				}

			return (modifiers . baseKey)
		}
		else
			return values2String(" & ", keys*)
	}
}


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

	if kLogStartup
		logMessage(kLogOff, "Requesting controller configuration - Start...")

	try {
		if !isSet(configuration)
			configuration := false
		else if (configuration == false)
			load := false
		else if (configuration == true)
			configuration := false

		pid := ProcessExist("Simulator Controller.exe")

		if force
			deleteFile(kTempDirectory . "Simulator Controller.state")

		if (isSet(isProperInstallation) && isProperInstallation() && load && FileExist(kUserConfigDirectory . "Simulator Controller.install"))
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

					RunWait(exePath, kBinariesDirectory)
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
	finally {
		if kLogStartup
			logMessage(kLogOff, "Requesting controller configuration - Done...")
	}
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
									 , "AMS2", "DLL", "PCARS2", "DLL", "RF2", "CLR", "LMU", "CLR")
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

				SetWorkingDir(kBinariesDirectory . "Connectors\")

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
				dllFile := (kBinariesDirectory . "Connectors\" . dllName)

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
			exePath := (kBinariesDirectory . "Providers\" . simulator . " SHM Provider.exe")

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

exitProcess(urgent := false) {
	global kGuardExit

	if urgent
		kGuardExit := false

	ExitApp(0)
}

exitProcesses(title, message, silent := false, force := false, excludes := [], urgent := false) {
	local foregroundApps := kForegroundApps
	local backgroundApps := kBackgroundApps
	local pid, hasFGProcesses, hasBGProcesses, ignore, app, translator, msgResult, processes

	computeTargets(targets) {
		local ignore, exclude

		for ignore, exclude in excludes
			targets := remove(targets, exclude)

		return targets
	}

	pid := ProcessExist()

	for ignore, app in excludes {
		foregroundApps := remove(foregroundApps, app)
		backgroundApps := remove(backgroundApps, app)
	}

	while true {
		hasFGProcesses := false
		hasBGProcesses := false

		for ignore, app in foregroundApps
			if ProcessExist(app . ".exe") {
				hasFGProcesses := true

				break
			}

		for ignore, app in backgroundApps
			if ProcessExist(app ".exe") {
				hasBGProcesses := true

				break
			}

		if (hasFGProcesses && !silent) {
			translator := translateMsgBoxButtons.Bind(["Continue", "Cancel"])

			OnMessage(0x44, translator)
			msgResult := withBlockedWindows(MsgBox, translate(message), translate(title), 8500)
			OnMessage(0x44, translator, 0)

			if (msgResult = "Yes") {
				if (GetKeyState("Ctrl") && (force = "CANCEL"))
					return true
				else if !force
					continue
			}
			else
				return false
		}

		if hasFGProcesses
			if force {
				if (urgent = "Kill")
					doApplications(computeTargets(foregroundApps), ProcessClose)
				else
					broadcastMessage(computeTargets(foregroundApps), "exitProcess", urgent)
			}
			else
				return false

		if hasBGProcesses
			if (urgent = "Kill")
				doApplications(computeTargets(foregroundApps), ProcessClose)
			else
				broadcastMessage(computeTargets(backgroundApps), "exitProcess", urgent)

		return true
	}
}

triggerDetector(callback := false, options := ["Joy", "Key"]) {
	static detectorTask := false

	if (callback = "Active")
		return (detectorTask && !detectorTask.Stopped)
	else {
		if (detectorTask && detectorTask.Stopped)
			detectorTask := false

		if detectorTask {
			detectorTask.stop()

			detectorTask := false
		}
		else if (callback != "Stop") {
			detectorTask := TriggerDetectorTask(callback, options, 100)

			detectorTask.start()
		}
	}
}

testAssistants(configurator, assistants := kRaceAssistants) {
	local configuration := configurator.getSimulatorConfiguration()
	local configurationFile := temporaryFileName("Simulator Configuration", "ini")
	local thePlugin, ignore, assistant, options, parameter, value

	deleteConfiguration(*) {
		deleteFile(configurationFile)

		return false
	}

	writeMultiMap(configurationFile, configuration)

	if !isDebug()
		OnExit(deleteConfiguration)

	Run(kBinariesDirectory . "Voice Server.exe -Debug true -Configuration `"" . configurationFile . "`"")

	Sleep(2000)

	language := getMultiMapValue(configuration, "Voice Control", "Language", getLanguage())

	for ignore, assistant in assistants {
		thePlugin := Plugin(assistant, configuration)

		options := ""

		for ignore, parameter in ["Name", "Language", "Synthesizer", "Speaker", "SpeakerVocalics", "Recognizer", "Listener"]
			if thePlugin.hasArgument("raceAssistant" . parameter) {
				value := thePlugin.getArgumentValue("raceAssistant" . parameter)

				if ((value = "On") || (value = kTrue))
					value := true
				else if ((value = "Off") || (value = kFalse))
					value := false

				options .= (" -" . parameter . " `"" . value . "`"")
			}

		Run(kBinariesDirectory . assistant . ".exe -Logo true -Debug true -Configuration `"" . configurationFile . "`"" . options)
	}
}