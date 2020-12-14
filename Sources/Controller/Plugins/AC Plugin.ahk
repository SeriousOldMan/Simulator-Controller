;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AC Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2020) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kACPlugin = "AC"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class ACPlugin extends ControllerPlugin {
	iACApplication := false
	
	ACApplication[] {
		Get {
			return this.iACApplication
		}
	}
	
	__New(controller, name, configuration := false) {
		this.iACApplication := new Application("Assetto Corsa", SimulatorController.Instance.Configuration)
		
		base.__New(controller, name, configuration)
	}
	
	runningSimulator() {
		return this.iACApplication.isRunning() ? "Assetto Corsa" : false
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startAC() {
	acApplication := SimulatorController.Instance.findPlugin(kACPlugin).ACApplication
	
	if !acApplication.isRunning()
		if (acApplication.startup(false))
			if !kSilentMode {
				protectionOff()
	
				try {
					if !kSilentMode {
						showSplash("Simulator Splash Images\AC Splash.jpg")
	
						songFile := getConfigurationValue(SimulatorController.Instance.ControllerConfiguration, "Startup", "Song", false)
				
						if (songFile && FileExist(kSplashMediaDirectory . songFile))
							raiseEvent(false, "Startup", "playStartupSong:" . songFile)
					}
					
					posX := Round((A_ScreenWidth - 300) / 2)
					posY := A_ScreenHeight - 150
	
					Progress B w300 x%posX% y%posY% FS8 CWD0D0D0 CBGreen, Assetto Corsa, Starting Simulator

					started := false

					Loop {
						if (A_Index >= 100)
							break
					
						Progress %A_Index%

						if (!started && acApplication.isRunning())
							started := true
	
						Sleep % started ? 10 : 100
					}
				
					Progress Off
				}
				finally {
					protectionOn()
	
					if !kSilentMode
						hideSplash()
				}
			}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeACPlugin() {
	local controller := SimulatorController.Instance
	
	new ACPlugin(controller, kACPlugin, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeACPlugin()
