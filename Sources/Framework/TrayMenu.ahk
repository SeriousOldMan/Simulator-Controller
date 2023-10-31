;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Tray Menu Functions             ;;;
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
#Include "Files.ahk"
#Include "Localization.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Task.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global gTrayMessageDuration := false

global gHasTrayMenu := false


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

emptyLogsDirectory(*) {
	deleteDirectory(kLogsDirectory, false)
}

emptyTempDirectory(*) {
	deleteDirectory(kTempDirectory, false)
}

exitApplication(*) {
	ExitApp(0)
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

hasTrayMenu() {
	return gHasTrayMenu
}

installTrayMenu(update := false) {
	global gHasTrayMenu
	local icon := kIconsDirectory . "Pause.ico"
	local label := translate("Exit")
	local levels, level, ignore, oldLabel

	if !update {
		TraySetIcon(icon, "1")

		Sleep(50)
	}

	if (update && gHasTrayMenu) {
		oldLabel := translate("Exit", gHasTrayMenu)

		A_TrayMenu.Rename(oldLabel, label)
	}
	else {
		A_TrayMenu.Delete()

		A_TrayMenu.Add(label, (*) => exitProcess())
	}

	try {
		LogMenu.Delete()
	}
	catch Any as exception {
		logError(exception)
	}

	try {
		SupportMenu.Delete()
	}
	catch Any as exception {
		logError(exception)
	}

	levels := kLogLevels

	for ignore, label in kLogLevelNames {
		level := levels[label]

		label := translate(label)

		LogMenu.Add(label, setLogLevel.Bind(level))

		if (level == getLogLevel())
			LogMenu.Check(label)
	}

	label := translate("Debug")

	SupportMenu.Add(label, toggleDebug)

	if isDebug()
		SupportMenu.Check(label)

	SupportMenu.Add(translate("Logging"), LogMenu)

	SupportMenu.Add()

	SupportMenu.Add(translate("Clear log files"), emptyLogsDirectory)
	SupportMenu.Add(translate("Clear temporary files"), emptyTempDirectory)

	label := translate("Support")

	if (update && gHasTrayMenu) {
		oldLabel := translate("Support", gHasTrayMenu)

		A_TrayMenu.Delete(oldLabel)
		A_TrayMenu.Insert("1&", label, SupportMenu)
	}
	else {
		A_TrayMenu.Insert("1&")
		A_TrayMenu.Insert("1&", label, SupportMenu)
	}

	gHasTrayMenu := getLanguage()
}

trayMessage(title, message, duration := false, async := true) {
	global gTrayMessageDuration

	if (async && (duration || gTrayMessageDuration))
		Task.startTask(trayMessage.Bind(title, message, duration, false), 0, kLowPriority)
	else {
		title := StrReplace(StrReplace(title, "`n", A_Space), "`r", "")
		message := StrReplace(StrReplace(message, "`n", A_Space), "`r", "")

		if !duration
			duration := gTrayMessageDuration

		if duration {
			protectionOn()

			try {
				TrayTip(title, message)

				Sleep(duration)

				TrayTip()

				if SubStr(A_OSVersion, 1, 3) = "10." {
					A_IconHidden := true
					Sleep(200)  ; It may be necessary to adjust this sleep...
					A_IconHidden := false
				}
			}
			finally {
				protectionOff()
			}
		}
	}
}

disableTrayMessages() {
	global gTrayMessageDuration

	gTrayMessageDuration := false
}

enableTrayMessages(duration := 1500) {
	global gTrayMessageDuration

	gTrayMessageDuration := duration
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

registerLocalizationCallback(installTrayMenu)

installTrayMenu()