﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Assistant Plugin           ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Extensions\Task.ahk"
#Include "..\..\Framework\Extensions\Messages.ahk"
#Include "SimulatorPlugin.ahk"
#Include "..\..\Database\Libraries\SessionDatabase.ahk"
#Include "..\..\Database\Libraries\SettingsDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceAssistantPlugin extends ControllerPlugin {
	static sAssistantCooldown := kUndefined
	static sTeamServerCooldown := kUndefined

	static sCollectorTask := false
	static sReplayDirectory := false

	static sAssistants := []

	static sSession := 0 ; kSessionFinished
	static sStintStartTime := false
	static sLastLap := 0
	static sLapRunning := 0
	static sAssistantWaitForShutdown := 0
	static sTeamServerWaitForShutdown := 0
	static sInPit := false
	static sFinish := false
	static sSettings := CaseInsenseMap()

	static sTeamServer := kUndefined
	static sTeamSession := false
	static sTeamSessionActive := false

	static sSimulator := false

	static sCollectData := CaseInsenseMap()

	iEnabled := false
	iName := false
	iLogo := false
	iLanguage := false
	iSynthesizer := false
	iSpeaker := false
	iSpeakerVocalics := false
	iSpeakerBooster := false
	iRecognizer := false
	iListener := false
	iListenerBooster := false
	iConversationBooster := false
	iAgentBooster := false
	iMuted := false

	iRaceAssistant := false
	iRaceAssistantZombie := false

	iRaceAssistantActive := false
	iRaceAssistantPrepared := false

	iNextSessionUpdate := false

	class RemoteRaceAssistant {
		iPlugin := false
		iRemoteEvent := false
		iRemotePID := false

		Plugin {
			Get {
				return this.iPlugin
			}
		}

		RemotePID {
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
			local pid := ProcessExist((this.Plugin.Plugin . ".exe"))

			if pid {
				if (pid != this.RemotePID)
					this.iRemotePID := pid
			}
			else
				return

			messageSend(kFileMessage, this.iRemoteEvent, function . ":" . values2String(";", arguments*), this.RemotePID)
		}

		shutdown(arguments*) {
			this.callRemote("shutdown", arguments*)
		}

		updateSettings(arguments*) {
			this.callRemote("callUpdateSettings", arguments*)
		}

		prepareSession(arguments*) {
			this.callRemote("callPrepareSession", arguments*)
		}

		startSession(arguments*) {
			this.callRemote("callStartSession", arguments*)
		}

		finishSession(arguments*) {
			this.callRemote("finishSession", arguments*)
		}

		addLap(arguments*) {
			this.callRemote("callAddLap", arguments*)
		}

		updateLap(arguments*) {
			this.callRemote("callUpdateLap", arguments*)
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

		interrupt(arguments*) {
			this.callRemote("interrupt", arguments*)
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

		Plugin {
			Get {
				return this.iPlugin
			}
		}

		Action {
			Get {
				return this.iAction
			}
		}

		Arguments {
			Get {
				return this.iArguments
			}
		}

		__New(plugin, function, label, icon, action, arguments*) {
			this.iPlugin := plugin
			this.iAction := action
			this.iArguments := arguments

			super.__New(function, label, icon)
		}

		fireAction(function, trigger) {
			local action := this.Action
			local enabled

			if ((action = "Accept") || (action = "Reject") || (action = "Call"))
				enabled := (this.Plugin.RaceAssistant[true] != false)
			else
				enabled := (this.Plugin.RaceAssistant != false)

			if enabled
				switch action, false {
					case "InformationRequest":
						this.Plugin.requestInformation(this.Arguments*)
					case "Call":
						this.Plugin.call()
					case "Accept":
						this.Plugin.accept()
					case "Reject":
						this.Plugin.reject()
					case "Interrupt":
						this.Plugin.interrupt()
					case "Mute":
						this.Plugin.mute()
					case "Unmute":
						this.Plugin.unmute()
					default:
						throw "Invalid action `"" . this.Action . "`" detected in RaceAssistantAction.fireAction...."
				}
		}
	}

	class RaceSettingsAction extends ControllerAction {
		iPlugin := false
		iAction := false

		Plugin {
			Get {
				return this.iPlugin
			}
		}

		Action {
			Get {
				return this.iAction
			}
		}

		__New(plugin, function, label, icon, action) {
			this.iPlugin := plugin
			this.iAction := action

			super.__New(function, label, icon)
		}

		fireAction(function, trigger) {
			if (this.Action = "RaceSettingsOpen")
				openRaceSettings(false, false, this.Plugin)
			else if (this.Action = "SetupImport")
				openRaceSettings(true, false, this.Plugin)
			else if (this.Action = "SoloCenterOpen")
				openSoloCenter(this.Plugin)
			else if (this.Action = "TeamCenterOpen")
				openTeamCenter(this.Plugin)
			else if (this.Action = "RaceReportsOpen")
				openRaceReports(this.Plugin)
			else if (this.Action = "SessionDatabaseOpen")
				openSessionDatabase(this.Plugin)
			else if (this.Action = "SetupWorkbenchOpen")
				openSetupWorkbench(this.Plugin)
			else if (this.Action = "StrategyWorkbenchOpen")
				openStrategyWorkbench(this.Plugin)
		}
	}

	class RaceAssistantToggleAction extends ControllerAction {
		iPlugin := false

		Plugin {
			Get {
				return this.iPlugin
			}
		}

		__New(plugin, function, label, icon) {
			this.iPlugin := plugin

			super.__New(function, label, icon)
		}

		fireAction(function, trigger) {
			local plugin := this.Plugin

			if plugin.Name
				if (plugin.Enabled && ((trigger = "On") || (trigger = "Off") || (trigger == "Push"))) {
					plugin.disableRaceAssistant(plugin.actionLabel(this))

					function.setLabel(plugin.actionLabel(this), "Black")
					function.setIcon(plugin.actionIcon(this), "Deactivated")
				}
				else if (!plugin.Enabled && ((trigger = "On") || (trigger == "Push"))) {
					plugin.enableRaceAssistant(plugin.actionLabel(this))

					function.setLabel(plugin.actionLabel(this), "Green")
					function.setIcon(plugin.actionIcon(this), "Activated")
				}
		}
	}

	class TeamServerToggleAction extends ControllerAction {
		iPlugin := false

		Plugin {
			Get {
				return this.iPlugin
			}
		}

		__New(plugin, function, label, icon) {
			this.iPlugin := plugin

			super.__New(function, label, icon)
		}

		fireAction(function, trigger) {
			local plugin := this.Plugin

			if (plugin.TeamServer.TeamServerEnabled && ((trigger = "On") || (trigger = "Off") || (trigger == "Push"))) {
				plugin.disableTeamServer(plugin.actionLabel(this))

				function.setLabel(plugin.actionLabel(this), "Black")
				function.setIcon(plugin.actionIcon(this), "Deactivated")
			}
			else if (!plugin.TeamServer.TeamServerEnabled && ((trigger = "On") || (trigger == "Push"))) {
				plugin.enableTeamServer(plugin.actionLabel(this))

				function.setLabel(plugin.actionLabel(this), "Green")
				function.setIcon(plugin.actionIcon(this), "Activated")
			}
		}
	}

	class RestoreSessionStateTask extends PeriodicTask {
		iRaceAssistant := false
		iData := false
		iTries := 50

		RaceAssistant {
			Get {
				return this.iRaceAssistant
			}
		}

		Data {
			Get {
				return this.iData
			}
		}

		__New(raceAssistant, data) {
			this.iRaceAssistant := raceAssistant
			this.iData := data

			super.__New(false, 0, kHighPriority)
		}

		run() {
			local raceAssistant := this.RaceAssistant
			local teamServer := raceAssistant.TeamServer
			local sessionSettings := this.getData(teamServer, "Settings")
			local sessionState := this.getData(teamServer, "State")
			local stateLap, dataLap

			if (sessionSettings && sessionState) {
				stateLap := getMultiMapValue(sessionState, "Session State", "Lap", false)
				dataLap := getMultiMapValue(this.Data, "Stint Data", "Laps", false)

				if (!dataLap || !stateLap || (Abs(dataLap - stateLap) <= 5)) {
					if isDebug() {
						if isLogLevel(kLogDebug)
							showMessage("Restoring session state for " . raceAssistant.Plugin)

						logMessage(kLogCritical, "Restoring session state for " . raceAssistant.Plugin . "...")
					}

					raceAssistant.Simulator.restoreSessionState(&sessionSettings, &sessionState)

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
					return false
				else
					return parseMultiMap(data)
			}
			catch Any as exception {
				return false
			}
		}

		createDataFile(data, extension) {
			local dataFile := temporaryFileName(this.RaceAssistant.Plugin, extension)

			data := printMultiMap(data)

			FileAppend(data, dataFile, "UTF-16")

			return dataFile
		}
	}

	static CollectorTask {
		Get {
			return RaceAssistantPlugin.sCollectorTask
		}
	}

	CollectorTask {
		Get {
			return RaceAssistantPlugin.CollectorTask
		}
	}

	static ReplayDirectory {
		Get {
			return RaceAssistantPlugin.sReplayDirectory
		}
	}

	ReplayDirectory {
		Get {
			return RaceAssistantPlugin.ReplayDirectory
		}
	}

	static Assistants[key?] {
		Get {
			return (isSet(key) ? RaceAssistantPlugin.sAssistants[key] : RaceAssistantPlugin.sAssistants)
		}
	}

	Assistants[key?] {
		Get {
			return RaceAssistantPlugin.Assistants[key?]
		}
	}

	static Simulator {
		Get {
			return RaceAssistantPlugin.sSimulator
		}
	}

	Simulator {
		Get {
			return RaceAssistantPlugin.Simulator
		}
	}

	static WaitForShutdown[teamServer := false] {
		Get {
			return (A_TickCount < (teamServer ? RaceAssistantPlugin.sTeamServerWaitForShutdown
											  : RaceAssistantPlugin.sAssistantWaitForShutdown))
		}

		Set {
			if teamServer {
				if (RaceAssistantPlugin.sTeamServerCooldown = kUndefined)
					RaceAssistantPlugin.sTeamServerCooldown := 600000

				RaceAssistantPlugin.sTeamServerWaitForShutdown := (value ? (A_TickCount + RaceAssistantPlugin.sTeamServerCooldown) : 0)
			}
			else {
				if (RaceAssistantPlugin.sAssistantCooldown = kUndefined)
					RaceAssistantPlugin.sAssistantCooldown := 90000

				RaceAssistantPlugin.sAssistantWaitForShutdown := (value ? (A_TickCount + RaceAssistantPlugin.sAssistantCooldown) : 0)
			}

			return value
		}
	}

	WaitForShutdown[teamServer := false] {
		Get {
			return RaceAssistantPlugin.WaitForShutdown[teamServer]
		}
	}

	static Settings[key?] {
		Get {
			return isSet(key) ? RaceAssistantPlugin.sSettings[key] : RaceAssistantPlugin.sSettings
		}

		Set {
			return isSet(key) ? (RaceAssistantPlugin.sSettings[key] := value) : (RaceAssistantPlugin.sSettings := value)
		}
	}

	static Finish {
		Get {
			return RaceAssistantPlugin.sFinish
		}
	}

	Finish {
		Get {
			return RaceAssistantPlugin.Finish
		}
	}

	static LastLap {
		Get {
			return RaceAssistantPlugin.sLastLap
		}
	}

	LastLap {
		Get {
			return RaceAssistantPlugin.LastLap
		}
	}

	static LapRunning {
		Get {
			return RaceAssistantPlugin.sLapRunning
		}
	}

	LapRunning {
		Get {
			return RaceAssistantPlugin.LapRunning
		}
	}

	static Session {
		Get {
			return RaceAssistantPlugin.sSession
		}
	}

	Session {
		Get {
			return RaceAssistantPlugin.Session
		}
	}

	static InPit {
		Get {
			return RaceAssistantPlugin.sInPit
		}
	}

	InPit {
		Get {
			return RaceAssistantPlugin.InPit
		}
	}

	static TeamServer {
		Get {
			return RaceAssistantPlugin.sTeamServer
		}
	}

	TeamServer {
		Get {
			return RaceAssistantPlugin.TeamServer
		}
	}

	static TeamSession {
		Get {
			return RaceAssistantPlugin.sTeamSession
		}
	}

	TeamSession {
		Get {
			return RaceAssistantPlugin.TeamSession
		}
	}

	static TeamSessionActive {
		Get {
			return RaceAssistantPlugin.sTeamSessionActive
		}
	}

	TeamSessionActive {
		Get {
			return RaceAssistantPlugin.TeamSessionActive
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

	RaceAssistantActive {
		Get {
			return this.iRaceAssistantActive
		}

		Set {
			return (this.iRaceAssistantActive := value)
		}
	}

	RaceAssistantPrepared {
		Get {
			return this.iRaceAssistantPrepared
		}

		Set {
			return (this.iRaceAssistantPrepared := value)
		}
	}

	Enabled {
		Get {
			return this.iEnabled
		}
	}

	RaceAssistantPersistent {
		Get {
			return false
		}
	}

	Name {
		Get {
			return this.iName
		}
	}

	Logo {
		Get {
			return this.iLogo
		}
	}

	Language {
		Get {
			return this.iLanguage
		}
	}

	Synthesizer {
		Get {
			return this.iSynthesizer
		}
	}

	Speaker {
		Get {
			return this.iSpeaker
		}
	}

	SpeakerVocalics {
		Get {
			return this.iSpeakerVocalics
		}
	}

	SpeakerBooster {
		Get {
			return this.iSpeakerBooster
		}
	}

	Recognizer {
		Get {
			return this.iRecognizer
		}
	}

	Listener {
		Get {
			return this.iListener
		}
	}

	ListenerBooster {
		Get {
			return this.iListenerBooster
		}
	}

	ConversationBooster {
		Get {
			return this.iConversationBooster
		}
	}

	AgentBooster {
		Get {
			return this.iAgentBooster
		}
	}

	Muted {
		Get {
			return this.iMuted
		}
	}

	static CollectData[type] {
		Get {
			return RaceAssistantPlugin.sCollectData[type]
		}

		Set {
			return (RaceAssistantPlugin.sCollectData[type] := value)
		}
	}

	__New(controller, name, configuration := false, register := true) {
		local teamServer, raceAssistantToggle, teamServerToggle, arguments, ignore, theAction, assistant
		local openRaceSettings, openRaceReports, openSessionDatabase, openSetupWorkbench
		local openSoloCenter, openTeamCenter, openStrategyWorkbench, importSetup
		local assistantSpeaker, assistantListener, first, index

		super.__New(controller, name, configuration, register)

		RaceAssistantPlugin.sCollectData.Default := true

		if (RaceAssistantPlugin.sTeamServer = kUndefined) {
			for ignore, assistant in kRaceAssistants {
				deleteFile(kTempDirectory . assistant . ".state")
				deleteFile(kTempDirectory . assistant . " Session.state")
			}

			if isSet(kTeamServerPlugin) {
				teamServer := this.Controller.findPlugin(kTeamServerPlugin)

				if (!teamServer || !this.Controller.isActive(teamServer))
					teamServer := false
			}
			else
				teamServer := false

			RaceAssistantPlugin.sTeamServer := teamServer
		}
		else
			teamServer := RaceAssistantPlugin.TeamServer

		if (this.Active || (isDebug() && isDevelopment())) {
			RaceAssistantPlugin.Assistants.Push(this)

			this.iName := this.getArgumentValue("name", this.getArgumentValue("raceAssistantName", false))
			this.iLogo := this.getArgumentValue("logo", this.getArgumentValue("raceAssistantLogo", false))
			this.iLanguage := this.getArgumentValue("language", this.getArgumentValue("raceAssistantLanguage", false))

			raceAssistantToggle := this.getArgumentValue("raceAssistant", false)

			if raceAssistantToggle {
				arguments := string2Values(A_Space, substituteString(raceAssistantToggle, "  ", A_Space))

				if (arguments.Length == 0)
					arguments := ["On"]

				if ((arguments.Length == 1) && !inList(["On", "Off"], arguments[1]))
					arguments.InsertAt(1, "On")

				this.iEnabled := (arguments[1] = "On")

				if (arguments.Length > 1)
					this.createRaceAssistantAction(controller, "RaceAssistant", arguments[2])
			}
			else
				this.iEnabled := (this.iName != false)

			if this.StartupSettings
				this.iEnabled := getMultiMapValue(this.StartupSettings, this.Plugin, "Enabled", this.iEnabled)

			if (teamServer && teamServer.Active) {
				teamServerToggle := this.getArgumentValue("teamServer", false)

				if teamServerToggle {
					arguments := string2Values(A_Space, substituteString(teamServerToggle, "  ", A_Space))

					if (arguments.Length == 0)
						arguments := ["Off"]

					if ((arguments.Length == 1) && !inList(["On", "Off"], arguments[1]))
						arguments.InsertAt(1, "Off")

					if (!this.StartupSettings || (getMultiMapValue(this.StartupSettings, "Session", "Mode", kUndefined) = kUndefined))
						if (arguments[1] = "On")
							this.enableTeamServer()
						else
							this.disableTeamServer()

					if (arguments.Length > 1)
						this.createRaceAssistantAction(controller, "TeamServer", arguments[2])
				}

				if (this.StartupSettings && (getMultiMapValue(this.StartupSettings, "Session", "Mode", kUndefined) != kUndefined))
					if (getMultiMapValue(this.StartupSettings, "Session", "Mode") = "Team")
						this.enableTeamServer()
					else
						this.disableTeamServer()
			}

			openRaceSettings := this.getArgumentValue("openRaceSettings", false)

			if openRaceSettings
				this.createRaceAssistantAction(controller, "RaceSettingsOpen", openRaceSettings)

			importSetup := this.getArgumentValue("importSetup", false)

			if importSetup
				this.createRaceAssistantAction(controller, "SetupImport", importSetup)

			openRaceReports := this.getArgumentValue("openRaceReports", false)

			if openRaceReports
				this.createRaceAssistantAction(controller, "RaceReportsOpen", openRaceReports)

			openSessionDatabase := this.getArgumentValue("openSessionDatabase", false)

			if openSessionDatabase
				this.createRaceAssistantAction(controller, "SessionDatabaseOpen", openSessionDatabase)

			openSetupWorkbench := this.getArgumentValue("openSetupWorkbench", false)

			if openSetupWorkbench
				this.createRaceAssistantAction(controller, "SetupWorkbenchOpen", openSetupWorkbench)

			openStrategyWorkbench := this.getArgumentValue("openStrategyWorkbench", false)

			if openStrategyWorkbench
				this.createRaceAssistantAction(controller, "StrategyWorkbenchOpen", openStrategyWorkbench)

			openSoloCenter := this.getArgumentValue("openSoloCenter", false)

			if openSoloCenter
				this.createRaceAssistantAction(controller, "SoloCenterOpen", openSoloCenter)

			openTeamCenter := this.getArgumentValue("openTeamCenter", false)

			if openTeamCenter
				this.createRaceAssistantAction(controller, "TeamCenterOpen", openTeamCenter)

			for ignore, theAction in string2Values(",", this.getArgumentValue("assistantCommands", ""))
				this.createRaceAssistantAction(controller, string2Values(A_Space, substituteString(theAction, "  ", A_Space))*)

			this.iSynthesizer := this.getArgumentValue("synthesizer", this.getArgumentValue("raceAssistantSynthesizer", false))

			assistantSpeaker := this.getArgumentValue("speaker", this.getArgumentValue("raceAssistantSpeaker", false))

			if ((assistantSpeaker = kFalse) || (assistantSpeaker = "Off"))
				assistantSpeaker := false

			if assistantSpeaker {
				this.iSpeaker := (((assistantSpeaker = kTrue) || (assistantSpeaker = "On")) ? true : assistantSpeaker)

				if (this.StartupSettings && (getMultiMapValue(this.StartupSettings, this.Plugin, "Silent", kUndefined) != kUndefined))
					if getMultiMapValue(this.StartupSettings, this.Plugin, "Silent", false) {
						this.iSpeaker := false

						assistantSpeaker := false
					}

				if assistantSpeaker {
					this.iSpeakerVocalics := this.getArgumentValue("speakerVocalics", this.getArgumentValue("raceAssistantSpeakerVocalics", false))
					this.iSpeakerBooster := this.getArgumentValue("speakerBooster", this.getArgumentValue("raceAssistantSpeakerBooster", false))

					this.iRecognizer := this.getArgumentValue("recognizer", this.getArgumentValue("raceAssistantRecognizer", false))

					assistantListener := this.getArgumentValue("listener", this.getArgumentValue("raceAssistantListener", false))

					if ((assistantListener != false) && (assistantListener != kFalse) && (assistantListener != "Off")) {
						this.iListenerBooster := this.getArgumentValue("listenerBooster", this.getArgumentValue("raceAssistantListenerBooster", false))
						this.iConversationBooster := this.getArgumentValue("conversationBooster", this.getArgumentValue("raceAssistantConversationBooster", false))

						this.iListener := (((assistantListener = kTrue) || (assistantListener = "On")) ? true : assistantListener)
					}
				}
			}

			this.iAgentBooster := this.getArgumentValue("agentBooster", this.getArgumentValue("raceAssistantAgentBooster", false))

			this.iMuted := (this.getArgumentValue("muted", this.getArgumentValue("raceAssistantMuted", false)) != false)

			if this.StartupSettings
				this.iMuted := getMultiMapValue(this.StartupSettings, this.Plugin, "Muted", this.iMuted)

			deleteDirectory(kTempDirectory . "Race Assistant")

			controller.registerPlugin(this)

			registerMessageHandler(this.Plugin, methodMessageHandler, this)

			if this.Enabled
				this.enableRaceAssistant(false, true)
			else
				this.disableRaceAssistant(false, true)
		}

		if !RaceAssistantPlugin.sCollectorTask {
			index := inList(A_Args, "-Replay")

			if index
				RaceAssistantPlugin.sReplayDirectory := (normalizeDirectoryPath(A_Args[index + 1]) . "\")

			if !FileExist(RaceAssistantPlugin.sReplayDirectory)
				RaceAssistantPlugin.sReplayDirectory := false

			RaceAssistantPlugin.sCollectorTask
				:= PeriodicTask(ObjBindMethod(RaceAssistantPlugin, "collectSessionData"), 1000, kHighPriority)

			RaceAssistantPlugin.CollectorTask.start()
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

				this.registerAction(RaceAssistantPlugin.RaceAssistantAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor), "InformationRequest", arguments*))
			}
			else if inList(["Call", "Accept", "Reject", "Interrupt", "Mute", "Unmute"], action) {
				descriptor := ConfigurationItem.descriptor(action, "Activate")

				this.registerAction(RaceAssistantPlugin.RaceAssistantAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor), action))
			}
			else if (action = "RaceAssistant") {
				descriptor := ConfigurationItem.descriptor(action, "Toggle")

				this.registerAction(RaceAssistantPlugin.RaceAssistantToggleAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor)))
			}
			else if (action = "TeamServer") {
				descriptor := ConfigurationItem.descriptor(action, "Toggle")

				this.registerAction(RaceAssistantPlugin.TeamServerToggleAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor)))
			}
			else if ((action = "RaceSettingsOpen") || (action = "SetupImport")
				  || (action = "RaceReportsOpen") || (action = "SessionDatabaseOpen") || (action = "SetupWorkbenchOpen")
				  || (action = "StrategyWorkbenchOpen") || (action = "SoloCenterOpen") || (action = "TeamCenterOpen")) {
				descriptor := ConfigurationItem.descriptor(action, "Activate")

				this.registerAction(RaceAssistantPlugin.RaceSettingsAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor), action))
			}
			else
				logMessage(kLogWarn, translate("Action `"") . action . translate("`" not found in plugin ") . translate(this.Plugin) . translate(" - please check the configuration"))
		}
		else
			this.logFunctionNotFound(actionFunction)
	}

	writePluginState(configuration, extended := true) {
		local tries := 10
		local teamServer, session, information, state

		static updateCycle := (getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))
																	   , "Team Server", "Update Frequency", 10) * 1000)

		if (this.Active && extended) {
			teamServer := this.TeamServer

			if (teamServer && teamServer.TeamServerActive && (A_TickCount > this.iNextSessionUpdate))
				try {
					this.iNextSessionUpdate := (A_TickCount + updateCycle)

					state := teamServer.Connector.GetSessionValue(teamServer.Session, this.Plugin . " Session Info")

					if (state && (state != ""))
						loop
							try {
								if !deleteFile(kTempDirectory . this.Plugin . " Session.state")
									throw "Cannot delete file..."

								FileAppend(state, kTempDirectory . this.Plugin . " Session.state")

								break
							}
							catch Any as exception {
								logError(exception)

								if (tries-- <= 0)
									break
								else
									Sleep(200)
							}
				}
				catch Any as exception {
					logError(exception)
				}

			if this.Enabled {
				if (this.RaceAssistant && !this.RaceAssistantActive && !this.WaitForShutdown) {
					setMultiMapValue(configuration, "Race Assistants", this.Plugin, "Waiting")

					setMultiMapValue(configuration, this.Plugin, "State", "Active")

					setMultiMapValue(configuration, this.Plugin, "Information"
								   , values2String("; ", translate("Started: ") . translate("Yes")
													   , translate("Session: ") . translate("Waiting...")))
				}
				else if (this.RaceAssistant && this.RaceAssistantActive) {
					setMultiMapValue(configuration, "Race Assistants", this.Plugin, "Active")

					setMultiMapValue(configuration, this.Plugin, "State", "Active")

					switch this.Session {
						case kSessionQualification:
							session := "Qualification"
						case kSessionPractice:
							session := "Practice"
						case kSessionRace:
							session := "Race"
						case kSessionTimeTrial:
							session := "Time Trial"
						default:
							session := "Unknown"
					}

					setMultiMapValue(configuration, "Race Assistants", "Session", (this.TeamSessionActive ? "Team" : "Solo") . ";" . session)

					information := values2String("; ", translate("Started: ") . translate(this.RaceAssistant ? "Yes" : "No")
													 , translate("Session: ") . translate((session = "Qualification") ? "Qualifying" : session)
													 , translate("Laps: ") . this.LastLap
													 , translate("Mode: ") . translate(this.TeamSessionActive ? "Team" : "Solo"))

					if !this.Speaker {
						information .= ("; " . translate("Silent: ") . translate("Yes"))

						setMultiMapValue(configuration, this.Plugin, "Silent", true)
					}

					if this.Muted {
						information .= ("; " . translate("Muted: ") . translate("Yes"))

						setMultiMapValue(configuration, this.Plugin, "Muted", true)
					}

					setMultiMapValue(configuration, this.Plugin, "Information", information)
				}
				else {
					setMultiMapValue(configuration, "Assistants", this.Plugin, "Passive")

					if this.WaitForShutdown {
						setMultiMapValue(configuration, this.Plugin, "State", "Warning")
						setMultiMapValue(configuration, "Race Assistants", this.Plugin, "Shutdown")

						setMultiMapValue(configuration, this.Plugin, "Information", translate("Message: ") . translate("Waiting for shutdown..."))
					}
					else
						setMultiMapValue(configuration, this.Plugin, "State", "Passive")
				}
			}
			else
				setMultiMapValue(configuration, this.Plugin, "State", "Disabled")
		}
		else
			super.writePluginState(configuration)
	}

	static startSimulation(simulator) {
		if (RaceAssistantPlugin.Simulator && (RaceAssistantPlugin.Simulator != simulator))
			RaceAssistantPlugin.stopSimulation(RaceAssistantPlugin.Simulator)

		RaceAssistantPlugin.sSimulator := simulator
	}

	static stopSimulation(simulator) {
		if (RaceAssistantPlugin.Simulator == simulator) {
			RaceAssistantPlugin.finishAssistantsSession()

			RaceAssistantPlugin.sSimulator := false
		}
	}

	static connectTeamSession() {
		local teamServer := RaceAssistantPlugin.TeamServer
		local settings, sessionIdentifier, serverURL, accessToken, teamIdentifier, driverIdentifier

		RaceAssistantPlugin.sTeamSessionActive := false

		if (teamServer && teamServer.TeamServerEnabled && !RaceAssistantPlugin.WaitForShutdown[true]) {
			settings := readMultiMap(getFileName("Race.settings", kUserConfigDirectory))

			sessionIdentifier := getMultiMapValue(settings, "Team Settings", "Session.Identifier", false)

			if this.StartupSettings
				sessionIdentifier := getMultiMapValue(this.StartupSettings, "Team Session", "Session.Identifier", sessionIdentifier)

			if !teamServer.Connected[true] {
				serverURL := getMultiMapValue(settings, "Team Settings", "Server.URL", "")
				accessToken := getMultiMapValue(settings, "Team Settings", "Server.Token", "")
				teamIdentifier := getMultiMapValue(settings, "Team Settings", "Team.Identifier", false)
				driverIdentifier := getMultiMapValue(settings, "Team Settings", "Driver.Identifier", false)

				if this.StartupSettings {
					serverURL := getMultiMapValue(this.StartupSettings, "Team Session", "Server.URL", serverURL)
					accessToken := getMultiMapValue(this.StartupSettings, "Team Session", "Server.Token", accessToken)
					teamIdentifier := getMultiMapValue(this.StartupSettings, "Team Session", "Team.Identifier", teamIdentifier)
					driverIdentifier := getMultiMapValue(this.StartupSettings, "Team Session", "Driver.Identifier", driverIdentifier)
					sessionIdentifier := getMultiMapValue(this.StartupSettings, "Team Session", "Session.Identifier", sessionIdentifier)
				}

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

	static disconnectTeamSession() {
		local teamServer := RaceAssistantPlugin.TeamServer

		RaceAssistantPlugin.sTeamSessionActive := false

		if (teamServer && teamServer.TeamServerEnabled)
			teamServer.disconnect()
	}

	static initializeAssistantsState() {
		RaceAssistantPlugin.sSession := kSessionFinished
		RaceAssistantPlugin.sStintStartTime := false
		RaceAssistantPlugin.sLastLap := 0
		RaceAssistantPlugin.sLapRunning := 0
		RaceAssistantPlugin.sInPit := false
		RaceAssistantPlugin.sFinish := false
		RaceAssistantPlugin.sSettings.Clear()
	}

	static requireRaceAssistants(simulator, car, track, weather) {
		local teamServer := this.TeamServer
		local activeAssistant := false
		local startupAssistant := false
		local ignore, assistant, wasActive, wait, settingsDB

		for ignore, assistant in RaceAssistantPlugin.Assistants {
			wasActive := (assistant.RaceAssistant != false)

			if assistant.requireRaceAssistant() {
				activeAssistant := true

				startupAssistant := (startupAssistant || !wasActive)
			}
		}

		if startupAssistant {
			Sleep(1500)

			RaceAssistantPlugin.CollectorTask.Priority := kLowPriority

			settingsDB := SettingsDatabase()

			try {
				RaceAssistantPlugin.sAssistantCooldown := (settingsDB.readSettingValue(simulator, car, track, weather, "Assistant", "Shutdown.Assistant.Cooldown", 90) * 1000)
			}
			catch Any as exception {
				logError(exception)

				RaceAssistantPlugin.sAssistantCooldown := 90000
			}

			try {
				RaceAssistantPlugin.sTeamServerCooldown := (settingsDB.readSettingValue(simulator, car, track, weather, "Assistant", "Shutdown.TeamServer.Cooldown", 600) * 1000)
			}
			catch Any as exception {
				logError(exception)

				RaceAssistantPlugin.sTeamServerCooldown := 600000
			}

			try {
				wait := settingsDB.readSettingValue(simulator, car, track, weather, "Assistant", "Session.Data.Frequency", 10)

				if (teamServer && teamServer.Connected[true])
					wait := Max(wait, getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))
																  , "Team Server", "Update Frequency", 10))

				RaceAssistantPlugin.CollectorTask.Sleep := (wait * 1000)
			}
			catch Any as exception {
				logError(exception)

				RaceAssistantPlugin.CollectorTask.Sleep := 10000
			}
		}

		return activeAssistant
	}

	static getSettings(assistant, data) {
		local key := assistant.Plugin
				   . getMultiMapValue(data, "Session Data", "Simulator") . getMultiMapValue(data, "Session Data", "Car")
				   . getMultiMapValue(data, "Session Data", "Track") . getMultiMapValue(data, "Weather Data", "WeatherNow")
		local settings

		if RaceAssistantPlugin.Settings.Has(key)
			return RaceAssistantPlugin.Settings[key]
		else
			return (RaceAssistantPlugin.Settings[key] := assistant.prepareSettings(data))
	}

	static prepareAssistantsSession(data, count) {
		local ignore, assistant, settings

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if assistant.requireRaceAssistant() {
				settings := RaceAssistantPlugin.getSettings(assistant, data)

				if !RaceAssistantPlugin.Simulator.hasPrepared(settings, data, count)
					RaceAssistantPlugin.Simulator.prepareSession(settings, data)

				if !assistant.hasPrepared(settings, data, count)
					assistant.prepareSession(settings, data)
			}
	}

	static acquireSessionData(&telemetryData, &standingsData, finished := false) {
		if RaceAssistantPlugin.Simulator {
			RaceAssistantPlugin.Simulator.acquireSessionData(&telemetryData, &standingsData, finished)

			data := newMultiMap()

			setMultiMapValue(data, "System", "Time", A_TickCount)

			RaceAssistantPlugin.updateAssistantsTelemetryData(telemetryData)
			RaceAssistantPlugin.updateAssistantsStandingsData(standingsData)

			addMultiMapValues(data, standingsData)
			addMultiMapValues(data, telemetryData)

			return data
		}
		else
			return newMultiMap()
	}

	static readSessionData(fileName, &telemetryData, &standingsData) {
		local data := readMultiMap(fileName)

		setMultiMapValue(data, "System", "Time", A_TickCount)

		telemetryData := data.Clone()

		removeMultiMapValues(telemetryData, "Position Data")

		standingsData := newMultiMap()

		setMultiMapValues(standingsData, "Position Data", getMultiMapValues(data, "Position Data"))

		data := newMultiMap()

		addMultiMapValues(data, telemetryData)
		addMultiMapValues(data, standingsData)

		return data
	}

	static startAssistantsSession(data, force := false) {
		local lap := getMultiMapValue(data, "Stint Data", "Laps", false)
		local start := ((lap = 1) || force || RaceAssistantPlugin.TeamSessionActive)
		local first := true
		local ignore, assistant, settings

		startOther() {
			RaceAssistantPlugin.Simulator.startSession(settings, data)

			if (this.TeamServer && this.TeamServer.Connected[true])
				RaceAssistantPlugin.CollectorTask.Sleep
					:= Max(RaceAssistantPlugin.CollectorTask.Sleep
						 , (getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))
										   , "Team Server", "Update Frequency", 10) * 1000))
		}

		if RaceAssistantPlugin.Simulator {
			RaceAssistantPlugin.sSession := RaceAssistantPlugin.getSession(data)
			RaceAssistantPlugin.sStintStartTime := false
			RaceAssistantPlugin.sFinish := false

			for ignore, assistant in RaceAssistantPlugin.Assistants {
				assistant.resetRaceAssistant()

				if assistant.requireRaceAssistant() {
					settings := RaceAssistantPlugin.getSettings(assistant, data)

					if first {
						first := false

						startOther()
					}

					if start
						assistant.startSession(settings, data)
					else
						assistant.joinSession(settings, data)
				}
			}

			if first
				startOther()

			Task.startTask(() {
				local usage := readMultiMap(kUserHomeDirectory . "Diagnostics\Usage.stat")
				local simulator := RaceAssistantPlugin.Simulator.Simulator[true]
				local session := (simulator . "." . getMultiMapValue(data, "Session Data", "Session", "Other"))

				setMultiMapValue(usage, "Simulators", simulator, getMultiMapValue(usage, "Simulators", simulator, 0) + 1)
				setMultiMapValue(usage, "Sessions", session, getMultiMapValue(usage, "Sessions", session, 0) + 1)

				writeMultiMap(kUserHomeDirectory . "Diagnostics\Usage.stat", usage)
			}, 10000, kLowPriority)
		}
	}

	static finishAssistantsSession(shutdownAssistant := true, shutdownTeamSession := true) {
		local restart := (GetKeyState("Shift") && GetKeyState("Ctrl"))
		local session := this.Session
		local finalizeAssistant := shutdownAssistant
		local ignore, assistant

		RaceAssistantPlugin.initializeAssistantsState()

		if (shutdownAssistant && !restart)
			for ignore, assistant in RaceAssistantPlugin.Assistants
				if (assistant.Enabled && assistant.RaceAssistant && !assistant.RaceAssistantPersistent) {
					RaceAssistantPlugin.WaitForShutdown := true

					break
				}

		if (finalizeAssistant && restart)
			finalizeAssistant := false

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if (assistant.Enabled && assistant.RaceAssistant)
				assistant.finishSession(finalizeAssistant, shutdownAssistant)

		if (shutdownTeamSession && RaceAssistantPlugin.TeamSessionActive) {
			RaceAssistantPlugin.TeamServer.leaveSession()

			RaceAssistantPlugin.disconnectTeamSession()

			if ((session == kSessionRace) && !restart)
				RaceAssistantPlugin.WaitForShutdown[true] := true
		}

		if RaceAssistantPlugin.Simulator
			RaceAssistantPlugin.Simulator.finishSession()

		RaceAssistantPlugin.updateAssistantsSession(kSessionFinished)

		if RaceAssistantPlugin.CollectorTask {
			RaceAssistantPlugin.CollectorTask.Priority := kHighPriority
			RaceAssistantPlugin.CollectorTask.Sleep := 1000
		}
	}

	static addAssistantsLap(data, telemetryData, standingsData) {
		local ignore, assistant

		if RaceAssistantPlugin.sStintStartTime {
			setMultiMapValue(data, "Stint Data", "StartTime", RaceAssistantPlugin.sStintStartTime)
			setMultiMapValue(telemetryData, "Stint Data", "StartTime", RaceAssistantPlugin.sStintStartTime)
		}

		if this.Simulator
			this.Simulator.addLap(RaceAssistantPlugin.LastLap, data)

		if RaceAssistantPlugin.TeamSessionActive
			RaceAssistantPlugin.TeamServer.addLap(RaceAssistantPlugin.LastLap, telemetryData, standingsData)

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if (assistant.requireRaceAssistant() && assistant.RaceAssistantActive)
				assistant.addLap(RaceAssistantPlugin.LastLap, RaceAssistantPlugin.LapRunning, data)
	}

	static updateAssistantsLap(data, telemetryData, standingsData) {
		local ignore, assistant

		if RaceAssistantPlugin.sStintStartTime {
			setMultiMapValue(data, "Stint Data", "StartTime", RaceAssistantPlugin.sStintStartTime)
			setMultiMapValue(telemetryData, "Stint Data", "StartTime", RaceAssistantPlugin.sStintStartTime)
		}

		if this.Simulator
			this.Simulator.updateLap(RaceAssistantPlugin.LastLap, data)

		if RaceAssistantPlugin.TeamSessionActive
			RaceAssistantPlugin.TeamServer.updateLap(RaceAssistantPlugin.LastLap, RaceAssistantPlugin.LapRunning, data, telemetryData, standingsData)

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if (assistant.requireRaceAssistant() && assistant.RaceAssistantActive)
				assistant.updateLap(RaceAssistantPlugin.LastLap, RaceAssistantPlugin.LapRunning, data)
	}

	static performAssistantsPitstop(lapNumber) {
		local options := false
		local ignore, assistant

		if RaceAssistantPlugin.Simulator
			options := RaceAssistantPlugin.Simulator.getPitstopAllOptionValues()

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if (assistant.requireRaceAssistant() && assistant.RaceAssistantActive)
				assistant.performPitstop(lapNumber, options)

		if RaceAssistantPlugin.Simulator
			RaceAssistantPlugin.Simulator.performPitstop(lapNumber, options)
	}

	static restoreAssistantsSessionState(data) {
		local ignore, assistant

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if (assistant.requireRaceAssistant() && assistant.RaceAssistantActive)
				assistant.restoreSessionState(data)
			else if !assistant.Enabled
				assistant.clearSessionInfo()
	}

	static updateAssistantsSession(session := kUndefined) {
		local simulator := RaceAssistantPlugin.Simulator
		local ignore, assistant

		static lastSessions := false

		if !lastSessions {
			lastSessions := Map()

			lastSessions.Default := kUndefined
		}

		if (session == kUndefined)
			session := RaceAssistantPlugin.getSession()

		if simulator {
			if (lastSessions[simulator] != session) {
				lastSessions[simulator] := session

				simulator.updateSession(session)
			}
		}
		else
			session := kSessionFinished

		if (session = kSessionFinished) {
			lastSessions := false

			for ignore, assistant in RaceAssistantPlugin.Assistants
				if assistant.Active
					assistant.updateSession(kSessionFinished)
		}
		else
			for ignore, assistant in RaceAssistantPlugin.Assistants
				if assistant.Active
					if (lastSessions[assistant] != (session . assistant.RaceAssistantActive)) {
						lastSessions[assistant] := (session . assistant.RaceAssistantActive)

						assistant.updateSession(session)
					}
	}

	static updateAssistantsTelemetryData(data) {
		local teamServer := this.TeamServer
		local simulator, car, track, maxFuel
		local ignore, assistant

		static settingsDB := false

		if !settingsDB
			settingsDB := SettingsDatabase()

		setMultiMapValue(data, "Session Data", "Mode", (teamServer && teamServer.SessionActive) ? "Team" : "Solo")

		simulator := getMultiMapValue(data, "Session Data", "Simulator")
		car := getMultiMapValue(data, "Session Data", "Car")
		track := getMultiMapValue(data, "Session Data", "Track")

		if !getMultiMapValue(data, "Session Data", "FuelAmount", false) {
			maxFuel := settingsDB.getSettingValue(simulator, car, track, "*", "Session Settings", "Fuel.Amount", kUndefined)

			if (maxFuel && (maxFuel != kUndefined) && (maxFuel != ""))
				setMultiMapValue(data, "Session Data", "FuelAmount", maxFuel)
		}

		if RaceAssistantPlugin.Simulator
			RaceAssistantPlugin.Simulator.updateTelemetryData(data)

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if assistant.Enabled
				assistant.updateTelemetryData(data)
	}

	static updateAssistantsStandingsData(data) {
		local ignore, assistant

		if RaceAssistantPlugin.Simulator
			RaceAssistantPlugin.Simulator.updateStandingsData(data)

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if assistant.Enabled
				assistant.updateStandingsData(data)
	}

	static getSession(data := false) {
		local ignore

		if RaceAssistantPlugin.Simulator {
			if !data
				data := RaceAssistantPlugin.Simulator.readSessionData()

			return getDataSession(data, &ignore)
		}
		else
			return kSessionFinished
	}

	static runningSession(data) {
		return getMultiMapValue(data, "Session Data", "Active", false)
	}

	static sessionActive(data) {
		local ignore, simulator

		if (getDataSession(data, &ignore) >= kSessionPractice) {
			simulator := RaceAssistantPlugin.Simulator

			if simulator
				return ((SessionDatabase.getSimulatorName(getMultiMapValue(data, "Session Data", "Simulator", "Unknown")) = simulator.Simulator[true])
					 && (!simulator.Car || (getMultiMapValue(data, "Session Data", "Car", "Unknown") = simulator.Car))
					 && (!simulator.Track || (getMultiMapValue(data, "Session Data", "Track", "Unknown") = simulator.Track)))
			else
				return true
		}
		else
			return false
	}

	static driverActive(data) {
		local teamServer := RaceAssistantPlugin.TeamServer

		if RaceAssistantPlugin.TeamSessionActive {
			if RaceAssistantPlugin.Simulator
				return RaceAssistantPlugin.Simulator.driverActive(data, teamServer.DriverForName, teamServer.DriverSurName)
			else
				return false
		}
		else
			return true
	}

	static currentLap(data) {
		if (RaceAssistantPlugin.Session == kSessionRace)
			loop getMultiMapValue(data, "Position Data", "Car.Count", 0)
				if (getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Position") = 1)
					return getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Laps", getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Lap"))

		return getMultiMapValue(data, "Stint Data", "Laps", 0)
	}

	static finished(data, state) {
		local leader := state[1]
		local driver := state[2]

		if (!driver && leader && ((leader == true) || (leader.Finish <= getMultiMapValue(data, "Position Data", "Car." . leader.Car . ".Laps")))) {
			if isDebug()
				logMessage(kLogDebug, "Leader finished: " . leader.Finish . "; " . getMultiMapValue(data, "Position Data", "Car." . leader.Car . ".Laps"))

			return true
		}
		else if (driver && ((driver == true) || (driver.Finish <= getMultiMapValue(data, "Position Data", "Car." . driver.Car . ".Laps")))) {
			if isDebug()
				logMessage(kLogDebug, "Driver finished: " . driver.Finish . "; " . getMultiMapValue(data, "Position Data", "Car." . driver.Car . ".Laps"))

			return true
		}
		else
			return false
	}

	static finalLap(data, &state) {
		local additionalLaps := getMultiMapValue(data, "Session Data", "AdditionalLaps", 0)
		local driverCar := getMultiMapValue(data, "Position Data", "Driver.Car")
		local leader, driver, sessionTimeRemaining, driverCar, time, leaderRunning, driverRunning

		if (getMultiMapValue(data, "Session Data", "SessionFormat") = "Time") {
			sessionTimeRemaining := getMultiMapValue(data, "Session Data", "SessionTimeRemaining", 0)

			if (sessionTimeRemaining < (getMultiMapValue(data, "Position Data", "Car." . driverCar . ".Time", 0) * 2)) {
				leader := false
				driver := false

				driverRunning := getMultiMapValue(data, "Position Data", "Car." . driverCar . ".Lap.Running")

				loop getMultiMapValue(data, "Position Data", "Car.Count", 0)
					if (getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Position") = 1) {
						time := getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Time")
						leaderRunning := getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Lap.Running")

						if ((sessionTimeRemaining - ((1 - leaderRunning) * time)) <= 0) {
							if ((leaderRunning < 0.1) || (driverRunning < 0.1))
								return false

							leader := {Car: A_Index, Finish: getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Laps") + 1 + additionalLaps}

							if (driverCar != A_Index)
								if (driverRunning > leaderRunning)
									driver := {Car: driverCar, Finish: getMultiMapValue(data, "Position Data", "Car." . driverCar . ".Laps") + 2 + additionalLaps}
								else
									driver := {Car: driverCar, Finish: getMultiMapValue(data, "Position Data", "Car." . driverCar . ".Laps") + 1 + additionalLaps}
						}

						break
					}

				if (sessionTimeRemaining <= 0) {
					if isDebug()
						logMessage(kLogDebug, "Time is up...")

					leader := false
					driver := {Car: driverCar, Finish: getMultiMapValue(data, "Position Data", "Car." . driverCar . ".Laps") + 1 + additionalLaps}
				}

				if (leader || driver) {
					if isDebug() {
						if leader
							logMessage(kLogDebug, "Leader will finish (" . sessionTimeRemaining . "): " . leader.Finish)

						if driver
							logMessage(kLogDebug, "Driver will finish (" . sessionTimeRemaining . "): " . driver.Finish)
					}

					state := [leader, driver]

					return true
				}
				else
					return false
			}
			else
				return false
		}
		else if ((additionalLaps > 0) && driverCar && (getMultiMapValue(data, "Session Data", "SessionLapsRemaining", 0) = 1)) {
			state := [false, {Car: driverCar, Finish: getMultiMapValue(data, "Position Data", "Car." . driverCar . ".Laps") + 1 + additionalLaps}]

			return true
		}
		else if (getMultiMapValue(data, "Session Data", "SessionLapsRemaining", 0) <= 0) {
			state := [true, true]

			return true
		}
		else
			return false
	}

	activate() {
		super.activate()

		this.updateActions(kSessionUnknown)
	}

	updateFunctions() {
		this.updateActions(kSessionUnknown)
	}

	updateActions(session) {
		local ignore, theAction, teamServer

		for ignore, theAction in this.Actions
			if isInstance(theAction, RaceAssistantPlugin.RaceAssistantToggleAction) {
				theAction.Function.setLabel(this.actionLabel(theAction), this.Name ? (this.Enabled ? "Green" : "Black") : "Gray")
				theAction.Function.setIcon(this.actionIcon(theAction), this.Name ? (this.Enabled ? "Activated" : "Deactivated") : "Disabled")

				if this.Name
					theAction.Function.enable(kAllTrigger, theAction)
				else
					theAction.Function.disable(kAllTrigger, theAction)
			}
			else if isInstance(theAction, RaceAssistantPlugin.TeamServerToggleAction) {
				teamServer := this.TeamServer

				if teamServer {
					theAction.Function.setLabel(this.actionLabel(theAction), (teamServer.TeamServerEnabled ? "Green" : "Black"))
					theAction.Function.setIcon(this.actionIcon(theAction), (teamServer.TeamServerEnabled ? "Activated" : "Deactivated"))
					theAction.Function.enable(kAllTrigger, theAction)
				}
				else {
					theAction.Function.setLabel(this.actionLabel(theAction), "Gray")
					theAction.Function.setIcon(this.actionIcon(theAction), "Disabled")
					theAction.Function.disable(kAllTrigger, theAction)
				}
			}
			else if isInstance(theAction, RaceAssistantPlugin.RaceSettingsAction) {
				if ((theAction.Action = "RaceSettingsOpen") || (theAction.Action = "RaceReportsOpen")
				 || (theAction.Action = "SessionDatabaseOpen") || (theAction.Action = "SetupWorkbenchOpen")
				 || (theAction.Action = "StrategyWorkbenchOpen") || (theAction.Action = "SoloCenterOpen")
				 || (theAction.Action = "TeamCenterOpen")) {
					theAction.Function.enable(kAllTrigger, theAction)
					theAction.Function.setLabel(this.actionLabel(theAction))
					theAction.Function.setIcon(this.actionIcon(theAction))
				}
				else if (theAction.Action = "SetupImport") {
					if this.supportsSetupImport() {
						theAction.Function.enable(kAllTrigger, theAction)
						theAction.Function.setLabel(this.actionLabel(theAction))
						theAction.Function.setIcon(this.actionIcon(theAction))
					}
					else {
						theAction.Function.disable(kAllTrigger, theAction)
						theAction.Function.setLabel(this.actionLabel(theAction), "Gray")
						theAction.Function.setIcon(this.actionIcon(theAction), "Disabled")
					}
				}
			}
			else if isInstance(theAction, RaceAssistantPlugin.RaceAssistantAction)
				if (theAction.Action = "Interrupt") {
					theAction.Function.enable(kAllTrigger, theAction)
					theAction.Function.setLabel(this.actionLabel(theAction))
					theAction.Function.setIcon(this.actionIcon(theAction))
				}
				else if (((theAction.Action = "Accept") || (theAction.Action = "Reject") || (theAction.Action = "Call"))
				 && (this.RaceAssistant[true] != false)) {
					theAction.Function.enable(kAllTrigger, theAction)
					theAction.Function.setLabel(this.actionLabel(theAction))
					theAction.Function.setIcon(this.actionIcon(theAction))
				}
				else if this.RaceAssistantActive {
					theAction.Function.enable(kAllTrigger, theAction)
					theAction.Function.setLabel(this.actionLabel(theAction))
					theAction.Function.setIcon(this.actionIcon(theAction))
				}
				else {
					theAction.Function.disable(kAllTrigger, theAction)
					theAction.Function.setLabel(this.actionLabel(theAction), "Gray")
					theAction.Function.setIcon(this.actionIcon(theAction), "Disabled")
				}
	}

	toggleRaceAssistant() {
		if this.Enabled
			this.disableRaceAssistant()
		else
			this.enableRaceAssistant()
	}

	updateTrayLabel(label, enabled) {
		static hasTrayMenu := Map()
		static first := true

		label := StrReplace(StrReplace(label, "`n", A_Space), "`r", "")

		if !hasTrayMenu.Has(this) {
			if first
				A_TrayMenu.Insert("1&")

			A_TrayMenu.Insert("1&", label, (*) => this.toggleRaceAssistant())

			hasTrayMenu[this] := true
			first := false
		}

		if enabled
			A_TrayMenu.Check(label)
		else
			A_TrayMenu.Uncheck(label)
	}

	enableRaceAssistant(label := false, startup := false) {
		if (!this.Enabled || startup) {
			this.iEnabled := (this.Name != false)

			if this.Enabled {
				label := translate(this.Plugin)

				trayMessage(label, translate("State: On"))

				this.updateTrayLabel(label, true)
			}

			this.updateActions(kSessionUnknown)
		}
	}

	disableRaceAssistant(label := false, startup := false) {
		local ignore, assistant

		if (this.Enabled || startup) {
			label := translate(this.Plugin)

			trayMessage(label, translate("State: Off"))

			this.iEnabled := false

			if this.RaceAssistant
				this.finishSession(!(GetKeyState("Shift") && GetKeyState("Ctrl")))

			this.updateTrayLabel(label, false)

			for ignore, assistant in RaceAssistantPlugin.Assistants
				if assistant.Enabled
					return

			RaceAssistantPlugin.finishAssistantsSession()

			this.updateActions(kSessionFinished)
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
		return RaceAssistantPlugin.RemoteRaceAssistant(pid)
	}

	resetRaceAssistant() {
		this.clearSessionInfo()
	}

	requireRaceAssistant() {
		local pid, options, ignore, parameter, exePath

		if this.Enabled {
			if !this.RaceAssistant {
				pid := ProcessExist()

				try {
					logMessage(kLogInfo, translate("Starting ") . translate(this.Plugin))

					options := " -Remote " . pid

					for ignore, parameter in ["Name", "Logo", "Language", "Synthesizer", "Speaker", "SpeakerVocalics", "Recognizer", "Listener"
											, "SpeakerBooster", "ListenerBooster", "ConversationBooster", "AgentBooster"]
						if this.%parameter%
							options .= (" -" . parameter . " `"" . this.%parameter% . "`"")

					if this.Muted
						options .= " -Muted"

					if this.Controller.VoiceServer
						options .= (" -Voice `"" . this.Controller.VoiceServer . "`"")

					exePath := ("`"" . kBinariesDirectory . this.Plugin . ".exe`"" . options)

					Run(exePath, kBinariesDirectory, , &pid)

					deleteFile(kTempDirectory . this.Plugin . ".settings")

					this.RaceAssistant := this.createRaceAssistant(pid)
				}
				catch Any as exception {
					logMessage(kLogCritical, translate("Cannot start " . this.Plugin . " (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

					if !kSilentMode
						showMessage(substituteVariables(translate("Cannot start " . this.Plugin . " (%kBinariesDirectory%" . this.Plugin . ".exe) - please rebuild the applications..."))
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

	loadSettings(simulator, car, track, data := false, settings := false) {
		local settingsDB := SettingsDatabase()
		local simulatorName := settingsDB.getSimulatorName(simulator)
		local dbSettings := settingsDB.loadSettings(simulatorName, car, track
												  , (data ? getMultiMapValue(data, "Weather Data", "Weather", "Dry") : "Dry"))
		local load, section, values, key, value

		if !settings
			settings := readMultiMap(kUserConfigDirectory . "Race.settings")

		load := getMultiMapValue(this.Configuration, this.Plugin . " Startup", simulatorName . ".LoadSettings", "Default")
		load := getMultiMapValue(this.Configuration, "Race Assistant Startup", simulatorName . ".LoadSettings", load)

		if (data && ((load = "SettingsDatabase") || (load = "SessionDatabase")))
			addMultiMapValues(settings, dbSettings)
		else {
			addMultiMapValues(dbSettings, settings)

			settings := dbSettings
		}

		if this.StartupSettings
			setMultiMapValue(settings, "Assistant", "Assistant.Autonomy"
									 , getMultiMapValue(this.StartupSettings, "Race Assistant", "Autonomy"
													  , getMultiMapValue(settings, "Assistant", "Assistant.Autonomy", "Custom")))

		return settings
	}

	reloadSettings(settings) {
		local settingsFileName := (kTempDirectory . this.Plugin . ".settings")
		local simulator

		if this.RaceAssistant {
			simulator := RaceAssistantPlugin.Simulator

			if (simulator && simulator.Car && simulator.Track)
				settings := this.loadSettings(simulator.Simulator[true], simulator.Car, simulator.Track, false, settings)

			writeMultiMap(settingsFileName, settings)

			this.RaceAssistant.updateSettings(settingsFileName)

			if this.Simulator
				this.Simulator.Settings := settings
		}
	}

	hasPrepared(settings, data, count) {
		local result := this.RaceAssistantPrepared

		if (getMultiMapValue(data, "Position Data", "Car.Count", 0) > 0)
			this.RaceAssistantPrepared := true

		return result
	}

	prepareSettings(data) {
		local settings := this.loadSettings(getMultiMapValue(data, "Session Data", "Simulator")
										  , getMultiMapValue(data, "Session Data", "Car")
										  , getMultiMapValue(data, "Session Data", "Track"), data)

		if this.Simulator
			settings := this.Simulator.prepareSettings(settings, data)

		writeMultiMap(kTempDirectory . this.Plugin . ".settings", settings)

		return settings
	}

	prepareSession(settings, data) {
		local dataFile, settingsFile, ignore

		if this.RaceAssistant {
			dataFile := kTempDirectory . this.Plugin . " Lap 0.0.data"

			writeMultiMap(dataFile, data)

			settingsFile := (kTempDirectory . this.Plugin . ".settings")

			writeMultiMap(settingsFile, settings)

			this.RaceAssistant.prepareSession(settingsFile, dataFile)

			this.updateActions(getDataSession(data, &ignore))
		}
	}

	startSession(settings, data) {
		local code, assistant, settingsFile, dataFile, ignore

		if this.Simulator {
			code := this.Simulator.Code
			assistant := this.Plugin

			DirCreate(kTempDirectory . code . " Data")

			loop Files, kTempDirectory . code . " Data\" . assistant . "*.*"
				deleteFile(A_LoopFilePath)

			if this.RaceAssistant
				this.finishSession(false, false)
			else
				this.requireRaceAssistant()

			if this.RaceAssistant {
				settingsFile := (kTempDirectory . this.Plugin . ".settings")
				dataFile := (kTempDirectory . this.Plugin . ".data")

				writeMultiMap(settingsFile, settings)
				writeMultiMap(dataFile, data)

				this.RaceAssistant.startSession(settingsFile, dataFile)

				this.RaceAssistantActive := true
			}

			this.updateActions(getDataSession(data, &ignore))
		}
	}

	joinSession(settings, data) {
	}

	finishSession(finalize := true, shutdown := true) {
		local teamServer := this.TeamServer

		if (teamServer && teamServer.SessionActive && this.TeamSessionActive)
			teamServer.setSessionValue(this.Plugin . " Session Info", "")

		if this.RaceAssistant {
			this.RaceAssistant.finishSession(finalize)

			this.RaceAssistantActive := false
			this.RaceAssistantPrepared := false

			if shutdown
				this.shutdownRaceAssistant()
		}
	}

	addLap(lap, update, data) {
		local dataFile

		if this.RaceAssistant {
			dataFile := (kTempDirectory . this.Simulator.Code . " Data\" . this.Plugin . " Lap " . lap . "." . update . ".data")

			writeMultiMap(dataFile, data)

			this.RaceAssistant.addLap(lap, dataFile)
		}
	}

	updateLap(lap, update, data) {
		local dataFile

		if this.RaceAssistant {
			dataFile := (kTempDirectory . this.Simulator.Code . " Data\" . this.Plugin . " Lap " . lap . "." . update . ".data")

			writeMultiMap(dataFile, data)

			this.RaceAssistant.updateLap(lap, dataFile)
		}
	}

	performPitstop(lapNumber, options) {
		local data, dataFile, ignore, key, value

		if this.RaceAssistant {
			dataFile := temporaryFileName(this.Plugin, "pitstop")

			data := newMultiMap()

			for ignore, key in ["Refuel", "Tyre Compound", "Tyre Compound Front", "Tyre Compound Rear"
							  , "Tyre Compound Front Left", "Tyre Compound Front Right"
							  , "Tyre Compound Rear Left", "Tyre Compound Rear Right"
							  , "Tyre Set", "Tyre Pressures", "Change Brakes"
							  , "Repair Suspension", "Repair Bodywork", "Repair Engine"]
				if options.Has(key) {
					value := options[key]

					if value
						switch key, false {
							case "Tyre Compound":
								setMultiMapValue(data, "Pitstop", "Tyre.Compound", value[1])
								setMultiMapValue(data, "Pitstop", "Tyre.Compound.Color", value[2])
							case "Tyre Compound Front":
								setMultiMapValue(data, "Pitstop", "Tyre.Compound.Front", value[1])
								setMultiMapValue(data, "Pitstop", "Tyre.Compound.Color.Front", value[2])
							case "Tyre Compound Rear":
								setMultiMapValue(data, "Pitstop", "Tyre.Compound.Rear", value[1])
								setMultiMapValue(data, "Pitstop", "Tyre.Compound.Color.Rear", value[2])
							case "Tyre Compound Front Left":
								setMultiMapValue(data, "Pitstop", "Tyre.Compound.FrontLeft", value[1])
								setMultiMapValue(data, "Pitstop", "Tyre.Compound.Color.FrontLeft", value[2])
							case "Tyre Compound Front Right":
								setMultiMapValue(data, "Pitstop", "Tyre.Compound.FrontRight", value[1])
								setMultiMapValue(data, "Pitstop", "Tyre.Compound.Color.FrontRight", value[2])
							case "Tyre Compound Rear Left":
								setMultiMapValue(data, "Pitstop", "Tyre.Compound.RearLeft", value[1])
								setMultiMapValue(data, "Pitstop", "Tyre.Compound.Color.RearLeft", value[2])
							case "Tyre Compound Rear Right":
								setMultiMapValue(data, "Pitstop", "Tyre.Compound.RearRight", value[1])
								setMultiMapValue(data, "Pitstop", "Tyre.Compound.Color.RearRight", value[2])
							case "Tyre Pressures":
								setMultiMapValue(data, "Pitstop", "Tyre.Pressures", values2String(";", value*))
							default:
								setMultiMapValue(data, "Pitstop", StrReplace(key, A_Space, "."), value[1])
						}
				}

			FileAppend(printMultiMap(data), dataFile, "UTF-16")

			this.RaceAssistant.performPitstop(lapNumber, dataFile)
		}
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

	interrupt() {
		if this.RaceAssistant
			this.RaceAssistant.interrupt()
	}

	mute() {
		if this.RaceAssistant
			this.RaceAssistant.mute()
	}

	unmute() {
		if this.RaceAssistant
			this.RaceAssistant.unmute()
	}

	updateTelemetryData(data) {
	}

	updateStandingsData(data) {
	}

	updateSession(session) {
		this.updateActions(session)
	}

	callSaveLapState(lap, stateFile) {
		local lapState

		if (stateFile && FileExist(stateFile)) {
			lapState := readMultiMap(stateFile)

			deleteFile(stateFile)
		}
		else
			lapState := false

		this.saveLapState(lap, lapState)
	}

	saveLapState(lap, state) {
		local teamServer := this.TeamServer
		local stateName

		if (teamServer && this.TeamSessionActive) {
			if (isDebug() && isLogLevel(kLogDebug))
				showMessage("Saving lap state for " . this.Plugin)

			if state {
				stateName := getKeys(state)

				stateName := ((stateName.Length = 1) ? stateName[1] : "State")

				teamServer.setLapValue(lap, this.Plugin . A_Space . stateName, printMultiMap(state))
			}
		}
	}

	callSaveSessionState(settingsFile, stateFile) {
		local sessionSettings, sessionState

		if (settingsFile && FileExist(settingsFile)) {
			sessionSettings := readMultiMap(settingsFile)

			deleteFile(settingsFile)
		}
		else
			sessionSettings := false

		if (stateFile && FileExist(stateFile)) {
			sessionState := readMultiMap(stateFile)

			deleteFile(stateFile)
		}
		else
			sessionState := false

		this.saveSessionState(sessionSettings, sessionState)
	}

	saveSessionState(settings, state) {
		local teamServer := this.TeamServer

		this.Simulator.saveSessionState(&settings, &state)

		if isDebug() {
			if (!settings || (settings.Count = 0))
				logMessage(kLogCritical, "Session settings are empty for " . this.Plugin . "...")

			if (!state || (state.Count = 0))
				logMessage(kLogCritical, "Session state is empty for " . this.Plugin . "...")
		}

		if (teamServer && this.TeamSessionActive) {
			if isDebug() {
				if isLogLevel(kLogDebug)
					showMessage("Saving session state for " . this.Plugin)

				logMessage(kLogCritical, "Saving session state for " . this.Plugin . "...")
			}

			if settings
				teamServer.setSessionValue(this.Plugin . " Settings", printMultiMap(settings))

			if state
				teamServer.setSessionValue(this.Plugin . " State", printMultiMap(state))
		}
	}

	restoreSessionState(data) {
		if isDebug() {
			if isLogLevel(kLogDebug)
				showMessage("Start session state restoring for " . this.Plugin)

			logMessage(kLogCritical, "Start session state restoring for " . this.Plugin . "...")
		}

		if (this.RaceAssistant && this.TeamServer && this.TeamSessionActive)
			RaceAssistantPlugin.RestoreSessionStateTask(this, data).start()
	}

	customAction(type, function, arguments*) {
		local callArguments := []
		local ignore, argument

		for ignore, argument in arguments
			callArguments.Push((argument = kUndefined) ? unset : argument)

		try {
			if (type = "Function")
				%function%(callArguments*)
			else
				this.Controller.%function%(callArguments*)
		}
		catch Any as exception {
			logError(exception, true)
		}
	}

	clearSessionInfo() {
		local teamServer := this.TeamServer

		if (teamServer && teamServer.SessionActive && this.TeamSessionActive)
			teamServer.setSessionValue(this.Plugin . " Session Info", "")
	}

	savePitstopState(lapNumber, fileName) {
		local teamServer := this.TeamServer

		if (FileExist(fileName) && teamServer && teamServer.SessionActive && this.TeamSessionActive)
			teamServer.setSessionValue("Pitstop State", FileRead(fileName))

		deleteFile(fileName)
	}

	saveSessionInfo(lapNumber, fileName) {
		local teamServer := this.TeamServer
		local tries := 10

		if FileExist(fileName) {
			if (teamServer && teamServer.SessionActive && this.TeamSessionActive) {
				teamServer.setSessionValue(this.Plugin . " Session Info", FileRead(fileName))

				deleteFile(fileName)
			}
			else {
				deleteFile(kTempDirectory . this.Plugin . " Session.state")

				loop
					try {
						FileMove(fileName, kTempDirectory . this.Plugin . " Session.state")

						break
					}
					catch Any as exception {
						logError(exception)

						if (tries-- <= 0)
							break
						else
							Sleep(200)
					}
			}
		}
		else {
			if (teamServer && teamServer.SessionActive && this.TeamSessionActive) {
				teamServer.setSessionValue(this.Plugin . " Session Info", "")

				deleteFile(fileName)
			}
			else
				deleteFile(kTempDirectory . this.Plugin . " Session.state")
		}
	}

	static collectSessionData() {
		local finished := false
		local joinedSession := false
		local teamSessionActive := false
		local startTime := A_TickCount
		local splitTime := startTime
		local lastLap := RaceAssistantPlugin.LastLap
		local skippedLap := false
		local telemetryData, standingsData, data, dataLastLap
		local testData, message, key, value, session, teamServer
		local newLap, firstLap, ignore, assistant, hasAssistant, finalLap
		local simulator, car, track, weather

		static replayLap := false
		static replayIndex := false
		static collectorLastLap := 0
		static collectorLapRunning := 0

		static isInactive := false
		static wasInactive := false

		wasInactive := isInactive

		if (RaceAssistantPlugin.Finish = "Finished")
			RaceAssistantPlugin.finishAssistantsSession()

		if RaceAssistantPlugin.WaitForShutdown
			return
		else {
			hasAssistant := false

			for ignore, assistant in RaceAssistantPlugin.Assistants {
				assistant.RaceAssistant[true]

				hasAssistant := (hasAssistant || (assistant.RaceAssistant != false))
			}

			if (!hasAssistant && (RaceAssistantPlugin.Session == kSessionFinished))
				RaceAssistantPlugin.initializeAssistantsState()
		}

		if isDebug() {
			logMessage(kLogInfo, "Collect session data (Initialize):" . (A_TickCount - splitTime) . " ms...")

			splitTime := A_TickCount
		}

		if (RaceAssistantPlugin.ReplayDirectory && !RaceAssistantPlugin.Simulator) {
			data := readMultiMap(RaceAssistantPlugin.ReplayDirectory . "Race Engineer Lap 1.1.data")

			simulator := getMultiMapValue(data, "Session Data", "Simulator", "Unknown")

			SimulatorController.Instance.simulatorStartup(SessionDatabase.getSimulatorName(simulator))
		}

		if RaceAssistantPlugin.Simulator {
			telemetryData := true
			standingsData := true

			if RaceAssistantPlugin.ReplayDirectory {
				replayIndex += 1

				if !FileExist(RaceAssistantPlugin.ReplayDirectory . "Race Engineer Lap " . replayLap . "." . replayIndex . ".data") {
					replayLap += 1
					replayIndex := 1

					if !FileExist(RaceAssistantPlugin.ReplayDirectory . "Race Engineer Lap " . replayLap . "." . replayIndex . ".data")
						if isDebug() {
							loop
								Sleep(1000)
						}
						else
							ExitApp(0)
				}

				data := RaceAssistantPlugin.readSessionData(RaceAssistantPlugin.ReplayDirectory . "Race Engineer Lap " . replayLap . "." . replayIndex . ".data"
														  , &telemetryData, &standingsData)
			}
			else
				data := RaceAssistantPlugin.acquireSessionData(&telemetryData, &standingsData)

			dataLastLap := getMultiMapValue(data, "Stint Data", "Laps", 0)

			if isDebug() {
				DirCreate(kTempDirectory . "Race Assistant")

				if (dataLastLap != collectorLastLap)
					collectorLapRunning := 0

				collectorLastLap := dataLastLap

				writeMultiMap(kTempDirectory . "Race Assistant\Lap " . dataLastLap . "." . ++collectorLapRunning . ".data", data)

				logMessage(kLogInfo, "Collect session data (Data Acquisition):" . (A_TickCount - splitTime) . " ms...")

				splitTime := A_TickCount
			}

			if (RaceAssistantPlugin.runningSession(data) && (lastLap == 0) && (dataLastLap == 1))
				prepareSessionDatabase(data)

			if (false && isDebug()) {
				testData := getMultiMapValues(data, "Test Data")

				if (testData.Count > 0) {
					message := "Raw Data`n`n"

					for key, value in testData
						message := message . key . " = " . value . "`n"

					showMessage(message, translate("Modular Simulator Controller System"), "Information.ico", 5000, "Left", "Bottom", 400, 400)
				}
			}

			protectionOn()

			try {
				session := getDataSession(data, &finished)

				if (finished && (RaceAssistantPlugin.Session == kSessionRace)) {
					session := kSessionRace

					setMultiMapValue(data, "Session Data", "Session", "Race")

					if (getMultiMapValue(data, "Session Data", "SessionFormat") = "Time") {
						if (!RaceAssistantPlugin.Finish && RaceAssistantPlugin.finalLap(data, &finalLap))
							RaceAssistantPlugin.sFinish := finalLap

						finished := false
					}
				}

				if isDebug() {
					logMessage(kLogInfo, "Collect session data (Preparation):" . (A_TickCount - splitTime) . " ms...")

					splitTime := A_TickCount
				}

				RaceAssistantPlugin.updateAssistantsSession(session)

				if isDebug() {
					logMessage(kLogInfo, "Collect session data (Update Session):" . (A_TickCount - splitTime) . " ms...")

					splitTime := A_TickCount
				}

				if (session == kSessionPaused) {
					RaceAssistantPlugin.sInPit := false

					return
				}

				if !RaceAssistantPlugin.sessionActive(data) {
					; Not in a supported session

					isInactive := true

					RaceAssistantPlugin.finishAssistantsSession()

					return
				}
				else
					isInactive := false

				if ((dataLastLap < lastLap) || (RaceAssistantPlugin.Session != session)) {
					; Start of new session without finishing previous session first

					if (RaceAssistantPlugin.Session != kSessionFinished) {
						RaceAssistantPlugin.finishAssistantsSession()

						return
					}
				}

				simulator := getMultiMapValue(data, "Session Data", "Simulator", "Unknown")
				car := getMultiMapValue(data, "Session Data", "Car", "Unknown")
				track := getMultiMapValue(data, "Session Data", "Track", "Unknown")
				weather := getMultiMapValue(data, "Weather Data", "Weather", "Dry")

				if isDebug() {
					logMessage(kLogInfo, "Collect session data (Finalize):" . (A_TickCount - splitTime) . " ms...")

					splitTime := A_TickCount
				}

				if RaceAssistantPlugin.requireRaceAssistants(simulator, car, track, weather) {
					; Car is on the track

					if isDebug() {
						logMessage(kLogInfo, "Collect session data (Require):" . (A_TickCount - splitTime) . " ms...")

						splitTime := A_TickCount
					}

					if getMultiMapValue(data, "Stint Data", "InPit", false) {
						; Car is in the Pit

						if !RaceAssistantPlugin.InPit {
							RaceAssistantPlugin.sStintStartTime := false

							RaceAssistantPlugin.performAssistantsPitstop(dataLastLap)

							RaceAssistantPlugin.sInPit := dataLastLap
						}
					}
					else if (dataLastLap == 0) {
						; Waiting for the car to cross the start line for the first time

						RaceAssistantPlugin.sStintStartTime := false

						RaceAssistantPlugin.WaitForShutdown[true] := false

						RaceAssistantPlugin.prepareAssistantsSession(data, RaceAssistantPlugin.LapRunning + 1)

						RaceAssistantPlugin.sLapRunning := (RaceAssistantPlugin.LapRunning + 1)
					}
					else if (dataLastLap > 0) {
						; Car has finished the first lap

						if (dataLastLap > 1) {
							if ((dataLastLap > (lastLap + 1)) && !wasInactive && RaceAssistantPlugin.LapRunning
							 && (SessionDatabase.getSimulatorName(simulator) = "iRacing") && (session = kSessionPractice)) {
								; The lap counter jumped from 0 directly to a value greater than 1 - strange case, which sometimes happen in iRacing practice sessions

								skippedLap := true
							}
							else if (lastLap == 0) {
								; Missed the start of the session, might be a team session

								teamSessionActive := RaceAssistantPlugin.connectTeamSession()

								RaceAssistantPlugin.sStintStartTime := false

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
							else if (lastLap < (dataLastLap - 1)) {
								; Regained the car after a driver swap, stint

								if !RaceAssistantPlugin.TeamSessionActive
									return

								RaceAssistantPlugin.sStintStartTime := false

								if !RaceAssistantPlugin.driverActive(data) {
									RaceAssistantPlugin.TeamServer.State["Driver"] := "Mismatch"

									logMessage(kLogWarn, translate("Cannot join team session. Driver names in team session and in simulation do not match."))

									return ; Still a different driver, might happen in some simulations
								}

								RaceAssistantPlugin.TeamServer.addStint(dataLastLap)

								RaceAssistantPlugin.sInPit := false

								RaceAssistantPlugin.restoreAssistantsSessionState(data)
							}

							if !RaceAssistantPlugin.driverActive(data)
								return ; Oops, a different driver, might happen in some simulations after a pitstop
						}

						if (!RaceAssistantPlugin.Finish && RaceAssistantPlugin.finalLap(data, &finalLap))
							RaceAssistantPlugin.sFinish := finalLap

						if RaceAssistantPlugin.InPit {
							RaceAssistantPlugin.sInPit := false

							; Was in the pits, check if same driver for next stint...

							if (RaceAssistantPlugin.TeamSessionActive && RaceAssistantPlugin.driverActive(data))
								RaceAssistantPlugin.TeamServer.addStint(dataLastLap)
						}

						newLap := (dataLastLap > lastLap)
						firstLap := ((lastLap == 0) && newLap)

						if newLap {
							if !RaceAssistantPlugin.sStintStartTime
								RaceAssistantPlugin.sStintStartTime := DateAdd(A_Now, - Round(getMultiMapValue(data, "Stint Data", "LapLastTime", 0) / 1000), "Seconds")

							RaceAssistantPlugin.sLastLap := dataLastLap
							RaceAssistantPlugin.sLapRunning := 0

							if RaceAssistantPlugin.Finish
								finished := RaceAssistantPlugin.finished(data, RaceAssistantPlugin.Finish)
							else if ((getMultiMapValue(data, "Session Data", "SessionFormat") != "Time")
								  && (getMultiMapValue(data, "Session Data", "SessionLapsRemaining", 0) <= 0))
								finished := true

							if (finished && !RaceAssistantPlugin.ReplayDirectory)
								data := RaceAssistantPlugin.acquireSessionData(&telemetryData, &standingsData, true)
						}

						if joinedSession {
							if RaceAssistantPlugin.TeamSessionActive {
								if firstLap {
									RaceAssistantPlugin.TeamServer.joinSession(getMultiMapValue(data, "Session Data", "Simulator")
																			 , getMultiMapValue(data, "Session Data", "Car")
																			 , getMultiMapValue(data, "Session Data", "Track")
																			 , dataLastLap)

									RaceAssistantPlugin.startAssistantsSession(data)
								}

								RaceAssistantPlugin.restoreAssistantsSessionState(data)
							}
							else
								RaceAssistantPlugin.startAssistantsSession(data)
						}
						else if firstLap {
							if RaceAssistantPlugin.connectTeamSession()
								if RaceAssistantPlugin.driverActive(data) {
									teamServer := RaceAssistantPlugin.TeamServer

									teamServer.joinSession(getMultiMapValue(data, "Session Data", "Simulator")
														 , getMultiMapValue(data, "Session Data", "Car")
														 , getMultiMapValue(data, "Session Data", "Track")
														 , dataLastLap
														 , Round((getMultiMapValue(data, "Session Data", "SessionTimeRemaining", 0) / 1000) / 60))

									for ignore, assistant in RaceAssistantPlugin.Assistants
										if assistant.Enabled {
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

							RaceAssistantPlugin.startAssistantsSession(data, skippedLap)
						}

						if isDebug() {
							logMessage(kLogInfo, "Collect session data (Start & Join):" . (A_TickCount - splitTime) . " ms...")

							splitTime := A_TickCount
						}

						RaceAssistantPlugin.sLapRunning := (RaceAssistantPlugin.LapRunning + 1)

						if newLap
							RaceAssistantPlugin.addAssistantsLap(data, telemetryData, standingsData)
						else
							RaceAssistantPlugin.updateAssistantsLap(data, telemetryData, standingsData)

						if isDebug() {
							logMessage(kLogInfo, "Collect session data (Process):" . (A_TickCount - splitTime) . " ms...")

							splitTime := A_TickCount
						}
					}
				}

				if finished
					RaceAssistantPlugin.sFinish := "Finished"
			}
			finally {
				protectionOff()
			}
		}
		else if (RaceAssistantPlugin.Session != kSessionFinished)
			RaceAssistantPlugin.finishAssistantsSession()

		if isDebug()
			logMessage(kLogInfo, "Collect session data (Overall):" . (A_TickCount - startTime) . " ms...")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

getDataSession(data, &finished) {
	local driver

	if getMultiMapValue(data, "Session Data", "Active", false) {
		finished := false

		if getMultiMapValue(data, "Session Data", "Paused", false)
			return kSessionPaused
		else
			switch getMultiMapValue(data, "Session Data", "Session", "Other"), false {
				case "Race":
					return kSessionRace
				case "Practice":
					return kSessionPractice
				case "Qualification":
					return kSessionQualification
				case "Time Trial":
					return kSessionTimeTrial
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
		if (RaceAssistantPlugin.Assistants.Length > 0)
			return RaceAssistantPlugin.Assistants[1]

	return plugin
}

prepareSessionDatabase(data) {
	local plugin := findActivePlugin()
	local sessionDB, simulator, car, track

	if (plugin  && plugin.Simulator) {
		simulator := plugin.Simulator.runningSimulator()
		car := getMultiMapValue(data, "Session Data", "Car", kUndefined)
		track := getMultiMapValue(data, "Session Data", "Track", kUndefined)

		if ((car != kUndefined) && (track != kUndefined))
			SessionDatabase.prepareDatabase(simulator, car, track, data)

		SessionDatabase.registerDriver(simulator, plugin.Controller.ID
									 , driverName(getMultiMapValue(data, "Stint Data", "DriverForname")
												, getMultiMapValue(data, "Stint Data", "DriverSurname")
												, getMultiMapValue(data, "Stint Data", "DriverNickname")))
	}
}

getSimulatorOptions(plugin := false) {
	local options := ""
	local data

	plugin := findActivePlugin(plugin)

	if (plugin && plugin.Simulator) {
		data := plugin.Simulator.acquireTelemetryData()

		if getMultiMapValue(data, "Session Data", "Active", false) {
			options := "-Simulator `"" . SessionDatabase.getSimulatorName(plugin.Simulator.runningSimulator()) . "`""
			options .= " -Car `"" . getMultiMapValue(data, "Session Data", "Car", "Unknown") . "`""
			options .= " -Track `"" . getMultiMapValue(data, "Session Data", "Track", "Unknown") . "`""
			options .= " -Weather " . getMultiMapValue(data, "Weather Data", "Weather", "Dry")
			options .= " -AirTemperature " . Round(getMultiMapValue(data, "Weather Data", "Temperature", "23"))
			options .= " -TrackTemperature " . Round(getMultiMapValue(data, "Track Data", "Temperature", "27"))
			options .= " -Compound " . getMultiMapValue(data, "Car Data", "TyreCompound", "Dry")
			options .= " -CompoundColor " . getMultiMapValue(data, "Car Data", "TyreCompoundColor", "Black")
			options .= " -Map " . getMultiMapValue(data, "Car Data", "MAP", "n/a")
			options .= " -TC " . getMultiMapValue(data, "Car Data", "TC", "n/a")
			options .= " -ABS " . getMultiMapValue(data, "Car Data", "ABS", "n/a")
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
	local temporary := false
	local pid, ignore, options

	reloadSettings() {
		local ignore, assistant, settings

		if ProcessExist(pid)
			return Task.CurrentTask
		else {
			settings := readMultiMap(fileName)

			for ignore, assistant in RaceAssistantPlugin.Assistants
				if (assistant && controller.isActive(assistant) && assistant.Enabled)
					assistant.reloadSettings(settings)

			if temporary
				deleteFile(fileName)

			return false
		}
	}

	plugin := findActivePlugin(plugin)

	if !fileName {
		fileName := kUserConfigDirectory . "Race.settings"

		for ignore, plugin in RaceAssistantPlugin.Assistants
			if (plugin && controller.isActive(plugin) && plugin.Enabled
			 && FileExist(kTempDirectory . plugin.Plugin . ".settings"))
				try {
					fileName := temporaryFileName("Race", "settings")
					temporary := true

					FileCopy(kTempDirectory . plugin.Plugin . ".settings", fileName, 1)

					break
				}
				catch Any as exception {
					logError(exception)
				}
	}

	try {
		if import {
			options := "-File `"" . fileName . "`" -Import"

			if (plugin && plugin.Simulator)
				options := (options . " `"" . controller.ActiveSimulator . "`" " . plugin.Simulator.Code)

			if silent
				options .= " -Silent"

			RunWait("`"" . exePath . "`" " . options, kBinariesDirectory)
		}
		else {
			options := ("-File `"" . fileName . "`" " . getSimulatorOptions(plugin))

			Run("`"" . exePath . "`" " . options, kBinariesDirectory, , &pid)

			if pid
				Task.startTask(reloadSettings, 1000, kLowPriority)
		}
	}
	catch Any as exception {
		logError(exception, true)

		logMessage(kLogCritical, translate("Cannot start the Race Settings tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

		if !kSilentMode
			showMessage(substituteVariables(translate("Cannot start the Race Settings tool (%exePath%) - please check the configuration..."), {exePath: exePath})
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

openRaceReports(plugin := false) {
	local exePath := kBinariesDirectory . "Race Reports.exe"
	local pid, options

	try {
		options := getSimulatorOptions(plugin)

		Run("`"" . exePath . "`" " . options, kBinariesDirectory, , &pid)
	}
	catch Any as exception {
		logError(exception, true)

		logMessage(kLogCritical, translate("Cannot start the Race Reports tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

		if !kSilentMode
			showMessage(substituteVariables(translate("Cannot start the Race Reports tool (%exePath%) - please check the configuration..."), {exePath: exePath})
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

openSessionDatabase(plugin := false) {
	local exePath := kBinariesDirectory . "Session Database.exe"
	local pid, options

	try {
		options := getSimulatorOptions(plugin)

		Run("`"" . exePath . "`" " . options, kBinariesDirectory, , &pid)
	}
	catch Any as exception {
		logError(exception, true)

		logMessage(kLogCritical, translate("Cannot start the Session Database tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

		if !kSilentMode
			showMessage(substituteVariables(translate("Cannot start the Session Database tool (%exePath%) - please check the configuration..."), {exePath: exePath})
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

openSetupWorkbench(plugin := false) {
	local exePath := kBinariesDirectory . "Setup Workbench.exe"
	local options

	try {
		options := getSimulatorOptions(plugin)

		Run("`"" . exePath . "`" " . options, kBinariesDirectory)
	}
	catch Any as exception {
		logError(exception, true)

		logMessage(kLogCritical, translate("Cannot start the Setup Workbench tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

		if !kSilentMode
			showMessage(substituteVariables(translate("Cannot start the Setup Workbench tool (%exePath%) - please check the configuration..."), {exePath: exePath})
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

openStrategyWorkbench(plugin := false) {
	local exePath := kBinariesDirectory . "Strategy Workbench.exe"
	local options

	try {
		options := getSimulatorOptions(plugin)

		Run("`"" . exePath . "`" " . options, kBinariesDirectory)
	}
	catch Any as exception {
		logError(exception, true)

		logMessage(kLogCritical, translate("Cannot start the Strategy Workbench tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

		if !kSilentMode
			showMessage(substituteVariables(translate("Cannot start the Strategy Workbench tool (%exePath%) - please check the configuration..."), {exePath: exePath})
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

openSoloCenter(plugin := false) {
	local exePath := kBinariesDirectory . "Solo Center.exe"
	local options

	try {
		options := getSimulatorOptions(plugin)

		Run("`"" . exePath . "`" " . options, kBinariesDirectory)
	}
	catch Any as exception {
		logError(exception, true)

		logMessage(kLogCritical, translate("Cannot start the Solo Center tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

		if !kSilentMode
			showMessage(substituteVariables(translate("Cannot start the Solo Center tool (%exePath%) - please check the configuration..."), {exePath: exePath})
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

openTeamCenter(plugin := false) {
	local exePath := kBinariesDirectory . "Team Center.exe"
	local options

	try {
		options := getSimulatorOptions(plugin)

		Run("`"" . exePath . "`" " . options, kBinariesDirectory)
	}
	catch Any as exception {
		logError(exception, true)

		logMessage(kLogCritical, translate("Cannot start the Team Center tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

		if !kSilentMode
			showMessage(substituteVariables(translate("Cannot start the Team Center tool (%exePath%) - please check the configuration..."), {exePath: exePath})
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

enableDataCollection(type) {
	RaceAssistantPlugin.CollectData[type] := true
}

disableDataCollection(type) {
	RaceAssistantPlugin.CollectData[type] := false
}