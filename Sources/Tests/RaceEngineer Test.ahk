;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - RaceEngineer Test               ;;;
;;;                                         (Race Engineer Rules)           ;;;
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

; SetBatchLines -1				; Maximize CPU utilization
; ListLines Off					; Disable execution history


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\RuleEngine.ahk
#Include ..\Libraries\RaceEngineer.ahk
#Include AHKUnit\AHKUnit.ahk


;;;-------------------------------------------------------------------------;;;
;;;                              Test Section                               ;;;
;;;-------------------------------------------------------------------------;;;

class RuleSetValidation extends Assert {
	RuleSetValidation_Test() {
		FileRead engineerRules, %kConfigDirectory%ACC Race Engineer.rules
		
		compiler := new RuleCompiler()
		
		productions := false
		reductions := false
		
		compiler.compileRules(engineerRules, productions, reductions)
		
		this.AssertEqual(3, productions.Length(), "Not all production rules compiled...")
		this.AssertEqual(21, reductions.Length(), "Not all reduction rules compiled...")
	}
}

class LapUpdate extends Assert {
}

class TrendProjection extends Assert {
}

class PitstopHandling extends Assert {
}

dumpRules(productions, reductions) {
	FileDelete %kUserHomeDirectory%Temp\rules.out

	for ignore, production in productions {
		text := production.toString() . "`n"
		FileAppend %text%, %kUserHomeDirectory%Temp\rules.out
	}

	for ignore, reduction in reductions {
		text := reduction.toString() . "`n"
		FileAppend %text%, %kUserHomeDirectory%Temp\rules.out
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

/*
AHKUnit.AddTestClass(RuleSetValidation)
AHKUnit.AddTestClass(LapUpdate)
AHKUnit.AddTestClass(TrendProjection)
AHKUnit.AddTestClass(PitstopHandling)

AHKUnit.Run()
*/


showHere(kb, args*) {
	MsgBox % "Here: " . values2String(", ", args*)
	
	return true
}

engineer := new RaceEngineer(false, readConfiguration(getFileName("Race Engineer.settings", kUserConfigDirectory, kConfigDirectory))
						   , false, "Jona", "Microsoft Zira Desktop", "Microsoft Server Speech Recognition Language - TELE (en-US)") ; "Microsoft Server Speech Recognition Language - Kinect (en-AU)"


Loop {
	data := readConfiguration(kSourcesDirectory . "Tests\Lap " . A_Index . ".data")
	
	if (data.Count() == 0)
		break
	else {
		engineer.addLap(A_Index, data)
	
		MsgBox % "Lap " . A_Index . " loaded - Continue?"
	}
}

MsgBox Done - Race on

ExitApp



/*
FileRead engineerRules, %kConfigDirectory%\Race Engineer.rules
		
compiler := new RuleCompiler()

productions := false
reductions := false

compiler.compileRules(engineerRules, productions, reductions)

dumpRules(productions, reductions)

data := readConfiguration(kSourcesDirectory . "Tests\Race.data")

initialFacts := getConfigurationSectionValues(data, "Race", {}).Clone()

engine := new RuleEngine(productions, reductions, initialFacts)
kb := engine.createKnowledgeBase(engine.createFacts(), engine.createRules())
; kb.RuleEngine.setTraceLevel(kTraceMedium)

Loop {
	section := "Lap " . A_Index
	
	lapData := getConfigurationSectionValues(data, section, {}).Clone()
	
	if (lapData.Count() == 0)
		break
	else {
		for theFact, value in lapData
			kb.addFact(theFact, value)
		
		if (A_Index == 1)
			kb.addFact("Lap", A_Index)
		else
			kb.setValue("Lap", A_Index)
		
		kb.produce()
		
		dumpFacts(kb)
	}
	
	if (A_Index == 3)
		pitstop(kb)
	
	if (A_Index == 5)
		pitstop(kb)
}

pitstop(kb) {
	kb.addFact("Pitstop.Plan", true)

	kb.produce()
	;kb.RuleEngine.setTraceLevel(kTraceMedium)

	s := new SpeechGenerator("Microsoft Zira Desktop")

	s.speak("Ok, we have the following for Pitstop number " . kb.getValue("Pitstop.Planned.Nr"), true)
	Sleep 100

	fuel := kb.getValue("Pitstop.Planned.Fuel", 0)
	if (fuel == 0)
		s.speak("Refueling is not necessary", true)
	else
		s.speak("We have to refuel " . Round(fuel) . " litres", true)
	
	s.speak("We will use " . kb.getValue("Pitstop.Planned.Tyre.Compound") . " tyre compound and tyre set number " . kb.getValue("Pitstop.Planned.Tyre.Set"), true)
	s.speak("Pressure front left " . Round(kb.getValue("Pitstop.Planned.Tyre.Pressure.FL"), 1), true)
	s.speak("Pressure front right " . Round(kb.getValue("Pitstop.Planned.Tyre.Pressure.FR"), 1), true)
	s.speak("Pressure rear left" . Round(kb.getValue("Pitstop.Planned.Tyre.Pressure.RL"), 1), true)
	s.speak("Pressure rear right " . Round(kb.getValue("Pitstop.Planned.Tyre.Pressure.RR"), 1), true)

	if kb.getValue("Pitstop.Planned.Repair.Suspension", false)
		s.speak("The suspension must be repaired", true)
	else
		s.speak("The suspension looks fine", true)

	if kb.getValue("Pitstop.Planned.Repair.Bodywork", false)
		s.speak("Bodywork and aerodynamic elements must be repaired", true)
	else
		s.speak("Bodywork and aerodynamic elements should be good", true)

	Sleep 100
	s.speak("Do you agree?", true)
	
kb.addFact("Pitstop.Prepare", true)	
			kb.produce()
	kb.addFact("Pitstop.Lap", kb.getValue("Lap") + 1)
	kb.produce()
dumpFacts(kb)
		msgbox here
}
		
dumpFacts(kb)

MsgBox % "Done - Race On"

exitapp
*/