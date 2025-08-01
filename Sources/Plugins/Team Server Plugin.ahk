﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Team Server Plugin              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Extensions\Task.ahk"
#Include "..\Framework\Extensions\CLR.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"
#Include "..\Database\Libraries\TelemetryCollector.ahk"
#Include "Libraries\SimulatorPlugin.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kSessionFinished := 0
global kSessionPaused := -1
global kSessionOther := 1
global kSessionPractice := 2
global kSessionQualification := 3
global kSessionRace := 4
global kSessionTimeTrial := 5

global kTeamServerPlugin := "Team Server"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class TeamServerPlugin extends ControllerPlugin {
	iConnector := false

	iServerURL := false
	iServerToken := false

	iConnection := false
	iLastMessage := ""

	iState := CaseInsenseMap()

	iSimulator := false
	iCar := false
	iTrack := false
	iTrackLength := false

	iTeam := false
	iTeamName := ""
	iDriver := false
	iDriverName := ""
	iSession := false
	iSessionName := ""

	iCachedObjects := CaseInsenseMap()

	iDriverForName := false
	iDriverSurName := false
	iDriverNickName := false

	iTeamServerEnabled := false

	iSessionActive := false
	iLapData := CaseInsenseMap("Telemetry", CaseInsenseMap(), "Positions", CaseInsenseMap())

	iTelemetryCollector := false
	iTelemetryDirectory := false

	iCollectorTask := false

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

			if (plugin.TeamServerEnabled && ((trigger = "On") || (trigger = "Off") || (trigger == "Push"))) {
				plugin.disableTeamServer(plugin.actionLabel(this))

				function.setLabel(plugin.actionLabel(this), "Black")
				function.setIcon(plugin.actionIcon(this), "Deactivated")
			}
			else if (!plugin.TeamServerEnabled && ((trigger = "On") || (trigger == "Push"))) {
				plugin.enableTeamServer(plugin.actionLabel(this))

				function.setLabel(plugin.actionLabel(this), "Green")
				function.setIcon(plugin.actionIcon(this), "Activated")
			}
		}
	}

	class RaceSettingsAction extends ControllerAction {
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
			local exePath := kBinariesDirectory . "Race Settings.exe"

			try {
				Run("`"" . exePath . "`"", kBinariesDirectory)
			}
			catch Any as exception {
				logError(exception, true)

				logMessage(kLogCritical, translate("Cannot start the Race Settings tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (")
									   . kBinariesDirectory . translate(")"))

				if !kSilentMode
					showMessage(substituteVariables(translate("Cannot start the Race Settings tool (%exePath%) - please check the configuration..."), {exePath: exePath})
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}
	}

	class TeamCenterAction extends ControllerAction {
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
			local exePath := kBinariesDirectory . "Team Center.exe"

			try {
				Run("`"" . exePath . "`"", kBinariesDirectory)
			}
			catch Any as exception {
				logError(exception, true)

				logMessage(kLogCritical, translate("Cannot start the Team Center tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (")
									   . kBinariesDirectory . translate(")"))

				if !kSilentMode
					showMessage(substituteVariables(translate("Cannot start the Team Center tool (%exePath%) - please check the configuration..."), {exePath: exePath})
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}
	}

	ID {
		Get {
			return this.Controller.ID
		}
	}

	Connector {
		Get {
			return this.iConnector
		}
	}

	ServerURL {
		Get {
			return ((this.iServerURL && (this.iServerURL != "")) ? this.iServerURL : false)
		}
	}

	ServerToken {
		Get {
			return ((this.iServerToken && (this.iServerToken != "")) ? this.iServerToken : false)
		}
	}

	Connection {
		Get {
			return this.iConnection
		}
	}

	Connected[logical := false] {
		Get {
			return ((this.Connection != false) && (logical || !this.Stalled))
		}
	}

	Stalled {
		Get {
			return (this.State.Has("Stalled") ? this.State["Stalled"] : false)
		}
	}

	LastMessage {
		Get {
			return this.iLastMessage
		}

		Set {
			return (this.iLastMessage := StrReplace(StrReplace(value, "`n", A_Space), "`r", ""))
		}
	}

	State[key?] {
		Get {
			return (isSet(key) ? this.iState[key] : this.iState)
		}

		Set {
			return (isSet(key) ? (this.iState[key] := value) : (this.iState := value))
		}
	}

	Simulator {
		Get {
			return this.iSimulator
		}
	}

	Car {
		Get {
			return this.iCar
		}
	}

	Track {
		Get {
			return this.iTrack
		}
	}

	TrackLength {
		Get {
			return this.iTrackLength
		}
	}

	TelemetryDirectory {
		Get {
			return this.iTelemetryDirectory
		}
	}

	TelemetryCollector {
		Get {
			return this.iTelemetryCollector
		}
	}

	Team[asText := false] {
		Get {
			if asText
				return ((this.iTeam && (this.iTeam != "")) ? this.iTeamName : "")
			else
				return ((this.iTeam && (this.iTeam != "")) ? this.iTeam : false)
		}
	}

	Driver[asText := false] {
		Get {
			if asText
				return ((this.iDriver && (this.iDriver != "")) ? this.iDriverName : "")
			else
				return ((this.iDriver && (this.iDriver != "")) ? this.iDriver : false)
		}
	}

	Session[asText := false] {
		Get {
			if asText
				return ((this.iSession && (this.iSession != "")) ? this.iSessionName : "")
			else
				return ((this.iSession && (this.iSession != "")) ? this.iSession : false)
		}
	}

	DriverForName[force := false] {
		Get {
			return this.getDriverForName(force)
		}
	}

	DriverSurName[force := false] {
		Get {
			return this.getDriverSurName(force)
		}
	}

	DriverNickName[force := false] {
		Get {
			return this.getDriverNickName(force)
		}
	}

	TeamServerEnabled {
		Get {
			return this.iTeamServerEnabled
		}
	}

	TeamServerActive {
		Get {
			return (this.Connected && this.TeamServerEnabled && this.Team && this.Driver && this.Session)
		}
	}

	SessionActive {
		Get {
			return (this.TeamServerActive && this.iSessionActive)
		}
	}

	DriverActive {
		Get {
			local currentDriver := this.getCurrentDriver()

			return (this.SessionActive && (currentDriver == this.Driver))
		}
	}

	__New(controller, name, configuration := false, register := true) {
		local dllFile := (kBinariesDirectory . "Connectors\Team Server Connector.dll")
		local teamServerToggle, arguments, openRaceSettings, openTeamCenter

		try {
			if (!FileExist(dllFile)) {
				logMessage(kLogCritical, translate("Team Server Connector.dll not found in ") . kBinariesDirectory)

				throw "Unable to find Team Server Connector.dll in " . kBinariesDirectory . "..."
			}

			this.iConnector := CLR_LoadLibrary(dllFile).CreateInstance("TeamServer.TeamServerConnector")
		}
		catch Any as exception {
			logMessage(kLogCritical, translate("Error while initializing Team Server Connector - please rebuild the applications"))

			logError(exception, true)

			if !kSilentMode
				showMessage(translate("Error while initializing Team Server Connector - please rebuild the applications") . translate("...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}

		super.__New(controller, name, configuration, false)

		if (this.Active || (isDebug() && isDevelopment())) {
			teamServerToggle := this.getArgumentValue("teamServer", false)

			if teamServerToggle {
				arguments := string2Values(A_Space, teamServerToggle)

				if (arguments.Length == 0)
					arguments := ["On"]

				if ((arguments.Length == 1) && !inList(["On", "Off"], arguments[1]))
					arguments.InsertAt(1, "Off")

				this.iTeamServerEnabled := (arguments[1] = "On")

				if (arguments.Length > 1)
					this.createTeamServerAction(controller, "TeamServer", arguments[2])
			}
			else
				this.iTeamServerEnabled := false

			if (this.StartupSettings && (getMultiMapValue(this.StartupSettings, "Session", "Mode", kUndefined) != kUndefined))
				this.iTeamServerEnabled := (getMultiMapValue(this.StartupSettings, "Session", "Mode") = "Team")

			openRaceSettings := this.getArgumentValue("openRaceSettings", false)

			if openRaceSettings
				this.createTeamServerAction(controller, "RaceSettingsOpen", openRaceSettings)

			openTeamCenter := this.getArgumentValue("openTeamCenter", false)

			if openTeamCenter
				this.createTeamServerAction(controller, "TeamCenterOpen", openTeamCenter)

			if register
				controller.registerPlugin(this)

			if this.TeamServerEnabled
				this.enableTeamServer(false, true)
			else
				this.disableTeamServer(false, true)

			this.keepAlive(true)

			OnExit(ObjBindMethod(this, "finishSession"))
		}
	}

	createTeamServerAction(controller, action, actionFunction, arguments*) {
		local function := controller.findFunction(actionFunction)
		local descriptor

		if (function != false) {
			if (action = "TeamServer") {
				descriptor := ConfigurationItem.descriptor(action, "Toggle")

				this.registerAction(TeamServerPlugin.TeamServerToggleAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor)))
			}
			else if (action = "RaceSettingsOpen") {
				descriptor := ConfigurationItem.descriptor(action, "Activate")

				this.registerAction(TeamServerPlugin.RaceSettingsAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor)))
			}
			else if (action = "RaceSettingsOpen") {
				descriptor := ConfigurationItem.descriptor(action, "Activate")

				this.registerAction(TeamServerPlugin.TeamCenterAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor)))
			}
			else
				logMessage(kLogWarn, translate("Action `"") . action . translate("`" not found in plugin ") . translate(this.Plugin) . translate(" - please check the configuration"))
		}
		else
			this.logFunctionNotFound(actionFunction)
	}

	writeDriversState(state) {
		local connectedDrivers := []
		local ignore, connection

		static nextUpdate := 0
		static lastDrivers := false

		if this.Session
			try {
				if (A_TickCount > nextUpdate) {
					for ignore, connection in string2Values(";", this.Connector.GetSessionConnections(this.Session)) {
						if !this.iCachedObjects.Has(connection)
							this.iCachedObjects[connection] := this.parseObject(this.Connector.GetConnection(connection))

						connection := this.iCachedObjects[connection]

						if (connection["Name"] && (connection["Name"] != "") && (connection["Type"] = "Driver")
											   && !inList(connectedDrivers, connection["Name"]))
							connectedDrivers.Push(connection["Name"])
					}

					lastDrivers := values2String("|", connectedDrivers*)

					nextUpdate := (A_TickCount + 30000)
				}

				state.Push("Drivers: " . lastDrivers)
			}
			catch Any as exception {
				logError(exception)

				this.keepAlive()
			}
	}

	writeStintState(state) {
		local stint, lap, driver

		static nextUpdate := 0
		static lastStintInfo := false

		if (this.Connected && this.Session)
			try {
				if (A_TickCount > nextUpdate) {
					stint := this.Connector.GetSessionCurrentStint(this.Session)

					if (stint && (stint != "") && (stint != kNull)) {
						if !this.iCachedObjects.Has(stint)
							this.iCachedObjects[stint] := this.parseObject(this.Connector.GetStint(stint))

						lap := this.Connector.GetSessionLastLap(this.Session)

						if (lap && (lap != "") && (lap != kNull)) {
							if !this.iCachedObjects.Has(lap)
								this.iCachedObjects[lap] := this.parseObject(this.Connector.GetLap(lap))

							driver := this.Connector.GetStintDriver(stint)

							if !this.iCachedObjects.Has(driver)
								this.iCachedObjects[driver] := this.parseObject(this.Connector.GetDriver(driver))

							driver := this.iCachedObjects[driver]

							lastStintInfo := [this.iCachedObjects[stint]["Nr"], this.iCachedObjects[lap]["Nr"]
											, driverName(driver["ForName"], driver["SurName"], driver["NickName"])]

							nextUpdate := (A_TickCount + 60000)
						}
					}
					else
						lastStintInfo := false
				}

				if lastStintInfo {
					state.Push("StintNr: " . lastStintInfo[1])
					state.Push("StintLap: " . lastStintInfo[2])
					state.Push("StintDriver: " . lastStintInfo[3])
				}
			}
			catch Any as exception {
				logError(exception)

				this.keepAlive()
			}
	}

	writePluginState(configuration) {
		local driverMismatch := false
		local key, value, teamServerState

		if this.Active {
			if this.TeamServerEnabled {
				if this.Connected {
					if this.LastMessage {
						setMultiMapValue(configuration, this.Plugin, "State", "Critical")

						setMultiMapValue(configuration, this.Plugin, "Information", translate("Message: ") . this.LastMessage)
					}
					else {
						if (this.State["Driver"] = "Mismatch") {
							setMultiMapValue(configuration, this.Plugin, "State", "Critical")

							driverMismatch := true
						}
						else
							setMultiMapValue(configuration, this.Plugin, "State", "Active")

						setMultiMapValue(configuration, this.Plugin, "Information"
													  , values2String("; ", translate("Team: ") . this.Team[true]
																		  , translate("Driver: ") . this.Driver[true] . (driverMismatch ? translate(" (No match)") : "")
																		  , translate("Session: ") . this.Session[true]))
					}
				}
				else if this.Session {
					setMultiMapValue(configuration, this.Plugin, "State", "Critical")

					setMultiMapValue(configuration, this.Plugin, "Information", translate("Message: ") . this.LastMessage)
				}
				else {
					setMultiMapValue(configuration, this.Plugin, "State", "Warning")

					setMultiMapValue(configuration, this.Plugin, "Information", translate("Message: ") . translate("No valid team session configured"))
				}

				teamServerState := []

				for key, value in this.State
					teamServerState.Push(key . ": " . value)

				this.writeDriversState(teamServerState)
				this.writeStintState(teamServerState)

				setMultiMapValue(configuration, this.Plugin, "Properties", values2String("; ", teamServerState*))
			}
			else
				setMultiMapValue(configuration, this.Plugin, "State", "Disabled")
		}
		else
			super.writePluginState(configuration)
	}

	activate() {
		super.activate()

		this.updateActions(kSessionUnknown)
	}

	updateFunctions() {
		this.updateActions(kSessionUnknown)
	}

	updateActions(session) {
		local ignore, theAction

		for ignore, theAction in this.Actions
			if isInstance(theAction, TeamServerPlugin.TeamServerToggleAction) {
				theAction.Function.enable(kAllTrigger, theAction)
				theAction.Function.setLabel(this.actionLabel(theAction), this.TeamServerEnabled ? "Green" : "Black")
				theAction.Function.setIcon(this.actionIcon(theAction), this.TeamServerEnabled ? "Activated" : "Deactivated")
			}
			else if isInstance(theAction, TeamServerPlugin.RaceSettingsAction) {
				theAction.Function.enable(kAllTrigger, theAction)
				theAction.Function.setLabel(this.actionLanbel(theAction))
			}
	}

	toggleTeamServer() {
		if this.TeamServerEnabled
			this.disableTeamServer()
		else
			this.enableTeamServer()
	}

	updateTrayLabel(label, enabled) {
		static hasTrayMenu := false

		label := StrReplace(StrReplace(label, "`n", A_Space), "`r", "")

		if !hasTrayMenu {
			A_TrayMenu.Insert("1&")
			A_TrayMenu.Insert("1&", label, (*) => this.toggleTeamServer())

			hasTrayMenu := true
		}

		if enabled
			A_TrayMenu.Check(label)
		else
			A_TrayMenu.Uncheck(label)
	}

	enableTeamServer(label := false, force := false) {
		if (!this.TeamServerEnabled || force) {
			if !label
				label := this.getLabel("TeamServer.Toggle")

			trayMessage(label, translate("State: On"))

			this.iTeamServerEnabled := true

			Task.startTask(ObjBindMethod(this, "tryConnect"), 2000, kLowPriority)

			this.updateActions(kSessionUnknown)

			this.updateTrayLabel(label, true)

			this.updateActions(kSessionUnknown)
		}
	}

	disableTeamServer(label := false, force := false) {
		if (this.TeamServerEnabled || force) {
			if !label
				label := this.getLabel("TeamServer.Toggle")

			trayMessage(label, translate("State: Off"))

			this.disconnect(true, true)

			A_IconTip := (string2Values(".", A_ScriptName)[1])

			this.iTeamServerEnabled := false

			this.updateActions(kSessionUnknown)

			this.updateTrayLabel(label, false)

			this.updateActions(kSessionUnknown)
		}
	}

	parseObject(properties) {
		local result := CaseInsenseMap()
		local property

		properties := StrReplace(properties, "`r", "")

		loop Parse, properties, "`n" {
			property := string2Values("=", A_LoopField)

			result[property[1]] := property[2]
		}

		return result
	}

	setSession(team, driver, session) {
		this.iTeam := ((team && (team != "")) ? team : false)
		this.iDriver := ((driver && (driver != "")) ? driver : false)
		this.iSession := ((session && (session != "")) ? session : false)

		this.iDriverForName := false
		this.iDriverSurName := false
		this.iDriverNickName := false
	}

	tryConnect() {
		local settings, serverURL, serverToken, teamIdentifier, driverIdentifier, sessionIdentifier

		if !this.Connected[true] {
			settings := readMultiMap(getFileName("Race.settings", kUserConfigDirectory))

			serverURL := getMultiMapValue(settings, "Team Settings", "Server.URL", "")
			serverToken := getMultiMapValue(settings, "Team Settings", "Server.Token", "")
			teamIdentifier := getMultiMapValue(settings, "Team Settings", "Team.Identifier", false)
			driverIdentifier := getMultiMapValue(settings, "Team Settings", "Driver.Identifier", false)
			sessionIdentifier := getMultiMapValue(settings, "Team Settings", "Session.Identifier", false)

			if this.StartupSettings {
				serverURL := getMultiMapValue(this.StartupSettings, "Team Session", "Server.URL", serverURL)
				serverToken := getMultiMapValue(this.StartupSettings, "Team Session", "Server.Token", serverToken)
				teamIdentifier := getMultiMapValue(this.StartupSettings, "Team Session", "Team.Identifier", teamIdentifier)
				driverIdentifier := getMultiMapValue(this.StartupSettings, "Team Session", "Driver.Identifier", driverIdentifier)
				sessionIdentifier := getMultiMapValue(this.StartupSettings, "Team Session", "Session.Identifier", sessionIdentifier)
			}

			this.connect(serverURL, serverToken, teamIdentifier, driverIdentifier, sessionIdentifier, !kSilentMode)

			this.disconnect()
		}
	}

	connect(serverURL, serverToken, team, driver, session, verbose := false) {
		local driverObject

		this.disconnect()

		this.iServerURL := ((serverURL && (serverURL != "")) ? serverURL : false)
		this.iServerToken := ((serverToken && (serverToken != "")) ? serverToken : false)

		this.setSession(team, driver, session)

		this.LastMessage := ""
		this.iCachedObjects := CaseInsenseMap()

		this.keepAlive()

		if this.Connected[true] {
			if isLogLevel(kLogInfo)
				logMessage(kLogInfo, translate("Connected to the Team Server (URL: ") . serverURL . translate(", Token: ") . serverToken
								   . translate(", Team: ") . team . translate(", Driver: ") . driver . translate(", Session: ") . session . translate(")"))

			if verbose
				showMessage(translate("Successfully connected to the Team Server.") . "`n`n" . translate("Team: ") . this.Team[true] . "`n"
									. translate("Driver: ") . this.Driver[true] . "`n"
									. translate("Session: ") . this.Session[true]
						  , false, "Information.ico", 5000, "Center", "Bottom", 400, 120)

			A_IconTip := (string2Values(".", A_ScriptName)[1] . translate(" (Team: ") . this.Team[true] . translate(")"))
		}

		return (this.Connected[true] && this.Team && this.Driver && this.Session)
	}

	disconnect(leave := true, disconnect := false) {
		if (leave && this.SessionActive)
			this.leaveSession()

		if disconnect {
			this.iServerURL := false
			this.iServerToken := false

			this.iConnection := false

			this.iTeamName := ""
			this.iDriverName := ""
			this.iSessionName := ""

			this.LastMessage := ""

			this.iCachedObjects := CaseInsenseMap()

			this.keepAlive()
		}
	}

	getStintDriverName(stint, session := false) {
		local driver

		if (!session && this.SessionActive)
			session := this.Session

		if session {
			try {
				if isInteger(stint)
					stint := this.Connector.GetSessionStint(session, stint)

				driver := this.Connector.GetStintDriver(stint)

				if !this.iCachedObjects.Has(driver)
					this.iCachedObjects[driver] := this.parseObject(this.Connector.GetDriver(driver))

				driver := this.iCachedObjects[driver]

				return driverName(driver["ForName"], driver["SurName"], driver["NickName"])
			}
			catch Any as exception {
				this.LastMessage := (translate("Error while fetching stint data (Session: ") . session . translate(", Stint: ") . stint
								   . translate("), Exception: ") . (isObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)

				logError(exception)
			}
		}

		return false
	}

	getDriverForName(force := false) {
		local driver

		if (!this.iDriverForName && (force || this.TeamServerActive)) {
			try {
				if ((this.Connected || force) && !this.iCachedObjects.Has(this.Driver))
					this.iCachedObjects[this.Driver] := this.parseObject(this.Connector.GetDriver(this.Driver))

				driver := this.iCachedObjects[this.Driver]

				this.iDriverForName := driver["ForName"]
				this.iDriverSurName := driver["SurName"]
				this.iDriverNickName := driver["NickName"]

				if isLogLevel(kLogInfo)
					logMessage(kLogInfo, translate("Fetching Driver (Driver: ") . this.Driver . translate(", Name: ") . driver["ForName"] . A_Space . driver["SurName"] . translate(")"))
			}
			catch Any as exception {
				if !force {
					this.LastMessage := (translate("Error while fetching driver names (Driver: ") . this.Driver
									   . translate("), Exception: ") . (isObject(exception) ? exception.Message : exception))

					logMessage(kLogCritical, this.LastMessage)

					this.keepAlive()
				}

				logError(exception)
			}
		}

		return (this.iDriverForName ? this.iDriverForName : "")
	}

	getDriverSurName(force := false) {
		this.getDriverForName(force)

		return (this.iDriverSurName ? this.iDriverSurName : "")
	}

	getDriverNickName(force := false) {
		this.getDriverForName(force)

		return (this.iDriverNickName ? this.iDriverNickName : "")
	}

	startSession(simulator, car, track, duration, retries := 20, wait := 500) {
		local waitUntil := (A_TickCount + (wait * retries))

		if this.SessionActive
			this.leaveSession()

		if (this.TeamServerActive && !this.SessionActive) {
			if (isDebug() && isLogLevel(kLogDebug))
				showMessage("Starting team session: " . car . ", " . track)

			try {
				this.iLapData := CaseInsenseMap("Telemetry", CaseInsenseMap(), "Positions", CaseInsenseMap())
				this.iSimulator := simulator
				this.iCar := car
				this.iTrack := track

				loop retries
					try {
						this.Connector.StartSession(this.Session, duration, car, track)

						this.Connector.SetSessionValue(this.Session, "Simulator", simulator)
						this.Connector.SetSessionValue(this.Session, "Car", car)
						this.Connector.SetSessionValue(this.Session, "Track", track)
						this.Connector.SetSessionValue(this.Session, "Time", A_Now)

						this.iSessionActive := true

						if isLogLevel(kLogInfo)
							logMessage(kLogInfo, translate("Starting session (Session: ") . this.Session . translate(", Car: ") . car . translate(", Track: ") . track . translate(")"))

						break
					}
					catch Any as exception {
						if ((A_Index = retries) || (A_TickCount > waitUntil))
							throw exception
						else
							Sleep(wait)
					}
			}
			catch Any as exception {
				this.iSessionActive := false

				this.LastMessage := (translate("Error while starting session (Session: ") . this.Session . translate(", Car: ") . car
								   . translate(", Track: ") . track . translate("), Exception: ")
								   . (isObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)

				logError(exception)

				this.keepAlive()
			}
		}
	}

	finishSession(arguments*) {
		if ((arguments.Length > 0) && inList(["Logoff", "Shutdown"], arguments[1]))
			return false

		if this.TeamServerActive {
			if this.TelemetryCollector
				this.shutdownTelemetryCollector()

			try {
				if this.DriverActive {
					if (isDebug() && isLogLevel(kLogDebug))
						showMessage("Finishing team session")

					this.Connector.FinishSession(this.Session)

					if isLogLevel(kLogInfo)
						logMessage(kLogInfo, translate("Finishing session (Session: ") . this.Session . translate(")"))
				}
			}
			catch Any as exception {
				this.LastMessage := (translate("Error while finishing session (Session: ") . this.Session
								   . translate("), Exception: ") . (isObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)

				logError(exception)

				this.keepAlive()
			}
		}

		this.iLapData := CaseInsenseMap("Telemetry", CaseInsenseMap(), "Positions", CaseInsenseMap())
		this.iSessionActive := false
		this.iSimulator := false
		this.iCar := false
		this.iTrack := false
		this.iTrackLength := false

		return false
	}

	joinSession(simulator, car, track, lapNumber, duration := 0) {
		if this.TeamServerActive {
			if !this.SessionActive {
				if (lapNumber = 1) {
					if (isDebug() && isLogLevel(kLogDebug))
						showMessage("Creating team session: " . car . ", " . track)

					this.startSession(simulator, car, track, duration)
				}
				else {
					if (isDebug() && isLogLevel(kLogDebug))
						showMessage("Joining team session: " . car . ", " . track)

					this.iLapData := CaseInsenseMap("Telemetry", CaseInsenseMap(), "Positions", CaseInsenseMap())
					this.iSessionActive := true
					this.iSimulator := simulator
					this.iCar := car
					this.iTrack := track
				}

				if this.SessionActive {
					if isLogLevel(kLogInfo)
						logMessage(kLogInfo, translate("Starting stint (Session: ") . this.Session . translate(", Lap: ") . lapNumber . translate(")"))

					return this.addStint(lapNumber)
				}
				else
					return false
			}
		}
	}

	leaveSession() {
		if this.TelemetryCollector
			this.shutdownTelemetryCollector()

		if this.DriverActive {
			if (isDebug() && isLogLevel(kLogDebug))
				showMessage("Leaving team session")

			if isLogLevel(kLogInfo)
				logMessage(kLogInfo, translate("Leaving team session (Session: ") . this.Session . translate(")"))

			this.finishSession()
		}
		else {
			this.iLapData := CaseInsenseMap("Telemetry", CaseInsenseMap(), "Positions", CaseInsenseMap())
			this.iSessionActive := false
			this.iSimulator := false
			this.iCar := false
			this.iTrack := false
			this.iTrackLength := false
		}
	}

	getCurrentDriver(retries := 5, wait := 100) {
		local waitUntil := (A_TickCount + (wait * retries))
		local driver


		if this.SessionActive {
			try {
				loop retries
					try {
						driver := this.Connector.GetSessionDriver(this.Session)

						if isLogLevel(kLogInfo)
							logMessage(kLogInfo, translate("Requesting current driver (Session: ") . this.Session . translate(", Driver: ") . driver . translate(")"))

						return driver
					}
					catch Any as exception {
						if ((A_Index = retries) || (A_TickCount > waitUntil))
							throw exception
						else
							Sleep(wait)
					}
			}
			catch Any as exception {
				this.LastMessage := (translate("Error while requesting current driver session (Session: ") . this.Session
								   . translate("), Exception: ") . (isObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)

				logError(exception)

				return false
			}
		}
		else
			return false
	}

	getSessionValue(name, default := kUndefined, retries := 5, wait := 100) {
		local waitUntil := (A_TickCount + (wait * retries))
		local value

		if this.SessionActive {
			try {
				loop retries
					try {
						value := this.Connector.GetSessionValue(this.Session, name)

						if (isDebug() && isLogLevel(kLogDebug))
							showMessage("Fetching session value: " . name . " => " . value)

						if (isLogLevel(kLogInfo) && value && (value != ""))
							logMessage(kLogInfo, translate("Fetching session data (Session: ") . this.Session . translate(", Name: ") . name . translate("), Value:`n`n") . value . "`n")

						return value
					}
					catch Any as exception {
						if ((A_Index = retries) || (A_TickCount > waitUntil))
							throw exception
						else
							Sleep(wait)
					}
			}
			catch Any as exception {
				this.LastMessage := (translate("Error while fetching session data (Session: ") . this.Session . translate(", Name: ") . name
								   . translate("), Exception: ") . (isObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)

				logError(exception)
			}
		}

		return ((default != kUndefined) ? default : false)
	}

	setSessionValue(name, value, retries := 5, wait := 100) {
		local waitUntil := (A_TickCount + (wait * retries))

		if this.SessionActive {
			try {
				if (isDebug() && isLogLevel(kLogDebug))
					showMessage("Saving session value: " . name . " => " . value)

				loop retries
					try {
						if (!value || (value == "")) {
							this.Connector.DeleteSessionValue(this.Session, name)

							if isLogLevel(kLogInfo)
								logMessage(kLogInfo, translate("Deleting session data (Session: ") . this.Session . translate(", Name: ") . name . translate(")"))
						}
						else {
							this.Connector.SetSessionValue(this.Session, name, value)

							if isLogLevel(kLogInfo)
								logMessage(kLogInfo, translate("Storing session data (Session: ") . this.Session . translate(", Name: ") . name . translate("), Value:`n`n") . value . "`n")
						}

						break
					}
					catch Any as exception {
						if ((A_Index = retries) || (A_TickCount > waitUntil))
							throw exception
						else
							Sleep(wait)
					}
			}
			catch Any as exception {
				this.LastMessage := (translate("Error while storing session data (Session: ") . this.Session . translate(", Name: ") . name
								   . translate("), Exception: ") . (isObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)

				logError(exception)
			}
		}
	}

	getStintValue(stint, name, session := false, retries := 5, wait := 100) {
		local waitUntil := (A_TickCount + (wait * retries))
		local value

		if (!session && this.SessionActive)
			session := this.Session

		if session {
			try {
				loop retries
					try {
						if isInteger(stint)
							value := this.Connector.GetSessionStintValue(session, stint, name)
						else
							value := this.Connector.GetStintValue(stint, name)

						if (isDebug() && isLogLevel(kLogDebug))
							showMessage("Fetching value for " . stint . ": " . name . " => " . value)

						if (isLogLevel(kLogInfo) && value && (value != ""))
							logMessage(kLogInfo, translate("Fetching stint data (Session: ") . this.Session . translate(", Name: ") . name . translate("), Value:`n`n") . value . "`n")

						return value
					}
					catch Any as exception {
						if ((A_Index = retries) || (A_TickCount > waitUntil))
							throw exception
						else
							Sleep(wait)
					}
			}
			catch Any as exception {
				this.LastMessage := (translate("Error while fetching stint data (Session: ") . session . translate(", Stint: ") . stint
								   . translate(", Name: ") . name . translate("), Exception: ") . (isObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)

				logError(exception)
			}
		}

		return false
	}

	setStintValue(stint, name, value, session := false, retries := 5, wait := 100) {
		local waitUntil := (A_TickCount + (wait * retries))

		if (!session && this.SessionActive)
			session := this.Session

		if session {
			try {
				if (isDebug() && isLogLevel(kLogDebug))
					showMessage("Saving value for stint " . stint . ": " . name . " => " . value)

				loop retries
					try {
						if (!value || (value == "")) {
							if isInteger(stint)
								this.Connector.DeleteSessionStintValue(session, stint, name)
							else
								this.Connector.DeleteStintValue(stint, name, value)
						}
						else {
							if isInteger(stint)
								this.Connector.SetSessionStintValue(session, stint, name, value)
							else
								this.Connector.SetStintValue(stint, name, value)
						}

						if isLogLevel(kLogInfo)
							logMessage(kLogInfo, translate("Storing stint data (Session: ") . this.Session . translate(", Name: ") . name . translate("), Value:`n`n") . value . "`n")

						break
					}
					catch Any as exception {
						if ((A_Index = retries) || (A_TickCount > waitUntil))
							throw exception
						else
							Sleep(wait)
					}
			}
			catch Any as exception {
				this.LastMessage := (translate("Error while storing stint data (Session: ") . session . translate(", Stint: ") . stint
								   . translate(", Name: ") . name . translate("), Exception: ") . (isObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)

				logError(exception)
			}
		}
	}

	getStintSession(stint, session := false, retries := 5, wait := 100) {
		local waitUntil := (A_TickCount + (wait * retries))

		if (!session && this.SessionActive)
			session := this.Session

		if session {
			try {
				loop retries
					try {
						if isInteger(stint)
							stint := this.Connector.GetSessionStint(session, stint)

						return this.Connector.GetStintSession(stint)
					}
					catch Any as exception {
						if ((A_Index = retries) || (A_TickCount > waitUntil))
							throw exception
						else
							Sleep(wait)
					}
			}
			catch Any as exception {
				this.LastMessage := (translate("Error while fetching stint data (Session: ") . session . translate(", Stint: ") . stint
								   . translate("), Exception: ") . (isObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)

				logError(exception)
			}
		}

		return false
	}

	getCurrentLap(session := false, retries := 5, wait := 100) {
		local waitUntil := (A_TickCount + (wait * retries))
		local lap, lapNr

		if (!session && this.SessionActive)
			session := this.Session

		if session {
			try {
				loop retries
					try {
						lap := this.Connector.GetSessionLastLap(session)

						if (lap && (lap != "") && (lap != kNull)) {
							if !this.iCachedObjects.Has(lap)
								this.iCachedObjects[lap] := this.parseObject(this.Connector.GetLap(lap))

							lapNr := this.iCachedObjects[lap]["Nr"]

							if isLogLevel(kLogInfo)
								logMessage(kLogInfo, translate("Fetching lap number (Session: ") . this.Session . translate(", Lap: ") . lap . translate(", Number: ") . lapNr . translate(")"))

							return lapNr
						}
						else
							return false
					}
					catch Any as exception {
						if ((A_Index = retries) || (A_TickCount > waitUntil))
							throw exception
						else
							Sleep(wait)
					}
			}
			catch Any as exception {
				this.LastMessage := (translate("Error while fetching lap data (Session: ") . session
								   . translate("), Exception: ") . (isObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)

				logError(exception)
			}
		}

		return false
	}

	getLapStint(lap, session := false, retries := 5, wait := 100) {
		local waitUntil := (A_TickCount + (wait * retries))

		if (!session && this.SessionActive)
			session := this.Session

		if session {
			try {
				if (lap = kNull)
					throw "Not a valid lap..."

				loop retries
					try {
						if isInteger(lap)
							lap := this.Connector.GetSessionLap(session, lap)

						return this.Connector.GetLapStint(lap)
					}
					catch Any as exception {
						if ((A_Index = retries) || (A_TickCount > waitUntil))
							throw exception
						else
							Sleep(wait)
					}
			}
			catch Any as exception {
				this.LastMessage := (translate("Error while fetching lap data (Session: ") . session . translate(", Lap: ") . lap
								   . translate("), Exception: ") . (isObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)

				logError(exception)
			}
		}

		return false
	}

	getLapValue(lap, name, session := false, retries := 5, wait := 100) {
		local waitUntil := (A_TickCount + (wait * retries))
		local value

		if (!session && this.SessionActive)
			session := this.Session

		if session {
			try {
				if (lap = kNull)
					throw "Not a valid lap..."

				loop retries
					try {
						if isInteger(lap)
							value := this.Connector.GetSessionLapValue(session, lap, name)
						else
							value := this.Connector.GetLapValue(lap, name)

						if (isDebug() && isLogLevel(kLogDebug))
							showMessage("Fetching value for " . lap . ": " . name . " => " . value)

						if (isLogLevel(kLogInfo) && value && (value != ""))
							logMessage(kLogInfo, translate("Fetching lap data (Session: ") . this.Session . translate(", Lap: ") . lap . translate(", Name: ") . name . translate("), Value:`n`n") . value . "`n")

						return value
					}
					catch Any as exception {
						if ((A_Index = retries) || (A_TickCount > waitUntil))
							throw exception
						else
							Sleep(wait)
					}
			}
			catch Any as exception {
				this.LastMessage := (translate("Error while fetching lap data (Session: ") . session . translate(", Lap: ") . lap
								   . translate(", Name: ") . name . translate("), Exception: ") . (isObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)

				logError(exception)
			}
		}

		return false
	}

	setLapValue(lap, name, value, session := false, retries := 5, wait := 100) {
		local waitUntil := (A_TickCount + (wait * retries))

		if (!session && this.SessionActive)
			session := this.Session

		if session {
			try {
				if (isDebug() && isLogLevel(kLogDebug))
					showMessage("Saving value for lap " . lap . ": " . name . " => " . value)

				loop retries
					try {
						if (!value || (value == "")) {
							if isInteger(lap)
								this.Connector.DeleteSessionLapValue(session, lap, name)
							else
								this.Connector.DeleteLapValue(lap, name, value)

							if isLogLevel(kLogInfo)
								logMessage(kLogInfo, translate("Deleting lap data (Session: ") . this.Session . translate(", Lap: ") . lap . translate(", Name: ") . name . translate(")"))
						}
						else {
							if isInteger(lap)
								this.Connector.SetSessionLapValue(session, lap, name, value)
							else
								this.Connector.SetLapValue(lap, name, value)

							if isLogLevel(kLogInfo)
								logMessage(kLogInfo, translate("Storing lap data (Session: ") . this.Session . translate(", Lap: ") . lap . translate(", Name: ") . name . translate("), Value:`n`n") . value . "`n")
						}

						break
					}
					catch Any as exception {
						if ((A_Index = retries) || (A_TickCount > waitUntil))
							throw exception
						else
							Sleep(wait)
					}
			}
			catch Any as exception {
				this.LastMessage := (translate("Error while storing lap data (Session: ") . session . translate(", Lap: ") . lap
								   . translate(", Name: ") . name . translate("), Exception: ") . (isObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)

				logError(exception)
			}
		}
	}

	startupTelemetryCollector(provider, directory := false) {
		local loadedLaps := CaseInsenseMap()

		updateTelemetry() {
			local newLaps := []
			local ignore, candidate, lap, lastLap

			if this.SessionActive {
				loop Files, this.TelemetryDirectory . "\*.telemetry" {
					lap := StrReplace(StrReplace(A_LoopFileName, "Lap ", ""), ".telemetry", "")

					if !loadedLaps.Has(lap)
						newLaps.Push(lap)
				}

				if (newLaps.Length > 0) {
					bubbleSort(&newLaps)

					lastLap := newLaps[newLaps.Length]

					for ignore, lap in newLaps {
						if (lap > (lastLap - 4)) {
							try {
								this.setLapValue(lap, "Lap Telemetry", FileRead(this.TelemetryDirectory . "\Lap " . lap . ".telemetry"))
								this.setSessionValue("HasTelemetry", true)
								
								loadedLaps[lap] := true
							}
							catch Any as exception {
								logError(exception)
							}
						}
						else
							loadedLaps[lap] := true
					}

					try {
						if (lastLap > 4)
							this.setLapValue(lastLap - 4, "Lap Telemetry", false)
					}
					catch Any as exception {
						logError(exception)
					}
				}
			}
		}

		if directory
			this.iTelemetryDirectory := normalizeDirectoryPath(directory)

		if (this.TelemetryDirectory && !this.TelemetryCollector && (this.TrackLength > 0)) {
			DirCreate(this.TelemetryDirectory)

			this.iTelemetryCollector := TelemetryCollector(provider, this.TelemetryDirectory, this.Simulator, this.Track, this.TrackLength)

			this.iTelemetryCollector.startup()

			this.iCollectorTask := PeriodicTask(updateTelemetry, 20000, kLowPriority)

			this.iCollectorTask.start()
		}
	}

	shutdownTelemetryCollector() {
		if this.TelemetryCollector
			this.TelemetryCollector.shutdown()

		if this.iCollectorTask
			this.iCollectorTask.stop()

		this.iTelemetryCollector := false
		this.iCollectorTask := false
	}

	addStint(lapNumber, retries := 20, wait := 500) {
		local waitUntil := (A_TickCount + (wait * retries))
		local stint

		if this.TeamServerActive {
			try {
				if !this.SessionActive
					throw "Cannot add a stint to an inactive session..."

				if (isDebug() && isLogLevel(kLogDebug))
					showMessage("Updating stint in lap " . lapNumber . " for team session")

				loop retries
					try {
						stint := this.Connector.StartStint(this.Session, this.Driver, lapNumber)

						this.Connector.SetStintValue(stint, "Time", A_Now)
						this.Connector.SetStintValue(stint, "ID", this.ID)

						break
					}
					catch Any as exception {
						if ((A_Index = retries) || (A_TickCount > waitUntil))
							throw exception
						else
							Sleep(wait)
					}

				return stint
			}
			catch Any as exception {
				this.LastMessage := (translate("Error while starting stint (Session: ") . this.Session . translate(", Driver: ") . this.Driver
								   . translate(", Lap: ") . lapNumber . translate("), Exception: ") . (isObject(exception) ? exception.Message :  exception))

				logMessage(kLogCritical, this.LastMessage)

				logError(exception)

				this.keepAlive()
			}
		}
	}

	addLap(lapNumber, telemetryData, standingsData, retries := 10, wait := 500) {
		local waitUntil := (A_TickCount + (wait * retries))
		local driverForName, driverSurName, driverNickName, stint, simulator, car, track, lap
		local teamServerConfig, telemetryDirectory

		if this.TeamServerActive {
			try {
				driverForName := getMultiMapValue(telemetryData, "Stint Data", "DriverForname", "John")
				driverSurName := getMultiMapValue(telemetryData, "Stint Data", "DriverSurname", "Doe")
				driverNickName := getMultiMapValue(telemetryData, "Stint Data", "DriverNickname", "JD")

				if (isDebug() && isLogLevel(kLogDebug)) {
					showMessage("Updating lap for team session: " . lapNumber)

					if (isDevelopment() && ((this.DriverForName != driverForName) || (this.DriverSurName != driverSurName)))
						throw "Driver inconsistency detected..."
				}

				stint := false

				loop retries
					try {
						if !this.SessionActive {
							simulator := getMultiMapValue(telemetryData, "Session Data", "Simulator", "Unknown")
							car := getMultiMapValue(telemetryData, "Session Data", "Car", "Unknown")
							track := getMultiMapValue(telemetryData, "Session Data", "Track", "Unknown")

							SessionDatabase.registerDriver(simulator, this.ID, driverName(driverForName, driverSurName, driverNickName))

							stint := this.joinSession(simulator, car, track, lapNumber)
						}
						else if !this.DriverActive
							stint := this.addStint(lapNumber)
						else
							stint := this.Connector.GetSessionCurrentStint(this.Session)

						if !stint
							throw "No stint started..."

						if !this.TrackLength
							this.iTrackLength := getMultiMapValue(telemetryData, "Track Data", "Length"
																, getMultiMapValue(standingsData, "Track Data", "Length", 0))

						lap := this.Connector.CreateLap(stint, lapNumber)

						if (telemetryData && (telemetryData.Count > 0) && !this.iLapData["Telemetry"].Has(lapNumber)) {
							telemetryText := printMultiMap(telemetryData)

							if (isDebug() && isLogLevel(kLogDebug))
								showMessage("Setting telemetry data for lap " . lapNumber . ": " . telemetryText)

							this.setLapValue(lapNumber, "Telemetry Data", telemetryText)

							this.iLapData["Telemetry"][lapNumber] := true
						}

						break
					}
					catch Any as exception {
						if ((A_Index = retries) || (A_TickCount > waitUntil))
							throw exception
						else
							Sleep(wait)
					}

				if (standingsData && (standingsData.Count > 0) && !this.iLapData["Positions"].Has(lapNumber)) {
					standingsData := printMultiMap(standingsData)

					if (isDebug() && isLogLevel(kLogDebug))
						showMessage("Setting standings data for lap " . lapNumber . ": " . standingsData)

					this.setLapValue(lapNumber, "Positions Data", standingsData)

					this.iLapData["Positions"][lapNumber] := true
				}

				teamServerConfig := readMultiMap(kUserConfigDirectory . "Team Server.ini")

				if getMultiMapValue(teamServerConfig, "Telemetry", "Collect") {
					telemetryDirectory := getMultiMapValue(teamServerConfig, "Telemetry", "Directory", false)

					if telemetryDirectory {
						if (!this.TelemetryCollector || (normalizeDirectoryPath(telemetryDirectory) != this.TelemetryDirectory)) {
							if this.TelemetryCollector
								this.shutdownTelemetryCollector()

							this.startupTelemetryCollector(getMultiMapValue(teamServerConfig, "Telemetry", "Provider", "Internal")
														 , normalizeDirectoryPath(telemetryDirectory))
						}
					}
					else if this.TelemetryCollector
						this.shutdownTelemetryCollector()
				}
				else if this.TelemetryCollector
					this.shutdownTelemetryCollector()
			}
			catch Any as exception {
				this.LastMessage := (translate("Error while updating a lap (Session: ") . this.Session . translate(", Lap: ") . lapNumber
								   . translate("), Exception: ") . (isObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)

				logError(exception)
			}
		}
	}

	updateLap(lapNumber, running, data, telemetryData, standingsData) {
		if this.TeamServerActive
			this.setLapValue(lapNumber, "Data Update", printMultiMap(data))
	}

	keepAlive(start := false) {
		local nextPing := 10000
		local invalid := false
		local connection := false
		local driverObject

		static keepAliveTask := false
		static initialized := false

		if (this.Connector && this.ServerURL && this.ServerToken) {
			try {
				if this.Connected[true]
					try {
						this.State["Stalled"] := !this.Connector.KeepAlive(this.Connection)
					}
					catch Any as exception {
						logError(exception)

						this.State["Stalled"] := true
					}

				if !this.Connected {
					if (!initialized && this.ServerURL && this.ServerToken) {
						this.Connector.Initialize(this.ServerURL, this.ServerToken)

						initialized := true
					}

					if !this.State.Has("ServerURL")
						this.State["ServerURL"] := "Invalid"

					if !this.State.Has("SessionToken")
						this.State["SessionToken"] := "Invalid"

					if !this.State.Has("Team")
						this.State["Team"] := "Invalid"

					if !this.State.Has("Driver")
						this.State["Driver"] := "Invalid"

					if !this.State.Has("Session")
						this.State["Session"] := "Invalid"

					if (this.Driver && this.Session)
						connection := this.Connector.Connect(this.ServerToken
														   , SessionDatabase().ID
														   , driverName(this.DriverForName[true]
																	  , this.DriverSurName[true]
																	  , this.DriverNickName[true])
														   , "Driver", this.Session ? this.Session : "")

					this.State["ServerURL"] := this.ServerURL
					this.State["SessionToken"] := this.ServerToken

					if connection {
						try {
							if !this.iCachedObjects.Has(this.Team)
								this.iCachedObjects[this.Team] := this.parseObject(this.Connector.GetTeam(this.Team))

							this.iTeamName := this.iCachedObjects[this.Team]["Name"]

							this.State["Team"] := this.Team[true]
						}
						catch Any as exception {
							logError(exception)

							invalid := exception
						}

						try {
							if !this.iCachedObjects.Has(this.Driver)
								this.iCachedObjects[this.Driver] := this.parseObject(this.Connector.GetDriver(this.Driver))

							driverObject := this.iCachedObjects[this.Driver]
							this.iDriverName := (driverObject["ForName"] . A_Space . driverObject["SurName"])

							this.State["Driver"] := this.Driver[true]
						}
						catch Any as exception {
							logError(exception)

							invalid := exception
						}

						try {
							if !this.iCachedObjects.Has(this.Session)
								this.iCachedObjects[this.Session] := this.parseObject(this.Connector.GetSession(this.Session))

							this.iSessionName := this.iCachedObjects[this.Session]["Name"]

							this.State["Session"] := this.Session[true]
						}
						catch Any as exception {
							logError(exception)

							invalid := exception
						}

						if invalid
							throw invalid
						else {
							A_IconTip := (string2Values(".", A_ScriptName)[1] . translate(" (Team: ") . this.Team[true] . translate(")"))

							this.iConnection := connection
						}
					}

					this.State["Stalled"] := false
				}
			}
			catch Any as exception {
				A_IconTip := (string2Values(".", A_ScriptName)[1] . translate(" (Team: Error)"))

				this.iDriverName := ""
				this.iTeamName := ""
				this.iSessionName := ""

				logError(exception)

				this.LastMessage := (translate("Cannot connect to the Team Server (URL: ") . this.ServerURL
								   . translate(", Token: ") . this.ServerToken
								   . translate("), Exception: ") . (isObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)

				this.iConnection := false
				this.State["Stalled"] := false
			}
		}
		else {
			this.iConnection := false

			this.State["ServerURL"] := "Invalid"
			this.State["SessionToken"] := "Invalid"
			this.State["Stalled"] := false
		}

		if this.Stalled
			this.LastMessage := (translate("Lost connection to the Team Server (URL: ") . this.ServerURL
							   . translate(", Token: ") . this.ServerToken . translate(")"))
		else if this.Connected
			this.LastMessage := ""

		if start {
			keepAliveTask := PeriodicTask(ObjBindMethod(this, "keepAlive"), 10000, kLowPriority)

			keepAliveTask.start()
		}
		else if keepAliveTask
			keepAliveTask.Sleep := (this.Connected ? 60000 : 1000)

		return false
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeTeamServerPlugin() {
	local controller := SimulatorController.Instance

	TeamServerPlugin(controller, kTeamServerPlugin, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                        Controller Action Section                        ;;;
;;;-------------------------------------------------------------------------;;;

enableTeamServer() {
	local controller := SimulatorController.Instance
	local plugin := controller.findPlugin(kTeamServerPlugin)

	protectionOn()

	try {
		if (plugin && controller.isActive(plugin))
			plugin.enableTeamServer()
	}
	finally {
		protectionOff()
	}
}

disableTeamServer() {
	local controller := SimulatorController.Instance
	local plugin := controller.findPlugin(kTeamServerPlugin)

	protectionOn()

	try {
		if (plugin && controller.isActive(plugin))
			plugin.disableTeamServer()
	}
	finally {
		protectionOff()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeTeamServerPlugin()
