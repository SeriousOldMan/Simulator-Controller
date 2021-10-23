;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Telemetry Database              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Database.ahk
#Include ..\Assistants\Libraries\SetupDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                   Private Variable Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

global kTelemetrySchemas = {Electronics: ["Weather", "Temperature.Air", "Temperature.Track", "Tyre.Compound", "Tyre.Compound.Color"
										, "Fuel.Remaining", "Fuel.Consumption", "Lap.Time", "Map", "TC", "ABS"]
						  , Tyres: ["Weather", "Temperature.Air", "Temperature.Track", "Tyre.Compound", "Tyre.Compound.Color"
								  , "Fuel.Remaining", "Fuel.Consumption", "Lap.Time", "Tyre.Laps"
								  , "Tyre.Pressure.Front.Left", "Tyre.Pressure.Front.Right"
								  , "Tyre.Pressure.Rear.Left", "Tyre.Pressure.Rear.Right"
								  , "Tyre.Temperature.Front.Left", "Tyre.Temperature.Front.Right"
								  , "Tyre.Temperature.Rear.Left", "Tyre.Temperature.Rear.Right"]}
								   

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class TelemetryDatabase extends SessionDatabase {
	iDatabase := false
	
	Database[] {
		Get {
			return this.iDatabase 
		}
	}
	
	__New(simulator := false, car := false, track := false) {
		base.__New()
		
		if (simulator && car && track) {
			if getConfigurationValue(this.ControllerConfiguration, "Simulators", simulator, false)
				simulatorCode := this.getSimulatorCode(simulator)
			else
				simulatorCode := simulator
			
			this.iDatabase := new Database(kDatabaseDirectory . "Local\" . simulatorCode . "\" . car . "\" . track . "\", kTelemetrySchemas)
		}
	}
	
	getSchema(table, includeVirtualColumns := false) {
		schema := kTelemetrySchemas[table].Clone()
		
		if (includeVirtualColumns && (table = "Tyres")) {
			schema.Push("Tyre.Pressure")
			schema.Push("Tyre.Pressure.Front")
			schema.Push("Tyre.Pressure.Rear")
			
			schema.Push("Tyre.Temperature")
			schema.Push("Tyre.Temperature.Front")
			schema.Push("Tyre.Temperature.Rear")
		}
		
		bubbleSort(schema)
		
		return schema
	}
	
	getElectronicEntries(weather, compound, compoundColor) {
		if this.Database
			return this.Database.query("Electronics", {Transform: "removeInvalidLaps"
													 , Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}})
		else
			return []
	}
	
	getTyreEntries(weather, compound, compoundColor) {
		if this.Database
			return this.Database.query("Tyres", {Transform: combine("removeInvalidLaps", "computePressures", "computeTemperatures")
											   , Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}})
		else
			return []
	}
	
	getMapsCount(weather, compound, compoundColor) {
		if this.Database
			return this.Database.query("Electronics", {Group: [["Map", "count", "Count"]], By: "Map"
													 , Transform: "removeInvalidLaps"
													 , Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}})
		else
			return []
	}
	
	getMapData(weather, compound, compoundColor) {
		if this.Database
			return this.Database.query("Electronics", {Group: [["Lap.Time", "average", "Lap.Time"], ["Fuel.Consumption", "average", "Fuel.Consumption"]]
													 , By: "Map"
													 , Transform: "removeInvalidLaps"
													 , Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}})
		else
			return []
	}
	
	getTyreData(weather, compound, compoundColor) {
		if this.Database
			return this.Database.query("Tyres", {Group: [["Lap.Time", "minimum", "Lap.Time"]], By: "Tyre.Laps"
											   , Transform: "removeInvalidLaps"
											   , Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}})
		else
			return []
	}
	
	getLapTimes(weather, compound, compoundColor) {
		if this.Database
			return this.Database.query("Electronics", {Group: [["Lap.Time", "minimum", "Lap.Time"]], By: ["Map", "Fuel.Remaining"]
													 , Transform: "removeInvalidLaps"
													 , Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}})
		else
			return []
	}
	
	getPressuresCount(weather, compound, compoundColor) {
		if this.Database {
			return this.Database.query("Tyres", {Group: [["Tyre.Pressure", "count", "Count"]], By: "Tyre.Pressure"
											   , Transform: combine("removeInvalidLaps", "computePressures")
											   , Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}})
		}
		else
			return []
	}
	
	getLapTimePressures(weather, compound, compoundColor) {
		if this.Database {
			return this.Database.query("Tyres", {Group: [["Tyre.Pressure.Front.Left", "average", "Tyre.Pressure.Front.Left"]
													   , ["Tyre.Pressure.Front.Right", "average", "Tyre.Pressure.Front.Right"]
													   , ["Tyre.Pressure.Rear.Left", "average", "Tyre.Pressure.Rear.Left"]
													   , ["Tyre.Pressure.Rear.Right", "average", "Tyre.Pressure.Rear.Right"]], By: "Lap.Time"
											   , Transform: combine("removeInvalidLaps", "computePressures")
											   , Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}})
		}
		else
			return []
	}
		
	addElectronicEntry(weather, airTemperature, trackTemperature, compound, compoundColor, map, tc, abs, fuelRemaining, fuelConsumption, lapTime) {
		this.Database.add("Electronics", {Weather: weather, "Temperature.Air": airTemperature, "Temperature.Track": trackTemperature
										, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor
										, "Fuel.Remaining": fuelRemaining, "Fuel.Consumption": fuelConsumption, "Lap.Time": lapTime
										, Map: map, TC: tc, ABS: abs}, true)
	}
	
	addTyreEntry(weather, airTemperature, trackTemperature, compound, compoundColor, tyreLaps
				, pressureFL, pressureFR, pressureRL, pressureRR, temperatureFL, temperatureFR, temperatureRL, temperatureRR
				, fuelRemaining, fuelConsumption, lapTime) {
		this.Database.add("Tyres", {Weather: weather, "Temperature.Air": airTemperature, "Temperature.Track": trackTemperature
								  , "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor
								  , "Fuel.Remaining": fuelRemaining, "Fuel.Consumption": fuelConsumption, "Lap.Time": lapTime, "Tyre.Laps": tyreLaps
								  , "Tyre.Pressure.Front.Left": pressureFL, "Tyre.Pressure.Front.Right": pressureFR
								  , "Tyre.Pressure.Rear.Left": pressureRL, "Tyre.Pressure.Rear.Right": pressureRR
								  , "Tyre.Temperature.Front.Left": temperatureFL, "Tyre.Temperature.Front.Right": temperatureFR
								  , "Tyre.Temperature.Rear.Left": temperatureRL, "Tyre.Temperature.Rear.Right": temperatureRR}, true)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

countValues(groupedColumn, countColumn, rows) {
	values := {}
	
	for ignore, row in rows {
		value := row[groupedColumn]
	
		if values.HasKey(value)
			values[value] := values[value] + 1
		else
			values[value] := 1
	}
	
	result := []
	
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
	local function
	
	for ignore, function in functions
		rows := %function%(rows)
	
	return rows
}

computePressures(rows) {
	for ignore, row in rows {
		row["Tyre.Pressure"] := Round(average([row["Tyre.Pressure.Front.Left"], row["Tyre.Pressure.Front.Right"]
											 , row["Tyre.Pressure.Rear.Left"], row["Tyre.Pressure.Rear.Right"]]), 1)
		row["Tyre.Pressure.Front"] := Round(average([row["Tyre.Pressure.Front.Left"], row["Tyre.Pressure.Front.Right"]]), 1)
		row["Tyre.Pressure.Rear"] := Round(average([row["Tyre.Pressure.Rear.Left"], row["Tyre.Pressure.Rear.Right"]]), 1)
	}
	
	return rows
}

computeTemperatures(rows) {
	for ignore, row in rows {
		row["Tyre.Temperature"] := Round(average([row["Tyre.Temperature.Front.Left"], row["Tyre.Temperature.Front.Right"]
												, row["Tyre.Temperature.Rear.Left"], row["Tyre.Temperature.Rear.Right"]]), 1)
		row["Tyre.Temperature.Front"] := Round(average([row["Tyre.Temperature.Front.Left"], row["Tyre.Temperature.Front.Right"]]), 1)
		row["Tyre.Temperature.Rear"] := Round(average([row["Tyre.Temperature.Rear.Left"], row["Tyre.Temperature.Rear.Right"]]), 1)
	}
	
	return rows
}

removeInvalidLaps(rows) {
	lapTimes := []
	consumption := []
	
	for ignore, row in rows {
		lapTimes.Push(row["Lap.Time"])
		consumption.Push(row["Fuel.Consumption"])
	}
	
	ltAvg := average(lapTimes)
	ltStdDev := stdDeviation(lapTimes)
	
	cAvg := average(consumption)
	cStdDev := stdDeviation(consumption)
	
	ltThreshold := (ltAvg + ltStdDev)
	
	result := []
	
	for ignore, row in rows
		if ((row["Lap.Time"] < ltThreshold) && (Abs(row["Fuel.Consumption"] - cAvg) <= cStdDev))
			result.Push(row)

	return result
}