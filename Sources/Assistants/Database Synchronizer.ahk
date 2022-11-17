;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Database Synchronizer           ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

;@SC-IF %configuration% == Development
#Include ..\Includes\Development.ahk
;@SC-EndIF

;@SC-If %configuration% == Production
;@SC #Include ..\Includes\Production.ahk
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Database Update.ico
;@Ahk2Exe-ExeName Database Synchronizer.exe

#MaxMem 1024


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\FTP.ahk
#Include ..\Libraries\Task.ahk
#Include ..\Assistants\Libraries\SessionDatabase.ahk
#Include ..\Assistants\Libraries\TelemetryDatabase.ahk
#Include ..\Assistants\Libraries\TyresDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

uploadSessionDatabase(id, uploadPressures, uploadSetups, uploadStrategies) {
	local sessionDB := new SessionDatabase()
	local sessionDBPath := sessionDB.DatabasePath
	local uploadTimeStamp := sessionDBPath . "UPLOAD"
	local targetDB := new TyresDatabase()
	local upload, now, simulator, car, track, distFile, configuration
	local directory, sourceDB, targetDB, ignore, type, row, compound, compoundColor

	if FileExist(uploadTimeStamp) {
		FileReadLine upload, %uploadTimeStamp%, 1

		now := A_Now

		EnvSub now, %upload%, days

		if (now <= 7)
			return
	}

	targetDB.DatabaseDirectory := (kTempDirectory . "Shared Database\")

	try {
		configuration := newConfiguration()

		setConfigurationValue(configuration, "Database Synchronizer", "UserID", sessionDB.ID)
		setConfigurationValue(configuration, "Database Synchronizer", "DatabaseID", sessionDB.DatabaseID)

		setConfigurationValue(configuration, "Database Synchronizer", "State", "Active")

		setConfigurationValue(configuration, "Database Synchronizer", "Information"
							, translate("Message: ") . translate("Uploading community database..."))

		setConfigurationValue(configuration, "Database Synchronizer", "Synchronization", "Uploading")

		writeConfiguration(kTempDirectory . "Database Synchronizer.state", configuration)

		deleteDirectory(kTempDirectory . "Shared Database")

		loop Files, %sessionDBPath%User\*.*, D									; Simulator
		{
			simulator := A_LoopFileName

			if ((simulator = "1") || (simulator = "Unknown")) {
				directory = %sessionDBPath%User\%simulator%

				deleteDirectory(directory)
			}
			else {
				FileCreateDir %kTempDirectory%Shared Database\Community\%simulator%

				loop Files, %sessionDBPath%User\%simulator%\*.*, D					; Car
				{
					car := A_LoopFileName

					if ((car = "1") || (car = "Unknown")) {
						directory = %sessionDBPath%User\%simulator%\%car%

						deleteDirectory(directory)
					}
					else {
						FileCreateDir %kTempDirectory%Shared Database\Community\%simulator%\%car%

						loop Files, %sessionDBPath%User\%simulator%\%car%\*.*, D			; Track
						{
							track := A_LoopFileName

							if ((track = "1") || (track = "Unknown")) {
								directory = %sessionDBPath%User\%simulator%\%car%\%track%

								deleteDirectory(directory)
							}
							else {
								FileCreateDir %kTempDirectory%Shared Database\Community\%simulator%\%car%\%track%

								if uploadPressures {
									directory := (sessionDBPath . "User\" . simulator . "\" . car . "\" . track . "\")

									if FileExist(directory . "Tyres.Pressures.Distribution.CSV") {
										sourceDB := new Database(directory, kTyresSchemas)

										for ignore, row in sourceDB.query("Tyres.Pressures.Distribution", {Where: {Driver: sessionDB.ID} }) {
											compound := row.Compound
											compoundColor := row["Compound.Color"]

											if ((compound = kNull) || !compound || (StrLen(compound) = 0))
												compound := "Dry"

											if ((compoundColor = kNull) || !compoundColor || (StrLen(compoundColor) = 0))
												compoundColor := "Black"

											targetDB.updatePressure(simulator, car, track, row.Weather
																  , row["Temperature.Air"], row["Temperature.Track"]
																  , compound, compoundColor, row.Type, row.Tyre
																  , row.Pressure, row.Count, false, true, "Community", kNull)

											Sleep 1
										}

										targetDB.flush()
									}
								}

								if uploadSetups {
									try {
										directory = %sessionDBPath%User\%simulator%\%car%\%track%\Car Setups

										if FileExist(directory)
											FileCopyDir %directory%, %kTempDirectory%Shared Database\Community\%simulator%\%car%\%track%\Car Setups

											directory = %kTempDirectory%Shared Database\Community\%simulator%\%car%\%track%\Car Setups\

											for ignore, type in kSetupTypes
												loop Files, %directory%%type%\*.info, F
												{
													SplitPath A_LoopFileName, , , , name

													info := sessionDB.readSetupInfo(simulator, car, track, name)

													if ((getConfigurationValue(info, "Origin", "Driver", false) != sessionDB.ID)
													 || !getConfigurationValue(info, "Access", "Share", false))
														deleteFile(directory . getConfigurationValue(info, "Setup", "Name"))

													deleteFile(A_LoopFilePath)

													Sleep 1
												}
									}
									catch exception {
										logError(exception)
									}
								}

								if uploadStrategies {
									try {
										directory = %sessionDBPath%User\%simulator%\%car%\%track%\Race Strategies

										if FileExist(directory)
											FileCopyDir %directory%, %kTempDirectory%Shared Database\Community\%simulator%\%car%\%track%\Race Strategies

											directory = %kTempDirectory%Shared Database\Community\%simulator%\%car%\%track%\Race Strategies\

											loop Files, %directory%*.info, F
											{
												SplitPath A_LoopFileName, , , , name

												info := sessionDB.readStrategyInfo(simulator, car, track, name)

												if ((getConfigurationValue(info, "Origin", "Driver", false) != sessionDB.ID)
												 || !getConfigurationValue(info, "Access", "Share", false))
													deleteFile(directory . getConfigurationValue(info, "Strategy", "Name"))

												deleteFile(A_LoopFilePath)

												Sleep 1
											}
									}
									catch exception {
										logError(exception)
									}
								}
							}
						}
					}
				}
			}
		}

		RunWait PowerShell.exe -Command Compress-Archive -LiteralPath '%kTempDirectory%Shared Database\Community' -CompressionLevel Optimal -DestinationPath '%kTempDirectory%Shared Database\Database.%id%.zip', , Hide

		ftpUpload("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", kTempDirectory . "Shared Database\Database." . id . ".zip", "simulator-controller/database-uploads/Database." . id . ".zip")

		deleteDirectory(kTempDirectory . "Shared Database")
		deleteFile(sessionDBPath . "UPLOAD")

		FileAppend %A_Now%, %sessionDBPath%UPLOAD

		setConfigurationValue(configuration, "Database Synchronizer", "Information"
							, translate("Message: ") . translate("Synchronization finished..."))

		setConfigurationValue(configuration, "Database Synchronizer", "Synchronization", "Finished")

		writeConfiguration(kTempDirectory . "Database Synchronizer.state", configuration)

		logMessage(kLogInfo, translate("Database successfully uploaded"))
	}
	catch exception {
		logMessage(kLogCritical, translate("Error while uploading database - please check your internet connection..."))
	}
}

downloadSessionDatabase(id, downloadPressures, downloadSetups, downloadStrategies) {
	local sessionDB := new SessionDatabase()
	local sessionDBPath := sessionDB.DatabasePath
	local downloadTimeStamp := sessionDBPath . "DOWNLOAD"
	local download, now, ignore, fileName, type, databaseDirectory, configuration

	if FileExist(downloadTimeStamp) {
		FileReadLine download, %downloadTimeStamp%, 1

		now := A_Now

		EnvSub now, %download%, days

		if (now <= 2)
			return
	}

	try {
		try {
			FileRemoveDir %kTempDirectory%Shared Database, 1
		}
		catch exception {
			logError(exception)
		}

		configuration := newConfiguration()

		setConfigurationValue(configuration, "Database Synchronizer", "UserID", sessionDB.ID)
		setConfigurationValue(configuration, "Database Synchronizer", "DatabaseID", sessionDB.DatabaseID)

		setConfigurationValue(configuration, "Database Synchronizer", "State", "Active")

		setConfigurationValue(configuration, "Database Synchronizer", "Information"
							, translate("Message: ") . translate("Downloading community database..."))

		setConfigurationValue(configuration, "Database Synchronizer", "Synchronization", "Downloading")

		writeConfiguration(kTempDirectory . "Database Synchronizer.state", configuration)

		sessionDB := new SessionDatabase()

		for ignore, fileName in ftpListFiles("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", "simulator-controller/database-downloads") {
			SplitPath fileName, , , , databaseDirectory

			type := StrSplit(Trim(fileName), ".", "", 2)[1]

			if ((type = (downloadPressures . downloadSetups . downloadStrategies)) || (type = (downloadPressures . downloadSetups))) {
				if (sessionDB.DatabaseVersion != databaseDirectory) {
					ftpDownload("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", "simulator-controller/database-downloads/" . fileName, kTempDirectory . fileName)

					RunWait PowerShell.exe -Command Expand-Archive -LiteralPath '%kTempDirectory%%fileName%' -DestinationPath '%kTempDirectory%Shared Database', , Hide

					deleteFile(kTempDirectory . fileName)
					deleteDirectory(sessionDBPath . "Community")

					if FileExist(kTempDirectory . "Shared Database\" . databaseDirectory . "\Community")
						FileMoveDir %kTempDirectory%Shared Database\%databaseDirectory%\Community, %sessionDBPath%Community, R
					else if FileExist(kTempDirectory . "Shared Database\Community")
						FileMoveDir %kTempDirectory%Shared Database\Community, %sessionDBPath%Community, R

					sessionDB.DatabaseVersion := databaseDirectory
				}
			}
		}

		deleteDirectory(kTempDirectory . "Shared Database")
		deleteFile(sessionDBPath . "DOWNLOAD")

		FileAppend %A_Now%, %sessionDBPath%DOWNLOAD

		setConfigurationValue(configuration, "Database Synchronizer", "State", "Active")

		setConfigurationValue(configuration, "Database Synchronizer", "Information"
							, translate("Message: ") . translate("Synchronization finished..."))

		setConfigurationValue(configuration, "Database Synchronizer", "Synchronization", "Finished")

		writeConfiguration(kTempDirectory . "Database Synchronizer.state", configuration)

		logMessage(kLogInfo, translate("Database successfully downloaded"))
	}
	catch exception {
		logMessage(kLogCritical, translate("Error while downloading database - please check your internet connection..."))
	}
}

synchronizeCommunityDatabase(id, usePressures, useSetups, useStrategies) {
	synchronizeDatabase("Stop")

	try {
		uploadSessionDatabase(id, usePressures, useSetups, useStrategies)
		downloadSessionDatabase(id, usePressures, useSetups, useStrategies)
	}
	finally {
		synchronizeDatabase("Start")
	}

	Task.CurrentTask.Sleep := (24 * 60 * 60 * 1000)

	return Task.CurrentTask
}

synchronizeSessionDatabase(minutes) {
	try {
		synchronizeDatabase()
	}
	catch exception {
		logError(exception)
	}

	Task.CurrentTask.Sleep := (minutes * 60000)

	return Task.CurrentTask
}

updateSessionDatabase() {
	local icon := kIconsDirectory . "Database Update.ico"
	local usePressures, useSetups, useStrategies, id, minutes, configuration

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Database Synchronizer

	usePressures := (inList(A_Args, "-Pressures") != 0)
	useSetups := (inList(A_Args, "-Setups") != 0)
	useStrategies := (inList(A_Args, "-Strategies") != 0)

	id := inList(A_Args, "-ID")

	if id {
		id := A_Args[id + 1]

		new PeriodicTask(Func("synchronizeCommunityDatabase").Bind(id, usePressures, useSetups, useStrategies), 10000, kLowPriority).start()
	}

	minutes := inList(A_Args, "-Synchronize")

	if minutes {
		minutes := A_Args[minutes + 1]

		if (minutes && (minutes != kFalse)) {
			if ((minutes == true) || (minutes = kTrue)) {
				configuration := readConfiguration(kUserConfigDirectory . "Session Database.ini")

				minutes := getConfigurationValue(configuration, "Team Server", "Replication", 30)
			}

			Task.startTask(Func("synchronizeSessionDatabase").Bind(minutes), 1000, kLowPriority)
		}
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

updateSessionDatabase()