;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Statistics Database             ;;;
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

global kStatisticsSchemas = {Electronics: ["Weather", "Temperature.Air", "Temperature.Track", "Tyre.Compound", "Tyre.Compound.Color"
										 , "Fuel.Remaining", "Fuel.Consumption", "Lap.Time", "Map", "TC", "ABS"]
						   , Tyres: ["Weather", "Temperature.Air", "Temperature.Track", "Tyre.Compound", "Tyre.Compound.Color"
								   , "Fuel.Remaining", "Fuel.Consumption", "Lap.Time", "Tyre.Laps"
								   , "Tyre.Pressure.FL", "Tyre.Pressure.FR", "Tyre.Pressure.RL", "Tyre.Pressure.RR"
								   , "Tyre.Temperature.FL", "Tyre.Temperature.FR", "Tyre.Temperature.RL", "Tyre.Temperature.RR"]}
								   

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class StatisticsDatabase extends SessionDatabase {
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
			
			this.iDatabase := new Database(kDatabaseDirectory . "Local\" . simulatorCode . "\" . car . "\" . track . "\", kStatisticsSchemas)
		}
	}
	
	getElectronicEntries(weather, compound, compoundColor) {
		return this.Database.query("Electronics", {Filter: "removeInvalidLaps", Where: Func("columnEqual").Bind({Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor})})
	}
	
	getTyreEntries(weather, compound, compoundColor) {
		return this.Database.query("Tyres", {Filter: "removeInvalidLaps", Where: Func("columnEqual").Bind({Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor})})
	}
	
	getMapsCount(weather, compound, compoundColor) {
		return this.Database.query("Electronics", {Select: ["Map"]
												 , GroupBy: ["Map"] , Group: Func("columnCount").Bind("Map"), flatten: true
												 , Filter: "removeInvalidLaps"
												 , Where: Func("columnEqual").Bind({Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor})})
	}
	
	getPressuresCount(weather, compound, compoundColor) {
		rows := this.Database.query("Tyres", {Where: Func("columnEqual").Bind({Weather: weather, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor})})
		
		for ignore, row in rows {
			row["Tyre.Pressure"] := Round(average([row["Tyre.Pressure.FL"], row["Tyre.Pressure.FR"], row["Tyre.Pressure.RL"], row["Tyre.Pressure.RR"]]), 1)
			row["Tyre.Temperature"] := Round(average([row["Tyre.Temperature.FL"], row["Tyre.Temperature.FR"], row["Tyre.Temperature.RL"], row["Tyre.Temperature.RR"]]), 1)
		}
		
		return columnCount("Tyre.Pressure", rows)
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
;;;                    Public Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

minimum(numbers) {
	min := 0
	
	for ignore, number in numbers
		min := (!min ? number : Min(min, number))

	return min
}

maximum(numbers) {
	max := 0
	
	for ignore, number in numbers
		max := (!max ? number : Max(max, number))

	return max
}

average(numbers) {
	avg := 0
	
	for ignore, value in numbers
		avg += value
	
	return (avg / numbers.Length())
}

stdDeviation(numbers) {
	avg := average(numbers)
	
	squareSum := 0
	
	for ignore, value in numbers
		squareSum += ((value - avg) * (value - avg))
	
	return Sqrt(squareSum)
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

columnEqual(constraints, row) {
	for column, value in constraints
		if (row[column] != value)
			return false
		
	return true
}

columnCount(column, rows) {
	values := {}
	
	for ignore, row in rows {
		value := row[column]
	
		if values.HasKey(value)
			values[value] := values[value] + 1
		else
			values[value] := 1
	}
	
	result := []
	
	for value, count in values {
		object := {Count: count}
		object[column] := value
		
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