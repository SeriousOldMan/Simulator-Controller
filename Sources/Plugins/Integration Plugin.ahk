;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Integration Plugin              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Task.ahk"
#Include "..\Libraries\JSON.ahk"
#Include "Driving Coach Plugin.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kIntegrationPlugin := "Integration"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class IntegrationPlugin extends ControllerPlugin {
	iDrivingCoach := false

	iStateFile := (kTempDirectory . "Session State.json")
	iAssistantsStateTask := false

	DrivingCoach {
		Get {
			return this.iDrivingCoach
		}
	}

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
		super.__New(controller, name, configuration)

		this.iStateFile := this.getArgumentValue("stateFile", kTempDirectory . "Session State.json")

		deleteFile(this.StateFile)

		if (this.Active || (isDebug() && isDevelopment())) {
			this.iAssistantsStateTask := PeriodicTask(ObjBindMethod(this, "updateSessionState"), 1000, kLowPriority)

			this.iAssistantsStateTask.start()
			this.iAssistantsStateTask.pause()

			this.updateSessionState()
		}

		this.iDrivingCoach := this.Controller.findPlugin(kDrivingCoachPlugin)
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
		local state := Map("Simulator", getMultiMapValue(sessionInfo, "Session", "Simulator", kNull)
						 , "Car", getMultiMapValue(sessionInfo, "Session", "Car", kNull)
						 , "Track", getMultiMapValue(sessionInfo, "Session", "Track", kNull)
						 , "Session", translate(getMultiMapValue(sessionInfo, "Session", "Type", kNull)))

		if (getMultiMapValue(sessionInfo, "Session", "Simulator", kNull) = kNull)
			state["Profile"] := kNull
		else if (getMultiMapValue(sessionInfo, "Session", "Profile", kUndefined) != kUndefined)
			state["Profile"] := getMultiMapValue(sessionInfo, "Session", "Profile")
		else
			state["Profile"] := translate("Standard")

		return state
	}

	createDurationState(sessionInfo) {
		local sessionTime := getMultiMapValue(sessionInfo, "Session", "Time.Remaining", kUndefined)
		local stintTime := getMultiMapValue(sessionInfo, "Stint", "Time.Remaining.Stint", kUndefined)
		local driverTime := getMultiMapValue(sessionInfo, "Stint", "Time.Remaining.Driver", kUndefined)
		local sessionLaps := getMultiMapValue(sessionInfo, "Session", "Laps.Remaining", 0)
		local stintLaps := getMultiMapValue(sessionInfo, "Stint", "Laps.Remaining.Stint", 0)
		local lastValid := getMultiMapValue(sessionInfo, "Stint", "Valid", true)
		local state := Map()
		local remainingStintTime, remainingSessionTime, remainingDriverTime

		if isNumber(sessionTime)
			remainingSessionTime := displayValue("Time", sessionTime)
		else
			remainingSessionTime := kNull

		if isNumber(stintTime)
			remainingStintTime := displayValue("Time", stintTime)
		else
			remainingStintTime := kNull

		if isNumber(driverTime)
			remainingDriverTime := displayValue("Time", driverTime)
		else
			remainingDriverTime := kNull

		state["Format"] := translate(getMultiMapValue(sessionInfo, "Session", "Format", kNull))
		state["SessionTimeLeft"] := remainingSessionTime
		state["StintTimeLeft"] := remainingStintTime
		state["StintTimeLeft"] := remainingDriverTime
		state["SessionLapsLeft"] := sessionLaps
		state["StintLapsLeft"] := stintLaps

		return state
	}

	createConditionsState(sessionInfo) {
		local weatherNow := getMultiMapValue(sessionInfo, "Weather", "Now", kNull)
		local weather10Min := getMultiMapValue(sessionInfo, "Weather", "10Min", kNull)
		local weather30Min := getMultiMapValue(sessionInfo, "Weather", "30Min", kNull)

		return Map("Weather", translate(weatherNow)
				 , "AirTemperature", convertUnit("Temperature", getMultiMapValue(sessionInfo, "Weather", "Temperature", 23))
				 , "TrackTemperature", convertUnit("Temperature", getMultiMapValue(sessionInfo, "Track", "Temperature", 27))
				 , "Grip", translate(getMultiMapValue(sessionInfo, "Track", "Grip", kNull))
				 , "Weather10Min", translate(weather10Min)
				 , "Weather30Min", translate(weather30Min))
	}

	createStintState(sessionInfo) {
		local lastLap := getMultiMapValue(sessionInfo, "Session", "Laps", 0)
		local lastValid := getMultiMapValue(sessionInfo, "Stint", "Valid", true)
		local lastTime := getMultiMapValue(sessionInfo, "Stint", "Lap.Time.Last", 3600)
		local bestTime := getMultiMapValue(sessionInfo, "Stint", "Lap.Time.Best", 3600)
		local lastSpeed := getMultiMapValue(sessionInfo, "Stint", "Speed.Last", false)
		local bestSpeed := getMultiMapValue(sessionInfo, "Stint", "Speed.Best", false)

		return Map("Driver", getMultiMapValue(sessionInfo, "Stint", "Driver")
				 , "Laps", getMultiMapValue(sessionInfo, "Stint", "Laps")
				 , "Lap", (lastLap + 1)
				 , "Position", getMultiMapValue(sessionInfo, "Stint", "Position")
				 , "BestTime", ((bestTime < 3600) ? displayValue("Time", bestTime) : kNull)
				 , "LastTime", ((lastTime < 3600) ? displayValue("Time", lastTime) : kNull)
				 , "BestSpeed", (bestSpeed ? convertUnit("Speed", bestSpeed) : kNull)
				 , "LastSpeed", (bestSpeed ? convertUnit("Speed", lastSpeed) : kNull))
	}


	createFuelState(sessionInfo) {
		local fuelLow := (Floor(getMultiMapValue(sessionInfo, "Stint", "Laps.Remaining.Fuel", 0)) < 4)

		return Map("LastConsumption", convertUnit("Volume", getMultiMapValue(sessionInfo, "Stint", "Fuel.Consumption", 0))
				 , "AvgConsumption", convertUnit("Volume", getMultiMapValue(sessionInfo, "Stint", "Fuel.AvgConsumption", 0))
				 , "RemainingFuel", convertUnit("Volume", getMultiMapValue(sessionInfo, "Stint", "Fuel.Remaining", 0))
				 , "RemainingLaps", Floor(getMultiMapValue(sessionInfo, "Stint", "Laps.Remaining.Fuel", 0)))
	}

	createTyresState(sessionInfo) {
		local state := Map()
		local pressures, temperatures, wear, tyreSet

		pressures := string2Values(",", getMultiMapValue(sessionInfo, "Tyres", "Pressures.Hot", ""))

		if (pressures.Length = 4) {
			state["HotPressures"] := [convertUnit("Pressure", pressures[1]), convertUnit("Pressure", pressures[2])
								    , convertUnit("Pressure", pressures[3]), convertUnit("Pressure", pressures[4])]
		}
		else
			state["HotPressures"] := [kNull, kNull, kNull, kNull]

		pressures := string2Values(",", getMultiMapValue(sessionInfo, "Tyres", "Pressures.Cold", ""))

		if ((pressures.Length = 4) && (pressures[1] != 0)) {
			state["ColdPressures"] := [convertUnit("Pressure", pressures[1]), convertUnit("Pressure", pressures[2])
									 , convertUnit("Pressure", pressures[3]), convertUnit("Pressure", pressures[4])]
		}
		else
			state["ColdPressures"] := [kNull, kNull, kNull, kNull]

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

		state["TyreCompound"] := translate(getMultiMapValue(sessionInfo, "Tyres", "Compound", "-"))

		tyreSet := getMultiMapValue(sessionInfo, "Tyres", "Set", false)

		state["TyreSet"] := (tyreSet ? tyreSet : kNull)

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
		local pitstopsCount := getMultiMapValue(sessionInfo, "Strategy", "Pitstops", kUndefined)
		local nextPitstop := getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next", false)
		local remainingPitstops := 0
		local state := Map()
		local pitstops := []
		local nextPitstop, tyreCompound, tyreCompoundColor, pitstop, position

		if (pitstopsCount == kUndefined) {
			pitstopsCount := 0

			state["State"] := "Unavailable"
		}
		else
			state["State"] := "Active"

		if (nextPitstop && (pitstopsCount != 0))
			remainingPitstops := (pitstopsCount - nextPitstop + 1)

		state["PlannedPitstops"] := pitstopsCount
		state["RemainingPitstops"] := remainingPitstops

		if nextPitstop {
			state["Lap"] := getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Lap", kNull)
			state["Fuel"] := convertUnit("Volume", getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Refuel", 0))

			tyreCompound := getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Tyre.Compound")

			if tyreCompound
				tyreCompound := translate(compound(tyreCompound, getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Tyre.Compound.Color")))
			else
				tyreCompound := kNull

			state["TyreCompound"] := tyreCompound

			position := getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Position", false)

			state["Position"] := (position ? position : kNull)
		}
		else {
			state["Lap"] := kNull
			state["Fuel"] := kNull
			state["TyreCompound"] := kNull
			state["Position"] := kNull
		}

		loop pitstopsCount {
			pitstop := Map("Nr", A_Index
						 , "Lap", getMultiMapValue(sessionInfo, "Strategy", "Pitstop." . A_Index . ".Lap")
						 , "Fuel", getMultiMapValue(sessionInfo, "Strategy", "Pitstop." . A_Index . ".Fuel.Amount"))

			if getMultiMapValue(sessionInfo, "Strategy", "Pitstop." . A_Index . ".Tyre.Change") {
				tyreCompound := getMultiMapValue(sessionInfo, "Strategy", "Pitstop." . A_Index . ".Tyre.Compound")
				tyreCompoundColor := getMultiMapValue(sessionInfo, "Strategy", "Pitstop." . A_Index . ".Tyre.Compound.Color")

				pitstop["TyreCompound"] := translate(compound(tyreCompound, tyreCompoundColor))
			}
			else
				pitstop["TyreCompound"] := kNull

			pitstops.Push(pitstop)
		}

		state["Pitstops"] := pitstops

		return state
	}

	createPitstopState(sessionInfo) {
		local pitstopNr := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Nr", kUndefined)
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

		if (pitstopNr == kUndefined) {
			pitstopNr := false

			state["State"] := "Unavailable"
		}
		else
			state["State"] := "Planned"

		if pitstopNr {
			state["Number"] := pitstopNr
			state["Lap"] := ((pitstopLap != 0) ? pitstopLap : kNull)
			state["ServiceTime"] := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Time.Service", 0)
			state["RepairTime"] := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Time.Repairs", 0)
			state["PitlaneDelta"] := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Time.Pitlane", 0)
			state["Fuel"] := convertUnit("Volume", getMultiMapValue(sessionInfo, "Pitstop", "Planned.Refuel"))

			tyreCompound := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Compound")

			if (tyreCompound && (tyreCompound != "-")) {
				tyreCompound := translate(compound(tyreCompound, getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Compound.Color")))

				state["TyreCompound"] := tyreCompound

				tyreSet := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Set")

				state["TyreSet"] := (tyreSet ? tyreSet : kNull)

				state["TyrePressures"] := [convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.FL"))
										 , convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.FR"))
										 , convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.RL"))
										 , convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.RR"))]
				state["TyrePressureIncrements"] := [convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.FL.Increment"))
												  , convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.FR.Increment"))
												  , convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.RL.Increment"))
										          , convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.RR.Increment"))]
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
		else if (getMultiMapValue(sessionInfo, "Pitstop", "Target.Fuel.Amount", kUndefined) != kUndefined) {
			state["State"] := "Forecast"
			state["Number"] := kNull
			state["Lap"] := kNull
			state["Repairs"] := kNull
			state["Prepared"] := kNull

			state["Fuel"] := convertUnit("Volume", getMultiMapValue(sessionInfo, "Pitstop", "Target.Fuel.Amount"))

			tyreCompound := getMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Compound")

			if (tyreCompound && (tyreCompound != "-")) {
				tyreCompound := translate(normalizeCompound(tyreCompound))

				state["TyreCompound"] := tyreCompound

				tyreSet := getMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Set")

				state["TyreSet"] := (tyreSet ? tyreSet : kNull)

				state["TyrePressures"] := [convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Pressure.FL"))
										 , convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Pressure.FR"))
										 , convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Pressure.RL"))
										 , convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Pressure.RR"))]
				state["TyrePressureIncrements"] := [convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Pressure.FL.Increment"))
												  , convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Pressure.FR.Increment"))
												  , convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Pressure.RL.Increment"))
										          , convertUnit("Pressure", getMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Pressure.RR.Increment"))]
			}
			else {
				state["TyreCompound"] := kNull
				state["TyreSet"] := kNull
				state["TyrePressures"] := [kNull, kNull, kNull, kNull]
				state["TyrePressureIncrements"] := [kNull, kNull, kNull, kNull]
			}
		}
		else {
			state["Number"] := kNull
			state["Lap"] := kNull
			state["Fuel"] := kNull
			state["TyreCompound"] := kNull
			state["TyreSet"] := kNull
			state["TyrePressures"] := [kNull, kNull, kNull, kNull]
			state["TyrePressureIncrements"] := [kNull, kNull, kNull, kNull]
			state["Repairs"] := kNull
			state["Prepared"] := kNull
		}

		return state
	}

	createStandingsState(sessionInfo) {
		local positionOverall := getMultiMapValue(sessionInfo, "Standings", "Position.Overall", 0)
		local positionClass := getMultiMapValue(sessionInfo, "Standings", "Position.Class", 0)
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
				nr := getMultiMapValue(sessionInfo, "Standings", opponent . ".Nr", false)

				state[opponent] := Map("Laps", getMultiMapValue(sessionInfo, "Standings", opponent . ".Laps")
									 , "Delta", displayValue("Time", getMultiMapValue(sessionInfo, "Standings", opponent . ".Delta"))
									 , "LapTime", displayValue("Time", getMultiMapValue(sessionInfo, "Standings", opponent . ".Lap.Time"))
									 , "InPit", (getMultiMapValue(sessionInfo, "Standings", opponent . ".InPit") ? kTrue : kFalse))

				state[opponent]["Nr"] := (nr ? nr : kNull)
			}
			else
				state[opponent] := kNull

		return state
	}

	createDamageState(sessionInfo) {
		local state := Map()
		local ignore, position, subState

		static projection := Map("FL", "FrontLeft", "FR", "FrontRight", "RL", "RearLeft", "RR", "RearRight")

		subState := Map()

		for ignore, position in ["Front", "Rear", "Left", "Right", "All"]
			subState[position] := getMultiMapValue(sessionInfo, "Damage", "Bodywork." . position, kNull)

		state["Bodywork"] := subState

		subState := Map()

		for ignore, position in ["FL", "FR", "RL", "RR"]
			subState[projection[position]] := getMultiMapValue(sessionInfo, "Damage", "Suspension." . position, kNull)

		state["Suspension"] := subState

		state["Engine"] := getMultiMapValue(sessionInfo, "Damage", "Engine", kNull)

		state["LapDelta"] := getMultiMapValue(sessionInfo, "Damage", "Lap.Delta", kNull)
		state["RepairTime"] := getMultiMapValue(sessionInfo, "Damage", "Time.Repairs", kNull)

		return state
	}

	createCornerInstructions(sessionInfo) {
		local coachingState := readMultiMap(kTempDirectory . "Driving Coach\Coaching.state")
		local coachingHints := string2Values(",", getMultiMapValue(coachingState, "Instructions", "Instructions", ""))
		local state := kNull
		local ignore, hint, hints, message

		if (coachingHints.Length > 0) {
			hints := []

			for ignore, hint in coachingHints {
				message := getMultiMapValue(coachingState, "Instructions", hint, false)

				hints.Push(Map("Hint", hint, "Message", message ? message : kNull))
			}

			state := Map("Corner", getMultiMapValue(coachingState, "Instructions", "Corner", kNull), "Hints", hints)
		}

		return state
	}

	updateControllerState(sessionState, controllerState) {
		local assistantsState := Map()
		local teamServerState := Map()
		local automationState := Map()
		local ignore, property, key, value, state, configuration

		for key, state in getMultiMapValues(controllerState, "Race Assistants") {
			if ((key = "Mode") || (key = "Session"))
				assistantsState[key] := translate(state)
			else {
				if !assistantsState.Has(key)
					assistantsState[key] := Map()

				if (state = "Active")
					assistantsState[key]["State"] := "Active"
				else if (state = "Waiting")
					assistantsState[key]["State"] := "Waiting"
				else if (state = "Shutdown")
					assistantsState[key]["State"] := "Finished"
				else
					assistantsState[key]["State"] := "Disabled"

				assistantsState[key]["Silent"] := (getMultiMapValue(controllerState, key, "Silent", false) ? kTrue : kFalse)
				assistantsState[key]["Muted"] := (getMultiMapValue(controllerState, key, "Muted", false) ? kTrue : kFalse)

				configuration := readMultiMap(kTempDirectory . key . ".state")

				if !getMultiMapValue(configuration, "Voice", "Speaker", true)
					assistantsState[key]["Silent"] := kTrue

				if getMultiMapValue(configuration, "Voice", "Muted", false)
					assistantsState[key]["Muted"] := kTrue
			}
		}

		if (assistantsState.Count == 0) {
			assistantsState["Mode"] := kNull
			assistantsState["Session"] := kNull
			assistantsState["Driving Coach"] := Map("State", "Disabled", "Silent", kNull, "Muted", kNull)
			assistantsState["Race Engineer"] := Map("State", "Disabled", "Silent", kNull, "Muted", kNull)
			assistantsState["Race Strategist"] := Map("State", "Disabled", "Silent", kNull, "Muted", kNull)
			assistantsState["Race Spotter"] := Map("State", "Disabled", "Silent", kNull, "Muted", kNull)
		}

		sessionState["Assistants"] := assistantsState

		state := getMultiMapValue(controllerState, "Team Server", "State", "Disabled")

		try {
			if ((state != "Unknown") && (state != "Disabled")) {
				state := CaseInsenseMap()

				for ignore, property in string2Values(";", getMultiMapValue(controllerState, "Team Server", "Properties")) {
					property := StrSplit(property, ":", " `t", 2)

					state[property[1]] := property[2]
				}

				teamServerState["Server"] := state["ServerURL"]
				teamServerState["Token"] := state["SessionToken"]
				teamServerState["Team"] := state["Team"]
				teamServerState["Driver"] := state["Driver"]
				teamServerState["Session"] := state["Session"]
			}
			else
				throw "Unknown Team Server state..."
		}
		catch Any as exception {
			teamServerState["Server"] := kNull
			teamServerState["Token"] := kNull
			teamServerState["Team"] := kNull
			teamServerState["Driver"] := kNull
			teamServerState["Session"] := kNull
		}

		sessionState["TeamServer"] := teamServerState

		state := getMultiMapValue(controllerState, "Track Automation", "State", "Disabled")

		if ((state != "Unknown") && (state != "Disabled")) {
			if (state = "Passive")
				automationState["State"] := "Waiting"
			else {
				automation := getMultiMapValue(controllerState, "Track Automation", "Automation", false)

				automationState["State"] := (automation ? "Active" : "Unavailable")

				automationState["Simulator"] := getMultiMapValue(controllerState, "Track Automation", "Simulator")
				automationState["Car"] := getMultiMapValue(controllerState, "Track Automation", "Car")
				automationState["Track"] := getMultiMapValue(controllerState, "Track Automation", "Track")
				automationState["Automation"] := (automation ? automation : kNull)
			}
		}
		else {
			automationState["Simulator"] := kNull
			automationState["Car"] := kNull
			automationState["Track"] := kNull
			automationState["Automation"] := kNull
			automationState["State"] := "Disabled"
		}

		sessionState["Automation"] := automationState
	}

	updateSessionState() {
		local needsUpdate := !FileExist(this.StateFile)
		local sessionInfo, sessionState, ignore, assistant, fileName

		static lastUpdate := A_Now

		for ignore, assistant in kRaceAssistants {
			fileName := (kTempDirectory . assistant . " Session.state")

			if (FileExist(fileName) && (FileGetTime(fileName, "M") > lastUpdate)) {
				needsUpdate := true

				break
			}
		}

		fileName := (kTempDirectory . "Simulator Controller.state")

		if (FileExist(fileName) && (FileGetTime(fileName, "M") > lastUpdate))
			needsUpdate := true

		if needsUpdate {
			lastUpdate := A_Now
			sessionInfo := newMultiMap()

			for ignore, assistant in kRaceAssistants
				addMultiMapValues(sessionInfo, readMultiMap(kTempDirectory . assistant . " Session.state"))

			sessionState := Map("Session", this.createSessionState(sessionInfo)
							  , "Duration", this.createDurationState(sessionInfo)
							  , "Conditions", this.createConditionsState(sessionInfo)
							  , "Stint", this.createStintState(sessionInfo)
							  , "Fuel", this.createFuelState(sessionInfo)
							  , "Tyres", this.createTyresState(sessionInfo)
							  , "Brakes", this.createBrakesState(sessionInfo)
							  , "Strategy", this.createStrategyState(sessionInfo)
							  , "Damage", this.createDamageState(sessionInfo)
							  , "Pitstop", this.createPitstopState(sessionInfo)
							  , "Standings", this.createStandingsState(sessionInfo))

			if (this.DrivingCoach && this.DrivingCoach.TrackCoachingActive) {
				sessionState["Instructions"] := this.createCornerInstructions(sessionInfo)

				if Task.CurrentTask {
					Task.CurrentTask.Priority := kHighPriority
					Task.CurrentTask.Sleep := 500
				}
			}
			else if Task.CurrentTask {
				Task.CurrentTask.Priority := kLowPriority
				Task.CurrentTask.Sleep := 1000
			}

			this.updateControllerState(sessionState, readMultiMap(kTempDirectory . "Simulator Controller.state"))

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

	writePluginState(configuration) {
		if this.Active
			setMultiMapValue(configuration, this.Plugin, "State", "Active")
		else
			super.writePluginState(configuration)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeIntegrationPlugin() {
	local controller := SimulatorController.Instance

	IntegrationPlugin(controller, kIntegrationPlugin, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeIntegrationPlugin()