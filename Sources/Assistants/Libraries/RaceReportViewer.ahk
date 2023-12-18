;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Report Viewer              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\HTMLViewer.ahk"
#Include "..\..\Libraries\Math.ahk"
#Include "..\..\Database\Libraries\SessionDatabase.ahk"
#Include "RaceReportReader.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kRaceReports := ["Overview", "Car", "Drivers", "Positions", "Lap Times", "Performance", "Consistency", "Pace"]


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

	iSettings := CaseInsenseMap()

	Window {
		Get {
			return this.iWindow
		}
	}

	ChartViewer {
		Get {
			return this.iChartViewer
		}
	}

	InfoViewer {
		Get {
			return this.iInfoViewer
		}
	}

	Settings[key?] {
		Get {
			return (isSet(key) ? this.iSettings[key] : this.iSettings)
		}

		Set {
			return (isSet(key) ? (this.iSettings[key] := value) : (this.iSettings := value))
		}
	}

	__New(window, chartViewer := false, infoViewer := false) {
		super.__New()

		this.iWindow := window
		this.iChartViewer := chartViewer
		this.iInfoViewer := infoViewer
	}

	static lapTimeDisplayValue(lapTime) {
		local seconds, fraction, minutes

		if isNumber(lapTime)
			return displayValue("Time", lapTime)
		else
			return lapTime
	}

	showReportChart(drawChartFunction, margin := 0) {
		local window, before, after, html

		if this.ChartViewer {
			this.ChartViewer.document.open()

			if (drawChartFunction && (drawChartFunction != "")) {
				before := "
				(
				<html>
					<meta charset='utf-8'>
					<head>
						<style>
							.headerStyle { height: 25; font-size: 11px; font-weight: 500; background-color: #%headerBackColor%; }
							.cellStyle { text-align: right; }
							.rowStyle { font-size: 11px; background-color: #%evenRowBackColor%; }
							.oddRowStyle { font-size: 11px; background-color: #%oddRowBackColor%; }
						</style>
						<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
						<script type="text/javascript">
							google.charts.load('current', {'packages':['corechart', 'bar', 'table']}).then(drawChart);
				)"

				before := substituteVariables(before, {headerBackColor: this.Window.Theme.ListBackColor["Header"]
													 , evenRowBackColor: this.Window.Theme.ListBackColor["EvenRow"]
													 , oddRowBackColor: this.Window.Theme.ListBackColor["OddRow"]})

				after := "
				(
						</script>
					</head>
					<body style='background-color: #%backColor%' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>
						<div id="chart_id" style="width: %width%px; height: %height%px"></div>
					</body>
				</html>
				)"

				html := (before . drawChartFunction . substituteVariables(after, {width: this.ChartViewer.getWidth() - 2 - margin
																				, height: this.ChartViewer.getHeight() - 2 - margin
																				, backColor: this.Window.AltBackColor}))

				this.ChartViewer.document.write(html)
			}
			else {
				html := "<html><body style='background-color: #%backColor%' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"

				this.ChartViewer.document.write(substituteVariables(html, {backColor: this.Window.AltBackColor}))
			}

			this.ChartViewer.document.close()
		}
	}

	showReportInfo(raceData) {
		local window, infoText, conditions, descriptor, info, html

		if this.InfoViewer {
			this.InfoViewer.document.open()

			if raceData {
				infoText := "<table>"
				infoText .= ("<tr><td>" . translate("Duration: ") . "</td><td>" . Round(getMultiMapValue(raceData, "Session", "Duration") / 60) . translate(" Minutes") . "</td></tr>")
				infoText .= ("<tr><td>" . translate("Format: ") . "</td><td>" . translate((getMultiMapValue(raceData, "Session", "Format") = "Time") ? "Duration" : "Laps") . "</td></tr>")
				infoText .= "<tr/>"
				infoText .= ("<tr><td>" . translate("# Cars: ") . "</td><td>" . getMultiMapValue(raceData, "Cars", "Count") . "</td></tr>")
				infoText .= ("<tr><td>" . translate("# Laps: ") . "</td><td>" . getMultiMapValue(raceData, "Laps", "Count") . "</td></tr>")
				infoText .= "<tr/>"
				infoText .= ("<tr><td>" . translate("My Car: ") . "</td><td>" . translate("#") . getMultiMapValue(raceData, "Cars", "Car." . getMultiMapValue(raceData, "Cars", "Driver") . ".Nr") . "</td></tr>")
				infoText .= "<tr/>"

				conditions := CaseInsenseMap()

				for descriptor, info in getMultiMapValues(raceData, "Laps") {
					descriptor := ConfigurationItem.splitDescriptor(descriptor)

					if ((descriptor.Length > 2) && (descriptor[3] = "Weather"))
						conditions[info] := info
				}

				infoText .= ("<tr><td>" . translate("Conditions: ") . "</td><td>" . values2String(", ", collect(conditions, translate)*) . "</td></tr>")
				infoText .= "</table>"

				infoText := "<html><body style='background-color: #%backColor%' style='overflow: auto' leftmargin='3' topmargin='3' rightmargin='3' bottommargin='3'><style> table, p { font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><p>" . infoText . "</p></body></html>"

				this.InfoViewer.document.write(substituteVariables(infoText, {backColor: this.Window.AltBackColor}))
			}
			else {
				html := "<html><body style='background-color: #%backColor%' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"

				this.InfoViewer.document.write(substituteVariables(html, {backColor: this.Window.AltBackColor}))
			}

			this.InfoViewer.document.close()
		}
	}

	getLaps(raceData, alwaysAll := false) {
		if (!alwaysAll && this.Settings.Has("Laps"))
			return this.Settings["Laps"]
		else
			return super.getLaps(raceData)
	}

	getClass(raceData, car, categories?) {
		if isSet(categories)
			return super.getClass(raceData, car, categories)
		else if this.Settings.Has("CarCategories")
			return super.getClass(raceData, car, this.Settings["CarCategories"])
		else
			return super.getClass(raceData, car)
	}

	getClasses(raceData, alwaysAll := false, categories?) {
		if (!alwaysAll && this.Settings.Has("Classes"))
			return this.Settings["Classes"]
		else
			return super.getClasses(raceData, categories?)
	}

	getDrivers(raceData) {
		if this.Settings.Has("Drivers")
			return this.Settings["Drivers"]
		else
			return super.getDrivers(raceData)
	}

	getReportLaps(raceData, alwaysAll := false) {
		return this.getLaps(raceData, alwaysAll)
	}

	getReportClasses(raceData, alwaysAll := false, categories?) {
		return this.getClasses(raceData, alwaysAll, categories?)
	}

	getReportCars(raceData) {
		return this.getDrivers(raceData)
	}

	getReportDrivers(raceData, drivers, &categories := false) {
		local resultDrivers := []
		local resultCategories := []
		local driver, category

		loop getMultiMapValue(raceData, "Cars", "Count")
			if (getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Car", kNotInitialized) != kNotInitialized)
				if drivers[1].Has(A_Index) {
					resultDrivers.Push(drivers[1][A_Index])

					if categories
						resultCategories.Push(categories[1][A_Index])
				}

		if categories
			categories := resultCategories

		return resultDrivers
	}

	loadReportData(laps, &raceData, &drivers, &positions, &times, &categories := false) {
		return this.loadData(laps, &raceData, &drivers, &positions, &times, &categories)
	}

	editReportSettings(settings*) {
		local result := editReportSettings(this, this.Report, settings)
		local setting, values

		if result {
			for setting, values in result
				if ((setting = "Laps") && (values == true)) {
					if this.Settings.Has("Laps")
						this.Settings.Delete("Laps")
				}
				else
					this.Settings[setting] := values

			if (!result.Has("Classes") && this.Settings.Has("Classes"))
				this.Settings.Delete("Classes")

			if (!result.Has("Categories") && this.Settings.Has("Categories"))
				this.Settings.Delete("Categories")
		}

		return (result != false)
	}

	showOverviewReport() {
		local drawChartFunction := "function drawChart() {`nvar data = new google.visualization.DataTable();`n"
		local report := this.Report
		local classes := CaseInsenseMap()
		local invalids := 0
		local raceData, drivers, categories, driver, category, positions, times, cars, carsCount, lapsCount, simulator, car
		local class, hasClasses, classResults, valid, carClasses
		local ignore, lap, rows, rowClasses, classRows, hasDNF, hasAlphaNr, result, lapTimes, hasNull, lapTime
		local min, avg, filteredLapTimes, nr, row, settings

		comparePositions(c1, c2) {
			local pos1 := c1[2]
			local pos2 := c2[2]

			if !isNumber(pos1)
				pos1 := 999

			if !isNumber(pos2)
				pos2 := 999

			return (pos1 > pos2)
		}

		if report {
			raceData := true
			drivers := true
			categories := (this.Settings.Has("DriverCategories") && this.Settings["DriverCategories"])
			positions := true
			times := true

			this.loadReportData(false, &raceData, &drivers, &positions, &times, &categories)

			cars := []

			carsCount := getMultiMapValue(raceData, "Cars", "Count")
			lapsCount := getMultiMapValue(raceData, "Laps", "Count")
			simulator := getMultiMapValue(raceData, "Session", "Simulator")

			loop carsCount {
				car := A_Index
				valid := false

				for ignore, lap in this.getReportLaps(raceData, true)
					if (positions.Length >= lap) {
						if (positions[lap].Has(car) && isNumber(positions[lap][car]) && (positions[lap][car] > 0))
							valid := true
						else if positions[lap].Has(car)
							positions[lap][car] := kNull ; carsCount
					}
					else
						valid := false

				if valid
					cars.Push(Array(getMultiMapValue(raceData, "Cars", "Car." . car . ".Nr"), getMultiMapValue(raceData, "Cars", "Car." . car . ".Car")))
				else
					for ignore, lap in this.getReportLaps(raceData, true) {
						if (drivers.Length >= lap) {
							if drivers[lap].Has(car)
								drivers[lap].RemoveAt(car)

							if positions[lap].Has(car)
								positions[lap].RemoveAt(car)

							if times[lap].Has(car)
								times[lap].RemoveAt(car)
						}
					}
			}

			carClasses := this.getReportClasses(raceData)
			carsCount := cars.Length

			rows := []
			rowClasses := []
			hasDNF := false
			hasAlphaNr := false

			loop carsCount
				hasAlphaNr := (hasAlphaNr || !isNumber(cars[A_Index][1]))

			loop carsCount {
				car := A_Index
				class := this.getClass(raceData, car)

				if positions[lapsCount].Has(car)
					result := (extendedIsNull(positions[lapsCount][car]) ? "DNF" : positions[lapsCount][car])
				else
					result := "DNF"

				lapTimes := []
				hasNull := false

				loop lapsCount {
					lapTime := (times[A_Index].Has(car) ? times[A_Index][car] : 0)

					if (!extendedIsNull(lapTime, A_Index < 2) && (lapTime > 0))
						lapTimes.Push(lapTime)
					else {
						if (A_Index == lapsCount)
							result := "DNF"
					}
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

				nr := cars[A_Index][1]

				if (getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Car", kNotInitialized) != kNotInitialized) {
					if !classes.Has(class)
						classes[class] := [Array(A_Index, result)]
					else
						classes[class].Push(Array(A_Index, result))

					driver := StrReplace(drivers[1][A_Index], "'", "\'")

					if (categories && (categories[1][A_Index] != "Unknown"))
						driver .= (translate(" [") . translate(categories[1][A_Index]) . translate("]"))

					rows.Push(Array("'" . class . "'", (hasAlphaNr ? ("'" . nr . "'") : nr)
								  , "'" . StrReplace(SessionDatabase.getCarName(simulator, cars[A_Index][2]), "'", "\'") . "'", "'" . driver . "'"
								  , "'" . RaceReportViewer.lapTimeDisplayValue(min) . "'"
								  , "'" . RaceReportViewer.lapTimeDisplayValue(avg) . "'", result, result))

					rowClasses.Push(class)
				}
				else
					invalids += 1
			}

			settings := (this.Settings.Has("CarCategories") ? this.Settings["CarCategories"] : false)

			if settings
				hasClasses := ((classes.Count > 1) || (this.getReportClasses(raceData, true, settings).Length > 1))
			else
				hasClasses := ((classes.Count > 1) || (this.getReportClasses(raceData, true).Length > 1))

			if hasClasses {
				classResults := CaseInsenseMap()

				for ignore, class in classes {
					bubbleSort(&class, comparePositions)

					for ignore, car in class {
						result := car[2]

						classResults[car[1]] := ((result = "DNF") ? result : A_Index)
					}
				}
			}

			classRows := []

			loop carsCount - invalids {
				if inList(carClasses, rowClasses[A_Index]) {
					row := rows[A_Index]

					if hasClasses
						row[8] := classResults[A_Index]

					if hasDNF {
						row[7] := ("'" . row[7] . "'")
						row[8] := ("'" . row[8] . "'")
					}

					if !hasClasses {
						row.RemoveAt(1)
						row.RemoveAt(row.Length)
					}

					classRows.Push("[" . values2String(", ", row*) . "]")
				}
			}

			rows := classRows

			if hasClasses
				drawChartFunction .= "`ndata.addColumn('string', '" . translate("Class") . "');"

			drawChartFunction .= "`ndata.addColumn('" . (hasAlphaNr ? "string" : "number") . "', '" . translate("#") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Car") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Driver (Start)") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Best Lap Time") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Avg Lap Time") . "');"
			drawChartFunction .= "`ndata.addColumn('" . (hasDNF ? "string" : "number") . "', '" . translate(hasClasses ? "Result (Overall)" : "Result") . "');"

			if hasClasses
				drawChartFunction .= "`ndata.addColumn('" . (hasDNF ? "string" : "number") . "', '" . translate("Result (Class)") . "');"

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

	editOverviewReportSettings() {
		return this.editReportSettings("Classes")
	}

	showCarReport() {
		local drawChartFunction := "function drawChart() {`nvar data = new google.visualization.DataTable();`n"
		local report := this.Report
		local tyreCompound, cars, rows, raceData, pitstops, ignore, lap, weather, consumption, lapTime, pitstop, row, lapState

		if report {
			raceData := readMultiMap(report . "\Race.data")

			cars := []
			rows := []

			pitstops := string2Values(",", getMultiMapValue(raceData, "Laps", "Pitstops", ""))

			for ignore, lap in this.getReportLaps(raceData, true) {
				weather := getMultiMapValue(raceData, "Laps", "Lap." . lap . ".Weather", kUndefined)

				if (weather != kUndefined) {
					weather := (weather ? translate(weather) : "n/a")

					if getMultiMapValue(raceData, "Laps", "Lap." . lap . ".Compound", false)
						tyreCompound := translate(compound(getMultiMapValue(raceData, "Laps", "Lap." . lap . ".Compound", "Dry")
														 , getMultiMapValue(raceData, "Laps", "Lap." . lap . ".CompoundColor", "Black")))
					else
						tyreCompound := "-"

					consumption := getMultiMapValue(raceData, "Laps", "Lap." . lap . ".Consumption", translate("n/a"))

					if (consumption == 0)
						consumption := translate("n/a")

					if isNumber(consumption)
						consumption := displayValue("Float", convertUnit("Volume", consumption))

					lapTime := getMultiMapValue(raceData, "Laps", "Lap." . lap . ".LapTime", "-")

					if (lapTime != "-")
						lapTime := Round(lapTime / 1000, 1)

					lapState := getMultiMapValue(raceData, "Laps", "Lap." . lap . ".State", "Valid")

					pitstop := ((pitstops.Length > 0) ? inList(pitstops, lap - 1) : (getMultiMapValue(raceData, "Laps", "Lap." . (lap - 1) . ".Pitstop", false)))

					row := values2String(", ", lap
											 , "'" . weather . "'"
											 , "'" . tyreCompound . "'"
											 , "'" . getMultiMapValue(raceData, "Laps", "Lap." . lap . ".Map", translate("n/a")) . "'"
											 , "'" . getMultiMapValue(raceData, "Laps", "Lap." . lap . ".TC", translate("n/a")) . "'"
											 , "'" . getMultiMapValue(raceData, "Laps", "Lap." . lap . ".ABS", translate("n/a")) . "'"
											 , "'" . consumption . "'"
											 , "'" . RaceReportViewer.lapTimeDisplayValue(lapTime) . "'"
											 , "'" . ((lapState != "Invalid") ? "" : translate("x")) . "'"
											 , "'" . (pitstop ? translate("x") : "") . "'")

					rows.Push("[" . row	. "]")
				}
			}

			drawChartFunction .= "`ndata.addColumn('number', '" . translate("#") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Weather") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Tyres") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Map") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("TC") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("ABS") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Consumption") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Lap Time") . "');"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Invalid") . "');"
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
		local raceData, drivers, categories, driver, category, positions, times, allDrivers, cars, ignore, car, ignore
		local potentials, raceCrafts, speeds, consistencies, carControls, classes

		if report {
			raceData := true
			drivers := true
			categories := (this.Settings.Has("DriverCategories") && this.Settings["DriverCategories"])
			positions := true
			times := true

			this.loadReportData(false, &raceData, &drivers, &positions, &times, &categories)

			classes := this.getReportClasses(raceData)

			allDrivers := this.getReportDrivers(raceData, drivers, &categories)

			cars := []

			for ignore, car in this.Settings["Drivers"]
				if (allDrivers.Has(car) && inList(classes, this.getClass(raceData, car)))
					cars.Push(car)

			drivers := []

			for ignore, car in cars {
				driver := StrReplace(allDrivers[car], "'", "\'")

				if categories {
					category := categories[car]

					if (category != "Unknown")
						driver .= (translate(" [") . translate(category) . translate("]"))
				}

				drivers.Push(driver)
			}

			potentials := false
			raceCrafts := false
			speeds := false
			consistencies := false
			carControls := false

			this.getDriverStatistics(raceData, cars, positions, times, &potentials, &raceCrafts, &speeds, &consistencies, &carControls)

			if (potentials && (potentials.Length > 0)) {
				drawChartFunction .= "`nvar data = google.visualization.arrayToDataTable(["
				drawChartFunction .= "`n['" . values2String("', '", translate("Category"), drivers*) . "'],"

				drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Potential") . "'", potentials*) . "],"
				drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Race Craft") . "'", raceCrafts*) . "],"
				drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Speed") . "'", speeds*) . "],"
				drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Consistency") . "'", consistencies*) . "],"
				drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Car Control") . "'", carControls*) . "]"

				drawChartFunction .= "`n]);"

				drawChartFunction := drawChartFunction . "`nvar options = { bars: 'horizontal', backgroundColor: '" . this.Window.AltBackColor . "', chartArea: { left: '20%', top: '5%', right: '30%', bottom: '10%' }, hAxis: {gridlines: {count: 0}}, vAxis: {gridlines: {count: 0}} };"
				drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.BarChart(document.getElementById('chart_id')); chart.draw(data, options); }"
			}
			else
				drawChartFunction .= "}"

			this.showReportChart(drawChartFunction, 10)
			this.showReportInfo(raceData)
		}
		else {
			this.showReportChart(false)
			this.showReportInfo(false)
		}
	}

	editDriverReportSettings() {
		return this.editReportSettings("Laps", "Drivers", "Classes")
	}

	showPositionsReport() {
		local report := this.Report
		local raceData, drivers, positions, times, cars, carsCount, simulator
		local carIndices, minPosition, maxPosition, newMinPosition, newMaxPosition
		local drawChartFunction, car, valid, ignore, lap, hasData, position, lapPositions, selectedClasses

		if report {
			raceData := true
			drivers := false
			positions := true
			times := true

			this.loadReportData(false, &raceData, &drivers, &positions, &times)

			cars := []

			carsCount := getMultiMapValue(raceData, "Cars", "Count")
			simulator := getMultiMapValue(raceData, "Session", "Simulator")

			carIndices := []
			minPosition := 9999
			maxPosition := 0

			selectedClasses := this.getReportClasses(raceData)

			loop carsCount {
				car := A_Index

				if inList(selectedClasses, this.getClass(raceData, A_Index)) {
					valid := false

					newMinPosition := minPosition
					newMaxPosition := maxPosition

					for ignore, lap in this.getReportLaps(raceData)
						if (positions.Has(lap) && times.Has(lap) && positions[lap].Has(car))
							if (!extendedIsNull(positions[lap][car]) && (positions[lap][car] > 0)
							 && times[lap].Has(car) && !extendedIsNull(times[lap][car], lap < 2)) {
								valid := true

								newMinPosition := Min(newMinPosition, positions[lap][car])
								newMaxPosition := Max(newMaxPosition, positions[lap][car])

								; break
							}
							else
								positions[lap][car] := kNull ; carsCount

					if valid {
						minPosition := newMinPosition
						maxPosition := newMaxPosition

						carIndices.Push(car)

						cars.Push("'#" . getMultiMapValue(raceData, "Cars", "Car." . car . ".Nr") . A_Space
									   . StrReplace(SessionDatabase.getCarName(simulator, getMultiMapValue(raceData, "Cars", "Car." . car . ".Car")), "'", "\'") . "'")
					}
				}
			}

			for ignore, lap in this.getReportLaps(raceData)
				loop carsCount {
					car := (carsCount - A_Index + 1)

					if (!inList(carIndices, car) && positions.Has(lap) && positions[lap].Has(car))
						positions[lap].RemoveAt(car)
				}

			drawChartFunction := ("function drawChart() {`nvar data = google.visualization.arrayToDataTable([`n[" . values2String(", ", "'" . translate("Laps") . "'", cars*) . "]")

			hasData := false

			if !this.Settings.Has("Laps")
				if (getMultiMapValue(raceData, "Cars", "Car.1.Position", kUndefined) != kUndefined) {
					drawChartFunction .= ",`n[0"

					loop cars.Length {
						position := getMultiMapValue(raceData, "Cars", "Car." . carIndices[A_Index] . ".Position", "null")

						if (StrLen(Trim(position)) == 0)
							position := A_Index
						else if (position != "null")
							if !isNumber(position)
								position := "null"

						drawChartFunction := (drawChartFunction . ", " . position)
					}

					drawChartFunction .= "]"
				}

			for ignore, lap in this.getReportLaps(raceData) {
				if (positions.Length >= lap) {
					hasData := true

					drawChartFunction .= (",`n[" . lap)

					lapPositions := positions[lap]

					loop cars.Length {
						if (lapPositions.Has(A_Index) && !extendedIsNull(lapPositions[A_Index], lap < 2))
							drawChartFunction := (drawChartFunction . ", " . lapPositions[A_Index])
						else
							drawChartFunction := (drawChartFunction . ", null")
					}

					drawChartFunction .= "]"
				}
			}

			if hasData {
				drawChartFunction := drawChartFunction . ("]);`nvar options = { legend: { position: 'right' }, chartArea: { left: '5%', top: '5%', right: '20%', bottom: '10%' }, ")
				drawChartFunction := drawChartFunction . ("hAxis: { title: '" . translate("Laps") . "', gridlines: {count: 0} }, vAxis: { viewWindow: {min: " . (minPosition - 1) . ", max: " . (maxPosition + 1) . "}, direction: -1, ticks: [], title: '" . translate("Cars") . "', baselineColor: 'D0D0D0', gridlines: {count: 0} }, backgroundColor: '" . this.Window.AltBackColor . "' };`n")

				drawChartFunction := drawChartFunction . "var chart = new google.visualization.LineChart(document.getElementById('chart_id')); chart.draw(data, options); }"
			}
			else
				drawChartFunction := "function drawChart() {}"

			this.showReportChart(drawChartFunction, 10)
			this.showReportInfo(raceData)
		}
		else {
			this.showReportChart(false)
			this.showReportInfo(false)
		}
	}

	editPositionsReportSettings() {
		return this.editReportSettings("Laps", "Classes")
	}

	showLapTimesReport() {
		local drawChartFunction := "function drawChart() {`nvar data = new google.visualization.DataTable();`n"
		local report := this.Report
		local raceData, drivers, positions, times, selectedCars, laps, driverTimes, ignore, lap, time, lapTimes
		local rows, car, selectedClasses

		if report {
			raceData := true
			drivers := false
			positions := false
			times := true

			this.loadReportData(false, &raceData, &drivers, &positions, &times)

			selectedClasses := this.getReportClasses(raceData)
			selectedCars := this.getReportCars(raceData)

			laps := this.getReportLaps(raceData)
			driverTimes := CaseInsenseMap()

			for ignore, lap in laps {
				lapTimes := []

				for ignore, car in selectedCars
					if inList(selectedClasses, this.getClass(raceData, car))
						if times.Has(lap) {
							time := (times[lap].Has(car) ? times[lap][car] : 0)
							time := (extendedIsNull(time) ? 0 : Round(time / 1000, 1))

							if (time > 0)
								lapTimes.Push("'" . RaceReportViewer.lapTimeDisplayValue(time) . "'")
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
				drawChartFunction .= "`ndata.addColumn('string', '#" . getMultiMapValue(raceData, "Cars", "Car." . car . ".Nr") . "');"

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
		return this.editReportSettings("Laps", "Cars", "Classes")
	}

	showConsistencyReport() {
		local drawChartFunction := "function drawChart() {"
		local report := this.Report
		local raceData, drivers, positions, times, selectedCars, laps, driverTimes, allTimes, ignore, lap, lapTimes
		local time, invalidCars, carTimes, avg, cars, offset, singleCar, theMin, theAvg, theMax, window
		local series, title, consistency, delta, car, index, selectedClasses

		if report {
			raceData := true
			drivers := false
			positions := false
			times := true

			this.loadReportData(false, &raceData, &drivers, &positions, &times)

			selectedClasses := this.getReportClasses(raceData)
			selectedCars := this.getReportCars(raceData)

			laps := this.getReportLaps(raceData)
			driverTimes := CaseInsenseMap()

			allTimes := []

			for ignore, lap in laps {
				lapTimes := []

				for ignore, car in selectedCars
					if inList(selectedClasses, this.getClass(raceData, car))
						if times.Has(lap) {
							time := (times[lap].Has(car) ? times[lap][car] : 0)
							time := (extendedIsNull(time) ? 0 : Round(time / 1000, 1))

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
					if (driverTimes.Has(lap) && times.Has(lap)) {
						time := (times[lap].Has(car) ? times[lap][car] : 0)

						if !extendedIsNull(time)
							carTimes.Push(time)
					}
				}

				if (carTimes.Length == 0)
					invalidCars.Push(car)
				else {
					theAvg := average(carTimes)

					for ignore, lap in laps
						if (driverTimes.Has(lap) && driverTimes[lap].Has(car))
							if (driverTimes[lap][car] = kNull)
								driverTimes[lap][car] := theAvg
				}
			}

			drawChartFunction .= "`nvar data = google.visualization.arrayToDataTable(["

			cars := []

			offset := 0

			for index, car in selectedCars
				if inList(selectedClasses, this.getClass(raceData, car))
					if inList(invalidCars, car) {
						for ignore, lap in laps
							driverTimes[lap].RemoveAt(index - offset)

						offset += 1
					}
					else
						cars.Push("#" . getMultiMapValue(raceData, "Cars", "Car." . car . ".Nr"))

			singleCar := (cars.Length = 1)

			if singleCar {
				cars.Push(translate("Max"))
				cars.Push(translate("Avg"))
				cars.Push(translate("Min"))

				carTimes := []

				for ignore, lap in laps {
					time := driverTimes[lap][1]

					if isNumber(time)
						carTimes.Push(time)
				}

				theMin := minimum(carTimes)
				theAvg := average(carTimes)
				theMax := maximum(carTimes)

				for ignore, lap in laps {
					driverTimes[lap].Push(theMax)
					driverTimes[lap].Push(theAvg)
					driverTimes[lap].Push(theMin)
				}
			}
			else {
				theMin := minimum(allTimes)
				theAvg := average(allTimes)
				theMax := maximum(allTimes)
			}

			drawChartFunction .= "`n['" . values2String("', '", translate("Lap"), cars*) . "']"

			for ignore, lap in laps
				drawChartFunction .= ",`n[" . lap . ", " . values2String(", ", driverTimes[lap]*) . "]"

			drawChartFunction .= ("`n]);")

			delta := (theMax - theMin)

			theMin := Max(theAvg - (3 * delta), 0)
			theMax := Min(theAvg + (2 * delta), theMax)

			if (theMin = 0)
				theMin := (theAvg / 3)

			window := ("baseline: " . theMin . ", viewWindow: {min: " . theMin . ", max: " . theMax . "}, ")
			series := ""
			title := ""

			if singleCar {
				consistency := 0

				for ignore, time in allTimes
					consistency += (100 - Abs(theAvg - time))

				consistency := Round(consistency / allTimes.Length, 2)

				series := ", series: {1: {type: 'line'}, 2: {type: 'line'}, 3: {type: 'line'}}"

				title := ("title: '" . translate("Consistency: ") . consistency . translate(" %") . "', titleTextStyle: {bold: false}, ")
			}

			drawChartFunction .= ("`nvar options = {" . title . "seriesType: 'bars'" . series . ", backgroundColor: '#" . this.Window.AltBackColor . "', vAxis: {" . window . "title: '" . translate("Lap Time") . "', gridlines: {count: 0}}, hAxis: {title: '" . translate("Laps") . "', gridlines: {count: 0}}, chartArea: { left: '10%', top: '15%', right: '15%', bottom: '15%' } };")

			drawChartFunction .= ("`nvar chart = new google.visualization.ComboChart(document.getElementById('chart_id')); chart.draw(data, options); }")

			this.showReportChart(drawChartFunction, 10)
			this.showReportInfo(raceData)
		}
		else {
			this.showReportChart(false)
			this.showReportInfo(false)
		}
	}

	editConsistencyReportSettings() {
		return this.editReportSettings("Laps", "Cars", "Classes")
	}

	showPaceReport() {
		local drawChartFunction := "function drawChart() {`nvar array = [`n"
		local report := this.Report
		local raceData, drivers, positions, times, selectedCars, cars, laps, lapTimes, driverTimes, length
		local ignore, car, carTimes, index, dIndex, time, text, selectedClasses

		if report {
			raceData := true
			drivers := false
			positions := false
			times := true

			this.loadReportData(false, &raceData, &drivers, &positions, &times)

			selectedClasses := this.getReportClasses(raceData)
			selectedCars := this.getReportCars(raceData)
			cars := []

			laps := this.getReportLaps(raceData)
			lapTimes := []

			driverTimes := CaseInsenseMap()
			length := 20000

			for ignore, car in selectedCars
				if inList(selectedClasses, this.getClass(raceData, car)) {
					carTimes := this.getDriverTimes(raceData, times, car)

					if (carTimes.Length > 0) {
						length := Min(length, carTimes.Length)

						driverTimes[car] := carTimes
					}
				}

			if (length == 20000)
				length := false

			for index, car in selectedCars
				if inList(selectedClasses, this.getClass(raceData, car))
					if driverTimes.Has(car) {
						carTimes := Array("'#" . getMultiMapValue(raceData, "Cars", "Car." . car . ".Nr") . "'")

						for dIndex, time in driverTimes[car]
							if (dIndex > length)
								break
							else
								carTimes.Push(time)

						lapTimes.Push("[" . values2String(", ", carTimes*) . "]")
					}

			drawChartFunction .= (values2String("`n, ", lapTimes*) . "];")

			drawChartFunction .= "`nvar data = new google.visualization.DataTable();"
			drawChartFunction .= "`ndata.addColumn('string', '" . translate("Car") . "');"

			loop Min(length, laps.Length)
				drawChartFunction .= "`ndata.addColumn('number', '" . translate("Lap") . A_Space . laps[A_Index] . "');"

			text := "
			(
			data.addColumn({id:'max', type:'number', role:'interval'});
			data.addColumn({id:'min', type:'number', role:'interval'});
			data.addColumn({id:'firstQuartile', type:'number', role:'interval'});
			data.addColumn({id:'median', type:'number', role:'interval'});
			data.addColumn({id:'mean', type:'number', role:'interval'});
			data.addColumn({id:'thirdQuartile', type:'number', role:'interval'});
			)"

			drawChartFunction .= ("`n" . text)

			drawChartFunction .= ("`n" . "data.addRows(getBoxPlotValues(array, " . (Min(length, laps.Length) + 1) . "));")

			drawChartFunction .= ("`n" . getBoxAndWhiskerJSFunctions())

			text := "
			(
			var options = {
				backgroundColor: '//backColor//', chartArea: { left: '10%', top: '5%', right: '5%', bottom: '20%' },
				legend: { position: 'none' },
			)"

			drawChartFunction .= StrReplace(text, "//backColor//", this.Window.AltBackColor)

			text := "
			(
				hAxis: { title: '%cars%', gridlines: {count: 0} },
				vAxis: { title: '%seconds%', gridlines: {count: 0} },
				lineWidth: 0,
				series: [ { 'color': '%backColor%' } ],
				intervals: { barWidth: 1, boxWidth: 1, lineWidth: 2, style: 'boxes' },
				interval: { max: { style: 'bars', fillOpacity: 1, color: '#777' },
							min: { style: 'bars', fillOpacity: 1, color: '#777' },
							mean: { style: 'points', color: 'grey', pointsize: 5 } }
			};
			)"

			drawChartFunction .= ("`n" . substituteVariables(text, {cars: translate("Cars"), seconds: translate("Seconds")
																  , backColor: this.Window.AltBackColor}))

			drawChartFunction .= ("`nvar chart = new google.visualization.LineChart(document.getElementById('chart_id')); chart.draw(data, options); }")

			this.showReportChart(drawChartFunction, 10)
			this.showReportInfo(raceData)
		}
		else {
			this.showReportChart(false)
			this.showReportInfo(false)
		}
	}

	editPaceReportSettings() {
		return this.editReportSettings("Laps", "Cars", "Classes")
	}

	showPerformanceReport() {
		local drawChartFunction := "function drawChart() {`n"
		local report := this.Report
		local raceData, drivers, positions, times, selectedCars, cars, laps, lapTimes, driverTimes, length
		local ignore, car, carTimes, index, dIndex, time, text, columns, lap
		local simulator, selectedClasses

		if report {
			raceData := true
			drivers := false
			positions := false
			times := true

			this.loadReportData(false, &raceData, &drivers, &positions, &times)

			selectedClasses := this.getReportClasses(raceData)
			selectedCars := this.getReportCars(raceData)
			cars := []

			laps := this.getReportLaps(raceData)
			lapTimes := []

			driverTimes := CaseInsenseMap()
			length := 20000

			for ignore, car in selectedCars
				if inList(selectedClasses, this.getClass(raceData, car)) {
					carTimes := this.getDriverTimes(raceData, times, car)

					if (carTimes.Length > 0) {
						length := Min(length, carTimes.Length)

						driverTimes[car] := carTimes
					}
				}

			if (length == 20000)
				length := false

			simulator := getMultiMapValue(raceData, "Session", "Simulator")
			columns := ["'" . translate("Lap") . "'"]

			for index, car in selectedCars
				if inList(selectedClasses, this.getClass(raceData, car))
					if driverTimes.Has(car) {
						columns.Push("'#" . getMultiMapValue(raceData, "Cars", "Car." . car . ".Nr") . A_Space
										  . StrReplace(SessionDatabase.getCarName(simulator, getMultiMapValue(raceData, "Cars", "Car." . car . ".Car")), "'", "\'") . "'")

						carTimes := []

						for dIndex, time in driverTimes[car]
							if (dIndex > length)
								break
							else
								carTimes.Push(time)

						lapTimes.Push(carTimes)
					}

			drawChartFunction .= "`nvar data = google.visualization.arrayToDataTable(["
			drawChartFunction .= "`n[" . values2String(", ", columns*) . "]"

			loop Min(length, laps.Length) {
				lap := A_Index
				drawChartFunction .= ",`n[" . laps[lap]

				for index, driverTimes in lapTimes
					drawChartFunction .= ", " . driverTimes[lap]

				drawChartFunction .= "]"
			}

			drawChartFunction .= "]);"

			text := "
			(
			var options = {
				backgroundColor: '//backColor//', chartArea: { left: '10%', top: '5%', right: '20%', bottom: '20%' },
				legend: { position: 'right' }, curveType: 'function',
			)"

			drawChartFunction .= "`n" . StrReplace(text, "//backColor//", this.Window.AltBackColor)

			text := "
			(
				hAxis: { title: '%lap%', gridlines: {count: 0} },
				vAxis: { title: '%seconds%', gridlines: {count: 0} }
			};
			)"

			drawChartFunction .= ("`n" . substituteVariables(text, {lap: translate("Lap"), seconds: translate("Seconds")}))

			drawChartFunction .= ("`nvar chart = new google.visualization.LineChart(document.getElementById('chart_id')); chart.draw(data, options); }")

			this.showReportChart(drawChartFunction, 10)
			this.showReportInfo(raceData)
		}
		else {
			this.showReportChart(false)
			this.showReportInfo(false)
		}
	}

	editPerformanceReportSettings() {
		return this.editReportSettings("Laps", "Cars", "Classes")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

getBoxAndWhiskerJSFunctions() {
	local script

	script := "
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
			var average = getAverage(arr);

			if (arr.length % 2 === 0) {
				var midUpper = arr.length / 2;
				var midLower = midUpper - 1;

				array[i][base + 2] = getMedian(arr.slice(0, midUpper));
				array[i][base + 5] = getMedian(arr.slice(midLower));
			}
			else {
				var index = Math.floor(arr.length / 2);

				array[i][base + 2] = getMedian(arr.slice(0, index + 1));
				array[i][base + 5] = getMedian(arr.slice(index));
			}

			array[i][base] = max;
			array[i][base + 1] = min
			array[i][base + 3] = median;
			array[i][base + 4] = average;
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
		if (length % 2 === 0) {
			var midUpper = length / 2;
			var midLower = midUpper - 1;

			return (array[midUpper] + array[midLower]) / 2;
		}
		else {
			return array[Math.floor(length / 2)];
		}
	}

	/*
	* Takes an array and returns
	* the average value.
	*/
	function getAverage(array) {
		var value = 0;

		if (array.length == 0)
			return 0;
		else {
			for (var i = 0; i < array.length; i++)
				value = value + array[i]

			return value / array.length;
		}
	}
	)"

	return script
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

editReportSettings(raceReport, report := false, availableOptions := false) {
	local x, y, oldEncoding
	local lapsDef, laps, baseLap, lastLap, ignore, lap, yOption, headers, allDrivers, selectedDrivers
	local simulator, ignore, driver, column1, column2, startLap, endLap, lap, index, chosen
	local newLaps, newDrivers, rowNumber, classes, selectedClass, valid, categories

	static reportSettingsGui

	static rangeLapsEdit
	static driverSelectCheck
	static categoriesDropDownMenu
	static classesDropDownMenu
	static driverCategoriesCheck
	static allLapsRadio
	static rangeLapsRadio
	static driversListView

	static drivers := false
	static result := false
	static reportViewer := false
	static raceData := false
	static options := false

	chooseAllLapSelection(*) {
		rangeLapsEdit.Enabled := false
		rangeLapsEdit.Text := ""
	}

	chooseRangeLapSelection(*) {
		rangeLapsEdit.Enabled := true
	}

	selectDriver(listView, line) {
		local selected := 0
		local row := 0

		loop {
			row := driversListView.GetNext(row, "C")

			if row
				selected += 1
			else
				break
		}

		if (selected == 0)
			driverSelectCheck.Value := 0
		else if (selected < driversListView.GetCount())
			driverSelectCheck.Value := -1
		else
			driverSelectCheck.Value := 1

		loop listView.GetCount()
			listView.Modify(A_Index, "-Select")
	}

	selectDrivers(*) {
		if (driverSelectCheck.Value == -1)
			driverSelectCheck.Value := 0

		loop driversListView.GetCount()
			driversListView.Modify(A_Index, driverSelectCheck.Value ? "Check" : "-Check")
	}

	getCategories() {
		switch categoriesDropDownMenu.Value {
			case 1:
				return ["Class", "Cup"]
			case 2:
				return ["Class"]
			case 3:
				return ["Cup"]
		}
	}

	if (raceReport = kCancel)
		result := kCancel
	else if (raceReport = kOk)
		result := kOk
	else if (raceReport = "UpdateCategory") {
		classes := reportViewer.getReportClasses(raceData, true, getCategories())

		classesDropDownMenu.Delete()
		classesDropDownMenu.Add(concatenate([translate("All")], classes))
		classesDropDownMenu.Choose(1)

		; classesDropDownMenu.Enabled := (categoriesDropDownMenu.Value > 1)

		editReportSettings("UpdateDrivers")
	}
	else if (raceReport = "UpdateDrivers") {
		if (inList(options, "Drivers") || inList(options, "Cars")) {
			allDrivers := reportViewer.getReportDrivers(raceData, drivers)
			selectedDrivers := []

			if reportViewer.Settings.Has("Drivers")
				selectedDrivers := reportViewer.Settings["Drivers"]
			else
				loop allDrivers.Length
					selectedDrivers.Push(A_Index)

			simulator := getMultiMapValue(raceData, "Session", "Simulator")
			categories := getCategories()

			if inList(options, "Classes") {
				if (classesDropDownMenu.Value > 1)
					selectedClass := reportViewer.getReportClasses(raceData, true, categories)[classesDropDownMenu.Value - 1]
				else
					selectedClass := false
			}
			else
				selectedClass := false

			driversListView.Delete()

			for ignore, driver in allDrivers
				if (!selectedClass || (selectedClass = reportViewer.getClass(raceData, A_Index, categories)))
					if (getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Car", kNotInitialized) != kNotInitialized) {
						if inList(options, "Cars")
							column1 := getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Nr")
						else
							column1 := driver

						column2 := SessionDatabase.getCarName(simulator, getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Car"))

						driversListView.Add(inList(selectedDrivers, A_Index) ? "Check" : "", column1, column2)
					}

			if (!selectedDrivers || (selectedDrivers.Length == driversListView.GetCount()))
				driverSelectCheck.Value := 1
			else if ((selectedDrivers.Length > 0) && (selectedDrivers.Length != driversListView.GetCount()))
				driverSelectCheck.Value := -1
			else
				driverSelectCheck.Value := 0

			if inList(options, "Cars")
				driversListView.ModifyCol(1, "AutoHdr Right")
			else
				driversListView.ModifyCol(1, "AutoHdr")

			driversListView.ModifyCol(2, "AutoHdr")
		}
	}
	else {
		reportViewer := raceReport
		result := false
		options := availableOptions

		raceData := readMultiMap(report . "\Race.data")

		drivers := []
		laps := []

		if (inList(options, "Drivers") || inList(options, "Cars")) {
			oldEncoding := A_FileEncoding

			FileEncoding("UTF-8")

			try {
				loop Read, report . "\Drivers.CSV" {
					lapDrivers := string2Values(";", A_LoopReadLine)

					loop lapDrivers.Length
						lapDrivers[A_Index] := string2Values("|||", lapDrivers[A_Index])[1]

					drivers.Push(lapDrivers)
				}

				drivers := correctEmptyValues(drivers)
			}
			catch Any as exception {
				logError(exception)
			}
			finally {
				FileEncoding(oldEncoding)
			}
		}

		reportSettingsGui := Window({Options: "0x400000"}, "")

		reportSettingsGui.Opt("+Owner" . raceReport.Window.Hwnd)

		reportSettingsGui.SetFont("s10 Bold", "Arial")

		reportSettingsGui.Add("Text", "w351 Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(reportSettingsGui, "Race Reports.Settings"))

		reportSettingsGui.SetFont("s9 Norm", "Arial")

		reportSettingsGui.Add("Documentation", "x106 YP+20 w164 Center", translate("Report Settings")
							, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#race-reports")

		reportSettingsGui.SetFont("s8 Norm", "Arial")

		reportSettingsGui.Add("Text", "x8 yp+30 w360 0x10")

		if inList(options, "Laps") {
			reportSettingsGui.Add("Text", "x16 yp+10 w70 h23 +0x200 Section", translate("Laps"))

			allLapsRadio := reportSettingsGui.Add("Radio", "x90 yp+4 w80 Group", translate(" All"))
			allLapsRadio.OnEvent("Click", chooseAllLapSelection)

			rangeLapsRadio := reportSettingsGui.Add("Radio", "x90 yp+24 w80", translate(" Range:"))
			rangeLapsRadio.OnEvent("Click", chooseRangeLapSelection)

			rangeLapsEdit := reportSettingsGui.Add("Edit", "x170 yp-3 w80")
			reportSettingsGui.Add("Text", "x255 yp+3 w110", translate("(e.g.: 1-5;8;12)"))

			if !raceReport.Settings.Has("Laps") {
				allLapsRadio.Value := 1
				rangeLapsEdit.Enabled := false
			}
			else {
				rangeLapsRadio.Value := 1
				rangeLapsEdit.Enabled := true

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

				rangeLapsEdit.Text := lapsDef
			}
		}

		if inList(options, "Classes") {
			yOption := (inList(options, "Laps") ? "yp+30" : "yp+10")

			categories := false

			if raceReport.Settings.Has("CarCategories") {
				categories := raceReport.Settings["CarCategories"]

				if (inList(categories, "Class") && inList(categories, "Cup"))
					chosen := 1
				else if inList(categories, "Class")
					chosen := 2
				else if inList(categories, "Cup")
					chosen := 3
				else
					chosen := 2
			}
			else
				chosen := 2

			reportSettingsGui.Add("Text", "x16 " . yOption . " w70 h23 +0x200", translate("Categories"))
			categoriesDropDownMenu := reportSettingsGui.Add("DropDownList", "x90 yp w130 Choose" . chosen, collect(["All", "Classes", "Cups"], translate))
			categoriesDropDownMenu.OnEvent("Change", editReportSettings.Bind("UpdateCategory"))

			classes := (categories ? raceReport.getReportClasses(raceData, true, categories) : raceReport.getReportClasses(raceData, true))

			; reportSettingsGui.Add("Text", "x16 yp+24 w70 h23 +0x200", translate("Class"))
			classesDropDownMenu := reportSettingsGui.Add("DropDownList", "x224 yp w130", concatenate([translate("All")], classes))
			classesDropDownMenu.OnEvent("Change", editReportSettings.Bind("UpdateDrivers"))

			if raceReport.Settings.Has("Classes")
				classesDropDownMenu.Choose(1 + inList(classes, raceReport.Settings["Classes"][1]))
			else
				classesDropDownMenu.Choose(1)

			reportSettingsGui.Add("Text", "x16 yp+24 w70 h23 +0x200 Section", translate("Drivers"))
			driverCategoriesCheck := reportSettingsGui.Add("CheckBox", "x90 yp+4", translate("Categories?"))

			if raceReport.Settings.Has("DriverCategories")
				driverCategoriesCheck.Value := raceReport.Settings["DriverCategories"]
		}

		if (inList(options, "Drivers") || inList(options, "Cars")) {
			yOption := ((inList(options, "Laps") || inList(options, "Classes")) ? "yp+30" : "yp+10")

			reportSettingsGui.Add("Text", "x16 " . yOption . " w70 h23 +0x200 Section", translate(inList(options, "Cars") ? "Cars" : "Drivers"))

			headers := (inList(options, "Drivers") ? ["     Driver (Start)", "Car"] : ["     #", "Car"])

			driversListView := reportSettingsGui.Add("ListView", "x90 yp-2 w264 h300 AltSubmit -Multi -LV0x10 Checked NoSort NoSortHdr", collect(headers, translate))
			driversListView.OnEvent("Click", selectDriver)
			driversListView.OnEvent("DoubleClick", selectDriver)

			driverSelectCheck := reportSettingsGui.Add("CheckBox", "Check3 x72 yp+2 w15 h23")
			driverSelectCheck.OnEvent("Click", selectDrivers)

			editReportSettings("UpdateDrivers")
		}

		reportSettingsGui.SetFont("s8 Norm", "Arial")

		yOption := ((inList(options, "Drivers") || inList(options, "Cars")) ? "yp+306" : "yp+30")

		reportSettingsGui.Add("Text", "x8 " . yOption . " w360 0x10")

		reportSettingsGui.Add("Button", "x108 yp+10 w80 h23 Default", translate("Ok")).OnEvent("Click", editReportSettings.Bind(kOk))
		reportSettingsGui.Add("Button", "x196 yp w80 h23", translate("&Cancel")).OnEvent("Click", editReportSettings.Bind(kCancel))

		if getWindowPosition("Race Reports.Settings", &x, &y)
			reportSettingsGui.Show("x" . x . " y" . y)
		else
			reportSettingsGui.Show()

		loop
			Sleep(100)
		until result

		if (result = kOk) {
			result := CaseInsenseMap()

			if inList(options, "Laps") {
				if allLapsRadio.Value
					result["Laps"] := true
				else {
					laps := CaseInsenseMap()
					valid := true

					for ignore, lap in string2Values(";", rangeLapsEdit.Text)
						if InStr(lap, "-") {
							lap := string2Values("-", lap)
							startLap := lap[1]
							endLap := lap[2]

							if isInteger(startLap) {
								if isInteger(endLap) {
									if (endLap = startLap)
										laps[startLap] := startLap
									else if (endLap < startLap) {
										loop {
											index := endLap + A_Index - 1

											laps[index] := index
										}
										until (index = startLap)
									}
									else
										loop {
											index := startLap + A_Index - 1

											laps[index] := index
										}
										until (index = endLap)
								}
								else
									valid := false
							}
							else
								valid := false
						}
						else if isInteger(lap)
							laps[lap] := lap
						else
							valid := false

					if valid {
						newlaps := []

						for lap, ignore in laps
							newLaps.Push(lap)

						result["Laps"] := newLaps
					}
					else
						result["Laps"] := true
				}
			}

			if inList(options, "Classes") {
				categories := getCategories()

				result["CarCategories"] := categories

				if (classesDropDownMenu.Value > 1)
					result["Classes"] := [raceReport.getReportClasses(raceData, true, categories)[classesDropDownMenu.Value - 1]]

				result["DriverCategories"] := driverCategoriesCheck.Value
			}
			else
				categories := ["Class"]

			if (inList(options, "Drivers") || inList(options, "Cars")) {
				allDrivers := raceReport.getReportDrivers(raceData, drivers)
				selectedDrivers := CaseInsenseWeakMap()

				simulator := getMultiMapValue(raceData, "Session", "Simulator")

				if inList(options, "Classes") {
					if (classesDropDownMenu.Value > 1)
						selectedClass := raceReport.getReportClasses(raceData, true, categories)[classesDropDownMenu.Value - 1]
					else
						selectedClass := false
				}
				else
					selectedClass := false

				for ignore, driver in allDrivers
					if (!selectedClass || (selectedClass = raceReport.getClass(raceData, A_Index, categories)))
						selectedDrivers[inList(options, "Cars") ? getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Nr") : driver] := A_Index

				newDrivers := []

				rowNumber := 0

				loop {
					rowNumber := driversListView.GetNext(rowNumber, "C")

					if !rowNumber
						break
					else
						newDrivers.Push(selectedDrivers[driversListView.GetText(rowNumber, 1)])
				}

				result["Drivers"] := newDrivers
				result["Cars"] := newDrivers
			}
		}
		else
			result := false

		reportSettingsGui.Destroy()

		return result
	}
}