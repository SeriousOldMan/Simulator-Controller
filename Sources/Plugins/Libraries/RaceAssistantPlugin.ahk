;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Assistant Plugin           ;;;
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
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceAssistantPlugin extends ControllerPlugin  {
	iRaceAssistantEnabled := false
	iRaceAssistantName := false
	iRaceAssistantLogo := false
	iRaceAssistantLanguage := false
	iRaceAssistantService := false
	iRaceAssistantSpeaker := false
	iRaceAssistantListener := false
	
	iRaceAssistant := false
	
	iSimulator := false
	
	iLastLap := 0
	iLastLapCounter := 0
	iInPit := false
	iFinished := false
	
	class RemoteRaceAssistant {
		iRemoteEvent := false
		iRemotePID := false
		
		RemotePID[] {
			Get {
				return this.iRemotePID
			}
		}
		
		__New(remoteEvent, remotePID) {
			this.iRemoteEvent := remoteEvent
			this.iRemotePID := remotePID
		}
		
		callRemote(function, arguments*) {
			raiseEvent(kFileMessage, this.iRemoteEvent, function . ":" . values2String(";", arguments*), this.RemotePID)
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
		
		requestInformation(arguments*) {
			this.callRemote("requestInformation", arguments*)
		}
		
		performPitstop(arguments*) {
			this.callRemote("performPitstop", arguments*)
		}
	}

	class RaceAssistantAction extends ControllerAction {
		iPlugin := false
	
		iAction := false
		iArguments := false
		
		Plugin[] {
			Get {
				return this.iPlugin
			}
		}
		
		Action[] {
			Get {
				return this.iAction
			}
		}
		
		Arguments[] {
			Get {
				return this.iArguments
			}
		}
		
		__New(plugin, function, label, action, arguments*) {
			this.iPlugin := plugin
			this.iAction := action
			this.iArguments := arguments
			
			base.__New(function, label)
		}
		
		fireAction(function, trigger) {
			if this.Plugin.RaceAssistant
				switch this.Action {
					case "InformationRequest":
						this.Plugin.requestInformation(this.Arguments*)
					case "Accept":
						this.Plugin.accept()
					case "Reject":
						this.Plugin.reject()
					default:
						Throw "Invalid action """ . this.Action . """ detected in RaceAssistantAction.fireAction...."
				}
		}
	}

	class RaceSettingsAction extends ControllerAction {
		iPlugin := false
	
		iAction := false
		
		Plugin[] {
			Get {
				return this.iPlugin
			}
		}
		
		Action[] {
			Get {
				return this.iAction
			}
		}
		
		__New(plugin, function, label, action) {
			this.iPlugin := plugin
			this.iAction := action
			
			base.__New(function, label)
		}
		
		fireAction(function, trigger) {
			if (this.Action = "RaceSettingsOpen")
				openRaceSettings(false, false, this.Plugin)
			else if (this.Action = "SetupImport")
				openRaceSettings(true, false, this.Plugin)
			else if (this.Action = "SetupDatabaseOpen")
				openSetupDatabase(this.Plugin)
		}
	}
	
	class RaceAssistantToggleAction extends ControllerAction {
		iPlugin := false
		
		Plugin[] {
			Get {
				return this.iPlugin
			}
		}
		
		__New(plugin, function, label) {
			this.iPlugin := plugin
			
			base.__New(function, label)
		}
		
		fireAction(function, trigger) {
			local plugin := this.Plugin
			
			if plugin.RaceAssistantName
				if (plugin.RaceAssistantEnabled && ((trigger = "Off") || (trigger == "Push"))) {
					plugin.disableRaceAssistant()
				
					trayMessage(plugin.actionLabel(this), translate("State: Off"))
				
					function.setText(plugin.actionLabel(this), "Black")
				}
				else if (!plugin.RaceAssistantEnabled && ((trigger = "On") || (trigger == "Push"))) {
					plugin.enableRaceAssistant()
				
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
	
	RaceAssistant[] {
		Get {
			return this.iRaceAssistant
		}
	}
	
	RaceAssistantEnabled[] {
		Get {
			return this.iRaceAssistantEnabled
		}
	}
	
	RaceAssistantName[] {
		Get {
			return this.iRaceAssistantName
		}
	}
	
	RaceAssistantLogo[] {
		Get {
			return this.iRaceAssistantLogo
		}
	}
	
	RaceAssistantLanguage[] {
		Get {
			return this.iRaceAssistantLanguage
		}
	}
	
	RaceAssistantService[] {
		Get {
			return this.iRaceAssistantService
		}
	}
	
	RaceAssistantSpeaker[] {
		Get {
			return this.iRaceAssistantSpeaker
		}
	}
	
	RaceAssistantListener[] {
		Get {
			return this.iRaceAssistantListener
		}
	}
	
	__New(controller, name, configuration := false) {
		base.__New(controller, name, configuration)
		
		this.iRaceAssistantName := this.getArgumentValue("raceAssistantName", false)
		this.iRaceAssistantLogo := this.getArgumentValue("raceAssistantLogo", false)
		this.iRaceAssistantLanguage := this.getArgumentValue("raceAssistantLanguage", false)
		
		raceAssistantToggle := this.getArgumentValue("raceAssistant", false)
		
		if raceAssistantToggle {
			arguments := string2Values(A_Space, raceAssistantToggle)
			
			this.iRaceAssistantEnabled := (arguments[1] = "On")
			
			this.createRaceAssistantAction(controller, "RaceAssistant", arguments[2])
		}
		else
			this.iRaceAssistantEnabled := (this.iRaceAssistantName != false)
		
		openRaceSettings := this.getArgumentValue("openRaceSettings", false)
		
		if openRaceSettings
			this.createRaceAssistantAction(controller, "RaceSettingsOpen", openRaceSettings)
		
		importSetup := this.getArgumentValue("importSetup", false)
		
		if importSetup
			this.createRaceAssistantAction(controller, "SetupImport", importSetup)
		
		openSetupDatabase := this.getArgumentValue("openSetupDatabase", false)
		
		if openSetupDatabase
			this.createRaceAssistantAction(controller, "SetupDatabaseOpen", openSetupDatabase)
		
		for ignore, theAction in string2Values(",", this.getArgumentValue("assistantCommands", ""))
			this.createRaceAssistantAction(controller, string2Values(A_Space, theAction)*)
		
		this.iRaceAssistantService := this.getArgumentValue("raceAssistantService", "Windows")
		
		assistantSpeaker := this.getArgumentValue("raceAssistantSpeaker", false)
		
		if ((assistantSpeaker != false) && (assistantSpeaker != kFalse)) {
			this.iRaceAssistantSpeaker := ((assistantSpeaker = kTrue) ? true : assistantSpeaker)
		
			assistantListener := this.getArgumentValue("raceAssistantListener", false)
			
			if ((assistantListener != false) && (assistantListener != kFalse))
				this.iRaceAssistantListener := ((assistantListener = kTrue) ? true : assistantListener)
		}
		
		controller.registerPlugin(this)
	}
	
	createRaceAssistantAction(controller, action, actionFunction, arguments*) {
		local function
		
		if (action = "InformationRequest") {
			arguments.InsertAt(1, actionFunction)
			
			actionFunction := arguments.Pop()
		}
		
		function := controller.findFunction(actionFunction)
		
		if (function != false) {
			if (action = "InformationRequest") {
				action := values2String("", arguments*)
				
				this.registerAction(new this.RaceAssistantAction(this, function, this.getLabel(ConfigurationItem.descriptor(action, "Activate"), action), "InformationRequest", arguments*))
			}
			else if inList(["Accept", "Reject"], action)
				this.registerAction(new this.RaceAssistantAction(this, function, this.getLabel(ConfigurationItem.descriptor(action, "Activate"), action), action))
			else if (action = "RaceAssistant")
				this.registerAction(new this.RaceAssistantToggleAction(this, function, this.getLabel(ConfigurationItem.descriptor(action, "Toggle"), action)))
			else if ((action = "RaceSettingsOpen") || (action = "SetupImport") || (action = "SetupDatabaseOpen"))
				this.registerAction(new this.RaceSettingsAction(this, function, this.getLabel(ConfigurationItem.descriptor(action, "Activate")), action))
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
			if isInstance(theAction, RaceAssistantPlugin.RaceAssistantToggleAction) {
				theAction.Function.setText(this.actionLabel(theAction), this.RaceAssistantName ? (this.RaceAssistantEnabled ? "Green" : "Black") : "Gray")
				
				if !this.RaceAssistantName
					theAction.Function.disable(kAllTrigger, theAction)
			}
			else if isInstance(theAction, RaceAssistantPlugin.RaceSettingsAction) {
				if ((theAction.Action = "RaceSettingsOpen") || (theAction.Action = "SetupDatabaseOpen")) {
					theAction.Function.enable(kAllTrigger, theAction)
					theAction.Function.setText(theAction.Label)
				}
				else if (theAction.Action = "SetupImport") {
					if this.supportsSetupImport() {
						theAction.Function.enable(kAllTrigger, theAction)
						theAction.Function.setText(theAction.Label)
					}
					else {
						theAction.Function.disable(kAllTrigger, theAction)
						theAction.Function.setText(theAction.Label, "Gray")
					}
				}
			}
			else if isInstance(theAction, RaceAssistantPlugin.RaceAssistantAction)
				if (((sessionState == kSessionRace) || (theAction.Action = "InformationRequest")) && (this.RaceAssistant != false)) {
					theAction.Function.enable(kAllTrigger, theAction)
					theAction.Function.setText(theAction.Label)
				}
				else {
					theAction.Function.disable(kAllTrigger, theAction)
					theAction.Function.setText(theAction.Label, "Gray")
				}
	}
	
	enableRaceAssistant() {
		this.iRaceAssistantEnabled := this.iRaceAssistantName
	}
	
	disableRaceAssistant() {
		this.iRaceAssistantEnabled := false
		
		if this.RaceAssistant
			this.finishSession()
	}
	
	createRaceAssistant(pid) {
		return new this.RemoteRaceAssistant(pid)
	}
	
	startupRaceAssistant() {
		if (this.RaceAssistantEnabled) {
			Process Exist
			
			controllerPID := ErrorLevel
			raceAssistantPID := 0
								
			try {
				logMessage(kLogInfo, translate("Starting ") . translate(this.Plugin))
				
				options := " -Settings """ . kTempDirectory . this.Plugin . ".settings" . """"
				
				options .= " -Remote " . controllerPID
				
				if this.RaceAssistantName
					options .= " -Name """ . this.RaceAssistantName . """"
				
				if this.RaceAssistantLogo
					options .= " -Logo """ . this.RaceAssistantLogo . """"
				
				if this.RaceAssistantLanguage
					options .= " -Language """ . this.RaceAssistantLanguage . """"
				
				if this.RaceAssistantService
					options .= " -Service """ . this.RaceAssistantService . """"
				
				if this.RaceAssistantSpeaker
					options .= " -Speaker """ . this.RaceAssistantSpeaker . """"
				
				if this.RaceAssistantListener
					options .= " -Listener """ . this.RaceAssistantListener . """"
				
				if this.Controller.VoiceServer
					options .= " -Voice """ . this.Controller.VoiceServer . """"
				
				exePath := """" . kBinariesDirectory . this.Plugin . ".exe""" . options
				
				Run %exePath%, %kBinariesDirectory%, , raceAssistantPID
			}
			catch exception {
				logMessage(kLogCritical, translate("Cannot start " . this.Plugin . " (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))
			
				showMessage(substituteVariables(translate("Cannot start " . this.Plugin . " (%kBinariesDirectory%Race Assistant.exe) - please rebuild the applications..."))
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				
				return false
			}
			
			this.iRaceAssistant := this.createRaceAssistant(raceAssistantPID)
		}
	}
	
	shutdownRaceAssistant() {
		local raceAssistant := this.RaceAssistant
		
		this.iRaceAssistant := false
		
		if raceAssistant
			raceAssistant.shutdown()
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
	
		loadSettings := getConfigurationValue(this.Configuration, "Race Assistant Startup", simulatorName . ".LoadSettings", getConfigurationValue(this.Configuration, this.Plugin . " Startup", simulatorName . ".LoadSettings", "Default"))
		
		if (loadSettings = "SetupDatabase")
			settings := setupDB.getSettings(simulatorName, car, track, {Weather: weather, Duration: (Round((duration / 60) / 5) * 300), Compound: compound, CompoundColor: compoundColor})
		else
			settings := readConfiguration(getFileName("Race.settings", kUserConfigDirectory))
		
		writeConfiguration(kTempDirectory . this.Plugin . ".settings", settings)
		
		return settings
	}
	
	reloadSettings(pid, settingsFileName) {
		Process Exist, %pid%
		
		if ErrorLevel {
			callback := ObjBindMethod(this, "reloadSettings", pid, settingsFileName)
		
			SetTimer %callback%, -1000
		}
		else if this.RaceAssistant
			this.RaceAssistant.updateSession(settingsFileName)
	}
	
	startSession(dataFile) {
		if this.Simulator {
			code := this.Simulator.Code
			assistant := this.Plugin
		
			FileCreateDir %kTempDirectory%%code% Data
			
			Loop Files, %kTempDirectory%%code% Data\%assistant%*.*
				if (A_LoopFilePath != dataFile)
					FileDelete %A_LoopFilePath%
		}
		
		if this.RaceAssistant
			this.finishSession(false)
		else
			this.startupRaceAssistant()
	
		if this.RaceAssistant
			this.RaceAssistant.startSession(dataFile)
	}
	
	finishSession(shutdown := true) {
		if this.RaceAssistant {
			this.RaceAssistant.finishSession()
			
			if shutdown
				this.shutdownRaceAssistant()
		}
	}
	
	addLap(lapNumber, dataFile) {
		if this.RaceAssistant
			this.RaceAssistant.addLap(lapNumber, dataFile)
	}
	
	updateLap(lapNumber, dataFile) {
		if this.RaceAssistant
			this.RaceAssistant.updateLap(lapNumber, dataFile)
	}
	
	supportsSetupImport() {
		return (this.Simulator ? this.Simulator.supportsSetupImport() : false)
	}
	
	requestInformation(arguments*) {
		Throw "Virtual method RaceAssistantPlugin.requestInformation must be implemented in a subclass..."
	}
	
	performPitstop(lapNumber) {
		if this.RaceEngineer
			this.RaceEngineer.performPitstop(lapNumber)
	}
	
	accept() {
		if this.RaceAssistant
			this.RaceAssistant.accept()
	}
	
	reject() {
		if this.RaceAssistant
			this.RaceAssistant.reject()
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
	
	updateSessionData(data) {
		this.Simulator.updateSessionData(data)
	}
	
	updateStandingsData(data) {
		this.Simulator.updateStandingsData(data)
	}
	
	collectSessionData() {
		if this.Simulator {
			code := this.Simulator.Code
			
			data := readSimulatorData(code)
			
			this.updateSessionData(data)
			
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
				else if (sessionState < (isInstance(this, RaceEngineerPlugin) ? kSessionPractice : kSessionRace)) {
					; Not in a supported session
				
					this.iLastLap := 0
					this.iFinished := false
					this.iInPit := false
			
					if this.RaceAssistant
						this.finishSession()
					
					return
				}
				
				if ((dataLastLap <= 1) && (dataLastLap < this.iLastLap)) {
					; Start of new race without finishing previous race first
				
					this.iLastLap := 0
					this.iFinished := false
					this.iInPit := false
			
					if this.RaceAssistant
						this.finishSession()
				}
				
				if this.RaceAssistantEnabled {
					if getConfigurationValue(data, "Stint Data", "InPit", false) {
						; Car is in the Pit
						
						if !this.iInPit {
							this.performPitstop(dataLastLap)
						
							this.iInPit := true
						}
					}
					else if (dataLastLap == 0) {
						; Car is on the track
					
						if !this.RaceAssistant
							this.startupRaceAssistant()
					}
					else if (dataLastLap > 0) {
						; Car has finished the first lap
					
						if ((dataLastLap > 1) && (this.iLastLap == 0))
							return
						
						firstLap := (this.iLastLap == 0)
						newLap := (dataLastLap > this.iLastLap)
					
						this.iInPit := false
						
						if newLap {
							if this.iFinished {
								this.iLastLap := 0
								this.iFinished := false
								this.iInPit := false
						
								if this.RaceAssistant
									this.finishSession()
								
								return
							}
							
							this.iLastLap := dataLastLap
							this.iLastLapCounter := 0
							
							if !firstLap
								this.iFinished := (getConfigurationValue(data, "Session Data", "SessionTimeRemaining", 0) == 0)
						}
							
						if isInstance(this, RaceStrategistPlugin)
							this.updateStandingsData(data)
						
						this.iLastLapCounter := this.iLastLapCounter + 1
						
						newDataFile := kTempDirectory . code . " Data\" . this.Plugin . " Lap " . this.iLastLap . "." . this.iLastLapCounter . ".data"
							
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
					this.iLastLap := 0
					this.iFinished := false
					this.iInPit := false
				}
			}
			finally {
				protectionOff()
			}
		}
		else {
			if this.RaceAssistant
				Loop 10 {
					if this.Simulator
						return
					
					Sleep 500
				}
			
			this.iLastLap := 0
			this.iFinished := false
			this.iInPit := false
		
			if this.RaceAssistant
				this.finishSession()
			
			this.updateSessionState(kSessionFinished)
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

readSimulatorData(simulator, options := "", protocol := "SHM") {
	exePath := kBinariesDirectory . simulator . " " . protocol . " Provider.exe"
	
	Random postfix, 1, 1000000
	
	FileCreateDir %kTempDirectory%%simulator% Data
	
	dataFile := kTempDirectory . simulator . " Data\" . protocol . "_" . Round(postfix) . ".data"
	
	try {
		RunWait %ComSpec% /c ""%exePath%" %options% > "%dataFile%"", , Hide
	}
	catch exception {
		logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider ("), {simulator: simulator, protocol: protocol})
												   . exePath . translate(") - please rebuild the applications in the binaries folder (")
												   . kBinariesDirectory . translate(")"))
			
		showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration...")
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
	controller := SimulatorController.Instance
	
	if !plugin {
		plugin := controller.findPlugin(kRaceEngineerPlugin)
		
		if !plugin
			plugin := controller.findPlugin(kRaceStrategistPlugin)
	}
	
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
;;;                         Controller Action Section                       ;;;
;;;-------------------------------------------------------------------------;;;

openRaceSettings(import := false, silent := false, plugin := false, fileName := false) {
	exePath := kBinariesDirectory . "Race Settings.exe"
	controller := SimulatorController.Instance
	
	if !plugin {
		plugin := controller.findPlugin(kRaceEngineerPlugin)
		
		if !plugin
			plugin := controller.findPlugin(kRaceStrategistPlugin)
	}
	
	if !fileName
		fileName := kUserConfigDirectory . "Race.settings"
	
	try {
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
	controller := SimulatorController.Instance
	
	if !plugin {
		plugin := controller.findPlugin(kRaceEngineerPlugin)
		
		if !plugin
			plugin := controller.findPlugin(kRaceStrategistPlugin)
	}
	
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