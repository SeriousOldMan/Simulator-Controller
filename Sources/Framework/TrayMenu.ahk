;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Tray Menu Functions             ;;;
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
#Include ..\Framework\Localization.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Task.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vTrayMessageDuration := false

global vHasTrayMenu := false


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

exitApplication() {
	ExitApp 0
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

hasTrayMenu() {
	return vHasTrayMenu
}

installTrayMenu(update := false) {
	local icon := kIconsDirectory . "Pause.ico"
	local label := translate("Exit")
	local levels, level, ignore, oldLabel, label, handler

	if !update {
		Menu Tray, Icon, %icon%, , 1

		Sleep 50
	}

	if (update && vHasTrayMenu) {
		oldLabel := translate("Exit", vHasTrayMenu)

		Menu Tray, Rename, %oldLabel%, %label%
	}
	else {
		Menu Tray, NoStandard
		Menu Tray, Add, %label%, exitApplication
	}

	try {
		Menu LogMenu, DeleteAll
	}
	catch exception {
		logError(exception)
	}

	try {
		Menu SupportMenu, DeleteAll
	}
	catch exception {
		logError(exception)
	}

	levels := kLogLevels

	for ignore, label in kLogLevelNames {
		level := levels[label]

		label := translate(label)
		handler := Func("setLogLevel").Bind(level)

		Menu LogMenu, Add, %label%, %handler%

		if (level == getLogLevel())
			Menu LogMenu, Check, %label%
	}

	label := translate("Debug")
	handler := Func("toggleDebug")

	Menu SupportMenu, Add, %label%, %handler%

	if isDebug()
		Menu SupportMenu, Check, %label%

	label := translate("Logging")

	Menu SupportMenu, Add, %label%, :LogMenu

	Menu SupportMenu, Add

	label := translate("Clear log files")
	handler := Func("deleteDirectory").Bind(kLogsDirectory, false)

	Menu SupportMenu, Add, %label%, %handler%

	label := translate("Clear temporary files")
	handler := Func("deleteDirectory").Bind(kTempDirectory, false)

	Menu SupportMenu, Add, %label%, %handler%

	label := translate("Support")

	if (update && vHasTrayMenu) {
		oldLabel := translate("Support", vHasTrayMenu)

		Menu Tray, Delete, %oldLabel%
		Menu Tray, Insert, 1&, %label%, :SupportMenu
	}
	else {
		Menu Tray, Insert, 1&
		Menu Tray, Insert, 1&, %label%, :SupportMenu
	}

	vHasTrayMenu := getLanguage()
}

trayMessage(title, message, duration := false, async := true) {
	if (async && (duration || vTrayMessageDuration))
		Task.startTask(Func("trayMessage").Bind(title, message, duration, false), 0, kLowPriority)
	else {
		title := StrReplace(title, "`n", A_Space)
		message := StrReplace(message, "`n", A_Space)

		if !duration
			duration := vTrayMessageDuration

		if duration {
			protectionOn()

			try {
				TrayTip %title%, %message%

				Sleep %duration%

				TrayTip

				if SubStr(A_OSVersion,1,3) = "10." {
					Menu Tray, NoIcon
					Sleep 200  ; It may be necessary to adjust this sleep...
					Menu Tray, Icon
				}
			}
			finally {
				protectionOff()
			}
		}
	}
}

disableTrayMessages() {
	vTrayMessageDuration := false
}

enableTrayMessages(duration := 1500) {
	vTrayMessageDuration := duration
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

registerLocalizationCallback("installTrayMenu")

installTrayMenu()