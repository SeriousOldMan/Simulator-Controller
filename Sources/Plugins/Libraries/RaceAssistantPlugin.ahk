;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Assistant Plugin           ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Task.ahk
#Include ..\Libraries\Messages.ahk
#Include ..\Plugins\Libraries\SimulatorPlugin.ahk
#Include ..\Assistants\Libraries\SessionDatabase.ahk
#Include ..\Assistants\Libraries\SettingsDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceAssistantPlugin extends ControllerPlugin  {
	static sCollectorTask := false

	static sAssistants := []

	static sSession := 0 ; kSessionFinished
	static sLastLap := 0
	static sLapRunning := 0
	static sAssistantWaitForShutdown := 0
	static sTeamServerWaitForShutdown := 0
	static sInPit := false
	static sFinished := false

	static sTeamServer := false
	static sTeamSession := false
	static sTeamSessionActive := false

	static sSimulator := false

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

	iRaceAssistantActive := false

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

		updateSettings(arguments*) {
			this.callRemote("updateSettings", arguments*)
		}

		prepareSession(arguments*) {
			this.callRemote("prepareSession", arguments*)
		}

		startSession(arguments*) {
			this.callRemote("startSession", arguments*)
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

		mute(arguments*) {
			this.callRemote("mute", arguments*)
		}

		unmute(arguments*) {
			this.callRemote("unmute", arguments*)
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

			if ((action = "Accept") || (action = "Reject") || (action = "Call"))
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
					case "Mute":
						this.Plugin.mute()
					case "Unmute":
						this.Plugin.unmute()
					default:
						throw "Invalid action """ . this.Action . """ detected in RaceAssistantAction.fireAction...."
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

	class RestoreSessionStateTask extends PeriodicTask {
		iRaceAssistant := false
		iData := false
		iTries := 50

		RaceAssistant[] {
			Get {
				return this.iRaceAssistant
			}
		}

		Data[] {
			Get {
				return this.iData
			}
		}

		__New(raceAssistant, data) {
			this.iRaceAssistant := raceAssistant
			this.iData := data

			base.__New(false, 0, kHighPriority)
		}

		run() {
			local raceAssistant := this.RaceAssistant
			local teamServer := raceAssistant.TeamServer
			local sessionSettings := this.getData(teamServer, "Settings")
			local sessionState := this.getData(teamServer, "State")
			local stateLap, dataLap

			if (sessionSettings && sessionState) {
				stateLap := getConfigurationValue(sessionState, "Session State", "Lap", 0)
				dataLap := getConfigurationValue(this.Data, "Stint Data", "Laps", 0)

				if (Abs(dataLap - stateLap) <= 5) {
					if isDebug()
						showMessage("Restoring session state for " . raceAssistant.Plugin)

					raceAssistant.Simulator.restoreSessionState(sessionSettings, sessionState)

					raceAssistant.RaceAssistant.restoreSessionState(this.createDataFile(sessionSettings, "settings")
																  , this.createDataFile(sessionState, "state"))

					this.stop()

					return
				}
			}

			if (this.iTries-- > 0)
				this.Sleep := 1000
			else
				this.stop()
		}

		getData(teamServer, type) {
			local data

			try {
				data := teamServer.getSessionValue(this.RaceAssistant.Plugin . A_Space . type)

				if (!data || (data = ""))
					throw "No data..."
				else
					return parseConfiguration(data)
			}
			catch exception {
				return false
			}
		}

		createDataFile(data, extension) {
			local dataFile := temporaryFileName(this.RaceAssistant.Plugin, extension)

			data := printConfiguration(data)

			FileAppend %data%, %dataFile%, UTF-16

			return dataFile
		}
	}

	CollectorTask[] {
		Get {
			return RaceAssistantPlugin.sCollectorTask
		}
	}

	Assistants[key := false] {
		Get {
			return (key ? RaceAssistantPlugin.sAssistants[key] : RaceAssistantPlugin.sAssistants)
		}
	}

	Simulator[] {
		Get {
			return RaceAssistantPlugin.sSimulator
		}
	}

	WaitForShutdown[teamServer := false] {
		Get {
			return (A_TickCount < (teamServer ? RaceAssistantPlugin.sTeamServerWaitForShutdown
											  : RaceAssistantPlugin.sAssistantWaitForShutdown))
		}

		Set {
			if teamServer
				RaceAssistantPlugin.sTeamServerWaitForShutdown := (value ? (A_TickCount + 600000) : 0)
			else
				RaceAssistantPlugin.sAssistantWaitForShutdown := (value ? (A_TickCount + 90000) : 0)

			return value
		}
	}

	Finished[] {
		Get {
			return RaceAssistantPlugin.sFinished
		}
	}

	LastLap[] {
		Get {
			return RaceAssistantPlugin.sLastLap
		}
	}

	LapRunning[] {
		Get {
			return RaceAssistantPlugin.sLapRunning
		}
	}

	Session[] {
		Get {
			return RaceAssistantPlugin.sSession
		}
	}

	InPit[] {
		Get {
			return RaceAssistantPlugin.sInPit
		}
	}

	RaceAssistant[zombie := false] {
		Get {
			local wasZombie

			if (!this.iRaceAssistant && zombie) {
				if !this.WaitForShutdown {
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

	RaceAssistantActive[] {
		Get {
			return this.iRaceAssistantActive
		}

		Set {
			return (this.iRaceAssistantActive := value)
		}
	}

	TeamServer[] {
		Get {
			return RaceAssistantPlugin.sTeamServer
		}
	}

	TeamSession[] {
		Get {
			return RaceAssistantPlugin.sTeamSession
		}
	}

	TeamSessionActive[] {
		Get {
			return RaceAssistantPlugin.sTeamSessionActive
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

	__New(controller, name, configuration := false, register := true) {
		local teamServer, raceAssistantToggle, teamServerToggle, arguments, ignore, theAction
		local openRaceSettings, openSessionDatabase, openSetupAdvisor, openRaceCenter, openStrategyWorkbench, importSetup
		local assistantSpeaker, assistantListener, first

		base.__New(controller, name, configuration, register)

		if (this.Active || isDebug()) {
			first := (RaceAssistantPlugin.Assistants.Length() = 0)

			RaceAssistantPlugin.Assistants.Push(this)

			if first {
				teamServer := this.Controller.findPlugin(kTeamServerPlugin)

				if (teamServer && this.Controller.isActive(teamServer))
					RaceAssistantPlugin.sTeamServer := teamServer
				else
					teamServer := false
			}
			else
				teamServer := RaceAssistantPlugin.TeamServer

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

			if first {
				RaceAssistantPlugin.sCollectorTask
					:= new PeriodicTask(ObjBindMethod(RaceAssistantPlugin, "collectSessionData"), 1000, kHighPriority)

				RaceAssistantPlugin.CollectorTask.start()
			}
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
			else if inList(["Call", "Accept", "Reject", "Mute", "Unmute"], action) {
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

	writePluginState(configuration) {
		local session, information

		if this.Active {
			if this.RaceAssistantEnabled {
				if (this.RaceAssistant && !this.RaceAssistantActive) {
					setConfigurationValue(configuration, "Race Assistants", this.Plugin, "Waiting")

					setConfigurationValue(configuration, this.Plugin, "State", "Active")

					setConfigurationValue(configuration, this.Plugin, "Information"
										, values2String("; ", translate("Started: ") . translate("Yes")
															, translate("Session: ") . translate("Waiting...")))
				}
				else if this.RaceAssistantActive {
					setConfigurationValue(configuration, "Race Assistants", this.Plugin, "Active")
					setConfigurationValue(configuration, "Race Assistants", "Mode", this.TeamSessionActive ? "Team" : "Solo")

					setConfigurationValue(configuration, this.Plugin, "State", "Active")

					switch this.Session {
						case kSessionQualification:
							session := "Qualification"
						case kSessionPractice:
							session := "Practice"
						case kSessionRace:
							session := "Race"
						default:
							session := "Unknown"
					}

					setConfigurationValue(configuration, "Race Assistants", "Session", session)

					information := values2String("; ", translate("Started: ") . translate(this.RaceAssistant ? "Yes" : "No")
													 , translate("Session: ") . translate(session)
													 , translate("Laps: ") . this.LastLap
													 , translate("Mode: ") . translate(this.TeamSessionActive ? "Team" : "Solo"))

					if !this.RaceAssistantSpeaker {
						information .= ("; " . translate("Muted: ") . translate("Yes"))

						setConfigurationValue(configuration, this.Plugin, "Muted", true)
					}

					setConfigurationValue(configuration, this.Plugin, "Information", information)
				}
				else {
					setConfigurationValue(configuration, "Assistants", this.Plugin, "Passive")

					if this.WaitForShutdown {
						setConfigurationValue(configuration, this.Plugin, "State", "Warning")

						setConfigurationValue(configuration, this.Plugin, "Information", translate("Message: ") . translate("Waiting for shutdown..."))
					}
					else
						setConfigurationValue(configuration, this.Plugin, "State", "Passive")
				}
			}
			else
				setConfigurationValue(configuration, this.Plugin, "State", "Disabled")
		}
		else
			base.writePluginState(configuration)
	}

	startSimulation(simulator) {
		if (RaceAssistantPlugin.Simulator && (RaceAssistantPlugin.Simulator != simulator))
			RaceAssistantPlugin.stopSimulation(RaceAssistantPlugin.Simulator)

		RaceAssistantPlugin.sSimulator := simulator
	}

	stopSimulation(simulator) {
		if (RaceAssistantPlugin.Simulator == simulator)
			RaceAssistantPlugin.sSimulator := false
	}

	connectTeamSession() {
		local teamServer := RaceAssistantPlugin.TeamServer
		local settings, sessionIdentifier, serverURL, accessToken, teamIdentifier, driverIdentifier

		RaceAssistantPlugin.sTeamSessionActive := false

		if (teamServer && teamServer.TeamServerEnabled && !RaceAssistantPlugin.WaitForShutdown[true]) {
			settings := readConfiguration(getFileName("Race.settings", kUserConfigDirectory))
			sessionIdentifier := getConfigurationValue(settings, "Team Settings", "Session.Identifier", false)

			if !teamServer.Connected {
				serverURL := getConfigurationValue(settings, "Team Settings", "Server.URL", "")
				accessToken := getConfigurationValue(settings, "Team Settings", "Server.Token", "")

				teamIdentifier := getConfigurationValue(settings, "Team Settings", "Team.Identifier", false)
				driverIdentifier := getConfigurationValue(settings, "Team Settings", "Driver.Identifier", false)

				RaceAssistantPlugin.sTeamSessionActive
					:= teamServer.connect(serverURL, accessToken, teamIdentifier, driverIdentifier, sessionIdentifier)
			}
			else
				RaceAssistantPlugin.sTeamSessionActive := true

			RaceAssistantPlugin.sTeamSession := (RaceAssistantPlugin.TeamSessionActive ? sessionIdentifier : false)
		}
		else
			RaceAssistantPlugin.sTeamSession := false

		return RaceAssistantPlugin.TeamSessionActive
	}

	disconnectTeamSession() {
		local teamServer := RaceAssistantPlugin.TeamServer

		RaceAssistantPlugin.sTeamSessionActive := false

		if (teamServer && teamServer.TeamServerEnabled)
			teamServer.disconnect()
	}

	initializeAssistantsState() {
		RaceAssistantPlugin.sSession := kSessionFinished
		RaceAssistantPlugin.sLastLap := 0
		RaceAssistantPlugin.sLapRunning := 0
		RaceAssistantPlugin.sInPit := false
		RaceAssistantPlugin.sFinished := false
	}

	requireAssistants() {
		local activeAssistant := false
		local ignore, assistant

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if assistant.requireRaceAssistant()
				activeAssistant := true

		if activeAssistant
			Sleep 1500

		RaceAssistantPlugin.CollectorTask.Priority := kLowPriority
		RaceAssistantPlugin.CollectorTask.Sleep := 10000

		return activeAssistant
	}

	prepareAssistantsSession(data) {
		local ignore, assistant

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if assistant.requireRaceAssistant()
				assistant.prepareSession(assistant.prepareSettings(data), data)
	}

	startAssistantsSession(data) {
		local lap := getConfigurationValue(data, "Stint Data", "Laps", false)
		local start := ((lap = 1) || RaceAssistantPlugin.TeamSessionActive)
		local first := true
		local ignore, assistant, settings

		if RaceAssistantPlugin.Simulator {
			RaceAssistantPlugin.sSession := RaceAssistantPlugin.getSession(data)
			RaceAssistantPlugin.sFinished := false

			for ignore, assistant in RaceAssistantPlugin.Assistants
				if assistant.requireRaceAssistant() {
					settings := assistant.prepareSettings(data)

					if first {
						first := false

						RaceAssistantPlugin.Simulator.startSession(settings, data)
					}

					if start
						assistant.startSession(settings, data)
					else
						assistant.joinSession(settings, data)
				}

			if first
				RaceAssistantPlugin.Simulator.startSession(settings, data)
		}
	}

	finishAssistantsSession(shutdownAssistant := true, shutdownTeamSession := true) {
		local session := this.Session
		local ignore, assistant

		RaceAssistantPlugin.initializeAssistantsState()

		if shutdownAssistant
			for ignore, assistant in RaceAssistantPlugin.Assistants
				if (assistant.RaceAssistantEnabled && assistant.RaceAssistant) {
					RaceAssistantPlugin.WaitForShutdown := true

					break
				}

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if (assistant.RaceAssistantEnabled && assistant.RaceAssistant)
				assistant.finishSession(shutdownAssistant)

		if (shutdownTeamSession && RaceAssistantPlugin.TeamSessionActive) {
			RaceAssistantPlugin.TeamServer.leaveSession()

			RaceAssistantPlugin.disconnectTeamSession()

			if (session == kSessionRace)
				RaceAssistantPlugin.WaitForShutdown[true] := true
		}

		RaceAssistantPlugin.Simulator.finishSession()

		RaceAssistantPlugin.updateAssistantsSession(kSessionFinished)

		if RaceAssistantPlugin.CollectorTask {
			RaceAssistantPlugin.CollectorTask.Priority := kHighPriority
			RaceAssistantPlugin.CollectorTask.Sleep := 1000
		}
	}

	addAssistantsLap(data, telemetryData, positionsData) {
		local ignore, assistant

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if (assistant.requireRaceAssistant() && assistant.RaceAssistantActive)
				assistant.addLap(RaceAssistantPlugin.LastLap, RaceAssistantPlugin.LapRunning, data)

		if RaceAssistantPlugin.TeamSessionActive
			RaceAssistantPlugin.TeamServer.addLap(RaceAssistantPlugin.LastLap, telemetryData, positionsData)
	}

	updateAssistantsLap(data) {
		local ignore, assistant

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if (assistant.requireRaceAssistant() && assistant.RaceAssistantActive)
				assistant.updateLap(RaceAssistantPlugin.LastLap, RaceAssistantPlugin.LapRunning, data)
	}

	performAssistantsPitstop(lapNumber) {
		local ignore, assistant

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if (assistant.requireRaceAssistant() && assistant.RaceAssistantActive)
				assistant.performPitstop(lapNumber)
	}

	restoreAssistantsSessionState(data) {
		local ignore, assistant

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if (assistant.requireRaceAssistant() && assistant.RaceAssistantActive)
				assistant.restoreSessionState(data)
	}

	updateAssistantsSession(session := "__Undefined__") {
		local ignore, assistant

		if (session == kUndefined)
			session := RaceAssistantPlugin.getSession()

		if RaceAssistantPlugin.Simulator
			RaceAssistantPlugin.Simulator.updateSession(session)
		else
			session := kSessionFinished

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if assistant.Active
				assistant.updateSession(session)
	}

	updateAssistantsTelemetryData(data) {
		local simulator, car, track, maxFuel, compound, compoundColor
		local ignore, assistant

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
			compound := new SessionDatabase().getTyreCompoundName(simulator, car, track, compound, kUndefined)

			if (compound = kUndefined)
				compound := normalizeCompound("Dry")

			compoundColor := false

			splitCompound(compound, compound, compoundColor)

			setConfigurationValue(data, "Car Data", "TyreCompound", compound)
			setConfigurationValue(data, "Car Data", "TyreCompoundColor", compoundColor)
		}

		RaceAssistantPlugin.Simulator.updateTelemetryData(data)

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if assistant.RaceAssistantEnabled
				assistant.updateTelemetryData(data)
	}

	updateAssistantsPositionsData(data) {
		local ignore, assistant

		RaceAssistantPlugin.Simulator.updatePositionsData(data)

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if assistant.RaceAssistantEnabled
				assistant.updatePositionsData(data)
	}

	activate() {
		base.activate()

		this.updateActions(kSessionFinished)
	}

	updateActions(session) {
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
				if (((theAction.Action = "Accept") || (theAction.Action = "Reject") || (theAction.Action = "Call"))
				 && (this.RaceAssistant[true] != false)) {
					theAction.Function.enable(kAllTrigger, theAction)
					theAction.Function.setLabel(theAction.Label)
				}
				else if this.RaceAssistantActive {
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
		local ignore, assistant

		if (this.RaceAssistantEnabled || force) {
			label := translate(this.Plugin)

			trayMessage(label, translate("State: Off"))

			this.iRaceAssistantEnabled := false

			if this.RaceAssistant
				this.finishSession()

			this.updateTrayLabel(label, false)

			for ignore, assistant in RaceAssistantPlugin.Assistants
				if assistant.RaceAssistantEnabled
					return

			RaceAssistantPlugin.finishAssistantsSession()
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

	requireRaceAssistant() {
		local pid, options, exePath

		if this.RaceAssistantEnabled {
			if !this.RaceAssistant {
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

					this.RaceAssistant := this.createRaceAssistant(pid)
				}
				catch exception {
					logMessage(kLogCritical, translate("Cannot start " . this.Plugin . " (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

					showMessage(substituteVariables(translate("Cannot start " . this.Plugin . " (%kBinariesDirectory%Race Assistant.exe) - please rebuild the applications..."))
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

					return false
				}
			}

			return true
		}
		else
			return false
	}

	shutdownRaceAssistant() {
		local raceAssistant := this.RaceAssistant

		if raceAssistant {
			this.RaceAssistant := false

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
			this.RaceAssistant.updateSettings(settingsFileName)

		return false
	}

	prepareSession(settings, data) {
		local dataFile, settingsFile

		if this.RaceAssistant {
			dataFile := kTempDirectory . this.Plugin . " Lap 0.0.data"

			writeConfiguration(dataFile, data)

			settingsFile := (kTempDirectory . this.Plugin . ".settings")

			writeConfiguration(settingsFile, settings)

			this.RaceAssistant.prepareSession(settingsFile, dataFile)
		}
	}

	startSession(settings, data) {
		local code, assistant, settingsFile, dataFile

		if this.Simulator {
			code := this.Simulator.Code
			assistant := this.Plugin

			FileCreateDir %kTempDirectory%%code% Data

			loop Files, %kTempDirectory%%code% Data\%assistant%*.*
				deleteFile(A_LoopFilePath)

			if this.RaceAssistant
				this.finishSession(false)
			else
				this.requireRaceAssistant()

			if this.RaceAssistant {
				settingsFile := (kTempDirectory . this.Plugin . ".settings")
				dataFile := (kTempDirectory . this.Plugin . ".data")

				writeConfiguration(settingsFile, settings)
				writeConfiguration(dataFile, data)

				this.RaceAssistant.startSession(settingsFile, dataFile)

				this.RaceAssistantActive := true
			}
		}
	}

	joinSession(settings, data) {
	}

	finishSession(shutdownAssistant := true) {
		if this.RaceAssistant {
			this.RaceAssistant.finishSession(shutdownAssistant)

			 this.RaceAssistantActive := false

			if shutdownAssistant
				this.shutdownRaceAssistant()
		}
	}

	addLap(lap, update, data) {
		local dataFile

		if this.RaceAssistant {
			dataFile := (kTempDirectory . this.Simulator.Code . " Data\" . this.Plugin . " Lap " . lap . "." . update . ".data")

			writeConfiguration(dataFile, data)

			this.RaceAssistant.addLap(lap, dataFile)
		}
	}

	updateLap(lap, update, data) {
		local dataFile

		if this.RaceAssistant {
			dataFile := (kTempDirectory . this.Simulator.Code . " Data\" . this.Plugin . " Lap " . lap . "." . update . ".data")

			writeConfiguration(dataFile, data)

			this.RaceAssistant.updateLap(lap, dataFile)
		}
	}

	performPitstop(lapNumber) {
		if this.RaceAssistant
			this.RaceAssistant.performPitstop(lapNumber)
	}

	supportsSetupImport() {
		return (this.Simulator ? this.Simulator.supportsSetupImport() : false)
	}

	requestInformation(arguments*) {
		throw "Virtual method RaceAssistantPlugin.requestInformation must be implemented in a subclass..."
	}

	call() {
		if this.RaceAssistant[true]
			this.RaceAssistant[true].call()
	}

	accept() {
		if this.RaceAssistant[true]
			this.RaceAssistant[true].accept()
	}

	reject() {
		if this.RaceAssistant[true]
			this.RaceAssistant[true].reject()
	}

	mute() {
		if this.RaceAssistant
			this.RaceAssistant.mute()
	}

	unmute() {
		if this.RaceAssistant
			this.RaceAssistant.unmute()
	}

	getSession(data := false) {
		local ignore

		if RaceAssistantPlugin.Simulator {
			if !data
				data := readSimulatorData(RaceAssistantPlugin.Simulator.Code)

			return getDataSession(data, ignore)
		}
		else
			return kSessionFinished
	}

	updateTelemetryData(data) {
	}

	updatePositionsData(data) {
	}

	runningSession(data) {
		return getConfigurationValue(data, "Session Data", "Active", false)
	}

	activeSession(data) {
		local ignore

		return (getDataSession(data, ignore) >= kSessionPractice)
	}

	updateSession(session) {
		this.updateActions(session)
	}

	callSaveSessionState(settingsFile, stateFile) {
		local sessionSettings, sessionState

		if settingsFile {
			sessionSettings := readConfiguration(settingsFile)

			deleteFile(settingsFile)
		}
		else
			sessionSettings := false

		if stateFile {
			sessionState := readConfiguration(stateFile)

			deleteFile(stateFile)
		}
		else
			sessionState := false

		this.saveSessionState(sessionSettings, sessionState)
	}

	saveSessionState(settings, state) {
		local teamServer := this.TeamServer

		this.Simulator.saveSessionState(settings, state)

		if (teamServer && this.TeamSessionActive) {
			if isDebug()
				showMessage("Saving session state for " . this.Plugin)

			if settings
				teamServer.setSessionValue(this.Plugin . " Settings", printConfiguration(settings))

			if state
				teamServer.setSessionValue(this.Plugin . " State", printConfiguration(state))
		}
	}

	restoreSessionState(data) {
		if (this.RaceAssistant && this.TeamSessionActive)
			new this.RestoreSessionStateTask(this, data).start()
	}

	driverActive(data) {
		local teamServer := RaceAssistantPlugin.TeamServer

		if RaceAssistantPlugin.TeamSessionActive
			return ((getConfigurationValue(data, "Stint Data", "DriverForname") = teamServer.DriverForName)
				 && (getConfigurationValue(data, "Stint Data", "DriverSurname") = teamServer.DriverSurName))
		else
			return true
	}

	currentLap(data) {
		if (this.Session == kSessionRace)
			loop % getConfigurationValue(data, "Position Data", "Car.Count")
				if (getConfigurationValue(data, "Position Data", "Car." . A_Index . ".Position") = 1)
					return getConfigurationValue(data, "Position Data", "Car." . A_Index . ".Lap")

		return getConfigurationValue(data, "Stint Data", "Laps", 0)
	}

	collectSessionData() {
		local finished := false
		local joinedSession := false
		local teamSessionActive := false
		local telemetryData, positionsData, data, dataLastLap
		local testData, message, key, value, session, teamServer
		local newLap, firstLap, ignore, assistant, hasAssistant
		local sessionTimeRemaining, sessionLapsRemaining

		if (RaceAssistantPlugin.Finished = "Finished")
			RaceAssistantPlugin.finishAssistantsSession()

		if RaceAssistantPlugin.WaitForShutdown
			return
		else {
			hasAssistant := false

			for ignore, assistant in RaceAssistantPlugin.Assistants {
				assistant.RaceAssistant[true]

				hasAssistant := (hasAssistant || (assistant.RaceAssistant != false))
			}

			if (!hasAssistant && (this.Session == kSessionFinished))
				RaceAssistantPlugin.initializeAssistantsState()
		}

		if RaceAssistantPlugin.Simulator {
			telemetryData := true
			positionsData := true

			data := RaceAssistantPlugin.Simulator.acquireSessionData(telemetryData, positionsData)

			dataLastLap := getConfigurationValue(data, "Stint Data", "Laps", 0)

			if (RaceAssistantPlugin.runningSession(data) && (RaceAssistantPlugin.LastLap == 0))
				prepareSessionDatabase(data)

			if false && isDebug() {
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
				session := getDataSession(data, finished)

				if (finished && (this.Session == kSessionRace)) {
					session := kSessionRace

					setConfigurationValue(data, "Session Data", "Session", "Race")

					if (getConfigurationValue(data, "Session Data", "SessionFormat") = "Time") {
						if !RaceAssistantPlugin.Finished
							RaceAssistantPlugin.sFinished := (this.currentLap(data) + 1)

						finished := false
					}
				}

				RaceAssistantPlugin.updateAssistantsSession(session)

				if (session == kSessionPaused) {
					RaceAssistantPlugin.sInPit := false

					return
				}

				if !RaceAssistantPlugin.activeSession(data) {
					; Not in a supported session

					RaceAssistantPlugin.finishAssistantsSession()

					return
				}

				if ((dataLastLap < RaceAssistantPlugin.LastLap) || (RaceAssistantPlugin.Session != session)) {
					; Start of new session without finishing previous session first

					if (RaceAssistantPlugin.Session != kSessionFinished) {
						RaceAssistantPlugin.finishAssistantsSession()

						return
					}
				}

				if RaceAssistantPlugin.requireAssistants() {
					; Car is on the track

					if getConfigurationValue(data, "Stint Data", "InPit", false) {
						; Car is in the Pit

						if !RaceAssistantPlugin.InPit {
							RaceAssistantPlugin.performAssistantsPitstop(dataLastLap)

							RaceAssistantPlugin.sInPit := dataLastLap
						}
					}
					else if (dataLastLap == 0) {
						; Waiting for the car to cross the start line for the first time

						RaceAssistantPlugin.WaitForShutdown[true] := false

						if (RaceAssistantPlugin.LapRunning = 0)
							RaceAssistantPlugin.prepareAssistantsSession(data)

						RaceAssistantPlugin.sLapRunning := RaceAssistantPlugin.LapRunning + 1
					}
					else if (dataLastLap > 0) {
						; Car has finished the first lap

						if (dataLastLap > 1) {
							if (RaceAssistantPlugin.LastLap == 0) {
								; Missed the start of the session, might be a team session

								teamSessionActive := RaceAssistantPlugin.connectTeamSession()

								if (teamSessionActive && RaceAssistantPlugin.TeamServer.Connected) {
									if !RaceAssistantPlugin.driverActive(data) {
										RaceAssistantPlugin.TeamServer.State["Driver"] := "Mismatch"

										logMessage(kLogWarn, translate("Cannot join team session. Driver names in team session and in simulation do not match."))

										return ; Still a different driver, might happen in some simulations
									}
								}

								RaceAssistantPlugin.sInPit := false

								joinedSession := true
							}
							else if (RaceAssistantPlugin.LastLap < (dataLastLap - 1)) {
								; Regained the car after a driver swap, new stint

								if !RaceAssistantPlugin.driverActive(data) {
									RaceAssistantPlugin.TeamServer.State["Driver"] := "Mismatch"

									logMessage(kLogWarn, translate("Cannot join team session. Driver names in team session and in simulation do not match."))

									return ; Still a different driver, might happen in some simulations
								}

								RaceAssistantPlugin.TeamServer.addStint(dataLastLap)

								RaceAssistantPlugin.sInPit := false

								RaceAssistantPlugin.restoreAssistantsSessionState(data)
							}
							else ; (this.LastLap == (dataLastLap - 1))
								if !RaceAssistantPlugin.driverActive(data)
									return ; Oops, a different driver, might happen in some simulations after a pitstop
						}

						newLap := (dataLastLap > RaceAssistantPlugin.LastLap)
						firstLap := ((dataLastLap == 1) && newLap)

						if RaceAssistantPlugin.InPit {
							RaceAssistantPlugin.sInPit := false

							; Was in the pits, check if same driver for next stint...

							if (RaceAssistantPlugin.TeamSessionActive && RaceAssistantPlugin.driverActive(data))
								RaceAssistantPlugin.TeamServer.addStint(dataLastLap)
						}

						if newLap {
							RaceAssistantPlugin.sLastLap := dataLastLap
							RaceAssistantPlugin.sLapRunning := 0

							if RaceAssistantPlugin.Finished {
								if (this.currentLap(data) >= RaceAssistantPlugin.Finished) {
									; Session has endedd

									finished := true
								}
							}
							else {
								sessionTimeRemaining := getConfigurationValue(data, "Session Data", "SessionTimeRemaining", 0)
								sessionLapsRemaining := getConfigurationValue(data, "Session Data", "SessionLapsRemaining", 0)

								if (getConfigurationValue(data, "Session Data", "SessionFormat") = "Time") {
									if (sessionTimeRemaining <= 0)
										RaceAssistantPlugin.sFinished := (this.currentLap(data) + 1)
									else if (sessionLapsRemaining < 1)
										RaceAssistantPlugin.sFinished := (this.currentLap(data) + 2)
								}
								else if (sessionLapsRemaining == 0)
									RaceAssistantPlugin.sFinished := dataLastLap
							}
						}

						if firstLap {
							if RaceAssistantPlugin.connectTeamSession()
								if RaceAssistantPlugin.driverActive(data) {
									teamServer := RaceAssistantPlugin.TeamServer

									teamServer.joinSession(getConfigurationValue(data, "Session Data", "Simulator")
														 , getConfigurationValue(data, "Session Data", "Car")
														 , getConfigurationValue(data, "Session Data", "Track")
														 , dataLastLap
														 , Round((getConfigurationValue(data, "Session Data", "SessionTimeRemaining", 0) / 1000) / 60))

									for ignore, assistant in RaceAssistantPlugin.Assistants
										if assistant.RaceAssistantEnabled {
											teamServer.setSessionValue(assistant.Plugin . " Settings", "")
											teamServer.setSessionValue(assistant.Plugin . " State", "")
										}
								}
								else {
									; Wrong Driver - no team session

									RaceAssistantPlugin.TeamServer.State["Driver"] := "Mismatch"

									RaceAssistantPlugin.disconnectTeamSession()

									logMessage(kLogWarn, translate("Cannot join the team session. Driver names in team session and in simulation do not match."))
								}

							RaceAssistantPlugin.startAssistantsSession(data)
						}
						else if joinedSession {
							if RaceAssistantPlugin.TeamSessionActive {
								RaceAssistantPlugin.TeamServer.joinSession(getConfigurationValue(data, "Session Data", "Simulator")
																		 , getConfigurationValue(data, "Session Data", "Car")
																		 , getConfigurationValue(data, "Session Data", "Track")
																		 , dataLastLap)

								RaceAssistantPlugin.startAssistantsSession(data)

								RaceAssistantPlugin.restoreAssistantsSessionState(data)
							}
							else
								RaceAssistantPlugin.startAssistantsSession(data)
						}

						RaceAssistantPlugin.sLapRunning := RaceAssistantPlugin.LapRunning + 1

						if newLap
							RaceAssistantPlugin.addAssistantsLap(data, telemetryData, positionsData)
						else
							RaceAssistantPlugin.updateAssistantsLap(data)
					}
				}

				if finished
					RaceAssistantPlugin.sFinished := "Finished"
			}
			finally {
				protectionOff()
			}
		}
		else if (RaceAssistantPlugin.Session != kSessionFinished)
			RaceAssistantPlugin.finishAssistantsSession()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

getDataSession(data, ByRef finished) {
	local driver

	if getConfigurationValue(data, "Session Data", "Active", false) {
		finished := false

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
				case "Finished":
					finished := true

					return kSessionFinished
				default:
					return kSessionOther
			}
	}
	else {
		finished := true

		return kSessionFinished
	}
}

findActivePlugin(plugin := false) {
	local controller := SimulatorController.Instance

	if (!plugin || !controller.isActive(plugin))
		if (RaceAssistantPlugin.Assistants.Length() > 0)
			return RaceAssistantPlugin.Assistants[1]

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
			options .= " -CompoundColor " . getConfigurationValue(data, "Car Data", "TyreCompoundColor", "Black")
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
				for ignore, plugin in RaceAssistantPlugin.Assistants {
					if (plugin && controller.isActive(plugin) && plugin.RaceAssistantEnabled)
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