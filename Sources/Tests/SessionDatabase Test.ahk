﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Session Database Test           ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#SingleInstance Force			; Ony one instance allowed
#Warn							; Enable warnings to assist with detecting common errors.
#Warn LocalSameAsGlobal, Off

SendMode("Input")				; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir)		; Ensures a consistent starting directory.

global kBuildConfiguration := "Development"


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Database\Libraries\TyresDatabase.ahk"
#Include "AHKUnit\AHKUnit.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Private Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class DatabaseTest extends Assert {
	clearDatabase() {
		deleteDirectory(kDatabaseDirectory . "User\Unknown\TestCar")

		this.AssertEqual(true, !FileExist(kDatabaseDirectory . "User\Unknown\TestCar"), "Database has not been deleted...")
	}

	updatePressures(database, simulator, car, track, weather, airTemperature, trackTemperature, compound, compoundColor, coldPressures) {
		if !database
			database := TyresDatabase()

		for ignore, pressures in coldPressures
			database.updatePressures(simulator, car, track, weather, airTemperature, trackTemperature
								   , compound, compoundColor, pressures, [26.5, 26.5, 26.5, 26.5], false)

		database.flush()
	}
}

class PressuresAssert extends DatabaseTest {
	pressuresEqual(list1, list2) {
		if (list1.Length == list2.Length) {
			for index, value in list1
				if (Round(list2[index], 1) != Round(value, 1))
					return false

			return true
		}
		else
			return false
	}

	AssertExactResult(pressures, flPressure, frPressure, rlPressure, rrPressure) {
		this.AssertTrue(pressures != false, "Undefined pressures detected...")

		if pressures
			for tyre, pressureInfo in pressures {
				switch tyre, false {
					case "FL":
						this.AssertEqual(flPressure, pressureInfo["Pressure"], "FL pressure should be " . flPressure . "...")
					case "FR":
						this.AssertEqual(frPressure, pressureInfo["Pressure"], "FR pressure should be " . frPressure . "...")
					case "RL":
						this.AssertEqual(rlPressure, pressureInfo["Pressure"], "RL pressure should be " . rlPressure . "...")
					case "RR":
						this.AssertEqual(rrPressure, pressureInfo["Pressure"], "RR pressure should be " . rrPressure . "...")
					default:
						this.AssertEqual(true, false, "Unknown tyre type encountered...")
				}

				this.AssertEqual(0, pressureInfo["Delta Air"], "Delta Air should be 0...")
				this.AssertEqual(0, pressureInfo["Delta Track"], "Delta Track should be 0...")
			}
	}

	AssertExtrapolatedResult(pressures, flPressure, frPressure, rlPressure, rrPressure, deltaAir, deltaTrack) {
		this.AssertTrue(pressures != false, "Undefined pressures detected...")

		if pressures
			for tyre, pressureInfo in pressures {
				switch tyre, false {
					case "FL":
						this.AssertEqual(flPressure, pressureInfo["Pressure"], "FL pressure should be " . flPressure . "...")
					case "FR":
						this.AssertEqual(frPressure, pressureInfo["Pressure"], "FR pressure should be " . frPressure . "...")
					case "RL":
						this.AssertEqual(rlPressure, pressureInfo["Pressure"], "RL pressure should be " . rlPressure . "...")
					case "RR":
						this.AssertEqual(rrPressure, pressureInfo["Pressure"], "RR pressure should be " . rrPressure . "...")
					default:
						this.AssertEqual(true, false, "Unknown tyre type encountered...")
				}

				this.AssertEqual(deltaAir, pressureInfo["Delta Air"], "Delta Air should be 0...")
				this.AssertEqual(deltaTrack, pressureInfo["Delta Track"], "Delta Track should be 0...")
			}
	}

	AssertExtrapolatedValues(expCompound, compound, expCompoundColor, compoundColor, expPressures, pressures, expCertainty, certainty) {
		this.AssertEqual(expCompound, compound, "Compound should be " . expCompound . "...")
		this.AssertEqual(expCompoundColor, compoundColor, "Compound color should be " . expCompoundColor . "...")
		this.AssertEqual(expCertainty, certainty, "Certainty should be " . expCertainty . "...")
		this.AssertEqual(true, this.pressuresEqual(pressures, expPressures), "Pressures " . values2String(",", pressures*) . " do not match with " . values2String(",", expPressures*) . "...")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                              Test Section                               ;;;
;;;-------------------------------------------------------------------------;;;

class ClearDatabase extends DatabaseTest {
	Clear_Test() {
		this.clearDatabase()

		deleteDirectory(kDatabaseDirectory . "User\Unknown")
	}
}

class InitializeDatabase extends DatabaseTest {
	SimpleWritePressure_Test() {
		this.updatePressures(false, "Unknown", "TestCar", "TestTrack", "Dry", 25, 25, "Dry", "Black", [[26.1, 26.2, 26.3, 26.4]])

		this.AssertEqual(true, (FileExist(kDatabaseDirectory . "User\Unknown\TestCar\TestTrack\Tyres.Pressures.Distribution.CSV") != false), "Database file has not been created...")

		line := FileRead((kDatabaseDirectory . "User\Unknown\TestCar\TestTrack\Tyres.Pressures.Distribution.CSV"))

		this.AssertEqual(true, (line != ""), "Temperature entry has not been created...")
	}

	ExtendedWritePressure_Test() {
		pressures := [[26.1, 26.2, 26.3, 26.4], [26.2, 26.2, 26.4, 26.4], [26.2, 26.4, 26.4, 26.4], [26.3, 26.4, 26.4, 26.4]
					, [26.3, 26.5, 26.4, 26.4], [26.4, 26.5, 26.4, 26.4], [26.3, 26.5, 26.4, 26.4], [26.4, 26.6, 26.5, 26.4]]

		this.updatePressures(false, "Unknown", "TestCar", "TestTrack", "Dry", 25, 26, "Dry", "Black", pressures)

		this.AssertEqual(true, (FileExist(kDatabaseDirectory . "User\Unknown\TestCar\TestTrack\Tyres.Pressures.Distribution.CSV") != false), "Database file has not been created...")

		line := FileRead((kDatabaseDirectory . "User\Unknown\TestCar\TestTrack\Tyres.Pressures.Distribution.CSV"))

		this.AssertEqual(true, (line != ""), "Temperature entry has not been created...")
	}

	ConditionWritePressure_Test() {
		this.updatePressures(false, "Unknown", "TestCar", "TestTrack", "Drizzle", 17, 18, "Dry", "Red", [[26.5, 26.4, 26.7, 26.5]])

		this.AssertTrue(FileExist(kDatabaseDirectory . "User\Unknown\TestCar\TestTrack\Tyres.Pressures.Distribution.CSV"), "Database file has not been created...")

		line := FileRead((kDatabaseDirectory . "User\Unknown\TestCar\TestTrack\Tyres.Pressures.Distribution.CSV"))

		this.AssertEqual(true, (line != ""), "Temperature entry has not been created...")
		this.AssertTrue(InStr(line, "Drizzle") && InStr(line, "Red"), "Database file has not been created...")
		this.AssertTrue(InStr(line, "17;18;"), "Temperature entry has not been created...")
		this.AssertFalse(InStr(line, "Wet") && InStr(line, "Black"), "Unexpected temperature entry detected...")

		this.updatePressures(false, "Unknown", "TestCar", "TestTrack", "MediumRain", 17, 18, "Wet", "Black", [[26.5, 26.4, 26.7, 26.5]])

		this.AssertTrue(FileExist(kDatabaseDirectory . "User\Unknown\TestCar\TestTrack\Tyres.Pressures.Distribution.CSV"), "Database file has not been created...")

		line := FileRead((kDatabaseDirectory . "User\Unknown\TestCar\TestTrack\Tyres.Pressures.Distribution.CSV"))

		this.AssertTrue(InStr(line, "Wet") && InStr(line, "Black"), "Temperature entry has not been created...")
	}
}

class SimplePressures extends PressuresAssert {
	SimpleReadPressure_Test() {
		pressures := TyresDatabase().getPressures("Unknown", "TestCar", "TestTrack", "Dry", 25, 25, "Dry", "Black")

		this.AssertExactResult(pressures, 26.1, 26.2, 26.3, 26.4)
	}

	ExtendedReadPressure_Test() {
		this.AssertExactResult(TyresDatabase().getPressures("Unknown", "TestCar", "TestTrack", "Dry", 25, 26, "Dry", "Black"), 26.3, 26.5, 26.4, 26.4)
	}
}

class ExtrapolatedPressures extends PressuresAssert {
	ReadPressure_Test() {
		tyresDB := TyresDatabase()

		this.AssertExtrapolatedResult(tyresDB.getPressures("Unknown", "TestCar", "TestTrack", "Dry", 25, 27, "Dry", "Black"), 26.3, 26.5, 26.4, 26.4, 0, -1)
		this.AssertExtrapolatedResult(tyresDB.getPressures("Unknown", "TestCar", "TestTrack", "Dry", 25, 28, "Dry", "Black"), 26.3, 26.5, 26.4, 26.4, 0, -2)
		this.AssertExtrapolatedResult(tyresDB.getPressures("Unknown", "TestCar", "TestTrack", "Dry", 24, 26, "Dry", "Black"), 26.3, 26.5, 26.4, 26.4, 1, 0)
		this.AssertExtrapolatedResult(tyresDB.getPressures("Unknown", "TestCar", "TestTrack", "Dry", 24, 27, "Dry", "Black"), 26.3, 26.5, 26.4, 26.4, 1, -1)
		this.AssertExtrapolatedResult(tyresDB.getPressures("Unknown", "TestCar", "TestTrack", "Dry", 25, 25, "Dry", "Black"), 26.1, 26.2, 26.3, 26.4, 0, 0)
	}

	ReadSetup_Test() {
		tyresDB := TyresDatabase()

		compound := false
		compoundColor := false
		pressures := false
		certainty := false

		tyresDB.getTyreSetup("Unknown", "TestCar", "TestTrack", "Dry", 25, 25, &compound, &compoundColor, &pressures, &certainty)
		this.AssertExtrapolatedValues("Dry", compound, "Black", compoundColor, [26.1, 26.2, 26.3, 26.4], pressures, 1.0, certainty)

		tyresDB.getTyreSetup("Unknown", "TestCar", "TestTrack", "Dry", 25, 26, &compound, &compoundColor, &pressures, &certainty)
		this.AssertExtrapolatedValues("Dry", compound, "Black", compoundColor, [26.3, 26.5, 26.4, 26.4], pressures, 1.0, certainty)

		tyresDB.getTyreSetup("Unknown", "TestCar", "TestTrack", "Dry", 24, 25, &compound, &compoundColor, &pressures, &certainty)
		this.AssertExtrapolatedValues("Dry", compound, "Black", compoundColor, [26.2, 26.3, 26.4, 26.5], pressures, 0.8, certainty)

		tyresDB.getTyreSetup("Unknown", "TestCar", "TestTrack", "Dry", 24, 24, &compound, &compoundColor, &pressures, &certainty)
		this.AssertExtrapolatedValues("Dry", compound, "Black", compoundColor, [26.2, 26.3, 26.4, 26.5], pressures, 0.6, certainty)

		tyresDB.getTyreSetup("Unknown", "TestCar", "TestTrack", "Dry", 24, 23, &compound, &compoundColor, &pressures, &certainty)
		this.AssertExtrapolatedValues("Dry", compound, "Black", compoundColor, [26.2, 26.3, 26.4, 26.5], pressures, 0.4, certainty)

		tyresDB.getTyreSetup("Unknown", "TestCar", "TestTrack", "Dry", 26, 27, &compound, &compoundColor, &pressures, &certainty)
		this.AssertExtrapolatedValues("Dry", compound, "Black", compoundColor, [26.2, 26.4, 26.3, 26.3], pressures, 0.6, certainty)
	}
}

class DifferentCompoundPressures extends PressuresAssert {
	CompoundSetup_Test() {
		tyresDB := TyresDatabase()

		compound := false
		compoundColor := false
		pressures := false
		certainty := false

		tyresDB.getTyreSetup("Unknown", "TestCar", "TestTrack", "Dry", 16, 17, &compound, &compoundColor, &pressures, &certainty)
		this.AssertExtrapolatedValues("Dry", compound, "Red", compoundColor, [26.6, 26.5, 26.8, 26.6], pressures, 0.6, certainty)

		compound := false
		compoundColor := false
		pressures := false
		certainty := false

		tyresDB.getTyreSetup("Unknown", "TestCar", "TestTrack", "LightRain", 17, 17, &compound, &compoundColor, &pressures, &certainty)
		this.AssertExtrapolatedValues("Wet", compound, "Black", compoundColor, [26.5, 26.4, 26.7, 26.5], pressures, 0.8, certainty)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

AHKUnit.AddTestClass(ClearDatabase)
AHKUnit.AddTestClass(InitializeDatabase)
AHKUnit.AddTestClass(SimplePressures)
AHKUnit.AddTestClass(ExtrapolatedPressures)
AHKUnit.AddTestClass(DifferentCompoundPressures)
AHKUnit.AddTestClass(ClearDatabase)

AHKUnit.Run()
