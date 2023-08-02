;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - SimHub Plugin                   ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Task.ahk"
#Include "..\Libraries\JSON.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kSimHubPlugin := "SimHub"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class SimHubPlugin extends ControllerPlugin {
	iAssistantsStateTask := false

	AssistantsStateTask {
		Get {
			return this.iAssistantsStateTask
		}
	}

	__New(controller, name, configuration := false) {
		super.__New(controller, name, configuration)

		if (this.Active || isDebug()) {
			this.iAssistantsStateTask := Task(ObjBindMethod(this, "updateSessionState"), 1000, kLowPriority)

			this.iAssistantsStateTask.pause()
		}
	}

	simulatorStartup(simulator) {
		super.simulatorStartup(simulator)

		if this.AssistantsStateTask
			this.AssistantsStateTask.resume()
	}

	simulatorShutdown(simulator) {
		if this.AssistantsStateTask
			this.AssistantsStateTask.pause()

		super.simulatorShutdown(simulator)
	}

	createSessionState(sessionInfo) {
		return Map("Simulator", getMultiMapValue(sessionInfo, "Session", "Simulator")
				 , "Car", getMultiMapValue(sessionInfo, "Session", "Car")
				 , "Track", getMultiMapValue(sessionInfo, "Session", "Track")
				 , "Session", translate(getMultiMapValue(sessionInfo, "Session", "Session")))
	}

	createDurationState(sessionInfo) {
		local sessionTime := getMultiMapValue(sessionInfo, "Session", "Time.Remaining", kUndefined)
		local stintTime := getMultiMapValue(sessionInfo, "Stint", "Time.Remaining.Stint", kUndefined)
		local driverTime := getMultiMapValue(sessionInfo, "Stint", "Time.Remaining.Driver", kUndefined)
		local sessionLaps := getMultiMapValue(sessionInfo, "Session", "Laps.Remaining", 0)
		local stintLaps := getMultiMapValue(sessionInfo, "Stint", "Laps.Remaining.Stint", 0)
		local lastValid := getMultiMapValue(sessionInfo, "Stint", "Valid", true)
		local lastTime := getMultiMapValue(sessionInfo, "Stint", "Lap.Time.Last", kUndefined)
		local state := Map()
		local remainingStintTime, remainingSessionTime, remainingDriverTime

		if isNumber(sessionTime)
			remainingSessionTime := displayValue("Time", sessionTime)
		else
			remainingSessionTime := kNull

		if (isNumber(stintTime) && isNumber(lastTime))
			remainingStintTime := ((((stintTime / lastTime) < 4) ? "<font color=`"red`">" : "") . displayValue("Time", stintTime) . (((stintTime / lastTime) < 4) ? "</font>" : ""))
		else
			remainingStintTime := kNull

		if (isNumber(driverTime) && isNumber(lastTime))
			remainingDriverTime := ((((driverTime / lastTime) < 4) ? "<font color=`"red`">" : "") . displayValue("Time", driverTime) . (((driverTime / lastTime) < 4) ? "</font>" : ""))
		else
			remainingDriverTime := kNull

		state["Format"] := translate(getMultiMapValue(sessionInfo, "Session", "Format"))
		state["SessionTimeLeft"] := remainingSessionTime
		state["StintTimeLeft"] := remainingStintTime
		state["StintTimeLeft"] := remainingDriverTime
		state["SessionLapsLeft"] := sessionLaps
		state["StintLapsLeft"] := stintLaps

		return state
	}

	createStintState(sessionInfo) {
		local lastLap := getMultiMapValue(sessionInfo, "Session", "Laps", 0)
		local lastValid := getMultiMapValue(sessionInfo, "Stint", "Valid", true)
		local lastTime := getMultiMapValue(sessionInfo, "Stint", "Lap.Time.Last")
		local bestTime := getMultiMapValue(sessionInfo, "Stint", "Lap.Time.Best")

		return Map("Driver", getMultiMapValue(sessionInfo, "Stint", "Driver")
				 , "Laps", getMultiMapValue(sessionInfo, "Stint", "Laps")
				 , "Lap", (lastLap + 1)
				 , "Position", getMultiMapValue(sessionInfo, "Stint", "Position")
				 , "BestTime", ((bestTime < 3600) ? displayValue("Time", bestTime) : kNull)
				 , "LastTime", ((lastTime < 3600) ? displayValue("Time", lastTime) : kNull))
	}

	createTyresState(sessionInfo) {
		local state := Map()
		local pressures, temperatures, wear

		pressures := string2Values(",", getMultiMapValue(sessionInfo, "Tyres", "Pressures", ""))

		if (pressures.Length = 4) {
			state["PressureFL"] := convertUnit("Pressure", pressures[1])
			state["PressureFR"] := convertUnit("Pressure", pressures[2])
			state["PressureRL"] := convertUnit("Pressure", pressures[3])
			state["PressureRR"] := convertUnit("Pressure", pressures[4])
		}
		else {
			state["PressureFL"] := kNull
			state["PressureFR"] := kNull
			state["PressureRL"] := kNull
			state["PressureRR"] := kNull
		}

		temperatures := string2Values(",", getMultiMapValue(sessionInfo, "Tyres", "Temperatures", ""))

		if (temperatures.Length = 4) {
			state["TemperatureFL"] := convertUnit("Temperature", temperatures[1])
			state["TemperatureFR"] := convertUnit("Temperature", temperatures[2])
			state["TemperatureRL"] := convertUnit("Temperature", temperatures[3])
			state["TemperatureRR"] := convertUnit("Temperature", temperatures[4])
		}
		else {
			state["TemperatureFL"] := kNull
			state["TemperatureFR"] := kNull
			state["TemperatureRL"] := kNull
			state["TemperatureRR"] := kNull
		}

		wear := string2Values(",", getMultiMapValue(sessionInfo, "Tyres", "Wear", ""))

		if (wear.Length = 4) {
			state["WearFL"] := wear[1]
			state["WearFR"] := wear[2]
			state["WearRL"] := wear[3]
			state["WearRR"] := wear[4]
		}
		else {
			state["WearFL"] := kNull
			state["WearFR"] := kNull
			state["WearRL"] := kNull
			state["WearRR"] := kNull
		}

		return state
	}

	createBrakesState(sessionInfo) {
		local state := Map()
		local temperatures, wear

		temperatures := string2Values(",", getMultiMapValue(sessionInfo, "Brakes", "Temperatures", ""))

		if (temperatures.Length = 4) {
			state["TemperatureFL"] := convertUnit("Temperature", temperatures[1])
			state["TemperatureFR"] := convertUnit("Temperature", temperatures[2])
			state["TemperatureRL"] := convertUnit("Temperature", temperatures[3])
			state["TemperatureRR"] := convertUnit("Temperature", temperatures[4])
		}
		else {
			state["TemperatureFL"] := kNull
			state["TemperatureFR"] := kNull
			state["TemperatureRL"] := kNull
			state["TemperatureRR"] := kNull
		}

		wear := string2Values(",", getMultiMapValue(sessionInfo, "Brakes", "Wear", ""))

		if (wear.Length = 4) {
			state["WearFL"] := wear[1]
			state["WearFR"] := wear[2]
			state["WearRL"] := wear[3]
			state["WearRR"] := wear[4]
		}
		else {
			state["WearFL"] := kNull
			state["WearFR"] := kNull
			state["WearRL"] := kNull
			state["WearRR"] := kNull
		}

		return state
	}

	/*
	createConditionsWidget(sessionInfo) {
		local weatherNow := getMultiMapValue(sessionInfo, "Weather", "Now")
		local weather10Min := getMultiMapValue(sessionInfo, "Weather", "10Min")
		local weather30Min := getMultiMapValue(sessionInfo, "Weather", "30Min")
		local html := ""

		try {
			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"2`"><div id=`"header`"><i>" . translate("Conditions") . "</i></div></th></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Weather") . "</th><td class=`"td-wdg`">" . translate(weatherNow) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Temperature (Air)") . "</th><td class=`"td-wdg`">" . displayValue("Float", convertUnit("Temperature", getMultiMapValue(sessionInfo, "Weather", "Temperature"))) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Temperature (Track)") . "</th><td class=`"td-wdg`">" . displayValue("Float", convertUnit("Temperature", getMultiMapValue(sessionInfo, "Track", "Temperature"))) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Grip") . "</th><td class=`"td-wdg`">" . translate(getMultiMapValue(sessionInfo, "Track", "Grip")) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Outlook (10 minutes)") . "</th><td class=`"td-wdg`">" . ((weather10Min != weatherNow) ? "<font color=`"red`">" : "") . translate(weather10Min) . ((weather10Min != weatherNow) ? "</font>" : "") . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Outlook (30 minutes)") . "</th><td class=`"td-wdg`">" . ((weather30Min != weatherNow) ? "<font color=`"red`">" : "") . translate(weather30Min) . ((weather30Min != weatherNow) ? "</font>" : "") . "</td></tr>")
		}
		catch Any as exception {
			logError(exception)

			html := "<table>"
		}

		html .= "</table>"

		return html
	}

	createFuelWidget(sessionInfo) {
		local fuelLow := (Floor(getMultiMapValue(sessionInfo, "Stint", "Laps.Remaining.Fuel", 0)) < 4)
		local html := ""

		try {
			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"2`"><div id=`"header`"><i>" . translate("Fuel") . "</i></div></th></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Consumption (Lap)") . "</th><td class=`"td-wdg`">" . displayValue("Float", convertUnit("Volume", getMultiMapValue(sessionInfo, "Stint", "Fuel.Consumption"))) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Consumption (Avg.)") . "</th><td class=`"td-wdg`">" . displayValue("Float", convertUnit("Volume", getMultiMapValue(sessionInfo, "Stint", "Fuel.AvgConsumption"))) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Remaining Fuel") . "</th><td class=`"td-wdg`">" . displayValue("Float", convertUnit("Volume", getMultiMapValue(sessionInfo, "Stint", "Fuel.Remaining"))) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Remaining Laps") . "</th><td class=`"td-wdg`">" . (fuelLow ? "<font color=`"red`">" : "") . Floor(getMultiMapValue(sessionInfo, "Stint", "Laps.Remaining.Fuel")) . (fuelLow ? "</font>" : "") . "</td></tr>")
		}
		catch Any as exception {
			logError(exception)

			html := "<table>"
		}

		html .= "</table>"

		return html
	}

	createStrategyWidget(sessionInfo) {
		local pitstopsCount := getMultiMapValue(sessionInfo, "Strategy", "Pitstops", kUndefined)
		local html := ""
		local remainingPitstops := 0
		local nextPitstop, tyreCompound

		try {
			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"2`"><div id=`"header`"><i>" . translate("Strategy") . "</i></div></th></tr>")

			if (pitstopsCount != kUndefined) {
				nextPitstop := getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next", 0)

				if (nextPitstop && pitstopsCount)
					remainingPitstops := (pitstopsCount - nextPitstop + 1)

				html .= ("<tr><th class=`"th-std th-left`">" . translate("Pitstops (Planned)") . "</th><td class=`"td-wdg`">" . pitstopsCount . "</td></tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Pitstops (Remaining)") . "</th><td class=`"td-wdg`">" . remainingPitstops . "</td></tr>")

				if nextPitstop {
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Next Pitstop (Lap)") . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Lap") . "</td></tr>")
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Fuel") . "</th><td class=`"td-wdg`">" . displayValue("Float", convertUnit("Volume", getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Refuel"))) . "</td></tr>")

					tyreCompound := getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Tyre.Compound")

					if tyreCompound
						tyreCompound := translate(compound(tyreCompound, getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Tyre.Compound.Color")))
					else
						tyreCompound := translate("No")

					html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyres") . "</th><td class=`"td-wdg`">" . tyreCompound . "</td></tr>")
				}
			}
			else
				html .= ("<tr><td class=`"td-wdg`" colspan=`"2`">" . translate("No active strategy") . "</td></tr>")
		}
		catch Any as exception {
			logError(exception)

			html := "<table>"
		}

		html .= "</table>"

		return html
	}

	createPitstopWidget(sessionInfo) {
		local pitstopNr := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Nr", false)
		local pitstopLap := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Lap", 0)
		local html := ""
		local tyreCompound, tyreSet, tyrePressures

		computeRepairs(bodywork, suspension, engine) {
			local repairs := ""

			if bodywork
				repairs := translate("Bodywork")

			if suspension {
				if (StrLen(repairs) > 0)
					repairs .= ", "

				repairs .= translate("Suspension")
			}

			if engine {
				if (StrLen(repairs) > 0)
					repairs .= ", "

				repairs .= translate("Engine")
			}

			return ((StrLen(repairs) > 0) ? repairs : "-")
		}

		try {
			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"3`"><div id=`"header`"><i>" . translate("Pitstop") . "</i></div></th></tr>")

			if pitstopNr {
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Nr.") . "</th><td class=`"td-wdg`" colspan=`"2`">" . pitstopNr . "</td></tr>")

				if pitstopLap
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Lap") . "</th><td class=`"td-wdg`" colspan=`"2`">" . pitstopLap . "</td></tr>")

				html .= ("<tr><th class=`"th-std th-left`">" . translate("Fuel") . "</th><td class=`"td-wdg`" colspan=`"2`">" . displayValue("Float", convertUnit("Volume", getMultiMapValue(sessionInfo, "Pitstop", "Planned.Refuel"))) . "</td></tr>")

				tyreCompound := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Compound")

				if tyreCompound {
					tyreCompound := translate(compound(tyreCompound, getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Compound.Color")))

					html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyres") . "</th><td class=`"td-wdg`" colspan=`"2`">" . tyreCompound . "</td></tr>")

					tyreSet := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Set")

					if tyreSet
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyre Set") . "</th><td class=`"td-wdg`" colspan=`"2`">" . tyreSet . "</td></tr>")

					html .= ("<tr><th class=`"th-std th-left`" rowspan=`"2`">" . translate("Pressures") . "</th><td class=`"td-wdg`" style=`"text-align: right`">"
						   . displayValue("Float", convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.FL"))) . "</td><td class=`"td-wdg`" style=`"text-align: right`">"
						   . displayValue("Float", convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.FR"))) . "</td></tr>")
					html .= ("<tr><td class=`"td-wdg`" style=`"text-align: right`">"
						   . displayValue("Float", convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.RL"))) . "</td><td class=`"td-wdg`" style=`"text-align: right`">"
						   . displayValue("Float", convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.RR"))) . "</td></tr>")
				}
				else
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyres") . "</th><td class=`"td-wdg`">" . translate("No") . "</td></tr>")

				html .= ("<tr><th class=`"th-std th-left`">" . translate("Repairs") . "</th><td class=`"td-wdg`" colspan=`"2`">"
															 . computeRepairs(getMultiMapValue(sessionInfo, "Pitstop", "Planned.Repair.Bodywork")
																			, getMultiMapValue(sessionInfo, "Pitstop", "Planned.Repair.Suspension")
																			, getMultiMapValue(sessionInfo, "Pitstop", "Planned.Repair.Engine"))
															 . "</td></tr>")

				html .= ("<tr><th class=`"th-std th-left`">" . translate("Prepared") . "</th><td class=`"td-wdg`" colspan=`"2`">"
															 . (getMultiMapValue(sessionInfo, "Pitstop", "Prepared") ? translate("Yes") : translate("No"))
															 . "</td></tr>")
			}
			else
				html .= ("<tr><td class=`"td-wdg`" colspan=`"3`">" . translate("No planned pitstop") . "</td></tr>")
		}
		catch Any as exception {
			logError(exception)

			html := "<table>"
		}

		html .= "</table>"

		return html
	}

	createStandingsWidget(sessionInfo) {
		local positionOverall := getMultiMapValue(sessionInfo, "Standings", "Position.Overall")
		local positionClass := getMultiMapValue(sessionInfo, "Standings", "Position.Class")
		local html := ""
		local leaderNr := false
		local nr, delta, colorOpen, colorClose

		static lastLeaderDelta := false
		static lastAheadDelta := false
		static lastBehindDelta := false

		computeColorInfo(delta, &lastDelta, upColor, downColor, &colorOpen, &colorClose) {
			if (lastDelta && (lastDelta != delta)) {
				colorOpen := ("<font color=`"" . ((delta > lastDelta) ? upColor : downColor) . "`">")
				colorClose := "</font>"
			}
			else {
				colorOpen := ""
				colorClose := ""
			}

			lastDelta := delta
		}

		try {
			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"2`"><div id=`"header`"><i>" . translate("Standings") . "</i></div></th></tr>")

			if (positionOverall != positionClass) {
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Position (Overall)") . "</th><td class=`"td-wdg`">" . positionOverall . "</td></tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Position (Class)") . "</th><td class=`"td-wdg`">" . positionClass . "</td></tr>")
			}
			else
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Position") . "</th><td class=`"td-wdg`">" . positionOverall . "</td></tr>")

			if (getMultiMapValue(sessionInfo, "Standings", "Leader.Lap.Time", kUndefined) != kUndefined) {
				nr := getMultiMapValue(sessionInfo, "Standings", "Leader.Nr")
				delta := getMultiMapValue(sessionInfo, "Standings", "Leader.Delta")

				computeColorInfo(Abs(delta), &lastLeaderDelta, "red", "green", &colorOpen, &colorClose)

				if nr {
					leaderNr := nr

					html .= ("<tr><th class=`"th-std th-left`">" . substituteVariables(translate("Leader #%nr% (Laps)"), {nr: nr}) . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionInfo, "Standings", "Leader.Laps") . "</td></tr>")
					html .= ("<tr><th class=`"th-std th-left`">" . substituteVariables(translate("Leader #%nr% (Delta)"), {nr: nr}) . "</th><td class=`"td-wdg`">" . colorOpen . displayValue("Time", delta) . colorClose . "</td></tr>")
					html .= ("<tr><th class=`"th-std th-left`">" . substituteVariables(translate("Leader #%nr% (Lap Time)"), {nr: nr}) . "</th><td class=`"td-wdg`">" . displayValue("Time", getMultiMapValue(sessionInfo, "Standings", "Leader.Lap.Time")) . "</td></tr>")
				}
				else {
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Leader (Laps)") . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionInfo, "Standings", "Leader.Laps") . "</td></tr>")
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Leader (Delta)") . "</th><td class=`"td-wdg`">" . colorOpen . displayValue("Time", delta) . colorClose . "</td></tr>")
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Leader (Lap Time)") . "</th><td class=`"td-wdg`">" . displayValue("Time", getMultiMapValue(sessionInfo, "Standings", "Leader.Lap.Time")) . "</td></tr>")
				}
			}

			if (getMultiMapValue(sessionInfo, "Standings", "Ahead.Lap.Time", kUndefined) != kUndefined) {
				nr := getMultiMapValue(sessionInfo, "Standings", "Ahead.Nr")
				delta := getMultiMapValue(sessionInfo, "Standings", "Ahead.Delta")

				computeColorInfo(Abs(delta), &lastAheadDelta, "red", "green", &colorOpen, &colorClose)

				if nr {
					if (nr != leaderNr) {
						html .= ("<tr><th class=`"th-std th-left`">" . substituteVariables(translate("Ahead #%nr% (Laps)"), {nr: nr}) . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionInfo, "Standings", "Ahead.Laps") . "</td></tr>")
						html .= ("<tr><th class=`"th-std th-left`">" . substituteVariables(translate("Ahead #%nr% (Delta)"), {nr: nr}) . "</th><td class=`"td-wdg`">" . colorOpen . displayValue("Time", delta) . colorClose . "</td></tr>")
						html .= ("<tr><th class=`"th-std th-left`">" . substituteVariables(translate("Ahead #%nr% (Lap Time)"), {nr: nr}) . "</th><td class=`"td-wdg`">" . displayValue("Time", getMultiMapValue(sessionInfo, "Standings", "Ahead.Lap.Time")) . "</td></tr>")
					}
				}
				else {
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Ahead (Laps)") . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionInfo, "Standings", "Ahead.Laps") . "</td></tr>")
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Ahead (Delta)") . "</th><td class=`"td-wdg`">" . colorOpen . displayValue("Time", delta) . colorClose . "</td></tr>")
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Ahead (Lap Time)") . "</th><td class=`"td-wdg`">" . displayValue("Time", getMultiMapValue(sessionInfo, "Standings", "Ahead.Lap.Time")) . "</td></tr>")
				}
			}

			if (getMultiMapValue(sessionInfo, "Standings", "Behind.Lap.Time", kUndefined) != kUndefined) {
				nr := getMultiMapValue(sessionInfo, "Standings", "Behind.Nr")
				delta := getMultiMapValue(sessionInfo, "Standings", "Behind.Delta")

				computeColorInfo(Abs(delta), &lastBehindDelta, "green", "red", &colorOpen, &colorClose)

				if nr {
					html .= ("<tr><th class=`"th-std th-left`">" . substituteVariables(translate("Behind #%nr% (Laps)"), {nr: nr}) . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionInfo, "Standings", "Behind.Laps") . "</td></tr>")
					html .= ("<tr><th class=`"th-std th-left`">" . substituteVariables(translate("Behind #%nr% (Delta)"), {nr: nr}) . "</th><td class=`"td-wdg`">" . colorOpen . displayValue("Time", delta) . colorClose . "</td></tr>")
					html .= ("<tr><th class=`"th-std th-left`">" . substituteVariables(translate("Behind #%nr% (Lap Time)"), {nr: nr}) . "</th><td class=`"td-wdg`">" . displayValue("Time", getMultiMapValue(sessionInfo, "Standings", "Behind.Lap.Time")) . "</td></tr>")
				}
				else {
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Behind (Laps)") . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionInfo, "Standings", "Behind.Laps") . "</td></tr>")
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Behind (Delta)") . "</th><td class=`"td-wdg`">" . colorOpen . displayValue("Time", delta) . colorClose . "</td></tr>")
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Behind (Lap Time)") . "</th><td class=`"td-wdg`">" . displayValue("Time", getMultiMapValue(sessionInfo, "Standings", "Behind.Lap.Time")) . "</td></tr>")
				}
			}
		}
		catch Any as exception {
			logError(exception)

			html := "<table>"
		}

		html .= "</table>"

		return html
	}
	*/

	updateSessionState() {
		local hasUpdate := false
		local sessionInfo, sessionState, ignore, assistant, fileName

		static lastUpdate := false

		for ignore, assistant in ["Race Engineer", "Race Strategist", "Race Spotter"] {
			fileName := (kTempDirectory . assistant . " Session.state")

			if (FileExist(fileName) && (FileGetTime(fileName, "M") > lastUpdate))
				hasUpdate := true
		}

		if hasUpdate {
			lastUpdate := A_Now
			sessionInfo := newMultiMap()

			for ignore, assistant in ["Race Engineer", "Race Strategist", "Race Spotter"]
				addMultiMapValues(sessionInfo, readMultiMap(kTempDirectory . assistant . " Session.state"))

			sessionState := Map("Session", this.createSessionState(sessionInfo)
							  , "Duration", this.createDurationState(sessionInfo)
							  , "Stint", this.createStintState(sessionInfo)
							  , "Tyres", this.createTyresState(sessionInfo)
							  , "Brakes", this.createBrakesState(sessionInfo))

			fileName := temporaryFileName("Session State", "json")

			deleteFile(fileName)

			FileAppend(JSON.print(sessionState), fileName)

			loop 10
				try {
					FileMove(fileName, kTempDirectory . "Session State.json", 1)

					break
				}
				catch Any {
					Sleep(20)
				}
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeSimHubPlugin() {
	local controller := SimulatorController.Instance

	SimHubPlugin(controller, kSimHubPlugin, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeSimHubPlugin()