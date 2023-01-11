;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Core Plugin                     ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startAITrack() {
	local aiTrack := new Application("Face Recognition", SimulatorController.Instance.Configuration)
	local pid, windowTitle, active

	if !aiTrack.isRunning() {
		pid := aiTrack.startup(false)

		if pid {
			windowTitle := aiTrack.WindowTitle

			WinWait %windowTitle%,
			WinMove %windowTitle%, , 50, 50

			active := false

			while !active {
				if !WinActive(windowTitle)
					WinActivate %windowTitle%

				active := (ErrorLevel == 0)

				if !active
					Sleep 500
			}

			protectionOn()

			try {
				MouseClick Left,  201,  344
				Sleep 5000
				WinMinimize %windowTitle%
				Sleep 100
			}
			finally {
				protectionOff()
			}
		}

		return pid
	}
	else
		return aiTrack.CurrentPID
}

startVoiceMacro() {
	local voiceMacro := new Application("Voice Recognition", SimulatorController.Instance.Configuration)
	local pid, curDetectHiddenWindows, windowTitle, active

	if !voiceMacro.isRunning() {
		pid := voiceMacro.startup(false)

		if pid {
			curDetectHiddenWindows := A_DetectHiddenWindows

			DetectHiddenWindows On

			try {
				windowTitle := voiceMacro.WindowTitle

				IfWinNotActive %windowTitle%, , WinMaximize, %windowTitle%
				Sleep 1000

				WinWait %windowTitle%,
				WinMove %windowTitle%, , 50, 50

				active := false

				while !active {
					if !WinActive(windowTitle)
						WinActivate %windowTitle%

					active := (ErrorLevel == 0)

					if !active
						Sleep 500
				}

				protectionOn()

				try {
					; MouseClick, Left,  465,  45
					; MouseClick, Left,  465,  45
					WinMinimize %windowTitle%
					Sleep 100
				}
				finally {
					protectionOff()
				}
			}
			finally {
				DetectHiddenWindows % curDetectHiddenWindows
			}
		}

		return pid
	}
	else
		return voiceMarco.CurrentPID
}