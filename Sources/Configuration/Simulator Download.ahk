;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Simulator Download              ;;;
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
;@SC #Include "..\Framework\Production.ahk"
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Installer.ico
;@Ahk2Exe-ExeName Simulator Download.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Process.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Task.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

updateProgress(max) {
	static counter := 0

	counter := Min(counter + 1, max)

	showProgress({progress: counter})
}

downloadSimulatorController() {
	local icon := kIconsDirectory . "Installer.ico"
	local options, index, cState, sState, devVersion, release, version, package, updateTask
	local directory, currentDirectory, start, ignore, url, error

	TraySetIcon(icon, "1")
	A_IconTip := "Simulator Download"

	if !A_IsAdmin {
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

		try {
			if A_IsCompiled
				Run("*RunAs `"" A_ScriptFullPath "`" /restart " options)
			else
				Run("*RunAs `"" A_AhkPath "`" /restart `"" A_ScriptFullPath "`" " options)
		}
		catch Any as exception {
			OnMessage(0x44, translateOkButton)
			MsgBox(translate("An error occured while starting the automatic installation due to Windows security restrictions. You can try a manual installation."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)
		}

		ExitApp(0)
	}

	cState := GetKeyState("Control", "P")
	sState := GetKeyState("Shift", "P")

	devVersion := (cState != false)

	try {
		Download("https://www.dropbox.com/s/txa8muw9j3g66tl/VERSION?dl=1", kTempDirectory . "VERSION")
	}
	catch Any as exception {
		logError(exception, true)

		OnMessage(0x44, translateOkButton)
		MsgBox(translate("The version repository is currently unavailable. Please try again later."), translate("Error"), 262160)
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
			showProgress({color: "Green", title: translate(inList(A_Args, "-Update") ? "Updating Simulator Controller" : "Installing Simulator Controller")
						, message: translate("Downloading Version ") . version})

			updateTask := PeriodicTask(updateProgress.Bind(45), 1500)

			updateTask.start()

			error := false

			for ignore, url in string2Values(";", package)
				try {
					Download(url, A_Temp . "\Simulator Controller.zip")

					error := false

					break
				}
				catch Any as exception {
					logError(exception)

					error := true
				}

			if error {
				OnMessage(0x44, translateOkButton)
				MsgBox(translate("The version repository is currently unavailable. Please try again later."), translate("Error"), 262160)
				OnMessage(0x44, translateOkButton, 0)

				ExitApp(0)
			}

			updateTask.stop()

			updateTask := PeriodicTask(updateProgress.Bind(90), 1000)

			updateTask.start()

			showProgress({message: translate("Extracting installation files...")})

			deleteDirectory(A_Temp . "\Simulator Controller")

			try {
				RunWait("PowerShell.exe -Command Expand-Archive -LiteralPath '" . A_Temp . "\Simulator Controller.zip' -DestinationPath '" . A_Temp . "\Simulator Controller'", , "Hide")
			}
			catch Any as exception {
				logError(exception)

				OnMessage(0x44, translateOkButton)
				MsgBox(translate("The version repository is currently unavailable. Please try again later."), translate("Error"), 262160)
				OnMessage(0x44, translateOkButton, 0)

				ExitApp(0)
			}

			deleteFile(A_Temp . "\Simulator Controller.zip")

			directory := (A_Temp . "\Simulator Controller")

			if FileExist(directory . "\Simulator Controller")
				directory .= "\Simulator Controller"

			showProgress({message: translate("Unblocking Applications and DLLs...")})

			currentDirectory := A_WorkingDir

			try {
				SetWorkingDir(directory "\Binaries")

				RunWait("Powershell -Command Get-ChildItem -Path '.' | Unblock-File", , "Hide")
			}
			catch Any as exception {
				logError(exception)

				OnMessage(0x44, translateOkButton)
				MsgBox(translate("An error occured while starting the automatic instalation due to Windows security restrictions. You can try a manual installation."), translate("Error"), 262160)
				OnMessage(0x44, translateOkButton, 0)

				Run("https://github.com/SeriousOldMan/Simulator-Controller#latest-release-builds")

				ExitApp(0)
			}
			finally {
				SetWorkingDir(currentDirectory)
			}

			updateTask.stop()

			showProgress({progress: 90, message: translate("Preparing installation...")})

			Sleep(1000)

			showProgress({progress: 100, message: translate("Starting installation...")})

			index := inList(A_Args, "-Start")

			try {
				if index {
					start := A_Args[index + 1]

					Run("`"" . directory . "\Binaries\Simulator Tools.exe`" -NoUpdate -Install -Start `"" . start . "`"")
				}
				else
					Run("`"" . directory . "\Binaries\Simulator Tools.exe`" -NoUpdate -Install")
			}
			catch Any as exception {
				OnMessage(0x44, translateOkButton)
				MsgBox(translate("An error occured while starting the automatic instalation due to Windows security restrictions. You can try a manual installation."), translate("Error"), 262160)
				OnMessage(0x44, translateOkButton, 0)

				Run("https://github.com/SeriousOldMan/Simulator-Controller#latest-release-builds")
			}

			Sleep(1000)

			hideProgress()
		}
		else
			Run("https://github.com/SeriousOldMan/Simulator-Controller#latest-release-builds")
	}

	ExitApp(0)
}


;;;-------------------------------------------------------------------------;;;
;;;                           Initialization Section                        ;;;
;;;-------------------------------------------------------------------------;;;

downloadSimulatorController()