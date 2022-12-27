;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Track Mapper                    ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

;@SC-IF %configuration% == Development
#Include ..\Framework\Development.ahk
;@SC-EndIF

;@SC-If %configuration% == Production
;@SC #Include ..\Framework\Production.ahk
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Track.ico
;@Ahk2Exe-ExeName Track Mapper.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Framework\Process.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include Libraries\SessionDatabase.ahk
#Include ..\Libraries\GDIP.ahk


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

createTrackImage(trackMap) {
	local mapWidth := getConfigurationValue(trackMap, "Map", "Width")
	local mapHeight := getConfigurationValue(trackMap, "Map", "Height")
	local offsetX := getConfigurationValue(trackMap, "Map", "Offset.X")
	local offsetY := getConfigurationValue(trackMap, "Map", "Offset.Y")
	local margin := Min(mapWidth / 20, mapHeight / 20)
	local marginX := margin
	local marginY := margin
	local width := (mapWidth + 2 * marginX)
	local height := (mapHeight + 2 * marginY)
	local scale := Min(1000 / width, 1000 / height)
	local token, bitmap, graphics, pen
	local firstX, firstY, lastX, lastY, x, y

	setConfigurationValue(trackMap, "Map", "Margin.X", marginX)
	setConfigurationValue(trackMap, "Map", "Margin.Y", marginY)
	setConfigurationValue(trackMap, "Map", "Scale", scale)

	token := Gdip_Startup()

	bitmap := Gdip_CreateBitmap(Round(width * scale), Round(height * scale))

	graphics := Gdip_GraphicsFromImage(bitmap)

	Gdip_SetSmoothingMode(graphics, 4)

	pen := Gdip_CreatePen(0xbb000000, 5)

	firstX := 0
	firstY := 0
	lastX := 0
	lastY := 0

	loop % getConfigurationValue(trackMap, "Map", "Points")
	{
		x := Round((marginX + offsetX + getConfigurationValue(trackMap, "Points", A_Index . ".X")) * scale)
		y := Round((marginY + offsetY + getConfigurationValue(trackMap, "Points", A_Index . ".Y")) * scale)

		if (A_Index = 1) {
			firstX := x
			firstY := y
		}
		else
			Gdip_DrawLine(graphics, pen, lastX, lastY, x, y)

		lastX := x
		lastY := y

		Sleep 1
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
	local sessionDB := new SessionDatabase()
	local trackMapperState := newConfiguration()
	local trackMap := newConfiguration()
	local coordinates := []
	local exact, xIndex, yIndex, xMin, xMax, yMin, yMax, points, ignore, coordinate, width, height
	local trackData, normalized

	setConfigurationValue(trackMap, "General", "Simulator", simulator)
	setConfigurationValue(trackMap, "General", "Track", track)

	setConfigurationValue(trackMapperState, "Track Mapper", "State", "Active")
	setConfigurationValue(trackMapperState, "Track Mapper", "Simulator", sessionDB.getSimulatorName(simulator))
	setConfigurationValue(trackMapperState, "Track Mapper", "Track", sessionDB.getTrackName(simulator, track))
	setConfigurationValue(trackMapperState, "Track Mapper", "Information", translate("Message: ") . translate("Creating track map..."))
	setConfigurationValue(trackMapperState, "Track Mapper", "Action", "Reading")
	setConfigurationValue(trackMapperState, "Track Mapper", "Points", 0)

	writeConfiguration(kTempDirectory . "Track Mapper.state", trackMapperState)

	loop Read, %fileName%
	{
		coordinates.Push(string2Values(",", A_LoopReadLine))

		Sleep 1

		if (Mod(A_Index, 100) = 0) {
			setConfigurationValue(trackMapperState, "Track Mapper", "Points", A_Index)

			writeConfiguration(kTempDirectory . "Track Mapper.state", trackMapperState)
		}
	}

	setConfigurationValue(trackMapperState, "Track Mapper", "Action", "Analyzing")
	setConfigurationValue(trackMapperState, "Track Mapper", "Points", 0)

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

			if (Mod(A_Index, 100) = 0) {
				setConfigurationValue(trackMapperState, "Track Mapper", "Points", A_Index)

				writeConfiguration(kTempDirectory . "Track Mapper.state", trackMapperState)
			}
		}

		width := (Ceil(xMax) - Floor(xMin))
		height := (Ceil(yMax) - Floor(yMin))

		setConfigurationValue(trackMap, "Map", "Width", Round(width))

		setConfigurationValue(trackMap, "Map", "Height", Round(height))
		setConfigurationValue(trackMap, "Map", "X.Min", Round(xMin, 3))
		setConfigurationValue(trackMap, "Map", "X.Max", Round(xMax, 3))
		setConfigurationValue(trackMap, "Map", "Y.Min", Round(yMin, 3))
		setConfigurationValue(trackMap, "Map", "Y.Max", Round(yMax, 3))

		setConfigurationValue(trackMap, "Map", "Offset.X", - xMin)
		setConfigurationValue(trackMap, "Map", "Offset.Y", - yMin)

		if exact
			trackData := false
		else {
			normalized := []

			loop 1000
				normalized.Push(false)

			normalized[1] := [0.0, 0.0]

			setConfigurationValue(trackMapperState, "Track Mapper", "Action", "Normalizing")
			setConfigurationValue(trackMapperState, "Track Mapper", "Points", 0)

			for ignore, coordinate in coordinates {
				normalized[Round(coordinate[1] * 1000)] := [coordinate[2], coordinate[3]]

				Sleep 1

				if (Mod(A_Index, 100) = 0) {
					setConfigurationValue(trackMapperState, "Track Mapper", "Points", A_Index)

					writeConfiguration(kTempDirectory . "Track Mapper.state", trackMapperState)
				}
			}

			trackData := ""

			setConfigurationValue(trackMapperState, "Track Mapper", "Action", "Transforming")
			setConfigurationValue(trackMapperState, "Track Mapper", "Points", 0)

			loop 1000 {
				coordinate := normalized[A_Index]

				if !coordinate {
					coordinate := normalized[A_Index - 1]

					normalized[A_Index] := coordinate
				}

				if (A_Index > 1)
					trackData .= "`n"

				trackData .= (coordinate[1] . A_Space . coordinate[2])

				Sleep 1

				if (Mod(A_Index, 100) = 0) {
					setConfigurationValue(trackMapperState, "Track Mapper", "Points", A_Index)

					writeConfiguration(kTempDirectory . "Track Mapper.state", trackMapperState)
				}
			}

			coordinates := normalized
			points := 1000
		}

		setConfigurationValue(trackMapperState, "Track Mapper", "Action", "Processing")
		setConfigurationValue(trackMapperState, "Track Mapper", "Points", 0)

		simulator := sessionDB.getSimulatorName(simulator)

		setConfigurationValue(trackMap, "Map", "Precision", exact ? "Exact" : "Estimated")
		setConfigurationValue(trackMap, "Map", "Points", points)

		loop %points% {
			setConfigurationValue(trackMap, "Points", A_Index . ".X", coordinates[A_Index][1])
			setConfigurationValue(trackMap, "Points", A_Index . ".Y", coordinates[A_Index][2])

			Sleep 1

			if (Mod(A_Index, 100) = 0) {
				setConfigurationValue(trackMapperState, "Track Mapper", "Points", A_Index)

				writeConfiguration(kTempDirectory . "Track Mapper.state", trackMapperState)
			}
		}

		if trackData {
			deleteFile(kTempDirectory . track . ".data")

			FileAppend %trackData%, %kTempDirectory%%track%.data

			trackData := (kTempDirectory . track . ".data")
		}

		setConfigurationValue(trackMapperState, "Track Mapper", "Action", "Image")
		removeConfigurationValue(trackMapperState, "Track Mapper", "Points")
		writeConfiguration(kTempDirectory . "Track Mapper.state", trackMapperState)

		fileName := createTrackImage(trackMap)

		setConfigurationValue(trackMapperState, "Track Mapper", "Action", "Metadata")
		writeConfiguration(kTempDirectory . "Track Mapper.state", trackMapperState)

		sessionDB.updateTrackMap(simulator, track, trackMap, fileName, trackData)

		deleteFile(fileName)

		if trackData
			deleteFile(fileName)

		Sleep 10000

		setConfigurationValue(trackMapperState, "Track Mapper", "Action", "Finished")
		writeConfiguration(kTempDirectory . "Track Mapper.state", trackMapperState)

		Sleep 10000

		deleteFile(kTempDirectory . "Track Mapper.state")
	}
}

recreateTrackMap(simulator, track) {
	local sessionDB := new SessionDatabase()
	local trackMap := sessionDB.getTrackMap(simulator, track)
	local fileName := createTrackImage(trackMap)

	sessionDB.updateTrackMap(simulator, track, trackMap, fileName)
}

recreateTrackMaps() {
	local sessionDB := new SessionDatabase()
	local directory := sessionDB.DatabasePath
	local code, simulator, track

	loop Files, %directory%User\Tracks\*.*, D		; Simulator
	{
		code := A_LoopFileName

		simulator := sessionDB.getSimulatorName(code)

		loop Files, %directory%User\Tracks\%code%\*.map, F		; Track
		{
			SplitPath A_LoopFileName, , , , track

			recreateTrackMap(simulator, track)
		}
	}
}

startTrackMapper() {
	local icon := kIconsDirectory . "Track.ico"
	local simulator := false
	local track := false
	local data := false
	local recreate := false
	local index

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Track Mapper

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

		deleteFile(data)
	}

	if recreate
		recreateTrackMaps()

	ExitApp 0
}

;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

startTrackMapper()