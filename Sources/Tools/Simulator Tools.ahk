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

global kUpdateMessages = {updateTranslations: "Updating translations to "
						, updatePluginLabels: "Updating plugin labels to "
						, updatePhraseGrammars: "Updating phrase grammars to "
						, updateACCPluginForV20: "Updating ACC plugin to ", updateACCPluginForV21: "Updating ACC plugin to "
						, updatePedalCalibrationPluginForV21: "Updating Pedal Calibration plugin to "
						, updateRF2PluginForV23: "Updating rFactor 2 plugin to "
						, updateRREPluginForV24: "Updating RaceRoom Racing Experience plugin to "}

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

global vTargetsCount = 0

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
	
	for target, rule in getConfigurationSectionValues(targets, "Cleanup", Object()) {
		if !InStr(target, "*.bak")
			target := ConfigurationItem.splitDescriptor(target)[1]
	
		cleanupSettings[target] := getConfigurationValue(configuration, "Cleanup", target, InStr(target, "*.ahk") ? true : false)
	}
	
	for target, rule in getConfigurationSectionValues(targets, "Copy", Object()) {
		target := ConfigurationItem.splitDescriptor(target)[1]
	
		copySettings[target] := getConfigurationValue(configuration, "Copy", target, true)
	}
	
	for target, rule in getConfigurationSectionValues(targets, "Build", Object()) {
		target := ConfigurationItem.splitDescriptor(target)[1]
	
		buildSettings[target] := getConfigurationValue(configuration, "Build", target, true)
	}
	
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
	static copyVariable9
	static copyVariable10
	static copyVariable11
	static copyVariable12
	static copyVariable13
	static copyVariable14
	static copyVariable15
	static copyVariable16
	
	static buildVariable1
	static buildVariable2
	static buildVariable3
	static buildVariable4
	static buildVariable5
	static buildVariable6
	static buildVariable7
	static buildVariable8
	static buildVariable9
	static buildVariable10
	static buildVariable11
	static buildVariable12
	static buildVariable13
	static buildVariable14
	static buildVariable15
	static buildVariable16
	
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
		
		Gui TE:-Border ; -Caption
		Gui TE:Color, D0D0D0
	
		Gui TE:Font, Bold, Arial
		
		Gui TE:Add, Text, w220 Center gmoveEditor, % translate("Modular Simulator Controller System") 
		
		Gui TE:Font, Norm, Arial
		Gui TE:Font, Italic, Arial
	
		Gui TE:Add, Text, YP+20 w220 Center, % translate("Targets")
	
		Gui TE:Font, Norm, Arial
		Gui TE:Font, Italic, Arial
		
		if (vUpdateSettings.Count() > 0) {
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
		themes := (translate("None") . "|" . values2String("|", themes*))
		
		Gui TE:Add, Text, X10 Y+20, % translate("Theme")
		Gui TE:Add, DropDownList, X90 YP-5 w140 Choose%chosen% vsplashTheme, %themes%
		
		Gui TE:Add, Button, Default X10 y+20 w100 gsaveTargets, % translate("Run")
		Gui TE:Add, Button, X+20 w100 gcancelTargets, % translate("&Cancel")
	
		Gui TE:Margin, 10, 10
		Gui TE:Show, AutoSize Center
		
		Loop
			Sleep 1000
		until result
	
		return ((result == 1) || (result == 2))
	}
}

updatePhraseGrammars() {
	languages := availableLanguages()
	
	for ignore, grammarFileName in getFileNames("Race Engineer.grammars.*", kUserConfigDirectory) {
		SplitPath grammarFileName, , , languageCode
		
		userGrammars := readConfiguration(grammarFileName)
		bundledGrammars := readConfiguration(getFileName("Race Engineer.grammars." . languageCode, kConfigDirectory))
	
		for section, keyValues in bundledGrammars
			for key, value in keyValues
				if (getConfigurationValue(userGrammars, section, key, kUndefined) == kUndefined)
					setConfigurationValue(userGrammars, section, key, value)
					
		writeConfiguration(grammarFileName, userGrammars)
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
			originalLanguageCode := "en"
			
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
			if (getConfigurationValue(userPluginLabels, section, key, kUndefined) == kUndefined)
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
			
			if (getConfigurationValue(userConfiguration, "Controller Functions", key, kUndefined) == kUndefined) {
				setConfigurationValue(userConfiguration, "Controller Functions", key, getConfigurationValue(bundledConfiguration, "Controller Functions", key))
				
				key .= " Action"
				
				setConfigurationValue(userConfiguration, "Controller Functions", key, getConfigurationValue(bundledConfiguration, "Controller Functions", key))
			}
			
			customCallIndex += 1
		} until (customCallIndex > endNumber)
	
		writeConfiguration(userConfigurationFile, userConfiguration)
	}
}

updateConfigurationForV26() {
	userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	userConfiguration := readConfiguration(userConfigurationFile)
	
	if (userConfiguration.Count() > 0) {
		config := getConfigurationValue(userConfiguration, "Controller Layouts", "Button Boxes", "Master Controller")
		
		setConfigurationValue(userConfiguration, "Controller Layouts", "Button Boxes", StrReplace(StrReplace(config, "Master", "Main"), "Slave", "Support"))
		
		writeConfiguration(userConfigurationFile, userConfiguration)
	}
}

updateConfigurationForV25() {
	userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	userConfiguration := readConfiguration(userConfigurationFile)
	
	if (userConfiguration.Count() > 0) {
		bundledConfiguration := readConfiguration(getFileName(kSimulatorConfigurationFile, kConfigDirectory))
	
		config := getConfigurationSectionValues(bundledConfiguration, "Voice Control", Object())
		
		setConfigurationSectionValues(userConfiguration, "Voice Control", config)
		
		setConfigurationValue(userConfiguration, "Controller Layouts", "Button Boxes", "Master Controller")
		
		writeConfiguration(userConfigurationFile, userConfiguration)
	}

    userSettingsFile := getFileName(kSimulatorSettingsFile, kUserConfigDirectory)
	userSettings := readConfiguration(userSettingsFile)
	
	if (userSettings.Count() > 0) {
		settings := getConfigurationSectionValues(userSettings, "Controller", Object())
		
		setConfigurationSectionValues(userSettings, "Tray Tip", settings)
		
		writeConfiguration(userSettingsFile, userSettings)
	}
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

updateACCPluginForV21() {
	userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	userConfiguration := readConfiguration(userConfigurationFile)
	
	if (userConfiguration.Count() > 0) {
		accPlugin := new Plugin("ACC", userConfiguration)
		
		if !accPlugin.hasArgument("raceEngineerName") {
			accPlugin.setArgumentValue("raceEngineerName", "Jona")
			accPlugin.setArgumentValue("raceEngineerSpeaker", kTrue)
			
			accPlugin.saveToConfiguration(userConfiguration)
		}
		
		writeConfiguration(userConfigurationFile, userConfiguration)
	}
}

updatePedalCalibrationPluginForV21() {
	userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	userConfiguration := readConfiguration(userConfigurationFile)
	
	if (userConfiguration.Count() > 0) {
		pedalPlugin := new Plugin("Pedal Calibration", readConfiguration(getFileName(kSimulatorConfigurationFile, kConfigDirectory)))
		
		pedalPlugin.iIsActive := false
			
		pedalPlugin.saveToConfiguration(userConfiguration)
		
		writeConfiguration(userConfigurationFile, userConfiguration)
	}
}

updateRF2PluginForV23() {
	userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	userConfiguration := readConfiguration(userConfigurationFile)
	
	if (userConfiguration.Count() > 0) {
		rf2Plugin := new Plugin("RF2", readConfiguration(getFileName(kSimulatorConfigurationFile, kConfigDirectory)))
			
		rf2Plugin.iIsActive := false
		
		rf2Plugin.saveToConfiguration(userConfiguration)
		
		writeConfiguration(userConfigurationFile, userConfiguration)
	}
}

updateRREPluginForV24() {
	userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	userConfiguration := readConfiguration(userConfigurationFile)
	
	if (userConfiguration.Count() > 0) {
		rrePlugin := new Plugin("RRE", readConfiguration(getFileName(kSimulatorConfigurationFile, kConfigDirectory)))
			
		rrePlugin.iIsActive := false
		
		rrePlugin.saveToConfiguration(userConfiguration)
		
		writeConfiguration(userConfigurationFile, userConfiguration)
	}
}


updateToV15() {
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
			showProgress({progress: buildProgress, message: translate("Updating to ") . targetName . translate("...")})
			
		logMessage(kLogInfo, translate("Updating to ") . targetName)
		
		Sleep 50
		
		progressStep := Round((100 / (vTargetsCount + 1)) / target[2].Length())
		
		for ignore, updateFunction in target[2] {
			if !kSilentMode {
				if kUpdateMessages.HasKey(updateFunction)
					message := translate(kUpdateMessages[updateFunction]) . targetName . translate("...")
				else
					message := translate("Updating configuration to ") . targetName . translate("...")
				
				showProgress({progress: buildProgress, message: message})
			}
					
			%updateFunction%()
			
			Sleep 50
			
			buildProgress += progressStep
		}
				
		buildProgress += Round(100 / (vTargetsCount + 1))
			
		if !kSilentMode
			showProgress({progress: buildProgress})
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
			showProgress({progress: buildProgress, message: translate("Cleaning ") . targetName . translate("...")})
			
		logMessage(kLogInfo, translate("Cleaning ") . targetName)

		if (target.Length() == 2) {
			fileOrFolder := target[2]
			
			if (InStr(FileExist(fileOrFolder), "D")) {
				currentDirectory := A_WorkingDir
		
				SetWorkingDir %fileOrFolder%
			
				try {
					Loop Files, *.*, FDR
					{
						if InStr(FileExist(A_LoopFilePath), "D")
							FileRemoveDir %A_LoopFilePath%, 1
						else
							FileDelete %A_LoopFilePath%
					
						if !kSilentMode
							showProgress({progress: buildProgress, message: translate("Deleting ") . A_LoopFileName . translate("...")})
						
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
						showProgress({progress: buildProgress, message: translate("Deleting ") . A_LoopFileName . translate("...")})
			
					Sleep 50
				}
			}
			finally {
				SetWorkingDir %currentDirectory%
			}
		}
			
		Sleep 50
				
		buildProgress += Round(100 / (vTargetsCount + 1))
			
		if !kSilentMode
			showProgress({progress: buildProgress})
	}
}

runCopyTargets(ByRef buildProgress) {
	local title
	
	if !kSilentMode
		showProgress({progress: buildProgress, message: translate("...")})
	
	for ignore, target in vCopyTargets {
		targetName := target[1]
			
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
			if !kSilentMode
				showProgress({progress: buildProgress, message: translate("Copying ") . targetName . translate("...")})
		
			logMessage(kLogInfo, targetName . translate(" out of date - update needed"))
			logMessage(kLogInfo, translate("Copying ") . targetSource)
			
			SplitPath targetDestination, , targetDirectory
			
			FileCreateDir %targetDirectory%
			FileCopy %targetSource%, %targetDestination%, 1
			
			Sleep 50
		}
		
		buildProgress += Round(100 / (vTargetsCount + 1))
			
		if !kSilentMode
			showProgress({progress: buildProgress})
	}
}

runBuildTargets(ByRef buildProgress) {
	local title
	
	if !kSilentMode
		showProgress({progress: buildProgress, message: ""})
	
	for ignore, target in vBuildTargets {
		targetName := target[1]
			
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
			if !kSilentMode
				showProgress({progress: buildProgress, message: translate("Compiling ") . targetName . translate("...")})
		
			logMessage(kLogInfo, targetName . translate(" or dependent files out of date - recompile triggered"))
			logMessage(kLogInfo, translate("Compiling ") . targetSource)

			try {
				RunWait % kCompiler . " /in """ . targetSource . """"
			}
			catch exception {
				logMessage(kLogCritical, translate("Cannot compile ") . targetSource . translate(" - source file or AHK Compiler (") . kCompiler . translate(") not found"))
		
				showMessage(substituteVariables(translate("Cannot compile %targetSource%: Source file or AHK Compiler (%kCompiler%) not found..."), {targetSource: targetSource, kCompiler: kCompiler})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
			
			SplitPath targetBinary, compiledFile, targetDirectory
			SplitPath targetSource, , sourceDirectory 
			
			compiledFile := sourceDirectory . "\" . compiledFile
			
			FileCreateDir %targetDirectory%
			FileMove %compiledFile%, %targetDirectory%, 1
		}
		
		buildProgress += Round(100 / (vTargetsCount + 1))
			
		if !kSilentMode
			showProgress({progress: buildProgress})
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
	counter := 0
	targets := readConfiguration(kToolsTargetsFile)
	
	for target, arguments in getConfigurationSectionValues(targets, "Update", Object()) {
		buildProgress += Floor(A_Index / 4)
		update := vUpdateSettings[target]
		
		if !kSilentMode
			showProgress({progress: buildProgress, message: target . ": " . (update ? translate("Yes") : translate("No"))})
		
		if update {
			arguments := string2Values("->", substituteVariables(arguments))
			
			if (arguments.Length() == 1)
				vUpdateTargets.Push(Array(target, string2Values(",", arguments[1]), []))
			else
				vUpdateTargets.Push(Array(target, string2Values(",", arguments[2]), string2Values(",", arguments[1])))
		}
	
		Sleep 50
	}
	
	bubbleSort(vUpdateTargets, "compareUpdateTargets")
	
	if !updateOnly {
		for target, arguments in getConfigurationSectionValues(targets, "Cleanup", Object()) {
			buildProgress += Floor(++counter / 20)
			cleanup := (InStr(target, "*.bak") ? vCleanupSettings[target] : vCleanupSettings[ConfigurationItem.splitDescriptor(target)[1]])
			
			if !kSilentMode
				showProgress({progress: buildProgress, message: target . ": " . (cleanup ? translate("Yes") : translate("No"))})
			
			if cleanup {
				arguments := substituteVariables(arguments)
				
				vCleanupTargets.Push(Array(target, string2Values(",", arguments)*))
			}
		
			Sleep 50
		}
		
		for target, arguments in getConfigurationSectionValues(targets, "Copy", Object()) {
			buildProgress += Floor(++counter / 20)
			copy := vCopySettings[ConfigurationItem.splitDescriptor(target)[1]]
			
			if !kSilentMode
				showProgress({progress: buildProgress, message: target . ": " . (copy ? translate("Yes") : translate("No"))})
			
			if copy {
				rule := string2Values("<-", substituteVariables(arguments))
			
				vCopyTargets.Push(Array(target, rule[2], rule[1]))
			}
		
			Sleep 50
		}
		
		for target, arguments in getConfigurationSectionValues(targets, "Build", Object()) {
			buildProgress += Floor(++counter / 20)
			build := vBuildSettings[ConfigurationItem.splitDescriptor(target)[1]]
			
			if !kSilentMode
				showProgress({progress: buildProgress, message: target . ": " . (build ? translate("Yes") : translate("No"))})
			
			if build {
				rule := string2Values("<-", substituteVariables(arguments))
				
				arguments := string2Values(";", rule[2])
			
				vBuildTargets.Push(Array(target, arguments[1], rule[1], string2Values(",", arguments[2])))
			}
		
			Sleep 50
		}
	}
}

startSimulatorTools() {
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
	
	Sleep 500
	
	x := Round((A_ScreenWidth - 300) / 2)
	y := A_ScreenHeight - 150
	
	if !kSilentMode
		showProgress({x: x, y: y, color: "Blue", message: "", title: translate("Preparing Targets")})

	buildProgress := 0
	
	prepareTargets(buildProgress, updateOnly)
	
	vTargetsCount := (vUpdateTargets.Length() + vCleanupTargets.Length() + vCopyTargets.Length() + (vBuildTargets.Length() * 2))
	
	if !kSilentMode
		showProgress({message: "", color: "Green", title: translate("Running Targets")})
	
	runUpdateTargets(buildProgress)
	
	if !updateOnly {
		runCleanTargets(buildProgress)
		runCopyTargets(buildProgress)
		runBuildTargets(buildProgress)
	}
		
	if !kSilentMode
		showProgress({progress: 100, message: translate("Done")})
	
	Sleep 500
	
	if !kSilentMode {
		hideProgress()
	
		if vSplashTheme
			hideSplashTheme()
	}
	
	ExitApp 0
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

startSimulatorTools()


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
	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
	
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