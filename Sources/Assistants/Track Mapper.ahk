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

	offsetX := (- xMin) + (mapWidth * 0.05)
	offsetY := (- yMin) + (mapHeight * 0.05)

	scale := 0.9

	firstX := 0
	firstY := 0
	lastX := 0
	lastY := 0

	Loop % getConfigurationValue(trackMap, "Map", "Points")
	{
		x := Round((offsetX + getConfigurationValue(trackMap, "Points", A_Index . ".X")) * scale)
		y := Round((offsetY + getConfigurationValue(trackMap, "Points", A_Index . ".Y")) * scale)

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

	setConfigurationValue(trackMap, "Map", "Offset.X", offsetX)
	setConfigurationValue(trackMap, "Map", "Offset.Y", offsetY)

	setConfigurationValue(trackMap, "Map", "Scale", scale)

	return (kTempDirectory . "TrackMap.png")
}

createTrackMap(simulator, track, fileName) {
	trackMap := newConfiguration()
	coordinates := []

	Loop Read, %fileName%
	{
		coordinates.Push(string2Values(",", A_LoopReadLine))

		Sleep 1
	}

	if (coordinates.Length() > 0) {
		if (coordinates[1].Length() = 2) {
			exact := true

			xIndex := 1
			yIndex := 2
		}
		else {
			exact := false

			xIndex := 2
			yIndex := 3
		}

		xMin := coordinates[1][xIndex]
		xMax := coordinates[1][xIndex]
		yMin := coordinates[1][yIndex]
		yMax := coordinates[1][yIndex]

		points := 0

		for ignore, coordinate in coordinates {
			xMin := Min(xMin, coordinate[xIndex])
			xMax := Max(xMax, coordinate[xIndex])
			yMin := Min(yMin, coordinate[yIndex])
			yMax := Max(yMax, coordinate[yIndex])

			points += 1

			Sleep 1
		}

		width := (Ceil(xMax) - Floor(xMin))
		height := (Ceil(yMax) - Floor(yMin))

		scale := Min(1000 / width, 1000 / height)

		width := (width * scale)
		height := (height * scale)
		xMin := (xMin * scale)
		xMax := (xMax * scale)
		yMin := (yMin * scale)
		yMax := (yMax * scale)

		for ignore, coordinate in coordinates {
			coordinate[xIndex] := (coordinate[xIndex] * scale)
			coordinate[yIndex] := (coordinate[yIndex] * scale)

			Sleep 1
		}

		if exact
			trackData := false
		else {
			normalized := []

			Loop 1000
				normalized.Push(false)

			normalized[1] := [0.0, 0.0]

			for ignore, coordinate in coordinates {
				normalized[Round(coordinate[1] * 1000)] := [coordinate[2], coordinate[3]]

				Sleep 1
			}

			trackData := ""

			Loop 1000 {
				coordinate := normalized[A_Index]

				if !coordinate {
					coordinate := normalized[A_Index - 1]

					normalized[A_Index] := coordinate
				}

				if (A_Index > 1)
					trackData .= "`n"

				trackData .= (coordinate[1] . A_Space . coordinate[2])

				Sleep 1
			}

			coordinates := normalized
			points := 1000
		}

		sessionDB := new SessionDatabase()

		simulator := sessionDB.getSimulatorName(simulator)

		setConfigurationValue(trackMap, "General", "Simulator", simulator)
		setConfigurationValue(trackMap, "General", "Track", track)

		setConfigurationValue(trackMap, "Map", "Width", Round(width))
		setConfigurationValue(trackMap, "Map", "Height", Round(height))
		setConfigurationValue(trackMap, "Map", "X.Min", Round(xMin, 3))
		setConfigurationValue(trackMap, "Map", "X.Max", Round(xMax, 3))
		setConfigurationValue(trackMap, "Map", "Y.Min", Round(yMin, 3))
		setConfigurationValue(trackMap, "Map", "Y.Max", Round(yMax, 3))

		setConfigurationValue(trackMap, "Map", "Precision", exact ? "Exact" : "Estimated")
		setConfigurationValue(trackMap, "Map", "Points", points)

		Loop %points% {
			setConfigurationValue(trackMap, "Points", A_Index . ".X", coordinates[A_Index][1])
			setConfigurationValue(trackMap, "Points", A_Index . ".Y", coordinates[A_Index][2])

			Sleep 1
		}

		if trackData {
			try {
				FileDelete %kTempDirectory%%track%.data
			}
			catch exception {
				; ignore
			}

			FileAppend %trackData%, %kTempDirectory%%track%.data

			trackData := (kTempDirectory . track . ".data")
		}

		fileName := createTrackImage(trackMap)

		sessionDB.updateTrackMap(simulator, track, trackMap, fileName, trackData)

		try {
			FileDelete %fileName%

			if trackData
				FileDelete %trackData%
		}
		catch exception {
			; ignore
		}
	}
}

recreateTrackMap(simulator, track) {
	sessionDB := new SessionDatabase()

	trackMap := sessionDB.getTrackMap(simulator, track)
	fileName := createTrackImage(trackMap)

	sessionDB.updateTrackMap(simulator, track, trackMap, fileName)
}

recreateTrackMaps() {
	sessionDB := new SessionDatabase()

	Loop Files, %kDatabaseDirectory%User\Tracks\*.*, D		; Simulator
	{
		code := A_LoopFileName

		simulator := sessionDB.getSimulatorName(code)

		Loop Files, %kDatabaseDirectory%User\Tracks\%code%\*.map, F		; Track
		{
			SplitPath A_LoopFileName, , , , track

			recreateTrackMap(simulator, track)
		}
	}
}

startTrackMapper() {
	icon := kIconsDirectory . "Track.ico"

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Track Mapper

	Menu Tray, NoStandard
	Menu Tray, Add, Exit, Exit

	simulator := false
	track := false
	data := false
	recreate := false

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
			case "-All":
				recreate := true
				index += 1
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

	if recreate
		recreateTrackMaps()

	ExitApp 0

Exit:
	ExitApp 0
}

;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

startTrackMapper()