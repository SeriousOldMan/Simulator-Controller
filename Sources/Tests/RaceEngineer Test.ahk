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

class OutOfFuelReporting extends Assert {
	FuelWarningTest() {
		engineer := new TestRaceEngineer(false, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race Engineer.settings"), false, false, false)

		vFuelWarnings := {}
		
		Loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Lap " . A_Index . ".data")
			
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
		engineer := new TestRaceEngineer(false, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race Engineer.settings"), false, false, false)

		vFuelWarnings := {}
		
		Loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Lap " . A_Index . ".data")
			
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
		engineer := new TestRaceEngineer(false, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
		Loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Lap " . A_Index . ".data")
			
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
		engineer := new TestRaceEngineer(false, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
		vCompletedActions := {}
		
		Loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Lap " . A_Index . ".data")
			
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
		engineer := new TestRaceEngineer(false, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
		vCompletedActions := {}
		
		Loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Lap " . A_Index . ".data")
			
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
		engineer := new TestRaceEngineer(false, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
		vCompletedActions := {}
		
		Loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Lap " . A_Index . ".data")
			
			if (data.Count() == 0)
				break
			else {
				engineer.addLap(A_Index, data)
			
				if (A_Index = 5)
					engineer.planPitstop()
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
		engineer := new TestRaceEngineer(false, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
		vCompletedActions := {}
		
		vPitstopFuel = kNotInitialized
		vPitstopTyreCompound = kNotInitialized
		vPitstopTyreSet = kNotInitialized
		vPitstopTyrePressureIncrements = kNotInitialized
		vPitstopRepairSuspension = kNotInitialized
		vPitstopRepairBodywork = kNotInitialized
		
		Loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Lap " . A_Index . ".data")
			
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
		engineer := new TestRaceEngineer(false, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race Engineer.settings"), new TestPitStopHandler(), false, false)
		
		vCompletedActions := {}
		
		vPitstopFuel = kNotInitialized
		vPitstopTyreCompound = kNotInitialized
		vPitstopTyreSet = kNotInitialized
		vPitstopTyrePressureIncrements = kNotInitialized
		vPitstopRepairSuspension = kNotInitialized
		vPitstopRepairBodywork = kNotInitialized
		
		Loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Lap " . A_Index . ".data")
			
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
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;


AHKUnit.AddTestClass(OutOfFuelReporting)
AHKUnit.AddTestClass(DamageReporting)
AHKUnit.AddTestClass(PitstopHandling)

AHKUnit.Run()
