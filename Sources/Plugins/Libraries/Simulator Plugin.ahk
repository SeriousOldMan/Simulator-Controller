;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Simulator Plugin                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kSessionFinished = 0
global kSessionPaused = -1
global kSessionOther = 1
global kSessionPractice = 2
global kSessionQualification = 3
global kSessionRace = 4


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class SimulatorPlugin extends ControllerPlugin {
	iSimulator := false
	iSessionState := kSessionFinished
	
	Code[] {
		Get {
			return this.Plugin
		}
	}
	
	Simulator[] {
		Get {
			return this.iSimulator
		}
	}
	
	SessionState[] {
		Get {
			return this.iSessionState
		}
	}
	
	__New(controller, name, simulator, configuration := false) {
		this.iSimulator := new Application(simulator, SimulatorController.Instance.Configuration)
		
		base.__New(controller, name, configuration)
	}
	
	runningSimulator() {
		return (this.Simulator.isRunning() ? this.Simulator.Application : false)
	}
	
	simulatorStartup(simulator) {
		base.simulatorStartup(simulator)
		
		if (simulator = this.Simulator.Application)
			this.updateSessionState(kSessionFinished)
	}
	
	simulatorShutdown(simulator) {
		base.simulatorShutdown(simulator)
		
		if (simulator = this.Simulator.Application)
			this.updateSessionState(kSessionFinished)
	}
	
	updateSessionState(sessionState) {
		this.iSessionState := sessionState
		
		if (sessionState != kSessionPaused)
			if (sessionState == kSessionFinished)
				this.Controller.setModes()
			else
				this.Controller.setModes(this.Simulator.Application, ["Other", "Practice", "Qualification", "Race"][sessionState])
	}
}

class RaceEngineerSimulatorPlugin extends SimulatorPlugin {
	iRaceEngineer := false
	
	RaceEngineer[] {
		Get {
			return this.iRaceEngineer
		}
	}
	
	simulatorStartup(simulator) {
		base.simulatorStartup(simulator)
		
		if (simulator = this.Simulator.Application) {
			raceEngineer := SimulatorController.Instance.findPlugin(kRaceEngineerPlugin)
			
			if (raceEngineer && raceEngineer.isActive()) {
				raceEngineer.startSimulation(this)
				
				this.iRaceEngineer := raceEngineer
			}
		}
	}
	
	simulatorShutdown(simulator) {
		base.simulatorShutdown(simulator)
		
		if (simulator = this.Simulator.Application) {
			raceEngineer := SimulatorController.Instance.findPlugin(kRaceEngineerPlugin)
			
			if (raceEngineer && raceEngineer.isActive()) {
				raceEngineer.stopSimulation(this)
				
				this.iRaceEngineer := false
			}
		}
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
	
	setPitstopTyreSet(pitstopNumber, compound, compoundColor, set := false) {
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork) {
	}
	
	updateSimulatorData(data) {
	}
}
