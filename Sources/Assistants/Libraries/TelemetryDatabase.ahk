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
										, "Fuel.Remaining", "Fuel.Consumption", "Lap.Time", "Map", "TC", "ABS", "Driver"]
						   , Tyres: ["Weather", "Temperature.Air", "Temperature.Track", "Tyre.Compound", "Tyre.Compound.Color"
								   , "Fuel.Remaining", "Fuel.Consumption", "Lap.Time", "Tyre.Laps"
								   , "Tyre.Pressure.Front.Left", "Tyre.Pressure.Front.Right"
								   , "Tyre.Pressure.Rear.Left", "Tyre.Pressure.Rear.Right"
								   , "Tyre.Temperature.Front.Left", "Tyre.Temperature.Front.Right"
								   , "Tyre.Temperature.Rear.Left", "Tyre.Temperature.Rear.Right"
								   , "Tyre.Wear.Front.Left", "Tyre.Wear.Front.Right"
								   , "Tyre.Wear.Rear.Left", "Tyre.Wear.Rear.Right", "Driver"]}


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class TelemetryDatabase extends SessionDatabase {
	iDatabase := false
	iDrivers := false

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

			this.iDatabase := new Database(kDatabaseDirectory . "User\" . simulatorCode . "\" . car . "\" . track . "\", kTelemetrySchemas)
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
		return this.combineResults("Tyres", {Transform: combine("removeInvalidLaps", "computePressures", "computeTemperatures", "computeWear")
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
										   , Transform: combine("removeInvalidLaps", "computePressures")
										   , Where: {Weather: weather}},
										  , drivers)
	}

	getLapTimePressures(weather, compound, compoundColor, drivers := "__Undefined__") {
		return this.combineResults("Tyres", {Group: [["Tyre.Pressure.Front.Left", "average", "Tyre.Pressure.Front.Left"]
												   , ["Tyre.Pressure.Front.Right", "average", "Tyre.Pressure.Front.Right"]
												   , ["Tyre.Pressure.Rear.Left", "average", "Tyre.Pressure.Rear.Left"]
												   , ["Tyre.Pressure.Rear.Right", "average", "Tyre.Pressure.Rear.Right"]], By: "Lap.Time"
										   , Transform: combine("removeInvalidLaps", "computePressures")
										   , Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}},
										  , drivers)
	}

	cleanupData(weather, compound, compoundColor, drivers := "__Undefined__") {
		local where, ltAvg, ltStdDev, cAvg, cStdDev, rows

		if this.Database {
			where := {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}

			ltAvg := false
			ltStdDev := false
			cAvg := false
			cStdDev := false

			rows := this.combineResults("Electronics", {Where: where}, drivers)

			computeFilterValues(rows, ltAvg, ltStdDev, cAvg, cStdDev)

			this.Database.remove("Electronics", where, Func("invalidLap").Bind(ltAvg, ltStdDev, cAvg, cStdDev, drivers), true)

			rows := this.combineResults("Tyres", {Where: where}, drivers)

			computeFilterValues(rows, ltAvg, ltStdDev, cAvg, cStdDev)

			this.Database.remove("Tyres", where, Func("invalidLap").Bind(ltAvg, ltStdDev, cAvg, cStdDev, drivers), true)
		}
	}

	addElectronicEntry(weather, airTemperature, trackTemperature, compound, compoundColor
					 , map, tc, abs, fuelConsumption, fuelRemaining, lapTime, driver := false) {
		if !driver
			driver := this.ID

		this.Database.add("Electronics", {Driver: driver, Weather: weather, "Temperature.Air": airTemperature, "Temperature.Track": trackTemperature
										, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor
										, "Fuel.Remaining": valueOrNull(fuelRemaining)
										, "Fuel.Consumption": valueOrNull(fuelConsumption)
										, "Lap.Time": valueOrNull(lapTime)
										, Map: map, TC: tc, ABS: abs}, true)
	}

	addTyreEntry(weather, airTemperature, trackTemperature, compound, compoundColor, tyreLaps
			   , pressureFL, pressureFR, pressureRL, pressureRR, temperatureFL, temperatureFR, temperatureRL, temperatureRR
			   , wearFL, wearFR, wearRL, wearRR, fuelConsumption, fuelRemaining, lapTime, driver := false) {
		if !driver
			driver := this.ID

		this.Database.add("Tyres", {Driver: driver, Weather: weather
								  , "Temperature.Air": valueOrNull(airTemperature), "Temperature.Track": valueOrNull(trackTemperature)
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
								  , "Tyre.Wear.Rear.Right": valueOrNull(wearRR)}
								  , true)
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

combine(functions*) {
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
	return ((Abs(row["Lap.Time"] - ltAvg) <= ltStdDev) && (Abs(row["Fuel.Consumption"] - cAvg) <= cStdDev))
}

invalidLap(ltAvg, ltStdDev, cAvg, cStdDev, row, drivers := "__Undefined__") {
	if ((drivers = kUndefined)
	 || (IsObject(drivers) && inList(drivers, row.Driver))
	 || ((drivers == true) && (row.Driver = this.ID))
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