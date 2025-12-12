;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Generic Telemetry Analyzer      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Extensions\Task.ahk"
#Include "..\..\Framework\Extensions\Math.ahk"
#Include "..\..\Database\Libraries\SessionDatabase.ahk"
#Include "..\..\Plugins\Libraries\SimulatorProvider.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; IssueCollector                                                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class IssueCollector {
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
	iSoundsDirectory := false

	iDataFile := false
	iCollectorPID := false
	iCalibrate := false

	iCategories := []

	iSampleFrequency := false
	iSampleTask := false

	iTemperatureSamples := []

	iExitCallback := false

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

	Handling {
		Get {
			return (inList(this.iCategories, "Handling") ? this.getHandling() : false)
		}
	}

	Temperatures {
		Get {
			return (inList(this.iCategories, "Temperatures") ? this.getTemperatures() : false)
		}
	}

	static AudioSettings {
		Get {
			return getAudioSettings("Analyzer")
		}
	}

	AudioSettings {
		Get {
			return IssueCollector.AudioSettings
		}
	}

	__New(simulator, car, track, settings := {}, acousticFeedback := false) {
		local setting, value

		this.iSimulator := SessionDatabase.getSimulatorName(simulator)
		this.iCar := (car ? SessionDatabase.getCarName(simulator, car) : false)
		this.iTrack := (car ? SessionDatabase.getTrackName(simulator, track) : false)

		this.iAcousticFeedback := acousticFeedback

		for setting, value in settings.OwnProps()
			if ((setting = "Handling") || ((setting = "Temperatures")))
				this.iCategories.Push(setting)
			else if (setting = "Frequency")
				this.iSampleFrequency := value
			else
				this.i%setting% := value

		this.iSoundsDirectory := temporaryFileName("Sounds")

		DirCreate(this.iSoundsDirectory)

		FileCopy(kResourcesDirectory . "Sounds\*", this.iSoundsDirectory)
		FileCopy(kUserHomeDirectory . "Sounds\*", this.iSoundsDirectory)

		OnExit((*) {
			deleteDirectory(this.iSoundsDirectory)

			return false
		})
	}

	__Delete() {
		deleteDirectory(this.iSoundsDirectory)
	}

	loadFromSettings(settings := false, section := "Settigs") {
		local defaultUndersteerThresholds := "40,70,100"
		local defaultOversteerThresholds := "-40,-70,-100"
		local defaultLowspeedThreshold := 120
		local prefix

		if !settings
			settings := readMultiMap(kUserConfigDirectory . "Issue Collector.ini")

		prefix := (this.Simulator . "." . (this.Car ? this.Car : "*") . ".*.")

		if this.settingAvailable("SteerLock", true)
			this.iSteerLock := getMultiMapValue(settings, section, prefix . "SteerLock", 900)

		if this.settingAvailable("SteerRatio", true)
			this.iSteerRatio := getMultiMapValue(settings, section, prefix . "SteerRatio", 12)

		if this.settingAvailable("Wheelbase", true)
			this.iWheelbase := getMultiMapValue(settings, section, prefix . "Wheelbase", 270)

		if this.settingAvailable("TrackWidth", true)
			this.iTrackWidth := getMultiMapValue(settings, section, prefix . "TrackWidth", 150)

		defaultUndersteerThresholds := getMultiMapValue(settings, section, prefix . "UndersteerThresholds", defaultUndersteerThresholds)
		defaultOversteerThresholds := getMultiMapValue(settings, section, prefix . "OversteerThresholds", defaultOversteerThresholds)
		defaultLowspeedThreshold := getMultiMapValue(settings, section, prefix . "LowspeedThreshold", defaultLowspeedThreshold)

		prefix := (this.Simulator . "." . (this.Car ? this.Car : "*") . "." . (this.Track ? this.Track : "*") . ".")

		if this.settingAvailable("SteerLock", true)
			this.iSteerLock := getMultiMapValue(settings, section, prefix . "SteerLock", this.SteerLock)

		if this.settingAvailable("SteerRatio", true)
			this.iSteerRatio := getMultiMapValue(settings, section, prefix . "SteerRatio", this.SteerRatio)

		if this.settingAvailable("Wheelbase", true)
			this.iWheelbase := getMultiMapValue(settings, section, prefix . "Wheelbase", this.Wheelbase)

		if this.settingAvailable("TrackWidth", true)
			this.iTrackWidth := getMultiMapValue(settings, section, prefix . "TrackWidth", this.TrackWidth)

		if this.settingAvailable("UndersteerThresholds", true)
			this.iUndersteerThresholds := string2Values(",", getMultiMapValue(settings, section
														   , prefix . "UndersteerThresholds", defaultUndersteerThresholds))

		if this.settingAvailable("OversteerThresholds", true)
			this.iOversteerThresholds := string2Values(",", getMultiMapValue(settings, section
														  , prefix . "OversteerThresholds", defaultOversteerThresholds))

		if this.settingAvailable("LowspeedThreshold", true)
			this.iLowspeedThreshold := getMultiMapValue(settings, section, prefix . "LowspeedThreshold", defaultLowspeedThreshold)
	}

	settingAvailable(setting, force := false) {
		return (force || (this.%setting% != false))
	}

	deleteSamples() {
		if this.iDataFile {
			deleteFile(this.iDataFile)

			this.iDataFile := false
		}

		this.iTemperatureSamples := []
	}

	startIssueCollector(calibrate := false) {
		local dataFile := temporaryFileName("Telemetry", "data")
		local player := requireSoundPlayer("DCAnalyzerPlayer.exe")
		local exePath, protocol, arguments, pid, options, code, message, audioDevice, workingDirectory

		collectSamples() {
			this.updateSamples()

			Task.CurrentTask.Sleep := this.iSampleFrequency
		}

		this.stopIssueCollector()
		this.deleteSamples()

		if (!this.iCollectorPID && inList(this.iCategories, "Handling")) {
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
					options .= (A_Space . "`"" . this.iSoundsDirectory . "`"")

					if this.AudioSettings {
						if kSox
							SplitPath(kSox, , &workingDirectory)
						else
							workingDirectory := A_WorkingDir

						options := (" `"" . this.AudioSettings.AudioDevice . "`" " . this.AudioSettings.Volume . (player ? (" `"" . player . "`" `"" . workingDirectory . "`"") : ""))
					}
				}

				code := SessionDatabase.getSimulatorCode(this.Simulator)

				protocol := "SHM"
				exePath := "..."

				protocol := SimulatorProvider.getProtocol(code, "Coach")

				exePath := protocol.File
				protocol := protocol.Protocol

				if !FileExist(exePath)
					throw "File not found..."

				if protocol.HasProp("Arguments")
					arguments := values2String(A_Space, collect(protocol.Arguments, (a) => ("`"" . a . "`""))*)
				else
					arguments := ""

				Run("`"" . exePath . "`" " . arguments . A_Space . options, kBinariesDirectory, "Hide", &pid)

				this.iCalibrate := calibrate
				this.iDataFile := dataFile
			}
			catch Any as exception {
				logError(exception, true)

				message := substituteVariables(translate("Cannot start %simulator% %protocol% Coach (%exePath%) - please check the configuration...")
											 , {simulator: code, protocol: protocol, exePath: exePath})

				logMessage(kLogCritical, StrReplace(message, translate("..."), ""))

				if !kSilentMode
					showMessage(message, translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

				pid := false
			}

			if pid {
				this.iCollectorPID := pid

				if !this.iExitCallback {
					this.iExitCallback := ObjBindMethod(this, "stopIssueCollector")

					OnExit(this.iExitCallback)
				}
			}

			if (!calibrate && this.iSampleFrequency) {
				this.iSampleTask := PeriodicTask(collectSamples, isDebug() ? this.iSampleFrequency : 180000, kLowPriority)

				this.iSampleTask.start()
			}
		}
	}

	stopIssueCollector(arguments*) {
		local pid := this.iCollectorPID
		local tries

		if ((arguments.Length > 0) && inList(["Logoff", "Shutdown"], arguments[1]))
			return false

		if pid {
			tries := 5

			while (tries-- > 0)
				if ProcessExist(pid) {
					ProcessClose(pid)

					Sleep(500)
				}
				else
					break

			if this.iSampleTask {
				this.iSampleTask.stop()

				this.iSampleTask := false
			}

			this.iCollectorPID := false
		}

		return false
	}

	static acousticFeedback(soundFile) {
		playSound("SWSoundPlayer.exe", soundFile, IssueCollector.AudioSettings, "echos 1 1 1 1")
	}

	getHandling() {
		local dataFile := this.iDataFile
		local handling := CaseInsenseMap()
		local handling, tries, data, ignore, type, speed, severity, where, frequency, key, value

		handling.Default := (this.iCalibrate ? false : [])

		if dataFile {
			tries := 10

			while (tries-- > 0) {
				data := readMultiMap(dataFile)

				if (data.Count > 0) {
					if this.iCalibrate {
						for ignore, type in ["Oversteer", "Understeer"]
							for ignore, speed in ["Slow", "Fast"]
								for ignore, where in ["Entry", "Apex", "Exit"] {
									value := getMultiMapValue(data, type . "." . speed, where, false)

									if value
										handling[type . ".Corner." . where . "." . speed] := value
								}
					}
					else {
						for ignore, type in ["Oversteer", "Understeer"]
							for ignore, speed in ["Slow", "Fast"]
								for ignore, where in ["Entry", "Apex", "Exit"] {
									key := (type . ".Corner." . where . "." . speed)

									for ignore, severity in ["Light", "Medium", "Heavy"] {
										frequency := getMultiMapValue(data, type . "." . speed . "." . severity, where, false)

										if frequency
											if handling.Has(key)
												handling[key].Push({Severity: severity, Frequency: frequency})
											else
												handling[key] := [{Severity: severity, Frequency: frequency}]
									}
								}
					}

					break
				}
				else
					Sleep(20)
			}
		}

		return handling
	}

	getTemperatures() {
		return this.iTemperatureSamples.Clone()
	}

	updateSamples() {
		local hasValues := false
		local data, tyreTemperatures, tyreInnerTemperatures, tyreOuterTemperatures, brakeTemperatures
		local waterTemperature, oilTemperature, sample

		if inList(this.iCategories, "Temperatures") {
			data := callSimulator(SessionDatabase.getSimulatorCode(this.Simulator))
			tyreTemperatures := string2Values(",", getMultiMapValue(data, "Car Data", "TyreTemperature", ""))
			tyreInnerTemperatures := string2Values(",", getMultiMapValue(data, "Car Data", "TyreInnerTemperature", ""))
			tyreOuterTemperatures := string2Values(",", getMultiMapValue(data, "Car Data", "TyreOuterTemperature", ""))
			brakeTemperatures := string2Values(",", getMultiMapValue(data, "Car Data", "BrakeTemperature", ""))
			waterTemperature := getMultiMapValue(data, "Car Data", "WaterTemperature", kUndefined)
			oilTemperature := getMultiMapValue(data, "Car Data", "OilTemperature", kUndefined)
			sample := {}

			if (sum(tyreTemperatures) > 0) {
				sample.TyreTemperatures := tyreTemperatures

				hasValues := true
			}

			if (sum(brakeTemperatures) > 0) {
				sample.BrakeTemperatures := brakeTemperatures

				hasValues := true
			}

			if ((tyreInnerTemperatures.Length = 4) && (tyreOuterTemperatures.Length = 4)) {
				loop 4
					tyreInnerTemperatures[A_Index] -= tyreOuterTemperatures[A_Index]

				sample.TyreOITemperatureDifferences := tyreInnerTemperatures

				hasValues := true
			}

			if (waterTemperature != kUndefined)
				sample.WaterTemperature := waterTemperature

			if (oilTemperature != kUndefined)
				sample.OilTemperature := oilTemperature

			if hasValues
				this.iTemperatureSamples.Push(sample)
		}
	}
}