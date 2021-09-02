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

global kReports = ["Overview", "Position", "Pace"]


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; RaceReports                                                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global simulatorDropDown
global reportsDropDown
global chartViewer
global infoViewer

global deleteRaceReportButtonHandle

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
		
		Gui %window%:Add, Text, x16 yp+10 w70 h23 +0x200 Section, % translate("Simulator")
		
		simulators := this.SetupDatabase.getSimulators()
		
		chosen := ((simulators.Length() > 0) ? 1 : 0)
	
		Gui %window%:Add, DropDownList, x90 yp w180 Choose%chosen% vsimulatorDropDown gchooseSimulator, % values2String("|", simulators*)
		
		Gui %window%:Add, Text, x16 yp+24 w70 h23 +0x200, % translate("Races")
		
		Gui Add, ListView, x90 yp w180 h300 -Multi -LV0x10 AltSubmit NoSort NoSortHdr gchooseRace, % values2String("|", map(["Date", "Time", "Track", "Car"], "translate")*)
		
		Gui %window%:Add, Button, x62 yp+277 w23 h23 HwnddeleteRaceReportButtonHandle gdeleteRaceReport
		setButtonIcon(deleteRaceReportButtonHandle, kIconsDirectory . "Minus.ico", 1)
		
		Gui %window%:Add, Text, x16 yp+30 w70 h23 +0x200, % translate("Info")
		Gui %window%:Add, ActiveX, x90 yp-2 w180 h170 Border vinfoViewer, shell.explorer
		
		infoViewer.Navigate("about:blank")
		
		Gui %window%:Add, Text, x290 ys w40 h23 +0x200, % translate("Report")
		Gui %window%:Add, DropDownList, x334 yp w180 AltSubmit Disabled Choose0 vreportsDropDown gchooseReport, % values2String("|", map(kReports, "translate")*)
		
		Gui %window%:Add, ActiveX, x290 yp+24 w910 h475 Border vchartViewer, shell.explorer
		
		chartViewer.Navigate("about:blank")
		
		if (simulators.Length() > 0)
			this.loadSimulator(simulators[1])
		else {
			this.showReportChart(false)
			this.showReportInfo(false)
		}
		
		Gui %window%:Add, Text, x8 y574 w1200 0x10
		
		Gui %window%:Add, Button, x568 y580 w80 h23 GcloseReports, % translate("Close")
	}
	
	show() {
		window := this.Window
			
		Gui %window%:Show
	}
	
	showReportChart(drawChartFunction) {
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
						.headerStyle { height: 25; font-size: 12px; font-weight: 500; background-color: 'FFFFFF'; }
						.rowStyle { background-color: 'E0E0E0'; }
						.oddRowStyle { background-color: 'E8E8E8'; }
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
	
	showReportInfo(raceData) {
		window := this.Window
		
		Gui %window%:Default
		
		infoViewer.Document.open()
		
		if raceData {
			infoText := "<table>"
			infoText .= ("<tr><td>" . translate("Duration: ") . "</td><td>" . Round(getConfigurationValue(raceData, "Session", "Duration") / 60) . translate(" Minutes") . "</td></tr>")
			infoText .= ("<tr><td>" . translate("Format: ") . "</td><td>" . translate((getConfigurationValue(raceData, "Session", "Format") = "Time") ? "Duration" : "Laps") . "</td></tr>")
			infoText .= "<tr/>"
			infoText .= ("<tr><td>" . translate("# Cars: ") . "</td><td>" . getConfigurationValue(raceData, "Cars", "Count") . "</td></tr>")
			infoText .= ("<tr><td>" . translate("# Laps: ") . "</td><td>" . getConfigurationValue(raceData, "Laps", "Count") . "</td></tr>")
			infoText .= "<tr/>"
			infoText .= ("<tr><td>" . translate("My Car: ") . "</td><td>" . translate("#") . getConfigurationValue(raceData, "Cars", "Car." . getConfigurationValue(raceData, "Cars", "Driver") . ".Nr") . "</td></tr>")
			infoText .= "<tr/>"
			
			conditions := {}
			
			for descriptor, info in getConfigurationSectionValues(raceData, "Laps")
				if (ConfigurationItem.splitDescriptor(descriptor)[3] = "Weather")
					conditions[info] := info
			
			infoText .= ("<tr><td>" . translate("Conditions: ") . "</td><td>" . values2String(", ", map(conditions, "translate")*) . "</td></tr>")
			infoText .= "</table>"
			
			infoText := "<html><meta charset='utf-8'><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='3' topmargin='3' rightmargin='3' bottommargin='3'><style> table, p { font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><p>" . infoText . "</p></body></html>"
			infoText := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='3' topmargin='3' rightmargin='3' bottommargin='3'><style> table, p { font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><p>" . infoText . "</p></body></html>"
			
			infoViewer.Document.write(infoText)
		}
		else {
			html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"
		
			infoViewer.Document.write(html)
		}
		
		infoViewer.Document.close()
	}
	
	showOverviewReport(dataFile, driversFile := false, positionsFile := false, lapsFile := false, timesFile := false) {
		raceData := (dataFile ? readConfiguration(dataFile) : false)
		
		if raceData {
			GuiControl Choose, reportsDropDown, % inList(kReports, "Overview")
		
			this.iSelectedReport := "Overview"
			
			cars := []
			drivers := []
			positions := []
			laps := []
			times := []
			
			oldEncoding := A_FileEncoding
			
			FileEncoding UTF-8
			
			try {
				Loop Read, %driversFile% 
					drivers.Push(string2Values(";", A_LoopReadLine))
				
				Loop Read, %positionsFile% 
					positions.Push(string2Values(";", A_LoopReadLine))
				
				Loop Read, %lapsFile% 
					laps.Push(string2Values(";", A_LoopReadLine))
				
				Loop Read, %timesFile% 
					times.Push(string2Values(";", A_LoopReadLine))
			}
			finally {
				FileEncoding %oldEncoding%
			}
			
			carsCount := getConfigurationValue(raceData, "Cars", "Count")
			lapsCount := getConfigurationValue(raceData, "Laps", "Count")
			
			Loop % carsCount
			{
				car := A_Index
				valid := false
				
				Loop %lapsCount%
					if (positions[A_Index][car] > 0)
						valid := true
					else
						positions[A_Index][car] := "null" ; carsCount
				
				if valid
					cars.Push(Array(getConfigurationValue(raceData, "Cars", "Car." . car . ".Nr"), getConfigurationValue(raceData, "Cars", "Car." . car . ".Car")))
				else
					Loop %lapsCount%
					{
						drivers[A_Index].RemoveAt(car)
						positions[A_Index].RemoveAt(car)
						laps[A_Index].RemoveAt(car)
						times[A_Index].RemoveAt(car)
					}
			}
			
			carsCount := cars.Length()
		
			rows := []
			hasDNF := false
			
			Loop % carsCount
			{
				car := A_Index
				
				result := (positions[lapsCount][car] = "null" ? "DNF" : positions[lapsCount][car])
				bestLap := 1000000
				lapTimes := []
				
				Loop % lapsCount
				{
					lapTime := times[A_Index][car]
					
					if (lapTime > 0)
						lapTimes.Push(lapTime)
					else
						result := "DNF"
				}
				
				min := Round(minimum(lapTimes) / 1000, 1)
				avg := Round(average(lapTimes) / 1000, 1)
				
				hasDNF := (hasDNF || (result = "DNF"))
				
				rows.Push(Array(cars[A_Index][1], "'" . cars[A_Index][2] . "'", "'" . drivers[1][A_Index] . "'"
							  , "{v: " . min . ", f: '" . format("{:.1f}", min) . "'}", "{v: " . avg . ", f: '" . format("{:.1f}", avg) . "'}", result))
			}
			
			Loop % carsCount
			{
				row := rows[A_Index]
				
				if hasDNF
					row[6] := ("'" . row[6] . "'")
				
				rows[A_Index] := ("[" . values2String(", ", row*) . "]")
			}
			
			drawChartFunction := ""
			
			drawChartFunction .= "function drawChart() {`nvar data = new google.visualization.DataTable();`n"
			drawChartFunction .= "`ndata.addColumn('number', '" . translate("#") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Car") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Driver (Start)") . "');"
			drawChartFunction .= "`ndata.addColumn('number', '" . translate("Best Lap Time") . "');"
			drawChartFunction .= "`ndata.addColumn('number', '" . translate("Avg Lap Time") . "');"
			drawChartFunction .= "`ndata.addColumn('" . (hasDNF ? "string" : "number") . "', '" . translate("Result") . "');"
			
			drawChartFunction .= ("`ndata.addRows([" . values2String(", ", rows*) . "]);")
			
			drawChartFunction .= "`nvar cssClassNames = { headerCell: 'headerStyle', tableRow: 'rowStyle', oddTableRow: 'oddRowStyle' };"
			drawChartFunction := drawChartFunction . "`nvar options = { cssClassNames: cssClassNames, width: '100%', height: '100%' };"
			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.Table(document.getElementById('chart_id')); chart.draw(data, options); }"
			
			this.showReportChart(drawChartFunction)
			this.showReportInfo(raceData)
		}
		else {
			GuiControl Choose, reportsDropDown, 0
		
			this.iSelectedReport := false
		
			this.showReportChart(false)
			this.showReportInfo(false)
		}
	}
	
	showPositionReport(dataFile, positionsFile := false) {
		raceData := (dataFile ? readConfiguration(dataFile) : false)
		
		if raceData {
			GuiControl Choose, reportsDropDown, % inList(kReports, "Position")
		
			this.iSelectedReport := "Position"
			
			cars := []
			positions := []
			
			oldEncoding := A_FileEncoding
			
			FileEncoding UTF-8
			
			try {
				Loop Read, %positionsFile% 
					positions.Push(string2Values(";", A_LoopReadLine))
			}
			finally {
				FileEncoding %oldEncoding%
			}
			
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
						positions[A_Index][car] := "null" ; carsCount
				
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
			
			drawChartFunction := drawChartFunction . ("]);`nvar options = { legend: { position: 'right' },  chartArea: { left: '5%', top: '2%', right: '20%', bottom: '10%' }, ")
			drawChartFunction := drawChartFunction . ("hAxis: { title: '" . translate("Laps") . "' }, vAxis: { direction: -1, ticks: [], title: '" . translate("Cars") . "', baselineColor: 'D0D0D0' }, backgroundColor: 'D0D0D0' };`n")

			drawChartFunction := drawChartFunction . "var chart = new google.visualization.LineChart(document.getElementById('chart_id')); chart.draw(data, options); }"
			
			this.showReportChart(drawChartFunction)
			this.showReportInfo(raceData)
		}
		else {
			GuiControl Choose, reportsDropDown, 0
		
			this.iSelectedReport := false
		
			this.showReportChart(false)
			this.showReportInfo(false)
		}
	}
	
	showPaceReport(dataFile, timesFile := false) {
		raceData := (dataFile ? readConfiguration(dataFile) : false)
		
		if raceData {
			GuiControl Choose, reportsDropDown, % inList(kReports, "Pace")
		
			this.iSelectedReport := "Pace"
			
			cars := []
			times := []
			
			oldEncoding := A_FileEncoding
			
			FileEncoding UTF-8
			
			try {
				Loop Read, %timesFile%
					times.Push(string2Values(";", A_LoopReadLine))
			}
			finally {
				FileEncoding %oldEncoding%
			}
			
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
						
						drawChartFunction := drawChartFunction . ("[" . values2String(", ", cars[car], min, Round(avg - Sqrt(stdDev / 2), 1), Round(avg + Sqrt(stdDev / 2), 1), max) . "]")
					}
				}
			}
			
			drawChartFunction := drawChartFunction . ("], true);`nvar options = { legend: 'none', chartArea: { left: '10%', top: '2%', right: '5%', bottom: '20%' }, ")
			drawChartFunction := drawChartFunction . ("hAxis: { title: '" . translate("Cars") . "' }, vAxis: { title: '" . translate("Seconds") . "' }, backgroundColor: 'D0D0D0', ")
			drawChartFunction := drawChartFunction . ("candlestick: { risingColor: { stroke: 'Black', fill: 'Silver' } } };`n")
			
			drawChartFunction := drawChartFunction . "var chart = new google.visualization.CandlestickChart(document.getElementById('chart_id')); chart.draw(data, options); }"
			
			this.showReportChart(drawChartFunction)
			this.showReportInfo(raceData)
		}
		else {
			GuiControl Choose, reportsDropDown, 0
		
			this.iSelectedReport := false
		
			this.showReportChart(false)
			this.showReportInfo(false)
		}
	}
	
	loadSimulator(simulator, force := false) {
		if (force || (simulator != this.SelectedSimulator)) {
			window := this.Window
		
			Gui %window%:Default
			
			this.iSelectedSimulator := simulator
			this.iSelectedRace := false
			this.iSelectedReport := false
				
			GuiControl Choose, simulatorDropDown, % inList(this.SetupDatabase.getSimulators(), simulator)
			GuiControl Disable, reportsDropDown
			GuiControl Choose, reportsDropDown, 0
			GuiControl Disable, %deleteRaceReportButtonHandle%
			
			if simulator {
				Gui ListView, % this.RacesListView
				
				this.showReportChart(false)
				this.showReportInfo(false)
				
				LV_Delete()
				
				Loop Files, % this.Database . "\" . this.SetupDatabase.getSimulatorCode(simulator) . "\*.*", D
				{
					FormatTime date, %A_LoopFileName%, ShortDate
					FormatTime time, %A_LoopFileName%, HH:mm
					
					raceData := readConfiguration(A_LoopFilePath . "\Race.data")
					
					LV_Add("", date, time, getConfigurationValue(raceData, "Session", "Track"), getConfigurationValue(raceData, "Session", "Car"))
				}

				LV_ModifyCol(1, "AutoHdr")
				LV_ModifyCol(2, "AutoHdr")
				LV_ModifyCol(3, "AutoHdr")
				LV_ModifyCol(4, "AutoHdr")
			}
			else {
				this.showReportChart(false)
				this.showReportInfo(false)
			}
		}
	}
	
	loadRace(raceNr) {
		if (raceNr != this.SelectedRace) {
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
				GuiControl Choose, reportsDropDown, 0
				GuiControl Disable, %deleteRaceReportButtonHandle%
				
				this.iSelectedRace := false
				
				this.showReportChart(false)
				this.showReportInfo(false)
			}
		}
	}
	
	loadReport(report) {
		if (report != this.SelectedReport) {
			if report {
				GuiControlGet simulatorDropDown
				
				this.iSelectedReport := report
				
				Loop Files, % this.Database . "\" . this.SetupDatabase.getSimulatorCode(simulatorDropDown) . "\*.*", D
					if (A_Index = this.SelectedRace) {
						GuiControl Choose, reportsDropDown, % inList(kReports, report)
						
						switch report {
							case "Overview":
								this.showOverviewReport(A_LoopFilePath . "\Race.data", A_LoopFilePath . "\Drivers.CSV", A_LoopFilePath . "\Positions.CSV", A_LoopFilePath . "\Laps.CSV", A_LoopFilePath . "\Times.CSV")
							case "Position":
								this.showPositionReport(A_LoopFilePath . "\Race.data", A_LoopFilePath . "\Positions.CSV")
							case "Pace":
								this.showPaceReport(A_LoopFilePath . "\Race.data", A_LoopFilePath . "\Times.CSV")
						}
						
						break
					}
			}
			else {
				GuiControl Choose, reportsDropDown, 0
				
				this.iSelectedReport := false
			
				this.showReportChart(false)
				this.showReportInfo(false)
			}
		}
	}
	
	deleteRace() {
		GuiControlGet simulatorDropDown
				
		Loop Files, % this.Database . "\" . this.SetupDatabase.getSimulatorCode(simulatorDropDown) . "\*.*", D
			if (A_Index = this.SelectedRace) {
				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
				title := translate("Modular Simulator Controller System")
				MsgBox 262436, %title%, % translate("Do you really want to delete the selected report?")
				OnMessage(0x44, "")
				
				IfMsgBox Yes
				{
					FileRemoveDir %A_LoopFilePath%, true
					
					this.loadSimulator(this.SelectedSimulator, true)
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