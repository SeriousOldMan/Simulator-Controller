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
#Include ..\Engineer\Libraries\RaceEngineer.ahk
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
global vPitstopTyreSet = kNotInitialized
global vPitstopTyrePressureIncrements = kNotInitialized
global vPitstopRepairSuspension = kNotInitialized
global vPitstopRepairBodywork = kNotInitialized


;;;-------------------------------------------------------------------------;;;
;;;                         Private Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class TestRaceEngineer extends RaceEngineer {
	lowFuelWarning(remainingLaps) {
		base.lowFuelWarning(remainingLaps)
		
		if isDebug() {
			SplashTextOn 400, 100, , % "Low fuel warning - " . remainingLaps . " lap left"
			Sleep 1000
			SplashTextOff
		}
		
		vFuelWarnings[this.KnowledgeBase.getValue("Lap")] := remainingLaps
	}
	
	damageWarning(newSuspensionDamage, newBodyworkDamage) {
		base.damageWarning(newSuspensionDamage, newBodyworkDamage)
		
		if isDebug() {
			SplashTextOn 400, 100, , % "Damage warning for " . (newSuspensionDamage ? "Suspension " : "") . (newBodyworkDamage ? "Bodywork" : "")
			Sleep 1000
			SplashTextOff
		}
		
		vSuspensionDamage := newSuspensionDamage
		vBodyworkDamage := newBodyworkDamage
	}
}

class TestPitstopHandler {
	showAction(action, arguments*) {
		if isDebug() {
			SplashTextOn 400, 100, , % "Invoking pitstop action " . action . ((arguments.Length() > 0) ? (" with " . values2String(", ", arguments*)) : "")
			Sleep 1000
			SplashTextOff
		}
	}

	pitstopPlanned(pitstopNumber) {
		this.showAction("pitstopPlanned", pitstopNumber)
		
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
	
	setPitstopTyreSet(pitstopNumber, compound, set := false) {
		this.showAction("setPitstopTyreSet", pitstopNumber, compound, set)
		
		vCompletedActions["setPitstopTyreSet"] := pitstopNumber
		
		vPitstopTyreCompound := compound
		vPitstopTyreSet := set
	}

	setPitstopTyrePressures(pitstopNumber, pressureFLIncrement, pressureFRIncrement, pressureRLIncrement, pressureRRIncrement) {
		this.showAction("setPitstopTyrePressures", pitstopNumber, pressureFLIncrement, pressureFRIncrement, pressureRLIncrement, pressureRRIncrement)
		
		vCompletedActions["setPitstopTyrePressures"] := pitstopNumber
		
		vPitstopTyrePressureIncrements := [pressureFLIncrement, pressureFRIncrement, pressureRLIncrement, pressureRRIncrement]
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
		engineer := new TestRaceEngineer(false, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), false, false, false)

		vFuelWarnings := {}
		
		Loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")
			
			if (data.Count() == 0)
				break
			else
				engineer.addLap(A_Index, data)
			
			dumpKnowledge(engineer.KnowledgeBase)
		}
		
		this.AssertEqual(false, vFuelWarnings.HasKey(1), "Unexpected fuel warning in lap 1...")
		this.AssertEqual(false, vFuelWarnings.HasKey(2), "Unexpected fuel warning in lap 2...")
		this.AssertEqual(true, vFuelWarnings.HasKey(3), "No fuel warning in lap 3...")
		this.AssertEqual(true, vFuelWarnings.HasKey(4), "No fuel warning in lap 4...")
		this.AssertEqual(true, vFuelWarnings.HasKey(5), "No fuel warning in lap 5...")
	}

	RemainingFuelTest() {
		engineer := new TestRaceEngineer(false, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), false, false, false)

		vFuelWarnings := {}
		
		Loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")
			
			if (data.Count() == 0)
				break
			else
				engineer.addLap(A_Index, data)
			
			dumpKnowledge(engineer.KnowledgeBase)
		}
		
		this.AssertEqual(3, vFuelWarnings[3], "Unexpected remaining fuel reported in lap 3...")
		this.AssertEqual(1, vFuelWarnings[4], "Unexpected remaining fuel reported in lap 4...")
		this.AssertEqual(1, vFuelWarnings[5], "Unexpected remaining fuel reported in lap 5...")
	}
}

class DamageReporting extends Assert {
	DamageReportingTest() {
		engineer := new TestRaceEngineer(false, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
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
			
			dumpKnowledge(engineer.KnowledgeBase)
		}
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
		engineer := new TestRaceEngineer(false, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
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
			
			dumpKnowledge(engineer.KnowledgeBase)
		}
		
		this.AssertEqual(true, vCompletedActions.HasKey("pitstopPlanned"), "No pitstop planned...")
		this.AssertEqual(1, vCompletedActions["pitstopPlanned"], "Pitstop not planned as number 1...")
		
		this.AssertEqual(true, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned")), "Pitstop not flagged as Planned...")
		this.AssertEqual(54, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Fuel")), "Expected 54 litres for refueling...")
		this.AssertEqual("Dry", engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Compound"), "Expected Dry tyre compound...")
		this.AssertEqual(8, engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Set"), "Expected tyre set 8...")
		this.AssertEqual(false, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Suspension"), "Expected no suspension repair...")
		this.AssertEqual(false, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Bodywork"), "Expected no bodywork repair...")
		this.AssertEqual(26.4, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FL"), 1), "Unexpected tyre pressure target for FL...")
		this.AssertEqual(26.4, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FR"), 1), "Unexpected tyre pressure target for FR...")
		this.AssertEqual(26.4, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RL"), 1), "Unexpected tyre pressure target for RL...")
		this.AssertEqual(26.4, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RR"), 1), "Unexpected tyre pressure target for RR...")
		
		this.AssertEqual(false, vCompletedActions.HasKey("pitstopPrepared"), "Unexpected pitstop action pitstopPrepared reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("pitstopFinished"), "Unexpected pitstop action pitstopFinished reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("startPitstopSetup"), "Unexpected pitstop action startPitstopSetup reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("finishPitstopSetup"), "Unexpected pitstop action finishPitstopSetup reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("setPitstopRefuelAmount"), "Unexpected pitstop action setPitstopRefuelAmount reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("setPitstopTyreSet"), "Unexpected pitstop action setPitstopTyreSet reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("setPitstopTyrePressures"), "Unexpected pitstop action setPitstopTyrePressures reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("requestPitstopRepairs"), "Unexpected pitstop action requestPitstopRepairs reported...")
	}
	
	PitstopPlanLap4Test() {
		engineer := new TestRaceEngineer(false, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
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
			
			dumpKnowledge(engineer.KnowledgeBase)
		}
		
		this.AssertEqual(true, vCompletedActions.HasKey("pitstopPlanned"), "No pitstop planned...")
		this.AssertEqual(1, vCompletedActions["pitstopPlanned"], "Pitstop not planned as number 1...")
		
		this.AssertEqual(true, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned")), "Pitstop not flagged as Planned...")
		this.AssertEqual(55, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Fuel")), "Expected 54 litres for refueling...")
		this.AssertEqual("Dry", engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Compound"), "Expected Dry tyre compound...")
		this.AssertEqual(8, engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Set"), "Expected tyre set 8...")
		this.AssertEqual(true, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Suspension"), "Expected suspension repair...")
		this.AssertEqual(false, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Bodywork"), "Expected no bodywork repair...")
		this.AssertEqual(26.5, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FL"), 1), "Unexpected tyre pressure target for FL...")
		this.AssertEqual(26.3, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FR"), 1), "Unexpected tyre pressure target for FR...")
		this.AssertEqual(26.4, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RL"), 1), "Unexpected tyre pressure target for RL...")
		this.AssertEqual(26.4, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RR"), 1), "Unexpected tyre pressure target for RR...")
		
		this.AssertEqual(false, vCompletedActions.HasKey("pitstopPrepared"), "Unexpected pitstop action pitstopPrepared reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("pitstopFinished"), "Unexpected pitstop action pitstopFinished reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("startPitstopSetup"), "Unexpected pitstop action startPitstopSetup reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("finishPitstopSetup"), "Unexpected pitstop action finishPitstopSetup reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("setPitstopRefuelAmount"), "Unexpected pitstop action setPitstopRefuelAmount reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("setPitstopTyreSet"), "Unexpected pitstop action setPitstopTyreSet reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("setPitstopTyrePressures"), "Unexpected pitstop action setPitstopTyrePressures reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("requestPitstopRepairs"), "Unexpected pitstop action requestPitstopRepairs reported...")
	}
	
	PitstopPlanLap5Test() {
		engineer := new TestRaceEngineer(false, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
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
			
			dumpKnowledge(engineer.KnowledgeBase)
		}
		
		this.AssertEqual(true, vCompletedActions.HasKey("pitstopPlanned"), "No pitstop planned...")
		this.AssertEqual(1, vCompletedActions["pitstopPlanned"], "Pitstop not planned as number 1...")
		
		this.AssertEqual(true, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned")), "Pitstop not flagged as Planned...")
		this.AssertEqual(55, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Fuel")), "Expected 55 litres for refueling...")
		this.AssertEqual("Dry", engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Compound"), "Expected Dry tyre compound...")
		this.AssertEqual(8, engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Set"), "Expected tyre set 8...")
		this.AssertEqual(true, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Suspension"), "Expected suspension repair...")
		this.AssertEqual(true, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Bodywork"), "Expected bodywork repair...")
		this.AssertEqual(26.4, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FL"), 1), "Unexpected tyre pressure target for FL...")
		this.AssertEqual(26.3, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FR"), 1), "Unexpected tyre pressure target for FR...")
		this.AssertEqual(26.4, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RL"), 1), "Unexpected tyre pressure target for RL...")
		this.AssertEqual(26.4, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RR"), 1), "Unexpected tyre pressure target for RR...")
		
		this.AssertEqual(false, vCompletedActions.HasKey("pitstopPrepared"), "Unexpected pitstop action pitstopPrepared reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("pitstopFinished"), "Unexpected pitstop action pitstopFinished reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("startPitstopSetup"), "Unexpected pitstop action startPitstopSetup reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("finishPitstopSetup"), "Unexpected pitstop action finishPitstopSetup reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("setPitstopRefuelAmount"), "Unexpected pitstop action setPitstopRefuelAmount reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("setPitstopTyreSet"), "Unexpected pitstop action setPitstopTyreSet reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("setPitstopTyrePressures"), "Unexpected pitstop action setPitstopTyrePressures reported...")
		this.AssertEqual(false, vCompletedActions.HasKey("requestPitstopRepairs"), "Unexpected pitstop action requestPitstopRepairs reported...")
	}
	
	PitstopPrepare3Test() {
		engineer := new TestRaceEngineer(false, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
		vCompletedActions := {}
		
		vPitstopFuel = kNotInitialized
		vPitstopTyreCompound = kNotInitialized
		vPitstopTyreSet = kNotInitialized
		vPitstopTyrePressureIncrements = kNotInitialized
		vPitstopRepairSuspension = kNotInitialized
		vPitstopRepairBodywork = kNotInitialized
		
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
			
			dumpKnowledge(engineer.KnowledgeBase)
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
		this.AssertEqual(8, vPitstopTyreSet, "Expected tyre set 8...")
		this.AssertEqual(false, vPitstopRepairSuspension, "Expected no suspension repair...")
		this.AssertEqual(false, vPitstopRepairBodywork, "Expected no bodywork repair...")
		this.AssertEqual(true, this.equalLists(vPitstopTyrePressureIncrements, [0.3, 0.3, 0.3, 0.3]), "Unexpected tyre pressure increments...")
	}
	
	PitstopPrepare5Test() {
		engineer := new TestRaceEngineer(false, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
		vCompletedActions := {}
		
		vPitstopFuel = kNotInitialized
		vPitstopTyreCompound = kNotInitialized
		vPitstopTyreSet = kNotInitialized
		vPitstopTyrePressureIncrements = kNotInitialized
		vPitstopRepairSuspension = kNotInitialized
		vPitstopRepairBodywork = kNotInitialized
		
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
			
			dumpKnowledge(engineer.KnowledgeBase)
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
		this.AssertEqual(8, vPitstopTyreSet, "Expected tyre set 8...")
		this.AssertEqual(true, vPitstopRepairSuspension, "Expected suspension repair...")
		this.AssertEqual(true, vPitstopRepairBodywork, "Expected bodywork repair...")
		this.AssertEqual(true, this.equalLists(vPitstopTyrePressureIncrements, [0.3, 0.2, 0.3, 0.3]), "Unexpected tyre pressure increments...")
	}
	
	PitstopPerformedTest() {
		engineer := new TestRaceEngineer(false, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
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
			
					dumpKnowledge(engineer.KnowledgeBase)
					
					this.AssertEqual(1, vCompletedActions["pitstopFinished"], "Pitstop not prepared as number 1...")
					
					this.AssertEqual(1, engineer.KnowledgeBase.getValue("Pitstop.Last"), "Last pitstop not set...")
					this.AssertEqual(5, engineer.KnowledgeBase.getValue("Pitstop.1.Lap"), "Pitstop lap not in history memory...")
					this.AssertEqual(true, engineer.KnowledgeBase.getValue("Pitstop.1.Repair.Suspension"), "Pitstop suspension repair info not in history memory...")
					this.AssertEqual(false, engineer.KnowledgeBase.getValue("Pitstop.1.Repair.Bodywork"), "Pitstop bodywork repair info not in history memory...")
					this.AssertEqual(25, engineer.KnowledgeBase.getValue("Pitstop.1.Temperature.Air"), "Pitstop air temperature not in history memory...")
					this.AssertEqual(32, engineer.KnowledgeBase.getValue("Pitstop.1.Temperature.Track"), "Pitstop track temperature not in history memory...")
					this.AssertEqual(626905, engineer.KnowledgeBase.getValue("Pitstop.1.Time"), "Pitstop timestamp not in history memory...")
					
					this.AssertEqual("Dry", engineer.KnowledgeBase.getValue("Pitstop.1.Tyre.Compound"), "Pitstop tyre compound not in history memory...")
					this.AssertEqual(8, engineer.KnowledgeBase.getValue("Pitstop.1.Tyre.Set"), "Pitstop tyre set not in history memory...")
					this.AssertEqual(26.5, Round(engineer.KnowledgeBase.getValue("Pitstop.1.Tyre.Pressure.FL"), 1), "Pitstop tyre pressure FL not in history memory...")
					this.AssertEqual(26.3, Round(engineer.KnowledgeBase.getValue("Pitstop.1.Tyre.Pressure.FR"), 1), "Pitstop tyre pressure FR not in history memory...")
					this.AssertEqual(26.4, Round(engineer.KnowledgeBase.getValue("Pitstop.1.Tyre.Pressure.RL"), 1), "Pitstop tyre pressure RL not in history memory...")
					this.AssertEqual(26.4, Round(engineer.KnowledgeBase.getValue("Pitstop.1.Tyre.Pressure.RR"), 1), "Pitstop tyre pressure RR not in history memory...")
					
					engineer.planPitstop()
				
					this.AssertEqual(kNotInitialized, engineer.KnowledgeBase.getValue("Pitstop.Planned.Nr"), "Planning of pitstop should not be possible in the same lap with a performed pitstop...")
				}
				
				if (A_Index = 7) {
					vFuelWarnings := {}

					vSuspensionDamage := kNotInitialized
					vBodyworkDamage := kNotInitialized

					engineer.planPitstop()
					
					dumpKnowledge(engineer.KnowledgeBase)
				
					this.AssertEqual(2, engineer.KnowledgeBase.getValue("Pitstop.Planned.Nr"), "Pitstop number increment failed...")
					this.AssertEqual(false, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Suspension"), "Expected no suspension repair...")
					this.AssertEqual(true, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Bodywork"), "Expected bodywork repair...")
					this.AssertEqual(0, vFuelWarnings.Count(), "Warning suppression not working...")
					this.AssertEqual(kNotInitialized, vSuspensionDamage, "Warning suppression not working...")
					this.AssertEqual(kNotInitialized, vBodyworkDamage, "Warning suppression not working...")
				}
			}
		}
	}
	
	PitstopMultipleTest() {
		engineer := new TestRaceEngineer(false, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
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
			
			dumpKnowledge(engineer.KnowledgeBase)
		}
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

if !GetKeyState("Ctrl") {
	AHKUnit.AddTestClass(FuelReporting)
	AHKUnit.AddTestClass(DamageReporting)
	AHKUnit.AddTestClass(PitstopHandling)

	AHKUnit.Run()
}
else {
	raceNr := (GetKeyState("Shift") ? 2 : 1)
	engineer := new TestRaceEngineer(false, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race " . raceNr . "\Race Engineer.settings")
								   , new TestPitStopHandler(), "Jona", "de", true, true)

	engineer.setDebug(kDebugPhrases, false)
	
	if (raceNr == 1)
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
				
				dumpKnowledge(engineer.KnowledgeBase)
				
				MsgBox % "Lap " . A_Index . " loaded - Continue?"
			}
		}
	else {
		; 0.0	->	1.1		Report
		; 2.4	->	2.5		Report
		; 2.10	->	2.11	Report
		; 3.4	->	3.5		Report
		
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
					
					dumpKnowledge(engineer.KnowledgeBase)
					
					SplashTextOn 400, 100, , % "Data " lap . "." . A_Index . " loaded..."
					Sleep 500
					SplashTextOff
				}
			}
		} until done
	}
	
	MsgBox Done...
	
	ExitApp
}