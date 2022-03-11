;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Settings Database               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Assistants\Libraries\SessionDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class SettingsDatabase extends SessionDatabase {	
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
