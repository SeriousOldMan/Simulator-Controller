;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Engineer Plugin            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Plugins\Libraries\RaceAssistantPlugin.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kRaceEngineerPlugin = "Race Engineer"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceEngineerPlugin extends RaceAssistantPlugin  {
	iPitstopPending := false
	
	class RemoteRaceEngineer extends RaceAssistantPlugin.RemoteRaceAssistant {
		__New(remotePID) {
			base.__New("Race Engineer", remotePID)
		}
		
		planPitstop(arguments*) {
			this.callRemote("callPlanPitstop", arguments*)
		}
		
		preparePitstop(arguments*) {
			this.callRemote("callPreparePitstop", arguments*)
		}
		
		pitstopOptionChanged(arguments*) {
			this.callRemote("pitstopOptionChanged", arguments*)
		}
	}

	class RaceEngineerAction extends RaceAssistantPlugin.RaceAssistantAction {
		fireAction(function, trigger) {
			if (this.Plugin.RaceAssistant && (this.Action = "PitstopPlan"))
				this.Plugin.planPitstop()
			else if (this.Plugin.RaceAssistant && (this.Action = "PitstopPrepare"))
				this.Plugin.preparePitstop()
			else
				base.fireAction(function, trigger)
		}
	}
	
	RaceEngineer[] {
		Get {
			return this.RaceAssistant
		}
	}
	
	PitstopPending[] {
		Get {
			return this.iPitstopPending
		}
	}
	
	__New(controller, name, configuration := false) {
		base.__New(controller, name, configuration)

		if (!this.Active && !isDebug())
			return
		
		if (this.RaceAssistantName)
			SetTimer collectRaceEngineerSessionData, 10000
		else
			SetTimer updateRaceEngineerSessionState, 5000
	}
	
	createRaceAssistantAction(controller, action, actionFunction, arguments*) {
		local function
		
		if inList(["PitstopPlan", "PitstopPrepare"], action) {
			function := controller.findFunction(actionFunction)
			
			if (function != false) {
				descriptor := ConfigurationItem.descriptor(action, "Activate")
				
				action := new this.RaceEngineerAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor), action)
				
				this.registerAction(action)
			}
			else
				this.logFunctionNotFound(actionFunction)
		}
		else
			return base.createRaceAssistantAction(controller, action, actionFunction, arguments*)
	}
	
	createRaceAssistant(pid) {
		return new this.RemoteRaceEngineer(pid)
	}
	
	prepareSettings(data) {
		settings := base.prepareSettings(data)
		
		setupDB := new SetupDatabase()
							
		simulator := getConfigurationValue(data, "Session Data", "Simulator")
		car := getConfigurationValue(data, "Session Data", "Car")
		track := getConfigurationValue(data, "Session Data", "Track")
		
		simulatorName := setupDB.getSimulatorName(simulator)
		
		duration := Round((getConfigurationValue(data, "Stint Data", "LapLastTime") - getConfigurationValue(data, "Session Data", "SessionTimeRemaining")) / 1000)
		weather := getConfigurationValue(data, "Weather Data", "Weather", "Dry")
		compound := getConfigurationValue(data, "Car Data", "TyreCompound", "Dry")
		compoundColor := getConfigurationValue(data, "Car Data", "TyreCompoundColor", "Black")
		
		tpSetting := getConfigurationValue(this.Configuration, "Race Engineer Startup", simulatorName . ".LoadTyrePressures", "Default")
		
		if (tpSetting = "SetupDatabase") {
			trackTemperature := getConfigurationValue(data, "Track Data", "Temperature", 23)
			airTemperature := getConfigurationValue(data, "Weather Data", "Temperature", 27)
			
			compound := false
			compoundColor := false
			pressures := {}
			certainty := 1.0
			
			if setupDB.getTyreSetup(simulatorName, car, track, weather, airTemperature, trackTemperature, compound, compoundColor, pressures, certainty) {
				setConfigurationValue(settings, "Session Setup", "Tyre.Compound", compound)
				setConfigurationValue(settings, "Session Setup", "Tyre.Compound.Color", compoundColor)
				
				setConfigurationValue(settings, "Session Setup", "Tyre." . compound . ".Pressure.FL", Round(pressures[1], 1))
				setConfigurationValue(settings, "Session Setup", "Tyre." . compound . ".Pressure.FR", Round(pressures[2], 1))
				setConfigurationValue(settings, "Session Setup", "Tyre." . compound . ".Pressure.RL", Round(pressures[3], 1))
				setConfigurationValue(settings, "Session Setup", "Tyre." . compound . ".Pressure.RR", Round(pressures[4], 1))
			}
		}
		else if (tpSetting = "Import") {
			writeConfiguration(kTempDirectory . "Race Engineer.settings", settings)
			
			openRaceSettings(true, true, false, kTempDirectory . "Race Engineer.settings")
			
			settings := readConfiguration(kTempDirectory . "Race Engineer.settings")
		}
		
		return settings
	}
	
	requestInformation(arguments*) {
		if (this.RaceEngineer && inList(["LapsRemaining", "Weather", "TyrePressures", "TyreTemperatures"], arguments[1])) {
			this.RaceEngineer.requestInformation(arguments*)
		
			return true
		}
		else
			return false
	}
	
	planPitstop() {
		if this.RaceEngineer
			this.RaceEngineer.planPitstop()
	}
	
	preparePitstop(lap := false) {
		if this.RaceEngineer
			this.RaceEngineer.preparePitstop(lap)
	}
	
	performPitstop(lapNumber) {
		base.performPitstop(lapNumber)
		
		this.iPitstopPending := false
					
		SetTimer collectRaceEngineerSessionData, 10000
	}
	
	pitstopOptionChanged(option, values*) {
		if this.RaceEngineer
			this.RaceEngineer.pitstopOptionChanged(option, values*)
	}
	
	pitstopPlanned(pitstopNumber, plannedLap := false) {
		this.Simulator.pitstopPlanned(pitstopNumber, plannedLap := false)
	}
	
	pitstopPrepared(pitstopNumber) {
		this.iPitstopPending := true
		
		this.Simulator.pitstopPrepared(pitstopNumber)
		
		SetTimer collectRaceEngineerSessionData, 5000
	}
	
	pitstopFinished(pitstopNumber) {
		this.iPitstopPending := false
		
		this.Simulator.pitstopFinished(pitstopNumber)
		
		SetTimer collectRaceEngineerSessionData, 10000
	}
	
	startPitstopSetup(pitstopNumber) {
		this.Simulator.startPitstopSetup(pitstopNumber)
	}

	finishPitstopSetup(pitstopNumber) {
		this.Simulator.finishPitstopSetup(pitstopNumber)
	}

	setPitstopRefuelAmount(pitstopNumber, litres) {
		this.Simulator.setPitstopRefuelAmount(pitstopNumber, litres)
	}
	
	setPitstopTyreSet(pitstopNumber, compound, compoundColor, set := false) {
		this.Simulator.setPitstopTyreSet(pitstopNumber, compound, compoundColor, set)
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		this.Simulator.setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork) {
		this.Simulator.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Controller Action Section                       ;;;
;;;-------------------------------------------------------------------------;;;

planPitstop() {
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kRaceEngineerPlugin).planPitstop()
	}
	finally {
		protectionOff()
	}
}

preparePitstop() {
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kRaceEngineerPlugin).preparePitstop()
	}
	finally {
		protectionOff()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

updateRaceEngineerSessionState() {
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kRaceEngineerPlugin).updateSessionState()
	}
	finally {
		protectionOff()
	}
}

collectRaceEngineerSessionData() {
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kRaceEngineerPlugin).collectSessionData()
	}
	finally {
		protectionOff()
	}
}

initializeRaceEngineerPlugin() {
	local controller := SimulatorController.Instance
	
	new RaceEngineerPlugin(controller, kRaceEngineerPlugin, controller.Configuration)
}

;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceEngineerPlugin()