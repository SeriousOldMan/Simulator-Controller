;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Integration Plugin              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Extensions\Task.ahk"
#Include "..\Framework\Extensions\JSON.ahk"
#Include "Driving Coach Plugin.ahk"
#Include "Libraries\SimulatorProvider.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kIntegrationPlugin := "Integration"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class IntegrationPlugin extends ControllerPlugin {
	iDrivingCoach := false

	iProvider := false

	iStateFile := (kTempDirectory . "Session State.json")
	iAssistantsStateTask := false

	iLanguage := "EN"
	iUnits := CaseInsenseMap("Pressure", "PSI"
						   , "Temperature", "Celsius"
						   , "Volume", "Liter"
						   , "Speed", "km/h")
	iFormats := CaseInsenseMap("Time", "[H:]M:S.##")

	DrivingCoach {
		Get {
			return this.iDrivingCoach
		}
	}

	Provider {
		Get {
			return this.iProvider
		}
	}

	StateFile {
		Get {
			return this.iStateFile
		}
	}

	Language {
		Get {
			return this.iLanguage
		}
	}

	Format[key] {
		Get {
			return this.iFormats[key]
		}
	}

	Unit[key] {
		Get {
			return this.iUnits[key]
		}
	}

	AssistantsStateTask {
		Get {
			return this.iAssistantsStateTask
		}
	}

	__New(controller, name, configuration := false) {
		local format, ignore, unit

		super.__New(controller, name, configuration)

		this.iStateFile := this.getArgumentValue("stateFile", kTempDirectory . "Session State.json")

		deleteFile(this.StateFile)

		this.iLanguage := this.getArgumentValue("stateFile", "EN")

		if !inList(availableLanguages(), this.iLanguage)
			this.iLanguage := "EN"

		formats := string2Values(A_Space, this.getArgumentValue("formats", ""))

		if ((format.Length = 2) && (format[1] = "Time") && inList(kTimeFormats, format[2]))
			this.iFormats["Time"] := format[2]

		for ignore, unit in string2Values(",", this.getArgumentValue("units", ""))
			for ignore, unit in string2Values(A_Space, unit)
				if (unit.Length = 2)
					switch unit[1], false {
						case "Volume":
							if inList(kVolumeUnits, unit[2])
								this.iUnits[unit[1]] := unit[2]
						case "Pressure":
							if inList(kPressureUnits, unit[2])
								this.iUnits[unit[1]] := unit[2]
						case "Temperature":
							if inList(kTemperatureUnits, unit[2])
								this.iUnits[unit[1]] := unit[2]
						case "Speed":
							if inList(kSpeedUnits, unit[2])
								this.iUnits[unit[1]] := unit[2]
					}

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
		local state

		if getMultiMapValue(sessionInfo, "Session", "Simulator", false) {
			state := Map("Simulator", getMultiMapValue(sessionInfo, "Session", "Simulator")
					   , "Car", getMultiMapValue(sessionInfo, "Session", "Car", kNull)
					   , "Track", getMultiMapValue(sessionInfo, "Session", "Track", kNull)
					   , "Session", translate(getMultiMapValue(sessionInfo, "Session", "Type", kNull), this.Language))

			if (getMultiMapValue(sessionInfo, "Session", "Simulator", kNull) = kNull)
				state["Profile"] := kNull
			else if (getMultiMapValue(sessionInfo, "Session", "Profile", kUndefined) != kUndefined)
				state["Profile"] := getMultiMapValue(sessionInfo, "Session", "Profile")
			else
				state["Profile"] := translate("Standard", this.Language)

			return state
		}
		else
			return kNull
	}

	createDurationState(sessionInfo) {
		local format := {Type: "Time", Format: this.Format["Time"]}
		local sessionTime, stintTime, driverTime, state

		if getMultiMapValue(sessionInfo, "Session", "Simulator", false) {
			state := Map()

			sessionTime := getMultiMapValue(sessionInfo, "Session", "Time.Remaining", kUndefined)
			stintTime := getMultiMapValue(sessionInfo, "Stint", "Time.Remaining.Stint", kUndefined)
			driverTime := getMultiMapValue(sessionInfo, "Stint", "Time.Remaining.Driver", kUndefined)

			if getMultiMapValue(sessionInfo, "Session", "Format", false)
				state["Format"] := translate(getMultiMapValue(sessionInfo, "Session", "Format"), this.Language)

			state["SessionLapsLeft"] := getMultiMapValue(sessionInfo, "Session", "Laps.Remaining", 0)
			state["StintLapsLeft"] := getMultiMapValue(sessionInfo, "Stint", "Laps.Remaining.Stint", 0)

			if isNumber(sessionTime)
				state["SessionTimeLeft"] := displayValue(format, sessionTime)

			if isNumber(stintTime)
				state["StintTimeLeft"] := displayValue(format, stintTime)

			if isNumber(driverTime)
				state["DriverTimeLeft"] := displayValue(format, driverTime)

			return state
		}
		else
			return kNull
	}

	createConditionsState(sessionInfo) {
		local weatherNow := getMultiMapValue(sessionInfo, "Weather", "Now", false)
		local weather10Min := getMultiMapValue(sessionInfo, "Weather", "10Min", false)
		local weather30Min := getMultiMapValue(sessionInfo, "Weather", "30Min", false)
		local grip := getMultiMapValue(sessionInfo, "Track", "Grip", false)
		local unit := {Type: "Temperature", Unit: this.Unit["Temperature"]}

		local state := Map("AirTemperature", convertUnit(unit, getMultiMapValue(sessionInfo, "Weather", "Temperature", 23))
						 , "TrackTemperature", convertUnit(unit, getMultiMapValue(sessionInfo, "Track", "Temperature", 27)))

		if grip
			state["Grip"] := translate(grip, this.Language)

		if weatherNow
			state["Weather"] := translate(weatherNow, this.Language)

		if weather10Min
			state["Weather10Min"] := translate(weather10Min, this.Language)

		if weather30Min
			state["Weather30Min"] := translate(weather30Min, this.Language)

		if ((state.Count > 2) || getMultiMapValue(sessionInfo, "Weather", "Temperature", false)
							  || getMultiMapValue(sessionInfo, "Track", "Temperature", false))
			return state
		else
			return kNull
	}

	createStintState(sessionInfo) {
		local format := {Type: "Time", Format: this.Format["Time"]}
		local lastTime := getMultiMapValue(sessionInfo, "Stint", "Lap.Time.Last", 3600)
		local bestTime := getMultiMapValue(sessionInfo, "Stint", "Lap.Time.Best", 3600)
		local lastSpeed := getMultiMapValue(sessionInfo, "Stint", "Speed.Last", false)
		local bestSpeed := getMultiMapValue(sessionInfo, "Stint", "Speed.Best", false)
		local unit := {Type: "Speed", Unit: this.Unit["Speed"]}
		local state

		if (getMultiMapValue(sessionInfo, "Session", "Simulator", false) && getMultiMapValue(sessionInfo, "Stint", "Position", false)) {
			state := Map("Driver", getMultiMapValue(sessionInfo, "Stint", "Driver")
					   , "Laps", getMultiMapValue(sessionInfo, "Stint", "Laps")
					   , "Lap", (getMultiMapValue(sessionInfo, "Session", "Laps", 0) + 1)
					   , "Position", getMultiMapValue(sessionInfo, "Stint", "Position"))

			if (bestTime < 3600)
				state["BestTime"] := displayValue(format, bestTime)

			if (lastTime < 3600)
				state["LastTime"] := displayValue(format, lastTime)

			if bestSpeed
				state["BestSpeed"] := convertUnit(unit, bestSpeed)

			if lastSpeed
				state["LastSpeed"] := convertUnit(unit, lastSpeed)

			return state
		}
		else
			return kNull
	}

	createFuelState(sessionInfo) {
		local unit := {Type: "Volume", Unit: this.Unit["Volume"]}
		local fuelLow := (Floor(getMultiMapValue(sessionInfo, "Stint", "Laps.Remaining.Fuel", 0)) < 4)
		local state := Map("LastConsumption", convertUnit(unit, getMultiMapValue(sessionInfo, "Stint", "Fuel.Consumption", 0))
						 , "AvgConsumption", convertUnit(unit, getMultiMapValue(sessionInfo, "Stint", "Fuel.AvgConsumption", 0))
						 , "RemainingFuel", convertUnit(unit, getMultiMapValue(sessionInfo, "Stint", "Fuel.Remaining", 0))
						 , "RemainingLaps", Floor(getMultiMapValue(sessionInfo, "Stint", "Laps.Remaining.Fuel", 0)))

		state["LastFuelConsumption"] := state["LastConsumption"]
		state["AvgFuelConsumption"] := state["AvgConsumption"]
		state["RemainingFuelLaps"] := state["RemainingLaps"]

		if (getMultiMapValue(sessionInfo, "Stint", "Energy.Consumption", kUndefined) != kUndefined) {
			state["RemainingEnergy"] := Round(getMultiMapValue(sessionInfo, "Stint", "Energy.Remaining"), 0)
			state["LastEnergyConsumption"] := Round(getMultiMapValue(sessionInfo, "Stint", "Energy.Consumption"), 0)
			state["AvgEnergyConsumption"] := Round(getMultiMapValue(sessionInfo, "Stint", "Energy.AvgConsumption"), 0)
			state["RemainingEnergyLaps"] := Floor(getMultiMapValue(sessionInfo, "Stint", "Laps.Remaining.Fuel", 0))
		}

		if exist(getValues(state), (v) => (v > 0))
			return state
		else
			return kNull
	}

	createTyresState(sessionInfo) {
		local temperatureUnit := {Type: "Temperature", Unit: this.Unit["Temperature"]}
		local pressureUnit := {Type: "Pressure", Unit: this.Unit["Pressure"]}
		local state := Map()
		local mixedCompounds := false
		local tyreSet := false
		local pressures, temperatures, wear, tyreSet, laps, tyreCompound

		nonZero(value) {
			return (!isNull(value) && (value != 0) && (value != "-"))
		}

		if this.Provider
			this.Provider.supportsTyreManagement(&mixedCompounds, &tyreSet)

		pressures := string2Values(",", getMultiMapValue(sessionInfo, "Tyres", "Pressures.Hot", ""))

		if ((pressures.Length = 4) && all(pressures, nonZero))
			state["HotPressures"] := [convertUnit(pressureUnit, pressures[1]), convertUnit(pressureUnit, pressures[2])
								    , convertUnit(pressureUnit, pressures[3]), convertUnit(pressureUnit, pressures[4])]

		pressures := string2Values(",", getMultiMapValue(sessionInfo, "Tyres", "Pressures.Cold", ""))

		if ((pressures.Length = 4) && all(pressures, nonZero))
			state["ColdPressures"] := [convertUnit(pressureUnit, pressures[1]), convertUnit(pressureUnit, pressures[2])
									 , convertUnit(pressureUnit, pressures[3]), convertUnit(pressureUnit, pressures[4])]

		pressures := string2Values(",", getMultiMapValue(sessionInfo, "Tyres", "Pressures.Loss", ""))

		if ((pressures.Length = 4) && all(pressures, (p) => isNumber(p)))
			state["PressureLosses"] := [convertUnit(pressureUnit, pressures[1]), convertUnit(pressureUnit, pressures[2])
									  , convertUnit(pressureUnit, pressures[3]), convertUnit(pressureUnit, pressures[4])]

		temperatures := string2Values(",", getMultiMapValue(sessionInfo, "Tyres", "Temperatures", ""))

		if ((temperatures.Length = 4) && all(temperatures, nonZero))
			state["Temperatures"] := [convertUnit(temperatureUnit, temperatures[1]), convertUnit(temperatureUnit, temperatures[2])
									, convertUnit(temperatureUnit, temperatures[3]), convertUnit(temperatureUnit, temperatures[4])]

		wear := string2Values(",", getMultiMapValue(sessionInfo, "Tyres", "Wear", ""))

		if ((wear.Length = 4) && all(wear, (w) => isNumber(w)))
			state["Wear"] := [wear[1], wear[2], wear[3], wear[4]]

		laps := string2Values(",", getMultiMapValue(sessionInfo, "Tyres", "Laps", ""))

		if ((laps.Length = 4) && all(laps, (l) => isNumber(l)))
			state["Laps"] := [Round(laps[1]), Round(laps[2]), Round(laps[3]), Round(laps[4])]

		tyreCompound := []

		state["TyreCompounds"] := tyreCompound

		if (mixedCompounds = "Wheel") {
			for ignore, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"]
				tyreCompound.Push(translate(getMultiMapValue(sessionInfo, "Tyres", "Compound" . tyre, "-"), this.Language))
		}
		else if (mixedCompounds = "Axle") {
			for ignore, tyre in ["Front", "Rear"] {
				tyreCompound.Push(translate(getMultiMapValue(sessionInfo, "Tyres", "Compound" . tyre, "-"), this.Language))
				tyreCompound.Push(translate(getMultiMapValue(sessionInfo, "Tyres", "Compound" . tyre, "-"), this.Language))
			}
		}
		else
			for ignore, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"]
				tyreCompound.Push(translate(getMultiMapValue(sessionInfo, "Tyres", "Compound", "-"), this.Language))

		if tyreSet {
			tyreSet := getMultiMapValue(sessionInfo, "Tyres", "Set", false)

			if tyreSet
				state["TyreSet"] := tyreSet
		}

		if exist(tyreCompound, (tc) => (tc = translate("-")))
			return kNull
		else
			return state
	}

	createBrakesState(sessionInfo) {
		local unit := {Type: "Temperature", Unit: this.Unit["Temperature"]}
		local state := Map()
		local temperatures, wear

		temperatures := string2Values(",", getMultiMapValue(sessionInfo, "Brakes", "Temperatures", ""))

		if (temperatures.Length = 4)
			state["Temperatures"] := [convertUnit(unit, temperatures[1]), convertUnit(unit, temperatures[2])
									, convertUnit(unit, temperatures[3]), convertUnit(unit, temperatures[4])]

		wear := string2Values(",", getMultiMapValue(sessionInfo, "Brakes", "Wear", ""))

		if (wear.Length = 4)
			state["Wear"] := [Round(wear[1], 2), Round(wear[2], 2), Round(wear[3], 2), Round(wear[4], 2)]

		return ((state.Count > 0) ? state : kNull)
	}

	createEngineState(sessionInfo) {
		local unit := {Type: "Temperature", Unit: this.Unit["Temperature"]}
		local state := Map()
		local temperature

		temperature := getMultiMapValue(sessionInfo, "Engine", "WaterTemperature", kUndefined)

		if (temperature != kUndefined)
			state["WaterTemperature"] := convertUnit(unit, temperature)

		temperature := getMultiMapValue(sessionInfo, "Engine", "OilTemperature", kUndefined)

		if (temperature != kUndefined)
			state["OilTemperature"] := convertUnit(unit, temperature)

		return state
	}

	createStrategyState(sessionInfo) {
		local unit := {Type: "Volume", Unit: this.Unit["Volume"]}
		local pitstopsCount := getMultiMapValue(sessionInfo, "Strategy", "Pitstops", kUndefined)
		local nextPitstop := getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next", false)
		local remainingPitstops := 0
		local state := Map()
		local pitstops := []
		local fuelService := false
		local tyreService := false
		local nextPitstop, tyreCompound, tyreCompoundColor, pitstop, position, index, tyre, axle

		if (pitstopsCount == kUndefined)
			return kNull
		else {
			if this.Provider
				this.Provider.supportsPitstop(&fuelService, &tyreService)

			if (nextPitstop && (pitstopsCount != 0))
				remainingPitstops := (pitstopsCount - nextPitstop + 1)

			state["PlannedPitstops"] := pitstopsCount
			state["RemainingPitstops"] := remainingPitstops

			if nextPitstop {
				nextPitstop := Map()

				state["NextPitstop"] := nextPitstop

				nextPitstop["Lap"] := getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Lap")

				if fuelService
					nextPitstop["Fuel"] := convertUnit(unit, getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Refuel", 0))

				if tyreService {
					tyreCompound := getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Tyre.Compound")

					if tyreCompound
						nextPitstop["TyreCompound"] := translate(compound(tyreCompound, getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Tyre.Compound.Color"))
															   , this.Language)
				}

				position := getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Position", false)

				if position
					nextPitstop["Position"] := position
			}

			loop pitstopsCount {
				pitstop := Map("Nr", A_Index
							 , "Lap", getMultiMapValue(sessionInfo, "Strategy", "Pitstop." . A_Index . ".Lap"))

				if fuelService
					pitstop["Fuel"] := getMultiMapValue(sessionInfo, "Strategy", "Pitstop." . A_Index . ".Fuel.Amount")

				if (tyreService && getMultiMapValue(sessionInfo, "Strategy", "Pitstop." . A_Index . ".Tyre.Change")) {
					tyreCompound := getMultiMapValue(sessionInfo, "Strategy", "Pitstop." . A_Index . ".Tyre.Compound")
					tyreCompoundColor := getMultiMapValue(sessionInfo, "Strategy", "Pitstop." . A_Index . ".Tyre.Compound.Color")

					pitstop["TyreCompound"] := translate(compound(tyreCompound, tyreCompoundColor), this.Language)
				}

				pitstops.Push(pitstop)
			}

			state["Pitstops"] := pitstops
		}

		return state
	}

	createPitstopState(sessionInfo) {
		local pressureUnit := {Type: "Pressure", Unit: this.Unit["Pressure"]}
		local volumeUnit := {Type: "Volume", Unit: this.Unit["Volume"]}
		local state := Map()
		local fuelService := false
		local tyreService := false
		local brakeService := false
		local repairService := []
		local tyreSet := false
		local tyreCompound, tyreSet, tyrePressures, index, tyre, axle
		local pressures, pressure, pressureIncrements
		local driverRequest, driver, compounds

		computeRepairs(bodywork, suspension, engine) {
			local service := Map()

			if inList(repairService, "Bodywork")
				service["Bodywork"] := (bodywork ? kTrue : kFalse)

			if inList(repairService, "Suspension")
				service["Suspension"] := (suspension ? kTrue : kFalse)

			if inList(repairService, "Engine")
				service["Engine"] := (engine ? kTrue : kFalse)

			return service
		}

		if this.Provider {
			this.Provider.supportsPitstop(&fuelService, &tyreService, &brakeService, &repairService)
			this.Provider.supportsTyreManagement( , &tyreSet)
		}

		if (getMultiMapValue(sessionInfo, "Pitstop", "Planned", false) && !getMultiMapValue(sessionInfo, "Pitstop", "Target.Planned", false))
			return kNull

		if getMultiMapValue(sessionInfo, "Pitstop", "Planned", false) {
			state["State"] := "Plan"

			state["Number"] := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Nr")

			if getMultiMapValue(sessionInfo, "Pitstop", "Planned.Lap", false)
				state["Lap"] := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Lap")

			if getMultiMapValue(sessionInfo, "Pitstop", "Planned.Time.Service", false)
				state["ServiceTime"] := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Time.Service")

			if getMultiMapValue(sessionInfo, "Pitstop", "Planned.Time.Pitlane", false)
				state["PitlaneDelta"] := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Time.Pitlane")

			if fuelService
				state["Fuel"] := convertUnit(volumeUnit, getMultiMapValue(sessionInfo, "Pitstop", "Planned.Refuel"))

			driverRequest := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Driver.Request", false)

			if driverRequest {
				driverRequest := string2Values("|", driverRequest)

				driver := string2Values(":", driverRequest[2])[1]

				if (driver != string2Values(":", driverRequest[1])[1])
					state["Driver"] := driver
				else
					state["Driver"] := string2Values(":", driverRequest[1])[1]
			}

			if ((repairService.Length > 0) && getMultiMapValue(sessionInfo, "Pitstop", "Planned.Time.Repairs", false))
				state["RepairTime"] := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Time.Repairs")

			compounds := []

			state["TyreCompounds"] := compounds

			if (tyreService = "Wheel") {
				for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
					tyreCompound := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Compound." . tyre)

					if (tyreCompound && (tyreCompound != "-"))
						tyreCompound := translate(compound(tyreCompound, getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Compound.Color." . tyre))
												, this.Language)
					else
						tyreCompound := kNull

					compounds.Push(tyreCompound)
				}
			}
			else if (tyreService = "Axle") {
				for index, axle in ["Front", "Rear"] {
					tyreCompound := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Compound." . axle)

					if (tyreCompound && (tyreCompound != "-"))
						tyreCompound := translate(compound(tyreCompound, getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Compound.Color." . axle))
												, this.Language)
					else
						tyreCompound := kNull

					compounds.Push(tyreCompound)
					compounds.Push(tyreCompound)
				}
			}
			else {
				tyreCompound := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Compound")

				if (tyreCompound && (tyreCompound != "-"))
					tyreCompound := translate(compound(tyreCompound, getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Compound.Color"))
											, this.Language)
				else
					tyreCompound := kNull

				loop 4
					compounds.Push(tyreCompound)
			}

			if (tyreService && exist(compounds, (tc) => (tc != kNull))) {
				if tyreSet {
					tyreSet := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Set")

					if tyreSet
						state["TyreSet"] := tyreSet
				}

				pressures := []
				pressureIncrements := []

				for ignore, tyre in ["FL", "FR", "RL", "RR"] {
					pressure := getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure." . tyre, false)

					if pressure {
						pressures.Push(convertUnit(pressureUnit, pressure))
						pressureIncrements.Push(convertUnit(pressureUnit, getMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure." . tyre . ".Increment")))
					}
					else {
						pressures.Push(kNull)
						pressureIncrements.Push(0)
					}
				}

				state["TyrePressures"] := pressures
				state["TyrePressureIncrements"] := pressureIncrements
			}

			if brakeService
				state["Brakes"] := (getMultiMapValue(sessionInfo, "Pitstop", "Planned.Brake.Change", false) ? kTrue : kFalse)

			if (repairService.Length > 0)
				state["Repairs"] := computeRepairs(getMultiMapValue(sessionInfo, "Pitstop", "Planned.Repair.Bodywork")
												 , getMultiMapValue(sessionInfo, "Pitstop", "Planned.Repair.Suspension")
												 , getMultiMapValue(sessionInfo, "Pitstop", "Planned.Repair.Engine"))

			state["Prepared"] := (getMultiMapValue(sessionInfo, "Pitstop", "Prepared", false) ? kTrue : kFalse)
		}
		else if getMultiMapValue(sessionInfo, "Pitstop", "Target.Planned", false) {
			state["State"] := "Forecast"

			if fuelService
				state["Fuel"] := convertUnit(volumeUnit, getMultiMapValue(sessionInfo, "Pitstop", "Target.Fuel.Amount"))

			compounds := []

			state["TyreCompounds"] := compounds

			if (tyreService = "Wheel") {
				for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
					tyreCompound := getMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Compound." . tyre)

					if (tyreCompound && (tyreCompound != "-"))
						tyreCompound := translate(compound(tyreCompound, getMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Compound.Color." . tyre))
												, this.Language)
					else
						tyreCompound := kNull

					compounds.Push(tyreCompound)
				}
			}
			else if (tyreService = "Axle") {
				for index, axle in ["Front", "Rear"] {
					tyreCompound := getMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Compound." . axle)

					if (tyreCompound && (tyreCompound != "-"))
						tyreCompound := translate(compound(tyreCompound, getMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Compound." . axle))
												, this.Language)
					else
						tyreCompound := kNull

					compounds.Push(tyreCompound)
					compounds.Push(tyreCompound)
				}
			}
			else {
				tyreCompound := getMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Compound")

				if (tyreCompound && (tyreCompound != "-"))
					tyreCompound := translate(normalizeCompound(tyreCompound), this.Language)
				else
					tyreCompound := kNull

				loop 4
					compounds.Push(tyreCompound)
			}

			if (tyreService && exist(compounds, (tc) => (tc != kNull))) {
				if tyreSet {
					tyreSet := getMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Set")

					if tyreSet
						state["TyreSet"] := tyreSet
				}

				pressures := []
				pressureIncrements := []

				for ignore, tyre in ["FL", "FR", "RL", "RR"] {
					pressure := getMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Pressure." . tyre, false)

					if pressure {
						pressures.Push(convertUnit(pressureUnit, pressure))
						pressureIncrements.Push(convertUnit(pressureUnit, getMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Pressure." . tyre . ".Increment")))
					}
					else {
						pressures.Push(kNull)
						pressureIncrements.Push(0)
					}
				}

				state["TyrePressures"] := pressures
				state["TyrePressureIncrements"] := pressureIncrements
			}

			if brakeService
				state["Brakes"] := (getMultiMapValue(sessionInfo, "Pitstop", "Target.Brake.Change", false) ? kTrue : kFalse)
		}

		return state
	}

	createStandingsState(sessionInfo) {
		local format := {Type: "Time", Format: this.Format["Time"]}
		local positionOverall := getMultiMapValue(sessionInfo, "Standings", "Position.Overall", 0)
		local positionClass := getMultiMapValue(sessionInfo, "Standings", "Position.Class", 0)
		local state := Map()
		local nr, opponent

		static lastLeaderDelta := false
		static lastAheadDelta := false
		static lastBehindDelta := false

		if (positionOverall > 0) {
			state["Position"] := positionOverall
			state["OverallPosition"] := positionOverall
			state["ClassPosition"] := positionClass

			for ignore, opponent in ["Leader", "Ahead", "Behind", "Focus"]
				if (getMultiMapValue(sessionInfo, "Standings", opponent . ".Lap.Time", kUndefined) != kUndefined) {
					nr := getMultiMapValue(sessionInfo, "Standings", opponent . ".Nr", false)

					state[opponent] := Map("Laps", getMultiMapValue(sessionInfo, "Standings", opponent . ".Laps")
										 , "Delta", displayValue(format, getMultiMapValue(sessionInfo, "Standings", opponent . ".Delta"))
										 , "LapTime", displayValue(format, getMultiMapValue(sessionInfo, "Standings", opponent . ".Lap.Time"))
										 , "InPit", (getMultiMapValue(sessionInfo, "Standings", opponent . ".InPit") ? kTrue : kFalse))

					state[opponent]["Nr"] := (nr ? nr : kNull)
				}
		}
		else
			state := kNull

		return state
	}

	createDamageState(sessionInfo) {
		local state := Map()
		local ignore, position, subState

		static projection := Map("FL", "FrontLeft", "FR", "FrontRight", "RL", "RearLeft", "RR", "RearRight")

		subState := Map()

		for ignore, position in ["Front", "Rear", "Left", "Right", "All"]
			if getMultiMapValue(sessionInfo, "Damage", "Bodywork." . position, false)
				subState[position] := getMultiMapValue(sessionInfo, "Damage", "Bodywork." . position)

		if (subState.Count > 0)
			state["Bodywork"] := subState

		subState := Map()

		for ignore, position in ["FL", "FR", "RL", "RR"]
			if getMultiMapValue(sessionInfo, "Damage", "Suspension." . position, false)
			subState[projection[position]] := getMultiMapValue(sessionInfo, "Damage", "Suspension." . position)

		if (subState.Count > 0)
			state["Suspension"] := subState

		if getMultiMapValue(sessionInfo, "Damage", "Engine", false)
			state["Engine"] := getMultiMapValue(sessionInfo, "Damage", "Engine")

		if (state.Count > 0) {
			if getMultiMapValue(sessionInfo, "Damage", "Lap.Delta", false)
				state["LapDelta"] := getMultiMapValue(sessionInfo, "Damage", "Lap.Delta")

			if getMultiMapValue(sessionInfo, "Damage", "Time.Repairs", false)
				state["RepairTime"] := getMultiMapValue(sessionInfo, "Damage", "Time.Repairs")
		}

		return ((state.Count > 0) ? state : kNull)
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

				hint := Map("Hint", hint)

				if message
					hint["Message"] := message

				hints.Push(hint)
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
			if ((key = "Session") && InStr(state, ";")) {
				state := string2Values(";", state)

				assistantsState["Mode"] := translate(state[1], this.Language)
				assistantsState["Session"] := translate(state[2], this.Language)
			}
			else if ((key = "Mode") || (key = "Session"))
				assistantsState[key] := translate(state, this.Language)
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

		if (assistantsState.Count > 0)
			sessionState["Assistants"] := assistantsState

		state := getMultiMapValue(controllerState, "Team Server", "State", "Disabled")

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

			sessionState["TeamServer"] := teamServerState
		}

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

				if automation
					automationState["Automation"] := automation
			}

			sessionState["Automation"] := automationState
		}
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

		if !needsUpdate {
			fileName := (kTempDirectory . "Simulator Controller.state")

			if (FileExist(fileName) && (FileGetTime(fileName, "M") > lastUpdate))
				needsUpdate := true
		}

		if needsUpdate {
			lastUpdate := A_Now
			sessionInfo := newMultiMap()

			for ignore, assistant in kRaceAssistants
				addMultiMapValues(sessionInfo, readMultiMap(kTempDirectory . assistant . " Session.state"))

			try {
				this.iProvider := SimulatorProvider.createSimulatorProvider(getMultiMapValue(sessionInfo, "Session", "Simulator")
																		  , getMultiMapValue(sessionInfo, "Session", "Car")
																		  , getMultiMapValue(sessionInfo, "Session", "Track"))
			}
			catch Any {
				this.iProvider := false
			}

			sessionState := Map("Session", this.createSessionState(sessionInfo)
							  , "Duration", this.createDurationState(sessionInfo)
							  , "Conditions", this.createConditionsState(sessionInfo)
							  , "Stint", this.createStintState(sessionInfo)
							  , "Fuel", this.createFuelState(sessionInfo)
							  , "Tyres", this.createTyresState(sessionInfo)
							  , "Brakes", this.createBrakesState(sessionInfo)
							  , "Engine", this.createEngineState(sessionInfo)
							  , "Strategy", this.createStrategyState(sessionInfo)
							  , "Damage", this.createDamageState(sessionInfo)
							  , "Pitstop", this.createPitstopState(sessionInfo)
							  , "Standings", this.createStandingsState(sessionInfo))

			do(getKeys(sessionState), (k) {
				try {
					if ((sessionState[k] == kNull) || (sessionState[k].Count = 0))
						sessionState.Delete(k)
				}
				catch Any as exception {
					logError(exception)
				}
			})

			if (this.DrivingCoach && (this.DrivingCoach.TrackCoachingActive || this.DrivingCoach.BrakeCoachingActive)) {
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

			FileAppend(JSON.print(sessionState, "  "), fileName)

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