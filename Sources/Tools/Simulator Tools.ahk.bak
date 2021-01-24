;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Build & Maintenance Tool        ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Tools.ico
;@Ahk2Exe-ExeName Simulator Tools.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kToolsConfigurationFile = "Simulator Tools.ini"
global kToolsTargetsFile = "Simulator Tools.targets"

global kUpdateMessages = {updateToV15: "Updating configuration to "
						, updateConfigurationForV20: "Updating configuration to ", updateTranslations: "Updating translations to "
						, updatePluginLabels: "Updating plugin labels to ", updateACCPluginForV20: "Updating ACC plugin to "
						, updateConfigurationForV203: "Updating configuration to "}

global kCompiler = kAHKDirectory . "Compiler\ahk2exe.exe"

global kSave = "save"
global kRevert = "revert"
global kCancel = "cancel"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vUpdateTargets = []
global vCleanupTargets = []
global vCopyTargets = []
global vBuildTargets = []
global vSplashTheme = false

global vTargetCounts = 0

global vUpdateSettings = Object()
global vCleanupSettings = Object()
global vCopySettings = Object()
global vBuildSettings = Object()


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

readToolsConfiguration(ByRef updateSettings, ByRef cleanupSettings, ByRef copySettings, ByRef buildSettings, ByRef splashTheme) {
	targets := readConfiguration(kToolsTargetsFile)
	configuration := readConfiguration(kToolsConfigurationFile)
	updateConfiguration := readConfiguration(getFileName("UPDATES", kUserConfigDirectory))
	
	updateSettings := Object()
	cleanupSettings := Object()
	copySettings := Object()
	buildSettings := Object()
	
	for target, rule in getConfigurationSectionValues(targets, "Update", Object())
		if !getConfigurationValue(updateConfiguration, "Processed", target, false)
			updateSettings[target] := true
	
	for target, rule in getConfigurationSectionValues(targets, "Cleanup", Object())
		cleanupSettings[target] := getConfigurationValue(configuration, "Cleanup", target, InStr(target, "*.ahk") ? true : false)
	
	for target, rule in getConfigurationSectionValues(targets, "Copy", Object())
		copySettings[target] := getConfigurationValue(configuration, "Copy", target, true)
	
	for target, rule in getConfigurationSectionValues(targets, "Build", Object())
		buildSettings[target] := getConfigurationValue(configuration, "Build", target, true)
	
	splashTheme := getConfigurationValue(configuration, "General", "Splash Theme", false)
	
	if A_IsCompiled
		buildSettings["Simulator Tools"] := false
}

writeToolsConfiguration(updateSettings, cleanupSettings, copySettings, buildSettings, splashTheme) {
	configuration := newConfiguration()
	
	for target, setting in cleanupSettings
		setConfigurationValue(configuration, "Cleanup", target, setting)
		
	for target, setting in copySettings
		setConfigurationValue(configuration, "Copy", target, setting)
		
	for target, setting in buildSettings
		setConfigurationValue(configuration, "Build", target, setting)
	
	setConfigurationValue(configuration, "General", "Splash Theme", splashTheme)
	
	writeConfiguration(kToolsConfigurationFile, configuration)
}

saveTargets() {
	editTargets(kSave)
}

cancelTargets() {
	editTargets(kCancel)
}

moveEditor() {
	moveByMouse("TE")
}

editTargets(command := "") {
	static result
	
	static updateVariable1
	static updateVariable2
	static updateVariable3
	static updateVariable4
	static updateVariable5
	static updateVariable6
	static updateVariable7
	static updateVariable8
	
	static cleanupVariable1
	static cleanupVariable2
	static cleanupVariable3
	static cleanupVariable4
	static cleanupVariable5
	static cleanupVariable6
	static cleanupVariable7
	static cleanupVariable8
	
	static copyVariable1
	static copyVariable2
	static copyVariable3
	static copyVariable4
	static copyVariable5
	static copyVariable6
	static copyVariable7
	static copyVariable8
	
	static buildVariable1
	static buildVariable2
	static buildVariable3
	static buildVariable4
	static buildVariable5
	static buildVariable6
	static buildVariable7
	static buildVariable8
	
	static splashTheme
	
	if (command == kSave) {
		Gui TE:Submit
		
		for target, setting in vUpdateSettings {
			updateVariable := "updateVariable" . A_Index
			
			vUpdateSettings[target] := %updateVariable%
		}
		
		for target, setting in vCleanupSettings {
			cleanupVariable := "cleanupVariable" . A_Index
			
			vCleanupSettings[target] := %cleanupVariable%
		}
		
		for target, setting in vCopySettings {
			copyVariable := "copyVariable" . A_Index
			
			vCopySettings[target] := %copyVariable%
		}
		
		for target, setting in vBuildSettings {
			buildVariable := "buildVariable" . A_Index
			
			vBuildSettings[target] := %buildVariable%
		}
		
		for target, setting in vCopySettings {
			copyVariable := "copyVariable" . A_Index
			
			vCopySettings[target] := %copyVariable%
		}
		
		vSplashTheme := (splashTheme == translate("None")) ? false : splashTheme
		
		writeToolsConfiguration(vUpdateSettings, vCleanupSettings, vCopySettings, vBuildSettings, vSplashTheme)
		
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
		
		if (vUpdateSettings.Length() > 8)
			Throw "Too many update targets detected in editTargets..."
		
		if (vCleanupSettings.Length() > 8)
			Throw "Too many cleanup targets detected in editTargets..."
		
		if (vCopySettings.Length() > 8)
			Throw "Too many copy targets detected in editTargets..."
		
		if (vBuildSettings.Length() > 8)
			Throw "Too many build targets detected in editTargets..."
		
		Gui TE:-border -Caption
		Gui TE:Color, D0D0D0
	
		Gui TE:Font, Bold, Arial
		
		Gui TE:Add, Text, w220 Center gmoveEditor, % translate("Modular Simulator Controller System") 
		
		Gui TE:Font, Norm, Arial
		Gui TE:Font, Italic, Arial
	
		Gui TE:Add, Text, YP+20 w220 Center, % translate("Targets")
	
		Gui TE:Font, Norm, Arial
		Gui TE:Font, Italic, Arial
		
		if (vupdateSettings.Count() > 0) {
			updateHeight := 20 + (vupdateSettings.Count() * 20)
			
			if (updateHeight == 20)
				updateHeight := 40
				
			Gui TE:Add, GroupBox, YP+30 w220 h%updateHeight%, % translate("Update")
		
			Gui TE:Font, Norm, Arial
		
			if (vUpdateSettings.Count() > 0)
				for target, setting in vUpdateSettings {
					option := ""
					
					if (A_Index == 1)
						option := option . " YP+20 XP+10"
						
					Gui TE:Add, CheckBox, %option% Disabled Checked%setting% vupdateVariable%A_Index%, %target%
				}
			else
				Gui TE:Add, Text, YP+20 XP+10, % translate("No updates required...")
		
			Gui TE:Font, Norm, Arial
			Gui TE:Font, Italic, Arial
			
			cleanupPosOption := "XP-10"
		}
		else
			cleanupPosOption := ""
		
		cleanupHeight := 20 + (vCleanupSettings.Count() * 20)
		
		if (cleanupHeight == 20)
			cleanupHeight := 40
			
		Gui TE:Add, GroupBox, %cleanupPosOption% YP+30 w220 h%cleanupHeight%, % translate("Cleanup")
	
		Gui TE:Font, Norm, Arial
	
		if (vCleanupSettings.Count() > 0)
			for target, setting in vCleanupSettings {
				option := ""
				
				if (A_Index == 1)
					option := option . " YP+20 XP+10"
					
				Gui TE:Add, CheckBox, %option% Checked%setting% vcleanupVariable%A_Index%, %target%
			}
		else
			Gui TE:Add, Text, YP+20 XP+10, % translate("No targets found...")
	
		Gui TE:Font, Norm, Arial
		Gui TE:Font, Italic, Arial
	
		copyHeight := 20 + (vCopySettings.Count() * 20)
		
		if (copyHeight == 20)
			copydHeight := 40
			
		Gui TE:Add, GroupBox, XP-10 YP+30 w220 h%copyHeight%, % translate("Copy")
	
		Gui TE:Font, Norm, Arial
	
		if (vCopySettings.Count() > 0)
			for target, setting in vCopySettings {
				option := ""
				
				if (A_Index == 1)
					option := option . " YP+20 XP+10"
					
				Gui TE:Add, CheckBox, %option% Checked%setting% vcopyVariable%A_Index%, %target%
			}
		else
			Gui TE:Add, Text, YP+20 XP+10, % translate("No targets found...")
		
		Gui TE:Font, Norm, Arial
		Gui TE:Font, Italic, Arial
	
		buildHeight := 20 + (vBuildSettings.Count() * 20)
		
		if (buildHeight == 20)
			buildHeight := 40
			
		Gui TE:Add, GroupBox, XP-10 YP+30 w220 h%buildHeight%, % translate("Compile")
	
		Gui TE:Font, Norm, Arial
	
		if (vBuildSettings.Count() > 0)
			for target, setting in vBuildSettings {
				option := ""
				
				if (A_Index == 1)
					option := option . " YP+20 XP+10"
					
				if (target == "Simulator Tools")
					option := option . (A_IsCompiled ? " Disabled" : "")
					
				Gui TE:Add, CheckBox, %option% Checked%setting% vbuildVariable%A_Index%, %target%
			}
		else
			Gui TE:Add, Text, YP+20 XP+10, % translate("No targets found...")
	 
		themes := getAllThemes()
		chosen := (vSplashTheme ? inList(themes, vSplashTheme) + 1 : 1)
		themes := translate("None") "|" + values2String("|", themes*)
		
		Gui TE:Add, Text, X10 Y+20, % translate("Theme")
		Gui TE:Add, DropDownList, X90 YP-5 w140 Choose%chosen% vsplashTheme, %themes%
		
		Gui TE:Add, Button, Default X10 y+20 w100 gsaveTargets, % translate("Run")
		Gui TE:Add, Button, X+20 w100 gcancelTargets, % translate("&Cancel")
	
		Gui TE: Margin, 10, 10
		Gui TE: show, AutoSize Center
		
		Loop
			Sleep 1000
		until result
	
		return ((result == 1) || (result == 2))
	}
}

updateTranslations() {
	languages := availableLanguages()
	
	for ignore, translationFileName in getFileNames("Translations.*", kUserConfigDirectory) {
		SplitPath translationFileName, , , languageCode
		
		translations := readTranslations(languageCode)
		
		if FileExist(getFileName(kConfigDirectory . "Translations." . languageCode))
			originalLanguageCode := languageCode
		else
			originalLanguageCode := "EN"
			
		for original, translation in readTranslations(originalLanguageCode, false)
			if !translations.HasKey(original)
				translations[original] := translation
				
		writeTranslations(languageCode, languages[languageCode], translations)
	}
}

updatePluginLabels() {
	userPluginLabelsFile := getFileName("Controller Plugin Labels.ini", kUserConfigDirectory)
	userPluginLabels := readConfiguration(userPluginLabelsFile)
	bundledPluginLabels := readConfiguration(getFileName("Controller Plugin Labels.ini", kConfigDirectory))
	
	for section, keyValues in bundledPluginLabels
		for key, value in keyValues
			if !getConfigurationValue(userPluginLabels, section, key, false)
				setConfigurationValue(userPluginLabels, section, key, value)
	
	writeConfiguration(userPluginLabelsFile, userPluginLabels)
}

updateCustomCalls(startNumber, endNumber) {
	userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	userConfiguration := readConfiguration(userConfigurationFile)
	
	if (userConfiguration.Count() > 0) {
		bundledConfiguration := readConfiguration(getFileName(kSimulatorConfigurationFile, kConfigDirectory))
	
		customCallIndex := startNumber
		
		Loop {
			key := "Custom." . customCallIndex . ".Call"
			
			if !getConfigurationValue(userConfiguration, "Controller Functions", key, false) {
				setConfigurationValue(userConfiguration, "Controller Functions", key, getConfigurationValue(bundledConfiguration, "Controller Functions", key))
				
				key .= " Action"
				
				setConfigurationValue(userConfiguration, "Controller Functions", key, getConfigurationValue(bundledConfiguration, "Controller Functions", key))
			}
			
			customCallIndex += 1
		} until (customCallIndex > endNumber)
	}
	
	writeConfiguration(userConfigurationFile, userConfiguration)
}

updateConfigurationForV20() {
	updateCustomCalls(13, 32)
}

updateConfigurationForV203() {
	updateCustomCalls(32, 34)
}

updateACCPluginForV20() {
	userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	userConfiguration := readConfiguration(userConfigurationFile)
	
	if (userConfiguration.Count() > 0) {
		bundledACCPlugin := getConfigurationValue(readConfiguration(getFileName(kSimulatorConfigurationFile, kConfigDirectory)), "Plugins", "ACC")
		userACCPlugin := getConfigurationValue(userConfiguration, "Plugins", "ACC", false)
		
		if userACCPlugin {
			userACCPlugin := string2Values("|", userACCPlugin)
			
			if (userACCPlugin[3] == "") {
				userACCPlugin[3] := string2Values("|", bundledACCPlugin)[3]
				
				setConfigurationValue(userConfiguration, "Plugins", "ACC", values2String("|", userACCPlugin*))
				
				writeConfiguration(userConfigurationFile, userConfiguration)
			}
		}
	}
}

updateToV15(targetName, ByRef buildProgress) {
}

checkFileDependency(file, modification) {
	logMessage(kLogInfo, translate("Checking file ") . file . translate(" for modification"))
	
	FileGetTime lastModified, %file%, M
	
	if (lastModified > modification) {
		logMessage(kLogInfo, translate("File ") . file . translate(" found more recent than ") . modification)
	
		return true
	}
	else
		return false
}

checkDirectoryDependency(directory, modification) {
	logMessage(kLogInfo, translate("Checking all files in ") . directory)
	
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

runUpdateTargets(ByRef buildProgress) {
	for ignore, target in vUpdateTargets {
		targetName := target[1]
	
		if !kSilentMode
			Progress %buildProgress%, % translate("Updating to ") . targetName . translate("...")
			
		logMessage(kLogInfo, translate("Updating to ") . targetName)
		
		Sleep 1000
		
		progressStep := Round((100 / (vTargetsCount + 1)) / target[2].Length())
		
		for ignore, updateFunction in target[2] {
			if !kSilentMode
				Progress %buildProgress%, % translate(kUpdateMessages[updateFunction]) . targetName . translate("...")
					
			%updateFunction%()
			
			Sleep 1000
			
			buildProgress += progressStep
		}
				
		buildProgress += Round(100 / (vTargetsCount + 1))
			
		if !kSilentMode
			Progress %buildProgress%
	}
	
	updatesFileName := getFileName("UPDATES", kUserConfigDirectory)
	
	updates := readConfiguration(updatesFileName)
	
	for target, ignore in vUpdateSettings
		setConfigurationValue(updates, "Processed", target, true)
		
	writeConfiguration(updatesFileName, updates)
}

runCleanTargets(ByRef buildProgress) {
	for ignore, target in vCleanupTargets {
		targetName := target[1]
	
		if !kSilentMode
			Progress %buildProgress%, % translate("Cleaning ") . targetName . translate("...")
			
		logMessage(kLogInfo, translate("Cleaning ") . targetName)

		if (target.Length() == 2) {
			fileOrFolder := target[2]
			
			if (InStr(FileExist(fileOrFolder), "D")) {
				currentDirectory := A_WorkingDir
		
				SetWorkingDir %fileOrFolder%
			
				try {
					Loop Files, *.*
					{
						FileDelete %A_LoopFilePath%
				
						if !kSilentMode
							Progress %buildProgress%, % translate("Deleting ") . A_LoopFileName . translate("...")
						
						Sleep 50
					}
				}
				finally {
					SetWorkingDir %currentDirectory%
				}
			}
			else if (FileExist(fileOrFolder) != "") {
				FileDelete %fileOrFolder%
			}
		}
		else {
			currentDirectory := A_WorkingDir
			directory := target[2]
			pattern := target[3]
			options := ((target[4] && (target[4] != "")) ? target[4] : "")
			
			SetWorkingDir %directory%
			
			try {
				Loop Files, %pattern%, %options%
				{
					FileDelete %A_LoopFilePath%
				
					if !kSilentMode
						Progress %buildProgress%, % translate("Deleting ") . A_LoopFileName . translate("...")
			
					Sleep 100
				}
			}
			finally {
				SetWorkingDir %currentDirectory%
			}
		}
			
		Sleep 1000
				
		buildProgress += Round(100 / (vTargetCounts + 1))
			
		if !kSilentMode
			Progress %buildProgress%
	}
}

runCopyTargets(ByRef buildProgress) {
	local title
	
	for ignore, target in vCopyTargets {
		targetName := target[1]
	
		if !kSilentMode
			Progress %buildProgress%, % translate("Copying ") . targetName . translate("...")
			
		logMessage(kLogInfo, translate("Check ") . targetName)

		copy := false
		
		targetSource := target[2]
		targetDestination := target[3]
		
		FileGetTime srcLastModified, %targetSource%, M
		FileGetTime dstLastModified, %targetDestination%, M
		
		if srcLastModified
			if dstLastModified
				copy := (srcLastModified > dstLastModified)
			else
				copy := true
		
		if copy {
			logMessage(kLogInfo, targetName . translate(" out of date - update needed"))
			logMessage(kLogInfo, translate("Copying ") . targetSource)
			
			SplitPath targetDestination, copiedFile, targetDirectory
			SplitPath targetSource, , sourceDirectory 
			
			copiedFile := sourceDirectory . "\" . copiedFile
			
			FileCreateDir %targetDirectory%
			FileMove %copiedFile%, %targetDirectory%, 1
		}
			
		Sleep 1000
		
		buildProgress += Round(100 / (vTargetCounts + 1))
			
		if !kSilentMode
			Progress %buildProgress%
	}
}

runBuildTargets(ByRef buildProgress) {
	local title
	
	for ignore, target in vBuildTargets {
		targetName := target[1]
	
		if !kSilentMode
			Progress %buildProgress%, % translate("Compiling ") . targetName . translate("...")
			
		logMessage(kLogInfo, translate("Check ") . targetName)

		build := false
		
		targetSource := target[2]
		targetBinary := target[3]
		
		FileGetTime srcLastModified, %targetSource%, M
		FileGetTime binLastModified, %targetBinary%, M
		
		if binLastModified {
			build := (build || (ErrorLevel || (srcLastModified > binLastModified)))
			build := (build || checkDependencies(target[4], binLastModified))
		}
		else
			build := true
		
		if build {
			logMessage(kLogInfo, targetName . translate(" or dependent files out of date - recompile triggered"))
			logMessage(kLogInfo, translate("Compiling ") . targetSource)

			try {
				RunWait % kCompiler . " /in """ . targetSource . """"
			}
			catch exception {
				logMessage(kLogCritical, translate("Cannot compile ") . targetSource . translate(" - source file or AHK Compiler (") . kCompiler . translate(") not found"))
			
				title := translate("Modular Simulator Controller System - Compiler")
				
				SplashTextOn 800, 60, %title%, % substituteVariables(translate("Cannot compile %targetSource%: Source file or AHK Compiler (%kCompiler%) not found..."), {targetSource: targetSource, kCompiler: kCompiler})
				
				Sleep 5000
				
				SplashTextOff
			}
			
			SplitPath targetBinary, compiledFile, targetDirectory
			SplitPath targetSource, , sourceDirectory 
			
			compiledFile := sourceDirectory . "\" . compiledFile
			
			FileCreateDir %targetDirectory%
			FileMove %compiledFile%, %targetDirectory%, 1
		}
			
		Sleep 1000
		
		buildProgress += Round(100 / (vTargetCounts + 1))
			
		if !kSilentMode
			Progress %buildProgress%
	}
}

compareUpdateTargets(t1, t2) {
	if inList(t2[3], t1[1])
		return false
	else if inList(t1[3], t2[1])
		return true
	else
		return (t1[1] >= t2[1])
}

prepareTargets(ByRef buildProgress, updateOnly) {
	targets := readConfiguration(kToolsTargetsFile)
	
	for target, arguments in getConfigurationSectionValues(targets, "Update", Object()) {
		buildProgress += 1
		update := vUpdateSettings[target]
		
		if !kSilentMode
			Progress, %buildProgress%, % target . ": " . (update ? translate("Yes") : translate("No"))
		
		if update {
			arguments := string2Values("->", substituteVariables(arguments))
			
			if (arguments.Length() == 1)
				vUpdateTargets.Push(Array(target, string2Values(",", arguments[1]), []))
			else
				vUpdateTargets.Push(Array(target, string2Values(",", arguments[2]), string2Values(",", arguments[1])))
		}
	
		Sleep 200
	}
	
	bubbleSort(vUpdateTargets, "compareUpdateTargets")
	
	if !updateOnly {
		for target, arguments in getConfigurationSectionValues(targets, "Cleanup", Object()) {
			buildProgress += 1
			cleanup := vCleanupSettings[target]
			
			if !kSilentMode
				Progress, %buildProgress%, % target . ": " . (cleanup ? translate("Yes") : translate("No"))
			
			if cleanup {
				arguments := substituteVariables(arguments)
				
				vCleanupTargets.Push(Array(target, string2Values(",", arguments)*))
			}
		
			Sleep 200
		}
		
		for target, arguments in getConfigurationSectionValues(targets, "Copy", Object()) {
			buildProgress += 1
			copy := vCopySettings[target]
			
			if !kSilentMode
				Progress, %buildProgress%, % target . ": " . (copy ? translate("Yes") : translate("No"))
			
			if copy {
				rule := string2Values("<-", substituteVariables(arguments))
			
				vCopyTargets.Push(Array(target, rule[2], rule[1]))
			}
		
			Sleep 200
		}
		
		for target, arguments in getConfigurationSectionValues(targets, "Build", Object()) {
			buildProgress += 1
			build := vBuildSettings[target]
			
			if !kSilentMode
				Progress, %buildProgress%, % target . ": " . (build ? translate("Yes") : translate("No"))
			
			if build {
				rule := string2Values("<-", substituteVariables(arguments))
				
				arguments := string2Values(";", rule[2])
			
				vBuildTargets.Push(Array(target, arguments[1], rule[1], string2Values(",", arguments[2])))
			}
		
			Sleep 200
		}
	}
}

runTargets() {
	updateOnly := false
	
	icon := kIconsDirectory . "Tools.ico"
	
	Menu Tray, Icon, %icon%, , 1
	
	readToolsConfiguration(vUpdateSettings, vCleanupSettings, vCopySettings, vBuildSettings, vSplashTheme)
	
	if (A_Args.Length() > 0)
		if (A_Args[1] = "-Update")
			updateOnly := true
	
	if updateOnly {
		vCleanupSettings := {}
		vCopySettings := {}
		vBuildSettings := {}
	}
	else if (!FileExist(getFileName(kToolsConfigurationFile, kUserConfigDirectory, kConfigDirectory)) || GetKeyState("Ctrl"))
		if !editTargets()
			ExitApp 0
	
	if (!kSilentMode && vSplashTheme)
		showSplashTheme(vSplashTheme, false, false)
	
	Sleep 1000
	
	x := Round((A_ScreenWidth - 300) / 2)
	y := A_ScreenHeight - 150
	
	if !kSilentMode
		Progress 1:B w300 x%x% y%y% FS8 CWD0D0D0 CBGreen, %A_Space%, % translate("Preparing Targets")

	buildProgress := 0
	
	prepareTargets(buildProgress, updateOnly)
	
	vTargetCounts := (vUpdateTargets.Length() + vCleanupTargets.Length() + vCopyTargets.Length() + vBuildTargets.Length())
	
	if !kSilentMode
		Progress, , %A_Space%, % translate("Running Targets")
	
	runUpdateTargets(buildProgress)
	
	if !updateOnly {
		runCleanTargets(buildProgress)
		runCopyTargets(buildProgress)
		runBuildTargets(buildProgress)
	}
		
	if !kSilentMode
		Progress 100, % translate("Done")
	
	Sleep 500
	
	if !kSilentMode {
		Progress Off
	
		if vSplashTheme
			hideSplashTheme()
	}
	
	ExitApp 0
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

runTargets()


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
	OnMessage(0x44, Func("translateMsgBoxButtons").bind(["Yes", "No"]))
	
	title := translate("Simulator Build")
	
	MsgBox 262180, %title%, % translate("Cancel target processing?")
	OnMessage(0x44, "")
	
	IfMsgBox Yes
		ExitApp 0
}
finally {
	protectionOff()
}

return