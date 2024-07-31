;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Database Synchronizer           ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
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


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Process.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\FTP.ahk"
#Include "..\Libraries\Task.ahk"
#Include "Libraries\SessionDatabase.ahk"
#Include "Libraries\TelemetryDatabase.ahk"
#Include "Libraries\TyresDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

uploadSessionDatabase(id, uploadPressures, uploadSetups, uploadStrategies) {
	local sessionDB := SessionDatabase()
	local sessionDBPath := sessionDB.DatabasePath
	local uploadTimeStamp := sessionDBPath . "UPLOAD"
	local targetDB := TyresDatabase()
	local simulator, car, track, distFile, configuration
	local directory, sourceDB, targetDB, ignore, type, row, compound, compoundColor

	if FileExist(uploadTimeStamp)
		if (DateDiff(A_Now, StrSplit(FileRead(uploadTimeStamp), "`n", "`r")[1], "days") <= 7)
			return

	targetDB.DatabaseDirectory := (kTempDirectory . "Shared Database\")
	targetDB.Shared := false

	try {
		configuration := newMultiMap()

		setMultiMapValue(configuration, "Database Synchronizer", "UserID", sessionDB.ID)
		setMultiMapValue(configuration, "Database Synchronizer", "DatabaseID", sessionDB.DatabaseID)

		setMultiMapValue(configuration, "Database Synchronizer", "State", "Active")

		setMultiMapValue(configuration, "Database Synchronizer", "Information"
					   , translate("Message: ") . translate("Uploading community database..."))

		setMultiMapValue(configuration, "Database Synchronizer", "Synchronization", "Uploading")

		writeMultiMap(kTempDirectory . "Database Synchronizer.state", configuration)

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

							if ((track = "1") || (track = "0") || (track = "Unknown"))
								deleteDirectory(sessionDBPath . "User\" . simulator . "\" . car . "\" . track)
							else {
								DirCreate(kTempDirectory . "Shared Database\Community\" . simulator . "\" . car . "\" . track)

								if uploadPressures {
									directory := (sessionDBPath . "User\" . simulator . "\" . car . "\" . track . "\")

									if FileExist(directory . "Tyres.Pressures.Distribution.CSV") {
										sourceDB := Database(directory, kTyresSchemas)

										for ignore, row in sourceDB.query("Tyres.Pressures.Distribution", {Where: {Driver: sessionDB.ID} }) {
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

										if FileExist(directory)
											DirCopy(directory, kTempDirectory . "Shared Database\Community\" . simulator . "\" . car . "\" . track . "\Car Setups")

											directory := kTempDirectory . "Shared Database\Community\" . simulator . "\" . car . "\" . track . "\Car Setups\"

											for ignore, type in kSetupTypes
												loop Files, directory . type . "\*.info", "F" {
													SplitPath(A_LoopFileName, , , , &name)

													info := sessionDB.readSetupInfo(simulator, car, track, type, name)

													if ((getMultiMapValue(info, "Origin", "Driver", false) != sessionDB.ID)
													 || !getMultiMapValue(info, "Access", "Share", false))
														deleteFile(directory . getMultiMapValue(info, "Setup", "Name"))

													deleteFile(A_LoopFilePath)

													Sleep(1)
												}
									}
									catch Any as exception {
										logError(exception)
									}
								}

								if uploadStrategies {
									try {
										directory := sessionDBPath . "User\" . simulator . "\" . car . "\" . track . "\Race Strategies"

										if FileExist(directory)
											DirCopy(directory, kTempDirectory . "Shared Database\Community\" . simulator . "\" . car . "\" . track . "\Race Strategies")

											directory := kTempDirectory . "Shared Database\Community\" . simulator . "\" . car . "\" . track . "\Race Strategies\"

											loop Files, directory . "*.info", "F" {
												SplitPath(A_LoopFileName, , , , &name)

												info := sessionDB.readStrategyInfo(simulator, car, track, name)

												if ((getMultiMapValue(info, "Origin", "Driver", false) != sessionDB.ID)
												 || !getMultiMapValue(info, "Access", "Share", false))
													deleteFile(directory . getMultiMapValue(info, "Strategy", "Name"))

												deleteFile(A_LoopFilePath)

												Sleep(1)
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

		ftpUpload("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", kTempDirectory . "Shared Database\Database." . id . ".zip", "htdocs/simulator-controller/database-uploads/Database." . id . ".zip")

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

downloadSessionDatabase(id, downloadPressures, downloadSetups, downloadStrategies) {
	local sessionDBPath := SessionDatabase.DatabasePath
	local downloadTimeStamp := sessionDBPath . "DOWNLOAD"
	local ignore, fileName, type, databaseDirectory, configuration

	if FileExist(downloadTimeStamp)
		if (DateDiff(A_Now, StrSplit(FileRead(downloadTimeStamp), "`n", "`r")[1], "days") <= 2)
			return

	try {
		try {
			DirDelete(kTempDirectory . "Shared Database", 1)
		}
		catch Any as exception {
			logError(exception)
		}

		configuration := newMultiMap()

		setMultiMapValue(configuration, "Database Synchronizer", "UserID", SessionDatabase.ID)
		setMultiMapValue(configuration, "Database Synchronizer", "DatabaseID", SessionDatabase.DatabaseID)

		setMultiMapValue(configuration, "Database Synchronizer", "State", "Active")

		setMultiMapValue(configuration, "Database Synchronizer", "Information"
					   , translate("Message: ") . translate("Downloading community database..."))

		setMultiMapValue(configuration, "Database Synchronizer", "Synchronization", "Downloading")

		writeMultiMap(kTempDirectory . "Database Synchronizer.state", configuration)

		for ignore, fileName in ftpListFiles("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", "htdocs/simulator-controller/database-downloads") {
			SplitPath(fileName, , , , &databaseDirectory)

			type := StrSplit(Trim(fileName), ".", "", 2)[1]

			if ((type = (downloadPressures . downloadSetups . downloadStrategies)) || (type = (downloadPressures . downloadSetups))) {
				if (SessionDatabase.DatabaseVersion != databaseDirectory) {
					ftpDownload("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", "htdocs/simulator-controller/database-downloads/" . fileName, kTempDirectory . fileName)

					try {
						RunWait("PowerShell.exe -Command Expand-Archive -LiteralPath '" . kTempDirectory . fileName . "' -DestinationPath '" . kTempDirectory . "Shared Database' -Force", , "Hide")
					}
					catch Any as exception {
						logError(exception)
					}

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

		setMultiMapValue(configuration, "Database Synchronizer", "State", "Active")

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

synchronizeCommunityDatabase(id, usePressures, useSetups, useStrategies) {
	synchronizeDatabase("Stop")

	Task.CurrentTask.Critical := true

	try {
		uploadSessionDatabase(id, usePressures, useSetups, useStrategies)
		downloadSessionDatabase(id, usePressures, useSetups, useStrategies)
	}
	finally {
		Task.CurrentTask.Critical := false

		synchronizeDatabase("Start")
	}

	Task.CurrentTask.Sleep := (24 * 60 * 60 * 1000)

	return Task.CurrentTask
}

synchronizeSessionDatabase(minutes) {
	Task.CurrentTask.Critical := true

	try {
		synchronizeDatabase()
	}
	catch Any as exception {
		logError(exception, true)
	}
	finally {
		Task.CurrentTask.Critical := false
	}

	Task.CurrentTask.Sleep := (minutes * 60000)

	return Task.CurrentTask
}

updateSessionDatabase() {
	local icon := kIconsDirectory . "Database Update.ico"
	local usePressures, useSetups, useStrategies, id, minutes

	TraySetIcon(icon, "1")
	A_IconTip := "Database Synchronizer"

	try {
		startupProcess()

		usePressures := (inList(A_Args, "-Pressures") != 0)
		useSetups := (inList(A_Args, "-Setups") != 0)
		useStrategies := (inList(A_Args, "-Strategies") != 0)

		id := inList(A_Args, "-ID")

		if id
			PeriodicTask(synchronizeCommunityDatabase.Bind(A_Args[id + 1], usePressures, useSetups, useStrategies), 10000, kLowPriority).start()

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