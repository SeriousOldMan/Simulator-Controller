;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Utility Functions               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                   Global Functions Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

global sendCommand := sendKeyboardCommand
global installKeyboardHook := InstallKeybdHook
global setSendDelay := SetKeyDelay
global setHotKey := (arguments*) => Hotkeys.registerHotkey(arguments*)
global detectProcess := detectRunningProcess
global activateWindow := WinActivate
global closeWindow := WinClose
global listWindows := (arguments*) => WinGetList(arguments*)


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

#Include "Extensions\Messages.ahk"
#Include "Extensions\Task.ahk"
#Include "Extensions\Hotkeys.ahk"


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

sendKeyboardCommand(command, mode := "Event", delay := false) {
	try {
		switch mode, false {
			case "Event":
				SendEvent(command)
			case "Input":
				SendInput(command)
			case "Play":
				SendPlay(command)
			case "Raw":
				Send("{Raw}" . command)
			default:
				Send(command)
		}
	}
	catch Any as exception {
		logMessage(kLogWarn, substituteVariables(translate("Cannot send command (%command%) - please check the configuration"), {command: command}))
	}

	if delay
		Sleep(delay)
}

detectRunningProcess(pid := false, winTitle := "", exePath := "") {
	local curDetectHiddenWindows := A_DetectHiddenWindows
	local processID := false

	DetectHiddenWindows(true)

	try {
		if pid
			processID := (((ProcessExist(pid) != 0) || WinExist("ahk_pid " . pid)) ? pid : 0)

		if (!processID && (winTitle != ""))
			if WinExist(winTitle)
				processID := WinGetPID(winTitle)

		if (!processID && (exePath != ""))
			if WinExist("ahk_exe " . exePath)
				processID := WinGetPID("ahk_exe " . exePath)
	}
	finally {
		DetectHiddenWindows(curDetectHiddenWindows)
	}

	if !isNumber(processID)
		processID := false

	return processID
}

initializeUtils() {
	/*
	global sendCommand, installKeyboardHook, setSendDelay, setHotkey, detectProcess
	global activateWindow, closeWindow, listWindows

	sendCommand := sendKeyboardCommand
	installKeyboardHook := InstallKeybdHook
	setSendDelay := SetKeyDelay
	setHotKey := Hotkey
	detectProcess := detectRunningProcess
	activateWindow := WinActivate
	closeWindow := WinClose
	listWindows := WinGetList
	*/

	/*
	sendCommand := (*) => false
	installKeyboardHook := (*) => false
	setSendDelay := (*) => false
	setHotKey := (*) => false
	detectProcess := (p, *) => p
	activateWindow := (*) => false
	closeWindow := (*) => false
	listWindows := (*) => []
	*/
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

		if (isSet(isProperInstallation) && isProperInstallation() && load
		 && (FileExist(kUserConfigDirectory . "Simulator Controller.install") || (RegRead("HKLM\" . kUninstallKey, "InstallLocation", "") != "")))
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
				finally {
					if isSet(fileName)
						deleteFile(fileName)
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

	try {
		ExitApp(0)
	}
	finally {
		if urgent
			ProcessClose(ProcessExist())
	}
}

exitProcesses(title, message, silent := false, force := false, excludes := [], urgent := false) {
	local foregroundApps := kForegroundApps
	local backgroundApps := kBackgroundApps
	local pid, hasFGProcesses, hasBGProcesses, ignore, app, msgResult, processes

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
			if ProcessExist(app . ".exe") {
				hasBGProcesses := true

				break
			}

		if (hasFGProcesses && !silent) {
			msgResult := withBlockedWindows(MsgDlg, translate(message), translate(title)
												  , {Options: 8500, Mode: "Question"
												   , Buttons: collect(["Continue", "Cancel"], translate)})

			if (msgResult = translate("Continue")) {
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
				doApplications(computeTargets(backgroundApps), ProcessClose)
			else
				broadcastMessage(computeTargets(backgroundApps), "exitProcess", urgent)

		return true
	}
}

testAssistants(configurator, assistants := kRaceAssistants, extended := false) {
	local configuration := configurator.getSimulatorConfiguration()
	local configurationFile := temporaryFileName("Simulator Configuration", "ini")
	local thePlugin, ignore, assistant, options, parameter, value, found

	deleteConfiguration(*) {
		deleteFile(configurationFile)

		return false
	}

	if (configuration.Count > 0) {
		writeMultiMap(configurationFile, configuration)

		if !isDebug()
			OnExit(deleteConfiguration)

		Run(kBinariesDirectory . "Voice Server.exe -Debug true -Configuration `"" . configurationFile . "`"")

		Sleep(2000)

		for ignore, assistant in assistants {
			thePlugin := Plugin(assistant, configuration)

			if thePlugin.Active {
				options := ""

				for ignore, parameter in ["Name", "Language", "Synthesizer", "Speaker", "SpeakerVocalics", "Recognizer", "Listener"] {
					found := false

					if thePlugin.hasArgument(parameter) {
						value := thePlugin.getArgumentValue(parameter)

						found := true
					}
					else if thePlugin.hasArgument("raceAssistant" . parameter) {
						value := thePlugin.getArgumentValue("raceAssistant" . parameter)

						found := true
					}

					if found {
						if ((value = "On") || (value = kTrue))
							value := true
						else if ((value = "Off") || (value = kFalse))
							value := false

						options .= (" -" . parameter . " `"" . value . "`"")
					}
				}

				if extended
					for ignore, parameter in ["Translator", "SpeakerBooster", "ListenerBooster", "ConversationBooster", "AgentBooster"] {
						found := false

						if thePlugin.hasArgument(parameter) {
							value := thePlugin.getArgumentValue(parameter)

							found := true
						}
						else if thePlugin.hasArgument("raceAssistant" . parameter) {
							value := thePlugin.getArgumentValue("raceAssistant" . parameter)

							found := true
						}

						if found {
							if ((value = "On") || (value = kTrue))
								value := true
							else if ((value = "Off") || (value = kFalse))
								value := false

							options .= (" -" . parameter . " `"" . value . "`"")
						}
					}

				Run(kBinariesDirectory . assistant . ".exe -Logo true -Debug true -Configuration `"" . configurationFile . "`"" . options)
			}
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeUtils()