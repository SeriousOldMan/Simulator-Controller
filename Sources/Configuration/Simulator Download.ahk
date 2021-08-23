;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Simulator Download              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Installer.ico
;@Ahk2Exe-ExeName Simulator Download.exe

				
;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

updateProgress(max) {
	static counter := 0
	
	counter := Min(counter + 1, max)
	
	showProgress({progress: counter})
}

downloadSimulatorController() {
	URLDownloadToFile https://www.dropbox.com/s/txa8muw9j3g66tl/VERSION?dl=1, %kTempDirectory%VERSION
			
	release := readConfiguration(kTempDirectory . "VERSION")
	version := getConfigurationValue(release, "Release", "Version", getConfigurationValue(release, "Version", "Release", false))

	if version {
		version := StrSplit(version, "-", , 2)
		current := StrSplit(kVersion, "-", , 2)
		
		dottedVersion := version[1]
		
		versionPostfix := version[2]
		currentPostfix := current[2]
		
		version := values2String("", string2Values(".", version[1])*)
		current := values2String("", string2Values(".", current[1])*)
		
		download := getConfigurationValue(release, "Release", "Download", false)
				
		if download {
			x := Round((A_ScreenWidth - 300) / 2)
			y := A_ScreenHeight - 150
			
			showProgress({x: x, y: y, color: "Green", title: translate(inList(A_Args, "-Update") ? "Updating Simulator Controller" : "Installing Simulator Controller"), message: translate("Downloading Version ") . dottedVersion})

			updateProgress := Func("updateProgress").Bind(45)
			
			SetTimer %updateProgress%, 1500
			
			URLDownloadToFile %download%, %A_Temp%\Simulator Controller.zip
			
			SetTimer %updateProgress%, Off
			
			updateProgress := Func("updateProgress").Bind(90)
			
			SetTimer %updateProgress%, 1000
			
			showProgress({message: translate("Extracting installation files...")})
			
			try {
				FileRemoveDir %A_Temp%\Simulator Controller, true
			}
			catch exception {
				; ignore
			}
			
			RunWait PowerShell.exe -Command Expand-Archive -LiteralPath '%A_Temp%\Simulator Controller.zip' -DestinationPath '%A_Temp%\Simulator Controller', , Hide
			
			try {
				FileDelete %A_Temp%\Simulator Controller.zip
			}
			catch exception {
				; ignore
			}
			
			SetTimer %updateProgress%, Off
			
			showProgress({progress: 90, message: translate("Preparing installation...")})
			
			Sleep 1000
			
			showProgress({progress: 100, message: translate("Starting installation...")})
			
			index := inList(A_Args, "-Start")
			
			if index {
				start := A_Args[index + 1]
				
				Run "%A_Temp%\Simulator Controller\Binaries\Simulator Tools.exe" -NoUpdate -Install -Start "%start%"
			}
			else
				Run "%A_Temp%\Simulator Controller\Binaries\Simulator Tools.exe" -NoUpdate -Install
			
			Sleep 1000
			
			hideProgress()
		}
		else
			Run https://github.com/SeriousOldMan/Simulator-Controller#latest-release-builds
				
		ExitApp 0
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                           Initialization Section                        ;;;
;;;-------------------------------------------------------------------------;;;

downloadSimulatorController()