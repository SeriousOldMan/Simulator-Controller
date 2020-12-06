;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Core Plugin                     ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2020) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startAITrack() {
	aiTrack := new Application("Face Recognition", SimulatorController.Instance.Configuration)
	windowTitle := aiTrack.WindowTitle
	
	aiTrack.startup(false)
	
	WinWait %windowTitle%, 
	WinMove %windowTitle%, , 50, 50

	active := false

	while !active {
		IfWinNotActive %windowTitle%, , WinActivate, %windowTitle% 
		WinWaitActive %windowTitle%, , 1
	
		active := (ErrorLevel == 0)
	}

	MouseClick left,  201,  344
	Sleep 5000
	WinMinimize %windowTitle%
	Sleep 100
}