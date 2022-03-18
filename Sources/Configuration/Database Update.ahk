;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Database Update Tool            ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Database Update.ico
;@Ahk2Exe-ExeName Database Update.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\FTP.ahk


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

uploadSessionDatabase(id, uploadPressures, uploadSetups) {
	uploadTimeStamp := kDatabaseDirectory . "User\UPLOAD"
	
	if FileExist(uploadTimeStamp) {
		FileReadLine upload, %uploadTimeStamp%, 1
		
		now := A_Now
		
		EnvSub now, %upload%, days
		
		if (now <= 7)
			return
	}
	
	try {
		try {
			FileRemoveDir %kTempDirectory%Shared Database, 1
		}
		catch exception {
			; ignore
		}
		
		Loop Files, %kDatabaseDirectory%User\*.*, D									; Simulator
		{
			simulator := A_LoopFileName
			
			FileCreateDir %kTempDirectory%Shared Database\%simulator%
			
			Loop Files, %kDatabaseDirectory%User\%simulator%\*.*, D					; Car
			{
				car := A_LoopFileName
				
				if car is number
					try {
						FileRemoveDir %kDatabaseDirectory%User\%simulator%\%car%, 1
					}
					catch exception {
						; ignore
					}
				else {
					FileCreateDir %kTempDirectory%Shared Database\%simulator%\%car%
					
					Loop Files, %kDatabaseDirectory%User\%simulator%\%car%\*.*, D			; Track
					{
						track := A_LoopFileName
				
						if car is number
							try {
								FileRemoveDir %kDatabaseDirectory%User\%simulator%\%car%\%track%, 1
							}
							catch exception {
								; ignore
							}
						else {
							FileCreateDir %kTempDirectory%Shared Database\%simulator%\%car%\%track%
							
							if uploadPressures {
								Loop Files, %kDatabaseDirectory%User\%simulator%\%car%\%track%\Tyre Setup*.*
									FileCopy %A_LoopFilePath%, %kTempDirectory%Shared Database\%simulator%\%car%\%track%
								
								distFile := (kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track . "\Tyres.Pressures.Distribution.CSV")
								
								if FileExist(distFile)
									FileCopy %distFile%, %kTempDirectory%Shared Database\%simulator%\%car%\%track%
							}
							
							if uploadSetups {
								try {
									FileCopyDir %kDatabaseDirectory%User\%simulator%\%car%\%track%\Car Setups, %kTempDirectory%Shared Database\%simulator%\%car%\%track%\Car Setups
								}
								catch exception {
									; ignore
								}
							}
						}
					}
				}
			}
		}
		
		RunWait PowerShell.exe -Command Compress-Archive -LiteralPath '%kTempDirectory%Shared Database' -CompressionLevel Optimal -DestinationPath '%kTempDirectory%Shared Database\Database.%id%.zip', , Hide
		
		ftpUpload("ftp.drivehq.com", "TheBigO", "29605343.9318.1940", kTempDirectory . "Shared Database\Database." . id . ".zip", "Simulator Controller\Database Uploads\Database." . id . ".zip")
	
		try {
			FileRemoveDir %kTempDirectory%Shared Database, 1
		}
		catch exception {
			; ignore
		}
		
		try {
			FileDelete %kDatabaseDirectory%User\UPLOAD
		}
		catch exception {
			; ignore
		}
		
		FileAppend %A_Now%, %kDatabaseDirectory%User\UPLOAD
		
		logMessage(kLogInfo, translate("Database successfully uploaded"))
	}
	catch exception {
		logMessage(kLogCritical, translate("Error while uploading database - please check your internet connection..."))
	
		showMessage(translate("Error while uploading database - please check your internet connection...")
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

downloadSessionDatabase(id, downloadPressures, downloadSetups) {
	try {
		try {
			FileRemoveDir %kTempDirectory%Shared Database, 1
		}
		catch exception {
			; ignore
		}
		
		for ignore, fileName in ftpListFiles("ftp.drivehq.com", "TheBigO", "29605343.9318.1940", "Simulator Controller\Database Downloads") {
			SplitPath fileName, , , , directory
		
			type := StrSplit(Trim(fileName), ".", "", 2)[1]
		
			if (type = (downloadPressures . downloadSetups)) {
				ftpDownload("ftp.drivehq.com", "TheBigO", "29605343.9318.1940", "Simulator Controller\Database Downloads\" . fileName, kTempDirectory . fileName)
			
				RunWait PowerShell.exe -Command Expand-Archive -LiteralPath '%kTempDirectory%%fileName%' -DestinationPath '%kTempDirectory%Shared Database', , Hide
				
				try {
					FileDelete %kTempDirectory%%fileName%
				}
				catch exception {
					; ignore
				}
		
				try {
					FileRemoveDir %kDatabaseDirectory%Community, 1
				}
				catch exception {
					; ignore
				}
				
				if FileExist(kTempDirectory . "Shared Database\" . directory . "\Community")
					FileMoveDir %kTempDirectory%Shared Database\%directory%\Community, %kDatabaseDirectory%Community, R
				else if FileExist(kTempDirectory . "Shared Database\Community")
					FileMoveDir %kTempDirectory%Shared Database\Community, %kDatabaseDirectory%Community, R
			}
		}
		
		try {
			FileRemoveDir %kTempDirectory%Shared Database, 1
		}
		catch exception {
			; ignore
		}
		
		logMessage(kLogInfo, translate("Database successfully downloaded"))
	}
	catch exception {
		logMessage(kLogCritical, translate("Error while downloading database - please check your internet connection..."))
	
		showMessage(translate("Error while downloading database - please check your internet connection...")
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

updateSessionDatabase() {
	icon := kIconsDirectory . "Database Update.ico"
	
	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Database Update
	
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