;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Team Server Plugin              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
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
				plugin.disableTeamServer()
			
				trayMessage(plugin.actionLabel(this), translate("State: On"))
			
				function.setLabel(plugin.actionLabel(this), "Green")
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
			this.iTeamServerEnabled := true
		
		if isDebug()
			showMessage("Team Server is " . (this.TeamServerEnabled ? "enabled" : "disabled"))
		
		if register
			controller.registerPlugin(this)
		
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
			if isInstance(theAction, TeamServerPlugin.TeamServerToggleAction)
				theAction.Function.setLabel(this.actionLabel(theAction), this.TeamServerEnabled ? "Green" : "Black")
	}
	
	enableTeamServer() {
		this.iTeamServerEnabled := true
		
		this.updateActions(kSessionFinished)
	}
	
	disableTeamServer() {
		this.disconnect()
		
		this.iTeamServerEnabled := false
		
		this.updateActions(kSessionFinished)
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
	
	connect(serverURL, accessToken, team, driver, session) {
		this.disconnect()
		
		this.iServerURL := ((serverURL && (serverURL != "")) ? serverURL : false)
		this.iAccessToken := ((accessToken && (accessToken != "")) ? accessToken : false)
		
		this.setSession(team, driver, session)
		
		this.keepAlive()
		
		if this.Connected {
			try {
				this.Connector.GetTeam(team)
				this.Connector.GetDriver(driver)
				this.Connector.GetSession(session)
			}
			catch exception {
				this.iConnected := false
				
				logMessage(kLogCritical, translate("Cannot connect to the session (URI: ") . serverURL . translate(", Token: ") . accessToken . translate(", Team: ") . team . translate(", Driver: ") . driver . translate(", Session: ") . session . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))
				
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
		
		if this.TeamServerActive {
			if isDebug()
				showMessage("Starting team session: " . car . ", " . track)
			
			try {
				this.Connector.StartSession(this.Session, duration, car, track)
				
				this.iSessionActive := true
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
				}
			}
			catch exception {
				logMessage(kLogCritical, translate("Error while finishing session (Session: ") . this.Session . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))
				
				this.keepAlive()
			}
		}
		
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
				
					this.iSessionActive := true
				}
				
				return this.addStint(lapNumber)
			}
		}
	}
	
	leaveSession() {
		if this.DriverActive {
			if isDebug()
				showMessage("Leaving team session")

			this.finishSession()
		}
		else
			this.iSessionActive := false
	}
	
	getCurrentDriver() {
		if this.SessionActive {
			try {
				return this.Connector.GetSessionDriver(this.Session)
			}
			catch exception {
				logMessage(kLogCritical, translate("Error while requesting current driver session (Session: ") . this.Session . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))
				
				return false
			}
		}
		else
			return false
	}
	
	getSessionValue(name) {
		if this.SessionActive {
			try {
				value := this.Connector.GetSessionValue(this.Session, name)

				if isDebug()
					showMessage("Fetching session value: " . name . " => " . value)
			
				return value
			}
			catch exception {
				logMessage(kLogCritical, translate("Error while fetching session value (Session: ") . this.Session . translate(", Name: ") . name . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))
			}
		}
		
		return false
	}
	
	setSessionValue(name, value) {
		if this.SessionActive {
			try {
				if isDebug()
					showMessage("Saving session value: " . name . " => " . value)
				
				this.Connector.SetSessionValue(this.Session, name, value)
			}
			catch exception {
				logMessage(kLogCritical, translate("Error while storing session value (Session: ") . this.Session . translate(", Name: ") . name . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))
			}
		}
	}
	
	getLapValue(lap, name) {
		if this.SessionActive {
			try {
				if lap is integer
					value := this.Connector.GetSessionLapValue(this.Session, lap, name)
				else
					value := this.Connector.GetLapValue(lap, name)

				if isDebug()
					showMessage("Fetching value for " . lap . ": " . name . " => " . value)
			
				return value
			}
			catch exception {
				logMessage(kLogCritical, translate("Error while fetching lap value (Session: ") . this.Session . translate(", Name: ") . name . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))
			}
		}
		
		return false
	}
	
	setLapValue(lap, name, value) {
		if this.SessionActive {
			try {
				if isDebug()
					showMessage("Saving value for lap " . lap . ": " . name . " => " . value)
				
				if lap is integer
					this.Connector.SetSessionLapValue(this.Session, lap, name, value)
				else
					this.Connector.SetLapValue(lap, name, value)
			}
			catch exception {
				logMessage(kLogCritical, translate("Error while storing session value (Session: ") . this.Session . translate(", Name: ") . name . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))
			}
		}
	}
	
	addStint(lapNumber) {
		if this.TeamServerActive {
			try {
				if !this.SessionActive
					throw Exception("Cannot start add a stint to an inactive session...")
				
				if isDebug()
					showMessage("Updating stint in lap " . lapNumber . " for team session")
			
				return this.Connector.StartStint(this.Session, this.Driver, lapNumber)
			}
			catch exception {
				this.iSessionActive := false
				
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
					driverNickName := getConfigurationValue(telemetryData, "Stint Data", "DriverNickname", "JD")
					
					if ((this.DriverForName != driverForName) || (this.DriverSurName != driverSurName) || (this.DriverNickName != driverNickName))
						throw Exception("Driver inconsistency detected...")
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
					stint := this.Connector.GetSessionStint(this.Session)
				
				this.Connector.CreateLap(stint, lapNumber)
			}
			catch exception {
				this.iSessionActive := false
				
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
				logMessage(kLogCritical, translate("Cannot connect to the Team Server (URI: ") . this.ServerURL . translate(", Token: ") . this.AccessToken . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))
				
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
