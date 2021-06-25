;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Engineer Plugin            ;;;
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

global kRaceEngineerPlugin = "Race Engineer"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceEngineerPlugin extends ControllerPlugin  {
	iRaceEngineerEnabled := false
	iRaceEngineerName := false
	iRaceEngineerLogo := false
	iRaceEngineerLanguage := false
	iRaceEngineerSpeaker := false
	iRaceEngineerListener := false
	
	iRaceEngineer := false
	iPitstopPending := false
	
	iSimulator := false
	
	class RemoteRaceEngineer {
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
			raiseEvent(kFileMessage, "Engineer", function . ":" . values2String(";", arguments*), this.RemotePID)
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
		
		accept(arguments*) {
			this.callRemote("accept", arguments*)
		}
		
		reject(arguments*) {
			this.callRemote("reject", arguments*)
		}
		
		planPitstop(arguments*) {
			this.callRemote("planPitstop", arguments*)
		}
		
		preparePitstop(arguments*) {
			this.callRemote("preparePitstop", arguments*)
		}
		
		performPitstop(arguments*) {
			this.callRemote("performPitstop", arguments*)
		}
	}

	class RaceEngineerAction extends ControllerAction {
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
			local plugin := this.Controller.findPlugin(kRaceEngineerPlugin)
			
			if plugin.RaceEngineer
				switch this.Action {
					case "PitstopPlan":
						plugin.planPitstop()
					case "PitstopPrepare":
						plugin.preparePitstop()
					case "Accept":
						plugin.accept()
					case "Reject":
						plugin.reject()
					default:
						Throw "Invalid action """ . this.Action . """ detected in RaceEngineerAction.fireAction...."
				}
		}
	}

	class RaceSettingsAction extends RaceEngineerPlugin.RaceEngineerAction {
		fireAction(function, trigger) {
			if (this.Action = "RaceEngineerOpenSettings")
				openRaceSettings()
			else if (this.Action = "RaceEngineerImportSettings")
				openRaceSettings(true)
			else if (this.Action = "RaceEngineerOpenSetups")
				openSetupDatabase()
		}
	}
	
	class RaceEngineerToggleAction extends ControllerAction {
		fireAction(function, trigger) {
			local plugin := this.Controller.findPlugin(kRaceEngineerPlugin)
			
			if plugin.RaceEngineerName
				if (plugin.RaceEngineerEnabled && ((trigger = "Off") || (trigger == "Push"))) {
					plugin.disableRaceEngineer()
				
					trayMessage(plugin.actionLabel(this), translate("State: Off"))
				
					function.setText(plugin.actionLabel(this), "Black")
				}
				else if (!plugin.RaceEngineerEnabled && ((trigger = "On") || (trigger == "Push"))) {
					plugin.enableRaceEngineer()
				
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
	
	RaceEngineer[] {
		Get {
			return this.iRaceEngineer
		}
	}
	
	RaceEngineerEnabled[] {
		Get {
			return this.iRaceEngineerEnabled
		}
	}
	
	RaceEngineerName[] {
		Get {
			return this.iRaceEngineerName
		}
	}
	
	RaceEngineerLogo[] {
		Get {
			return this.iRaceEngineerLogo
		}
	}
	
	RaceEngineerLanguage[] {
		Get {
			return this.iRaceEngineerLanguage
		}
	}
	
	RaceEngineerSpeaker[] {
		Get {
			return this.iRaceEngineerSpeaker
		}
	}
	
	RaceEngineerListener[] {
		Get {
			return this.iRaceEngineerListener
		}
	}
	
	PitstopPending[] {
		Get {
			return this.iPitstopPending
		}
	}
	
	__New(controller, name, configuration := false) {
		base.__New(controller, name, configuration)
		
		this.iRaceEngineerName := this.getArgumentValue("raceEngineerName", false)
		this.iRaceEngineerLogo := this.getArgumentValue("raceEngineerLogo", false)
		this.iRaceEngineerLanguage := this.getArgumentValue("raceEngineerLanguage", false)
		
		raceEngineerToggle := this.getArgumentValue("raceEngineer", false)
		
		if raceEngineerToggle {
			arguments := string2Values(A_Space, raceEngineerToggle)
			
			this.iRaceEngineerEnabled := (arguments[1] = "On")
			
			this.createRaceEngineerAction(controller, "RaceEngineer", arguments[2])
		}
		else
			this.iRaceEngineerEnabled := (this.iRaceEngineerName != false)
		
		raceEngineerOpenSettings := this.getArgumentValue("raceEngineerOpenSettings", false)
		
		if raceEngineerOpenSettings
			this.createRaceEngineerAction(controller, "RaceEngineerOpenSettings", raceEngineerOpenSettings)
		
		raceEngineerImportSettings := this.getArgumentValue("raceEngineerImportSettings", false)
		
		if raceEngineerImportSettings
			this.createRaceEngineerAction(controller, "RaceEngineerImportSettings", raceEngineerImportSettings)
		
		raceEngineerOpenSetups := this.getArgumentValue("raceEngineerOpenSetups", false)
		
		if raceEngineerOpenSetups
			this.createRaceEngineerAction(controller, "RaceEngineerOpenSetups", raceEngineerOpenSetups)
		
		for ignore, theAction in string2Values(",", this.getArgumentValue("raceEngineerCommands", ""))
			this.createRaceEngineerAction(controller, string2Values(A_Space, theAction)*)
		
		engineerSpeaker := this.getArgumentValue("raceEngineerSpeaker", false)
		
		if ((engineerSpeaker != false) && (engineerSpeaker != kFalse)) {
			this.iRaceEngineerSpeaker := ((engineerSpeaker = kTrue) ? true : engineerSpeaker)
		
			engineerListener := this.getArgumentValue("raceEngineerListener", false)
			
			if ((engineerListener != false) && (engineerListener != kFalse))
				this.iRaceEngineerListener := ((engineerListener = kTrue) ? true : engineerListener)
		}
		
		controller.registerPlugin(this)
	
		if (this.RaceEngineerName)
			SetTimer collectRaceEngineerSessionData, 10000
		else
			SetTimer updateRaceEngineerSessionState, 5000
	}
	
	createRaceEngineerAction(controller, action, actionFunction) {
		local function := controller.findFunction(actionFunction)
		
		if (function != false) {
			if inList(["PitstopPlan", "PitstopPrepare", "Accept", "Reject"], action)
				this.registerAction(new this.RaceEngineerAction(function, this.getLabel(ConfigurationItem.descriptor(action, "Activate"), action), action))
			else if (action = "RaceEngineer")
				this.registerAction(new this.RaceEngineerToggleAction(function, this.getLabel(ConfigurationItem.descriptor(action, "Toggle"), action)))
			else if ((action = "RaceEngineerOpenSettings") || (action = "RaceEngineerImportSettings") || (action = "RaceEngineerOpenSetups"))
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
			if isInstance(theAction, RaceEngineerPlugin.RaceEngineerToggleAction) {
				theAction.Function.setText(this.actionLabel(theAction), this.RaceEngineerName ? (this.RaceEngineerEnabled ? "Green" : "Black") : "Gray")
				
				if !this.RaceEngineerName
					theAction.Function.disable()
			}
			else if isInstance(theAction, RaceEngineerPlugin.RaceEngineerAction)
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
				else if ((sessionState == kSessionRace) && (this.RaceEngineer != false)) {
					theAction.Function.enable(kAllTrigger, theAction)
					theAction.Function.setText(theAction.Label)
				}
				else {
					theAction.Function.disable(kAllTrigger, theAction)
					theAction.Function.setText(theAction.Label, "Gray")
				}
	}
	
	enableRaceEngineer() {
		this.iRaceEngineerEnabled := this.iRaceEngineerName
	}
	
	disableRaceEngineer() {
		this.iRaceEngineerEnabled := false
		
		if this.RaceEngineer
			this.finishSession()
	}
	
	startupRaceEngineer() {
		if (this.RaceEngineerEnabled) {
			Process Exist
			
			controllerPID := ErrorLevel
			raceEngineerPID := 0
								
			try {
				logMessage(kLogInfo, translate("Starting ") . translate("Race Engineer"))
				
				options := " -Settings """ . kTempDirectory . "Race Engineer.settings" . """"
				
				if this.Simulator.supportsPitstop()
					options .= " -Remote " . controllerPID
				
				if this.RaceEngineerName
					options .= " -Name """ . this.RaceEngineerName . """"
				
				if this.RaceEngineerLogo
					options .= " -Logo """ . this.RaceEngineerLogo . """"
				
				if this.RaceEngineerLanguage
					options .= " -Language """ . this.RaceEngineerLanguage . """"
				
				if this.RaceEngineerSpeaker
					options .= " -Speaker """ . this.RaceEngineerSpeaker . """"
				
				if this.RaceEngineerListener
					options .= " -Listener """ . this.RaceEngineerListener . """"
				
				if this.Controller.VoiceServer
					options .= " -Voice """ . this.Controller.VoiceServer . """"
				
				exePath := kBinariesDirectory . "Race Engineer.exe" . options 
				
				Run %exePath%, %kBinariesDirectory%, , raceEngineerPID
				
				Sleep 5000
			}
			catch exception {
				logMessage(kLogCritical, translate("Cannot start Race Engineer (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))
			
				showMessage(substituteVariables(translate("Cannot start Race Engineer (%kBinariesDirectory%Race Engineer.exe) - please rebuild the applications..."))
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				
				return false
			}
			
			this.iRaceEngineer := new this.RemoteRaceEngineer(raceEngineerPID)
		}
	}
	
	shutdownRaceEngineer() {
		local raceEngineer := this.RaceEngineer
		
		this.iRaceEngineer := false
		
		if raceEngineer
			raceEngineer.shutdown()
	}
	
	reloadSettings(pid, settingsFileName) {
		Process Exist, %pid%
		
		if ErrorLevel {
			callback := ObjBindMethod(this, "reloadSettings", pid, settingsFileName)
		
			SetTimer %callback%, -1000
		}
		else if this.RaceEngineer
			this.RaceEngineer.updateSession(settingsFileName)
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
		
		loadSettings := getConfigurationValue(this.Configuration, "Race Assistant Startup", simulatorName . ".LoadSettings", getConfigurationValue(this.Configuration, "Race Engineer Startup", simulatorName . ".LoadSettings", "Default"))
		
		if (loadSettings = "SetupDatabase")
			settings := setupDB.getSettings(simulatorName, car, track, {Weather: weather, Duration: (Round((duration / 60) / 5) * 300), Compound: compound, CompoundColor: compoundColor})
		else
			settings := readConfiguration(getFileName("Race.settings", kUserConfigDirectory))
		
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
			
			writeConfiguration(kTempDirectory . "Race Engineer.settings", settings)
		}
		else if (tpSetting = "Import") {
			writeConfiguration(kTempDirectory . "Race Engineer.settings", settings)
			
			openRaceSettings(true, true, false, kTempDirectory . "Race Engineer.settings")
		}
		else
			writeConfiguration(kTempDirectory . "Race Engineer.settings", settings)
	}
	
	startSession(dataFile) {
		if this.Simulator {
			code := this.Simulator.Code
		
			FileCreateDir %kTempDirectory%%code% Data
			
			Loop Files, %kTempDirectory%%code% Data\%kRaceEngineerPlugin%*.*
				if (A_LoopFilePath != dataFile)
					FileDelete %A_LoopFilePath%
		}
		
		if this.RaceEngineer
			this.finishSession(false)
		else
			this.startupRaceEngineer()
	
		if this.RaceEngineer
			this.RaceEngineer.startSession(dataFile)
	}
	
	finishSession(shutdown := true) {
		if this.RaceEngineer {
			this.RaceEngineer.finishSession()
			
			if shutdown
				this.shutdownRaceEngineer()
			
			this.iPitstopPending := false
		}
	}
	
	addLap(lapNumber, dataFile) {
		if this.RaceEngineer
			this.RaceEngineer.addLap(lapNumber, dataFile)
	}
	
	updateLap(lapNumber, dataFile) {
		if this.RaceEngineer
			this.RaceEngineer.updateLap(lapNumber, dataFile)
	}
	
	supportsPitstop() {
		return (this.Simulator ? this.Simulator.supportsPitstop() : false)
	}
	
	accept() {
		if this.RaceEngineer
			this.RaceEngineer.accept()
	}
	
	reject() {
		if this.RaceEngineer
			this.RaceEngineer.reject()
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
		if this.RaceEngineer {
			this.RaceEngineer.performPitstop(lapNumber)
		
			this.iPitstopPending := false
					
			SetTimer collectRaceEngineerSessionData, 10000
		}
	}
	
	pitstopPlanned(pitstopNumber) {
		this.Simulator.pitstopPlanned(pitstopNumber)
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
	
	startSimulation(simulator) {
		if (this.Simulator && (this.Simulator != simulator))
			this.stopSimulation(this.Simulator)
		
		this.iSimulator := simulator
	}
	
	stopSimulation(simulator) {
		if (this.Simulator == simulator)
			this.iSimulator := false
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
	
	collectSessionData() {
		static lastLap := 0
		static lastLapCounter := 0
		static inPit := false
		
		if this.Simulator {
			code := this.Simulator.Code
			
			data := readSimulatorData(code)
			
			this.updateSimulatorData(data)
			
			dataLastLap := getConfigurationValue(data, "Stint Data", "Laps", 0)
			
			if isDebug() {
				testData := getConfigurationSectionValues(data, "Test Data", Object())
				
				if (testData.Count() > 0) {
					message := "Raw Data`n`n"
					
					for key, value in testData
						message := message . key . " = " . value . "`n"

					showMessage(message, translate("Modular Simulator Controller System"), "Information.png", 5000, "Left", "Bottom", 400, 400)
				}
			}
			
			protectionOn()
			
			try {
				sessionState := this.getSessionState(data)
				
				this.updateSessionState(sessionState)
				
				if (sessionState == kSessionPaused)
					return
				else if (sessionState < kSessionPractice) {
					; Not on track
				
					lastLap := 0
					inPit := false
			
					if this.RaceEngineer
						this.finishSession()
					
					return
				}
				
				if ((dataLastLap <= 1) && (dataLastLap < lastLap)) {
					; Start of new session without finishing previous session first
				
					lastLap := 0
					inPit := false
			
					if this.RaceEngineer
						this.finishSession()
				}
				
				if this.RaceEngineerEnabled {
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
						
						newDataFile := kTempDirectory . code . " Data\" . kRaceEngineerPlugin . " Lap " . lastLap . "." . ++lastLapCounter . ".data"
							
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
			if this.RaceEngineer
				Loop 10 {
					if this.Simulator
						return
					
					Sleep 500
				}
			
			lastLap := 0
			inPit := false
		
			if this.RaceEngineer
				this.finishSession()
			
			this.updateSessionState(kSessionFinished)
		}
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

openRaceSettings(import := false, silent := false, plugin := false, fileName := false) {
	exePath := kBinariesDirectory . "Race Settings.exe"
	
	if !fileName
		fileName := kUserConfigDirectory . "Race.settings"
	
	try {
		controller := SimulatorController.Instance
		
		if !plugin
			plugin := controller.findPlugin(kRaceEngineerPlugin)
		
		if import {
			options := "-File """ . fileName . """ -Import"
			
			if (plugin && plugin.Simulator)
				options := (options . " """ . controller.ActiveSimulator . """ " . plugin.Simulator.Code)
			
			if silent
				options .= " -Silent"
			
			Run "%exePath%" %options%, %kBinariesDirectory%, , pid
		}
		else {
			options := "-File """ . fileName . """ " . getSimulatorOptions(plugin)
			
			Run "%exePath%" %options%, %kBinariesDirectory%, , pid
		}
		
		if pid {
			callback := ObjBindMethod(plugin, "reloadSettings", pid, fileName)
			
			SetTimer %callback%, -1000
		}
	}
	catch exception {
		logMessage(kLogCritical, translate("Cannot start the Race Settings tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))
			
		showMessage(substituteVariables(translate("Cannot start the Race Settings tool (%exePath%) - please check the configuration..."), {exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

openSetupDatabase(plugin := false) {
	exePath := kBinariesDirectory . "Setup Database.exe"
	
	if !plugin
		plugin := SimulatorController.Instance.findPlugin(kRaceEngineerPlugin)
	
	try {
		options := getSimulatorOptions(plugin)
		
		Run "%exePath%" %options%, %kBinariesDirectory%, , pid
	}
	catch exception {
		logMessage(kLogCritical, translate("Cannot start the Setup Database tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))
			
		showMessage(substituteVariables(translate("Cannot start the Setup Database tool (%exePath%) - please check the configuration..."), {exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

readSimulatorData(simulator, options := "", protocol := "SHM") {
	exePath := kBinariesDirectory . simulator . " " . protocol . " Reader.exe"
	
	Random prefix, 1, 1000000
	
	FileCreateDir %kTempDirectory%%simulator% Data
	
	dataFile := kTempDirectory . simulator . " Data\" . protocol . "_" . Round(prefix) . ".data"
	
	try {
		RunWait %ComSpec% /c ""%exePath%" %options% > "%dataFile%"", , Hide
	}
	catch exception {
		logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Reader ("), {simulator: simulator, protocol: protocol})
												   . exePath . translate(") - please rebuild the applications in the binaries folder (")
												   . kBinariesDirectory . translate(")"))
			
		showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Reader (%exePath%) - please check the configuration...")
									  , {exePath: exePath, simulator: simulator, protocol: protocol})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
	
	data := readConfiguration(dataFile)
	
	try {
		FileDelete %dataFile%
	}
	catch exception {
		; ignore
	}
	
	setConfigurationValue(data, "Session Data", "Simulator", simulator)
	
	return data
}

getDataSessionState(data) {
	if getConfigurationValue(data, "Session Data", "Active", false) {
		if getConfigurationValue(data, "Session Data", "Paused", false)
			return kSessionPaused
		else
			switch getConfigurationValue(data, "Session Data", "Session", "Other") {
				case "Race":
					return kSessionRace
				case "Practice":
					return kSessionPractice
				case "Qualification":
					return kSessionQualification
				default:
					return kSessionOther
			}
	}
	else
		return kSessionFinished
}

getSimulatorOptions(plugin := false) {
	if !plugin
		plugin := SimulatorController.Instance.findPlugin(kRaceEngineerPlugin)
	
	options := ""
	
	if plugin.Simulator {
		data := readSimulatorData(plugin.Simulator.Code)
		
		if getConfigurationValue(data, "Session Data", "Active", false) {
			options := "-Simulator """ . plugin.Simulator.runningSimulator() . """"
			options .= " -Car """ . getConfigurationValue(data, "Session Data", "Car", "Unknown") . """"
			options .= " -Track """ . getConfigurationValue(data, "Session Data", "Track", "Unknown") . """"
			options .= " -Weather " . getConfigurationValue(data, "Weather Data", "Weather", "Dry")
			options .= " -AirTemperature " . getConfigurationValue(data, "Weather Data", "Temperature", "23")
			options .= " -TrackTemperature " . getConfigurationValue(data, "Track Data", "Temperature", "27")
			options .= " -Compound " . getConfigurationValue(data, "Car Data", "TyreCompound", "Dry")
		}
	}
	
	return options
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
	
	registerEventHandler("Pitstop", "handlePitstopRemoteCalls")
}


;;;-------------------------------------------------------------------------;;;
;;;                          Event Handler Section                          ;;;
;;;-------------------------------------------------------------------------;;;

handlePitstopRemoteCalls(event, data) {
	if InStr(data, ":") {
		data := StrSplit(data, ":", , 2)
		
		return withProtection(ObjBindMethod(SimulatorController.Instance.findPlugin(kRaceEngineerPlugin), data[1]), string2Values(";", data[2])*)
	}
	else
		return withProtection(ObjBindMethod(SimulatorController.Instance.findPlugin(kRaceEngineerPlugin), data))
}

;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceEngineerPlugin()