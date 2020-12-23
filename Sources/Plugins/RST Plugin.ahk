;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - RST Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2020) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startRST() {
	rstApplication := new Application("RST Telemetry", SimulatorController.Instance.Configuration)
	
	if !rstApplication.isRunning() {
		pid := rstApplication.startup(false)
	
		if pid {
			WinWait ahk_pid %pid%
			IfWinNotActive ahk_pid %pid%, , WinActivate, ahk_pid %pid%, 
			WinWaitActive ahk_pid %pid%, , 10
			Sleep 5000
			MouseClick left,  860,  21
			Sleep 2000
			MouseClick left,  830,  115
		}
		
		return pid
	}
	else
		return.rstApplication.CurrentPID
}
