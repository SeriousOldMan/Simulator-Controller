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

global kReports = ["Overview", "Car", "Driver", "Position", "Pace"]

global kOk = "Ok"
global kCancel = "Cancel"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; RaceReports                                                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global simulatorDropDown
global reportsDropDown
global reportSettingsButton
global chartViewer
global infoViewer

global deleteRaceReportButtonHandle

class RaceReports extends ConfigurationItem {
	iDatabase := false
	iSetupDatabase := false
	
	iSelectedSimulator := false
	iSelectedRace := false
	iSelectedReport := false
	
	iSettings := {}
	
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
	
	Settings[key := false] {
		Get {
			if key
				return this.iSettings[key]
			else
				return this.iSettings
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
		
		Gui %window%:Add, ListView, x90 yp w180 h300 -Multi -LV0x10 AltSubmit NoSort NoSortHdr gchooseRace, % values2String("|", map(["Date", "Time", "Track", "Car"], "translate")*)
		
		Gui %window%:Add, Button, x62 yp+277 w23 h23 HwnddeleteRaceReportButtonHandle gdeleteRaceReport
		setButtonIcon(deleteRaceReportButtonHandle, kIconsDirectory . "Minus.ico", 1)
		
		Gui %window%:Add, Text, x16 yp+30 w70 h23 +0x200, % translate("Info")
		Gui %window%:Add, ActiveX, x90 yp-2 w180 h170 Border vinfoViewer, shell.explorer
		
		infoViewer.Navigate("about:blank")
		
		Gui %window%:Add, Text, x290 ys w40 h23 +0x200, % translate("Report")
		Gui %window%:Add, DropDownList, x334 yp w180 AltSubmit Disabled Choose0 vreportsDropDown gchooseReport, % values2String("|", map(kReports, "translate")*)
		
		Gui %window%:Add, Button, x1177 yp w23 h23 HwndreportSettingsButtonHandle vreportSettingsButton greportSettings
		setButtonIcon(reportSettingsButtonHandle, kIconsDirectory . "Report Settings.ico", 1)
		
		Gui %window%:Add, ActiveX, x290 yp+24 w910 h475 Border vchartViewer, shell.explorer
		
		chartViewer.Navigate("about:blank")
		
		if (simulators.Length() > 0)
			this.loadSimulator(simulators[1])
		else {
			this.showReportChart(false)
			this.showReportInfo(false)
		}
		
		Gui %window%:Add, Text, x8 y574 w1200 0x10
		
		Gui %window%:Add, Button, x574 y580 w80 h23 GcloseReports, % translate("Close")
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
	
	getReportLaps(raceData) {
		if this.Settings.HasKey("Laps")
			return this.Settings["Laps"]
		else {
			laps := []
		
			Loop % getConfigurationValue(raceData, "Laps", "Count")
				laps.Push(A_Index)
			
			return laps
		}
	}
	
	getReportDrivers(raceData) {
		if this.Settings.HasKey("Drivers")
			return this.Settings["Drivers"]
		else {
			cars := []
		
			Loop % getConfigurationValue(raceData, "Cars", "Count")
				cars.Push(A_Index)
			
			return cars
		}
	}
	
	getDriverPositions(raceData, positions, car) {
		result := []
		
		for ignore, lap in this.getReportLaps(raceData)
			result.Push(positions[lap][car])
		
		return result
	}
	
	getDriverTimes(raceData, times, car) {
		min := false
		max := false
		avg := false
		stdDev := false
		
		result := []
		
		if this.getDriverPace(raceData, times, car, min, max, avg, stdDev)
			for ignore, lap in this.getReportLaps(raceData) {
				time := Round(times[lap][car] / 1000, 1)
				
				if (time > 0) {
					if ((time > avg) && (Abs(time - avg) > (stdDev / 2)))
						result.Push(avg)
					else
						result.Push(time)
				}
				else
					result.Push(avg)
			}
		
		return result
	}
	
	getDriverPace(raceData, times, car, ByRef min, ByRef max, ByRef avg, ByRef stdDev) {
		validTimes := []
		
		for ignore, lap in this.getReportLaps(raceData) {
			time := times[lap][car]
			
			if (time > 0)
				validTimes.Push(time)
		}
		
		min := Round(minimum(validTimes) / 1000, 1)
		
		stdDev := stdDeviation(validTimes)
		avg := average(validTimes)
		
		invalidTimes := []
		
		for ignore, time in validTimes
			if ((time > avg) && (Abs(time - avg) > (stdDev / 2)))
				invalidTimes.Push(time)
		
		for ignore, time in invalidTimes
			validTimes.RemoveAt(inList(validTimes, time))
		
		if (validTimes.Length() > 1) {
			max := Round(maximum(validTimes) / 1000, 1)
			avg := Round(average(validTimes) / 1000, 1)
			stdDev := (stdDeviation(validTimes) / 1000)
			
			return true
		}
		else
			return false
	}
	
	getDriverPotential(raceData, positions, car) {
		cars := getConfigurationValue(raceData, "Cars", "Count")
		positions := this.getDriverPositions(raceData, positions, car)
		
		return Max(0, cars - positions[1]) + Max(0, cars - positions[positions.Length()])
	}
	
	getDriverRaceCraft(raceData, positions, car) {
		cars := getConfigurationValue(raceData, "Cars", "Count")
		result := 0
		
		positions := this.getDriverPositions(raceData, positions, car)
		
		lastPosition := false
		
		Loop % positions.Length()
		{
			position := positions[A_Index]
		
			result += (Max(0, 11 - position) / 10)
			
			if lastPosition
				result += (lastPosition - position)
			
			lastPosition := position
			
			result := Max(0, result)
		}
		
		return result
	}
	
	getDriverSpeed(raceData, times, car) {
		min := false
		max := false
		avg := false
		stdDev := false
		
		if this.getDriverPace(raceData, times, car, min, max, avg, stdDev)
			return min
		else
			return false
	}
	
	getDriverConsistency(raceData, times, car) {
		min := false
		max := false
		avg := false
		stdDev := false
		
		if this.getDriverPace(raceData, times, car, min, max, avg, stdDev)
			return ((stdDev == 0) ? 0.1 : (1 / stdDev))
		else
			return false
	}
	
	getDriverCarControl(raceData, times, car) {
		min := false
		max := false
		avg := false
		stdDev := false
		
		if this.getDriverPace(raceData, times, car, min, max, avg, stdDev) {
			carControl := 1
			threshold := (avg + ((max - avg) / 4))
			
			for ignore, lap in this.getReportLaps(raceData) {
				time := Round(times[lap][car] / 1000, 1)
			
				if (time > 0)
					if (time > threshold)
						carControl *= 0.90
			}
			
			return carControl
		}
		else
			return false
	}
	
	normalizeValues(values, target) {
		factor := (target / maximum(values))
		
		for index, value in values
			values[index] *= factor
		
		return values
	}
	
	normalizeSpeedValues(values, target) {
		for index, value in values
			values[index] := - value
		
		halfTarget := (target / 2)
		min := minimum(values)
		
		for index, value in values
			values[index] := halfTarget + (value - min)
		
		factor := (target / maximum(values))
		
		for index, value in values
			values[index] *= factor
		
		return values
	}
	
	getDrivers(raceData, drivers) {
		result := []
		
		Loop % getConfigurationValue(raceData, "Cars", "Count")
			result.Push(drivers[1][A_Index])
		
		return result
	}
	
	getDriverStats(raceData, cars, positions, times, ByRef potentials, ByRef raceCrafts, ByRef speeds, ByRef consistencies, ByRef carControls) {
		consistencies := this.normalizeValues(map(cars, ObjBindMethod(this, "getDriverConsistency", raceData, times)), 5)
		carControls := this.normalizeValues(map(cars, ObjBindMethod(this, "getDriverCarControl", raceData, times)), 5)
		speeds := this.normalizeSpeedValues(map(cars, ObjBindMethod(this, "getDriverSpeed", raceData, times)), 5)
		raceCrafts := this.normalizeValues(map(cars, ObjBindMethod(this, "getDriverRaceCraft", raceData, positions)), 5)
		potentials := this.normalizeValues(map(cars, ObjBindMethod(this, "getDriverPotential", raceData, positions)), 5)
		
		return true
	}
	
	editReportSettings(reportDirectory, settings*) {
		result := editReportSettings(this, reportDirectory, settings)
		
		if result
			for setting, values in result
				if ((setting = "Laps") && (values == true))
					this.Settings.Delete("Laps")
				else
					this.Settings[setting] := values
		
		return (result != false)
	}
	
	showOverviewReport(reportDirectory) {
		if reportDirectory {
			raceData := readConfiguration(reportDirectory . "\Race.data")
			
			GuiControl Choose, reportsDropDown, % inList(kReports, "Overview")
		
			this.iSelectedReport := "Overview"
			
			cars := []
			drivers := []
			positions := []
			times := []
			
			oldEncoding := A_FileEncoding
			
			FileEncoding UTF-8
			
			try {
				Loop Read, % reportDirectory . "\Drivers.CSV"
					drivers.Push(string2Values(";", A_LoopReadLine))
				
				Loop Read, % reportDirectory . "\Positions.CSV"
					positions.Push(string2Values(";", A_LoopReadLine))
				
				Loop Read, % reportDirectory . "\Times.CSV"
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
				
				for ignore, lap in this.getReportLaps(raceData)
					if (positions[lap][car] > 0)
						valid := true
					else
						positions[lap][car] := "null" ; carsCount
				
				if valid
					cars.Push(Array(getConfigurationValue(raceData, "Cars", "Car." . car . ".Nr"), getConfigurationValue(raceData, "Cars", "Car." . car . ".Car")))
				else
					for ignore, lap in this.getReportLaps(raceData) {
						drivers[lap].RemoveAt(car)
						positions[lap].RemoveAt(car)
						times[lap].RemoveAt(car)
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
			drawChartFunction := drawChartFunction . "`nvar options = { cssClassNames: cssClassNames, width: '100%' };"
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
	
	showCarReport(reportDirectory) {
		if reportDirectory {
			raceData := readConfiguration(reportDirectory . "\Race.data")
			
			GuiControl Choose, reportsDropDown, % inList(kReports, "Car")
		
			this.iSelectedReport := "Car"
			
			cars := []
			rows := []
			
			for ignore, lap in this.getReportLaps(raceData) {
				weather := (translate(getConfigurationValue(raceData, "Laps", "Lap." . lap . ".Compound", "Dry")) . translate(" (") . translate(getConfigurationValue(raceData, "Laps", "Lap." . lap . ".CompoundColor", "Black")) . translate(")"))
				consumption := getConfigurationValue(raceData, "Laps", "Lap." . lap . ".Consumption", translate("n/a"))
				
				if (consumption == 0)
					consumption := translate("n/a")
				
				lapTime := getConfigurationValue(raceData, "Laps", "Lap." . lap . ".LapTime", "-")
				
				if (lapTime != "-")
					lapTime := Round(lapTime / 1000, 1)
				
				row := values2String(", "
									, lap
									, "'" . translate(getConfigurationValue(raceData, "Laps", "Lap." . lap . ".Weather")) . "'"
									, "'" . weather . "'"
									, "'" . getConfigurationValue(raceData, "Laps", "Lap." . lap . ".Map", translate("n/a")) . "'"
									, "'" . getConfigurationValue(raceData, "Laps", "Lap." . lap . ".TC", translate("n/a")) . "'"
									, "'" . getConfigurationValue(raceData, "Laps", "Lap." . lap . ".ABS", translate("n/a")) . "'"
									, "'" . consumption . "'"
									, "'" . lapTime . "'"
									, "'" . (getConfigurationValue(raceData, "Laps", "Lap." . lap . ".Pitstop", false) ? translate("x") : "") . "'")
											
				rows.Push("[" . row	. "]")
			}
			
			drawChartFunction := ""
			
			drawChartFunction .= "function drawChart() {`nvar data = new google.visualization.DataTable();`n"
			drawChartFunction .= "`ndata.addColumn('number', '" . translate("#") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Weather") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Tyres") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Map") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("TC") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("ABS") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Consumption") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Laptime") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Pitstop") . "');"
			
			drawChartFunction .= ("`ndata.addRows([" . values2String(", ", rows*) . "]);")
			
			drawChartFunction .= "`nvar cssClassNames = { headerCell: 'headerStyle', tableRow: 'rowStyle', oddTableRow: 'oddRowStyle' };"
			drawChartFunction := drawChartFunction . "`nvar options = { cssClassNames: cssClassNames, width: '100%' };"
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
	
	showDriverReport(reportDirectory) {
		if reportDirectory {
			GuiControl Enable, reportSettingsButton
				
			raceData := readConfiguration(reportDirectory . "\Race.data")
			
			GuiControl Choose, reportsDropDown, % inList(kReports, "Driver")
		
			this.iSelectedReport := "Driver"
			
			drivers := []
			positions := []
			times := []
			
			oldEncoding := A_FileEncoding
			
			FileEncoding UTF-8
			
			try {
				Loop Read, % reportDirectory . "\Drivers.CSV"
					drivers.Push(string2Values(";", A_LoopReadLine))
				
				Loop Read, % reportDirectory . "\Positions.CSV"
					positions.Push(string2Values(";", A_LoopReadLine))
				
				Loop Read, % reportDirectory . "\Times.CSV"
					times.Push(string2Values(";", A_LoopReadLine))
			}
			finally {
				FileEncoding %oldEncoding%
			}	
			
			allDrivers := this.getDrivers(raceData, drivers)
			
			cars := this.Settings["Drivers"]
			drivers := []
			
			for ignore, car in cars
				drivers.Push(allDrivers[car])
		
			potentials := false
			raceCrafts := false
			speeds := false
			consistencies := false
			carControls := false
			
			this.getDriverStats(raceData, cars, positions, times, potentials, raceCrafts, speeds, consistencies, carControls)
			
			drawChartFunction := ""
			
			drawChartFunction .= "function drawChart() {"
			drawChartFunction .= "`nvar data = google.visualization.arrayToDataTable(["
			drawChartFunction .= "`n['" . values2String("', '", translate("Category"), drivers*) . "'],"
			
			drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Potential") . "'", potentials*) . "],"
			drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Race Craft") . "'", raceCrafts*) . "],"
			drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Speed") . "'", speeds*) . "],"
			drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Consistency") . "'", consistencies*) . "],"
			drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Car Control") . "'", carControls*) . "]"
			
			drawChartFunction .= ("`n]);")
			
			drawChartFunction := drawChartFunction . "`nvar options = { bars: 'horizontal', backgroundColor: 'D0D0D0', chartArea: { left: '20%', top: '5%', right: '30%', bottom: '10%' } };"
			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.BarChart(document.getElementById('chart_id')); chart.draw(data, options); }"
			
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
	
	editDriverReportSettings(reportDirectory) {
		return this.editReportSettings(reportDirectory, "Laps", "Drivers")
	}
	
	showPositionReport(reportDirectory) {
		if reportDirectory {
			GuiControl Enable, reportSettingsButton
				
			raceData := readConfiguration(reportDirectory . "\Race.data")
			
			GuiControl Choose, reportsDropDown, % inList(kReports, "Position")
		
			this.iSelectedReport := "Position"
			
			cars := []
			positions := []
			
			oldEncoding := A_FileEncoding
			
			FileEncoding UTF-8
			
			try {
				Loop Read, % reportDirectory . "\Positions.CSV"
					positions.Push(string2Values(";", A_LoopReadLine))
			}
			finally {
				FileEncoding %oldEncoding%
			}
			
			carsCount := getConfigurationValue(raceData, "Cars", "Count")
			
			Loop % carsCount
			{
				car := A_Index
				valid := false
				
				for ignore, lap in this.getReportLaps(raceData)
					if (positions[lap][car] > 0) {
						valid := true
						
						break
					}
					else
						positions[A_Index][car] := "null" ; carsCount
				
				if valid
					cars.Push("'#" . getConfigurationValue(raceData, "Cars", "Car." . car . ".Nr") . A_Space . getConfigurationValue(raceData, "Cars", "Car." . car . ".Car") . "'")
				else
					for ignore, lap in this.getReportLaps(raceData)
						positions[lap].RemoveAt(car)
			}
			
			drawChartFunction := ""
			
			drawChartFunction .= ("function drawChart() {`nvar data = google.visualization.arrayToDataTable([`n[" . values2String(", ", "'" . translate("Laps") . "'", cars*) . "]")
			
			for ignore, lap in this.getReportLaps(raceData) {
				drawChartFunction := drawChartFunction . (",`n[" . lap)
				
				Loop % cars.Length()
					drawChartFunction := drawChartFunction . (", " . positions[lap][A_Index])
				
				drawChartFunction := drawChartFunction . "]"
			}
			
			drawChartFunction := drawChartFunction . ("]);`nvar options = { legend: { position: 'right' }, chartArea: { left: '5%', top: '5%', right: '20%', bottom: '10%' }, ")
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
	
	editPositionReportSettings(reportDirectory) {
		return this.editReportSettings(reportDirectory, "Laps")
	}
	
	showPaceReport(reportDirectory) {
		if reportDirectory {
			GuiControl Enable, reportSettingsButton
				
			raceData := readConfiguration(reportDirectory . "\Race.data")
			
			GuiControl Choose, reportsDropDown, % inList(kReports, "Pace")
		
			this.iSelectedReport := "Pace"
			
			selectedCars := this.getReportDrivers(raceData)
			cars := []
			times := []
			
			oldEncoding := A_FileEncoding
			
			FileEncoding UTF-8
			
			try {
				Loop Read, % reportDirectory . "\Times.CSV"
					times.Push(string2Values(";", A_LoopReadLine))
			}
			finally {
				FileEncoding %oldEncoding%
			}
			
			drawChartFunction := "function drawChart() {`nvar array = [`n"
			
			laps := this.getReportLaps(raceData)
			lapTimes := []
			
			for ignore, car in selectedCars {
				carTimes := Array("'#" . getConfigurationValue(raceData, "Cars", "Car." . car . ".Nr") . "'")
				
				for ignore, time in this.getDriverTimes(raceData, times, car)
					carTimes.Push(time)
				
				lapTimes.Push("[" . values2String(", ", carTimes*) . "]")
			}
			
			drawChartFunction .= (values2String("`n, ", lapTimes*) . "];")
			
			drawChartFunction .= "`nvar data = new google.visualization.DataTable();"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Car") . "');"
			
			Loop % laps.Length()
				drawChartFunction .= "`ndata.addColumn('number', '" . translate("Lap") . A_Space . laps[A_Index] . "');"
			
			text =
			(
			data.addColumn({id:'max', type:'number', role:'interval'});
			data.addColumn({id:'min', type:'number', role:'interval'});
			data.addColumn({id:'firstQuartile', type:'number', role:'interval'});
			data.addColumn({id:'median', type:'number', role:'interval'});
			data.addColumn({id:'thirdQuartile', type:'number', role:'interval'});
			)
			
			drawChartFunction .= ("`n" . text)
			
			drawChartFunction .= ("`n" . "data.addRows(getBoxPlotValues(array, " . (laps.Length() + 1) . "));")
			
			drawChartFunction .= ("`n" . getPaceJSFunctions())
			
			text =
			(
			var options = {
				backgroundColor: 'D0D0D0', chartArea: { left: '10`%', top: '5`%', right: '5`%', bottom: '20`%' },
				legend: { position: 'none' },
			)
			
			drawChartFunction .= text
			
			text =
			(
				hAxis: { title: '`%cars`%', gridlines: { color: '#777' } },
				vAxis: { title: '`%seconds`%' }, 
				lineWidth: 0,
				series: [ { 'color': 'D8D8D8' } ],
				intervals: { barWidth: 1, boxWidth: 1, lineWidth: 2, style: 'boxes' },
				interval: { max: { style: 'bars', fillOpacity: 1, color: '#777' },
							min: { style: 'bars', fillOpacity: 1, color: '#777' } }
			};
			)
			
			drawChartFunction .= ("`n" . substituteVariables(text, {cars: translate("Cars"), seconds: translate("Seconds")}))
			
			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.LineChart(document.getElementById('chart_id')); chart.draw(data, options); }"
			
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
	
	editPaceReportSettings(reportDirectory) {
		return this.editReportSettings(reportDirectory, "Laps", "Drivers")
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
			GuiControl Disable, reportSettingsButton
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
				GuiControl Disable, reportSettingsButton
				GuiControl Choose, reportsDropDown, 0
				GuiControl Disable, %deleteRaceReportButtonHandle%
				
				this.iSelectedRace := false
				
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
	
	loadReport(report) {
		if (report != this.SelectedReport) {
			this.iSettings := {}
			
			if report {
				GuiControlGet simulatorDropDown
				
				this.iSelectedReport := report
				
				this.Settings.Delete("Laps")
				this.Settings.Delete("Drivers")
								
				Loop Files, % this.Database . "\" . this.SetupDatabase.getSimulatorCode(simulatorDropDown) . "\*.*", D
					if (A_Index = this.SelectedRace) {
						GuiControl Choose, reportsDropDown, % inList(kReports, report)
						GuiControl Disable, reportSettingsButton
						
						switch report {
							case "Overview":
								this.showOverviewReport(A_LoopFilePath)
							case "Car":
								this.showCarReport(A_LoopFilePath)
							case "Driver":
								this.Settings["Drivers"] := [1, 2, 3, 4, 5]
								
								this.showDriverReport(A_LoopFilePath)
							case "Position":
								this.showPositionReport(A_LoopFilePath)
							case "Pace":
								this.showPaceReport(A_LoopFilePath)
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
	
	reportSettings(report) {
		raceFolder := false
		
		Loop Files, % this.Database . "\" . this.SetupDatabase.getSimulatorCode(simulatorDropDown) . "\*.*", D
			if (A_Index = this.SelectedRace) {
				raceFolder := A_LoopFilePath
				
				break
			}
		
		if raceFolder {
			switch report {
				case "Driver":
					if this.editDriverReportSettings(raceFolder)
						this.showDriverReport(raceFolder)
				case "Position":
					if this.editPositionReportSettings(raceFolder)
						this.showPositionReport(raceFolder)
				case "Pace":
					if this.editPaceReportSettings(raceFolder)
						this.showPaceReport(raceFolder)
			}
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

getPaceJSFunctions() {
	script =
	(
	/**
	* Takes an array of input data and returns an
	* array of the input data with the box plot
	* interval data appended to each row.
	*/
	function getBoxPlotValues(array, base) {
		for (var i = 0; i < array.length; i++) {
			var arr = array[i].slice(1).sort(function (a, b) {
												return a - b;
											 });

			var max = arr[arr.length - 1];
			var min = arr[0];
			var median = getMedian(arr);

			if (arr.length `% 2 === 0) {
				var midUpper = arr.length / 2;
				var midLower = midUpper - 1;

				array[i][base + 2] = getMedian(arr.slice(0, midUpper));
				array[i][base + 4] = getMedian(arr.slice(midLower));
			}
			else {
				var index = Math.floor(arr.length / 2);

				array[i][base + 2] = getMedian(arr.slice(0, index + 1));
				array[i][base + 4] = getMedian(arr.slice(index));
			}

			array[i][base] = max;
			array[i][base + 1] = min
			array[i][base + 3] = median;
		}

		return array;
	}

	/*
	* Takes an array and returns
	* the median value.
	*/
	function getMedian(array) {
		var length = array.length;

		/* If the array is an even length the
		* median is the average of the two
		* middle-most values. Otherwise the
		* median is the middle-most value.
		*/
		if (length `% 2 === 0) {
			var midUpper = length / 2;
			var midLower = midUpper - 1;

			return (array[midUpper] + array[midLower]) / 2;
		}
		else {
			return array[Math.floor(length / 2)];
		}
	}
	)
	
	return script
}

global rangeLapsEdit
	
editReportSettings(raceReports, reportDirectory := false, options := false) {
	static allLapsRadio
	static rangeLapsRadio
	
	static result := false
	
	if (raceReports = kCancel)
		result := kCancel
	else if (raceReports = kOk)
		result := kOk
	else {
		result := false
	
		raceData := readConfiguration(reportDirectory . "\Race.data")
		
		drivers := []
		laps := []
		
		oldEncoding := A_FileEncoding
		
		FileEncoding UTF-8
		
		try {
			Loop Read, % reportDirectory . "\Drivers.CSV"
				drivers.Push(string2Values(";", A_LoopReadLine))
						
			Loop Read, % reportDirectory . "\Laps.CSV"
				laps.Push(string2Values(";", A_LoopReadLine))
		}
		finally {
			FileEncoding %oldEncoding%
		}
	
		owner := RaceReports.Instance.Window
		
		Gui RRS:Default
		Gui RRS:+Owner%owner%
	
		Gui RRS:-Border ; -Caption
		Gui RRS:Color, D0D0D0, D8D8D8

		Gui RRS:Font, s10 Bold, Arial

		Gui RRS:Add, Text, w344 Center gmoveSettings, % translate("Modular Simulator Controller System") 
		
		Gui RRS:Font, s9 Norm, Arial
		Gui RRS:Font, Italic Underline, Arial

		Gui RRS:Add, Text, YP+20 w344 cBlue Center gopenReportsDocumentation, % translate("Report Settings")
		
		Gui RRS:Font, s8 Norm, Arial
		
		Gui RRS:Add, Text, x8 yp+30 w360 0x10
		
		if inList(options, "Laps") {
			Gui RRS:Add, Text, x16 yp+10 w70 h23 +0x200 Section, % translate("Laps")
		
			Gui RRS:Add, Radio, x90 yp+4 w80 Group vallLapsRadio gchooseLapSelection, % translate(" All")
			Gui RRS:Add, Radio, x90 yp+24 w80 vrangeLapsRadio gchooseLapSelection, % translate(" Range:")
			Gui RRS:Add, Edit, x170 yp-3 w80 vrangeLapsEdit
			Gui RRS:Add, Text, x255 yp+3 w110, % translate("(e.g.: 1-5;8;12)")
			
			if !raceReports.Settings.HasKey("Laps") {
				GuiControl, , allLapsRadio, 1
				GuiControl Disable, rangeLapsEdit
			}
			else {
				GuiControl, , rangeLapsRadio, 1
				GuiControl Enable, rangeLapsEdit
				
				lapsDef := ""
				laps := raceReports.Settings["Laps"]
				baseLap := false
				lastLap := false
				
				for ignore, lap in laps {
					if !baseLap
						baseLap := lap
					else if (lap != (lastLap + 1)) {
						if (baseLap = lastLap)
							lapsDef .= (((lapsDef != "") ? ";" : "") . baseLap)
						else
							lapsDef .= (((lapsDef != "") ? ";" : "") . (baseLap . "-" . lastLap))
					
						baseLap := lap
					}
					
					lastLap := lap
				}
			
				if (baseLap = lastLap)
					lapsDef .= (((lapsDef != "") ? ";" : "") . baseLap)
				else
					lapsDef .= (((lapsDef != "") ? ";" : "") . (baseLap . "-" . lastLap))
				
				GuiControl Text, rangeLapsEdit, %lapsDef%
			}
		}
		
		if inList(options, "Drivers") {
			yOption := (inList(options, "Laps") ? "yp+30" : "yp+10")
			
			Gui RRS:Add, Text, x16 %yOption% w70 h23 +0x200 Section, % translate("Drivers")
			
			Gui RRS:Add, ListView, x90 yp w264 h300 -Multi -LV0x10 Checked NoSort NoSortHdr, % values2String("|", map(["Driver", "Car"], "translate")*)
			
			allDrivers := raceReports.getDrivers(raceData, drivers)
			selectedDrivers := []
			
			if raceReports.Settings.HasKey("Drivers")
				selectedDrivers := raceReports.Settings["Drivers"]
			else
				Loop % allDrivers.Length()
					selectedDrivers.Push(A_Index)
				
			for ignore, driver in allDrivers
				LV_Add(inList(selectedDrivers, A_Index) ? "Check" : "", driver, getConfigurationValue(raceData, "Cars", "Car." . A_Index . ".Car"))
			
			LV_ModifyCol(1, "AutoHdr")
			LV_ModifyCol(2, "AutoHdr")
		}	

		Gui RRS:Font, s8 Norm, Arial
		
		yOption := (inList(options, "Drivers") ? "yp+306" : "yp+30")
		
		Gui RRS:Add, Text, x8 %yOption% w360 0x10
		
		Gui RRS:Add, Button, x108 yp+10 w80 h23 Default GacceptSettings, % translate("Ok")
		Gui RRS:Add, Button, x196 yp w80 h23 GcancelSettings, % translate("&Cancel")
		
		Gui RRS:Show
		
		Loop
			Sleep 100
		Until result
		
		if (result = kOk) {
			result := {}
			
			Gui RRS:Submit
		
			if inList(options, "Laps") {
				if allLapsRadio
					result["Laps"] := true
				else {
					laps := {}
							
					for ignore, lap in string2Values(";", rangeLapsEdit)
						if InStr(lap, "-") {
							lap := string2Values("-", lap)
							startLap := lap[1]
							endLap := lap[2]
							
							if startLap is integer
								if endLap is integer
									if (endLap + 0) > (startLap + 0)
										Loop {
											index := startLap + A_Index - 1
										
											laps[index] := index
										} Until (index = endLap)
						}
						else if lap is integer
							laps[lap] := lap
					
					newlaps := []
					
					for lap, ignore in laps
						newLaps.Push(lap)
					
					result["Laps"] := newLaps
				}
			}
			
			if inList(options, "Drivers") {
				newDrivers := []
				
				rowNumber := 0
				
				Loop {
					rowNumber := LV_GetNext(rowNumber, "C")
					
					if !rowNumber
						break
					else
						newDrivers.Push(rowNumber)
				}
				
				result["Drivers"] := newDrivers
			}
		}
		else
			result := false
		
		Gui RRS:Destroy
		
		return result
	}
}

acceptSettings() {
	editReportSettings(kOk)
}

cancelSettings() {
	editReportSettings(kCancel)
}

chooseLapSelection() {
	if (A_GuiControl = "allLapsRadio") {
		GuiControl Disable, rangeLapsEdit
		GuiControl Text, rangeLapsEdit, % ""
	}
	else
		GuiControl Enable, rangeLapsEdit
}

moveSettings() {
	moveByMouse("RRS")
}
	
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
	
	current := fixIE(11)
	
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