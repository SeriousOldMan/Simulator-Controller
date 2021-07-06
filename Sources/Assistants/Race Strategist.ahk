;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Strategist                 ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Artificial Intelligence.ico
;@Ahk2Exe-ExeName Race Strategist.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\RuleEngine.ahk
#Include ..\Assistants\Libraries\RaceStrategist.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vRemotePID = 0


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

showLogo(name) {
	static videoPlayer

	info := kVersion . " - 2021, Oliver Juwig`nCreative Commons - BY-NC-SA"
	logo := kResourcesDirectory . "Rotating Brain.gif"
	image := "1:" . logo

	SysGet mainScreen, MonitorWorkArea
	
	x := mainScreenLeft
	y := mainScreenBottom - 234

	title1 := translate("Modular Simulator Controller System")
	title2 := substituteVariables(translate("%name% - The Virtual Race Strategist"), {name: name})
	SplashImage %image%, B FS8 CWD0D0D0 w299 x%x% y%y% ZH155 ZW279, %info%, %title1%`n%title2%

	Gui Logo:-Border -Caption 
	Gui Logo:Add, ActiveX, x0 y0 w279 h155 VvideoPlayer, shell explorer

	videoPlayer.Navigate("about:blank")

	html := "<html><body style='background-color: transparent' style='overflow:hidden' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><img src='" . logo . "' width=279 height=155 border=0 padding=0></body></html>"

	videoPlayer.document.write(html)

	x += 10
	y += 40

	Gui Logo:Margin, 0, 0
	Gui Logo:+AlwaysOnTop
	Gui Logo:Show, AutoSize x%x% y%y%
}

hideLogo() {
	Gui Logo:Destroy
	SplashImage 1:Off
}

checkRemoteProcessAlive() {
	Process Exist, %vRemotePID%
	
	if !ErrorLevel
		ExitApp 0
}

startRaceStrategist() {
	icon := kIconsDirectory . "Artificial Intelligence.ico"
	
	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Race Strategist
	
	remotePID := 0
	remoteHandle := false
	strategistName := "Cato"
	strategistLogo := false
	strategistLanguage := false
	strategistSpeaker := false
	strategistListener := false
	strategistSettingsFile := getFileName("Race.settings", kUserConfigDirectory)
	debug := false
	
	Process Exist, Voice Server.exe
	
	voiceServer := ErrorLevel
	
	index := 1
	
	while (index < A_Args.Length()) {
		switch A_Args[index] {
			case "-Remote":
				remotePID := A_Args[index + 1]
				index += 2
			case "-Name":
				strategistName := A_Args[index + 1]
				index += 2
			case "-Logo":
				strategistLogo := (((A_Args[index + 1] = kTrue) || (A_Args[index + 1] = true)) ? true : false)
				index += 2
			case "-Language":
				strategistLanguage := A_Args[index + 1]
				index += 2
			case "-Speaker":
				strategistSpeaker := A_Args[index + 1]
				index += 2
			case "-Listener":
				strategistListener := A_Args[index + 1]
				index += 2
			case "-Settings":
				strategistSettingsFile := A_Args[index + 1]
				index += 2
			case "-Voice":
				voiceServer := A_Args[index + 1]
				index += 2
			case "-Debug":
				debug := (((A_Args[index + 1] = kTrue) || (A_Args[index + 1] = true)) ? true : false)
				index += 2
			default:
				index += 1
		}
	}
	
	if (strategistSpeaker = kTrue)
		strategistSpeaker := true
	else if (strategistSpeaker = kFalse)
		strategistSpeaker := false
	
	if (strategistListener = kTrue)
		strategistListener := true
	else if (strategistListener = kFalse)
		strategistListener := false
	
	if debug
		setDebug(true)
	
	RaceStrategist.Instance := new RaceStrategist(kSimulatorConfiguration, readConfiguration(strategistSettingsFile)
												, strategistName, strategistLanguage, strategistSpeaker, strategistListener, voiceServer)
	
	registerEventHandler("Strategist", "handleStrategistRemoteCalls")
	
	if (debug && strategistSpeaker) {
		RaceStrategist.Instance.getSpeaker()
		
		RaceStrategist.Instance.createKnowledgeBase({})
	}
	
	if (strategistLogo && !kSilentMode)
		showLogo(strategistName)
	
	if (remotePID != 0) {
		vRemotePID := remotePID
		
		SetTimer checkRemoteProcessAlive, 10000
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                          Event Handler Section                          ;;;
;;;-------------------------------------------------------------------------;;;

shutdownRaceStrategist(shutdown := false) {
	if shutdown
		ExitApp 0

	if (RaceStrategist.Instance.Session == kSessionFinished) {
		RaceStrategist.Instance.shutdownVoiceAssistant()
		
		callback := Func("shutdownRaceStrategist").Bind(true)
		
		SetTimer %callback%, -5000
	}
	else
		SetTimer shutdownRaceStrategist, -1000
}

handleStrategistRemoteCalls(event, data) {
	if InStr(data, ":") {
		data := StrSplit(data, ":", , 2)
		
		if (data[1] = "Shutdown") {
			SetTimer shutdownRaceStrategist, -20000
			
			return true
		}
		else
			return withProtection(ObjBindMethod(RaceStrategist.Instance, data[1]), string2Values(";", data[2])*)
	}
	else if (data = "Shutdown")
		SetTimer shutdownRaceStrategist, -20000
	else
		return withProtection(ObjBindMethod(RaceStrategist.Instance, data))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

startRaceStrategist()