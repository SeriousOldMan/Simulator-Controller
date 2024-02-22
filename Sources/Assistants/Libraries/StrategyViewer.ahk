;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Strategy Viewer                 ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Strategy.ahk"
#Include "..\..\Libraries\HTMLViewer.ahk"
#Include "..\..\Database\Libraries\SessionDatabase.ahk"


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

	Window {
		Get {
			return this.iWindow
		}
	}

	StrategyViewer {
		Get {
			return this.iStrategyViewer
		}
	}

	__New(window, strategyViewer := false) {
		this.iWindow := window
		this.iStrategyViewer := strategyViewer
	}

	static lapTimeDisplayValue(lapTime) {
		local seconds, fraction, minutes

		if isNumber(lapTime)
			return displayValue("Time", lapTime)
		else
			return lapTime
	}

	createStrategyInfo(strategy) {
		local sessionDB := SessionDatabase()
		local simulator := (strategy.Simulator ? strategy.Simulator : translate("Unknown"))
		local car := (strategy.Car ? strategy.Car : translate("Unknown"))
		local track := (strategy.Track ? strategy.Track : translate("Unknown"))
		local html := "<table>"

		html .= ("<tr><td><b>" . translate("Simulator:") . "</b></td><td>" . simulator . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Car:") . "</b></td><td>" . sessionDB.getCarName(simulator, car) . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Track:") . "</b></td><td>" . sessionDB.getTrackName(simulator, track) . "</td></tr>")

		if (strategy.SessionType = "Duration") {
			html .= ("<tr><td><b>" . translate("Duration:") . "</b></td><td>" . strategy.SessionLength . A_Space . translate("(") . Round(strategy.getSessionDuration() / 60, 1) . translate(")") . A_Space . translate("Minutes") . "</td></tr>")
			html .= ("<tr><td><b>" . translate("Laps:") . "</b></td><td>" . displayValue("Float", strategy.getSessionLaps(), 1) . A_Space . translate("Laps") . "</td></tr>")
		}
		else {
			html .= ("<tr><td><b>" . translate("Laps:") . "</b></td><td>" . strategy.SessionLength . A_Space . translate("Laps") . "</td></tr>")
			html .= ("<tr><td><b>" . translate("Duration:") . "</b></td><td>" . Round(strategy.getSessionDuration() / 60, 1) . A_Space . translate("Minutes") . "</td></tr>")
		}

		html .= ("<tr><td><b>" . translate("Weather:") . "</b></td><td>" . translate(strategy.Weather) . translate(" (") . displayValue("Float", convertUnit("Temperature", strategy.AirTemperature)) . translate(" / ") . displayValue("Float", convertUnit("Temperature", strategy.TrackTemperature)) . translate(")") . "</td></tr>")
		html .= "</table>"

		return html
	}

	createSetupInfo(strategy) {
		local html := "<table>"
		local pressures := strategy.TyrePressures

		loop pressures.Length
			pressures[A_Index] := displayValue("Float", convertUnit("Pressure", pressures[A_Index]))

		html .= ("<tr><td><b>" . translate("Fuel:") . "</b></td><td>" . displayValue("Float", convertUnit("Volume", strategy.StartFuel)) . A_Space . getUnit("Volume", true) . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Compound:") . "</b></td><td>" . translate(compound(strategy.TyreCompound, strategy.TyreCompoundColor)) . (strategy.TyreSet ? (translate(" [") . strategy.TyreSet . translate("]")) : "") . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Pressures (hot):") . "</b></td><td>" . values2String(", ", pressures*) . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Map:") . "</b></td><td>" . strategy.Map . "</td></tr>")
		html .= ("<tr><td><b>" . translate("TC:") . "</b></td><td>" . strategy.TC . "</td></tr>")
		html .= ("<tr><td><b>" . translate("ABS:") . "</b></td><td>" . strategy.ABS . "</td></tr>")
		html .= "</table>"

		return html
	}

	createStintsInfo(strategy, &timeSeries, &lapSeries, &fuelSeries, &tyreSeries) {
		local startStint := strategy.StartStint
		local html := "<table class=`"table-std`">"
		local stints, drivers, maps, laps, lapTimes, fuelConsumptions, pitstopInfos, refuels, tyreChanges, weathers
		local lastDriver, lastMap, lastLap, lastLapTime, lastFuelConsumption, lastRefuel, lastPitstopInfo
		local lastWeather, lastTyreChange, lastTyreLaps, ignore, pitstop

		timeSeries := [strategy.SessionStartTime / 60]
		lapSeries := [strategy.StartLap]
		fuelSeries := [strategy.RemainingFuel]
		tyreSeries := [strategy.RemainingTyreLaps]

		if !strategy.LastPitstop {
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Stint") . "</th><th class=`"th-std`">" . startStint . "</th></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Driver") . "</th><td class=`"td-std`">" . strategy.DriverName . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Map") . "</th><td class=`"td-std`">" . strategy.Map . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Laps") . "</th><td class=`"td-std`">" . strategy.RemainingSessionLaps . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Lap Time") . "</th><td class=`"td-std`">" . StrategyViewer.lapTimeDisplayValue(strategy.AvgLapTime) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Consumption") . "</th><td class=`"td-std`">" . displayValue("Float", convertUnit("Volume", strategy.FuelConsumption)) . "</td></tr>")
			html .= "</table>"

			timeSeries.Push(strategy.getSessionDuration() / 60)
			lapSeries.Push(strategy.getSessionLaps())
			fuelSeries.Push(strategy.RemainingFuel - (strategy.FuelConsumption * strategy.RemainingSessionLaps))
			tyreSeries.Push(strategy.RemainingTyreLaps - strategy.RemainingSessionLaps)
		}
		else {
			stints := []
			drivers := []
			maps := []
			laps := []
			lapTimes := []
			fuelConsumptions := []
			pitstopInfos := []
			refuels := []
			tyreChanges := []
			weathers := []

			lastDriver := strategy.DriverName
			lastMap := strategy.Map
			lastLap := strategy.StartLap
			lastLapTime := strategy.AvgLapTime
			lastFuelConsumption := strategy.FuelConsumption
			lastRefuel := ""
			lastPitstopInfo := ""
			lastWeather := (translate(strategy.Weather) . translate(" (") . displayValue("Float", convertUnit("Temperature", strategy.AirTemperature)) . translate(" / ") . displayValue("Float", convertUnit("Temperature", strategy.TrackTemperature), 1) . translate(")"))
			lastTrackTemperature := strategy.TrackTemperature
			lastTyreChange := ""
			lastTyreLaps := strategy.RemainingTyreLaps

			for ignore, pitstop in strategy.Pitstops {
				stints.Push("<th class=`"th-std`">" . (startStint + A_Index - 1) . "</th>")
				drivers.Push("<td class=`"td-std`">" . lastDriver . "</td>")
				maps.Push("<td class=`"td-std`">" . lastMap . "</td>")
				laps.Push("<td class=`"td-std`">" . Max(pitstop.Lap - lastLap, 0) . "</td>")
				lapTimes.Push("<td class=`"td-std`">" . StrategyViewer.lapTimeDisplayValue(Round(lastLapTime, 1)) . "</td>")
				fuelConsumptions.Push("<td class=`"td-std`">" . (isNumber(lastFuelConsumption) ? displayValue("Float", convertUnit("Volume", lastFuelConsumption)) : "") . "</td>")
				pitstopInfos.Push("<td class=`"td-std td-right`">" . lastPitstopInfo . "</td>")
				weathers.Push("<td class=`"td-std`">" . lastWeather . "</td>")
				refuels.Push("<td class=`"td-std`">" . (isNumber(lastRefuel) ? displayValue("Float", convertUnit("Volume", lastRefuel)) : "") . "</td>")
				tyreChanges.Push("<td class=`"td-std`">" . lastTyreChange . "</td>")

				timeSeries.Push(pitstop.Time / 60)
				lapSeries.Push(pitstop.Lap + 1)
				fuelSeries.Push(pitstop.RemainingFuel - pitstop.RefuelAmount)
				tyreSeries.Push(lastTyreLaps - (pitstop.Lap - lastLap))

				lastDriver := pitstop.DriverName
				lastMap := pitstop.Map
				lastLap := pitstop.Lap
				lastFuelConsumption := pitstop.FuelConsumption
				lastLapTime := pitstop.AvgLapTime
				lastWeather := (translate(pitstop.Weather) . translate(" (") . displayValue("Float", convertUnit("Temperature", pitstop.AirTemperature)) . translate(" / ") . displayValue("Float", convertUnit("Temperature", pitstop.TrackTemperature), 1) . translate(")"))
				lastRefuel := pitstop.RefuelAmount
				lastPitstopInfo := (Format("{1:3}", pitstop.Lap + 1) . translate(" - ") . displayValue("Time", pitstop.Time, true, false, false))
				lastTyreChange := (pitstop.TyreChange ? translate(compound(pitstop.TyreCompound, pitstop.TyreCompoundColor)) . (pitstop.TyreSet ? (translate(" [") . pitstop.TyreSet . translate("]")) : "") : translate("No"))
				lastTyreLaps := pitstop.RemainingTyreLaps

				timeSeries.Push((pitstop.Time + pitStop.Duration) / 60)
				lapSeries.Push(pitstop.Lap + 1)
				fuelSeries.Push(pitstop.RemainingFuel)
				tyreSeries.Push(lastTyreLaps)
			}

			stints.Push("<th class=`"th-std`">" . (strategy.Pitstops.Length + startStint) . "</th>")
			drivers.Push("<td class=`"td-std`">" . lastDriver . "</td>")
			maps.Push("<td class=`"td-std`">" . lastMap . "</td>")
			laps.Push("<td class=`"td-std`">" . strategy.LastPitstop.StintLaps . "</td>")
			lapTimes.Push("<td class=`"td-std`">" . StrategyViewer.lapTimeDisplayValue(Round(lastLapTime, 1)) . "</td>")
			fuelConsumptions.Push("<td class=`"td-std`">" . displayValue("Float", convertUnit("Volume", lastFuelConsumption)) . "</td>")
			pitstopInfos.Push("<td class=`"td-std`">" . lastPitstopInfo . "</td>")
			weathers.Push("<td class=`"td-std`">" . lastWeather . "</td>")
			refuels.Push("<td class=`"td-std`">" . displayValue("Float", convertUnit("Volume", lastRefuel)) . "</td>")
			tyreChanges.Push("<td class=`"td-std`">" . lastTyreChange . "</td>")

			timeSeries.Push((strategy.LastPitstop.Time + (strategy.LastPitstop.StintLaps * lastLapTime)) / 60)
			lapSeries.Push(lastLap + strategy.LastPitstop.StintLaps)
			fuelSeries.Push(strategy.LastPitstop.RemainingFuel - (strategy.LastPitstop.StintLaps * strategy.LastPitstop.FuelConsumption))
			tyreSeries.Push(lastTyreLaps - strategy.LastPitstop.StintLaps)

			html .= "<table class=`"table-std`">"

			html .= ("<tr><th class=`"th-std`">" . translate("Stint") . "</th>"
					   . "<th class=`"th-std`">" . translate("Driver") . "</th>"
					   . "<th class=`"th-std`">" . translate("Weather") . "</th>"
					   . "<th class=`"th-std`">" . translate("Laps") . "</th>"
					   . "<th class=`"th-std`">" . translate("Map") . "</th>"
					   . "<th class=`"th-std`">" . translate("Lap Time") . "</th>"
					   . "<th class=`"th-std`">" . translate("Consumption") . "</th>"
					   . "<th class=`"th-std`">" . translate("Pitstop") . "</th>"
					   . "<th class=`"th-std`">" . translate("Refuel Amount") . "</th>"
					   . "<th class=`"th-std`">" . translate("Tyre Change") . "</th>"
				   . "</tr>")

			loop stints.Length
				html .= ("<tr>" . stints[A_Index]
								. drivers[A_Index]
								. weathers[A_Index]
								. laps[A_Index]
								. maps[A_Index]
								. lapTimes[A_Index]
								. fuelConsumptions[A_Index]
								. pitstopInfos[A_Index]
								. refuels[A_Index]
								. tyreChanges[A_Index]
					   . "</tr>")

			html .= "</table>"
		}

		return html
	}

	createConsumablesChart(strategy, width, height, timeSeries, lapSeries, fuelSeries, tyreSeries, &drawChartFunction, &chartID) {
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

			drawChartFunction .= ("[" . xAxis . ", " . convertUnit("Volume", fuelSeries[A_Index]) . ", " . tyreSeries[A_Index] . "]")
		}

		drawChartFunction .= ("]);`nvar options = { curveType: 'function', legend: { position: 'Right' }, chartArea: { left: '10%', top: '5%', right: '25%', bottom: '20%' }, hAxis: { title: '"
							. (durationSession ? translate("Lap") : translate("Minute")) . "' }, vAxis: { viewWindow: { min: 0 } }, backgroundColor: '" . this.Window.AltBackColor . "' };`n")

		drawChartFunction .= ("`nvar chart = new google.visualization.LineChart(document.getElementById('chart_" . chartID . "')); chart.draw(data, options); }")

		return ("<div id=`"chart_" . chartID . "`" style=`"width: " . Round(width - 120) . "px; height: " . Round(height) . "px`"></div>")
	}

	showStrategyInfo(strategy) {
		local html := ""
		local timeSeries, lapSeries, fuelSeries, tyreSeries, drawChartFunction, chartID, width, chartArea
		local before, after, tableCSS

		if !this.StrategyViewer
			strategy := false

		if strategy {
			html := ("<div id=`"header`"><b>" . translate("Strategy: ") . strategy.Name . "</b></div>")

			html .= ("<br><br><div id=`"header`"><i>" . translate("Session") . "</i></div>")

			html .= ("<br><br>" . this.createStrategyInfo(strategy))

			html .= ("<br><br><div id=`"header`"><i>" . translate("Setup") . "</i></div>")

			html .= ("<br><br>" . this.createSetupInfo(strategy))

			html .= ("<br><br><div id=`"header`"><i>" . translate("Stints") . "</i></div>")

			timeSeries := []
			lapSeries := []
			fuelSeries := []
			tyreSeries := []

			html .= ("<br><br>" . this.createStintsInfo(strategy, &timeSeries, &lapSeries, &fuelSeries, &tyreSeries))

			html .= ("<br><br><div id=`"header`"><i>" . translate("Consumables") . "</i></div>")

			drawChartFunction := false
			chartID := false

			width := (this.StrategyViewer.getWidth() - 4)

			chartArea := this.createConsumablesChart(strategy, width, width / 2, timeSeries, lapSeries, fuelSeries, tyreSeries, &drawChartFunction, &chartID)

			before := "
			(
				<meta charset='utf-8'>
				<head>
					<style>
						.headerStyle { height: 25; font-size: 11px; font-weight: 500; background-color: #%headerBackColor%; }
						.rowStyle { font-size: 11px; background-color: #%evenRowBackColor%; }
						.oddRowStyle { font-size: 11px; background-color: #%oddRowBackColor%; }
					</style>
					<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
					<script type="text/javascript">
						google.charts.load('current', {'packages':['corechart', 'table', 'scatter']}).then(drawChart%chartID%);
			)"

			before := substituteVariables(before, {headerBackColor: this.Window.Theme.ListBackColor["Header"]
												 , evenRowBackColor: this.Window.Theme.ListBackColor["EvenRow"]
												 , oddRowBackColor: this.Window.Theme.ListBackColor["OddRow"]
												 , chartID: chartID})

			after := "
			(
					</script>
				</head>
			)"
		}
		else {
			before := ""
			after := ""
			drawChartFunction := ""
			chartArea := ""
		}

		tableCSS := this.getTableCSS()

		html := ("<html>" . before . drawChartFunction . after . "<body style='background-color: #" . this.Window.AltBackColor . "' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><style> div, table { font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><style>" . tableCSS . "</style><style> #header { font-size: 12px; } </style><div>" . html . "</div><br>" . chartArea . "</body></html>")

		if this.StrategyViewer {
			this.StrategyViewer.document.open()
			this.StrategyViewer.document.write(html)
			this.StrategyViewer.document.close()
		}
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
			}

			.th-std, .caption-std {
				background-color: #%headerBackColor%;
				color: #%textColor%;
				border: thin solid #%frameColor%;
			}

			.td-std {
				border-left: thin solid #%frameColor%;
				border-right: thin solid #%frameColor%;
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
				background-color: #%altBackColor%;
			}

			.table-std tbody tr:nth-child(odd) {
				background-color: #%backColor%;
			}
		)"

		return substituteVariables(script, {altBackColor: this.Window.AltBackColor, backColor: this.Window.BackColor
										  , textColor: this.Window.Theme.TextColor
										  , headerBackColor: this.Window.Theme.TableColor["Header"], frameColor: this.Window.Theme.TableColor["Frame"]})
	}
}