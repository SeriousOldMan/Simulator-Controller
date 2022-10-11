;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Telemetry Database              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Math.ahk
#Include ..\Libraries\Database.ahk
#Include ..\Assistants\Libraries\SessionDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                    Public Variable Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

global kTelemetrySchemas := {Electronics: ["Weather", "Temperature.Air", "Temperature.Track", "Tyre.Compound", "Tyre.Compound.Color"
										 , "Fuel.Remaining", "Fuel.Consumption", "Lap.Time", "Map", "TC", "ABS", "Driver"
										 , "Identifier", "Synchronized"]
						   , Tyres: ["Weather", "Temperature.Air", "Temperature.Track", "Tyre.Compound", "Tyre.Compound.Color"
								   , "Fuel.Remaining", "Fuel.Consumption", "Lap.Time", "Tyre.Laps"
								   , "Tyre.Pressure.Front.Left", "Tyre.Pressure.Front.Right"
								   , "Tyre.Pressure.Rear.Left", "Tyre.Pressure.Rear.Right"
								   , "Tyre.Temperature.Front.Left", "Tyre.Temperature.Front.Right"
								   , "Tyre.Temperature.Rear.Left", "Tyre.Temperature.Rear.Right"
								   , "Tyre.Wear.Front.Left", "Tyre.Wear.Front.Right"
								   , "Tyre.Wear.Rear.Left", "Tyre.Wear.Rear.Right", "Driver"
								   , "Identifier", "Synchronized"]}


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class TelemetryDatabase extends SessionDatabase {
	iDatabase := false
	iDrivers := false
	iShared := true

	Database[] {
		Get {
			return this.iDatabase
		}
	}

	Drivers[] {
		Get {
			return this.iDrivers
		}
	}

	Shared[] {
		Get {
			return this.iShared
		}

		Set {
			return (this.iShared := value)
		}
	}

	__New(simulator := false, car := false, track := false, drivers := false) {
		local simulatorCode

		this.iDrivers := drivers

		base.__New()

		if (simulator && car && track) {
			if getConfigurationValue(this.ControllerConfiguration, "Simulators", simulator, false)
				simulatorCode := this.getSimulatorCode(simulator)
			else
				simulatorCode := simulator

			car := this.getCarCode(simulator, car)
			track := this.getCarCode(simulator, track)

			this.iDatabase := new Database(this.DatabasePath . "User\" . simulatorCode . "\" . car . "\" . track . "\", kTelemetrySchemas)
		}
	}

	setDatabase(database) {
		this.iDatabase := database
	}

	setDrivers(drivers) {
		this.iDrivers := drivers
	}

	getSchema(table, includeVirtualColumns := false) {
		local schema := kTelemetrySchemas[table].Clone()

		if (includeVirtualColumns && (table = "Tyres")) {
			schema.Push("Tyre.Pressure")
			schema.Push("Tyre.Pressure.Front")
			schema.Push("Tyre.Pressure.Rear")

			schema.Push("Tyre.Temperature")
			schema.Push("Tyre.Temperature.Front")
			schema.Push("Tyre.Temperature.Rear")

			schema.Push("Tyre.Wear")
			schema.Push("Tyre.Wear.Front")
			schema.Push("Tyre.Wear.Rear")
		}

		bubbleSort(schema)

		return schema
	}

	combineResults(table, query, drivers := "__Undefined__") {
		if (drivers = kUndefined)
			drivers := this.Drivers

		if this.Database {
			if (drivers == false)
				return this.Database.query(table, query)
			else {
				if (drivers == true)
					drivers := [this.ID]
				else if !IsObject(drivers)
					drivers := [drivers]

				return this.Database.combine(table, query, "Driver", drivers)
			}
		}
		else
			return []
	}

	getElectronicsCount(drivers := "__Undefined__") {
		local result := this.combineResults("Electronics", {Group: [["Lap.Time", "count", "Count"]]
														  , Transform: "removeInvalidLaps"
														  , Where: {}}, drivers)

		return ((result.Length() > 0) ? result[1].Count : 0)
	}

	getTyresCount(drivers := "__Undefined__") {
		local result := this.combineResults("Tyres", {Group: [["Lap.Time", "count", "Count"]]
													, Transform: "removeInvalidLaps"
													, Where: {}}, drivers)

		return ((result.Length() > 0) ? result[1].Count : 0)
	}

	getElectronicEntries(weather, compound, compoundColor, drivers := "__Undefined__") {
		return this.combineResults("Electronics", {Transform: "removeInvalidLaps"
												 , Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}}
												, drivers)
	}

	getTyreEntries(weather, compound, compoundColor, drivers := "__Undefined__") {
		return this.combineResults("Tyres", {Transform: compose("removeInvalidLaps", "computePressures", "computeTemperatures", "computeWear")
										   , Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}}
										  , drivers)
	}

	getMapsCount(weather, drivers := "__Undefined__") {
		return this.combineResults("Electronics", {Group: [["Map", "count", "Count"]], By: ["Map", "Tyre.Compound", "Tyre.Compound.Color"]
												 , Transform: "removeInvalidLaps"
												 , Where: {Weather: weather}},
												, drivers)
	}

	getMapData(weather, compound, compoundColor, drivers := "__Undefined__") {
		return this.combineResults("Electronics", {Group: [["Lap.Time", "average", "Lap.Time"], ["Fuel.Consumption", "average", "Fuel.Consumption"]]
												 , By: "Map", Transform: "removeInvalidLaps"
												 , Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}},
												, drivers)
	}

	getTyreData(weather, compound, compoundColor, drivers := "__Undefined__") {
		return this.combineResults("Tyres", {Group: [["Lap.Time", "minimum", "Lap.Time"]], By: "Tyre.Laps"
										   , Transform: "removeInvalidLaps"
										   , Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}},
										  , drivers)
	}

	getTyreCompoundColors(weather, compound, drivers := "__Undefined__") {
		return this.combineResults("Tyres", {Select: ["Tyre.Compound.Color"], By: "Tyre.Compound.Color"
										   , Transform: "removeInvalidLaps"
										   , Where: {Weather: weather, "Tyre.Compound": compound}},
										  , drivers)
	}

	getMapLapTimes(weather, compound, compoundColor, drivers := "__Undefined__") {
		return this.combineResults("Electronics", {Group: [["Lap.Time", "minimum", "Lap.Time"]], By: ["Map", "Fuel.Remaining"]
												 , Transform: "removeInvalidLaps"
												 , Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}},
												, drivers)
	}

	getTyreLapTimes(weather, compound, compoundColor, drivers := "__Undefined__") {
		return this.combineResults("Tyres", {Group: [["Lap.Time", "minimum", "Lap.Time"]], By: "Tyre.Laps"
										   , Transform: "removeInvalidLaps"
										   , Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}},
										  , drivers)
	}

	getFuelLapTimes(weather, compound, compoundColor, drivers := "__Undefined__") {
		return this.combineResults("Tyres", {Group: [["Lap.Time", "minimum", "Lap.Time"]], By: "Fuel.Remaining"
										   , Transform: "removeInvalidLaps"
										   , Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}},
										  , drivers)
	}

	getPressuresCount(weather, drivers := "__Undefined__") {
		return this.combineResults("Tyres", {Group: [["Tyre.Pressure", "count", "Count"]], By: ["Tyre.Pressure", "Tyre.Compound", "Tyre.Compound.Color"]
										   , Transform: compose("removeInvalidLaps", "computePressures")
										   , Where: {Weather: weather}},
										  , drivers)
	}

	getLapTimePressures(weather, compound, compoundColor, drivers := "__Undefined__") {
		return this.combineResults("Tyres", {Group: [["Tyre.Pressure.Front.Left", "average", "Tyre.Pressure.Front.Left"]
												   , ["Tyre.Pressure.Front.Right", "average", "Tyre.Pressure.Front.Right"]
												   , ["Tyre.Pressure.Rear.Left", "average", "Tyre.Pressure.Rear.Left"]
												   , ["Tyre.Pressure.Rear.Right", "average", "Tyre.Pressure.Rear.Right"]], By: "Lap.Time"
										   , Transform: compose("removeInvalidLaps", "computePressures")
										   , Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}},
										  , drivers)
	}

	cleanupData(weather, compound, compoundColor, drivers := "__Undefined__") {
		local database := this.Database
		local connector := this.Connector
		local where, ltAvg, ltStdDev, cAvg, cStdDev, rows, identifiers, filter, ignore, row

		if database {
			where := {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}

			ltAvg := false
			ltStdDev := false
			cAvg := false
			cStdDev := false

			if (!this.Shared || database.lock("Electronics"))
				try {
					if this.Shared
						database.reload("Electronics")

					rows := this.combineResults("Electronics", {Where: where}, drivers)

					computeFilterValues(rows, ltAvg, ltStdDev, cAvg, cStdDev)

					filter := Func("invalidLap").Bind(ltAvg, ltStdDev, cAvg, cStdDev, drivers)

					if connector {
						identifiers := []

						for ignore, row in rows
							if (%filter%(row) && (row.Identifier != kNull))
								identifiers.Push(row.Identifier)
					}
					else
						identifiers := false

					this.Database.remove("Electronics", where, filter, true)

					if identifiers
						connector.DeleteData("Electronics", values2String(";", identifiers*))
				}
				finally {
					if this.Shared
						database.unlock("Electronics")
				}

			ltAvg := false
			ltStdDev := false
			cAvg := false
			cStdDev := false

			if (!this.Shared || database.lock("Tyres"))
				try {
					if this.Shared
						database.reload("Tyres")

					rows := this.combineResults("Tyres", {Where: where}, drivers)

					computeFilterValues(rows, ltAvg, ltStdDev, cAvg, cStdDev)

					filter := Func("invalidLap").Bind(ltAvg, ltStdDev, cAvg, cStdDev, drivers)

					if connector {
						identifiers := []

						for ignore, row in rows
							if (%filter%(row) && (row.Identifier != kNull))
								identifiers.Push(row.Identifier)
					}
					else
						identifiers := false

					this.Database.remove("Tyres", where, filter, true)

					if identifiers
						connector.DeleteData("Tyres", values2String(";", identifiers*))
				}
				finally {
					if this.Shared
						database.unlock("Tyres")
				}

		}
	}

	addElectronicEntry(weather, airTemperature, trackTemperature, compound, compoundColor
					 , map, tc, abs, fuelConsumption, fuelRemaining, lapTime
					 , driver := false, identifier := false) {
		local database := this.Database

		if !driver
			driver := this.ID

		if (!this.Shared || database.lock("Electronics", false))
			try {
				database.add("Electronics", {Driver: driver, Weather: weather
										   , "Temperature.Air": airTemperature, "Temperature.Track": trackTemperature
										   , "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor
										   , "Fuel.Remaining": valueOrNull(fuelRemaining)
										   , "Fuel.Consumption": valueOrNull(fuelConsumption)
										   , "Lap.Time": valueOrNull(lapTime)
										   , Map: map, TC: tc, ABS: abs
										   , Identifier: identifier ? identifier : kNull}
										  , true)
			}
			finally {
				if this.Shared
					database.unlock("Electronics")
			}
	}

	addTyreEntry(weather, airTemperature, trackTemperature, compound, compoundColor, tyreLaps
			   , pressureFL, pressureFR, pressureRL, pressureRR, temperatureFL, temperatureFR, temperatureRL, temperatureRR
			   , wearFL, wearFR, wearRL, wearRR, fuelConsumption, fuelRemaining, lapTime
			   , driver := false, identifier := false) {
		local database := this.Database

		if !driver
			driver := this.ID

		if (!this.Shared || database.lock("Tyres", false))
			try {
				this.Database.add("Tyres", {Driver: driver, Weather: weather
										  , "Temperature.Air": valueOrNull(airTemperature)
										  , "Temperature.Track": valueOrNull(trackTemperature)
										  , "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor
										  , "Fuel.Remaining": valueOrNull(fuelRemaining)
										  , "Fuel.Consumption": valueOrNull(fuelConsumption)
										  , "Lap.Time": valueOrNull(lapTime), "Tyre.Laps": valueOrNull(tyreLaps)
										  , "Tyre.Pressure.Front.Left": valueOrNull(pressureFL)
										  , "Tyre.Pressure.Front.Right": valueOrNull(pressureFR)
										  , "Tyre.Pressure.Rear.Left": valueOrNull(pressureRL)
										  , "Tyre.Pressure.Rear.Right": valueOrNull(pressureRR)
										  , "Tyre.Temperature.Front.Left": valueOrNull(temperatureFL)
										  , "Tyre.Temperature.Front.Right": valueOrNull(temperatureFR)
										  , "Tyre.Temperature.Rear.Left": valueOrNull(temperatureRL)
										  , "Tyre.Temperature.Rear.Right": valueOrNull(temperatureRR)
										  , "Tyre.Wear.Front.Left": valueOrNull(wearFL)
										  , "Tyre.Wear.Front.Right": valueOrNull(wearFR)
										  , "Tyre.Wear.Rear.Left": valueOrNull(wearRL)
										  , "Tyre.Wear.Rear.Right": valueOrNull(wearRR)
										  , Identifier: identifier ? identifier : kNull}
										 , true)
			}
			finally {
				if this.Shared
					database.unlock("Tyres")
			}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

countValues(groupedColumn, countColumn, rows) {
	local values := {}
	local result := []
	local ignore, row, value, count, object

	for ignore, row in rows {
		value := row[groupedColumn]

		if values.HasKey(value)
			values[value] := values[value] + 1
		else
			values[value] := 1
	}

	for value, count in values {
		object := Object()

		object[groupedColumn] := value
		object[countColumn] := count

		result.Push(object)
	}

	return result
}

compose(functions*) {
	return Func("callFunctions").Bind(functions)
}

callFunctions(functions, rows) {
	local ignore, function

	for ignore, function in functions
		rows := %function%(rows)

	return rows
}

computePressures(rows) {
	local ignore, row

	for ignore, row in rows {
		row["Tyre.Pressure"] := Round(average([row["Tyre.Pressure.Front.Left"], row["Tyre.Pressure.Front.Right"]
											 , row["Tyre.Pressure.Rear.Left"], row["Tyre.Pressure.Rear.Right"]]), 1)
		row["Tyre.Pressure.Front"] := Round(average([row["Tyre.Pressure.Front.Left"], row["Tyre.Pressure.Front.Right"]]), 1)
		row["Tyre.Pressure.Rear"] := Round(average([row["Tyre.Pressure.Rear.Left"], row["Tyre.Pressure.Rear.Right"]]), 1)
	}

	return rows
}

computeTemperatures(rows) {
	local ignore, row

	for ignore, row in rows {
		row["Tyre.Temperature"] := Round(average([row["Tyre.Temperature.Front.Left"], row["Tyre.Temperature.Front.Right"]
												, row["Tyre.Temperature.Rear.Left"], row["Tyre.Temperature.Rear.Right"]]), 1)
		row["Tyre.Temperature.Front"] := Round(average([row["Tyre.Temperature.Front.Left"], row["Tyre.Temperature.Front.Right"]]), 1)
		row["Tyre.Temperature.Rear"] := Round(average([row["Tyre.Temperature.Rear.Left"], row["Tyre.Temperature.Rear.Right"]]), 1)
	}

	return rows
}

computeWear(rows) {
	local ignore, row

	for ignore, row in rows {
		row["Tyre.Wear"] := averageWear([row["Tyre.Wear.Front.Left"], row["Tyre.Wear.Front.Right"]
									   , row["Tyre.Wear.Rear.Left"], row["Tyre.Wear.Rear.Right"]])
		row["Tyre.Wear.Front"] := averageWear([row["Tyre.Wear.Front.Left"], row["Tyre.Wear.Front.Right"]])
		row["Tyre.Wear.Rear"] := averageWear([row["Tyre.Wear.Rear.Left"], row["Tyre.Wear.Rear.Right"]])
	}

	return rows
}

averageWear(wears) {
	local result := 0
	local ignore, wear

	for ignore, wear in wears
		if (wear = kNull)
			return kNull
		else
			result += wear

	return Round(result / wears.Length())
}

computeFilterValues(rows, ByRef lapTimeAverage, ByRef lapTimeStdDev, ByRef consumptionAverage, ByRef consumptionStdDev) {
	local lapTimes := []
	local consumption := []
	local ignore, row

	for ignore, row in rows {
		lapTimes.Push(row["Lap.Time"])
		consumption.Push(row["Fuel.Consumption"])
	}

	lapTimeAverage := average(lapTimes)
	lapTimeStdDev := stdDeviation(lapTimes)

	consumptionAverage := average(consumption)
	consumptionStdDev := stdDeviation(consumption)
}

validLap(ltAvg, ltStdDev, cAvg, cStdDev, row) {
	if ((row["Lap.Time"] > 0) && (row["Fuel.Consumption"] > 0))
		return ((Abs(row["Lap.Time"] - ltAvg) <= ltStdDev) && (Abs(row["Fuel.Consumption"] - cAvg) <= cStdDev))
	else
		return false
}

invalidLap(ltAvg, ltStdDev, cAvg, cStdDev, row, drivers := "__Undefined__") {
	if ((drivers = kUndefined)
	 || (IsObject(drivers) && inList(drivers, row.Driver))
	 || ((drivers == true) && (row.Driver = SessionDatabase.ID))
	 || (drivers = row.Driver))
		return !validLap(ltAvg, ltStdDev, cAvg, cStdDev, row)
	else
		return false
}

removeInvalidLaps(rows) {
	local ltAvg := false
	local ltStdDev := false
	local cAvg := false
	local cStdDev := false
	local count := rows.Length()
	local result := []
	local ignore, row

	computeFilterValues(rows, ltAvg, ltStdDev, cAvg, cStdDev)

	if (count < 5) {
		ltStdDev *= 2
		cStdDev *= 2
	}
	else if (count < 10) {
		ltStdDev *= 1.5
		cStdDev *= 1.5
	}
	else if (count < 20) {
		ltStdDev *= 1.2
		cStdDev *= 1.2
	}

	for ignore, row in rows
		if validLap(ltAvg, ltStdDev, cAvg, cStdDev, row)
			result.Push(row)

	return result
}

synchronizeTelemetry(sessionDB, connector, simulators, timestamp, lastSynchronization) {
	local ignore, simulator, car, track, db, modified, identifier, telemetry, properties

	try {
		for ignore, simulator in simulators {
			simulator := sessionDB.getSimulatorCode(simulator)

			for ignore, car in sessionDB.getCars(simulator)
				for ignore, track in sessionDB.getTracks(simulator, car) {
					db := new Database(kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track, kTelemetrySchemas)

					if db.lock("Electronics", false)
						try {
							modified := false

							for ignore, identifier in string2Values(";"
																  , connector.QueryData("Electronics", "Simulator = '" . simulator . "' And "
																									 . "Car = '" . car . "' And "
																									 . "Track = '" . track . "' And "
																									 . "Modified > " . lastSynchronization . " And "
																									 . "Driver <> '" . sessionDB.ID . "'")) {
								if (db.query("Electronics", {Where: {Identifier: identifier} }).Length() = 0) {
									modified := true

									telemetry := parseData(connector.GetData("Electronics", identifier))

									db.add("Electronics", {Identifier: identifier, Synchronized: timestamp
														 , Driver: driver, Weather: weather
														 , "Temperature.Air": telemetry.AirTemperature
														 , "Temperature.Track": telemetry.TrackTemperature
														 , "Tyre.Compound": telemetry.TyreCompound
														 , "Tyre.Compound.Color": telemetry.TyreCompoundColor
														 , "Fuel.Remaining": telemetry.FuelRemaining, "Fuel.Consumption": telemetry.FuelConsumption
														 , "Lap.Time": telemetry.LapTime, "Map": telemetry.Map, "TC": telemetry.TC, "ABS": telemetry.ABS})
								}
							}

							for ignore, telemetry in db.query("Electronics", {Where: {Synchronized: kNull, Driver: sessionDB.ID} }) {
								if (telemetry.Identifier = kNull)
									telemetry.Identifier := createGUID()

								telemetry.Synchronized := timestamp

								db.changed("Electronics")
								modified := true

								if (connector.CountData("Electronics", "Identifier = '" . telemetry.Identifier . "'") = 0)
									connector.CreateData("Electronics"
													   , substituteVariables("Identifier=%Identifier%`nDriver=%Driver%`n"
																		   . "Simulator=%Simulator%`nCar=%Car%`nTrack=%Track%`n"
																		   . "Weather=%Weather%`nAirTemperature=%AirTemperature%`n"
																		   . "TrackTemperature=%TrackTemperature%`n"
																		   . "TyreCompound=%TyreCompound%`nTyreCompoundColor=%TyreCompoundColor%`n"
																		   . "FuelRemaining=%FuelRemaining%`nFuelConsumption=%FuelConsumption%`n"
																		   . "LapTime=%LapTime%`nMap=%Map%`nTC=%TC%`nABS=%ABS%"
																		   , {Identifier: telemetry.Identifier, Driver: telemetry.Driver
																		    , Simulator: simulator, Car: car, Track: track
																			, Weather: telemetry.Weather
																			, AirTemperature: telemetry["Temperature.Air"]
																			, TrackTemperature: telemetry["Temperature.Track"]
																			, TyreCompound: telemetry["Tyre.Compound"]
																			, TyreCompoundColor: telemetry["Tyre.Compound.Color"]
																			, FuelConsumption: telemetry["Fuel.Consumption"]
																			, FuelRemaining: telemetry["Fuel.Remaining"]
																			, LapTime: telemetry["Lap.Time"], Map: telemetry.Map
																			, TC: telemetry.TC, ABS: telemetry.ABS}))
							}
						}
						finally {
							if modified
								db.flush("Electronics")

							db.unlock("Electronics")
						}

					if db.lock("Tyres", false)
						try {
							modified := false

							for ignore, identifier in string2Values(";"
																  , connector.QueryData("Tyres", "Simulator = '" . simulator . "' And "
																							   . "Car = '" . car . "' And "
																							   . "Track = '" . track . "' And "
																							   . "Modified > " . lastSynchronization . " And "
																							   . "Driver <> '" . sessionDB.ID . "'")) {
								if (db.query("Tyres", {Where: {Identifier: identifier} }).Length() = 0) {
									modified := true

									telemetry := parseData(connector.GetData("Tyres", identifier))

									db.add("Tyres", {Identifier: identifier, Synchronized: timestamp
														 , Driver: driver, Weather: weather
														 , "Temperature.Air": telemetry.AirTemperature
														 , "Temperature.Track": telemetry.TrackTemperature
														 , "Tyre.Compound": telemetry.TyreCompound
														 , "Tyre.Compound.Color": telemetry.TyreCompoundColor
														 , "Fuel.Remaining": telemetry.FuelRemaining, "Fuel.Consumption": telemetry.FuelConsumption
														 , "Lap.Time": telemetry.LapTime, "Tyre.Laps": telemetry.Laps
														 , "Tyre.Pressure.Front.Left": telemetry.PressureFrontLeft
														 , "Tyre.Pressure.Front.Right": telemetry.PressureFrontRight
														 , "Tyre.Pressure.Rear.Left": telemetry.PressureRearLeft
														 , "Tyre.Pressure.Rear.Right": telemetry.PressureRearRight
														 , "Tyre.Temperature.Front.Left": telemetry.TemperatureFrontLeft
														 , "Tyre.Temperature.Front.Right": telemetry.TemperatureFrontRight
														 , "Tyre.Temperature.Rear.Left": telemetry.TemperatureRearLeft
														 , "Tyre.Temperature.Rear.Right": telemetry.TemperatureRearRight
														 , "Tyre.Wear.Front.Left": telemetry.WearFrontLeft
														 , "Tyre.Wear.Front.Right": telemetry.WearFrontRight
														 , "Tyre.Wear.Rear.Left": telemetry.WearRearLeft
														 , "Tyre.Wear.Rear.Right": telemetry.WearRearRight})
								}
							}

							for ignore, telemetry in db.query("Tyres", {Where: {Synchronized: kNull, Driver: sessionDB.ID} }) {
								if (telemetry.Identifier = kNull)
									telemetry.Identifier := createGUID()

								telemetry.Synchronized := timestamp

								db.changed("Tyres")
								modified := true

								if (connector.CountData("Tyres", "Identifier = '" . telemetry.Identifier . "'") = 0)
									connector.CreateData("Tyres"
													   , substituteVariables("Identifier=%Identifier%`nDriver=%Driver%`n"
																		   . "Simulator=%Simulator%`nCar=%Car%`nTrack=%Track%`n"
																		   . "Weather=%Weather%`nAirTemperature=%AirTemperature%`n"
																		   . "TrackTemperature=%TrackTemperature%`n"
																		   . "TyreCompound=%TyreCompound%`nTyreCompoundColor=%TyreCompoundColor%`n"
																		   . "FuelRemaining=%FuelRemaining%`nFuelConsumption=%FuelConsumption%`n"
																		   . "LapTime=%LapTime%`nLaps=%Laps%`n"
																		   . "PressureFrontLeft=%PressureFrontLeft%`nPressureFrontRight=%PressureFrontRight%`n"
																		   . "PressureRearLeft=%PressureRearLeft%`nPressureRearRight=%PressureRearRight%`n"
																		   . "TemperatureFrontLeft=%TemperatureFrontLeft%`n
																		   . "TemperatureFrontRight=%TemperatureFrontRight%`n"
																		   . "TemperatureRearLeft=%TemperatureRearLeft%`n"
																		   . "TemperatureRearRight=%TemperatureRearRight%`n"
																		   . "WearFrontLeft=%WearFrontLeft%`nWearFrontRight=%WearFrontRight%`n"
																		   . "WearRearLeft=%WearRearLeft%`nWearRearRight=%WearRearRight%"
																		   , {Identifier: telemetry.Identifier, Driver: telemetry.Driver
																		    , Simulator: simulator, Car: car, Track: track
																			, Weather: telemetry.Weather
																			, AirTemperature: telemetry["Temperature.Air"]
																			, TrackTemperature: telemetry["Temperature.Track"]
																			, TyreCompound: telemetry["Tyre.Compound"]
																			, TyreCompoundColor: telemetry["Tyre.Compound.Color"]
																			, FuelConsumption: telemetry["Fuel.Consumption"]
																			, FuelRemaining: telemetry["Fuel.Remaining"]
																			, LapTime: telemetry["Lap.Time"], Laps: telemetry["Tyre.Laps"]
																			, PressureFrontLeft: telemetry["Tyre.Pressure.Front.Left"]
																			, PressureFrontRight: telemetry["Tyre.Pressure.Front.Right"]
																			, PressureRearLeft: telemetry["Tyre.Pressure.Rear.Left"]
																			, PressureRearRight: telemetry["Tyre.Pressure.Rear.Right"]
																			, TemperatureFrontLeft: telemetry["Tyre.Temperature.Front.Left"]
																			, TemperatureFrontRight: telemetry["Tyre.Temperature.Front.Right"]
																			, TemperatureRearLeft: telemetry["Tyre.Temperature.Rear.Left"]
																			, TemperatureRearRight: telemetry["Tyre.Temperature.Rear.Right"]
																			, WearFrontLeft: telemetry["Tyre.Wear.Front.Left"]
																			, WearFrontRight: telemetry["Tyre.Wear.Front.Right"]
																			, WearRearLeft: telemetry["Tyre.Wear.Rear.Left"]
																			, WearRearRight: telemetry["Tyre.Wear.Rear.Right"]}))
							}
						}
						finally {
							if modified
								db.flush("Tyres")

							db.unlock("Tyres")
						}
				}
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                           Initialization Section                        ;;;
;;;-------------------------------------------------------------------------;;;

SessionDatabase.registerSynchronizer("synchronizeTelemetry")