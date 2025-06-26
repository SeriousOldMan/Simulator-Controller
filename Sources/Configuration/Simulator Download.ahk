﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Simulator Download              ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Installer.ico
;@Ahk2Exe-ExeName Simulator Download.exe
;@Ahk2Exe-SetCompanyName Oliver Juwig (TheBigO)
;@Ahk2Exe-SetCopyright TheBigO - Creative Commons - BY-NC-SA
;@Ahk2Exe-SetProductName Simulator Controller
;@Ahk2Exe-SetVersion 0.0.0.0


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Process.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Extensions\Task.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

updateProgress(max) {
	static counter := 0

	counter := Min(counter + 1, max)

	showProgress({progress: counter})
}

downloadSimulatorController() {
	local MASTER := StrSplit(FileRead(kConfigDirectory . "MASTER"), "`n", "`r")[1]
	local icon := kIconsDirectory . "Installer.ico"
	local error := false
	local options, index, cState, devVersion, release, version, package, updateTask
	local directory, currentDirectory, ignore, url

	exitOthers() {
		loop 20
			if exitProcesses("", "", true, true, ["Simulator Download"], true)
				break
			else
				Sleep(1000)
	}

	cState := GetKeyState("Ctrl")

	TraySetIcon(icon, "1")
	A_IconTip := "Simulator Download"

	startupProcess()

	if !A_IsAdmin {
		if RegExMatch(DllCall("GetCommandLine", "str"), " /restart(?!\S)") {
			OnMessage(0x44, translateOkButton)
			withBlockedWindows(MsgBox, translate("Simulator Controller cannot request Admin privileges. Please enable User Account Control."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)

			ExitApp(0)
		}

		options := ""

		if inList(A_Args, "-NoUpdate")
			options .= " -NoUpdate"

		if inList(A_Args, "-Update")
			options .= " -Update"

		if inList(A_Args, "-Download")
			options .= " -Download"

		index := inList(A_Args, "-Start")

		if index
			options .= (" -Start `"" . A_Args[index + 1] . "`"")

		if cState
			options .= " -Development"

		try {
			if A_IsCompiled
				Run((!A_IsAdmin ? "*RunAs `"" : "`"") . A_ScriptFullPath . "`" /restart " . options)
			else
				Run((!A_IsAdmin ? "*RunAs `"" : "`"") . A_AhkPath . "`" /restart `"" . A_ScriptFullPath . "`" " . options)
		}
		catch Any as exception {
			OnMessage(0x44, translateOkButton)
			withBlockedWindows(MsgBox, translate("An error occured while starting the automatic installation due to Windows security restrictions. You can try a manual installation."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)
		}

		ExitApp(0)
	}

	devVersion := (cState || inList(A_Args, "-Development"))

	deleteFile(kTempDirectory . "VERSION")
	
	for ignore, url in ["https://fileshare.impresion3d.pro/filebrowser/api/public/dl/OH13SGRl"
					  , "https://www.dropbox.com/scl/fi/3m941rw7qz7voftjoqalq/VERSION?rlkey=b1r9ecrztj1t3cr0jmmbor6du&st=zhl9bzbm&dl=1"
					  , "https://" . MASTER . ":801/api/public/dl/bkguewzP"
					  , "https://simulatorcontroller.s3.eu-central-1.amazonaws.com/Releases/VERSION"]
		try {
			error := false

			Download("https://simulatorcontroller.s3.eu-central-1.amazonaws.com/Releases/VERSION", kTempDirectory . "VERSION")

			if FileExist(kTempDirectory . "VERSION")
				break
		}
		catch Any as exception {
			error := exception
		}

	if (error || !FileExist(kTempDirectory . "VERSION")) {
		if error
			logError(error, true)

		OnMessage(0x44, translateOkButton)
		withBlockedWindows(MsgBox, translate("The download repository is currently unavailable. Please try again later."), translate("Error"), 262160)
		OnMessage(0x44, translateOkButton, 0)

		ExitApp(0)
	}

	release := readMultiMap(kTempDirectory . "VERSION")
	version := getMultiMapValue(release, (devVersion ? "Development" : "Release"), "Version", getMultiMapValue(release, "Version", "Release", false))

	if version {
		if devVersion
			package := getMultiMapValue(release, "Development", "Download", false)
		else
			package := getMultiMapValue(release, "Release", "Download", false)

		if package {
			package := substituteVariables(package, {master: MASTER})
			
			exitOthers()

			for ignore, url in string2Values(";", package)
				try {
					error := false

					showProgress({progress: 0, color: "Green", title: translate(inList(A_Args, "-Update") ? "Updating Simulator Controller" : "Installing Simulator Controller")
								, message: translate("Downloading Version ") . version})

					updateTask := PeriodicTask(updateProgress.Bind(45), 1500)

					updateTask.start()

					deleteFile(kTempDirectory . "InstallPackage.zip")

					Download(url, kTempDirectory . "InstallPackage.zip")

					updateTask.stop()

					updateTask := PeriodicTask(updateProgress.Bind(90), 1000)

					updateTask.start()

					showProgress({message: translate("Extracting installation files...")})

					deleteDirectory(kTempDirectory . "SC-Install")

					RunWait("PowerShell.exe -Command Expand-Archive -LiteralPath '" . kTempDirectory . "InstallPackage.zip' -DestinationPath '" . kTempDirectory . "SC-Install' -Force", , "Hide")

					exitOthers()

					deleteFile(kTempDirectory . "InstallPackage.zip")

					directory := (kTempDirectory . "SC-Install")

					if FileExist(directory . "\Simulator Controller")
						directory .= "\Simulator Controller"

					if DirExist(directory . "\Binaries") {
						currentDirectory := A_WorkingDir

						try {
							showProgress({message: translate("Unblocking Applications and DLLs...")})

							SetWorkingDir(directory . "\Binaries")

							RunWait("Powershell -Command Get-ChildItem -Path '.' | Unblock-File", , "Hide")
						}
						catch Any as exception {
							logError(exception, true)

							OnMessage(0x44, translateOkButton)
							withBlockedWindows(MsgBox, translate("An error occured while starting the automatic instalation due to Windows security restrictions. You can try a manual installation."), translate("Error"), 262160)
							OnMessage(0x44, translateOkButton, 0)

							Run("https://github.com/SeriousOldMan/Simulator-Controller#latest-release-build")

							ExitApp(0)
						}
						finally {
							SetWorkingDir(currentDirectory)
						}
					}
					else
						throw "Archive does not contain a valid installation package..."

					break
				}
				catch Any as exception {
					error := exception
				}

			if error {
				logError(error, true)

				OnMessage(0x44, translateOkButton)
				withBlockedWindows(MsgBox, translate("The download repository is currently unavailable. Please try again later."), translate("Error"), 262160)
				OnMessage(0x44, translateOkButton, 0)

				ExitApp(0)
			}

			updateTask.stop()

			showProgress({progress: 90, message: translate("Preparing installation...")})

			Sleep(1000)

			exitOthers()

			showProgress({progress: 100, message: translate("Starting installation...")})

			index := inList(A_Args, "-Start")

			try {
				if index
					Run("`"" . directory . "\Binaries\Simulator Tools.exe`" -NoUpdate -Install -Start `"" . A_Args[index + 1] . "`"")
				else
					Run("`"" . directory . "\Binaries\Simulator Tools.exe`" -NoUpdate -Install")
			}
			catch Any as exception {
				OnMessage(0x44, translateOkButton)
				withBlockedWindows(MsgBox, translate("An error occured while starting the automatic instalation due to Windows security restrictions. You can try a manual installation."), translate("Error"), 262160)
				OnMessage(0x44, translateOkButton, 0)

				Run("https://github.com/SeriousOldMan/Simulator-Controller#latest-release-build")
			}

			Sleep(1000)

			hideProgress()
		}
		else
			Run("https://github.com/SeriousOldMan/Simulator-Controller#latest-release-build")
	}

	ExitApp(0)
}


;;;-------------------------------------------------------------------------;;;
;;;                           Initialization Section                        ;;;
;;;-------------------------------------------------------------------------;;;

downloadSimulatorController()