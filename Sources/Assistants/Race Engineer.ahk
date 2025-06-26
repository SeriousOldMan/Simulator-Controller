﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Engineer                   ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Artificial Intelligence Yellow.ico
;@Ahk2Exe-ExeName Race Engineer.exe
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
#Include "Libraries\RaceEngineer.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

showLogo(name) {
	local info := kVersion . " - 2025, Oliver Juwig`nCreative Commons - BY-NC-SA"
	local logo := kResourcesDirectory . "Rotating Brain.gif"
	local title1 := translate("Modular Simulator Controller System")
	local title2 := substituteVariables(translate("%name% - The AI Race Engineer"), {name: name})
	local mainScreenTop, mainScreenLeft, mainScreenRight, mainScreenBottom, x, y, html
	local logoGui, videoPlayer

	MonitorGetWorkArea(, &mainScreenLeft, &mainScreenTop, &mainScreenRight, &mainScreenBottom)

	x := mainScreenRight - 299
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

startupRaceEngineer() {
	local icon := kIconsDirectory . "Artificial Intelligence Yellow.ico"
	local remotePID := false
	local engineerName := "Jona"
	local engineerLogo := false
	local engineerLanguage := false
	local engineerSynthesizer := true
	local engineerSpeaker := false
	local engineerSpeakerVocalics := false
	local engineerSpeakerBooster := false
	local engineerRecognizer := true
	local engineerListener := false
	local engineerListenerBooster := false
	local engineerConversationBooster := false
	local engineerAgentBooster := false
	local engineerMuted := false
	local debug := false
	local voiceServer, index, engineer, label

	TraySetIcon(icon, "1")
	A_IconTip := "Race Engineer"

	voiceServer := ProcessExist("Voice Server.exe")

	index := 1

	while (index < A_Args.Length) {
		switch A_Args[index], false {
			case "-Remote":
				remotePID := A_Args[index + 1]
				index += 2
			case "-Name":
				engineerName := A_Args[index + 1]
				index += 2
			case "-Logo":
				engineerLogo := (((A_Args[index + 1] = kTrue) || (A_Args[index + 1] = true) || (A_Args[index + 1] = "On")) ? true : false)
				index += 2
			case "-Language":
				engineerLanguage := A_Args[index + 1]
				index += 2
			case "-Synthesizer":
				engineerSynthesizer := A_Args[index + 1]
				index += 2
			case "-Speaker":
				engineerSpeaker := A_Args[index + 1]
				index += 2
			case "-SpeakerVocalics":
				engineerSpeakerVocalics := A_Args[index + 1]
				index += 2
			case "-SpeakerBooster":
				engineerSpeakerBooster := A_Args[index + 1]
				index += 2
			case "-Recognizer":
				engineerRecognizer := A_Args[index + 1]
				index += 2
			case "-Listener":
				engineerListener := A_Args[index + 1]
				index += 2
			case "-ListenerBooster":
				engineerListenerBooster := A_Args[index + 1]
				index += 2
			case "-ConversationBooster":
				engineerConversationBooster := A_Args[index + 1]
				index += 2
			case "-AgentBooster":
				engineerAgentBooster := A_Args[index + 1]
				index += 2
			case "-Muted":
				engineerMuted := true
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

	if (engineerSpeaker = kTrue)
		engineerSpeaker := true
	else if (engineerSpeaker = kFalse)
		engineerSpeaker := false

	if (engineerListener = kTrue)
		engineerListener := true
	else if (engineerListener = kFalse)
		engineerListener := false

	if debug
		setDebug(true)

	engineer := RaceEngineer(kSimulatorConfiguration
						   , remotePID ? RaceEngineer.RaceEngineerRemoteHandler(remotePID) : false
						   , engineerName, engineerLanguage
						   , engineerSynthesizer, engineerSpeaker, engineerSpeakerVocalics, engineerSpeakerBooster
						   , engineerRecognizer, engineerListener, engineerListenerBooster, engineerConversationBooster, engineerAgentBooster
						   , engineerMuted, voiceServer)

	RaceEngineer.Instance := engineer

	SupportMenu.Insert("1&")

	label := translate("Debug Rule System")

	SupportMenu.Insert("1&", label, ObjBindMethod(engineer, "toggleDebug", kDebugRules))

	if engineer.Debug[kDebugRules]
		SupportMenu.Check(label)

	label := translate("Debug Knowledgebase")

	SupportMenu.Insert("1&", label, ObjBindMethod(engineer, "toggleDebug", kDebugKnowledgeBase))

	if engineer.Debug[kDebugKnowledgebase]
		SupportMenu.Check(label)

	registerMessageHandler("Race Engineer", handleEngineerMessage)

	if engineerSpeaker
		engineer.getSpeaker()

	if debug
		engineer.updateDynamicValues({KnowledgeBase: RaceEngineer.Instance.createKnowledgeBase()})

	if (engineerLogo && !kSilentMode)
		showLogo(engineerName)

	if remotePID
		Task.startTask(PeriodicTask(checkRemoteProcessAlive.Bind(remotePID), 10000, kLowPriority))

	startupProcess()
}


;;;-------------------------------------------------------------------------;;;
;;;                         Message Handler Section                         ;;;
;;;-------------------------------------------------------------------------;;;

shutdownRaceEngineer(shutdown := false) {
	if shutdown
		ExitApp(0)

	if (RaceEngineer.Instance.Session == kSessionFinished)
		Task.startTask(shutdownRaceEngineer.Bind(true), 10000, kLowPriority)
	else
		Task.startTask(shutdownRaceEngineer, 1000, kLowPriority)

	return false
}

handleEngineerMessage(category, data) {
	if InStr(data, ":") {
		data := StrSplit(data, ":", , 2)

		if (data[1] = "Shutdown") {
			Task.startTask(shutdownRaceEngineer, 20000, kLowPriority)

			return true
		}
		else
			return withProtection(ObjBindMethod(RaceEngineer.Instance, data[1]), string2Values(";", data[2])*)
	}
	else if (data = "Shutdown")
		Task.startTask(shutdownRaceEngineer, 20000, kLowPriority)
	else
		return withProtection(ObjBindMethod(RaceEngineer.Instance, data))
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

startupRaceEngineer()