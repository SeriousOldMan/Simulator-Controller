;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Report Viewer              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Math.ahk
#Include Libraries\SetupDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kRaceReports = ["Overview", "Car", "Driver", "Position", "Pace"]


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kOk = "Ok"
global kCancel = "Cancel"

global kNull = "null"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceReportViewer {
	iWindow := false
	iReport := false
	iChartViewer := false
	iInfoViewer := false
	
	iSettings := {}
	
	Window[] {
		Get {
			return this.iWindow
		}
	}
	
	Report[] {
		Get {
			return this.iReport
		}
	}
	
	ChartViewer[] {
		Get {
			return this.iChartViewer
		}
	}
	
	InfoViewer[] {
		Get {
			return this.iInfoViewer
		}
	}
	
	Settings[key := false] {
		Get {
			if key
				return this.iSettings[key]
			else
				return this.iSettings
		}
		
		Set {
			if key
				return this.iSettings[key] := value
			else
				return this.iSettings := value
		}
	}
	
	__New(window, chartViewer := false, infoViewer := false) {
		this.iWindow := window
		this.iChartViewer := chartViewer
		this.iInfoViewer := infoViewer
	}
	
	showReportChart(drawChartFunction) {
		if this.ChartViewer {
			window := this.Window
			
			Gui %window%:Default
			
			this.ChartViewer.Document.open()
			
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

				width := this.ChartViewer.Width
				height := (this.ChartViewer.Height - 1)
				
				after =
				(
						</script>
					</head>
					<body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>
						<div id="chart_id" style="width: %width%px; height: %height%px"></div>
					</body>
				</html>
				)

				this.ChartViewer.Document.write(before . drawChartFunction . after)
			}
			else {
				html := "<html><body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"
			
				this.ChartViewer.Document.write(html)
			}
			
			this.ChartViewer.Document.close()
		}
	}
	
	setReport(report) {
		this.iReport := report
	}
	
	showReportInfo(raceData) {
		if this.InfoViewer {
			window := this.Window
			
			Gui %window%:Default
			
			this.InfoViewer.Document.open()
			
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
				
				infoText := "<html><body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='3' topmargin='3' rightmargin='3' bottommargin='3'><style> table, p { font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><p>" . infoText . "</p></body></html>"
				
				this.InfoViewer.Document.write(infoText)
			}
			else {
				html := "<html><body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"
			
				this.InfoViewer.Document.write(html)
			}
			
			this.InfoViewer.Document.close()
		}
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
	
	getCar(lap, car, ByRef carNumber, ByRef carName, ByRef driverForname, ByRef driverSurname, ByRef driverNickname) {
		local raceData := true
		local drivers := true
		local positions := false
		local times := false
		
		this.loadReportData(Array(lap), raceData, drivers, positions, times)
		
		carNumber := getConfigurationValue(raceData, "Cars", "Car." . car . ".Nr", "-")
		carName := getConfigurationValue(raceData, "Cars", "Car." . car . ".Car", translate("Unknown"))
		
		if (drivers.Length() > 0) {
			parts := string2Values(A_Space, drivers[1][car])
			
			driverForname := parts[1]
			driverSurname := parts[2]
			driverNickname := StrReplace(StrReplace(parts[3], "(", ""), ")", "")
		}
		else {
			driverForname := "John"
			driverSurname := "Doe"
			driverNickname := "JDO"
		}
	}
	
	getStandings(lap, ByRef cars, ByRef positions, ByRef carNumbers, ByRef carNames, ByRef driverFornames, ByRef driverSurnames, ByRef driverNicknames) {
		local raceData := true
		local drivers := true
		local tPositions := true
		local times := false
		
		this.loadReportData(Array(lap), raceData, drivers, tPositions, times)
		
		if cars
			cars := []
			
		if positions
			positions := []
		
		if carNumbers
			carNumbers := []
		
		if carNames
			carNames := []
				
		if driverFornames
			driverFornames := []
			
		if driverSurnames
			driverSurnames := []
			
		if driverNicknames
			driverNicknames := []
			
		if cars
			Loop % getConfigurationValue(raceData, "Cars", "Count", 0) {
				cars.Push(A_Index)
			
				if positions
					positions.Push(tPositions[1][A_Index])
			
				if carNumbers
					carNumbers.Push(getConfigurationValue(raceData, "Cars", "Car." . A_Index . ".Nr"))
			
				if carNames
					carNames.Push(getConfigurationValue(raceData, "Cars", "Car." . A_Index . ".Car"))
		
				parts := string2Values(A_Space, drivers[1][A_Index])
				
				if driverFornames
					driverFornames.Push(parts[1])
				
				if driverSurnames
					driverSurnames.Push(parts[2])
				
				if driverNicknames
					driverNicknames.Push(StrReplace(StrReplace(parts[3], "(", ""), ")", ""))
			}
	}
	
	getDriverPositions(raceData, positions, car) {
		result := []
		
		for ignore, lap in this.getReportLaps(raceData)
			result.Push(positions[lap].HasKey(car) ? positions[lap][car] : kNull)
		
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
				time := (times[lap].HasKey(car) ? times[lap][car] : 0)
				time := ((time = kNull) ? 0 : Round(times[lap][car] / 1000, 1))
				
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
			time := (times[lap].HasKey(car) ? times[lap][car] : 0)
			time := ((time = kNull) ? 0 : Round(time, 1))
				
			if (time > 0)
				validTimes.Push(time)
		}
		
		min := Round(minimum(validTimes) / 1000, 1)
		
		stdDev := stdDeviation(validTimes)
		avg := average(validTimes)
		
		invalidTimes := []
		
		for ignore, time in validTimes
			if ((time > avg) && (Abs(time - avg) > stdDev))
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
				time := (times[lap].HasKey(car) ? times[lap][car] : 0)
				time := ((time = kNull) ? 0 : Round(times[lap][car] / 1000, 1))
				
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
	
	getDriverStatistics(raceData, cars, positions, times, ByRef potentials, ByRef raceCrafts, ByRef speeds, ByRef consistencies, ByRef carControls) {
		consistencies := this.normalizeValues(map(cars, ObjBindMethod(this, "getDriverConsistency", raceData, times)), 5)
		carControls := this.normalizeValues(map(cars, ObjBindMethod(this, "getDriverCarControl", raceData, times)), 5)
		speeds := this.normalizeSpeedValues(map(cars, ObjBindMethod(this, "getDriverSpeed", raceData, times)), 5)
		raceCrafts := this.normalizeValues(map(cars, ObjBindMethod(this, "getDriverRaceCraft", raceData, positions)), 5)
		potentials := this.normalizeValues(map(cars, ObjBindMethod(this, "getDriverPotential", raceData, positions)), 5)
		
		return true
	}
	
	loadReportData(laps, ByRef raceData, ByRef drivers, ByRef positions, ByRef times) {
		if drivers
			drivers := []
		
		if positions
			positions := []
		
		if times
			times := []
			
		report := this.Report
		
		if report {
			if raceData
				raceData := readConfiguration(report . "\Race.data")
			
			oldEncoding := A_FileEncoding
			
			FileEncoding UTF-8
			
			try {
				if drivers {
					Loop Read, % report . "\Drivers.CSV"
						if (!laps || inList(laps, A_Index))
							drivers.Push(string2Values(";", A_LoopReadLine))

					drivers := correctEmptyValues(drivers)
				}
				
				if positions {
					Loop Read, % report . "\Positions.CSV"
						if (!laps || inList(laps, A_Index))
							positions.Push(string2Values(";", A_LoopReadLine))

					positions := correctEmptyValues(positions, kNull)
				}
				
				if times {
					Loop Read, % report . "\Times.CSV"
						if (!laps || inList(laps, A_Index))
							times.Push(string2Values(";", A_LoopReadLine))

					times := correctEmptyValues(times, kNull)
				}
			}
			finally {
				FileEncoding %oldEncoding%
			}
		}
	}
	
	editReportSettings(settings*) {
		result := editReportSettings(this, this.Report, settings)
		
		if result
			for setting, values in result
				if ((setting = "Laps") && (values == true))
					this.Settings.Delete("Laps")
				else
					this.Settings[setting] := values
		
		return (result != false)
	}
	
	showOverviewReport() {
		report := this.Report
		
		if report {
			raceData := true
			drivers := true
			positions := true
			times := true
			
			this.loadReportData(false, raceData, drivers, positions, times)
			
			cars := []
			
			carsCount := getConfigurationValue(raceData, "Cars", "Count")
			lapsCount := getConfigurationValue(raceData, "Laps", "Count")
			simulator := getConfigurationValue(raceData, "Session", "Simulator")
			
			sessionDB := new SessionDatabase()
			
			Loop %carsCount% {
				car := A_Index
				valid := false
				
				for ignore, lap in this.getReportLaps(raceData)
					if (positions.Length() >= lap) {
						if (positions[lap].HasKey(car) && (positions[lap][car] > 0))
							valid := true
						else
							positions[lap][car] := kNull ; carsCount
					}
					else
						valid := false
				
				if valid
					cars.Push(Array(getConfigurationValue(raceData, "Cars", "Car." . car . ".Nr"), getConfigurationValue(raceData, "Cars", "Car." . car . ".Car")))
				else
					for ignore, lap in this.getReportLaps(raceData) {
						if (drivers.Length() >= lap) {
							drivers[lap].RemoveAt(car)
							positions[lap].RemoveAt(car)
							times[lap].RemoveAt(car)
						}
					}
			}
			
			carsCount := cars.Length()
		
			rows := []
			hasDNF := false
			
			Loop % carsCount
			{
				car := A_Index
				
				result := (positions[lapsCount][car] = kNull ? "DNF" : positions[lapsCount][car])
				lapTimes := []
				
				Loop % lapsCount
				{
					lapTime := times[A_Index][car]
				
					if ((lapTime != kNull) && (lapTime > 0))
						lapTimes.Push(lapTime)
					else
						result := "DNF"
				}
				
				min := minimum(lapTimes)
				avg := average(lapTimes)
				
				filteredLapTimes := lapTimes
				lapTimes := []
				
				for ignore, lapTime in filteredLapTimes
					if (lapTime < (avg + (avg - min)))
						lapTimes.Push(lapTime)
					
				min := Round(minimum(lapTimes) / 1000, 1)
				avg := Round(average(lapTimes) / 1000, 1)
				
				hasDNF := (hasDNF || (result = "DNF"))
				
				rows.Push(Array(cars[A_Index][1], "'" . StrReplace(sessionDB.getCarName(simulator, cars[A_Index][2]), "'", "\'") . "'", "'" . StrReplace(drivers[1][A_Index], "'", "\'") . "'"
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
			this.showReportChart(false)
			this.showReportInfo(false)
		}
	}
	
	showCarReport() {
		report := this.Report
		
		if report {
			raceData := readConfiguration(report . "\Race.data")
			
			cars := []
			rows := []
			
			pitstops := string2Values(",", getConfigurationValue(raceData, "Laps", "Pitstops", ""))
			
			for ignore, lap in this.getReportLaps(raceData) {
				weather := getConfigurationValue(raceData, "Laps", "Lap." . lap . ".Weather")
				weather := (weather ? translate(weather) : "n/a")
			
				if getConfigurationValue(raceData, "Laps", "Lap." . lap . ".Compound", false)
					compound := translate(compound(getConfigurationValue(raceData, "Laps", "Lap." . lap . ".Compound", "Dry")
												 , getConfigurationValue(raceData, "Laps", "Lap." . lap . ".CompoundColor", "Black")))
				else
					compound := "-"
				
				consumption := getConfigurationValue(raceData, "Laps", "Lap." . lap . ".Consumption", translate("n/a"))
				
				if (consumption == 0)
					consumption := translate("n/a")
				
				lapTime := getConfigurationValue(raceData, "Laps", "Lap." . lap . ".LapTime", "n/a")
				
				if (lapTime != "-")
					lapTime := Round(lapTime / 1000, 1)
				
				pitstop := ((pitstops.Length() > 0) ? inList(pitstops, lap) : (getConfigurationValue(raceData, "Laps", "Lap." . lap . ".Pitstop", false)))
				
				row := values2String(", "
									, lap
									, "'" . weather . "'"
									, "'" . compound . "'"
									, "'" . getConfigurationValue(raceData, "Laps", "Lap." . lap . ".Map", translate("n/a")) . "'"
									, "'" . getConfigurationValue(raceData, "Laps", "Lap." . lap . ".TC", translate("n/a")) . "'"
									, "'" . getConfigurationValue(raceData, "Laps", "Lap." . lap . ".ABS", translate("n/a")) . "'"
									, "'" . consumption . "'"
									, "'" . lapTime . "'"
									, "'" . (pitstop ? translate("x") : "") . "'")
											
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
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Lap Time") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Pitstop") . "');"
			
			drawChartFunction .= ("`ndata.addRows([" . values2String(", ", rows*) . "]);")
			
			drawChartFunction .= "`nvar cssClassNames = { headerCell: 'headerStyle', tableRow: 'rowStyle', oddTableRow: 'oddRowStyle' };"
			drawChartFunction := drawChartFunction . "`nvar options = { cssClassNames: cssClassNames, width: '100%' };"
			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.Table(document.getElementById('chart_id')); chart.draw(data, options); }"
			
			this.showReportChart(drawChartFunction)
			this.showReportInfo(raceData)
		}
		else {
			this.showReportChart(false)
			this.showReportInfo(false)
		}
	}
	
	showDriverReport() {
		report := this.Report
		
		if report {
			raceData := true
			drivers := true
			positions := true
			times := true
			
			this.loadReportData(false, raceData, drivers, positions, times)
			
			allDrivers := this.getDrivers(raceData, drivers)
			
			cars := []
			
			for ignore, car in this.Settings["Drivers"]
				if allDrivers.HasKey(car)
					cars.Push(car)
				
			drivers := []
			
			for ignore, car in cars
				drivers.Push(StrReplace(allDrivers[car], "'", "\'"))
		
			potentials := false
			raceCrafts := false
			speeds := false
			consistencies := false
			carControls := false
			
			this.getDriverStatistics(raceData, cars, positions, times, potentials, raceCrafts, speeds, consistencies, carControls)
			
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
			
			drawChartFunction := drawChartFunction . "`nvar options = { bars: 'horizontal', backgroundColor: 'D8D8D8', chartArea: { left: '20%', top: '5%', right: '30%', bottom: '10%' } };"
			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.BarChart(document.getElementById('chart_id')); chart.draw(data, options); }"
			
			this.showReportChart(drawChartFunction)
			this.showReportInfo(raceData)
		}
		else {
			this.showReportChart(false)
			this.showReportInfo(false)
		}
	}
	
	editDriverReportSettings() {
		return this.editReportSettings("Laps", "Drivers")
	}
	
	showPositionReport() {
		report := this.Report
		
		if report {
			raceData := true
			drivers := false
			positions := true
			times := false
			
			this.loadReportData(false, raceData, drivers, positions, times)
			
			cars := []
			
			carsCount := getConfigurationValue(raceData, "Cars", "Count")
			simulator := getConfigurationValue(raceData, "Session", "Simulator")
			
			sessionDB := new SessionDatabase()
			
			Loop % carsCount
			{
				car := A_Index
				valid := false
				
				for ignore, lap in this.getReportLaps(raceData)
					if (positions[lap].HasKey(car) && (positions[lap][car] > 0)) {
						valid := true
						
						break
					}
					else
						positions[A_Index][car] := kNull ; carsCount
				
				if valid
					cars.Push("'#" . getConfigurationValue(raceData, "Cars", "Car." . car . ".Nr") . A_Space
								   . StrReplace(sessionDB.getCarName(simulator, getConfigurationValue(raceData, "Cars", "Car." . car . ".Car")), "'", "\'") . "'")
				else
					for ignore, lap in this.getReportLaps(raceData)
						positions[lap].RemoveAt(car)
			}
			
			drawChartFunction := ""
			
			drawChartFunction .= ("function drawChart() {`nvar data = google.visualization.arrayToDataTable([`n[" . values2String(", ", "'" . translate("Laps") . "'", cars*) . "]")
			
			for ignore, lap in this.getReportLaps(raceData) {
				if (positions.Length() >= lap) {
					drawChartFunction := drawChartFunction . (",`n[" . lap)
					
					Loop % cars.Length() {
						lapPositions := positions[lap]
					
						if lapPositions.HasKey(A_Index)
							drawChartFunction := (drawChartFunction . ", " . lapPositions[A_Index])
						else
							drawChartFunction := (drawChartFunction . ", null")
					}
					
					drawChartFunction := drawChartFunction . "]"
				}
			}
			
			drawChartFunction := drawChartFunction . ("]);`nvar options = { legend: { position: 'right' }, chartArea: { left: '5%', top: '5%', right: '20%', bottom: '10%' }, ")
			drawChartFunction := drawChartFunction . ("hAxis: { title: '" . translate("Laps") . "' }, vAxis: { direction: -1, ticks: [], title: '" . translate("Cars") . "', baselineColor: 'D0D0D0' }, backgroundColor: 'D8D8D8' };`n")

			drawChartFunction := drawChartFunction . "var chart = new google.visualization.LineChart(document.getElementById('chart_id')); chart.draw(data, options); }"
			
			this.showReportChart(drawChartFunction)
			this.showReportInfo(raceData)
		}
		else {
			this.showReportChart(false)
			this.showReportInfo(false)
		}
	}
	
	editPositionReportSettings() {
		return this.editReportSettings("Laps")
	}
	
	showPaceReport() {
		report := this.Report
		
		if report {
			raceData := true
			drivers := false
			positions := false
			times := true
			
			this.loadReportData(false, raceData, drivers, positions, times)
			
			selectedCars := this.getReportDrivers(raceData)
			cars := []
			
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
				backgroundColor: 'D8D8D8', chartArea: { left: '10`%', top: '5`%', right: '5`%', bottom: '20`%' },
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
			
			drawChartFunction .= ("`nvar chart = new google.visualization.LineChart(document.getElementById('chart_id')); chart.draw(data, options); }")
			
			this.showReportChart(drawChartFunction)
			this.showReportInfo(raceData)
		}
		else {
			this.showReportChart(false)
			this.showReportInfo(false)
		}
	}
	
	editPaceReportSettings() {
		return this.editReportSettings("Laps", "Drivers")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

compound(compound, color := false) {
	if color {
		if (color = "Black")
			return compound
		else
			return (compound . " (" . color . ")")
	}
	else
		return string2Values(A_Space, compound)[1]
}

compoundColor(compound) {
	compound := string2Values(A_Space, compound)
	
	if (compound.Length() == 1)
		return "Black"
	else
		return SubStr(compound[2], 2, StrLen(compound[2]) - 2)
}

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


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

correctEmptyValues(table, default := "__Undefined__") {
	Loop % table.Length()
	{
		line := A_Index
		
		if (line > 1)
			Loop % table[line].Length()
				if (table[line][A_Index] = "-")
					table[line][A_Index] := ((default == kUndefined) ? table[line][A_Index - 1] : default)
	}
	
	return table
}

global rangeLapsEdit
global driverSelectCheck

editReportSettings(raceReport, report := false, options := false) {
	static allLapsRadio
	static rangeLapsRadio
	
	static result := false
	
	if (raceReport = kCancel)
		result := kCancel
	else if (raceReport = kOk)
		result := kOk
	else {
		result := false
	
		raceData := readConfiguration(report . "\Race.data")
		
		drivers := []
		laps := []
		
		oldEncoding := A_FileEncoding
		
		FileEncoding UTF-8
		
		try {
			Loop Read, % report . "\Drivers.CSV"
				drivers.Push(string2Values(";", A_LoopReadLine))
			
			drivers := correctEmptyValues(drivers)
			
			Loop Read, % report . "\Laps.CSV"
				laps.Push(string2Values(";", A_LoopReadLine))
			
			laps := correctEmptyValues(laps)
		}
		finally {
			FileEncoding %oldEncoding%
		}

		owner := raceReport.Window
		
		Gui RRS:Default
		Gui RRS:+Owner%owner%
	
		Gui RRS:-Border ; -Caption
		Gui RRS:Color, D0D0D0, D8D8D8

		Gui RRS:Font, s10 Bold, Arial

		Gui RRS:Add, Text, w344 Center gmoveSettings, % translate("Modular Simulator Controller System") 
		
		Gui RRS:Font, s9 Norm, Arial
		Gui RRS:Font, Italic Underline, Arial

		Gui RRS:Add, Text, YP+20 w344 cBlue Center gopenReportSettingsDocumentation, % translate("Report Settings")
		
		Gui RRS:Font, s8 Norm, Arial
		
		Gui RRS:Add, Text, x8 yp+30 w360 0x10
		
		if inList(options, "Laps") {
			Gui RRS:Add, Text, x16 yp+10 w70 h23 +0x200 Section, % translate("Laps")
		
			Gui RRS:Add, Radio, x90 yp+4 w80 Group vallLapsRadio gchooseLapSelection, % translate(" All")
			Gui RRS:Add, Radio, x90 yp+24 w80 vrangeLapsRadio gchooseLapSelection, % translate(" Range:")
			Gui RRS:Add, Edit, x170 yp-3 w80 vrangeLapsEdit
			Gui RRS:Add, Text, x255 yp+3 w110, % translate("(e.g.: 1-5;8;12)")
			
			if !raceReport.Settings.HasKey("Laps") {
				GuiControl, , allLapsRadio, 1
				GuiControl Disable, rangeLapsEdit
			}
			else {
				GuiControl, , rangeLapsRadio, 1
				GuiControl Enable, rangeLapsEdit
				
				lapsDef := ""
				laps := raceReport.Settings["Laps"]
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
			yOption := (inList(options, "Laps") ? "yp+30" : "yp+10") + 2
			
			Gui RRS:Add, Text, x16 %yOption% w70 h23 +0x200 Section, % translate("Drivers")
			
			Gui RRS:Add, ListView, x90 yp-2 w264 h300 AltSubmit -Multi -LV0x10 Checked NoSort NoSortHdr gselectDriver, % values2String("|", map(["     Driver", "Car"], "translate")*)
			
			Gui RRS:Add, CheckBox, Check3 x72 yp+2 w15 h23 vdriverSelectCheck gselectDrivers
			
			allDrivers := raceReport.getDrivers(raceData, drivers)
			selectedDrivers := []
			
			if raceReport.Settings.HasKey("Drivers")
				selectedDrivers := raceReport.Settings["Drivers"]
			else
				Loop % allDrivers.Length()
					selectedDrivers.Push(A_Index)
			
			sessionDB := new SessionDatabase()
			simulator := getConfigurationValue(raceData, "Session", "Simulator")
			
			for ignore, driver in allDrivers
				LV_Add(inList(selectedDrivers, A_Index) ? "Check" : "", driver
					 , sessionDB.getCarName(simulator, getConfigurationValue(raceData, "Cars", "Car." . A_Index . ".Car")))
			
			if (!selectedDrivers || (selectedDrivers.Length() == allDrivers.Length()))
				GuiControl, , driverSelectCheck, 1
			else if ((selectedDrivers.Length() > 0) && (selectedDrivers.Length() != allDrivers.Length()))
				GuiControl, , driverSelectCheck, -1
			else
				GuiControl, , driverSelectCheck, 0
			
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

selectDriver() {
	selected := 0
	
	row := 0
	
	Loop {
		row := LV_GetNext(row, "C")
	
		if row
			selected += 1
		else
			break
	}
	
	if (selected == 0)
		GuiControl, , driverSelectCheck, 0
	else if (selected < LV_GetCount())
		GuiControl, , driverSelectCheck, -1
	else
		GuiControl, , driverSelectCheck, 1
}

selectDrivers() {
	GuiControlGet driverSelectCheck
	
	if (driverSelectCheck == -1) {
		driverSelectCheck := 0
		
		GuiControl, , driverSelectCheck, 0
	}
	
	Loop % LV_GetCount()
		LV_Modify(A_Index, driverSelectCheck ? "Check" : "-Check")
}

moveSettings() {
	moveByMouse("RRS")
}

openReportSettingsDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#race-reports
}