;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Strategist                 ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

;@SC-IF %configuration% == Development
#Include "..\Framework\Development.ahk"
;@SC-EndIF

;@SC-If %configuration% == Production
;@SC #Include ..\Framework\Production.ahk
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Artificial Intelligence.ico
;@Ahk2Exe-ExeName Race Strategist.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Process.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Task.ahk"
#Include "..\Libraries\Messages.ahk"
#Include "..\Libraries\RuleEngine.ahk"
#Include "..\Assistants\Libraries\RaceStrategist.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

showLogo(name) {
	/*
	local info := kVersion . " - 2023, Oliver Juwig`nCreative Commons - BY-NC-SA"
	local logo := kResourcesDirectory . "Rotating Brain.gif"
	local image := "1:" . logo
	local mainScreen, mainScreenTop, mainScreenLeft, mainScreenRight, mainScreenBottom, x, y, title1, title2, html

	static videoPlayer

	MonitorGetWorkArea(, &mainScreenLeft, &mainScreenTop, &mainScreenRight, &mainScreenBottom)

	x := mainScreenLeft
	y := mainScreenBottom - 234

	title1 := translate("Modular Simulator Controller System")
	title2 := substituteVariables(translate("%name% - The Virtual Race Strategist"), {name: name})
	SplashImageGui := Gui("ToolWindow -Sysmenu Disabled"), SplashImageGui.SetFont("bold"), SplashImageGui.AddText("w200 Center", title1 "`n" title2), SplashImageGui.AddPicture("w200 h-1", image), SplashImageGui.SetFont("norm"), SplashImageGui.AddText("w200 Center", info), SplashImageGui.Show()

	Logo := Gui()
	Logo.Opt("-Border -Caption")
	Logo.Add("ActiveX", "x0 y0 w279 h155 VvideoPlayer", "shell explorer")

	videoPlayer.Navigate("about:blank")

	html := "<html><body style='background-color: transparent' style='overflow:hidden' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><img src='" . logo . "' width=279 height=155 border=0 padding=0></body></html>"

	videoPlayer.document.write(html)

	x += 10
	y += 40

	Logo.MarginX := "0", Logo.MarginY := "0"
	Logo.Opt("+AlwaysOnTop")
	Logo.Show("AutoSize x" . x . " y" . y)
	*/
}

checkRemoteProcessAlive(pid) {
	if !ProcessExist(pid)
		ExitApp(0)
}

startRaceStrategist() {
	local icon := kIconsDirectory . "Artificial Intelligence.ico"
	local remotePID := false
	local strategistName := "Cato"
	local strategistLogo := false
	local strategistLanguage := false
	local strategistSynthesizer := true
	local strategistSpeaker := false
	local strategistSpeakerVocalics := false
	local strategistRecognizer := true
	local strategistListener := false
	local strategistMuted := false
	local debug := false
	local voiceServer, index, strategist, label

	TraySetIcon(icon, "1")
	A_IconTip := "Race Strategist"

	voiceServer := ProcessExist("Voice Server.exe")

	index := 1

	while (index < A_Args.Length) {
		switch A_Args[index], false {
			case "-Remote":
				remotePID := A_Args[index + 1]
				index += 2
			case "-Name":
				strategistName := A_Args[index + 1]
				index += 2
			case "-Logo":
				strategistLogo := (((A_Args[index + 1] = kTrue) || (A_Args[index + 1] = true) || (A_Args[index + 1] = "On")) ? true : false)
				index += 2
			case "-Language":
				strategistLanguage := A_Args[index + 1]
				index += 2
			case "-Synthesizer":
				strategistSynthesizer := A_Args[index + 1]
				index += 2
			case "-Speaker":
				strategistSpeaker := A_Args[index + 1]
				index += 2
			case "-SpeakerVocalics":
				strategistSpeakerVocalics := A_Args[index + 1]
				index += 2
			case "-Recognizer":
				strategistRecognizer := A_Args[index + 1]
				index += 2
			case "-Listener":
				strategistListener := A_Args[index + 1]
				index += 2
			case "-Muted":
				strategistMuted := true
				index += 1
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

	strategist := new RaceStrategist(kSimulatorConfiguration
								   , remotePID ? RaceStrategist.RaceStrategistRemoteHandler(remotePID) : false
								   , strategistName, strategistLanguage
								   , strategistSynthesizer, strategistSpeaker, strategistSpeakerVocalics
								   , strategistRecognizer, strategistListener, strategistMuted, voiceServer)

	RaceStrategist.Instance := strategist

	SupportMenu.Insert("1&")

	label := translate("Debug Rule System")

	SupportMenu.Insert("1&", label, ObjBindMethod(strategist, "toggleDebug", kDebugRules))

	if strategist.Debug[kDebugRules]
		SupportMenu.Check(label)

	label := translate("Debug Knowledgebase")

	SupportMenu.Insert("1&", label, ObjBindMethod(strategist, "toggleDebug", kDebugKnowledgeBase))

	if strategist.Debug[kDebugKnowledgebase]
		SupportMenu.Check(label)

	registerMessageHandler("Race Strategist", handleStrategistMessage)

	if (debug && strategistSpeaker) {
		strategist.getSpeaker()

		strategist.updateDynamicValues({KnowledgeBase: RaceStrategist.Instance.createKnowledgeBase({})})
	}

	if (strategistLogo && !kSilentMode)
		showLogo(strategistName)

	if remotePID
		Task.startTask(new PeriodicTask(checkRemoteProcessAlive.Bind(remotePID), 10000, kLowPriority))

	return
}


;;;-------------------------------------------------------------------------;;;
;;;                         Message Handler Section                         ;;;
;;;-------------------------------------------------------------------------;;;

shutdownRaceStrategist(shutdown := false) {
	if shutdown
		ExitApp(0)

	if (RaceStrategist.Instance.Session == kSessionFinished)
		Task.startTask(shutdownRaceStrategist.Bind(true), 10000, kLowPriority)
	else
		Task.startTask(shutdownRaceStrategist, 1000, kLowPriority)

	return false
}

handleStrategistMessage(category, data) {
	if InStr(data, ":") {
		data := StrSplit(data, ":", , 2)

		if (data[1] = "Shutdown") {
			Task.startTask(shutdownRaceStrategist, 20000, kLowPriority)

			return true
		}
		else
			return withProtection(ObjBindMethod(RaceStrategist.Instance, data[1]), string2Values(";", data[2])*)
	}
	else if (data = "Shutdown")
		Task.startTask(shutdownRaceStrategist, 20000, kLowPriority)
	else
		return withProtection(ObjBindMethod(RaceStrategist.Instance, data))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

startRaceStrategist()