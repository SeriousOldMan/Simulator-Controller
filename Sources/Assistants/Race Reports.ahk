;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Reports Tool               ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Chart.ico
;@Ahk2Exe-ExeName Race Reports.exe

				
;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk

				
;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include Libraries\RaceReportViewer.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kReports = ["Overview", "Car", "Driver", "Position", "Pace"]

global kOk = "Ok"
global kCancel = "Cancel"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global simulatorDropDown
global carDropDown
global trackDropDown
global reportsDropDown
global reportSettingsButton
global chartViewer
global infoViewer

global deleteRaceReportButtonHandle

class RaceReports extends ConfigurationItem {
	iDatabase := false
	
	iSelectedSimulator := false
	iSelectedCar := false
	iSelectedTrack := false
	
	iAvailableRaces := []
	
	iRacesListView := false
	iSelectedRace := false
	iSelectedReport := false
	
	iReportViewer := false
	
	Window[] {
		Get {
			return "Reports"
		}
	}
	
	RacesListView[] {
		Get {
			return this.iRacesListView
		}
	}
	
	Database[] {
		Get {
			return this.iDatabase
		}
	}
	
	SelectedSimulator[] {
		Get {
			return this.iSelectedSimulator
		}
	}
	
	SelectedCar[] {
		Get {
			return this.iSelectedCar
		}
	}
	
	SelectedTrack[] {
		Get {
			return this.iSelectedTrack
		}
	}
	
	AvailableRaces[index := false] {
		Get {
			if index
				return this.iAvailableRaces[index]
			else
				return this.iAvailableRaces
		}
	}
	
	SelectedRace[] {
		Get {
			return this.iSelectedRace
		}
	}
	
	SelectedReport[] {
		Get {
			return this.iSelectedReport
		}
	}
	
	ReportViewer[] {
		Get {
			return this.iReportViewer
		}
	}
	
	Settings[] {
		Get {
			return this.ReportViewer.Settings
		}
	}
	
	__New(database, configuration) {
		this.iDatabase := database
		
		base.__New(configuration)
		
		RaceReports.Instance := this
	}
	
	createGui(configuration) {
		local stepWizard
		
		window := this.Window
		
		Gui %window%:Default
	
		Gui %window%:-Border ; -Caption
		Gui %window%:Color, D0D0D0, D8D8D8

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Text, w1184 Center gmoveReports, % translate("Modular Simulator Controller System") 
		
		Gui %window%:Font, s9 Norm, Arial
		Gui %window%:Font, Italic Underline, Arial

		Gui %window%:Add, Text, YP+20 w1184 cBlue Center gopenReportsDocumentation, % translate("Race Reports")
		
		Gui %window%:Add, Text, x8 yp+30 w1200 0x10

		Gui %window%:Font, s8 Norm, Arial
		
		Gui %window%:Add, Text, x16 yp+10 w70 h23 +0x200 Section, % translate("Simulator")
		
		simulators := this.getSimulators()
		
		simulator := ((simulators.Length() > 0) ? 1 : 0)
	
		Gui %window%:Add, DropDownList, x90 yp w180 Choose%simulator% vsimulatorDropDown gchooseSimulator, % values2String("|", simulators*)
		
		if (simulator > 0)
			simulator := simulators[simulator]
		else
			simulator := false
		
		Gui %window%:Add, Text, x16 yp+24 w70 h23 +0x200, % translate("Car")
		Gui %window%:Add, DropDownList, x90 yp w180 vcarDropDown gchooseCar
		
		Gui %window%:Add, Text, x16 yp24 w70 h23 +0x200, % translate("Track")
		Gui %window%:Add, DropDownList, x90 yp w180 vtrackDropDown gchooseTrack
		
		Gui %window%:Add, Text, x16 yp+26 w70 h23 +0x200, % translate("Races")
		
		Gui %window%:Add, ListView, x90 yp-2 w180 h252 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDraceListView gchooseRace, % values2String("|", map(["Date", "Time", "Duration", "Starting Grid"], "translate")*)
		
		this.iRacesListView := raceListView
		
		Gui %window%:Add, Button, x62 yp+229 w23 h23 HwnddeleteRaceReportButtonHandle gdeleteRaceReport
		setButtonIcon(deleteRaceReportButtonHandle, kIconsDirectory . "Minus.ico", 1)
		
		Gui %window%:Add, Text, x16 yp+30 w70 h23 +0x200, % translate("Info")
		Gui %window%:Add, ActiveX, x90 yp-2 w180 h170 Border vinfoViewer, shell.explorer
		
		infoViewer.Navigate("about:blank")
		
		Gui %window%:Add, Text, x290 ys w40 h23 +0x200, % translate("Report")
		Gui %window%:Add, DropDownList, x334 yp w120 AltSubmit Disabled Choose0 vreportsDropDown gchooseReport, % values2String("|", map(kReports, "translate")*)
		
		Gui %window%:Add, Button, x1177 yp w23 h23 HwndreportSettingsButtonHandle vreportSettingsButton greportSettings
		setButtonIcon(reportSettingsButtonHandle, kIconsDirectory . "Report Settings.ico", 1)
		
		Gui %window%:Add, ActiveX, x290 yp+24 w910 h475 Border vchartViewer, shell.explorer
		
		chartViewer.Navigate("about:blank")
		
		this.iReportViewer := new RaceReportViewer(window, chartViewer, infoViewer)
		
		this.loadSimulator(simulator, true)
		
		Gui %window%:Add, Text, x8 y574 w1200 0x10
		
		Gui %window%:Add, Button, x574 y580 w80 h23 GcloseReports, % translate("Close")
	}
	
	show() {
		window := this.Window
			
		Gui %window%:Show
	}
	
	showOverviewReport(reportDirectory) {
		if reportDirectory {
			GuiControl Choose, reportsDropDown, % inList(kReports, "Overview")
		
			this.iSelectedReport := "Overview"
		}
		else {
			GuiControl Choose, reportsDropDown, 0
		
			this.iSelectedReport := false
		}
		
		this.ReportViewer.setReport(reportDirectory)
		this.ReportViewer.showOverviewReport()
	}
	
	showCarReport(reportDirectory) {
		if reportDirectory {
			GuiControl Choose, reportsDropDown, % inList(kReports, "Car")
		
			this.iSelectedReport := "Car"
		}
		else {
			GuiControl Choose, reportsDropDown, 0
		
			this.iSelectedReport := false
		}
		
		this.ReportViewer.setReport(reportDirectory)
		this.ReportViewer.showCarReport()
	}
	
	showDriverReport(reportDirectory) {
		if reportDirectory {
			GuiControl Enable, reportSettingsButton
			GuiControl Choose, reportsDropDown, % inList(kReports, "Driver")
		
			this.iSelectedReport := "Driver"
		}
		else {
			GuiControl Choose, reportsDropDown, 0
		
			this.iSelectedReport := false
		}
		
		this.ReportViewer.setReport(reportDirectory)
		this.ReportViewer.showDriverReport()
	}
	
	editDriverReportSettings(reportDirectory) {
		this.ReportViewer.setReport(reportDirectory)
		
		return this.ReportViewer.editReportSettings("Laps", "Drivers")
	}
	
	showPositionReport(reportDirectory) {
		if reportDirectory {
			GuiControl Enable, reportSettingsButton
			GuiControl Choose, reportsDropDown, % inList(kReports, "Position")
		
			this.iSelectedReport := "Position"
		}
		else {
			GuiControl Choose, reportsDropDown, 0
		
			this.iSelectedReport := false
		}
		
		this.ReportViewer.setReport(reportDirectory)
		this.ReportViewer.showPositionReport()
	}
	
	editPositionReportSettings(reportDirectory) {
		this.ReportViewer.setReport(reportDirectory)
		
		return this.ReportViewer.editReportSettings("Laps")
	}
	
	showPaceReport(reportDirectory) {
		if reportDirectory {
			GuiControl Enable, reportSettingsButton
			GuiControl Choose, reportsDropDown, % inList(kReports, "Pace")
		
			this.iSelectedReport := "Pace"
		}
		else {
			GuiControl Choose, reportsDropDown, 0
		
			this.iSelectedReport := false
		}
		
		this.ReportViewer.setReport(reportDirectory)
		this.ReportViewer.showPaceReport()
	}
	
	editPaceReportSettings(reportDirectory) {
		this.ReportViewer.setReport(reportDirectory)
		
		return this.ReportViewer.editReportSettings("Laps", "Drivers")
	}

	getSimulators() {
		simulators := []
		
		for simulator, ignore in getConfigurationSectionValues(getControllerConfiguration(), "Simulators", Object()) {
			hasReports := false
			
			Loop Files, % this.Database . "\" . this.getSimulatorCode(simulator) . "\*.*", D
			{
				hasReports := true
				
				break
			}
			
			if hasReports
				simulators.Push(simulator)
		}
				
		return simulators
	}

	getSimulatorName(simulatorCode) {
		if (simulatorCode = "Unknown")
			return "Unknown"
		else {
			for name, description in getConfigurationSectionValues(getControllerConfiguration(), "Simulators", Object())
				if ((simulatorCode = name) || (simulatorCode = string2Values("|", description)[1]))
					return name
				
			return false
		}
	}

	getSimulatorCode(simulatorName) {
		if (simulatorName = "Unknown")
			return "Unknown"
		else {
			code := getConfigurationValue(getControllerConfiguration(), "Simulators", simulatorName, false)
		
			if code
				return string2Values("|", code)[1]
			else {
				for name, description in getConfigurationSectionValues(getControllerConfiguration(), "Simulators", Object())
					if (simulatorName = string2Values("|", description)[1])
						return simulatorName
				
				return false
			}
		}
	}

	getCars(simulator) {
		cars := {}
		
		Loop Files, % this.Database . "\" . this.getSimulatorCode(simulator) . "\*.*", D
		{
			raceData := readConfiguration(A_LoopFilePath . "\Race.data")
			car := getConfigurationValue(raceData, "Session", "Car")
			
			cars[car] := car
		}
		
		result := []
		
		for car, ignore in cars
			result.Push(car)
		
		return result
	}

	getTracks(simulator, car) {
		tracks := {}
		
		Loop Files, % this.Database . "\" . this.getSimulatorCode(simulator) . "\*.*", D
		{
			raceData := readConfiguration(A_LoopFilePath . "\Race.data")
			
			if (getConfigurationValue(raceData, "Session", "Car") = car) {
				track := getConfigurationValue(raceData, "Session", "Track")
				
				tracks[track] := track
			}
		}
		
		result := []
		
		for track, ignore in tracks
			result.Push(track)
		
		return result
	}
	
	loadSimulator(simulator, force := false) {
		if (force || (simulator != this.SelectedSimulator)) {
			window := this.Window
		
			Gui %window%:Default
			
			this.iSelectedSimulator := simulator
			
			cars := this.getCars(simulator)
			
			GuiControl Choose, simulatorDropDown, % inList(this.getSimulators(), simulator)
			GuiControl, , carDropDown, % "|" . values2String("|", cars*)
			
			this.loadCar((cars.Length() > 0) ? cars[1] : false, true)
		}
	}
				
	loadCar(car, force := false) {
		if (force || (car != this.SelectedCar)) {
			window := this.Window
		
			Gui %window%:Default
			
			this.iSelectedCar := car
			
			tracks := this.getTracks(this.SelectedSimulator, car)
			
			GuiControl Choose, carDropDown, % inList(this.getCars(this.SelectedSimulator), car)
			GuiControl, , trackDropDown, % "|" . values2String("|", tracks*)
			
			this.loadTrack((tracks.Length() > 0) ? tracks[1] : false, true)
		}
	}
	
	loadTrack(track, force := false) {
		if (force || (track != this.SelectedTrack)) {
			window := this.Window
		
			Gui %window%:Default
			
			simulator := this.SelectedSimulator
			
			this.iSelectedTrack := track
			this.iAvailableRaces := []
			this.iSelectedRace := false
			this.iSelectedReport := false
				
			GuiControl Choose, trackDropDown, % inList(this.getTracks(simulator, this.SelectedCar), track)
			GuiControl Disable, reportsDropDown
			GuiControl Disable, reportSettingsButton
			GuiControl Choose, reportsDropDown, 0
			GuiControl Disable, %deleteRaceReportButtonHandle%
			
			this.ReportViewer.showReportChart(false)
			this.ReportViewer.showReportInfo(false)

			Gui ListView, % this.RacesListView
				
			LV_Delete()
				
			if track {
				Loop Files, % this.Database . "\" . this.getSimulatorCode(simulator) . "\*.*", D
				{
					FormatTime date, %A_LoopFileName%, ShortDate
					FormatTime time, %A_LoopFileName%, HH:mm
					
					raceData := readConfiguration(A_LoopFilePath . "\Race.data")
					
					if ((getConfigurationValue(raceData, "Session", "Car") = this.SelectedCar) && (getConfigurationValue(raceData, "Session", "Track") = track)) {
						this.AvailableRaces.Push(A_LoopFileName)
						
						LV_Add("", date, time, Round(getConfigurationValue(raceData, "Session", "Duration") / 60), getConfigurationValue(raceData, "Cars", "Count"))
					}
				}

				LV_ModifyCol(1, "AutoHdr")
				LV_ModifyCol(2, "AutoHdr")
				LV_ModifyCol(3, "AutoHdr")
				LV_ModifyCol(4, "AutoHdr")
			}
		}
	}
	
	loadRace(raceNr) {
		if (raceNr != this.SelectedRace) {
			this.iSettings := {}
			
			if raceNr {
				GuiControl Enable, reportsDropDown
				GuiControl Choose, reportsDropDown, % inList(kReports, "Overview")
				GuiControl Enable, %deleteRaceReportButtonHandle%
				
				this.iSelectedRace := raceNr
				this.iSelectedReport := false
				
				this.loadReport("Overview")
			}
			else {
				GuiControl Disable, reportsDropDown
				GuiControl Disable, reportSettingsButton
				GuiControl Choose, reportsDropDown, 0
				GuiControl Disable, %deleteRaceReportButtonHandle%
				
				this.iSelectedRace := false
				
				this.ReportViewer.showReportChart(false)
				this.ReportViewer.showReportInfo(false)
			}
		}
	}
	
	deleteRace() {
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
		title := translate("Delete")
		MsgBox 262436, %title%, % translate("Do you really want to delete the selected report?")
		OnMessage(0x44, "")
		
		IfMsgBox Yes
		{
			raceDirectory := (this.Database . "\" . this.getSimulatorCode(this.SelectedSimulator) . "\" . this.AvailableRaces[this.SelectedRace])
			
			FileRemoveDir %raceDirectory%, true
		
			this.loadTrack(this.SelectedTrack, true)
		}
	}
	
	loadReport(report) {
		if (report != this.SelectedReport) {
			if report {
				GuiControlGet simulatorDropDown
				
				this.iSelectedReport := report
								
				GuiControl Choose, reportsDropDown, % inList(kReports, report)
				GuiControl Disable, reportSettingsButton
				
				reportDirectory := (this.Database . "\" . this.getSimulatorCode(this.SelectedSimulator) . "\" . this.AvailableRaces[this.SelectedRace])
				
				switch report {
					case "Overview":
						this.showOverviewReport(reportDirectory)
					case "Car":
						this.showCarReport(reportDirectory)
					case "Driver":
						if !this.Settings.HasKey("Drivers")
							this.Settings["Drivers"] := [1, 2, 3, 4, 5]
						
						this.showDriverReport(reportDirectory)
					case "Position":
						this.showPositionReport(reportDirectory)
					case "Pace":
						this.showPaceReport(reportDirectory)
				}
			}
			else {
				GuiControl Choose, reportsDropDown, 0
				
				this.iSelectedReport := false
			
				this.ReportViewer.showReportChart(false)
				this.ReportViewer.showReportInfo(false)
			}
		}
	}
	
	reportSettings(report) {
		reportDirectory := (this.Database . "\" . this.getSimulatorCode(this.SelectedSimulator) . "\" . this.AvailableRaces[this.SelectedRace])
		
		switch report {
			case "Driver":
				if this.editDriverReportSettings(reportDirectory)
					this.showDriverReport(reportDirectory)
			case "Position":
				if this.editPositionReportSettings(reportDirectory)
					this.showPositionReport(reportDirectory)
			case "Pace":
				if this.editPaceReportSettings(reportDirectory)
					this.showPaceReport(reportDirectory)
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

closeReports() {
	ExitApp 0
}

moveReports() {
	moveByMouse(RaceReports.Instance.Window)
}

openReportsDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#race-reports
}

chooseSimulator() {
	reports := RaceReports.Instance
	
	GuiControlGet simulatorDropDown
	
	reports.loadSimulator(simulatorDropDown)
}

chooseCar() {
	reports := RaceReports.Instance
	
	GuiControlGet carDropDown
	
	reports.loadCar(carDropDown)
}

chooseTrack() {
	reports := RaceReports.Instance
	
	GuiControlGet trackDropDown
	
	reports.loadTrack(trackDropDown)
}

chooseRace() {
	if (A_GuiEvent = "Normal")
		RaceReports.Instance.loadRace(A_EventInfo)
}

chooseReport() {
	reports := RaceReports.Instance
	
	GuiControlGet reportsDropDown
	
	RaceReports.Instance.loadReport(kReports[reportsDropDown])
}

reportSettings() {
	GuiControlGet reportsDropDown
	
	RaceReports.Instance.reportSettings(kReports[reportsDropDown])
}

deleteRaceReport() {
	RaceReports.Instance.deleteRace()
}

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

runRaceReports() {
	icon := kIconsDirectory . "Chart.ico"
	
	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Race Reports
	
	reportsDirectory := getConfigurationValue(kSimulatorConfiguration, "Race Strategist Reports", "Database", false)
	
	if !reportsDirectory {
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
		title := translate("Configuration")
		MsgBox 262436, %title%, % translate("The Reports folder has not been configured yet. Do you want to start the Configuration tool now?")
		OnMessage(0x44, "")
		
		IfMsgBox Yes
			Run %kBinariesDirectory%Simulator Configuration.exe
		
		ExitApp 0
	}
	
	current := fixIE(11)
	
	try {
		reports := new RaceReports(reportsDirectory, kSimulatorConfiguration)
		
		reports.createGui(reports.Configuration)
		reports.show()
		
		simulators := reports.getSimulators()
		
		if (simulators.Length() > 0)
			reports.loadSimulator(simulators[1])
	}
	finally {
		fixIE(current)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                           Initialization Section                        ;;;
;;;-------------------------------------------------------------------------;;;

runRaceReports()