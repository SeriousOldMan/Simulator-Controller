;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Track Mapper                    ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

;@SC-IF %configuration% == Development
#Include "..\Framework\Development.ahk"
;@SC-EndIF

;@SC-If %configuration% == Production
;@SC #Include ..\Framework\Production.ahk
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Track.ico
;@Ahk2Exe-ExeName Track Mapper.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Process.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Database\Libraries\SessionDatabase.ahk"
#Include "..\Libraries\GDIP.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

createTrackImage(trackMap) {
	local mapWidth := getMultiMapValue(trackMap, "Map", "Width")
	local mapHeight := getMultiMapValue(trackMap, "Map", "Height")
	local offsetX := getMultiMapValue(trackMap, "Map", "Offset.X")
	local offsetY := getMultiMapValue(trackMap, "Map", "Offset.Y")
	local margin := Min(mapWidth / 20, mapHeight / 20)
	local marginX := margin
	local marginY := margin
	local width := (mapWidth + 2 * marginX)
	local height := (mapHeight + 2 * marginY)
	local scale := Min(1000 / width, 1000 / height)
	local token, bitmap, graphics, pen
	local firstX, firstY, lastX, lastY, x, y

	setMultiMapValue(trackMap, "Map", "Margin.X", marginX)
	setMultiMapValue(trackMap, "Map", "Margin.Y", marginY)
	setMultiMapValue(trackMap, "Map", "Scale", scale)

	token := Gdip_Startup()

	bitmap := Gdip_CreateBitcollect(Round(width * scale), Round(height * scale))

	graphics := Gdip_GraphicsFromImage(bitmap)

	Gdip_SetSmoothingMode(graphics, 4)

	pen := Gdip_CreatePen(0xbb000000, 5)

	firstX := 0
	firstY := 0
	lastX := 0
	lastY := 0

	loop getMultiMapValue(trackMap, "Map", "Points") {
		x := Round((marginX + offsetX + getMultiMapValue(trackMap, "Points", A_Index . ".X")) * scale)
		y := Round((marginY + offsetY + getMultiMapValue(trackMap, "Points", A_Index . ".Y")) * scale)

		if (A_Index = 1) {
			firstX := x
			firstY := y
		}
		else
			Gdip_DrawLine(graphics, pen, lastX, lastY, x, y)

		lastX := x
		lastY := y

		Sleep(1)
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
	local sessionDB := SessionDatabase()
	local trackMapperState := newMultiMap()
	local trackMap := newMultiMap()
	local coordinates := []
	local exact, xIndex, yIndex, xMin, xMax, yMin, yMax, points, ignore, coordinate, width, height
	local trackData, normalized

	setMultiMapValue(trackMap, "General", "Simulator", simulator)
	setMultiMapValue(trackMap, "General", "Track", track)

	setMultiMapValue(trackMapperState, "Track Mapper", "State", "Active")
	setMultiMapValue(trackMapperState, "Track Mapper", "Simulator", sessionDB.getSimulatorName(simulator))
	setMultiMapValue(trackMapperState, "Track Mapper", "Track", sessionDB.getTrackName(simulator, track))
	setMultiMapValue(trackMapperState, "Track Mapper", "Information", translate("Message: ") . translate("Creating track map..."))
	setMultiMapValue(trackMapperState, "Track Mapper", "Action", "Reading")
	setMultiMapValue(trackMapperState, "Track Mapper", "Points", 0)

	writeMultiMap(kTempDirectory . "Track Mapper.state", trackMapperState)

	loop Read, fileName {
		coordinates.Push(string2Values(",", A_LoopReadLine))

		Sleep(1)

		if (Mod(A_Index, 100) = 0) {
			setMultiMapValue(trackMapperState, "Track Mapper", "Points", A_Index)

			writeMultiMap(kTempDirectory . "Track Mapper.state", trackMapperState)
		}
	}

	setMultiMapValue(trackMapperState, "Track Mapper", "Action", "Analyzing")
	setMultiMapValue(trackMapperState, "Track Mapper", "Points", 0)

	if (coordinates.Length > 0) {
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

			Sleep(1)

			if (Mod(A_Index, 100) = 0) {
				setMultiMapValue(trackMapperState, "Track Mapper", "Points", A_Index)

				writeMultiMap(kTempDirectory . "Track Mapper.state", trackMapperState)
			}
		}

		width := (Ceil(xMax) - Floor(xMin))
		height := (Ceil(yMax) - Floor(yMin))

		setMultiMapValue(trackMap, "Map", "Width", Round(width))

		setMultiMapValue(trackMap, "Map", "Height", Round(height))
		setMultiMapValue(trackMap, "Map", "X.Min", Round(xMin, 3))
		setMultiMapValue(trackMap, "Map", "X.Max", Round(xMax, 3))
		setMultiMapValue(trackMap, "Map", "Y.Min", Round(yMin, 3))
		setMultiMapValue(trackMap, "Map", "Y.Max", Round(yMax, 3))

		setMultiMapValue(trackMap, "Map", "Offset.X", - xMin)
		setMultiMapValue(trackMap, "Map", "Offset.Y", - yMin)

		if exact
			trackData := false
		else {
			normalized := []

			loop 1000
				normalized.Push(false)

			normalized[1] := [0.0, 0.0]

			setMultiMapValue(trackMapperState, "Track Mapper", "Action", "Normalizing")
			setMultiMapValue(trackMapperState, "Track Mapper", "Points", 0)

			for ignore, coordinate in coordinates {
				normalized[Round(coordinate[1] * 1000)] := [coordinate[2], coordinate[3]]

				Sleep(1)

				if (Mod(A_Index, 100) = 0) {
					setMultiMapValue(trackMapperState, "Track Mapper", "Points", A_Index)

					writeMultiMap(kTempDirectory . "Track Mapper.state", trackMapperState)
				}
			}

			trackData := ""

			setMultiMapValue(trackMapperState, "Track Mapper", "Action", "Transforming")
			setMultiMapValue(trackMapperState, "Track Mapper", "Points", 0)

			loop 1000 {
				coordinate := normalized[A_Index]

				if !coordinate {
					coordinate := normalized[A_Index - 1]

					normalized[A_Index] := coordinate
				}

				if (A_Index > 1)
					trackData .= "`n"

				trackData .= (coordinate[1] . A_Space . coordinate[2])

				Sleep(1)

				if (Mod(A_Index, 100) = 0) {
					setMultiMapValue(trackMapperState, "Track Mapper", "Points", A_Index)

					writeMultiMap(kTempDirectory . "Track Mapper.state", trackMapperState)
				}
			}

			coordinates := normalized
			points := 1000
		}

		setMultiMapValue(trackMapperState, "Track Mapper", "Action", "Processing")
		setMultiMapValue(trackMapperState, "Track Mapper", "Points", 0)

		simulator := sessionDB.getSimulatorName(simulator)

		setMultiMapValue(trackMap, "Map", "Precision", exact ? "Exact" : "Estimated")
		setMultiMapValue(trackMap, "Map", "Points", points)

		loop points {
			setMultiMapValue(trackMap, "Points", A_Index . ".X", coordinates[A_Index][1])
			setMultiMapValue(trackMap, "Points", A_Index . ".Y", coordinates[A_Index][2])

			Sleep(1)

			if (Mod(A_Index, 100) = 0) {
				setMultiMapValue(trackMapperState, "Track Mapper", "Points", A_Index)

				writeMultiMap(kTempDirectory . "Track Mapper.state", trackMapperState)
			}
		}

		if trackData {
			deleteFile(kTempDirectory . track . ".data")

			FileAppend(trackData, kTempDirectory . track . ".data")

			trackData := (kTempDirectory . track . ".data")
		}

		setMultiMapValue(trackMapperState, "Track Mapper", "Action", "Image")
		removeMultiMapValue(trackMapperState, "Track Mapper", "Points")
		writeMultiMap(kTempDirectory . "Track Mapper.state", trackMapperState)

		fileName := createTrackImage(trackMap)

		setMultiMapValue(trackMapperState, "Track Mapper", "Action", "Metadata")
		writeMultiMap(kTempDirectory . "Track Mapper.state", trackMapperState)

		sessionDB.updateTrackMap(simulator, track, trackMap, fileName, trackData)

		deleteFile(fileName)

		if trackData
			deleteFile(fileName)

		Sleep(10000)

		setMultiMapValue(trackMapperState, "Track Mapper", "Action", "Finished")
		writeMultiMap(kTempDirectory . "Track Mapper.state", trackMapperState)

		Sleep(10000)

		deleteFile(kTempDirectory . "Track Mapper.state")
	}
}

recreateTrackMap(simulator, track) {
	local sessionDB := SessionDatabase()
	local trackMap := sessionDB.getTrackMap(simulator, track)
	local fileName := createTrackImage(trackMap)

	sessionDB.updateTrackMap(simulator, track, trackMap, fileName)
}

recreateTrackMaps() {
	local sessionDB := SessionDatabase()
	local directory := sessionDB.DatabasePath
	local code, simulator, track

	loop Files, directory . "User\Tracks\*.*", "D" {
		code := A_LoopFileName

		simulator := sessionDB.getSimulatorName(code)

		loop Files, directory . "User\Tracks\" . code . "\*.map", "F" {
			SplitPath(A_LoopFileName, , , , &track)

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

	TraySetIcon(icon, "1")
	A_IconTip := "Track Mapper"

	index := 1

	while (index < A_Args.Length) {
		switch A_Args[index], false {
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

	ExitApp(0)
}

;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

startTrackMapper()