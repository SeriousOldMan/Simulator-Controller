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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Start.ico
;@Ahk2Exe-ExeName Simulator Startup.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Libraries Include Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#Include Libraries\Configuration Editor.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kSplashVideo = true


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vSimulatorControllerPID := 0
global vStartupFinished = false


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;
	
class SimulatorStartup extends ConfigurationItem {
	iCoreComponents := []
	iFeedbackComponents := []
	iControllerConfiguration := false
	iSimulators := false
	iStartupOption := false
	iSimulatorControllerPID := 0
	
	ControllerConfiguration[] {
		Get {
			return this.iControllerConfiguration
		}
	}
	
	__New(configuration, controllerConfiguration) {
		this.iControllerConfiguration := controllerConfiguration
		
		base.__New(configuration)
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		this.iSimulators := string2Values("|", getConfigurationValue(configuration, "Configuration", "Simulators", ""))
		this.iStartupOption := getConfigurationValue(this.ControllerConfiguration, "Startup", "Simulator", false)
		
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
		noSetup := (this.Configuration.Count() == 0)
		editConfig := GetKeyState("Ctrl")
		
		configuration := this.iControllerConfiguration
		
		if (editConfig || noSetup) {
			result := editConfiguration(configuration, true)
			
			if (result == kCancel)
				ExitApp 0
			else if (noSetup && (readConfiguration(kSimulatorConfigurationFile).Count() == 0)) {
				OnMessage(0x44, "translateMsgBoxButtons")
				MsgBox 262160, Error, Cannot initiate startup sequence, please complete the setup...
				OnMessage(0x44, "")
			
				ExitApp 0
			}
			else if (result == kSave) {
				writeConfiguration(kControllerConfigurationFile, configuration)
				
				this.iControllerConfiguration := configuration
			}
		}
		
		this.loadFromConfiguration(this.Configuration)
	}
	
	startSimulatorController() {
		try {
			logMessage(kLogInfo, "Starting Simulator Controller")
			
			exePath := kBinariesDirectory . "Simulator Controller.exe"
			
			Run %exePath%, %kBinariesDirectory%, , simulatorControllerPID
			
			return simulatorControllerPID
		}
		catch exception {
			logMessage(kLogCritical, "Cannot start Simulator Controller (" . exePath . ") - please rebuild the applications in the binaries folder (" . kBinariesDirectory . ")")
			
			SplashTextOn 800, 60, Modular Simulator Controller System - Startup, Cannot start Simulator Controller (kBinariesDirectory . "Simulator Controller.exe"): `n`nPlease rebuild the applications...
				
			Sleep 5000
				
			SplashTextOff
			
			return 0
		}
	}
	
	updateSplash(number) {
		if (!kSilentMode && !kSplashVideo)
			if (number < 2)
				showSplash("Porsche 911 GT3.jpg")
			else if (number < 3)
				showSplash("McLaren 720s GT3.jpg")
			else if (number < 4)
				showSplash("Lamborghini Huracan Evo GT3.jpg")
			else if (number < 5)
				showSplash("Mercedes AMG GT3.jpg")
			else if (number < 6)
				showSplash("720s GT3.gif")
			else if (number < 7)
				showSplash("Blancpain.jpg")
	}
	
	startComponent(component) {
		logMessage(kLogInfo, "Starting component " . component)
				
		raiseEvent("ahk_pid " . this.iSimulatorControllerPID, "Startup", "startupComponent:" . component)
	}
	
	startComponents(section, components, ByRef startSimulator, ByRef runningIndex) {
		for ignore, component in components {
			startSimulator := (startSimulator || (GetKeyState("Ctrl") || GetKeyState("MButton")))
			
			if getConfigurationValue(this.ControllerConfiguration, section, component, true) {
				if !kSilentMode
					Progress, , % "Start: " . component . "..."
				
				logMessage(kLogInfo, "Component " . component . " is actived")
				
				this.updateSplash(runningIndex)
				
				this.startComponent(component)
				
				Sleep 2000
			}
			else
				logMessage(kLogInfo, "Component " . component . " is deactived")
			
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
		songIsPlaying := false
		
		if !kSilentMode
			if !kSplashVideo
				showSplash("Ferrari 488 GT3.jpg")
			else
				showSplash("Blancpain 2019.gif")
		
		Sleep 1000
		
		x := Round((A_ScreenWidth - 300) / 2)
		y := A_ScreenHeight - 150
		
		if !kSilentMode
			Progress B w300 x%x% y%y% FS8 CWD0D0D0 CBBlue, Start: Simulator Controller, Initialize Core System
		
		this.iSimulatorControllerPID := this.startSimulatorController()
		vSimulatorControllerPID := this.iSimulatorControllerPID
		
		if (this.iSimulatorControllerPID == 0)
			ExitApp 0
					
		Loop 50 {
			if !kSilentMode
				Progress % A_Index * 2
			
			Sleep 5
		}
		
		if !kSilentMode {
			songFile := getConfigurationValue(this.ControllerConfiguration, "Startup", "Song", false)
			
			if (songFile && FileExist(kSplashImagesDirectory . songFile)) {
				raiseEvent("ahk_pid " . this.iSimulatorControllerPID, "Startup", "playStartupSong:" . songFile)
				
				songIsPlaying := true
			}
				
			if kSplashVideo
				showSplashAnimation("Blancpain 2019.gif")
		}

		if !kSilentMode
			Progress B w300 x%x% y%y% FS8 CWD0D0D0 CBGreen, ..., Starting System Components
			
		runningIndex := 1
		
		this.startComponents("Core", this.iCoreComponents, startSimulator, runningIndex)
		this.startComponents("Feedback", this.iFeedbackComponents, startSimulator, runningIndex)
		
		if !kSilentMode
			Progress 100, Done
		
		Sleep 500
		
		if (startSimulator || (GetKeyState("Ctrl") || GetKeyState("MButton")))
			this.startSimulator()

		if kSilentMode
			ExitApp 0
		else {
			Progress Off
		
			if !kSplashVideo && !songIsPlaying
				ExitApp 0
			
			vStartupFinished := true
			
			index := 0
			
			Loop {
				if (index == 6)
					index := 0
				
				this.updateSplash(++index)
				
				Sleep 3000
			}
		}
			
		vStartupFinished := true
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

startSimulator() {
	configuration := readConfiguration(kControllerConfigurationFile)
	
	kSplashVideo := (getConfigurationValue(configuration, "Startup", "Video", false) && FileExist(kSplashImagesDirectory . "Blancpain 2019.gif"))
	
	icon := kIconsDirectory . "Start.ico"
		
	Menu Tray, Icon, %icon%, , 1
	
	registerEventHandler("Startup", "handleStartupEvents")
	
	new SimulatorStartup(kSimulatorConfiguration, configuration).startup()
}


;;;-------------------------------------------------------------------------;;;
;;;                          Event Handler Section                          ;;;
;;;-------------------------------------------------------------------------;;;

exitStartup() {
	ExitApp 0
}

handleStartupEvents(event, data) {
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

return


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
		MsgBox 262180, Simulator Startup, Cancel Startup?
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
