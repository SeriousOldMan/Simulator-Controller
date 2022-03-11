;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Session Database                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kWeatherOptions = ["Dry", "Drizzle", "LightRain", "MediumRain", "HeavyRain", "Thunderstorm"]

global kTyreCompounds = ["Dry", "Intermediate", "Wet"]
global kTyreCompoundColors = ["Black", "Red", "Yellow", "White", "Green", "Blue", "Soft", "Medium", "Hard"]

global kQualifiedTyreCompounds = ["Wet", "Intermediate", "Dry", "Dry (Red)", "Dry (Yellow)", "Dry (White)", "Dry (Green)", "Dry (Blue)", "Dry (Soft)", "Dry (Medium)", "Dry (Hard)"]
global kQualifiedTyreCompoundColors = ["Black", "Black", "Black", "Red", "Yellow", "White", "Green", "Blue", "Soft", "Medium", "Hard"]


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class SessionDatabase {
	iControllerConfiguration := false
	
	iUseGlobalDatabase := false
		
	ControllerConfiguration[] {
		Get {
			return this.iControllerConfiguration
		}
	}
	
	UseGlobalDatabase[] {
		Get {
			return this.iUseGlobalDatabase
		}
	}
	
	__New(controllerConfiguration := false) {
		if !controllerConfiguration {
			controllerConfiguration := getControllerConfiguration()
		
			if !controllerConfiguration
				controllerConfiguration := {}
		}
		
		this.iControllerConfiguration := controllerConfiguration
	}
	
	setUseGlobalDatabase(useGlobalDatabase) {
		this.iUseGlobalDatabase := useGlobalDatabase
	}
		
	getEntries(filter := "*.*", option := "D") {
		result := []
		
		Loop Files, %kDatabaseDirectory%Local\%filter%, %option%
			result.Push(A_LoopFileName)
		
		if this.UseGlobalDatabase
			Loop Files, %kDatabaseDirectory%Global\%filter%, %option%
				if !inList(result, A_LoopFileName)
					result.Push(A_LoopFileName)
		
		return result
	}

	getSimulatorName(simulatorCode) {
		if (simulatorCode = "Unknown")
			return "Unknown"
		else if (this.ControllerConfiguration.Count() > 0) {
			for name, description in getConfigurationSectionValues(this.ControllerConfiguration, "Simulators", Object())
				if ((simulatorCode = name) || (simulatorCode = string2Values("|", description)[1]))
					return name
				
			return false
		}
		else {
			for name, code in {"Assetto Corsa": "AC", "Assetto Corsa Competizione": "ACC", "Automobilista 2": "AMS2"
							 , "iRacing": "IRC", "RaceRoom Racing Experience": "R3E", "rFactor 2": "RF2"}
				if ((simulatorCode = name) || (simulatorCode = code))
					return name
				
			return false
		}
	}

	getSimulatorCode(simulatorName) {
		if (simulatorName = "Unknown")
			return "Unknown"
		else {
			code := getConfigurationValue(this.ControllerConfiguration, "Simulators", simulatorName, false)
		
			if code
				return string2Values("|", code)[1]
			else {
				for name, description in getConfigurationSectionValues(this.ControllerConfiguration, "Simulators", Object())
					if (simulatorName = string2Values("|", description)[1])
						return simulatorName
				
				for name, code in {"Assetto Corsa": "AC", "Assetto Corsa Competizione": "ACC", "Automobilista 2": "AMS2"
								 , "iRacing": "IRC", "RaceRoom Racing Experience": "R3E", "rFactor 2": "RF2"}
					if ((simulatorName = name) || (simulatorName = code))
						return code
				
				return false
			}
		}
	}

	getSimulators() {
		simulators := []
		
		for simulator, ignore in getConfigurationSectionValues(this.ControllerConfiguration, "Simulators", Object())
			simulators.Push(simulator)
		
		if (simulators.Length() = 0)
			for name, code in {"Assetto Corsa": "AC", "Assetto Corsa Competizione": "ACC", "Automobilista 2": "AMS2"
							 , "iRacing": "IRC", "RaceRoom Racing Experience": "R3E", "rFactor 2": "RF2"}
				if FileExist(kDatabaseDirectory . "Local\" . code)
					simulators.Push(name)
				
		return simulators
	}

	getCars(simulator) {
		code := this.getSimulatorCode(simulator)
		
		if code {
			return this.getEntries(code . "\*.*")
		}
		else
			return []
	}

	getTracks(simulator, car) {
		code := this.getSimulatorCode(simulator)
		
		if code {
			return this.getEntries(code . "\" . car . "\*.*")
		}
		else
			return []
	}
	
	getCarName(simulator, car) {
		static carNames := false
		
		code := this.getSimulatorCode(simulator)
		
		if (code == "ACC") {
			if !carNames
				carNames := readConfiguration(kResourcesDirectory . "Simulator Data\ACC\Car Model.ini")
		
			return getConfigurationValue(carNames, "Car Model", car, car)
		}
		else
			return car
	}
}