;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Strategist Plugin          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Plugins\Libraries\SimulatorPlugin.ahk
#Include ..\Assistants\Libraries\SetupDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kRaceStrategistPlugin = "Race Strategist"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceStrategistPlugin extends ControllerPlugin  {
	iRaceStrategistEnabled := false
	iRaceStrategistName := false
	iRaceStrategistLogo := false
	iRaceStrategistLanguage := false
	iRaceStrategistSpeaker := false
	iRaceStrategistListener := false
	
	iRaceStrategist := false
	
	iSimulator := false
	
	class RemoteRaceStrategist {
		iRemotePID := false
		
		RemotePID[] {
			Get {
				return this.iRemotePID
			}
		}
		
		__New(remotePID) {
			this.iRemotePID := remotePID
		}
		
		callRemote(function, arguments*) {
			raiseEvent(kFileMessage, "Strategist", function . ":" . values2String(";", arguments*), this.RemotePID)
		}
		
		shutdown(arguments*) {
			this.callRemote("shutdown", arguments*)
		}
		
		startSession(arguments*) {
			this.callRemote("startSession", arguments*)
		}
		
		updateSession(arguments*) {
			this.callRemote("updateSession", arguments*)
		}
		
		finishSession(arguments*) {
			this.callRemote("finishSession", arguments*)
		}
		
		addLap(arguments*) {
			this.callRemote("addLap", arguments*)
		}
		
		updateLap(arguments*) {
			this.callRemote("updateLap", arguments*)
		}
		
		performPitstop(arguments*) {
			this.callRemote("performPitstop", arguments*)
		}
	}

	class RaceSettingsAction extends ControllerAction {
		iAction := false
		
		Action[] {
			Get {
				return this.iAction
			}
		}
		
		__New(function, label, action) {
			this.iAction := action
			
			base.__New(function, label)
		}
		
		fireAction(function, trigger) {
			local plugin := this.Controller.findPlugin(kRaceStrategistPlugin)
			
			if (this.Action = "RaceStrategistOpenSettings")
				openRaceSettings(false, false, plugin)
			else if (this.Action = "RaceStrategistImportSettings")
				openRaceSettings(true, false, plugin)
			else if (this.Action = "RaceStrategistOpenSetups")
				openSetupDatabase(plugin)
		}
	}
	
	class RaceStrategistToggleAction extends ControllerAction {
		fireAction(function, trigger) {
			local plugin := this.Controller.findPlugin(kRaceStrategistPlugin)
			
			if plugin.RaceStrategistName
				if (plugin.RaceStrategistEnabled && ((trigger = "Off") || (trigger == "Push"))) {
					plugin.disableRaceStrategist()
				
					trayMessage(plugin.actionLabel(this), translate("State: Off"))
				
					function.setText(plugin.actionLabel(this), "Black")
				}
				else if (!plugin.RaceStrategistEnabled && ((trigger = "On") || (trigger == "Push"))) {
					plugin.enableRaceStrategist()
				
					trayMessage(plugin.actionLabel(this), translate("State: On"))
				
					function.setText(plugin.actionLabel(this), "Green")
				}
		}
	}
	
	Simulator[] {
		Get {
			return this.iSimulator
		}
	}
	
	RaceStrategist[] {
		Get {
			return this.iRaceStrategist
		}
	}
	
	RaceStrategistEnabled[] {
		Get {
			return this.iRaceStrategistEnabled
		}
	}
	
	RaceStrategistName[] {
		Get {
			return this.iRaceStrategistName
		}
	}
	
	RaceStrategistLogo[] {
		Get {
			return this.iRaceStrategistLogo
		}
	}
	
	RaceStrategistLanguage[] {
		Get {
			return this.iRaceStrategistLanguage
		}
	}
	
	RaceStrategistSpeaker[] {
		Get {
			return this.iRaceStrategistSpeaker
		}
	}
	
	RaceStrategistListener[] {
		Get {
			return this.iRaceStrategistListener
		}
	}
	
	__New(controller, name, configuration := false) {
		base.__New(controller, name, configuration)
		
		this.iRaceStrategistName := this.getArgumentValue("raceStrategistName", false)
		this.iRaceStrategistLogo := this.getArgumentValue("raceStrategistLogo", false)
		this.iRaceStrategistLanguage := this.getArgumentValue("raceStrategistLanguage", false)
		
		raceStrategistToggle := this.getArgumentValue("raceStrategist", false)
		
		if raceStrategistToggle {
			arguments := string2Values(A_Space, raceStrategistToggle)
			
			this.iRaceStrategistEnabled := (arguments[1] = "On")
			
			this.createRaceStrategistAction(controller, "RaceStrategist", arguments[2])
		}
		else
			this.iRaceStrategistEnabled := (this.iRaceStrategistName != false)
		
		raceStrategistOpenSettings := this.getArgumentValue("raceStrategistOpenSettings", false)
		
		if raceStrategistOpenSettings
			this.createRaceStrategistAction(controller, "RaceStrategistOpenSettings", raceStrategistOpenSettings)
		
		raceStrategistImportSettings := this.getArgumentValue("raceStrategistImportSettings", false)
		
		if raceStrategistImportSettings
			this.createRaceStrategistAction(controller, "RaceStrategistImportSettings", raceStrategistImportSettings)
		
		raceStrategistOpenSetups := this.getArgumentValue("raceStrategistOpenSetups", false)
		
		if raceStrategistOpenSetups
			this.createRaceStrategistAction(controller, "RaceStrategistOpenSetups", raceStrategistOpenSetups)
		
		strategistSpeaker := this.getArgumentValue("raceStrategistSpeaker", false)
		
		if ((strategistSpeaker != false) && (strategistSpeaker != kFalse)) {
			this.iRaceStrategistSpeaker := ((strategistSpeaker = kTrue) ? true : strategistSpeaker)
		
			strategistListener := this.getArgumentValue("raceStrategistListener", false)
			
			if ((strategistListener != false) && (strategistListener != kFalse))
				this.iRaceStrategistListener := ((strategistListener = kTrue) ? true : strategistListener)
		}
		
		controller.registerPlugin(this)
		
		if (this.RaceStrategistName)
			SetTimer collectRaceStrategistSessionData, 10000
		else
			SetTimer updateRaceStrategistSessionState, 5000
	}
	
	createRaceStrategistAction(controller, action, actionFunction) {
		local function := controller.findFunction(actionFunction)
		
		if (function != false) {
			if (action = "RaceStrategist")
				this.registerAction(new this.RaceStrategistToggleAction(function, this.getLabel(ConfigurationItem.descriptor(action, "Toggle"), action)))
			else if ((action = "RaceStrategistOpenSettings") || (action = "RaceStrategistImportSettings") || (action = "RaceStrategistOpenSetups"))
				this.registerAction(new this.RaceSettingsAction(function, this.getLabel(ConfigurationItem.descriptor(action, "Activate")), action))
			else
				logMessage(kLogWarn, translate("Action """) . action . translate(""" not found in plugin ") . translate(this.Plugin) . translate(" - please check the configuration"))
		}
		else
			this.logFunctionNotFound(actionFunction)
	}
	
	activate() {
		base.activate()
		
		this.updateActions(kSessionFinished)
	}
		
	updateActions(sessionState) {
		for ignore, theAction in this.Actions
			if isInstance(theAction, RaceStrategistPlugin.RaceStrategistToggleAction) {
				theAction.Function.setText(this.actionLabel(theAction), this.RaceStrategistName ? (this.RaceStrategistEnabled ? "Green" : "Black") : "Gray")
				
				if !this.RaceStrategistName
					theAction.Function.disable(kAllTrigger, theAction)
			}
			else if isInstance(theAction, RaceStrategistPlugin.RaceSettingsAction)
				if ((theAction.Action = "RaceEngineerOpenSettings") || (theAction.Action = "RaceEngineerOpenSetups")) {
					theAction.Function.enable(kAllTrigger, theAction)
					theAction.Function.setText(theAction.Label)
				}
				else if (theAction.Action = "RaceEngineerImportSettings") {
					if this.Simulator {
						theAction.Function.enable(kAllTrigger, theAction)
						theAction.Function.setText(theAction.Label)
					}
					else {
						theAction.Function.disable(kAllTrigger, theAction)
						theAction.Function.setText(theAction.Label, "Gray")
					}
				}
	}
	
	enableRaceStrategist() {
		this.iRaceStrategistEnabled := this.iRaceStrategistName
	}
	
	disableRaceStrategist() {
		this.iRaceStrategistEnabled := false
		
		if this.RaceStrategist
			this.finishSession()
	}
	
	startupRaceStrategist() {
		if (this.RaceStrategistEnabled) {
			Process Exist
			
			controllerPID := ErrorLevel
			raceStrategistPID := 0
								
			try {
				logMessage(kLogInfo, translate("Starting ") . translate("Race Strategist"))
				
				options := " -Settings """ . kTempDirectory . "Race Strategist.settings" . """"
				
				options .= " -Remote " . controllerPID
				
				if this.RaceStrategistName
					options .= " -Name """ . this.RaceStrategistName . """"
				
				if this.RaceStrategistLogo
					options .= " -Logo """ . this.RaceStrategistLogo . """"
				
				if this.RaceStrategistLanguage
					options .= " -Language """ . this.RaceStrategistLanguage . """"
				
				if this.RaceStrategistSpeaker
					options .= " -Speaker """ . this.RaceStrategistSpeaker . """"
				
				if this.RaceStrategistListener
					options .= " -Listener """ . this.RaceStrategistListener . """"
				
				if this.Controller.VoiceServer
					options .= " -Voice """ . this.Controller.VoiceServer . """"
				
				exePath := kBinariesDirectory . "Race Strategist.exe" . options 
				
				Run %exePath%, %kBinariesDirectory%, , raceStrategistPID
				
				Sleep 5000
			}
			catch exception {
				logMessage(kLogCritical, translate("Cannot start Race Strategist (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))
			
				showMessage(substituteVariables(translate("Cannot start Race Strategist (%kBinariesDirectory%Race Strategist.exe) - please rebuild the applications..."))
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				
				return false
			}
			
			this.iRaceStrategist := new this.RemoteRaceStrategist(raceStrategistPID)
		}
	}
	
	shutdownRaceStrategist() {
		local raceStrategist := this.RaceStrategist
		
		this.iRaceStrategist := false
		
		if raceStrategist
			raceStrategist.shutdown()
	}
	
	prepareSettings(data) {
		setupDB := new SetupDatabase()
							
		simulator := getConfigurationValue(data, "Session Data", "Simulator")
		car := getConfigurationValue(data, "Session Data", "Car")
		track := getConfigurationValue(data, "Session Data", "Track")
		
		simulatorName := setupDB.getSimulatorName(simulator)
		
		duration := Round((getConfigurationValue(data, "Stint Data", "LapLastTime") - getConfigurationValue(data, "Session Data", "SessionTimeRemaining")) / 1000)
		weather := getConfigurationValue(data, "Weather Data", "Weather", "Dry")
		compound := getConfigurationValue(data, "Car Data", "TyreCompound", "Dry")
		compoundColor := getConfigurationValue(data, "Car Data", "TyreCompoundColor", "Black")
	
		loadSettings := getConfigurationValue(this.Configuration, "Race Assistant Startup", simulatorName . ".LoadSettings", getConfigurationValue(this.Configuration, "Race Strategist Startup", simulatorName . ".LoadSettings", "Default"))
		
		if (loadSettings = "SetupDatabase")
			settings := setupDB.getSettings(simulatorName, car, track, {Weather: weather, Duration: duration, Compound: compound, CompoundColor: compoundColor})
		else
			settings := readConfiguration(getFileName("Race.settings", kUserConfigDirectory))
		
		writeConfiguration(kTempDirectory . "Race Strategist.settings", settings)
	}
	
	startSession(dataFile) {
		if this.Simulator {
			code := this.Simulator.Code
		
			FileCreateDir %kTempDirectory%%code% Data
			
			Loop Files, %kTempDirectory%%code% Data\%kRaceStrategistPlugin%*.*
				if (A_LoopFilePath != dataFile)
					FileDelete %A_LoopFilePath%
		}
		
		if this.RaceStrategist
			this.finishSession(false)
		else
			this.startupRaceStrategist()
	
		if this.RaceStrategist
			this.RaceStrategist.startSession(dataFile)
	}
	
	finishSession(shutdown := true) {
		if this.RaceStrategist {
			this.RaceStrategist.finishSession()
			
			if shutdown
				this.shutdownRaceStrategist()
		}
	}
	
	addLap(lapNumber, dataFile) {
		if this.RaceStrategist
			this.RaceStrategist.addLap(lapNumber, dataFile)
	}
	
	updateLap(lapNumber, dataFile) {
		if this.RaceStrategist
			this.RaceStrategist.updateLap(lapNumber, dataFile)
	}
	
	performPitstop(lapNumber) {
		if this.RaceStrategist
			this.RaceStrategist.performPitstop(lapNumber)
	}
	
	startSimulation(simulator) {
		if (this.Simulator && (this.Simulator != simulator))
			this.stopSimulation(this.Simulator)
		
		this.iSimulator := simulator
	}
	
	stopSimulation(simulator) {
		if (this.Simulator == simulator)
			this.iSimulator := false
	}
	
	getSessionState(data := false) {
		if this.Simulator {
			if !data
				data := readSimulatorData(this.Simulator.Code)
			
			return getDataSessionState(data)
		}
		else
			return kSessionFinished
	}

	updateSessionState(sessionState := "__Undefined__") {
		if (sessionState == kUndefined)
			sessionState := this.getSessionState()
		
		if this.Simulator
			this.Simulator.updateSessionState(sessionState)
		else
			sessionState := kSessionFinished
		
		this.updateActions(sessionState)
	}
	
	updateSimulatorData(data) {
		this.Simulator.updateSimulatorData(data)
	}
	
	updateStandingsData(data) {
		this.Simulator.updateStandingsData(data)
	}
	
	collectSessionData() {
		static lastLap := 0
		static lastLapCounter := 0
		static inPit := false
		
		if this.Simulator {
			code := this.Simulator.Code
			
			data := readSimulatorData(code)
			
			this.updateSimulatorData(data)
			
			dataLastLap := getConfigurationValue(data, "Stint Data", "Laps", 0)
			
			protectionOn()
			
			try {
				sessionState := this.getSessionState(data)
				
				this.updateSessionState(sessionState)
				
				if (sessionState == kSessionPaused)
					return
				else if (sessionState < kSessionRace) {
					; Not in a race
				
					lastLap := 0
					inPit := false
			
					if this.RaceStrategist
						this.finishSession()
					
					return
				}
				
				if ((dataLastLap <= 1) && (dataLastLap < lastLap)) {
					; Start of new race without finishing previous race first
				
					lastLap := 0
					inPit := false
			
					if this.RaceStrategist
						this.finishSession()
				}
				
				if this.RaceStrategistEnabled {
					if getConfigurationValue(data, "Stint Data", "InPit", false) {
						; Car is in the Pit
						
						if !inPit {
							this.performPitstop(dataLastLap)
						
							inPit := true
						}
					}
					else if (dataLastLap > 0) {
						; Car is on the track
					
						if ((dataLastLap > 1) && (lastLap == 0))
							return
						
						firstLap := (lastLap == 0)
						newLap := (dataLastLap > lastLap)
					
						inPit := false
						
						if newLap {
							lastLap := dataLastLap
							lastLapCounter := 0
						}
							
						this.updateStandingsData(data)
						
						newDataFile := kTempDirectory . code . " Data\" . kRaceStrategistPlugin . " Lap " . lastLap . "." . ++lastLapCounter . ".data"
							
						writeConfiguration(newDataFile, data)
						
						if firstLap {
							this.prepareSettings(data)
							
							this.startSession(newDataFile)
						}
						
						if newLap
							this.addLap(dataLastLap, newDataFile)
						else	
							this.updateLap(dataLastLap, newDataFile)
					}
				}
				else {
					lastLap := 0
					inPit := false
				}
			}
			finally {
				protectionOff()
			}
		}
		else {
			if this.RaceStrategist
				Loop 10 {
					if this.Simulator
						return
					
					Sleep 500
				}
			
			lastLap := 0
			inPit := false
		
			if this.RaceStrategist
				this.finishSession()
			
			this.updateSessionState(kSessionFinished)
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

collectRaceStrategistSessionData() {
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kRaceStrategistPlugin).collectSessionData()
	}
	finally {
		protectionOff()
	}
}

updateRaceStrategistSessionState() {
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kRaceStrategistPlugin).updateSessionState()
	}
	finally {
		protectionOff()
	}
}

initializeRaceStrategistPlugin() {
	local controller := SimulatorController.Instance
	
	new RaceStrategistPlugin(controller, kRaceStrategistPlugin, controller.Configuration)
}

;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceStrategistPlugin()