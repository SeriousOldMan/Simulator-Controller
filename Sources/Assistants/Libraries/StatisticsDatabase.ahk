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

class LapData {
	iWeather := false
	iAirTemperature := false
	iTrackTemperature := false
	iCompound := false
	iCompoundColor := false
	
	iFuelRemaining := false
	iFuelConsumption := false
	iLapTime := false
	
	Weather[] {
		Get {
			return this.iWeather
		}
	}
	
	AirTemperature[] {
		Get {
			return this.iAirTemperature
		}
	}
	
	TrackTemperature[] {
		Get {
			return this.iTrackTemperature
		}
	}
	
	Compound[] {
		Get {
			return this.iCompound
		}
	}
	
	CompoundColor[] {
		Get {
			return this.iCompoundColor
		}
	}
	
	FuelRemaining[] {
		Get {
			return this.iFuelRemaining
		}
	}
	
	FuelConsumption[] {
		Get {
			return this.iFuelConsumption
		}
	}
	
	LapTime[] {
		Get {
			return this.iLapTime
		}
	}
	
	__New(weather, airTemperature, trackTemperature, compound, compoundColor, fuelRemaining, fuelConsumption, lapTime) {
		this.iWeather := weather
		this.iAirTemperature := airTemperature
		this.iTrackTemperature := trackTemperature
		this.iCompound := compound
		this.iCompoundColor := compoundColor
		this.iFuelRemaining := fuelRemaining
		this.iFuelConsumption := fuelConsumption
		this.iLapTime := lapTime
	}
}

class ElectronicsLapData extends LapData {
	iMap := "n/a"
	iTC := "n/a"
	iABS := "n/a"
	
	Map[] {
		Get {
			return this.iMap
		}
	}
	
	TC[] {
		Get {
			return this.iTC
		}
	}
	
	ABS[] {
		Get {
			return this.iABS
		}
	}
	
	__New(weather, airTemperature, trackTemperature, compound, compoundColor, fuelRemaining, fuelConsumption, lapTime, map, tc, abs) {
		this.iMap := map
		this.iTC := tc
		this.iABS := abs
		
		base.__New(weather, airTemperature, trackTemperature, compound, compoundColor, fuelRemaining, fuelConsumption, lapTime)
	}
}

class TyresLapData extends LapData {
	iFLPressure := false
	iFRPressure := false
	iRLPressure := false
	iRRPressure := false
	
	iFLTemperature := false
	iFRTemperature := false
	iRLTemperature := false
	iRRTemperature := false
	
	PressureFL[] {
		Get {
			return this.iFLPressure
		}
	}
	
	PressureFR[] {
		Get {
			return this.iFRPressure
		}
	}
	
	PressureRL[] {
		Get {
			return this.iRLPressure
		}
	}
	
	PressureRR[] {
		Get {
			return this.iRRPressure
		}
	}
	
	TemperatureFL[] {
		Get {
			return this.iFLTemperature
		}
	}
	
	TemperatureFR[] {
		Get {
			return this.iFRTemperature
		}
	}
	
	TemperatureRL[] {
		Get {
			return this.iRLTemperature
		}
	}
	
	TemperatureRR[] {
		Get {
			return this.iRRTemperature
		}
	}
	
	__New(weather, airTemperature, trackTemperature, compound, compoundColor, fuelRemaining, fuelConsumption, lapTime
		, flPressure, frPressure, rlPressure, rrPressure, flTemperature, frTemperature, rlTemperature, rrTemperature) {
		this.iFLPressure := flPressure
		this.iFRPressure := frPressure
		this.iRLPressure := rlPressure
		this.iRRPressure := rrPressure
		
		this.iFLTemperature := flTemperature
		this.iFRTemperature := frTemperature
		this.iRLTemperature := rlTemperature
		this.iRRTemperature := rrTemperature
		
		base.__New(weather, airTemperature, trackTemperature, compound, compoundColor, fuelRemaining, fuelConsumption, lapTime)
	}
}

class StatisticsDatabase extends Database {
	getLapData(simulator, car, track, type, groupBy) {
		local lapData
		
		if getConfigurationValue(this.ControllerConfiguration, "Simulators", simulator, false)
			simulatorCode := this.getSimulatorCode(simulator)
		else
			simulatorCode := simulator
		
		simulator := this.getSimulatorName(simulatorCode)
		
		fileName := (kDatabaseDirectory . "Local\" . simulatorCode . "\" . car . "\" . track)
		
		laps := []
		
		if (type = "Electronics")
			Loop Read, % kDatabaseDirectory . "Local\" . simulatorCode . "\" . car . "\" . track . "\ElectronicsData.CSV"
				laps.Push(new ElectronicsLapData(string2Values(";", A_LoopReadLine)*))
		else
			Loop Read, % kDatabaseDirectory . "Local\" . simulatorCode . "\" . car . "\" . track . "\TyressData.CSV"
				laps.Push(new TyresLapData(string2Values(";", A_LoopReadLine)*))
		
		groupedLaps := {}
			
		if (groupBy.Length() > 0) {
			while (laps.Length() > 0) {
				candidate := laps.Pop()
			
				key := []
				
				for ignore, field in groupBy
					key.Push(candidate[field])
				
				key := values2String("|", key*)
				
				if !groupedLaps.HasKey(key)
					groupedLaps[key] := []
				
				groupedLaps[key].Push(candidate)
			}
		}
		else
			groupedLaps["All"] := laps
		
		result := []
		
		for ignore, lapData in groupedLaps
			result.Push(lapData)
		
		return result
	}
		
	updateElectronicsStatistics(simulator, car, track, weather, airTemperature, trackTemperature, compound, compoundColor, map, tc, abs, fuelRemaining, fuelConsumption, lapTime) {
		if getConfigurationValue(this.ControllerConfiguration, "Simulators", simulator, false)
			simulatorCode := this.getSimulatorCode(simulator)
		else
			simulatorCode := simulator
		
		simulator := this.getSimulatorName(simulatorCode)
		
		directory := (kDatabaseDirectory . "Local\" . simulatorCode . "\" . car . "\" . track)
		
		FileCreateDir %directory%
				
		line := (values2String(";", weather, airTemperature, trackTemperature, compound, compoundColor, fuelRemaining, fuelConsumption, lapTime
								  , map, tc, abs) . "`n")
		
		FileAppend %line%, % directory . "\ElectronicsData.CSV"
	}
	
	updateTyreStatistics(simulator, car, track, weather, airTemperature, trackTemperature, compound, compoundColor
					   , flPressure, frPressure, rlPressure, rrPressure, flTemperature, frTemperature, rlTemperature, rrTemperature
					   , fuelRemaining, fuelConsumption, lapTime) {
		if getConfigurationValue(this.ControllerConfiguration, "Simulators", simulator, false)
			simulatorCode := this.getSimulatorCode(simulator)
		else
			simulatorCode := simulator
		
		simulator := this.getSimulatorName(simulatorCode)
		
		directory := (kDatabaseDirectory . "Local\" . simulatorCode . "\" . car . "\" . track)
		
		FileCreateDir %directory%
				
		line := (values2String(";", weather, airTemperature, trackTemperature, compound, compoundColor, fuelRemaining, fuelConsumption, lapTime
								  , flPressure, frPressure, rlPressure, rrPressure, flTemperature, frTemperature, rlTemperature, rrTemperature) . "`n")
		
		FileAppend %line%, % directory . "\TyresData.CSV"
	}
}
