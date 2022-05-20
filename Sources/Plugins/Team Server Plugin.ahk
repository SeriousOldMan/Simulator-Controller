;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Team Server Plugin              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kSessionFinished = 0
global kSessionPaused = -1
global kSessionOther = 1
global kSessionPractice = 2
global kSessionQualification = 3
global kSessionRace = 4

global kTeamServerPlugin = "Team Server"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class TeamServerPlugin extends ControllerPlugin {
	iConnector := false

	iServerURL := false
	iAccessToken := false

	iConnected := false

	iTeam := false
	iDriver := false
	iSession := false

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

			if (plugin.TeamServerEnabled && ((trigger = "Off") || (trigger == "Push"))) {
				plugin.disableTeamServer()

				trayMessage(plugin.actionLabel(this), translate("State: Off"))

				function.setLabel(plugin.actionLabel(this), "Black")
			}
			else if (!plugin.TeamServerEnabled && ((trigger = "On") || (trigger == "Push"))) {
				plugin.enableTeamServer()

				trayMessage(plugin.actionLabel(this), translate("State: On"))

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
			exePath := kBinariesDirectory . "Race Settings.exe"

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
			exePath := kBinariesDirectory . "Race Center.exe"

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

	AccessToken[] {
		Get {
			return ((this.iAccessToken && (this.iAccessToken != "")) ? this.iAccessToken : false)
		}
	}

	Connected[] {
		Get {
			return this.iConnected
		}
	}

	Team[] {
		Get {
			return ((this.iTeam && (this.iTeam != "")) ? this.iTeam : false)
		}
	}

	Driver[] {
		Get {
			return ((this.iDriver && (this.iDriver != "")) ? this.iDriver : false)
		}
	}

	Session[] {
		Get {
			return ((this.iSession && (this.iSession != "")) ? this.iSession : false)
		}
	}

	DriverForName[] {
		Get {
			return this.getDriverForName()
		}
	}

	DriverSurName[] {
		Get {
			return this.getDriverSurName()
		}
	}

	DriverNickName[] {
		Get {
			return this.getDriverNickName()
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
			currentDriver := this.getCurrentDriver()

			return (this.SessionActive && (currentDriver == this.Driver))
		}
	}

	__New(controller, name, configuration := false, register := true) {
		dllName := "Team Server Connector.dll"
		dllFile := kBinariesDirectory . dllName

		try {
			if (!FileExist(dllFile)) {
				logMessage(kLogCritical, translate("Team Server Connector.dll not found in ") . kBinariesDirectory)

				Throw "Unable to find Team Server Connector.dll in " . kBinariesDirectory . "..."
			}

			this.iConnector := CLR_LoadLibrary(dllFile).CreateInstance("TeamServer.TeamServerConnector")
		}
		catch exception {
			logMessage(kLogCritical, translate("Error while initializing Team Server Connector - please rebuild the applications"))

			showMessage(translate("Error while initializing Team Server Connector - please rebuild the applications") . translate("...")
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}

		base.__New(controller, name, configuration, false)

		if (!this.Active && !isDebug())
			return

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
			this.enableTeamServer()

		this.keepAlive()
	}

	createTeamServerAction(controller, action, actionFunction, arguments*) {
		local function

		function := controller.findFunction(actionFunction)

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

	activate() {
		base.activate()

		this.updateActions(kSessionFinished)
	}

	updateActions(sessionState) {
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

	updateTrayLabel(enabled) {
		if enabled {
			if !InStr(A_IconTip, translate(" (Team)"))
				Menu Tray, Tip, % A_IconTip . translate(" (Team)")
		}
		else {
			index := InStr(A_IconTip, translate(" (Team)"))

			if index
				Menu Tray, Tip, % SubStr(A_IconTip, 1, index - 1)
		}
	}

	enableTeamServer() {
		this.iTeamServerEnabled := true

		callback := ObjBindMethod(this, "tryConnect")

		SetTimer %callback%, -5000

		this.updateActions(kSessionFinished)

		this.updateTrayLabel(true)
	}

	disableTeamServer() {
		this.disconnect()

		this.iTeamServerEnabled := false

		this.updateActions(kSessionFinished)

		this.updateTrayLabel(false)
	}

	parseObject(properties) {
		result := {}

		properties := StrReplace(properties, "`r", "")

		Loop Parse, properties, `n
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
		settings := readConfiguration(getFileName("Race.settings", kUserConfigDirectory))

		serverURL := getConfigurationValue(settings, "Team Settings", "Server.URL", "")
		accessToken := getConfigurationValue(settings, "Team Settings", "Server.Token", "")
		teamIdentifier := getConfigurationValue(settings, "Team Settings", "Team.Identifier", false)
		driverIdentifier := getConfigurationValue(settings, "Team Settings", "Driver.Identifier", false)
		sessionIdentifier := getConfigurationValue(settings, "Team Settings", "Session.Identifier", false)

		this.connect(serverURL, accessToken, teamIdentifier, driverIdentifier, sessionIdentifier, !kSilentMode)

		this.disconnect()
	}

	connect(serverURL, accessToken, team, driver, session, verbose := false) {
		this.disconnect()

		this.iServerURL := ((serverURL && (serverURL != "")) ? serverURL : false)
		this.iAccessToken := ((accessToken && (accessToken != "")) ? accessToken : false)

		this.setSession(team, driver, session)

		this.keepAlive()

		if this.Connected {
			try {
				driverObject := this.parseObject(this.Connector.GetDriver(driver))

				teamName := this.parseObject(this.Connector.GetTeam(team)).Name
				driverName := (driverObject.ForName . A_Space . driverObject.SurName)
				sessionName := this.parseObject(this.Connector.GetSession(session)).Name

				if (getLogLevel() <= kLogInfo)
					logMessage(kLogInfo, translate("Connected to the Team Server (URL: ") . serverURL . translate(", Token: ") . accessToken . translate(", Team: ") . team . translate(", Driver: ") . driver . translate(", Session: ") . session . translate(")"))

				if verbose
					showMessage(translate("Successfully connected to the team server.") . "`n`n"
										. translate("Team: ") . teamName . "`n"
										. translate("Driver: ") . driverName . "`n"
										. translate("Session: ") . sessionName
							  , false, "Information.png", 5000, "Center", "Bottom", 400, 120)
			}
			catch exception {
				this.iConnected := false

				if !InStr(A_IconTip, translate(" - Invalid"))
					Menu Tray, Tip, % A_IconTip . translate(" - Invalid")

				logMessage(kLogCritical, translate("Cannot connect to the Team Server (URL: ") . serverURL . translate(", Token: ") . accessToken . translate(", Team: ") . team . translate(", Driver: ") . driver . translate(", Session: ") . session . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))

				this.disconnect(false)
			}
		}

		return (this.Connected && this.Team && this.Driver && this.Session)
	}

	disconnect(leave := true) {
		if (leave && this.SessionActive)
			this.leaveSession()

		this.iServerURL := false
		this.iAccessToken := false

		this.setSession(false, false, false)

		this.keepAlive()
	}

	getDriverForName() {
		if (!this.iDriverForName && this.TeamServerActive) {
			try {
				driver := this.parseObject(this.Connector.GetDriver(this.Driver))

				this.iDriverForName := driver.ForName
				this.iDriverSurName := driver.SurName
				this.iDriverNickName := driver.NickName

				if (getLogLevel() <= kLogInfo)
					logMessage(kLogInfo, translate("Fetching Driver (Driver: ") . this.Driver . translate(", Name: ") . driver.ForName . A_Space . driver.SurName . translate(")"))
			}
			catch exception {
				logMessage(kLogCritical, translate("Error while fetching driver names (Driver: ") . this.Driver . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))

				this.keepAlive()
			}
		}

		return (this.iDriverForName ? this.iDriverForName : "")
	}

	getDriverSurName() {
		this.getDriverForName()

		return (this.iDriverSurName ? this.iDriverSurName : "")
	}

	getDriverNickName() {
		this.getDriverForName()

		return (this.iDriverNickName ? this.iDriverNickName : "")
	}

	startSession(duration, car, track) {
		if this.SessionActive
			this.leaveSession()

		if this.TeamServerActive && !this.SessionActive {
			if isDebug()
				showMessage("Starting team session: " . car . ", " . track)

			try {
				this.iLapData := {Telemetry: {}, Positions: {}}

				this.Connector.StartSession(this.Session, duration, car, track)

				this.Connector.SetSessionValue(this.Session, "Time", A_Now)

				this.iSessionActive := true

				if (getLogLevel() <= kLogInfo)
					logMessage(kLogInfo, translate("Starting session (Session: ") . this.Session . translate(", Car: ") . car . translate(", Track: ") . track . translate(")"))
			}
			catch exception {
				this.iSessionActive := false

				logMessage(kLogCritical, translate("Error while starting session (Session: ") . this.Session . translate(", Car: ") . car . translate(", Track: ") . track . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))

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
				logMessage(kLogCritical, translate("Error while finishing session (Session: ") . this.Session . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))

				this.keepAlive()
			}
		}

		this.iLapData := {Telemetry: {}, Positions: {}}
		this.iSessionActive := false
	}

	joinSession(car, track, lapNumber, duration := 0) {
		if this.TeamServerActive {
			if !this.SessionActive {
				if (lapNumber = 1) {
					if isDebug()
						showMessage("Creating team session: " . car . ", " . track)

					this.startSession(duration, car, track)
				}
				else {
					if isDebug()
						showMessage("Joining team session: " . car . ", " . track)

					this.iLapData := {Telemetry: {}, Positions: {}}
					this.iSessionActive := true
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
				logMessage(kLogCritical, translate("Error while requesting current driver session (Session: ") . this.Session . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))

				return false
			}
		}
		else
			return false
	}

	getSessionValue(name, default := "__Undefined__") {
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
				logMessage(kLogCritical, translate("Error while fetching session data (Session: ") . this.Session . translate(", Name: ") . name . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))
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
				logMessage(kLogCritical, translate("Error while storing session data (Session: ") . this.Session . translate(", Name: ") . name . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))
			}
		}
	}

	getStintValue(stint, name, session := false) {
		if (!session && this.SessionActive)
			session := this.Session

		if session {
			try {
				if stint is integer
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
				logMessage(kLogCritical, translate("Error while fetching stint data (Session: ") . session . translate(", Stint: ") . stint . translate(", Name: ") . name . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))
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
					if stint is integer
						this.Connector.DeleteSessionStintValue(session, stint, name)
					else
						this.Connector.DeleteStintValue(stint, name, value)
				}
				else {
					if stint is integer
						this.Connector.SetSessionStintValue(session, stint, name, value)
					else
						this.Connector.SetStintValue(stint, name, value)
				}

				if (getLogLevel() <= kLogInfo)
					logMessage(kLogInfo, translate("Storing stint data (Session: ") . this.Session . translate(", Name: ") . name . translate("), Value:`n`n") . value . "`n")
			}
			catch exception {
				logMessage(kLogCritical, translate("Error while storing stint data (Session: ") . session . translate(", Stint: ") . stint . translate(", Name: ") . name . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))
			}
		}
	}

	getCurrentLap(session := false) {
		if (!session && this.SessionActive)
			session := this.Session

		if session {
			try {
				lap := this.Connector.GetSessionLastLap(session)
				lapNr := this.parseObject(this.Connector.GetLap(lap)).Nr

				if (getLogLevel() <= kLogInfo)
					logMessage(kLogInfo, translate("Fetching lap number (Session: ") . this.Session . translate(", Lap: ") . lap . translate(", Number: ") . lapNr . translate(")"))

				return lapNr
			}
			catch exception {
				logMessage(kLogCritical, translate("Error while fetching lap data (Session: ") . session . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))
			}
		}

		return false
	}

	getLapValue(lap, name, session := false) {
		if (!session && this.SessionActive)
			session := this.Session

		if session {
			try {
				if lap is integer
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
				logMessage(kLogCritical, translate("Error while fetching lap data (Session: ") . session . translate(", Lap: ") . lap . translate(", Name: ") . name . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))
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
					if lap is integer
						this.Connector.DeleteSessionLapValue(session, lap, name)
					else
						this.Connector.DeleteLapValue(lap, name, value)

					if (getLogLevel() <= kLogInfo)
						logMessage(kLogInfo, translate("Deleting lap data (Session: ") . this.Session . translate(", Lap: ") . lap . translate(", Name: ") . name . translate(")"))
				}
				else {
					if lap is integer
						this.Connector.SetSessionLapValue(session, lap, name, value)
					else
						this.Connector.SetLapValue(lap, name, value)

					if (getLogLevel() <= kLogInfo)
						logMessage(kLogInfo, translate("Storing lap data (Session: ") . this.Session . translate(", Lap: ") . lap . translate(", Name: ") . name . translate("), Value:`n`n") . value . "`n")
				}
			}
			catch exception {
				logMessage(kLogCritical, translate("Error while storing lap data (Session: ") . session . translate(", Lap: ") . lap . translate(", Name: ") . name . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))
			}
		}
	}

	addStint(lapNumber) {
		if this.TeamServerActive {
			try {
				if !this.SessionActive
					Throw Exception("Cannot start add a stint to an inactive session...")

				if isDebug()
					showMessage("Updating stint in lap " . lapNumber . " for team session")

				stint := this.Connector.StartStint(this.Session, this.Driver, lapNumber)

				try {
					this.Connector.SetStintValue(stint, "Time", A_Now)
				}
				catch exception {
					; ignore
				}

				return stint
			}
			catch exception {
				logMessage(kLogCritical, translate("Error while starting stint (Session: ") . this.Session . translate(", Driver: ") . this.Driver . translate(", Lap: ") . lapNumber . translate("), Exception: ") . (IsObject(exception) ? exception.Message :  exception))

				this.keepAlive()
			}
		}
	}

	addLap(lapNumber, telemetryData, positionsData) {
		if this.TeamServerActive {
			try {
				if isDebug()
					showMessage("Updating lap for team session: " . lapNumber)

				if isDebug() {
					driverForName := getConfigurationValue(telemetryData, "Stint Data", "DriverForname", "John")
					driverSurName := getConfigurationValue(telemetryData, "Stint Data", "DriverSurname", "Doe")
					driverNickName := getConfigurationValue(telemetryData, "Stint Data", "DriverNickname", "JDO")

					if ((this.DriverForName != driverForName) || (this.DriverSurName != driverSurName))
						Throw Exception("Driver inconsistency detected...")
				}

				stint := false

				if !this.SessionActive {
					car := getConfigurationValue(telemetryData, "Session Data", "Car", "Unknown")
					track := getConfigurationValue(telemetryData, "Session Data", "Track", "Unknown")

					stint := this.joinSession(car, track, lapNumber)
				}
				else if !this.DriverActive
					stint := this.addStint(lapNumber)
				else
					stint := this.Connector.GetSessionCurrentStint(this.Session)

				lap := this.Connector.CreateLap(stint, lapNumber)

				if (telemetryData && !this.iLapData["Telemetry"].HasKey(lapNumber)) {
					telemetryData := printConfiguration(telemetryData)

					if isDebug()
						showMessage("Setting telemetry data for lap " . lapNumber . ": " . telemetryData)

					this.setLapValue(lapNumber, "Telemetry Data", telemetryData)

					this.iLapData["Telemetry"][lapNumber] := true
				}

				if (positionsData && !this.iLapData["Positions"].HasKey(lapNumber)) {
					positionsData := printConfiguration(positionsData)

					if isDebug()
						showMessage("Setting standings data for lap " . lapNumber . ": " . positionsData)

					this.setLapValue(lapNumber, "Positions Data", positionsData)

					this.iLapData["Positions"][lapNumber] := true
				}
			}
			catch exception {
				logMessage(kLogCritical, translate("Error while updating a lap (Session: ") . this.Session . translate(", Lap: ") . lapNumber . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))
			}
		}
	}

	keepAlive() {
		nextPing := 10000

		if (this.Connector && this.ServerURL && this.AccessToken)
			try {
				this.Connector.Connect(this.ServerURL, this.AccessToken)

				this.iConnected := true

				nextPing := 60000
			}
			catch exception {
				if !InStr(A_IconTip, translate(" - Invalid"))
					Menu Tray, Tip, % A_IconTip . translate(" - Invalid")

				logMessage(kLogCritical, translate("Cannot connect to the Team Server (URL: ") . this.ServerURL . translate(", Token: ") . this.AccessToken . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))

				this.iConnected := false
			}
		else
			this.iConnected := false

		callback := ObjBindMethod(this, "keepAlive")

		SetTimer %callback%, -%nextPing%
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
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeTeamServerPlugin()
