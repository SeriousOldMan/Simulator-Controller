;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - RST Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startRST() {
	local rstApplication := new Application("RST Telemetry", SimulatorController.Instance.Configuration)
	local pid

	if !rstApplication.isRunning() {
		pid := rstApplication.startup(false)

		if pid {
			WinWait ahk_pid %pid%

			if !WinActive("ahk_pid " . pid)
				WinActivate ahk_pid %pid%

			protectionOn()

			try {
				Sleep 2000

				MouseClick Left,  860,  21

				Sleep 2000

				MouseClick Left,  830,  115
			}
			finally {
				protectionOff()
			}
		}

		return pid
	}
	else
		return rstApplication.CurrentPID
}
