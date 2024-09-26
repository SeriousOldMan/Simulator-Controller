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
#Include "SessionDatabase.ahk"
#Include "SessionDatabaseBrowser.ahk"
#Include "TelemetryCollector.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class TelemetryChart {
	static sChartID := 1

	iWindow := false

	iTelemetryViewer := false

	iZoom := 100

	Window {
		Get {
			return this.iWindow
		}
	}

	TelemetryViewer {
		Get {
			return this.iTelemetryViewer
		}
	}

	Zoom {
		Get {
			return this.iZoom
		}

		Set {
			return (this.iZoom := value)
		}
	}

	__New(window, telemetryViewer := false) {
		this.iWindow := window
		this.iTelemetryViewer := telemetryViewer
	}

	showTelemetryChart(lapFileName, referenceLapFileName := false) {
		if this.TelemetryViewer {
			this.TelemetryViewer.document.open()
			this.TelemetryViewer.document.write(this.createTelemetryChart(lapFileName, referenceLapFileName))
			this.TelemetryViewer.document.close()
		}
	}

	createTelemetryChart(lapFileName, referenceLapFileName := false, margin := 0) {
		local lapTelemetry := []
		local referenceLapTelemetry := false
		local html := ""
		local width, height
		local drawChartFunction1, chartID1, chartArea1, drawChartFunction2, chartID2, chartArea2
		local drawChartFunction3, chartID3, chartArea3
		local before, after, margins
		local entry, index, field, running

		if lapFileName
			loop Read, lapFileName {
				entry := string2Values(";", A_LoopReadLine)

				for index, value in entry
					if !isNumber(value)
						entry[index] := kNull

				lapTelemetry.Push(entry)
			}

		if referenceLapFileName {
			referenceLapTelemetry := Map()

			loop Read, referenceLapFileName {
				entry := string2Values(";", A_LoopReadLine)

				running := kNull

				for index, value in entry
					if !isNumber(value)
						entry[index] := kNull
					else if (index = 1)
						running := entry[index] := (Round(entry[index] / 5) * 5)

				referenceLapTelemetry[running] := entry
			}
		}

		if this.TelemetryViewer {
			width := ((this.TelemetryViewer.getWidth() - 4) / 100 * this.Zoom)
			height := (this.TelemetryViewer.getHeight() - 4)

			chartArea1 := this.createSpeedChart(width, height / 3 * 2, lapTelemetry, referenceLapTelemetry, &drawChartFunction1, &chartID1)
			chartArea2 := this.createElectronicsChart(width, height / 3, lapTelemetry, referenceLapTelemetry, &drawChartFunction2, &chartID2)
			chartArea3 := this.createAccelerationChart(width, height / 3, lapTelemetry, referenceLapTelemetry, &drawChartFunction3, &chartID3)

			if chartArea3
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
						<script type="text/javascript">function drawCharts() { drawChart%chartID1%(); drawChart%chartID2%(); drawChart%chartID3%() }</script>
						<script type="text/javascript">
							google.charts.load('current', {'packages':['corechart', 'table', 'scatter']}).then(drawCharts);
				)"
			else {
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
						<script type="text/javascript">function drawCharts() { drawChart%chartID1%(); drawChart%chartID2%() }</script>
						<script type="text/javascript">
							google.charts.load('current', {'packages':['corechart', 'table', 'scatter']}).then(drawCharts);
				)"

				chartID3 := false
			}

			before := substituteVariables(before, {fontColor: this.Window.Theme.TextColor
												 , headerBackColor: this.Window.Theme.ListBackColor["Header"]
												 , evenRowBackColor: this.Window.Theme.ListBackColor["EvenRow"]
												 , oddRowBackColor: this.Window.Theme.ListBackColor["OddRow"]
												 , chartID1: chartID1, chartID2: chartID2, chartID3: chartID3})

			after := "
			(
					</script>
				</head>
			)"

			margins := substituteVariables("style='overflow: auto' leftmargin='%margin%' topmargin='%margin%' rightmargin='%margin%' bottommargin='%margin%'"
										 , {margin: margin})

			return ("<html>" . before . drawChartFunction1 . "`n" . drawChartFunction2 . (chartArea3 ? ("`n" . drawChartFunction3) : "") . after . "<body style='background-color: #" . this.Window.AltBackColor . "' " . margins . "><style> div, table { color: '" . this.Window.Theme.TextColor . "'; font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><style> #header { font-size: 12px; } table, p, div { color: #" . this.Window.Theme.TextColor . " } </style>" . chartArea1 . chartArea2 . (chartArea3 ? chartArea3 : "") . "</body></html>")
		}
		else
			return "<html></html>"
	}

	createSpeedChart(width, height, lapTelemetry, referenceLapTelemetry, &drawChartFunction, &chartID) {
		local speedMin := 9999
		local speedMax := 0
		local ignore, data, refData, axes, speed, refSpeed, color, running, refRunning

		chartID := TelemetryChart.sChartID++
		drawChartFunction := ("function drawChart" . chartID . "() {`nvar data = new google.visualization.DataTable();")

		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Distance") . "');")

		if referenceLapTelemetry {
			drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Speed") . translate(" (Reference)") . "');")
			drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Throttle") . translate(" (Reference)") . "');")
			drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Brake") . translate(" (Reference)") . "');")
			drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Steering") . translate(" (Reference)") . "');")
		}

		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Speed") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Throttle") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Brake") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Steering") . "');")

		drawChartFunction .= "`ndata.addRows(["

		for ignore, data in lapTelemetry {
			if (A_Index = 1)
				continue
			else if (A_Index > 2)
				drawChartFunction .= ", "

			running := data[1]
			speed := data[7]

			if (speed > 0) {
				speed := convertUnit("Speed", speed)

				speedMin := Min(speedMin, speed)
				speedMax := Max(speedMax, speed)
			}
			else
				speed := kNull

			if referenceLapTelemetry {
				refRunning := (Round(running / 5) * 5)

				if referenceLapTelemetry.Has(refRunning) {
					refData := referenceLapTelemetry[refRunning]

					refSpeed := refData[7]

					if (refSpeed = 0)
						refSpeed := kNull

					drawChartFunction .= ("[" . running . ", " . refSpeed . ", " . refData[2] . ", " . refData[3] . ", " . refData[4] . ", " . speed . ", " . data[2] . ", " . data[3] . ", " . data[4] . "]")
				}
				else
					drawChartFunction .= ("[" . running . ", null, null, null, null, " . speed . ", " . data[2] . ", " . data[3] . ", " . data[4] . "]")
			}
			else
				drawChartFunction .= ("[" . running . ", " . speed . ", " . data[2] . ", " . data[3] . ", " . data[4] . "]")
		}

		if referenceLapTelemetry {
			color := this.Window.Theme.TextColor["Disabled"]

			axes := "series: { 0: {targetAxisIndex: 0, color: '" . color . "'}, 1: {targetAxisIndex: 1, color: '" . color . "'}, 2: {targetAxisIndex: 2, color: '" . color . "'}, 3: {targetAxisIndex: 3, color: '" . color . "'}, 4: {targetAxisIndex: 4}, 5: {targetAxisIndex: 5}, 6: {targetAxisIndex: 6}, 7: {targetAxisIndex: 7} },`n"
			axes .= "hAxes: {gridlines: {count: 0}, ticks: []}, vAxes: { 0: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: " . (speedMax - ((speedMax - speedMin) * 3)) . " }, 1: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue : -2, maxValue: 5 }, 2: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: -2, maxValue: 5 }, 3: { gridlines: {count: 0}, ticks: [], minValue: -1, maxValue: 5 }, 4: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: " . (speedMax - ((speedMax - speedMin) * 3)) . " }, 5: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue : -2, maxValue: 5 }, 6: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: -2, maxValue: 5 },  7: { gridlines: {count: 0}, ticks: [], minValue: -1, maxValue: 5 } }"
		}
		else {
			axes := "series: { 0: {targetAxisIndex: 0}, 1: {targetAxisIndex: 1}, 2: {targetAxisIndex: 2}, 3: {targetAxisIndex: 3} },`n"
			axes .= "hAxes: {gridlines: {count: 0}, ticks: []}, vAxes: { 0: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: " . (speedMax - ((speedMax - speedMin) * 3)) . " }, 1: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue : -2, maxValue: 5 }, 2: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: -2, maxValue: 5 }, 3: { gridlines: {count: 0}, ticks: [], minValue: -1, maxValue: 5 } }"
		}

		drawChartFunction .= ("]);`nvar options = { " . axes . ", legend: { position: 'bottom', textStyle: { color: '" . this.Window.Theme.TextColor . "'} }, chartArea: { left: '2%', top: '5%', right: '2%', bottom: '20%' }, backgroundColor: '" . this.Window.AltBackColor . "' };`n")

		drawChartFunction .= ("`nvar chart = new google.visualization.LineChart(document.getElementById('chart_" . chartID . "')); chart.draw(data, options); }")

		return ("<div id=`"chart_" . chartID . "`" style=`"width: " . Round(width) . "px; height: " . Round(height) . "px`"></div>")
	}

	createElectronicsChart(width, height, lapTelemetry, referenceLapTelemetry, &drawChartFunction, &chartID) {
		local rpmsMin := 99999
		local rpmsMax := 0
		local ignore, data, refData, rpms, refRpms, axes, color, running, refRunning

		chartID := TelemetryChart.sChartID++
		drawChartFunction := ("function drawChart" . chartID . "() {`nvar data = new google.visualization.DataTable();")

		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Distance") . "');")

		if referenceLapTelemetry {
			drawChartFunction .= ("`ndata.addColumn('number', '" . translate("RPM") . translate(" (Reference)") . "');")
			drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Gear") . translate(" (Reference)") . "');")
			drawChartFunction .= ("`ndata.addColumn('number', '" . translate("TC") . translate(" (Reference)") . "');")
			drawChartFunction .= ("`ndata.addColumn('number', '" . translate("ABS") . translate(" (Reference)") . "');")
		}

		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("RPM") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Gear") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("TC") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("ABS") . "');")

		drawChartFunction .= "`ndata.addRows(["

		for ignore, data in lapTelemetry {
			if (A_Index = 1)
				continue
			else if (A_Index > 2)
				drawChartFunction .= ", "

			running := data[1]
			rpms := data[6]

			if (rpms > 0) {
				rpmsMin := Min(rpmsMin, rpms)
				rpmsMax := Max(rpmsMax, rpms)
			}
			else
				rpms := kNull

			if referenceLapTelemetry {
				refRunning := (Round(running / 5) * 5)

				if referenceLapTelemetry.Has(refRunning) {
					refData := referenceLapTelemetry[refRunning]

					refRpms := refData[6]

					if (refRpms = 0)
						refRpms := kNull

					drawChartFunction .= ("[" . running . ", " . refRpms . ", " . refData[5] . ", " . refData[8] . ", " . refData[9] . ", " . rpms . ", " . data[5] . ", " . data[8] . ", " . data[9] . "]")
				}
				else
					drawChartFunction .= ("[" . running . ", null, null, null, null, " . rpms . ", " . data[5] . ", " . data[8] . ", " . data[9] . "]")
			}
			else
				drawChartFunction .= ("[" . running . ", " . rpms . ", " . data[5] . ", " . data[8] . ", " . data[9] . "]")
		}

		if referenceLapTelemetry {
			color := this.Window.Theme.TextColor["Disabled"]

			axes := "series: { 0: {targetAxisIndex: 0, color: '" . color . "'}, 1: {targetAxisIndex: 1, color: '" . color . "'}, 2: {targetAxisIndex: 2, color: '" . color . "'}, 3: {targetAxisIndex: 3, color: '" . color . "'}, 4: {targetAxisIndex: 4}, 5: {targetAxisIndex: 5}, 6: {targetAxisIndex: 6}, 7: {targetAxisIndex: 7} },`n"
			axes .= "hAxes: {gridlines: {count: 0}, ticks: []}, vAxes: { 0: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: " . (rpmsMax - ((rpmsMax - rpmsMin) * 3)) . " }, 1: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue : -2, maxValue: 10 }, 2: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: -1, maxValue: 5 }, 3: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: -1, maxValue: 5 }, 4: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: " . (rpmsMax - ((rpmsMax - rpmsMin) * 3)) . " }, 5: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue : -2, maxValue: 10 }, 6: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: -1, maxValue: 5 },  7: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: -1, maxValue: 5 } }"
		}
		else {
			axes := "series: { 0: {targetAxisIndex: 0}, 1: {targetAxisIndex: 1}, 2: {targetAxisIndex: 2}, 3: {targetAxisIndex: 3} },`n"
			axes .= "hAxes: {gridlines: {count: 0}, ticks: []}, vAxes: { 0: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: " . (rpmsMax - ((rpmsMax - rpmsMin) * 3)) . " }, 1: { baselineColor: '" . this.Window.AltBackColor . "', baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue : -2, maxValue: 10 }, 2: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: -1, maxValue: 5 }, 3: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: -1, maxValue: 5 } }"
		}

		drawChartFunction .= ("]);`nvar options = { " . axes . ", legend: { position: 'bottom', textStyle: { color: '" . this.Window.Theme.TextColor . "'} }, chartArea: { left: '2%', top: '5%', right: '2%', bottom: '20%' }, backgroundColor: '" . this.Window.AltBackColor . "' };`n")

		drawChartFunction .= ("`nvar chart = new google.visualization.LineChart(document.getElementById('chart_" . chartID . "')); chart.draw(data, options); }")

		return ("<div id=`"chart_" . chartID . "`" style=`"width: " . Round(width) . "px; height: " . Round(height) . "px`"></div>")
	}

	createAccelerationChart(width, height, lapTelemetry, referenceLapTelemetry, &drawChartFunction, &chartID) {
		local accelMin := kUndefined
		local accelMax := kUndefined
		local curvMin := kUndefined
		local curvMax := kUndefined
		local ignore, data, refData, longG, latG, refLongG, refLatG, axes, color, running, refRunning, curvature, speed, absG

		chartID := TelemetryChart.sChartID++
		drawChartFunction := ("function drawChart" . chartID . "() {`nvar data = new google.visualization.DataTable();")

		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Distance") . "');")

		if referenceLapTelemetry {
			drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Long G") . translate(" (Reference)") . "');")
			drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Lat G") . translate(" (Reference)") . "');")
		}

		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Long G") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Lat G") . "');")

		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Curvature") . "');")

		drawChartFunction .= "`ndata.addRows(["

		if (lapTelemetry.Length = 0)
			return false

		for ignore, data in lapTelemetry {
			if (data.Length < 10)
				return false

			if (A_Index = 1)
				continue
			else if (A_Index > 2)
				drawChartFunction .= ", "

			running := data[1]

			longG := data[10]
			latG := data[11]

			if (accelMin = kUndefined) {
				accelMin := longG
				accelMax := longG
			}
			else {
				accelMin := Min(accelMin, longG)
				accelMax := Max(accelMax, longG)
			}

			accelMin := Min(accelMin, latG)
			accelMax := Max(accelMax, latG)

			speed := data[7]

			absG := Abs(latG)

			if (absG > 0.1) {
				curvature := - Log(((speed / 3.6) ** 2) / ((absG = 0) ? 0.00001 : absG))

				if (curvMin = kUndefined) {
					curvMin := curvature
					curvMax := curvature
				}
				else {
					curvMin := Min(curvMin, curvature)
					curvMax := Max(curvMax, curvature)
				}
			}
			else
				curvature := kNull

			if referenceLapTelemetry {
				refRunning := (Round(running / 5) * 5)

				if referenceLapTelemetry.Has(refRunning) {
					refData := referenceLapTelemetry[refRunning]

					if (refData.Length >= 10) {
						refLongG := refData[10]
						refLatG := refData[11]

						accelMin := Min(accelMin, refLongG)
						accelMax := Max(accelMax, refLongG)
						accelMin := Min(accelMin, refLatG)
						accelMax := Max(accelMax, refLatG)

						drawChartFunction .= ("[" . running . ", " . refLongG . ", " . refLatG . ", " . longG . ", " . latG . ", " . curvature . "]")
					}
					else
						drawChartFunction .= ("[" . running . ", null, null, " . longG . ", " . latG . ", " . curvature . "]")
				}
				else
					drawChartFunction .= ("[" . running . ", null, null, " . longG . ", " . latG . ", " . curvature . "]")
			}
			else
				drawChartFunction .= ("[" . running . ", " . longG . ", " . latG . ", " . curvature . "]")
		}

		if (accelMin = kUndefined) {
			accelMin := 0
			accelMax := 0
		}
		else
			accelMin := (accelMax - ((accelMax - accelMin) * 2))

		if (curvMin = kUndefined) {
			curvMin := 0
			curvMax := 0
		}
		else
			curvMax := (curvMax + ((curvMax - curvMin) * 2))

		if referenceLapTelemetry {
			color := this.Window.Theme.TextColor["Disabled"]

			axes := "series: { 0: {targetAxisIndex: 0, color: '" . color . "'}, 1: {targetAxisIndex: 1, color: '" . color . "'}, 2: {targetAxisIndex: 2}, 3: {targetAxisIndex: 3}, 4: {targetAxisIndex: 4} },`n"
			axes .= "hAxes: {gridlines: {count: 0}, ticks: [] }, vAxes: { 0: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: " . accelMin . ", maxValue: " . accelMax . " }, 1: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: " . accelMin . ", maxValue: " . accelMax . " }, 2: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: " . accelMin . ", maxValue: " . accelMax . " }, 3: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: " . accelMin . ", maxValue: " . accelMax . " }, 4: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: " . curvMin . ", maxValue: " . curvMax . " } }"
		}
		else {
			axes := "series: { 0: {targetAxisIndex: 0}, 1: {targetAxisIndex: 1}, 2: {targetAxisIndex: 2} },`n"
			axes .= "hAxes: {gridlines: {count: 0}, ticks: []}, vAxes: { 0: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: " . accelMin . ", maxValue: " . accelMax . " }, 1: { baselineColor: '" . this.Window.AltBackColor . "', baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: " . accelMin . ", maxValue: " . accelMax . " }, 2: { baselineColor: '" . this.Window.AltBackColor . "', gridlines: {count: 0}, ticks: [], minValue: " . curvMin . ", maxValue: " . curvMax . " } }"
		}

		drawChartFunction .= ("]);`nvar options = { " . axes . ", legend: { position: 'bottom', textStyle: { color: '" . this.Window.Theme.TextColor . "'} }, chartArea: { left: '2%', top: '5%', right: '2%', bottom: '20%' }, backgroundColor: '" . this.Window.AltBackColor . "' };`n")

		drawChartFunction .= ("`nvar chart = new google.visualization.LineChart(document.getElementById('chart_" . chartID . "')); chart.draw(data, options); }")

		return ("<div id=`"chart_" . chartID . "`" style=`"width: " . Round(width) . "px; height: " . Round(height) . "px`"></div>")
	}
}

class TelemetryViewer {
	iManager := false

	iTelemetryDirectory := false
	iTelemetryCollector := false

	iWindow := false

	iTelemetryChart := false

	iLaps := []
	iImportedLaps := []

	iLap := false
	iReferenceLap := false

	iCollectorTask := false

	iCollect := false

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

			super.__New(arguments*)

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

					this.iTelemetryViewer.TelemetryChart.TelemetryViewer.Resized()

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
				return (path ? this.iLap[3] : this.iLap)
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
				return (path ? this.iReferenceLap[3] : this.iReferenceLap[1])
		}

		Set {
			this.iReferenceLap := value

			this.updateTelemetryChart(true)

			return value
		}
	}

	Collect {
		Get {
			return this.iCollect
		}
	}

	__New(manager, directory, collect := true) {
		this.iManager := manager
		this.iTelemetryDirectory := (normalizeDirectoryPath(directory) . "\")

		this.iCollect := collect
	}

	createGui() {
		local viewerGui := TelemetryViewer.TelemetryViewerWindow(this, {Descriptor: "Telemetry Browser", Closeable: true, Resizeable:  "Deferred"})
		local viewerControl

		changeZoom(*) {
			this.TelemetryChart.Zoom := viewerGui["zoomSlider"].Value

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

		this.iWindow := viewerGui

		viewerGui.SetFont("s10 Bold", "Arial")

		viewerGui.Add("Text", "w656 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(viewerGui, "Telemetry Browser"))

		viewerGui.SetFont("s9 Norm", "Arial")

		viewerGui.Add("Documentation", "x176 YP+20 w336 H:Center Center", translate("Telemetry Browser")
					 , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Solo-Center#Telemetry-Browser")

		viewerGui.Add("Text", "x8 yp+30 w656 W:Grow 0x10")

		viewerGui.SetFont("s8 Norm", "Arial")

		viewerGui.Add("Text", "x16 yp+10 w80", translate("Lap"))
		viewerGui.Add("DropDownList", "x98 yp-4 w280 vlapDropDown", collect(this.Laps, (l) => this.lapLabel(l))).OnEvent("Change", chooseLap)

		viewerGui.Add("Button", "x380 yp w23 h23 Center +0x200 Disabled vloadButton").OnEvent("Click", loadLap)
		setButtonIcon(viewerGui["loadButton"], kIconsDirectory . "Load.ico", 1, "L4 T4 R4 B4")
		viewerGui.Add("Button", "x404 yp w23 h23 Center +0x200 Disabled vsaveButton").OnEvent("Click", saveLap)
		setButtonIcon(viewerGui["saveButton"], kIconsDirectory . "Save.ico", 1, "L4 T4 R4 B4")
		viewerGui.Add("Button", "x430 yp w23 h23 Center +0x200 vdeleteButton").OnEvent("Click", deleteLap)
		setButtonIcon(viewerGui["deleteButton"], kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

		viewerGui.Add("Text", "x16 yp+28 w80", translate("Reference"))
		viewerGui.Add("DropDownList", "x98 yp-4 w280 Choose1 vreferenceLapDropDown", concatenate([translate("None")], collect(this.Laps, (l) => this.lapLabel(l)))).OnEvent("Change", chooseReferenceLap)

		viewerGui.Add("Text", "x468 yp+4 w80 X:Move", translate("Zoom"))
		viewerGui.Add("Slider", "Center Thick15 x556 yp-2 X:Move w100 0x10 Range100-400 ToolTip vzoomSlider", 100).OnEvent("Change", changeZoom)

		viewerControl := viewerGui.Add("HTMLViewer", "x16 yp+24 w640 h480 W:Grow H:Grow Border")

		viewerControl.document.open()
		viewerControl.document.write("")
		viewerControl.document.close()

		this.iTelemetryChart := TelemetryChart(viewerGui, viewerControl)

		viewerGui.Add(TelemetryViewer.TelemetryViewerResizer(this, viewerControl))

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

		this.loadTelemetry()

		this.updateTelemetryChart(true)

		if this.Collect {
			if this.iCollectorTask
				this.iCollectorTask.stop()

			this.iCollectorTask := PeriodicTask(ObjBindMethod(this, "loadTelemetry"), 10000, kLowPriority)

			this.iCollectorTask.start()
		}
	}

	close() {
		this.shutdownCollector()

		if this.iCollectorTask {
			this.iCollectorTask.stop()

			this.iCollectorTask := false
		}

		this.Manager.closedTelemetryViewer()

		this.Window.Destroy()
	}

	updateState() {
		this.Control["loadButton"].Enabled := true

		if this.SelectedLap
			this.Control["deleteButton"].Enabled := true
		else
			this.Control["deleteButton"].Enabled := false

		if (this.SelectedLap && isNumber(this.SelectedLap))
			this.Control["saveButton"].Enabled := true
		else
			this.Control["saveButton"].Enabled := false
	}

	startupCollector(simulator, trackLength) {
		if !this.TelemetryCollector {
			this.iTelemetryCollector := TelemetryCollector(this.TelemetryDirectory, simulator, trackLength)

			this.iTelemetryCollector.startup()
		}
	}

	shutdownCollector() {
		if this.TelemetryCollector {
			this.TelemetryCollector.shutdown()

			this.iTelemetryCollector := false
		}
	}

	restart(directory, collect := true) {
		this.selectLap(false, true)
		this.selectReferenceLap(false, true)

		this.Laps := []
		this.ImportedLaps := []

		this.iTelemetryDirectory := (normalizeDirectoryPath(directory) . "\")

		if this.Window {
			this.Control["lapDropDown"].Delete()
			this.Control["referenceLapDropDown"].Delete()

			this.Control["referenceLapDropDown"].Add([translate("None")])
			this.Control["referenceLapDropDown"].Choose(1)

			this.updateState()
		}

		if collect
			OnExit(ObjBindMethod(this, "shutdownTelemetryCollector", true))
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

	loadLap(fileName := false, driver := false) {
		local name := false
		local telemetry := false
		local info := false
		local simulator, car, track
		local sessionDB, directory, dataFile, file, size, lap

		this.Manager.getSessionInformation(&simulator, &car, &track)

		sessionDB := SessionDatabase()

		if !fileName {
			this.Window.Opt("+OwnDialogs")

			this.Window.Block()

			try {
				fileName := browseLapTelemetries(this.Window, &simulator, &car, &track)
			}
			finally {
				this.Window.Unblock()
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
				lap := [name, driver ? driver
									 : SessionDatabase.getDriverName(simulator, getMultiMapValue(info, "Telemetry", "Driver"))
					  , telemetry]
			else
				lap := [name, driver ? driver : "John Doe (JD)", telemetry]

			this.ImportedLaps.Push(lap)

			this.loadTelemetry(lap)
		}
	}

	saveLap(lap := false, prompt := true) {
		local simulator, car, track
		local sessionDB, dirName, fileName, newFileName, file, folder, telemetry

		this.Manager.getSessionInformation(&simulator, &car, &track)

		if !lap
			lap := this.SelectedLap

		if (lap && isNumber(lap)) {
			if (simulator && car && track) {
				dirName := (SessionDatabase.DatabasePath . "User\" . SessionDatabase.getSimulatorCode(simulator)
						  . "\" . car . "\" . track . "\Lap Telemetries")

				DirCreate(dirName)
			}
			else
				dirName := ""

			fileName := (dirName . "\Lap " . lap)

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
						file := FileOpen((this.TelemetryDirectory . "Lap " . lap . ".telemetry"), "r-wd")

						if file {
							size := file.Length

							telemetry := Buffer(size)

							file.RawRead(telemetry, size)

							file.Close()

							sessionDB.writeTelemetry(simulator, car, track, fileName, telemetry, size
												   , false, true, SessionDatabase.ID)

							return
						}
					}

					DirCreate(folder)
					FileCopy(this.TelemetryDirectory . "Lap " . lap . ".telemetry"
						   , folder . "\" . fileName . ".telemetry", 1)
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
			else
				return lap
		}
		else
			return (lap[1] . translate(":") . A_Space . lap[2])
	}

	loadTelemetry(select := false) {
		local laps := []
		local lap, name

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
				this.Control["lapDropDown"].Choose(inList(this.Laps, this.SelectedLap))
				this.Control["referenceLapDropDown"].Choose(1 + inList(this.Laps, this.SelectedReferenceLap))
			}

			this.updateState()
		}
	}

	updateTelemetryChart(redraw := false) {
		if (this.TelemetryChart && redraw)
			this.TelemetryChart.showTelemetryChart(this.SelectedLap[true], this.SelectedReferenceLap[true])
	}
}