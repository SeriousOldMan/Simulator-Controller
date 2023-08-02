;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Interface Plugin                ;;;
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

global kInterfacePlugin := "Interface"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class InterfacePlugin extends ControllerPlugin {
	iStateFile := (kTempDirectory . "Session State.json")
	iAssistantsStateTask := false

	StateFile {
		Get {
			return this.iStateFile
		}
	}

	AssistantsStateTask {
		Get {
			return this.iAssistantsStateTask
		}
	}

	__New(controller, name, configuration := false) {
		this.iStateFile := this.getArgumentValue("stateFile", kTempDirectory . "Session State.json")

		super.__New(controller, name, configuration)

		if (this.Active || isDebug()) {
			this.iAssistantsStateTask := PeriodicTask(ObjBindMethod(this, "updateSessionState"), 1000, kLowPriority)

			this.iAssistantsStateTask.start()
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
				 , "Session", translate(getMultiMapValue(sessionInfo, "Session", "Type")))
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

	createConditionsState(sessionInfo) {
		local weatherNow := getMultiMapValue(sessionInfo, "Weather", "Now")
		local weather10Min := getMultiMapValue(sessionInfo, "Weather", "10Min")
		local weather30Min := getMultiMapValue(sessionInfo, "Weather", "30Min")

		return Map("Weather", translate(weatherNow)
				 , "AirTemperature", convertUnit("Temperature", getMultiMapValue(sessionInfo, "Weather", "Temperature"))
				 , "TrackTemperature", convertUnit("Temperature", getMultiMapValue(sessionInfo, "Track", "Temperature"))
				 , "Grip", translate(getMultiMapValue(sessionInfo, "Track", "Grip"))
				 , "Weather10Min", translate(weather10Min)
				 , "Weather30Min", translate(weather30Min))
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


	createFuelState(sessionInfo) {
		local fuelLow := (Floor(getMultiMapValue(sessionInfo, "Stint", "Laps.Remaining.Fuel", 0)) < 4)

		return Map("LastConsumption", convertUnit("Volume", getMultiMapValue(sessionInfo, "Stint", "Fuel.Consumption"))
				 , "AvgConsumption", convertUnit("Volume", getMultiMapValue(sessionInfo, "Stint", "Fuel.AvgConsumption"))
				 , "RemainingFuel", convertUnit("Volume", getMultiMapValue(sessionInfo, "Stint", "Fuel.Remaining"))
				 , "RemainingLaps", Floor(getMultiMapValue(sessionInfo, "Stint", "Laps.Remaining.Fuel")))
	}

	createTyresState(sessionInfo) {
		local state := Map()
		local pressures, temperatures, wear

		pressures := string2Values(",", getMultiMapValue(sessionInfo, "Tyres", "Pressures", ""))

		if (pressures.Length = 4) {
			state["Pressures"] := [convertUnit("Pressure", pressures[1]), convertUnit("Pressure", pressures[2])
								 , convertUnit("Pressure", pressures[3]), convertUnit("Pressure", pressures[4])]
		}
		else
			state["Pressures"] := [kNull, kNull, kNull, kNull]

		temperatures := string2Values(",", getMultiMapValue(sessionInfo, "Tyres", "Temperatures", ""))

		if (temperatures.Length = 4)
			state["Temperatures"] := [convertUnit("Temperature", temperatures[1]), convertUnit("Temperature", temperatures[2])
									, convertUnit("Temperature", temperatures[3]), convertUnit("Temperature", temperatures[4])]
		else
			state["Temperatures"] := [kNull, kNull, kNull, kNull]

		wear := string2Values(",", getMultiMapValue(sessionInfo, "Tyres", "Wear", ""))

		if (wear.Length = 4)
			state["Wear"] := [wear[1], wear[2], wear[3], wear[4]]
		else
			state["Wear"] := [kNull, kNull, kNull, kNull]

		return state
	}

	createBrakesState(sessionInfo) {
		local state := Map()
		local temperatures, wear

		temperatures := string2Values(",", getMultiMapValue(sessionInfo, "Brakes", "Temperatures", ""))

		if (temperatures.Length = 4)
			state["Temperatures"] := [convertUnit("Temperature", temperatures[1]), convertUnit("Temperature", temperatures[2])
									, convertUnit("Temperature", temperatures[3]), convertUnit("Temperature", temperatures[4])]
		else
			state["Temperatures"] := [kNull, kNull, kNull, kNull]

		wear := string2Values(",", getMultiMapValue(sessionInfo, "Brakes", "Wear", ""))

		if (wear.Length = 4)
			state["Wear"] := [wear[1], wear[2], wear[3], wear[4]]
		else
			state["Wear"] := [kNull, kNull, kNull, kNull]

		return state
	}

	createStrategyState(sessionInfo) {
		local pitstopsCount := getMultiMapValue(sessionInfo, "Strategy", "Pitstops", 0)
		local nextPitstop := getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next", false)
		local remainingPitstops := 0
		local state := Map()
		local nextPitstop, tyreCompound

		if (nextPitstop && (pitstopsCount != 0))
			remainingPitstops := (pitstopsCount - nextPitstop + 1)

		state["PlannedPitstops"] := pitstopsCount
		state["RemainingPitstops"] := remainingPitstops

		if nextPitstop {
			state["Lap"] := getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Lap")
			state["Fuel"] := convertUnit("Volume", getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Refuel"))

			tyreCompound := getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Tyre.Compound")

			if tyreCompound
				tyreCompound := translate(compound(tyreCompound, getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Tyre.Compound.Color")))
			else
				tyreCompound := kNull

			state["TyreCompound"] := tyreCompound
		}
		else {
			state["Lap"] := kNull
			state["Fuel"] := kNull
			state["TyreCompound"] := kNull
		}

		return state
	}

	createPitstopState(sessionInfo) {
		local pitstopNr := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Nr", false)
		local pitstopLap := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Lap", 0)
		local state := Map()
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

		if pitstopNr {
			state["Number"] := pitstopNr
			state["Lap"] := ((pitstopLap != 0) ? pitstopLap : kNull)
			state["Fuel"] := convertUnit("Volume", getMultiMapValue(sessionInfo, "Pitstop", "Planned.Refuel"))

			tyreCompound := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Compound")

			if tyreCompound {
				tyreCompound := translate(compound(tyreCompound, getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Compound.Color")))

				state["TyreCompound"] := tyreCompound

				tyreSet := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Set")

				state["TyreSet"] := (tyreSet ? tyreSet : kNull)

				state["TyrePressures"] := [convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.FL"))
										 , convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.FR"))
										 , convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.RL"))
										 , convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.RR"))]
			}
			else {
				state["TyreCompound"] := kNull
				state["TyreSet"] := kNull
				state["TyrePressures"] := [kNull, kNull, kNull, kNull]
			}

			state["Repairs"] := computeRepairs(getMultiMapValue(sessionInfo, "Pitstop", "Planned.Repair.Bodywork")
											 , getMultiMapValue(sessionInfo, "Pitstop", "Planned.Repair.Suspension")
											 , getMultiMapValue(sessionInfo, "Pitstop", "Planned.Repair.Engine"))

			state["Prepared"] := getMultiMapValue(sessionInfo, "Pitstop", "Prepared")
		}
		else {
			state["Number"] := kNull
			state["Lap"] := kNull
			state["Fuel"] := kNull
			state["TyreCompound"] := kNull
			state["TyreSet"] := kNull
			state["TyrePressures"] := [kNull, kNull, kNull, kNull]
			state["Repairs"] := kNull
			state["Prepared"] := kNull
		}

		return state
	}

	createStandingsState(sessionInfo) {
		local positionOverall := getMultiMapValue(sessionInfo, "Standings", "Position.Overall")
		local positionClass := getMultiMapValue(sessionInfo, "Standings", "Position.Class")
		local state := Map()
		local nr, opponent

		static lastLeaderDelta := false
		static lastAheadDelta := false
		static lastBehindDelta := false

		state["Position"] := positionOverall
		state["OverallPosition"] := positionOverall
		state["ClassPosition"] := positionClass

		for ignore, opponent in ["Leader", "Ahead", "Behind", "Focus"]
			if (getMultiMapValue(sessionInfo, "Standings", opponent . ".Lap.Time", kUndefined) != kUndefined) {
				nr := getMultiMapValue(sessionInfo, "Standings", opponent . ".Nr")

				state[opponent] := Map("Laps", getMultiMapValue(sessionInfo, "Standings", opponent . ".Laps")
									 , "Delta", displayValue("Time", getMultiMapValue(sessionInfo, "Standings", opponent . ".Delta"))
									 , "LapTime", displayValue("Time", getMultiMapValue(sessionInfo, "Standings", opponent . ".Lap.Time"))
									 , "InPit", getMultiMapValue(sessionInfo, "Standings", opponent . ".InPit"))

				state[opponent]["Nr"] := (nr ? nr : kNull)
			}
			else
				state[opponent] := kNull

		return state
	}

	updateSessionState() {
		local hasUpdate := false
		local sessionInfo, sessionState, ignore, assistant, fileName

		static lastUpdate := A_Now

		for ignore, assistant in ["Race Engineer", "Race Strategist", "Race Spotter"] {
			fileName := (kTempDirectory . assistant . " Session.state")

			if (FileExist(fileName) && (FileGetTime(fileName, "M") > lastUpdate)) {
				hasUpdate := true

				break
			}
		}

		if hasUpdate {
			lastUpdate := A_Now
			sessionInfo := newMultiMap()

			for ignore, assistant in ["Race Engineer", "Race Strategist", "Race Spotter"]
				addMultiMapValues(sessionInfo, readMultiMap(kTempDirectory . assistant . " Session.state"))

			sessionState := Map("Session", this.createSessionState(sessionInfo)
							  , "Duration", this.createDurationState(sessionInfo)
							  , "Conditions", this.createConditionsState(sessionInfo)
							  , "Stint", this.createStintState(sessionInfo)
							  , "Fuel", this.createFuelState(sessionInfo)
							  , "Tyres", this.createTyresState(sessionInfo)
							  , "Brakes", this.createBrakesState(sessionInfo)
							  , "Strategy", this.createStrategyState(sessionInfo)
							  , "Pitstop", this.createPitstopState(sessionInfo)
							  , "Standings", this.createStandingsState(sessionInfo))

			fileName := temporaryFileName("Session State", "json")

			deleteFile(fileName)

			FileAppend(JSON.print(sessionState, "`t"), fileName)

			loop 10
				try {
					FileMove(fileName, this.StateFile, 1)

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

initializeInterfacePlugin() {
	local controller := SimulatorController.Instance

	InterfacePlugin(controller, kInterfacePlugin, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeInterfacePlugin()