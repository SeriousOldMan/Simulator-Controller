;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - RRE Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kRREPlugin = "RRE"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RREPlugin extends ControllerPlugin {
	iRREApplication := false
	
	RREApplication[] {
		Get {
			return this.iRREApplication
		}
	}
	
	__New(controller, name, configuration := false) {
		this.iRREApplication := new Application("RaceRoom Racing Experience", SimulatorController.Instance.Configuration)
		
		base.__New(controller, name, configuration)
	}
	
	runningSimulator() {
		return (this.RREApplication.isRunning() ? "RaceRoom Racing Experience" : false)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startRRE() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kRREPlugin).RREApplication
											         , "Simulator Splash Images\RRE Splash.jpg")
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeRREPlugin() {
	local controller := SimulatorController.Instance
	
	new RREPlugin(controller, kRREPlugin, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRREPlugin()
