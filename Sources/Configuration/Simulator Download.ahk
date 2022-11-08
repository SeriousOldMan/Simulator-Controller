;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Simulator Download              ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Installer.ico
;@Ahk2Exe-ExeName Simulator Download.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Task.ahk


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
	local options, index, title, cState, sState, devVersion, release, version, download, updateTask
	local directory, currentDirectory, start, ignore, url, error

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Simulator Download

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
			options .= (" -Start """ . A_Args[index + 1] . """")

		try {
			if A_IsCompiled
				Run *RunAs "%A_ScriptFullPath%" /restart %options%
			else
				Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%" %options%
		}
		catch exception {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			title := translate("Error")
			MsgBox 262160, %title%, % translate("An error occured while starting the automatic installation due to Windows security restrictions. You can try a manual installation.")
			OnMessage(0x44, "")
		}

		ExitApp 0
	}

	cState := GetKeyState("Control", "P")
	sState := GetKeyState("Shift", "P")

	devVersion := (cState != false)

	try {
		URLDownloadToFile https://www.dropbox.com/s/txa8muw9j3g66tl/VERSION?dl=1, %kTempDirectory%VERSION

		if ErrorLevel
			throw "No valid installation file (Error: " . ErrorLevel . ")..."
	}
	catch exception {
		logError(exception, true)

		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
		title := translate("Error")
		MsgBox 262160, %title%, % translate("The version repository is currently unavailable. Please try again later.")
		OnMessage(0x44, "")

		ExitApp 0
	}

	release := readConfiguration(kTempDirectory . "VERSION")
	version := getConfigurationValue(release, (devVersion ? "Development" : "Release"), "Version", getConfigurationValue(release, "Version", "Release", false))

	if version {
		if devVersion
			download := getConfigurationValue(release, "Development", "Download", false)
		else
			download := getConfigurationValue(release, "Release", "Download", false)

		if download {
			showProgress({color: "Green", title: translate(inList(A_Args, "-Update") ? "Updating Simulator Controller" : "Installing Simulator Controller"), message: translate("Downloading Version ") . version})

			updateTask := new PeriodicTask(Func("updateProgress").Bind(45), 1500)

			updateTask.start()

			error := false

			for ignore, url in string2Values(";", download)
				try {
					URLDownloadToFile %download%, %A_Temp%\Simulator Controller.zip

					if ErrorLevel {
						error := true

						throw "No valid installation file (Error: " . ErrorLevel . ")..."
					}
					else {
						error := false

						break
					}
				}
				catch exception {
					logError(exception, true)
				}

			if error {
				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
				title := translate("Error")
				MsgBox 262160, %title%, % translate("The version repository is currently unavailable. Please try again later.")
				OnMessage(0x44, "")

				ExitApp 0
			}

			updateTask.stop()

			updateTask := new PeriodicTask(Func("updateProgress").Bind(90), 1000)

			updateTask.start()

			showProgress({message: translate("Extracting installation files...")})

			deleteDirectory(A_Temp . "\Simulator Controller")

			RunWait PowerShell.exe -Command Expand-Archive -LiteralPath '%A_Temp%\Simulator Controller.zip' -DestinationPath '%A_Temp%\Simulator Controller', , Hide

			deleteFile(A_Temp . "\Simulator Controller.zip")

			directory := (A_Temp . "\Simulator Controller")

			if FileExist(directory . "\Simulator Controller")
				directory .= "\Simulator Controller"

			showProgress({message: translate("Unblocking Applications and DLLs...")})

			currentDirectory := A_WorkingDir

			try {
				SetWorkingDir %directory%

				RunWait *RunAs Powershell -Command Get-ChildItem -Path '.' -Recurse | Unblock-File, , Hide
			}
			finally {
				SetWorkingDir %currentDirectory%
			}

			updateTask.stop()

			showProgress({progress: 90, message: translate("Preparing installation...")})

			Sleep 1000

			showProgress({progress: 100, message: translate("Starting installation...")})

			index := inList(A_Args, "-Start")

			try {
				if index {
					start := A_Args[index + 1]

					Run *RunAs "%directory%\Binaries\Simulator Tools.exe" -NoUpdate -Install -Start "%start%"
				}
				else
					Run *RunAs "%directory%\Binaries\Simulator Tools.exe" -NoUpdate -Install
			}
			catch exception {
				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
				title := translate("Error")
				MsgBox 262160, %title%, % translate("An error occured while starting the automatic instalation due to Windows security restrictions. You can try a manual installation.")
				OnMessage(0x44, "")
			}

			Sleep 1000

			hideProgress()
		}
		else
			Run https://github.com/SeriousOldMan/Simulator-Controller#latest-release-builds
	}

	ExitApp 0
}


;;;-------------------------------------------------------------------------;;;
;;;                           Initialization Section                        ;;;
;;;-------------------------------------------------------------------------;;;

downloadSimulatorController()