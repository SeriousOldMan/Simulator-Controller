;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Assistant Plugin           ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
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
	iRaceAssistantSpeakerVocalics := false
	iRaceAssistantListener := false
	
	iRaceAssistant := false
	
	iTeamServer := false
	iTeamSession := false
	iTeamSessionActive := false
	
	iSimulator := false
	
	iLastLap := 0
	iLastLapCounter := 0
	iWaitPeriod := 0
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
		
		prepareSession(arguments*) {
			this.callRemote("prepareSession", arguments*)
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
		
		call(arguments*) {
			this.callRemote("call", arguments*)
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
		
		restoreSessionState(arguments*) {
			this.callRemote("restoreSessionState", arguments*)
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
		
		__New(plugin, function, label, icon, action, arguments*) {
			this.iPlugin := plugin
			this.iAction := action
			this.iArguments := arguments
			
			base.__New(function, label, icon)
		}
		
		fireAction(function, trigger) {
			if this.Plugin.RaceAssistant
				switch this.Action {
					case "InformationRequest":
						this.Plugin.requestInformation(this.Arguments*)
					case "Call":
						this.Plugin.call()
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
		
		__New(plugin, function, label, icon, action) {
			this.iPlugin := plugin
			this.iAction := action
			
			base.__New(function, label, icon)
		}
		
		fireAction(function, trigger) {
			if (this.Action = "RaceSettingsOpen")
				openRaceSettings(false, false, this.Plugin)
			else if (this.Action = "SetupImport")
				openRaceSettings(true, false, this.Plugin)
			else if (this.Action = "RaceCenterOpen")
				openRaceCenter(this.Plugin)
			else if (this.Action = "SetupDatabaseOpen")
				openSetupDatabase(this.Plugin)
			else if (this.Action = "SetupAdvisorOpen")
				openSetupAdvisor(this.Plugin)
			else if (this.Action = "StrategyWorkbenchOpen")
				openStrategyWorkbench(this.Plugin)
		}
	}
	
	class RaceAssistantToggleAction extends ControllerAction {
		iPlugin := false
		
		Plugin[] {
			Get {
				return this.iPlugin
			}
		}
		
		__New(plugin, function, label, icon) {
			this.iPlugin := plugin
			
			base.__New(function, label, icon)
		}
		
		fireAction(function, trigger) {
			local plugin := this.Plugin
			
			if plugin.RaceAssistantName
				if (plugin.RaceAssistantEnabled && ((trigger = "Off") || (trigger == "Push"))) {
					plugin.disableRaceAssistant()
				
					trayMessage(plugin.actionLabel(this), translate("State: Off"))
				
					function.setLabel(plugin.actionLabel(this), "Black")
				}
				else if (!plugin.RaceAssistantEnabled && ((trigger = "On") || (trigger == "Push"))) {
					plugin.enableRaceAssistant()
				
					trayMessage(plugin.actionLabel(this), translate("State: On"))
				
					function.setLabel(plugin.actionLabel(this), "Green")
				}
		}
	}
	
	class TeamServerToggleAction extends ControllerAction {
		iPlugin := false
		
		Plugin[] {
			Get {
				return this.iPlugin
			}
		}
		
		__New(plugin, function, label, icon) {
			this.iPlugin := plugin
			
			base.__New(function, label, icon)
		}
		
		fireAction(function, trigger) {
			local plugin := this.Plugin
			
			if (plugin.TeamServer.TeamServerEnabled && ((trigger = "Off") || (trigger == "Push"))) {
				plugin.disableTeamServer()
			
				trayMessage(plugin.actionLabel(this), translate("State: Off"))
			
				function.setLabel(plugin.actionLabel(this), "Black")
			}
			else if (!plugin.TeamServer.TeamServerEnabled && ((trigger = "On") || (trigger == "Push"))) {
				plugin.enableTeamServer()
			
				trayMessage(plugin.actionLabel(this), translate("State: On"))
			
				function.setLabel(plugin.actionLabel(this), "Green")
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
	
	TeamServer[] {
		Get {
			return this.iTeamServer
		}
	}
	
	TeamSession[] {
		Get {
			return this.iTeamSession
		}
	}
	
	TeamSessionActive[] {
		Get {
			return this.iTeamSessionActive
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
	
	RaceAssistantSpeakerVocalics[] {
		Get {
			return this.iRaceAssistantSpeakerVocalics
		}
	}
	
	RaceAssistantListener[] {
		Get {
			return this.iRaceAssistantListener
		}
	}
	
	__New(controller, name, configuration := false, register := true) {
		base.__New(controller, name, configuration, register)
		
		if (!this.Active && !isDebug())
			return
		
		this.iTeamServer := this.Controller.FindPlugin(kTeamServerPlugin)
		
		this.iRaceAssistantName := this.getArgumentValue("raceAssistantName", false)
		this.iRaceAssistantLogo := this.getArgumentValue("raceAssistantLogo", false)
		this.iRaceAssistantLanguage := this.getArgumentValue("raceAssistantLanguage", false)
		
		raceAssistantToggle := this.getArgumentValue("raceAssistant", false)
		
		if raceAssistantToggle {
			arguments := string2Values(A_Space, raceAssistantToggle)
	
			if (arguments.Length() == 0)
				arguments := ["On"]

			if ((arguments.Length() == 1) && !inList(["On", "Off"], arguments[1]))
				arguments.InsertAt(1, "On")
			
			this.iRaceAssistantEnabled := (arguments[1] = "On")
			
			if (arguments.Length() > 1)
				this.createRaceAssistantAction(controller, "RaceAssistant", arguments[2])
		}
		else
			this.iRaceAssistantEnabled := (this.iRaceAssistantName != false)
		
		teamServer := this.Controller.FindPlugin(kTeamServerPlugin)
		teamServerToggle := this.getArgumentValue("teamServer", false)
		
		if (teamServerToggle && teamServer && teamServer.Active) {
			arguments := string2Values(A_Space, teamServerToggle)
	
			if (arguments.Length() == 0)
				arguments := ["On"]
			
			if ((arguments.Length() == 1) && !inList(["On", "Off"], arguments[1]))
				arguments.InsertAt(1, "Off")
			
			if (arguments[1] = "On")
				this.enableTeamServer()
			else
				this.disableTeamServer()
			
			if (arguments.Length() > 1)
				this.createRaceAssistantAction(controller, "TeamServer", arguments[2])
		}
		
		openRaceSettings := this.getArgumentValue("openRaceSettings", false)
		
		if openRaceSettings
			this.createRaceAssistantAction(controller, "RaceSettingsOpen", openRaceSettings)
		
		importSetup := this.getArgumentValue("importSetup", false)
		
		if importSetup
			this.createRaceAssistantAction(controller, "SetupImport", importSetup)
		
		openSetupDatabase := this.getArgumentValue("openSetupDatabase", false)
		
		if openSetupDatabase
			this.createRaceAssistantAction(controller, "SetupDatabaseOpen", openSetupDatabase)
		
		openSetupAdvisor := this.getArgumentValue("openSetupAdvisor", false)
		
		if openSetupAdvisor
			this.createRaceAssistantAction(controller, "SetupAdvisorOpen", openSetupAdvisor)
		
		openStrategyWorkbench := this.getArgumentValue("openStrategyWorkbench", false)
		
		if openStrategyWorkbench
			this.createRaceAssistantAction(controller, "StrategyWorkbenchOpen", openStrategyWorkbench)
		
		openRaceCenter := this.getArgumentValue("openRaceCenter", false)
		
		if openRaceCenter
			this.createRaceAssistantAction(controller, "RaceCenterOpen", openRaceCenter)
		
		for ignore, theAction in string2Values(",", this.getArgumentValue("assistantCommands", ""))
			this.createRaceAssistantAction(controller, string2Values(A_Space, theAction)*)
		
		this.iRaceAssistantService := this.getArgumentValue("raceAssistantService", false)
		
		assistantSpeaker := this.getArgumentValue("raceAssistantSpeaker", false)
		
		if ((assistantSpeaker != false) && (assistantSpeaker != kFalse) && (assistantSpeaker != "Off")) {
			this.iRaceAssistantSpeaker := (((assistantSpeaker = kTrue) || (assistantSpeaker = "On")) ? true : assistantSpeaker)
		
			this.iRaceAssistantSpeakerVocalics := this.getArgumentValue("raceAssistantSpeakerVocalics", false)
		
			assistantListener := this.getArgumentValue("raceAssistantListener", false)
			
			if ((assistantListener != false) && (assistantListener != kFalse) && (assistantListener != "Off"))
				this.iRaceAssistantListener := (((assistantListener = kTrue) || (assistantListener = "On")) ? true : assistantListener)
		}
		
		controller.registerPlugin(this)
	
		registerEventHandler(this.Plugin, ObjBindMethod(this, "handleRemoteCalls"))
	}
	
	handleRemoteCalls(event, data) {
		if InStr(data, ":") {
			data := StrSplit(data, ":", , 2)
			
			return withProtection(ObjBindMethod(this, data[1]), string2Values(";", data[2])*)
		}
		else
			return withProtection(ObjBindMethod(this, data))
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
				descriptor := ConfigurationItem.descriptor(action, "Activate")
				
				this.registerAction(new this.RaceAssistantAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor), "InformationRequest", arguments*))
			}
			else if inList(["Call", "Accept", "Reject"], action) {
				descriptor := ConfigurationItem.descriptor(action, "Activate")
				
				this.registerAction(new this.RaceAssistantAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor), action))
			}
			else if (action = "RaceAssistant") {
				descriptor := ConfigurationItem.descriptor(action, "Toggle")
				
				this.registerAction(new this.RaceAssistantToggleAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor)))
			}
			else if (action = "TeamServer") {
				descriptor := ConfigurationItem.descriptor(action, "Toggle")
				
				this.registerAction(new this.TeamServerToggleAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor)))
			}
			else if ((action = "RaceSettingsOpen") || (action = "SetupImport")
				  || (action = "SetupDatabaseOpen") || (action = "SetupAdvisorOpen")
				  || (action = "StrategyWorkbenchOpen") || (action = "RaceCenterOpen")) {
				descriptor := ConfigurationItem.descriptor(action, "Activate")
				
				this.registerAction(new this.RaceSettingsAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor), action))
			}
			else
				logMessage(kLogWarn, translate("Action """) . action . translate(""" not found in plugin ") . translate(this.Plugin) . translate(" - please check the configuration"))
		}
		else
			this.logFunctionNotFound(actionFunction)
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
	
	activate() {
		base.activate()
		
		this.updateActions(kSessionFinished)
	}
		
	updateActions(sessionState) {
		for ignore, theAction in this.Actions
			if isInstance(theAction, RaceAssistantPlugin.RaceAssistantToggleAction) {
				theAction.Function.setLabel(this.actionLabel(theAction), this.RaceAssistantName ? (this.RaceAssistantEnabled ? "Green" : "Black") : "Gray")
				
				if this.RaceAssistantName
					theAction.Function.enable(kAllTrigger, theAction)
				else
					theAction.Function.disable(kAllTrigger, theAction)
			}
			else if isInstance(theAction, RaceAssistantPlugin.TeamServerToggleAction) {
				teamServer := this.Controller.FindPlugin(kTeamServerPlugin)
				
				theAction.Function.setLabel(this.actionLabel(theAction), (teamServer.TeamServerEnabled ? "Green" : "Black"))
				
				theAction.Function.enable(kAllTrigger, theAction)
			}
			else if isInstance(theAction, RaceAssistantPlugin.RaceSettingsAction) {
				if ((theAction.Action = "RaceSettingsOpen") || (theAction.Action = "SetupDatabaseOpen")
				 || (theAction.Action = "SetupAdvisorOpen")
				 || (theAction.Action = "StrategyWorkbenchOpen")|| (theAction.Action = "RaceCenterOpen")) {
					theAction.Function.enable(kAllTrigger, theAction)
					theAction.Function.setLabel(theAction.Label)
				}
				else if (theAction.Action = "SetupImport") {
					if this.supportsSetupImport() {
						theAction.Function.enable(kAllTrigger, theAction)
						theAction.Function.setLabel(theAction.Label)
					}
					else {
						theAction.Function.disable(kAllTrigger, theAction)
						theAction.Function.setLabel(theAction.Label, "Gray")
					}
				}
			}
			else if isInstance(theAction, RaceAssistantPlugin.RaceAssistantAction)
				if (((sessionState == kSessionRace) || (theAction.Action = "InformationRequest")) && (this.RaceAssistant != false)) {
					theAction.Function.enable(kAllTrigger, theAction)
					theAction.Function.setLabel(theAction.Label)
				}
				else {
					theAction.Function.disable(kAllTrigger, theAction)
					theAction.Function.setLabel(theAction.Label, "Gray")
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
	
	enableTeamServer() {
		teamServer := this.Controller.FindPlugin(kTeamServerPlugin)
		
		if (teamServer && teamServer.Active)
			teamServer.enableTeamServer()
	}
	
	disableTeamServer() {
		teamServer := this.Controller.FindPlugin(kTeamServerPlugin)
		
		if (teamServer && teamServer.Active)
			teamServer.disableTeamServer()
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
				
				options := " -Remote " . controllerPID
				
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
				
				if this.RaceAssistantSpeakerVocalics
					options .= " -SpeakerVocalics """ . this.RaceAssistantSpeakerVocalics . """"
				
				if this.RaceAssistantListener
					options .= " -Listener """ . this.RaceAssistantListener . """"
				
				if this.Controller.VoiceServer
					options .= " -Voice """ . this.Controller.VoiceServer . """"
				
				exePath := """" . kBinariesDirectory . this.Plugin . ".exe""" . options
				
				Run %exePath%, %kBinariesDirectory%, , raceAssistantPID
				
				Sleep 5000
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
		
		if raceAssistant {
			this.iWaitPeriod := (A_TickCount + (90 * 1000))
			
			raceAssistant.shutdown()
		}
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
		
		; writeConfiguration(kTempDirectory . this.Plugin . ".settings", settings)
		
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
	
	connectTeamSession() {
		teamServer := this.TeamServer
		
		this.iTeamSessionActive := false
		
		if (teamServer && teamServer.TeamServerEnabled) {
			settings := readConfiguration(getFileName("Race.settings", kUserConfigDirectory))
			sessionIdentifier := getConfigurationValue(settings, "Team Settings", "Session.Identifier", false)
				
			if !teamServer.Connected {
				serverURL := getConfigurationValue(settings, "Team Settings", "Server.URL", "")
				accessToken := getConfigurationValue(settings, "Team Settings", "Server.Token", "")
				
				teamIdentifier := getConfigurationValue(settings, "Team Settings", "Team.Identifier", false)
				driverIdentifier := getConfigurationValue(settings, "Team Settings", "Driver.Identifier", false)
				
				this.iTeamSessionActive := teamServer.connect(serverURL, accessToken, teamIdentifier, driverIdentifier, sessionIdentifier)
			}
			else
				this.iTeamSessionActive := true
			
			this.iTeamSession := (this.TeamSessionActive ? sessionIdentifier : false)
		}
		else
			this.iTeamSession := false
		
		return this.iTeamSessionActive
	}
	
	disconnectTeamSession() {
		teamServer := this.TeamServer
		
		this.iTeamSessionActive := false
		
		if (teamServer && teamServer.TeamServerEnabled)
			teamServer.disconnect()
	}
	
	prepareSession(settingsFile, dataFile) {
		if this.RaceAssistant
			this.RaceAssistant.prepareSession(settingsFile, dataFile)
	}
	
	startSession(settingsFile, dataFile, teamSession) {
		if this.Simulator {
			code := this.Simulator.Code
			assistant := this.Plugin
		
			FileCreateDir %kTempDirectory%%code% Data
			
			Loop Files, %kTempDirectory%%code% Data\%assistant%*.*
				if (A_LoopFilePath != dataFile)
					FileDelete %A_LoopFilePath%
		}
		
		if this.RaceAssistant
			this.finishSession(false, !teamSession)
		else
			this.startupRaceAssistant()
	
		if this.RaceAssistant
			this.RaceAssistant.startSession(settingsFile, dataFile)
	}
	
	finishSession(shutdownAssistant := true, shutdownTeamSession := true) {
		if this.RaceAssistant {
			this.RaceAssistant.finishSession(shutdownAssistant)
			
			if (shutdownTeamSession && this.TeamSessionActive) {
				this.TeamServer.leaveSession()
				
				this.disconnectTeamSession()
			}
				
			if shutdownAssistant
				this.shutdownRaceAssistant()
		}
	}
	
	addLap(lapNumber, dataFile, telemetryData, positionsData) {
		if this.RaceAssistant
			this.RaceAssistant.addLap(lapNumber, dataFile)
		
		if this.TeamSessionActive
			this.TeamServer.addLap(lapNumber, telemetryData, positionsData)
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
		if this.RaceAssistant
			this.RaceAssistant.performPitstop(lapNumber)
	}
	
	call() {
		if this.RaceAssistant
			this.RaceAssistant.call()
	}
	
	accept() {
		if this.RaceAssistant
			this.RaceAssistant.accept()
	}
	
	reject() {
		if this.RaceAssistant
			this.RaceAssistant.reject()
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
	
	updatePositionsData(data) {
		this.Simulator.updatePositionsData(data)
	}
	
	sessionActive(sessionState) {
		return (sessionState >= kSessionPractice)
	}
	
	saveSessionState(settingsFile, stateFile) {
		teamServer := this.TeamServer
		
		if (teamServer && teamServer.Active) {
			FileRead sessionSettings, %settingsFile%
			FileRead sessionState, %stateFile%
			
			if isDebug()
				showMessage("Saving session for " . this.RaceAssistantName)
			
			teamServer.setSessionValue(this.Plugin . " Settings", sessionSettings)
			teamServer.setSessionValue(this.Plugin . " State", sessionState)
		}
		
		try {
			FileDelete %settingsFile%
			FileDelete %stateFile%
		}
		catch exception {
			; ignore
		}
	}
	
	createSessionSettingsFile(ByRef sessionSettings) {
		teamServer := this.TeamServer
		
		parse := (sessionSettings != false)
		
		if (teamServer && teamServer.Active) {
			try {
				sessionSettings := teamServer.getSessionValue(this.Plugin . " Settings")
				
				if (!sessionSettings || (sessionSettings = ""))
					Throw "No data..."
			}
			catch exception {
				return false
			}
				
			Random postfix, 1, 1000000
					
			settingsFile := (kTempDirectory . this.Plugin . A_Space . postfix . ".settings")

			FileAppend %sessionSettings%, %settingsFile%, UTF-16
			
			if parse
				sessionSettings := parseConfiguration(sessionSettings)
			
			return settingsFile
		}
		else
			return false
	}
	
	createSessionStateFile(ByRef sessionState) {
		teamServer := this.TeamServer
		
		parse := (sessionState != false)
		
		if (teamServer && teamServer.Active) {
			try {
				sessionState := teamServer.getSessionValue(this.Plugin . " State")
				
				if (!sessionState || (sessionState = ""))
					Throw "No data..."
			}
			catch exception {
				return false
			}
				
			Random postfix, 1, 1000000
					
			stateFile := (kTempDirectory . this.Plugin . A_Space . postfix . ".state")

			FileAppend %sessionState%, %stateFile%, UTF-16
			
			if parse
				sessionState := parseConfiguration(sessionState)
			
			return stateFile
		}
		else
			return false
	}
	
	restoreSessionState() {
		if this.RaceAssistant {
			teamServer := this.TeamServer
		
			if (teamServer && teamServer.Active) {
				if isDebug()
					showMessage("Restoring session state for " . this.RaceAssistantName)
				
				sessionSettings := true
				sessionState := true
				
				this.RaceAssistant.restoreSessionState(this.createSessionSettingsFile(sessionSettings), this.createSessionStateFile(sessionState))
				
				if (sessionSettings || sessionState)
					this.Simulator.restoreSessionState(sessionSettings, sessionState)
			}
		}
	}
	
	driverActive(data) {
		if this.TeamSessionActive {
			teamServer := this.TeamServer
			
			return ((getConfigurationValue(data, "Stint Data", "DriverForname") = teamServer.DriverForName)
				 && (getConfigurationValue(data, "Stint Data", "DriverSurname") = teamServer.DriverSurName))
		}
		else
			return true
	}
	
	acquireSessionData(ByRef telemetryData, ByRef positionsData) {
		code := this.Simulator.Code
			
		data := readSimulatorData(code)
			
		this.updateSessionData(data)
		
		if telemetryData
			if !IsObject(telemetryData)
				telemetryData := data.Clone()
			else
				for section, values in data
					setConfigurationSectionValues(telemetryData, section, values)
		
		if (positionsData && !IsObject(positionsData))
			positionsData := newConfiguration()
		
		return data
	}
	
	collectSessionData() {
		if (A_TickCount <= this.iWaitPeriod)
			return
		
		if this.Simulator {
			code := this.Simulator.Code
			
			if (this.TeamServer && this.TeamServer.TeamServerEnabled) {
				telemetryData := true
				positionsData := true
			}
			else {
				telemetryData := false
				positionsData := false
			}
			
			data := this.acquireSessionData(telemetryData, positionsData)
			
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
				joinedSession := false
				
				this.updateSessionState(sessionState)
				
				if (sessionState == kSessionPaused) {
					this.iInPit := false
					
					return
				}
				else if !this.sessionActive(sessionState) {
					; Not in a supported session
				
					this.iLastLap := 0
					this.iLastLapCounter := 0
					this.iFinished := false
					this.iInPit := false
			
					if this.RaceAssistant
						this.finishSession()
					
					return
				}
				
				if ((dataLastLap <= 1) && (dataLastLap < this.iLastLap)) {
					; Start of new race without finishing previous race first
				
					this.iLastLap := 0
					this.iLastLapCounter := 0
					this.iFinished := false
					this.iInPit := false
			
					if this.RaceAssistant
						this.finishSession()
				}
				
				if this.RaceAssistantEnabled {
					; Car is on the track
				
					if !this.RaceAssistant
						this.startupRaceAssistant()
					
					if getConfigurationValue(data, "Stint Data", "InPit", false) {
						; Car is in the Pit
						
						if !this.iInPit {
							this.performPitstop(dataLastLap)
						
							this.iInPit := dataLastLap
						}
					}
					else if (dataLastLap == 0) {
						; Waiting for the car to cross the start line for the first time
					
						if (this.iLastLapCounter = 5) {
							dataFile := kTempDirectory . this.Plugin . " Lap 0.0.data"
								
							writeConfiguration(dataFile, data)
							
							settings := this.prepareSettings(data)
							settingsFile := (kTempDirectory . this.Plugin . ".settings")
							
							writeConfiguration(settingsFile, settings)
							
							this.prepareSession(settingsFile, dataFile)
						}
						
						this.iLastLapCounter := this.iLastLapCounter + 1
					}
					else if (dataLastLap > 0) {
						; Car has finished the first lap
					
						if (dataLastLap > 1) {
							if (this.iLastLap == 0) {
								; Missed the start of the session, might be a team session
									
								teamSessionActive := this.connectTeamSession()
							
								if (!teamSessionActive || !this.TeamServer.Connected)
									return ; No Team Server, no late join
								
								if !this.driverActive(data)
									return ; Still a different driver, might happen in some simulations
							
								this.iInPit := false
								
								joinedSession := true
							}
							else if (this.iLastLap < (dataLastLap - 1)) {
								; Regained the car after a driver swap, new stint
								
								if !this.driverActive(data)
									return ; Still a different driver, might happen in some simulations
							
								this.TeamServer.addStint(dataLastLap)
								
								this.iInPit := false
								
								this.restoreSessionState()
							}
							else ; (this.iLastLap == (dataLastLap - 1))
								if !this.driverActive(data)
									return ; Oops, a different driver, might happen in some simulations after a pitstop
						}
						
						newLap := (dataLastLap > this.iLastLap)
						firstLap := ((dataLastLap == 1) && newLap)
						
						if this.iInPit {
							; Was in the pits, check if same driver for next stint...
							
							if this.driverActive(data)
								this.TeamServer.addStint(dataLastLap)
						}
						
						this.iInPit := false
						
						if newLap {
							if this.iFinished {
								this.iLastLap := 0
								this.iLastLapCounter := 0
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
						
						this.iLastLapCounter := this.iLastLapCounter + 1
						
						newDataFile := kTempDirectory . code . " Data\" . this.Plugin . " Lap " . this.iLastLap . "." . this.iLastLapCounter . ".data"
							
						writeConfiguration(newDataFile, data)
						
						if firstLap {
							if this.connectTeamSession() {
								teamServer := this.TeamServer
								
								teamServer.joinSession(getConfigurationValue(data, "Session Data", "Car")
													 , getConfigurationValue(data, "Session Data", "Track")
													 , dataLastLap
													 , Round((getConfigurationValue(data, "Session Data", "SessionTimeRemaining", 0) / 1000) / 60))
							
								this.TeamServer.setSessionValue(this.Plugin . " Settings", "")
								this.TeamServer.setSessionValue(this.Plugin . " State", "")
							}
							
							settings := this.prepareSettings(data)
							settingsFile := (kTempDirectory . this.Plugin . ".settings")
							
							writeConfiguration(settingsFile, settings)
							
							this.startSession(settingsFile, newDataFile, this.TeamSessionActive)
						}
						else if joinedSession {
							this.TeamServer.joinSession(getConfigurationValue(data, "Session Data", "Car")
													  , getConfigurationValue(data, "Session Data", "Track")
													  , dataLastLap)
							
							settingsFile := this.createSessionSettingsFile()
							
							if !settingsFile {
								settings := this.prepareSettings(data)
								
								Random postfix, 1, 1000000
	
								settingsFile := (kTempDirectory . this.Plugin . A_Space . postfix . ".settings")
								
								writeConfiguration(settingsFile, settings)
							}	
								
							this.startSession(settingsFile, newDataFile, this.TeamSessionActive)
							
							this.restoreSessionState()
						}
						
						if newLap
							this.addLap(dataLastLap, newDataFile, telemetryData, positionsData)
						else	
							this.updateLap(dataLastLap, newDataFile)
					}
				}
				else {
					this.iLastLap := 0
					this.iLastLapCounter := 0
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
			this.iLastLapCounter := 0
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
	exePath := kBinariesDirectory . simulator . A_Space . protocol . " Provider.exe"
	
	Random postfix, 1, 1000000
	
	FileCreateDir %kTempDirectory%%simulator% Data
	
	dataFile := (kTempDirectory . simulator . " Data\" . protocol . "_" . Round(postfix) . ".data")
	
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
			options .= " -Map " . getConfigurationValue(data, "Car Data", "MAP", "n/a")
			options .= " -TC " . getConfigurationValue(data, "Car Data", "TC", "n/a")
			options .= " -ABS " . getConfigurationValue(data, "Car Data", "ABS", "n/a")
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

openSetupAdvisor(plugin := false) {
	exePath := kBinariesDirectory . "Setup Advisor.exe"	
	controller := SimulatorController.Instance
	
	if !plugin {
		plugin := controller.findPlugin(kRaceEngineerPlugin)
		
		if !plugin
			plugin := controller.findPlugin(kRaceStrategistPlugin)
	}
	
	try {
		; options := getSimulatorOptions(plugin)
		
		Run "%exePath%" %options%, %kBinariesDirectory%, , pid
	}
	catch exception {
		logMessage(kLogCritical, translate("Cannot start the Setup Advisor tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))
			
		showMessage(substituteVariables(translate("Cannot start the Setup Advisor tool (%exePath%) - please check the configuration..."), {exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

openStrategyWorkbench(plugin := false) {
	exePath := kBinariesDirectory . "Strategy Workbench.exe"	
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
		logMessage(kLogCritical, translate("Cannot start the Strategy Workbench tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))
			
		showMessage(substituteVariables(translate("Cannot start the Strategy Workbench tool (%exePath%) - please check the configuration..."), {exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

openRaceCenter(plugin := false) {
	exePath := kBinariesDirectory . "Race Center.exe"	
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
		logMessage(kLogCritical, translate("Cannot start the Race Center tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))
			
		showMessage(substituteVariables(translate("Cannot start the Race Center tool (%exePath%) - please check the configuration..."), {exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}