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

global kDryQualificationSetup = "DQ"
global kDryRaceSetup = "DR"
global kWetQualificationSetup = "WQ"
global kWetRaceSetup = "WR"

global kSetupTypes = [kDryQualificationSetup, kDryRaceSetup, kWetQualificationSetup, kWetRaceSetup]


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class SessionDatabase {
	iControllerConfiguration := false
	
	iUseCommunity := false
		
	ControllerConfiguration[] {
		Get {
			return this.iControllerConfiguration
		}
	}
	
	UseCommunity[] {
		Get {
			return this.iUseCommunity
		}
		
		Set {
			return (this.iUseCommunity := value)
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
	
	ensure(simulator, car, track) {
		if (simulator && car && track) {
			simulatorCode := this.getSimulatorCode(simulator)

			fileName = %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%
		}
	}
		
	getEntries(filter := "*.*", option := "D") {
		result := []
		
		Loop Files, %kDatabaseDirectory%User\%filter%, %option%
			result.Push(A_LoopFileName)
		
		if this.UseCommunity
			Loop Files, %kDatabaseDirectory%Community\%filter%, %option%
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
				if FileExist(kDatabaseDirectory . "User\" . code)
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
	
	readNotes(simulator, car, track) {
		simulatorCode := this.getSimulatorCode(simulator)
		
		try {
			if (track && (track != true))
				FileRead notes, %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Notes.txt
			else if (car && (car != true))
				FileRead notes, %kDatabaseDirectory%User\%simulatorCode%\%car%\Notes.txt
			else
				FileRead notes, %kDatabaseDirectory%User\%simulatorCode%\Notes.txt
			
			return notes
		}
		catch exception {
			return ""
		}
	}
	
	writeNotes(simulator, car, track, notes) {
		simulatorCode := this.getSimulatorCode(simulator)
		
		try {
			if (car && (car != true)) {
				if (track && (track != true))
					FileDelete %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Notes.txt
				else 
					FileDelete %kDatabaseDirectory%User\%simulatorCode%\%car%\Notes.txt
			}
			else
				FileDelete %kDatabaseDirectory%User\%simulatorCode%\Notes.txt
		}
		catch exception {
			; ignore
		}
		
		if (car && (car != true)) {
			if (track && (track != true)) {
				FileCreateDir %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%
		
				FileAppend %notes%, %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Notes.txt, UTF-16
			}
			else {
				FileCreateDir %kDatabaseDirectory%User\%simulatorCode%\%car%
		
				FileAppend %notes%, %kDatabaseDirectory%User\%simulatorCode%\%car%\Notes.txt, UTF-16
			}
		}
		else {
			FileCreateDir %kDatabaseDirectory%User\%simulatorCode%
		
			FileAppend %notes%, %kDatabaseDirectory%User\%simulatorCode%\Notes.txt, UTF-16
		}
	}
	
	getSetupNames(simulator, car, track, ByRef userSetups, ByRef communitySetups) {
		simulatorCode := this.getSimulatorCode(simulator)
		
		if userSetups {
			userSetups := {}
			
			for ignore, type in kSetupTypes {
				setups := []
				
				Loop Files, %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Car Setups\%type%\*.*
				{
					SplitPath A_LoopFileName, name
				
					setups.Push(name)
				}
				
				userSetups[type] := setups
			}
		}
		
		if communitySetups {
			communitySetups := {}
		
			for ignore, type in kSetupTypes {
				setups := []
				
				Loop Files, %kDatabaseDirectory%Community\%simulatorCode%\%car%\%track%\Car Setups\%type%\*.*
				{
					SplitPath A_LoopFileName, name
				
					setups.Push(name)
				}
				
				communitySetups[type] := setups
			}
		}
	}
	
	readSetup(simulator, car, track, type, name, ByRef size) {
		simulatorCode := this.getSimulatorCode(simulator)
		
		data := false
		fileName = %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Car Setups\%type%\%name%
		
		file := FileOpen(fileName, "r")
		size := file.Length
		
		file.RawRead(data, size)
	
		file.Close()
		
		return data
	}
	
	writeSetup(simulator, car, track, type, name, setup, size) {
		simulatorCode := this.getSimulatorCode(simulator)
		
		try {
			FileDelete %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Car Setups\%type%\%name%
		}
		catch exception {
			; ignore
		}

		fileName = %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Car Setups\%type%
		
		FileCreateDir %fileName%
		
		fileName := (fileName . "\" . name)
		
		file := FileOpen(fileName, "w", "")
		
		file.RawWrite(setup, size)
	
		file.Close()
	}
	
	removeSetup(simulator, car, track, type, name) {
		simulatorCode := this.getSimulatorCode(simulator)
		
		try {
			FileDelete %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Car Setups\%type%\%name%
		}
		catch exception {
			; ignore
		}
	}
}