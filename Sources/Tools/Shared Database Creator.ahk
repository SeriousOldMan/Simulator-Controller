﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Shared Database Creator         ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#Requires AutoHotkey >=v2.0
#SingleInstance Force			; Ony one instance allowed
#Warn							; Enable warnings to assist with detecting common errors.
#Warn LocalSameAsGlobal, Off

SendMode("Input")					; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir)			; Ensures a consistent starting directory.

ListLines(false)					; Disable execution history

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Tools.ico
;@Ahk2Exe-ExeName Shared Database Creator.exe
;@Ahk2Exe-SetCompanyName Oliver Juwig (TheBigO)
;@Ahk2Exe-SetCopyright TheBigO - Creative Commons - BY-NC-SA
;@Ahk2Exe-SetProductName Simulator Controller
;@Ahk2Exe-SetVersion 0.0.0.0

global kBuildConfiguration := "Development"


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Application.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Extensions\FTP.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"
#Include "..\Database\Libraries\TyresDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variables Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global vProgressCount := 0


;;;-------------------------------------------------------------------------;;;
;;;                         Private Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class DatabaseCreator {
	iSourceDirectory := false
	iTargetDirectory := false

	iIncludePressures := false
	iIncludeStrategies := false
	iIncludeTelemetries := false
	iIncludeSetups := false

	iTyresDatabase := false

	SourceDirectory {
		Get {
			return this.iSourceDirectory
		}
	}

	TargetDirectory {
		Get {
			return this.iTargetDirectory
		}
	}

	IncludePressures {
		Get {
			return this.iIncludePressures
		}
	}

	IncludeTelemetries {
		Get {
			return this.iIncludeTelemetries
		}
	}

	IncludeStrategies {
		Get {
			return this.iIncludeStrategies
		}
	}

	IncludeSetups {
		Get {
			return this.iIncludeSetups
		}
	}

	TyresDatabase {
		Get {
			return this.iTyresDatabase
		}
	}

	__New(sourceDirectory, targetDirectory, includePressures, includeSetups, includeStrategies, includeTelemetries) {
		this.iSourceDirectory := sourceDirectory
		this.iTargetDirectory := targetDirectory
		this.iIncludePressures := includePressures
		this.iIncludeSetups := includeSetups
		this.iIncludeStrategies := includeStrategies
		this.iIncludeTelemetries := includeTelemetries
	}

	createDatabase() {
		local database

		sourceDirectory := this.SourceDirectory

		database := TyresDatabase()

		database.DatabaseDirectory := this.TargetDirectory
		database.Shared := false

		this.iTyresDatabase := database

		loop Files, sourceDirectory . "*.*", "D"
			this.loadDatabase(A_LoopFilePath . "\")
	}

	loadDatabase(databaseDirectory) {
		loop Files, databaseDirectory . "*.*", "D" {
			simulator := A_LoopFileName

			if ((simulator = "1") || (simulator = "0") || (simulator = "Unknown"))
				deleteDirectory(databaseDirectory . simulator)
			else
				loop Files, databaseDirectory . simulator . "\*.*", "D" {
					car := A_LoopFileName

					if ((car = "1") || (car = "0") || (car = "Unknown"))
						deleteDirectory(databaseDirectory . simulator . "\" . car)
					else
						loop Files, databaseDirectory . simulator . "\" . car . "\*.*", "D" {
							track := A_LoopFileName

							if ((track = "1") || (track = "0") || (track = "Unknown"))
								deleteDirectory(databaseDirectory . simulator . "\" . car . "\" . track)
							else {
								directory := databaseDirectory . simulator . "\" . car . "\" . track . "\"

								if FileExist(directory . "Setup.Pressures.Distribution.CSV")
									FileMove(directory . "Setup.Pressures.Distribution.CSV", directory . "Tyres.Pressures.Distribution.CSV")

								if FileExist(directory . "Tyres.Pressures.Distribution.CSV")
									this.loadPressures(simulator, car, track, Database(directory, kTyresSchemas))

								loop Files, databaseDirectory . simulator . "\" . car . "\" . track . "\Lap Telemetries\*.telemetry"
									this.loadLapTelemetry(simulator, car, track, A_LoopFilePath)

								loop Files, databaseDirectory . simulator . "\" . car . "\" . track . "\Race Strategies\*.strategy"
									this.loadRaceStrategy(simulator, car, track, A_LoopFilePath)

								loop Files, databaseDirectory . simulator . "\" . car . "\" . track . "\Car Setups\*.*", "D" {
									type := A_LoopFileName

									loop Files, databaseDirectory . simulator . "\" . car . "\Car Setups\" . type . "\*.*" {
										SplitPath(A_LoopFilePath, , , &extension)

										if (extension != "info")
											this.loadCarSetup(simulator, car, track, type, A_LoopFilePath)
									}
								}
							}
						}
				}
		}
	}

	loadPressures(simulator, car, track, database) {
		if this.IncludePressures {
			updateProgress("Pressures: " simulator . A_Space . car . A_Space . track . "...")

			for ignore, row in database.Tables["Tyres.Pressures.Distribution"] {
				compound := row["Compound"]
				color := row["Compound.Color"]

				if ((compound = kNull) || !compound || (StrLen(compound) = 0))
					compound := "Dry"

				if ((color = kNull) || !color || (StrLen(color) = 0))
					color := "Black"

				this.TyresDatabase.updatePressure(simulator, car, track, row["Weather"]
												, row["Temperature.Air"], row["Temperature.Track"]
												, compound, color, row["Type"], row["Tyre"]
												, row["Pressure"], row["Count"], false, true, "Community", kNull)
			}

			this.TyresDatabase.flush()
		}
	}

	loadLapTelemetry(simulator, car, track, telemetryFile) {
		local directory := this.TargetDirectory

		if this.IncludeTelemetries {
			updateProgress("Telemetries: " . simulator . " / " . car . " / " . track . "...")

			DirCreate(directory . "Community\" . simulator . "\" . car . "\" . track . "\Lap Telemetries")

			FileCopy(telemetryFile, directory . "Community\" . simulator . "\" . car . "\" . track . "\Lap Telemetries", 1)

			if FileExist(telemetryFile . ".info") {
				info := readMultiMap(telemetryFile . ".info")
				newInfo := newMultiMap()

				setMultiMapValue(newInfo, "Info", "Driver", "John Doe")

				if getMultiMapValue(info, "Lap", "LapTime", false)
					setMultiMapValue(newInfo, "Info", "LapTime", getMultiMapValue(info, "Lap", "LapTime"))

				if getMultiMapValue(info, "Lap", "SectorTimes", false)
					setMultiMapValue(newInfo, "Info", "SectorTimes", getMultiMapValue(info, "Lap", "SectorTimes"))

				SplitPath(telemetryFile, &telemetryFile)

				writeMultiMap(directory . "Community\" . simulator . "\" . car . "\" . track . "\Lap Telemetries\" . telemetryFile . ".info"
							, newInfo)
			}
		}
	}

	loadRaceStrategy(simulator, car, track, strategyFile) {
		local directory := this.TargetDirectory

		if this.IncludeStrategies {
			updateProgress("Strategies: " . simulator . " / " . car . " / " . track . "...")

			DirCreate(directory . "Community\" . simulator . "\" . car . "\" . track . "\Race Strategies")

			FileCopy(strategyFile, directory . "Community\" . simulator . "\" . car . "\" . track . "\Race Strategies", 1)
		}
	}

	loadCarSetup(simulator, car, track, type, setupFile) {
		local directory := this.TargetDirectory

		if this.IncludeSetups {
			updateProgress("Setups: " . simulator . " / " . car . " / " . track . "...")

			DirCreate(directory . "Community\" . simulator . "\" . car . "\" . track . "\Car Setups\" . type)

			FileCopy(setupFile, directory . "Community\" . simulator . "\" . car . "\" . track . "\Car Setups\" . type, 1)
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

updateProgress(message) {
	global vProgressCount

	vProgressCount += 5

	if (vProgressCount > 100)
		vProgressCount := 0

	showProgress({progress: vProgressCount, message: message})
}

windowsPath(path) {
	if (SubStr(path, StrLen(path), 1) = "\")
		return SubStr(path, 1, StrLen(path) - 1)
	else
		return path
}

downloadUserDatabases(directory) {
	local MASTER := StrSplit(FileRead(kConfigDirectory . "MASTER"), "`n", "`r")[1]
	local wDirectory := windowsPath(directory)

	renameDirectory(directory, newName) {
		loop 5 {
			try {
				DirMove(directory, newName, "R")

				break
			}
			catch Any {
				Sleep(100)
			}
		}
	}

	for ignore, fileName in ftpListFiles(MASTER, "SimulatorController", "Sc-1234567890-Sc", "Database-Uploads") { ; ftpListFiles("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", "htdocs/simulator-controller/database-uploads") {
		SplitPath(fileName, , , , &idName)

		idName := StrReplace(idName, "Database.", "")

		updateProgress("Downloading " . idName . "...")

		; ftpDownload("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", "htdocs/simulator-controller/database-uploads/" . fileName, directory . fileName)

		ftpDownload(MASTER, "SimulatorController", "Sc-1234567890-Sc", "Database-Uploads/" . fileName, directory . fileName)

		updateProgress("Extracting " . idName . "...")

		RunWait("PowerShell.exe -Command Expand-Archive -LiteralPath '" . directory . fileName . "' -DestinationPath '" . wDirectory . "' -Force", , "Hide")

		deleteFile(directory . fileName)

		if FileExist(directory . "Shared Database Creator")
			renameDirectory(directory . "Shared Database Creator", directory . idName)
		else if FileExist(directory . "Shared Database")
			renameDirectory(directory . "Shared Database", directory . idName)
		else if FileExist(directory . "Community")
			renameDirectory(directory . "Community", directory . idName)
		else if FileExist(directory . "DBase")
			renameDirectory(directory . "DBase", directory . idName)
		else if FileExist(directory . "Dabase")
			renameDirectory(directory . "Dabase", directory . idName)
		else if FileExist(directory . "SetupDabase")
			renameDirectory(directory . "SetupDabase", directory . idName)
	}
}

createDatabases(inputDirectory, outputDirectory) {
	local database

	archives := []

	version1 := Random(1, 1000)
	version2 := Random(1, 1000)

	updateProgress("Processing [Pressures]...")

	DatabaseCreator(inputDirectory, outputDirectory . "Pressures\", true, false, false, false).createDatabase()

	updateProgress("Processing [Setups]...")

	DatabaseCreator(inputDirectory, outputDirectory . "Setups\", false, true, false, false).createDatabase()

	updateProgress("Processing [Strategies]...")

	DatabaseCreator(inputDirectory, outputDirectory . "Strategies\", false, false, true, false).createDatabase()

	updateProgress("Processing [Telemetries]...")

	DatabaseCreator(inputDirectory, outputDirectory . "Telemetries\", false, false, false, true).createDatabase()

	for strategiesLabel, strategiesEnabled in Map("Strategies", true, "No Strategies", false)
		for setupsLabel, setupsEnabled in Map("Setups", true, "No Setups", false)
			for pressuresLabel, pressuresEnabled in Map("Pressures", true, "No Pressures", false)
				for telemetriesLabel, telemetriesEnabled in Map("Telemetries", true, "No Telemetries", false)
					if (pressuresEnabled || setupsEnabled || strategiesEnabled || telemetriesEnabled) {
						updateProgress("Assembling [" . strategiesLabel . " | " . setupsLabel . " | " . pressuresLabel . " | " . telemetriesLabel . "]...")

						type := (pressuresEnabled . setupsEnabled . strategiesEnabled . telemetriesEnabled)

						database := (outputDirectory . type . "." . version1 . "." . version2)

						if pressuresEnabled
							if FileExist(outputDirectory . pressuresLabel)
								DirCopy(outputDirectory . pressuresLabel, database, 1)

						if setupsEnabled
							if FileExist(outputDirectory . setupsLabel)
								DirCopy(outputDirectory . setupsLabel, database, 1)

						if strategiesEnabled
							if FileExist(outputDirectory . strategiesLabel)
								DirCopy(outputDirectory . strategiesLabel, database, 1)

						if telemetriesEnabled
							if FileExist(outputDirectory . telemetriesLabel)
								DirCopy(outputDirectory . telemetriesLabel, database, 1)

						RunWait("PowerShell.exe -Command Compress-Archive -LiteralPath '" . database . "\Community' -CompressionLevel Optimal -DestinationPath '" . database . ".zip'", , "Hide")

						if FileExist(database . ".zip")
							archives.Push(database . ".zip")
					}

	for strategiesLabel, strategiesEnabled in Map("Strategies", true, "No Strategies", false)
		for setupsLabel, setupsEnabled in Map("Setups", true, "No Setups", false)
			for pressuresLabel, pressuresEnabled in Map("Pressures", true, "No Pressures", false)
				if (pressuresEnabled || setupsEnabled || strategiesEnabled) {
					updateProgress("Assembling [" . strategiesLabel . " | " . setupsLabel . " | " . pressuresLabel . "]...")

					type := (pressuresEnabled . setupsEnabled . strategiesEnabled)

					database := (outputDirectory . type . "." . version1 . "." . version2)

					if pressuresEnabled
						if FileExist(outputDirectory . pressuresLabel)
							DirCopy(outputDirectory . pressuresLabel, database, 1)

					if setupsEnabled
						if FileExist(outputDirectory . setupsLabel)
							DirCopy(outputDirectory . setupsLabel, database, 1)

					if strategiesEnabled
						if FileExist(outputDirectory . strategiesLabel)
							DirCopy(outputDirectory . strategiesLabel, database, 1)

					RunWait("PowerShell.exe -Command Compress-Archive -LiteralPath '" . database . "\Community' -CompressionLevel Optimal -DestinationPath '" . database . ".zip'", , "Hide")

					if FileExist(database . ".zip")
						archives.Push(database . ".zip")
				}

	for setupsLabel, setupsEnabled in Map("Setups", true, "No Setups", false)
		for pressuresLabel, pressuresEnabled in Map("Pressures", true, "No Pressures", false)
			if (pressuresEnabled || setupsEnabled) {
				updateProgress("Assembling [" . setupsLabel . " | " . pressuresLabel . "]...")

				type := (pressuresEnabled . setupsEnabled)

				database := (outputDirectory . type . "." . version1 . "." . version2)

				if pressuresEnabled
					if FileExist(outputDirectory . setupsLabel)
						DirCopy(outputDirectory . setupsLabel, database, 1)

				if setupsEnabled
					if FileExist(outputDirectory . setupsLabel)
						DirCopy(outputDirectory . setupsLabel, database, 1)

				RunWait("PowerShell.exe -Command Compress-Archive -LiteralPath '" . database . "\Community' -CompressionLevel Optimal -DestinationPath '" . database . ".zip'", , "Hide")

				if FileExist(database . ".zip")
					archives.Push(database . ".zip")
			}

	return archives
}

createSharedDatabases() {
	global vProgressCount

	local MASTER := StrSplit(FileRead(kConfigDirectory . "MASTER"), "`n", "`r")[1]
	local command, ignore, file

	vProgressCount := 0

	showProgress({color: "Blue", title: "Creating Shared Database", message: "Cleaning temporary database...", width: 400})

	Sleep(500)

	databaseDirectory := (kTempDirectory . "Shared Database Creator")

	deleteDirectory(databaseDirectory)

	DirCreate(databaseDirectory . "\Input")
	DirCreate(databaseDirectory . "\Output")

	showProgress({progress: (vProgressCount := vProgressCount + 2), title: "Downloading Community Content", message: "..."})

	downloadUserDatabases(databaseDirectory . "\Input\")

	showProgress({progress: (vProgressCount := vProgressCount + 2), color: "Green", title: "Processing Community Content", message: "..."})

	archives := createDatabases(databaseDirectory . "\Input\", databaseDirectory . "\Output\")

	showProgress({progress: (vProgressCount := vProgressCount + 2), color: "Green", title: "Uploading Community Content", message: "Cleaning remote repository..."})

	if false {
		ftpClearDirectory("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", "htdocs/simulator-controller/database-downloads")
		ftpRemoveDirectory("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", "htdocs/simulator-controller", "database-downloads")
		ftpCreateDirectory("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", "htdocs/simulator-controller", "database-downloads")
	}
	else {
		ftpClearDirectory(MASTER, "SimulatorController", "Sc-1234567890-Sc", "Database-Downloads")
		ftpRemoveDirectory(MASTER, "SimulatorController", "Sc-1234567890-Sc", ".", "Database-Downloads")
		ftpCreateDirectory(MASTER, "SimulatorController", "Sc-1234567890-Sc", ".", "Database-Downloads")
	}

	for ignore, file in ftpListFiles(MASTER, "SimulatorController", "Sc-1234567890-Sc", "Database-Downloads") { ; ftpListFiles("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", "htdocs/simulator-controller/database-downloads") {
		deleteFile(A_Temp . "\clearRemoteDirectory.txt")

/*
		command := "
(
open ftpupload.net
epiz_32854064
d5NW1ps6jX6Lk
cd htdocs
cd simulator-controller
cd database-downloads
del %file%
quit
)"
*/

		command := "
(
open %master%
SimulatorController
Sc-1234567890-Sc
cd Database-Downloads
del %file%
quit
)"

		command := substituteVariables(command, {file: file, master: MASTER})

		FileAppend(command, A_Temp . "\clearRemoteDirectory.txt")

		deleteFile(A_Temp . "\clearRemoteDirectory.bat")

		command := "ftp -s:clearRemoteDirectory.txt"

		FileAppend(command, A_Temp . "\clearRemoteDirectory.bat")

		RunWait("`"" . A_Temp . "\clearRemoteDirectory.bat`"", A_Temp, "Hide")
	}

	deleteFile(A_Temp . "\clearRemoteDirectory.txt")
	deleteFile(A_Temp . "\clearRemoteDirectory.bat")

	for ignore, filePath in archives {
		SplitPath(filePath, &fileName)

		updateProgress("Uploading " . fileName . "...")

		; ftpUpload("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", filePath, "htdocs/simulator-controller/database-downloads/" . fileName)

		ftpUpload(MASTER, "SimulatorController", "Sc-1234567890-Sc", filePath, "Database-Downloads/" . fileName)
	}

	showProgress({progress: 100, message: "Finished..."})

	Sleep(500)

	hideProgress()

	ExitApp(0)
}


;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

createSharedDatabases()