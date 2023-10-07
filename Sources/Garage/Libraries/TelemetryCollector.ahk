;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Generic Telemetry Analyzer      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\Task.ahk"
#Include "..\..\Libraries\Messages.ahk"
#Include "..\..\Libraries\Math.ahk"
#Include "..\..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kClose := "close"

global kMinThreshold := -180
global kMaxThreshold := 180


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; TelemetryCollector                                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class TelemetryCollector {
	iSimulator := false
	iCar := false
	iTrack := false

	iUndersteerThresholds := false
	iOversteerThresholds := false
	iLowspeedThreshold := false

	iSteerLock := false
	iSteerRatio := false

	iWheelBase := false
	iTrackWidth := false

	iAcousticFeedback := true
	static sAudioDevice := false

	iCollectorPID := false

	Simulator {
		Get {
			return this.iSimulator
		}
	}

	Car {
		Get {
			return this.iCar
		}
	}

	Track {
		Get {
			return this.iTrack
		}
	}

	UndersteerThresholds[key?] {
		Get {
			return (isSet(key) ? this.iUndersteerThresholds[key] : this.iUndersteerThresholds)
		}
	}

	OversteerThresholds[key?] {
		Get {
			return (isSet(key) ? this.iOversteerThresholds[key] : this.iOversteerThresholds)
		}
	}

	LowspeedThreshold {
		Get {
			return this.iLowspeedThreshold
		}
	}

	SteerLock {
		Get {
			return this.iSteerLock
		}
	}

	SteerRatio {
		Get {
			return this.iSteerRatio
		}
	}

	Wheelbase {
		Get {
			return this.iWheelbase
		}
	}

	TrackWidth {
		Get {
			return this.iTrackWidth
		}
	}

	AcousticFeedback {
		Get {
			return this.iAcousticFeedback
		}
	}

	static AudioDevice {
		Get {
			return TelemetryCollector.sAudioDevice
		}
	}

	AudioDevice {
		Get {
			return TelemetryCollector.AudioDevice
		}
	}

	__New(simulator, car, track, settings := {}, acousticFeedback := false) {
		local setting, value

		static first := true

		this.iSimulator := SessionDatabase.getSimulatorName(simulator)
		this.iCar := car
		this.iTrack := track

		this.iAcousticFeedback := acousticFeedback

		for setting, value in settings.OwnProps()
			this.i%setting% := value

		if first {
			TelemetryCollector.sAudioDevice := getMultiMapValue(readMultiMap(kUserConfigDirectory . "Audio Settings.ini"), "Output", "Analyzer.AudioDevice", false)

			first := false
		}
	}

	loadFromSettings(settings := false, section := "Setup Workbench") {
		local defaultUndersteerThresholds := "40,70,100"
		local defaultOversteerThresholds := "-40,-70,-100"
		local defaultLowspeedThreshold := 120
		local prefix

		if !settings
			settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

		prefix := (this.Simulator . "." . (this.Car ? this.Car : "*") . ".*.")

		if this.settingAvailable("SteerLock")
			this.iSteerLock := getMultiMapValue(settings, section, prefix . "SteerLock", this.SteerLock)

		if this.settingAvailable("SteerRatio")
			this.iSteerRatio := getMultiMapValue(settings, section, prefix . "SteerRatio", this.SteerRatio)

		if this.settingAvailable("Wheelbase")
			this.iWheelbase := getMultiMapValue(settings, section, prefix . "Wheelbase", this.Wheelbase)

		if this.settingAvailable("TrackWidth")
			this.iTrackWidth := getMultiMapValue(settings, section, prefix . "TrackWidth", this.TrackWidth)

		defaultUndersteerThresholds := getMultiMapValue(settings, section, prefix . "UndersteerThresholds", defaultUndersteerThresholds)
		defaultOversteerThresholds := getMultiMapValue(settings, section, prefix . "OversteerThresholds", defaultOversteerThresholds)
		defaultLowspeedThreshold := getMultiMapValue(settings, section, prefix . "LowspeedThreshold", defaultLowspeedThreshold)

		prefix := (simulator . "." . (selectedCar ? selectedCar : "*") . "." . (selectedTrack ? selectedTrack : "*") . ".")

		if this.settingAvailable("SteerLock")
			this.iSteerLock := getMultiMapValue(settings, section, prefix . "SteerLock", this.SteerLock)

		if this.settingAvailable("SteerRatio")
			this.iSteerRatio := getMultiMapValue(settings, section, prefix . "SteerRatio", this.SteerRatio)

		if this.settingAvailable("Wheelbase")
			this.iWheelbase := getMultiMapValue(settings, section, prefix . "Wheelbase", this.Wheelbase)

		if this.settingAvailable("TrackWidth")
			this.iTrackWidth := getMultiMapValue(settings, section, prefix . "TrackWidth", this.TrackWidth)

		if this.settingAvailable("UndersteerThresholds")
			this.iUndersteerThresholds := string2Values(",", getMultiMapValue(settings, section
														   , prefix . "UndersteerThresholds", defaultUndersteerThresholds))

		if this.settingAvailable("OversteerThresholds")
			this.iOversteerThresholds := string2Values(",", getMultiMapValue(settings, section
														  , prefix . "OversteerThresholds", defaultOversteerThresholds))

		if this.settingAvailable("LowspeedThreshold")
			this.iLowspeedThreshold := getMultiMapValue(settings, section, prefix . "LowspeedThreshold", defaultLowspeedThreshold)
	}

	settingAvailable(setting) {
		return (this.%setting% != false)
	}

	startTelemetryCollector(dataFile, calibrate := false) {
		local pid, options, code, message

		this.stopTelemetryCollector()

		if !this.iCollectorPID {
			try {
				options := ((calibrate ? "-Calibrate `"" : "-Analyze `"") . dataFile . "`"")

				if !calibrate {
					if this.settingAvailable("UndersteerThresholds")
						options .= (A_Space . values2String(A_Space, this.UndersteerThresholds*))

					if this.settingAvailable("OversteerThresholds")
						options .= (A_Space . values2String(A_Space, this.OversteerThresholds*))
				}

				if this.settingAvailable("LowspeedThreshold")
					options .= (A_Space . this.LowspeedThreshold)

				if this.settingAvailable("SteerLock")
					options .= (A_Space . this.SteerLock)

				if this.settingAvailable("SteerRatio")
					options .= (A_Space . this.SteerRatio)

				if this.settingAvailable("Wheelbase")
					options .= (A_Space . this.Wheelbase)

				if this.settingAvailable("TrackWidth")
					options .= (A_Space . this.TrackWidth)

				if this.AcousticFeedback {
					options .= (A_Space . "`"" . kResourcesDirectory . "Sounds`"")

					if this.AudioDevice
						options .= (A_Space . "`"" . this.AudioDevice . "`"")
				}

				code := SessionDatabase.getSimulatorCode(this.Simulator)

				Run(kBinariesDirectory . code . " SHM Spotter.exe " . options, kBinariesDirectory, "Hide", &pid)
			}
			catch Any as exception {
				logError(exception, true)

				message := substituteVariables(translate("Cannot start %simulator% %protocol% Spotter (%exePath%) - please check the configuration...")													   , {simulator: code, protocol: "SHM", exePath: kBinariesDirectory . code . " SHM Spotter.exe"})

				logMessage(kLogCritical, message)

				showMessage(message, translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

				pid := false
			}

			this.iCollectorPID := pid

			OnExit(ObjBindMethod(this, "stopTelemetryCollector"))
		}
	}

	stopTelemetryCollector(*) {
		local pid := this.iCollectorPID
		local tries

		if pid {
			tries := 5

			while (tries-- > 0) {
				if ProcessExist(pid) {
					ProcessClose(pid)

					Sleep(500)
				}
				else
					break
			}

			this.iCollectorPID := false
		}

		return false
	}

	static acousticFeedback(soundFile) {
		playSound("SWSoundPlayer.exe", soundFile, (TelemetryCollector.AudioDevice ? TelemetryCollector.AudioDevice : "") . " echos 1 1 1 1")
	}
}