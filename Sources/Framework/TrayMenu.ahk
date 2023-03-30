;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Tray Menu Functions             ;;;
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
#Include "..\Framework\Localization.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Task.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vTrayMessageDuration := false

global vHasTrayMenu := false


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
	return vHasTrayMenu
}

installTrayMenu(update := false) {
	global vHasTrayMenu
	local icon := kIconsDirectory . "Pause.ico"
	local label := translate("Exit")
	local levels, level, ignore, oldLabel

	if !update {
		TraySetIcon(icon, "1")

		Sleep(50)
	}

	if (update && vHasTrayMenu) {
		oldLabel := translate("Exit", vHasTrayMenu)

		A_TrayMenu.Rename(oldLabel, label)
	}
	else {
		A_TrayMenu.Delete()

		A_TrayMenu.Add(label, exitApplication)
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

	if (update && vHasTrayMenu) {
		oldLabel := translate("Support", vHasTrayMenu)

		A_TrayMenu.Delete(oldLabel)
		A_TrayMenu.Insert("1&", label, SupportMenu)
	}
	else {
		A_TrayMenu.Insert("1&")
		A_TrayMenu.Insert("1&", label, SupportMenu)
	}

	vHasTrayMenu := getLanguage()
}

trayMessage(title, message, duration := false, async := true) {
	global vTrayMessageDuration

	if (async && (duration || vTrayMessageDuration))
		Task.startTask(trayMessage.Bind(title, message, duration, false), 0, kLowPriority)
	else {
		title := StrReplace(title, "`n", A_Space)
		message := StrReplace(message, "`n", A_Space)

		if !duration
			duration := vTrayMessageDuration

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
	global vTrayMessageDuration

	vTrayMessageDuration := false
}

enableTrayMessages(duration := 1500) {
	global vTrayMessageDuration

	vTrayMessageDuration := duration
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

registerLocalizationCallback(installTrayMenu)

installTrayMenu()