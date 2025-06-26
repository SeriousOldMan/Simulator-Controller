﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Telemetry Viewer                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Extensions\Task.ahk"
#Include "..\..\Framework\Extensions\HTMLViewer.ahk"
#Include "..\..\Framework\Extensions\GDIP.ahk"
#Include "SessionDatabase.ahk"
#Include "SessionDatabaseBrowser.ahk"
#Include "TelemetryCollector.ahk"
#Include "TelemetryAnalyzer.ahk"


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

	showTelemetryChart(cluster, channels, lapFileName, referenceLapFileName := false, distanceCorrection := 0) {
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
			this.ChartArea.document.write(this.createTelemetryChart(cluster, channels, lapFileName, referenceLapFileName, distanceCorrection))
			this.ChartArea.document.close()

			this.ChartArea.document.parentWindow.eventHandler := eventHandler
		}
	}

	createTelemetryChart(cluster, channels, lapFileName, referenceLapFileName := false
					   , distanceCorrection := 0, margin := 0, hScale := 1, wScale := 1) {
		local channelCount := choose(channels, (c) => (c != "|")).Length
		local lapTelemetry := []
		local referenceLapTelemetry := false
		local html := ""
		local chartAreas := []
		local chartFunctions := []
		local width, height
		local clusterIndex, currentCluster, clusterChannels, drawChartFunction
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
			loop cluster {
				currentCluster := 1
				clusterIndex := A_index

				clusterChannels := choose(collect(channels, (c) {
					if (c = "|")
						currentCluster += 1
					else if (clusterIndex = currentCluster)
						return c

					return false
				}), (c) => c)

				if (clusterChannels.Length > 0) {
					width := ((this.ChartArea.getWidth() - 4) / 100 * this.WidthZoom * wScale)
					height := ((this.ChartArea.getHeight() - 4) / 100 * this.HeightZoom * hScale) * (clusterChannels.Length / channelCount)

					chartAreas.Push(this.createChannelChart(width, height, A_Index, clusterChannels
														  , lapTelemetry, referenceLapTelemetry, &drawChartFunction))
					chartFunctions.Push(drawChartFunction)
				}
			}

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

			before .= "`n function drawChart() {"

			loop chartFunctions.Length
				before .= (" drawChart" . A_Index . "();")

			before .= " }`n"

			before .= "`n function selectTelemetry(row) {"

			loop chartFunctions.Length
				before .= (" selectTelemetry" . A_Index . "(row);")

			before .= " }`n"

			return ("<html>" . before . values2String(A_Space, chartFunctions*) . after . "<body style='background-color: #" . this.Window.AltBackColor . "' " . margins . "><style> div, table { color: '" . this.Window.Theme.TextColor . "'; font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><style> #header { font-size: 12px; } table, p, div { color: #" . this.Window.Theme.TextColor . " } </style>" . values2String("", chartAreas*) . "</body></html>")
		}
		else
			return "<html></html>"
	}

	createChannelChart(width, height, cluster, channels, lapTelemetry, referenceLapTelemetry, &drawChartFunction) {
		local channelsCount := channels.Length
		local channelsEstate := 0
		local axisCount := 0
		local currentCluster := 1
		local ignore, index, offset, data, refData, axes, color, running, refRunning, values
		local theChannel, theName, theIndex, theValue, theConverter, theMinValue, minValue, maxValue, spread

		channels := collect(channels, (c) {
			local minValues := []
			local maxValues := []

			c := c.Clone()

			channelsEstate += c.Size

			c.MinValue := kUndefined
			c.MaxValue := kUndefined

			axisCount += c.Indices.Length

			return c
		})

		drawChartFunction := ("function drawChart" . cluster . "() {`nvar data = new google.visualization.DataTable();")

		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Distance") . "');")

		if referenceLapTelemetry
			for ignore, theChannel in channels
				for ignore, theName in theChannel.Channels
					drawChartFunction .= ("`ndata.addColumn('number', '" . translate(theName) . translate(" (Reference)") . "');")

		for ignore, theChannel in channels
			for ignore, theName in theChannel.Channels
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

				for ignore, theChannel in channels
					if theChannel.HasProp("Function") {
						theValue := theChannel.Function.Call(refData)

						if isNumber(theValue)
							if (theChannel.MinValue = kUndefined) {
								theChannel.MinValue := theValue
								theChannel.MaxValue := theValue
							}
							else {
								theChannel.MinValue := Min(theChannel.MinValue, theValue)
								theChannel.MaxValue := Max(theChannel.MaxValue, theValue)
							}

						values.Push(theValue)
					}
					else
						for ignore, theIndex in theChannel.Indices
							if refData.Has(theIndex) {
								if theChannel.HasProp("Converter")
									theValue := theChannel.Converter[A_Index](refData[theIndex])
								else
									theValue := refData[theIndex]

								if isNumber(theValue)
									if (theChannel.MinValue = kUndefined) {
										theChannel.MinValue := theValue
										theChannel.MaxValue := theValue
									}
									else {
										theChannel.MinValue := Min(theChannel.MinValue, theValue)
										theChannel.MaxValue := Max(theChannel.MaxValue, theValue)
									}

								values.Push(theValue)
							}
							else
								values.Push(kNull)
			}
			else if referenceLapTelemetry
				loop channels.Length
					loop channels[A_Index].Indices.Length
						values.Push(kNull)

			for ignore, theChannel in channels
				if theChannel.HasProp("Function") {
					theValue := theChannel.Function.Call(data)

					if isNumber(theValue)
						if (theChannel.MinValue = kUndefined) {
							theChannel.MinValue := theValue
							theChannel.MaxValue := theValue
						}
						else {
							theChannel.MinValue := Min(theChannel.MinValue, theValue)
							theChannel.MaxValue := Max(theChannel.MaxValue, theValue)
						}

					values.Push(theValue)
				}
				else
					for ignore, theIndex in theChannel.Indices
						if data.Has(theIndex) {
							if theChannel.HasProp("Converter")
								theValue := theChannel.Converter[A_Index](data[theIndex])
							else
								theValue := data[theIndex]

							if isNumber(theValue)
								if (theChannel.MinValue = kUndefined) {
									theChannel.MinValue := theValue
									theChannel.MaxValue := theValue
								}
								else {
									theChannel.MinValue := Min(theChannel.MinValue, theValue)
									theChannel.MaxValue := Max(theChannel.MaxValue, theValue)
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
			for ignore, theChannel in channels {
				offset := (A_Index - 1)

				minValue := theChannel.MinValue

				loop theChannel.Indices.Length {
					if (index > 0)
						axes .= ", "

					axes .= (index . ": { baselineColor: '" . this.Window.AltBackColor . "', viewWindowMode: 'maximized', gridlines: {count: 0}, ticks: []")

					if (minValue != kUndefined) {
						maxValue := theChannel.MaxValue
						spread := (maxValue - minValue)

						axes .= (", minValue: " . (minValue - ((channelsCount - offset - 1) * spread / theChannel.Size)) . ", maxValue: " . (maxValue + (offset * spread / theChannel.Size)))
					}

					axes .= " }"

					index += 1
				}
			}
		}

		for ignore, theChannel in channels {
			offset := (A_Index - 1)

			minValue := theChannel.MinValue

			loop theChannel.Indices.Length {
				if (index > 0)
					axes .= ", "

				axes .= (index . ": { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, viewWindowMode: 'maximized', ticks: []")

				if (minValue != kUndefined) {
					maxValue := theChannel.MaxValue
					spread := (maxValue - minValue)

					axes .= (", minValue: " . (minValue - ((channelsCount - offset - 1) * spread / theChannel.Size)) . ", maxValue: " . (maxValue + (offset * spread / theChannel.Size)))
				}

				axes .= " }"

				index += 1
			}
		}

		axes .= " }"

		drawChartFunction .= ("]);`nvar options = { interpolateNulls: true, " . axes . ", legend: { position: 'bottom', textStyle: { color: '" . this.Window.Theme.TextColor . "'} }, chartArea: { left: '2%', top: '5%', right: '2%', bottom: '10%' }, backgroundColor: '" . this.Window.AltBackColor . "' };`n")

		drawChartFunction .= ("`nvar chart = new google.visualization.LineChart(document.getElementById('chart" . cluster . "')); chart.draw(data, options); document.telemetryChart" . cluster . " = chart;")
		drawChartFunction .= "`nfunction selectHandler(e) { var cSelection = chart.getSelection(); var selection = ''; for (var i = 0; i < cSelection.length; i++) { var item = cSelection[i]; if (i > 0) selection += ';'; selection += (item.row + '|' + item.column); } try { eventHandler('Select', selection); } catch(e) {} }"

		drawChartFunction .= "`ngoogle.visualization.events.addListener(chart, 'select', selectHandler); }"

		drawChartFunction .= ("`nfunction selectTelemetry" . cluster . "(row) {`ndocument.telemetryChart" . cluster . ".setSelection([{row: row, column: null}]); }")

		return ("<div id=`"chart" . cluster . "`" style=`"width: " . Round(width) . "px; height: " . Round(height) . "px`"></div>")
	}

	selectRow(row) {
		local data, x

		static htmlViewer := getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory)), "HTML", "Viewer", "IE11")

		if (false && (htmlViewer = "WebView2"))
			this.ChartArea.HTMLViewer.WebView2.Core().ExecuteScript("selectTelemetry(" . row . ")", false)
		else
			this.ChartArea.document.parentWindow.selectTelemetry(row)

		data := this.TelemetryViewer.Data[this.TelemetryViewer.SelectedLap[true]]

		if (data.Has(row) && (data[row].Length > 11)) {
			x := data[row][12]

			if isNumber(x)
				this.TelemetryViewer.showSectionInfo(x, data[row][13])
		}
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

	iCollect := false
	iSynchronize := false
	iSynchronizeTask := false

	iTrackMap := false

	iData := CaseInsenseMap()

	iLayouts := CaseInsenseMap()
	iSelectedLayout := false

	class TelemetryViewerWindow extends Window {
		iViewer := false
		iActivationTask := false

		__New(viewer, arguments*) {
			local lastButton := A_TickCount
			local lastActivation := A_TickCount

			this.iViewer := viewer

			this.iActivationTask := PeriodicTask(() {
										local ignore, button

										for ignore, button in ["LButton", "MButton", "RButton"]
											if GetKeyState(button) {
												lastButton := A_TickCount

												return
											}

										if (WinActive(this) && (A_TickCount > (lastButton + 5000)))
											if (A_TickCount > (lastActivation + 2000)) {
												lastActivation := A_TickCount

												Task.startTask(() => SectionInfoViewer.bringToFront())
											}
									}, 50, kInterruptPriority)

			this.iActivationTask.start()

			super.__New(arguments*)
		}

		Close(*) {
			this.iActivationTask.stop()
			this.iViewer.close()
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

	Window {
		Get {
			return this.iWindow
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
				return (path ? this.iLap[5] : this.iLap)
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
				return (path ? this.iReferenceLap[5] : this.iReferenceLap)
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

	Synchronize {
		Get {
			return this.iSynchronize
		}
	}

	SynchronizeTask {
		Get {
			return this.iSynchronizeTask
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

	__New(manager, directory, synchronize := true, collect := true) {
		this.iManager := manager
		this.iTelemetryDirectory := (normalizeDirectoryPath(directory) . "\")

		this.iSynchronize := synchronize
		this.iCollect := collect

		this.loadLayouts()
	}

	loadLayouts() {
		local configuration := readMultiMap(kUserConfigDirectory . "Telemetry.layouts")
		local layouts := CaseInsenseMap()
		local name, definition, ignore, button, clusterCount

		if (configuration.Count > 0)
			for name, definition in getMultiMapValues(configuration, "Layouts")
				try {
					clusterCount := 1

					layouts[name] := {Name: name
									, WidthZoom: getMultiMapValue(configuration, "Zoom", name . ".Width", 100)
									, HeightZoom: getMultiMapValue(configuration, "Zoom", name . ".Height", 100)
									, Channels: choose(collect(string2Values(",", definition), (name) {
														   if (name = "|") {
															   clusterCount += 1

															   return name
														   }
														   else
															   return choose(kTelemetryChannels, (c) => c.Name = name)[1]
													   })
													 , (c) => ((c = "|") ? c : c.HasProp("Size")))}

					layouts[name].Cluster := clusterCount
				}
				catch Any as exception {
					logError(exception)
				}

		if (layouts.Count = 0)
			layouts := CaseInsenseMap(translate("Standard")
									, {Name: translate("Standard")
									 , WidthZoom: 100, HeightZoom: 100
									 , Cluster: 1
									 , Channels: choose(kTelemetryChannels
													  , (c) => (!inList(["Speed", "Throttle", "Brake", "TC", "ABS"
																	   , "Long G", "Lat G"], c.Name) && c.HasProp("Size")))})

		this.iLayouts := layouts
		this.iSelectedLayout := getMultiMapValue(configuration, "Selected", "Layout", translate("Standard"))

		if !layouts.Has(this.iSelectedLayout)
			if layouts.Has(translate("Standard"))
				this.iSelectedLayout := translate("Standard")
			else
				this.iSelectedLayout := getKeys(layouts)[1]
	}

	saveLayouts() {
		local configuration := newMultiMap()
		local name, layout

		for name, layout in this.Layouts {
			setMultiMapValue(configuration, "Layouts", name, values2String(",", collect(layout.Channels, (c) => ((c = "|") ? c : c.Name))*))

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
			local all := (this.Collect && GetKeyState("Ctrl"))
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
			local configuration := readMultiMap(kUserConfigDirectory . "Telemetry.layouts")

			this.iSelectedLayout := viewerGui["layoutDropDown"].Text

			this.TelemetryChart.WidthZoom := this.Layouts[this.SelectedLayout].WidthZoom
			this.TelemetryChart.HeightZoom := this.Layouts[this.SelectedLayout].HeightZoom

			this.Window["zoomWSlider"].Value := this.TelemetryChart.WidthZoom
			this.Window["zoomHSlider"].Value := this.TelemetryChart.HeightZoom

			setMultiMapValue(configuration, "Selected", "Layout", this.SelectedLayout)

			writeMultiMap(kUserConfigDirectory . "Telemetry.layouts", configuration)

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

		button := viewerGui.Add("Button", "x653 yp+5 w23 h23 X:Move" . (!this.Collect ? " Disabled" : ""))
		button.OnEvent("Click", (*) {
			local provider := getMultiMapValue(readMultiMap(kUserConfigDirectory . "Application Settings.ini")
														  , "Telemetry Viewer", "Provider", "Internal")
			local newProvider, configuration, collector

			viewerGui.Block()

			try {
				newProvider := editTelemetrySettings(this, provider)

				if (newProvider && (newProvider != provider)) {
					configuration := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

					setMultiMapValue(configuration, "Telemetry Viewer", "Provider", newProvider)

					writeMultiMap(kUserConfigDirectory . "Application Settings.ini", configuration)

					collector := this.TelemetryCollector

					if collector {
						this.shutdownCollector()

						this.restart(this.TelemetryDirectory)

						this.startupCollector(collector.Simulator, collector.Track, collector.TrackLength)
					}
				}
			}
			finally {
				viewerGui.Unblock()
			}
		})
		setButtonIcon(button, kIconsDirectory . "Connect.ico", 1)

		viewerGui.Add("Text", "x8 yp+25 w676 W:Grow 0x10")

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

		if this.Synchronize {
			if this.SynchronizeTask
				this.SynchronizeTask.stop()

			this.iSynchronizeTask := PeriodicTask(ObjBindMethod(this, "loadTelemetry"), 10000, kLowPriority)

			this.SynchronizeTask.start()
		}
	}

	close() {
		this.shutdownCollector()

		if this.SynchronizeTask {
			this.SynchronizeTask.stop()

			this.iSynchronizeTask := false
		}

		this.Manager.closedTelemetryViewer()

		if this.TrackMap
			this.closeTrackMap()

		SectionInfoViewer.closeSectionInfo()

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
		if this.Collect
			if !this.TelemetryCollector {
				this.iTelemetryCollector := TelemetryCollector(getMultiMapValue(readMultiMap(kUserConfigDirectory . "Application Settings.ini")
																			  , "Telemetry Viewer", "Provider", "Internal")
															 , this.TelemetryDirectory, simulator, track, trackLength)

				this.iTelemetryCollector.startup()

				this.CollectingNotifier.show()

				this.CollectingNotifier.document.open()
				this.CollectingNotifier.document.write("<html><body style='background-color: #" . this.Window.Theme.WindowBackColor . "' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><img src='" . (kResourcesDirectory . "Wait.gif?" . Random(1, 10000)) . "' width=28 height=28 border=0 padding=0></body></html>")
				this.CollectingNotifier.document.close()
			}
			else {
				if ((this.iTelemetryCollector.Simulator != simulator) || (this.iTelemetryCollector.Track != track)
																	  || (this.iTelemetryCollector.TrackLength != trackLength)) {
					this.iTelemetryCollector.initialize(simulator, track, trackLength)

					this.iTelemetryCollector.startup(true)
				}
				else
					this.iTelemetryCollector.startup()
			}
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

	trackMapChanged(trackMap) {
		local x, y

		if (this.TrackMap && this.TrackMap.getSelectedTrackPosition(&x, &y))
			this.showSectionInfo(x, y, false)
		else
			SectionInfoViewer.closeSectionInfo()
	}

	restart(directory) {
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

		SectionInfoViewer.closeSectionInfo()
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
			local theSectorTimes := false
			local telemetry := false
			local name, directory, dataFile, file, size, lap

			if info {
				info := readMultiMap(info)

				if driver
					theDriver := driver
				else
					theDriver := getMultiMapValue(info, "Info", "Driver")

				theLapTime := getMultiMapValue(info, "Info", "LapTime")
				theSectorTimes := getMultiMapValue(info, "Info", "SectorTimes")

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

							theDriver := getMultiMapValue(info, "Lap", "Driver", false)
							theLapTime := getMultiMapValue(info, "Lap", "LapTime", false)
							theSectorTimes := getMultiMapValue(info, "Lap", "SectorTimes", false)
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

					if FileExist(telemetry . ".info") {
						info := readMultiMap(telemetry . ".info")

						theDriver := getMultiMapValue(info, "Info", "Driver", false)
						theLapTime := getMultiMapValue(info, "Info", "LapTime", false)
						theSectorTimes := getMultiMapValue(info, "Info", "SectorTimes", false)
					}
					else
						info := false
				}
			}

			if telemetry {
				if info
					lap := [name, theDriver ? theDriver
											: SessionDatabase.getDriverName(simulator, getMultiMapValue(info, "Telemetry", "Driver"))
						  , theLapTime ? theLapTime : "-"
						  , theSectorTimes ? string2Values(",", theSectorTimes) : []
						  , telemetry]
				else
					lap := [name, theDriver ? theDriver : "John Doe (JD)"
						  , theLapTime ? theLapTime : "-"
						  , theSectorTimes ? string2Values(",", theSectorTimes) : []
						  , telemetry]

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
		local sessionDB, dirName, fileName, newFileName, file, folder, telemetry, driver, lapTime, sectorTimes

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

			if isNumber(lap) {
				this.Manager.getLapInformation(lap, &driver, &lapTime, &sectorTimes)

				fileName := (dirName . "\Lap " . lap . translate(" (") . driver . ((lapTime != "-") ? (" - " . lapTime) : "") . translate(")"))
			}
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
							file := FileOpen(lap[5], "r-wd")

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

							info := sessionDB.readTelemetryInfo(simulator, car, track, fileName)

							if isNumber(lap) {
								this.Manager.getLapInformation(lap, &driver, &lapTime, &sectorTimes)

								setMultiMapValue(info, "Lap", "Driver", driver)

								if (lapTime && (lapTime != "-"))
									setMultiMapValue(info, "Lap", "LapTime", lapTime)

								if (sectorTimes && (sectorTimes.Length > 0) && (sectorTimes[1] != "-"))
									setMultiMapValue(info, "Lap", "SectorTimes", values2String(",", sectorTimes*))
							}
							else {
								setMultiMapValue(info, "Lap", "Driver", lap[2])

								if (lap[3] && (lap[3] != "-"))
									setMultiMapValue(info, "Lap", "LapTime", lap[3])

								if (lap[4].Length > 0)
									setMultiMapValue(info, "Lap", "SectorTimes", values2String(",", lap[4]*))
							}

							sessionDB.writeTelemetryInfo(simulator, car, track, fileName, info)

							return
						}
					}

					DirCreate(folder)

					if isNumber(lap)
						FileCopy(this.TelemetryDirectory . "Lap " . lap . ".telemetry"
							   , folder . "\" . fileName . ".telemetry", 1)
					else
						FileCopy(lap[5], folder . "\" . fileName . ".telemetry", 1)
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
		local x, y

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

				if this.TrackMap {
					this.TrackMap.updateTrackPosition()

					if (this.TrackMap.getSelectedTrackPosition(&x, &y))
						this.showSectionInfo(x, y, false)
					else
						SectionInfoViewer.closeSectionInfo()
				}

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

				if this.TrackMap {
					this.TrackMap.updateTrackPosition()

					if (this.TrackMap.getSelectedTrackPosition(&x, &y))
						this.showSectionInfo(x, y, false)
					else
						SectionInfoViewer.closeSectionInfo()
				}

				this.updateState()
			}
		}
	}

	showSectionInfo(x, y, open := true) {
		local referenceTelemetry := false
		local simulator, car, track, analyzer, telemetry, section, lap, referenceLap, driver, lapTime, sectorTimes

		try {
			this.Manager.getSessionInformation(&simulator, &car, &track)

			analyzer := TelemetryAnalyzer(simulator, track)
			lap := this.SelectedLap

			if isNumber(lap)
				this.Manager.getLapInformation(lap, &driver, &lapTime, &sectorTimes)
			else {
				driver := lap[2]
				lapTime := ((lap[3] != "-") ? lap[3] : false)
				sectorTimes := lap[4]
			}

			telemetry := analyzer.createTelemetry(0, this.SelectedLap[true], driver, lapTime, sectorTimes)

			if (analyzer.TrackSections.Length = 0)
				withTask(ProgressTask(StrReplace(translate("Scanning track..."), "...", "")), () {
					withBlockedWindows(() {
						analyzer.requireTrackSections(telemetry)

						telemetry := analyzer.createTelemetry(0, this.SelectedLap[true], driver, lapTime, sectorTimes)
					})
				})

			referenceLap := this.SelectedReferenceLap

			if referenceLap {
				if isNumber(referenceLap)
					this.Manager.getLapInformation(lap, &driver, &lapTime, &sectorTimes)
				else {
					driver := referenceLap[2]
					lapTime := ((referenceLap[3] != "-") ? referenceLap[3] : false)
					sectorTimes := referenceLap[4]
				}

				referenceTelemetry := analyzer.createTelemetry(0, this.SelectedReferenceLap[true], driver, lapTime, sectorTimes)
			}

			if telemetry {
				section := telemetry.findSection(x, y)

				if section
					SectionInfoViewer.showSectionInfo(section, referenceTelemetry ? referenceTelemetry.findSection(x, y) : false, open)
			}
		}
		catch Any as exception {
			logError(exception)
		}
	}

	lapLabel(lap) {
		local theLap, driver, lapTime, sectorTimes

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

			theLap := lap
		}
		else {
			theLap := lap[1]

			lapTime := lap[3]
			driver := lap[2]
			sectorTimes := lap[4]
		}

		if (lapTime != "-")
			return (theLap . translate(":") . A_Space . driver . translate(" - ") . lapTimeDisplayValue(lapTime) . ((sectorTimes.Length > 0) ? (A_Space . translate("[") . values2String(", ", collect(sectorTimes, lapTimeDisplayValue)*) . translate("]")) : ""))
		else if !InStr(driver, "John Doe")
			return (theLap . translate(":") . A_Space . driver)
		else
			return theLap
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
			this.TelemetryChart.showTelemetryChart(this.Layouts[this.SelectedLayout].Cluster, this.Layouts[this.SelectedLayout].Channels
												 , this.SelectedLap[true], this.SelectedReferenceLap[true], this.DistanceCorrection)

			this.updateState()
		}
	}
}

class SectionInfoViewer {
	static Instance := false

	iWindow := false
	iInfoViewer := false

	iSection := false
	iReferenceSection := false

	class SectionInfoWindow extends Window {
		iViewer := false

		__New(viewer, arguments*) {
			this.iViewer := viewer

			super.__New(arguments*)
		}

		Close(*) {
			this.iViewer.close()
		}
	}

	class SectionInfoResizer extends Window.Resizer {
		iViewer := false

		__New(viewer, arguments*) {
			this.iViewer := viewer

			super.__New(viewer.Window, arguments*)
		}

		Resize(deltaWidth, deltaHeight) {
			this.iViewer.InfoViewer.Resized()

			if this.iViewer.Section
				this.iViewer.showSectionInfo(this.iViewer.Section, this.iViewer.ReferenceSection)
		}
	}

	Window {
		Get {
			return this.iWindow
		}
	}

	InfoViewer {
		Get {
			return this.iInfoViewer
		}
	}

	Section {
		Get {
			return this.iSection
		}
	}

	ReferenceSection {
		Get {
			return this.iReferenceSection
		}
	}

	static bringToFront() {
		if SectionInfoViewer.Instance
			WinActivate(SectionInfoViewer.Instance.Window)
	}

	static showSectionInfo(section, referenceSection := false, open := true) {
		if (!SectionInfoViewer.Instance && open) {
			SectionInfoViewer.Instance := SectionInfoViewer()

			SectionInfoViewer.Instance.show()
		}

		if SectionInfoViewer.Instance
			SectionInfoViewer.Instance.showSectionInfo(section, referenceSection)
	}

	static closeSectionInfo() {
		if SectionInfoViewer.Instance
			SectionInfoViewer.Instance.close()
	}

	createGui() {
		local infoGui := SectionInfoViewer.SectionInfoWindow(this, {Descriptor: "Telemetry Browser.Info Viewer", Closeable: true, Resizeable: true, Options: "ToolWindow"}, translate("Section"))

		this.iWindow := infoGui

		infoGui.MarginX := 0
		infoGui.MarginY := 0

		this.iInfoViewer := infoGui.Add("HTMLViewer", "x0 y0 w240 h" . Round(240 * 1.618) . " W:Grow H:Grow")

		infoGui.Add(SectionInfoViewer.SectionInfoResizer(this))
	}

	show() {
		this.createGui()

		if getWindowPosition("Telemetry Browser.Info Viewer", &x, &y)
			this.Window.Show("x" . x . " y" . y)
		else
			this.Window.Show()

		if getWindowSize("Telemetry Browser.Info Viewer", &w, &h)
			this.Window.Resize("Initialize", w, h)
	}

	close() {
		SectionInfoViewer.Instance := false

		this.Window.Destroy()
	}

	getTableCSS() {
		local script

		script := "
		(
			.table-std, .th-std, .td-std {
				border-collapse: collapse;
				padding: .3em .5em;
			}

			.th-std, .td-std {
				text-align: center;
				color: #%textColor%;
			}

			.th-std, .caption-std {
				background-color: #%headerBackColor%;
				color: #%textColor%;
				border: thin solid #%frameColor%;
			}

			.td-std {
				border: none;
			}

			.th-left {
				text-align: left;
			}

			.td-left {
				text-align: left;
			}

			.th-right {
				text-align: right;
			}

			.td-right {
				text-align: right;
			}

			tfoot {
				border-bottom: thin solid #%frameColor%;
			}

			.caption-std {
				font-size: 1.5em;
				border-radius: .5em .5em 0 0;
				padding: .5em 0 0 0
			}

			.table-std tbody tr:nth-child(even) {
				background-color: #%evenRowColor%;
			}

			.table-std tbody tr:nth-child(odd) {
				background-color: #%evenRowColor%;
			}
		)"

		return substituteVariables(script, {evenRowColor: this.Window.Theme.ListBackColor["EvenRow"]
										  , oddRowColor: this.Window.Theme.ListBackColor["OddRow"]
										  , altBackColor: this.Window.AltBackColor, backColor: this.Window.BackColor
										  , textColor: this.Window.Theme.TextColor
										  , headerBackColor: this.Window.Theme.TableColor["Header"], frameColor: this.Window.Theme.TableColor["Frame"]})
	}

	createSectionInfo(section, referenceSection := false) {
		local html, name

		nullZero(value) {
			return (isNull(value) ? 0 : value)
		}

		nullRound(value, precision := 0) {
			if isNumber(value)
				return Round(value, precision)
			else
				return value
		}

		stdCell(name, unit := false) {
			unit := (unit ? (A_Space . translate(unit)) : "")

			if referenceSection
				return ("<td class=`"td-std td-left`">" . section.%name% . unit . "</td><td class=`"td-std td-left`">" . referenceSection.%name% . unit . "</td>")
			else
				return ("<td class=`"td-std td-left`">" . section.%name% . unit . "</td>")
		}

		unitCell(name, unit) {
			local value := (convertUnit(unit, nullRound(section.%name%)) . A_Space . getUnit(unit))
			local referenceValue

			if referenceSection {
				referenceValue := (convertUnit(unit, nullRound(referenceSection.%name%)) . A_Space . getUnit(unit))

				return ("<td class=`"td-std td-left`">" . value . "</td><td class=`"td-std td-left`">" . referenceValue . "</td>")
			}
			else
				return ("<td class=`"td-std td-left`">" . value . "</td>")
		}

		numberCell(name, precision := 2, scale := 1, unit := false) {
			unit := (unit ? (A_Space . translate(unit)) : "")

			if referenceSection
				return ("<td class=`"td-std td-left`">" . ((scale = 1) ? nullRound(section.%name%, precision) : Round(section.%name% / scale, precision)) . unit
					  . "</td><td class=`"td-std td-left`">" . ((scale = 1) ? nullRound(referenceSection.%name%, precision) : Round(referenceSection.%name% / scale, precision)) . unit . "</td>")
			else
				return ("<td class=`"td-std td-left`">" . ((scale = 1) ? nullRound(section.%name%, precision) : Round(section.%name% / scale, precision)) . unit . "</td>")
		}

		fieldCell(name, field, precision := 2, scale := 1, unit := false) {
			unit := (unit ? (A_Space . translate(unit)) : "")

			if referenceSection
				return ("<td class=`"td-std td-left`">" . ((scale = 1) ? nullRound(section.%name%[field], precision) : Round(section.%name%[field] / scale, precision)) . unit
					  . "</td><td class=`"td-std td-left`">" . ((scale = 1) ? nullRound(referenceSection.%name%[field], precision) : Round(referenceSection.%name%[field] / scale, precision)) . unit . "</td>")
			else
				return ("<td class=`"td-std td-left`">" . ((scale = 1) ? nullRound(section.%name%[field], precision) : Round(section.%name%[field] / scale, precision)) . unit . "</td>")
		}

		startCell(name) {
			local value := (convertUnit("Length", Round(section.Start[name], 1)) . A_Space . getUnit("Length"))
			local referenceValue

			if referenceSection {
				referenceValue := (convertUnit("Length", referenceSection.Start[name]) . A_Space . getUnit("Length"))

				return ("<td class=`"td-std td-left`">" . value . "</td><td class=`"td-std td-left`">" . referenceValue . "</td>")
			}
			else
				return ("<td class=`"td-std td-left`">" . value . "</td>")
		}

		unitFieldCell(name, field, unit, precision := 1) {
			local value := (convertUnit(unit, nullRound(section.%name%[field], precision)) . A_Space . getUnit(unit))
			local referenceValue

			if referenceSection {
				referenceValue := (convertUnit(unit, nullRound(referenceSection.%name%[field], precision)) . A_Space . getUnit(unit))

				return ("<td class=`"td-std td-left`">" . value . "</td><td class=`"td-std td-left`">" . referenceValue . "</td>")
			}
			else
				return ("<td class=`"td-std td-left`">" . value . "</td>")
		}

		if (section.Type = "Corner") {
			if (section.HasProp("Name") && section.Name)
				name := (A_Space . section.Name)
			else
				name := ""

			this.Window.Title := (translate("Corner") . name . translate(" (") . translate(section.Direction) . translate(")"))

			html := "<table class=`"table-std`">"

			html .= ("<tr><th class=`"th-std th-left`">" . translate("Nr.") . "</th>" . stdCell("Nr") . "</tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Length") . "</th>" . unitCell("Length", "Length") . "</tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Time") . "</th>" . numberCell("Time", 2, 1000, "Seconds") . "</tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Curvature") . "</th>" . numberCell("Curvature") . "</tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Steering Corrections") . "</th>" . stdCell("SteeringCorrections") . "</tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Steering Smoothness") . "</th>" . numberCell("SteeringSmoothness", 0, 1, "\%") . "</tr>")

			html .= "</table>"

			if (section.Start["Entry"] && (section.Start["Entry"] != kNull)) {
				html .= ("<br><br><i>" . translate("Entry") . "</i><br><br>")
				html .= "<table class=`"table-std`">"

				html .= ("<tr><th class=`"th-std th-left`">" . translate("Time") . "</th>" . fieldCell("Time", "Entry", 2, 1000, "Seconds") . "</tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Braking Point") . "</th>" . startCell("Entry") . "</tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Braking Distance") . "</th>" . unitFieldCell("Length", "Entry", "Length") . "</tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Brake Pressure") . "</th>" . numberCell("MaxBrakePressure", 0, 1, "\%") . "</tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Brake Rampup") . "</th>" . unitCell("BrakePressureRampUp", "Length") . "</tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Brake Corrections") . "</th>" . stdCell("BrakeCorrections") . "</tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Brake Smoothness") . "</th>" . numberCell("BrakeSmoothness", 0, 1, "\%") . "</tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("ABS Activations") . "</th>" . stdCell("ABSActivations", "\%") . "</tr>")

				html .= "</table>"
			}

			if (section.Start["Apex"] && (section.Start["Apex"] != kNull)) {
				html .= ("<br><br><i>" . translate("Apex") . "</i><br><br>")
				html .= "<table class=`"table-std`">"

				html .= ("<tr><th class=`"th-std th-left`">" . translate("Time") . "</th>" . fieldCell("Time", "Apex", 2, 1000, "Seconds") . "</tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Rolling Start") . "</th>" . startCell("Apex") . "</tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Rolling Distance") . "</th>" . unitFieldCell("Length", "Apex", "Length") . "</tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Gear") . "</th>" . stdCell("RollingGear") . "</tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("RPM") . "</th>" . stdCell("RollingRPM") . "</tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Speed") . "</th>" . unitCell("MinSpeed", "Speed") . "</tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Lateral G-Force") . "</th>" . numberCell("AvgLateralGForce", 2) . "</tr>")

				html .= "</table>"
			}

			if (section.Start["Exit"] && (section.Start["Exit"] != kNull)) {
				html .= ("<br><br><i>" . translate("Exit ") . "</i><br><br>")
				html .= "<table class=`"table-std`">"

				html .= ("<tr><th class=`"th-std th-left`">" . translate("Time") . "</th>" . fieldCell("Time", "Exit", 2, 1000, "Seconds") . "</tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Acceleration Start") . "</th>" . startCell("Exit") . "</tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Acceleration Distance") . "</th>" . unitFieldCell("Length", "Exit", "Length") . "</tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Gear") . "</th>" . stdCell("AcceleratingGear") . "</tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("RPM") . "</th>" . stdCell("AcceleratingRPM") . "</tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Speed") . "</th>" . unitCell("AcceleratingSpeed", "Speed") . "</tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Throttle Corrections") . "</th>" . stdCell("ThrottleCorrections") . "</tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Throttle Smoothness") . "</th>" . numberCell("ThrottleSmoothness", 0, 1, "\%") . "</tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("TC Activations") . "</th>" . stdCell("TCActivations", "\%") . "</tr>")

				html .= "</table>"
			}
		}
		else {

			if (section.HasProp("Name") && section.Name)
				name := (A_Space . section.Name)
			else
				name := ""

			this.Window.Title := (translate("Straight") . name)

			html := "<table class=`"table-std`">"

			html .= ("<tr><th class=`"th-std th-left`">" . translate("Nr.") . "</th>" . stdCell("Nr") . "</tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Length") . "</th>" . unitCell("Length", "Length") . "</tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Time") . "</th>" . numberCell("Time", 2, 1000, "Seconds") . "</tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Min Speed") . "</th>" . unitCell("MinSpeed", "Speed") . "</tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Max Speed") . "</th>" . unitCell("MaxSpeed", "Speed") . "</tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Avg Speed") . "</th>" . unitCell("AvgSpeed", "Speed") . "</tr>")

			html .= "</table>"
		}

		return html
	}

	showSectionInfo(section, referenceSection := false) {
		local infoText := "<html><style>" . this.getTableCSS() . "</style><body style='background-color: #%backColor%' style='overflow: auto' leftmargin='3' topmargin='3' rightmargin='3' bottommargin='3'><style> table, p { color: #%fontColor%; font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><p>" . this.createSectionInfo(section, referenceSection) . "</p></body></html>"

		this.iSection := section
		this.iReferenceSection := referenceSection

		this.InfoViewer.document.open()
		this.InfoViewer.document.write(StrReplace(substituteVariables(infoText, {fontColor: this.Window.Theme.TextColor
																			   , backColor: this.Window.AltBackColor})
												, "\%", "%"))
		this.InfoViewer.document.close()
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

	iEditorTask := false

	class TrackMapWindow extends Window {
		iMap := false

		__New(map, arguments*) {
			this.iMap := map

			super.__New(arguments*)
		}

		Close(*) {
			this.iMap.close()
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
			local x, y, moved, startX, startY, originalX, originalY, currentX, currentY, msgResult

			MouseGetPos(&x, &y)

			x := screen2Window(x)
			y := screen2Window(y)

			startX := x
			startY := y

			moved := false

			if this.findTrackCoordinate(x - this.iTrackDisplayArea[1], y - this.iTrackDisplayArea[2], &coordinateX, &coordinateY)
				if (this.TrackMapMode = "Position") {
					this.trackClicked(coordinateX, coordinateY)
				}
				else {
					section := this.findTrackSection(coordinateX, coordinateY)

					if section {
						if (false && GetKeyState("Ctrl")) {
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

								if ((Abs(startX - x) > 15) || (Abs(startY - y) > 15))
									moved := true

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

							if moved {
								section.X := currentX
								section.Y := currentY

								this.updateTrackSections()
							}
							else {
								this.updateTrackMap()

								this.sectionClicked(originalX, originalY, section)
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

				if !GetKeyState("Ctrl")
					this.updateTrackSections(true, false)

				this.updateTrackMap(this.Simulator, this.Track)
			}
		}

		autoSections(*) {
			this.Window.Block()

			try {
				withTask(ProgressTask(StrReplace(translate("Scanning track..."), "...", "")), () {
					withBlockedWindows(() {
						local analyzer := TelemetryAnalyzer(this.Simulator, this.Track)
						local lap := this.TelemetryViewer.SelectedLap
						local driver, lapTime, sectorTimes, telemetry, index, section

						if isNumber(lap)
							this.TelemetryViewer.Manager.getLapInformation(lap, &driver, &lapTime, &sectorTimes)
						else {
							driver := lap[2]
							lapTime := ((lap[3] != "-") ? lap[3] : false)
							sectorTimes := lap[4]
						}

						telemetry := analyzer.createTelemetry(0, this.TelemetryViewer.SelectedLap[true], driver, lapTime, sectorTimes)

						removeMultiMapValues(this.TrackMap, "Sections")

						this.iTrackSections := analyzer.findTrackSections(telemetry)

						this.updateTrackSections(false)

						for index, section in this.TrackSections {
							setMultiMapValue(this.TrackMap, "Sections", index . ".Index", section.Index)
							setMultiMapValue(this.TrackMap, "Sections", index . ".Nr", section.Nr)
							setMultiMapValue(this.TrackMap, "Sections", index . ".Type", section.Type)
							setMultiMapValue(this.TrackMap, "Sections", index . ".X", section.X)
							setMultiMapValue(this.TrackMap, "Sections", index . ".Y", section.Y)

							if (section.HasProp("Name") && (Trim(section.Name) != ""))
								setMultiMapValue(this.TrackMap, "Sections", index . ".Name", section.Name)
						}

						this.updateTrackMap()
					})
				})
			}
			finally {
				this.Window.Unblock()
			}
		}

		local mapGui := TrackMap.TrackMapWindow(this, {Descriptor: "Telemetry Browser.Track Map", Closeable: true, Resizeable:  "Deferred"})

		this.iWindow := mapGui

		this.iTrackDisplayArea := [480, 480, 480, 380]

		mapGui.Add("Text", "x88 y2 w306 H:Center Center vtrackNameDisplay")

		mapGui.Add("Button", "x8 yp h20 w80 Center +0x200 vscanButton Hidden", translate("Scan")).OnEvent("Click", autoSections)
		mapGui.Add("Button", "x399 yp h20 w80 Center +0x200 X:Move veditButton", translate("Edit")).OnEvent("Click", toggleMode)

		mapGui.Add("Picture", "x0 y25 w479 h379 W:Grow H:Grow vtrackDisplayArea")

		this.iTrackDisplay := mapGui.Add("Picture", "x479 y379 BackgroundTrans vtrackDisplay")
		this.iTrackDisplay.OnEvent("Click", selectTrackPosition)

		mapGui.Add(TrackMap.TrackMapResizer(this))
	}

	show() {
		local sessionDB := SessionDatabase()
		local x, y, w, h

		showPositionInfo(*) {
			global gPositionInfoEnabled

			local x, y, coordinateX, coordinateY, window

			static currentAction := false
			static previousAction := false
			static currentSection := false
			static previousSection := false
			static positionInfo := ""

			displayToolTip() {
				SetTimer(displayToolTip, 0)

				ToolTip(positionInfo)

				SetTimer(removeToolTip, 10000)
			}

			removeToolTip() {
				SetTimer(removeToolTip, 0)

				ToolTip()
			}

			MouseGetPos(&x, &y)

			x := screen2Window(x)
			y := screen2Window(y)

			coordinateX := false
			coordinateY := false

			if this.findTrackCoordinate(x - this.iTrackDisplayArea[1], y - this.iTrackDisplayArea[2], &coordinateX, &coordinateY) {
				previousAction := false

				currentSection := this.findTrackSection(coordinateX, coordinateY)

				if !currentSection
					currentSection := (coordinateX . ";" . coordinateY)

				if (currentSection && (currentSection != previousSection)) {
					ToolTip()

					if isObject(currentSection) {
						if currentSection.HasProp("Nr") {
							if (currentSection.HasProp("Name") && currentSection.Name && (Trim(currentSection.Name) != ""))
								positionInfo := (translate(" (") . currentSection.Name . translate(")"))
							else
								positionInfo := ""

							switch currentSection.Type, false {
								case "Corner":
									positionInfo := (translate("Corner") . A_Space . currentSection.Nr . positionInfo . translate(": "))
								case "Straight":
									positionInfo := (translate("Straight") . A_Space . currentSection.Nr . positionInfo . translate(": "))
								default:
									throw "Unknown section type detected in SessionDatabaseEditor.show..."
							}

							positionInfo .= (Round(currentSection.X, 3) . translate(", ") . Round(currentSection.Y, 3))
						}
						else
							return
					}
					else
						positionInfo := (Round(string2Values(";", currentSection)[1], 3) . translate(", ") . Round(string2Values(";", currentSection)[2], 3))

					SetTimer(removeToolTip, 0)
					SetTimer(displayToolTip, 1000)

					previousSection := currentSection
				}
				else if !currentSection {
					ToolTip()

					SetTimer(removeToolTip, 0)

					previousSection := false
				}
			}
			else {
				ToolTip()

				SetTimer(removeToolTip, 0)

				previousAction := false
				previousSection := false
			}
		}

		this.createGui()

		if getWindowPosition("Telemetry Browser.Track Map", &x, &y)
			this.Window.Show("x" . x . " y" . y)
		else
			this.Window.Show()

		if getWindowSize("Telemetry Browser.Track Map", &w, &h)
			this.Window.Resize("Initialize", w, h)

		this.loadTrackMap(sessionDB.getTrackMap(this.Simulator, this.Track)
						, sessionDB.getTrackImage(this.Simulator, this.Track))

		this.iEditorTask := PeriodicTask(() {
								if (this.TrackMapMode = "Edit")
									this.Control["editButton"].Text := translate(GetKeyState("Ctrl") ? "Cancel" : "Save")

								if WinActive(this.Window)
									OnMessage(0x0200, showPositionInfo)
								else
									OnMessage(0x0200, showPositionInfo, 0)
							}, 100, kHighPriority)

		this.iEditorTask.start()
	}

	close() {
		if this.iEditorTask {
			this.iEditorTask.stop()

			this.iEditorTask := false
		}

		this.TelemetryViewer.closedTrackMap()

		this.Window.Destroy()
	}

	getSelectedTrackPosition(&x, &y) {
		if this.iLastTrackPosition {
			x := this.iLastTrackPosition[1]
			y := this.iLastTrackPosition[2]

			return true
		}
		else
			return false
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

		loop getMultiMapValue(trackMap, "Sections", "Count") {
			sections.Push({Type: getMultiMapValue(trackMap, "Sections", A_Index . ".Type")
						 , X: getMultiMapValue(trackMap, "Sections", A_Index . ".X")
						 , Y: getMultiMapValue(trackMap, "Sections", A_Index . ".Y")})

			if (getMultiMapValue(trackMap, "Sections", A_Index . ".Name", kUndefined) != kUndefined)
				sections[A_Index].Name := getMultiMapValue(trackMap, "Sections", A_Index . ".Name")
		}

		this.iTrackSections := sections

		this.updateTrackSections(false)

		this.createTrackMap()

		this.Control["editButton"].Enabled := true
		this.Control["scanButton"].Visible := ((this.TrackMapMode = "Edit") && !!this.TelemetryViewer.SelectedLap)
		this.Control["editButton"].Text := translate("Edit")
	}

	unloadTrackMap() {
		this.iTrackDisplay.Value := (kIconsDirectory . "Empty.png")

		this.iTrackMap := false
		this.iTrackImage := false

		this.iTrackMapMode := "Position"

		this.Control["editButton"].Enabled := false
		this.Control["scanButton"].Visible := false
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
			if this.iLastTrackPosition
				this.createTrackMap(this.iLastTrackPosition[1], this.iLastTrackPosition[2])
			else
				this.createTrackMap()

		this.Control["scanButton"].Visible := ((this.TrackMapMode = "Edit") && !!this.TelemetryViewer.SelectedLap)
	}

	updateTrackSections(save := false, async := true) {
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

		saveTrackMap() {
			local index, section

			removeMultiMapValues(this.TrackMap, "Sections")

			setMultiMapValue(this.TrackMap, "Sections", "Count", this.TrackSections.Length)

			for index, section in sections {
				setMultiMapValue(this.TrackMap, "Sections", index . ".Nr", section.Nr)
				setMultiMapValue(this.TrackMap, "Sections", index . ".Type", section.Type)
				setMultiMapValue(this.TrackMap, "Sections", index . ".Index", section.Index)
				setMultiMapValue(this.TrackMap, "Sections", index . ".X", section.X)
				setMultiMapValue(this.TrackMap, "Sections", index . ".Y", section.Y)

				if (section.HasProp("Name") && (Trim(section.Name) != ""))
					setMultiMapValue(this.TrackMap, "Sections", index . ".Name", section.Name)
			}

			SessionDatabase().updateTrackMap(this.Simulator, this.Track, this.TrackMap)

			this.TelemetryViewer.trackMapChanged(this.TrackMap)
		}

		sections := this.TrackSections

		for index, section in sections
			section.Index := this.getTrackCoordinateIndex(section.X, section.Y)

		bubbleSort(&sections,  (a, b) => (a.Index > b.Index))

		for index, section in this.TrackSections
			section.Nr := ((section.Type = "Corner") ? ++corners : ++straights)

		if (save && this.TrackMap) {
			sections := this.TrackSections.Clone()

			if async
				Task.startTask(saveTrackMap, 0, kLowPriority)
			else
				saveTrackMap()
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

		this.Control["scanButton"].Visible := ((this.TrackMapMode = "Edit") && !!this.TelemetryViewer.SelectedLap)
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
		local x, y, newSection

		CoordMode("Mouse", "Screen")

		MouseGetPos(&x, &y)

		x := screen2Window(x)
		y := screen2Window(y)

		CoordMode("Mouse", oldCoordMode)

		newSection := this.chooseTrackSectionType(section)

		if (newSection = "Delete")
			this.deleteTrackSection(section)
		else if newSection
			this.updateTrackSection(newSection)
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
		local cornerLabel := translate("Corner")
		local straightLabel := translate("Straight")

		if (section && (section.Type = "Corner"))
			cornerLabel .= translate("...")

		sectionsMenu.Add(cornerLabel, (*) => (result := "Corner"))

		if (section && (section.Type = "Straight"))
			straightLabel .= translate("...")

		sectionsMenu.Add(straightLabel, (*) => (result := "Straight"))

		if section {
			if (section.Type = "Corner")
				sectionsMenu.Check(cornerLabel)
			else
				sectionsMenu.Check(straightLabel)

			sectionsMenu.Add()

			sectionsMenu.Add(translate("Delete"), (*) => (result := "Delete"))
		}

		sectionsMenu.Add()

		sectionsMenu.Add(translate("Cancel"), (*) => (result := "Cancel"))

		this.Window.Block()

		try {
			sectionsMenu.Show()

			while (!result && !GetKeyState("Esc"))
				Sleep(100)

			if (result = "Delete")
				return result
			else if (result && (result != "Cancel")) {
				if section {
					section := section.Clone()

					if ((result = "Corner") && (section.Type = "Corner")) {
						result := withBlockedWindows(InputBox, translate("Please enter the name of the corner:"), translate("Corner"), "w300 h100", section.HasProp("Name") ? section.Name : "")

						if (result.Result = "Ok")
							section.Name := result.Value

						result := "Corner"
					}
					else if ((result = "Straight") && (section.Type = "Straight")) {
						result := withBlockedWindows(InputBox, translate("Please enter the name of the straight:"), translate("Straight"), "w300 h100", section.HasProp("Name") ? section.Name : "")

						if (result.Result = "Ok")
							section.Name := result.Value

						result := "Straight"
					}
				}
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

			if (isSet(posX) && isSet(posY)) {
				brush := Gdip_BrushCreateSolid(0xffB0B0B0)

				r := Round(15 / (imgScale * 3))

				imgX := Round((marginX + offsetX + posX) * scale)
				imgY := Round((marginX + offsetY + posY) * scale)

				Gdip_FillEllipse(graphics, brush, imgX - r, imgY - r, r * 2, r * 2)

				Gdip_DeleteBrush(brush)
			}

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
	local name, names, x, y, ignore, channel, selected, tempLayout, checked1, checked2, inputResult, select

	static layoutsGui

	static telemetryViewer := false
	static result := false

	static channelsListView := false

	static layouts := []
	static layout := false

	checked(row) {
		local index := 0

		while (index := channelsListView.GetNext(index, "C"))
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
	else if (telemetryViewerOrCommand = "ChannelUp") {
		selected := channelsListView.GetNext()

		if selected {
			channel := channelsListView.GetText(selected)

			checked1 := checked(selected)
			checked2 := checked(selected - 1)

			channelsListView.Modify(selected, checked2 ? "Check" : "-Check", channelsListView.GetText(selected - 1))
			channelsListView.Modify(selected - 1, (checked1 ? "Check " : "-Check ") . "Select Vis", channel)

			editLayoutSettings("UpdateState")
		}
	}
	else if (telemetryViewerOrCommand = "ChannelDown") {
		selected := channelsListView.GetNext()

		if selected {
			channel := channelsListView.GetText(selected)

			checked1 := checked(selected)
			checked2 := checked(selected + 1)

			channelsListView.Modify(selected, checked2 ? "Check" : "-Check", channelsListView.GetText(selected + 1))
			channelsListView.Modify(selected + 1, (checked1 ? "Check " : "-Check ") . "Select Vis", channel)

			editLayoutSettings("UpdateState")
		}
	}
	else if (telemetryViewerOrCommand = "ChannelSelect")
		editLayoutSettings("UpdateState")
	else if (telemetryViewerOrCommand = "ChannelCheck") {
		if (!arguments[3] && !channelsListView.GetNext(0, "C"))
			channelsListView.Modify(arguments[2], "Check")
	}
	else if (telemetryViewerOrCommand = "LayoutNew") {
		inputResult := withBlockedWindows(InputBox, translate("Please enter the name of the new layout:"), translate("Telemetry Layouts"), "w300 h120")

		if (inputResult.Result = "Ok") {
			if layout
				editLayoutSettings("LayoutSave")

			name := inputResult.Value
			newName := name

			while layouts.Has(newName)
				newName := (name . translate(" (") . A_Index . translate(")"))

			layouts[newName] := {Name: newName, WidthZoom: 100, HeightZoom: 100
							   , Cluster: 1, Channels: [choose(kTelemetryChannels, (c) => c.HasProp("Size"))[1]]}

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
			channels := []
			selected := 0

			while (selected := channelsListView.GetNext(selected, "C")) {
				name := channelsListView.GetText(selected)

				if (name = translate("---------------------------------------------"))
					channels.Push("|")
				else
					channels.Push(choose(kTelemetryChannels, (c) => translate(c.Name) = name)[1])
			}

			layouts[layout.Name] := {Name: layout.Name
								   , WidthZoom: layoutsGui["zoomWSlider"].Value
								   , HeightZoom: layoutsGui["zoomHSlider"].Value
								   , Cluster: layoutsGui["clusterEdit"].Text
								   , Channels: channels}
		}
	}
	else if (telemetryViewerOrCommand = "LayoutSelect")
		editLayoutSettings("LayoutLoad", layouts[layoutsGui["layoutDropDown"].Text])
	else if (telemetryViewerOrCommand = "LayoutLoad") {
		if layout
			editLayoutSettings("LayoutSave")

		layout := arguments[1]

		layoutsGui["layoutDropDown"].Choose(inList(getKeys(layouts), layout.Name))
		layoutsGui["clusterEdit"].Text := (layout.HasProp("Cluster") ? layout.Cluster : 1)

		channelsListView.Delete()

		if layout {
			names := []

			for ignore, channel in layout.Channels {
				if (channel = "|")
					channelsListView.Add("Check", translate("---------------------------------------------"))
				else {
					names.Push(channel.Name)

					channelsListView.Add("Check", translate(channel.Name))
				}
			}

			for ignore, channel in choose(kTelemetryChannels, (c) => c.HasProp("Size"))
				if (!inList(names, channel.Name) && (channel.Channels.Length > 0))
					channelsListView.Add("", translate(channel.Name))

			layoutsGui["zoomWSlider"].Value := layout.WidthZoom
			layoutsGui["zoomHSlider"].Value := layout.HeightZoom
		}

		channelsListView.ModifyCol()
		channelsListView.ModifyCol(1, "AutoHdr")

		editLayoutSettings("AdjustCluster")
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
	else if (telemetryViewerOrCommand = "AdjustCluster") {
		select := ((arguments.Length > 0) && arguments[1])

		if (Trim(layoutsGui["clusterEdit"].Text) = "")
			layoutsGui["clusterEdit"].Text := 1

		currentGroups := 1

		loop channelsListView.GetCount()
			if (channelsListView.GetText(A_Index) = translate("---------------------------------------------"))
				currentGroups += 1

		if (layoutsGui["clusterEdit"].Text > currentGroups)
			loop Max(0, layoutsGui["clusterEdit"].Text - currentGroups) {
				channelsListView.Add("Check", translate("---------------------------------------------"))

				if select
					channelsListView.Modify(channelsListView.GetCount(), "+Select Vis")
			}

		if (layoutsGui["clusterEdit"].Text < currentGroups)
			loop Max(0, currentGroups - layoutsGui["clusterEdit"].Text)
				loop channelsListView.GetCount()
					if (channelsListView.GetText(channelsListView.GetCount() - A_Index + 1) = translate("---------------------------------------------")) {
						channelsListView.Delete(channelsListView.GetCount() - A_Index + 1)

						break
					}

		if select
			editLayoutSettings("UpdateState")
	}
	else if (telemetryViewerOrCommand = "UpdateState") {
		if ((layouts.Count <= 1) || !layout)
			layoutsGui["deleteButton"].Enabled := false
		else
			layoutsGui["deleteButton"].Enabled := true

		if layout {
			layoutsGui["clusterEdit"].Enabled := true

			if (Trim(layoutsGui["clusterEdit"].Text) = "") {
				layoutsGui["clusterEdit"].Text := 1

				editLayoutSettings("AdjustCluster")
			}
		}
		else {
			layoutsGui["clusterEdit"].Enabled := false

			layoutsGui["clusterEdit"].Text := ""
		}

		loop channelsListView.GetCount()
			if (channelsListView.GetText(A_Index) = translate("---------------------------------------------"))
				channelsListView.Modify(A_Index, "Check")

		selected := channelsListView.GetNext()

		if selected {
			if (selected = 1) {
				layoutsGui["upButton"].Enabled := false
				layoutsGui["downButton"].Enabled := true
			}
			else if (selected = channelsListView.GetCount()) {
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
		layoutsGui.Add("DropDownList", "x98 yp-4 w152 vlayoutDropDown").OnEvent("Change", editLayoutSettings.Bind("LayoutSelect"))

		layoutsGui.Add("Button", "x252 yp w23 h23 Center +0x200 vnewButton").OnEvent("Click", editLayoutSettings.Bind("LayoutNew"))
		setButtonIcon(layoutsGui["newButton"], kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		layoutsGui.Add("Button", "x277 yp w23 h23 Center +0x200 Disabled vdeleteButton").OnEvent("Click", editLayoutSettings.Bind("LayoutDelete"))
		setButtonIcon(layoutsGui["deleteButton"], kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

		layoutsGui.Add("Text", "x16 yp+26 w80", translate("Groups"))
		layoutsGui.Add("Edit", "x98 yp-2 w40 Number Limit1 vclusterEdit", 1)
		layoutsGui.Add("UpDown", "xp+32 yp-2 w18 h20 Range1-4", 1)

		layoutsGui["clusterEdit"].OnEvent("Change", (*) => editLayoutSettings("AdjustCluster", true))

		channelsListView := layoutsGui.Add("ListView", "x16 yp+30 w284 h300 AltSubmit -Multi -LV0x10 Checked NoSort NoSortHdr", collect(["Channel"], translate))
		channelsListView.OnEvent("Click", editLayoutSettings.Bind("ChannelSelect"))
		channelsListView.OnEvent("DoubleClick", editLayoutSettings.Bind("ChannelSelect"))
		channelsListView.OnEvent("ItemSelect", editLayoutSettings.Bind("ChannelSelect"))
		channelsListView.OnEvent("ItemCheck", editLayoutSettings.Bind("ChannelCheck"))

		layoutsGui.Add("Button", "x252 yp+302 w23 h23 Center +0x200 vupButton").OnEvent("Click", editLayoutSettings.Bind("ChannelUp"))
		setButtonIcon(layoutsGui["upButton"], kIconsDirectory . "Up Arrow.ico", 1, "L4 T4 R4 B4")
		layoutsGui.Add("Button", "x277 yp w23 h23 Center +0x200 Disabled vdownButton").OnEvent("Click", editLayoutSettings.Bind("ChannelDown"))
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

editTelemetrySettings(telemetryViewerOrCommand, arguments*) {
	local settingsGui

	static result := false

	static providerDropDown
	static endpointLabel
	static endpointEdit

	chooseProvider(*) {
		editTelemetrySettings("UpdateState")
	}

	if (telemetryViewerOrCommand == kOk)
		result := kOk
	else if (telemetryViewerOrCommand == kCancel)
		result := kCancel
	else if (telemetryViewerOrCommand == "UpdateState") {
		if (providerDropDown.Value = 1) {
			; endpointLabel.Visible := false
			; endpointEdit.Visible := false

			endpointEdit.Enabled := false
			endpointEdit.Text := translate("n/a")
		}
		else {
			; endpointLabel.Visible := true
			; endpointEdit.Visible := true

			endpointEdit.Enabled := true

			if ((Trim(endpointEdit.Text) = "") || (endpointEdit.Text = translate("n/a")))
				endpointEdit.Text := "http://localhost:5007/api"
		}
	}
	else {
		result := false

		settingsGui := Window({Options: "0x400000"}, translate("Telemetry"))

		settingsGui.SetFont("Norm", "Arial")

		settingsGui.Add("Text", "x16 y16 w90 h23 +0x200", translate("Telemetry Provider"))
		settingsGui.Add("Text", "x110 yp w160 h23 +0x200", "")

		providerDropDown := settingsGui.Add("DropDownList", "x110 yp+1 w160 Choose1", collect(["Internal", "Second Monitor"], translate))
		providerDropDown.OnEvent("Change", chooseProvider)

		endpointLabel := settingsGui.Add("Text", "x16 yp+30 w90 h23 +0x200", translate("Provider URL"))
		endpointEdit := settingsGui.Add("Edit", "x110 yp+1 w160 h21")

		settingsGui.Add("Button", "x60 yp+35 w80 h23 Default", translate("Ok")).OnEvent("Click", editTelemetrySettings.Bind(kOk))
		settingsGui.Add("Button", "x146 yp w80 h23", translate("&Cancel")).OnEvent("Click", editTelemetrySettings.Bind(kCancel))

		if (arguments[1] && (arguments[1] != "Internal")) {
			providerDropDown.Choose(2)

			endpointEdit.Text := string2Values("|", arguments[1])[2]

			editTelemetrySettings("UpdateState")
		}

		settingsGui.Opt("+Owner" . telemetryViewerOrCommand.Window.Hwnd)

		settingsGui.Show("AutoSize Center")

		editTelemetrySettings("UpdateState")

		while !result
			Sleep(100)

		try {
			if (result == kCancel)
				return false
			else if (result == kOk) {
				if (providerDropDown.Value = 1)
					return "Internal"
				else
					return ("Second Monitor|" . endpointEdit.Text)
			}
		}
		finally {
			settingsGui.Destroy()
		}
	}
}