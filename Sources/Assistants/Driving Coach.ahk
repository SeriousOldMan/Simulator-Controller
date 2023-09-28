;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Driving Coach                   ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Coach.ico
;@Ahk2Exe-ExeName Driving Coach.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Process.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\GIFViewer.ahk"
#Include "..\Libraries\Task.ahk"
#Include "..\Libraries\Messages.ahk"
#Include "..\Libraries\RuleEngine.ahk"
#Include "..\Assistants\Libraries\DrivingCoach.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

showLogo(name) {
	local info := kVersion . " - 2023, Oliver Juwig`nCreative Commons - BY-NC-SA"
	local logo := kResourcesDirectory . "Rotating Brain.gif"
	local title1 := translate("Modular Simulator Controller System")
	local title2 := substituteVariables(translate("%name% - The Virtual Driving Coach"), {name: name})
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

startupDrivingCoach() {
	local icon := kIconsDirectory . "Coach.ico"
	local remotePID := false
	local coachName := "Aiden"
	local coachLogo := false
	local coachLanguage := false
	local coachSynthesizer := true
	local coachSpeaker := false
	local coachSpeakerVocalics := false
	local coachRecognizer := true
	local coachListener := false
	local coachMuted := false
	local debug := false
	local voiceServer, index, coach, label

	TraySetIcon(icon, "1")
	A_IconTip := "Driving Coach"

	startupProcess()

	voiceServer := ProcessExist("Voice Server.exe")

	index := 1

	while (index < A_Args.Length) {
		switch A_Args[index], false {
			case "-Remote":
				remotePID := A_Args[index + 1]
				index += 2
			case "-Name":
				coachName := A_Args[index + 1]
				index += 2
			case "-Logo":
				coachLogo := (((A_Args[index + 1] = kTrue) || (A_Args[index + 1] = true)) ? true : false)
				index += 2
			case "-Language":
				coachLanguage := A_Args[index + 1]
				index += 2
			case "-Synthesizer":
				coachSynthesizer := A_Args[index + 1]
				index += 2
			case "-Speaker":
				coachSpeaker := A_Args[index + 1]
				index += 2
			case "-SpeakerVocalics":
				coachSpeakerVocalics := A_Args[index + 1]
				index += 2
			case "-Recognizer":
				coachRecognizer := A_Args[index + 1]
				index += 2
			case "-Listener":
				coachListener := A_Args[index + 1]
				index += 2
			case "-Muted":
				coachMuted := true
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

	if (coachSpeaker = kTrue)
		coachSpeaker := true
	else if (coachSpeaker = kFalse)
		coachSpeaker := false

	if (coachListener = kTrue)
		coachListener := true
	else if (coachListener = kFalse)
		coachListener := false

	if debug
		setDebug(true)

	coach := DrivingCoach(kSimulatorConfiguration
						, remotePID ? DrivingCoach.DrivingCoachRemoteHandler(remotePID) : false
						, coachName, coachLanguage
						, coachSynthesizer, coachSpeaker, coachSpeakerVocalics
						, coachRecognizer, coachListener, coachMuted, voiceServer)

	DrivingCoach.Instance := coach

	SupportMenu.Insert("1&")

	label := translate("Debug Rule System")

	SupportMenu.Insert("1&", label, ObjBindMethod(coach, "toggleDebug", kDebugRules))

	if coach.Debug[kDebugRules]
		SupportMenu.Check(label)

	label := translate("Debug Knowledgebase")

	SupportMenu.Insert("1&", label, ObjBindMethod(coach, "toggleDebug", kDebugKnowledgeBase))

	if coach.Debug[kDebugKnowledgebase]
		SupportMenu.Check(label)

	registerMessageHandler("Driving Coach", handleCoachMessage)

	if coachSpeaker
		coach.getSpeaker()

	if debug
		coach.updateDynamicValues({KnowledgeBase: DrivingCoach.Instance.createKnowledgeBase({})})

	if (coachLogo && !kSilentMode)
		showLogo(coachName)

	if remotePID
		Task.startTask(PeriodicTask(checkRemoteProcessAlive.Bind(remotePID), 10000, kLowPriority))

	return
}


;;;-------------------------------------------------------------------------;;;
;;;                         Message Handler Section                         ;;;
;;;-------------------------------------------------------------------------;;;

shutdownDrivingCoach(shutdown := false) {
	if shutdown
		ExitApp(0)

	if (DrivingCoach.Instance.Session == kSessionFinished)
		Task.startTask(shutdownDrivingCoach.Bind(true), 10000, kLowPriority)
	else
		Task.startTask(shutdownDrivingCoach, 1000, kLowPriority)

	return false
}

handleCoachMessage(category, data) {
	if InStr(data, ":") {
		data := StrSplit(data, ":", , 2)

		if (data[1] = "Shutdown") {
			Task.startTask(shutdownDrivingCoach, 20000, kLowPriority)

			return true
		}
		else
			return withProtection(ObjBindMethod(DrivingCoach.Instance, data[1]), string2Values(";", data[2])*)
	}
	else if (data = "Shutdown")
		Task.startTask(shutdownDrivingCoach, 20000, kLowPriority)
	else
		return withProtection(ObjBindMethod(DrivingCoach.Instance, data))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

startupDrivingCoach()