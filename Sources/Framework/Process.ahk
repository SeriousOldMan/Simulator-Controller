;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Global Process Framework        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Framework.ahk"
#Include "GUI.ahk"
#Include "Message.ahk"
#Include "Progress.ahk"
#Include "Configuration.ahk"
#Include "Startup.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

startupProcess() {
	global kLogStartup

	local isCritical := Task.CriticalHandler

	if kLogStartup
		logMessage(kLogOff, "Starting process...")

	guardExit(arguments*) {
		if ((arguments.Length > 0) && inList(["Logoff", "Shutdown"], arguments[1]))
			return false

		if (isCritical() && kGuardExit && !GetKeyState("Ctrl")) {
			OnMessage(0x44, translateOkButton)
			withBlockedWindows(MsgBox, translate("Please wait until all tasks have been finished."), StrSplit(A_ScriptName, ".")[1], 262192)
			OnMessage(0x44, translateOkButton, 0)

			return true
		}
		else
			return false
	}

	Task.CriticalHandler := (*) => guardExit()

	OnExit(guardExit, -1)

	if kLogStartup
		logMessage(kLogOff, "Starting message handler...")

	MessageManager.resume()

	kLogStartup := false
}


;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

MessageManager.pause()