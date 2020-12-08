;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Build & Maintenance Tool        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2020) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#SingleInstance Force			; Ony one instance allowed
#NoEnv							; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn							; Enable warnings to assist with detecting common errors.

SendMode Input					; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.

SetBatchLines -1				; Maximize CPU utilization
ListLines Off					; Disable execution history

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Tools.ico
;@Ahk2Exe-ExeName Simulator Tools.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kCleanupTargets = [["Binaries Folder", false, 1000, kBinariesDirectory]
						, ["Config Folder", false, 1000, kConfigDirectory]
						, ["Logs Folder", false, 1000, kLogsDirectory]
						, ["Simulator Controller.ini", false, 1000, kControllerConfigurationFile]
						, ["Simulator Tools.ini", false, 1000, kToolsConfigurationFile]
						, ["*.bak Files", true, 1000]]

global kBuildTargets = [["Simulator Controller", true, 3000
					   , kSourcesDirectory . "Controller\Simulator Controller.ahk", kBinariesDirectory . "Simulator Controller.exe"
					   , [kSourcesDirectory . "Controller\Plugins\"]]
					  , ["Simulator Configuration", true, 1000
					   , kSourcesDirectory . "Startup\Simulator Configuration.ahk", kBinariesDirectory . "Simulator Configuration.exe"
					   , [kSourcesDirectory . "Startup\Libraries\"]]
					  , ["Simulator Startup", true, 2000
					   , kSourcesDirectory . "Startup\Simulator Startup.ahk", kBinariesDirectory . "Simulator Startup.exe"
					   , [kSourcesDirectory . "Startup\Libraries\"]]
					  , ["Simulator Setup", true, 2000
					   , kSourcesDirectory . "Tools\Simulator Setup.ahk", kBinariesDirectory . "Simulator Setup.exe"]
					  , ["Simulator Tools", true, 2000
					   , kSourcesDirectory . "Tools\Simulator Tools.ahk", kBinariesDirectory . "Simulator Tools.exe"]]

global kBuildProgressSteps = kCleanupTargets.Length() + kBuildTargets.Length() + 1

global kCompiler = kAHKDirectory . "Compiler\ahk2exe.exe"

global kSave = "save"
global kRevert = "revert"
global kCancel = "cancel"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vCleanupSettings = Object()
global vBuildSettings = Object()

global vBuildProgress = 0


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

checkFileDependency(file, modification) {
	logMessage(kLogInfo, "Checking file " . file . " for modification")
	
	FileGetTime lastModified, %file%, M
	
	if (lastModified > modification) {
		logMessage(kLogInfo, "File " . file . " found more recent than " . modification)
	
		return true
	}
	else
		return false
}

checkDirectoryDependency(directory, modification) {
	logMessage(kLogInfo, "Checking all files in " . directory)
	
	files := []
	
	Loop Files, % directory . "*.ahk", R
	{
		files.Push(A_LoopFilePath)
	}
	
	for ignore, file in files
		if checkFileDependency(file, modification)
			return true
	
	return false
}

checkLibraryDependency(modification) {
	return checkDirectoryDependency(kIncludesDirectory, modification)
}

checkDependencies(dependencies, modification) {
	for ignore, fileOrFolder in dependencies {
		attributes := FileExist(fileOrFolder)
	
		if InStr(attributes, "D") {
			if checkDirectoryDependency(fileOrFolder, modification)
				return true
		}
		else if attributes {
			if checkFileDependency(fileOrFolder, modification)
				return true
		}
	}
	
	return false
}

readToolsConfiguration(ByRef cleanupSettings, ByRef buildSettings) {
	configuration := readConfiguration(kToolsConfigurationFile)
	
	cleanupSettings := Object()
	buildSettings := Object()
	
	for ignore, target in kCleanupTargets {
		key := target[1]
	
		cleanupSettings[key] := getConfigurationValue(configuration, "Cleanup", key, target[2])
	}
	
	for ignore, target in kBuildTargets {
		key := target[1]
	
		buildSettings[key] := getConfigurationValue(configuration, "Build", key, target[2])
	}
	
	if A_IsCompiled
		buildSettings["Simulator Tools"] := false
}

writeToolsConfiguration(cleanupSettings, buildSettings) {
	configuration := newConfiguration()
	
	for ignore, target in kCleanupTargets {
		key := target[1]
	
		setConfigurationValue(configuration, "Cleanup", key, cleanupSettings[key])
	}
	
	for ignore, target in kBuildTargets {
		key := target[1]
	
		setConfigurationValue(configuration, "Build", key, buildSettings[key])
	}
	
	writeConfiguration(kToolsConfigurationFile, configuration)
}

saveTargets() {
	editTargets(kSave)
}

cancelTargets() {
	editTargets(kCancel)
}

editTargets(command := "") {
	static result
	
	static cleanBinaries
	static cleanConfig
	static cleanLogs
	static cleanStartupIni
	static cleanToolsIni
	static cleanBakFiles
	static buildNeuralNetwork
	static buildSimulatorController
	static buildSimulatorConfiguration
	static buildSimulatorStartup
	static buildSimulatorSetup
	static buildSimulatorTools
	
	if (command == kSave) {
		Gui TE:Submit
		
		startupSettings := Object()
		
		vCleanupSettings["Binaries Folder"] := cleanBinaries
		vCleanupSettings["Config Folder"] := cleanConfig
		vCleanupSettings["Logs Folder"] := cleanLogs
		vCleanupSettings["Simulator Controller.ini"] := cleanStartupIni
		vCleanupSettings["Simulator Tools.ini"] := cleanToolsIni
		vCleanupSettings["*.bak Files"] := cleanBakFiles
		
		vBuildSettings["Simulator Controller"] := buildSimulatorController
		vBuildSettings["Simulator Configuration"] := buildSimulatorConfiguration
		vBuildSettings["Simulator Startup"] := buildSimulatorStartup
		vBuildSettings["Simulator Setup"] := buildSimulatorSetup
		vBuildSettings["Simulator Tools"] := buildSimulatorTools
		
		writeToolsConfiguration(vCleanupSettings, vBuildSettings)
		
		Gui TE:Destroy
		
		result := 1
	}
	else if (command == kRevert) {
		Gui TE:Destroy
		
		result := 2
	}
	else if (command == kCancel) {
		Gui TE:Destroy
		
		result := 3
	}
	else {
		result := false
		
		cleanBinaries := vCleanupSettings["Binaries Folder"]
		cleanConfig := vCleanupSettings["Config Folder"]
		cleanLogs := vCleanupSettings["Logs Folder"]
		cleanStartupIni := vCleanupSettings["Simulator Controller.ini"]
		cleanToolsIni := vCleanupSettings["Simulator Tools.ini"]
		cleanBakFiles := vCleanupSettings["*.bak Files"]
		
		buildSimulatorController := vBuildSettings["Simulator Controller"]
		buildSimulatorConfiguration := vBuildSettings["Simulator Configuration"]
		buildSimulatorStartup := vBuildSettings["Simulator Startup"]
		buildSimulatorSetup := vBuildSettings["Simulator Setup"]
		buildSimulatorTools := A_IsCompiled ? false : vBuildSettings["Simulator Tools"]
		
		Gui TE:-border -Caption
		Gui TE:Color, D0D0D0
	
		Gui TE:Font, Bold, Arial
	
		Gui TE:Add, Text, w220 Center, Modular Simulator Controller System 
		
		Gui TE:Font, Norm, Arial
		Gui TE:Font, Italic, Arial
	
		Gui TE:Add, Text, YP+20 w220 Center, Build Targets
	
		Gui TE:Font, Norm, Arial
		Gui TE:Font, Italic, Arial
	
		Gui TE:Add, GroupBox, YP+30 w220 h120, Cleanup
	
		Gui TE:Font, Norm, Arial
	
		Gui TE:Add, CheckBox, YP+20 XP+10 Checked%cleanBinaries% vcleanBinaries, Binaries Folder
		Gui TE:Add, CheckBox, Checked%cleanConfig% vcleanConfig, Config Folder
		Gui TE:Add, CheckBox, Checked%cleanLogs% vcleanLogs, Logs Folder
		Gui TE:Add, CheckBox, Checked%cleanStartupIni% vcleanStartupIni, Simulator Controller.ini
		Gui TE:Add, CheckBox, Checked%cleanToolsIni% vcleanToolsIni, Simulator Tools.ini
		Gui TE:Add, CheckBox, Checked%cleanBakFiles% vcleanBakFiles, *.bak Files
	
		Gui TE:Font, Norm, Arial
		Gui TE:Font, Italic, Arial
	
		Gui TE:Add, GroupBox, XP-10 YP+30 w220 h140, Compile
	
		Gui TE:Font, Norm, Arial
	
		Gui TE:Add, CheckBox, YP+20 XP+10 Checked%buildSimulatorController% vbuildSimulatorController, Simulator Controller
		Gui TE:Add, CheckBox, Checked%buildSimulatorConfiguration% vbuildSimulatorConfiguration, Simulator Configuration
		Gui TE:Add, CheckBox, Checked%buildSimulatorStartup% vbuildSimulatorStartup, Simulator Startup
		Gui TE:Add, CheckBox, Checked%buildSimulatorSetup% vbuildSimulatorSetup, Simulator Setup
		
		disabledState := A_IsCompiled ? "Disabled" : ""
		
		Gui TE:Add, CheckBox, %disabledState% Checked%buildSimulatorTools% vbuildSimulatorTools, Simulator Tools
	 
		Gui TE:Add, Button, Default X10 Y+20 w100 gsaveTargets, &Build
		Gui TE:Add, Button, X+20 w100 gcancelTargets, &Cancel
	
		Gui TE: Margin, 10, 10
		Gui TE: show, AutoSize Center
		
		Loop
			Sleep 1000
		until result
	
		return ((result == 1) || (result == 2))
	}
}

runCleanTargets() {
	for ignore, target in kCleanupTargets {
		targetName := target[1]
	
		if vCleanupSettings[targetName] {
			Progress %vBuildProgress%, % "Cleaning " . targetName . "..."
			
			logMessage(kLogInfo, "Cleaning " . targetName)
	
			if (target.Length() > 3) {
				fileOrFolder := target[4]
				
				if (InStr(FileExist(fileOrFolder), "D")) {
					currentDirectory := A_WorkingDir
			
					SetWorkingDir %fileOrFolder%
				
					Loop Files, *.*
						FileDelete %A_LoopFilePath%
				
					SetWorkingDir %currentDirectory%
				}
				else if (FileExist(fileOrFolder) != "") {
					FileDelete %fileOrFolder%
				}
			}
			else if (targetName == "*.bak Files") {
				currentDirectory := A_WorkingDir
			
				SetWorkingDir %kHomeDirectory%
				
				Loop Files, *.ahk.bak, R
				{
					FileDelete %A_LoopFilePath%
				
					Progress %vBuildProgress%, % "Deleting " . A_LoopFileName . "..."
			
					Sleep 100
				}
				
				SetWorkingDir %currentDirectory%
			}
				
			Sleep target[3]
		}
		else	
			Sleep 100
				
		vBuildProgress += Round(100 / kBuildProgressSteps)
			
		Progress %vBuildProgress%
	}
}

runBuildTargets() {
	for ignore, target in kBuildTargets {
		targetName := target[1]
		wait := target[3]
	
		if vBuildSettings[targetName] {
			Progress %vBuildProgress%, % "Compiling " . targetName . "..."
			
			logMessage(kLogInfo, "Building " . targetName)
	
			if (target.Length() > 3) {
				build := false
				
				targetSource := target[4]
				targetBinary := target[5]
				
				FileGetTime srcLastModified, %targetSource%, M
				FileGetTime binLastModified, %targetBinary%, M
				
				if binLastModified {
					build := (build || (ErrorLevel || (srcLastModified > binLastModified)))
					build := (build || checkLibraryDependency(binLastModified))
				
					if (!build && (target.Length() > 5))
						build := checkDependencies(target[6], binLastModified)
				}
				else
					build := true
				
				if build {
					logMessage(kLogInfo, targetName . " or dependent files out of date - needs recompile")
					logMessage(kLogInfo, "Compiling " . targetSource)
	
					try {
						RunWait % kCompiler . " /in """ . targetSource . """"
					}
					catch exception {
						logMessage(kLogCritical, "Cannot compile " . targetSource . " - source file or AHK Compiler (" . kCompiler . ") not found")
					
						SplashTextOn 800, 60, Modular Simulator Controller System - Compiler, Cannot compile %targetSource%: `n`nSource file or AHK Compiler (%kCompiler%) not found...
						
						Sleep 5000
						
						SplashTextOff
					}
					
					SplitPath targetBinary, compiledFile
					SplitPath targetSource, , sourceDirectory 
					
					targetBinary := sourceDirectory . "\" . compiledFile
					
					FileCreateDir % SubStr(kBinariesDirectory, 1, StrLen(kBinariesDirectory) - 1)
					FileMove %targetBinary%, %kBinariesDirectory%, 1
				}
				else
					wait := 100
			}
				
			Sleep %wait%
		}
		else
			Sleep 100
		
		vBuildProgress += Round(100 / kBuildProgressSteps)
			
		Progress %vBuildProgress%
	}
}

prepareTargets(targets, settings) {
	for ignore, target in targets {
		targetName := target[1]
	
		vBuildProgress +=1
		
		Progress, %vBuildProgress%, % targetName . ": " . (settings[targetName] ? "Yes" : "No")
	
		Sleep 100
	}
}

runTargets() {
	if (!FileExist(kToolsConfigurationFile) || GetKeyState("Ctrl")) {
		readToolsConfiguration(vCleanupSettings, vBuildSettings)
	
		if !editTargets()
			ExitApp 0
	}
	else
		readToolsConfiguration(vCleanupSettings, vBuildSettings)
	
	icon := kIconsDirectory . "Tools.ico"
	
	Menu Tray, Icon, %icon%, , 1
	
	showSplash("McLaren 720s GT3.jpg", false)
	
	Sleep 1000
	
	x := Round((A_ScreenWidth - 300) / 2)
	y := A_ScreenHeight - 150
	
	Progress 1:B w300 x%x% y%y% FS8 CWD0D0D0 CBGreen, %A_Space%, Preparing Targets

	prepareTargets(kCleanupTargets, vCleanupSettings)
	prepareTargets(kBuildTargets, vBuildSettings)
	
	Sleep 100
	
	Progress, , %A_Space%, Running Targets
	
	runCleanTargets()
	runBuildTargets()
		
	Progress 100, Done
	
	Sleep 500
	
	Progress Off
	
	ExitApp 0
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

runTargets()

return


;;;-------------------------------------------------------------------------;;;
;;;                         Hotkey & Label Section                          ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Escape::                   Cancel Build                                 ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
Escape::
protectionOn()

try {
	SoundPlay *32
	OnMessage(0x44, "translateMsgBoxButtons")
	MsgBox 262180, Simulator Build, Cancel target processing?
	OnMessage(0x44, "")
	
	IfMsgBox Yes
		ExitApp 0
}
finally {
	protectionOff()
}

return