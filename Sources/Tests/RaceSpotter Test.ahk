;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - RaceSpotter Test                ;;;
;;;                                         (Race Spotter Rules)            ;;;
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

global kBuildConfiguration := "Production"


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Startup.ahk"
#Include "..\Framework\Extensions\RuleEngine.ahk"
#Include "..\Plugins\Libraries\SimulatorProvider.ahk"
#Include "..\Plugins\Simulator Providers.ahk"
#Include "..\Assistants\Libraries\RaceSpotter.ahk"
#Include "AHKUnit\AHKUnit.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Private Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class UnknownProvider extends SimulatorProvider {
	Simulator {
		Get {
			return "Unknown"
		}
	}

	supportsPitstop(&refuelService?, &tyreService?, &brakeService?, &repairService?) {
		refuelService := true
		tyreService := "All"
		brakeService := true
		repairService := ["Bodywork", "Suspension", "Engine"]

		return true
	}

	supportsTyreManagement(&mixedCompounds?, &tyreSets?) {
		mixedCompounds := "All"
		tyreSets := true

		return true
	}
}

class TestRaceSpotter extends RaceSpotter {
	__New(configuration, settings, remoteHandler := false, name := false, language := kUndefined, synthesizer := false, speaker := false, vocalics := false, speakerBooster := false
		, recognizer := false, listener := false, listenerBooster := false, conversationBooster := false, agentBooster := false
		, muted := false, voiceServer := false) {
		super.__New(configuration, remoteHandler, name, language, synthesizer, speaker, vocalics, speakerBooster
				  , recognizer, listener, listenerBooster, conversationBooster, agentBooster
				  , muted, voiceServer)

		this.updateConfigurationValues({Settings: settings})

		setDebug(false)

		this.setDebug(kDebugKnowledgeBase, false)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

raceNr := 23  ; (22, 23)

spotter := TestRaceSpotter(kSimulatorConfiguration, readMultiMap(kSourcesDirectory . "Tests\Test Data\Race " . raceNr . "\Race Spotter.settings")
						   , false, "Peter", "EN", true, true, false, true, true, true, true, true, true)

spotter.VoiceManager.setDebug(kDebugGrammars, false)

if (raceNr == 22) {
	done := false

	loop {
		lap := A_Index

		loop {
			data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race " . raceNr . "\Race Spotter Lap " . lap . "." . A_Index . ".data")

			if (data.Count == 0) {
				if (lap == 9)
					done := true

				break
			}
			else {
				if (A_Index == 1)
					spotter.addLap(lap, &data)
				else
					spotter.updateLap(lap, &data)

				if (A_Index == 1)
					showMessage("Data " lap . "." . A_Index . " loaded...")
			}
		}
	}
	until done
}
else if (raceNr == 23) {
	done := false

	loop {
		lap := A_Index

		loop {
			data := readMultiMap(kSourcesDirectory . "Tests\Test Data\Race " . raceNr . "\Race Spotter Lap " . lap . "." . A_Index . ".data")

			if (data.Count == 0) {
				if (lap == 37)
					done := true

				break
			}
			else {
				if (A_Index == 1)
					spotter.addLap(lap, &data)
				else
					spotter.updateLap(lap, &data)

				if (A_Index == 1)
					showMessage("Data " lap . "." . A_Index . " loaded...")
			}
		}
	}
	until done
}

if isDebug()
	withBlockedWindows(MsgBox, "Done...")

ExitApp()

show(context, args*) {
	showMessage(values2string(A_Space, args*), "Race Spotter Test", "Information.ico", 2500)

	return true
}