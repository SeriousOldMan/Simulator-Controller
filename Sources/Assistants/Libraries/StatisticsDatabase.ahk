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

global kStatisticsSchemas = {Electronics: ["Weather", "AirTemperature", "TrackTemperature", "Compound", "CompoundColor"
										 , "FuelRemaining", "FuelConsumption", "LapTime", "Map", "TC", "ABS"]
						   , Tyres: ["Weather", "AirTemperature", "TrackTemperature", "Compound", "CompoundColor"
								   , "FuelRemaining", "FuelConsumption", "LapTime"
								   , "PressureFL", "PressureFR", "PressureRL", "PressureRR"
								   , "TemperatureFL", "TemperatureFR", "TemperatureRL", "TemperatureRR"]}


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
	
	queryElectronics(weather, compound, compoundColor) {
		return this.Database.query("Electronics", {GroupBy: ["Map", "TC", "ABS"]
												 , Combine: "removeInvalidLaps"
												 , Filter: Func("filterEqual").Bind({Weather: weather, Compound: compound, CompoundColor: compoundColor})})
	}
	
	queryTyres(weather, compound, compoundColor) {
		rows := this.Database.query("Tyres", {Filter: Func("filterEqual").Bind({Weather: weather, Compound: compound, CompoundColor: compoundColor})})
		
		for ignore, row in rows {
			row["Pressure"] := average([row["PressureFL"], row["PressureFR"], row["PressureRL"], row["PressureRR"]])
			row["Temperature"] := average([row["TemperatureFL"], row["TemperatureFR"], row["TemperatureRL"], row["TemperatureRR"]])
		}
		
		return removeInvalidLaps(rows)
	}
		
	addElectronicsEntry(weather, airTemperature, trackTemperature, compound, compoundColor, map, tc, abs, fuelRemaining, fuelConsumption, lapTime) {
		this.Database.add("Electronics", {Weather: weather, AirTemperature: airTemperature, TrackTemperature: trackTemperature
										, Compound: compound, CompoundColor: compoundColor
										, FuelRemaining: fuelRemaining, FuelConsumption: fuelConsumption, LapTime: lapTime
										, Map: map, TC: tc, ABS: abs}, true)
	}
	
	addTyresEntry(weather, airTemperature, trackTemperature, compound, compoundColor
				, pressureFL, pressureFR, pressureRL, pressureRR, temperatureFL, temperatureFR, temperatureRL, temperatureRR
				, fuelRemaining, fuelConsumption, lapTime) {
		this.Database.add("Tyres", {Weather: weather, AirTemperature: airTemperature, TrackTemperature: trackTemperature
								  , Compound: compound, CompoundColor: compoundColor
								  , FuelRemaining: fuelRemaining, FuelConsumption: fuelConsumption, LapTime: lapTime
								  , PressureFL: pressureFL, PressureFR: pressureFR, PressureRL: pressureRL, PressureRR: pressureRR
								  , TemperatureFL: temperatureFL, TemperatureFR: temperatureFR
								  , TemperatureRL: temperatureRL, TemperatureRR: temperatureRR}, true)
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

filterEqual(constraints, row) {
	for column, value in constraints
		if (row[column] != value)
			return false
		
	return true
}

removeInvalidLaps(rows) {
	lapTimes := []
	
	for ignore, row in rows
		lapTimes.Push(row["LapTime"])
	
	avg := average(lapTimes)
	stdDeviation := stdDeviation(lapTimes)
	
	threshold := (avg + (stdDeviation / 2))
	
	result := []
	
	for ignore, row in rows
		if (row["LapTime"] < threshold)
			result.Push(row)

	return result
}
