;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - RaceEngineer Test               ;;;
;;;                                         (Race Engineer Rules)           ;;;
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

; SetBatchLines -1				; Maximize CPU utilization
; ListLines Off					; Disable execution history


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\RuleEngine.ahk
#Include ..\Assistants\Libraries\RaceEngineer.ahk
#Include AHKUnit\AHKUnit.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vFuelWarnings = {}

global vSuspensionDamage = kNotInitialized
global vBodyworkDamage = kNotInitialized

global vCompletedActions = {}

global vPitstopFuel = kNotInitialized
global vPitstopTyreCompound = kNotInitialized
global vPitstopTyreCompoundColor = kNotInitialized
global vPitstopTyreSet = kNotInitialized
global vPitstopTyrePressures = kNotInitialized
global vPitstopRepairSuspension = kNotInitialized
global vPitstopRepairBodywork = kNotInitialized

global vSuspensionDamage
global vBodyworkDamage
global vDamageRepair
global vDamageLapDelta
global vDamageStintLaps


;;;-------------------------------------------------------------------------;;;
;;;                         Private Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class TestRaceEngineer extends RaceEngineer {
	__New(configuration, settings, remoteHandler := false, name := false, language := "__Undefined__", service := false, speaker := false, recognizer := false, listener := false, voiceServer := false) {
		base.__New(configuration, remoteHandler, name, language, service, speaker, false, recognizer, listener, voiceServer)
		
		this.updateConfigurationValues({Settings: settings})
	}
	
	supportsPitstop() {
		return true
	}
	
	lowFuelWarning(remainingLaps) {
		base.lowFuelWarning(remainingLaps)
		
		if isDebug()
			showMessage("Low fuel warning - " . remainingLaps . " lap left")
		
		vFuelWarnings[this.KnowledgeBase.getValue("Lap")] := remainingLaps
	}
	
	damageWarning(newSuspensionDamage, newBodyworkDamage) {
		base.damageWarning(newSuspensionDamage, newBodyworkDamage)
		
		if isDebug()
			showMessage("Damage warning for " . (newSuspensionDamage ? "Suspension " : "") . (newBodyworkDamage ? "Bodywork" : ""))
		
		vSuspensionDamage := newSuspensionDamage
		vBodyworkDamage := newBodyworkDamage
	}
	
	reportDamageAnalysis(repair, stintLaps, delta) {
		base.reportDamageAnalysis(repair, stintLaps, delta)
		
		if isDebug()
			showMessage("Damage analysis - Repair: " . (repair ? "Yes" : "No") . "; Lap Delta : " . delta . "; Remaining Laps: " . stintLaps)
		
		vDamageRepair := repair
		vDamageLapDelta := delta
		vDamageStintLaps := stintLaps
	}
}

class TestPitstopHandler {
	showAction(action, arguments*) {
		if isDebug()
			showMessage("Invoking pitstop action " . action . ((arguments.Length() > 0) ? (" with " . values2String(", ", arguments*)) : ""))
	}

	saveSessionState(stateFile) {
		FileRead state, %stateFile%
		
		this.showAction("saveSessionState", stateFile, SubStr(state, 1, 20) . "...")
		
		vCompletedActions["saveSessionState"] := state
	}

	pitstopPlanned(pitstopNumber, plannedLap := false) {
		this.showAction("pitstopPlanned", pitstopNumber, plannedLap)
		
		vCompletedActions["pitstopPlanned"] := pitstopNumber
	}
	
	pitstopPrepared(pitstopNumber) {
		this.showAction("pitstopPrepared", pitstopNumber)
		
		vCompletedActions["pitstopPrepared"] := pitstopNumber
	}
	
	pitstopFinished(pitstopNumber) {
		this.showAction("pitstopFinished", pitstopNumber)
		
		vCompletedActions["pitstopFinished"] := pitstopNumber
	}
	
	startPitstopSetup(pitstopNumber) {
		this.showAction("startPitstopSetup", pitstopNumber)
		
		vCompletedActions["startPitstopSetup"] := pitstopNumber
	}

	finishPitstopSetup(pitstopNumber) {
		this.showAction("finishPitstopSetup", pitstopNumber)
		
		vCompletedActions["finishPitstopSetup"] := pitstopNumber
	}

	setPitstopRefuelAmount(pitstopNumber, litres) {
		this.showAction("setPitstopRefuelAmount", pitstopNumber, litres)
		
		vCompletedActions["setPitstopRefuelAmount"] := pitstopNumber
		
		vPitstopFuel := Round(litres)
	}
	
	setPitstopTyreSet(pitstopNumber, compound, compoundColor, set := false) {
		this.showAction("setPitstopTyreSet", pitstopNumber, compound, set)
		
		vCompletedActions["setPitstopTyreSet"] := pitstopNumber
		
		vPitstopTyreCompound := compound
		vPitstopTyreCompoundColor := compoundColor
		vPitstopTyreSet := set
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		this.showAction("setPitstopTyrePressures", pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)
		
		vCompletedActions["setPitstopTyrePressures"] := pitstopNumber
		
		vPitstopTyrePressures := [pressureFL, pressureFR, pressureRL, pressureRR]
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork) {
		this.showAction("requestPitstopRepairs", pitstopNumber, repairSuspension, repairBodywork)
		
		vCompletedActions["requestPitstopRepairs"] := pitstopNumber
		
		vPitstopRepairSuspension := repairSuspension
		vPitstopRepairBodywork := repairBodywork
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                              Test Section                               ;;;
;;;-------------------------------------------------------------------------;;;

class FuelReporting extends Assert {
	FuelWarningTest() {
		engineer := new TestRaceEngineer(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), false, false, false)

		vFuelWarnings := {}
		
		Loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")
			
			if (data.Count() == 0)
				break
			else
				engineer.addLap(A_Index, data)
			
			engineer.dumpKnowledge(engineer.KnowledgeBase)
		}
		
		this.AssertEqual(false, vFuelWarnings.HasKey(1), "Unexpected fuel warning in lap 1...")
		this.AssertEqual(false, vFuelWarnings.HasKey(2), "Unexpected fuel warning in lap 2...")
		this.AssertEqual(true, vFuelWarnings.HasKey(3), "No fuel warning in lap 3...")
		this.AssertEqual(true, vFuelWarnings.HasKey(4), "No fuel warning in lap 4...")
		this.AssertEqual(true, vFuelWarnings.HasKey(5), "No fuel warning in lap 5...")
		
		engineer.finishSession(false)
	}

	RemainingFuelTest() {
		engineer := new TestRaceEngineer(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), false, false, false)

		vFuelWarnings := {}
		
		Loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")
			
			if (data.Count() == 0)
				break
			else
				engineer.addLap(A_Index, data)
			
			engineer.dumpKnowledge(engineer.KnowledgeBase)
		}
		
		this.AssertEqual(3, vFuelWarnings[3], "Unexpected remaining fuel reported in lap 3...")
		this.AssertEqual(1, vFuelWarnings[4], "Unexpected remaining fuel reported in lap 4...")
		this.AssertEqual(1, vFuelWarnings[5], "Unexpected remaining fuel reported in lap 5...")
		
		engineer.finishSession(false)
	}
}

class DamageReporting extends Assert {
	DamageReportingTest() {
		engineer := new TestRaceEngineer(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
		Loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")
			
			vSuspensionDamage := kNotInitialized
			vBodyworkDamage := kNotInitialized
				
			if (data.Count() == 0)
				break
			else
				engineer.addLap(A_Index, data)
			
			if (A_Index = 4) {
				this.AssertEqual(true, vSuspensionDamage, "Expected suspension damage to be reported...")
				this.AssertEqual(false, vBodyworkDamage, "Expected no bodywork damage to be reported...")
			}
			else if (A_Index = 5) {
				this.AssertEqual(true, vSuspensionDamage, "Expected suspension damage to be reported...")
				this.AssertEqual(true, vBodyworkDamage, "Expected bodywork damage to be reported...")
			}
			else {
				this.AssertEqual(kNotInitialized, vSuspensionDamage, "Expected no suspension damage to be reported...")
				this.AssertEqual(kNotInitialized, vBodyworkDamage, "Expected no bodywork damage to be reported...")
			}
			
			engineer.dumpKnowledge(engineer.KnowledgeBase)
		}
		
		engineer.finishSession(false)
	}
}

global vSuspensionDamage
global vBodyworkDamage
global vDamageRepair
global vDamageLapDelta
global vDamageStintLaps

class DamageAnalysis extends Assert {
	DamageRace2ReportingTest() {
		engineer := new TestRaceEngineer(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 2\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
		done := false
	
		Loop {
			lap := A_Index
		
			Loop {
				vSuspensionDamage := kNotInitialized
				vBodyworkDamage := kNotInitialized
				vDamageRepair := kNotInitialized
				vDamageLapDelta := kNotInitialized
				vDamageStintLaps := kNotInitialized

				data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 2\Lap " . lap . "." . A_Index . ".data")
			
				if (data.Count() == 0) {
					if (A_Index == 1)
						done := true
						
					break
				}
				else {
					if (A_Index == 1)
						engineer.addLap(lap, data)
					else
						engineer.updateLap(lap, data)
					
					engineer.dumpKnowledge(engineer.KnowledgeBase)
				}
			
				; 0.0	->	1.1		Report Bodywork
				; 2.4	->	2.5		Report Bodywork
				; 2.10	->	2.11	Report Suspension & Bodywork
				; 3.4	->	3.5		Report Bodywork
				
				if ((lap == 1) && (A_Index == 1)) {
					this.AssertEqual(false, vSuspensionDamage, "Expected suspension damage not to be reported...")
					this.AssertEqual(true, vBodyworkDamage, "Expected bodywork damage to be reported...")
				}
				else if ((lap == 2) && (A_Index == 5)) {
					this.AssertEqual(false, vSuspensionDamage, "Expected suspension damage not to be reported...")
					this.AssertEqual(true, vBodyworkDamage, "Expected bodywork damage to be reported...")
				}
				else if ((lap == 2) && (A_Index == 11)) {
					this.AssertEqual(true, vSuspensionDamage, "Expected suspension damage to be reported...")
					this.AssertEqual(true, vBodyworkDamage, "Expected bodywork damage to be reported...")
				}
				else if ((lap == 3) && (A_Index == 5)) {
					this.AssertEqual(false, vSuspensionDamage, "Expected suspension damage not to be reported...")
					this.AssertEqual(true, vBodyworkDamage, "Expected bodywork damage to be reported...")
				}
				else {
					this.AssertEqual(kNotInitialized, vSuspensionDamage, "Expected suspension damage not to be reported...")
					this.AssertEqual(kNotInitialized, vBodyworkDamage, "Expected bodywork damage not to be reported...")
				}
				
				this.AssertEqual(kNotInitialized, vDamageRepair, "Unexpected damage analysis reported...")
				this.AssertEqual(kNotInitialized, vDamageLapDelta, "Unexpected damage analysis reported...")
				this.AssertEqual(kNotInitialized, vDamageStintLaps, "Unexpected damage analysis reported...")
			}
		} until done
		
		engineer.finishSession(false)
	}
	
	DamageRace3ReportingTest() {
		engineer := new TestRaceEngineer(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 3\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
		done := false
	
		Loop {
			lap := A_Index
		
			Loop {
				vSuspensionDamage := kNotInitialized
				vBodyworkDamage := kNotInitialized
				vDamageRepair := kNotInitialized
				vDamageLapDelta := kNotInitialized
				vDamageStintLaps := kNotInitialized

				data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 3\Lap " . lap . "." . A_Index . ".data")
			
				if (data.Count() == 0) {
					if (A_Index == 1)
						done := true
						
					break
				}
				else {
					if (A_Index == 1)
						engineer.addLap(lap, data)
					else
						engineer.updateLap(lap, data)
					
					engineer.dumpKnowledge(engineer.KnowledgeBase)
				}
			
				; 3.1	->	3.2		Report Bodywork
				; 5.1				Recommend Pitstop
				; 5.3	->	5.4		Report Bodywork
				; 7.1				Recommend Pitstop
				
				if ((lap == 3) && (A_Index == 2)) {
					this.AssertEqual(false, vSuspensionDamage, "Expected suspension damage not to be reported...")
					this.AssertEqual(true, vBodyworkDamage, "Expected bodywork damage to be reported...")
					this.AssertEqual(kNotInitialized, vDamageRepair, "Unexpected damage analysis reported...")
					this.AssertEqual(kNotInitialized, vDamageLapDelta, "Unexpected damage analysis reported...")
					this.AssertEqual(kNotInitialized, vDamageStintLaps, "Unexpected damage analysis reported...")
				}
				else if ((lap == 5) && (A_Index == 1)) {
					this.AssertEqual(kNotInitialized, vSuspensionDamage, "Expected suspension damage not to be reported...")
					this.AssertEqual(kNotInitialized, vBodyworkDamage, "Expected bodywork damage not to be reported...")
					this.AssertEqual(true, vDamageRepair, "Expected pitstop to be recommended...")
					this.AssertEqual(1.7, Round(vDamageLapDelta, 1), "Expected lap delta to be 1.7...")
					this.AssertEqual(16, Round(vDamageStintLaps), "Expected remaining stints to be 16...")
				}
				else if ((lap == 5) && (A_Index == 4)) {
					this.AssertEqual(false, vSuspensionDamage, "Expected suspension damage not to be reported...")
					this.AssertEqual(true, vBodyworkDamage, "Expected bodywork damage to be reported...")
					this.AssertEqual(kNotInitialized, vDamageRepair, "Unexpected damage analysis reported...")
					this.AssertEqual(kNotInitialized, vDamageLapDelta, "Unexpected damage analysis reported...")
					this.AssertEqual(kNotInitialized, vDamageStintLaps, "Unexpected damage analysis reported...")
				}
				else if ((lap == 7) && (A_Index == 1)) {
					this.AssertEqual(kNotInitialized, vSuspensionDamage, "Expected suspension damage not to be reported...")
					this.AssertEqual(kNotInitialized, vBodyworkDamage, "Expected bodywork damage not to be reported...")
					this.AssertEqual(true, vDamageRepair, "Expected pitstop to be recommended...")
					this.AssertEqual(1.7, Round(vDamageLapDelta, 1), "Expected lap delta to be 1.7...")
					this.AssertEqual(18, Round(vDamageStintLaps), "Expected remaining stints to be 18...")
				}
				else {
					this.AssertEqual(kNotInitialized, vSuspensionDamage, "Expected suspension damage not to be reported...")
					this.AssertEqual(kNotInitialized, vBodyworkDamage, "Expected bodywork damage not to be reported...")
					this.AssertEqual(kNotInitialized, vDamageRepair, "Unexpected damage analysis reported...")
					this.AssertEqual(kNotInitialized, vDamageLapDelta, "Unexpected damage analysis reported...")
					this.AssertEqual(kNotInitialized, vDamageStintLaps, "Unexpected damage analysis reported...")
				}
			}
		} until done
		
		engineer.finishSession(false)
	}
	
	DamageRace4ReportingTest() {
		engineer := new TestRaceEngineer(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 4\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
		done := false
	
		Loop {
			lap := A_Index
		
			Loop {
				vSuspensionDamage := kNotInitialized
				vBodyworkDamage := kNotInitialized
				vDamageRepair := kNotInitialized
				vDamageLapDelta := kNotInitialized
				vDamageStintLaps := kNotInitialized

				data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 4\Lap " . lap . "." . A_Index . ".data")
			
				if (data.Count() == 0) {
					if (A_Index == 1)
						done := true
						
					break
				}
				else {
					if (A_Index == 1)
						engineer.addLap(lap, data)
					else
						engineer.updateLap(lap, data)
					
					engineer.dumpKnowledge(engineer.KnowledgeBase)
				}
			
				; 0.0	->	1.1		Report Bodywork
				; 2.1	->	3.1		Recommend Strategy
				; 11.7	->	11.8	Report Bodywork
				; 12.10	->	13.1	Recommend Strategy
				
				if ((lap == 1) && (A_Index == 1)) {
					this.AssertEqual(false, vSuspensionDamage, "Expected suspension damage not to be reported...")
					this.AssertEqual(true, vBodyworkDamage, "Expected bodywork damage to be reported...")
					this.AssertEqual(kNotInitialized, vDamageRepair, "Unexpected damage analysis reported...")
					this.AssertEqual(kNotInitialized, vDamageLapDelta, "Unexpected damage analysis reported...")
					this.AssertEqual(kNotInitialized, vDamageStintLaps, "Unexpected damage analysis reported...")
				}
				else if ((lap == 3) && (A_Index == 1)) {
					this.AssertEqual(kNotInitialized, vSuspensionDamage, "Expected suspension damage not to be reported...")
					this.AssertEqual(kNotInitialized, vBodyworkDamage, "Expected bodywork damage not to be reported...")
					this.AssertEqual(false, vDamageRepair, "Expected no pitstop to be recommended...")
					this.AssertEqual(0, Round(vDamageLapDelta, 1), "Expected lap delta to be 0.0...")
					this.AssertEqual(15, Round(vDamageStintLaps), "Expected remaining stints to be 15...")
				}
				else if ((lap == 11) && (A_Index == 8)) {
					this.AssertEqual(false, vSuspensionDamage, "Expected suspension damage not to be reported...")
					this.AssertEqual(true, vBodyworkDamage, "Expected bodywork damage to be reported...")
					this.AssertEqual(kNotInitialized, vDamageRepair, "Unexpected damage analysis reported...")
					this.AssertEqual(kNotInitialized, vDamageLapDelta, "Unexpected damage analysis reported...")
					this.AssertEqual(kNotInitialized, vDamageStintLaps, "Unexpected damage analysis reported...")
				}
				else if ((lap == 13) && (A_Index == 1)) {
					this.AssertEqual(kNotInitialized, vSuspensionDamage, "Expected suspension damage not to be reported...")
					this.AssertEqual(kNotInitialized, vBodyworkDamage, "Expected bodywork damage not to be reported...")
					this.AssertEqual(false, vDamageRepair, "Expected pitstop to be recommended...")
					this.AssertEqual(1.3, Round(vDamageLapDelta, 1), "Expected lap delta to be 1.3...")
					this.AssertEqual(5, Round(vDamageStintLaps), "Expected remaining stints to be 5...")
				}
				else {
					this.AssertEqual(kNotInitialized, vSuspensionDamage, "Expected suspension damage not to be reported...")
					this.AssertEqual(kNotInitialized, vBodyworkDamage, "Expected bodywork damage not to be reported...")
					this.AssertEqual(kNotInitialized, vDamageRepair, "Unexpected damage analysis reported...")
					this.AssertEqual(kNotInitialized, vDamageLapDelta, "Unexpected damage analysis reported...")
					this.AssertEqual(kNotInitialized, vDamageStintLaps, "Unexpected damage analysis reported...")
				}
			}
		} until done
		
		engineer.finishSession(false)
	}
}

class PitstopHandling extends Assert {
	equalLists(listA, listB) {
		if (listA.Length() != listB.Length())
			return false
		else
			for index, value in listA
				if (listB[index] != value)
					return false
				
		return true
	}

	PitstopPlanLap3Test() {
		engineer := new TestRaceEngineer(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
		vCompletedActions := {}
		
		Loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")
			
			if (data.Count() == 0)
				break
			else {
				engineer.addLap(A_Index, data)
			
				if (A_Index = 3)
					engineer.planPitstop()
			}
			
			engineer.dumpKnowledge(engineer.KnowledgeBase)
		}
		
		this.AssertEqual(true, vCompletedActions.HasKey("pitstopPlanned"), "No pitstop planned...")
		this.AssertEqual(1, vCompletedActions["pitstopPlanned"], "Pitstop not planned as number 1...")
		
		this.AssertEqual(true, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned")), "Pitstop not flagged as Planned...")
		this.AssertEqual(54, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Fuel")), "Expected 54 litres for refueling...")
		this.AssertEqual("Dry", engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Compound"), "Expected Dry tyre compound...")
		this.AssertEqual(8, engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Set"), "Expected tyre set 8...")
		this.AssertEqual(false, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Suspension"), "Expected no suspension repair...")
		this.AssertEqual(false, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Bodywork"), "Expected no bodywork repair...")
		this.AssertEqual(26.6, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FL"), 1), "Unexpected tyre pressure target for FL...")
		this.AssertEqual(26.4, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FR"), 1), "Unexpected tyre pressure target for FR...")
		this.AssertEqual(26.6, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RL"), 1), "Unexpected tyre pressure target for RL...")
		this.AssertEqual(26.1, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RR"), 1), "Unexpected tyre pressure target for RR...")
		
		this.AssertEqual(false, vCompletedActions.HasKey("pitstopPrepared"), "Unexpected pitstop action pitstopPrepared reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("pitstopFinished"), "Unexpected pitstop action pitstopFinished reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("startPitstopSetup"), "Unexpected pitstop action startPitstopSetup reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("finishPitstopSetup"), "Unexpected pitstop action finishPitstopSetup reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("setPitstopRefuelAmount"), "Unexpected pitstop action setPitstopRefuelAmount reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("setPitstopTyreSet"), "Unexpected pitstop action setPitstopTyreSet reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("setPitstopTyrePressures"), "Unexpected pitstop action setPitstopTyrePressures reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("requestPitstopRepairs"), "Unexpected pitstop action requestPitstopRepairs reported...")
		
		engineer.finishSession(false)
	}
	
	PitstopPlanLap4Test() {
		engineer := new TestRaceEngineer(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
		vCompletedActions := {}
		
		Loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")
			
			if (data.Count() == 0)
				break
			else {
				engineer.addLap(A_Index, data)
			
				if (A_Index = 4)
					engineer.planPitstop()
			}
			
			engineer.dumpKnowledge(engineer.KnowledgeBase)
		}
		
		this.AssertEqual(true, vCompletedActions.HasKey("pitstopPlanned"), "No pitstop planned...")
		this.AssertEqual(1, vCompletedActions["pitstopPlanned"], "Pitstop not planned as number 1...")
		
		this.AssertEqual(true, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned")), "Pitstop not flagged as Planned...")
		this.AssertEqual(55, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Fuel")), "Expected 54 litres for refueling...")
		this.AssertEqual("Dry", engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Compound"), "Expected Dry tyre compound...")
		this.AssertEqual(8, engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Set"), "Expected tyre set 8...")
		this.AssertEqual(true, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Suspension"), "Expected suspension repair...")
		this.AssertEqual(false, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Bodywork"), "Expected no bodywork repair...")
		this.AssertEqual(26.7, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FL"), 1), "Unexpected tyre pressure target for FL...")
		this.AssertEqual(26.4, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FR"), 1), "Unexpected tyre pressure target for FR...")
		this.AssertEqual(26.6, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RL"), 1), "Unexpected tyre pressure target for RL...")
		this.AssertEqual(26.1, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RR"), 1), "Unexpected tyre pressure target for RR...")
		
		this.AssertEqual(false, vCompletedActions.HasKey("pitstopPrepared"), "Unexpected pitstop action pitstopPrepared reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("pitstopFinished"), "Unexpected pitstop action pitstopFinished reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("startPitstopSetup"), "Unexpected pitstop action startPitstopSetup reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("finishPitstopSetup"), "Unexpected pitstop action finishPitstopSetup reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("setPitstopRefuelAmount"), "Unexpected pitstop action setPitstopRefuelAmount reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("setPitstopTyreSet"), "Unexpected pitstop action setPitstopTyreSet reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("setPitstopTyrePressures"), "Unexpected pitstop action setPitstopTyrePressures reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("requestPitstopRepairs"), "Unexpected pitstop action requestPitstopRepairs reported...")
		
		engineer.finishSession(false)
	}
	
	PitstopPlanLap5Test() {
		engineer := new TestRaceEngineer(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
		vCompletedActions := {}
		
		Loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")
			
			if (data.Count() == 0)
				break
			else {
				engineer.addLap(A_Index, data)
			
				if (A_Index = 5)
					engineer.planPitstop()
				
				if (A_Index = 6) 
					Break
			}
			
			engineer.dumpKnowledge(engineer.KnowledgeBase)
		}
		
		this.AssertEqual(true, vCompletedActions.HasKey("pitstopPlanned"), "No pitstop planned...")
		this.AssertEqual(1, vCompletedActions["pitstopPlanned"], "Pitstop not planned as number 1...")
		
		this.AssertEqual(true, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned")), "Pitstop not flagged as Planned...")
		this.AssertEqual(55, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Fuel")), "Expected 55 litres for refueling...")
		this.AssertEqual("Dry", engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Compound"), "Expected Dry tyre compound...")
		this.AssertEqual(8, engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Set"), "Expected tyre set 8...")
		this.AssertEqual(true, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Suspension"), "Expected suspension repair...")
		this.AssertEqual(true, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Bodywork"), "Expected bodywork repair...")
		this.AssertEqual(26.6, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FL"), 1), "Unexpected tyre pressure target for FL...")
		this.AssertEqual(26.3, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FR"), 1), "Unexpected tyre pressure target for FR...")
		this.AssertEqual(26.6, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RL"), 1), "Unexpected tyre pressure target for RL...")
		this.AssertEqual(26.1, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RR"), 1), "Unexpected tyre pressure target for RR...")
		
		this.AssertEqual(false, vCompletedActions.HasKey("pitstopPrepared"), "Unexpected pitstop action pitstopPrepared reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("pitstopFinished"), "Unexpected pitstop action pitstopFinished reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("startPitstopSetup"), "Unexpected pitstop action startPitstopSetup reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("finishPitstopSetup"), "Unexpected pitstop action finishPitstopSetup reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("setPitstopRefuelAmount"), "Unexpected pitstop action setPitstopRefuelAmount reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("setPitstopTyreSet"), "Unexpected pitstop action setPitstopTyreSet reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("setPitstopTyrePressures"), "Unexpected pitstop action setPitstopTyrePressures reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("requestPitstopRepairs"), "Unexpected pitstop action requestPitstopRepairs reported...")
		
		engineer.finishSession(false)
	}
	
	PitstopPrepare3Test() {
		engineer := new TestRaceEngineer(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
		vCompletedActions := {}
		
		vPitstopFuel := kNotInitialized
		vPitstopTyreCompound := kNotInitialized
		vPitstopTyreCompoundColor := kNotInitialized
		vPitstopTyreSet := kNotInitialized
		vPitstopTyrePressures := kNotInitialized
		vPitstopRepairSuspension := kNotInitialized
		vPitstopRepairBodywork := kNotInitialized
		
		Loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")
			
			if (data.Count() == 0)
				break
			else {
				engineer.addLap(A_Index, data)
			
				if (A_Index = 3) {
					engineer.planPitstop()
					engineer.preparePitstop()
				}
			}
			
			engineer.dumpKnowledge(engineer.KnowledgeBase)
		}
		
		this.AssertEqual(1, vCompletedActions["pitstopPlanned"], "Pitstop not planned as number 1...")
		this.AssertEqual(1, vCompletedActions["pitstopPrepared"], "Pitstop not prepared as number 1...")
		
		this.AssertEqual(false, vCompletedActions.HasKey("pitstopFinished"), "Pitstop action pitstopFinished should not be reported...")
		
		this.AssertEqual(true, vCompletedActions.HasKey("startPitstopSetup"), "Pitstop action startPitstopSetup not reported...")
		this.AssertEqual(true, vCompletedActions.HasKey("finishPitstopSetup"), "Pitstop action finishPitstopSetup not reported...")
		this.AssertEqual(true, vCompletedActions.HasKey("setPitstopRefuelAmount"), "Pitstop action setPitstopRefuelAmount not reported...")
		this.AssertEqual(true, vCompletedActions.HasKey("setPitstopTyreSet"), "Pitstop action setPitstopTyreSet not reported...")
		this.AssertEqual(true, vCompletedActions.HasKey("setPitstopTyrePressures"), "Pitstop action setPitstopTyrePressures not reported...")
		this.AssertEqual(true, vCompletedActions.HasKey("requestPitstopRepairs"), "Pitstop action requestPitstopRepairs not reported...")
		
		this.AssertEqual(54, vPitstopFuel, "Expected 54 litres for refueling...")
		this.AssertEqual("Dry", vPitstopTyreCompound, "Expected Dry tyre compound...")
		this.AssertEqual("Black", vPitstopTyreCompoundColor, "Expected Black tyre compound color...")
		this.AssertEqual(8, vPitstopTyreSet, "Expected tyre set 8...")
		this.AssertEqual(false, vPitstopRepairSuspension, "Expected no suspension repair...")
		this.AssertEqual(false, vPitstopRepairBodywork, "Expected no bodywork repair...")
		
		this.AssertEqual(true, this.equalLists(vPitstopTyrePressures, [26.6, 26.4, 26.6, 26.1]), "Unexpected tyre pressures...")
		
		engineer.finishSession(false)
	}
	
	PitstopPrepare5Test() {
		engineer := new TestRaceEngineer(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
		vCompletedActions := {}
		
		vPitstopFuel := kNotInitialized
		vPitstopTyreCompound := kNotInitialized
		vPitstopTyreCompoundColor := kNotInitialized
		vPitstopTyreSet := kNotInitialized
		vPitstopTyrePressures := kNotInitialized
		vPitstopRepairSuspension := kNotInitialized
		vPitstopRepairBodywork := kNotInitialized
		
		Loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")
			
			if (data.Count() == 0)
				break
			else {
				engineer.addLap(A_Index, data)
			
				if (A_Index = 5) {
					engineer.planPitstop()
					engineer.preparePitstop()
				}
			}
			
			engineer.dumpKnowledge(engineer.KnowledgeBase)
		}
		
		this.AssertEqual(1, vCompletedActions["pitstopPlanned"], "Pitstop not planned as number 1...")
		this.AssertEqual(1, vCompletedActions["pitstopPrepared"], "Pitstop not prepared as number 1...")
		
		this.AssertEqual(false, vCompletedActions.HasKey("pitstopFinished"), "Pitstop action pitstopFinished should not be reported...")
		
		this.AssertEqual(true, vCompletedActions.HasKey("startPitstopSetup"), "Pitstop action startPitstopSetup not reported...")
		this.AssertEqual(true, vCompletedActions.HasKey("finishPitstopSetup"), "Pitstop action finishPitstopSetup not reported...")
		this.AssertEqual(true, vCompletedActions.HasKey("setPitstopRefuelAmount"), "Pitstop action setPitstopRefuelAmount not reported...")
		this.AssertEqual(true, vCompletedActions.HasKey("setPitstopTyreSet"), "Pitstop action setPitstopTyreSet not reported...")
		this.AssertEqual(true, vCompletedActions.HasKey("setPitstopTyrePressures"), "Pitstop action setPitstopTyrePressures not reported...")
		this.AssertEqual(true, vCompletedActions.HasKey("requestPitstopRepairs"), "Pitstop action requestPitstopRepairs not reported...")
		
		this.AssertEqual(55, vPitstopFuel, "Expected 54 litres for refueling...")
		this.AssertEqual("Dry", vPitstopTyreCompound, "Expected Dry tyre compound...")
		this.AssertEqual("Black", vPitstopTyreCompoundColor, "Expected Black tyre compound color...")
		this.AssertEqual(8, vPitstopTyreSet, "Expected tyre set 8...")
		this.AssertEqual(true, vPitstopRepairSuspension, "Expected suspension repair...")
		this.AssertEqual(true, vPitstopRepairBodywork, "Expected bodywork repair...")
		
		this.AssertEqual(true, this.equalLists(vPitstopTyrePressures, [26.6, 26.3, 26.6, 26.1]), "Unexpected tyre pressures...")
		
		engineer.finishSession(false)
	}
	
	PitstopPerformedTest() {
		engineer := new TestRaceEngineer(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
		vCompletedActions := {}
		
		Loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")
			
			if (data.Count() == 0)
				break
			else {
				engineer.addLap(A_Index, data)
			
				if (A_Index = 4) {
					engineer.planPitstop()
					engineer.preparePitstop()
				}
			
				if (A_Index = 5) {
					engineer.performPitstop()
			
					engineer.dumpKnowledge(engineer.KnowledgeBase)
					
					this.AssertEqual(1, vCompletedActions["pitstopFinished"], "Pitstop not prepared as number 1...")
					
					this.AssertEqual(1, engineer.KnowledgeBase.getValue("Pitstop.Last"), "Last pitstop not set...")
					this.AssertEqual(5, engineer.KnowledgeBase.getValue("Pitstop.1.Lap"), "Pitstop lap not in history memory...")
					this.AssertEqual(true, engineer.KnowledgeBase.getValue("Pitstop.1.Repair.Suspension"), "Pitstop suspension repair info not in history memory...")
					this.AssertEqual(false, engineer.KnowledgeBase.getValue("Pitstop.1.Repair.Bodywork"), "Pitstop bodywork repair info not in history memory...")
					this.AssertEqual(25, engineer.KnowledgeBase.getValue("Pitstop.1.Temperature.Air"), "Pitstop air temperature not in history memory...")
					this.AssertEqual(32, engineer.KnowledgeBase.getValue("Pitstop.1.Temperature.Track"), "Pitstop track temperature not in history memory...")
					this.AssertEqual(544615, engineer.KnowledgeBase.getValue("Pitstop.1.Time"), "Pitstop timestamp not in history memory...")
					
					this.AssertEqual("Dry", engineer.KnowledgeBase.getValue("Pitstop.1.Tyre.Compound"), "Pitstop tyre compound not in history memory...")
					this.AssertEqual(8, engineer.KnowledgeBase.getValue("Pitstop.1.Tyre.Set"), "Pitstop tyre set not in history memory...")
					this.AssertEqual(26.7, Round(engineer.KnowledgeBase.getValue("Pitstop.1.Tyre.Pressure.FL"), 1), "Pitstop tyre pressure FL not in history memory...")
					this.AssertEqual(26.4, Round(engineer.KnowledgeBase.getValue("Pitstop.1.Tyre.Pressure.FR"), 1), "Pitstop tyre pressure FR not in history memory...")
					this.AssertEqual(26.6, Round(engineer.KnowledgeBase.getValue("Pitstop.1.Tyre.Pressure.RL"), 1), "Pitstop tyre pressure RL not in history memory...")
					this.AssertEqual(26.1, Round(engineer.KnowledgeBase.getValue("Pitstop.1.Tyre.Pressure.RR"), 1), "Pitstop tyre pressure RR not in history memory...")
					
					engineer.planPitstop()
				
					this.AssertEqual(kNotInitialized, engineer.KnowledgeBase.getValue("Pitstop.Planned.Nr"), "Planning of pitstop should not be possible in the same lap with a performed pitstop...")
				}
				
				if (A_Index = 7) {
					vFuelWarnings := {}

					vSuspensionDamage := kNotInitialized
					vBodyworkDamage := kNotInitialized

					engineer.planPitstop()
					
					engineer.dumpKnowledge(engineer.KnowledgeBase)
				
					this.AssertEqual(2, engineer.KnowledgeBase.getValue("Pitstop.Planned.Nr"), "Pitstop number increment failed...")
					this.AssertEqual(false, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Suspension"), "Expected no suspension repair...")
					this.AssertEqual(true, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Bodywork"), "Expected bodywork repair...")
					this.AssertEqual(0, vFuelWarnings.Count(), "Warning suppression not working...")
					this.AssertEqual(kNotInitialized, vSuspensionDamage, "Warning suppression not working...")
					this.AssertEqual(kNotInitialized, vBodyworkDamage, "Warning suppression not working...")
				}
			}
		}
		
		engineer.finishSession(false)
	}
	
	PitstopMultipleTest() {
		engineer := new TestRaceEngineer(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
		Loop {
			vSuspensionDamage := kNotInitialized
			vBodyworkDamage := kNotInitialized

			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")
			
			if (data.Count() == 0)
				break
			else {
				engineer.addLap(A_Index, data)
			
				if (A_Index = 3) {
					engineer.planPitstop()
					engineer.preparePitstop()
				}
			
				if (A_Index = 4) {
					engineer.performPitstop()
					
					this.AssertEqual(1, engineer.KnowledgeBase.getValue("Pitstop.Last", 0), "Last Pitstop not in history memory...")
					this.AssertEqual(true, vSuspensionDamage, "Expected suspension damage to be reported...")
					this.AssertEqual(false, vBodyworkDamage, "Expected no bodywork damage to be reported...")
				}
			
				if (A_Index = 5) {
					this.AssertEqual(true, vSuspensionDamage, "Expected suspension damage to be reported...")
					this.AssertEqual(true, vBodyworkDamage, "Expected bodywork damage to be reported...")
				}
			
				if (A_Index = 7) {
					engineer.planPitstop()
					
					this.AssertEqual(2, engineer.KnowledgeBase.getValue("Pitstop.Planned.Nr", 0), "Pitstop number increment failed...")
					this.AssertEqual(false, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Suspension"), "Expected no suspension repair...")
					this.AssertEqual(true, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Bodywork"), "Expected bodywork repair...")
					
					engineer.preparePitstop()
					engineer.performPitstop()
					
					this.AssertEqual(kNotInitialized, vSuspensionDamage, "Expected no suspension damage to be reported...")
					this.AssertEqual(kNotInitialized, vBodyworkDamage, "Expected no bodywork damage to be reported...")
					
					this.AssertEqual(-1, engineer.KnowledgeBase.getValue("Pitstop.Planned.Nr", -1), "Pitstop number increment failed...")
					this.AssertEqual(2, engineer.KnowledgeBase.getValue("Pitstop.Last", 0), "Last Pitstop not in history memory...")
					this.AssertEqual(7, engineer.KnowledgeBase.getValue("Pitstop.2.Lap", 0), "Wrong lap recorded Pitstop...")
					this.AssertEqual(false, engineer.KnowledgeBase.getValue("Pitstop.2.Repair.Suspension"), "Expected no suspension repair...")
					this.AssertEqual(true, engineer.KnowledgeBase.getValue("Pitstop.2.Repair.Bodywork"), "Expected bodywork repair...")
					this.AssertEqual(9, engineer.KnowledgeBase.getValue("Pitstop.2.Tyre.Set"), "Expected new tyres...")
				}
			}
			
			engineer.dumpKnowledge(engineer.KnowledgeBase)
		}
		
		engineer.finishSession(false)
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

setConfigurationValue(kSimulatorConfiguration, "Race Engineer Analysis", "Unknown" . ".ConsideredHistoryLaps", 2)
setConfigurationValue(kSimulatorConfiguration, "Race Engineer Analysis", "Unknown" . ".HistoryLapsDamping", 0.5)
setConfigurationValue(kSimulatorConfiguration, "Race Engineer Analysis", "Unknown" . ".AdjustLapTime", false)

if !GetKeyState("Ctrl") {
	startTime := A_TickCount
	
	AHKUnit.AddTestClass(FuelReporting)
	AHKUnit.AddTestClass(DamageReporting)
	AHKUnit.AddTestClass(DamageAnalysis)
	AHKUnit.AddTestClass(PitstopHandling)

	AHKUnit.Run()
	
	MsgBox % "Full run took " . (A_TickCount - startTime) . " ms"
}
else {
	raceNr := (GetKeyState("Alt") ? 18 : ((GetKeyState("Shift") ? 2 : 1)))
	engineer := new TestRaceEngineer(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race " . raceNr . "\Race Engineer.settings")
								   , new TestPitStopHandler(), "Jona", "en", "Windows", true, true, true)

	engineer.VoiceAssistant.setDebug(kDebugGrammars, false)
	
	if (raceNr == 1) {
		Loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")
			
			if (data.Count() == 0)
				break
			else {
				engineer.addLap(A_Index, data)
		
				if (A_Index = 3) {
					engineer.planPitstop()
					engineer.preparePitstop()
				}
		
				if (A_Index = 4) {
					engineer.performPitstop()
				}
				
				engineer.dumpKnowledge(engineer.KnowledgeBase)
				
				if isDebug()
					MsgBox % "Lap " . A_Index . " loaded - Continue?"
			}
		}
		
		engineer.finishSession()
		
		while engineer.KnowledgeBase
			Sleep 1000
	}
	else if (raceNr == 2) {
		; 0.0	->	1.1		Report Bodywork
		; 2.4	->	2.5		Report Bodywork
		; 2.10	->	2.11	Report Suspension & Bodywork
		; 3.4	->	3.5		Report Bodywork
		
		done := false
	
		Loop {
			lap := A_Index
		
			Loop {
				data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 2\Lap " . lap . "." . A_Index . ".data")
			
				if (data.Count() == 0) {
					if (A_Index == 1)
						done := true
						
					break
				}
				else {
					if (A_Index == 1)
						engineer.addLap(lap, data)
					else
						engineer.updateLap(lap, data)
					
					engineer.dumpKnowledge(engineer.KnowledgeBase)
					
					if isDebug()
						showMessage("Data " lap . "." . A_Index . " loaded...")
				}
			}
		} until done
	}
	else if (raceNr == 3) {
		; 3.1	->	3.2		Report Bodywork
		; 5.1				Recommend Pitstop
		; 5.3	->	5.4		Report Bodywork
		; 7.1				Recommend Pitstop
		
		done := false
		
		Loop {
			lap := A_Index
		
			Loop {
				data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 3\Lap " . lap . "." . A_Index . ".data")
			
				if (data.Count() == 0) {
					if (A_Index == 1)
						done := true
						
					break
				}
				else {
					if (A_Index == 1)
						engineer.addLap(lap, data)
					else
						engineer.updateLap(lap, data)
					
					engineer.dumpKnowledge(engineer.KnowledgeBase)
					
					if isDebug()
						showMessage("Data " lap . "." . A_Index . " loaded...")
				}
			}
		} until done
	}
	else if (raceNr == 4) {
		; 0.0	->	1.1		Report Bodywork
		; 2.1	->	3.1		Recommend Strategy
		; 11.7	->	11.8	Report Bodywork
		; 12.10	->	13.1	Recommend Strategy
	
		done := false
		
		Loop {
			lap := A_Index
		
			Loop {
				data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 4\Lap " . lap . "." . A_Index . ".data")
			
				if (data.Count() == 0) {
					if (A_Index == 1)
						done := true
						
					break
				}
				else {
					if (A_Index == 1)
						engineer.addLap(lap, data)
					else
						engineer.updateLap(lap, data)
					
					if (lap = 8) {
						engineer.planPitstop()
						
						engineer.preparePitstop()
					}
				
					engineer.dumpKnowledge(engineer.KnowledgeBase)
					
					if isDebug()
						showMessage("Data " lap . "." . A_Index . " loaded...")
				}
			}
		} until done
	}
	else if (raceNr == 5) {
		done := false
		
		Loop {
			lap := A_Index
		
			Loop {
				data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 5\Lap " . lap . "." . A_Index . ".data")
			
				if (data.Count() == 0) {
					if (A_Index == 1)
						done := true
					
					break
				}
				else {
					if (A_Index == 1)
						engineer.addLap(lap, data)
					else
						engineer.updateLap(lap, data)
				
					if (lap = 8)
						engineer.planPitstop()
				
					engineer.dumpKnowledge(engineer.KnowledgeBase)
					
					if (lap = 8)
						MsgBox Pitstop
					
					if isDebug()
						showMessage("Data " lap . "." . A_Index . " loaded...")
				}
			}
		} until done
	}
	else if (raceNr == 6) {
		done := false
		
		Loop {
			lap := A_Index
		
			Loop {
				data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 6\Lap " . lap . "." . A_Index . ".data")
			
				if (data.Count() == 0) {
					if (A_Index == 1)
						done := true
					
					break
				}
				else {
					if (A_Index == 1)
						engineer.addLap(lap, data)
					else
						engineer.updateLap(lap, data)
				
					if (lap = 17) {
						engineer.planPitstop()
				
						engineer.dumpKnowledge(engineer.KnowledgeBase)
					
						MsgBox Pitstop
					}
					
					if isDebug()
						showMessage("Data " lap . "." . A_Index . " loaded...")
				}
			}
		} until done
	}
	else if ((raceNr = 9) || (raceNr = 11) || (raceNr = 12)) {
		done := false
		
		Loop {
			lap := A_Index
		
			Loop {
				data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race " . raceNr . "\Lap " . lap . "." . A_Index . ".data")
			
				if (data.Count() == 0) {
					if (A_Index == 1)
						done := true
					
					break
				}
				else {
					if (A_Index == 1)
						engineer.addLap(lap, data)
					else
						engineer.updateLap(lap, data)
					
					if (raceNr = 9) {
						if (lap = 22) {
							engineer.planPitstop()
							engineer.preparePitstop()
						
							MsgBox Pitstop Prepare
						}
						
						if (lap = 24) {
							engineer.performPitstop(23)
						
							MsgBox Pitstop Perform
						}
					}
					else if (raceNr = 11) {
						if (lap = 9) {
							engineer.planPitstop()
							engineer.preparePitstop()
						
							MsgBox Pitstop Prepare
						}
						
						if (lap = 11) {
							engineer.performPitstop(11)
						
							MsgBox Pitstop Perform
						}
						
						if (lap = 19)
							MsgBox Inspect
					}
					else if (raceNr = 12) {
						if (lap = 21) {
							engineer.planPitstop()
							engineer.preparePitstop()
						
							MsgBox Pitstop Prepare
						}
						
						if (lap = 22) {
							engineer.performPitstop(22)
						
							MsgBox Pitstop Perform
						}
						
						if (lap = 24)
							MsgBox Inspect
					}
					
					if isDebug()
						showMessage("Data " lap . "." . A_Index . " loaded...")
				}
			}
		} until done
	}
	else if (raceNr = 18) {
		done := false
		
		Loop {
			lap := A_Index
		
			Loop {
				data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race " . raceNr . "\Race Engineer Lap " . lap . "." . A_Index . ".data")
			
				if (data.Count() == 0) {
					if (lap == 82)
						done := true
					
					break
				}
				else {
					if (A_Index == 1)
						engineer.addLap(lap, data)
					else
						engineer.updateLap(lap, data)
					
					if (isDebug() && (A_Index == 1))
						showMessage("Data " lap . "." . A_Index . " loaded...")
				}
			}
		} until done
	}
	else if (raceNr > 6) {
		done := false
		
		Loop {
			lap := A_Index
		
			Loop {
				data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race " . raceNr . "\Lap " . lap . "." . A_Index . ".data")
			
				if (data.Count() == 0) {
					if (A_Index == 1)
						done := true
					
					break
				}
				else {
					if (A_Index == 1)
						engineer.addLap(lap, data)
					else
						engineer.updateLap(lap, data)
					
					if isDebug()
						showMessage("Data " lap . "." . A_Index . " loaded...")
				}
			}
		} until done
	}
	
	if isDebug()
		MsgBox Done...
	
	ExitApp
}

show(context, args*) {
	showMessage(values2string(A_Space, args*), "Race Engineer Test", "Information.png", 2500)
	
	return true
}