;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Strategist                 ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Artificial Intelligence Green.ico
;@Ahk2Exe-ExeName Race Strategist.exe
;@Ahk2Exe-SetCompanyName Oliver Juwig (TheBigO)
;@Ahk2Exe-SetCopyright TheBigO - Creative Commons - BY-NC-SA
;@Ahk2Exe-SetProductName Simulator Controller
;@Ahk2Exe-SetVersion 0.0.0.0


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Process.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Extensions\GIFViewer.ahk"
#Include "..\Framework\Extensions\Task.ahk"
#Include "..\Framework\Extensions\Messages.ahk"
#Include "..\Framework\Extensions\RuleEngine.ahk"
#Include "..\Assistants\Libraries\RaceStrategist.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

showLogo(name) {
	local info := kVersion . " - 2025, Oliver Juwig`nCreative Commons - BY-NC-SA"
	local logo := kResourcesDirectory . "Rotating Brain.gif"
	local title1 := translate("Modular Simulator Controller System")
	local title2 := substituteVariables(translate("%name% - The AI Race Strategist"), {name: name})
	local mainScreenTop, mainScreenLeft, mainScreenRight, mainScreenBottom, x, y, html
	local logoGui, videoPlayer

	MonitorGetWorkArea(, &mainScreenLeft, &mainScreenTop, &mainScreenRight, &mainScreenBottom)

	x := mainScreenLeft
	y := mainScreenBottom - 234

	logoGui := Window()

	logoGui.SetFont("Bold")
	logoGui.AddText("w279 Center", title1 . "`n" . title2)

	videoPlayer := logoGui.Add("GIFViewer", "x10 y40 w279 h155", logo)

	logoGui.SetFont("Norm")
	logoGui.AddText("w279 Center", info)

	logoGui.Show("X" . x . " Y" . y)

	videoPlayer.Start()

	WinSetTransparent(224, logoGui)
}

checkRemoteProcessAlive(pid) {
	if !ProcessExist(pid)
		ExitApp(0)
}

startupRaceStrategist() {
	local icon := kIconsDirectory . "Artificial Intelligence Green.ico"
	local remotePID := false
	local strategistName := "Cato"
	local strategistLogo := false
	local strategistLanguage := false
	local strategistSynthesizer := true
	local strategistSpeaker := false
	local strategistSpeakerVocalics := false
	local strategistSpeakerBooster := false
	local strategistRecognizer := true
	local strategistListener := false
	local strategistListenerBooster := false
	local strategistConversationBooster := false
	local strategistAgentBooster := false
	local strategistMuted := false
	local debug := false
	local voiceServer, index, strategist, label

	TraySetIcon(icon, "1")
	A_IconTip := "Race Strategist"

	ProcessSetPriority("L")

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
			case "-SpeakerBooster":
				strategistSpeakerBooster := A_Args[index + 1]
				index += 2
			case "-Recognizer":
				strategistRecognizer := A_Args[index + 1]
				index += 2
			case "-Listener":
				strategistListener := A_Args[index + 1]
				index += 2
			case "-ListenerBooster":
				strategistListenerBooster := A_Args[index + 1]
				index += 2
			case "-ConversationBooster":
				strategistConversationBooster := A_Args[index + 1]
				index += 2
			case "-AgentBooster":
				strategistAgentBooster := A_Args[index + 1]
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

	strategist := RaceStrategist(kSimulatorConfiguration
							   , remotePID ? RaceStrategist.RaceStrategistRemoteHandler(remotePID) : false
							   , strategistName, strategistLanguage
							   , strategistSynthesizer, strategistSpeaker, strategistSpeakerVocalics, strategistSpeakerBooster
							   , strategistRecognizer, strategistListener, strategistListenerBooster, strategistConversationBooster, strategistAgentBooster
							   , strategistMuted, voiceServer)

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

	if strategistSpeaker
		strategist.getSpeaker()

	if debug
		strategist.updateDynamicValues({KnowledgeBase: RaceStrategist.Instance.createKnowledgeBase({})})

	if (strategistLogo && !kSilentMode)
		showLogo(strategistName)

	if remotePID
		Task.startTask(PeriodicTask(checkRemoteProcessAlive.Bind(remotePID), 10000, kLowPriority))

	startupProcess()
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
;;;                          Plugin Include Section                         ;;;
;;;-------------------------------------------------------------------------;;;

if kLogStartup
	logMessage(kLogOff, "Loading plugins...")

#Include "..\Plugins\Simulator Providers.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

startupRaceStrategist()