;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Team Session Log Program        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Engine.ico
;@Ahk2Exe-ExeName Team Session Logger.exe

global vBuildConfiguration := "Development"


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Framework\Application.ahk


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

readSimulatorData(simulator, options := "", protocol := "SHM") {
	exePath := kBinariesDirectory . simulator . A_Space . protocol . " Provider.exe"

	FileCreateDir %kTempDirectory%%simulator% Data

	dataFile := temporaryFileName(simulator . " Data\" . protocol, "data")

	try {
		RunWait %ComSpec% /c ""%exePath%" %options% > "%dataFile%"", , Hide
	}
	catch Any as exception {
		logError(exception, true)

		logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider ("), {simulator: simulator, protocol: protocol})
												   . exePath . translate(") - please rebuild the applications in the binaries folder (")
												   . kBinariesDirectory . translate(")"))

		showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration...")
									  , {exePath: exePath, simulator: simulator, protocol: protocol})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}

	data := readMultiMap(dataFile)

	deleteFile(dataFile)

	setMultiMapValue(data, "Session Data", "Simulator", simulator)

	return data
}

runTeamSessionLogger() {
	icon := kIconsDirectory . "Engine.ico"

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Team Session Logger

	deleteFile(kTempDirectory . "Team Session.log")

	loop {
		data := readSimulatorData("ACC")

		info := values2String("; ", A_Now,
								  , getMultiMapValue(data, "Session Data", "Active", "?")
								  , getMultiMapValue(data, "Session Data", "Paused", "?")
								  , getMultiMapValue(data, "Session Data", "Session", "?")
								  , getMultiMapValue(data, "Stint Data", "Laps", "?")
								  , getMultiMapValue(data, "Stint Data", "InPit", "?")
								  , getMultiMapValue(data, "Stint Data", "DriverForname", "?")
								  , getMultiMapValue(data, "Stint Data", "DriverSurname", "?")
								  , getMultiMapValue(data, "Stint Data", "DriverNickName", "?")
								  , getMultiMapValue(data, "Stint Data", "DriverTimeRemaining", "?")
								  , getMultiMapValue(data, "Stint Data", "StintTimeRemaining", "?")) . "`n"

		FileAppend %info%, %kTempDirectory%Team Session.log

		Sleep 10000
	}

	return
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

runTeamSessionLogger()