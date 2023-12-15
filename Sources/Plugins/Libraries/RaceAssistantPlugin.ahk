;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Assistant Plugin           ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\Task.ahk"
#Include "..\..\Libraries\Messages.ahk"
#Include "SimulatorPlugin.ahk"
#Include "..\..\Database\Libraries\SessionDatabase.ahk"
#Include "..\..\Database\Libraries\SettingsDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceAssistantPlugin extends ControllerPlugin  {
	static sStartupSettings := kUndefined

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
	iRaceAssistantMuted := false

	iRaceAssistant := false
	iRaceAssistantZombie := false

	iRaceAssistantActive := false

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
			this.callRemote("updateSettings", arguments*)
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
			else if (this.Action = "PracticeCenterOpen")
				openPracticeCenter(this.Plugin)
			else if (this.Action = "RaceCenterOpen")
				openRaceCenter(this.Plugin)
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

			if plugin.RaceAssistantName
				if (plugin.RaceAssistantEnabled && ((trigger = "On") || (trigger = "Off") || (trigger == "Push"))) {
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

				if (!dataLap || !stateLap || Abs(dataLap - stateLap) <= 5) {
					if (isDebug() && isLogLevel(kLogDebug))
						showMessage("Restoring session state for " . raceAssistant.Plugin)

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
					throw "No data..."
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

	RaceAssistantEnabled {
		Get {
			return this.iRaceAssistantEnabled
		}
	}

	RaceAssistantPersistent {
		Get {
			return false
		}
	}

	RaceAssistantName {
		Get {
			return this.iRaceAssistantName
		}
	}

	RaceAssistantLogo {
		Get {
			return this.iRaceAssistantLogo
		}
	}

	RaceAssistantLanguage {
		Get {
			return this.iRaceAssistantLanguage
		}
	}

	RaceAssistantSynthesizer {
		Get {
			return this.iRaceAssistantSynthesizer
		}
	}

	RaceAssistantSpeaker {
		Get {
			return this.iRaceAssistantSpeaker
		}
	}

	RaceAssistantSpeakerVocalics {
		Get {
			return this.iRaceAssistantSpeakerVocalics
		}
	}

	RaceAssistantRecognizer {
		Get {
			return this.iRaceAssistantRecognizer
		}
	}

	RaceAssistantListener {
		Get {
			return this.iRaceAssistantListener
		}
	}

	RaceAssistantMuted {
		Get {
			return this.iRaceAssistantMuted
		}
	}

	__New(controller, name, configuration := false, register := true) {
		local teamServer, raceAssistantToggle, teamServerToggle, arguments, ignore, theAction
		local openRaceSettings, openRaceReports, openSessionDatabase, openSetupWorkbench
		local openPracticeCenter, openRaceCenter, openStrategyWorkbench, importSetup
		local assistantSpeaker, assistantListener, first

		super.__New(controller, name, configuration, register)

		deleteFile(kTempDirectory . this.Plugin . " Session.state")

		if (RaceAssistantPlugin.sStartupSettings = kUndefined)
			if FileExist(kUserConfigDirectory . "Simulator Startup.ini")
				RaceAssistantPlugin.sStartupSettings := readMultiMap(kUserConfigDirectory . "Simulator Startup.ini")
			else
				RaceAssistantPlugin.sStartupSettings := false

		if !RaceAssistantPlugin.sTeamServer {
			if isSet(kTeamServerPlugin) {
				teamServer := this.Controller.findPlugin(kTeamServerPlugin)

				if (teamServer && this.Controller.isActive(teamServer))
					RaceAssistantPlugin.sTeamServer := teamServer
				else
					teamServer := false
			}
			else
				teamServer := false
		}
		else
			teamServer := RaceAssistantPlugin.TeamServer

		if (this.Active || (isDebug() && isDevelopment())) {
			RaceAssistantPlugin.Assistants.Push(this)

			this.iRaceAssistantName := this.getArgumentValue("raceAssistantName", false)
			this.iRaceAssistantLogo := this.getArgumentValue("raceAssistantLogo", false)
			this.iRaceAssistantLanguage := this.getArgumentValue("raceAssistantLanguage", false)

			raceAssistantToggle := this.getArgumentValue("raceAssistant", false)

			if raceAssistantToggle {
				arguments := string2Values(A_Space, substituteString(raceAssistantToggle, "  ", A_Space))

				if (arguments.Length == 0)
					arguments := ["On"]

				if ((arguments.Length == 1) && !inList(["On", "Off"], arguments[1]))
					arguments.InsertAt(1, "On")

				this.iRaceAssistantEnabled := (arguments[1] = "On")

				if (arguments.Length > 1)
					this.createRaceAssistantAction(controller, "RaceAssistant", arguments[2])
			}
			else
				this.iRaceAssistantEnabled := (this.iRaceAssistantName != false)

			if RaceAssistantPlugin.sStartupSettings
				this.iRaceAssistantEnabled := getMultiMapValue(RaceAssistantPlugin.sStartupSettings, this.Plugin, "Enabled", this.iRaceAssistantEnabled)

			if (teamServer && teamServer.Active) {
				teamServerToggle := this.getArgumentValue("teamServer", false)

				if teamServerToggle {
					arguments := string2Values(A_Space, substituteString(teamServerToggle, "  ", A_Space))

					if (arguments.Length == 0)
						arguments := ["Off"]

					if ((arguments.Length == 1) && !inList(["On", "Off"], arguments[1]))
						arguments.InsertAt(1, "Off")

					if (!RaceAssistantPlugin.sStartupSettings || (getMultiMapValue(RaceAssistantPlugin.sStartupSettings, "Team Server", "Enabled", kUndefined) = kUndefined))
						if (arguments[1] = "On")
							this.enableTeamServer()
						else
							this.disableTeamServer()

					if (arguments.Length > 1)
						this.createRaceAssistantAction(controller, "TeamServer", arguments[2])
				}

				if (RaceAssistantPlugin.sStartupSettings && (getMultiMapValue(RaceAssistantPlugin.sStartupSettings, "Team Server", "Enabled", kUndefined) != kUndefined))
					if getMultiMapValue(RaceAssistantPlugin.sStartupSettings, "Team Server", "Enabled", false)
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

			openPracticeCenter := this.getArgumentValue("openPracticeCenter", false)

			if openPracticeCenter
				this.createRaceAssistantAction(controller, "PracticeCenterOpen", openPracticeCenter)

			openRaceCenter := this.getArgumentValue("openRaceCenter", false)

			if openRaceCenter
				this.createRaceAssistantAction(controller, "RaceCenterOpen", openRaceCenter)

			for ignore, theAction in string2Values(",", this.getArgumentValue("assistantCommands", ""))
				this.createRaceAssistantAction(controller, string2Values(A_Space, substituteString(theAction, "  ", A_Space))*)

			this.iRaceAssistantSynthesizer := this.getArgumentValue("raceAssistantSynthesizer", false)

			assistantSpeaker := this.getArgumentValue("raceAssistantSpeaker", false)

			if ((assistantSpeaker = kFalse) || (assistantSpeaker = "Off"))
				assistantSpeaker := false

			if assistantSpeaker {
				this.iRaceAssistantSpeaker := (((assistantSpeaker = kTrue) || (assistantSpeaker = "On")) ? true : assistantSpeaker)

				if RaceAssistantPlugin.sStartupSettings
					if getMultiMapValue(RaceAssistantPlugin.sStartupSettings, this.Plugin, "Silent", false) {
						this.iRaceAssistantSpeaker := false

						assistantSpeaker := false
					}

				if assistantSpeaker {
					this.iRaceAssistantSpeakerVocalics := this.getArgumentValue("raceAssistantSpeakerVocalics", false)

					this.iRaceAssistantRecognizer := this.getArgumentValue("raceAssistantRecognizer", false)

					assistantListener := this.getArgumentValue("raceAssistantListener", false)

					if ((assistantListener != false) && (assistantListener != kFalse) && (assistantListener != "Off"))
						this.iRaceAssistantListener := (((assistantListener = kTrue) || (assistantListener = "On")) ? true : assistantListener)
				}
			}

			this.iRaceAssistantMuted := this.getArgumentValue("raceAssistantMuted", false)

			if RaceAssistantPlugin.sStartupSettings
				this.iRaceAssistantMuted := getMultiMapValue(RaceAssistantPlugin.sStartupSettings, this.Plugin, "Muted", this.iRaceAssistantMuted)

			controller.registerPlugin(this)

			registerMessageHandler(this.Plugin, methodMessageHandler, this)

			if this.RaceAssistantEnabled
				this.enableRaceAssistant(false, true)
			else
				this.disableRaceAssistant(false, true)
		}

		if !RaceAssistantPlugin.sCollectorTask {
			index := inList(A_Args, "-Replay")

			if index
				RaceAssistantPlugin.sReplayDirectory := A_Args[index + 1]

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
			else if inList(["Call", "Accept", "Reject", "Mute", "Unmute"], action) {
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
				  || (action = "StrategyWorkbenchOpen") || (action = "PracticeCenterOpen") || (action = "RaceCenterOpen")) {
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

			if this.RaceAssistantEnabled {
				if (this.RaceAssistant && !this.RaceAssistantActive && !this.WaitForShutdown) {
					setMultiMapValue(configuration, "Race Assistants", this.Plugin, "Waiting")

					setMultiMapValue(configuration, this.Plugin, "State", "Active")

					setMultiMapValue(configuration, this.Plugin, "Information"
								   , values2String("; ", translate("Started: ") . translate("Yes")
													   , translate("Session: ") . translate("Waiting...")))
				}
				else if this.RaceAssistantActive {
					setMultiMapValue(configuration, "Race Assistants", this.Plugin, "Active")

					setMultiMapValue(configuration, this.Plugin, "State", "Active")

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

					setMultiMapValue(configuration, "Race Assistants", "Session", (this.TeamSessionActive ? "Team" : "Solo") . ";" . session)

					information := values2String("; ", translate("Started: ") . translate(this.RaceAssistant ? "Yes" : "No")
													 , translate("Session: ") . translate((session = "Qualification") ? "Qualifying" : session)
													 , translate("Laps: ") . this.LastLap
													 , translate("Mode: ") . translate(this.TeamSessionActive ? "Team" : "Solo"))

					if !this.RaceAssistantSpeaker {
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
		if (RaceAssistantPlugin.Simulator == simulator)
			RaceAssistantPlugin.sSimulator := false
	}

	static connectTeamSession() {
		local teamServer := RaceAssistantPlugin.TeamServer
		local settings, sessionIdentifier, serverURL, accessToken, teamIdentifier, driverIdentifier

		RaceAssistantPlugin.sTeamSessionActive := false

		if (teamServer && teamServer.TeamServerEnabled && !RaceAssistantPlugin.WaitForShutdown[true]) {
			settings := readMultiMap(getFileName("Race.settings", kUserConfigDirectory))
			sessionIdentifier := getMultiMapValue(settings, "Team Settings", "Session.Identifier", false)

			if !teamServer.Connected {
				serverURL := getMultiMapValue(settings, "Team Settings", "Server.URL", "")
				accessToken := getMultiMapValue(settings, "Team Settings", "Server.Token", "")

				teamIdentifier := getMultiMapValue(settings, "Team Settings", "Team.Identifier", false)
				driverIdentifier := getMultiMapValue(settings, "Team Settings", "Driver.Identifier", false)

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

				if (teamServer && teamServer.Connected)
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

	static prepareAssistantsSession(data) {
		local first := true
		local ignore, assistant, settings

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if assistant.requireRaceAssistant() {
				settings := assistant.prepareSettings(data)

				assistant.prepareSession(settings, data)

				if first {
					first := false

					RaceAssistantPlugin.Simulator.prepareSession(settings, data)
				}
			}
	}

	static startAssistantsSession(data) {
		local lap := getMultiMapValue(data, "Stint Data", "Laps", false)
		local start := ((lap = 1) || RaceAssistantPlugin.TeamSessionActive)
		local first := true
		local ignore, assistant, settings

		if RaceAssistantPlugin.Simulator {
			RaceAssistantPlugin.sSession := RaceAssistantPlugin.getSession(data)
			RaceAssistantPlugin.sStintStartTime := false
			RaceAssistantPlugin.sFinish := false

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

			if first {
				RaceAssistantPlugin.Simulator.startSession(settings, data)

				if (this.TeamServer && this.TeamServer.Connected)
					RaceAssistantPlugin.CollectorTask.Sleep
						:= Max(RaceAssistantPlugin.CollectorTask.Sleep
							 , getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))
																	   , "Team Server", "Update Frequency", 10) * 1000)
			}
		}
	}

	static finishAssistantsSession(shutdownAssistant := true, shutdownTeamSession := true) {
		local restart := (GetKeyState("Shift", "P") && GetKeyState("Ctrl", "P"))
		local session := this.Session
		local finalizeAssistant := shutdownAssistant
		local ignore, assistant

		RaceAssistantPlugin.initializeAssistantsState()

		if (shutdownAssistant && !restart)
			for ignore, assistant in RaceAssistantPlugin.Assistants
				if (assistant.RaceAssistantEnabled && assistant.RaceAssistant && !assistant.RaceAssistantPersistent) {
					RaceAssistantPlugin.WaitForShutdown := true

					break
				}

		if (finalizeAssistant && restart)
			finalizeAssistant := false

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if (assistant.RaceAssistantEnabled && assistant.RaceAssistant)
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

	static addAssistantsLap(data, telemetryData, positionsData) {
		local ignore, assistant

		if RaceAssistantPlugin.sStintStartTime {
			setMultiMapValue(data, "Stint Data", "StartTime", RaceAssistantPlugin.sStintStartTime)
			setMultiMapValue(telemetryData, "Stint Data", "StartTime", RaceAssistantPlugin.sStintStartTime)
		}

		if RaceAssistantPlugin.TeamSessionActive
			RaceAssistantPlugin.TeamServer.addLap(RaceAssistantPlugin.LastLap, telemetryData, positionsData)

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if (assistant.requireRaceAssistant() && assistant.RaceAssistantActive)
				assistant.addLap(RaceAssistantPlugin.LastLap, RaceAssistantPlugin.LapRunning, data)
	}

	static updateAssistantsLap(data, telemetryData, positionsData) {
		local ignore, assistant

		if RaceAssistantPlugin.sStintStartTime {
			setMultiMapValue(data, "Stint Data", "StartTime", RaceAssistantPlugin.sStintStartTime)
			setMultiMapValue(telemetryData, "Stint Data", "StartTime", RaceAssistantPlugin.sStintStartTime)
		}

		if RaceAssistantPlugin.TeamSessionActive
			RaceAssistantPlugin.TeamServer.updateLap(RaceAssistantPlugin.LastLap, RaceAssistantPlugin.LapRunning, data, telemetryData, positionsData)

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
			else if !assistant.RaceAssistantEnabled
				assistant.clearSessionState(data)
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
		local simulator, car, track, maxFuel, compound, compoundColor
		local ignore, assistant, section

		static settingsDB := false

		if !settingsDB
			settingsDB := SettingsDatabase()

		setMultiMapValue(data, "Session Data", "Mode", (teamServer && teamServer.SessionActive) ? "Team" : "Solo")

		simulator := getMultiMapValue(data, "Session Data", "Simulator")
		car := getMultiMapValue(data, "Session Data", "Car")
		track := getMultiMapValue(data, "Session Data", "Track")

		maxFuel := settingsDB.getSettingValue(simulator, car, track, "*", "Session Settings", "Fuel.Amount", kUndefined)

		if (maxFuel && (maxFuel != kUndefined) && (maxFuel != ""))
			setMultiMapValue(data, "Session Data", "FuelAmount", maxFuel)

		for ignore, section in ["Car Data", "Setup Data"] {
			compound := getMultiMapValue(data, section, "TyreCompoundRaw", kUndefined)

			if (compound != kUndefined) {
				compound := SessionDatabase().getTyreCompoundName(simulator, car, track, compound, kUndefined)

				if (compound = kUndefined)
					compound := normalizeCompound("Dry")

				compoundColor := false

				if compound
					splitCompound(compound, &compound, &compoundColor)

				setMultiMapValue(data, section, "TyreCompound", compound)
				setMultiMapValue(data, section, "TyreCompoundColor", compoundColor)
			}
		}

		if RaceAssistantPlugin.Simulator
			RaceAssistantPlugin.Simulator.updateTelemetryData(data)

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if assistant.RaceAssistantEnabled
				assistant.updateTelemetryData(data)
	}

	static updateAssistantsPositionsData(data) {
		local ignore, assistant

		if RaceAssistantPlugin.Simulator
			RaceAssistantPlugin.Simulator.updatePositionsData(data)

		for ignore, assistant in RaceAssistantPlugin.Assistants
			if assistant.RaceAssistantEnabled
				assistant.updatePositionsData(data)
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
			loop getMultiMapValue(data, "Position Data", "Car.Count")
				if (getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Position") = 1)
					return getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Laps", getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Lap"))

		return getMultiMapValue(data, "Stint Data", "Laps", 0)
	}

	static finished(data, state) {
		local leader := state[1]
		local driver := state[2]

		if (leader && ((leader == true) || (leader.Finish <= getMultiMapValue(data, "Position Data", "Car." . leader.Car . ".Laps"))))
			return true
		else if (driver && ((driver == true) || (driver.Finish <= getMultiMapValue(data, "Position Data", "Car." . driver.Car . ".Laps"))))
			return true
		else
			return false
	}

	static lastLap(data, &state) {
		local leader, driver, sessionTimeRemaining, driverCar, time, running

		if (getMultiMapValue(data, "Session Data", "SessionFormat") = "Time") {
			driverCar := getMultiMapValue(data, "Position Data", "Driver.Car")
			sessionTimeRemaining := getMultiMapValue(data, "Session Data", "SessionTimeRemaining", 0)

			if (sessionTimeRemaining < (getMultiMapValue(data, "Position Data", "Car." . driverCar . ".Time", 0) * 2)) {
				leader := false
				driver := false

				loop getMultiMapValue(data, "Position Data", "Car.Count")
					if (getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Position") = 1) {
						time := getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Time")
						running := getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Lap.Running")

						if ((sessionTimeRemaining - ((1 - running) * time)) <= 0) {
							leader := {Car: A_Index, Finish: getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Laps") + 1}

							if (driverCar != A_Index)
								if (getMultiMapValue(data, "Position Data", "Car." . driverCar . ".Lap.Running") > running)
									driver := {Car: driverCar, Finish: getMultiMapValue(data, "Position Data", "Car." . driverCar . ".Laps") + 2}
								else
									driver := {Car: driverCar, Finish: getMultiMapValue(data, "Position Data", "Car." . driverCar . ".Laps") + 1}
						}

						break
					}

				if (sessionTimeRemaining <= 0) {
					leader := false
					driver := {Car: driverCar, Finish: getMultiMapValue(data, "Position Data", "Car." . driverCar . ".Laps") + 1}
				}

				if (leader || driver) {
					state := [leader, driver]

					return true
				}
				else
					return false
			}
			else
				return false
		}
		else if (getMultiMapValue(data, "Session Data", "SessionLapsRemaining", 0) <= 0) {
			state := [true, true]

			return true
		}
		else
			return false
	}

	/*
	static lastLap(data, &overLap) {
		local driverCar := getMultiMapValue(data, "Position Data", "Driver.Car")
		local sessionTimeRemaining, driverCar, time, running

		overLap := 0

		if (getMultiMapValue(data, "Session Data", "SessionFormat") = "Time") {
			sessionTimeRemaining := getMultiMapValue(data, "Session Data", "SessionTimeRemaining", 0)

			if (sessionTimeRemaining < (getMultiMapValue(data, "Position Data", "Car." . driverCar . ".Time", 0) * 2)) {
				loop getMultiMapValue(data, "Position Data", "Car.Count")
					if (getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Position") = 1) {
						time := getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Time")
						running := getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Lap.Running")

						if ((sessionTimeRemaining - ((1 - running) * time)) <= 0) {
							if (driverCar != A_Index)
								if (getMultiMapValue(data, "Position Data", "Car." . driverCar . ".Lap.Running") > running)
									overLap := 1

							return true
						}

						break
					}

				return (sessionTimeRemaining <= 0)
			}
			else
				return false
		}
		else
			return (getMultiMapValue(data, "Session Data", "SessionLapsRemaining", 0) <= 0)
	}
	*/

	activate() {
		super.activate()

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
				if ((theAction.Action = "RaceSettingsOpen") || (theAction.Action = "RaceReportsOpen")
				 || (theAction.Action = "SessionDatabaseOpen") || (theAction.Action = "SetupWorkbenchOpen")
				 || (theAction.Action = "StrategyWorkbenchOpen") || (theAction.Action = "PracticeCenterOpen")
				 || (theAction.Action = "RaceCenterOpen")) {
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
		if (!this.RaceAssistantEnabled || startup) {
			this.iRaceAssistantEnabled := (this.RaceAssistantName != false)

			if this.RaceAssistantEnabled {
				label := translate(this.Plugin)

				trayMessage(label, translate("State: On"))

				this.updateTrayLabel(label, true)
			}
		}
	}

	disableRaceAssistant(label := false, startup := false) {
		local ignore, assistant

		if (this.RaceAssistantEnabled || startup) {
			label := translate(this.Plugin)

			trayMessage(label, translate("State: Off"))

			this.iRaceAssistantEnabled := false

			if this.RaceAssistant
				this.finishSession(!(GetKeyState("Shift", "P") && GetKeyState("Ctrl", "P")))

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
		return RaceAssistantPlugin.RemoteRaceAssistant(pid)
	}

	requireRaceAssistant() {
		local pid, options, exePath

		if this.RaceAssistantEnabled {
			if !this.RaceAssistant {
				pid := ProcessExist()

				try {
					logMessage(kLogInfo, translate("Starting ") . translate(this.Plugin))

					options := " -Remote " . pid

					if this.RaceAssistantName
						options .= " -Name `"" . this.RaceAssistantName . "`""

					if this.RaceAssistantLogo
						options .= " -Logo `"" . this.RaceAssistantLogo . "`""

					if this.RaceAssistantLanguage
						options .= " -Language `"" . this.RaceAssistantLanguage . "`""

					if this.RaceAssistantSynthesizer
						options .= " -Synthesizer `"" . this.RaceAssistantSynthesizer . "`""

					if this.RaceAssistantSpeaker
						options .= " -Speaker `"" . this.RaceAssistantSpeaker . "`""

					if this.RaceAssistantSpeakerVocalics
						options .= " -SpeakerVocalics `"" . this.RaceAssistantSpeakerVocalics . "`""

					if this.RaceAssistantRecognizer
						options .= " -Recognizer `"" . this.RaceAssistantRecognizer . "`""

					if this.RaceAssistantListener
						options .= " -Listener `"" . this.RaceAssistantListener . "`""

					if this.RaceAssistantMuted
						options .= " -Muted"

					if this.Controller.VoiceServer
						options .= " -Voice `"" . this.Controller.VoiceServer . "`""

					exePath := "`"" . kBinariesDirectory . this.Plugin . ".exe`"" . options

					Run(exePath, kBinariesDirectory, , &pid)

					this.RaceAssistant := this.createRaceAssistant(pid)
				}
				catch Any as exception {
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
		local settingsDB := SettingsDatabase()
		local simulator := getMultiMapValue(data, "Session Data", "Simulator")
		local car := getMultiMapValue(data, "Session Data", "Car")
		local track := getMultiMapValue(data, "Session Data", "Track")
		local simulatorName := settingsDB.getSimulatorName(simulator)
		local settings := readMultiMap(getFileName("Race.settings", kUserConfigDirectory))
		local loadSettings := getMultiMapValue(this.Configuration, this.Plugin . " Startup", simulatorName . ".LoadSettings", "Default")
		local section, values, key, value

		loadSettings := getMultiMapValue(this.Configuration, "Race Assistant Startup", simulatorName . ".LoadSettings", loadSettings)

		if ((loadSettings = "SettingsDatabase") || (loadSettings = "SessionDatabase"))
			for section, values in settingsDB.loadSettings(simulatorName, car, track
														 , getMultiMapValue(data, "Weather Data", "Weather", "Dry"))
				for key, value in values
					setMultiMapValue(settings, section, key, value)

		if RaceAssistantPlugin.sStartupSettings
			setMultiMapValue(settings, "Assistant", "Assistant.Autonomy"
									 , getMultiMapValue(RaceAssistantPlugin.sStartupSettings, "Assistant", "Autonomy"
													  , getMultiMapValue(settings, "Assistant", "Assistant.Autonomy", "Custom")))

		if isDebug()
			writeMultiMap(kTempDirectory . this.Plugin . ".settings", settings)

		return settings
	}

	reloadSettings(pid, settingsFileName) {
		if ProcessExist(pid)
			Task.startTask(ObjBindMethod(this, "reloadSettings", pid, settingsFileName), 1000, kLowPriority)
		else if this.RaceAssistant
			this.RaceAssistant.updateSettings(settingsFileName)

		return false
	}

	prepareSession(settings, data) {
		local dataFile, settingsFile

		if this.RaceAssistant {
			dataFile := kTempDirectory . this.Plugin . " Lap 0.0.data"

			writeMultiMap(dataFile, data)

			settingsFile := (kTempDirectory . this.Plugin . ".settings")

			writeMultiMap(settingsFile, settings)

			this.RaceAssistant.prepareSession(settingsFile, dataFile)
		}
	}

	startSession(settings, data) {
		local teamServer := this.TeamServer
		local code, assistant, settingsFile, dataFile

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

			if (teamServer && teamServer.SessionActive && this.TeamSessionActive)
				teamServer.setSessionValue(this.Plugin . " Session Info", "")

			if this.RaceAssistant {
				settingsFile := (kTempDirectory . this.Plugin . ".settings")
				dataFile := (kTempDirectory . this.Plugin . ".data")

				writeMultiMap(settingsFile, settings)
				writeMultiMap(dataFile, data)

				this.RaceAssistant.startSession(settingsFile, dataFile)

				this.RaceAssistantActive := true
			}
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

			for ignore, key in ["Refuel", "Tyre Compound", "Tyre Set", "Tyre Pressures"
							  , "Repair Suspension", "Repair Bodywork", "Repair Engine"]
				if options.Has(key) {
					value := options[key]

					if value
						switch key, false {
							case "Tyre Compound":
								setMultiMapValue(data, "Pitstop", "Tyre.Compound", value[1])
								setMultiMapValue(data, "Pitstop", "Tyre.Compound.Color", value[2])
							case "Tyre Pressures":
								setMultiMapValue(data, "Pitstop", "Tyre.Pressures", values2String(";", value*))
							default:
								setMultiMapValue(data, "Pitstop", StrReplace(key, A_Space, "."), value[1])
						}
				}

			data := printMultiMap(data)

			FileAppend(data, dataFile, "UTF-16")

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

	updatePositionsData(data) {
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

		if (teamServer && this.TeamSessionActive) {
			if (isDebug() && isLogLevel(kLogDebug))
				showMessage("Saving session state for " . this.Plugin)

			if settings
				teamServer.setSessionValue(this.Plugin . " Settings", printMultiMap(settings))

			if state
				teamServer.setSessionValue(this.Plugin . " State", printMultiMap(state))
		}
	}

	restoreSessionState(data) {
		if (this.RaceAssistant && this.TeamSessionActive)
			RaceAssistantPlugin.RestoreSessionStateTask(this, data).start()
	}

	clearSessionState(data) {
		local teamServer := this.TeamServer

		if (teamServer && teamServer.SessionActive && this.TeamSessionActive)
			teamServer.setSessionValue(this.Plugin . " Session Info", false)
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
		local telemetryData, positionsData, data, dataLastLap
		local testData, message, key, value, session, teamServer
		local newLap, firstLap, ignore, assistant, hasAssistant, lastLap
		local simulator, car, track, weather

		static replayLap := false
		static replayIndex := false

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
			positionsData := true

			if RaceAssistantPlugin.ReplayDirectory {
				replayIndex += 1

				if !FileExist(RaceAssistantPlugin.ReplayDirectory . "Race Engineer Lap " . replayLap . "." . replayIndex . ".data") {
					replayLap += 1
					replayIndex := 1

					if !FileExist(RaceAssistantPlugin.ReplayDirectory . "Race Engineer Lap " . replayLap . "." . replayIndex . ".data")
						ExitApp(0)
				}

				data := readMultiMap(RaceAssistantPlugin.ReplayDirectory . "Race Engineer Lap " . replayLap . "." . replayIndex . ".data")

				telemetryData := data.Clone()

				removeMultiMapValues(telemetryData, "Position Data")

				positionsData := newMultiMap()

				setMultiMapValues(positionsData, "Position Data", getMultiMapValues(data, "Position Data"))
			}
			else
				data := RaceAssistantPlugin.Simulator.acquireSessionData(&telemetryData, &positionsData)

			if isDebug() {
				logMessage(kLogInfo, "Collect session data (Data Acquisition):" . (A_TickCount - splitTime) . " ms...")

				splitTime := A_TickCount
			}

			dataLastLap := getMultiMapValue(data, "Stint Data", "Laps", 0)

			if (RaceAssistantPlugin.runningSession(data) && (RaceAssistantPlugin.LastLap == 0))
				prepareSessionDatabase(data)

			if (false && isDebug()) {
				testData := getMultiMapValues(data, "Test Data")

				if (testData.Count > 0) {
					message := "Raw Data`n`n"

					for key, value in testData
						message := message . key . " = " . value . "`n"

					showMessage(message, translate("Modular Simulator Controller System"), "Information.png", 5000, "Left", "Bottom", 400, 400)
				}
			}

			protectionOn()

			try {
				session := getDataSession(data, &finished)

				if (finished && (RaceAssistantPlugin.Session == kSessionRace)) {
					session := kSessionRace

					setMultiMapValue(data, "Session Data", "Session", "Race")

					if (getMultiMapValue(data, "Session Data", "SessionFormat") = "Time") {
						if (!RaceAssistantPlugin.Finish && RaceAssistantPlugin.lastLap(data, &lastLap))
							RaceAssistantPlugin.sFinish := lastLap

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
							else if (RaceAssistantPlugin.LastLap < (dataLastLap - 1)) {
								; Regained the car after a driver swap, stint

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
							else ; (this.LastLap == (dataLastLap - 1))
								if !RaceAssistantPlugin.driverActive(data)
									return ; Oops, a different driver, might happen in some simulations after a pitstop
						}

						if (!RaceAssistantPlugin.Finish && RaceAssistantPlugin.lastLap(data, &lastLap))
							RaceAssistantPlugin.sFinish := lastLap

						newLap := (dataLastLap > RaceAssistantPlugin.LastLap)
						firstLap := ((dataLastLap == 1) && newLap)

						if RaceAssistantPlugin.InPit {
							RaceAssistantPlugin.sInPit := false

							; Was in the pits, check if same driver for next stint...

							if (RaceAssistantPlugin.TeamSessionActive && RaceAssistantPlugin.driverActive(data))
								RaceAssistantPlugin.TeamServer.addStint(dataLastLap)
						}

						if newLap {
							if !RaceAssistantPlugin.sStintStartTime
								RaceAssistantPlugin.sStintStartTime := DateAdd(A_Now, - Round(getMultiMapValue(data, "Stint Data", "LapLastTime", 0) / 1000), "Seconds")

							RaceAssistantPlugin.sLastLap := dataLastLap
							RaceAssistantPlugin.sLapRunning := 0

							if RaceAssistantPlugin.Finish
								finished := RaceAssistantPlugin.finished(data, RaceAssistantPlugin.Finish)
							else if ((getMultiMapValue(data, "Session Data", "SessionFormat") != "Time")
								  && (getMultiMapValue(data, "Session Data", "SessionLapsRemaining", 0) == 0))
								finished := true
						}

						if firstLap {
							if RaceAssistantPlugin.connectTeamSession()
								if RaceAssistantPlugin.driverActive(data) {
									teamServer := RaceAssistantPlugin.TeamServer

									teamServer.joinSession(getMultiMapValue(data, "Session Data", "Simulator")
														 , getMultiMapValue(data, "Session Data", "Car")
														 , getMultiMapValue(data, "Session Data", "Track")
														 , dataLastLap
														 , Round((getMultiMapValue(data, "Session Data", "SessionTimeRemaining", 0) / 1000) / 60))

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
								RaceAssistantPlugin.TeamServer.joinSession(getMultiMapValue(data, "Session Data", "Simulator")
																		 , getMultiMapValue(data, "Session Data", "Car")
																		 , getMultiMapValue(data, "Session Data", "Track")
																		 , dataLastLap)

								RaceAssistantPlugin.startAssistantsSession(data)

								RaceAssistantPlugin.restoreAssistantsSessionState(data)
							}
							else
								RaceAssistantPlugin.startAssistantsSession(data)
						}

						if isDebug() {
							logMessage(kLogInfo, "Collect session data (Start & Join):" . (A_TickCount - splitTime) . " ms...")

							splitTime := A_TickCount
						}

						RaceAssistantPlugin.sLapRunning := RaceAssistantPlugin.LapRunning + 1

						if newLap
							RaceAssistantPlugin.addAssistantsLap(data, telemetryData, positionsData)
						else
							RaceAssistantPlugin.updateAssistantsLap(data, telemetryData, positionsData)

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
		data := plugin.Simulator.readSessionData()

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
	local pid, ignore, options

	plugin := findActivePlugin(plugin)

	if !fileName
		fileName := kUserConfigDirectory . "Race.settings"

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
			options := "-File `"" . fileName . "`" " . getSimulatorOptions(plugin)

			Run("`"" . exePath . "`" " . options, kBinariesDirectory, , &pid)

			if pid
				for ignore, plugin in RaceAssistantPlugin.Assistants {
					if (plugin && controller.isActive(plugin) && plugin.RaceAssistantEnabled)
						Task.startTask(ObjBindMethod(plugin, "reloadSettings", pid, fileName), 1000, kLowPriority)
				}
		}
	}
	catch Any as exception {
		logError(exception, true)

		logMessage(kLogCritical, translate("Cannot start the Race Settings tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

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

		showMessage(substituteVariables(translate("Cannot start the Strategy Workbench tool (%exePath%) - please check the configuration..."), {exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

openPracticeCenter(plugin := false) {
	local exePath := kBinariesDirectory . "Practice Center.exe"
	local options

	try {
		options := getSimulatorOptions(plugin)

		Run("`"" . exePath . "`" " . options, kBinariesDirectory)
	}
	catch Any as exception {
		logError(exception, true)

		logMessage(kLogCritical, translate("Cannot start the Practice Center tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

		showMessage(substituteVariables(translate("Cannot start the Practice Center tool (%exePath%) - please check the configuration..."), {exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

openRaceCenter(plugin := false) {
	local exePath := kBinariesDirectory . "Race Center.exe"
	local options

	try {
		options := getSimulatorOptions(plugin)

		Run("`"" . exePath . "`" " . options, kBinariesDirectory)
	}
	catch Any as exception {
		logError(exception, true)

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