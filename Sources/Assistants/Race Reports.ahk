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
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Assistants\Libraries\SetupDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kReports = ["Position", "Pace"]


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; RaceReports                                                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global simulatorDropDown
global reportsDropDown
global chartViewer

class RaceReports extends ConfigurationItem {
	iDatabase := false
	iSetupDatabase := false
	
	iSelectedSimulator := false
	iSelectedRace := false
	iSelectedReport := false
	
	Window[] {
		Get {
			return "Reports"
		}
	}
	
	Database[] {
		Get {
			return this.iDatabase
		}
	}
	
	SetupDatabase[] {
		Get {
			if !this.iSetupDatabase
				this.iSetupDatabase := new SetupDatabase()
			
			return this.iSetupDatabase
		}
	}
	
	SelectedSimulator[] {
		Get {
			return this.iSelectedSimulator
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
		
		Gui %window%:Add, Text, x16 yp+10 w80 h23 +0x200 Section, % translate("Simulator")
		
		choices := this.SetupDatabase.getSimulators()
	
		Gui %window%:Add, DropDownList, x90 yp w180 Choose0 vsimulatorDropDown gchooseSimulator, % values2String("|", choices*)
		
		Gui %window%:Add, Text, x16 yp+24 w80 h23 +0x200, % translate("Races")
		
		Gui Add, ListView, x90 yp w180 h300 -Multi -LV0x10 AltSubmit NoSort NoSortHdr gchooseRace, % values2String("|", map(["Date", "Time", "Track", "Car"], "translate")*)
		
		Gui %window%:Add, Text, x290 ys w40 h23 +0x200, % translate("Report")
		Gui %window%:Add, DropDownList, x334 yp w180 AltSubmit Disabled Choose0 vreportsDropDown gchooseReport, % values2String("|", map(kReports, "translate")*)
		
		Gui %window%:Add, ActiveX, x290 yp+24 w910 h480 vchartViewer, shell.explorer
		
		chartViewer.Navigate("about:blank")
		
		this.showReport(false)
		
		Gui %window%:Add, Text, x8 y574 w1200 0x10
		
		Gui %window%:Add, Button, x568 y580 w80 h23 GcloseReports, % translate("Close")
	}
	
	show() {
		window := this.Window
			
		Gui %window%:Show
	}
	
	showReport(drawChartFunction) {
		window := this.Window
		
		Gui %window%:Default
		
		chartViewer.Document.open()
		
		if (drawChartFunction && (drawChartFunction != "")) {
			before =
			(
			<html>
				<head>
					<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
					<script type="text/javascript">
						google.charts.load('current', {'packages':['corechart']}).then(drawChart);
			)

			after =
			(
					</script>
				</head>
				<body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>
					<div id="chart_id" style="width: 910px; height: 470px"></div>
				</body>
			</html>
			)

			chartViewer.Document.write(before . drawChartFunction . after)
		}
		else
			chartViewer.Document.write("<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>")
		
		chartViewer.Document.close()
	}
	
	showPositionReport(raceData, positionsFile := false) {
		if raceData {
			GuiControl Choose, reportsDropDown, % inList(kReports, "Position")
		
			this.iSelectedReport := "Position"
			
			cars := []
			positions := []
			
			Loop Read, %positionsFile% 
				positions.Push(string2Values(";", A_LoopReadLine))
			
			carsCount := getConfigurationValue(raceData, "Cars", "Count")
			lapsCount := getConfigurationValue(raceData, "Laps", "Count")
			
			Loop % carsCount
			{
				car := A_Index
				valid := false
				
				Loop %lapsCount%
					if (positions[A_Index][car] > 0) {
						valid := true
						
						break
					}
					else
						positions[A_Index][car] := carsCount
				
				if valid
					cars.Push("'#" . getConfigurationValue(raceData, "Cars", "Car." . car . ".Nr") . A_Space . getConfigurationValue(raceData, "Cars", "Car." . car . ".Car") . "'")
				else
					Loop %lapsCount%
						positions[A_Index].RemoveAt(car)
			}
			
			drawChartFunction := ""
			
			drawChartFunction .= ("function drawChart() {`nvar data = google.visualization.arrayToDataTable([`n[" . values2String(", ", "'" . translate("Laps") . "'", cars*) . "]")
			
			Loop % lapsCount
			{
				lap := A_Index
			
				drawChartFunction := drawChartFunction . (",`n[" . lap)
				
				Loop % cars.Length()
					drawChartFunction := drawChartFunction . (", " . positions[lap][A_Index])
				
				drawChartFunction := drawChartFunction . "]"
			}
			
			drawChartFunction := drawChartFunction . ("]);`nvar options = { legend: { position: 'right' }, chartArea: { left: '5%', top: '2%', right: '25%', bottom: '10%' }, ")
			drawChartFunction := drawChartFunction . ("hAxis: { title: '" . translate("Laps") . "' }, vAxis: { direction: -1, ticks: [], title: '" . translate("Cars") . "', baselineColor: 'D0D0D0' }, backgroundColor: 'D0D0D0' };`n")

			drawChartFunction := drawChartFunction . "var chart = new google.visualization.LineChart(document.getElementById('chart_id')); chart.draw(data, options); }"
			
			this.showReport(drawChartFunction)
		}
		else {
			GuiControl Choose, reportsDropDown, 0
		
			this.iSelectedReport := false
		
			this.showReport(false)
		}
	}
	
	showPaceReport(raceData, timesFile := false) {
		if raceData {
			GuiControl Choose, reportsDropDown, % inList(kReports, "Pace")
		
			this.iSelectedReport := "Pace"
			
			cars := []
			times := []
			
			Loop Read, %timesFile%
				times.Push(string2Values(";", A_LoopReadLine))
			
			Loop % getConfigurationValue(raceData, "Cars", "Count")
				cars.Push("'#" . getConfigurationValue(raceData, "Cars", "Car." . A_Index . ".Nr") . "'")
			
			drawChartFunction := ""
			
			drawChartFunction .= "function drawChart() {`nvar data = google.visualization.arrayToDataTable([`n"
			
			lapsCount := getConfigurationValue(raceData, "Laps", "Count")
			
			first := true
			
			Loop % getConfigurationValue(raceData, "Cars", "Count")
			{
				car := A_Index
				
				validTimes := []
				
				Loop % lapsCount
				{
					time := times[A_Index][car]
					
					if (time > 0)
						validTimes.Push(time)
				}
				
				stdDev := stdDeviation(validTimes)
				avg := average(validTimes)
				
				invalidTimes := []
				
				for ignore, time in validTimes
					if (Abs(time - avg) > (stdDev / 2))
						invalidTimes.Push(time)
				
				for ignore, time in invalidTimes
					validTimes.RemoveAt(inList(validTimes, time))
				
				if (validTimes.Length() > 1) {
					min := Round(minimum(validTimes) / 1000, 1)
					max := Round(maximum(validTimes) / 1000, 1)
					avg := (average(validTimes) / 1000)
					stdDev := (stdDeviation(validTimes) / 1000)
					
					if (stdDev > 0) {
						if first
							first := false
						else
							drawChartFunction := drawChartFunction . ",`n"
						
						drawChartFunction := drawChartFunction . ("[" . values2String(", ", cars[car], min, Round(avg - (stdDev / 2), 1), Round(avg + (stdDev / 2), 1), max) . "]")
					}
				}
			}
			
			drawChartFunction := drawChartFunction . ("], true);`nvar options = { legend: 'none', chartArea: { left: '10%', top: '2%', right: '5%', bottom: '30%' }, ")
			drawChartFunction := drawChartFunction . ("hAxis: { title: '" . translate("Cars") . "' }, vAxis: { title: '" . translate("Seconds") . "' }, backgroundColor: 'D0D0D0', ")
			drawChartFunction := drawChartFunction . ("candlestick: { risingColor: { stroke: 'Black', fill: 'Silver' } } };`n")
			
			drawChartFunction := drawChartFunction . "var chart = new google.visualization.CandlestickChart(document.getElementById('chart_id')); chart.draw(data, options); }"
			
			this.showReport(drawChartFunction)
		}
		else {
			GuiControl Choose, reportsDropDown, 0
		
			this.iSelectedReport := false
		
			this.showReport(false)
		}
	}
	
	loadSimulator(simulator) {
		if (simulator != this.SelectedSimulator) {
			window := this.Window
		
			Gui %window%:Default
			
			this.iSelectedRace := false
			this.iSelectedReport := false
			
			if simulator {
				Gui ListView, % this.RacesListView
				
				GuiControl Choose, simulatorDropDown, % inList(this.SetupDatabase.getSimulators(), simulator)
				GuiControl Disable, reportsDropDown
				GuiControl Choose, reportsDropDown, 0
				
				this.showReport(false)
				
				LV_Delete()
				
				Loop Files, % this.Database . "\" . this.SetupDatabase.getSimulatorCode(simulator) . "\*.*", D
				{
					dateTime := SubStr(A_LoopFileName, 12)
					
					FormatTime date, %dateTime%, ShortDate
					FormatTime time, %dateTime%, HH:mm
					
					raceData := readConfiguration(A_LoopFilePath . "\Race.data")
					
					LV_Add("", date, time, getConfigurationValue(raceData, "Session", "Track"), getConfigurationValue(raceData, "Session", "Car"))
				}

				LV_ModifyCol(1, "AutoHdr")
				LV_ModifyCol(2, "AutoHdr")
				LV_ModifyCol(3, "AutoHdr")
				LV_ModifyCol(4, "AutoHdr")
			}
			else {
				GuiControl Choose, simulatorDropDown, 0
				GuiControl Disable, reportsDropDown
				GuiControl Choose, reportsDropDown, 0
			
				this.showReport(false)
			}
		}
	}
	
	loadRace(raceNr) {
		if (raceNr != this.SelectedRace) {
			if raceNr {
				GuiControl Enable, reportsDropDown
				GuiControl Choose, reportsDropDown, % inList(kReports, "Position")
				
				this.iSelectedRace := raceNr
				this.iSelectedReport := false
				
				this.loadReport("Position")
			}
			else {
				GuiControl Disable, reportsDropDown
				GuiControl Choose, reportsDropDown, 0
				
				this.iSelectedRace := false
				
				this.showReport(false)
			}
		}
	}
	
	loadReport(report) {
		if (report != this.SelectedReport) {
			if report {
				GuiControlGet simulatorDropDown
				
				this.iSelectedReport := report
				
				Loop Files, % this.Database . "\" . this.SetupDatabase.getSimulatorCode(simulatorDropDown) . "\*.*", D
					if (A_index = this.SelectedRace) {
						GuiControl Choose, reportsDropDown, % inList(kReports, report)
						
						switch report {
							case "Position":
								this.showPositionReport(readConfiguration(A_LoopFilePath . "\Race.data"), A_LoopFilePath . "\Positions.CSV")
							case "Pace":
								this.showPaceReport(readConfiguration(A_LoopFilePath . "\Race.data"), A_LoopFilePath . "\Times.CSV")
						}
						
						break
					}
			}
			else {
				GuiControl Choose, reportsDropDown, 0
				
				this.iSelectedReport := false
			
				this.showReport(false)
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

chooseRace() {
	if (A_GuiEvent = "Normal")
		RaceReports.Instance.loadRace(A_EventInfo)
}

chooseReport() {
	reports := RaceReports.Instance
	
	GuiControlGet reportsDropDown
	
	RaceReports.Instance.loadReport(kReports[reportsDropDown])
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

runRaceReport() {
	icon := kIconsDirectory . "Chart.ico"
	
	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Race Reports
	
	reportsDirectory := getConfigurationValue(kSimulatorConfiguration, "Race Strategist Reports", "Database", false)
	
	if !reportsDirectory {
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
		title := translate("Modular Simulator Controller System")
		MsgBox 262436, %title%, % translate("The Reports folder has not been configured yet. Do you want to start the Configuration tool now?")
		OnMessage(0x44, "")
		
		IfMsgBox Yes
			Run %kBinariesDirectory%Simulator Configuration.exe
		
		ExitApp 0
	}
	
	current := fixIE()
	
	try {
		reports := new RaceReports(reportsDirectory, kSimulatorConfiguration)
		
		reports.createGui(reports.Configuration)
		reports.show()
		
		simulators := reports.SetupDatabase.getSimulators()
		
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

runRaceReport()