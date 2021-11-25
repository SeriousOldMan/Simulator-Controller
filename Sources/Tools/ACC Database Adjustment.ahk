;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - ACC Database Cleanup            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#SingleInstance Force			; Ony one instance allowed
#NoEnv							; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn							; Enable warnings to assist with detecting common errors.
#Warn LocalSameAsGlobal, Off

SendMode Input					; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.

SetBatchLines -1				; Maximize CPU utilization
ListLines Off					; Disable execution history

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Tools.ico
;@Ahk2Exe-ExeName ACC Database Adjustment.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Assistants\Libraries\SetupDatabase.ahk
#Include ..\Assistants\Libraries\TelemetryDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Function Section                         ;;;
;;;-------------------------------------------------------------------------;;;

adjustPressureDistributions(code, car, track, compound, weather, airTemperature, trackTemperature, correction, ByRef progress) {
	fileName := (code . "\" . car . "\" . track . "\Tyre Setup " . compound . A_Space . weather . ".data")
	fileName := (kDatabaseDirectory . "local\" . fileName)
	
	if FileExist(fileName) {
		showProgress({progress: progress++, message: "Adjusting " . compound . " (" . airTemperature . ", " . trackTemperature . ") for " . car . " on " . track . " in " weather . "..."})
					
		if (progress > 100)
			progress := 0
			
		temperature := ConfigurationItem.descriptor(airTemperature, trackTemperature)
		distributions := {FL: {}, FR: {}, RL: {}, RR: {}}
		pressureData := readConfiguration(fileName)
		tyrePressures := getConfigurationValue(pressureData, "Pressures", temperature, false)
		
		if tyrePressures {
			tyrePressures := string2Values(";", tyrePressures)
			newTyrePressures := []
			
			for index, key in ["FL", "FR", "RL", "RR"] {
				newPressures := []
			
				for ignore, pressure in string2Values(",", tyrePressures[index]) {
					pressure := string2Values(":", pressure)
				
					correctedPressure := Round(pressure[1] + correction, 1)
					
					newPressures.Push(values2String(":", correctedPressure, pressure[2]))
				}
				
				newTyrePressures.Push(values2String(",", newPressures*))
			}
			
			tyrePressures := values2String(";", newTyrePressures*)
			
			setConfigurationValue(pressureData, "Pressures", temperature, tyrePressures)
			
			writeConfiguration(fileName, pressureData)
			
			Sleep 100
		}
	}
}

cleanupTyrePressures() {
	setupDB := new SetupDatabase()

	dryCorrection := ""
	prompt := "Please input the adjustment factor for cold DRY pressures in PSI (use ""."" as decimal point).`n`nExample: -0.1 will adjust 25.6 to 25.5."
	
	Loop {
		InputBox dryCorrection, Cold Pressure Correction, %prompt%, , 350, 200, , , , , %dryCorrection%
	
		if ErrorLevel {
			ExitApp 0
		}
		else if dryCorrection is not number
			MsgBox Please input a correct number...
		else
			break
	}

	wetCorrection := ""
	prompt := "Please input the adjustment factor for cold WET pressures in PSI (use ""."" as decimal point).`n`nExample: -0.1 will adjust 25.6 to 25.5."
	
	Loop {
		InputBox wetCorrection, Cold Pressure Adjustment, %prompt%, , 350, 200, , , , , %wetCorrection%
	
		if ErrorLevel {
			ExitApp 0
		}
		else if wetCorrection is not number
			MsgBox Please input a correct number...
		else
			break
	}
	
	progress := 0
	
	x := Round((A_ScreenWidth - 300) / 2)
	y := A_ScreenHeight - 150

	showProgress({x: x, y: y, width: 450, color: "Silver", message: "", title: translate("Adjust Tyre Pressures")})
	
	for ignore, car in setupDB.getCars("Assetto Corsa Competizione")
		for ignore, track in setupDB.getTracks("Assetto Corsa Competizione", car)
			for ignore, condition in setupDB.getConditions("Assetto Corsa Competizione", car, track) {
				weather := condition[1]
				airTemperature := condition[2]
				trackTemperature := condition[3]
				compound := condition[4]
				
				if (((compound = "Dry") && (dryCorrection != 0)) || ((compound = "Wet") && (wetCorrection != 0)))
					for ignore, qualifiedCompound in kQualifiedTyreCompounds
						adjustPressureDistributions(setupDB.getSimulatorCode("Assetto Corsa Competizione"), car, track, qualifiedCompound, weather
												  , airTemperature, trackTemperature, (compound = "Dry") ? dryCorrection : wetCorrection, progress)
			}
	
	hideProgress()
}

cleanupTelemetryData() {
	setupDB := new SetupDatabase()

	laptimeCorrection := ""
	prompt := "Please input the adjustment factor for laptimes in DRY conditions (use ""."" as decimal point).`n`nExample: 0.5 will increase all lap times in telemetry data by half a second."
	
	Loop {
		InputBox laptimeCorrection, Laptime Correction, %prompt%, , 350, 200, , , , , %laptimeCorrection%
	
		if ErrorLevel {
			ExitApp 0
		}
		else if laptimeCorrection is not number
			MsgBox Please input a correct number...
		else
			break
	}
	
	if (laptimeCorrection != 0) {
		progress := 0
		
		x := Round((A_ScreenWidth - 300) / 2)
		y := A_ScreenHeight - 150

		showProgress({x: x, y: y, width: 450, color: "Silver", message: "", title: translate("Adjust Laptimes")})
	
		for ignore, car in setupDB.getCars("Assetto Corsa Competizione")
			for ignore, track in setupDB.getTracks("Assetto Corsa Competizione", car) {
				showProgress({progress: progress++, message: "Adjusting laptime for " . car . " on " . track . " in Dry..."})
			
				if (progress > 100)
					progress := 0
		
				telemetryDB := new TelemetryDatabase("Assetto Corsa Competizione", car, track)
				
				for ignore, entry in telemetryDB.Database.Tables["Electronics"]
					if (entry["Weather"] = "Dry")
						entry["Lap.Time"] := Round(entry["Lap.Time"] + lapTimeCorrection, 1)
			
				for ignore, entry in telemetryDB.Database.Tables["Tyres"]
					if (entry["Weather"] = "Dry")
						entry["Lap.Time"] := Round(entry["Lap.Time"] + lapTimeCorrection, 1)
			
				Sleep 100
				
				telemetryDB.Database.flush()
			}
	
		hideProgress()
	}
}

cleanupACCDatabase() {
	icon := kIconsDirectory . "Tools.ico"
	
	try {
		Menu Tray, Icon, %icon%, , 1
		Menu Tray, Tip, ACC Database Adjustment
		
		cleanupTyrePressures()
		cleanupTelemetryData()
	}
	finally {
		ExitApp 0
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;
	
cleanupACCDatabase()