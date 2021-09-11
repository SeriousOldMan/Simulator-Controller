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

#Include ..\Assistants\Libraries\SetupDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class StatisticsDatabase extends Database {
	updateElectronicsStatistics(simulator, car, track, weather, airTemperature, trackTemperature, compound, compoundColor, map, tc, abs, fuelConsumption, lapTime) {
		if getConfigurationValue(this.ControllerConfiguration, "Simulators", simulator, false)
			simulatorCode := this.getSimulatorCode(simulator)
		else
			simulatorCode := simulator
		
		simulator := this.getSimulatorName(simulatorCode)
		
		directory := (kDatabaseDirectory . "Local\" . simulatorCode . "\" .car . "\" . track)
		
		FileCreateDir %directory%
				
		line := (values2String(";", weather, airTemperature, trackTemperature, compound, compoundColor, map, tc, abs, fuelConsumption, lapTime) . "`n")
		
		FileAppend %line%, % directory . "\ElectronicsData.CSV"
	}
	
	updateTyreStatistics(simulator, car, track, weather, airTemperature, trackTemperature, compound, compoundColor
					   , flPressure, frPressure, rlPressure, rrPressure, flTemperature, frTemperature, rlTemperature, rrTemperature, lapTime) {
		if getConfigurationValue(this.ControllerConfiguration, "Simulators", simulator, false)
			simulatorCode := this.getSimulatorCode(simulator)
		else
			simulatorCode := simulator
		
		simulator := this.getSimulatorName(simulatorCode)
		
		directory := (kDatabaseDirectory . "Local\" . simulatorCode . "\" .car . "\" . track)
		
		FileCreateDir %directory%
				
		line := (values2String(";", weather, airTemperature, trackTemperature, compound, compoundColor
								  , flPressure, frPressure, rlPressure, rrPressure, flTemperature, frTemperature, rlTemperature, rrTemperature, laptime) . "`n")
		
		FileAppend %line%, % directory . "\TyreData.CSV"
	}
}
