;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - RaceStrategist Test             ;;;
;;;                                         (Race Strategist Rules)         ;;;
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
#Include ..\Assistants\Libraries\RaceStrategist.ahk
#Include AHKUnit\AHKUnit.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Private Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;



;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

if !GetKeyState("Ctrl") {
	AHKUnit.Run()
}
else {
	raceNr := 13
	strategist := new RaceStrategist(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race " . raceNr . "\Race Strategist.settings")
								   , "Khato", "de", true, true)

	strategist.VoiceAssistant.setDebug(kDebugGrammars, false)
	
	if (raceNr == 13) {
		done := false
		
		Loop {
			lap := A_Index
		
			Loop {
				data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race " . raceNr . "\Race Strategist Lap " . lap . "." . A_Index . ".data")
			
				if (data.Count() == 0) {
					if (A_Index == 1)
						done := true
					
					break
				}
				else {
					if (A_Index == 1) {
						strategist.addLap(lap, data)
				
						strategist.dumpKnowledge(strategist.KnowledgeBase)
						
						MsgBox % "Lap " . lap . " loaded - Continue?"
					}
					else
						strategist.updateLap(lap, data)
					
					if isDebug()
						showMessage("Data " lap . "." . A_Index . " loaded...")
				}
			}
		} until done
		
		strategist.finishSession()
		
		while strategist.KnowledgeBase
			Sleep 1000
	}
	
	if isDebug()
		MsgBox Done...
	
	ExitApp
}

show(context, args*) {
	showMessage(values2string(" ", args*), "Race Strategist Test", "Information.png", 2500)
	
	return true
}