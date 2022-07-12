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
#Include ..\Libraries\GDIP.ahk


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

createTrackImage(trackMap) {
	mapWidth := getConfigurationValue(trackMap, "Map", "Width")
	mapHeight := getConfigurationValue(trackMap, "Map", "Height")

	xMin := getConfigurationValue(trackMap, "Map", "X.Min")
	yMin := getConfigurationValue(trackMap, "Map", "Y.Min")

	token := Gdip_Startup()

	bitmap := Gdip_CreateBitmap(mapWidth, mapHeight)

	graphics := Gdip_GraphicsFromImage(bitmap)

	Gdip_SetSmoothingMode(graphics, 4)

	pen := Gdip_CreatePen(0xbb000000, 3)

	scale := 1.0

	offsetX := (- xMin) + (mapWidth * 0.1)
	offsetY := (- yMin) + (mapHeight * 0.1)

	scaleX := (scale * 0.8)
	scaleY := (scale * 0.8)

	firstX := 0
	firstY := 0
	lastX := 0
	lastY := 0

	Loop % getConfigurationValue(trackMap, "Map", "Points")
	{
		x := Round((offsetX + getConfigurationValue(trackMap, "Points", A_Index . ".X")) * scaleX)
		y := Round((offsetY + getConfigurationValue(trackMap, "Points", A_Index . ".Y")) * scaleY)

		if (A_Index = 1) {
			firstX := x
			firstY := y
		}
		else
			Gdip_DrawLine(graphics, pen, lastX, lastY, x, y)

		lastX := x
		lastY := y
	}

	Gdip_DrawLine(graphics, pen, lastX, lastY, firstX, firstY)

	Gdip_DeletePen(pen)

	Gdip_SaveBitmapToFile(bitmap, kTempDirectory . "TrackMap.png")

	Gdip_DisposeImage(bitmap)

	Gdip_DeleteGraphics(graphics)

	Gdip_Shutdown(token)

	return (kTempDirectory . "TrackMap.png")
}

createTrackMap(simulator, track, fileName) {
	xMin := kUndefined
	xMax := kUndefined
	yMin := kUndefined
	yMax := kUndefined

	trackMap := newConfiguration()
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

		setConfigurationValue(trackMap, "Points", A_Index . ".X", Round(coordinates[1], 3))
		setConfigurationValue(trackMap, "Points", A_Index . ".Y", Round(coordinates[2], 3))

		Sleep 50
	}

	sessionDB := new SessionDatabase()

	simulator := sessionDB.getSimulatorName(simulator)

	setConfigurationValue(trackMap, "General", "Simulator", simulator)
	setConfigurationValue(trackMap, "General", "Track", track)

	setConfigurationValue(trackMap, "Map", "Points", points)
	setConfigurationValue(trackMap, "Map", "Width", Ceil(xMax) - Floor(xMin))
	setConfigurationValue(trackMap, "Map", "Height", Ceil(yMax) - Floor(yMin))
	setConfigurationValue(trackMap, "Map", "X.Min", Round(xMin, 3))
	setConfigurationValue(trackMap, "Map", "X.Max", Round(xMax, 3))
	setConfigurationValue(trackMap, "Map", "Y.Min", Round(yMin, 3))
	setConfigurationValue(trackMap, "Map", "Y.Max", Round(yMax, 3))

	fileName := createTrackImage(trackMap)

	sessionDB.updateTrackMap(simulator, track, trackMap, fileName)

	try {
		FileDelete %fileName%
	}
	catch exception {
		; ignore
	}
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