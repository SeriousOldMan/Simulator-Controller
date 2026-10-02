;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - DrivingCoach Test               ;;;
;;;                                         (Driving Coach AI)              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
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
#Include "..\Assistants\Libraries\DrivingCoach.ahk"
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

class TestDrivingCoach extends DrivingCoach {
	__New(configuration, settings, remoteHandler := false, name := false, language := kUndefined, translator := kUndefined, synthesizer := false, speaker := false, vocalics := false, speakerBooster := false
		, recognizer := false, listener := false, listenerBooster := false, conversationBooster := false, agentBooster := false
		, muted := false, voiceServer := false) {
		super.__New(configuration, remoteHandler, name, language, translator, synthesizer, speaker, vocalics, speakerBooster
				  , recognizer, listener, listenerBooster, conversationBooster, agentBooster
				  , muted, voiceServer)

		this.updateConfigurationValues({Settings: settings})

		setDebug(true)
		setLogLevel(kLogDebug)

		this.setDebug(kDebugKnowledgeBase, false)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                              Test Section                               ;;;
;;;-------------------------------------------------------------------------;;;

brakeCoachingTest() {
	coach := TestDrivingCoach(kSimulatorConfiguration, readMultiMap(kUserConfigDirectory . "Race.settings")
							, false, "Peter", "EN", false, true, true, false, true, true, true, true, true, true)

	coach.updateSessionValues({Simulator: "Le Mans Ultimate"
							 , Car: "Porsche 963", Track: "Autodromo Enzo e Dino Ferrari"
							 , TrackLength: 4887, TrackType: "Circuit"})

	DirCreate(kTempDirectory . "Driving Coach\Telemetry")

	coach.iTelemetryAnalyzer := TelemetryAnalyzer(coach.Simulator, coach.Track)
	coach.iTelemetryCollector := TelemetryCollector("Internal", kTempDirectory . "Driving Coach\Telemetry"
												  , coach.Simulator, coach.Track, coach.TrackLength)

	coach.iTelemetryCollector.startup()
	coach.startupBrakeTrigger()

	while !coach.iBrakeCommand
		Sleep(1000)

	loop 10 {
		telemetry := coach.TelemetryAnalyzer.createTelemetry(A_Index, kSourcesDirectory . "Tests\Test Data\Telemetries\963-Imola.telemetry")

		coach.TelemetryAnalyzer.requireTrackSections(telemetry)

		coach.updateBrakeTrigger(telemetry, A_Index)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

brakeCoachingTest()

if isDebug()
	withBlockedWindows(MsgDlg, "Done...")

ExitApp()