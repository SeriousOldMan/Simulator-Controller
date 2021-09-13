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
	
	getElectronicsStatistics() {
		return this.Database.query("Electronics", {Select: ["Weather", "Compound", "CompoundColor"]
												 , GroupBy: ["Weather", "Compound", "CompoundColor"]})
	}
		
	updateElectronicsStatistics(weather, airTemperature, trackTemperature, compound, compoundColor, map, tc, abs, fuelRemaining, fuelConsumption, lapTime) {
		this.Database.add("Electronics", {Weather: weather, AirTemperature: airTemperature, TrackTemperature: trackTemperature
										, Compound: compound, CompoundColor: compoundColor
										, FuelRemaining: fuelRemaining, FuelConsumption: fuelConsumption, LapTime: lapTime
										, Map: map, TC: tc, ABS: abs}, true)
	}
	
	updateTyreStatistics(weather, airTemperature, trackTemperature, compound, compoundColor
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
