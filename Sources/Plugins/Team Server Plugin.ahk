;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Team Server Plugin              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Task.ahk
#Include ..\Assistants\Libraries\SessionDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kSessionFinished := 0
global kSessionPaused := -1
global kSessionOther := 1
global kSessionPractice := 2
global kSessionQualification := 3
global kSessionRace := 4

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

	iState := {}

	iSimulator := false
	iTeam := false
	iTeamName := ""
	iDriver := false
	iDriverName := ""
	iSession := false
	iSessionName := ""

	iCachedObjects := {}

	iDriverForName := false
	iDriverSurName := false
	iDriverNickName := false

	iTeamServerEnabled := false

	iSessionActive := false
	iLapData := {Telemetry: {}, Positions: {}}

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

			if (plugin.TeamServerEnabled && ((trigger = "On") || (trigger = "Off") || (trigger == "Push"))) {
				plugin.disableTeamServer(plugin.actionLabel(this))

				function.setLabel(plugin.actionLabel(this), "Black")
			}
			else if (!plugin.TeamServerEnabled && ((trigger = "On") || (trigger == "Push"))) {
				plugin.enableTeamServer(plugin.actionLabel(this))

				function.setLabel(plugin.actionLabel(this), "Green")
			}
		}
	}

	class RaceSettingsAction extends ControllerAction {
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
			local exePath := kBinariesDirectory . "Race Settings.exe"

			try {
				Run "%exePath%", %kBinariesDirectory%
			}
			catch exception {
				logMessage(kLogCritical, translate("Cannot start the Race Settings tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

				showMessage(substituteVariables(translate("Cannot start the Race Settings tool (%exePath%) - please check the configuration..."), {exePath: exePath})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}
	}

	class RaceCenterAction extends ControllerAction {
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
			local exePath := kBinariesDirectory . "Race Center.exe"

			try {
				Run "%exePath%", %kBinariesDirectory%
			}
			catch exception {
				logMessage(kLogCritical, translate("Cannot start the Race Center tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

				showMessage(substituteVariables(translate("Cannot start the Race Center tool (%exePath%) - please check the configuration..."), {exePath: exePath})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}
	}

	ID[] {
		Get {
			return this.Controller.ID
		}
	}

	Connector[] {
		Get {
			return this.iConnector
		}
	}

	ServerURL[] {
		Get {
			return ((this.iServerURL && (this.iServerURL != "")) ? this.iServerURL : false)
		}
	}

	ServerToken[] {
		Get {
			return ((this.iServerToken && (this.iServerToken != "")) ? this.iServerToken : false)
		}
	}

	Connection[] {
		Get {
			return this.iConnection
		}
	}

	Connected[] {
		Get {
			return (this.Connection != false)
		}
	}

	LastMessage[] {
		Get {
			return this.iLastMessage
		}

		Set {
			return (this.iLastMessage := StrReplace(value, "`n", A_Space))
		}
	}

	State[key := false] {
		Get {
			return (key ? this.iState[key] : this.iState)
		}

		Set {
			return (key ? (this.iState[key] := value) : (this.iState := value))
		}
	}

	Stalled[] {
		Get {
			return (this.State.HasKey("Stalled") ? this.State["Stalled"] : false)
		}
	}

	Simulator[] {
		Get {
			return this.iSimulator
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

	DriverForName[ignore := false] {
		Get {
			return this.getDriverForName(ignore)
		}
	}

	DriverSurName[ignore := false] {
		Get {
			return this.getDriverSurName(ignore)
		}
	}

	DriverNickName[ignore := false] {
		Get {
			return this.getDriverNickName(ignore)
		}
	}

	TeamServerEnabled[] {
		Get {
			return this.iTeamServerEnabled
		}
	}

	TeamServerActive[] {
		Get {
			return (this.Connected && this.TeamServerEnabled && this.Team && this.Driver && this.Session)
		}
	}

	SessionActive[] {
		Get {
			return (this.TeamServerActive && this.iSessionActive)
		}
	}

	DriverActive[] {
		Get {
			local currentDriver := this.getCurrentDriver()

			return (this.SessionActive && (currentDriver == this.Driver))
		}
	}

	__New(controller, name, configuration := false, register := true) {
		local dllName := "Team Server Connector.dll"
		local dllFile := kBinariesDirectory . dllName
		local teamServerToggle, arguments, openRaceSettings, openRaceCenter

		try {
			if (!FileExist(dllFile)) {
				logMessage(kLogCritical, translate("Team Server Connector.dll not found in ") . kBinariesDirectory)

				throw "Unable to find Team Server Connector.dll in " . kBinariesDirectory . "..."
			}

			this.iConnector := CLR_LoadLibrary(dllFile).CreateInstance("TeamServer.TeamServerConnector")
		}
		catch exception {
			logMessage(kLogCritical, translate("Error while initializing Team Server Connector - please rebuild the applications"))

			showMessage(translate("Error while initializing Team Server Connector - please rebuild the applications") . translate("...")
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}

		base.__New(controller, name, configuration, false)

		if (this.Active || isDebug()) {
			teamServerToggle := this.getArgumentValue("teamServer", false)

			if teamServerToggle {
				arguments := string2Values(A_Space, teamServerToggle)

				if (arguments.Length() == 0)
					arguments := ["On"]

				if ((arguments.Length() == 1) && !inList(["On", "Off"], arguments[1]))
					arguments.InsertAt(1, "Off")

				this.iTeamServerEnabled := (arguments[1] = "On")

				if (arguments.Length() > 1)
					this.createTeamServerAction(controller, "TeamServer", arguments[2])
			}
			else
				this.iTeamServerEnabled := false

			openRaceSettings := this.getArgumentValue("openRaceSettings", false)

			if openRaceSettings
				this.createTeamServerAction(controller, "RaceSettingsOpen", openRaceSettings)

			openRaceCenter := this.getArgumentValue("openRaceCenter", false)

			if openRaceCenter
				this.createTeamServerAction(controller, "RaceCenterOpen", openRaceCenter)

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

				this.registerAction(new this.TeamServerToggleAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor)))
			}
			else if (action = "RaceSettingsOpen") {
				descriptor := ConfigurationItem.descriptor(action, "Activate")

				this.registerAction(new this.RaceSettingsAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor)))
			}
			else if (action = "RaceSettingsOpen") {
				descriptor := ConfigurationItem.descriptor(action, "Activate")

				this.registerAction(new this.RaceCenterAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor)))
			}
			else
				logMessage(kLogWarn, translate("Action """) . action . translate(""" not found in plugin ") . translate(this.Plugin) . translate(" - please check the configuration"))
		}
		else
			this.logFunctionNotFound(actionFunction)
	}

	writeDriversState(state) {
		local connectedDrivers := []
		local ignore, connection

		try {
			for ignore, connection in string2Values(";", this.Connector.GetSessionConnections(this.Session)) {
				if !this.iCachedObjects.HasKey(connection)
					this.iCachedObjects[connection] := this.parseObject(this.Connector.GetConnection(connection))

				connection := this.iCachedObjects[connection]

				if (connection.Name && (connection.Name != "") && (connection.Type = "Driver")
									&& !inList(connectedDrivers, connection.Name))
					connectedDrivers.Push(connection.Name)
			}

			state.Push("Drivers: " . values2String("|", connectedDrivers*))
		}
		catch exception {
			logError(exception)
		}
	}

	writeStintState(state) {
		local stint, lap, driver

		if this.Connected
			try {
				stint := this.Connector.GetSessionCurrentStint(this.Session)

				if (stint && (stint != "")) {
					if !this.iCachedObjects.HasKey(stint)
						this.iCachedObjects[stint] := this.parseObject(this.Connector.GetStint(stint))

					lap := this.Connector.GetSessionLastLap(this.Session)

					if !this.iCachedObjects.HasKey(lap)
						this.iCachedObjects[lap] := this.parseObject(this.Connector.GetLap(lap))

					driver := this.Connector.GetStintDriver(stint)

					if !this.iCachedObjects.HasKey(driver)
						this.iCachedObjects[driver] := this.parseObject(this.Connector.GetDriver(driver))

					state.Push("StintNr: " . this.iCachedObjects[stint].Nr)
					state.Push("StintLap: " . this.iCachedObjects[lap].Nr)

					driver := this.iCachedObjects[driver]

					state.Push("StintDriver: " . computeDriverName(driver.ForName, driver.SurName, driver.NickName))
				}
			}
			catch exception {
				logError(exception)
			}
	}

	writePluginState(configuration) {
		local driverMismatch := false
		local key, value, teamServerState

		if this.Active {
			if this.TeamServerEnabled {
				if this.Connected {
					if (this.Stalled || this.LastMessage) {
						setConfigurationValue(configuration, this.Plugin, "State", "Critical")

						setConfigurationValue(configuration, this.Plugin, "Information", translate("Message: ") . this.LastMessage)
					}
					else {
						if (this.State["Driver"] = "Mismatch") {
							setConfigurationValue(configuration, this.Plugin, "State", "Critical")

							driverMismatch := true
						}
						else
							setConfigurationValue(configuration, this.Plugin, "State", "Active")

						setConfigurationValue(configuration, this.Plugin, "Information"
											, values2String("; ", translate("Team: ") . this.Team[true]
																, translate("Driver: ") . this.Driver[true] . (driverMismatch ? translate(" (No match)") : "")
																, translate("Session: ") . this.Session[true]))
					}
				}
				else if this.Session {
					setConfigurationValue(configuration, this.Plugin, "State", "Critical")

					setConfigurationValue(configuration, this.Plugin, "Information", translate("Message: ") . this.LastMessage)
				}
				else {
					setConfigurationValue(configuration, this.Plugin, "State", "Warning")

					setConfigurationValue(configuration, this.Plugin, "Information", translate("Message: ") . translate("No valid team session configured"))
				}

				teamServerState := []

				for key, value in this.State
					teamServerState.Push(key . ": " . value)

				this.writeDriversState(teamServerState)
				this.writeStintState(teamServerState)

				setConfigurationValue(configuration, this.Plugin, "Properties", values2String("; ", teamServerState*))
			}
			else
				setConfigurationValue(configuration, this.Plugin, "State", "Disabled")
		}
		else
			base.writePluginState(configuration)
	}

	activate() {
		base.activate()

		this.updateActions(kSessionFinished)
	}

	updateActions(session) {
		local ignore, theAction

		for ignore, theAction in this.Actions
			if isInstance(theAction, TeamServerPlugin.TeamServerToggleAction) {
				theAction.Function.enable(kAllTrigger, theAction)
				theAction.Function.setLabel(this.actionLabel(theAction), this.TeamServerEnabled ? "Green" : "Black")
			}
			else if isInstance(theAction, TeamServerPlugin.RaceSettingsAction) {
				theAction.Function.enable(kAllTrigger, theAction)
				theAction.Function.setLabel(theAction.Label)
			}
	}

	toggleTeamServer() {
		if this.TeamServerEnabled
			this.disableTeamServer()
		else
			this.enableTeamServer()
	}

	updateTrayLabel(label, enabled) {
		local callback, index

		static hasTrayMenu := false

		label := StrReplace(label, "`n", A_Space)

		if !hasTrayMenu {
			callback := ObjBindMethod(this, "toggleTeamServer")

			Menu Tray, Insert, 1&
			Menu Tray, Insert, 1&, %label%, %callback%

			hasTrayMenu := true
		}

		if enabled
			Menu Tray, Check, %label%
		else
			Menu Tray, Uncheck, %label%
	}

	enableTeamServer(label := false, force := false) {
		if (!this.TeamServerEnabled || force) {
			if !label
				label := this.getLabel("TeamServer.Toggle")

			trayMessage(label, translate("State: On"))

			this.iTeamServerEnabled := true

			Task.startTask(ObjBindMethod(this, "tryConnect"), 2000, kLowPriority)

			this.updateActions(kSessionFinished)

			this.updateTrayLabel(label, true)
		}
	}

	disableTeamServer(label := false, force := false) {
		if (this.TeamServerEnabled || force) {
			if !label
				label := this.getLabel("TeamServer.Toggle")

			trayMessage(label, translate("State: Off"))

			this.disconnect(true, true)

			Menu Tray, Tip, % string2Values(".", A_ScriptName)[1]

			this.iTeamServerEnabled := false

			this.updateActions(kSessionFinished)

			this.updateTrayLabel(label, false)
		}
	}

	parseObject(properties) {
		local result := {}
		local property

		properties := StrReplace(properties, "`r", "")

		loop Parse, properties, `n
		{
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

		if !this.Connected {
			settings := readConfiguration(getFileName("Race.settings", kUserConfigDirectory))
			serverURL := getConfigurationValue(settings, "Team Settings", "Server.URL", "")
			serverToken := getConfigurationValue(settings, "Team Settings", "Server.Token", "")
			teamIdentifier := getConfigurationValue(settings, "Team Settings", "Team.Identifier", false)
			driverIdentifier := getConfigurationValue(settings, "Team Settings", "Driver.Identifier", false)
			sessionIdentifier := getConfigurationValue(settings, "Team Settings", "Session.Identifier", false)

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
		this.iCachedObjects := {}

		this.keepAlive()

		if this.Connected {
			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, translate("Connected to the Team Server (URL: ") . serverURL . translate(", Token: ") . serverToken
								   . translate(", Team: ") . team . translate(", Driver: ") . driver . translate(", Session: ") . session . translate(")"))

			if verbose
				showMessage(translate("Successfully connected to the Team Server.") . "`n`n" . translate("Team: ") . this.Team[true] . "`n"
						  . translate("Driver: ") . this.Driver[true] . "`n" . translate("Session: ") . this.Session[true]
						  , false, "Information.png", 5000, "Center", "Bottom", 400, 120)

			Menu Tray, Tip, % string2Values(".", A_ScriptName)[1] . translate(" (Team: ") . this.Team[true] . translate(")")
		}

		return (this.Connected && this.Team && this.Driver && this.Session)
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

			this.iCachedObjects := {}

			this.keepAlive()
		}
	}

	getStintDriverName(stint, session := false) {
		local driver

		if (!session && this.SessionActive)
			session := this.Session

		if session {
			try {
				if stint is Integer
					stint := this.Connector.GetSessionStint(session, stint)

				driver := this.Connector.GetStintDriver(stint)

				if !this.iCachedObjects.HasKey(driver)
					this.iCachedObjects[driver] := this.Connector.GetDriver(driver)

				driver := this.iCachedObjects[driver]

				return computeDriverName(driver.ForName, driver.SurName, driver.NickName)
			}
			catch exception {
				this.LastMessage := (translate("Error while fetching stint data (Session: ") . session . translate(", Stint: ") . stint
								   . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)
			}
		}

		return false
	}

	getDriverForName(ignore := false) {
		local driver

		if (!this.iDriverForName && (ignore || this.TeamServerActive)) {
			try {
				if !this.iCachedObjects.HasKey(this.Driver)
					this.iCachedObjects[this.Driver] := this.parseObject(this.Connector.GetDriver(this.Driver))

				driver := this.iCachedObjects[this.Driver]

				this.iDriverForName := driver.ForName
				this.iDriverSurName := driver.SurName
				this.iDriverNickName := driver.NickName

				if (getLogLevel() <= kLogInfo)
					logMessage(kLogInfo, translate("Fetching Driver (Driver: ") . this.Driver . translate(", Name: ") . driver.ForName . A_Space . driver.SurName . translate(")"))
			}
			catch exception {
				if !ignore {
					this.LastMessage := (translate("Error while fetching driver names (Driver: ") . this.Driver
									   . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))

					logMessage(kLogCritical, this.LastMessage)

					this.keepAlive()
				}
			}
		}

		return (this.iDriverForName ? this.iDriverForName : "")
	}

	getDriverSurName(ignore := false) {
		this.getDriverForName(ignore)

		return (this.iDriverSurName ? this.iDriverSurName : "")
	}

	getDriverNickName(ignore := false) {
		this.getDriverForName(ignore)

		return (this.iDriverNickName ? this.iDriverNickName : "")
	}

	startSession(simulator, car, track, duration) {
		if this.SessionActive
			this.leaveSession()

		if (this.TeamServerActive && !this.SessionActive) {
			if isDebug()
				showMessage("Starting team session: " . car . ", " . track)

			try {
				this.iLapData := {Telemetry: {}, Positions: {}}
				this.iSimulator := simulator

				this.Connector.StartSession(this.Session, duration, car, track)

				this.Connector.SetSessionValue(this.Session, "Simulator", simulator)
				this.Connector.SetSessionValue(this.Session, "Car", car)
				this.Connector.SetSessionValue(this.Session, "Track", track)
				this.Connector.SetSessionValue(this.Session, "Time", A_Now)

				this.iSessionActive := true

				if (getLogLevel() <= kLogInfo)
					logMessage(kLogInfo, translate("Starting session (Session: ") . this.Session . translate(", Car: ") . car . translate(", Track: ") . track . translate(")"))
			}
			catch exception {
				this.iSessionActive := false

				this.LastMessage := (translate("Error while starting session (Session: ") . this.Session . translate(", Car: ") . car
								   . translate(", Track: ") . track . translate("), Exception: ")
								   . (IsObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)

				this.keepAlive()
			}
		}
	}

	finishSession() {
		if this.TeamServerActive {
			try {
				if this.DriverActive {
					if isDebug()
						showMessage("Finishing team session")

					this.Connector.FinishSession(this.Session)

					if (getLogLevel() <= kLogInfo)
						logMessage(kLogInfo, translate("Finishing session (Session: ") . this.Session . translate(")"))
				}
			}
			catch exception {
				this.LastMessage := (translate("Error while finishing session (Session: ") . this.Session
								   . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)

				this.keepAlive()
			}
		}

		this.iLapData := {Telemetry: {}, Positions: {}}
		this.iSessionActive := false
		this.iSimulator := false

		return false
	}

	joinSession(simulator, car, track, lapNumber, duration := 0) {
		if this.TeamServerActive {
			if !this.SessionActive {
				if (lapNumber = 1) {
					if isDebug()
						showMessage("Creating team session: " . car . ", " . track)

					this.startSession(simulator, car, track, duration)
				}
				else {
					if isDebug()
						showMessage("Joining team session: " . car . ", " . track)

					this.iLapData := {Telemetry: {}, Positions: {}}
					this.iSessionActive := true
					this.iSimulator := simulator
				}

				if (getLogLevel() <= kLogInfo)
					logMessage(kLogInfo, translate("Starting stint (Session: ") . this.Session . translate(", Lap: ") . lapNumber . translate(")"))

				return this.addStint(lapNumber)
			}
		}
	}

	leaveSession() {
		if this.DriverActive {
			if isDebug()
				showMessage("Leaving team session")

			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, translate("Leaving team session (Session: ") . this.Session . translate(")"))

			this.finishSession()
		}
		else {
			this.iLapData := {Telemetry: {}, Positions: {}}
			this.iSessionActive := false
			this.iSimulator := false
		}
	}

	getCurrentDriver() {
		local driver

		if this.SessionActive {
			try {
				driver := this.Connector.GetSessionDriver(this.Session)

				if (getLogLevel() <= kLogInfo)
					logMessage(kLogInfo, translate("Requesting current driver (Session: ") . this.Session . translate(", Driver: ") . driver . translate(")"))

				return driver
			}
			catch exception {
				this.LastMessage := (translate("Error while requesting current driver session (Session: ") . this.Session
								   . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)

				return false
			}
		}
		else
			return false
	}

	getSessionValue(name, default := "__Undefined__") {
		local value

		if this.SessionActive {
			try {
				value := this.Connector.GetSessionValue(this.Session, name)

				if isDebug()
					showMessage("Fetching session value: " . name . " => " . value)

				if ((getLogLevel() <= kLogInfo) && value && (value != ""))
					logMessage(kLogInfo, translate("Fetching session data (Session: ") . this.Session . translate(", Name: ") . name . translate("), Value:`n`n") . value . "`n")

				return value
			}
			catch exception {
				this.LastMessage := (translate("Error while fetching session data (Session: ") . this.Session . translate(", Name: ") . name
								   . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)
			}
		}

		return ((default != kUndefined) ? default : false)
	}

	setSessionValue(name, value) {
		if this.SessionActive {
			try {
				if isDebug()
					showMessage("Saving session value: " . name . " => " . value)

				if (!value || (value == "")) {
					this.Connector.DeleteSessionValue(this.Session, name)

					if (getLogLevel() <= kLogInfo)
						logMessage(kLogInfo, translate("Deleting session data (Session: ") . this.Session . translate(", Name: ") . name . translate(")"))
				}
				else {
					this.Connector.SetSessionValue(this.Session, name, value)

					if (getLogLevel() <= kLogInfo)
						logMessage(kLogInfo, translate("Storing session data (Session: ") . this.Session . translate(", Name: ") . name . translate("), Value:`n`n") . value . "`n")
				}
			}
			catch exception {
				this.LastMessage := (translate("Error while storing session data (Session: ") . this.Session . translate(", Name: ") . name
								   . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)
			}
		}
	}

	getStintValue(stint, name, session := false) {
		local value

		if (!session && this.SessionActive)
			session := this.Session

		if session {
			try {
				if stint is Integer
					value := this.Connector.GetSessionStintValue(session, stint, name)
				else
					value := this.Connector.GetStintValue(stint, name)

				if isDebug()
					showMessage("Fetching value for " . stint . ": " . name . " => " . value)

				if ((getLogLevel() <= kLogInfo) && value && (value != ""))
					logMessage(kLogInfo, translate("Fetching stint data (Session: ") . this.Session . translate(", Name: ") . name . translate("), Value:`n`n") . value . "`n")

				return value
			}
			catch exception {
				this.LastMessage := (translate("Error while fetching stint data (Session: ") . session . translate(", Stint: ") . stint
								   . translate(", Name: ") . name . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)
			}
		}

		return false
	}

	setStintValue(stint, name, value, session := false) {
		if (!session && this.SessionActive)
			session := this.Session

		if session {
			try {
				if isDebug()
					showMessage("Saving value for stint " . stint . ": " . name . " => " . value)

				if (!value || (value == "")) {
					if stint is Integer
						this.Connector.DeleteSessionStintValue(session, stint, name)
					else
						this.Connector.DeleteStintValue(stint, name, value)
				}
				else {
					if stint is Integer
						this.Connector.SetSessionStintValue(session, stint, name, value)
					else
						this.Connector.SetStintValue(stint, name, value)
				}

				if (getLogLevel() <= kLogInfo)
					logMessage(kLogInfo, translate("Storing stint data (Session: ") . this.Session . translate(", Name: ") . name . translate("), Value:`n`n") . value . "`n")
			}
			catch exception {
				this.LastMessage := (translate("Error while storing stint data (Session: ") . session . translate(", Stint: ") . stint
								   . translate(", Name: ") . name . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)
			}
		}
	}

	getStintSession(stint, session := false) {
		if (!session && this.SessionActive)
			session := this.Session

		if session {
			try {
				if stint is Integer
					stint := this.Connector.GetSessionStint(session, stint)

				return this.Connector.GetStintSession(stint)
			}
			catch exception {
				this.LastMessage := (translate("Error while fetching stint data (Session: ") . session . translate(", Stint: ") . stint
								   . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)
			}
		}

		return false
	}

	getCurrentLap(session := false) {
		local lap, lapNr

		if (!session && this.SessionActive)
			session := this.Session

		if session {
			try {
				lap := this.Connector.GetSessionLastLap(session)

				if !this.iCachedObjects.HasKey(lap)
					this.iCachedObjects[lap] := this.parseObject(this.Connector.GetLap(lap))

				lapNr := this.iCachedObjects[lap].Nr

				if (getLogLevel() <= kLogInfo)
					logMessage(kLogInfo, translate("Fetching lap number (Session: ") . this.Session . translate(", Lap: ") . lap . translate(", Number: ") . lapNr . translate(")"))

				return lapNr
			}
			catch exception {
				this.LastMessage := (translate("Error while fetching lap data (Session: ") . session
								   . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)
			}
		}

		return false
	}

	getLapStint(lap, session := false) {
		if (!session && this.SessionActive)
			session := this.Session

		if session {
			try {
				if lap is Integer
					lap := this.Connector.GetSessionLap(session, lap)

				return this.Connector.GetLapStint(lap)
			}
			catch exception {
				this.LastMessage := (translate("Error while fetching lap data (Session: ") . session . translate(", Lap: ") . lap
								   . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)
			}
		}

		return false
	}

	getLapValue(lap, name, session := false) {
		local value

		if (!session && this.SessionActive)
			session := this.Session

		if session {
			try {
				if lap is Integer
					value := this.Connector.GetSessionLapValue(session, lap, name)
				else
					value := this.Connector.GetLapValue(lap, name)

				if isDebug()
					showMessage("Fetching value for " . lap . ": " . name . " => " . value)

				if ((getLogLevel() <= kLogInfo) && value && (value != ""))
					logMessage(kLogInfo, translate("Fetching lap data (Session: ") . this.Session . translate(", Lap: ") . lap . translate(", Name: ") . name . translate("), Value:`n`n") . value . "`n")

				return value
			}
			catch exception {
				this.LastMessage := (translate("Error while fetching lap data (Session: ") . session . translate(", Lap: ") . lap
								   . translate(", Name: ") . name . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)
			}
		}

		return false
	}

	setLapValue(lap, name, value, session := false) {
		if (!session && this.SessionActive)
			session := this.Session

		if session {
			try {
				if isDebug()
					showMessage("Saving value for lap " . lap . ": " . name . " => " . value)

				if (!value || (value == "")) {
					if lap is Integer
						this.Connector.DeleteSessionLapValue(session, lap, name)
					else
						this.Connector.DeleteLapValue(lap, name, value)

					if (getLogLevel() <= kLogInfo)
						logMessage(kLogInfo, translate("Deleting lap data (Session: ") . this.Session . translate(", Lap: ") . lap . translate(", Name: ") . name . translate(")"))
				}
				else {
					if lap is Integer
						this.Connector.SetSessionLapValue(session, lap, name, value)
					else
						this.Connector.SetLapValue(lap, name, value)

					if (getLogLevel() <= kLogInfo)
						logMessage(kLogInfo, translate("Storing lap data (Session: ") . this.Session . translate(", Lap: ") . lap . translate(", Name: ") . name . translate("), Value:`n`n") . value . "`n")
				}
			}
			catch exception {
				this.LastMessage := (translate("Error while storing lap data (Session: ") . session . translate(", Lap: ") . lap
								   . translate(", Name: ") . name . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)
			}
		}
	}

	addStint(lapNumber) {
		local stint

		if this.TeamServerActive {
			try {
				if !this.SessionActive
					throw Exception("Cannot add a stint to an inactive session...")

				if isDebug()
					showMessage("Updating stint in lap " . lapNumber . " for team session")

				stint := this.Connector.StartStint(this.Session, this.Driver, lapNumber)

				try {
					this.Connector.SetStintValue(stint, "Time", A_Now)
					this.Connector.SetStintValue(stint, "ID", this.ID)
				}
				catch exception {
					logError(exception)
				}

				return stint
			}
			catch exception {
				this.LastMessage := (translate("Error while starting stint (Session: ") . this.Session . translate(", Driver: ") . this.Driver
								   . translate(", Lap: ") . lapNumber . translate("), Exception: ") . (IsObject(exception) ? exception.Message :  exception))

				logMessage(kLogCritical, this.LastMessage)

				this.keepAlive()
			}
		}
	}

	addLap(lapNumber, telemetryData, positionsData) {
		local driverForName, driverSurName, driverNickName, stint, simulator, car, track, lap

		if this.TeamServerActive {
			try {
				driverForName := getConfigurationValue(telemetryData, "Stint Data", "DriverForname", "John")
				driverSurName := getConfigurationValue(telemetryData, "Stint Data", "DriverSurname", "Doe")
				driverNickName := getConfigurationValue(telemetryData, "Stint Data", "DriverNickname", "JDO")

				if isDebug() {
					showMessage("Updating lap for team session: " . lapNumber)

					if (isDevelopment() && ((this.DriverForName != driverForName) || (this.DriverSurName != driverSurName)))
						throw Exception("Driver inconsistency detected...")
				}

				stint := false

				if !this.SessionActive {
					simulator := getConfigurationValue(telemetryData, "Session Data", "Simulator", "Unknown")
					car := getConfigurationValue(telemetryData, "Session Data", "Car", "Unknown")
					track := getConfigurationValue(telemetryData, "Session Data", "Track", "Unknown")

					new SessionDatabase().registerDriver(simulator, this.ID, computeDriverName(driverForName, driverSurName, driverNickName))

					stint := this.joinSession(simulator, car, track, lapNumber)
				}
				else if !this.DriverActive
					stint := this.addStint(lapNumber)
				else
					stint := this.Connector.GetSessionCurrentStint(this.Session)

				lap := this.Connector.CreateLap(stint, lapNumber)

				if (telemetryData && (telemetryData.Count() > 0) && !this.iLapData["Telemetry"].HasKey(lapNumber)) {
					telemetryData := printConfiguration(telemetryData)

					if isDebug()
						showMessage("Setting telemetry data for lap " . lapNumber . ": " . telemetryData)

					this.setLapValue(lapNumber, "Telemetry Data", telemetryData)

					this.iLapData["Telemetry"][lapNumber] := true
				}

				if (positionsData && (positionsData.Count() > 0) && !this.iLapData["Positions"].HasKey(lapNumber)) {
					positionsData := printConfiguration(positionsData)

					if isDebug()
						showMessage("Setting standings data for lap " . lapNumber . ": " . positionsData)

					this.setLapValue(lapNumber, "Positions Data", positionsData)

					this.iLapData["Positions"][lapNumber] := true
				}
			}
			catch exception {
				this.LastMessage := (translate("Error while updating a lap (Session: ") . this.Session . translate(", Lap: ") . lapNumber
								   . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))

				logMessage(kLogCritical, this.LastMessage)
			}
		}
	}

	keepAlive(start := false) {
		local nextPing := 10000
		local invalid := false
		local driverObject

		static keepAliveTask := false

		if (this.Connector && this.ServerURL && this.ServerToken) {
			try {
				if this.Connection
					this.State["Stalled"] := !this.Connector.KeepAlive(this.Connection)
				else {
					this.State["ServerURL"] := "Invalid"
					this.State["SessionToken"] := "Invalid"

					this.Connector.Initialize(this.ServerURL, this.ServerToken)

					this.State["Team"] := "Invalid"
					this.State["Driver"] := "Invalid"
					this.State["Session"] := "Invalid"

					if (this.Driver && this.Session) {
						this.iConnection := this.Connector.Connect(this.ServerToken
																 , new SessionDatabase().ID
																 , computeDriverName(this.DriverForName[true]
																				   , this.DriverSurName[true]
																				   , this.DriverNickName[true])
																 , "Driver", this.Session)

						this.State["ServerURL"] := this.ServerURL
						this.State["SessionToken"] := this.ServerToken

						try {
							if !this.iCachedObjects.HasKey(this.Team)
								this.iCachedObjects[this.Team] := this.parseObject(this.Connector.GetTeam(this.Team))

							this.iTeamName := this.iCachedObjects[this.Team].Name

							this.State["Team"] := this.Team[true]
						}
						catch exception {
							logError(exception)

							invalid := exception
						}

						try {
							if !this.iCachedObjects.HasKey(this.Driver)
								this.iCachedObjects[this.Driver] := this.parseObject(this.Connector.GetDriver(this.Driver))

							driverObject := this.iCachedObjects[this.Driver]
							this.iDriverName := (driverObject.ForName . A_Space . driverObject.SurName)

							this.State["Driver"] := this.Driver[true]
						}
						catch exception {
							logError(exception)

							invalid := exception
						}

						try {
							if !this.iCachedObjects.HasKey(this.Session)
								this.iCachedObjects[this.Session] := this.parseObject(this.Connector.GetSession(this.Session))

							this.iSessionName := this.iCachedObjects[this.Session].Name

							this.State["Session"] := this.Session[true]
						}
						catch exception {
							logError(exception)

							invalid := exception
						}

						if invalid
							throw invalid
						else
							Menu Tray, Tip, % (string2Values(".", A_ScriptName)[1] . translate(" (Team: ") . this.Team[true] . translate(")"))
					}
					else {
						this.State["ServerURL"] := this.ServerURL
						this.State["SessionToken"] := this.ServerToken
					}

					this.State["Stalled"] := false
				}
			}
			catch exception {
				Menu Tray, Tip, % string2Values(".", A_ScriptName)[1] . translate(" (Team: Error)")

				this.iDriverName := ""
				this.iTeamName := ""
				this.iSessionName := ""

				this.LastMessage := (translate("Cannot connect to the Team Server (URL: ") . this.ServerURL
								   . translate(", Token: ") . this.ServerToken
								   . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))

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
			keepAliveTask := new PeriodicTask(ObjBindMethod(this, "keepAlive"), 10000, kLowPriority)

			keepAliveTask.start()
		}
		else if keepAliveTask
			keepAliveTask.Sleep := ((this.Connection && !this.Stalled) ? 60000 : 10000)

		return false
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeTeamServerPlugin() {
	local controller := SimulatorController.Instance

	new TeamServerPlugin(controller, kTeamServerPlugin, controller.Configuration)
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
