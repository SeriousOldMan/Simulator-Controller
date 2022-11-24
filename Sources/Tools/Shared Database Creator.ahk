;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Shared Database Creator         ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Tools.ico
;@Ahk2Exe-ExeName Shared Database Creator.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\FTP.ahk
#Include ..\Assistants\Libraries\SessionDatabase.ahk
#Include ..\Assistants\Libraries\TyresDatabase.ahk


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
	iIncludeStratgies := false
	iIncludeSetups := false

	iTyresDatabase := false

	SourceDirectory[] {
		Get {
			return this.iSourceDirectory
		}
	}

	TargetDirectory[] {
		Get {
			return this.iTargetDirectory
		}
	}

	IncludePressures[] {
		Get {
			return this.iIncludePressures
		}
	}

	IncludeStrategies[] {
		Get {
			return this.iIncludeStrategies
		}
	}

	IncludeSetups[] {
		Get {
			return this.iIncludeSetups
		}
	}

	TyresDatabase[] {
		Get {
			return this.iTyresDatabase
		}
	}

	__New(sourceDirectory, targetDirectory, includePressures, includeSetups, includeStrategies) {
		this.iSourceDirectory := sourceDirectory
		this.iTargetDirectory := targetDirectory
		this.iIncludePressures := includePressures
		this.iIncludeSetups := includeSetups
		this.iIncludeStratgies := includeStrategies
	}

	createDatabase() {
		local database

		sourceDirectory := this.SourceDirectory

		database := new TyresDatabase()

		database.DatabaseDirectory := this.TargetDirectory

		this.iTyresDatabase := database

		loop Files, %sourceDirectory%*.*, D
			this.loadDatabase(A_LoopFilePath . "\")
	}

	loadDatabase(databaseDirectory) {
		loop Files, %databaseDirectory%*.*, D									; Simulator
		{
			simulator := A_LoopFileName

			if ((simulator = "1") || (simulator = "Unknown"))
				deleteDirectory(databaseDirectory . simulator)
			else
				loop Files, %databaseDirectory%%simulator%\*.*, D					; Car
				{
					car := A_LoopFileName

					if ((car = "1") || (car = "Unknown"))
						deleteDirectory(databaseDirectory . simulator . "\" . car)
					else
						loop Files, %databaseDirectory%%simulator%\%car%\*.*, D		; Track
						{
							track := A_LoopFileName

							if ((track = "1") || (track = "Unknown"))
								deleteDirectory(databaseDirectory . simulator . "\" . car . "\" . track)
							else {
								directory = %databaseDirectory%%simulator%\%car%\%track%\

								if FileExist(directory . "Setup.Pressures.Distribution.CSV")
									FileMove %directory%Setup.Pressures.Distribution.CSV, %directory%Tyres.Pressures.Distribution.CSV

								if FileExist(directory . "Tyres.Pressures.Distribution.CSV")
									this.loadPressures(simulator, car, track, new Database(directory, kTyresSchemas))

								loop Files, %databaseDirectory%%simulator%\%car%\Race Strategies\*.*
									this.loadRaceStrategy(simulator, car, track, A_LoopFilePath)

								loop Files, %databaseDirectory%%simulator%\%car%\Car Setups\*.*, D
								{
									type := A_LoopFileName

									loop Files, %databaseDirectory%%simulator%\%car%\Car Setups\%type%\*.*
										this.loadCarSetup(simulator, car, track, type, A_LoopFilePath)
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
				compound := row.Compound
				color := row["Compound.Color"]

				if ((compound = kNull) || !compound || (StrLen(compound) = 0))
					compound := "Dry"

				if ((color = kNull) || !color || (StrLen(color) = 0))
					color := "Black"

				this.TyresDatabase.updatePressure(simulator, car, track, row.Weather
												, row["Temperature.Air"], row["Temperature.Track"]
												, compound, color, row.Type, row.Tyre
												, row.Pressure, row.Count, false, true, "Community", kNull)
			}

			this.TyresDatabase.flush()
		}
	}

	loadRaceStrategy(simulator, car, track, strategyFile) {
		local directory := new SessionDatabase.DatabasePath

		if this.IncludeStrategies {
			updateProgress("Strategies: " simulator . " / " . car . " / " . track . "...")

			FileCreateDir %directory%Community\%simulator%\%car%\Race Strategies

			FileCopy %strategyFile%, %directory%Community\%simulator%\%car%\Race Strategies, 1
		}
	}

	loadCarSetup(simulator, car, track, type, setupFile) {
		local directory := new SessionDatabase.DatabasePath

		if this.IncludeSetups {
			updateProgress("Setups: " simulator . " / " . car . " / " . track . "...")

			FileCreateDir %directory%Community\%simulator%\%car%\Car Setups

			FileCopy %setupFile%, %directory%Community\%simulator%\%car%\Car Setups\%type%, 1
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

updateProgress(message) {
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
	wDirectory := windowsPath(directory)

	for ignore, fileName in ftpListFiles("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", "simulator-controller/database-uploads") {
		SplitPath fileName, , , , idName

		idName := StrReplace(idName, "Database.", "")

		updateProgress("Downloading " . idName . "...")

		ftpDownload("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", "simulator-controller/database-uploads/" . fileName, directory . fileName)

		updateProgress("Extracting " . idName . "...")

		RunWait PowerShell.exe -Command Expand-Archive -LiteralPath '%directory%%fileName%' -DestinationPath '%wDirectory%', , Hide

		deleteFile(directory . fileName)

		if FileExist(directory . "Shared Database Creator")
			FileMoveDir %directory%Shared Database Creator, %directory%%idName%, R
		else if FileExist(directory . "Shared Database")
			FileMoveDir %directory%Shared Database, %directory%%idName%, R
		else if FileExist(directory . "Community")
			FileMoveDir %directory%Community, %directory%%idName%, R
		else if FileExist(directory . "DBase")
			FileMoveDir %directory%DBase, %directory%%idName%, R
		else if FileExist(directory . "Dabase")
			FileMoveDir %directory%Dabase, %directory%%idName%, R
		else if FileExist(directory . "SetupDabase")
			FileMoveDir %directory%SetupDabase, %directory%%idName%, R
	}
}

createDatabases(inputDirectory, outputDirectory) {
	local database

	archives := []

	Random version1, 1, 1000
	Random version2, 1, 1000

	for strategiesLabel, strategiesEnabled in {Strategies: true, "No Strategies": false}
		for setupsLabel, setupsEnabled in {Setups: true, "No Setups": false}
			for pressuresLabel, pressuresEnabled in {Pressures: true, "No Pressures": false}
				if (pressuresEnabled || setupsEnabled || strategiesEnabled) {
					updateProgress("Processing [" . strategiesLabel . " | " . setupsLabel . " | " . pressuresLabel . "]...")

					type := (pressuresEnabled . setupsEnabled . strategiesEnabled)

					database := (outputDirectory . type . "." . version1 . "." . version2)

					new DatabaseCreator(inputDirectory, database . "\", pressuresEnabled, setupsEnabled, strategiesEnabled).createDatabase()

					RunWait PowerShell.exe -Command Compress-Archive -LiteralPath '%database%\Community' -CompressionLevel Optimal -DestinationPath '%database%.zip', , Hide

					if FileExist(database ".zip")
						archives.Push(database ".zip")
				}

	for setupsLabel, setupsEnabled in {Setups: true, "No Setups": false}
		for pressuresLabel, pressuresEnabled in {Pressures: true, "No Pressures": false}
			if (pressuresEnabled || setupsEnabled) {
				updateProgress("Processing [" . setupsLabel . " | " . pressuresLabel . "]...")

				type := (pressuresEnabled . setupsEnabled)

				database := (outputDirectory . type . "." . version1 . "." . version2)

				new DatabaseCreator(inputDirectory, database . "\", pressuresEnabled, setupsEnabled, false).createDatabase()

				RunWait PowerShell.exe -Command Compress-Archive -LiteralPath '%database%\Community' -CompressionLevel Optimal -DestinationPath '%database%.zip', , Hide

				if FileExist(database ".zip")
					archives.Push(database ".zip")
			}

	return archives
}

createSharedDatabases() {
	local command, ignore, file

	vProgressCount := 0

	showProgress({color: "Blue", title: "Creating Shared Database", message: "Cleaning temporary database..."})

	Sleep 500

	databaseDirectory := (kTempDirectory . "Shared Database Creator")

	deleteDirectory(databaseDirectory)

	FileCreateDir %databaseDirectory%\Input
	FileCreateDir %databaseDirectory%\Output

	showProgress({progress: (vProgressCount := vProgressCount + 2), title: "Downloading Community Content", message: "..."})

	downloadUserDatabases(databaseDirectory . "\Input\")

	showProgress({progress: (vProgressCount := vProgressCount + 2), color: "Green", title: "Processing Community Content", message: "..."})

	archives := createDatabases(databaseDirectory . "\Input\", databaseDirectory . "\Output\")

	showProgress({progress: (vProgressCount := vProgressCount + 2), color: "Green", title: "Uploading Community Content", message: "Cleaning remote repository..."})

	ftpClearDirectory("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", "simulator-controller/database-downloads")
	ftpRemoveDirectory("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", "simulator-controller", "database-downloads")
	ftpCreateDirectory("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", "simulator-controller", "database-downloads")

	for ignore, file in ftpListFiles("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", "simulator-controller/database-downloads") {
		deleteFile(A_Temp . "\clearRemoteDirectory.txt")

		command =
(
open ftpupload.net
epiz_32854064
d5NW1ps6jX6Lk
cd simulator-controller
cd database-downloads
del %file%
quit
)
		FileAppend %command%, %A_Temp%\clearRemoteDirectory.txt

		deleteFile(A_Temp . "\clearRemoteDirectory.bat")

		command := "ftp -s:clearRemoteDirectory.txt"

		FileAppend %command%, %A_Temp%\clearRemoteDirectory.bat

		RunWait "%A_Temp%\clearRemoteDirectory.bat", %A_Temp%, Hide
	}

	deleteFile(A_Temp . "\clearRemoteDirectory.txt")
	deleteFile(A_Temp . "\clearRemoteDirectory.bat")

	for ignore, filePath in archives {
		SplitPath filePath, fileName

		updateProgress("Uploading " . fileName . "...")

		ftpUpload("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", filePath, "simulator-controller/database-downloads/" . fileName)
	}

	showProgress({progress: 100, message: "Finished..."})

	Sleep 500

	hideProgress()

	ExitApp 0
}


;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

createSharedDatabases()