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
#Include ..\Assistants\Libraries\SessionDatabase.ahk
#Include ..\Assistants\Libraries\RaceReportReader.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kRaceReports := ["Overview", "Car", "Drivers", "Positions", "Lap Times", "Consistency", "Pace"]


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kOk := "Ok"
global kCancel := "Cancel"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceReportViewer extends RaceReportReader {
	iWindow := false
	iChartViewer := false
	iInfoViewer := false

	iSettings := {}

	Window[] {
		Get {
			return this.iWindow
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
		base.__New()

		this.iWindow := window
		this.iChartViewer := chartViewer
		this.iInfoViewer := infoViewer
	}

	lapTimeDisplayValue(lapTime) {
		local seconds, fraction, minutes

		if lapTime is Number
		{
			seconds := Floor(lapTime)
			fraction := (lapTime - seconds)
			minutes := Floor(seconds / 60)

			fraction := Round(fraction * 10)

			seconds := ((seconds - (minutes * 60)) . "")

			if (StrLen(seconds) = 1)
				seconds := ("0" . seconds)

			return (minutes . ":" . seconds . "." . fraction)
		}
		else
			return lapTime
	}

	showReportChart(drawChartFunction) {
		local window, before, after, width, height, html

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
							.cellStyle { text-align: right; }
							.rowStyle { font-size: 11px; background-color: 'E0E0E0'; }
							.oddRowStyle { font-size: 11px; background-color: 'E8E8E8'; }
						</style>
						<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
						<script type="text/javascript">
							google.charts.load('current', {'packages':['corechart', 'bar', 'table']}).then(drawChart);
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

				html := (before . drawChartFunction . after)

				this.ChartViewer.Document.write(html)
			}
			else {
				html := "<html><body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"

				this.ChartViewer.Document.write(html)
			}

			this.ChartViewer.Document.close()
		}
	}

	showReportInfo(raceData) {
		local window, infoText, conditions, descriptor, info, html

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

	getLaps(raceData, alwaysAll := false) {
		if (!alwaysAll && this.Settings.HasKey("Laps"))
			return this.Settings["Laps"]
		else
			return base.getLaps(raceData)
	}

	getDrivers(raceData) {
		if this.Settings.HasKey("Drivers")
			return this.Settings["Drivers"]
		else
			return base.getDrivers(raceData)
	}

	getReportLaps(raceData, alwaysAll := false) {
		return this.getLaps(raceData, alwaysAll)
	}

	getReportDrivers(raceData, drivers := false) {
		local result

		if drivers {
			result := []

			loop % getConfigurationValue(raceData, "Cars", "Count")
				result.Push(drivers[1][A_Index])

			return result
		}
		else
			return this.getDrivers(raceData)
	}

	loadReportData(laps, ByRef raceData, ByRef drivers, ByRef positions, ByRef times) {
		return this.loadData(laps, raceData, drivers, positions, times)
	}

	editReportSettings(settings*) {
		local result := editReportSettings(this, this.Report, settings)
		local setting, values

		if result
			for setting, values in result
				if ((setting = "Laps") && (values == true))
					this.Settings.Delete("Laps")
				else
					this.Settings[setting] := values

		return (result != false)
	}

	showOverviewReport() {
		local drawChartFunction := "function drawChart() {`nvar data = new google.visualization.DataTable();`n"
		local report := this.Report
		local raceData, drivers, positions, times, cars, carsCount, lapsCount, simulator, sessionDB, car, valid
		local ignore, lap, rows, hasDNF, result, lapTimes, hasNull, lapTime, min, avg, filteredLapTimes, nr, row

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

			loop %carsCount% {
				car := A_Index
				valid := false

				for ignore, lap in this.getReportLaps(raceData, true)
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
					for ignore, lap in this.getReportLaps(raceData, true) {
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

			loop % carsCount
			{
				car := A_Index

				result := (isNull(positions[lapsCount][car]) ? "DNF" : positions[lapsCount][car])
				lapTimes := []
				hasNull := false

				loop % lapsCount
				{
					lapTime := times[A_Index][car]

					if (!isNull(lapTime) && (lapTime > 0))
						lapTimes.Push(lapTime)
					else if (A_Index == lapsCount)
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

				nr := StrReplace(cars[A_Index][1], """", "")

				rows.Push(Array(nr, "'" . StrReplace(sessionDB.getCarName(simulator, cars[A_Index][2]), "'", "\'") . "'", "'" . StrReplace(drivers[1][A_Index], "'", "\'") . "'"
							  , "'" . this.lapTimeDisplayValue(min) . "'", "'" . this.lapTimeDisplayValue(avg) . "'", result))
			}

			loop % carsCount
			{
				row := rows[A_Index]

				if hasDNF
					row[6] := ("'" . row[6] . "'")

				rows[A_Index] := ("[" . values2String(", ", row*) . "]")
			}

			drawChartFunction .= "`ndata.addColumn('number', '" . translate("#") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Car") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Driver (Start)") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Best Lap Time") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Avg Lap Time") . "');"
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
		local drawChartFunction := "function drawChart() {`nvar data = new google.visualization.DataTable();`n"
		local report := this.Report
		local compound, cars, rows, raceData, pitstops, ignore, lap, weather, consumption, lapTime, pitstop, row

		if report {
			raceData := readConfiguration(report . "\Race.data")

			cars := []
			rows := []

			pitstops := string2Values(",", getConfigurationValue(raceData, "Laps", "Pitstops", ""))

			for ignore, lap in this.getReportLaps(raceData, true) {
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
									, "'" . this.lapTimeDisplayValue(lapTime) . "'"
									, "'" . (pitstop ? translate("x") : "") . "'")

				rows.Push("[" . row	. "]")
			}

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
		local drawChartFunction := "function drawChart() {"
		local report := this.Report
		local raceData, drivers, positions, times, allDrivers, cars, ignore, car, ignore
		local potentials, raceCrafts, speeds, consistencies, carControls

		if report {
			raceData := true
			drivers := true
			positions := true
			times := true

			this.loadReportData(false, raceData, drivers, positions, times)

			allDrivers := this.getReportDrivers(raceData, drivers)

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

			if (potentials && (potentials.Length() > 0)) {
				drawChartFunction .= "`nvar data = google.visualization.arrayToDataTable(["
				drawChartFunction .= "`n['" . values2String("', '", translate("Category"), drivers*) . "'],"

				drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Potential") . "'", potentials*) . "],"
				drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Race Craft") . "'", raceCrafts*) . "],"
				drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Speed") . "'", speeds*) . "],"
				drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Consistency") . "'", consistencies*) . "],"
				drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Car Control") . "'", carControls*) . "]"

				drawChartFunction .= "`n]);"

				drawChartFunction := drawChartFunction . "`nvar options = { bars: 'horizontal', backgroundColor: 'D8D8D8', chartArea: { left: '20%', top: '5%', right: '30%', bottom: '10%' }, hAxis: {gridlines: {count: 0}}, vAxis: {gridlines: {count: 0}} };"
				drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.BarChart(document.getElementById('chart_id')); chart.draw(data, options); }"
			}
			else
				drawChartFunction .= "}"

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

	showPositionsReport() {
		local report := this.Report
		local raceData, drivers, positions, times, cars, carsCount, simulator, sessionDB, carIndices, maxPosition
		local drawChartFunction, car, valid, ignore, lap, hasData, position, lapPositions

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
			carIndices := []
			maxPosition := 0

			loop % carsCount
			{
				car := A_Index
				valid := false

				for ignore, lap in this.getReportLaps(raceData)
					if positions.HasKey(lap)
						if (positions[lap].HasKey(car) && (positions[lap][car] != kNull) && (positions[lap][car] > 0)) {
							valid := true

							maxPosition := Max(maxPosition, positions[lap][car])

							break
						}
						else
							positions[A_Index][car] := kNull ; carsCount

				if valid {
					carIndices.Push(car)

					cars.Push("'#" . getConfigurationValue(raceData, "Cars", "Car." . car . ".Nr") . A_Space
								   . StrReplace(sessionDB.getCarName(simulator, getConfigurationValue(raceData, "Cars", "Car." . car . ".Car")), "'", "\'") . "'")
				}
				else
					for ignore, lap in this.getReportLaps(raceData)
						if positions.HasKey(lap)
							positions[lap].RemoveAt(car)
			}

			drawChartFunction := ("function drawChart() {`nvar data = google.visualization.arrayToDataTable([`n[" . values2String(", ", "'" . translate("Laps") . "'", cars*) . "]")

			hasData := false

			if !this.Settings.HasKey("Laps")
				if (getConfigurationValue(raceData, "Cars", "Car.1.Position", kUndefined) != kUndefined) {
					drawChartFunction .= ",`n[0"

					loop % cars.Length() {
						position := getConfigurationValue(raceData, "Cars", "Car." . carIndices[A_Index] . ".Position", "null")

						if (StrLen(Trim(position)) == 0)
							position := A_Index
						else if (position != "null")
							if position is not number
								position := "null"

						drawChartFunction := (drawChartFunction . ", " . position)
					}

					drawChartFunction .= "]"
				}

			for ignore, lap in this.getReportLaps(raceData) {
				if (positions.Length() >= lap) {
					hasData := true

					drawChartFunction .= (",`n[" . lap)

					lapPositions := positions[lap]

					loop % cars.Length() {
						if lapPositions.HasKey(A_Index)
							drawChartFunction := (drawChartFunction . ", " . lapPositions[A_Index])
						else
							drawChartFunction := (drawChartFunction . ", null")
					}

					drawChartFunction .= "]"
				}
			}

			if hasData {
				drawChartFunction := drawChartFunction . ("]);`nvar options = { legend: { position: 'right' }, chartArea: { left: '5%', top: '5%', right: '20%', bottom: '10%' }, ")
				drawChartFunction := drawChartFunction . ("hAxis: { title: '" . translate("Laps") . "', gridlines: {count: 0} }, vAxis: { viewWindow: {min: 1, max: " . (maxPosition + 1) . "}, direction: -1, ticks: [], title: '" . translate("Cars") . "', baselineColor: 'D0D0D0', gridlines: {count: 0} }, backgroundColor: 'D8D8D8' };`n")

				drawChartFunction := drawChartFunction . "var chart = new google.visualization.LineChart(document.getElementById('chart_id')); chart.draw(data, options); }"
			}
			else
				drawChartFunction := "function drawChart() {}"

			this.showReportChart(drawChartFunction)
			this.showReportInfo(raceData)
		}
		else {
			this.showReportChart(false)
			this.showReportInfo(false)
		}
	}

	editPositionsReportSettings() {
		return this.editReportSettings("Laps")
	}

	showLapTimesReport() {
		local drawChartFunction := "function drawChart() {`nvar data = new google.visualization.DataTable();`n"
		local report := this.Report
		local raceData, drivers, positions, times, selectedCars, laps, driverTimes, ignore, lap, time, lapTimes
		local rows, car

		if report {
			raceData := true
			drivers := true
			positions := false
			times := true

			this.loadReportData(false, raceData, drivers, positions, times)

			selectedCars := this.getReportDrivers(raceData)

			laps := this.getReportLaps(raceData)
			driverTimes := {}

			for ignore, lap in laps {
				lapTimes := []

				for ignore, car in selectedCars
					if times.hasKey(lap) {
						time := (times[lap].HasKey(car) ? times[lap][car] : 0)
						time := (isNull(time) ? 0 : Round(times[lap][car] / 1000, 1))

						if (time > 0)
							lapTimes.Push("'" . this.lapTimeDisplayValue(time) . "'")
						else
							lapTimes.Push(kNull)
					}
					else
						lapTimes.Push(kNull)

				driverTimes[lap] := lapTimes
			}

			rows := []

			for ignore, lap in laps
				rows.Push("[" . values2String(", ", lap, driverTimes[lap]*) . "]")

			drawChartFunction .= "`ndata.addColumn('number', '" . translate("Lap") . "');"

			for ignore, car in selectedCars
				drawChartFunction .= "`ndata.addColumn('string', '#" . getConfigurationValue(raceData, "Cars", "Car." . car . ".Nr") . "');"

			drawChartFunction .= ("`ndata.addRows([" . values2String(", ", rows*) . "]);")

			drawChartFunction .= "`nvar cssClassNames = { headerCell: 'headerStyle', tableCell: 'cellStyle', tableRow: 'rowStyle', oddTableRow: 'oddRowStyle' };"
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

	editLapTimesReportSettings() {
		return this.editReportSettings("Laps", "Cars")
	}

	showConsistencyReport() {
		local drawChartFunction := "function drawChart() {"
		local report := this.Report
		local raceData, drivers, positions, times, selectedCars, laps, driverTimes, allTimes, ignore, lap, lapTimes
		local time, invalidCars, carTimes, avg, cars, offset, singleCar, min, avg, max, window
		local series, title, consistency, delta, car, index

		if report {
			raceData := true
			drivers := true
			positions := false
			times := true

			this.loadReportData(false, raceData, drivers, positions, times)

			selectedCars := this.getReportDrivers(raceData)

			laps := this.getReportLaps(raceData)
			driverTimes := {}

			allTimes := []

			for ignore, lap in laps {
				lapTimes := []

				for ignore, car in selectedCars
					if times.hasKey(lap) {
						time := (times[lap].HasKey(car) ? times[lap][car] : 0)
						time := (isNull(time) ? 0 : Round(times[lap][car] / 1000, 1))

						if (time > 0) {
							allTimes.Push(time)
							lapTimes.Push(time)
						}
						else
							lapTimes.Push(kNull)
					}
					else
						lapTimes.Push(kNull)

				driverTimes[lap] := lapTimes
			}

			invalidCars := []

			for index, car in selectedCars {
				carTimes := []

				for ignore, lap in laps {
					time := drivertimes[lap][car]

					if (time != kNull)
						carTimes.Push(time)
				}

				if (carTimes.Length() == 0)
					invalidCars.Push(car)
				else {
					avg := average(carTimes)

					for ignore, lap in laps
						if (drivertimes[lap][car] = kNull)
							drivertimes[lap][car] := avg
				}
			}

			drawChartFunction .= "`nvar data = google.visualization.arrayToDataTable(["

			cars := []

			offset := 0

			for index, car in selectedCars
				if inList(invalidCars, car) {
					for ignore, lap in laps
						driverTimes[lap].RemoveAt(index - offset)

					offset += 1
				}
				else
					cars.Push("#" . getConfigurationValue(raceData, "Cars", "Car." . car . ".Nr"))

			singleCar := (cars.Length() = 1)

			if singleCar {
				cars.Push(translate("Max"))
				cars.Push(translate("Avg"))
				cars.Push(translate("Min"))

				carTimes := []

				for ignore, lap in laps {
					time := driverTimes[lap][1]

					if time is number
						carTimes.Push(time)
				}

				min := minimum(carTimes)
				avg := average(carTimes)
				max := maximum(carTimes)

				for ignore, lap in laps {
					driverTimes[lap].Push(max)
					driverTimes[lap].Push(avg)
					driverTimes[lap].Push(min)
				}
			}
			else {
				min := minimum(allTimes)
				avg := average(allTimes)
				max := maximum(allTimes)
			}

			drawChartFunction .= "`n['" . values2String("', '", translate("Lap"), cars*) . "']"

			for ignore, lap in laps
				drawChartFunction .= ",`n[" . lap . ", " . values2String(", ", driverTimes[lap]*) . "]"

			drawChartFunction .= ("`n]);")

			delta := (max - min)

			min := Max(avg - (3 * delta), 0)
			max := Min(avg + (2 * delta), max)

			window := window := ("baseline: " . min . ", viewWindow: {min: " . min . ", max: " . max . "}, ")
			series := ""
			title := ""

			if singleCar {
				consistency := 0

				for ignore, time in allTimes
					consistency += (100 - Abs(avg - time))

				consistency := Round(consistency / allTimes.Length(), 2)

				series := ", series: {1: {type: 'line'}, 2: {type: 'line'}, 3: {type: 'line'}}"

				title := ("title: '" . translate("Consistency: ") . consistency . translate(" %") . "', titleTextStyle: {bold: false}, ")
			}

			drawChartFunction .= ("`nvar options = {" . title . "seriesType: 'bars'" . series . ", backgroundColor: '#D8D8D8', vAxis: {" . window . "title: '" . translate("Lap Time") . "', gridlines: {count: 0}}, hAxis: {title: '" . translate("Laps") . "', gridlines: {count: 0}}, chartArea: { left: '10%', top: '15%', right: '15%', bottom: '15%' } };")

			drawChartFunction .= ("`nvar chart = new google.visualization.ComboChart(document.getElementById('chart_id')); chart.draw(data, options); }")

			this.showReportChart(drawChartFunction)
			this.showReportInfo(raceData)
		}
		else {
			this.showReportChart(false)
			this.showReportInfo(false)
		}
	}

	editConsistencyReportSettings() {
		return this.editReportSettings("Laps", "Cars")
	}

	showPaceReport() {
		local drawChartFunction := "function drawChart() {`nvar array = [`n"
		local report := this.Report
		local raceData, drivers, positions, times, selectedCars, cars, laps, lapTimes, driverTimes, length
		local ignore, car, carTimes, index, dIndex, time, text

		if report {
			raceData := true
			drivers := false
			positions := false
			times := true

			this.loadReportData(false, raceData, drivers, positions, times)

			selectedCars := this.getReportDrivers(raceData)
			cars := []

			laps := this.getReportLaps(raceData)
			lapTimes := []

			driverTimes := {}
			length := 20000

			for ignore, car in selectedCars {
				carTimes := this.getDriverTimes(raceData, times, car)

				if (carTimes.Length() > 0) {
					length := Min(length, carTimes.Length())

					driverTimes[car] := carTimes
				}
			}

			if (length == 20000)
				length := false

			for index, car in selectedCars {
				if driverTimes.HasKey(car) {
					carTimes := Array("'#" . getConfigurationValue(raceData, "Cars", "Car." . car . ".Nr") . "'")

					for dIndex, time in driverTimes[car]
						if (dIndex > length)
							break
						else
							carTimes.Push(time)

					lapTimes.Push("[" . values2String(", ", carTimes*) . "]")
				}
			}

			drawChartFunction .= (values2String("`n, ", lapTimes*) . "];")

			drawChartFunction .= "`nvar data = new google.visualization.DataTable();"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Car") . "');"

			loop % Min(length, laps.Length())
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

			drawChartFunction .= ("`n" . "data.addRows(getBoxPlotValues(array, " . (Min(length, laps.Length()) + 1) . "));")

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
				hAxis: { title: '`%cars`%', gridlines: {count: 0} },
				vAxis: { title: '`%seconds`%', gridlines: {count: 0} },
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
		return this.editReportSettings("Laps", "Cars")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

getPaceJSFunctions() {
	local script

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

global rangeLapsEdit
global driverSelectCheck

editReportSettings(raceReport, report := false, options := false) {
	local x, y, raceData, drivers, laps, oldEncoding, owner
	local lapsDef, laps, baseLap, lastLap, ignore, lap, yOption, headers, allDrivers, selectedDrivers
	local sessionDB, simulator, ignore, driver, column1, column2, startLap, endLap, lap, index
	local newLaps, newDrivers, rowNumber

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
			loop Read, % report . "\Drivers.CSV"
				drivers.Push(string2Values(";", A_LoopReadLine))

			drivers := correctEmptyValues(drivers)

			loop Read, % report . "\Laps.CSV"
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

		Gui RRS:Add, Text, w351 Center gmoveSettings, % translate("Modular Simulator Controller System")

		Gui RRS:Font, s9 Norm, Arial
		Gui RRS:Font, Italic Underline, Arial

		Gui RRS:Add, Text, x136 YP+20 w104 cBlue Center gopenReportSettingsDocumentation, % translate("Report Settings")

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

		if (inList(options, "Drivers") || inList(options, "Cars")) {
			yOption := (inList(options, "Laps") ? "yp+30" : "yp+10") + 2

			Gui RRS:Add, Text, x16 %yOption% w70 h23 +0x200 Section, % translate(inList(options, "Cars") ? "Cars" : "Drivers")

			headers := (inList(options, "Drivers") ? ["     Driver (Start)", "Car"] : ["     #", "Car"])

			Gui RRS:Add, ListView, x90 yp-2 w264 h300 AltSubmit -Multi -LV0x10 Checked NoSort NoSortHdr gselectDriver, % values2String("|", map(headers, "translate")*)

			Gui RRS:Add, CheckBox, Check3 x72 yp+2 w15 h23 vdriverSelectCheck gselectDrivers

			allDrivers := raceReport.getReportDrivers(raceData, drivers)
			selectedDrivers := []

			if raceReport.Settings.HasKey("Drivers")
				selectedDrivers := raceReport.Settings["Drivers"]
			else
				loop % allDrivers.Length()
					selectedDrivers.Push(A_Index)

			sessionDB := new SessionDatabase()
			simulator := getConfigurationValue(raceData, "Session", "Simulator")

			for ignore, driver in allDrivers {
				if inList(options, "Cars")
					column1 := getConfigurationValue(raceData, "Cars", "Car." . A_Index . ".Nr")
				else
					column1 := driver

				column2 := sessionDB.getCarName(simulator, getConfigurationValue(raceData, "Cars", "Car." . A_Index . ".Car"))

				LV_Add(inList(selectedDrivers, A_Index) ? "Check" : "", column1, column2)
			}

			if (!selectedDrivers || (selectedDrivers.Length() == allDrivers.Length()))
				GuiControl, , driverSelectCheck, 1
			else if ((selectedDrivers.Length() > 0) && (selectedDrivers.Length() != allDrivers.Length()))
				GuiControl, , driverSelectCheck, -1
			else
				GuiControl, , driverSelectCheck, 0

			if inList(options, "Cars")
				LV_ModifyCol(1, "AutoHdr Right")
			else
				LV_ModifyCol(1, "AutoHdr")

			LV_ModifyCol(2, "AutoHdr")
		}

		Gui RRS:Font, s8 Norm, Arial

		yOption := ((inList(options, "Drivers") || inList(options, "Cars")) ? "yp+306" : "yp+30")

		Gui RRS:Add, Text, x8 %yOption% w360 0x10

		Gui RRS:Add, Button, x108 yp+10 w80 h23 Default GacceptSettings, % translate("Ok")
		Gui RRS:Add, Button, x196 yp w80 h23 GcancelSettings, % translate("&Cancel")

		if getWindowPosition("Race Reports.Settings", x, y)
			Gui RRS:Show, x%x% y%y%
		else
			Gui RRS:Show

		Gui RRS:Show

		loop
			Sleep 100
		until result

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
										loop {
											index := startLap + A_Index - 1

											laps[index] := index
										} until (index = endLap)
						}
						else if lap is Integer
							if laps.HasKey(lap)
								laps[lap] := lap

					newlaps := []

					for lap, ignore in laps
						newLaps.Push(lap)

					result["Laps"] := newLaps
				}
			}

			if (inList(options, "Drivers") || inList(options, "Cars")) {
				newDrivers := []

				rowNumber := 0

				loop {
					rowNumber := LV_GetNext(rowNumber, "C")

					if !rowNumber
						break
					else
						newDrivers.Push(rowNumber)
				}

				result["Drivers"] := newDrivers
				result["Cars"] := newDrivers
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
	local selected := 0
	local row := 0

	loop {
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

	loop % LV_GetCount()
		LV_Modify(A_Index, driverSelectCheck ? "Check" : "-Check")
}

moveSettings() {
	moveByMouse("RRS", "Race Reports.Settings")
}

openReportSettingsDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#race-reports
}