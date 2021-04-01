;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - R3E Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kR3EApplication = "RaceRoom Racing Experience"

global kR3EPlugin = "R3E"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class R3EPlugin extends ControllerPlugin {
	iR3EApplication := false
	
	iRaceEngineer := false
	
	iSessionState := kSessionFinished
	
	Code[] {
		Get {
			return "R3E"
		}
	}
	
	R3EApplication[] {
		Get {
			return this.iR3EApplication
		}
	}
	
	RaceEngineer[] {
		Get {
			return this.iRaceEngineer
		}
	}
	
	SessionState[] {
		Get {
			return this.iSessionState
		}
	}
	
	__New(controller, name, configuration := false) {
		this.iR3EApplication := new Application(kR3EApplication, SimulatorController.Instance.Configuration)
		
		base.__New(controller, name, configuration)
	}
	
	runningSimulator() {
		return (this.R3EApplication.isRunning() ? kR3EApplication : false)
	}
	
	simulatorStartup(simulator) {
		base.simulatorStartup(simulator)
		
		if (simulator = kR3EApplication) {
			raceEngineer := SimulatorController.Instance.findPlugin(kRaceEngineerPlugin)
			
			if (raceEngineer && raceEngineer.isActive())
				raceEngineer.startSimulation(this)
		}
	}
	
	simulatorShutdown(simulator) {
		base.simulatorShutdown(simulator)
		
		if (simulator = kR3EApplication) {
			raceEngineer := SimulatorController.Instance.findPlugin(kRaceEngineerPlugin)
			
			if (raceEngineer && raceEngineer.isActive())
				raceEngineer.stopSimulation(this)
		
			this.updateSessionState(kSessionFinished)
		}
	}
	
	updateSessionState(sessionState) {
		this.iSessionState := sessionState
	}
	
	planPitstop() {
		if this.RaceEngineer
			this.RaceEngineer.planPitstop()
	}
	
	preparePitstop(lap := false) {
		if this.RaceEngineer
			this.RaceEngineer.preparePitstop(lap)
	}
	
	pitstopPlanned(pitstopNumber) {
	}
	
	pitstopPrepared(pitstopNumber) {
	}
	
	pitstopFinished(pitstopNumber) {
	}
	
	startPitstopSetup(pitstopNumber) {
	}

	finishPitstopSetup(pitstopNumber) {
	}

	setPitstopRefuelAmount(pitstopNumber, litres) {
	}
	
	setPitstopTyreSet(pitstopNumber, compound, set := false) {
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork) {
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startR3E() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kR3EPlugin).R3EApplication
											         , "Simulator Splash Images\R3E Splash.jpg")
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeR3EPlugin() {
	local controller := SimulatorController.Instance
	
	new R3EPlugin(controller, kR3EPlugin, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeR3EPlugin()
