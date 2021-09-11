;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Strategy Workbench Tool         ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Dashboard.ico
;@Ahk2Exe-ExeName Strategy Workbench.exe

				
;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kOk = "Ok"
global kCancel = "Cancel"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; StrategyWorkbench                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global simulatorDropDown
global carDropDown
global trackDropDown
global chartViewer
global infoViewer

class StrategyWorkbench extends ConfigurationItem {
	iStatisticsDatabase := false
	
	iSelectedSimulator := false
	iSelectedCar := false
	iSelectedTrack := false
	
	Window[] {
		Get {
			return "Workbench"
		}
	}
	
	StatisticsDatabase[] {
		Get {
			if !this.iStatisticsDatabase
				this.iStatisticsDatabase := new StatisticsDatabase()
			
			return this.iStatisticsDatabase
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
	
	__New(simulator := false, car := false, track := false, duration := false, weather := false, airTemperature := false, trackTemperature := false
		, compound := false, map := "n/a", tc := "n/a", abs := "n/a") {
		this.iSelectedSimulator := simulator
		this.iSelectedCar := car
		this.iSelectedTrack := track
		
		this.iWeather := weather
		this.iAirTemperature := airTemperature
		this.iTrackTemperature := trackTemperature
		this.iCompound := compound
		this.iMap := map
		this.iTC := tc
		this.iABS := abs
		
		base.__New(kSimulatorConfiguration)
		
		StrategyWorkbench.Instance := this
	}
	
	createGui(configuration) {
		local stepWizard
		
		window := this.Window
		
		Gui %window%:Default
	
		Gui %window%:-Border ; -Caption
		Gui %window%:Color, D0D0D0, D8D8D8

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Text, w1184 Center gmoveWorkbench, % translate("Modular Simulator Controller System") 
		
		Gui %window%:Font, s9 Norm, Arial
		Gui %window%:Font, Italic Underline, Arial

		Gui %window%:Add, Text, YP+20 w1184 cBlue Center gopenWorkbenchDocumentation, % translate("Strategy Workbench")
		
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
		
		Gui %window%:Add, ActiveX, x290 yp+24 w910 h475 Border vchartViewer, shell.explorer
		
		chartViewer.Navigate("about:blank")
		
		this.loadSimulator(simulator, true)
		
		Gui %window%:Add, Text, x8 y574 w1200 0x10
		
		Gui %window%:Add, Button, x574 y580 w80 h23 GcloseWorkbench, % translate("Close")
	}
	
	show() {
		window := this.Window
			
		Gui %window%:Show
	}
	
	showWorkbenchChart(drawChartFunction) {
		window := this.Window
		
		Gui %window%:Default
		
		chartViewer.Document.open()
		
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
						google.charts.load('current', {'packages':['corechart', 'table']}).then(drawChart);
			)

			after =
			(
					</script>
				</head>
				<body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>
					<div id="chart_id" style="width: 908px; height: 470px"></div>
				</body>
			</html>
			)

			chartViewer.Document.write(before . drawChartFunction . after)
		}
		else {
			html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"
		
			chartViewer.Document.write(html)
		}
		
		chartViewer.Document.close()
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
			
			Gui ListView, % this.RacesListView
				
			this.showReportChart(false)
			this.showReportInfo(false)

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
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

minimum(numbers) {
	min := 0
	
	for ignore, number in numbers
		min := (!min ? number : Min(min, number))

	return min
}

maximum(numbers) {
	max := 0
	
	for ignore, number in numbers
		max := (!max ? number : Max(max, number))

	return max
}

average(numbers) {
	avg := 0
	
	for ignore, value in numbers
		avg += value
	
	return (avg / numbers.Length())
}

stdDeviation(numbers) {
	avg := average(numbers)
	
	squareSum := 0
	
	for ignore, value in numbers
		squareSum += ((value - avg) * (value - avg))
	
	return Sqrt(squareSum)
}

closeWorkbench() {
	ExitApp 0
}

moveWorkbench() {
	moveByMouse(StrategyWorkbench.Instance.Window)
}

openWorkbenchDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#strategy-workbench
}

chooseSimulator() {
	workbench := StrategyWorkbench.Instance
	
	GuiControlGet simulatorDropDown
	
	workbench.loadSimulator(simulatorDropDown)
}

chooseCar() {
	workbench := StrategyWorkbench.Instance
	
	GuiControlGet carDropDown
	
	workbench.loadCar(carDropDown)
}

chooseTrack() {
	workbench := StrategyWorkbench.Instance
	
	GuiControlGet trackDropDown
	
	workbench.loadTrack(trackDropDown)
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
	
	RegRead PreviousValue, HKCU, %key%, %exeName%

	if (version = "")
		RegDelete, HKCU, %key%, %exeName%
	else
		RegWrite, REG_DWORD, HKCU, %key%, %exeName%, %version%
	
	return previousValue
}

runStrategyWorkbench() {
	icon := kIconsDirectory . "Dashboard.ico"
	
	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Strategy Workbench
	
	simulator := false
	car := false
	track := false
	duration := false
	weather := "Dry"
	airTemperature := 23
	trackTemperature:= 27
	compound := "Dry"
	map := "n/a"
	tc := "n/a"
	abs := "n/a"
	
	index := 1
	
	while (index < A_Args.Length()) {
		switch A_Args[index] {
			case "-Simulator":
				simulator := A_Args[index + 1]
				index += 2
			case "-Car":
				car := A_Args[index + 1]
				index += 2
			case "-Track":
				track := A_Args[index + 1]
				index += 2
			case "-Duration":
				duration := A_Args[index + 1]
				index += 2
			case "-Weather":
				weather := A_Args[index + 1]
				index += 2
			case "-AirTemperature":
				airTemperature := A_Args[index + 1]
				index += 2
			case "-TrackTemperature":
				trackTemperature := A_Args[index + 1]
				index += 2
			case "-Compound":
				compound := A_Args[index + 1]
				index += 2
			case "-Map":
				map := A_Args[index + 1]
				index += 2
			case "-TC":
				tc := A_Args[index + 1]
				index += 2
			case "-ABS":
				abs := A_Args[index + 1]
				index += 2
			default:
				index += 1
		}
	}
	
	if ((airTemperature <= 0) || (trackTemperature <= 0)) {
		airTemperature := false
		trackTemperature := false
	}
	
	current := fixIE(11)
	
	try {
		workbench := new StrategyWorkbench(simulator, car, track, duration, weather, airTemperature, trackTemperature, compound, map, tc, abs)
		
		workbench.createGui(workbench.Configuration)
		workbench.show()
		
		simulators := workbench.getSimulators()
		
		if (simulators.Length() > 0)
			workbench.loadSimulator(simulators[1])
	}
	finally {
		fixIE(current)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                           Initialization Section                        ;;;
;;;-------------------------------------------------------------------------;;;

runStrategyWorkbench()