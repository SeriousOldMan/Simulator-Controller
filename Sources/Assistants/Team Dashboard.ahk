;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Team Team Dashboard             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#SingleInstance Force			; Ony one instance allowed
#NoEnv							; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn							; Enable warnings to assist with detecting common errors.
#Warn LocalSameAsGlobal, Off

SendMode Input					; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.

SetBatchLines -1				; Maximize CPU utilization
ListLines Off					; Disable execution history

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Console.ico
;@Ahk2Exe-ExeName Team Dashboard.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\CLR.ahk


;;;-------------------------------------------------------------------------;;;
;;;                   Private Constant Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

global kClose = "Close"
global kConnect = "Connect"
global kEvent = "Event"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vToken := false

	
;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

setButtonIcon(buttonHandle, file, index := 1, options := "") {
;   Parameters:
;   1) {Handle} 	HWND handle of Gui button
;   2) {File} 		File containing icon image
;   3) {Index} 		Index of icon in file
;						Optional: Default = 1
;   4) {Options}	Single letter flag followed by a number with multiple options delimited by a space
;						W = Width of Icon (default = 16)
;						H = Height of Icon (default = 16)
;						S = Size of Icon, Makes Width and Height both equal to Size
;						L = Left Margin
;						T = Top Margin
;						R = Right Margin
;						B = Botton Margin
;						A = Alignment (0 = left, 1 = right, 2 = top, 3 = bottom, 4 = center; default = 4)

	RegExMatch(options, "i)w\K\d+", W), (W="") ? W := 16 :
	RegExMatch(options, "i)h\K\d+", H), (H="") ? H := 16 :
	RegExMatch(options, "i)s\K\d+", S), S ? W := H := S :
	RegExMatch(options, "i)l\K\d+", L), (L="") ? L := 0 :
	RegExMatch(options, "i)t\K\d+", T), (T="") ? T := 0 :
	RegExMatch(options, "i)r\K\d+", R), (R="") ? R := 0 :
	RegExMatch(options, "i)b\K\d+", B), (B="") ? B := 0 :
	RegExMatch(options, "i)a\K\d+", A), (A="") ? A := 4 :

	ptrSize := A_PtrSize = "" ? 4 : A_PtrSize, DW := "UInt", Ptr := A_PtrSize = "" ? DW : "Ptr"

	VarSetCapacity(button_il, 20 + ptrSize, 0)

	NumPut(normal_il := DllCall("ImageList_Create", DW, W, DW, H, DW, 0x21, DW, 1, DW, 1), button_il, 0, Ptr)	; Width & Height
	NumPut(L, button_il, 0 + ptrSize, DW)		; Left Margin
	NumPut(T, button_il, 4 + ptrSize, DW)		; Top Margin
	NumPut(R, button_il, 8 + ptrSize, DW)		; Right Margin
	NumPut(B, button_il, 12 + ptrSize, DW)		; Bottom Margin	
	NumPut(A, button_il, 16 + ptrSize, DW)		; Alignment

	SendMessage, BCM_SETIMAGELIST := 5634, 0, &button_il,, AHK_ID %buttonHandle%

	return IL_Add(normal_il, file, index)
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

getKeys(map) {
	keys := []
	
	for key, ignore in map
		keys.Push(key)
	
	return keys
}

getValues(map) {
	values := []
	
	for ignore, value in map
		values.Push(value)
	
	return values
}

loadTeams(connector) {
	teams := {}
	
	for ignore, identifier in string2Values(";", connector.GetAllTeams()) {
		team := parseObject(connector.GetTeam(identifier))
		
		teams[team.Name] := team.Identifier
	}
	
	return teams
}

loadSessions(connector, team) {
	sessions := {}

	if team
		for ignore, identifier in string2Values(";", connector.GetTeamSessions(team)) {
			try {
				session := parseObject(connector.GetSession(identifier))
				
				sessions[session.Name] := session.Identifier
			}
			catch exception {
				; ignore
			}
		}			
	
	return sessions
}

teamDashboard(configurationOrCommand, arguments*) {
	static connector := false
	static connected := false
	
	static teams := {}
	static sessions := {}
	
	static teamIdentifier := false
	static teamName := false
	static sessionIdentifier := false
	static sessionName := false
	
	static done := false
	
	static serverURLEdit = "https://localhost:5001"
	static serverTokenEdit = ""
	static sessionDropDownMenu
	static teamDropDownMenu
	
	static telemetryDataEdit
	static positionsDataEdit

	static pitstopLapEdit
	static pitstopRefuelEdit
	static pitstopTyreCompoundDropDown
	static pitstopTyreSetEdit
	static pitstopPressureFLEdit
	static pitstopPressureFREdit
	static pitstopPressureRLEdit
	static pitstopPressureRREdit
	static pitstopRepairsDropDown
	
	if (configurationOrCommand == kClose)
		done := true
	else if (configurationOrCommand == kConnect) {
		GuiControlGet serverURLEdit
		GuiControlGet serverTokenEdit
		
		try {
			connector.Connect(serverURLEdit, serverTokenEdit)
	
			connected := true
			
			showMessage(translate("Successfully connected to the Team Server."))
			
			teamDashBoard(kEvent, "TeamsLoad")
		}
		catch exception {
			if ((arguments.Length() == 0) || (arguments[1] != "Silent")) {
				title := translate("Error")
			
				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
				MsgBox 262160, %title%, % (translate("Cannot connect to the Team Server.") . "`n`n" . translate("Error: ") . exception.Message)
				OnMessage(0x44, "")
			}
		}
	}
	else if (configurationOrCommand == kEvent) {
		try {
			if (arguments[1] = "UpdateState") {
				GuiControlGet pitstopTyreCompoundDropDown
				
				if (pitstopTyreCompoundDropDown > 1) {
					GuiControl Enable, pitstopTyreSetEdit
					GuiControl Enable, pitstopPressureFLEdit
					GuiControl Enable, pitstopPressureFREdit
					GuiControl Enable, pitstopPressureRLEdit
					GuiControl Enable, pitstopPressureRREdit
				}
				else {
					GuiControl Disable, pitstopTyreSetEdit
					GuiControl Disable, pitstopPressureFLEdit
					GuiControl Disable, pitstopPressureFREdit
					GuiControl Disable, pitstopPressureRLEdit
					GuiControl Disable, pitstopPressureRREdit
				}
			}
			else if (arguments[1] = "TeamsLoad") {
				teams := (connected ? loadTeams(connector) : {})
			
				names := getKeys(teams)
				chosen := inList(getValues(teams), teamIdentifier)
			
				if ((chosen == 0) && (names.Length() > 0))
					chosen := 1
				
				if (chosen == 0) {
					teamName := ""
					teamIdentifier := false
				}
				else {
					teamName := names[chosen]
					teamIdentifier := teams[teamName]
				}

				GuiControl, , teamDropDownMenu, % ("|" . values2String("|", names*))
				GuiControl Choose, teamDropDownMenu, % chosen
				
				teamDashboard(kEvent, "TeamSelect")
			}
			else if (arguments[1] = "TeamSelect") {
				GuiControlGet teamDropDownMenu
				
				teamName := getKeys(teams)[teamDropDownMenu]
				teamIdentifier := teams[teamName]
				
				teamDashboard(kEvent, "SessionsLoad")
			}
			else if (arguments[1] = "SessionsLoad") {
				sessions := ((connected && teamIdentifier) ? loadSessions(connector, teamIdentifier) : {})
				
				names := getKeys(sessions)
				chosen := inList(getValues(sessions), sessionIdentifier)
				
				if ((chosen == 0) && (names.Length() > 0))
					chosen := 1
				
				if (chosen == 0) {
					sessionName := ""
					sessionIdentifier := false
				}
				else {
					sessionName := names[chosen]
					sessionIdentifier := sessions[sessionName]
				}
				
				GuiControl, , sessionDropDownMenu, % ("|" . values2String("|", names*))
				GuiControl Choose, sessionDropDownMenu, % chosen
				
				teamDashboard(kEvent, "SessionSelect")
			}
			else if (arguments[1] = "SessionSelect") {
				GuiControlGet sessionDropDownMenu
				
				sessionName := getKeys(sessions)[sessionDropDownMenu]
				sessionIdentifier := sessions[sessionName]
			}
			else if (arguments[1] = "DataUpdate") {
				if connected {
					Gui TD:Default
					
					try {
						lap := connector.GetSessionLastLap(sessionIdentifier)
						
						if (lap && (lap != "")) {
							GuiControl, , telemetryDataEdit, % connector.GetLapValue(lap, "Telemetry Data")
							GuiControl, , positionsDataEdit, % connector.GetLapValue(lap, "Positions Data")
						}
					}
					catch exception {
						GuiControl, , telemetryDataEdit, % ""
						GuiControl, , positionsDataEdit, % ""
					}
				}
			}
			else if (arguments[1] = "PitstopPlan") {
				GuiControlGet pitstopLapEdit
				GuiControlGet pitstopRefuelEdit
				GuiControlGet pitstopTyreCompoundDropDown
				GuiControlGet pitstopTyreSetEdit
				GuiControlGet pitstopPressureFLEdit
				GuiControlGet pitstopPressureFREdit
				GuiControlGet pitstopPressureRLEdit
				GuiControlGet pitstopPressureRREdit
				GuiControlGet pitstopRepairsDropDown
				
				pitstopPlan := newConfiguration()
				
				setConfigurationValue(pitstopPlan, "Pitstop", "Lap", pitstopLapEdit)
				setConfigurationValue(pitstopPlan, "Pitstop", "Refuel", pitstopRefuelEdit)
				
				if (pitstopTyreCompoundDropDown > 1) {
					setConfigurationValue(pitstopPlan, "Pitstop", "Tyre.Change", true)
					
					setConfigurationValue(pitstopPlan, "Pitstop", "Tyre.Set", pitstopTyreSetEdit)
					setConfigurationValue(pitstopPlan, "Pitstop", "Tyre.Compound", (pitstopTyreCompoundDropDown = 2) ? "Wet" : "Dry")
					setConfigurationValue(pitstopPlan, "Pitstop", "Tyre.Compound.Color"
										, ["Black", "Black", "Red", "White", "Blue"][pitstopTyreCompoundDropDown - 1])
					
					setConfigurationValue(pitstopPlan, "Pitstop", "Tyre.Pressures"
										, values2String(",", pitstopPressureFLEdit, pitstopPressureFREdit
														   , pitstopPressureRLEdit, pitstopPressureRREdit))
				}
				else
					setConfigurationValue(pitstopPlan, "Pitstop", "Tyre.Change", false)
				
				setConfigurationValue(pitstopPlan, "Pitstop", "Repair.Bodywork", false)
				setConfigurationValue(pitstopPlan, "Pitstop", "Repair.Suspension", false)
					
				if ((pitstopRepairsDropDown = 2) || (pitstopRepairsDropDown = 4))
					setConfigurationValue(pitstopPlan, "Pitstop", "Repair.Bodywork", true)
					
				if (pitstopRepairsDropDown > 2)
					setConfigurationValue(pitstopPlan, "Pitstop", "Repair.Suspension", true)
				
				try {
					lap := connector.GetSessionLastLap(sessionIdentifier)

					connector.SetLapValue(lap, "Pitstop Plan", printConfiguration(pitstopPlan))
					connector.SetSessionValue(sessionIdentifier, "Pitstop Plan", lap)
					
					showMessage(translate("Race Engineer will be instructed in the next lap..."))
				}
				catch exception {
					showMessage(translate("Session has not been started yet..."))
				}
			}
		}
		catch exception {
			title := translate("Error")
		
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			MsgBox 262160, %title%, % (translate("Error while executing command.") . "`n`n" . translate("Error: ") . exception.Message)
			OnMessage(0x44, "")
		}
	}
	else {
		serverURLEdit := getConfigurationValue(arguments[1], "Team Settings", "Server.URL", "")
		serverTokenEdit := getConfigurationValue(arguments[1], "Team Settings", "Server.Token", "")
		teamName := getConfigurationValue(arguments[1], "Team Settings", "Team.Name", "")
		teamIdentifier := getConfigurationValue(arguments[1], "Team Settings", "Team.Identifier", false)
		sessionIdentifier := getConfigurationValue(arguments[1], "Team Settings", "Session.Identifier", "")
		sessionName := getConfigurationValue(arguments[1], "Team Settings", "Session.Name", "")
			
		dllName := "Team Server Connector.dll"
		dllFile := kBinariesDirectory . dllName
		
		try {
			if (!FileExist(dllFile)) {
				logMessage(kLogCritical, translate("Team Server Connector.dll not found in ") . kBinariesDirectory)
				
				Throw "Unable to find Team Server Connector.dll in " . kBinariesDirectory . "..."
			}

			connector := CLR_LoadLibrary(dllFile).CreateInstance("TeamServer.TeamServerConnector")
		}
		catch exception {
			logMessage(kLogCritical, translate("Error while initializing Team Server Connector - please rebuild the applications"))
			
			showMessage(translate("Error while initializing Team Server Connector - please rebuild the applications") . translate("...")
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
	
		Gui TD:Default
			
		Gui TD:-Border ; -Caption
		Gui TD:Color, D0D0D0, D8D8D8

		Gui TD:Font, Bold, Arial

		Gui TD:Add, Text, w388 Center gmoveTeamDashboard, % translate("Modular Simulator Controller System") 

		Gui TD:Font, Norm, Arial
		Gui TD:Font, Italic Underline, Arial

		Gui TD:Add, Text, YP+20 w388 cBlue Center gopenConsoleDocumentation, % translate("Team Dashboard")
		
		Gui TD:Add, Text, x24 yp+30 w356 0x10

		Gui TD:Font, Norm, Arial
				
		Gui TD:Add, Button, x164 y454 w80 h23 gcloseTeamDashboard, % translate("Close")
		
		x := 8
		y := 70
		width := 388
		
		x0 := x + 8
		x1 := x + 132
		
		w1 := width - (x1 - x + 8)
		
		w2 := w1 - 70
		
		x2 := x1 - 25
		
		w4 := w1 - 25
		x4 := x1 + 123 + 2
		
		w3 := Round((w4 / 2) - 3)
		x3 := x1 + w3 + 6
		
		x5 := x3 + w3 + 2
		w5 := w3 - 25
			
		Gui TD:Add, Text, x%x0% y%y% w90 h23 +0x200, % translate("Server URL")
		Gui TD:Add, Edit, x%x1% yp+1 w%w1% h21 VserverURLEdit, %serverURLEdit%
		
		Gui TD:Add, Text, x%x0% yp+26 w90 h23 +0x200, % translate("Access Token")
		Gui TD:Add, Edit, x%x1% yp-1 w%w1% h21 VserverTokenEdit, %serverTokenEdit%
		Gui TD:Add, Button, x%x2% yp-1 w23 h23 Default Center +0x200 HWNDconnectButton gconnectServer
		setButtonIcon(connectButton, kIconsDirectory . "Authorize.ico", 1, "L4 T4 R4 B4")

		Gui TD:Add, Text, x16 yp+26 w90 h23 +0x200, % translate("Team / Session")
			
		if teamIdentifier
			Gui TD:Add, DropDownList, x%x1% yp w123 AltSubmit Choose1 vteamDropDownMenu gchooseTeam, % teamName
		else
			Gui TD:Add, DropDownList, x%x1% yp w123 AltSubmit vteamDropDownMenu gchooseTeam
			
		if sessionIdentifier
			Gui TD:Add, DropDownList, x%x4% yp w123 AltSubmit Choose1 vsessionDropDownMenu gchooseSession, % sessionName
		else
			Gui TD:Add, DropDownList, x%x4% yp w123 AltSubmit Choose0 vsessionDropDownMenu gchooseSession
		
		Gui TD:Add, Tab3, x8 y150 w388 h296 -Wrap, % values2String("|", map(["Telemetry", "Standings", "Pitstop"], "translate")*)
		
		x0 := 16
		y := 178
		
		Gui Tab, 1
		
		Gui TD:Add, Edit, x16 y180 w372 h256 ReadOnly vtelemetryDataEdit
		
		Gui Tab, 2
		
		Gui TD:Add, Edit, x16 y180 w372 h256 ReadOnly vpositionsDataEdit
		
		Gui Tab, 3
	
		Gui TD:Add, Text, x16 y184 w90 h20, % translate("Lap")
		Gui TD:Add, Edit, x106 yp-2 w50 h20 Limit3 Number vpitstopLapEdit
		Gui TD:Add, UpDown, x138 yp-2 w18 h20
		
		Gui TD:Add, Text, x16 yp+30 w90 h20, % translate("Refuel")
		Gui TD:Add, Edit, x106 yp-2 w50 h20 Limit3 Number vpitstopRefuelEdit
		Gui TD:Add, UpDown, x138 yp-2 w18 h20
		Gui TD:Add, Text, x164 yp+2 w30 h20, % translate("Liter")

		Gui TD:Add, Text, x16 yp+30 w85 h23 +0x200, % translate("Tyre Change")
		choices := map(["No Tyre Change", "Wet", "Dry", "Dry (Red)", "Dry (White)", "Dry (Blue)"], "translate")
		Gui TD:Add, DropDownList, x106 yp w157 AltSubmit Choose1 vpitstopTyreCompoundDropDown gupdateState, % values2String("|", choices*)

		Gui TD:Add, Text, x16 yp+26 w95 h20, % translate("Tyre Set")
		Gui TD:Add, Edit, x106 yp-2 w50 h20 Limit2 Number vpitstopTyreSetEdit
		Gui TD:Add, UpDown, x138 yp-2 w18 h20

		Gui TD:Font, Norm, Arial
		Gui TD:Font, Italic, Arial

		Gui TD:Add, GroupBox, -Theme x16 yp+26 w247 h72 Section, % translate("Pressures")
				
		Gui TD:Font, Norm, Arial

		Gui TD:Add, Text, x26 yp+24 w75 h20, % translate("Front")
		Gui TD:Add, Edit, x106 yp-2 w50 h20 Limit4 vpitstopPressureFLEdit
		Gui TD:Add, Edit, x160 yp w50 h20 Limit4 vpitstopPressureFREdit
		; Gui TD:Add, UpDown, x138 yp-2 w18 h20
		Gui TD:Add, Text, x218 yp+2 w30 h20, % translate("PSI")

		Gui TD:Add, Text, x26 yp+24 w75 h20 , % translate("Rear")
		Gui TD:Add, Edit, x106 yp-2 w50 h20 Limit4 vpitstopPressureRLEdit
		Gui TD:Add, Edit, x160 yp w50 h20 Limit4 vpitstopPressureRREdit
		; Gui TD:Add, UpDown, x138 yp-2 w18 h20
		Gui TD:Add, Text, x218 yp+2 w30 h20, % translate("PSI")
		
		Gui TD:Add, Text, x16 ys+80 w85 h23 +0x200, % translate("Repairs")
		choices := map(["No Repairs", "Bodywork & Aerodynamics", "Suspension & Chassis", "Everything"], "translate")
		Gui TD:Add, DropDownList, x106 yp w157 AltSubmit Choose1 vpitstopRepairsDropDown, % values2String("|", choices*)
		Gui TD:Show, AutoSize Center
		
		Gui TD:Add, Button, x116 yp+40 w180 h23 gplanPitstop, % translate("Instruct Engineer...")
		
		teamDashboard(kConnect, "Silent")
		teamDashboard(kEvent, "UpdateState")
		
		Loop {
			Sleep 1000
		} until done
	}
}

moveTeamDashboard() {
	moveByMouse("TD")
}

closeTeamDashboard() {
	teamDashboard(kClose)
}

connectServer() {
	teamDashboard(kConnect)
}

chooseTeam() {
	teamDashboard(kEvent, "TeamSelect")
}

chooseSession() {
	teamDashboard(kEvent, "SessionSelect")
}

openConsoleDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#team-dashboard
}

updateState() {
	teamDashboard(kEvent, "UpdateState")
}

dataUpdate() {
	teamDashboard(kEvent, "DataUpdate")
}

planPitstop() {
	teamDashboard(kEvent, "PitstopPlan")
}

startupTeamDashboard() {
	icon := kIconsDirectory . "Console.ico"
	
	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Team Dashboard

	SetTimer dataUpdate, 30000
	
	teamDashboard(kSimulatorConfiguration, readConfiguration(kUserConfigDirectory . "Race.settings"))

	ExitApp 0
}


;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

startupTeamDashboard()