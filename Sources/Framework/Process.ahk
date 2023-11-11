;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Global Process Framework        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
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
	local isCritical := Task.CriticalHandler

	guardExit(*) {
		if (isCritical() && !GetKeyState("Ctrl", "P")) {
			OnMessage(0x44, translateOkButton)
			MsgBox(translate("Please wait until all tasks have been finished."), StrSplit(A_ScriptName, ".")[1], 262192)
			OnMessage(0x44, translateOkButton, 0)

			return true
		}
		else
			return false
	}

	Task.CriticalHandler := (*) => guardExit()

	OnExit(guardExit, -1)

	MessageManager.resume()
}


;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

MessageManager.pause()