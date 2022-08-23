;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - RaceStrategist Test             ;;;
;;;                                         (Race Strategist Rules)         ;;;
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
#Include ..\Assistants\Libraries\RaceStrategist.ahk
#Include AHKUnit\AHKUnit.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Private Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class TestRaceStrategist extends RaceStrategist {
	__New(configuration, settings, remoteHandler := false, name := false, language := "__Undefined__", service := false, speaker := false, recognizer := false, listener := false, voiceServer := false) {
		base.__New(configuration, remoteHandler, name, language, service, speaker, false, recognizer, listener, voiceServer)

		this.updateConfigurationValues({Settings: settings})
	}

	createKnowledgeBase(facts) {
		local knowledgeBase := base.createKnowledgeBase(facts)

		knowledgeBase.addRule(new RuleCompiler().compileRule("carNumber(?car, ?car)"))

		return knowledgeBase
	}
}

class BasicReporting extends Assert {
	BasisTest() {
		strategist := new TestRaceStrategist(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 13\Race Strategist.settings"), false, false, false)

		loop {
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

			strategist.dumpKnowledgeBase(strategist.KnowledgeBase)

			if (A_Index >= 5)
				break
		}

		strategist.finishSession(false)
	}

	StandingsMemoryTest() {
		strategist := new TestRaceStrategist(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 13\Race Strategist.settings"), false, false, false)

		loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 13\Race Strategist Lap " . A_Index . ".1.data")

			if (data.Count() == 0)
				break
			else
				strategist.addLap(A_Index, data)

			strategist.dumpKnowledgeBase(strategist.KnowledgeBase)

			if (A_Index >= 5)
				break
		}

		this.AssertEqual(7, strategist.KnowledgeBase.getValue("Standings.Lap.1.Car.13.Position"), "Unexpected position detected in lap 1...")
		this.AssertEqual(117417, strategist.KnowledgeBase.getValue("Standings.Lap.1.Car.13.Time"), "Unexpected time detected in lap 1...")
		this.AssertEqual(7, strategist.KnowledgeBase.getValue("Standings.Lap.2.Car.13.Position"), "Unexpected position detected in lap 2...")
		this.AssertEqual(105939, strategist.KnowledgeBase.getValue("Standings.Lap.2.Car.13.Time"), "Unexpected time detected in lap 2...")
		this.AssertEqual(7, strategist.KnowledgeBase.getValue("Standings.Lap.3.Car.13.Position"), "Unexpected position detected in lap 3...")
		this.AssertEqual(104943, strategist.KnowledgeBase.getValue("Standings.Lap.3.Car.13.Time"), "Unexpected time detected in lap 3...")
		this.AssertEqual(6, strategist.KnowledgeBase.getValue("Standings.Lap.4.Car.13.Position"), "Unexpected position detected in lap 4...")
		this.AssertEqual(103383, strategist.KnowledgeBase.getValue("Standings.Lap.4.Car.13.Time"), "Unexpected time detected in lap 4...")
		this.AssertEqual(5, strategist.KnowledgeBase.getValue("Standings.Lap.5.Car.13.Position"), "Unexpected position detected in lap 5...")
		this.AssertEqual(103032, strategist.KnowledgeBase.getValue("Standings.Lap.5.Car.13.Time"), "Unexpected time detected in lap 5...")

		strategist.finishSession(false)
	}
}

class GapReporting extends Assert {
	checkGap(knowledgeBase, type, behindCar, behindDelta, frontCar, frontDelta, leaderCar := false, leaderGap := false) {
		if (behindCar != knowledgeBase.getValue("Position." . type . ".Behind.Car", false))
			return false

		if (behindDelta != Round(knowledgeBase.getValue("Position." . type . ".Behind.Delta", false)))
			return false

		if (frontCar != knowledgeBase.getValue("Position." . type . ".Ahead.Car", knowledgeBase.getValue("Position." . type . ".Front.Car", false)))
			return false

		if (frontDelta != Round(knowledgeBase.getValue("Position." . type . ".Ahead.Delta", knowledgeBase.getValue("Position." . type . ".Front.Delta", false))))
			return false

		if ((type = "Standings") && leaderCar) {
			if (leaderCar != knowledgeBase.getValue("Position." . type . ".Leader.Car", false))
				return false

			if (leaderGap != Round(knowledgeBase.getValue("Position." . type . ".Leader.Delta", false)))
				return false
		}

		return true
	}

	StandingsGapTest() {
		strategist := new TestRaceStrategist(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 13\Race Strategist.settings"), false, false, false)

		loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 13\Race Strategist Lap " . A_Index . ".1.data")

			if (data.Count() == 0)
				break
			else
				strategist.addLap(A_Index, data)

			switch A_Index {
				case 1:
					this.AssertTrue(this.checkGap(strategist.KnowledgeBase, "Standings", 6, -871, 10, 219, 1, -133938), "Unexpected standings gap detected in lap " . A_Index . "...")
				case 2:
					this.AssertTrue(this.checkGap(strategist.KnowledgeBase, "Standings", 9, -7553, 6, 582, 1, -218441), "Unexpected standings gap detected in lap " . A_Index . "...")
				case 3:
					this.AssertTrue(this.checkGap(strategist.KnowledgeBase, "Standings", 19, -9343, 6, 1446, 1, -329184), "Unexpected standings gap detected in lap " . A_Index . "...")
				case 4:
					this.AssertTrue(this.checkGap(strategist.KnowledgeBase, "Standings", 6, -4755, 11, 6900, 1, -422693), "Unexpected standings gap detected in lap " . A_Index . "...")
				case 5:
					this.AssertTrue(this.checkGap(strategist.KnowledgeBase, "Standings", 6, -4464, 4, 9153, 1, -519263), "Unexpected standings gap detected in lap " . A_Index . "...")
			}

			strategist.dumpKnowledgeBase(strategist.KnowledgeBase)

			if (A_Index >= 5)
				break
		}

		strategist.finishSession(false)
	}

	TrackGapTest() {
		strategist := new TestRaceStrategist(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 13\Race Strategist.settings"), false, false, false)

		loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 13\Race Strategist Lap " . A_Index . ".1.data")

			if (data.Count() == 0)
				break
			else
				strategist.addLap(A_Index, data)

			switch A_Index {
				case 1:
					this.AssertTrue(this.checkGap(strategist.KnowledgeBase, "Track", 6, -871, 10, 219), "Unexpected track gap detected in lap " . A_Index . "...")
				case 2:
					this.AssertTrue(this.checkGap(strategist.KnowledgeBase, "Track", 1, -6563, 6, 582), "Unexpected track gap detected in lap " . A_Index . "...")
				case 3:
					this.AssertTrue(this.checkGap(strategist.KnowledgeBase, "Track", 19, -9343, 6, 1446), "Unexpected track gap detected in lap " . A_Index . "...")
				case 4:
					this.AssertTrue(this.checkGap(strategist.KnowledgeBase, "Track", 6, -4755, 20, 6315), "Unexpected track gap detected in lap " . A_Index . "...")
				case 5:
					this.AssertTrue(this.checkGap(strategist.KnowledgeBase, "Track", 21, -4103, 4, 9153), "Unexpected track gap detected in lap " . A_Index . "...")
			}

			strategist.dumpKnowledgeBase(strategist.KnowledgeBase)

			if (A_Index >= 5)
				break
		}

		strategist.finishSession(false)
	}
}

class PositionProjection extends Assert {
	PositionProjectionTest() {
		strategist := new TestRaceStrategist(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 13\Race Strategist.settings"), false, false, false)

		loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 13\Race Strategist Lap " . A_Index . ".1.data")

			if (data.Count() == 0)
				break
			else
				strategist.addLap(A_Index, data)

			if (A_Index = 3) {
				strategist.KnowledgeBase.setFact("Standings.Extrapolate", 10)

				strategist.KnowledgeBase.produce()

				position := strategist.KnowledgeBase.getValue("Standings.Extrapolated." . 10 . ".Car.13.Position", false)

				strategist.dumpKnowledgeBase(strategist.KnowledgeBase)

				this.AssertEqual(8, position, "Unexpected future position detected in lap 3...")
			}
			else if (A_Index = 5) {
				strategist.KnowledgeBase.setFact("Standings.Extrapolate", 20)

				strategist.KnowledgeBase.produce()

				position := strategist.KnowledgeBase.getValue("Standings.Extrapolated." . 20 . ".Car.13.Position", false)

				this.AssertEqual(4, position, "Unexpected future position detected in lap 3...")
			}

			strategist.dumpKnowledgeBase(strategist.KnowledgeBase)

			if (A_Index >= 5)
				break
		}

		strategist.finishSession(false)
	}
}

class PitstopRecommendation extends Assert {
	PitstopRecommendationTest() {
		strategist := new TestRaceStrategist(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 13\Race Strategist.settings"), false, false, false)

		loop {
			data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race 13\Race Strategist Lap " . A_Index . ".1.data")

			if (data.Count() == 0)
				break
			else
				strategist.addLap(A_Index, data)

			if (A_Index = 3) {
				strategist.KnowledgeBase.setFact("Pitstop.Strategy.Plan", true)

				strategist.KnowledgeBase.produce()

				this.AssertFalse(strategist.KnowledgeBase.getValue("Pitstop.Strategy.Lap"), "Unexpected pitstop recommmendation detected in lap 3...")
			}

			strategist.dumpKnowledgeBase(strategist.KnowledgeBase)

			if (A_Index >= 5)
				break
		}

		strategist.finishSession(false)
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

if !GetKeyState("Ctrl") {
	startTime := A_TickCount

	AHKUnit.AddTestClass(BasicReporting)
	AHKUnit.AddTestClass(PositionProjection)
	AHKUnit.AddTestClass(GapReporting)
	AHKUnit.AddTestClass(PitstopRecommendation)

	AHKUnit.Run()

	MsgBox % "Full run took " . (A_TickCount - startTime) . " ms"
}
else {
	raceNr := 17
	strategist := new TestRaceStrategist(kSimulatorConfiguration, readConfiguration(kSourcesDirectory . "Tests\Test Data\Race " . raceNr . "\Race Strategist.settings")
									   , new RaceStrategist.RaceStrategistRemoteHandler(0), "Khato", "EN", "Windows", true, true, true)

	strategist.VoiceManager.setDebug(kDebugGrammars, false)

	if (raceNr == 15) {
		done := false

		loop {
			lap := A_Index

			loop {
				data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race " . raceNr . "\Race Strategist Lap " . lap . "." . A_Index . ".data")

				if (data.Count() == 0) {
					if (A_Index == 1)
						done := true

					break
				}
				else {
					if (A_Index == 1)
						strategist.addLap(lap, data)
					else
						strategist.updateLap(lap, data)

					if isDebug()
						showMessage("Data " lap . "." . A_Index . " loaded...")
				}

				if (A_Index = 1)
					break
			}

			if (A_Index = 19) {
				strategist.performPitstop()

				MsgBox Pitstop...
			}
		} until done

		strategist.finishSession()

		while strategist.KnowledgeBase
			Sleep 1000
	}
	else if (raceNr == 16) {
		done := false

		loop {
			lap := A_Index

			loop {
				data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race " . raceNr . "\Race Strategist Lap " . lap . "." . A_Index . ".data")

				if (data.Count() == 0) {
					if (A_Index == 1)
						done := true

					break
				}
				else {
					if (A_Index == 1)
						strategist.addLap(lap, data)
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
	else if (raceNr == 17) {
		done := false

		loop {
			lap := A_Index

			loop {
				data := readConfiguration(kSourcesDirectory . "Tests\Test Data\Race " . raceNr . "\Race Strategist Lap " . lap . "." . A_Index . ".data")

				if (lap == 1 && A_Index == 1)
					strategist.prepareSession(false, data)

				if (data.Count() == 0) {
					if (lap == 82)
						done := true

					break
				}
				else {
					if (A_Index == 1)
						strategist.addLap(lap, data)
					else
						strategist.updateLap(lap, data)

					if (isDebug() && (A_Index == 1))
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
	showMessage(values2string(A_Space, args*), "Race Strategist Test", "Information.png", 500)

	return true
}