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

startVoiceMacro() {
	voiceMacro := new Application("Voice Recognition", SimulatorController.Instance.Configuration)
	windowTitle := voiceMacro.WindowTitle
	
	voiceMacro.startup(false)
	
	curDetectHiddenWindows := A_DetectHiddenWindows
		
	DetectHiddenWindows On
	
	try {
		IfWinNotActive %windowTitle%, , WinActivate, %windowTitle% 
			
		WinWait %windowTitle%, 
		WinMove %windowTitle%, , 50, 50

		MouseClick, left,  465,  45
		Sleep, 100
		MouseClick, left,  465,  45
		Sleep, 100
		MouseClick, left,  524,  13
		Sleep, 100
	}
	finally {
		DetectHiddenWindows % curDetectHiddenWindows
	}
}