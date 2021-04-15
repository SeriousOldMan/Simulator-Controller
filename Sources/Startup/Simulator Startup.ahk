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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Startup.ico
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
global vStartupCanceled = false


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
		
		if (settings.Count() = 0)
			editConfig := true
		
		if (editConfig || noConfiguration) {
			result := editSettings(settings, true)
			
			if (result == kCancel)
				exitStartup(true)
			else if (noConfiguration && (readConfiguration(kSimulatorConfigurationFile).Count() == 0)) {
				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
				error := translate("Error")
				MsgBox 262160, %error%, % translate("Cannot initiate startup sequence, please check the configuration...")
				OnMessage(0x44, "")
			
				exitStartup(true)
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
			
			exePath := kBinariesDirectory . "Voice Server.exe"
			
			Run %exePath%, %kBinariesDirectory%, , processID
			
			exePath := kBinariesDirectory . "Simulator Controller.exe -Startup -Voice " . processID
			
			Run %exePath%, %kBinariesDirectory%, , processID
			
			return processID
		}
		catch exception {
			logMessage(kLogCritical, translate("Cannot start Simulator Controller (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))
		
			showMessage(substituteVariables(translate("Cannot start Simulator Controller (%kBinariesDirectory%Simulator Controller.exe) - please rebuild the applications..."))
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			
			return 0
		}
	}
	
	startComponent(component) {
		logMessage(kLogInfo, translate("Starting component ") . component)
					
		raiseEvent(kFileMessage, "Startup", "startupComponent:" . component, vSimulatorControllerPID)
	}
	
	startComponents(section, components, ByRef startSimulator, ByRef runningIndex) {
		for ignore, component in components {
			if vStartupCanceled
				break
			
			startSimulator := (startSimulator || (GetKeyState("Ctrl") || GetKeyState("MButton")))
			
			if getConfigurationValue(this.Settings, section, component, false) {
				if !kSilentMode
					showProgress({message: translate("Start: ") . component . translate("...")})
				
				logMessage(kLogInfo, translate("Component ") . component . translate(" is activated"))
				
				this.startComponent(component)
				
				Sleep 2000
			}
			else
				logMessage(kLogInfo, translate("Component ") . component . translate(" is deactivated"))
			
			if !kSilentMode
				showProgress({progress: Round((runningIndex++ / (this.iCoreComponents.Length() + this.iFeedbackComponents.Length())) * 90)})
		}
	}
	
	startSimulator() {
		if vStartupCanceled
			return
			
		if (!this.iStartupOption && (this.iSimulators.Length() > 0))
			this.iStartupOption := this.iSimulators[1]
			
		if this.iStartupOption
			raiseEvent(kFileMessage, "Startup", "startupSimulator:" . this.iStartupOption, vSimulatorControllerPID)
	}
	
	startup() {
		this.prepareConfiguration()
		
		startSimulator := ((this.iStartupOption != false) || GetKeyState("Ctrl") || GetKeyState("MButton"))
		
		this.iSimulatorControllerPID := this.startSimulatorController()
		vSimulatorControllerPID := this.iSimulatorControllerPID
		
		if (this.iSimulatorControllerPID == 0)
			exitStartup(true)
		
		if (!kSilentMode && this.iSplashTheme)
			showSplashTheme(this.iSplashTheme, "playSong")
			
		x := Round((A_ScreenWidth - 300) / 2)
		y := A_ScreenHeight - 150
		
		if !kSilentMode {
			message := translate("Start: Simulator Controller")
			
			showProgress({x: x, y: y, color: "Blue", message: message, title: translate("Initialize Core System")})
		}
		
		Loop 50 {
			if !kSilentMode
				showProgress({progress: A_Index * 2})
			
			Sleep 20
		}

		if !kSilentMode {
			message := translate("...")
			
			showProgress({progress: 0, color: "Green", message: message, title: translate("Starting System Components")})
		}
			
		runningIndex := 1
		
		this.startComponents("Core", this.iCoreComponents, startSimulator, runningIndex)
		this.startComponents("Feedback", this.iFeedbackComponents, startSimulator, runningIndex)
		
		if !kSilentMode
			showProgress({progress: 100, message: translate("Done")})
		
		Sleep 500
			
		vStartupFinished := true
		hidden := false
		
		if (startSimulator || (GetKeyState("Ctrl") || GetKeyState("MButton"))) {
			if (!kSilentMode && this.iSplashTheme) {
				hideSplashTheme()
				
				hidden := true
			}
			
			this.startSimulator()
		}

		if (kSilentMode || vStartupCanceled) {
			if (!hidden && !kSilentMode && this.iSplashTheme)
				hideSplashTheme()
			
			exitStartup(true)
		}
		else {
			; Progress Off
			hideProgress()
		
			if !this.iSplashTheme
				exitStartup(true)
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

watchStartupSemaphore() {
	if !FileExist(kTempDirectory . "Startup.semaphore")
		exitStartup()
}

startSimulator() {
	icon := kIconsDirectory . "Startup.ico"
		
	Menu Tray, Icon, %icon%, , 1
						
	new SimulatorStartup(kSimulatorConfiguration, readConfiguration(kSimulatorSettingsFile)).startup()
	
	; Looks like we have recurring deadlock situations with bidirectional pipes in case of process exit situations...
	;
	; registerEventHandler("Startup", "functionEventHandler")
	;
	; Using a sempahore file instead...
	
	fileName := (kTempDirectory . "Startup.semaphore")
	
	if !FileExist(fileName)
		FileAppend Startup, %fileName%
	
	SetTimer watchStartupSemaphore, 2000
}

playSong(songFile) {
	if (songFile && FileExist(getFileName(songFile, kUserSplashMediaDirectory, kSplashMediaDirectory)))
		raiseEvent(kFileMessage, "Startup", "playStartupSong:" . songFile, vSimulatorControllerPID)
}


;;;-------------------------------------------------------------------------;;;
;;;                          Event Handler Section                          ;;;
;;;-------------------------------------------------------------------------;;;

exitStartup(sayGoodbye := false) {
	if (sayGoodbye && (vSimulatorControllerPID != false)) {
		raiseEvent(kFileMessage, "Startup", "startupExited", vSimulatorControllerPID)
		
		SetTimer exitStartup, -2000
		
		Exit
	}
	else {
		fileName := (kTempDirectory . "Startup.semaphore")
						
		try {
			FileDelete %fileName%
		}
		catch exception {
			; ignore
		}

		ExitApp 0
	}
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
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
		
		title := translate("Simulator Startup")
		
		MsgBox 262180, %title%, % translate("Cancel Startup?")
		OnMessage(0x44, "")
		
		IfMsgBox Yes
		{
			if (vSimulatorControllerPID != 0)
				raiseEvent(kFileMessage, "Startup", "stopStartupSong", vSimulatorControllerPID)
		
			vStartupCanceled := true
		}
	}
	else {
		if (vSimulatorControllerPID != 0)
			raiseEvent(kFileMessage, "Startup", "stopStartupSong", vSimulatorControllerPID)
		
		exitStartup(true)
	}
}
finally {
	protectionOff()
}

return
