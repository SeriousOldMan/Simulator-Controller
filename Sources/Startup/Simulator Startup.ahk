;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Startup Sequence                ;;;
;;;     1. Voice Recognition 	- Voice Command Recognition (VoiceMacro)    ;;;
;;;     2. Face Recogition      - Headtracking Neural Network (AITrack)     ;;;
;;;     3. View Tracking        - Viewtracking Interface Manager (opentrack);;;
;;;     4. Simulator Controller - Simulator Controller & Automation         ;;;
;;;     5. Tactile Feedback     - Tactile Feedback System (SimHub)          ;;;
;;;     6. Motion Feedback      - Motion Feedback System (SimFeedback)      ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Start.ico
;@Ahk2Exe-ExeName Simulator Startup.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Libraries Include Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#Include Libraries\Settings Editor.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vSimulatorControllerPID := 0
global vStartupFinished = false

global vSongFile = false


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;
	
class SimulatorStartup extends ConfigurationItem {
	iCoreComponents := []
	iFeedbackComponents := []
	iSettings := false
	iSimulators := false
	iSplashTheme := false
	iStartupOption := false
	iSimulatorControllerPID := 0
	
	Settings[] {
		Get {
			return this.iSettings
		}
	}
	
	__New(configuration, settings) {
		this.iSettings := settings
		
		base.__New(configuration)
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		this.iSimulators := string2Values("|", getConfigurationValue(configuration, "Configuration", "Simulators", ""))
		this.iSplashTheme := getConfigurationValue(this.Settings, "Startup", "Splash Theme", false)
		this.iStartupOption := getConfigurationValue(this.Settings, "Startup", "Simulator", false)
		
		this.iCoreComponents := []
		this.iFeedbackComponents := []
		
		for descriptor, applicationName in getConfigurationSectionValues(configuration, "Applications", Object()) {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
		
			if (descriptor[1] == "Core")
				this.iCoreComponents.Push(applicationName)
			else if (descriptor[1] == "Feedback")
				this.iFeedbackComponents.Push(applicationName)
		}
	}
	
	prepareConfiguration() {
		noConfiguration := (this.Configuration.Count() == 0)
		editConfig := GetKeyState("Ctrl")
		
		settings := this.Settings
		
		if (editConfig || noConfiguration) {
			result := editSettings(settings, true)
			
			if (result == kCancel)
				ExitApp 0
			else if (noConfiguration && (readConfiguration(kSimulatorConfigurationFile).Count() == 0)) {
				OnMessage(0x44, "translateMsgBoxButtons")
				error := translate("Error")
				MsgBox 262160, %error%, % translate("Cannot initiate startup sequence, please check the configuration...")
				OnMessage(0x44, "")
			
				ExitApp 0
			}
			else if (result == kSave) {
				writeConfiguration(kSimulatorSettingsFile, settings)
				
				this.iSettings := settings
			}
		}
		
		this.loadFromConfiguration(this.Configuration)
	}
	
	startSimulatorController() {
		local title
		
		try {
			logMessage(kLogInfo, translate("Starting ") . translate("Simulator Controller"))
			
			exePath := kBinariesDirectory . "Simulator Controller.exe"
			
			Run %exePath%, %kBinariesDirectory%, , simulatorControllerPID
			
			return simulatorControllerPID
		}
		catch exception {
			logMessage(kLogCritical, translate("Cannot start Simulator Controller (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))
			
			title := translate("Modular Simulator Controller System - Startup")
			
			SplashTextOn 800, 60, %title%, % substituteVariables(translate("Cannot start Simulator Controller (%kBinariesDirectory%Simulator Controller.exe) - please rebuild the applications..."))
				
			Sleep 5000
				
			SplashTextOff
			
			return 0
		}
	}
	
	startComponent(component) {
		logMessage(kLogInfo, translate("Starting component ") . component)
				
		raiseEvent("ahk_pid " . this.iSimulatorControllerPID, "Startup", "startupComponent:" . component)
	}
	
	startComponents(section, components, ByRef startSimulator, ByRef runningIndex) {
		for ignore, component in components {
			startSimulator := (startSimulator || (GetKeyState("Ctrl") || GetKeyState("MButton")))
			
			if getConfigurationValue(this.Settings, section, component, true) {
				if !kSilentMode
					Progress, , % translate("Start: ") . component . translate("...")
				
				logMessage(kLogInfo, translate("Component ") . component . translate(" is activated"))
				
				this.startComponent(component)
				
				Sleep 2000
			}
			else
				logMessage(kLogInfo, translate("Component ") . component . translate(" is deactivated"))
			
			if !kSilentMode
				Progress % Round((runningIndex++ / (this.iCoreComponents.Length() + this.iFeedbackComponents.Length())) * 90)
		}
	}
	
	startSimulator() {
		if (!this.iStartupOption && (this.iSimulators.Length() > 0))
			this.iStartupOption := this.iSimulators[1]
			
		if this.iStartupOption {
			raiseEvent("ahk_pid " . this.iSimulatorControllerPID, "Startup", "startupSimulator:" . this.iStartupOption)
			
			ExitApp 0
		} 
	}
	
	startup() {
		this.prepareConfiguration()
		
		startSimulator := ((this.iStartupOption != false) || GetKeyState("Ctrl") || GetKeyState("MButton"))
		
		this.iSimulatorControllerPID := this.startSimulatorController()
		vSimulatorControllerPID := this.iSimulatorControllerPID
		
		if (this.iSimulatorControllerPID == 0)
			ExitApp 0
		
		if (!kSilentMode && this.iSplashTheme)
			showSplashTheme(this.iSplashTheme, "playSong")
			
		x := Round((A_ScreenWidth - 300) / 2)
		y := A_ScreenHeight - 150
		
		if !kSilentMode
			message := translate("Start: Simulator Controller")
			Progress B w300 x%x% y%y% FS8 CWD0D0D0 CBBlue, %message%, % translate("Initialize Core System")
					
		Loop 50 {
			if !kSilentMode
				Progress % A_Index * 2
			
			Sleep 5
		}

		if !kSilentMode {
			message := translate("...")
			Progress B w300 x%x% y%y% FS8 CWD0D0D0 CBGreen, %message%, % translate("Starting System Components")
		}
			
		runningIndex := 1
		
		this.startComponents("Core", this.iCoreComponents, startSimulator, runningIndex)
		this.startComponents("Feedback", this.iFeedbackComponents, startSimulator, runningIndex)
		
		if !kSilentMode
			Progress 100, % translate("Done")
		
		Sleep 500
		
		if (startSimulator || (GetKeyState("Ctrl") || GetKeyState("MButton")))
			this.startSimulator()

		if kSilentMode
			ExitApp 0
		else {
			Progress Off
		
			if !this.iSplashTheme
				ExitApp 0
		}
			
		vStartupFinished := true
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

startSimulator() {
	settings := readConfiguration(kSimulatorSettingsFile)
	
	icon := kIconsDirectory . "Start.ico"
		
	Menu Tray, Icon, %icon%, , 1
	
	registerEventHandler("Startup", "handleStartupEvents")
	
	new SimulatorStartup(kSimulatorConfiguration, settings).startup()
}

playSongRemote() {
	if raiseEvent("ahk_pid " . vSimulatorControllerPID, "Startup", "playStartupSong:" . vSongFile) {
		vSongFile := false
		
		SetTimer playSongRemote, Off
	}
}

playSong(songFile) {
	if (songFile && FileExist(getFileName(songFile, kUserSplashMediaDirectory, kSplashMediaDirectory))) {
		vSongFile := songFile
		
		SetTimer playSongRemote, 50
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                          Event Handler Section                          ;;;
;;;-------------------------------------------------------------------------;;;

exitStartup() {
	ExitApp 0
}

handleStartupEvents(event, data) {
	local function
	
	if InStr(data, ":") {
		data := StrSplit(data, ":")
		
		function := data[1]
		arguments := StrSplit(data[2], ",")
		
		numArguments := arguments.Length()
		
		Loop %numArguments%
			arguments[A_index] := Trim(arguments[A_Index], A_Space)
			
		withProtection(function, arguments*)
	}
	else	
		withProtection(data)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

startSimulator()


;;;-------------------------------------------------------------------------;;;
;;;                         Hotkey & Label Section                          ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Escape::                   Cancel Startup                               ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
Escape::
protectionOn()

try {
	if !vStartupFinished {
		SoundPlay *32
		OnMessage(0x44, "translateMsgBoxButtons")
		
		title := translate("Simulator Startup")
		
		MsgBox 262180, %title%, % translate("Cancel Startup?")
		OnMessage(0x44, "")
		
		IfMsgBox Yes
		{
			if (vSimulatorControllerPID != 0)
				raiseEvent("ahk_pid " . vSimulatorControllerPID, "Startup", "stopStartupSong")
		
			ExitApp 0
		}
	}
	else {
		if (vSimulatorControllerPID != 0)
			raiseEvent("ahk_pid " . vSimulatorControllerPID, "Startup", "stopStartupSong")
		
		ExitApp 0
	}
}
finally {
	protectionOff()
}

return
