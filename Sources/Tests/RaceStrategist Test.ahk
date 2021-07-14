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

class BasicReporting extends Assert {
	BasisTest() {
		strategist := new RaceStrategist(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 13\Race Strategist.settings"), false, false, false)

		Loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 13\Race Strategist Lap " . A_Index . ".1.data")
			
			if (data.Count() == 0)
				break
			else
				strategist.addLap(A_Index, data)
			
			switch A_Index {
				case 1, 2, 3:
					this.AssertEqual(7, strategist.KnowledgeBase.getValue("Position"), "Unexpected position detected in lap " . A_Index . "...")
				case 4:
					this.AssertEqual(6, strategist.KnowledgeBase.getValue("Position"), "Unexpected position detected in lap " . A_Index . "...")
				case 5:
					this.AssertEqual(5, strategist.KnowledgeBase.getValue("Position"), "Unexpected position detected in lap " . A_Index . "...")
			}
			
			fuel := Round(strategist.KnowledgeBase.getValue("Lap.Remaining.Fuel"))
			
			switch A_Index {
				case 2:
					this.AssertEqual(14, fuel, "Unexpected remaining laps detected in lap " . A_Index . "...")
				case 3:
					this.AssertEqual(13, fuel, "Unexpected remaining laps detected in lap " . A_Index . "...")
				case 4:
					this.AssertEqual(12, fuel, "Unexpected remaining laps detected in lap " . A_Index . "...")
				case 5:
					this.AssertEqual(11, fuel, "Unexpected remaining laps detected in lap " . A_Index . "...")
			}
			
			strategist.dumpKnowledge(strategist.KnowledgeBase)
			
			if (A_Index >= 5)
				break
		}
	}
	
	StandingsMemoryTest() {
		strategist := new RaceStrategist(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 13\Race Strategist.settings"), false, false, false)

		Loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 13\Race Strategist Lap " . A_Index . ".1.data")
			
			if (data.Count() == 0)
				break
			else
				strategist.addLap(A_Index, data)
			
			strategist.dumpKnowledge(strategist.KnowledgeBase)
			
			if (A_Index >= 5)
				break
		}
		
		this.AssertEqual(7, strategist.KnowledgeBase.getValue("Standings.Lap.1.Car.13.Position"), "Unexpected position detected in lap 1...")
		this.AssertEqual(117417, strategist.KnowledgeBase.getValue("Standings.Lap.1.Car.13.Time"), "Unexpected time detected in lap 1...")
		this.AssertEqual(117417, Round(strategist.KnowledgeBase.getValue("Standings.Lap.1.Car.13.Time.Average")), "Unexpected average time detected in lap 1...")
		this.AssertEqual(7, strategist.KnowledgeBase.getValue("Standings.Lap.2.Car.13.Position"), "Unexpected position detected in lap 2...")
		this.AssertEqual(105939, strategist.KnowledgeBase.getValue("Standings.Lap.2.Car.13.Time"), "Unexpected time detected in lap 2...")
		this.AssertEqual(110530, Round(strategist.KnowledgeBase.getValue("Standings.Lap.2.Car.13.Time.Average")), "Unexpected average time detected in lap 2...")
		this.AssertEqual(7, strategist.KnowledgeBase.getValue("Standings.Lap.3.Car.13.Position"), "Unexpected position detected in lap 3...")
		this.AssertEqual(104943, strategist.KnowledgeBase.getValue("Standings.Lap.3.Car.13.Time"), "Unexpected time detected in lap 3...")
		this.AssertEqual(107703, Round(strategist.KnowledgeBase.getValue("Standings.Lap.3.Car.13.Time.Average")), "Unexpected average time detected in lap 3...")
		this.AssertEqual(6, strategist.KnowledgeBase.getValue("Standings.Lap.4.Car.13.Position"), "Unexpected position detected in lap 4...")
		this.AssertEqual(103383, strategist.KnowledgeBase.getValue("Standings.Lap.4.Car.13.Time"), "Unexpected time detected in lap 4...")
		this.AssertEqual(105482, Round(strategist.KnowledgeBase.getValue("Standings.Lap.4.Car.13.Time.Average")), "Unexpected average time detected in lap 4...")
		this.AssertEqual(5, strategist.KnowledgeBase.getValue("Standings.Lap.5.Car.13.Position"), "Unexpected position detected in lap 5...")
		this.AssertEqual(103032, strategist.KnowledgeBase.getValue("Standings.Lap.5.Car.13.Time"), "Unexpected time detected in lap 5...")
		this.AssertEqual(103680, Round(strategist.KnowledgeBase.getValue("Standings.Lap.5.Car.13.Time.Average")), "Unexpected average time detected in lap 5...")
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

if !GetKeyState("Ctrl") {
	AHKUnit.AddTestClass(BasicReporting)
	; AHKUnit.AddTestClass(LapTimesReporting)
	; AHKUnit.AddTestClass(PositionProjection)
	; AHKUnit.AddTestClass(GapReporting)

	AHKUnit.Run()
}
else {
	raceNr := 13
	strategist := new RaceStrategist(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race " . raceNr . "\Race Strategist.settings")
								   , "Khato", "en", true, true)

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
				
				if (A_Index = 1)
					break
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
	showMessage(values2string(" ", args*), "Race Strategist Test", "Information.png", 500)
	
	return true
}