﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Database Synchronizer           ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

;@SC-IF %configuration% == Development
#Include "..\Framework\Development.ahk"
;@SC-EndIF

;@SC-If %configuration% == Production
;@SC #Include "..\Framework\Production.ahk"
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Database Update.ico
;@Ahk2Exe-ExeName Database Synchronizer.exe
;@Ahk2Exe-SetCompanyName Oliver Juwig (TheBigO)
;@Ahk2Exe-SetCopyright TheBigO - Creative Commons - BY-NC-SA
;@Ahk2Exe-SetProductName Simulator Controller
;@Ahk2Exe-SetVersion 0.0.0.0


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Process.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Extensions\FTP.ahk"
#Include "..\Framework\Extensions\Task.ahk"
#Include "Libraries\SessionDatabase.ahk"
#Include "Libraries\LapsDatabase.ahk"
#Include "Libraries\TyresDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                   Private Variables Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

global gSynchronizing := false


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

uploadSessionDatabase(id, uploadPressures, uploadSetups, uploadStrategies, uploadTelemetries) {
	local MASTER := StrSplit(FileRead(kConfigDirectory . "MASTER"), "`n", "`r")[1]
	local sessionDB := SessionDatabase()
	local sessionDBPath := sessionDB.DatabasePath
	local uploadTimeStamp := sessionDBPath . "UPLOAD"
	local targetDB := TyresDatabase()
	local configuration := newMultiMap()
	local step := 20
	local simulator, car, track, distFile
	local directory, sourceDB, targetDB, ignore, type, row, compound, compoundColor
	local name, extension, files

	updateState() {
		if (++step > 20) {
			step := 0

			writeMultiMap(kTempDirectory . "Database Synchronizer.state", configuration)
		}
	}

	setMultiMapValue(configuration, "Database Synchronizer", "UserID", sessionDB.ID)
	setMultiMapValue(configuration, "Database Synchronizer", "DatabaseID", sessionDB.DatabaseID)

	setMultiMapValue(configuration, "Database Synchronizer", "State", "Active")

	setMultiMapValue(configuration, "Database Synchronizer", "Information"
				   , translate("Message: ") . translate("Uploading community database..."))

	setMultiMapValue(configuration, "Database Synchronizer", "Synchronization", "Uploading")

	if FileExist(uploadTimeStamp)
		if (DateDiff(A_Now, StrSplit(FileRead(uploadTimeStamp), "`n", "`r")[1], "days") <= 7)
			return

	targetDB.DatabaseDirectory := (kTempDirectory . "Shared Database\")
	targetDB.Shared := false

	try {
		updateState()

		deleteDirectory(kTempDirectory . "Shared Database")

		loop Files, sessionDBPath . "User\*.*", "D" {
			simulator := A_LoopFileName

			if ((simulator = "1") || (simulator = "0") || (simulator = "Unknown"))
				deleteDirectory(sessionDBPath . "User\" . simulator)
			else {
				DirCreate(kTempDirectory . "Shared Database\Community\" simulator)

				loop Files, sessionDBPath . "User\" . simulator . "\*.*", "D" {
					car := A_LoopFileName

					if ((car = "1") || (car = "0") || (car = "Unknown"))
						deleteDirectory(sessionDBPath . "User\" . simulator . "\" . car)
					else {
						DirCreate(kTempDirectory . "Shared Database\Community\" . simulator . "\" . car)

						loop Files, sessionDBPath . "User\" . simulator . "\" . car . "\*.*", "D" {
							track := A_LoopFileName

							updateState()

							if ((track = "1") || (track = "0") || (track = "Unknown"))
								deleteDirectory(sessionDBPath . "User\" . simulator . "\" . car . "\" . track)
							else {
								DirCreate(kTempDirectory . "Shared Database\Community\" . simulator . "\" . car . "\" . track)

								if uploadPressures {
									directory := (sessionDBPath . "User\" . simulator . "\" . car . "\" . track . "\")

									if FileExist(directory . "Tyres.Pressures.Distribution.CSV") {
										sourceDB := Database(directory, kTyresSchemas)

										for ignore, row in sourceDB.query("Tyres.Pressures.Distribution", {Where: {Driver: sessionDB.ID} }) {
											updateState()

											compound := row["Compound"]
											compoundColor := row["Compound.Color"]

											if ((compound = kNull) || !compound || (StrLen(compound) = 0))
												compound := "Dry"

											if ((compoundColor = kNull) || !compoundColor || (StrLen(compoundColor) = 0))
												compoundColor := "Black"

											targetDB.updatePressure(simulator, car, track, row["Weather"]
																  , row["Temperature.Air"], row["Temperature.Track"]
																  , compound, compoundColor, row["Type"], row["Tyre"]
																  , row["Pressure"], row["Count"], false, true, "Community", kNull)

											Sleep(1)
										}

										targetDB.flush()
									}
								}

								if uploadSetups {
									try {
										directory := sessionDBPath . "User\" . simulator . "\" . car . "\" . track . "\Car Setups"

										if FileExist(directory) {
											DirCopy(directory, kTempDirectory . "Shared Database\Community\" . simulator . "\" . car . "\" . track . "\Car Setups")

											directory := kTempDirectory . "Shared Database\Community\" . simulator . "\" . car . "\" . track . "\Car Setups\"

											files := []

											for ignore, type in kSetupTypes
												loop Files, directory . type . "\*.*", "F" {
													SplitPath(A_LoopFileName, , , &extension, &name)

													if (extension = "info") {
														updateState()

														info := sessionDB.readSetupInfo(simulator, car, track, type, name)

														if ((getMultiMapValue(info, "Origin", "Driver", false) != sessionDB.ID)
														 || !getMultiMapValue(info, "Access", "Share", false))
															deleteFile(directory . getMultiMapValue(info, "Setup", "Name"))
														else
															files.Push([type, getMultiMapValue(info, "Setup", "Name")])

														deleteFile(A_LoopFilePath)

														Sleep(1)
													}
												}

											for ignore, type in kSetupTypes
												loop Files, directory . type . "\*.*", "F" {
													SplitPath(A_LoopFileName, , , , &name)

													if (choose(files, (c) => ((c[1] = type) && c[2] = name)).Length = 0)
														deleteFile(A_LoopFilePath)

													Sleep(1)
												}
										}
									}
									catch Any as exception {
										logError(exception)
									}
								}

								if uploadStrategies {
									try {
										directory := sessionDBPath . "User\" . simulator . "\" . car . "\" . track . "\Race Strategies"

										if FileExist(directory) {
											DirCopy(directory, kTempDirectory . "Shared Database\Community\" . simulator . "\" . car . "\" . track . "\Race Strategies")

											directory := kTempDirectory . "Shared Database\Community\" . simulator . "\" . car . "\" . track . "\Race Strategies\"

											loop Files, directory . "*.info", "F" {
												updateState()

												SplitPath(A_LoopFileName, , , , &name)

												info := sessionDB.readStrategyInfo(simulator, car, track, name)

												if ((getMultiMapValue(info, "Origin", "Driver", false) != sessionDB.ID)
												 || !getMultiMapValue(info, "Access", "Share", false))
													deleteFile(directory . getMultiMapValue(info, "Strategy", "Name"))

												deleteFile(A_LoopFilePath)

												Sleep(1)
											}

											loop Files, directory . "*.*", "FD" {
												if InStr(FileExist(A_LoopFileName), "D")
													deleteDirectory(A_LoopFileName)
												else {
													SplitPath(A_LoopFileName, , , &extension)

													if ((extension != "info") && (extension != "strategy"))
														deleteFile(A_LoopFileName)
												}

												Sleep(1)
											}
										}
									}
									catch Any as exception {
										logError(exception)
									}
								}

								if uploadTelemetries {
									try {
										directory := sessionDBPath . "User\" . simulator . "\" . car . "\" . track . "\Lap Telemetries"

										if FileExist(directory) {
											DirCopy(directory, kTempDirectory . "Shared Database\Community\" . simulator . "\" . car . "\" . track . "\Lap Telemetries")

											directory := kTempDirectory . "Shared Database\Community\" . simulator . "\" . car . "\" . track . "\Lap Telemetries\"

											loop Files, directory . "*.info", "F" {
												updateState()

												SplitPath(A_LoopFileName, , , , &name)

												info := sessionDB.readTelemetryInfo(simulator, car, track, name)

												if ((getMultiMapValue(info, "Origin", "Driver", false) != sessionDB.ID)
												 || !getMultiMapValue(info, "Access", "Share", false))
													deleteFile(directory . getMultiMapValue(info, "Telemetry", "Name"))

												deleteFile(A_LoopFilePath)

												Sleep(1)
											}

											loop Files, directory . "*.*", "FD" {
												if InStr(FileExist(A_LoopFileName), "D")
													deleteDirectory(A_LoopFileName)
												else {
													SplitPath(A_LoopFileName, , , &extension)

													if ((extension != "info") && (extension != "telemetry"))
														deleteFile(A_LoopFileName)
												}

												Sleep(1)
											}
										}
									}
									catch Any as exception {
										logError(exception)
									}
								}
							}
						}
					}
				}
			}
		}

		try {
			RunWait("PowerShell.exe -Command Compress-Archive -LiteralPath '" . kTempDirectory . "Shared Database\Community' -CompressionLevel Optimal -DestinationPath '" . kTempDirectory . "Shared Database\Database." . id . ".zip'", , "Hide")
		}
		catch Any as exception {
			logError(exception)
		}

		; ftpUpload("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", kTempDirectory . "Shared Database\Database." . id . ".zip", "htdocs/simulator-controller/database-uploads/Database." . id . ".zip")

		ftpUpload(MASTER, "SimulatorController", "Sc-1234567890-Sc", kTempDirectory . "Shared Database\Database." . id . ".zip", "Database-Uploads/Database." . id . ".zip")

		deleteDirectory(kTempDirectory . "Shared Database")
		deleteFile(sessionDBPath . "UPLOAD")

		FileAppend(A_Now, sessionDBPath . "UPLOAD")

		setMultiMapValue(configuration, "Database Synchronizer", "Information"
					   , translate("Message: ") . translate("Synchronization finished..."))

		setMultiMapValue(configuration, "Database Synchronizer", "Synchronization", "Finished")

		writeMultiMap(kTempDirectory . "Database Synchronizer.state", configuration)

		logMessage(kLogInfo, translate("Database successfully uploaded"))
	}
	catch Any as exception {
		logMessage(kLogCritical, translate("Error while uploading database - please check your internet connection..."))
	}
}

downloadSessionDatabase(id, downloadPressures, downloadSetups, downloadStrategies, downloadTelemetries) {
	local MASTER := StrSplit(FileRead(kConfigDirectory . "MASTER"), "`n", "`r")[1]
	local sessionDBPath := SessionDatabase.DatabasePath
	local downloadTimeStamp := sessionDBPath . "DOWNLOAD"
	local configuration := newMultiMap()
	local ignore, fileName, type, databaseDirectory

	if FileExist(downloadTimeStamp)
		if (DateDiff(A_Now, StrSplit(FileRead(downloadTimeStamp), "`n", "`r")[1], "days") <= 2)
			return

	updateState() {
		writeMultiMap(kTempDirectory . "Database Synchronizer.state", configuration)
	}

	setMultiMapValue(configuration, "Database Synchronizer", "UserID", SessionDatabase.ID)
	setMultiMapValue(configuration, "Database Synchronizer", "DatabaseID", SessionDatabase.DatabaseID)

	setMultiMapValue(configuration, "Database Synchronizer", "State", "Active")

	setMultiMapValue(configuration, "Database Synchronizer", "Information"
				   , translate("Message: ") . translate("Downloading community database..."))

	setMultiMapValue(configuration, "Database Synchronizer", "Synchronization", "Downloading")

	try {
		try {
			DirDelete(kTempDirectory . "Shared Database", 1)
		}
		catch Any as exception {
			logError(exception)
		}

		updateState()

		for ignore, fileName in ftpListFiles(MASTER, "SimulatorController", "Sc-1234567890-Sc", "Database-Downloads") { ; ftpListFiles("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", "htdocs/simulator-controller/database-downloads") {
			SplitPath(fileName, , , , &databaseDirectory)

			type := StrSplit(Trim(fileName), ".", "", 2)[1]

			if (type = (downloadPressures . downloadSetups . downloadStrategies . downloadTelemetries)) {
				if (SessionDatabase.DatabaseVersion != databaseDirectory) {
					; ftpDownload("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", "htdocs/simulator-controller/database-downloads/" . fileName, kTempDirectory . fileName)

					ftpDownload(MASTER, "SimulatorController", "Sc-1234567890-Sc", "Database-Downloads/" . fileName, kTempDirectory . fileName)

					updateState()

					try {
						RunWait("PowerShell.exe -Command Expand-Archive -LiteralPath '" . kTempDirectory . fileName . "' -DestinationPath '" . kTempDirectory . "Shared Database' -Force", , "Hide")
					}
					catch Any as exception {
						logError(exception)
					}

					updateState()

					deleteFile(kTempDirectory . fileName)
					deleteDirectory(sessionDBPath . "Community")

					try {
						if FileExist(kTempDirectory . "Shared Database\" . databaseDirectory . "\Community")
							DirMove(kTempDirectory . "Shared Database\" . databaseDirectory . "\Community", sessionDBPath . "Community", "R")
						else if FileExist(kTempDirectory . "Shared Database\Community")
							DirMove(kTempDirectory . "Shared Database\Community", sessionDBPath . "Community", "R")
					}
					catch Any as exception {
						logError(exception)
					}

					SessionDatabase.DatabaseVersion := databaseDirectory

					break
				}
			}
		}

		deleteDirectory(kTempDirectory . "Shared Database")
		deleteFile(sessionDBPath . "DOWNLOAD")

		FileAppend(A_Now, sessionDBPath . "DOWNLOAD")

		setMultiMapValue(configuration, "Database Synchronizer", "Information"
					   , translate("Message: ") . translate("Synchronization finished..."))

		setMultiMapValue(configuration, "Database Synchronizer", "Synchronization", "Finished")

		writeMultiMap(kTempDirectory . "Database Synchronizer.state", configuration)

		logMessage(kLogInfo, translate("Database successfully downloaded"))
	}
	catch Any as exception {
		logMessage(kLogCritical, translate("Error while downloading database - please check your internet connection..."))
	}
}

synchronizeCommunityDatabase(id, usePressures, useSetups, useStrategies, useTelemetries) {
	global gSynchronizing
	
	local oldCritical := Task.Critical

	if gSynchronizing
		return Task.CurrentTask
	else
		gSynchronizing := true

	synchronizeDatabase("Stop")

	Task.Critical := true

	try {
		uploadSessionDatabase(id, usePressures, useSetups, useStrategies, useTelemetries)
		downloadSessionDatabase(id, usePressures, useSetups, useStrategies, useTelemetries)
	}
	finally {
		Task.Critical := oldCritical

		synchronizeDatabase("Start")

		gSynchronizing := false
	}

	Task.CurrentTask.Sleep := (24 * 60 * 60 * 1000)

	return Task.CurrentTask
}

synchronizeSessionDatabase(minutes) {
	global gSynchronizing
	
	local oldCritical := Task.Critical

	if gSynchronizing
		return Task.CurrentTask
	else
		gSynchronizing := true

	Task.Critical := true

	try {
		synchronizeDatabase()
	}
	catch Any as exception {
		logError(exception, true)
	}
	finally {
		Task.Critical := oldCritical

		gSynchronizing := false
	}

	Task.CurrentTask.Sleep := (minutes * 60000)

	return Task.CurrentTask
}

updateSessionDatabase() {
	local icon := kIconsDirectory . "Database Update.ico"
	local usePressures, useSetups, useStrategies, useTelemetries, id, minutes

	TraySetIcon(icon, "1")
	A_IconTip := "Database Synchronizer"

	try {
		startupProcess()

		usePressures := (inList(A_Args, "-Pressures") != 0)
		useSetups := (inList(A_Args, "-Setups") != 0)
		useStrategies := (inList(A_Args, "-Strategies") != 0)
		useTelemetries := (inList(A_Args, "-Telemetries") != 0)

		id := inList(A_Args, "-ID")

		if id
			PeriodicTask(synchronizeCommunityDatabase.Bind(A_Args[id + 1], usePressures, useSetups, useStrategies, useTelemetries), 2000, kLowPriority).start()

		minutes := inList(A_Args, "-Synchronize")

		if minutes {
			minutes := A_Args[minutes + 1]

			if (minutes && (minutes != kFalse)) {
				if ((minutes == true) || (minutes = kTrue))
					minutes := getMultiMapValue(readMultiMap(kUserConfigDirectory . "Session Database.ini")
											  , "Team Server", "Replication", 30)

				if !isInteger(minutes)
					minutes := 30

				Task.startTask(synchronizeSessionDatabase.Bind(minutes), 1000, kLowPriority)
			}
		}
	}
	catch Any as exception {
		logError(exception, true)

		OnMessage(0x44, translateOkButton)
		withBlockedWindows(MsgBox, substituteVariables(translate("Cannot start %application% due to an internal error..."), {application: "Database Synchronizer"}), translate("Error"), 262160)
		OnMessage(0x44, translateOkButton, 0)

		ExitApp(1)
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

updateSessionDatabase()