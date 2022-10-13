;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Strategy Viewer                 ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include Libraries\Strategy.ahk
#Include Libraries\SessionDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variables Section                        ;;;
;;;-------------------------------------------------------------------------;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class StrategyViewer {
	static sChartID := 1

	iWindow := false
	iStrategyViewer := false

	Window[] {
		Get {
			return this.iWindow
		}
	}

	StrategyViewer[] {
		Get {
			return this.iStrategyViewer
		}
	}

	__New(window, strategyViewer := false) {
		this.iWIndow := window
		this.iStrategyViewer := strategyViewer
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

	createStrategyInfo(strategy) {
		local sessionDB := new SessionDatabase()
		local simulator := (strategy.Simulator ? strategy.Simulator : translate("Unknown"))
		local car := (strategy.Car ? strategy.Car : translate("Unknown"))
		local track := (strategy.Track ? strategy.Track : translate("Unknown"))
		local html := "<table>"

		html .= ("<tr><td><b>" . translate("Simulator:") . "</b></td><td>" . simulator . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Car:") . "</b></td><td>" . sessionDB.getCarName(simulator, car) . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Track:") . "</b></td><td>" . sessionDB.getTrackName(simulator, track) . "</td></tr>")

		if (strategy.SessionType = "Duration") {
			html .= ("<tr><td><b>" . translate("Duration:") . "</b></td><td>" . strategy.SessionLength . A_Space . translate("Minutes") . "</td></tr>")
			html .= ("<tr><td><b>" . translate("Laps:") . "</b></td><td>" . Round(strategy.getSessionLaps(), 1) . A_Space . translate("Laps") . "</td></tr>")
		}
		else {
			html .= ("<tr><td><b>" . translate("Laps:") . "</b></td><td>" . strategy.SessionLength . A_Space . translate("Laps") . "</td></tr>")
			html .= ("<tr><td><b>" . translate("Duration:") . "</b></td><td>" . Round(strategy.getSessionDuration() / 60) . A_Space . translate("Minutes") . "</td></tr>")
		}

		html .= ("<tr><td><b>" . translate("Weather:") . "</b></td><td>" . translate(strategy.Weather) . translate(" (") . strategy.AirTemperature . translate(" / ") . strategy.TrackTemperature . translate(")") . "</td></tr>")
		html .= "</table>"

		return html
	}

	createSetupInfo(strategy) {
		local html := "<table>"

		html .= ("<tr><td><b>" . translate("Fuel:") . "</b></td><td>" . Round(strategy.RemainingFuel, 1) . A_Space . translate("Liter") . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Compound:") . "</b></td><td>" . translate(compound(strategy.TyreCompound, strategy.TyreCompoundColor)) . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Pressures (hot):") . "</b></td><td>" . strategy.TyrePressures[true] . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Map:") . "</b></td><td>" . strategy.Map . "</td></tr>")
		html .= ("<tr><td><b>" . translate("TC:") . "</b></td><td>" . strategy.TC . "</td></tr>")
		html .= ("<tr><td><b>" . translate("ABS:") . "</b></td><td>" . strategy.ABS . "</td></tr>")
		html .= "</table>"

		return html
	}

	createStintsInfo(strategy, ByRef timeSeries, ByRef lapSeries, ByRef fuelSeries, ByRef tyreSeries) {
		local startStint := strategy.StartStint
		local html := "<table class=""table-std"">"
		local stints, drivers, maps, laps, lapTimes, fuelConsumptions, pitstopLaps, refuels, tyreChanges, weathers
		local lastDriver, lastMap, lastLap, lastLapTime, lastFuelConsumption, lastRefuel, lastPitstopLap
		local lastWeather, lastTyreChange, lastTyreLaps, ignore, pitstop, pitstopLap

		timeSeries := [strategy.SessionStartTime / 60]
		lapSeries := [strategy.StartLap]
		fuelSeries := [strategy.RemainingFuel]
		tyreSeries := [strategy.RemainingTyreLaps]

		if !strategy.LastPitstop {
			html .= ("<tr><th class=""th-std th-left"">" . translate("Stint") . "</th><th class=""th-std"">" . startStint . "</th></tr>")
			html .= ("<tr><th class=""th-std th-left"">" . translate("Driver") . "</th><td class=""td-std"">" . strategy.DriverName . "</td></tr>")
			html .= ("<tr><th class=""th-std th-left"">" . translate("Map") . "</th><td class=""td-std"">" . strategy.Map . "</td></tr>")
			html .= ("<tr><th class=""th-std th-left"">" . translate("Laps") . "</th><td class=""td-std"">" . strategy.RemainingLaps . "</td></tr>")
			html .= ("<tr><th class=""th-std th-left"">" . translate("Lap Time") . "</th><td class=""td-std"">" . this.lapTimeDisplayValue(strategy.AvgLapTime) . "</td></tr>")
			html .= ("<tr><th class=""th-std th-left"">" . translate("Consumption") . "</th><td class=""td-std"">" . strategy.FuelConsumption . "</td></tr>")
			html .= "</table>"

			timeSeries.Push(strategy.getSessionDuration() / 60)
			lapSeries.Push(strategy.getSessionLaps())
			fuelSeries.Push(strategy.RemainingFuel - (strategy.FuelConsumption * strategy.RemainingLaps))
			tyreSeries.Push(strategy.RemainingTyreLaps - strategy.RemainingLaps)
		}
		else {
			stints := []
			drivers := []
			maps := []
			laps := []
			lapTimes := []
			fuelConsumptions := []
			pitstopLaps := []
			refuels := []
			tyreChanges := []
			weathers := []

			lastDriver := strategy.DriverName
			lastMap := strategy.Map
			lastLap := strategy.StartLap
			lastLapTime := strategy.AvgLapTime
			lastFuelConsumption := strategy.FuelConsumption
			lastRefuel := ""
			lastPitstopLap := ""
			lastWeather := (translate(strategy.Weather) . translate(" (") . strategy.AirTemperature . translate(" / ") . strategy.TrackTemperature . translate(")"))
			lastTrackTemperature := strategy.TrackTemperature
			lastTyreChange := ""
			lastTyreLaps := strategy.RemainingTyreLaps

			for ignore, pitstop in strategy.Pitstops {
				pitstopLap := (pitstop.Lap - lastLap)

				stints.Push("<th class=""th-std"">" . (startStint + A_Index - 1) . "</th>")
				drivers.Push("<td class=""td-std"">" . lastDriver . "</td>")
				maps.Push("<td class=""td-std"">" . lastMap . "</td>")
				laps.Push("<td class=""td-std"">" . Max(pitstopLap, 0) . "</td>")
				lapTimes.Push("<td class=""td-std"">" . this.lapTimeDisplayValue(Round(lastLapTime, 1)) . "</td>")
				fuelConsumptions.Push("<td class=""td-std"">" . Round(lastFuelConsumption, 2) . "</td>")
				pitstopLaps.Push("<td class=""td-std"">" . lastPitstopLap . "</td>")
				weathers.Push("<td class=""td-std"">" . lastWeather . "</td>")
				refuels.Push("<td class=""td-std"">" . ((pitstop.Nr > 1) ? Ceil(lastRefuel) : "") . "</td>")
				tyreChanges.Push("<td class=""td-std"">" . lastTyreChange . "</td>")

				timeSeries.Push(pitstop.Time / 60)
				lapSeries.Push(pitstop.Lap)
				fuelSeries.Push(pitstop.RemainingFuel - pitstop.RefuelAmount)
				tyreSeries.Push(lastTyreLaps - (pitstop.Lap - lastLap))

				lastDriver := pitstop.DriverName
				lastMap := pitstop.Map
				lastLap := pitstop.Lap
				lastFuelConsumption := pitstop.FuelConsumption
				lastLapTime := pitstop.AvgLapTime
				lastWeather := (translate(pitstop.Weather) . translate(" (") . pitstop.AirTemperature . translate(" / ") . pitstop.TrackTemperature . translate(")"))
				lastRefuel := pitstop.RefuelAmount
				lastPitstopLap := pitstop.Lap
				lastTyreChange := (pitstop.TyreChange ? translate(compound(pitstop.TyreCompound, pitstop.TyreCompoundColor)) : translate("No"))
				lastTyreLaps := pitstop.RemainingTyreLaps

				timeSeries.Push((pitstop.Time + pitStop.Duration) / 60)
				lapSeries.Push(pitstop.Lap)
				fuelSeries.Push(pitstop.RemainingFuel)
				tyreSeries.Push(lastTyreLaps)
			}

			stints.Push("<th class=""th-std"">" . (strategy.Pitstops.Length() + startStint) . "</th>")
			drivers.Push("<td class=""td-std"">" . lastDriver . "</td>")
			maps.Push("<td class=""td-std"">" . lastMap . "</td>")
			laps.Push("<td class=""td-std"">" . strategy.LastPitstop.StintLaps . "</td>")
			lapTimes.Push("<td class=""td-std"">" . this.lapTimeDisplayValue(Round(lastLapTime, 1)) . "</td>")
			fuelConsumptions.Push("<td class=""td-std"">" . Round(lastFuelConsumption, 2) . "</td>")
			pitstopLaps.Push("<td class=""td-std"">" . lastPitstopLap . "</td>")
			weathers.Push("<td class=""td-std"">" . lastWeather . "</td>")
			refuels.Push("<td class=""td-std"">" . Ceil(lastRefuel) . "</td>")
			tyreChanges.Push("<td class=""td-std"">" . lastTyreChange . "</td>")

			timeSeries.Push((strategy.LastPitstop.Time + (strategy.LastPitstop.StintLaps * lastLapTime)) / 60)
			lapSeries.Push(lastLap + strategy.LastPitstop.StintLaps)
			fuelSeries.Push(strategy.LastPitstop.RemainingFuel - (strategy.LastPitstop.StintLaps * strategy.LastPitstop.FuelConsumption))
			tyreSeries.Push(lastTyreLaps - strategy.LastPitstop.StintLaps)

			html .= "<table class=""table-std"">"

			html .= ("<tr><th class=""th-std"">" . translate("Stint") . "</th>"
			       . "<th class=""th-std"">" . translate("Driver") . "</th>"
			       . "<th class=""th-std"">" . translate("Weather") . "</th>"
			       . "<th class=""th-std"">" . translate("Laps") . "</th>"
			       . "<th class=""th-std"">" . translate("Map") . "</th>"
			       . "<th class=""th-std"">" . translate("Lap Time") . "</th>"
			       . "<th class=""th-std"">" . translate("Consumption") . "</th>"
			       . "<th class=""th-std"">" . translate("Pitstop Lap") . "</th>"
			       . "<th class=""th-std"">" . translate("Refuel Amount") . "</th>"
			       . "<th class=""th-std"">" . translate("Tyre Change") . "</th>"
			   . "</tr>")

			loop % stints.Length()
				html .= ("<tr>" . stints[A_Index]
								. drivers[A_Index]
								. weathers[A_Index]
								. laps[A_Index]
								. maps[A_Index]
								. this.lapTimeDisplayValue(lapTimes[A_Index])
								. fuelConsumptions[A_Index]
								. pitstopLaps[A_Index]
								. refuels[A_Index]
								. tyreChanges[A_Index]
					   . "</tr>")

			html .= "</table>"
		}

		return html
	}

	createConsumablesChart(strategy, width, height, timeSeries, lapSeries, fuelSeries, tyreSeries, ByRef drawChartFunction, ByRef chartID) {
		local durationSession := (strategy.SessionType = "Duration")
		local ignore, time, xAxis

		chartID := StrategyViewer.sChartID++

		drawChartFunction := ("function drawChart" . chartID . "() {`nvar data = new google.visualization.DataTable();")

		if durationSession
			drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Lap") . "');")
		else
			drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Minute") . "');")

		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Fuel Level") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Tyre Life") . "');")

		drawChartFunction .= "`ndata.addRows(["

		for ignore, time in timeSeries {
			if (A_Index > 1)
				drawChartFunction .= ", "

			xAxis := (durationSession ? lapSeries[A_Index] : time)

			drawChartFunction .= ("[" . xAxis . ", " . fuelSeries[A_Index] . ", " . tyreSeries[A_Index] . "]")
		}

		drawChartFunction .= ("]);`nvar options = { curveType: 'function', legend: { position: 'Right' }, chartArea: { left: '10%', top: '5%', right: '25%', bottom: '20%' }, hAxis: { title: '" . (durationSession ? translate("Lap") : translate("Minute")) . "' }, vAxis: { viewWindow: { min: 0 } }, backgroundColor: 'D8D8D8' };`n")

		drawChartFunction .= ("`nvar chart = new google.visualization.LineChart(document.getElementById('chart_" . chartID . "')); chart.draw(data, options); }")

		return ("<div id=""chart_" . chartID . """ style=""width: " . width . "px; height: " . height . "px"">")
	}

	showStrategyInfo(strategy) {
		local html := ""
		local timeSeries, lapSeries, fuelSeries, tyreSeries, drawChartFunction, chartID, width, chartArea
		local before, after, tableCSS

		if !this.StrategyViewer
			strategy := false

		if strategy {
			html := ("<div id=""header""><b>" . translate("Strategy: ") . strategy.Name . "</b></div>")

			html .= ("<br><br><div id=""header""><i>" . translate("Session") . "</i></div>")

			html .= ("<br><br>" . this.createStrategyInfo(strategy))

			html .= ("<br><br><div id=""header""><i>" . translate("Setup") . "</i></div>")

			html .= ("<br><br>" . this.createSetupInfo(strategy))

			html .= ("<br><br><div id=""header""><i>" . translate("Stints") . "</i></div>")

			timeSeries := []
			lapSeries := []
			fuelSeries := []
			tyreSeries := []

			html .= ("<br><br>" . this.createStintsInfo(strategy, timeSeries, lapSeries, fuelSeries, tyreSeries))

			html .= ("<br><br><div id=""header""><i>" . translate("Consumables") . "</i></div>")

			drawChartFunction := false
			chartID := false

			width := (this.StrategyViewer.Width - 10)

			chartArea := this.createConsumablesChart(strategy, width, width / 2, timeSeries, lapSeries, fuelSeries, tyreSeries, drawChartFunction, chartID)

			before =
			(
				<meta charset='utf-8'>
				<head>
					<style>
						.headerStyle { height: 25; font-size: 11px; font-weight: 500; background-color: 'FFFFFF'; }
						.rowStyle { font-size: 11px; background-color: 'E0E0E0'; }
						.oddRowStyle { font-size: 11px; background-color: 'E8E8E8'; }
					</style>
					<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
					<script type="text/javascript">
						google.charts.load('current', {'packages':['corechart', 'table', 'scatter']}).then(drawChart%chartID%);
			)

			after =
			(
					</script>
				</head>
			)
		}
		else {
			before := ""
			after := ""
			drawChartFunction := ""
			chartArea := ""
		}

		tableCSS := getTableCSS()

		html := ("<html>" . before . drawChartFunction . after . "<body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><style> div, table { font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><style>" . tableCSS . "</style><style> #header { font-size: 12px; } </style><div>" . html . "</div><br>" . chartArea . "</body></html>")

		if this.StrategyViewer {
			this.StrategyViewer.Document.Open()
			this.StrategyViewer.Document.Write(html)
			this.StrategyViewer.Document.Close()
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Public Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

getTableCSS() {
	local script

	script =
	(
		.table-std, .th-std, .td-std {
			border-collapse: collapse;
			padding: .3em .5em;
		}

		.th-std, .td-std {
			text-align: center;
		}

		.th-std, .caption-std {
			background-color: #BBB;
			color: #000;
			border: thin solid #BBB;
		}

		.td-std {
			border-left: thin solid #BBB;
			border-right: thin solid #BBB;
		}

		.th-left {
			text-align: left;
		}

		tfoot {
			border-bottom: thin solid #BBB;
		}

		.caption-std {
			font-size: 1.5em;
			border-radius: .5em .5em 0 0;
			padding: .5em 0 0 0
		}

		.table-std tbody tr:nth-child(even) {
			background-color: #D8D8D8;
		}

		.table-std tbody tr:nth-child(odd) {
			background-color: #D0D0D0;
		}
	)

	return script
}