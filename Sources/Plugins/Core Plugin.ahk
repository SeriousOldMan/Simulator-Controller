;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Core Plugin                     ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startAITrack() {
	aiTrack := new Application("Face Recognition", SimulatorController.Instance.Configuration)
	
	if !aiTrack.isRunning() {
		pid := aiTrack.startup(false)
		
		if pid {
			windowTitle := aiTrack.WindowTitle
			
			WinWait %windowTitle%, 
			WinMove %windowTitle%, , 50, 50

			active := false

			while !active {
				IfWinNotActive %windowTitle%, , WinActivate, %windowTitle% 
				WinWaitActive %windowTitle%, , 1
			
				active := (ErrorLevel == 0)
			}

			protectionOn()
			
			try {
				MouseClick left,  201,  344
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
	voiceMacro := new Application("Voice Recognition", SimulatorController.Instance.Configuration)
	
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
					IfWinNotActive %windowTitle%, , WinActivate, %windowTitle% 
					WinWaitActive %windowTitle%, , 1
				
					active := (ErrorLevel == 0)
				}
				
				protectionOn()
			
				try {
					MouseClick, left,  465,  45
					Sleep, 1000
					MouseClick, left,  465,  45
					Sleep, 1000
					MouseClick, left,  524,  13
					Sleep, 100
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