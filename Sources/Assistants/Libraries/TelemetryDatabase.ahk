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
								  , "Tyre.Pressure.FL", "Tyre.Pressure.FR", "Tyre.Pressure.RL", "Tyre.Pressure.RR"
								  , "Tyre.Temperature.FL", "Tyre.Temperature.FR", "Tyre.Temperature.RL", "Tyre.Temperature.RR"]}
								   

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
	
	getElectronicEntries(weather, compound, compoundColor) {
		if this.Database
			return this.Database.query("Electronics", {Filter: "removeInvalidLaps", Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}})
		else
			return []
	}
	
	getTyreEntries(weather, compound, compoundColor) {
		if this.Database
			return this.Database.query("Tyres", {Filter: "removeInvalidLaps", Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}})
		else
			return []
	}
	
	getMapsCount(weather, compound, compoundColor) {
		if this.Database
			return this.Database.query("Electronics", {Group: [["Map", "count", "Count"]], By: "Map"
													 , Filter: "removeInvalidLaps"
													 , Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}})
		else
			return []
	}
	
	getMapLapTimes(weather, compound, compoundColor) {
		if this.Database
			return this.Database.query("Electronics", {Group: [["Map", "average", "Lap.Time"]], By: "Map"
													 , Filter: "removeInvalidLaps"
													 , Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}})
		else
			return []
	}
	
	getTyreLapsLapTimes(weather, compound, compoundColor) {
		if this.Database
			return this.Database.query("Tyres", {Group: [["Lap.Time", "minimum", "Lap.Time"]], By: "Tyre.Laps"
											   , Filter: "removeInvalidLaps"
											   , Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}})
		else
			return []
	}
	
	getPressuresCount(weather, compound, compoundColor) {
		if this.Database {
			rows := this.Database.query("Tyres", {Where: {Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}})
			
			for ignore, row in rows {
				row["Tyre.Pressure"] := Round(average([row["Tyre.Pressure.FL"], row["Tyre.Pressure.FR"], row["Tyre.Pressure.RL"], row["Tyre.Pressure.RR"]]), 1)
				row["Tyre.Temperature"] := Round(average([row["Tyre.Temperature.FL"], row["Tyre.Temperature.FR"], row["Tyre.Temperature.RL"], row["Tyre.Temperature.RR"]]), 1)
			}
			
			return countValues("Tyre.Pressure", "Count", rows)
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
								  , "Tyre.Pressure.FL": pressureFL, "Tyre.Pressure.FR": pressureFR, "Tyre.Pressure.RL": pressureRL, "Tyre.Pressure.RR": pressureRR
								  , "Tyre.Temperature.FL": temperatureFL, "Tyre.Temperature.FR": temperatureFR
								  , "Tyre.Temperature.RL": temperatureRL, "Tyre.Temperature.RR": temperatureRR}, true)
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

removeInvalidLaps(rows) {
	lapTimes := []
	
	for ignore, row in rows
		lapTimes.Push(row["Lap.Time"])
	
	avg := average(lapTimes)
	stdDeviation := stdDeviation(lapTimes)
	
	threshold := (avg + (stdDeviation / 2))
	
	result := []
	
	for ignore, row in rows
		if (row["Lap.Time"] < threshold)
			result.Push(row)

	return result
}