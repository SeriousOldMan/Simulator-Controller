;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Team Server Configuration       ;;;
;;;                                         Plugin                          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\CLR.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; TeamServerConfigurator                                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global teamServerURLEdit = "https://localhost:5001"
global teamServerNameEdit = ""
global teamServerPasswordEdit = ""

class TeamServerConfigurator extends ConfigurationItem {
	iEditor := false
	
	iTeamServerConnector := false
	
	Editor[] {
		Get {
			return this.iEditor
		}
	}
	
	__New(editor, configuration := false) {
		this.iEditor := editor
		
		base.__New(configuration)
		
		dllName := "Team Server Connector.dll"
		dllFile := kBinariesDirectory . dllName
		
		try {
			if (!FileExist(dllFile)) {
				logMessage(kLogCritical, translate("Team Server Connector.dll not found in " . kBinariesDirectory))
				
				Throw "Unable to find Team Server Connector.dll in " . kBinariesDirectory . "..."
			}

			this.iTeamServerConnector := CLR_LoadLibrary(dllFile).CreateInstance("TeamServer.TeamServerConnector")
		}
		catch exception {
			logMessage(kLogCritical, translate("Error while initializing Team Server Connector - please rebuild the applications"))
			
			showMessage(translate("Error while initializing Team Server Connector - please rebuild the applications") . translate("...")
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
		
		TeamServerConfigurator.Instance := this
	}
	
	createGui(editor, x, y, width, height) {
		window := editor.Window
		
		Gui %window%:Font, Norm, Arial
		
		x0 := x + 8
		x1 := x + 132
		
		w1 := width - (x1 - x + 8)
		
		w2 := w1 - 70
		
		x2 := x + 172
		w3 := Round((w2 / 2) - 3)
		x3 := x1 + w3 + 6
		
		
		x4 := x1 + w2 + 4
		
		Gui %window%:Add, Text, x%x0% y%y% w134 h23 +0x200 HWNDwidget1 Hidden, % translate("Server URL")
		Gui %window%:Add, Edit, x%x1% yp+1 w%w2% h21 VteamServerURLEdit HWNDwidget2 Hidden, %teamServerURLEdit%
		Gui %window%:Add, Text, x%x4% yp+2 w66 h23 HWNDwidget3 Hidden, % translate("/api/login")
		
		Gui %window%:Add, Text, x%x0% yp+21 w135 h23 +0x200 HWNDwidget4 Hidden, % translate("Login Credentials")
		Gui %window%:Add, Edit, x%x1% yp+1 w%w3% h21 VteamServerNameEdit HWNDwidget5 Hidden, %teamServerNameEdit%
		Gui %window%:Add, Edit, x%x3% yp w%w3% h21 Password VteamServerPasswordEdit HWNDwidget6 Hidden, %teamServerPasswordEdit%
		
		Gui %window%:Add, Button, x%x4% yp w66 h23 Center +0x200 gtestLogin HWNDwidget7 Hidden, % translate("Test...")
		
		Loop 7
			editor.registerWidget(this, widget%A_Index%)
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
	}
	
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)

		window := this.Editor.Window
		
		Gui %window%:Default

	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

testLogin() {
	configurator := TeamServerConfigurator.Instance
	connector := configurator.iTeamServerConnector
	
	GuiControlGet teamServerURLEdit
	GuiControlGet teamServerNameEdit
	GuiControlGet teamServerPasswordEdit
	
	connector.Connect(teamServerURLEdit)
	
	connector.Login(teamServerNameEdit, teamServerPasswordEdit)
	
	token := connector.Token
	minutesLeft := connector.GetMinutesLeft()
	tokenLifeTime := connector.GetTokenLifeTime()
}

initializeTeamServerConfigurator() {
	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance
		
		editor.registerConfigurator(translate("Team Server"), new TeamServerConfigurator(editor, editor.Configuration))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeTeamServerConfigurator()