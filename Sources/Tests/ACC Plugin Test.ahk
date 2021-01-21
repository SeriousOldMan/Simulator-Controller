;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - ACC Plugin Test                 ;;;
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

dumpFacts(knowledgeBase) {
	FileDelete %kUserHomeDirectory%Temp\facts.out

	for key, value in knowledgeBase.Facts.Facts {
		text := key . " = " . value . "`n"
		FileAppend %text%, %kUserHomeDirectory%Temp\facts.out
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

FileRead engineerRules, %kSourcesDirectory%Plugins\ACC Race Engineer.rules
		
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
}

MsgBox % "Done"

kb.addFact("Pitstop.Prepare", true)

kb.produce()
		
dumpFacts(kb)

MsgBox % "Pistop"

exitapp