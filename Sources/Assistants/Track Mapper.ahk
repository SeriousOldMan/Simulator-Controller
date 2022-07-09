;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Track Mapper                    ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Track.ico
;@Ahk2Exe-ExeName Track Mapper.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include Libraries\SessionDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

createTrackMap(simulator, track, fileName) {
	xMin := kUndefined
	xMax := kUndefined
	yMin := kUndefined
	yMax := kUndefined

	data := newConfiguration()
	points := 0

	Loop Read, %fileName%
	{
		coordinates := string2Values(",", A_LoopReadLine)

		if (xMin == kUndefined) {
			xMin := coordinates[1]
			xMax := coordinates[1]
			yMin := coordinates[2]
			yMax := coordinates[2]
		}
		else {
			xMin := Min(xMin, coordinates[1])
			xMax := Max(xMax, coordinates[1])
			yMin := Min(yMin, coordinates[2])
			yMax := Max(yMax, coordinates[2])
		}

		points += 1

		setConfigurationValue(data, "Points", A_Index . ".X", Round(coordinates[1], 3))
		setConfigurationValue(data, "Points", A_Index . ".Y", Round(coordinates[2], 3))

		Sleep 50
	}

	sessionDB := new SessionDatabase()

	setConfigurationValue(data, "General", "Simulator", sessionDB.getSimulatorName(simulator))
	setConfigurationValue(data, "General", "Track", sessionDB.getTrackName(simulator, track))

	setConfigurationValue(data, "Map", "Points", points)
	setConfigurationValue(data, "Map", "Width", Ceil(xMax) - Floor(xMin))
	setConfigurationValue(data, "Map", "Height", Ceil(yMax) - Floor(yMin))
	setConfigurationValue(data, "Map", "X.Min", Round(xMin, 3))
	setConfigurationValue(data, "Map", "X.Max", Round(xMax, 3))
	setConfigurationValue(data, "Map", "Y.Min", Round(yMin, 3))
	setConfigurationValue(data, "Map", "Y.Max", Round(yMax, 3))

	sessionDB.updateTrackMap(simulator, track, data)
}

startTrackMapper() {
	icon := kIconsDirectory . "Track.ico"

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Database Synchronizer

	Menu Tray, NoStandard
	Menu Tray, Add, Exit, Exit

	simulator := false
	track := false
	data := false

	index := 1

	while (index < A_Args.Length()) {
		switch A_Args[index] {
			case "-Simulator":
				simulator := A_Args[index + 1]
				index += 2
			case "-Track":
				track := A_Args[index + 1]
				index += 2
			case "-Data":
				data := A_Args[index + 1]
				index += 2
			default:
				index += 1
		}
	}

	if (simulator && track && data) {
		createTrackMap(simulator, track, data)

		try {
			FileDelete %data%
		}
		catch exception {
			; ignore
		}
	}

	ExitApp 0

Exit:
	ExitApp 0
}

;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

startTrackMapper()