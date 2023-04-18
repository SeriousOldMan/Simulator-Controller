;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Spotter                   ;;;
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
;@SC #Include "..\Framework\Production.ahk"
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Artificial Intelligence.ico
;@Ahk2Exe-ExeName Race Spotter.exe


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
#Include "..\Assistants\Libraries\RaceSpotter.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

showLogo(name) {
	local info := kVersion . " - 2023, Oliver Juwig`nCreative Commons - BY-NC-SA"
	local logo := kResourcesDirectory . "Rotating Brain.gif"
	local title1 := translate("Modular Simulator Controller System")
	local title2 := substituteVariables(translate("%name% - The Virtual Race Spotter"), {name: name})
	local mainScreenTop, mainScreenLeft, mainScreenRight, mainScreenBottom, x, y, html
	local logoGui, videoPlayer

	MonitorGetWorkArea(, &mainScreenLeft, &mainScreenTop, &mainScreenRight, &mainScreenBottom)

	x := mainScreenLeft
	y := mainScreenBottom - 234

	logoGui := Window()

	logoGui.SetFont("Bold")
	logoGui.AddText("w279 Center", title1 . "`n" . title2)

	videoPlayer := logoGui.Add("ActiveX", "x10 y40 w279 h155", "shell explorer").Value

	logoGui.SetFont("Norm")
	logoGui.AddText("w279 Center", info)

	videoPlayer.navigate("about:blank")

	html := "<html><body style='background-color: transparent' style='overflow:hidden' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><img src='" . logo . "' width=279 height=155 border=0 padding=0></body></html>"

	videoPlayer.document.write(html)

	logoGui.Show("X" . x . " Y" . y)

	WinSetTransparent(255, , translate("Creative Commons - BY-NC-SA"))
}

checkRemoteProcessAlive(pid) {
	if !ProcessExist(pid)
		ExitApp(0)
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
	local spotterMuted := false
	local debug := false
	local voiceServer, index, spotter, label

	TraySetIcon(icon, "1")
	A_IconTip := "Race Spotter"

	voiceServer := ProcessExist("Voice Server.exe")

	index := 1

	while (index < A_Args.Length) {
		switch A_Args[index], false {
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
			case "-Muted":
				spotterMuted := true
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

	spotter := RaceSpotter(kSimulatorConfiguration
						 , remotePID ? RaceSpotter.RaceSpotterRemoteHandler(remotePID) : false
						 , spotterName, spotterLanguage
						 , spotterSynthesizer, spotterSpeaker, spotterSpeakerVocalics
						 , spotterRecognizer, spotterListener, spotterMuted, voiceServer)

	RaceSpotter.Instance := spotter

	SupportMenu.Insert("1&")

	label := translate("Debug Positions")

	SupportMenu.Insert("1&", label, ObjBindMethod(spotter, "toggleDebug", kDebugPositions))

	if spotter.Debug[kDebugPositions]
		SupportMenu.Check(label)

	label := translate("Debug Rule System")

	SupportMenu.Insert("1&", label, ObjBindMethod(spotter, "toggleDebug", kDebugRules))

	if spotter.Debug[kDebugRules]
		SupportMenu.Check(label)

	label := translate("Debug Knowledgebase")

	SupportMenu.Insert("1&", label, ObjBindMethod(spotter, "toggleDebug", kDebugKnowledgeBase))

	if spotter.Debug[kDebugKnowledgebase]
		SupportMenu.Check(label)

	registerMessageHandler("Race Spotter", handleSpotterMessage)

	if (debug && spotterSpeaker) {
		RaceSpotter.Instance.getSpeaker()

		RaceSpotter.Instance.updateDynamicValues({KnowledgeBase: RaceSpotter.Instance.createKnowledgeBase({})})
	}

	if (spotterLogo && !kSilentMode)
		showLogo(spotterName)

	if remotePID
		Task.startTask(PeriodicTask(checkRemoteProcessAlive.Bind(remotePID), 10000, kLowPriority))

	return
}


;;;-------------------------------------------------------------------------;;;
;;;                         Message Handler Section                         ;;;
;;;-------------------------------------------------------------------------;;;

shutdownRaceSpotter(shutdown := false) {
	if shutdown
		ExitApp(0)

	if (RaceSpotter.Instance.Session == kSessionFinished)
		Task.startTask(shutdownRaceSpotter.Bind(true), 10000, kLowPriority)
	else
		Task.startTask(shutdownRaceSpotter, 1000, kLowPriority)

	return false
}

handleSpotterMessage(category, data) {
	if InStr(data, ":") {
		data := StrSplit(data, ":", , 2)

		if (data[1] = "Shutdown") {
			Task.startTask(shutdownRaceSpotter, 20000, kLowPriority)

			return true
		}
		else
			return withProtection(ObjBindMethod(RaceSpotter.Instance, data[1]), string2Values(";", data[2])*)
	}
	else if (data = "Shutdown")
		Task.startTask(shutdownRaceSpotter, 20000, kLowPriority)
	else
		return withProtection(ObjBindMethod(RaceSpotter.Instance, data))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

startRaceSpotter()