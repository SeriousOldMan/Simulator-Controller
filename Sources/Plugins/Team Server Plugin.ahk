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
	iToken := false
	iTeam := false
	iSession := false
	iDriver := false
	
	iActive := false
	
	Connector[] {
		Get {
			return this.iConnector
		}
	}
	
	Token[] {
		Get {
			return this.iToken
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
	
	Active[] {
		Get {
			return this.iActive
		}
	}
	
	__New(controller, name, configuration := false, register := true) {
		dllName := "Team Server Connector.dll"
		dllFile := kBinariesDirectory . dllName
		
		try {
			if (!FileExist(dllFile)) {
				logMessage(kLogCritical, translate("Team Server Connector.dll not found in " . kBinariesDirectory))
				
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
	}
	
	prepareSession(token, team, driver, session) {
		this.iToken := token
		this.iTeam := team
		this.iDriver := driver
		this.iSession := session
	}
	
	startSession() {
	}
	
	addStint() {
	}
	
	addLap() {
	}
	
	finishSession() {
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
