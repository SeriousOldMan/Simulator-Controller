;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Setup Database                  ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kWeatherOptions = ["Dry", "Drizzle", "LightRain", "MediumRain", "HeavyRain", "Thunderstorm"]

global kTyreCompounds = ["Dry", "Wet"]
global kTyreCompoundColors = ["Red", "White", "Blue", "Black"]

global kQualifiedTyreCompounds = ["Wet", "Dry", "Dry (Red)", "Dry (White)", "Dry (Blue)"]

global kDryQualificationSetup = "DQ"
global kDryRaceSetup = "DR"
global kWetQualificationSetup = "WQ"
global kWetRaceSetup = "WR"

global kSetupTypes = [kDryQualificationSetup, kDryRaceSetup, kWetQualificationSetup, kWetRaceSetup]


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kTemperatureDeltas = [0, 1, -1, 2, -2]
global kMaxTemperatureDelta = 4


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
		this.iControllerConfiguration := (controllerConfiguration ? controllerConfiguration : getControllerConfiguration())
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
		else {
			for name, description in getConfigurationSectionValues(this.ControllerConfiguration, "Simulators", Object())
				if ((simulatorCode = name) || (simulatorCode = string2Values("|", description)[1]))
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
				
				return false
			}
		}
	}

	getSimulators() {
		simulators := []
		
		for simulator, ignore in getConfigurationSectionValues(this.ControllerConfiguration, "Simulators", Object())
			simulators.Push(simulator)
				
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
}

class SetupDatabase extends SessionDatabase {
	iLastSimulator := false
	iLastCar := false
	iLastTrack := false
	iLastCompound := false
	iLastCompoundColor := false
	iLastWeather := false
	
	iDatabase := false
	iDatabaseName := false

	getPressureDistributions(fileName, airTemperature, trackTemperature, ByRef distributions) {
		tyreSetup := getConfigurationValue(readConfiguration(fileName), "Pressures", ConfigurationItem.descriptor(airTemperature, trackTemperature), false)
		
		if tyreSetup {
			tyreSetup := string2Values(";", tyreSetup)
			
			for index, key in ["FL", "FR", "RL", "RR"]
				for ignore, pressure in string2Values(",", tyreSetup[index]) {
					pressure := string2Values(":", pressure)
				
					if distributions[key].HasKey(pressure[1])
						distributions[key][pressure[1]] := distributions[key][pressure[1]] + pressure[2]
					else
						distributions[key][pressure[1]] := pressure[2]
				}
		}		
	}

	getConditions(simulator, car, track) {
		local condition
		local compound
		
		path := (this.getSimulatorCode(simulator) . "\" . car . "\" . track . "\")
		conditions := []
		
		for ignore, fileName in this.getEntries(path . "Tyre Setup*.data", "F") {
			condition := string2Values(A_Space, StrReplace(StrReplace(fileName, "Tyre Setup ", ""), ".data", ""))
		
			if (condition.Length() == 2) {
				compound := condition[1]
				weather := condition[2]
			}
			else {
				compound := condition[1] . A_Space . condition[2]
				weather := condition[3]
			}
			
			pressures := readConfiguration(kDatabaseDirectory . "local\" . path . fileName)
			
			if (pressures.Count() == 0)
				pressures := readConfiguration(kDatabaseDirectory . "global\" . path . fileName)
			
			for descriptor, ignore in getConfigurationSectionValues(pressures, "Pressures") {
				descriptor := ConfigurationItem.splitDescriptor(descriptor)
			
				if descriptor[1] {
					; weather, airTemperature, trackTemperature, compound
					conditions.Push(Array(weather, descriptor[1], descriptor[2], compound))
				}
			}
		}
		
		return conditions
	}

	getTyreSetup(simulator, car, track, weather, airTemperature, trackTemperature, ByRef compound, ByRef compoundColor, ByRef pressures, ByRef certainty) {
		local condition
		
		simulator := this.getSimulatorName(simulator)
		
		if !compound {
			weatherIndex := inList(kWeatherOptions, weather)
			visited := []
			compounds := []
			
			for ignore, condition in this.getConditions(simulator, car, track) {
				theCompound := condition[4]
				conditionIndex := inList(kWeatherOptions, condition[1])
			
				if (((Abs(weatherIndex - conditionIndex) <= 1) || ((weatherIndex >= 2) && (conditionIndex >= 2))) && !inList(visited, theCompound)) {  
					visited.Push(theCompound)
					
					theCompound := string2Values(A_Space, theCompound)
					
					if (theCompound.Length() == 1)
						theCompoundColor := "Black"
					else
						theCompoundColor := SubStr(theCompound[2], 2, StrLen(theCompound[2]) - 2)
				
					compounds.Push(Array(theCompound[1], theCompoundColor))
				}
			}
		}
		else
			compounds := [Array(compound, compoundColor)]
		
		thePressures := []
		theCertainty := 1.0
		
		for ignore, compoundInfo in compounds {
			theCompound := compoundInfo[1]
			theCompoundColor := compoundInfo[2]
			
			for ignore, pressureInfo in this.getPressures(simulator, car, track, weather, airTemperature, trackTemperature, theCompound, theCompoundColor) {
				deltaAir := pressureInfo["Delta Air"]
				deltaTrack := pressureInfo["Delta Track"]
				
				thePressures.Push(pressureInfo["Pressure"] + ((deltaAir + Round(deltaTrack * 0.49)) * 0.1))
				
				theCertainty := Min(theCertainty, 1.0 - (Abs(deltaAir + deltaTrack) / (kMaxTemperatureDelta + 1)))
			}
			
			if (thePressures.Length() > 0) {
				compound := theCompound
				compoundColor := theCompoundColor
				certainty := theCertainty
				pressures := thePressures
				
				return true
			}
		}
		
		return false
	}

	getPressures(simulator, car, track, weather, airTemperature, trackTemperature, compound, compoundColor) {
		weatherBaseIndex := inList(kWeatherOptions, weather)
		
		if (weatherBaseIndex == 1)
			weatherCandidateOffsets := [0, 1]
		if (weatherBaseIndex == 2)
			weatherCandidateOffsets := [0, -1]
		else
			weatherCandidateOffsets := [0, 1, 2, 3]
		
		for ignore, weatherOffset in weatherCandidateOffsets {
			weather := kWeatherOptions[Max(0, Min(weatherBaseIndex + weatherOffset, kWeatherOptions.Length()))]
		
			if (compoundColor = "Black")
				path := (this.getSimulatorCode(simulator) . "\" . car . "\" . track . "\Tyre Setup " . compound . A_Space . weather . ".data")
			else
				path := (this.getSimulatorCode(simulator) . "\" . car . "\" . track . "\Tyre Setup " . compound . " (" . compoundColor . ") " . weather . ".data")
			
			for ignore, airDelta in kTemperatureDeltas {
				for ignore, trackDelta in kTemperatureDeltas {
					distributions := {FL: {}, FR: {}, RL: {}, RR: {}}
					
					this.getPressureDistributions(kDatabaseDirectory . "local\" . path, airTemperature + airDelta, trackTemperature + trackDelta, distributions)
					
					if this.UseGlobalDatabase
						this.getPressureDistributions(kDatabaseDirectory . "global\" . path, airTemperature + airDelta, trackTemperature + trackDelta, distributions)
					
					if (distributions["FL"].Count() != 0) {
						thePressures := {}
						
						for index, tyre in ["FL", "FR", "RL", "RR"] {
							thePressures[tyre] := {}
							tyrePressures := distributions[tyre]
						
							bestPressure := false
							bestCount := 0
							
							for pressure, pressureCount in tyrePressures {
								if (pressureCount > bestCount) {
									bestCount := pressureCount
									bestPressure := pressure
								}
							}
								
							thePressures[tyre]["Pressure"] := bestPressure
							thePressures[tyre]["Delta Air"] := airDelta
							thePressures[tyre]["Delta Track"] := trackDelta
						}
						
						return thePressures
					}
				}
			}
		}
			
		return {}
	}
	
	updatePressures(simulator, car, track, weather, airTemperature, trackTemperature, compound, compoundColor, targetPressures) {
		if getConfigurationValue(this.ControllerConfiguration, "Simulators", simulator, false)
			simulatorCode := this.getSimulatorCode(simulator)
		else
			simulatorCode := simulator
		
		simulator := this.getSimulatorName(simulatorCode)
		
		FileCreateDir %kDatabaseDirectory%Local\%simulatorCode%\%car%\%track%
		
		if ((this.iLastSimulator != simulator) || (this.iLastCar != car) || (this.iLastTrack != track)
		 || (this.iLastCompound != compound) || (this.iLastCompoundColor != compoundColor) || (this.iLastWeather != weather)) {
			this.iDatabase := false
		
			this.iLastSimulator := simulator
			this.iLastCar := car
			this.iLastTrack := track
			this.iLastCompound := compound
			this.iLastCompoundColor := compoundColor
			this.iLastWeather := weather
		}
		
		key := ConfigurationItem.descriptor(airTemperature, trackTemperature)
		
		if !this.iDatabase {
			if (compoundColor = "Black")
				this.iDatabaseName := (kDatabaseDirectory . "Local\" . simulatorCode . "\" . car . "\" . track . "\Tyre Setup " . compound . A_Space . weather . ".data")
			else
				this.iDatabaseName := (kDatabaseDirectory . "Local\" . simulatorCode . "\" . car . "\" . track . "\Tyre Setup " . compound . " (" . compoundColor . ") " . weather . ".data")
		
			this.iDatabase := readConfiguration(this.iDatabaseName)
		}
		
		pressureData := getConfigurationValue(this.iDatabase, "Pressures", key, false)
		pressures := {FL: {}, FR: {}, RL: {}, RR: {}}
		
		if pressureData {
			pressureData := string2Values(";", pressureData)
			
			for index, tyre in ["FL", "FR", "RL", "RR"]
				for index, pressure in string2Values(",", pressureData[index]) {
					pressure := string2Values(":", pressure)
				
					pressures[tyre][pressure[1]] := pressure[2]
				}
		}
		
		for tyrePressure, count in targetPressures {
			tyrePressure := string2Values(":", tyrePressure)
			pressure := tyrePressure[2]
			
			tyrePressures := pressures[tyrePressure[1]]
			
			tyrePressures[pressure] := (tyrePressures.HasKey(pressure) ? (tyrePressures[pressure] + count) : count)
		}
			
		pressureData := []
		
		for ignore, tyrePressures in pressures {
			data := []
		
			for pressure, count in tyrePressures
				data.Push(pressure . ":" . count)
			
			pressureData.Push(values2String(",", data*))
		}
		
		setConfigurationValue(this.iDatabase, "Pressures", key, values2String("; ", pressureData*))
		
		writeConfiguration(this.iDatabaseName, this.iDatabase)
	}
	
	readNotes(simulator, car, track) {
		simulatorCode := this.getSimulatorCode(simulator)
		
		try {
			FileRead notes, %kDatabaseDirectory%Local\%simulatorCode%\%car%\%track%\Notes.txt
			
			return notes
		}
		catch exception {
			return ""
		}
	}
	
	writeNotes(simulator, car, track, notes) {
		simulatorCode := this.getSimulatorCode(simulator)
		
		FileCreateDir %kDatabaseDirectory%Local\%simulatorCode%\%car%\%track%
		
		try {
			FileDelete %kDatabaseDirectory%Local\%simulatorCode%\%car%\%track%\Notes.txt
		}
		catch exception {
			; ignore
		}
		
		FileAppend %notes%, %kDatabaseDirectory%Local\%simulatorCode%\%car%\%track%\Notes.txt, UTF-16
	}
	
	getSetupNames(simulator, car, track, ByRef localSetups, ByRef globalSetups) {
		simulatorCode := this.getSimulatorCode(simulator)
		
		localSetups := {}
		globalSetups := {}
		
		for ignore, setupType in kSetupTypes {
			setups := []
			
			Loop Files, %kDatabaseDirectory%Local\%simulatorCode%\%car%\%track%\Car Setups\%setupType%\*.*
			{
				SplitPath A_LoopFileName, setupName
			
				setups.Push(setupName)
			}
			
			localSetups[setupType] := setups
		}
		
		if this.UseGlobalDatabase
			for ignore, setupType in kSetupTypes {
				setups := []
				
				Loop Files, %kDatabaseDirectory%Global\%simulatorCode%\%car%\%track%\Car Setups\%setupType%\*.*
				{
					SplitPath A_LoopFileName, setupName
				
					setups.Push(setupName)
				}
				
				globalSetups[setupType] := setups
			}
	}
	
	readSetup(simulator, car, track, setupType, setup) {
		simulatorCode := this.getSimulatorCode(simulator)
		
		FileRead setupData, %kDatabaseDirectory%Local\%simulatorCode%\%car%\%track%\Car Setups\%setupType%\%setup%
		
		return setupData
	}
	
	writeSetup(simulator, car, track, setupType, fileName, setup) {
		simulatorCode := this.getSimulatorCode(simulator)
		
		try {
			FileDelete %kDatabaseDirectory%Local\%simulatorCode%\%car%\%track%\Car Setups\%setupType%\%fileName%
		}
		catch exception {
			; ignore
		}
		
		FileCreateDir %kDatabaseDirectory%Local\%simulatorCode%\%car%\%track%\Car Setups\%setupType%
		FileAppend %setup%, %kDatabaseDirectory%Local\%simulatorCode%\%car%\%track%\Car Setups\%setupType%\%fileName%
	}
	
	deleteSetup(simulator, car, track, setupType, setup) {
		simulatorCode := this.getSimulatorCode(simulator)
		
		try {
			FileDelete %kDatabaseDirectory%Local\%simulatorCode%\%car%\%track%\Car Setups\%setupType%\%setup%
		}
		catch exception {
			; ignore
		}
	}
	
	getSettingsNames(simulator, car, track, ByRef localSettings, ByRef globalSettings) {
		simulatorCode := this.getSimulatorCode(simulator)
		
		localSettings := []
		globalSettings := []
			
		Loop Files, %kDatabaseDirectory%Local\%simulatorCode%\%car%\%track%\Race Settings\*.*
		{
			SplitPath A_LoopFileName, settingsName
		
			localSettings.Push(StrReplace(settingsName, ".settings", ""))
		}
		
		if this.UseGlobalDatabase {
			Loop Files, %kDatabaseDirectory%Global\%simulatorCode%\%car%\%track%\Race Settings\*.*
			{
				SplitPath A_LoopFileName, settingsName
			
				globalSettings.Push(StrReplace(settingsName, ".settings", ""))
			}
		}
	}
	
	doSettings(simulator, car, track, function) {
		localSettings := false
		globalSettings := false
		
		this.getSettingsNames(simulator, car, track, localSettings, globalSettings)
		
		for ignore, name in localSettings
			%function%(simulator, car, track, name)
		
		for ignore, name in globalSettings
			%function%(simulator, car, track, name)
	}
	
	matchProperties(query, precise, result, simulator, car, track, name) {
		local compound
		
		if precise {
			match := true
			
			newSettings := this.readSettings(simulator, car, track, name)
			
			if (query.HasKey("Duration") && (getConfigurationValue(newSettings, "Session Settings", "Duration") != query["Duration"]))
				match := false
			
			if (getConfigurationValue(newSettings, "Session Setup", "Tyre.Compound", "Dry") != (query.HasKey("Compound") ? query["Compound"] : "Dry"))
				match := false
			
			if match {
				result["Name"] := name
				result["Settings"] := newSettings
			}
		}
		else {
			if !result.HasKey("Name") {
				result["Name"] := name
				result["Settings"] := this.readSettings(simulator, car, track, name)
			}
			else {
				newSettings := this.readSettings(simulator, car, track, name)
			
				if query.HasKey("Duration") {
					duration := query["Duration"]
					
					betterMatchingDuration := (Abs(getConfigurationValue(newSettings, "Session Settings", "Duration") - duration) < Abs(getConfigurationValue(result["Settings"], "Session Settings", "Duration") - duration))
				}
				else
					betterMatchingDuration := false
				
				if query.HasKey("Compound") {
					compound := query["Compound"]
				
					matchingTyres := (compound = getConfigurationValue(newSettings, "Session Setup", "Tyre.Compound", "Dry"))
					
					betterMatchingTyres := (matchingTyres && (compound != getConfigurationValue(result["Settings"], "Session Setup", "Tyre.Compound", "Dry")))
				}
				else {
					matchingTyres := (getConfigurationValue(newSettings, "Session Setup", "Tyre.Compound", "Dry") = "Dry")
				
					if (getConfigurationValue(result["Settings"], "Session Setup", "Tyre.Compound", "Dry") = "Dry")
						betterMatchingTyres := false
					else
						betterMatchingTyres := matchingTyres
				}
				
				if (betterMatchingDuration && !matchingTyres)
					betterMatchingDuration := false
				
				if (betterMatchingTyres || betterMatchingDuration) {
					result["Name"] := name
					result["Settings"] := newSettings
				}
			}
		}
	}
	
	getSettings(simulator, car, track, query) {
		simulatorName := this.getSimulatorName(simulator)
		
		result := {}
			
		this.doSettings(simulatorName, car, track, ObjBindMethod(this, "matchProperties", query, false, result))
	
		settingsName := (result.HasKey("Name") ? result["Name"] : false)
		
		if settingsName
			return this.readSettings(simulatorName, car, track, settingsName)
		else
			return readConfiguration(getFileName("Race.settings", kUserConfigDirectory))
	}
	
	readSettings(simulator, car, track, settingsName) {
		simulatorCode := this.getSimulatorCode(simulator)
		
		fileName = %kDatabaseDirectory%Local\%simulatorCode%\%car%\%track%\Race Settings\%settingsName%.settings
		
		settings := readConfiguration(fileName)
		
		if (settings.Count() = 0) {
			fileName = %kDatabaseDirectory%Global\%simulatorCode%\%car%\%track%\Race Settings\%settingsName%.settings
		
			return readConfiguration(fileName)
		}
		else
			return settings
	}
	
	writeSettings(simulator, car, track, settingsName, settings) {
		simulatorCode := this.getSimulatorCode(simulator)
		
		fileName = %kDatabaseDirectory%Local\%simulatorCode%\%car%\%track%\Race Settings
		
		FileCreateDir %fileName%
		
		fileName := (fileName . "\" . settingsName . ".settings")
		
		writeConfiguration(fileName, settings)
	}
	
	deleteSettings(simulator, car, track, settingsName) {
		simulatorCode := this.getSimulatorCode(simulator)
		
		fileName = %kDatabaseDirectory%Local\%simulatorCode%\%car%\%track%\Race Settings\%settingsName%.settings
		
		try {
			FileDelete %fileName%
		}
		catch exception {
			; ignore
		}
	}
	
	renameSettings(simulator, car, track, oldSettingsName, newSettingsName) {
		simulatorCode := this.getSimulatorCode(simulator)
		
		oldFileName = %kDatabaseDirectory%Local\%simulatorCode%\%car%\%track%\Race Settings\%oldSettingsName%.settings
		newFileName = %kDatabaseDirectory%Local\%simulatorCode%\%car%\%track%\Race Settings\%newSettingsName%.settings
		
		try {
			FileMove %oldFileName%, %newFileName%, 1
		}
		catch exception {
			; ignore
		}
	}
	
	updateSettingsValues(settings, values) {
		if values.HasKey("Compound")
			setConfigurationValue(settings, "Session Setup", "Tyre.Compound", values["Compound"])
		
		if values.HasKey("CompoundColor")
			setConfigurationValue(settings, "Session Setup", "Tyre.Compound.Color", values["CompoundColor"])
		
		if values.HasKey("AvgLapTime")
			setConfigurationValue(settings, "Session Settings", "Lap.AvgTime", values["AvgLapTime"])
		
		if values.HasKey("AvgFuelConsumption")
			setConfigurationValue(settings, "Session Settings", "Fuel.AvgConsumption", values["AvgFuelConsumption"])
		
		if values.HasKey("Duration")
			setConfigurationValue(settings, "Session Settings", "Duration", values["Duration"])
	}
	
	updateSettings(simulator, car, track, query, values) {
		simulatorName := this.getSimulatorName(simulator)
		
		result := {}
		
		this.doSettings(simulatorName, car, track, ObjBindMethod(this, "matchProperties", query, true, result))
	
		settingsName := (result.HasKey("Name") ? result["Name"] : false)
		
		if settingsName {
			settings := this.readSettings(simulatorName, car, track, settingsName)
		
			this.updateSettingsValues(settings, values)
			
			this.writeSettings(simulatorName, car, track, settingsName, settings)
		}
		else {
			fileName := getFileName("Race.settings", kUserConfigDirectory)
			
			settings := readConfiguration(fileName)
			
			this.updateSettingsValues(settings, values)
			
			this.writeSettings(simulatorName, car, track, translate("New") . " - " . A_Now, settings)
		}
	}
}
