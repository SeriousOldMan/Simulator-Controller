;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Database Synchronizer           ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

;@SC-If %configuration% == Production
;@SC #Include ..\Includes\Production.ahk
;@SC-EndIf

;@SC-If %configuration% == Development
;@SC #Include ..\Includes\Development.ahk
;@SC-EndIf

#Include ..\Includes\Development.ahk

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
#Include ..\Assistants\Libraries\SessionDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

uploadSessionDatabase(id, uploadPressures, uploadSetups) {
	local sessionDB := new SessionDatabase()
	local databaseDirectory := sessionDB.DatabasePath
	local uploadTimeStamp := databaseDirectory . "UPLOAD"
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

		loop Files, %databaseDirectory%User\*.*, D									; Simulator
		{
			simulator := A_LoopFileName

			FileCreateDir %kTempDirectory%Shared Database\%simulator%

			loop Files, %databaseDirectory%User\%simulator%\*.*, D					; Car
			{
				car := A_LoopFileName

				if (car = "1") {
					directoryName = %databaseDirectory%User\%simulator%\%car%
							
					deleteDirectory(directoryName)
				}
				else {
					FileCreateDir %kTempDirectory%Shared Database\%simulator%\%car%

					loop Files, %databaseDirectory%User\%simulator%\%car%\*.*, D			; Track
					{
						track := A_LoopFileName

						if (track = "1") {
							directoryName = %databaseDirectory%User\%simulator%\%car%\%track%
							
							deleteDirectory(directoryName)
						}
						else {
							FileCreateDir %kTempDirectory%Shared Database\%simulator%\%car%\%track%

							if uploadPressures {
								distFile := (databaseDirectory . "User\" . simulator . "\" . car . "\" . track . "\Tyres.Pressures.Distribution.CSV")

								if FileExist(distFile)
									FileCopy %distFile%, %kTempDirectory%Shared Database\%simulator%\%car%\%track%
							}

							if uploadSetups {
								try {
									FileCopyDir %databaseDirectory%User\%simulator%\%car%\%track%\Car Setups, %kTempDirectory%Shared Database\%simulator%\%car%\%track%\Car Setups
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

		ftpUpload("ftp.drivehq.com", "TheBigO", "29605343.9318.1940", kTempDirectory . "Shared Database\Database." . id . ".zip", "Simulator Controller\Database Uploads\Database." . id . ".zip")

		deleteDirectory(kTempDirectory . "Shared Database")
		deleteFile(databaseDirectory . "UPLOAD")

		FileAppend %A_Now%, %databaseDirectory%UPLOAD

		logMessage(kLogInfo, translate("Database successfully uploaded"))
	}
	catch exception {
		logMessage(kLogCritical, translate("Error while uploading database - please check your internet connection..."))

		showMessage(translate("Error while uploading database - please check your internet connection...")
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

downloadSessionDatabase(id, downloadPressures, downloadSetups) {
	local sessionDB := new SessionDatabase()
	local databaseDirectory := sessionDB.DatabasePath
	local downloadTimeStamp := databaseDirectory . "DOWNLOAD"
	local download, now, ignore, fileName, databaseDirectory, type, sessionDB

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

		for ignore, fileName in ftpListFiles("ftp.drivehq.com", "TheBigO", "29605343.9318.1940", "Simulator Controller\Database Downloads") {
			SplitPath fileName, , , , databaseDirectory

			type := StrSplit(Trim(fileName), ".", "", 2)[1]

			if (type = (downloadPressures . downloadSetups)) {
				sessionDB := new SessionDatabase()

				if (sessionDB.DatabaseVersion != databaseDirectory) {
					ftpDownload("ftp.drivehq.com", "TheBigO", "29605343.9318.1940", "Simulator Controller\Database Downloads\" . fileName, kTempDirectory . fileName)

					RunWait PowerShell.exe -Command Expand-Archive -LiteralPath '%kTempDirectory%%fileName%' -DestinationPath '%kTempDirectory%Shared Database', , Hide

					deleteFile(kTempDirectory . fileName)
					deleteDirectory(databaseDirectory . "Community")

					if FileExist(kTempDirectory . "Shared Database\" . databaseDirectory . "\Community")
						FileMoveDir %kTempDirectory%Shared Database\%databaseDirectory%\Community, %databaseDirectory%Community, R
					else if FileExist(kTempDirectory . "Shared Database\Community")
						FileMoveDir %kTempDirectory%Shared Database\Community, %databaseDirectory%Community, R

					sessionDB.DatabaseVersion := databaseDirectory
				}
			}
		}

		deleteDirectory(kTempDirectory . "Shared Database")
		deleteFile(databaseDirectory . "DOWNLOAD")

		FileAppend %A_Now%, %databaseDirectory%DOWNLOAD

		logMessage(kLogInfo, translate("Database successfully downloaded"))
	}
	catch exception {
		logMessage(kLogCritical, translate("Error while downloading database - please check your internet connection..."))

		showMessage(translate("Error while downloading database - please check your internet connection...")
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

updateSessionDatabase() {
	local icon := kIconsDirectory . "Database Update.ico"
	local usePressures, useSetups, id

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Database Synchronizer

	usePressures := (inList(A_Args, "-Pressures") != 0)
	useSetups := (inList(A_Args, "-Setups") != 0)

	id := inList(A_Args, "-ID")

	if id {
		id := A_Args[id + 1]

		uploadSessionDatabase(id, usePressures, useSetups)
		downloadSessionDatabase(id, usePressures, useSetups)
	}

	ExitApp 0
}

;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

updateSessionDatabase()