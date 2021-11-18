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
	
	iTeamServerEnabled := false
	
	iActionSession := false
	
	class TeamServerToggleAction extends ControllerAction {
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
			return this.iServerURL
		}
	}
	
	AccessToken[] {
		Get {
			return this.iAccessToken
		}
	}
	
	Connected[] {
		Get {
			return this.iConnected
		}
	}
	
	Team[] {
		Get {
			return this.iTeam
		}
	}
	
	Driver[] {
		Get {
			return this.iDriver
		}
	}
	
	Session[] {
		Get {
			return this.iSession
		}
	}
	
	TeamServerEnabled[] {
		Get {
			return this.iTeamServerEnabled
		}
	}
	
	TeamServerActive[] {
		Get {
			return (this.Connected && this.TeamServerEnabled && this.Team && this.Driver && this.Sssion)
		}
	}
	
	ActiveSession[] {
		Get {
			return this.iActiveSession
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
		
		base.__New(controller, name, configuration, register)
		
		teamServerToggle := this.getArgumentValue("teamServer", false)
		
		if teamServerToggle {
			arguments := string2Values(A_Space, teamServerToggle)
	
			if (arguments.Length() == 1)
				arguments.InsertAt(1, "Off")
			
			this.iTeamServerEnabled := (arguments[1] = "On")
			
			this.createTeamServerAction(controller, "TeamServer", arguments[2])
		}
		else
			this.iTeamServerEnabled := (this.iTeamServerName != false)
		
		if this.isActive()
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
	
	enableTeamServer() {
		this.iTeamServerEnabled := true
	}
	
	disableTeamServer() {
		this.iTeamServerEnabled := false
		
		if this.ActiveSession
			this.finishSession()
	}
	
	connect(serverURL, accessToken) {
		this.iServerURL := ((serverURL && (serverURL != "")) ? serverURL : false)
		this.iAccessToken := ((accessToken && (accessToken != "")) ? accessToken : false)
		
		this.keepAlive()	
	}
	
	setSession(team, driver, session) {
		this.iTeam := ((team && (team != "")) ? team : false)
		this.iDriver := ((driver && (driver != "")) ? driver : false)
		this.iSession := ((session && (session != "")) ? session : false)
	}
	
	startSession(car, track, raceNr) {
		if this.ActiveSession
			this.finishSession()
		
		if this.TeamServerActive {
			try {
				this.iActiveSession := this.Connector.StartSession(this.Team, car, track, raceNr)
			}
			catch exception {
				this.iActiveSession := false
				
				logMessage(kLogCritical, translate("Error while starting session (Team: ") . this.Team . translate(", Car: ") . car . translate(", Track: ") . track . translate(", RaceNr: ") . raceNr . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))
				
				this.keepAlive()
			}
		}
	}
	
	addStint() {
	}
	
	addLap() {
	}
	
	finishSession() {
		if this.TeamServerActive {
			try {
				this.Connector.FinishSession(this.ActiveSession)
			}
			catch exception {
				logMessage(kLogCritical, translate("Error while starting session (Team: ") . this.Team . translate(", Car: ") . car . translate(", Track: ") . track . translate(", RaceNr: ") . raceNr . translate("), Exception: ") . (IsObject(exception) ? exception.Message : exception))
				
				this.keepAlive()
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
