;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Telemetry Viewer                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\HTMLViewer.ahk"
#Include "..\..\Libraries\GDIP.ahk"
#Include "SessionDatabase.ahk"
#Include "SessionDatabaseBrowser.ahk"
#Include "TelemetryCollector.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                       Private Constants Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kDataSeries := [{Name: "Speed", Indices: [7], Size: 1, Series: ["Speed"], Converter: [(s) => isNumber(s) ? convertUnit("Speed", s) : kNull]}
					 , {Name: "Throttle", Indices: [2], Size: 0.5, Series: ["Throttle"]}
					 , {Name: "Brake", Indices: [3], Size: 0.5, Series: ["Brake"]}
					 , {Name: "Throttle/Brake", Indices: [2, 3], Size: 0.5, Series: ["Throttle", "Brake"]}
					 , {Name: "Steering", Indices: [4], Size: 0.8, Series: ["Steering"]}
					 , {Name: "TC", Indices: [8], Size: 0.3, Series: ["TC"]}
					 , {Name: "ABS", Indices: [9], Size: 0.3, Series: ["ABS"]}
					 , {Name: "TC/ABS", Indices: [8, 9], Size: 0.3, Series: ["TC", "ABS"]}
					 , {Name: "RPM", Indices: [6], Size: 0.5, Series: ["RPM"]}
					 , {Name: "Gear", Indices: [5], Size: 0.5, Series: ["Gear"]}
					 , {Name: "Long G", Indices: [10], Size: 1, Series: ["Long G"]}
					 , {Name: "Lat G", Indices: [11], Size: 1, Series: ["Lat G"]}
					 , {Name: "Long G/Lat G", Indices: [10, 11], Size: 1, Series: ["Long G", "Lat G"]}
					 , {Name: "Curvature", Special: true, Indices: [false], Size: 1, Series: ["Curvature"]}
					 , {Name: "Time", Indices: [14], Size: 1, Series: ["Time"], Converter: [(t) => isNumber(t) ? t / 1000 : kNull]}]


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class TelemetryChart {
	iTelemetryViewer := false

	iChartArea := false

	iWidthZoom := 100
	iHeightZoom := 100

	TelemetryViewer {
		Get {
			return this.iTelemetryViewer
		}
	}

	Window {
		Get {
			return this.TelemetryViewer.Window
		}
	}

	ChartArea {
		Get {
			return this.iChartArea
		}
	}

	WidthZoom {
		Get {
			return this.iWidthZoom
		}

		Set {
			return (this.iWidthZoom := value)
		}
	}

	HeightZoom {
		Get {
			return this.iHeightZoom
		}

		Set {
			return (this.iHeightZoom := value)
		}
	}

	__New(telemetryViewer, chartArea := false) {
		this.iTelemetryViewer := telemetryViewer
		this.iChartArea := chartArea
	}

	showTelemetryChart(series, lapFileName, referenceLapFileName := false, distanceCorrection := 0) {
		eventHandler(event, arguments*) {
			local telemetryViewer := this.TelemetryViewer
			local row := false
			local data, posX

			try {
				if (event = "Select") {
					row := string2Values(";", arguments[1])

					if ((row.Length > 0) && (StrLen(Trim(row[1])) > 0)) {
						row := string2Values("|", row[1])[1]

						if isNumber(row) {
							row := (row + 1)

							if telemetryViewer.Data.Has(telemetryViewer.SelectedLap[true]) {
								this.selectRow(row)

								data := telemetryViewer.Data[telemetryViewer.SelectedLap[true]]

								if (data.Has(row) && (data[row].Length > 11)) {
									posX := data[row][12]

									if (telemetryViewer.TrackMap && isNumber(posX))
										telemetryViewer.TrackMap.updateTrackPosition(posX, data[row][13])
								}
							}
						}
					}
				}
			}
			catch Any as exception {
				logError(exception)
			}
		}

		if this.ChartArea {
			this.ChartArea.document.open()
			this.ChartArea.document.write(this.createTelemetryChart(series, lapFileName, referenceLapFileName, distanceCorrection))
			this.ChartArea.document.close()

			this.ChartArea.document.parentWindow.eventHandler := eventHandler
		}
	}

	createTelemetryChart(series, lapFileName, referenceLapFileName := false, distanceCorrection := 0, margin := 0, hScale := 1, wScale := 1) {
		local lapTelemetry := []
		local referenceLapTelemetry := false
		local html := ""
		local width, height
		local drawChartFunction, chartArea
		local before, after, margins
		local entry, index, field, running

		if lapFileName
			lapTelemetry := this.TelemetryViewer.loadData(lapFileName)

		if referenceLapFileName {
			referenceLapTelemetry := Map()

			loop Read, referenceLapFileName {
				entry := string2Values(";", A_LoopReadLine)

				running := kNull

				for index, value in entry
					if !isNumber(value)
						entry[index] := kNull
					else if (index = 1)
						running := entry[index] := (Round((entry[index] + distanceCorrection) / 7.5) * 7.5)

				referenceLapTelemetry[running] := entry
			}
		}

		if this.ChartArea {
			width := ((this.ChartArea.getWidth() - 4) / 100 * this.WidthZoom * wScale)
			height := ((this.ChartArea.getHeight() - 4) / 100 * this.HeightZoom * hScale)

			chartArea:= this.createSeriesChart(width, height, series, lapTelemetry, referenceLapTelemetry, &drawChartFunction)

			before := "
			(
				<meta charset='utf-8'>
				<head>
					<style>
						.headerStyle { height: 25; font-size: 11px; font-weight: 500; background-color: #%headerBackColor%; }
						.rowStyle { font-size: 11px; color: #%fontColor%; background-color: #%evenRowBackColor%; }
						.oddRowStyle { font-size: 11px; color: #%fontColor%; background-color: #%oddRowBackColor%; }
					</style>
					<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
					<script type="text/javascript">
						google.charts.load('current', {'packages':['corechart', 'table', 'scatter']}).then(drawChart);
			)"

			before := substituteVariables(before, {fontColor: this.Window.Theme.TextColor
												 , headerBackColor: this.Window.Theme.ListBackColor["Header"]
												 , evenRowBackColor: this.Window.Theme.ListBackColor["EvenRow"]
												 , oddRowBackColor: this.Window.Theme.ListBackColor["OddRow"]})

			after := "
			(
					</script>
				</head>
			)"

			margins := substituteVariables("style='overflow: auto' leftmargin='%margin%' topmargin='%margin%' rightmargin='%margin%' bottommargin='%margin%'"
										 , {margin: margin})

			return ("<html>" . before . drawChartFunction . after . "<body style='background-color: #" . this.Window.AltBackColor . "' " . margins . "><style> div, table { color: '" . this.Window.Theme.TextColor . "'; font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><style> #header { font-size: 12px; } table, p, div { color: #" . this.Window.Theme.TextColor . " } </style>" . chartArea . "</body></html>")
		}
		else
			return "<html></html>"
	}

	createSeriesChart(width, height, series, lapTelemetry, referenceLapTelemetry, &drawChartFunction) {
		local seriesCount := series.Length
		local seriesEstate := 0
		local axisCount := 0
		local ignore, index, offset, data, refData, axes, color, running, refRunning, values
		local theSeries, theName, theIndex, theValue, theConverter, theMinValue, minValue, maxValue, spread, absG

		series := collect(series, (s) {
			local minValues := []
			local maxValues := []

			s := s.Clone()

			seriesEstate += s.Size

			s.MinValue := kUndefined
			s.MaxValue := kUndefined

			axisCount += s.Indices.Length

			return s
		})

		drawChartFunction := ("function drawChart() {`nvar data = new google.visualization.DataTable();")

		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Distance") . "');")

		if referenceLapTelemetry
			for ignore, theSeries in series
				for ignore, theName in theSeries.Series
					drawChartFunction .= ("`ndata.addColumn('number', '" . translate(theName) . translate(" (Reference)") . "');")

		for ignore, theSeries in series
			for ignore, theName in theSeries.Series
				drawChartFunction .= ("`ndata.addColumn('number', '" . translate(theName) . "');")

		drawChartFunction .= "`ndata.addRows(["

		for ignore, data in lapTelemetry {
			if (A_Index = 1)
				continue
			else if (A_Index > 2)
				drawChartFunction .= ", "

			running := data[1]
			refRunning := kNull

			if referenceLapTelemetry {
				refRunning := (Round(running / 7.5) * 7.5)

				if !referenceLapTelemetry.Has(refRunning)
					refRunning := kNull
			}

			values := []

			if (refRunning != kNull) {
				refData := referenceLapTelemetry[refRunning]

				for ignore, theSeries in series
					if (theSeries.Name = "Curvature") {
						if refData.Has(11) {
							absG := Abs(refData[11])

							if (absG > 0.1) {
								theValue := - Log(((refData[7] / 3.6) ** 2) / ((absG = 0) ? 0.00001 : absG))

								if (theSeries.MinValue = kUndefined) {
									theSeries.MinValue := theValue
									theSeries.MaxValue := theValue
								}
								else {
									theSeries.MinValue := Min(theSeries.MinValue, theValue)
									theSeries.MaxValue := Max(theSeries.MaxValue, theValue)
								}
							}
							else
								theValue := kNull

							values.Push(theValue)
						}
						else
							values.Push(kNull)
					}
					else
						for ignore, theIndex in theSeries.Indices
							if refData.Has(theIndex) {
								if theSeries.HasProp("Converter")
									theValue := theSeries.Converter[A_Index](refData[theIndex])
								else
									theValue := refData[theIndex]

								if isNumber(theValue)
									if (theSeries.MinValue = kUndefined) {
										theSeries.MinValue := theValue
										theSeries.MaxValue := theValue
									}
									else {
										theSeries.MinValue := Min(theSeries.MinValue, theValue)
										theSeries.MaxValue := Max(theSeries.MaxValue, theValue)
									}

								values.Push(theValue)
							}
							else
								values.Push(kNull)
			}
			else if referenceLapTelemetry
				loop series.Length
					loop series[A_Index].Indices.Length
						values.Push(kNull)

			for ignore, theSeries in series
				if (theSeries.Name = "Curvature") {
					if data.Has(11) {
						absG := Abs(data[11])

						if (absG > 0.1) {
							theValue := - Log(((data[7] / 3.6) ** 2) / ((absG = 0) ? 0.00001 : absG))

							if isNumber(theValue)
								if (theSeries.MinValue = kUndefined) {
									theSeries.MinValue := theValue
									theSeries.MaxValue := theValue
								}
								else {
									theSeries.MinValue := Min(theSeries.MinValue, theValue)
									theSeries.MaxValue := Max(theSeries.MaxValue, theValue)
								}
						}
						else
							theValue := kNull

						values.Push(theValue)
					}
					else
						values.Push(kNull)
				}
				else
					for ignore, theIndex in theSeries.Indices
						if data.Has(theIndex) {
							if theSeries.HasProp("Converter")
								theValue := theSeries.Converter[A_Index](data[theIndex])
							else
								theValue := data[theIndex]

							if isNumber(theValue)
								if (theSeries.MinValue = kUndefined) {
									theSeries.MinValue := theValue
									theSeries.MaxValue := theValue
								}
								else {
									theSeries.MinValue := Min(theSeries.MinValue, theValue)
									theSeries.MaxValue := Max(theSeries.MaxValue, theValue)
								}

							values.Push(theValue)
						}
						else
							values.Push(kNull)

			drawChartFunction .= ("[" . running . ", " . values2String(", ", values*) . "]")
		}

		axes := "series: { "

		index := 0

		if referenceLapTelemetry {
			color := this.Window.Theme.TextColor["Disabled"]

			loop axisCount {
				if (index > 0)
					axes .= ", "

				axes .= (index . ": {targetAxisIndex: " . (A_Index - 1) . ", color: '" . color . "'}")

				index += 1
			}
		}

		loop axisCount {
			if (index > 0)
				axes .= ", "

			axes .= (index . ": {targetAxisIndex: " . (A_Index - 1) . "}")

			index += 1
		}

		axes .= " },`nhAxes: {gridlines: {count: 0}, ticks: []}, vAxes: { "

		index := 0

		if referenceLapTelemetry {
			for ignore, theSeries in series {
				offset := (A_Index - 1)

				minValue := theSeries.MinValue

				loop theSeries.Indices.Length {
					if (index > 0)
						axes .= ", "

					axes .= (index . ": { baselineColor: '" . this.Window.AltBackColor . "', viewWindowMode: 'maximized', gridlines: {count: 0}, ticks: []")

					if (minValue != kUndefined) {
						maxValue := theSeries.MaxValue
						spread := (maxValue - minValue)

						axes .= (", minValue: " . (minValue - ((seriesCount - offset - 1) * spread / theSeries.Size)) . ", maxValue: " . (maxValue + (offset * spread / theSeries.Size)))
					}

					axes .= " }"

					index += 1
				}
			}
		}

		for ignore, theSeries in series {
			offset := (A_Index - 1)

			minValue := theSeries.MinValue

			loop theSeries.Indices.Length {
				if (index > 0)
					axes .= ", "

				axes .= (index . ": { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, viewWindowMode: 'maximized', ticks: []")

				if (minValue != kUndefined) {
					maxValue := theSeries.MaxValue
					spread := (maxValue - minValue)

					axes .= (", minValue: " . (minValue - ((seriesCount - offset - 1) * spread / theSeries.Size)) . ", maxValue: " . (maxValue + (offset * spread / theSeries.Size)))
				}

				axes .= " }"

				index += 1
			}
		}

		axes .= " }"

		drawChartFunction .= ("]);`nvar options = { " . axes . ", legend: { position: 'bottom', textStyle: { color: '" . this.Window.Theme.TextColor . "'} }, chartArea: { left: '2%', top: '5%', right: '2%', bottom: '10%' }, backgroundColor: '" . this.Window.AltBackColor . "' };`n")

		drawChartFunction .= ("`nvar chart = new google.visualization.LineChart(document.getElementById('chart')); chart.draw(data, options); document.telemetryChart = chart;")
		drawChartFunction .= "`nfunction selectHandler(e) { var cSelection = chart.getSelection(); var selection = ''; for (var i = 0; i < cSelection.length; i++) { var item = cSelection[i]; if (i > 0) selection += ';'; selection += (item.row + '|' + item.column); } try { eventHandler('Select', selection); } catch(e) {} }"

		drawChartFunction .= "`ngoogle.visualization.events.addListener(chart, 'select', selectHandler); }"

		drawChartFunction .= ("`nfunction selectTelemetry(row) {`ndocument.telemetryChart.setSelection([{row: row, column: null}]); }")

		return ("<div id=`"chart`" style=`"width: " . Round(width) . "px; height: " . Round(height) . "px`"></div>")
	}

	selectRow(row) {
		local environment

		static htmlViewer := getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory)), "HTML", "Viewer", "IE11")

		if (false && (htmlViewer = "WebView2"))
			this.ChartArea.HTMLViewer.WebView2.Core().ExecuteScript("selectTelemetry(" . row . ")", false)
		else
			this.ChartArea.document.parentWindow.selectTelemetry(row)
	}

	selectPosition(posX, posY, threshold := 40) {
		local data := this.TelemetryViewer.Data[this.TelemetryViewer.SelectedLap[true]]
		local lastX := kUndefined
		local lastY := kUndefined
		local row := false
		local coordX, coordY, dx, dy, deltaX, deltaY, row

		if ((data.Length > 0) && data[1].Length > 11) {
			loop data.Length {
				coordX := data[A_Index][12]
				coordY := data[A_Index][13]

				dX := Abs(coordX - posX)
				dY := Abs(coordY - posY)

				if ((dX <= threshold) && (dY <= threshold) && ((lastX == kUndefined) || ((dx + dy) < (deltaX + deltaY)))) {
					lastX := coordX
					lastY := coordY
					deltaX := dX
					deltaY := dY

					row := A_Index
				}
			}

			if row
				this.selectRow(row - 1)
		}
	}
}

class TelemetryViewer {
	iManager := false

	iTelemetryDirectory := false
	iTelemetryCollector := false

	iCollectingNotifier := false

	iWindow := false

	iTelemetryChart := false

	iLaps := []
	iImportedLaps := []

	iLap := false
	iReferenceLap := false

	iDistanceCorrection := 0

	iCollectorTask := false

	iCollect := false

	iTrackMap := false

	iData := CaseInsenseMap()

	iLayouts := CaseInsenseMap()
	iSelectedLayout := false

	class TelemetryViewerWindow extends Window {
		iViewer := false

		__New(viewer, arguments*) {
			this.iViewer := viewer

			super.__New(arguments*)
		}

		Close(*) {
			this.iViewer.Close()
		}
	}

	class TelemetryViewerResizer extends Window.Resizer {
		iTelemetryViewer := false
		iRedraw := false

		__New(telemetryViewer, arguments*) {
			this.iTelemetryViewer := telemetryViewer

			super.__New(telemetryViewer.Window, arguments*)

			Task.startTask(ObjBindMethod(this, "RedrawHTMLViewer"), 500, kHighPriority)
		}

		Resize(deltaWidth, deltaHeight) {
			this.iRedraw := true
		}

		RedrawHTMLViewer() {
			if this.iRedraw
				try {
					local ignore, button

					for ignore, button in ["LButton", "MButton", "RButton"]
						if GetKeyState(button)
							return Task.CurrentTask

					this.iRedraw := false

					this.iTelemetryViewer.TelemetryChart.ChartArea.Resized()

					Task.startTask(ObjBindMethod(this.iTelemetryViewer, "updateTelemetryChart", true))
				}
				catch Any as exception {
					logError(exception)
				}
				finally {
					this.iRedraw := false
				}

			return Task.CurrentTask
		}
	}

	Manager {
		Get {
			return this.iManager
		}
	}

	TelemetryDirectory {
		Get {
			return this.iTelemetryDirectory
		}
	}

	TelemetryCollector {
		Get {
			return this.iTelemetryCollector
		}
	}

	ReadOnly {
		Get {
			return !this.iCollectorTask
		}
	}

	Window {
		Get {
			return this.iWindow
		}
	}

	CollectorTask {
		Get {
			return this.iCollectorTask
		}
	}

	CollectingNotifier {
		Get {
			return this.iCollectingNotifier
		}
	}

	Control[name] {
		Get {
			return this.Window[name]
		}
	}

	TelemetryChart {
		Get {
			return this.iTelemetryChart
		}
	}

	Laps {
		Get {
			return this.iLaps
		}

		Set {
			return (this.iLaps := value)
		}
	}

	ImportedLaps {
		Get {
			return this.iImportedLaps
		}

		Set {
			return (this.iImportedLaps := value)
		}
	}

	SelectedLap[path := false] {
		Get {
			if isNumber(this.iLap)
				return (this.iLap ? (path ? (this.TelemetryDirectory . "Lap " . this.iLap . ".telemetry")
										  : this.iLap)
								  : false)
			else
				return (path ? this.iLap[4] : this.iLap)
		}

		Set {
			this.iLap := value

			this.updateTelemetryChart(true)

			return value
		}
	}

	SelectedReferenceLap[path := false] {
		Get {
			if isNumber(this.iReferenceLap)
				return (this.iReferenceLap ? (path ? (this.TelemetryDirectory . "Lap " . this.iReferenceLap . ".telemetry")
												   : this.iReferenceLap)
										   : false)
			else
				return (path ? this.iReferenceLap[4] : this.iReferenceLap)
		}

		Set {
			this.iReferenceLap := value

			this.updateTelemetryChart(true)

			return value
		}
	}

	DistanceCorrection {
		Get {
			return this.iDistanceCorrection
		}
	}

	Collect {
		Get {
			return this.iCollect
		}
	}

	TrackMap {
		Get {
			return this.iTrackMap
		}
	}

	Layouts {
		Get {
			return this.iLayouts
		}
	}

	SelectedLayout {
		Get {
			return this.iSelectedLayout
		}
	}

	Data[key?] {
		Get {
			return (isSet(key) ? this.iData[key] : this.iData)
		}

		Set {
			return (isSet(key) ? (this.iData[key] := value) : (this.iData := value))
		}
	}

	__New(manager, directory, collect := true) {
		this.iManager := manager
		this.iTelemetryDirectory := (normalizeDirectoryPath(directory) . "\")

		this.iCollect := collect

		this.loadLayouts()
	}

	loadLayouts() {
		local configuration := readMultiMap(kUserConfigDirectory . "Telemetry.layouts")
		local layouts, name, definition, ignore

		if (configuration.Count = 0) {
			this.iLayouts := CaseInsenseMap(translate("Standard")
										  , {Name: translate("Standard")
										   , WidthZoom: 100, HeightZoom: 100
										   , Series: choose(kDataSeries
														  , (s) => (!inList(["Speed", "Throttle", "Brake", "TC", "ABS"
																		   , "Long G", "Lat G"], s.Name) && s.HasProp("Size")))})

			this.iSelectedLayout := translate("Standard")
		}
		else {
			layouts := CaseInsenseMap()

			for name, definition in getMultiMapValues(configuration, "Layouts")
				layouts[name] := {Name: name
								, WidthZoom: getMultiMapValue(configuration, "Zoom", name . ".Width", 100)
								, HeightZoom: getMultiMapValue(configuration, "Zoom", name . ".Height", 100)
								, Series: collect(string2Values(",", definition), (name) {
											  return choose(kDataSeries, (s) => s.Name = name)[1]
										  })}

			this.iLayouts := layouts
			this.iSelectedLayout := getMultiMapValue(configuration, "Selected", "Layout")
		}
	}

	saveLayouts() {
		local configuration := newMultiMap()
		local name, layout

		for name, layout in this.Layouts {
			setMultiMapValue(configuration, "Layouts", name, values2String(",", collect(layout.Series, (s) => s.Name)*))

			setMultiMapValue(configuration, "Zoom", name . ".Width", layout.WidthZoom)
			setMultiMapValue(configuration, "Zoom", name . ".Height", layout.HeightZoom)
		}

		setMultiMapValue(configuration, "Selected", "Layout", this.SelectedLayout)

		writeMultiMap(kUserConfigDirectory . "Telemetry.layouts", configuration)
	}

	createGui() {
		local viewerGui := TelemetryViewer.TelemetryViewerWindow(this, {Descriptor: "Telemetry Browser", Closeable: true, Resizeable:  "Deferred"})
		local viewerControl

		changeWidthZoom(*) {
			this.TelemetryChart.WidthZoom := viewerGui["zoomWSlider"].Value

			this.Layouts[this.SelectedLayout].WidthZoom := this.TelemetryChart.WidthZoom

			this.saveLayouts()

			this.updateTelemetryChart(true)
		}

		changeHeightZoom(*) {
			this.TelemetryChart.HeightZoom := viewerGui["zoomHSlider"].Value

			this.Layouts[this.SelectedLayout].HeightZoom := this.TelemetryChart.HeightZoom

			this.saveLayouts()

			this.updateTelemetryChart(true)
		}

		chooseLap(*) {
			local lap := viewerGui["lapDropDown"].Text
			local chosen

			if (lap != translate("---------------------------------------------") . translate("---------------------------------------------"))
				if (viewerGui["lapDropDown"].Value <= this.Laps.Length)
					this.selectLap(string2Values(":", lap)[1])
				else {
					chosen := viewerGui["lapDropDown"].Value

					if (this.Laps.Length > 0)
						chosen -= (this.Laps.Length + 1)

					this.selectLap(this.ImportedLaps[chosen])
				}
		}

		chooseReferenceLap(*) {
			local chosen := viewerGui["referenceLapDropDown"].Value
			local lap := viewerGui["referenceLapDropDown"].Text

			if (chosen = 1)
				this.selectReferenceLap(false)
			else if (lap != translate("---------------------------------------------") . translate("---------------------------------------------")) {
				chosen -= 1

				if (chosen <= this.Laps.Length)
					this.selectReferenceLap(string2Values(":", lap)[1])
				else {
					if (this.Laps.Length > 0)
						chosen -= (1 + this.Laps.Length)

					this.selectReferenceLap(this.ImportedLaps[chosen])
				}
			}
		}

		deleteLap(*) {
			local all := (!this.ReadOnly && GetKeyState("Ctrl"))
			local msgResult

			if this.SelectedLap {
				if isNumber(this.SelectedLap) {
					OnMessage(0x44, translateYesNoButtons)
					msgResult := withBlockedWindows(MsgBox, translate("Do you really want to delete the selected data?"), translate("Delete"), 262436)
					OnMessage(0x44, translateYesNoButtons, 0)

					if (msgResult = "Yes")
						if all
							this.clear()
						else
							this.deleteLap()
				}
				else if all
					this.clear()
				else
					this.deleteLap()
			}
		}

		loadLap(*) {
			this.loadLap()
		}

		saveLap(*) {
			this.saveLap()
		}

		openTrackMap(*) {
			this.openTrackMap()
		}

		selectLayout(*) {
			this.iSelectedLayout := viewerGui["layoutDropDown"].Text

			this.TelemetryChart.WidthZoom := this.Layouts[this.SelectedLayout].WidthZoom
			this.TelemetryChart.HeightZoom := this.Layouts[this.SelectedLayout].HeightZoom

			this.Window["zoomWSlider"].Value := this.TelemetryChart.WidthZoom
			this.Window["zoomHSlider"].Value := this.TelemetryChart.HeightZoom

			this.updateTelemetryChart(true)
		}

		editLayouts(*) {
			local selectedLayout := this.SelectedLayout
			local newLayouts := editLayoutSettings(this, this.Layouts, &selectedLayout)

			if newLayouts {
				this.iLayouts := newLayouts
				this.iSelectedLayout := selectedLayout

				viewerGui["layoutDropDown"].Delete()
				viewerGui["layoutDropDown"].Add(getKeys(newLayouts))

				newLayouts := getKeys(newLayouts)

				this.iSelectedLayout := newLayouts[inList(newLayouts, this.SelectedLayout) || inList(newLayouts, translate("Standard")) || 1]

				this.TelemetryChart.WidthZoom := this.Layouts[this.SelectedLayout].WidthZoom
				this.TelemetryChart.HeightZoom := this.Layouts[this.SelectedLayout].HeightZoom

				viewerGui["zoomWSlider"].Value := this.TelemetryChart.WidthZoom
				viewerGui["zoomHSlider"].Value := this.TelemetryChart.HeightZoom

				viewerGui["layoutDropDown"].Choose(inList(newLayouts, this.SelectedLayout))

				this.saveLayouts()

				this.updateTelemetryChart(true)
			}
		}

		shiftLeft(*) {
			this.iDistanceCorrection -= (GetKeyState("Ctrl") ? (GetKeyState("Shift") ? 50 : 10) : 1)

			this.updateTelemetryChart(true)
		}

		shiftRight(*) {
			this.iDistanceCorrection += (GetKeyState("Ctrl") ? (GetKeyState("Shift") ? 50 : 10) : 1)

			this.updateTelemetryChart(true)
		}

		this.iWindow := viewerGui

		viewerGui.SetFont("s10 Bold", "Arial")

		viewerGui.Add("Text", "w666 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(viewerGui, "Telemetry Browser"))

		viewerGui.SetFont("s9 Norm", "Arial")

		viewerGui.Add("Documentation", "x186 YP+20 w336 H:Center Center", translate("Telemetry Viewer")
					 , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#Telemetry-Viewer")

		viewerGui.Add("Text", "x8 yp+30 w676 W:Grow 0x10")

		viewerGui.SetFont("s8 Norm", "Arial")

		viewerGui.Add("Text", "x16 yp+20 w80", translate("Lap"))
		viewerGui.Add("DropDownList", "x98 yp-4 w250 vlapDropDown", collect(this.Laps, (l) => this.lapLabel(l))).OnEvent("Change", chooseLap)

		viewerGui.Add("Button", "x350 yp w23 h23 Center +0x200 Disabled vloadButton").OnEvent("Click", loadLap)
		setButtonIcon(viewerGui["loadButton"], kIconsDirectory . "Load.ico", 1, "L4 T4 R4 B4")
		viewerGui.Add("Button", "x374 yp w23 h23 Center +0x200 Disabled vsaveButton").OnEvent("Click", saveLap)
		setButtonIcon(viewerGui["saveButton"], kIconsDirectory . "Save.ico", 1, "L4 T4 R4 B4")
		viewerGui.Add("Button", "x400 yp w23 h23 Center +0x200 vdeleteButton").OnEvent("Click", deleteLap)
		setButtonIcon(viewerGui["deleteButton"], kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

		viewerGui.Add("Text", "x468 yp+4 w80 X:Move", translate("Layout"))
		viewerGui.Add("DropDownList", "x556 yp-4 w96 Choose" . inList(getKeys(this.Layouts), this.SelectedLayout) . " X:Move vlayoutDropDown", getKeys(this.Layouts)).OnEvent("Change", selectLayout)

		viewerGui.Add("Button", "x653 yp w23 h23 +0x200 Center X:Move vlayoutButton", translate("...")).OnEvent("Click", editLayouts)

		this.iCollectingNotifier := viewerGui.Add("HTMLViewer", "x426 yp+9 w30 h30 vcollectingNotifier Hidden")

		this.CollectingNotifier.document.open()
		this.CollectingNotifier.document.write("<html><body style='background-color: #" . this.Window.Theme.WindowBackColor . "' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'> </body></html>")
		this.CollectingNotifier.document.close()

		viewerGui.Add("Text", "x16 yp+19 w80", translate("Reference"))
		viewerGui.Add("DropDownList", "x98 yp-4 w225 Choose1 vreferenceLapDropDown", concatenate([translate("None")], collect(this.Laps, (l) => this.lapLabel(l)))).OnEvent("Change", chooseReferenceLap)

		viewerGui.Add("Button", "x324 yp w12 h23 Center +0x200 Disabled vleftShiftButton").OnEvent("Click", shiftLeft)
		setButtonIcon(viewerGui["leftShiftButton"], kIconsDirectory . "Previous.ico", 1, "L4 T4 R4 B4")
		viewerGui.Add("Button", "x337 yp w12 h23 Center +0x200 Disabled vrightShiftButton").OnEvent("Click", shiftRight)
		setButtonIcon(viewerGui["rightShiftButton"], kIconsDirectory . "Next.ico", 1, "L4 T4 R4 B4")

		viewerGui.Add("Button", "x350 yp w73 h23 vtrackButton", translate("Map...")).OnEvent("Click", openTrackMap)

		viewerGui.Add("Text", "x468 yp+4 w80 X:Move", translate("Zoom"))
		viewerGui.Add("Slider", "Center Thick15 x556 yp-2 X:Move w59 0x10 Range100-400 ToolTip vzoomWSlider", 100).OnEvent("Change", changeWidthZoom)
		viewerGui.Add("Slider", "Center Thick15 x617 yp X:Move w59 0x10 Range100-400 ToolTip vzoomHSlider", 100).OnEvent("Change", changeHeightZoom)

		viewerControl := viewerGui.Add("HTMLViewer", "x16 yp+24 w660 h480 W:Grow H:Grow Border")

		viewerControl.document.open()
		viewerControl.document.write("")
		viewerControl.document.close()

		this.iTelemetryChart := TelemetryChart(this, viewerControl)

		viewerGui.Add(TelemetryViewer.TelemetryViewerResizer(this))

		if (this.Laps.Length > 0)
			this.selectLap(this.Laps[1])
		else
			this.updateState()
	}

	show() {
		local x, y, w, h

		this.createGui()

		if getWindowPosition("Telemetry Browser", &x, &y)
			this.Window.Show("x" . x . " y" . y)
		else
			this.Window.Show()

		if getWindowSize("Telemetry Browser", &w, &h)
			this.Window.Resize("Initialize", w, h)

		this.Window.Opt("+OwnDialogs")

		this.loadTelemetry()

		if this.SelectedLayout {
			this.TelemetryChart.WidthZoom := this.Layouts[this.SelectedLayout].WidthZoom
			this.TelemetryChart.HeightZoom := this.Layouts[this.SelectedLayout].HeightZoom

			this.Window["zoomWSlider"].Value := this.TelemetryChart.WidthZoom
			this.Window["zoomHSlider"].Value := this.TelemetryChart.HeightZoom
		}

		this.updateTelemetryChart(true)

		if this.Collect {
			if this.CollectorTask
				this.CollectorTask.stop()

			this.iCollectorTask := PeriodicTask(ObjBindMethod(this, "loadTelemetry"), 10000, kLowPriority)

			this.CollectorTask.start()
		}
	}

	close() {
		this.shutdownCollector()

		if this.CollectorTask {
			this.CollectorTask.stop()

			this.iCollectorTask := false
		}

		this.Manager.closedTelemetryViewer()

		if this.TrackMap
			this.closeTrackMap()

		this.Window.Destroy()
	}

	updateState() {
		local simulator, car, track, descriptor

		static sessionDB := SessionDatabase()

		this.Control["loadButton"].Enabled := true

		if this.SelectedLap
			this.Control["deleteButton"].Enabled := true
		else
			this.Control["deleteButton"].Enabled := false

		this.Manager.getSessionInformation(&simulator, &car, &track)

		if (this.SelectedLap && car && track) {
			if isNumber(this.SelectedLap)
				this.Control["saveButton"].Enabled := true
			else {
				descriptor := this.SelectedLap

				this.Control["saveButton"].Enabled := !SessionDatabase().hasTelemetry(simulator, car, track, true, false, descriptor[1])
			}
		}
		else
			this.Control["saveButton"].Enabled := false

		if this.SelectedReferenceLap {
			this.Control["leftShiftButton"].Enabled := true
			this.Control["rightShiftButton"].Enabled := true
		}
		else {
			this.Control["leftShiftButton"].Enabled := false
			this.Control["rightShiftButton"].Enabled := false
		}

		this.Control["trackButton"].Enabled := sessionDB.hasTrackMap(simulator, track)
	}

	startupCollector(simulator, track, trackLength) {
		if !this.TelemetryCollector {
			this.iTelemetryCollector := TelemetryCollector(this.TelemetryDirectory, simulator, track, trackLength)

			this.iTelemetryCollector.startup()

			this.CollectingNotifier.show()

			this.CollectingNotifier.document.open()
			this.CollectingNotifier.document.write("<html><body style='background-color: #" . this.Window.Theme.WindowBackColor . "' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><img src='" . (kResourcesDirectory . "Wait.gif?" . Random(1, 10000)) . "' width=28 height=28 border=0 padding=0></body></html>")
			this.CollectingNotifier.document.close()
		}
		else
			this.iTelemetryCollector.startup()
	}

	shutdownCollector() {
		if this.TelemetryCollector {
			this.TelemetryCollector.shutdown()

			this.iTelemetryCollector := false

			this.CollectingNotifier.hide()
		}
	}

	openTrackMap() {
		local simulator, car, track

		if this.TrackMap
			WinActivate(this.TrackMap.Window)
		else {
			this.Manager.getSessionInformation(&simulator, &car, &track)

			this.iTrackMap := TrackMap(this, simulator, track)

			this.TrackMap.show()
		}
	}

	closeTrackMap() {
		if this.TrackMap {
			this.TrackMap.close()

			this.iTrackMap := false
		}
	}

	closedTrackMap() {
		this.iTrackMap := false
	}

	restart(directory, collect := true) {
		local simulator, car, track

		this.selectLap(false, true)
		this.selectReferenceLap(false, true)

		this.Laps := []
		this.ImportedLaps := []

		this.Data := CaseInsenseMap()

		this.iTelemetryDirectory := (normalizeDirectoryPath(directory) . "\")

		if this.Window {
			this.Control["lapDropDown"].Delete()
			this.Control["referenceLapDropDown"].Delete()

			this.Control["referenceLapDropDown"].Add([translate("None")])
			this.Control["referenceLapDropDown"].Choose(1)

			this.updateState()
		}

		if this.TrackMap {
			this.Manager.getSessionInformation(&simulator, &car, &track)

			if SessionDatabase().hasTrackMap(simulator, track)
				this.TrackMap.updateTrackMap(simulator, track)
			else
				this.closeTrackMap()
		}
	}

	clear() {
		this.selectLap(false, true)
		this.selectReferenceLap(false, true)

		this.Laps := []
		this.ImportedLaps := []

		loop Files, this.TelemetryDirectory . "*.telemetry"
			deleteFile(A_LoopFileFullPath)

		this.loadTelemetry()
	}

	loadData(fileName) {
		local data, entry

		if this.Data.Has(fileName)
			return this.Data[fileName]
		else {
			data := []

			loop Read, fileName {
				entry := string2Values(";", A_LoopReadLine)

				for index, value in entry
					if !isNumber(value)
						entry[index] := kNull

				data.Push(entry)
			}

			this.Data[fileName] := data

			return data
		}
	}

	loadLap(fileName := false, driver := false) {
		local info := false
		local lap := false
		local sessionDB := SessionDatabase()
		local simulator, car, track

		processFile(fileName, info) {
			local theDriver := driver
			local theLapTime := false
			local telemetry := false
			local name, directory, dataFile, file, size, lap

			if info {
				info := readMultiMap(info)

				if driver
					theDriver := driver
				else
					theDriver := getMultiMapValue(info, "Info", "Driver")

				theLapTime := getMultiMapValue(info, "Info", "LapTime")

				DirCreate(this.TelemetryDirectory . "Imported")

				if getMultiMapValue(info, "Info", "Lap", false) {
					FileCopy(fileName, this.TelemetryDirectory . "Imported\Lap " . getMultiMapValue(info, "Info", "Lap") . ".telemetry", 1)

					fileName := (this.TelemetryDirectory . "Imported\Lap " . getMultiMapValue(info, "Info", "Lap") . ".telemetry")
				}
				else {
					SplitPath(fileName, , , , &name)

					FileCopy(fileName, this.TelemetryDirectory . "Imported\" . name . ".telemetry", 1)

					fileName := (this.TelemetryDirectory . "Imported\" . name . ".telemetry")
				}
			}

			if (fileName && (fileName != "")) {
				SplitPath(fileName, , &directory, , &fileName)

				if (normalizeDirectoryPath(directory) = normalizeDirectoryPath(sessionDB.getTelemetryDirectory(simulator, car, track, "User"))) {
					dataFile := temporaryFileName("Lap Telemetry", "telemetry")

					try {
						telemetry := sessionDB.readTelemetry(simulator, car, track, fileName, &size)

						file := FileOpen(dataFile, "w", "")

						if file {
							file.RawWrite(telemetry, size)

							file.Close()

							name := fileName
							telemetry := dataFile
							info := sessionDB.readTelemetryInfo(simulator, car, track, fileName)
						}
						else
							telemetry := false
					}
					catch Any as exception {
						logError(exception)

						telemetry := false
					}
				}
				else {
					name := fileName
					telemetry := (directory . "\" . fileName . ".telemetry")
					info := false
				}
			}

			if telemetry {
				if info
					lap := [name, theDriver ? theDriver
											: SessionDatabase.getDriverName(simulator, getMultiMapValue(info, "Telemetry", "Driver"))
						  , theLapTime ? theLapTime : "-"
						  , telemetry]
				else
					lap := [name, theDriver ? theDriver : "John Doe (JD)", theLapTime ? theLapTime : "-", telemetry]

				this.ImportedLaps.Push(lap)

				return lap
			}
			else
				return false
		}

		this.Manager.getSessionInformation(&simulator, &car, &track)

		if !fileName {
			this.Window.Opt("+OwnDialogs")

			this.Window.Block()

			try {
				fileName := browseLapTelemetries(this.Window, &simulator, &car, &track, &info)
			}
			finally {
				this.Window.Unblock()
			}
		}
		else
			info := false

		if (fileName && (fileName != "")) {
			if isObject(fileName) {
				loop fileName.Length
					lap := (processFile(fileName[A_Index], info ? info[A_Index] : false) || lap)
			}
			else
				lap := (processFile(fileName, info) || lap)

			this.loadTelemetry(lap)
		}
	}

	saveLap(lap := false, prompt := true) {
		local simulator, car, track
		local sessionDB, dirName, fileName, newFileName, file, folder, telemetry, driver

		this.Manager.getSessionInformation(&simulator, &car, &track)

		if !lap
			lap := this.SelectedLap

		if lap {
			if (simulator && car && track) {
				dirName := (SessionDatabase.DatabasePath . "User\" . SessionDatabase.getSimulatorCode(simulator)
						  . "\" . car . "\" . track . "\Lap Telemetries")

				DirCreate(dirName)
			}
			else
				dirName := ""

			if isNumber(lap)
				fileName := (dirName . "\Lap " . lap)
			else {
				SplitPath(lap[1], , , , &newFileName)

				fileName := (dirName . "\" . newFileName . translate(" (") . lap[2] . ((lap[3] != "-") ? (" - " . lap[3]) : "") . translate(")"))
			}

			newFileName := (fileName . ".telemetry")

			while FileExist(newFileName)
				newFileName := (fileName . " (" . (A_Index + 1) . ")" . ".telemetry")

			fileName := newFileName

			if prompt {
				this.Window.Opt("+OwnDialogs")

				OnMessage(0x44, translateSaveCancelButtons)
				fileName := withBlockedWindows(FileSelect, "S17", fileName, translate("Save Telemetry..."), "Lap Telemetry (*.telemetry)")
				OnMessage(0x44, translateSaveCancelButtons, 0)
			}

			if (fileName != "")
				try {
					sessionDB := SessionDatabase()

					SplitPath(fileName, , &folder, , &fileName)

					if (normalizeDirectoryPath(folder) = normalizeDirectoryPath(sessionDB.getTelemetryDirectory(simulator, car, track, "User"))) {
						if isNumber(lap)
							file := FileOpen((this.TelemetryDirectory . "Lap " . lap . ".telemetry"), "r-wd")
						else
							file := FileOpen(lap[4], "r-wd")

						if file {
							size := file.Length

							telemetry := Buffer(size)

							file.RawRead(telemetry, size)

							file.Close()

							if isNumber(lap)
								driver := SessionDatabase.ID
							else {
								driver := SessionDatabase.getDriverID(simulator, lap[2])

								if !driver
									driver := SessionDatabase.ID
							}

							sessionDB.writeTelemetry(simulator, car, track, fileName, telemetry, size
												   , false, true, driver)

							return
						}
					}

					DirCreate(folder)

					if isNumber(lap)
						FileCopy(this.TelemetryDirectory . "Lap " . lap . ".telemetry"
							   , folder . "\" . fileName . ".telemetry", 1)
					else
						FileCopy(lap[4], folder . "\" . fileName . ".telemetry", 1)
				}
				catch Any as exception {
					logError(exception)
				}
		}
	}

	deleteLap(lap := false) {
		local selectedLap := this.SelectedLap
		local selectedReferenceLap := this.SelectedReferenceLap

		if !lap
			lap := selectedLap

		if (lap = selectedLap)
			this.selectLap(false, true)

		if (lap = selectedReferenceLap)
			this.selectReferenceLap(false, true)

		if isNumber(lap) {
			deleteFile(this.TelemetryDirectory . "Lap " . lap . ".telemetry")

			this.Laps := remove(this.Laps, lap)
		}
		else
			this.ImportedLaps := remove(this.ImportedLaps, lap)

		this.loadTelemetry()

		if (selectedLap && (inList(this.Laps, selectedLap) || inList(this.ImportedLaps, selectedLap)))
			this.selectLap(selectedLap, true)

		if (selectedReferenceLap && (inList(this.Laps, selectedReferenceLap) || inList(this.ImportedLaps, selectedReferenceLap)))
			this.selectReferenceLap(selectedReferenceLap, true)
	}

	selectLap(lap, force := false) {
		local index := 0

		if (force || (lap != this.SelectedLap)) {
			this.SelectedLap := lap

			if this.Window {
				index := inList(this.Laps, lap)

				if !index {
					index := inList(this.ImportedLaps, lap)

					if (index && (this.Laps.Length > 0))
						index += (this.Laps.Length + 1)
				}

				this.Control["lapDropDown"].Choose(index)

				if this.TrackMap
					this.TrackMap.updateTrackPosition()

				this.updateState()
			}
		}
	}

	selectReferenceLap(lap, force := false) {
		local index := 0

		if (lap = translate("None"))
			lap := false

		if (force || (lap != this.SelectedReferenceLap)) {
			this.SelectedReferenceLap := lap

			if this.Window {
				index := inList(this.Laps, lap)

				if !index {
					index := inList(this.ImportedLaps, lap)

					if (index && (this.Laps.Length > 0))
						index += (this.Laps.Length + 1)
				}

				this.Control["referenceLapDropDown"].Choose(index + 1)

				if this.TrackMap
					this.TrackMap.updateTrackPosition()

				this.updateState()
			}
		}
	}

	lapLabel(lap) {
		local driver, lapTime, sectorTimes

		lapTimeDisplayValue(lapTime) {
			local seconds, fraction, minutes

			if ((lapTime = "-") || isNull(lapTime))
				return "-"
			else if isNumber(lapTime)
				return displayValue("Time", lapTime)
			else
				return lapTime
		}

		if isNumber(lap) {
			this.Manager.getLapInformation(lap, &driver, &lapTime, &sectorTimes)

			if (!InStr(driver, "John Doe") && (lapTime != "-"))
				return (lap . translate(":") . A_Space . driver . translate(" - ") . lapTimeDisplayValue(lapTime) . A_Space . translate("[") . values2String(", ", collect(sectorTimes, lapTimeDisplayValue)*) . translate("]"))
			else if !InStr(driver, "John Doe")
				return (lap . translate(":") . A_Space . driver)
			else
				return lap
		}
		else {
			lapTime := lap[3]
			driver := lap[2]

			if (lapTime != "-")
				return (lap[1] . translate(":") . A_Space . driver . translate(" - ") . lapTimeDisplayValue(lapTime))
			else if !InStr(driver, "John Doe")
				return (lap[1] . translate(":") . A_Space . driver)
			else
				return lap[1]
		}
	}

	loadTelemetry(select := false) {
		local laps := []
		local lap, name, index

		newLap(lap) {
			local file

			if !inList(this.Laps, lap) {
				try {
					file := FileOpen(this.TelemetryDirectory . "Lap " . lap . ".telemetry", "r-wd")

					if file {
						file.Close()

						return true
					}
					else
						return false
				}
				catch Any {
					return false
				}
			}
			else
				return false
		}

		loop Files, this.TelemetryDirectory . "*.telemetry" {
			SplitPath(A_LoopFileName, , , , &name)

			lap := Integer(StrReplace(name, "Lap ", ""))

			if newLap(lap)
				laps.Push(lap)
		}

		laps := bubbleSort(&laps)

		this.Laps := concatenate(this.Laps, laps)

		if this.Window {
			laps := collect(this.Laps, (l) => this.lapLabel(l))

			this.Control["lapDropDown"].Delete()
			this.Control["referenceLapDropDown"].Delete()

			this.Control["lapDropDown"].Add(laps)
			this.Control["referenceLapDropDown"].Add(concatenate([translate("None")], laps))

			if (this.ImportedLaps.Length > 0) {
				if (laps.Length > 0) {
					this.Control["lapDropDown"].Add([translate("---------------------------------------------") . translate("---------------------------------------------")])
					this.Control["referenceLapDropDown"].Add([translate("---------------------------------------------") . translate("---------------------------------------------")])
				}

				this.Control["lapDropDown"].Add(collect(this.ImportedLaps, (d) => this.lapLabel(d)))
				this.Control["referenceLapDropDown"].Add(collect(this.ImportedLaps, (d) => this.lapLabel(d)))
			}

			if select {
				this.selectLap(select, true)
				this.selectReferenceLap(false, true)
			}
			else if (!this.SelectedLap && (laps.Length > 0)) {
				this.selectLap(this.Laps[1])
				this.selectReferenceLap(false, true)
			}
			else if (!this.SelectedLap && (this.ImportedLaps.Length > 0)) {
				this.selectLap(this.ImportedLaps[1])
				this.selectReferenceLap(false, true)
			}
			else {
				index := inList(this.Laps, this.SelectedLap)

				if !index {
					index := inList(this.ImportedLaps, this.SelectedLap)

					if (index && (this.Laps.Length > 0))
						index += (this.Laps.Length + 1)
				}

				this.Control["lapDropDown"].Choose(index)

				index := inList(this.Laps, this.SelectedReferenceLap)

				if !index {
					index := inList(this.ImportedLaps, this.SelectedReferenceLap)

					if (index && (this.Laps.Length > 0))
						index += (this.Laps.Length + 1)
				}

				this.Control["referenceLapDropDown"].Choose(1 + index)
			}

			this.updateState()
		}
	}

	updateTelemetryChart(redraw := false) {
		if (this.TelemetryChart && redraw) {
			this.TelemetryChart.showTelemetryChart(this.Layouts[this.SelectedLayout].Series, this.SelectedLap[true], this.SelectedReferenceLap[true], this.DistanceCorrection)

			this.updateState()
		}
	}
}

class TrackMap {
	iTelemetryViewer := false

	iWindow := false

	iSimulator := false
	iTrack := false

	iTrackDisplay := false
	iTrackDisplayArea := false

	iTrackMap := false
	iTrackImage := false

	iTrackMapMode := "Position"

	iTrackSections := []

	iLastTrackPosition := false

	class TrackMapWindow extends Window {
		iMap := false

		__New(map, arguments*) {
			this.iMap := map

			super.__New(arguments*)
		}

		Close(*) {
			this.iMap.Close()
		}
	}

	class TrackMapResizer extends Window.Resizer {
		iTrackMap := false
		iRedraw := false

		__New(trackMap, arguments*) {
			this.iTrackMap := trackMap

			super.__New(trackMap.Window, arguments*)

			Task.startTask(ObjBindMethod(this, "RedrawTrackMap"), 500, kHighPriority)
		}

		Resize(deltaWidth, deltaHeight) {
			this.iRedraw := true
		}

		RedrawTrackMap() {
			local ignore, button

			if this.iRedraw {
				for ignore, button in ["LButton", "MButton", "RButton"]
					if GetKeyState(button)
						return Task.CurrentTask

				this.iRedraw := false

				this.iTrackMap.updateTrackMap()

				WinRedraw(this.iTrackMap.Window)
			}

			return Task.CurrentTask
		}
	}

	TelemetryViewer {
		Get {
			return this.iTelemetryViewer
		}
	}

	Window {
		Get {
			return this.iWindow
		}
	}

	Control[name] {
		Get {
			return this.Window[name]
		}
	}

	Simulator {
		Get {
			return this.iSimulator
		}
	}

	Track {
		Get {
			return this.iTrack
		}
	}

	TrackMap {
		Get {
			return this.iTrackMap
		}
	}

	TrackImage {
		Get {
			return this.iTrackImage
		}
	}

	TrackMapMode {
		Get {
			return this.iTrackMapMode
		}
	}

	TrackSections[key?] {
		Get {
			return (isSet(key) ? this.iTrackSections[key] : this.iTrackSections)
		}

		Set {
			return (isSet(key) ? (this.iTrackSections[key] := value) : (this.iTrackSections := value))
		}
	}

	__New(telemetryViewer, simulator, track) {
		this.iTelemetryViewer := telemetryViewer

		this.iSimulator := simulator
		this.iTrack := track
	}

	createGui() {
		selectTrackPosition(*) {
			local coordinateX := false
			local coordinateY := false
			local action := false
			local section := false
			local x, y, originalX, originalY, currentX, currentY, msgResult

			MouseGetPos(&x, &y)

			x := screen2Window(x)
			y := screen2Window(y)

			if this.findTrackCoordinate(x - this.iTrackDisplayArea[1], y - this.iTrackDisplayArea[2], &coordinateX, &coordinateY)
				if (this.TrackMapMode = "Position") {
					this.trackClicked(coordinateX, coordinateY)
				}
				else {
					section := this.findTrackSection(coordinateX, coordinateY)

					if section {
						if GetKeyState("Ctrl") {
							OnMessage(0x44, translateYesNoButtons)
							msgResult := withBlockedWindows(MsgBox, translate("Do you really want to delete the selected section?"), translate("Delete"), 262436)
							OnMessage(0x44, translateYesNoButtons, 0)

							if (msgResult = "Yes")
								this.deleteTrackSection(section)
						}
						else {
							originalX := section.X
							originalY := section.Y

							while (GetKeyState("LButton")) {
								MouseGetPos(&x, &y)

								x := screen2Window(x)
								y := screen2Window(y)

								if this.findTrackCoordinate(x - this.iTrackDisplayArea[1], y - this.iTrackDisplayArea[2], &coordinateX, &coordinateY) {
									section.X := coordinateX
									section.Y := coordinateY

									this.updateTrackMap()
								}
							}

							currentX := section.X
							currentY := section.Y

							section.X := originalX
							section.Y := originalY

							if (this.findTrackSection(currentX, currentY) == section) {
								this.updateTrackMap()

								this.sectionClicked(originalX, originalY, section)
							}
							else {
								section.X := currentX
								section.Y := currentY

								this.updateTrackSections()
							}
						}
					}
					else
						this.trackClicked(coordinateX, coordinateY)
				}
		}

		toggleMode(*) {
			if (this.TrackMapMode = "Position") {
				this.iTrackMapMode := "Edit"

				this.Control["editButton"].Text := translate("Save")

				this.updateTrackMap()
			}
			else {
				this.iTrackMapMode := "Position"

				this.Control["editButton"].Text := translate("Edit")

				this.updateTrackSections(true)

				this.updateTrackMap()
			}
		}

		local mapGui := TrackMap.TrackMapWindow(this, {Descriptor: "Track Map", Closeable: true, Resizeable:  "Deferred"})

		this.iWindow := mapGui

		this.iTrackDisplayArea := [480, 480, 480, 380]

		mapGui.Add("Text", "x88 y2 w306 H:Center Center vtrackNameDisplay")

		mapGui.Add("Button", "x399 yp w23 h20 w80 Center +0x200 X:Move veditButton", translate("Edit")).OnEvent("Click", toggleMode)

		mapGui.Add("Picture", "x0 y25 w479 h379 W:Grow H:Grow vtrackDisplayArea")

		this.iTrackDisplay := mapGui.Add("Picture", "x479 y379 BackgroundTrans vtrackDisplay")
		this.iTrackDisplay.OnEvent("Click", selectTrackPosition)

		mapGui.Add(TrackMap.TrackMapResizer(this))
	}

	show() {
		local sessionDB := SessionDatabase()
		local x, y, w, h

		this.createGui()

		if getWindowPosition("Track Map", &x, &y)
			this.Window.Show("x" . x . " y" . y)
		else
			this.Window.Show()

		if getWindowSize("Track Map", &w, &h)
			this.Window.Resize("Initialize", w, h)

		this.loadTrackMap(sessionDB.getTrackMap(this.Simulator, this.Track)
						, sessionDB.getTrackImage(this.Simulator, this.Track))
	}

	close() {
		this.TelemetryViewer.closedTrackMap()

		this.Window.Destroy()
	}

	findTrackSection(coordinateX, coordinateY, threshold := 40) {
		local trackMap := this.TrackMap
		local candidate, deltaX, deltaY, dX, dY
		local index, section

		if ((this.TrackMapMode = "Edit") && trackMap) {
			candidate := false
			deltaX := false
			deltaY := false

			threshold := (threshold / getMultiMapValue(trackMap, "Map", "Scale"))

			for index, section in this.TrackSections {
				dX := Abs(coordinateX - section.X)
				dY := Abs(coordinateY - section.Y)

				if ((dX <= threshold) && (dY <= threshold) && (!candidate || ((dX + dy) < (deltaX + deltaY)))) {
					candidate := section

					deltaX := dx
					deltaY := dy
				}
			}

			return candidate
		}
		else
			return false
	}

	getTrackCoordinateIndex(x, y, threshold := 5) {
		local trackMap := this.TrackMap
		local index := false
		local candidateX, candidateY, deltaX, deltaY, coordX, coordY, dX, dY

		if trackMap {
			candidateX := kUndefined
			candidateY := false
			deltaX := false
			deltaY := false

			loop getMultiMapValue(trackMap, "Map", "Points") {
				coordX := getMultiMapValue(trackMap, "Points", A_Index . ".X")
				coordY := getMultiMapValue(trackMap, "Points", A_Index . ".Y")

				dX := Abs(coordX - x)
				dY := Abs(coordY - y)

				if ((dX <= threshold) && (dY <= threshold) && ((candidateX == kUndefined) || ((dx + dy) < (deltaX + deltaY)))) {
					candidateX := coordX
					candidateY := coordY
					deltaX := dX
					deltaY := dY

					index := A_Index
				}
			}

			return index
		}
		else
			return false
	}

	loadTrackMap(trackMap, trackImage) {
		local directory := kTempDirectory . "Track Images"
		local sections := []
		local image

		deleteDirectory(directory)

		DirCreate(directory)

		image := this.Window.Theme.RecolorizeImage(trackImage)

		this.iTrackMap := trackMap
		this.iTrackImage := image

		this.Control["trackNameDisplay"].Text := SessionDatabase.getTrackName(this.Simulator
																			, getMultiMapValue(trackMap, "General", "Track", ""))

		loop getMultiMapValue(trackMap, "Sections", "Count")
			sections.Push({Type: getMultiMapValue(trackMap, "Sections", A_Index . ".Type")
						 , X: getMultiMapValue(trackMap, "Sections", A_Index . ".X")
						 , Y: getMultiMapValue(trackMap, "Sections", A_Index . ".Y")})

		this.iTrackSections := sections

		this.updateTrackSections(false)

		this.createTrackMap()
	}

	unloadTrackMap() {
		this.iTrackDisplay.Value := (kIconsDirectory . "Empty.png")

		this.iTrackMap := false
		this.iTrackImage := false

		this.iTrackMapMode := "Position"

		this.Control["editButton"].Enabled := false
		this.Control["editButton"].Text := translate("Edit")
	}

	updateTrackMap(simulator := false, track := false) {
		local load := false
		local sessionDB

		if simulator {
			this.iSimulator := simulator

			load := true
		}

		if track {
			this.iTrack := track

			load := true
		}

		if load {
			sessionDB := SessionDatabase()

			this.unloadTrackMap()

			this.loadTrackMap(sessionDB.getTrackMap(this.Simulator, this.Track)
							, sessionDB.getTrackImage(this.Simulator, this.Track))
		}

		if (this.TrackMap && this.TrackImage)
			if ((this.TrackMapMode = "Position") && this.iLastTrackPosition)
				this.createTrackMap(this.iLastTrackPosition[1], this.iLastTrackPosition[2])
			else
				this.createTrackMap()
	}

	updateTrackSections(save := false) {
		local straights := 0
		local corners := 0
		local sections, index, section

		computeLength(index) {
			local next := ((index = this.TrackSections.Length) ? 1 : (index + 1))
			local distance := 0
			local count := getMultiMapValue(this.TrackMap, "Map", "Points", 0)
			local lastX, lastY, nextX, nextY

			index := this.getTrackCoordinateIndex(this.TrackSections[index].X, this.TrackSections[index].Y)
			next := this.getTrackCoordinateIndex(this.TrackSections[next].X, this.TrackSections[next].Y)

			if (index && next) {
				lastX := getMultiMapValue(this.TrackMap, "Points", index . ".X", 0)
				lastY := getMultiMapValue(this.TrackMap, "Points", index . ".Y", 0)

				index += 1

				loop
					if (index = next)
						break
					else if (index > count)
						index := 1
					else {
						nextX := getMultiMapValue(this.TrackMap, "Points", index . ".X", 0)
						nextY := getMultiMapValue(this.TrackMap, "Points", index . ".Y", 0)

						distance += Sqrt(((nextX - lastX) ** 2) + ((nextY - lastY) ** 2))

						lastX := nextX
						lastY := nextY

						index += 1
					}
				}

			return Round(convertUnit("Length", distance))
		}

		sections := this.TrackSections

		for index, section in sections
			section.Index := this.getTrackCoordinateIndex(section.X, section.Y)

		bubbleSort(&sections,  (a, b) => (a.Index > b.Index))

		for index, section in this.TrackSections
			section.Nr := ((section.Type = "Corner") ? ++corners : ++straights)

		if (save && this.TrackMap) {
			sections := this.TrackSections.Clone()

			Task.startTask(() {
				local index, section

				removeMultiMapValues(this.TrackMap, "Sections")

				setMultiMapValue(this.TrackMap, "Sections", "Count", this.TrackSections.Length)

				for index, section in sections {
					setMultiMapValue(this.TrackMap, "Sections", index . ".Nr", section.Nr)
					setMultiMapValue(this.TrackMap, "Sections", index . ".Type", section.Type)
					setMultiMapValue(this.TrackMap, "Sections", index . ".Index", section.Index)
					setMultiMapValue(this.TrackMap, "Sections", index . ".X", section.X)
					setMultiMapValue(this.TrackMap, "Sections", index . ".Y", section.Y)
				}

				SessionDatabase().updateTrackMap(this.Simulator, this.Track, this.TrackMap)
			}, 0, kLowPriority)
		}
	}

	updateTrackPosition(posX?, posY?) {
		if (isSet(posX) && isNumber(posX)) {
			this.iLastTrackPosition := [posX, posY]

			if this.TrackMap
				this.createTrackMap(posX, posY)
		}
		else {
			this.iLastTrackPosition := false

			if this.TrackMap
				this.createTrackMap()
		}
	}

	findTrackCoordinate(x, y, &coordinateX, &coordinateY, threshold := 40) {
		local trackMap := this.TrackMap
		local trackImage := this.TrackImage
		local scale, offsetX, offsetY, marginX, marginY, width, height, imgWidth, imgHeight, imgScale
		local candidateX, candidateY, deltaX, deltaY, coordX, coordY, dX, dY

		if (trackMap && trackImage) {
			scale := getMultiMapValue(trackMap, "Map", "Scale")

			offsetX := getMultiMapValue(trackMap, "Map", "Offset.X")
			offsetY := getMultiMapValue(trackMap, "Map", "Offset.Y")

			marginX := getMultiMapValue(trackMap, "Map", "Margin.X")
			marginY := getMultiMapValue(trackMap, "Map", "Margin.Y")

			width := this.iTrackDisplayArea[3]
			height := this.iTrackDisplayArea[4]

			imgWidth := ((getMultiMapValue(trackMap, "Map", "Width") + (2 * marginX)) * scale)
			imgHeight := ((getMultiMapValue(trackMap, "Map", "Height") + (2 * marginY)) * scale)

			imgScale := Min(width / imgWidth, height / imgHeight)

			x := (x / imgScale)
			y := (y / imgScale)

			x := ((x / scale) - offsetX - marginX)
			y := ((y / scale) - offsetY - marginY)

			candidateX := kUndefined
			candidateY := false
			deltaX := false
			deltaY := false

			threshold := (threshold / scale)

			loop getMultiMapValue(trackMap, "Map", "Points") {
				coordX := getMultiMapValue(trackMap, "Points", A_Index . ".X")
				coordY := getMultiMapValue(trackMap, "Points", A_Index . ".Y")

				dX := Abs(coordX - x)
				dY := Abs(coordY - y)

				if ((dX <= threshold) && (dY <= threshold) && ((candidateX == kUndefined) || ((dx + dy) < (deltaX + deltaY)))) {
					candidateX := coordX
					candidateY := coordY
					deltaX := dX
					deltaY := dY
				}
			}

			if (candidateX != kUndefined) {
				coordinateX := candidateX
				coordinateY := candidateY

				return true
			}
			else
				return false
		}
		else
			return false
	}

	trackClicked(coordinateX, coordinateY) {
		local oldCoordMode := A_CoordModeMouse
		local x, y, action, section

		CoordMode("Mouse", "Screen")

		MouseGetPos(&x, &y)

		x := screen2Window(x)
		y := screen2Window(y)

		CoordMode("Mouse", oldCoordMode)

		if (this.TrackMapMode = "Position") {
			this.TelemetryViewer.TelemetryChart.selectPosition(coordinateX, coordinateY)

			this.updateTrackPosition(coordinateX, coordinateY)
		}
		else {
			section := this.chooseTrackSectionType()

			if section {
				section.X := coordinateX
				section.Y := coordinateY

				this.addTrackSection(section)
			}
		}
	}

	sectionClicked(coordinateX, coordinateY, section) {
		local oldCoordMode := A_CoordModeMouse
		local x, y

		CoordMode("Mouse", "Screen")

		MouseGetPos(&x, &y)

		x := screen2Window(x)
		y := screen2Window(y)

		CoordMode("Mouse", oldCoordMode)

		section := this.chooseTrackSectionType(section)

		if section
			this.updateTrackSection(section)
	}

	addTrackSection(section) {
		this.TrackSections.Push(section)

		this.updateTrackSections()
		this.updateTrackMap()
	}

	updateTrackSection(section) {
		local index, candidate

		for index, candidate in this.TrackSections
			if ((section.X = candidate.X) && (section.Y = candidate.Y)) {
				this.TrackSections[index] := section

				this.updateTrackSections()
				this.updateTrackMap()

				break
			}
	}

	deleteTrackSection(section) {
		local index, candidate

		for index, candidate in this.TrackSections
			if ((section.X = candidate.X) && (section.Y = candidate.Y)) {
				this.TrackSections.RemoveAt(index)

				this.updateTrackSections()
				this.updateTrackMap()

				break
			}
	}

	chooseTrackSectionType(section := false) {
		local result := false
		local sectionsMenu := Menu()

		sectionsMenu.Add(translate("Corner"), (*) => (result := "Corner"))
		sectionsMenu.Add(translate("Straight"), (*) => (result := "Straight"))

		if section
			sectionsMenu.Check(translate(section.Type))

		this.Window.Block()

		try {
			sectionsMenu.Show()

			while (!result && !GetKeyState("Esc"))
				Sleep(100)

			if result {
				if section
					section := section.Clone()
				else
					section := Object()

				section.Type := result

				return section
			}
			else
				return false
		}
		finally {
			this.Window.Unblock()
		}
	}

	createTrackMap(posX?, posY?) {
		local trackMap := this.TrackMap
		local trackImage := this.TrackImage
		local scale := getMultiMapValue(trackMap, "Map", "Scale")
		local offsetX := getMultiMapValue(trackMap, "Map", "Offset.X")
		local offsetY := getMultiMapValue(trackMap, "Map", "Offset.Y")
		local marginX := getMultiMapValue(trackMap, "Map", "Margin.X")
		local marginY := getMultiMapValue(trackMap, "Map", "Margin.Y")
		local imgWidth := ((getMultiMapValue(trackMap, "Map", "Width") + (2 * marginX)) * scale)
		local imgHeight := ((getMultiMapValue(trackMap, "Map", "Height") + (2 * marginY)) * scale)
		local x, y, w, h, imgScale, deltaX, deltaY
		local token, bitmap, graphics, brush, r, imgX, imgY, trackImage

		ControlGetPos(&x, &y, &w, &h, this.Control["trackDisplayArea"])

		x += 2
		y += 2
		w -= 4
		h -= 4

		imgScale := Min(w / imgWidth, h / imgHeight)

		if (this.TrackMapMode = "Position") {
			if (isSet(posX) && isSet(posY)) {
				token := Gdip_Startup()

				bitmap := Gdip_CreateBitmapFromFile(trackImage)

				graphics := Gdip_GraphicsFromImage(bitmap)

				Gdip_SetSmoothingMode(graphics, 4)

				brush := Gdip_BrushCreateSolid(0xff00ff00)

				r := Round(15 / (imgScale * 3))

				imgX := Round((marginX + offsetX + posX) * scale)
				imgY := Round((marginX + offsetY + posY) * scale)

				Gdip_FillEllipse(graphics, brush, imgX - r, imgY - r, r * 2, r * 2)

				Gdip_DeleteBrush(brush)

				trackImage := temporaryFileName("Track Images\TrackMap", "png")

				Gdip_SaveBitmapToFile(bitmap, trackImage)

				Gdip_DisposeImage(bitmap)

				Gdip_DeleteGraphics(graphics)

				Gdip_Shutdown(token)
			}
		}
		else {
			token := Gdip_Startup()

			bitmap := Gdip_CreateBitmapFromFile(trackImage)

			graphics := Gdip_GraphicsFromImage(bitmap)

			Gdip_SetSmoothingMode(graphics, 4)

			r := Round(15 / (imgScale * 3))

			brushStart := Gdip_BrushCreateSolid(0xff808080)
			brushCorner := Gdip_BrushCreateSolid(0xffFF0000)
			brushStraight := Gdip_BrushCreateSolid(0xff00FF00)

			imgX := Round((marginX + offsetX + getMultiMapValue(trackMap, "Points", "1.X")) * scale)
			imgY := Round((marginX + offsetY + getMultiMapValue(trackMap, "Points", "1.Y")) * scale)

			Gdip_FillEllipse(graphics, brushStart, imgX - r, imgY - r, r * 2, r * 2)

			for ignore, section in this.TrackSections {
				imgX := Round((marginX + offsetX + section.X) * scale)
				imgY := Round((marginX + offsetY + section.Y) * scale)

				Gdip_FillEllipse(graphics, (section.Type = "Corner") ? brushCorner : brushStraight, imgX - r, imgY - r, r * 2, r * 2)
			}

			Gdip_DeleteBrush(brushStart)
			Gdip_DeleteBrush(brushCorner)
			Gdip_DeleteBrush(brushStraight)

			trackImage := temporaryFileName("Track Images\TrackMap", "png")

			Gdip_SaveBitmapToFile(bitmap, trackImage)

			Gdip_DisposeImage(bitmap)

			Gdip_DeleteGraphics(graphics)

			Gdip_Shutdown(token)
		}

		imgWidth *= imgScale
		imgHeight *= imgScale

		deltaX := ((w - imgWidth) / 2)
		deltaY := ((h - imgHeight) / 2)

		x := Round(x + deltaX)
		y := Round(y + deltaY)

		this.iTrackDisplayArea := [x, y, w, h, deltaX, deltaY]

		this.iTrackDisplay.Opt("-Redraw")

		ControlMove(x, y, w, h, this.iTrackDisplay)

		this.iTrackDisplay.Value := ("*w" . imgWidth . " *h" . imgHeight . A_Space . trackImage)

		this.iTrackDisplay.Opt("+Redraw")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

editLayoutSettings(telemetryViewerOrCommand, arguments*) {
	local name, names, x, y, ignore, series, selected, tempLayout, checked1, checked2, inputResult

	static layoutsGui

	static telemetryViewer := false
	static result := false

	static seriesListView := false

	static layouts := []
	static layout := false

	checked(row) {
		local index := 0

		while (index := seriesListView.GetNext(index, "C"))
			if (index = row)
				return true

		return false
	}

	if (telemetryViewerOrCommand = kCancel)
		result := kCancel
	else if (telemetryViewerOrCommand = kOk) {
		if layout
			editLayoutSettings("LayoutSave")

		result := kOk
	}
	else if (telemetryViewerOrCommand = "SeriesUp") {
		selected := seriesListView.GetNext()

		if selected {
			series := seriesListView.GetText(selected)

			checked1 := checked(selected)
			checked2 := checked(selected - 1)

			seriesListView.Modify(selected, checked2 ? "Check" : "-Check", seriesListView.GetText(selected - 1))
			seriesListView.Modify(selected - 1, (checked1 ? "Check " : "-Check ") . "Select Vis", series)

			editLayoutSettings("UpdateState")
		}
	}
	else if (telemetryViewerOrCommand = "SeriesDown") {
		selected := seriesListView.GetNext()

		if selected {
			series := seriesListView.GetText(selected)

			checked1 := checked(selected)
			checked2 := checked(selected + 1)

			seriesListView.Modify(selected, checked2 ? "Check" : "-Check", seriesListView.GetText(selected + 1))
			seriesListView.Modify(selected + 1, (checked1 ? "Check " : "-Check ") . "Select Vis", series)

			editLayoutSettings("UpdateState")
		}
	}
	else if (telemetryViewerOrCommand = "SeriesSelect")
		editLayoutSettings("UpdateState")
	else if (telemetryViewerOrCommand = "SeriesCheck") {
		if (!arguments[3] && !seriesListView.GetNext(0, "C"))
			seriesListView.Modify(arguments[2], "Check")
	}
	else if (telemetryViewerOrCommand = "LayoutNew") {
		inputResult := withBlockedWindows(InputBox, translate("Please enter the name of the new layout:"), translate("Telemetry Layouts"), "w300 h120")

		if (inputResult.Result = "Ok") {
			name := inputResult.Value
			newName := name

			while layouts.Has(newName)
				newName := (name . translate(" (") . A_Index . translate(")"))

			layouts[newName] := {Name: newName, WidthZoom: 100, HeightZoom: 100, Series: [choose(kDataSeries, (s) => s.HasProp("Size"))[1]]}

			editLayoutSettings("LayoutsLoad", layouts)
			editLayoutSettings("LayoutLoad", layouts[newName])
		}
	}
	else if (telemetryViewerOrCommand = "LayoutDelete") {
		if layout {
			layouts.Delete(layout.Name)

			layout := false

			editLayoutSettings("LayoutsLoad", layouts)
		}
	}
	else if (telemetryViewerOrCommand = "LayoutSave") {
		if layout {
			series := []
			selected := 0

			while (selected := seriesListView.GetNext(selected, "C")) {
				name := seriesListView.GetText(selected)

				series.Push(choose(kDataSeries, (s) => translate(s.Name) = name)[1])
			}

			layouts[layout.Name] := {Name: layout.Name
								   , WidthZoom: layoutsGui["zoomWSlider"].Value
								   , HeightZoom: layoutsGui["zoomHSlider"].Value
								   , Series: series}
		}
	}
	else if (telemetryViewerOrCommand = "LayoutSelect")
		editLayoutSettings("LayoutLoad", layouts[layoutsGui["layoutDropDown"].Text])
	else if (telemetryViewerOrCommand = "LayoutLoad") {
		if layout
			editLayoutSettings("LayoutSave")

		layout := arguments[1]

		layoutsGui["layoutDropDown"].Choose(inList(getKeys(layouts), layout.Name))

		seriesListView.Delete()

		if layout {
			names := []

			for ignore, series in layout.Series {
				names.Push(series.Name)

				seriesListView.Add("Check", translate(series.Name))
			}

			for ignore, series in choose(kDataSeries, (s) => s.HasProp("Size"))
				if !inList(names, series.Name)
					seriesListView.Add("", translate(series.Name))

			layoutsGui["zoomWSlider"].Value := layout.WidthZoom
			layoutsGui["zoomHSlider"].Value := layout.HeightZoom
		}

		seriesListView.ModifyCol()
		seriesListView.ModifyCol(1, "AutoHdr")

		editLayoutSettings("UpdateState")
	}
	else if (telemetryViewerOrCommand = "LayoutsLoad") {
		layouts := arguments[1]

		names := []

		for name, ignore in layouts
			names.Push(name)

		layoutsGui["layoutDropDown"].Delete()
		layoutsGui["layoutDropDown"].Add(names)

		if (names.Length > 0)
			editLayoutSettings("LayoutLoad", layouts[names[1]])
		else
			editLayoutSettings("UpdateState")
	}
	else if (telemetryViewerOrCommand = "UpdateState") {
		if ((layouts.Count <= 1) || !layout)
			layoutsGui["deleteButton"].Enabled := false
		else
			layoutsGui["deleteButton"].Enabled := true

		selected := seriesListView.GetNext()

		if selected {
			if (selected = 1) {
				layoutsGui["upButton"].Enabled := false
				layoutsGui["downButton"].Enabled := true
			}
			else if (selected = seriesListView.GetCount()) {
				layoutsGui["upButton"].Enabled := true
				layoutsGui["downButton"].Enabled := false
			}
			else {
				layoutsGui["upButton"].Enabled := true
				layoutsGui["downButton"].Enabled := true
			}
		}
		else {
			layoutsGui["upButton"].Enabled := false
			layoutsGui["downButton"].Enabled := false
		}
	}
	else {
		telemetryViewer := telemetryViewerOrCommand
		result := false

		layouts := []
		layout := false

		layoutsGui := Window({Options: "0x400000"})

		layoutsGui.Opt("+Owner" . telemetryViewer.Window.Hwnd)

		layoutsGui.SetFont("s10 Bold", "Arial")

		layoutsGui.Add("Text", "w291 Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(layoutsGui, "Telemetry Browser.Layouts"))

		layoutsGui.SetFont("s9 Norm", "Arial")

		layoutsGui.Add("Documentation", "x76 YP+20 w164 Center", translate("Telemetry Layouts")
					 , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#telemetry-viewer")

		layoutsGui.SetFont("s8 Norm", "Arial")

		layoutsGui.Add("Text", "x8 yp+30 w300 0x10")

		layoutsGui.Add("Text", "x16 yp+10 w80", translate("Layout"))
		layoutsGui.Add("DropDownList", "x98 yp-4 w120 vlayoutDropDown").OnEvent("Change", editLayoutSettings.Bind("LayoutSelect"))

		layoutsGui.Add("Button", "x219 yp w23 h23 Center +0x200 vnewButton").OnEvent("Click", editLayoutSettings.Bind("LayoutNew"))
		setButtonIcon(layoutsGui["newButton"], kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		layoutsGui.Add("Button", "x243 yp w23 h23 Center +0x200 Disabled vdeleteButton").OnEvent("Click", editLayoutSettings.Bind("LayoutDelete"))
		setButtonIcon(layoutsGui["deleteButton"], kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

		seriesListView := layoutsGui.Add("ListView", "x16 yp+30 w284 h300 AltSubmit -Multi -LV0x10 Checked NoSort NoSortHdr", collect(["Channel"], translate))
		seriesListView.OnEvent("Click", editLayoutSettings.Bind("SeriesSelect"))
		seriesListView.OnEvent("DoubleClick", editLayoutSettings.Bind("SeriesSelect"))
		seriesListView.OnEvent("ItemSelect", editLayoutSettings.Bind("SeriesSelect"))
		seriesListView.OnEvent("ItemCheck", editLayoutSettings.Bind("SeriesCheck"))

		layoutsGui.Add("Button", "x252 yp+302 w23 h23 Center +0x200 vupButton").OnEvent("Click", editLayoutSettings.Bind("SeriesUp"))
		setButtonIcon(layoutsGui["upButton"], kIconsDirectory . "Up Arrow.ico", 1, "L4 T4 R4 B4")
		layoutsGui.Add("Button", "x277 yp w23 h23 Center +0x200 Disabled vdownButton").OnEvent("Click", editLayoutSettings.Bind("SeriesDown"))
		setButtonIcon(layoutsGui["downButton"], kIconsDirectory . "Down Arrow.ico", 1, "L4 T4 R4 B4")

		layoutsGui.Add("Text", "x16 yp+5 w80 X:Move", translate("Zoom"))
		layoutsGui.Add("Slider", "Center Thick15 x104 yp-2 X:Move w59 0x10 Range100-400 ToolTip vzoomWSlider", 100)
		layoutsGui.Add("Slider", "Center Thick15 x" . (617 - 452) . " yp X:Move w59 0x10 Range100-400 ToolTip vzoomHSlider", 100)

		layoutsGui.Add("Text", "x8 yp+30 w300 0x10")

		layoutsGui.Add("Button", "x78 yp+10 w80 h23 Default", translate("Ok")).OnEvent("Click", editLayoutSettings.Bind(kOk))
		layoutsGui.Add("Button", "x166 yp w80 h23", translate("&Cancel")).OnEvent("Click", editLayoutSettings.Bind(kCancel))

		editLayoutSettings("LayoutsLoad", arguments[1].Clone())
		editLayoutSettings("LayoutLoad", arguments[1][%arguments[2]%])

		telemetryViewer.Window.Block()

		try {
			if getWindowPosition("Telemetry Browser.Layouts", &x, &y)
				layoutsGui.Show("x" . x . " y" . y)
			else
				layoutsGui.Show()

			loop
				Sleep(100)
			until result

			if (result = kOk) {
				result := layouts

				%arguments[2]% := layout.Name
			}
			else
				result := false

			layoutsGui.Destroy()
		}
		finally {
			telemetryViewer.Window.Unblock()
		}

		return result
	}
}