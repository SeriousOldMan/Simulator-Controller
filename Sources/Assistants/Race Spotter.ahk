;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Spotter                   ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
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
; ListLines Off					; Disable execution history

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Artificial Intelligence.ico
;@Ahk2Exe-ExeName Race Spotter.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Task.ahk
#Include ..\Libraries\Messages.ahk
#Include ..\Libraries\RuleEngine.ahk
#Include ..\Assistants\Libraries\RaceSpotter.ahk


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

showLogo(name) {
	local info := kVersion . " - 2022, Oliver Juwig`nCreative Commons - BY-NC-SA"
	local logo := kResourcesDirectory . "Rotating Brain.gif"
	local image := "1:" . logo
	local mainScreen, mainScreenTop, mainScreenLeft, mainScreenRight, mainScreenBottom, x, y, title1, title2, html

	static videoPlayer

	SysGet mainScreen, MonitorWorkArea

	x := mainScreenRight - 299
	y := mainScreenBottom - 234

	title1 := translate("Modular Simulator Controller System")
	title2 := substituteVariables(translate("%name% - The Virtual Race Spotter"), {name: name})
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

checkRemoteProcessAlive(pid) {
	Process Exist, %pid%

	if !ErrorLevel
		ExitApp 0
}

startRaceSpotter() {
	local icon := kIconsDirectory . "Artificial Intelligence.ico"
	local remotePID := false
	local spotterName := "Elisa"
	local spotterLogo := false
	local spotterLanguage := false
	local spotterSynthesizer := true
	local spotterSpeaker := false
	local spotterSpeakerVocalics := false
	local spotterRecognizer := true
	local spotterListener := false
	local debug := false
	local voiceServer, index

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Race Spotter

	Process Exist, Voice Server.exe

	voiceServer := ErrorLevel

	index := 1

	while (index < A_Args.Length()) {
		switch A_Args[index] {
			case "-Remote":
				remotePID := A_Args[index + 1]
				index += 2
			case "-Name":
				spotterName := A_Args[index + 1]
				index += 2
			case "-Logo":
				spotterLogo := (((A_Args[index + 1] = kTrue) || (A_Args[index + 1] = true)) ? true : false)
				index += 2
			case "-Language":
				spotterLanguage := A_Args[index + 1]
				index += 2
			case "-Synthesizer":
				spotterSynthesizer := A_Args[index + 1]
				index += 2
			case "-Speaker":
				spotterSpeaker := A_Args[index + 1]
				index += 2
			case "-SpeakerVocalics":
				spotterSpeakerVocalics := A_Args[index + 1]
				index += 2
			case "-Recognizer":
				spotterRecognizer := A_Args[index + 1]
				index += 2
			case "-Listener":
				spotterListener := A_Args[index + 1]
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

	if (spotterSpeaker = kTrue)
		spotterSpeaker := true
	else if (spotterSpeaker = kFalse)
		spotterSpeaker := false

	if (spotterListener = kTrue)
		spotterListener := true
	else if (spotterListener = kFalse)
		spotterListener := false

	if debug
		setDebug(true)

	RaceSpotter.Instance := new RaceSpotter(kSimulatorConfiguration
										  , remotePID ? new RaceSpotter.RaceSpotterRemoteHandler(remotePID) : false
										  , spotterName, spotterLanguage
										  , spotterSynthesizer, spotterSpeaker, spotterSpeakerVocalics
										  , spotterRecognizer, spotterListener, voiceServer)

	registerMessageHandler("Race Spotter", "handleSpotterMessage")

	if (debug && spotterSpeaker) {
		RaceSpotter.Instance.getSpeaker()

		RaceSpotter.Instance.updateDynamicValues({KnowledgeBase: RaceSpotter.Instance.createKnowledgeBase({})})
	}

	if (spotterLogo && !kSilentMode)
		showLogo(spotterName)

	if remotePIP
		Task.startTask(Func("checkRemoteProcessAlive").Bind(remotePID), 10000, kLowPriority)

	return
}


;;;-------------------------------------------------------------------------;;;
;;;                         Message Handler Section                         ;;;
;;;-------------------------------------------------------------------------;;;

shutdownRaceSpotter(shutdown := false) {
	if shutdown
		ExitApp 0

	if (RaceSpotter.Instance.Session == kSessionFinished)
		Task.startTask(Func("shutdownRaceSpotter").Bind(true), 10000, kLowPriority)
	else
		Task.startTask("shutdownRaceSpotter", 1000, kLowPriority)

	return false
}

handleSpotterMessage(category, data) {
	if InStr(data, ":") {
		data := StrSplit(data, ":", , 2)

		if (data[1] = "Shutdown") {
			Task.startTask("shutdownRaceSpotter", 20000, kLowPriority)

			return true
		}
		else
			return withProtection(ObjBindMethod(RaceSpotter.Instance, data[1]), string2Values(";", data[2])*)
	}
	else if (data = "Shutdown")
		Task.startTask("shutdownRaceSpotter", 20000, kLowPriority)
	else
		return withProtection(ObjBindMethod(RaceSpotter.Instance, data))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

startRaceSpotter()