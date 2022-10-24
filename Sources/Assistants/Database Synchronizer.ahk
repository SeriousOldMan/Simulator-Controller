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

uploadSessionDatabase(id, uploadPressures, uploadSetups) {
	local sessionDB := new SessionDatabase()
	local sessionDBPath := sessionDB.DatabasePath
	local uploadTimeStamp := sessionDBPath . "UPLOAD"
	local upload, now, simulator, car, track, distFile, directoryName

	if FileExist(uploadTimeStamp) {
		FileReadLine upload, %uploadTimeStamp%, 1

		now := A_Now

		EnvSub now, %upload%, days

		if (now <= 7)
			return
	}

	try {
		deleteDirectory(kTempDirectory . "Shared Database")

		loop Files, %sessionDBPath%User\*.*, D									; Simulator
		{
			simulator := A_LoopFileName

			FileCreateDir %kTempDirectory%Shared Database\%simulator%

			loop Files, %sessionDBPath%User\%simulator%\*.*, D					; Car
			{
				car := A_LoopFileName

				if (car = "1") {
					directoryName = %sessionDBPath%User\%simulator%\%car%

					deleteDirectory(directoryName)
				}
				else {
					FileCreateDir %kTempDirectory%Shared Database\%simulator%\%car%

					loop Files, %sessionDBPath%User\%simulator%\%car%\*.*, D			; Track
					{
						track := A_LoopFileName

						if (track = "1") {
							directoryName = %sessionDBPath%User\%simulator%\%car%\%track%

							deleteDirectory(directoryName)
						}
						else {
							FileCreateDir %kTempDirectory%Shared Database\%simulator%\%car%\%track%

							if uploadPressures {
								distFile := (sessionDBPath . "User\" . simulator . "\" . car . "\" . track . "\Tyres.Pressures.Distribution.CSV")

								if FileExist(distFile)
									FileCopy %distFile%, %kTempDirectory%Shared Database\%simulator%\%car%\%track%
							}

							if uploadSetups {
								try {
									FileCopyDir %sessionDBPath%User\%simulator%\%car%\%track%\Car Setups, %kTempDirectory%Shared Database\%simulator%\%car%\%track%\Car Setups
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

		RunWait PowerShell.exe -Command Compress-Archive -LiteralPath '%kTempDirectory%Shared Database' -CompressionLevel Optimal -DestinationPath '%kTempDirectory%Shared Database\Database.%id%.zip', , Hide

		ftpUpload("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", kTempDirectory . "Shared Database\Database." . id . ".zip", "simulator-controller\database-uploads\Database." . id . ".zip")

		deleteDirectory(kTempDirectory . "Shared Database")
		deleteFile(sessionDBPath . "UPLOAD")

		FileAppend %A_Now%, %sessionDBPath%UPLOAD

		logMessage(kLogInfo, translate("Database successfully uploaded"))
	}
	catch exception {
		logMessage(kLogCritical, translate("Error while uploading database - please check your internet connection..."))

		showMessage(translate("Error while uploading database - please check your internet connection...")
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}

	Task.CurrentTask.Sleep := (24 * 60 * 60 * 1000)

	return Task.CurrentTask
}

downloadSessionDatabase(id, downloadPressures, downloadSetups) {
	local sessionDB := new SessionDatabase()
	local sessionDBPath := sessionDB.DatabasePath
	local downloadTimeStamp := sessionDBPath . "DOWNLOAD"
	local download, now, ignore, fileName, type, databaseDirectory

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

		for ignore, fileName in ftpListFiles("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", "simulator-controller\database-downloads") {
			SplitPath fileName, , , , databaseDirectory

			type := StrSplit(Trim(fileName), ".", "", 2)[1]

			if (type = (downloadPressures . downloadSetups)) {
				sessionDB := new SessionDatabase()

				if (sessionDB.DatabaseVersion != databaseDirectory) {
					ftpDownload("ftpupload.net", "epiz_32854064", "d5NW1ps6jX6Lk", "simulator-controller\database-downloads\" . fileName, kTempDirectory . fileName)

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

		logMessage(kLogInfo, translate("Database successfully downloaded"))
	}
	catch exception {
		logMessage(kLogCritical, translate("Error while downloading database - please check your internet connection..."))

		showMessage(translate("Error while downloading database - please check your internet connection...")
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
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
	local usePressures, useSetups, id, minutes, configuration

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Database Synchronizer

	usePressures := (inList(A_Args, "-Pressures") != 0)
	useSetups := (inList(A_Args, "-Setups") != 0)

	id := inList(A_Args, "-ID")

	if id {
		id := A_Args[id + 1]

		new PeriodicTask(Func("uploadSessionDatabase").Bind(id, usePressures, useSetups)).start()
		new PeriodicTask(Func("downloadSessionDatabase").Bind(id, usePressures, useSetups)).start()
	}

	minutes := inList(A_Args, "-Synchronize")

	if minutes {
		minutes := A_Args[minutes + 1]

		if (minutes && (minutes != kFalse)) {
			if ((minutes == true) || (minutes = kTrue)) {
				configuration := readConfiguration(kUserConfigDirectory . "Session Database.ini")

				minutes := getConfigurationValue(configuration, "Team Server", "Replication", 30)
			}

			Task.startTask(Func("synchronizeSessionDatabase").Bind(minutes), 1000)
		}
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

updateSessionDatabase()