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
	updateLapStatistics(simulator, car, track, weather, airTemperature, trackTemperature, compound, compoundColor, map, tc, abs, fuelConsumption, laptime) {
		if getConfigurationValue(this.ControllerConfiguration, "Simulators", simulator, false)
			simulatorCode := this.getSimulatorCode(simulator)
		else
			simulatorCode := simulator
		
		simulator := this.getSimulatorName(simulatorCode)
		
		directory := (kDatabaseDirectory . "Local\" . simulatorCode . "\" .car . "\" . track)
		
		FileCreateDir %directory%
				
		line := (values2String(";", weather, airTemperature, trackTemperature, compound, compoundColor, map, tc, abs, fuelConsumption, laptime) . "`n")
		
		FileAppend %line%, % directory . "\LapStatistics.CSV"
	}
}
