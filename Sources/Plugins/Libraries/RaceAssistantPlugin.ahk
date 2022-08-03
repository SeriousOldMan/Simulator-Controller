;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Assistant Plugin           ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Messages.ahk
#Include ..\Plugins\Libraries\SimulatorPlugin.ahk
#Include ..\Assistants\Libraries\SessionDatabase.ahk
#Include ..\Assistants\Libraries\SettingsDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceAssistantPlugin extends ControllerPlugin  {
	iRaceAssistantEnabled := false
	iRaceAssistantName := false
	iRaceAssistantLogo := false
	iRaceAssistantLanguage := false
	iRaceAssistantSynthesizer := false
	iRaceAssistantSpeaker := false
	iRaceAssistantSpeakerVocalics := false
	iRaceAssistantRecognizer := false
	iRaceAssistantListener := false

	iRaceAssistant := false
	iRaceAssistantZombie := false

	iTeamServer := false
	iTeamSession := false
	iTeamSessionActive := false

	iSimulator := false
	iSessionActive := false

	iLastSession := kSessionFinished
	iLastLap := 0
	iUpdateLapCounter := 0
	iWaitForShutdown := 0
	iInPit := false
	iFinished := false

	class RemoteRaceAssistant {
		iPlugin := false
		iRemoteEvent := false
		iRemotePID := false

		Plugin[] {
			Get {
				return this.iPlugin
			}
		}

		RemotePID[] {
			Get {
				return this.iRemotePID
			}
		}

		__New(plugin, remoteEvent, remotePID) {
			this.iPlugin := plugin
			this.iRemoteEvent := remoteEvent
			this.iRemotePID := remotePID
		}

		callRemote(function, arguments*) {
			Process Exist, % (this.Plugin.Plugin . ".exe")

			if ErrorLevel {
				if (ErrorLevel != this.RemotePID)
					this.iRemotePID := ErrorLevel
			}
			else
				return

			sendMessage(kFileMessage, this.iRemoteEvent, function . ":" . values2String(";", arguments*), this.RemotePID)
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
			local action := this.Action
			local enabled

			if ((action = "Accept") || (action = "Reject"))
				enabled := (this.Plugin.RaceAssistant[true] != false)
			else
				enabled := (this.Plugin.RaceAssistant != false)

			if enabled
				switch action {
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
			else if (this.Action = "SessionDatabaseOpen")
				openSessionDatabase(this.Plugin)
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
					plugin.disableRaceAssistant(plugin.actionLabel(this))

					function.setLabel(plugin.actionLabel(this), "Black")
				}
				else if (!plugin.RaceAssistantEnabled && ((trigger = "On") || (trigger == "Push"))) {
					plugin.enableRaceAssistant(plugin.actionLabel(this))

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
				plugin.disableTeamServer(plugin.actionLabel(this))

				function.setLabel(plugin.actionLabel(this), "Black")
			}
			else if (!plugin.TeamServer.TeamServerEnabled && ((trigger = "On") || (trigger == "Push"))) {
				plugin.enableTeamServer(plugin.actionLabel(this))

				function.setLabel(plugin.actionLabel(this), "Green")
			}
		}
	}

	Simulator[] {
		Get {
			return this.iSimulator
		}
	}

	SessionActive[] {
		Get {
			return this.iSessionActive
		}
	}

	RaceAssistant[zombie := false] {
		Get {
			local wasZombie

			if (!this.iRaceAssistant && zombie) {
				if !this.iWaitForShutdown {
					wasZombie := (this.iRaceAssistantZombie != false)

					this.iRaceAssistantZombie := false

					if wasZombie
						this.updateActions(kSessionFinished)
				}

				return this.iRaceAssistantZombie
			}
			else
				return this.iRaceAssistant
		}

		Set {
			if value
				this.iRaceAssistantZombie := value

			return (this.iRaceAssistant := value)
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

	RaceAssistantSynthesizer[] {
		Get {
			return this.iRaceAssistantSynthesizer
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

	RaceAssistantRecognizer[] {
		Get {
			return this.iRaceAssistantRecognizer
		}
	}

	RaceAssistantListener[] {
		Get {
			return this.iRaceAssistantListener
		}
	}

	LastLap[] {
		Get {
			return this.iLastLap
		}
	}

	InPit[] {
		Get {
			return this.iInPit
		}
	}

	__New(controller, name, configuration := false, register := true) {
		local teamServer, raceAssistantToggle, teamServerToggle, arguments, ignore, theAction
		local openRaceSettings, openSessionDatabase, openSetupAdvisor, openRaceCenter, openStrategyWorkbench, importSetup
		local assistantSpeaker, assistantListener

		base.__New(controller, name, configuration, register)

		if (this.Active || isDebug()) {
			teamServer := this.Controller.findPlugin(kTeamServerPlugin)

			if (teamServer && this.Controller.isActive(teamServer))
				this.iTeamServer := teamServer
			else
				teamServer := false

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

			teamServerToggle := this.getArgumentValue("teamServer", false)

			if (teamServerToggle && teamServer && teamServer.Active) {
				arguments := string2Values(A_Space, teamServerToggle)

				if (arguments.Length() == 0)
					arguments := ["Off"]

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

			openSessionDatabase := this.getArgumentValue("openSessionDatabase", false)

			if openSessionDatabase
				this.createRaceAssistantAction(controller, "SessionDatabaseOpen", openSessionDatabase)

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

			this.iRaceAssistantSynthesizer := this.getArgumentValue("raceAssistantSynthesizer", false)

			assistantSpeaker := this.getArgumentValue("raceAssistantSpeaker", false)

			if ((assistantSpeaker != false) && (assistantSpeaker != kFalse) && (assistantSpeaker != "Off")) {
				this.iRaceAssistantSpeaker := (((assistantSpeaker = kTrue) || (assistantSpeaker = "On")) ? true : assistantSpeaker)

				this.iRaceAssistantSpeakerVocalics := this.getArgumentValue("raceAssistantSpeakerVocalics", false)

				this.iRaceAssistantRecognizer := this.getArgumentValue("raceAssistantRecognizer", false)

				assistantListener := this.getArgumentValue("raceAssistantListener", false)

				if ((assistantListener != false) && (assistantListener != kFalse) && (assistantListener != "Off"))
					this.iRaceAssistantListener := (((assistantListener = kTrue) || (assistantListener = "On")) ? true : assistantListener)
			}

			controller.registerPlugin(this)

			registerMessageHandler(this.Plugin, "methodMessageHandler", this)

			if this.RaceAssistantEnabled
				this.enableRaceAssistant(false, true)
			else
				this.disableRaceAssistant(false, true)
		}
	}

	createRaceAssistantAction(controller, action, actionFunction, arguments*) {
		local function, descriptor

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
				  || (action = "SessionDatabaseOpen") || (action = "SetupAdvisorOpen")
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
		local ignore, theAction, teamServer

		for ignore, theAction in this.Actions
			if isInstance(theAction, RaceAssistantPlugin.RaceAssistantToggleAction) {
				theAction.Function.setLabel(this.actionLabel(theAction), this.RaceAssistantName ? (this.RaceAssistantEnabled ? "Green" : "Black") : "Gray")

				if this.RaceAssistantName
					theAction.Function.enable(kAllTrigger, theAction)
				else
					theAction.Function.disable(kAllTrigger, theAction)
			}
			else if isInstance(theAction, RaceAssistantPlugin.TeamServerToggleAction) {
				teamServer := this.TeamServer

				if teamServer {
					theAction.Function.setLabel(this.actionLabel(theAction), (teamServer.TeamServerEnabled ? "Green" : "Black"))
					theAction.Function.enable(kAllTrigger, theAction)
				}
				else {
					theAction.Function.setLabel(this.actionLabel(theAction), "Gray")
					theAction.Function.disable(kAllTrigger, theAction)
				}
			}
			else if isInstance(theAction, RaceAssistantPlugin.RaceSettingsAction) {
				if ((theAction.Action = "RaceSettingsOpen") || (theAction.Action = "SessionDatabaseOpen")
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
				if (((theAction.Action = "Accept") || (theAction.Action = "Reject")) && (this.RaceAssistant[true] != false)) {
					theAction.Function.enable(kAllTrigger, theAction)
					theAction.Function.setLabel(theAction.Label)
				}
				else if (this.RaceAssistant != false) {
					theAction.Function.enable(kAllTrigger, theAction)
					theAction.Function.setLabel(theAction.Label)
				}
				else {
					theAction.Function.disable(kAllTrigger, theAction)
					theAction.Function.setLabel(theAction.Label, "Gray")
				}
	}

	toggleRaceAssistant() {
		if this.RaceAssistantEnabled
			this.disableRaceAssistant()
		else
			this.enableRaceAssistant()
	}

	updateTrayLabel(label, enabled) {
		local callback

		static hasTrayMenu := {}
		static first := true

		label := StrReplace(label, "`n", A_Space)

		if !hasTrayMenu.HasKey(this) {
			callback := ObjBindMethod(this, "toggleRaceAssistant")

			if first
				Menu Tray, Insert, 1&

			Menu Tray, Insert, 1&, %label%, %callback%

			hasTrayMenu[this] := true
			first := false
		}

		if enabled
			Menu Tray, Check, %label%
		else
			Menu Tray, Uncheck, %label%
	}

	enableRaceAssistant(label := false, force := false) {
		if (!this.RaceAssistantEnabled || force) {
			this.iRaceAssistantEnabled := (this.RaceAssistantName != false)

			if this.RaceAssistantEnabled {
				label := translate(this.Plugin)

				trayMessage(label, translate("State: On"))

				this.updateTrayLabel(label, true)
			}
		}
	}

	disableRaceAssistant(label := false, force := false) {
		if (this.RaceAssistantEnabled || force) {
			label := translate(this.Plugin)

			trayMessage(label, translate("State: Off"))

			this.iRaceAssistantEnabled := false

			this.iLastSession := kSessionFinished
			this.iLastLap := 0
			this.iUpdateLapCounter := 0
			this.iFinished := false
			this.iInPit := false

			if this.RaceAssistant
				this.finishSession()

			this.updateTrayLabel(label, false)
		}
	}

	enableTeamServer(label := false) {
		local teamServer := this.TeamServer

		if (teamServer && teamServer.Active)
			teamServer.enableTeamServer(label)
	}

	disableTeamServer(label := false) {
		local teamServer := this.TeamServer

		if (teamServer && teamServer.Active)
			teamServer.disableTeamServer(label)
	}

	createRaceAssistant(pid) {
		return new this.RemoteRaceAssistant(pid)
	}

	startupRaceAssistant() {
		local pid, options

		if (this.RaceAssistantEnabled) {
			Process Exist

			pid := ErrorLevel

			try {
				logMessage(kLogInfo, translate("Starting ") . translate(this.Plugin))

				options := " -Remote " . pid

				if this.RaceAssistantName
					options .= " -Name """ . this.RaceAssistantName . """"

				if this.RaceAssistantLogo
					options .= " -Logo """ . this.RaceAssistantLogo . """"

				if this.RaceAssistantLanguage
					options .= " -Language """ . this.RaceAssistantLanguage . """"

				if this.RaceAssistantSynthesizer
					options .= " -Synthesizer """ . this.RaceAssistantSynthesizer . """"

				if this.RaceAssistantSpeaker
					options .= " -Speaker """ . this.RaceAssistantSpeaker . """"

				if this.RaceAssistantSpeakerVocalics
					options .= " -SpeakerVocalics """ . this.RaceAssistantSpeakerVocalics . """"

				if this.RaceAssistantRecognizer
					options .= " -Recognizer """ . this.RaceAssistantRecognizer . """"

				if this.RaceAssistantListener
					options .= " -Listener """ . this.RaceAssistantListener . """"

				if this.Controller.VoiceServer
					options .= " -Voice """ . this.Controller.VoiceServer . """"

				exePath := """" . kBinariesDirectory . this.Plugin . ".exe""" . options

				Run %exePath%, %kBinariesDirectory%, , pid

				Sleep 1500
			}
			catch exception {
				logMessage(kLogCritical, translate("Cannot start " . this.Plugin . " (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

				showMessage(substituteVariables(translate("Cannot start " . this.Plugin . " (%kBinariesDirectory%Race Assistant.exe) - please rebuild the applications..."))
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

				return false
			}

			this.RaceAssistant := this.createRaceAssistant(pid)

			return true
		}
		else
			return false
	}

	shutdownRaceAssistant() {
		local raceAssistant := this.RaceAssistant

		this.RaceAssistant := false

		if raceAssistant {
			this.iWaitForShutdown := (A_TickCount + (90 * 1000))

			raceAssistant.shutdown()
		}
	}

	prepareSettings(data) {
		local settingsDB := new SettingsDatabase()
		local simulator := getConfigurationValue(data, "Session Data", "Simulator")
		local car := getConfigurationValue(data, "Session Data", "Car")
		local track := getConfigurationValue(data, "Session Data", "Track")
		local simulatorName := settingsDB.getSimulatorName(simulator)
		local settings := readConfiguration(getFileName("Race.settings", kUserConfigDirectory))
		local  loadSettings := getConfigurationValue(this.Configuration, this.Plugin . " Startup", simulatorName . ".LoadSettings", "Default")
		local section, values, key, value

		loadSettings := getConfigurationValue(this.Configuration, "Race Assistant Startup", simulatorName . ".LoadSettings", loadSettings)

		if ((loadSettings = "SettingsDatabase") || (loadSettings = "SessionDatabase"))
			for section, values in settingsDB.loadSettings(simulatorName, car, track
														 , getConfigurationValue(data, "Weather Data", "Weather", "Dry"))
				for key, value in values
					setConfigurationValue(settings, section, key, value)

		if isDebug()
			writeConfiguration(kTempDirectory . this.Plugin . ".settings", settings)

		return settings
	}

	reloadSettings(pid, settingsFileName) {
		Process Exist, %pid%

		if ErrorLevel
			Task.startTask(ObjBindMethod(this, "reloadSettings", pid, settingsFileName), 1000, kLowPriority)
		else if this.RaceAssistant
			this.RaceAssistant.updateSession(settingsFileName)

		return false
	}

	connectTeamSession() {
		local teamServer := this.TeamServer
		local settings, sessionIdentifier, serverURL, accessToken, teamIdentifier, driverIdentifier

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

		return this.TeamSessionActive
	}

	disconnectTeamSession() {
		local teamServer := this.TeamServer

		this.iTeamSessionActive := false

		if (teamServer && teamServer.TeamServerEnabled)
			teamServer.disconnect()
	}

	prepareSession(settingsFile, dataFile) {
		if this.RaceAssistant
			this.RaceAssistant.prepareSession(settingsFile, dataFile)
	}

	startSession(settings, data, teamSession) {
		local code, assistant, settingsFile, dataFile

		if this.Simulator {
			code := this.Simulator.Code
			assistant := this.Plugin

			FileCreateDir %kTempDirectory%%code% Data

			Loop Files, %kTempDirectory%%code% Data\%assistant%*.*
				try {
					FileDelete %A_LoopFilePath%
				}
				catch exception {
					; ignore
				}

			this.Simulator.startSession(settings, data)

			if this.RaceAssistant
				this.finishSession(false, !teamSession)
			else
				this.startupRaceAssistant()

			this.iSessionActive := true

			if this.RaceAssistant {
				settingsFile := (kTempDirectory . this.Plugin . ".settings")
				dataFile := (kTempDirectory . this.Plugin . ".data")

				writeConfiguration(settingsFile, settings)
				writeConfiguration(dataFile, data)

				this.RaceAssistant.startSession(settingsFile, dataFile)
			}
		}
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

		this.iSessionActive := false
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
		if this.RaceAssistant[true]
			this.RaceAssistant[true].accept()
	}

	reject() {
		if this.RaceAssistant[true]
			this.RaceAssistant[true].reject()
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
		local simulator, car, track, maxFuel, compound, compoundColor

		static settingsDB := false

		if !settingsDB
			settingsDB := new SettingsDatabase()

		simulator := getConfigurationValue(data, "Session Data", "Simulator")
		car := getConfigurationValue(data, "Session Data", "Car")
		track := getConfigurationValue(data, "Session Data", "Track")

		maxFuel := settingsDB.getSettingValue(simulator, car, track
											, "*", "Session Settings", "Fuel.Amount", kUndefined)

		if (maxFuel && (maxFuel != kUndefined) && (maxFuel != ""))
			setConfigurationValue(data, "Session Data", "FuelAmount", maxFuel)

		compound := getConfigurationValue(data, "Car Data", "TyreCompoundRaw", kUndefined)

		if (compound != kUndefined) {
			compound := new SessionDatabase().getTyreCompoundName(simulator, car, track, compound, "Dry")
			compoundColor := false

			splitCompound(compound, compound, compoundColor)

			setConfigurationValue(data, "Car Data", "TyreCompound", compound)
			setConfigurationValue(data, "Car Data", "TyreCompoundColor", compoundColor)
		}

		this.Simulator.updateSessionData(data)
	}

	updatePositionsData(data) {
		this.Simulator.updatePositionsData(data)
	}

	runningSession(data) {
		return getConfigurationValue(data, "Session Data", "Active", false)
	}

	activeSession(data) {
		return (getDataSessionState(data) >= kSessionPractice)
	}

	callSaveSessionState(settingsFile, stateFile) {
		local sessionSettings, sessionState

		if settingsFile {
			sessionSettings := readConfiguration(settingsFile)

			try {
				FileDelete %settingsFile%
			}
			catch exception {
				; ignore
			}
		}
		else
			sessionSettings := false

		if stateFile {
			sessionState := readConfiguration(stateFile)

			try {
				FileDelete %stateFile%
			}
			catch exception {
				; ignore
			}
		}
		else
			sessionState := false

		this.saveSessionState(sessionSettings, sessionState)
	}

	saveSessionState(settings, state) {
		local teamServer := this.TeamServer

		this.Simulator.saveSessionState(settings, state)

		if (teamServer && teamServer.Active) {
			if isDebug()
				showMessage("Saving session for " . this.RaceAssistantName)

			if settings
				teamServer.setSessionValue(this.Plugin . " Settings", printConfiguration(settings))

			if state
				teamServer.setSessionValue(this.Plugin . " State", printConfiguration(state))
		}
	}

	createSessionSettings() {
		local teamServer := this.TeamServer
		local sessionSettings

		if (teamServer && teamServer.Active)
			try {
				sessionSettings := teamServer.getSessionValue(this.Plugin . " Settings")

				if (!sessionSettings || (sessionSettings = ""))
					Throw "No data..."
				else
					return parseConfiguration(sessionSettings)
			}
			catch exception {
				return false
			}
		else
			return false
	}

	createSessionState() {
		local teamServer := this.TeamServer
		local sessionState

		if (teamServer && teamServer.Active)
			try {
				sessionState := teamServer.getSessionValue(this.Plugin . " State")

				if (!sessionState || (sessionState = ""))
					Throw "No data..."
				else
					return parseConfiguration(sessionState)
			}
			catch exception {
				return false
			}
		else
			return false
	}

	createSessionSettingsFile(sessionSettings) {
		local postfix, settingsFile

		Random postfix, 1, 1000000

		settingsFile := (kTempDirectory . this.Plugin . A_Space . postfix . ".settings")
		sessionSettings := printConfiguration(sessionSettings)

		FileAppend %sessionSettings%, %settingsFile%, UTF-16
	}

	createSessionStateFile(sessionState) {
		local postfix, stateFile

		Random postfix, 1, 1000000

		stateFile := (kTempDirectory . this.Plugin . A_Space . postfix . ".settings")
		sessionState := printConfiguration(sessionState)

		FileAppend %sessionState%, %stateFile%, UTF-16
	}

	restoreSessionState() {
		local teamServer := this.TeamServer
		local sessionSettings, sessionState

		if (this.RaceAssistant && teamServer && teamServer.Active) {
			if isDebug()
				showMessage("Restoring session state for " . this.RaceAssistantName)

			sessionSettings := this.createSessionSettings()
			sessionState := this.createSessionState()

			if (sessionSettings || sessionState)
				this.Simulator.restoreSessionState(sessionSettings, sessionState)

			if sessionSettings
				sessionSettings := this.createSettingsFile(sessionSettings)

			if sessionState
				sessionState := this.createStateFile(sessionState)

			this.RaceAssistant.restoreSessionState(sessionSettings, sessionState)
		}
	}

	driverActive(data) {
		local teamServer := this.TeamServer

		if this.TeamSessionActive
			return ((getConfigurationValue(data, "Stint Data", "DriverForname") = teamServer.DriverForName)
				 && (getConfigurationValue(data, "Stint Data", "DriverSurname") = teamServer.DriverSurName))
		else
			return true
	}

	acquireSessionData(ByRef telemetryData, ByRef positionsData) {
		local simulator, code, trackData, data, section, values

		static sessionDB := false

		if !sessionDB
			sessionDB := new SessionDatabase()

		simulator := this.Simulator
		code := simulator.Code
		trackData := sessionDB.getTrackData(code, simulator.Track)
		data := (trackData ? readSimulatorData(code, "-Track """ . trackData . """") : readSimulatorData(code))

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
		local code, telemetryData, positionsData, data, dataFile, settings, settingsFile, dataLastLap
		local testData, message, key, value, sessionState, teamServer, teamSessionActive, joinedSession, wasFinished
		local newLap, firstLap

		if (A_TickCount <= this.iWaitForShutdown)
			return
		else {
			this.iWaitForShutdown := false

			this.RaceAssistant[true]
		}

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

			if (this.runningSession(data) && (this.iLastLap == 0))
				prepareSessionDatabase(data)

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

				if !this.activeSession(data) {
					; Not in a supported session

					this.iLastSession := kSessionFinished
					this.iLastLap := 0
					this.iUpdateLapCounter := 0
					this.iFinished := false
					this.iInPit := false

					if this.RaceAssistant
						this.finishSession()

					return
				}

				if ((dataLastLap < this.LastLap) || (this.iLastSession != sessionState)) {
					; Start of new session without finishing previous session first

					wasFinished := (this.iLastSession == kSessionFinished)

					this.iLastSession := sessionState
					this.iLastLap := 0
					this.iUpdateLapCounter := 0
					this.iFinished := false
					this.iInPit := false

					if !wasFinished {
						this.updateSessionState(kSessionFinished)

						if this.RaceAssistant {
							this.finishSession()

							return
						}
					}
				}

				if this.RaceAssistantEnabled {
					; Car is on the track

					if !this.RaceAssistant
						this.startupRaceAssistant()

					if getConfigurationValue(data, "Stint Data", "InPit", false) {
						; Car is in the Pit

						if !this.InPit {
							this.performPitstop(dataLastLap)

							this.iInPit := dataLastLap
						}
					}
					else if (dataLastLap == 0) {
						; Waiting for the car to cross the start line for the first time

						if (this.iUpdateLapCounter = 0) {
							dataFile := kTempDirectory . this.Plugin . " Lap 0.0.data"

							writeConfiguration(dataFile, data)

							settings := this.prepareSettings(data)
							settingsFile := (kTempDirectory . this.Plugin . ".settings")

							writeConfiguration(settingsFile, settings)

							this.prepareSession(settingsFile, dataFile)
						}

						this.iUpdateLapCounter := this.iUpdateLapCounter + 1
					}
					else if (dataLastLap > 0) {
						; Car has finished the first lap

						if (dataLastLap > 1) {
							if (this.LastLap == 0) {
								; Missed the start of the session, might be a team session

								teamSessionActive := this.connectTeamSession()

								if (!teamSessionActive || !this.TeamServer.Connected)
									return ; No Team Server, no late join

								if !this.driverActive(data) {
									logMessage(kLogWarn, translate("Cannot join team session. Driver names in team session and in simulation do not match."))

									return ; Still a different driver, might happen in some simulations
								}

								this.iInPit := false

								joinedSession := true
							}
							else if (this.LastLap < (dataLastLap - 1)) {
								; Regained the car after a driver swap, new stint

								if !this.driverActive(data) {
									logMessage(kLogWarn, translate("Cannot join team session. Driver names in team session and in simulation do not match."))

									return ; Still a different driver, might happen in some simulations
								}

								this.TeamServer.addStint(dataLastLap)

								this.iInPit := false

								this.restoreSessionState()
							}
							else ; (this.LastLap == (dataLastLap - 1))
								if !this.driverActive(data)
									return ; Oops, a different driver, might happen in some simulations after a pitstop
						}

						newLap := (dataLastLap > this.LastLap)
						firstLap := ((dataLastLap == 1) && newLap)

						if this.InPit {
							this.iInPit := false

							; Was in the pits, check if same driver for next stint...

							if (this.TeamSessionActive && this.driverActive(data))
								this.TeamServer.addStint(dataLastLap)
						}

						if newLap {
							if this.iFinished {
								this.iLastSession := kSessionFinished
								this.iLastLap := 0
								this.iUpdateLapCounter := 0
								this.iFinished := false
								this.iInPit := false

								if this.RaceAssistant
									this.finishSession()

								return
							}

							this.iLastLap := dataLastLap
							this.iUpdateLapCounter := 0

							if !firstLap
								this.iFinished := (getConfigurationValue(data, "Session Data", "SessionTimeRemaining", 0) == 0)
						}

						if firstLap {
							if this.connectTeamSession()
								if this.driverActive(data) {
									teamServer := this.TeamServer

									teamServer.joinSession(getConfigurationValue(data, "Session Data", "Simulator")
														 , getConfigurationValue(data, "Session Data", "Car")
														 , getConfigurationValue(data, "Session Data", "Track")
														 , dataLastLap
														 , Round((getConfigurationValue(data, "Session Data", "SessionTimeRemaining", 0) / 1000) / 60))

									this.TeamServer.setSessionValue(this.Plugin . " Settings", "")
									this.TeamServer.setSessionValue(this.Plugin . " State", "")
								}
								else {
									; Wrong Driver - no team session

									this.disconnectTeamSession()

									logMessage(kLogWarn, translate("Cannot join the team session. Driver names in team session and in simulation do not match."))
								}

							this.startSession(this.prepareSettings(data), data, this.TeamSessionActive)
						}
						else if joinedSession {
							this.TeamServer.joinSession(getConfigurationValue(data, "Session Data", "Simulator")
													  , getConfigurationValue(data, "Session Data", "Car")
													  , getConfigurationValue(data, "Session Data", "Track")
													  , dataLastLap)

							this.startSession(this.prepareSettings(data), data, this.TeamSessionActive)

							this.restoreSessionState()
						}

						this.iUpdateLapCounter := this.iUpdateLapCounter + 1

						dataFile := kTempDirectory . code . " Data\" . this.Plugin . " Lap " . this.LastLap . "." . this.iUpdateLapCounter . ".data"

						writeConfiguration(dataFile, data)

						if newLap
							this.addLap(dataLastLap, dataFile, telemetryData, positionsData)
						else
							this.updateLap(dataLastLap, dataFile)
					}
				}
				else {
					this.iLastSession := kSessionFinished
					this.iLastLap := 0
					this.iUpdateLapCounter := 0
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

			this.iLastSession := kSessionFinished
			this.iLastLap := 0
			this.iUpdateLapCounter := 0
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
	local exePath := kBinariesDirectory . simulator . A_Space . protocol . " Provider.exe"
	local postfix, dataFile, data

	Random postfix, 1, 1000000

	FileCreateDir %kTempDirectory%%simulator% Data

	dataFile := (kTempDirectory . simulator . " Data\" . protocol . "_" . Round(postfix) . ".data")

	try {
		RunWait %ComSpec% /c ""%exePath%" %options% > "%dataFile%"", , Hide
	}
	catch exception {
		logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider (")
												   , {simulator: simulator, protocol: protocol})
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

findActivePlugin(plugin := false) {
	local controller := SimulatorController.Instance

	if (!plugin || !controller.isActive(plugin))
		plugin := controller.findPlugin(kRaceEngineerPlugin)

	if (!plugin || !controller.isActive(plugin))
		plugin := controller.findPlugin(kRaceStrategistPlugin)

	if (!plugin || !controller.isActive(plugin))
		plugin := controller.findPlugin(kRaceSpotterPlugin)

	return plugin
}

prepareSessionDatabase(data) {
	local plugin := findActivePlugin()
	local sessionDB, simulator, car, track

	if (plugin  && plugin.Simulator) {
		sessionDB := new SessionDatabase()

		simulator := plugin.Simulator.runningSimulator()
		car := getConfigurationValue(data, "Session Data", "Car", kUndefined)
		track := getConfigurationValue(data, "Session Data", "Track", kUndefined)

		if ((car != kUndefined) && (track != kUndefined))
			sessionDB.prepareDatabase(simulator, car, track, data)

		sessionDB.registerDriver(simulator, plugin.Controller.ID
							   , computeDriverName(getConfigurationValue(data, "Stint Data", "DriverForname")
												 , getConfigurationValue(data, "Stint Data", "DriverSurname")
												 , getConfigurationValue(data, "Stint Data", "DriverNickname")))
	}
}

getSimulatorOptions(plugin := false) {
	local options := ""
	local data

	plugin := findActivePlugin(plugin)

	if (plugin && plugin.Simulator) {
		data := readSimulatorData(plugin.Simulator.Code)

		if getConfigurationValue(data, "Session Data", "Active", false) {
			options := "-Simulator """ . new SessionDatabase().getSimulatorName(plugin.Simulator.runningSimulator()) . """"
			options .= " -Car """ . getConfigurationValue(data, "Session Data", "Car", "Unknown") . """"
			options .= " -Track """ . getConfigurationValue(data, "Session Data", "Track", "Unknown") . """"
			options .= " -Weather " . getConfigurationValue(data, "Weather Data", "Weather", "Dry")
			options .= " -AirTemperature " . Round(getConfigurationValue(data, "Weather Data", "Temperature", "23"))
			options .= " -TrackTemperature " . Round(getConfigurationValue(data, "Track Data", "Temperature", "27"))
			options .= " -Compound " . getConfigurationValue(data, "Car Data", "TyreCompound", "Dry")
			options .= " -CompoundColor " . getConfigurationValue(data, "Car Data", "TyreCompoundColor", "Dry")
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
	local exePath := kBinariesDirectory . "Race Settings.exe"
	local controller := SimulatorController.Instance
	local pid, ignore, options

	plugin := findActivePlugin(plugin)

	if !fileName
		fileName := kUserConfigDirectory . "Race.settings"

	try {
		if import {
			options := "-File """ . fileName . """ -Import"

			if (plugin && plugin.Simulator)
				options := (options . " """ . controller.ActiveSimulator . """ " . plugin.Simulator.Code)

			if silent
				options .= " -Silent"

			RunWait "%exePath%" %options%, %kBinariesDirectory%
		}
		else {
			options := "-File """ . fileName . """ " . getSimulatorOptions(plugin)

			Run "%exePath%" %options%, %kBinariesDirectory%, , pid

			if pid
				for ignore, plugin in [kRaceEngineerPlugin, kRaceStrategistPlugin, kRaceSpotterPlugin] {
					plugin := controller.findPlugin(plugin)

					if (plugin && controller.isActive(plugin))
						Task.startTask(ObjBindMethod(plugin, "reloadSettings", pid, fileName), 1000, kLowPriority)
				}
		}
	}
	catch exception {
		logMessage(kLogCritical, translate("Cannot start the Race Settings tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

		showMessage(substituteVariables(translate("Cannot start the Race Settings tool (%exePath%) - please check the configuration..."), {exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

openSessionDatabase(plugin := false) {
	local exePath := kBinariesDirectory . "Session Database.exe"
	local pid, options

	try {
		options := getSimulatorOptions(plugin)

		Run "%exePath%" %options%, %kBinariesDirectory%, , pid
	}
	catch exception {
		logMessage(kLogCritical, translate("Cannot start the Session Database tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

		showMessage(substituteVariables(translate("Cannot start the Session Database tool (%exePath%) - please check the configuration..."), {exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

openSetupAdvisor(plugin := false) {
	local exePath := kBinariesDirectory . "Setup Advisor.exe"
	local options

	try {
		options := getSimulatorOptions(plugin)

		Run "%exePath%" %options%, %kBinariesDirectory%
	}
	catch exception {
		logMessage(kLogCritical, translate("Cannot start the Setup Advisor tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

		showMessage(substituteVariables(translate("Cannot start the Setup Advisor tool (%exePath%) - please check the configuration..."), {exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

openStrategyWorkbench(plugin := false) {
	local exePath := kBinariesDirectory . "Strategy Workbench.exe"
	local options

	try {
		options := getSimulatorOptions(plugin)

		Run "%exePath%" %options%, %kBinariesDirectory%
	}
	catch exception {
		logMessage(kLogCritical, translate("Cannot start the Strategy Workbench tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

		showMessage(substituteVariables(translate("Cannot start the Strategy Workbench tool (%exePath%) - please check the configuration..."), {exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

openRaceCenter(plugin := false) {
	local exePath := kBinariesDirectory . "Race Center.exe"
	local options

	try {
		options := getSimulatorOptions(plugin)

		Run "%exePath%" %options%, %kBinariesDirectory%
	}
	catch exception {
		logMessage(kLogCritical, translate("Cannot start the Race Center tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

		showMessage(substituteVariables(translate("Cannot start the Race Center tool (%exePath%) - please check the configuration..."), {exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

enableRaceAssistant(name) {
	local controller := SimulatorController.Instance
	local plugin := controller.findPlugin(name)

	protectionOn()

	try {
		if (plugin && controller.isActive(plugin))
			plugin.enableRaceAssistant()
	}
	finally {
		protectionOff()
	}
}

disableRaceAssistant(name) {
	local controller := SimulatorController.Instance
	local plugin := controller.findPlugin(name)

	protectionOn()

	try {
		if (plugin && controller.isActive(plugin))
			plugin.disableRaceAssistant()
	}
	finally {
		protectionOff()
	}
}