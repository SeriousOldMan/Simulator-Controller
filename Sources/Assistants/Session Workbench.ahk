;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Session Workbench               ;;;
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
;@Ahk2Exe-ExeName Session Workbench.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Math.ahk
#Include ..\Libraries\CLR.ahk
#Include Libraries\RaceReportViewer.ahk
#Include Libraries\TelemetryDatabase.ahk
#Include Libraries\SetupDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                   Private Constant Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

global kClose = "Close"
global kConnect = "Connect"
global kEvent = "Event"

global kSessionReports = concatenate(kRaceReports, ["Pressures", "Temperatures", "Free"])

global kSessionDataSchemas := {"Lap.Data": ["Stint", "Lap", "Lap.Time", "Temperature.Air", "Temperature.Track", "Map", "TC", "ABS"
										  , "Fuel.Remaining", "Fuel.Consumption", "Tyre.Laps"
										  , "Tyre.Pressure.Cold.Average", "Tyre.Pressure.Cold.Front.Average", "Tyre.Pressure.Cold.Rear.Average"
										  , "Tyre.Pressure.Cold.Front.Left", "Tyre.Pressure.Cold.Front.Right"
										  , "Tyre.Pressure.Cold.Rear.Left", "Tyre.Pressure.Cold.Rear.Right"
										  , "Tyre.Pressure.Hot.Average", "Tyre.Pressure.Hot.Front.Average", "Tyre.Pressure.Hot.Rear.Average"
										  , "Tyre.Pressure.Hot.Front.Left", "Tyre.Pressure.Hot.Front.Right"
										  , "Tyre.Pressure.Hot.Rear.Left", "Tyre.Pressure.Hot.Rear.Right"
										  , "Tyre.Temperature.Average", "Tyre.Temperature.Front.Average", "Tyre.Temperature.Rear.Average"
										  , "Tyre.Temperature.Front.Left", "Tyre.Temperature.Front.Right"
										  , "Tyre.Temperature.Rear.Left", "Tyre.Temperature.Rear.Right"]}
										  
						
;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vToken := false


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global serverURLEdit
global serverTokenEdit
global teamDropDownMenu
global sessionDropDownMenu

global chartTypeDropDown
global chartViewer

global reportSettingsButton

global detailsViewer

global reportsListView

global dataXDropDown
global dataY1DropDown
global dataY2DropDown
global dataY3DropDown

global analysisMenuDropDown
global informationMenuDropDown
global pitstopMenuDropDown

global pitstopLapEdit
global pitstopRefuelEdit
global pitstopTyreCompoundDropDown
global pitstopTyreSetEdit
global pitstopPressureFLEdit
global pitstopPressureFREdit
global pitstopPressureRLEdit
global pitstopPressureRREdit
global pitstopRepairsDropDown

class SessionWorkbench extends ConfigurationItem {
	iClosed := false
	
	iSessionDirectory := false
	iRaceSettings := false
	
	iConnector := false
	iConnected := false
	
	iServerURL := ""
	iServerToken := ""
	
	iTeams := {}
	iSessions := {}
	
	iTeamIdentifier := false
	iTeamName := false
	
	iSessionIdentifier := false
	iSessionName := false
	
	iStints := {}
	iLaps := {}
	
	iCurrentStint := false
	iLastLap := false
	
	iStintsListView := false
	iLapsListView := false
	iPitstopsListView := false
	
	iReportViewer := false
	iReportDatabase := false
	iSelectedReport := false
	iSelectedChartType := false
	
	iTelemetryDatabase := false
	iPressuresDatabase := false
	
	class SessionTelemetryDatabase extends TelemetryDatabase {
		__New(workbench) {
			base.__New()
			
			this.setDatabase(new Database(workbench.SessionDirectory, kTelemetrySchemas))
		}
	}
	
	class SessionPressuresDatabase {
		iDatabase := false
		
		Database[] {
			Get {
				return this.iDatabase
			}
		}
		
		__New(workbench) {
			this.iDatabase := new Database(workbench.SessionDirectory, kSetupDataSchemas)
		}
		
		updatePressures(weather, airTemperature, trackTemperature, compound, compoundColor, coldPressures, hotPressures, flush := true) {
			if (!compoundColor || (compoundColor = ""))
				compoundColor := "Black"
			
			this.Database.add("Setup.Pressures", {Weather: weather, "Temperature.Air": airTemperature, "Temperature.Track": trackTemperature
												, Compound: compound, "Compound.Color": compoundColor
												, "Tyre.Pressure.Cold.Front.Left": coldPressures[1], "Tyre.Pressure.Cold.Front.Right": coldPressures[2]
												, "Tyre.Pressure.Cold.Rear.Left": coldPressures[3], "Tyre.Pressure.Cold.Rear.Right": coldPressures[4]
												, "Tyre.Pressure.Hot.Front.Left": hotPressures[1], "Tyre.Pressure.Hot.Front.Right": hotPressures[2]
												, "Tyre.Pressure.Hot.Rear.Left": hotPressures[3], "Tyre.Pressure.Hot.Rear.Right": hotPressures[4]}, flush)
			
			tyres := ["FL", "FR", "RL", "RR"]
			types := ["Cold", "Hot"]
			
			for typeIndex, tPressures in [coldPressures, hotPressures]
				for tyreIndex, pressure in tPressures
					this.updatePressure(weather, airTemperature, trackTemperature, compound, compoundColor
									  , types[typeIndex], tyres[tyreIndex], pressure, 1, flush, false)
		}
		
		updatePressure(weather, airTemperature, trackTemperature, compound, compoundColor
					 , type, tyre, pressure, count := 1, flush := true) {
			if (!compoundColor || (compoundColor = ""))
				compoundColor := "Black"
			
			rows := this.Database.query("Setup.Pressures.Distribution"
									  , {Where: {Weather: weather, "Temperature.Air": airTemperature, "Temperature.Track": trackTemperature
											   , Compound: compound, "Compound.Color": compoundColor, Type: type, Tyre: tyre, "Pressure": pressure}})
			
			if (rows.Length() > 0)
				rows[1].Count := rows[1].Count + count
			else
				this.Database.add("Setup.Pressures.Distribution"
								, {Weather: weather, "Temperature.Air": airTemperature, "Temperature.Track": trackTemperature
								 , Compound: compound, "Compound.Color": compoundColor, Type: type, Tyre: tyre, "Pressure": pressure, Count: count}, flush)
		}
	}
	
	Window[] {
		Get {
			return "Dashboard"
		}
	}
	
	RaceSettings[] {
		Get {
			return this.iRaceSettings
		}
	}
	
	SessionDirectory[] {
		Get {
			if this.ActiveSession
				return (this.iSessionDirectory . this.iSessionName . "\")
			else
				return this.iSessionDirectory
		}
	}
	
	Connector[] {
		Get {
			return this.iConnector
		}
	}
	
	Connected[] {
		Get {
			return this.iConnected
		}
	}
	
	ServerURL[] {
		Get {
			return this.iServerURL
		}
	}
	
	ServerToken[] {
		Get {
			return this.iServerToken
		}
	}
	
	Teams[key := false] {
		Get {
			if key
				return this.iTeams[key]
			else
				return this.iTeams
		}
	}
	
	Sessions[key := false] {
		Get {
			if key
				return this.iSessions[key]
			else
				return this.iSessions
		}
	}
	
	SelectedTeam[asIdentifier := false] {
		Get {
			return (asIdentifier ? this.iTeamIdentifier : this.iTeamName)
		}
	}
	
	SelectedSession[asIdentifier := false] {
		Get {
			return (asIdentifier ? this.iSessionIdentifier : this.iSessionName)
		}
	}
	
	ActiveSession[] {
		Get {
			return (this.Connected && this.SelectedTeam[true] && this.SelectedSession[true])
		}
	}
	
	Stints[key := false] {
		Get {
			return (key ? this.iStints[key] : this.iStints)
		}
		
		Set {
			return (key ? (this.iStints[key] := value) : (this.iStints := value))
		}
	}
	
	CurrentStint[asIdentifier := false] {
		Get {
			if this.iCurrentStint
				return (asIdentifier ? this.iCurrentStint.Identifier : this.iCurrentStint)
			else
				return false
		}
	}
	
	Laps[key := false] {
		Get {
			return (key ? this.iLaps[key] : this.iLaps)
		}
		
		Set {
			return (key ? (this.iLaps[key] := value) : (this.iLaps := value))
		}
	}
	
	LastLap[asIdentifier := false] {
		Get {
			if this.iLastLap
				return (asIdentifier ? this.iLastLap.Identifier : this.iLastLap)
			else
				return false
		}
	}
	
	StintsListView[] {
		Get {
			return this.iStintsListView
		}
	}
	
	LapsListView[] {
		Get {
			return this.iLapsListView
		}
	}
	
	PitstopsListView[] {
		Get {
			return this.iPitstopsListView
		}
	}
	
	ReportViewer[] {
		Get {
			return this.iReportViewer
		}
	}
	
	ReportDatabase[] {
		Get {
			return this.iReportDatabase
		}
	}
	
	SelectedReport[] {
		Get {
			return this.iSelectedReport
		}
	}
	
	SelectedChartType[] {
		Get {
			return this.iSelectedChartType
		}
	}
	
	TelemetryDatabase[] {
		Get {
			return this.iTelemetryDatabase
		}
	}
	
	PressuresDatabase[] {
		Get {
			return this.iPressuresDatabase
		}
	}
	
	__New(configuration, raceSettings) {
		this.iRaceSettings := raceSettings
		
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
		
		base.__New(configuration)
		
		SessionWorkbench.Instance := this
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		this.iSessionDirectory := (getConfigurationValue(configuration, "Team Server", "Session.Folder", kTempDirectory . "Sessions") . "\")
		
		settings := this.RaceSettings
		
		this.iServerURL := getConfigurationValue(settings, "Team Settings", "Server.URL", "")
		this.iServerToken := getConfigurationValue(settings, "Team Settings", "Server.Token", "")
		this.iTeamName := getConfigurationValue(settings, "Team Settings", "Team.Name", "")
		this.iTeamIdentifier := getConfigurationValue(settings, "Team Settings", "Team.Identifier", false)
		this.iSessionName := getConfigurationValue(settings, "Team Settings", "Session.Name", "")
		this.iSessionIdentifier := getConfigurationValue(settings, "Team Settings", "Session.Identifier", false)
	}
	
	createGui(configuration) {
		window := this.Window
		
		Gui %window%:Default
	
		Gui %window%:-Border ; -Caption
		Gui %window%:Color, D0D0D0, D8D8D8

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Text, w1184 Center gmoveTeamDashboard, % translate("Modular Simulator Controller System") 
		
		Gui %window%:Font, s9 Norm, Arial
		Gui %window%:Font, Italic Underline, Arial

		Gui %window%:Add, Text, YP+20 w1184 cBlue Center gopenDashboardDocumentation, % translate("Session Workbench")
		
		Gui %window%:Add, Text, x8 yp+30 w1200 0x10
			
		Gui %window%:Font, Norm
		Gui %window%:Font, s10 Bold, Arial
			
		Gui %window%:Add, Picture, x16 yp+12 w30 h30 Section, %kIconsDirectory%Report.ico
		Gui %window%:Add, Text, x50 yp+5 w80 h26, % translate("Reports")
			
		Gui %window%:Font, s8 Norm, Arial
		
		x := 16
		y := 70
		width := 388
			
		Gui %window%:Add, Text, x16 yp+30 w90 h23 +0x200, % translate("Server URL")
		Gui %window%:Add, Edit, x141 yp+1 w245 h21 VserverURLEdit, % this.ServerURL
		
		Gui %window%:Add, Text, x16 yp+26 w90 h23 +0x200, % translate("Access Token")
		Gui %window%:Add, Edit, x141 yp-1 w245 h21 VserverTokenEdit, % this.ServerToken
		Gui %window%:Add, Button, x116 yp-1 w23 h23 Center +0x200 HWNDconnectButton gconnectServer
		setButtonIcon(connectButton, kIconsDirectory . "Authorize.ico", 1, "L4 T4 R4 B4")

		Gui %window%:Add, Text, x16 yp+26 w90 h23 +0x200, % translate("Team / Session")
			
		if this.SelectedTeam[true]
			Gui %window%:Add, DropDownList, x141 yp w120 AltSubmit Choose1 vteamDropDownMenu gchooseTeam, % this.SelectedTeam
		else
			Gui %window%:Add, DropDownList, x141 yp w120 AltSubmit vteamDropDownMenu gchooseTeam
			
		if this.SelectedSession[true]
			Gui %window%:Add, DropDownList, x266 yp w120 AltSubmit Choose1 vsessionDropDownMenu gchooseSession, % this.SelectedSession
		else
			Gui %window%:Add, DropDownList, x266 yp w120 AltSubmit Choose0 vsessionDropDownMenu gchooseSession
		
		Gui %window%:Add, Text, x24 yp+30 w356 0x10
		
		Gui %window%:Add, ListView, x16 yp+10 w115 h176 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDreportsListView gchooseReport, % translate("Report")
		
		for ignore, report in map(kSessionReports, "translate")
			LV_Add("", report)
		
		LV_ModifyCol(1, "AutoHdr")
		
		
		Gui %window%:Add, Text, x141 yp+2 w70 h23 +0x200, % translate("X-Axis")
		
		Gui %window%:Add, DropDownList, x195 yp w191 AltSubmit vdataXDropDown gchooseAxis
		
		Gui %window%:Add, Text, x141 yp+24 w70 h23 +0x200, % translate("Series")
		
		Gui %window%:Add, DropDownList, x195 yp w191 AltSubmit vdataY1DropDown gchooseAxis
		Gui %window%:Add, DropDownList, x195 yp+24 w191 AltSubmit vdataY2DropDown gchooseAxis
		Gui %window%:Add, DropDownList, x195 yp+24 w191 AltSubmit vdataY3DropDown gchooseAxis
		
		Gui %window%:Add, Text, x400 ys w40 h23 +0x200, % translate("Plot")
		Gui %window%:Add, DropDownList, x444 yp w80 AltSubmit Choose1 vchartTypeDropDown gchooseChartType, % values2String("|", map(["Scatter", "Bar", "Bubble", "Line"], "translate")*)
		
		Gui %window%:Add, Button, x1177 yp w23 h23 HwndreportSettingsButtonHandle vreportSettingsButton greportSettings
		setButtonIcon(reportSettingsButtonHandle, kIconsDirectory . "Report Settings.ico", 1)
		
		Gui %window%:Add, ActiveX, x400 yp+24 w800 h278 Border vchartViewer, shell.explorer
		
		chartViewer.Navigate("about:blank")
		
		Gui %window%:Add, Text, x8 yp+286 w1200 0x10

		Gui %window%:Font, s10 Bold, Arial
			
		Gui %window%:Add, Picture, x16 yp+10 w30 h30 Section, %kIconsDirectory%Tools BW.ico
		Gui %window%:Add, Text, x50 yp+5 w80 h26, % translate("Session")
		
		Gui %window%:Font, s8 Norm, Arial

		Gui %window%:Add, DropDownList, x220 yp-2 w180 AltSubmit Choose1 +0x200 vanalysisMenuDropDown ganalysisMenu, % values2String("|", map(["Analysis", "---------------------------------------------"], "translate")*)
		
		Gui %window%:Add, DropDownList, x405 yp w180 AltSubmit Choose1 +0x200 vinformationMenuDropDown ginformationMenu, % values2String("|", map(["Information", "---------------------------------------------"], "translate")*)
		
		Gui %window%:Add, DropDownList, x590 yp w180 AltSubmit Choose1 +0x200 vpitstopMenuDropDown gpitstopMenu, % values2String("|", map(["Pitstop", "---------------------------------------------", "Instruct Engineer..."], "translate")*)
		
		Gui %window%:Font, s8 Norm, Arial
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x619 ys+39 w577 h9, % translate("Details")
		
		Gui %window%:Add, ActiveX, x619 yp+21 w577 h193 Border vdetailsViewer, shell.explorer
		
		detailsViewer.Navigate("about:blank")
		
		this.showDetails(false)
		this.showChart(false)
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x8 y650 w1200 0x10
		
		Gui %window%:Add, Button, x574 y656 w80 h23 GcloseTeamDashboard, % translate("Close")

		Gui %window%:Add, Tab, x16 ys+39 w593 h216 -Wrap Section, % values2String("|", map(["Stints", "Laps", "Pitstop"], "translate")*)
		
		Gui Tab, 1
		
		Gui %window%:Add, ListView, x24 ys+33 w577 h170 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDlistHandle gchooseStint, % values2String("|", map(["#", "Driver", "Weather", "Compound", "Laps", "Pos. (Start)", "Pos. (End)", "Avg. Laptime", "Consumption", "Accidents", "Race Craft", "Consistency", "Car Control"], "translate")*)
		
		this.iStintsListView := listHandle
		
		Gui Tab, 2
		
		Gui %window%:Add, ListView, x24 ys+33 w577 h170 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDlistHandle gchooseLap, % values2String("|", map(["#", "Stint", "Driver", "Position", "Laptime", "Consumption", "Accident"], "translate")*)
		
		this.iLapsListView := listHandle
		
		Gui Tab, 3
	
		Gui %window%:Add, Text, x24 ys+34 w85 h20, % translate("Lap")
		Gui %window%:Add, Edit, x106 yp-2 w50 h20 Limit3 Number vpitstopLapEdit
		Gui %window%:Add, UpDown, x138 yp-2 w18 h20
		
		Gui %window%:Add, Text, x24 yp+30 w85 h20, % translate("Refuel")
		Gui %window%:Add, Edit, x106 yp-2 w50 h20 Limit3 Number vpitstopRefuelEdit
		Gui %window%:Add, UpDown, x138 yp-2 w18 h20
		Gui %window%:Add, Text, x164 yp+2 w30 h20, % translate("Liter")

		Gui %window%:Add, Text, x24 yp+24 w85 h23 +0x200, % translate("Tyre Change")
		choices := map(["No Tyre Change", "Wet", "Dry", "Dry (Red)", "Dry (White)", "Dry (Blue)"], "translate")
		Gui %window%:Add, DropDownList, x106 yp w157 AltSubmit Choose1 vpitstopTyreCompoundDropDown gupdateState, % values2String("|", choices*)

		Gui %window%:Add, Text, x24 yp+26 w85 h20, % translate("Tyre Set")
		Gui %window%:Add, Edit, x106 yp-2 w50 h20 Limit2 Number vpitstopTyreSetEdit
		Gui %window%:Add, UpDown, x138 yp w18 h20
		
		Gui %window%:Add, Text, x24 yp+24 w85 h20, % translate("Pressures")
		
		Gui %window%:Add, Edit, x106 yp-2 w50 h20 Limit4 vpitstopPressureFLEdit
		Gui %window%:Add, Edit, x160 yp w50 h20 Limit4 vpitstopPressureFREdit
		Gui %window%:Add, Text, x214 yp+2 w30 h20, % translate("PSI")
		Gui %window%:Add, Edit, x106 yp+20 w50 h20 Limit4 vpitstopPressureRLEdit
		Gui %window%:Add, Edit, x160 yp w50 h20 Limit4 vpitstopPressureRREdit
		Gui %window%:Add, Text, x214 yp+2 w30 h20, % translate("PSI")
		
		Gui %window%:Add, Text, x24 yp+24 w85 h23 +0x200, % translate("Repairs")
		choices := map(["No Repairs", "Bodywork & Aerodynamics", "Suspension & Chassis", "Everything"], "translate")
		Gui %window%:Add, DropDownList, x106 yp w157 AltSubmit Choose1 vpitstopRepairsDropDown, % values2String("|", choices*)
		
		Gui %window%:Add, ListView, x270 ys+34 w331 h169 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDlistHandle, % values2String("|", map(["#", "Lap", "Refuel", "Compound", "Set", "Pressures", "Repairs"], "translate")*)
		
		this.iPitstopsListView := listHandle
		
		this.iReportViewer := new RaceReportViewer(window, chartViewer)
		
		this.initializeSession()
		
		this.updateState()
	}
	
	connect(silent := false) {
		try {
			this.Connector.Connect(this.ServerURL, this.ServerToken)
	
			this.iConnected := true
			
			showMessage(translate("Successfully connected to the Team Server."))
			
			this.initializeSession()
			this.loadTeams()
		}
		catch exception {
			this.iServerToken := ""
			
			GuiControl, , serverTokenEdit, % ""
			
			if !silent {
				title := translate("Error")
			
				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
				MsgBox 262160, %title%, % (translate("Cannot connect to the Team Server.") . "`n`n" . translate("Error: ") . exception.Message)
				OnMessage(0x44, "")
			}
		}
		
		this.loadTeams()
	}
	
	loadTeams() {
		window := this.Window
		
		Gui %window%:Default
		
		teams := (this.Connected ? loadTeams(this.Connector) : {})
		
		this.iTeams := teams

		names := getKeys(teams)
		identifiers := getValues(teams)
		
		GuiControl, , teamDropDownMenu, % ("|" . values2String("|", names*))
		
		chosen := inList(identifiers, this.SelectedTeam[true])
	
		if ((chosen == 0) && (names.Length() > 0))
			chosen := 1
		
		this.selectTeam((chosen == 0) ? false : identifiers[chosen])
	}
	
	selectTeam(identifier) {
		window := this.Window
		
		Gui %window%:Default
		
		chosen := inList(getValues(this.Teams), identifier)
		
		GuiControl Choose, teamDropDownMenu, % chosen

		names := getKeys(this.Teams)
		
		if (chosen > 0) {
			this.iTeamName := names[chosen]
			this.iTeamIdentifier := identifier
		}
		else {
			this.iTeamName := ""
			this.iTeamIdentifier := false
		}
		
		this.loadSessions()
	}
	
	loadSessions() {
		window := this.Window
		
		Gui %window%:Default
		
		teamIdentifier := this.SelectedTeam[true]
		
		sessions := ((this.Connected && teamIdentifier) ? loadSessions(this.Connector, teamIdentifier) : {})
		
		this.iSessions := sessions
				
		names := getKeys(sessions)
		identifiers := getValues(sessions)
		
		GuiControl, , sessionDropDownMenu, % ("|" . values2String("|", names*))
		
		chosen := inList(identifiers, this.SelectedSession[true])
	
		if ((chosen == 0) && (names.Length() > 0))
			chosen := 1
		
		this.selectSession((chosen == 0) ? false : identifiers[chosen])
	}
	
	selectSession(identifier) {
		window := this.Window
		
		Gui %window%:Default
		
		chosen := inList(getValues(this.Sessions), identifier)
		
		GuiControl Choose, sessionDropDownMenu, % chosen

		names := getKeys(this.Sessions)
		
		if (chosen > 0) {
			this.iSessionName := names[chosen]
			this.iSessionIdentifier := identifier
		}
		else {
			this.iSessionName := ""
			this.iSessionIdentifier := false
		}
		
		this.loadSession()
	}
	
	updateState() {
		window := this.Window
		
		Gui %window%:Default
		
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
		
		GuiControl Disable, dataXDropDown
		GuiControl Disable, dataY1DropDown
		GuiControl Disable, dataY2DropDown
		GuiControl Disable, dataY3DropDown

		if this.ActiveSession {
			if inList(["Driver", "Position", "Pace"], this.SelectedReport)
				GuiControl Enable, reportSettingsButton
			else
				GuiControl Disable, reportSettingsButton
			
			if inList(["Pressures", "Temperatures", "Free"], this.SelectedReport) {
				GuiControl Enable, chartTypeDropDown

				GuiControl Enable, dataXDropDown
				GuiControl Enable, dataY1DropDown
				GuiControl Enable, dataY2DropDown
				GuiControl Enable, dataY3DropDown
			}
			else {
				GuiControl Disable, chartTypeDropDown
				GuiControl Choose, chartTypeDropDown, 0
		
				this.iSelectedChartType := false
				
				GuiControl Choose, dataXDropDown, 0
				GuiControl Choose, dataY1DropDown, 0
				GuiControl Choose, dataY2DropDown, 0
				GuiControl Choose, dataY3DropDown, 0
			}
		}
		else {
			GuiControl Disable, reportSettingsButton

			GuiControl Choose, dataXDropDown, 0
			GuiControl Choose, dataY1DropDown, 0
			GuiControl Choose, dataY2DropDown, 0
			GuiControl Choose, dataY3DropDown, 0
			
			GuiControl Disable, chartTypeDropDown
			GuiControl Choose, chartTypeDropDown, 0
			
			this.iSelectedChartType := false
		}
	}
	
	planPitstop() {
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
			session := this.SelectedSession[true]
			
			lap := this.Connector.GetSessionLastLap(session)

			this.Connector.SetLapValue(lap, "Pitstop Plan", printConfiguration(pitstopPlan))
			this.Connector.SetSessionValue(session, "Pitstop Plan", lap)
			
			showMessage(translate("Race Engineer will be instructed in the next lap..."))
		}
		catch exception {
			showMessage(translate("Session has not been started yet..."))
		}
	}
	
	chooseAnalysisMenu(line) {
		if !this.ActiveSession
			return
		
		window := this.Window
						
		Gui %window%:Default
		
		switch line {
		}
	}
	
	chooseInformationMenu(line) {
		if !this.ActiveSession
			return
		
		window := this.Window
						
		Gui %window%:Default
		
		switch line {
		}
	}
	
	choosePitstopMenu(line) {
		if !this.ActiveSession
			return
		
		window := this.Window
						
		Gui %window%:Default
		
		switch line {
			case 3:
				this.planPitstop()
		}
	}
	
	withExceptionHandler(function, arguments*) {
		try {
			%function%(arguments*)
		}
		catch exception {
			title := translate("Error")
		
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			MsgBox 262160, %title%, % (translate("Error while executing command.") . "`n`n" . translate("Error: ") . exception.Message)
			OnMessage(0x44, "")
		}
	}
	
	initializeSession() {
		if this.ActiveSession {
			directory := this.SessionDirectory
			
			try {
				FileRemoveDir %directory%, 1
			}
			catch exception {
				; ignore
			}
			
			FileCreateDir %directory%
			
			reportDirectory := (directory . "Race Report")
			
			try {
				FileRemoveDir %reportDirectory%, 1
			}
			catch exception {
				; ignore
			}
		
			FileCreateDir %reportDirectory%
		}
		
		Gui ListView, % this.StintsListView
		
		LV_Delete()
		
		Gui ListView, % this.LapsListView
		
		LV_Delete()
		
		Gui ListView, % this.PitstopsListView
		
		LV_Delete()
		
		this.iStints := {}
		this.iLaps := {}
		
		this.iLastLap := false
		this.iCurrentStint := false
		
		this.iTelemetryDatabase := false
		this.iPressuresDatabase := false
		
		this.iReportDatabase := false
		this.iSelectedReport := false
		this.iSelectedChartType := false
		
		this.showChart(false)
	}
	
	loadNewStints(currentStint) {
		session := this.SelectedSession[true]
		newStints := []
			
		if (!this.CurrentStint || (currentStint.Nr > this.CurrentStint.Nr)) {
			for ignore, identifier in string2Values(";", this.Connector.GetSessionStints(session))
				if !this.Stints.HasKey(identifier)
					newStints.Push(parseObject(this.Connector.GetStint(identifier)))
			
			Loop % newStints.Length()
			{
				stint := newStints[A_Index]
				identifier := stint.Identifier
				
				driver := parseObject(this.Connector.GetDriver(this.Connector.GetStintDriver(identifier)))
				
				stint.Driver := driver
				stint.Driver.Fullname := computeDriverName(driver.Forname, driver.Surname, driver.Nickname)
				stint.FuelConsumption := 0.0
				stint.Accidents := 0
				stint.Weather := "-"
				stint.Compound := "-"
				stint.StartPosition := "-"
				stint.EndPosition := "-"
				stint.AvgLaptime := "-"
				stint.RaceCraft := "-"
				stint.Consistency := "-"
				stint.CarControl := "-"
				
				stint.Laps := []
				
				this.Stints[identifier] := stint
				this.Stints[stint.Nr] := stint
			}
		}
		
		bubbleSort(newStints, "objectOrder")
			
		return newStints
	}

	loadNewLaps(stint) {
		newLaps := []
				
		for ignore, identifier in string2Values(";" , this.Connector.GetStintLaps(stint.Identifier))
			if !this.Laps.HasKey(identifier) {
				newLap := parseObject(this.Connector.GetLap(identifier))
				
				if !this.Laps.HasKey(newLap.Nr)
					newLaps.Push(newLap)
			}
		
		bubbleSort(newLaps, "objectOrder")
		
		Loop % newLaps.Length()
		{
			lap := newLaps[A_Index]
			identifier := lap.Identifier
			
			stint.Laps.Push(lap)
			lap.Stint := stint
			
			rawData := this.Connector.GetLapValue(identifier, "Telemetry Data")
			data := parseConfiguration(rawData)
			
			lap.Telemetry := rawData
			
			damage := 0
			
			for ignore, value in string2Values(",", getConfigurationValue(data, "Car Data", "BodyworkDamage"))
				damage += value
			
			for ignore, value in string2Values(",", getConfigurationValue(data, "Car Data", "SuspensionDamage"))
				damage += value
			
			lap.Damage := damage
			
			if ((lap.Nr == 1) && (damage > 0))
				lap.Accident := true
			else if ((lap.Nr > 1) && (damage > this.Laps[lap.Nr - 1].Damage))
				lap.Accident := true
			else
				lap.Accident := false
			
			lap.FuelRemaining := Round(getConfigurationValue(data, "Car Data", "FuelRemaining"), 1)
			
			if ((lap.Nr == 1) || (stint.Laps[1] == lap))
				lap.FuelConsumption := "-"
			else
				lap.FuelConsumption := Round((this.Laps[lap.Nr - 1].FuelRemaining - lap.FuelRemaining), 1)
			
			lap.Laptime := Round(getConfigurationValue(data, "Stint Data", "LapLastTime") / 1000, 1)
			
			lap.Map := getConfigurationValue(data, "Car Data", "Map")
			lap.TC := getConfigurationValue(data, "Car Data", "TC")
			lap.ABS := getConfigurationValue(data, "Car Data", "ABS")
			
			lap.Weather := translate(getConfigurationValue(data, "Weather Data", "Weather"))
			lap.AirTemperature := Round(getConfigurationValue(data, "Weather Data", "Temperature"), 1)
			lap.TrackTemperature := Round(getConfigurationValue(data, "Track Data", "Temperature"), 1)
			lap.Grip := translate(getConfigurationValue(data, "Track Data", "Grip"))
			
			compound := getConfigurationValue(data, "Car Data", "TyreCompound")
			color := getConfigurationValue(data, "Car Data", "TyreCompoundColor")
			
			if (color != "Black")
				compound .= (" (" . color . ")")
			
			lap.Compound := translate(compound)
			
			rawData := this.Connector.GetLapValue(identifier, "Positions Data")
			data := parseConfiguration(rawData)
			
			lap.Positions := rawData
			
			car := getConfigurationValue(data, "Position Data", "Driver.Car")
			
			if car
				lap.Position := getConfigurationValue(data, "Position Data", "Car." . car . ".Position")
			else
				lap.Position := "-"
			
			this.Laps[identifier] := lap
			this.Laps[lap.Nr] := lap
		}
		
		return newLaps
	}
	
	updateDriverStats(stint) {
	}
		
	updateStint(stint) {
		window := this.Window
				
		Gui %window%:Default
		
		Gui ListView, % this.StintsListView
		
		stint.FuelConsumption := 0.0
		stint.Accidents := 0
		stint.Weather := ""
		
		laps := stint.Laps
		numLaps := laps.Length()
		
		lapTimes := []
		
		for ignore, lap in laps {
			if (lap.Nr > 1) {
				consumption := lap.FuelConsumption
					
				if consumption is number
					stint.FuelConsumption += ((this.Laps[lap.Nr - 1].FuelConsumption = "-") ? (consumption * 2) : consumption)
			}
				
			if lap.Accident
				stint.Accidents += 1
			
			lapTimes.Push(lap.Laptime)
			
			if (A_Index == 1) {
				stint.Compound := lap.Compound
				stint.StartPosition := lap.Position
			}
			else if (A_Index == numLaps)
				stint.EndPosition := lap.Position
			
			weather := lap.Weather
			
			if (stint.Weather = "")
				stint.Weather := weather
			else if !inList(string2Values(",", stint.Weather), weather)
				stint.Weather .= (", ", weather)
		}
		
		stint.AvgLaptime := Round(average(laptimes), 1)
		stint.FuelConsumption := Round(stint.FuelConsumption, 1)
		
		this.updateDriverStats(stint)
		
		LV_Modify(stint.Row, "", stint.Nr, stint.Driver.FullName, stint.Weather, stint.Compound, stint.Laps.Length()
							   , stint.StartPosition, stint.EndPosition, stint.AvgLaptime, stint.FuelConsumption, stint.Accidents
							   , stint.RaceCraft, stint.Consistency, stint.CarControl)
	}
	
	syncLaps() {
		session := this.SelectedSession[true]
		
		window := this.Window
		
		Gui %window%:Default
		
		try {
			currentStint := this.Connector.GetSessionCurrentStint(session)
			
			if currentStint
				currentStint := parseObject(this.Connector.GetStint(currentStint))
		}
		catch exception {
			currentStint := false
		}
		
		try {
			lastLap := this.Connector.GetSessionLastLap(session)
			
			if lastLap
				lastLap := parseObject(this.Connector.GetLap(lastLap))
		}
		catch exception {
			lastLap := false
		}
		
		newData := false
		
		first := (!this.CurrentStint || !this.LastLap)
		
		if (!currentStint
		 || !lastLap
		 || (this.CurrentStint && ((currentStint.Nr < this.CurrentStint.Nr)
								|| ((currentStint.Nr = this.CurrentStint.Nr) && (currentStint.Identifier != this.CurrentStint.Identifier))))
		 || (this.LastLap && (lastLap.Nr < this.LastLap.Nr))) {
			this.initializeSession()
			
			first := true
		}
		
		newData := first
		
		if !lastLap
			return false
		
		if (!this.LastLap || (lastLap.Nr > this.LastLap.Nr)) {
			try {
				newStints := this.loadNewStints(currentStint)
				
				currentStint := this.Stints[currentStint.Identifier]
				
				updatedStints := []
				
				if this.CurrentStint
					updatedStints := [this.CurrentStint]
					
				Gui ListView, % this.StintsListView
				
				for ignore, stint in newStints {
					LV_Add("", stint.Nr, stint.Driver.FullName, stint.Weather, stint.Compound, stint.Laps.Length()
							 , stint.StartPosition, stint.EndPosition, stint.AvgLaptime, stint.FuelConsumption, stint.Accidents
							 , stint.RaceCraft, stint.Consistency, stint.CarControl)
					
					stint.Row := LV_GetCount()
					
					updatedStints.Push(stint)
				}
				
				if first {
					LV_ModifyCol()
					
					Loop 13
						LV_ModifyCol(A_Index, "AutoHdr")
				}
		
				Gui ListView, % this.LapsListView
				
				for ignore, stint in updatedStints {
					for ignore, lap in this.loadNewLaps(stint) {
						LV_Add("", lap.Nr, lap.Stint.Nr, stint.Driver.Fullname, lap.Position, lap.Laptime, lap.FuelConsumption, lap.Accident ? translate("x") : "")
					
						lap.Row := LV_GetCount()
					}
				}
				
				if first {
					LV_ModifyCol()
					
					Loop 7
						LV_ModifyCol(A_Index, "AutoHdr")
				}
				
				for ignore, stint in updatedStints
					this.updateStint(stint)
				
				newData := true
				
				this.iLastLap := this.Laps[lastLap.Nr]
				this.iCurrentStint := currentStint
			}
			catch exception {
				return newData
			}
		}
		
		return newData
	}
	
	syncRaceReport() {
		lastLap := this.LastLap
		
		if lastLap
			lastLap := lastLap.Nr
		else
			return
		
		directory := this.SessionDirectory . "Race Report\"
		
		FileCreateDir %directory%
		
		data := readConfiguration(directory . "Race.data")
		
		if (data.Count() == 0)
			lap := 1
		else
			lap := (getConfigurationValue(data, "Laps", "Count") + 1)
		
		if (lap == 1) {
			try {
				try {
					raceInfo := this.Connector.getLapValue(this.Laps[lap].Identifier, "Race Strategist Race Info")
				}
				catch exception {
					raceInfo := false
				}

				if (!raceInfo || (raceInfo == ""))
					return
					
				FileAppend %raceInfo%, %directory%Race.data
			}
			catch exception {
				; ignore
			}
				
			data := readConfiguration(directory . "Race.data")
		}
		
		newData := false
		
		while (lap <= lastLap) {
			try {
				lapData := parseConfiguration(this.Connector.getLapValue(this.Laps[lap].Identifier, "Race Strategist Race Lap"))
			}
			catch exception {
				return newData
			}
			
			if (lapData.Count() == 0)
				return
			
			for key, value in getConfigurationSectionValues(lapData, "Lap")
				setConfigurationValue(data, "Laps", key, value)
			
			times := getConfigurationValue(lapData, "Times", lap)
			positions := getConfigurationValue(lapData, "Positions", lap)
			laps := getConfigurationValue(lapData, "Laps", lap)
			drivers := getConfigurationValue(lapData, "Drivers", lap)
			
			newLine := ((lap > 1) ? "`n" : "")
			
			line := (newLine . times)
			
			FileAppend %line%, % directory . "Times.CSV"
			
			line := (newLine . positions)
			
			FileAppend %line%, % directory . "Positions.CSV"
			
			line := (newLine . laps)
			
			FileAppend %line%, % directory . "Laps.CSV"
			
			line := (newLine . drivers)
			fileName := (directory . "Drivers.CSV")
			
			FileAppend %line%, %fileName%, UTF-16
			
			removeConfigurationValue(data, "Laps", "Lap")
			setConfigurationValue(data, "Laps", "Count", lap)
			
			newData := true
			lap += 1
		}
		
		if newData
			writeConfiguration(directory . "Race.data", data)
		
		return newData
	}
	
	syncTelemetry() {
		session := this.SelectedSession[true]
		
		if !this.TelemetryDatabase
			this.iTelemetryDatabase := new this.SessionTelemetryDatabase(this)
		
		telemetryDB := this.TelemetryDatabase
		
		lastLap := this.LastLap
		
		if lastLap
			lastLap := lastLap.Nr
		else
			return
		
		tyresTable := telemetryDB.Database.Tables["Tyres"]
		lap := tyresTable.Length()
		
		if (lap > 0)
			runningLap := tyresTable[lap]["Tyre.Laps"]
		else
			runningLap := 0

		newData := false
		lap += 1
		
		while (lap <= lastLap) {
			try {
				telemetryData := this.Connector.GetSessionLapValue(session, lap, "Race Strategist Telemetry")
			}
			catch exception {
				telemetryData := values2String(";", "-", "-", "-", "-", "-", "-", "-", "-", "-", false, "n/a", "n/a", "n/a", "-", "-", "-,-,-,-", "-,-,-,-")
			}
		
			if (!telemetryData || (telemetryData == "")) {
				lap += 1
				
				continue
			}
			
			telemetryData := string2Values(";", telemetryData)
		
			if telemetryData[10]
				runningLap := 0
			
			runningLap += 1
			
			pressures := string2Values(",", telemetryData[16])
			temperatures := string2Values(",", telemetryData[17])
			
			telemetryDB.addElectronicEntry(telemetryData[4], telemetryData[5], telemetryData[6], telemetryData[14], telemetryData[15]
										 , telemetryData[11], telemetryData[12], telemetryData[13], telemetryData[7], telemetryData[8], telemetryData[9])
										 
			telemetryDB.addTyreEntry(telemetryData[4], telemetryData[5], telemetryData[6], telemetryData[14], telemetryData[15], runningLap
								   , pressures[1], pressures[2], pressures[4], pressures[4]
								   , temperatures[1], temperatures[2], temperatures[3], temperatures[4]
								   , telemetryData[7], telemetryData[8], telemetryData[9])
			
			newData := true
			lap += 1
		}
		
		return newData
	}
	
	syncTyrePressures() {
		session := this.SelectedSession[true]
		
		if !this.PressuresDatabase
			this.iPressuresDatabase := new this.SessionPressuresDatabase(this)
		
		pressuresDB := this.PressuresDatabase
		
		lastLap := this.LastLap
		
		if lastLap
			lastLap := lastLap.Nr
		else
			return
		
		pressuresTable := pressuresDB.Database.Tables["Setup.Pressures"]
		lap := pressuresTable.Length()
		
		newData := false
		lap += 1
		
		flush := (Abs(lastLap - lap) <= 2)
		
		while (lap <= lastLap) {
			try {
				lapPressures := this.Connector.GetSessionLapValue(session, lap, "Race Engineer Pressures")
			}
			catch exception {
				lapPressures := values2String(";", "-", "-", "-", "-", "-", "-", "-", "-", "-,-,-,-", "-,-,-,-")
			}
		
			if (!lapPressures || (lapPressures == "")) {
				lap += 1
				
				continue
			}
			
			lapPressures := string2Values(";", lapPressures)
			
			pressuresDB.updatePressures(lapPressures[4], lapPressures[5], lapPressures[6]
									  , lapPressures[7], lapPressures[8], string2Values(",", lapPressures[9]), string2Values(",", lapPressures[10]), flush)
			
			newData := true
			lap += 1
		}
		
		if (newData && !flush)
			pressuresDB.Database.flush()
		
		return newData
	}
	
	syncPitstops(state := false) {
		session := this.SelectedSession[true]
		
		Gui ListView, % this.PitstopsListView
		
		nextStop := (LV_GetCount() + 1)
		
		if !state
			try {
				state := this.Connector.GetSessionValue(session, "Race Engineer State")
				
				state := parseConfiguration(state)
			}
			catch exception {
				; ignore
			}
		
		if (state && (state != "")) {
			lap := getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Lap", false)
			
			if lap {
				fuel := Round(getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Fuel", 0))
				compound := Round(getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Tyre.Compound", false))
				compoundColor := Round(getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Tyre.Compound.Color"))
				tyreSet := Round(getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Tyre.Set", "-"))
				pressureFL := Round(getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Tyre.Pressure.FL", "-"), 1)
				pressureFR := Round(getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Tyre.Pressure.FR", "-"), 1)
				pressureRL := Round(getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Tyre.Pressure.RL", "-"), 1)
				pressureRR := Round(getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Tyre.Pressure.RR", "-"), 1)
				repairBodywork := Round(getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Repair.Bodywork", "-"))
				repairSuspension := Round(getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Repair.Suspension", "-"))
				
				if compound {
					compound := (compound . ((compoundColor = "Black") ? "" : (" (" . compoundColor . ")")))
					pressures := values2String(", ", pressureFL, pressureFR, pressureRL, pressureRR)
				}
				else {
					compound := "-"
				
					tyreSet := "-"
					pressures := "-"
				}
				
				if (repairBodywork && repairSuspension)
					repairs := (translate("Bodywork") . ", " . translate("Suspension"))
				else if repairBodywork
					repairs := translate("Bodywork")
				else if repairSuspension
					repairs := translate("Suspension")
				else
					repairs := "-"
				
				LV_Add("", nextStop, lap, fuel, compound, tyreSet, pressures, repairs)
				
				if (nextStop = 1) {
					LV_ModifyCol()
					
					Loop 7
						LV_ModifyCol(A_Index, "AutoHdr")
				}
					
				
				this.syncPitstop(state)
			}
		}
	}
	
	syncSession() {
		newLaps := false
		newData := false
		
		if this.ActiveSession {
			if this.syncLaps()
				newLaps := true
			
			if this.syncRaceReport()
				newData := true
			
			if this.syncTelemetry()
				newData := true
			
			if this.syncTyrePressures()
				newData := true
			
			if newLaps
				this.syncPitstops()
		}
		
		if (newData || newLaps)
			this.updateReports()
	}
	
	updateReports() {
		if !this.SelectedReport
			this.iSelectedReport := "Overview"
		
		this.showReport(this.SelectedReport, true)
	}
	
	show() {
		window := this.Window
			
		Gui %window%:Show
		
		callback := ObjBindMethod(this, "syncSession")
		
		SetTimer %callback%, 10000
		
		while !this.iClosed
			Sleep 1000
		
		SetTimer %callback%, Off
	}
	
	close() {
		this.iClosed := true
	}
	
	showChart(drawChartFunction) {
		window := this.Window
		
		Gui %window%:Default
		
		chartViewer.Document.Open()
		
		if (drawChartFunction && (drawChartFunction != "")) {
			before =
			(
			<html>
			    <meta charset='utf-8'>
				<head>
					<style>
						.headerStyle { height: 25; font-size: 11px; font-weight: 500; background-color: 'FFFFFF'; }
						.rowStyle { font-size: 11px; background-color: 'E0E0E0'; }
						.oddRowStyle { font-size: 11px; background-color: 'E8E8E8'; }
					</style>
					<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
					<script type="text/javascript">
						google.charts.load('current', {'packages':['corechart', 'table', 'scatter']}).then(drawChart);
			)

			after =
			(
					</script>
				</head>
				<body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>
					<div id="chart_id" style="width: 798px; height: 248px"></div>
				</body>
			</html>
			)

			html := (before . drawChartFunction . after)
			
			chartViewer.Document.Write(html)
		}
		else {
			html := "<html><body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"
		
			chartViewer.Document.Write(html)
		}
		
		chartViewer.Document.Close()
	}
	
	showDataPlot(data, xAxis, yAxises) {
		double := (yAxises.Length() > 1)
		
		drawChartFunction := ""
		
		drawChartFunction .= "function drawChart() {"
		drawChartFunction .= "`nvar data = new google.visualization.DataTable();"
		
		if (this.SelectedChartType = "Bubble")
			drawChartFunction .= ("`ndata.addColumn('string', 'ID');")
		
		drawChartFunction .= ("`ndata.addColumn('number', '" . xAxis . "');")
		
		for ignore, yAxis in yAxises {
			drawChartFunction .= ("`ndata.addColumn('number', '" . yAxis . "');")
		}
		
		drawChartFunction .= "`ndata.addRows(["
		
		for ignore, values in data {
			if (A_Index > 1)
				drawChartFunction .= ",`n"
			
			value := values[xAxis]
			
			if ((value = "n/a") || (value == kNull))
				value := "null"

			if (this.SelectedChartType = "Bubble")
				drawChartFunction .= ("['', " . value)
			else
				drawChartFunction .= ("[" . value)
		
			for ignore, yAxis in yAxises {
				value := values[yAxis]
			
				if ((value = "n/a") || (value == kNull))
					value := "null"
				
				drawChartFunction .= (", " . value)
			}
			
			drawChartFunction .= "]"
		}
		
		drawChartFunction .= "`n]);"
		
		series := "series: {"
		vAxis := "vAxis: { gridlines: { color: 'E0E0E0' }, "
		for ignore, yAxis in yAxises {
			if (A_Index > 1) {
				series .= ", "
				vAxis .= ", "
			}
			
			index := A_Index - 1
			
			series .= (index . ": {targetAxisIndex: " . index . "}")
			vAxis .= (index . ": {title: '" . translate(yAxis) . "'}")
		}
		
		series .= "}"
		vAxis .= "}"
		
		if (this.SelectedChartType = "Scatter") {
			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom'}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#D8D8D8', hAxis: { title: '" . translate(xAxis) . "', gridlines: { color: 'E0E0E0' } }, " . series . ", " . vAxis . "};")
				
			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.ScatterChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}
		else if (this.SelectedChartType = "Bar") {
			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom'}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#D8D8D8', hAxis: { viewWindowMode: 'pretty' }, vAxis: { viewWindowMode: 'pretty' } };")
				
			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.BarChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}
		else if (this.SelectedChartType = "Bubble") {
			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom'}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#D8D8D8', hAxis: { title: '" . translate(xAxis) . "', viewWindowMode: 'pretty' }, vAxis: { title: '" . translate(yAxises[1]) . "', viewWindowMode: 'pretty' }, colorAxis: { legend: {position: 'none'}, colors: ['blue', 'red'] }, sizeAxis: { maxSize: 15 } };")
				
			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.BubbleChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}
		else if (this.SelectedChartType = "Line") {
			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom'}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#D8D8D8' };")
				
			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.LineChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}
		
		this.showChart(drawChartFunction)
	}
	
	showDetails(details) {
		chartID := 0
		html := (details ? details : "")
		
		if details {
			drawChartFunction := "function drawChart" . chartID . "() {}"
			
			chartArea := ""
			
			before =
			(
				<meta charset='utf-8'>
				<head>
					<style>
						.headerStyle { height: 25; font-size: 11px; font-weight: 500; background-color: 'FFFFFF'; }
						.rowStyle { font-size: 11px; background-color: 'E0E0E0'; }
						.oddRowStyle { font-size: 11px; background-color: 'E8E8E8'; }
					</style>
					<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
					<script type="text/javascript">
						google.charts.load('current', {'packages':['corechart', 'table', 'scatter']}).then(drawChart%chartID%);
			)

			after =
			(
					</script>
				</head>
			)
		}
		else {
			before := ""
			after := ""
			drawChartFunction := ""
			chartArea := ""
		}
			
		html := ("<html>" . before . drawChartFunction . after . "<body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><style> div, table { font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><style> #stints td { border-right: solid 1px #A0A0A0; } </style><style> #header { font-size: 12px; } </style><style> #data { border-collapse: separate; border-spacing: 10px; text-align: center; } </style><div>" . html . "</div><br>" . chartArea . "</body></html>")

		detailsViewer.Document.Open()
		detailsViewer.Document.Write(html)
		detailsViewer.Document.Close()
	}
	
	selectReport(report) {
		Gui ListView, % reportsListView
		
		if report {
			LV_Modify(inList(kSessionReports, report), "+Select")
		
			this.iSelectedReport := report
		}
		else {
			Loop % LV_GetCount()
				LV_Modify(A_Index, "-Select")
			
			this.iSelectedReport := false
		}
	}
	
	showOverviewReport() {
		this.selectReport("Overview")
		
		this.ReportViewer.setReport(this.SessionDirectory . "Race Report")
		this.ReportViewer.showOverviewReport()
		
		this.updateState()
	}
	
	showCarReport() {
		this.selectReport("Car")
		
		this.ReportViewer.setReport(this.SessionDirectory . "Race Report")
		this.ReportViewer.showCarReport()
		
		this.updateState()
	}
	
	showDriverReport() {
		this.selectReport("Driver")
		
		this.ReportViewer.setReport(this.SessionDirectory . "Race Report")
		this.ReportViewer.showDriverReport()
		
		this.updateState()
	}
	
	editDriverReportSettings() {
		this.ReportViewer.setReport(this.SessionDirectory . "Race Report")
		
		return this.ReportViewer.editReportSettings("Laps", "Drivers")
	}
	
	showPositionReport() {
		this.selectReport("Position")
		
		this.ReportViewer.setReport(this.SessionDirectory . "Race Report")
		this.ReportViewer.showPositionReport()
		
		this.updateState()
	}
	
	editPositionReportSettings() {
		this.ReportViewer.setReport(this.SessionDirectory . "Race Report")
		
		return this.ReportViewer.editReportSettings("Laps")
	}
	
	showPaceReport() {
		this.selectReport("Pace")
		
		this.ReportViewer.setReport(this.SessionDirectory . "Race Report")
		this.ReportViewer.showPaceReport()
		
		this.updateState()
	}
	
	editPaceReportSettings() {
		this.ReportViewer.setReport(this.SessionDirectory . "Race Report")
		
		return this.ReportViewer.editReportSettings("Laps", "Drivers")
	}
	
	showRaceReport(report) {
		switch report {
			case "Overview":
				this.showOverviewReport()
			case "Car":
				this.showCarReport()
			case "Driver":
				if !this.ReportViewer.Settings.HasKey("Drivers")
					this.ReportViewer.Settings["Drivers"] := [1, 2, 3, 4, 5]
				
				this.showDriverReport()
			case "Position":
				this.showPositionReport()
			case "Pace":
				this.showPaceReport()
		}
	}
	
	showTelemetryReport() {
		window := this.Window
		
		Gui %window%:Default
		
		GuiControlGet dataXDropDown
		GuiControlGet dataY1DropDown
		GuiControlGet dataY2DropDown
		GuiControlGet dataY3DropDown
		
		xAxis := this.iXColumns[dataXDropDown]
		yAxises := Array(this.iY1Columns[dataY1DropDown])
		
		if (dataY2DropDown > 1)
			yAxises.Push(this.iY2Columns[dataY2DropDown - 1])
		
		if (dataY3DropDown > 1)
			yAxises.Push(this.iY3Columns[dataY3DropDown - 1])
		
		this.showDataPlot(this.ReportDatabase.Tables["Lap.Data"], xAxis, yAxises)
		
		this.updateState()
	}
	
	showPressuresReport() {
		this.selectReport("Pressures")
		
		this.showTelemetryReport()
		
		this.updateState()
	}
	
	showTemperaturesReport() {
		this.selectReport("Temperatures")
		
		this.showTelemetryReport()
		
		this.updateState()
	}
	
	showCustomReport() {
		this.selectReport("Free")
		
		this.showTelemetryReport()
		
		this.updateState()
	}
	
	updateSeriesSelector(report, force := false) {
		window := this.Window
		
		Gui %window%:Default
		
		GuiControlGet dataXDropDown
		
		if (force || (report != this.SelectedReport) || (dataXDropDown == 0)) {
			xChoices := []
			y1Choices := []
			y2Choices := []
			y3Choices := []
			y4Choices := []
		
			if (report = "Pressures") {
				xChoices := ["Stint", "Lap", "Lap.Time"]
			
				y1Choices := ["Temperature.Air", "Temperature.Track", "Fuel.Remaining", "Tyre.Laps"
							, "Tyre.Pressure.Cold.Average", "Tyre.Pressure.Cold.Front.Average", "Tyre.Pressure.Cold.Rear.Average"
							, "Tyre.Pressure.Hot.Average", "Tyre.Pressure.Hot.Front.Average", "Tyre.Pressure.Hot.Rear.Average"
							, "Tyre.Pressure.Cold.Front.Left", "Tyre.Pressure.Cold.Front.Right", "Tyre.Pressure.Cold.Rear.Left", "Tyre.Pressure.Cold.Rear.Right"
							, "Tyre.Pressure.Hot.Front.Left", "Tyre.Pressure.Hot.Front.Right", "Tyre.Pressure.Hot.Rear.Left", "Tyre.Pressure.Hot.Rear.Right"]
				
				y2Choices := y1Choices
				y3Choices := y1Choices
			}
			else if (report = "Temperatures") {
				xChoices := ["Stint", "Lap", "Lap.Time"]
			
				y1Choices := ["Temperature.Air", "Temperature.Track", "Fuel.Remaining", "Tyre.Laps"
							, "Tyre.Pressure.Hot.Average", "Tyre.Pressure.Hot.Front.Average", "Tyre.Pressure.Hot.Rear.Average"
							, "Tyre.Pressure.Hot.Front.Left", "Tyre.Pressure.Hot.Front.Right", "Tyre.Pressure.Hot.Rear.Left", "Tyre.Pressure.Hot.Rear.Right"
							, "Tyre.Temperature.Average", "Tyre.Temperature.Front.Average", "Tyre.Temperature.Rear.Average"
							, "Tyre.Temperature.Front.Left", "Tyre.Temperature.Front.Right", "Tyre.Temperature.Rear.Left", "Tyre.Temperature.Rear.Right"]
				
				y2Choices := y1Choices
				y3Choices := y1Choices
			}
			else if (report = "Free") {
				xChoices := ["Stint", "Lap", "Lap.Time", "Tyre.Laps", "Map", "TC", "ABS", "Temperature.Air", "Temperature.Track"]
			
				y1Choices := ["Temperature.Air", "Temperature.Track", "Fuel.Remaining", "Fuel.Consumption", "Lap.Time", "Tyre.Laps", "Map", "TC", "ABS"
							, "Tyre.Pressure.Cold.Average", "Tyre.Pressure.Cold.Front.Average", "Tyre.Pressure.Cold.Rear.Average"
							, "Tyre.Pressure.Hot.Average", "Tyre.Pressure.Hot.Front.Average", "Tyre.Pressure.Hot.Rear.Average"
							, "Tyre.Pressure.Hot.Front.Left", "Tyre.Pressure.Hot.Front.Right", "Tyre.Pressure.Hot.Rear.Left", "Tyre.Pressure.Hot.Rear.Right"
							, "Tyre.Temperature.Average", "Tyre.Temperature.Front.Average", "Tyre.Temperature.Rear.Average"
							, "Tyre.Temperature.Front.Left", "Tyre.Temperature.Front.Right", "Tyre.Temperature.Rear.Left", "Tyre.Temperature.Rear.Right"]
				
				y2Choices := y1Choices
				y3Choices := y1Choices
			}
			
			this.iXColumns := xChoices
			this.iY1Columns := y1Choices
			this.iY2Columns := y2Choices
			this.iY3Columns := y3Choices
			
			GuiControl, , dataXDropDown, % ("|" . values2String("|", xChoices*))
			GuiControl, , dataY1DropDown, % ("|" . values2String("|", y1Choices*))
			GuiControl, , dataY2DropDown, % ("|" . values2String("|", translate("None"), y2Choices*))
			GuiControl, , dataY3DropDown, % ("|" . values2String("|", translate("None"), y3Choices*))
		
			dataY1DropDown := 0
			dataY2DropDown := 0
			dataY3DropDown := 0
			
			if (report = "Pressures") {
				GuiControl Choose, chartTypeDropDown, 4
				
				this.iSelectedChartType := "Line"
				
				dataXDropDown := inList(xChoices, "Lap")
				dataY1DropDown := inList(y1Choices, "Temperature.Air")
				dataY2DropDown := inList(y2Choices, "Tyre.Pressure.Cold.Average") + 1
				dataY3DropDown := inList(y3Choices, "Tyre.Pressure.Hot.Average") + 1
			}
			else if (report = "Temperatures") {
				GuiControl Choose, chartTypeDropDown, 1
				
				this.iSelectedChartType := "Scatter"
				
				dataXDropDown := inList(xChoices, "Lap")
				dataY1DropDown := inList(y1Choices, "Temperature.Air")
				dataY2DropDown := inList(y2Choices, "Tyre.Temperature.Front.Average") + 1
				dataY3DropDown := inList(y3Choices, "Tyre.Temperature.Rear.Average") + 1
			}
			else if (report = "Free") {
				GuiControl Choose, chartTypeDropDown, 1
				
				this.iSelectedChartType := "Scatter"
				
				dataXDropDown := inList(xChoices, "Lap")
				dataY1DropDown := inList(y1Choices, "Lap.Time")
				dataY2DropDown := inList(y2Choices, "Temperature.Air") + 1
				dataY3DropDown := inList(y3Choices, "Tyre.Pressure.Hot.Average") + 1
			}
			
			GuiControl Choose, dataXDropDown, %dataXDropDown%
			GuiControl Choose, dataY1DropDown, %dataY1DropDown%
			GuiControl Choose, dataY2DropDown, %dataY2DropDown%
			GuiControl Choose, dataY3DropDown, %dataY3DropDown%
		}
	}
	
	syncReportDatabase(report) {
		reportDB := this.ReportDatabase
		
		if !reportDB {
			reportDB := new Database(false, kSessionDataSchemas)
			
			this.iReportDatabase := reportDB
		}
		pressuresDB := this.PressuresDatabase
		telemetryDB := this.TelemetryDatabase
		
		if (!pressuresDB || !telemetryDB)
			return
				
		lastLap := this.LastLap
		
		if lastLap {
			pressuresTable := pressuresDB.Database.Tables["Setup.Pressures"]
			tyresTable := telemetryDB.Database.Tables["Tyres"]
					
			newLap := (reportDB.Tables["Lap.Data"].Length() + 1)
			
			while (newLap <= lastLap.Nr) {
				lap := this.Laps[newLap]
				
				if ((pressuresTable.Length() < newLap) || (tyresTable.Length() < newLap))
					return
				
				lapData := {Lap: newLap, Stint: lap.Stint.Nr, "Lap.Time": lap.Laptime
						  , "Fuel.Consumption": lap.FuelConsumption, "Fuel.Remaining": lap.FuelRemaining
						  , "Temperature.Air": valueOrNull(lap.AirTemperature), "Temperature.Track": valueOrNull(lap.TrackTemperature)
						  , Map: valueOrNull(lap.Map), TC: valueOrNull(lap.TC), ABS: valueOrNull(lap.ABS)}				
				
				pressures := pressuresTable[newLap]
				
				pressureFL := pressures["Tyre.Pressure.Cold.Front.Left"]
				pressureFR := pressures["Tyre.Pressure.Cold.Front.Right"]
				pressureRL := pressures["Tyre.Pressure.Cold.Rear.Left"]
				pressureRR := pressures["Tyre.Pressure.Cold.Rear.Right"]
				
				lapData["Tyre.Pressure.Cold.Front.Left"] := valueOrNull(pressureFL)
				lapData["Tyre.Pressure.Cold.Front.Right"] := valueOrNull(pressureFR)
				lapData["Tyre.Pressure.Cold.Rear.Left"] := valueOrNull(pressureRL)
				lapData["Tyre.Pressure.Cold.Rear.Right"] := valueOrNull(pressureRR)
				lapData["Tyre.Pressure.Cold.Average"] := valueOrNull(average([pressureFL, pressureFR, pressureRL, pressureRR]))
				lapData["Tyre.Pressure.Cold.Front.Average"] := valueOrNull(average([pressureFL, pressureFR]))
				lapData["Tyre.Pressure.Cold.Rear.Average"] := valueOrNull(average([pressureRL, pressureRR]))
				
				pressureFL := pressures["Tyre.Pressure.Hot.Front.Left"]
				pressureFR := pressures["Tyre.Pressure.Hot.Front.Right"]
				pressureRL := pressures["Tyre.Pressure.Hot.Rear.Left"]
				pressureRR := pressures["Tyre.Pressure.Hot.Rear.Right"]
				
				lapData["Tyre.Pressure.Hot.Front.Left"] := valueOrNull(pressureFL)
				lapData["Tyre.Pressure.Hot.Front.Right"] := valueOrNull(pressureFR)
				lapData["Tyre.Pressure.Hot.Rear.Left"] := valueOrNull(pressureRL)
				lapData["Tyre.Pressure.Hot.Rear.Right"] := valueOrNull(pressureRR)
				lapData["Tyre.Pressure.Hot.Average"] := valueOrNull(average([pressureFL, pressureFR, pressureRL, pressureRR]))
				lapData["Tyre.Pressure.Hot.Front.Average"] := valueOrNull(average([pressureFL, pressureFR]))
				lapData["Tyre.Pressure.Hot.Rear.Average"] := valueOrNull(average([pressureRL, pressureRR]))
		
				tyres := tyresTable[newLap]
				
				lapData["Tyre.Laps"] := valueOrNull(tyres["Tyre.Laps"])
				
				temperatureFL := tyres["Tyre.Temperature.Front.Left"]
				temperatureFR := tyres["Tyre.Temperature.Front.Right"]
				temperatureRL := tyres["Tyre.Temperature.Rear.Left"]
				temperatureRR := tyres["Tyre.Temperature.Rear.Right"]
				
				lapData["Tyre.Temperature.Front.Left"] := valueOrNull(temperatureFL)
				lapData["Tyre.Temperature.Front.Right"] := valueOrNull(temperatureFR)
				lapData["Tyre.Temperature.Rear.Left"] := valueOrNull(temperatureRL)
				lapData["Tyre.Temperature.Rear.Right"] := valueOrNull(temperatureRR)
				lapData["Tyre.Temperature.Average"] := valueOrNull(average([temperatureFL, temperatureFR, temperatureRL, temperatureRR]))
				lapData["Tyre.Temperature.Front.Average"] := valueOrNull(average([temperatureFL, temperatureFR]))
				lapData["Tyre.Temperature.Rear.Average"] := valueOrNull(average([temperatureRL, temperatureRR]))
				
				reportDB.add("Lap.Data", lapData, false)
				
				newLap += 1
			}
		}
	}
	
	reportSettings(report) {
		switch report {
			case "Driver":
				if this.editDriverReportSettings()
					this.showDriverReport()
			case "Position":
				if this.editPositionReportSettings()
					this.showPositionReport()
			case "Pace":
				if this.editPaceReportSettings()
					this.showPaceReport()
		}
	}
	
	showReport(report, force := false) {
		if (force || (report != this.SelectedReport)) {
			this.syncReportDatabase(report)
			this.updateSeriesSelector(report)
			
			if inList(kRaceReports, report)
				this.showRaceReport(report)
			else if (report = "Pressures")
				this.showPressuresReport()
			else if (report = "Temperatures")
				this.showTemperaturesReport()
			else if (report = "Free")
				this.showCustomReport()
		}
	}
	
	selectChartType(chartType, force := false) {
		if (force || (chartType != this.SelectedChartType)) {
			GuiControl Choose, chartTypeDropDown, % inList(["Scatter", "Bar", "Bubble", "Line"], chartType)
			
			this.iSelectedChartType := chartType
			
			this.showTelemetryReport()
		}
	}
	
	createStintHeader(stint) {
		html := "<table>"
		html .= ("<tr><td><b>" . translate("Driver:") . "</b></div></td><td>" . stint.Driver.Fullname . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Start Position:") . "</b></div></td><td>" . stint.StartPosition . "</td></tr>")
		html .= ("<tr><td><b>" . translate("End Position:") . "</b></div></td><td>" . stint.EndPosition . "</td></tr>")
		html .= "</table>"
		
		return html
	}
	
	createLaptimesDetails(stint) {
		html := "<table>"
		html .= ("<tr><td><b>" . translate("Average:") . "</b></td><td>" . stint.AvgLapTime . "</td></tr>")
		
		telemetry := ((stint.Nr == this.CurrentStint.Nr) ? this.LastLap.Telemetry : this.Laps[this.Stints[stint.Nr + 1].Lap - 1].Telemetry)
		
		telemetry := parseConfiguration(telemetry)
		
		html .= ("<tr><td><b>" . translate("Best:") . "</b></td><td>" . Round(getConfigurationValue(telemetry, "Stint Data", "LapBestTime") / 1000, 1) . "</td></tr>")
		
		html .= "</table>"
		
		return html
	}
	
	showStintDetails(stint) {
		html := ("<div id=""header""><b>" . translate("Stint: ") . stint.Nr . "</b></div>")
			
		html .= ("<br>" . this.createStintHeader(stint))
		
		html .= ("<br><br><div id=""header""><i>" . translate("Laptimes") . "</i></div>")
		
		html .= ("<br>" . this.createLaptimesDetails(stint))
			
		this.showDetails(html)
	}
	
	showLapDetails(lap) {
		this.showDetails("Lap: " . lap.Nr . "`n" . "Laptime: " . lap.Laptime)
	}
}


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

fixIE(version := 0, exeName := "") {
	static key := "Software\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION"
	static versions := {7: 7000, 8: 8888, 9: 9999, 10: 10001, 11: 11001}
	
	if versions.HasKey(version)
		version := versions[version]
	
	if !exeName {
		if A_IsCompiled
			exeName := A_ScriptName
		else
			SplitPath A_AhkPath, exeName
	}
	
	RegRead previousValue, HKCU, %key%, %exeName%

	if (version = "")
		RegDelete, HKCU, %key%, %exeName%
	else
		RegWrite, REG_DWORD, HKCU, %key%, %exeName%, %version%
	
	return previousValue
}

valueOrNull(value) {
	return (((value != "-") && (value != "n/a")) ? value : kNull)
}

objectOrder(a, b) {
	return (a.Nr > b.Nr)
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

computeDriverName(forName, surName, nickName) {
	name := ""
	
	if (forName != "")
		name .= (forName . A_Space)
	
	if (surName != "")
		name .= (surName . A_Space)
	
	if (nickName != "")
		name .= (translate("(") . nickName . translate(")"))
	
	return Trim(name)
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
	
	try {
		for ignore, identifier in string2Values(";", connector.GetAllTeams()) {
			team := parseObject(connector.GetTeam(identifier))
			
			teams[team.Name] := team.Identifier
		}
	}
	catch exception {
		; ignore
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

moveTeamDashboard() {
	moveByMouse(SessionWorkbench.Instance.Window)
}

closeTeamDashboard() {
	SessionWorkbench.Instance.close()
}

connectServer() {
	workbench := SessionWorkbench.Instance
	
	GuiControlGet serverURLEdit
	GuiControlGet serverTokenEdit
	
	workbench.iServerURL := serverURLEdit
	workbench.iServerToken := serverTokenEdit
	
	workbench.connect()
}

chooseTeam() {
	workbench := SessionWorkbench.Instance
	
	GuiControlGet teamDropDownMenu
	
	workbench.withExceptionhandler(ObjBindMethod(workbench, "selectTeam")
								 , getValues(workbench.Teams)[teamDropDownMenu])
}

chooseSession() {
	workbench := SessionWorkbench.Instance
	
	GuiControlGet sessionDropDownMenu
	
	workbench.withExceptionhandler(ObjBindMethod(workbench, "selectSession")
								 , getValues(workbench.Teams)[sessionDropDownMenu])
}

chooseChartType() {
	workbench := SessionWorkbench.Instance
	
	GuiControlGet chartTypeDropDown
	
	workbench.selectChartType(["Scatter", "Bar", "Bubble", "Line"][chartTypeDropDown])
}

analysisMenu() {
	GuiControlGet analysisMenuDropDown
	
	GuiControl Choose, analysisMenuDropDown, 1
	
	SessionWorkbench.Instance.chooseAnalysisMenu(analysisMenuDropDown)
}

informationMenu() {
	GuiControlGet informationMenuDropDown
	
	GuiControl Choose, informationMenuDropDown, 1
	
	SessionWorkbench.Instance.chooseInformationMenu(informationMenuDropDown)
}

pitstopMenu() {
	GuiControlGet pitstopMenuDropDown
	
	GuiControl Choose, pitstopMenuDropDown, 1
	
	SessionWorkbench.Instance.choosePitstopMenu(pitstopMenuDropDown)
}

openDashboardDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#session-workbench
}

updateState() {
	workbench := SessionWorkbench.Instance
	
	workbench.withExceptionhandler(ObjBindMethod(workbench, "updateState"))
}

planPitstop() {
	workbench := SessionWorkbench.Instance
	
	workbench.withExceptionhandler(ObjBindMethod(workbench, "planPitstop"))
}

chooseStint() {
	workbench := SessionWorkbench.Instance
	
	Gui ListView, % workbench.StintsListView
	
	if (((A_GuiEvent = "Normal") || (A_GuiEvent = "RightClick")) && (A_EventInfo > 0)) {
		LV_GetText(stint, A_EventInfo, 1)
		
		workbench.showStintDetails(workbench.Stints[stint])
	}
}

chooseLap() {
	workbench := SessionWorkbench.Instance
	
	Gui ListView, % workbench.LapsListView
	
	if (((A_GuiEvent = "Normal") || (A_GuiEvent = "RightClick")) && (A_EventInfo > 0)) {
		LV_GetText(lap, A_EventInfo, 1)
		
		workbench.showLapDetails(workbench.Laps[lap])
	}
}

chooseReport() {
	workbench := SessionWorkbench.Instance
	
	Gui ListView, % reportsListView
	
	if workbench.ActiveSession {
		if (((A_GuiEvent = "Normal") || (A_GuiEvent = "RightClick")) && (A_EventInfo > 0))
			workbench.showReport(kSessionReports[A_EventInfo])
	}
	else
		Loop % LV_GetCount()
			LV_Modify(A_Index, "-Select")
}

chooseAxis() {
	workbench := SessionWorkbench.Instance
	
	workbench.showTelemetryReport()
}

reportSettings() {
	workbench := SessionWorkbench.Instance
	
	workbench.reportSettings(workbench.SelectedReport)
}

startupSessionWorkbench() {
	icon := kIconsDirectory . "Console.ico"
	
	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Session Workbench

	current := fixIE(11)
	
	try {
		workbench := new SessionWorkbench(kSimulatorConfiguration, readConfiguration(kUserConfigDirectory . "Race.settings"))
		
		workbench.createGui(workbench.Configuration)
		
		workbench.connect(true)
		
		workbench.show()
		
		ExitApp 0
	}
	finally {
		fixIE(current)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

startupSessionWorkbench()