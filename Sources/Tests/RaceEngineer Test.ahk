;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - RaceEngineer Test               ;;;
;;;                                         (Race Engineer Rules)           ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#SingleInstance Force			; Ony one instance allowed
#Warn							; Enable warnings to assist with detecting common errors.
#Warn LocalSameAsGlobal, Off

SendMode("Input")				; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir)		; Ensures a consistent starting directory.

global kBuildConfiguration := "Production"


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Startup.ahk"
#Include "..\Libraries\RuleEngine.ahk"
#Include "..\Assistants\Libraries\RaceEngineer.ahk"
#Include "AHKUnit\AHKUnit.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vFuelWarnings := CaseInsenseMap()

global vSuspensionDamage := kNotInitialized
global vBodyworkDamage := kNotInitialized
global vEngineDamage := kNotInitialized
global vDamageRepair := kNotInitialized
global vDamageLapDelta := kNotInitialized
global vDamageStintLaps := kNotInitialized

global vCompletedActions := CaseInsenseMap()

global vPitstopFuel := kNotInitialized
global vPitstopTyreCompound := kNotInitialized
global vPitstopTyreCompoundColor := kNotInitialized
global vPitstopTyreSet := kNotInitialized
global vPitstopTyrePressures := kNotInitialized
global vPitstopRepairSuspension := kNotInitialized
global vPitstopRepairBodywork := kNotInitialized
global vPitstopRepairEngine := kNotInitialized


;;;-------------------------------------------------------------------------;;;
;;;                         Private Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class TestRaceEngineer extends RaceEngineer {
	__New(configuration, settings, remoteHandler := false, name := false, language := kUndefined, synthesizer := false, speaker := false, vocalics := false, speakerBooster := false
		, recognizer := false, listener := false, listenerBooster := false, conversationBooster := false, muted := false, voiceServer := false) {
		super.__New(configuration, remoteHandler, name, language, synthesizer, speaker, vocalics, speakerBooster, recognizer, listener, listenerBooster, conversationBooster, muted, voiceServer)

		this.updateConfigurationValues({Settings: settings})

		setDebug(false)

		this.setDebug(kDebugKnowledgeBase, false)
	}

	createKnowledgeBase(facts := false) {
		local knowledgeBase := super.createKnowledgeBase(facts)

		knowledgeBase.setFact("Session.Settings.Tyre.Pressure.Correction.Pressure", true)

		return knowledgeBase
	}

	supportsPitstop() {
		return true
	}

	addLap(lapNumber, &data) {
		super.addLap(lapNumber, &data)

		if (lapNumber = 1)
			this.updateConfigurationValues({Announcements: {FuelWarning: true, DamageReporting: true, DamageAnalysis: true, PressureReporting: true, WeatherUpdate: true}})
	}

	lowFuelWarning(remainingLaps) {
		super.lowFuelWarning(remainingLaps)

		if isDebug()
			showMessage("Low fuel warning - " . remainingLaps . " lap left")

		vFuelWarnings[this.KnowledgeBase.getValue("Lap")] := remainingLaps
	}

	damageWarning(newSuspensionDamage, newBodyworkDamage, newEngineDamage) {
		global vSuspensionDamage, vBodyworkDamage, vEngineDamage, vDamageRepair, vDamageLapDelta, vDamageStintLaps

		super.damageWarning(newSuspensionDamage, newBodyworkDamage, newEngineDamage)

		if isDebug()
			showMessage("Damage warning for " . (newSuspensionDamage ? "Suspension " : "") . (newBodyworkDamage ? " Bodywork" : "") . (newEngineDamage ? " Engine" : ""))

		vSuspensionDamage := newSuspensionDamage
		vBodyworkDamage := newBodyworkDamage
		vEngineDamage := newEngineDamage
	}

	pressureLossWarning(tyre, lostPressure) {
		super.pressureLossWarning(tyre, lostPressure)

		if isDebug()
			showMessage("Pressure loss warning for " . tyre . ": " . lostPressure)
	}

	reportDamageAnalysis(repair, stintLaps, delta) {
		global vSuspensionDamage, vBodyworkDamage, vEngineDamage, vDamageRepair, vDamageLapDelta, vDamageStintLaps

		super.reportDamageAnalysis(repair, stintLaps, delta)

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
			showMessage("Invoking pitstop action " . action . ((arguments.Length > 0) ? (" with " . values2String(", ", arguments*)) : ""))
	}

	saveSessionState(settingsFile, stateFile) {
		settings := FileRead(settingsFile)
		state := FileRead(stateFile)

		this.showAction("saveSessionState", stateFile, SubStr(state, 1, 20) . "...")

		vCompletedActions["saveSessionState"] := [settings, state]
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

	setPitstopRefuelAmount(pitstopNumber, liters) {
		global vPitstopFuel, vPitstopTyreCompound, vPitstopTyreCompoundColor, vPitstopTyreSet, vPitstopTyrePressures
		global vPitstopRepairSuspension, vPitstopRepairBodywork, vPitstopRepairEngine

		this.showAction("setPitstopRefuelAmount", pitstopNumber, liters)

		vCompletedActions["setPitstopRefuelAmount"] := pitstopNumber

		vPitstopFuel := Round(liters)
	}

	setPitstopTyreSet(pitstopNumber, compound, compoundColor, set := false) {
		global vPitstopFuel, vPitstopTyreCompound, vPitstopTyreCompoundColor, vPitstopTyreSet, vPitstopTyrePressures
		global vPitstopRepairSuspension, vPitstopRepairBodywork, vPitstopRepairEngine

		this.showAction("setPitstopTyreSet", pitstopNumber, compound, set)

		vCompletedActions["setPitstopTyreSet"] := pitstopNumber

		vPitstopTyreCompound := compound
		vPitstopTyreCompoundColor := compoundColor
		vPitstopTyreSet := set
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		global vPitstopFuel, vPitstopTyreCompound, vPitstopTyreCompoundColor, vPitstopTyreSet, vPitstopTyrePressures
		global vPitstopRepairSuspension, vPitstopRepairBodywork, vPitstopRepairEngine

		this.showAction("setPitstopTyrePressures", pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)

		vCompletedActions["setPitstopTyrePressures"] := pitstopNumber

		vPitstopTyrePressures := [pressureFL, pressureFR, pressureRL, pressureRR]
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine) {
		global vPitstopFuel, vPitstopTyreCompound, vPitstopTyreCompoundColor, vPitstopTyreSet, vPitstopTyrePressures
		global vPitstopRepairSuspension, vPitstopRepairBodywork, vPitstopRepairEngine

		this.showAction("requestPitstopRepairs", pitstopNumber, repairSuspension, repairBodywork, repairEngine)

		vCompletedActions["requestPitstopRepairs"] := pitstopNumber

		vPitstopRepairSuspension := repairSuspension
		vPitstopRepairBodywork := repairBodywork
		vPitstopRepairEngine := repairEngine
	}

	savePressureData(*) {
	}

	saveLapState(*) {
	}

	saveSessionInfo(*) {
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                              Test Section                               ;;;
;;;-------------------------------------------------------------------------;;;

class FuelReporting extends Assert {
	FuelWarningTest() {
		global vFuelWarnings

		engineer := TestRaceEngineer(kSimulatorConfiguration, readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), false, false, false)

		vFuelWarnings := CaseInsenseMap()

		loop {
			data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")

			if (data.Count == 0)
				break
			else
				engineer.addLap(A_Index, &data)

			if engineer.Debug[kDebugKnowledgeBase]
				engineer.dumpKnowledgeBase(engineer.KnowledgeBase)
		}

		this.AssertEqual(false, vFuelWarnings.Has(1), "Unexpected fuel warning in lap 1...")
		this.AssertEqual(false, vFuelWarnings.Has(2), "Unexpected fuel warning in lap 2...")
		this.AssertEqual(true, vFuelWarnings.Has(3), "No fuel warning in lap 3...")
		this.AssertEqual(true, vFuelWarnings.Has(4), "No fuel warning in lap 4...")
		this.AssertEqual(true, vFuelWarnings.Has(5), "No fuel warning in lap 5...")

		engineer.finishSession(false)
	}

	RemainingFuelTest() {
		global vFuelWarnings

		engineer := TestRaceEngineer(kSimulatorConfiguration, readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), false, false, false)

		vFuelWarnings := CaseInsenseMap()

		loop {
			data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")

			if (data.Count == 0)
				break
			else
				engineer.addLap(A_Index, &data)

			if engineer.Debug[kDebugKnowledgeBase]
				engineer.dumpKnowledgeBase(engineer.KnowledgeBase)
		}

		this.AssertEqual(2, vFuelWarnings[3], "Unexpected remaining fuel reported in lap 3...")
		this.AssertEqual(1, vFuelWarnings[4], "Unexpected remaining fuel reported in lap 4...")
		this.AssertEqual(0, vFuelWarnings[5], "Unexpected remaining fuel reported in lap 5...")

		engineer.finishSession(false)
	}
}

class DamageReporting extends Assert {
	DamageReportingTest() {
		global vSuspensionDamage, vBodyworkDamage, vEngineDamage, vDamageRepair, vDamageLapDelta, vDamageStintLaps

		engineer := TestRaceEngineer(kSimulatorConfiguration, readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), TestPitStopHandler(), false, false)

		loop {
			data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")

			vSuspensionDamage := kNotInitialized
			vBodyworkDamage := kNotInitialized
			vEngineDamage := kNotInitialized

			if (data.Count == 0)
				break
			else
				engineer.addLap(A_Index, &data)

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

			if engineer.Debug[kDebugKnowledgeBase]
				engineer.dumpKnowledgeBase(engineer.KnowledgeBase)
		}

		engineer.finishSession(false)
	}
}

class DamageAnalysis extends Assert {
	DamageRace2ReportingTest() {
		global vSuspensionDamage, vBodyworkDamage, vEngineDamage, vDamageRepair, vDamageLapDelta, vDamageStintLaps

		engineer := TestRaceEngineer(kSimulatorConfiguration, readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 2\Race Engineer.settings"), TestPitStopHandler(), false, false)

		done := false

		loop {
			lap := A_Index

			loop {
				vSuspensionDamage := kNotInitialized
				vBodyworkDamage := kNotInitialized
				vEngineDamage := kNotInitialized
				vDamageRepair := kNotInitialized
				vDamageLapDelta := kNotInitialized
				vDamageStintLaps := kNotInitialized

				data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 2\Lap " . lap . "." . A_Index . ".data")

				if (data.Count == 0) {
					if (A_Index == 1)
						done := true

					break
				}
				else {
					if (A_Index == 1)
						engineer.addLap(lap, &data)
					else
						engineer.updateLap(lap, &data)

					if engineer.Debug[kDebugKnowledgeBase]
						engineer.dumpKnowledgeBase(engineer.KnowledgeBase)
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
		}
		until done

		engineer.finishSession(false)
	}

	DamageRace3ReportingTest() {
		global vSuspensionDamage, vBodyworkDamage, vEngineDamage, vDamageRepair, vDamageLapDelta, vDamageStintLaps

		engineer := TestRaceEngineer(kSimulatorConfiguration, readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 3\Race Engineer.settings"), TestPitStopHandler(), false, false)

		done := false

		loop {
			lap := A_Index

			loop {
				vSuspensionDamage := kNotInitialized
				vBodyworkDamage := kNotInitialized
				vEngineDamage := kNotInitialized
				vDamageRepair := kNotInitialized
				vDamageLapDelta := kNotInitialized
				vDamageStintLaps := kNotInitialized

				data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 3\Lap " . lap . "." . A_Index . ".data")

				if (data.Count == 0) {
					if (A_Index == 1)
						done := true

					break
				}
				else {
					if (A_Index == 1)
						engineer.addLap(lap, &data)
					else
						engineer.updateLap(lap, &data)

					if engineer.Debug[kDebugKnowledgeBase]
						engineer.dumpKnowledgeBase(engineer.KnowledgeBase)
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

					if engineer.Debug[kDebugKnowledgeBase]
						engineer.dumpKnowledgeBase(engineer.KnowledgeBase)

					engineer.planPitstop()

					if engineer.Debug[kDebugKnowledgeBase]
						engineer.dumpKnowledgeBase(engineer.KnowledgeBase)

					this.AssertEqual(true, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned")), "Pitstop not flagged as Planned...")
					this.AssertEqual(false, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Suspension"), "Expected no suspension repair...")
					this.AssertEqual(true, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Bodywork"), "Expected bodywork repair...")
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
		}
		until done

		engineer.finishSession(false)
	}

	DamageRace4ReportingTest() {
		global vSuspensionDamage, vBodyworkDamage, vEngineDamage, vDamageRepair, vDamageLapDelta, vDamageStintLaps

		engineer := TestRaceEngineer(kSimulatorConfiguration, readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 4\Race Engineer.settings"), TestPitStopHandler(), false, false)

		done := false

		loop {
			lap := A_Index

			loop {
				vSuspensionDamage := kNotInitialized
				vBodyworkDamage := kNotInitialized
				vEngineDamage := kNotInitialized
				vDamageRepair := kNotInitialized
				vDamageLapDelta := kNotInitialized
				vDamageStintLaps := kNotInitialized

				data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 4\Lap " . lap . "." . A_Index . ".data")

				if (data.Count == 0) {
					if (A_Index == 1)
						done := true

					break
				}
				else {
					if (A_Index == 1)
						engineer.addLap(lap, &data)
					else
						engineer.updateLap(lap, &data)

					if engineer.Debug[kDebugKnowledgeBase]
						engineer.dumpKnowledgeBase(engineer.KnowledgeBase)
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
		}
		until done

		engineer.finishSession(false)
	}
}

class PitstopHandling extends Assert {
	equalLists(listA, listB) {
		if (listA.Length != listB.Length)
			return false
		else
			for index, value in listA
				if (listB[index] != value)
					return false

		return true
	}

	PitstopPlanLap3Test() {
		global vCompletedActions

		engineer := TestRaceEngineer(kSimulatorConfiguration, readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), TestPitStopHandler(), false, false)

		vCompletedActions := CaseInsenseMap()

		loop {
			data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")

			if (data.Count == 0)
				break
			else {
				engineer.addLap(A_Index, &data)

				if (A_Index = 3)
					engineer.planPitstop()
			}

			if engineer.Debug[kDebugKnowledgeBase]
				engineer.dumpKnowledgeBase(engineer.KnowledgeBase)
		}

		this.AssertEqual(true, vCompletedActions.Has("pitstopPlanned"), "No pitstop planned...")
		if vCompletedActions.Has("pitstopPlanned")
			this.AssertEqual(1, vCompletedActions["pitstopPlanned"], "Pitstop not planned as number 1...")

		this.AssertEqual(true, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned")), "Pitstop not flagged as Planned...")
		this.AssertEqual(57, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Fuel")), "Expected 57 liters for refueling...")
		this.AssertEqual("Dry", engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Compound"), "Expected Dry tyre compound...")
		this.AssertEqual(8, engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Set"), "Expected tyre set 8...")
		this.AssertEqual(false, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Suspension"), "Expected no suspension repair...")
		this.AssertEqual(false, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Bodywork"), "Expected no bodywork repair...")
		this.AssertEqual(26.6, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FL"), 1), "Unexpected tyre pressure target for FL...")
		this.AssertEqual(26.4, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FR"), 1), "Unexpected tyre pressure target for FR...")
		this.AssertEqual(26.6, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RL"), 1), "Unexpected tyre pressure target for RL...")
		this.AssertEqual(26.1, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RR"), 1), "Unexpected tyre pressure target for RR...")

		this.AssertEqual(false, vCompletedActions.Has("pitstopPrepared"), "Unexpected pitstop action pitstopPrepared reported...")
		this.AssertEqual(false, vCompletedActions.Has("pitstopFinished"), "Unexpected pitstop action pitstopFinished reported...")
		this.AssertEqual(false, vCompletedActions.Has("startPitstopSetup"), "Unexpected pitstop action startPitstopSetup reported...")
		this.AssertEqual(false, vCompletedActions.Has("finishPitstopSetup"), "Unexpected pitstop action finishPitstopSetup reported...")
		this.AssertEqual(false, vCompletedActions.Has("setPitstopRefuelAmount"), "Unexpected pitstop action setPitstopRefuelAmount reported...")
		this.AssertEqual(false, vCompletedActions.Has("setPitstopTyreSet"), "Unexpected pitstop action setPitstopTyreSet reported...")
		this.AssertEqual(false, vCompletedActions.Has("setPitstopTyrePressures"), "Unexpected pitstop action setPitstopTyrePressures reported...")
		this.AssertEqual(false, vCompletedActions.Has("requestPitstopRepairs"), "Unexpected pitstop action requestPitstopRepairs reported...")

		engineer.finishSession(false)
	}

	PitstopPlanLap4Test() {
		global vCompletedActions

		engineer := TestRaceEngineer(kSimulatorConfiguration, readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), TestPitStopHandler(), false, false)

		vCompletedActions := CaseInsenseMap()

		loop {
			data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")

			if (data.Count == 0)
				break
			else {
				engineer.addLap(A_Index, &data)

				if (A_Index = 4)
					engineer.planPitstop()
			}

			if engineer.Debug[kDebugKnowledgeBase]
				engineer.dumpKnowledgeBase(engineer.KnowledgeBase)
		}

		this.AssertEqual(true, vCompletedActions.Has("pitstopPlanned"), "No pitstop planned...")
		if vCompletedActions.Has("pitstopPlanned")
			this.AssertEqual(1, vCompletedActions["pitstopPlanned"], "Pitstop not planned as number 1...")

		this.AssertEqual(true, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned")), "Pitstop not flagged as Planned...")
		this.AssertEqual(57, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Fuel")), "Expected 57 liters for refueling...")
		this.AssertEqual("Dry", engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Compound"), "Expected Dry tyre compound...")
		this.AssertEqual(8, engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Set"), "Expected tyre set 8...")
		this.AssertEqual(true, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Suspension"), "Expected suspension repair...")
		this.AssertEqual(false, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Bodywork"), "Expected no bodywork repair...")
		this.AssertEqual(26.7, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FL"), 1), "Unexpected tyre pressure target for FL...")
		this.AssertEqual(26.4, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FR"), 1), "Unexpected tyre pressure target for FR...")
		this.AssertEqual(26.6, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RL"), 1), "Unexpected tyre pressure target for RL...")
		this.AssertEqual(26.0, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RR"), 1), "Unexpected tyre pressure target for RR...")

		this.AssertEqual(false, vCompletedActions.Has("pitstopPrepared"), "Unexpected pitstop action pitstopPrepared reported...")
		this.AssertEqual(false, vCompletedActions.Has("pitstopFinished"), "Unexpected pitstop action pitstopFinished reported...")
		this.AssertEqual(false, vCompletedActions.Has("startPitstopSetup"), "Unexpected pitstop action startPitstopSetup reported...")
		this.AssertEqual(false, vCompletedActions.Has("finishPitstopSetup"), "Unexpected pitstop action finishPitstopSetup reported...")
		this.AssertEqual(false, vCompletedActions.Has("setPitstopRefuelAmount"), "Unexpected pitstop action setPitstopRefuelAmount reported...")
		this.AssertEqual(false, vCompletedActions.Has("setPitstopTyreSet"), "Unexpected pitstop action setPitstopTyreSet reported...")
		this.AssertEqual(false, vCompletedActions.Has("setPitstopTyrePressures"), "Unexpected pitstop action setPitstopTyrePressures reported...")
		this.AssertEqual(false, vCompletedActions.Has("requestPitstopRepairs"), "Unexpected pitstop action requestPitstopRepairs reported...")

		engineer.finishSession(false)
	}

	PitstopPlanLap5Test() {
		global vCompletedActions

		engineer := TestRaceEngineer(kSimulatorConfiguration, readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), TestPitStopHandler(), false, false)

		vCompletedActions := CaseInsenseMap()

		loop {
			data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")

			if (data.Count == 0)
				break
			else {
				engineer.addLap(A_Index, &data)

				if (A_Index = 5)
					engineer.planPitstop()

				if (A_Index = 6)
					Break
			}

			if engineer.Debug[kDebugKnowledgeBase]
				engineer.dumpKnowledgeBase(engineer.KnowledgeBase)
		}

		this.AssertEqual(true, vCompletedActions.Has("pitstopPlanned"), "No pitstop planned...")
		if vCompletedActions.Has("pitstopPlanned")
			this.AssertEqual(1, vCompletedActions["pitstopPlanned"], "Pitstop not planned as number 1...")

		this.AssertEqual(true, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned")), "Pitstop not flagged as Planned...")
		this.AssertEqual(57, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Fuel")), "Expected 57 liters for refueling...")
		this.AssertEqual("Dry", engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Compound"), "Expected Dry tyre compound...")
		this.AssertEqual(8, engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Set"), "Expected tyre set 8...")
		this.AssertEqual(true, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Suspension"), "Expected suspension repair...")
		this.AssertEqual(true, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Bodywork"), "Expected bodywork repair...")
		this.AssertEqual(26.6, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FL"), 1), "Unexpected tyre pressure target for FL...")
		this.AssertEqual(26.3, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FR"), 1), "Unexpected tyre pressure target for FR...")
		this.AssertEqual(26.6, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RL"), 1), "Unexpected tyre pressure target for RL...")
		this.AssertEqual(26.3, Round(engineer.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RR"), 1), "Unexpected tyre pressure target for RR...")

		this.AssertEqual(false, vCompletedActions.Has("pitstopPrepared"), "Unexpected pitstop action pitstopPrepared reported...")
		this.AssertEqual(false, vCompletedActions.Has("pitstopFinished"), "Unexpected pitstop action pitstopFinished reported...")
		this.AssertEqual(false, vCompletedActions.Has("startPitstopSetup"), "Unexpected pitstop action startPitstopSetup reported...")
		this.AssertEqual(false, vCompletedActions.Has("finishPitstopSetup"), "Unexpected pitstop action finishPitstopSetup reported...")
		this.AssertEqual(false, vCompletedActions.Has("setPitstopRefuelAmount"), "Unexpected pitstop action setPitstopRefuelAmount reported...")
		this.AssertEqual(false, vCompletedActions.Has("setPitstopTyreSet"), "Unexpected pitstop action setPitstopTyreSet reported...")
		this.AssertEqual(false, vCompletedActions.Has("setPitstopTyrePressures"), "Unexpected pitstop action setPitstopTyrePressures reported...")
		this.AssertEqual(false, vCompletedActions.Has("requestPitstopRepairs"), "Unexpected pitstop action requestPitstopRepairs reported...")

		engineer.finishSession(false)
	}

	PitstopPrepare3Test() {
		global vCompletedActions
		global vPitstopFuel, vPitstopTyreCompound, vPitstopTyreCompoundColor, vPitstopTyreSet, vPitstopTyrePressures
		global vPitstopRepairSuspension, vPitstopRepairBodywork, vPitstopRepairEngine

		engineer := TestRaceEngineer(kSimulatorConfiguration, readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), TestPitStopHandler(), false, false)

		vCompletedActions := CaseInsenseMap()

		vPitstopFuel := kNotInitialized
		vPitstopTyreCompound := kNotInitialized
		vPitstopTyreCompoundColor := kNotInitialized
		vPitstopTyreSet := kNotInitialized
		vPitstopTyrePressures := kNotInitialized
		vPitstopRepairSuspension := kNotInitialized
		vPitstopRepairBodywork := kNotInitialized
		vPitstopRepairEngine := kNotInitialized

		loop {
			data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")

			if (data.Count == 0)
				break
			else {
				engineer.addLap(A_Index, &data)

				if (A_Index = 3) {
					engineer.planPitstop()
					engineer.preparePitstop()
				}
			}

			if engineer.Debug[kDebugKnowledgeBase]
				engineer.dumpKnowledgeBase(engineer.KnowledgeBase)
		}

		if vCompletedActions.Has("pitstopPlanned")
			this.AssertEqual(1, vCompletedActions["pitstopPlanned"], "Pitstop not planned as number 1...")
		else
			this.AssertTrue(false, "Pitstop not planned as number 1...")
		if vCompletedActions.Has("pitstopPrepared")
			this.AssertEqual(1, vCompletedActions["pitstopPrepared"], "Pitstop not prepared as number 1...")
		else
			this.AssertTrue(false, "Pitstop not prepared as number 1...")

		this.AssertEqual(false, vCompletedActions.Has("pitstopFinished"), "Pitstop action pitstopFinished should not be reported...")

		this.AssertEqual(true, vCompletedActions.Has("startPitstopSetup"), "Pitstop action startPitstopSetup not reported...")
		this.AssertEqual(true, vCompletedActions.Has("finishPitstopSetup"), "Pitstop action finishPitstopSetup not reported...")
		this.AssertEqual(true, vCompletedActions.Has("setPitstopRefuelAmount"), "Pitstop action setPitstopRefuelAmount not reported...")
		this.AssertEqual(true, vCompletedActions.Has("setPitstopTyreSet"), "Pitstop action setPitstopTyreSet not reported...")
		this.AssertEqual(true, vCompletedActions.Has("setPitstopTyrePressures"), "Pitstop action setPitstopTyrePressures not reported...")
		this.AssertEqual(true, vCompletedActions.Has("requestPitstopRepairs"), "Pitstop action requestPitstopRepairs not reported...")

		this.AssertEqual(57, vPitstopFuel, "Expected 57 liters for refueling...")
		this.AssertEqual("Dry", vPitstopTyreCompound, "Expected Dry tyre compound...")
		this.AssertEqual("Black", vPitstopTyreCompoundColor, "Expected Black tyre compound color...")
		this.AssertEqual(8, vPitstopTyreSet, "Expected tyre set 8...")
		this.AssertEqual(false, vPitstopRepairSuspension, "Expected no suspension repair...")
		this.AssertEqual(false, vPitstopRepairBodywork, "Expected no bodywork repair...")
		this.AssertEqual(false, vPitstopRepairEngine, "Expected no engine repair...")

		this.AssertEqual(true, this.equalLists(vPitstopTyrePressures, [26.6, 26.4, 26.6, 26.1]), "Unexpected tyre pressures...")

		engineer.finishSession(false)
	}

	PitstopPrepare5Test() {
		global vCompletedActions
		global vPitstopFuel, vPitstopTyreCompound, vPitstopTyreCompoundColor, vPitstopTyreSet, vPitstopTyrePressures
		global vPitstopRepairSuspension, vPitstopRepairBodywork, vPitstopRepairEngine

		engineer := TestRaceEngineer(kSimulatorConfiguration, readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), TestPitStopHandler(), false, false)

		vCompletedActions := CaseInsenseMap()

		vPitstopFuel := kNotInitialized
		vPitstopTyreCompound := kNotInitialized
		vPitstopTyreCompoundColor := kNotInitialized
		vPitstopTyreSet := kNotInitialized
		vPitstopTyrePressures := kNotInitialized
		vPitstopRepairSuspension := kNotInitialized
		vPitstopRepairBodywork := kNotInitialized
		vPitstopRepairEngine := kNotInitialized

		loop {
			data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")

			if (data.Count == 0)
				break
			else {
				engineer.addLap(A_Index, &data)

				if (A_Index = 5) {
					engineer.planPitstop()
					engineer.preparePitstop()
				}
			}

			if engineer.Debug[kDebugKnowledgeBase]
				engineer.dumpKnowledgeBase(engineer.KnowledgeBase)
		}

		if vCompletedActions.Has("pitstopPlanned")
			this.AssertEqual(1, vCompletedActions["pitstopPlanned"], "Pitstop not planned as number 1...")
		else
			this.AssertTrue(false, "Pitstop not planned as number 1...")
		if vCompletedActions.Has("pitstopPrepared")
			this.AssertEqual(1, vCompletedActions["pitstopPrepared"], "Pitstop not prepared as number 1...")
		else
			this.AssertTrue(false, "Pitstop not prepared as number 1...")

		this.AssertEqual(false, vCompletedActions.Has("pitstopFinished"), "Pitstop action pitstopFinished should not be reported...")

		this.AssertEqual(true, vCompletedActions.Has("startPitstopSetup"), "Pitstop action startPitstopSetup not reported...")
		this.AssertEqual(true, vCompletedActions.Has("finishPitstopSetup"), "Pitstop action finishPitstopSetup not reported...")
		this.AssertEqual(true, vCompletedActions.Has("setPitstopRefuelAmount"), "Pitstop action setPitstopRefuelAmount not reported...")
		this.AssertEqual(true, vCompletedActions.Has("setPitstopTyreSet"), "Pitstop action setPitstopTyreSet not reported...")
		this.AssertEqual(true, vCompletedActions.Has("setPitstopTyrePressures"), "Pitstop action setPitstopTyrePressures not reported...")
		this.AssertEqual(true, vCompletedActions.Has("requestPitstopRepairs"), "Pitstop action requestPitstopRepairs not reported...")

		this.AssertEqual(57, vPitstopFuel, "Expected 57 liters for refueling...")
		this.AssertEqual("Dry", vPitstopTyreCompound, "Expected Dry tyre compound...")
		this.AssertEqual("Black", vPitstopTyreCompoundColor, "Expected Black tyre compound color...")
		this.AssertEqual(8, vPitstopTyreSet, "Expected tyre set 8...")
		this.AssertEqual(true, vPitstopRepairSuspension, "Expected suspension repair...")
		this.AssertEqual(true, vPitstopRepairBodywork, "Expected bodywork repair...")
		this.AssertEqual(false, vPitstopRepairEngine, "Expected no engine repair...")

		this.AssertEqual(true, this.equalLists(vPitstopTyrePressures, [26.6, 26.3, 26.6, 26.3]), "Unexpected tyre pressures...")

		engineer.finishSession(false)
	}

	PitstopPerformedTest() {
		global vFuelWarnings
		global vCompletedActions
		global vSuspensionDamage, vBodyworkDamage, vEngineDamage, vDamageRepair, vDamageLapDelta, vDamageStintLaps

		engineer := TestRaceEngineer(kSimulatorConfiguration, readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), TestPitStopHandler(), false, false)

		vCompletedActions := CaseInsenseMap()

		loop {
			data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")

			if (data.Count == 0)
				break
			else {
				engineer.addLap(A_Index, &data)

				if (A_Index = 4) {
					engineer.planPitstop()
					engineer.preparePitstop()
				}

				if (A_Index = 5) {
					engineer.performPitstop()

					if engineer.Debug[kDebugKnowledgeBase]
						engineer.dumpKnowledgeBase(engineer.KnowledgeBase)

					if vCompletedActions.Has("pitstopFinished")
						this.AssertEqual(1, vCompletedActions["pitstopFinished"], "Pitstop not prepared as number 1...")
					else
						this.AssertTrue(false, "Pitstop not prepared as number 1...")

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
					this.AssertEqual(26.0, Round(engineer.KnowledgeBase.getValue("Pitstop.1.Tyre.Pressure.RR"), 1), "Pitstop tyre pressure RR not in history memory...")

					engineer.planPitstop()

					this.AssertEqual(kNotInitialized, engineer.KnowledgeBase.getValue("Pitstop.Planned.Nr"), "Planning of pitstop should not be possible in the same lap with a performed pitstop...")
				}

				if (A_Index = 7) {
					vFuelWarnings := CaseInsenseMap()

					vSuspensionDamage := kNotInitialized
					vBodyworkDamage := kNotInitialized
					vEngineDamage := kNotInitialized

					engineer.planPitstop()

					if engineer.Debug[kDebugKnowledgeBase]
						engineer.dumpKnowledgeBase(engineer.KnowledgeBase)

					this.AssertEqual(2, engineer.KnowledgeBase.getValue("Pitstop.Planned.Nr"), "Pitstop number increment failed...")
					this.AssertEqual(false, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Suspension"), "Expected no suspension repair...")
					this.AssertEqual(true, engineer.KnowledgeBase.getValue("Pitstop.Planned.Repair.Bodywork"), "Expected bodywork repair...")
					this.AssertEqual(0, vFuelWarnings.Count, "Warning suppression not working...")
					this.AssertEqual(kNotInitialized, vSuspensionDamage, "Warning suppression not working...")
					this.AssertEqual(kNotInitialized, vBodyworkDamage, "Warning suppression not working...")
				}
			}
		}

		engineer.finishSession(false)
	}

	PitstopMultipleTest() {
		global vSuspensionDamage, vBodyworkDamage, vEngineDamage, vDamageRepair, vDamageLapDelta, vDamageStintLaps

		engineer := TestRaceEngineer(kSimulatorConfiguration, readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 1\Race Engineer.settings"), TestPitStopHandler(), false, false)

		loop {
			vSuspensionDamage := kNotInitialized
			vBodyworkDamage := kNotInitialized
			vEngineDamage := kNotInitialized

			data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")

			if (data.Count == 0)
				break
			else {
				engineer.addLap(A_Index, &data)

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

					engineer.dumpKnowledgeBase(engineer.KnowledgeBase)

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

			if engineer.Debug[kDebugKnowledgeBase]
				engineer.dumpKnowledgeBase(engineer.KnowledgeBase)
		}

		engineer.finishSession(false)
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

setMultiMapValue(kSimulatorConfiguration, "Race Engineer Analysis", "Unknown" . ".ConsideredHistoryLaps", 2)
setMultiMapValue(kSimulatorConfiguration, "Race Engineer Analysis", "Unknown" . ".HistoryLapsDamping", 0.5)
setMultiMapValue(kSimulatorConfiguration, "Race Engineer Analysis", "Unknown" . ".AdjustLapTime", false)

if !GetKeyState("Ctrl") {
	startTime := A_TickCount

	AHKUnit.AddTestClass(FuelReporting)
	AHKUnit.AddTestClass(DamageReporting)
	AHKUnit.AddTestClass(DamageAnalysis)
	AHKUnit.AddTestClass(PitstopHandling)

	AHKUnit.Run()

	withBlockedWindows(MsgBox, "Full run took " . (A_TickCount - startTime) . " ms")
}
else {
	raceNr := (GetKeyState("Alt") ? 18 : ((GetKeyState("Shift") ? 2 : 1)))

	engineer := TestRaceEngineer(kSimulatorConfiguration, readMultiMap(kSourcesDirectory . "Tests\Test Data\Race " . raceNr . "\Race Engineer.settings")
							   , TestPitStopHandler(), "Jona", "EN", true, true, false, true, true, true, true, true)

	engineer.VoiceManager.setDebug(kDebugGrammars, false)

	if (raceNr == 1) {
		engineer.setDebug(kDebugKnowledgeBase, true)

		loop {
			data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 1\Lap " . A_Index . ".data")

			if (data.Count == 0)
				break
			else {
				engineer.addLap(A_Index, &data)

				if (A_Index = 3) {
					engineer.planPitstop()
					engineer.preparePitstop()
				}

				if (A_Index = 4) {
					engineer.performPitstop()
				}

				if engineer.Debug[kDebugKnowledgeBase]
					engineer.dumpKnowledgeBase(engineer.KnowledgeBase)

				if isDebug()
					withBlockedWindows(MsgBox, "Lap " . A_Index . " loaded - Continue?")
			}
		}

		engineer.finishSession()

		while engineer.KnowledgeBase
			Sleep(1000)
	}
	else if (raceNr == 2) {
		; 0.0	->	1.1		Report Bodywork
		; 2.4	->	2.5		Report Bodywork
		; 2.10	->	2.11	Report Suspension & Bodywork
		; 3.4	->	3.5		Report Bodywork

		done := false

		loop {
			lap := A_Index

			loop {
				data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 2\Lap " . lap . "." . A_Index . ".data")

				if (data.Count == 0) {
					if (A_Index == 1)
						done := true

					break
				}
				else {
					if (A_Index == 1)
						engineer.addLap(lap, &data)
					else
						engineer.updateLap(lap, &data)

					if engineer.Debug[kDebugKnowledgeBase]
						engineer.dumpKnowledgeBase(engineer.KnowledgeBase)

					if isDebug()
						showMessage("Data " lap . "." . A_Index . " loaded...")
				}
			}
		}
		until done
	}
	else if (raceNr == 3) {
		; 3.1	->	3.2		Report Bodywork
		; 5.1				Recommend Pitstop
		; 5.3	->	5.4		Report Bodywork
		; 7.1				Recommend Pitstop

		done := false

		loop {
			lap := A_Index

			loop {
				data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 3\Lap " . lap . "." . A_Index . ".data")

				if (data.Count == 0) {
					if (A_Index == 1)
						done := true

					break
				}
				else {
					if (A_Index == 1)
						engineer.addLap(lap, &data)
					else
						engineer.updateLap(lap, &data)

					if engineer.Debug[kDebugKnowledgeBase]
						engineer.dumpKnowledgeBase(engineer.KnowledgeBase)

					if isDebug()
						showMessage("Data " lap . "." . A_Index . " loaded...")
				}
			}
		}
		until done
	}
	else if (raceNr == 4) {
		; 0.0	->	1.1		Report Bodywork
		; 2.1	->	3.1		Recommend Strategy
		; 11.7	->	11.8	Report Bodywork
		; 12.10	->	13.1	Recommend Strategy

		done := false

		loop {
			lap := A_Index

			loop {
				data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 4\Lap " . lap . "." . A_Index . ".data")

				if (data.Count == 0) {
					if (A_Index == 1)
						done := true

					break
				}
				else {
					if (A_Index == 1)
						engineer.addLap(lap, &data)
					else
						engineer.updateLap(lap, &data)

					if (lap = 8) {
						engineer.planPitstop()

						engineer.preparePitstop()
					}

					if engineer.Debug[kDebugKnowledgeBase]
						engineer.dumpKnowledgeBase(engineer.KnowledgeBase)

					if isDebug()
						showMessage("Data " lap . "." . A_Index . " loaded...")
				}
			}
		}
		until done
	}
	else if (raceNr == 5) {
		done := false

		loop {
			lap := A_Index

			loop {
				data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 5\Lap " . lap . "." . A_Index . ".data")

				if (data.Count == 0) {
					if (A_Index == 1)
						done := true

					break
				}
				else {
					if (A_Index == 1)
						engineer.addLap(lap, &data)
					else
						engineer.updateLap(lap, &data)

					if (lap = 8)
						engineer.planPitstop()

					if engineer.Debug[kDebugKnowledgeBase]
						engineer.dumpKnowledgeBase(engineer.KnowledgeBase)

					if (lap = 8)
						withBlockedWindows(MsgBox, "Pitstop")

					if isDebug()
						showMessage("Data " lap . "." . A_Index . " loaded...")
				}
			}
		}
		until done
	}
	else if (raceNr == 6) {
		done := false

		loop {
			lap := A_Index

			loop {
				data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race 6\Lap " . lap . "." . A_Index . ".data")

				if (data.Count == 0) {
					if (A_Index == 1)
						done := true

					break
				}
				else {
					if (A_Index == 1)
						engineer.addLap(lap, &data)
					else
						engineer.updateLap(lap, &data)

					if (lap = 17) {
						engineer.planPitstop()

						if engineer.Debug[kDebugKnowledgeBase]
							engineer.dumpKnowledgeBase(engineer.KnowledgeBase)

						withBlockedWindows(MsgBox, "Pitstop")
					}

					if isDebug()
						showMessage("Data " lap . "." . A_Index . " loaded...")
				}
			}
		}
		until done
	}
	else if ((raceNr = 9) || (raceNr = 11) || (raceNr = 12)) {
		done := false

		loop {
			lap := A_Index

			loop {
				data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race " . raceNr . "\Lap " . lap . "." . A_Index . ".data")

				if (data.Count == 0) {
					if (A_Index == 1)
						done := true

					break
				}
				else {
					if (A_Index == 1)
						engineer.addLap(lap, &data)
					else
						engineer.updateLap(lap, &data)

					if (raceNr = 9) {
						if (lap = 22) {
							engineer.planPitstop()
							engineer.preparePitstop()

							withBlockedWindows(MsgBox, "Pitstop Prepare")
						}

						if (lap = 24) {
							engineer.performPitstop(23)

							withBlockedWindows(MsgBox, "Pitstop Perform")
						}
					}
					else if (raceNr = 11) {
						if (lap = 9) {
							engineer.planPitstop()
							engineer.preparePitstop()

							withBlockedWindows(MsgBox, "Pitstop Prepare")
						}

						if (lap = 11) {
							engineer.performPitstop(11)

							withBlockedWindows(MsgBox, "Pitstop Perform")
						}

						if (lap = 19)
							withBlockedWindows(MsgBox, "Inspect")
					}
					else if (raceNr = 12) {
						if (lap = 21) {
							engineer.planPitstop()
							engineer.preparePitstop()

							withBlockedWindows(MsgBox, "Pitstop Prepare")
						}

						if (lap = 22) {
							engineer.performPitstop(22)

							withBlockedWindows(MsgBox, "Pitstop Perform")
						}

						if (lap = 24)
							withBlockedWindows(MsgBox, "Inspect")
					}

					if isDebug()
						showMessage("Data " lap . "." . A_Index . " loaded...")
				}
			}
		}
		until done
	}
	else if (raceNr = 18) {
		done := false

		loop {
			lap := A_Index

			loop {
				data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race " . raceNr . "\Race Engineer Lap " . lap . "." . A_Index . ".data")

				if (data.Count == 0) {
					if (lap == 82)
						done := true

					break
				}
				else {
					if (A_Index == 1)
						engineer.addLap(lap, &data)
					else
						engineer.updateLap(lap, &data)

					if (isDebug() && (A_Index == 1))
						showMessage("Data " lap . "." . A_Index . " loaded...")
				}
			}
		}
		until done
	}
	else if (raceNr > 6) {
		done := false

		loop {
			lap := A_Index

			loop {
				data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race " . raceNr . "\Lap " . lap . "." . A_Index . ".data")

				if (data.Count == 0) {
					if (A_Index == 1)
						done := true

					break
				}
				else {
					if (A_Index == 1)
						engineer.addLap(lap, &data)
					else
						engineer.updateLap(lap, &data)

					if isDebug()
						showMessage("Data " lap . "." . A_Index . " loaded...")
				}
			}
		}
		until done
	}

	if isDebug()
		withBlockedWindows(MsgBox, "Done...")

	ExitApp()
}

show(context, args*) {
	showMessage(values2string(A_Space, args*), "Race Engineer Test", "Information.png", 2500)

	return true
}