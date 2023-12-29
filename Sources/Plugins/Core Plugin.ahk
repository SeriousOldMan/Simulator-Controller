;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Core Plugin                     ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startAITrack() {
	local aiTrack := Application("Face Recognition", SimulatorController.Instance.Configuration)
	local pid, windowTitle

	if !aiTrack.isRunning() {
		pid := aiTrack.startup(false)

		if pid {
			windowTitle := aiTrack.WindowTitle

			try {
				WinWait(windowTitle)

				if !WinActive(windowTitle)
					Sleep(1000)

				WinMove(50, 50, , , windowTitle)

				while !WinActive(windowTitle) {
					WinActivate(windowTitle)

					Sleep(500)
				}

				protectionOn()

				try {
					MouseClick("Left", 201, 344)
					Sleep(5000)
					WinMinimize(windowTitle)
					Sleep(100)
				}
				finally {
					protectionOff()
				}
			}
			catch Any as exception {
				logError(exception)
			}
		}

		return pid
	}
	else
		return aiTrack.CurrentPID
}

startVoiceMacro() {
	local voiceMacro := Application("Voice Recognition", SimulatorController.Instance.Configuration)
	local pid, curDetectHiddenWindows, windowTitle, active

	if !voiceMacro.isRunning() {
		pid := voiceMacro.startup(false)

		if pid {
			curDetectHiddenWindows := A_DetectHiddenWindows

			DetectHiddenWindows(true)

			try {
				windowTitle := voiceMacro.WindowTitle

				WinWait(windowTitle)

				WinMaximize(windowTitle)

				WinActivate(windowTitle)

				if !WinActive(windowTitle) {
					Sleep(1000)

				WinMove(50, 50, , , windowTitle)

				while !WinActive(windowTitle) {
					WinActivate(windowTitle)

					Sleep(500)
				}

				protectionOn()

				try {
					; MouseClick, Left,  465,  45
					; MouseClick, Left,  465,  45
					WinMinimize(windowTitle)
					Sleep(100)
				}
				finally {
					protectionOff()
				}
			}
			catch Any as exception {
				logError(exception)
			}
			finally {
				DetectHiddenWindows(curDetectHiddenWindows)
			}
		}

		return pid
	}
	else
		return voiceMacro.CurrentPID
}