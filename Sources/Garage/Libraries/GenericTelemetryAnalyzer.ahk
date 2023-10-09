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
#Include "TelemetryCollector.ahk"


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
;;; GenericTelemetryAnalyzer                                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class GenericTelemetryAnalyzer extends TelemetryAnalyzer {
	iCar := false
	iTrack := false

	iUndersteerThresholds := [40, 70, 100]
	iOversteerThresholds := [-40, -70, -100]
	iLowspeedThreshold := 120

	iSteerLock := 900
	iSteerRatio := 12

	iWheelBase := 270
	iTrackWidth := 150

	iFrontTyreTemperatures := [70, 80, 95]
	iRearTyreTemperatures := [70, 80, 95]

	iOITemperatureDifference := 10

	iFrontBrakeTemperatures := [300, 550, 680]
	iRearBrakeTemperatures := [300, 550, 680]

	iAcousticFeedback := true
	static sAudioDevice := false

	iTelemetryCollector := false
	iLastHandling := false
	iLastTemperatures := false

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

	CollectorClass {
		Get {
			return "TelemetryCollector"
		}
	}

	UndersteerThresholds[key?] {
		Get {
			return (isSet(key) ? this.iUndersteerThresholds[key] : this.iUndersteerThresholds)
		}

		Set {
			if isSet(key) {
				this.iUndersteerThresholds[key] := value

				setAnalyzerSetting(this, "UndersteerThresholds", values2String(",", this.iUndersteerThresholds*))

				return value
			}
			else {
				setAnalyzerSetting(this, "UndersteerThresholds", values2String(",", value*))

				return (this.iUndersteerThresholds := value)
			}
		}
	}

	OversteerThresholds[key?] {
		Get {
			return (isSet(key) ? this.iOversteerThresholds[key] : this.iOversteerThresholds)
		}

		Set {
			if isSet(key) {
				this.iOversteerThresholds[key] := value

				setAnalyzerSetting(this, "OversteerThresholds", values2String(",", this.iOversteerThresholds*))

				return value
			}
			else {
				setAnalyzerSetting(this, "OversteerThresholds", values2String(",", value*))

				return (this.iOversteerThresholds := value)
			}
		}
	}

	LowspeedThreshold {
		Get {
			return this.iLowspeedThreshold
		}

		Set {
			setAnalyzerSetting(this, "LowspeedThreshold", value)

			return (this.iLowspeedThreshold := value)
		}
	}

	SteerLock {
		Get {
			return this.iSteerLock
		}

		Set {
			setAnalyzerSetting(this, "SteerLock", value)

			return (this.iSteerLock := value)
		}
	}

	SteerRatio {
		Get {
			return this.iSteerRatio
		}

		Set {
			setAnalyzerSetting(this, "SteerRatio", value)

			return (this.iSteerRatio := value)
		}
	}

	Wheelbase {
		Get {
			return this.iWheelbase
		}

		Set {
			setAnalyzerSetting(this, "Wheelbase", value)

			return (this.iWheelbase := value)
		}
	}

	TrackWidth {
		Get {
			return this.iTrackWidth
		}

		Set {
			setAnalyzerSetting(this, "TrackWidth", value)

			return (this.iTrackWidth := value)
		}
	}

	FrontTyreTemperatures[key?] {
		Get {
			return (isSet(key) ? this.iFrontTyreTemperatures[key] : this.iFrontTyreTemperatures)
		}

		Set {
			if isSet(key) {
				this.iFrontTyreTemperatures[key] := value

				setAnalyzerSetting(this, "FrontTyreTemperatures", values2String(",", this.iFrontTyreTemperatures*))

				return value
			}
			else {
				setAnalyzerSetting(this, "FrontTyreTemperatures", values2String(",", value*))

				return (this.iFrontTyreTemperatures := value)
			}
		}
	}

	RearTyreTemperatures[key?] {
		Get {
			return (isSet(key) ? this.iRearTyreTemperatures[key] : this.iRearTyreTemperatures)
		}

		Set {
			if isSet(key) {
				this.iRearTyreTemperatures[key] := value

				setAnalyzerSetting(this, "RearTyreTemperatures", values2String(",", this.iRearTyreTemperatures*))

				return value
			}
			else {
				setAnalyzerSetting(this, "RearTyreTemperatures", values2String(",", value*))

				return (this.iRearTyreTemperatures := value)
			}
		}
	}

	OITemperatureDifference {
		Get {
			return this.iOITemperatureDifference
		}

		Set {
			setAnalyzerSetting(this, "TyreOITemperatureDifference", value)

			return (this.iOITemperatureDifference := value)
		}
	}

	FrontBrakeTemperatures[key?] {
		Get {
			return (isSet(key) ? this.iFrontBrakeTemperatures[key] : this.iFrontBrakeTemperatures)
		}

		Set {
			if isSet(key) {
				this.iFrontBrakeTemperatures[key] := value

				setAnalyzerSetting(this, "FrontBrakeTemperatures", values2String(",", this.iFrontBrakeTemperatures*))

				return value
			}
			else {
				setAnalyzerSetting(this, "FrontBrakeTemperatures", values2String(",", value*))

				return (this.iFrontBrakeTemperatures := value)
			}
		}
	}

	RearBrakeTemperatures[key?] {
		Get {
			return (isSet(key) ? this.iRearBrakeTemperatures[key] : this.iRearBrakeTemperatures)
		}

		Set {
			if isSet(key) {
				this.iRearBrakeTemperatures[key] := value

				setAnalyzerSetting(this, "RearBrakeTemperatures", values2String(",", this.iRearBrakeTemperatures*))

				return value
			}
			else {
				setAnalyzerSetting(this, "RearBrakeTemperatures", values2String(",", value*))

				return (this.iRearBrakeTemperatures := value)
			}
		}
	}

	AcousticFeedback {
		Get {
			return this.iAcousticFeedback
		}

		Set {
			setAnalyzerSetting(this, "Feedback", value)

			return (this.iAcousticFeedback := value)
		}
	}

	static AudioDevice {
		Get {
			return GenericTelemetryAnalyzer.sAudioDevice
		}
	}

	AudioDevice {
		Get {
			return GenericTelemetryAnalyzer.AudioDevice
		}
	}

	Handling {
		Get {
			if this.iTelemetryCollector
				return (this.iLastHandling := this.iTelemetryCollector.Handling)
			else if !this.iLastHandling {
				this.iLastHandling := CaseInsenseMap()
				this.iLastHandling.Default := []
			}

			return this.iLastHandling
		}
	}

	Temperatures {
		Get {
			if this.iTelemetryCollector
				this.iLastTemperatures := this.iTelemetryCollector.Temperatures
			else if !this.iLastTemperatures
				this.iLastTemperatures := []

			return this.computeTemperatures(this.iLastTemperatures)
		}
	}

	__New(workbench, simulator) {
		local selectedCar := workbench.SelectedCar[false]
		local selectedTrack := workbench.SelectedTrack[false]
		local defaultUndersteerThresholds := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "UndersteerThresholds", "40,70,100")
		local defaultOversteerThresholds := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "OversteerThresholds", "-40,-70,-100")
		local defaultLowspeedThreshold := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "LowspeedThreshold", 120)
		local defaultFrontTyreTemperatures := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "FrontTyreTemperatures", "70,80,95")
		local defaultRearTyreTemperatures := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "RearTyreTemperatures", "70,80,95")
		local defaultOITemperatureDifference := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "TyreOITemperatureDifference", 10)
		local defaultFrontBrakeTemperatures := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "FrontBrakeTemperatures", "300,550,680")
		local defaultRearBrakeTemperatures := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "RearBrakeTemperatures", "300,550,680")
		local fileName, configuration, settings, prefix

		static first := true

		simulator := SessionDatabase.getSimulatorName(simulator)

		if (selectedCar == true)
			selectedCar := false

		if (selectedTrack == true)
			selectedTrack := false

		this.iCar := selectedCar
		this.iTrack := selectedTrack

		this.iSteerLock := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "SteerLock", 900)
		this.iSteerRatio := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "SteerRatio", 12)
		this.iWheelbase := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "Wheelbase", 270)
		this.iTrackWidth := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "TrackWidth", 150)

		if selectedCar {
			fileName := getFileName("Garage\Definitions\Cars\" . simulator . "." . selectedCar . ".ini", kResourcesDirectory, kUserHomeDirectory)

			if FileExist(fileName) {
				configuration := readMultiMap(fileName)

				this.iSteerLock := getMultiMapValue(configuration, "Setup.General", "SteerLock", this.SteerLock)
				this.iSteerRatio := getMultiMapValue(configuration, "Setup.General", "SteerRatio", this.SteerRatio)
				this.iWheelbase := getMultiMapValue(configuration, "Setup.General", "Wheelbase", this.Wheelbase)
				this.iTrackWidth := getMultiMapValue(configuration, "Setup.General", "TrackWidth", this.TrackWidth)

				defaultUndersteerThresholds := getMultiMapValue(configuration, "Analyzer", "UndersteerThresholds", defaultUndersteerThresholds)
				defaultOversteerThresholds := getMultiMapValue(configuration, "Analyzer", "OversteerThresholds", defaultOversteerThresholds)
				defaultLowspeedThreshold := getMultiMapValue(configuration, "Analyzer", "LowspeedThreshold", defaultLowspeedThreshold)

				defaultFrontTyreTemperatures := getMultiMapValue(configuration, "Analyzer", "FrontTyreTemperatures", defaultFrontTyreTemperatures)
				defaultRearTyreTemperatures := getMultiMapValue(configuration, "Analyzer", "RearTyreTemperatures", defaultRearTyreTemperatures)
				defaultOITemperatureDifference := getMultiMapValue(configuration, "Analyzer", "TyreOITemperatureDifference", defaultOITemperatureDifference)
				defaultFrontBrakeTemperatures := getMultiMapValue(configuration, "Analyzer", "FrontBrakeTemperatures", defaultFrontBrakeTemperatures)
				defaultRearBrakeTemperatures := getMultiMapValue(configuration, "Analyzer", "RearBrakeTemperatures", defaultRearBrakeTemperatures)
			}
		}

		settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

		prefix := (simulator . "." . (selectedCar ? selectedCar : "*") . ".*.")

		this.iSteerLock := getMultiMapValue(settings, "Setup Workbench", prefix . "SteerLock", this.SteerLock)
		this.iSteerRatio := getMultiMapValue(settings, "Setup Workbench", prefix . "SteerRatio", this.SteerRatio)
		this.iWheelbase := getMultiMapValue(settings, "Setup Workbench", prefix . "Wheelbase", this.Wheelbase)
		this.iTrackWidth := getMultiMapValue(settings, "Setup Workbench", prefix . "TrackWidth", this.TrackWidth)
		this.iAcousticFeedback := getMultiMapValue(settings, "Setup Workbench", prefix . "Feedback", true)

		defaultUndersteerThresholds := getMultiMapValue(settings, "Setup Workbench", prefix . "UndersteerThresholds", defaultUndersteerThresholds)
		defaultOversteerThresholds := getMultiMapValue(settings, "Setup Workbench", prefix . "OversteerThresholds", defaultOversteerThresholds)
		defaultLowspeedThreshold := getMultiMapValue(settings, "Setup Workbench", prefix . "LowspeedThreshold", defaultLowspeedThreshold)

		prefix := (simulator . "." . (selectedCar ? selectedCar : "*") . "." . (selectedTrack ? selectedTrack : "*") . ".")

		this.iSteerLock := getMultiMapValue(settings, "Setup Workbench", prefix . "SteerLock", this.SteerLock)
		this.iSteerRatio := getMultiMapValue(settings, "Setup Workbench", prefix . "SteerRatio", this.SteerRatio)
		this.iWheelbase := getMultiMapValue(settings, "Setup Workbench", prefix . "Wheelbase", this.Wheelbase)
		this.iTrackWidth := getMultiMapValue(settings, "Setup Workbench", prefix . "TrackWidth", this.TrackWidth)
		this.iAcousticFeedback := getMultiMapValue(settings, "Setup Workbench", prefix . "Feedback", this.AcousticFeedback)

		this.iUndersteerThresholds := string2Values(",", getMultiMapValue(settings, "Setup Workbench"
													   , prefix . "UndersteerThresholds", defaultUndersteerThresholds))
		this.iOversteerThresholds := string2Values(",", getMultiMapValue(settings, "Setup Workbench"
													  , prefix . "OversteerThresholds", defaultOversteerThresholds))
		this.iLowspeedThreshold := getMultiMapValue(settings, "Setup Workbench", prefix . "LowspeedThreshold", defaultLowspeedThreshold)

		this.iFrontTyreTemperatures := string2Values(",", getMultiMapValue(settings, "Setup Workbench"
													    , prefix . "FrontTyreTemperatures", defaultFrontTyreTemperatures))
		this.iRearTyreTemperatures := string2Values(",", getMultiMapValue(settings, "Setup Workbench"
													   , prefix . "RearTyreTemperatures", defaultRearTyreTemperatures))
		this.iOITemperatureDifference := getMultiMapValue(settings, "Setup Workbench", prefix . "TyreOITemperatureDifference", defaultOITemperatureDifference)

		this.iFrontBrakeTemperatures := string2Values(",", getMultiMapValue(settings, "Setup Workbench"
														 , prefix . "FrontBrakeTemperatures", defaultFrontBrakeTemperatures))
		this.iRearBrakeTemperatures := string2Values(",", getMultiMapValue(settings, "Setup Workbench"
														, prefix . "RearBrakeTemperatures", defaultRearBrakeTemperatures))

		super.__New(workbench, simulator)

		OnExit(ObjBindMethod(this, "stopTelemetryAnalyzer", true))

		if first {
			GenericTelemetryAnalyzer.sAudioDevice := getMultiMapValue(readMultiMap(kUserConfigDirectory . "Audio Settings.ini"), "Output", "Analyzer.AudioDevice", false)

			registerMessageHandler("Analyzer", methodMessageHandler, GenericTelemetryAnalyzer)

			first := false
		}
	}

	settingAvailable(setting) {
		return true
	}

	createCharacteristics(issues := false) {
		local workbench, severities, maxFrequency
		local characteristicLabels, characteristic, characteristics, ignore, type, severity, speed, where, value, issue
		local temperature, position, category

		if issues {
			workbench := this.Workbench
			characteristicLabels := getMultiMapValues(workbench.Definition, "Workbench.Characteristics.Labels")
			severities := CaseInsenseMap("Light", 33, "Medium", 50, "Heavy", 66)
			characteristics := CaseInsenseMap()
			maxFrequency := 0

			workbench.clearCharacteristics()

			workbench.ProgressCount := 0

			showProgress({color: "Green", width: 350, title: translate("Creating Problems"), message: translate("Preparing Characteristics...")})

			for ignore, type in ["Oversteer", "Understeer"]
				for ignore, speed in ["Slow", "Fast"]
					for ignore, where in ["Entry", "Apex", "Exit"]
						for ignore, issue in issues[type . ".Corner." . where . "." . speed]
							maxFrequency := Max(maxFrequency, issue.Frequency)

			for ignore, type in ["Oversteer", "Understeer"]
				for ignore, speed in ["Slow", "Fast"]
					for ignore, where in ["Entry", "Apex", "Exit"] {
						characteristic := (type . ".Corner." . where . "." . speed)

						for ignore, issue in issues[characteristic] {
							value := issue.Frequency
							severity := issue.Severity

							if !characteristics.Has(characteristic)
								characteristics[characteristic] := [Round(value / maxFrequency * 66), severities[severity]]
							else {
								characteristic := characteristics[characteristic]

								characteristic[1] := Max(characteristic[1], Round(value / maxFrequency * 66))
								characteristic[2] := Max(characteristic[2], severities[severity])
							}
						}
					}

			maxFrequency := 0

			for ignore, category in ["Around", "Inner", "Outer"]
				for ignore, temperature in ["Cold", "Hot"]
					for ignore, position in ["Front", "Rear"]
						for ignore, issue in issues["Tyre.Temperatures." . temperature . "." . position . "." . category]
							maxFrequency := Max(maxFrequency, issue.Frequency)

			for ignore, category in ["Around", "Inner", "Outer"]
				for ignore, temperature in ["Cold", "Hot"]
					for ignore, position in ["Front", "Rear"] {
						characteristic := ("Tyre.Temperatures." . temperature . "." . position . "." . category)

						for ignore, issue in issues[characteristic] {
							value := issue.Frequency
							severity := issue.Severity

							if !characteristics.Has(characteristic)
								characteristics[characteristic] := [Round(value / maxFrequency * 66), severities[severity]]
							else {
								characteristic := characteristics[characteristic]

								characteristic[1] := Max(characteristic[1], Round(value / maxFrequency * 66))
								characteristic[2] := Max(characteristic[2], severities[severity])
							}
						}
					}

			maxFrequency := 0

			for ignore, category in ["Front", "Rear"]
				for ignore, issue in issues["Brake.Temperatures." . category]
					maxFrequency := Max(maxFrequency, issue.Frequency)

			for ignore, category in ["Front", "Rear"] {
				characteristic := ("Brake.Temperatures." . category)

				for ignore, issue in issues[characteristic] {
					value := issue.Frequency
					severity := issue.Severity

					if !characteristics.Has(characteristic)
						characteristics[characteristic] := [Round(value / maxFrequency * 66), severities[severity]]
					else {
						characteristic := characteristics[characteristic]

						characteristic[1] := Max(characteristic[1], Round(value / maxFrequency * 66))
						characteristic[2] := Max(characteristic[2], severities[severity])
					}
				}
			}

			Sleep(500)

			for characteristic, value in characteristics {
				if (A_Index > kMaxCharacteristics)
					break

				showProgress({progress: (workbench.ProgressCount += 10), message: translate("Create ") . characteristicLabels[characteristic] . translate("...")})

				workbench.addCharacteristic(characteristic, value[1], value[2], false)
			}

			workbench.updateRecommendations()

			workbench.updateState()

			showProgress({progress: 100, message: translate("Finished...")})

			Sleep(500)

			hideProgress()
		}
		else {
			issues := runAnalyzer(this)

			if issues
				Task.startTask(ObjBindMethod(this, "createCharacteristics", issues), 100)
		}
	}

	startTelemetryAnalyzer(calibrate := false) {
		local settings := {Handling: true, Temperatures: true, Frequency: 2000}
		local ignore, setting

		this.stopTelemetryAnalyzer()

		if !this.iTelemetryCollector {
			if !calibrate
				for ignore, setting in ["UndersteerThresholds", "OversteerThresholds"]
					if this.settingAvailable(setting)
						settings.%setting% := this.%setting%

			for ignore, setting in ["LowSpeedThreshold", "SteerLock", "SteerRatio", "WheelBase", "TrackWidth"]
				if this.settingAvailable(setting)
					settings.%setting% := this.%setting%

			this.iTelemetryCollector := %this.CollectorClass%(this.Simulator, this.Car, this.Track, settings, this.AcousticFeedback)

			this.iTelemetryCollector.startTelemetryCollector(calibrate)
		}

		return this.iTelemetryCollector
	}

	stopTelemetryAnalyzer(*) {
		local collector := this.iTelemetryCollector

		if collector {
			this.iLastHandling := collector.Handling

			collector.stopTelemetryCollector()
		}

		this.iTelemetryCollector := false
	}

	computeTemperatures(samples) {
		local count := samples.Length
		local tyreTemperatures := [[], [], [], []]
		local brakeTemperatures := [[], [], [], []]
		local tyreOITemperatureDifferences := [[], [], [], []]
		local issues := CaseInsenseMap()

		getTemperatures(category, temperatures) {
			local ignore, sample

			for ignore, sample in samples
				loop 4
					temperatures[A_Index].Push(sample.%category%Temperatures[A_Index])
		}

		getOIDifferences() {
			local ignore, sample, tyre, index

			for ignore, sample in samples
				if sample.HasProp("TyreOITemperatureDifferences")
					loop 4
						tyreOITemperatureDifferences[A_Index].Push(sample.TyreOITemperatureDifferences[A_Index])
		}

		computeTyreIssues(category, tyres, minThreshold, maxThreshold, idealValue) {
			local coldHeavy := 0
			local hotHeavy := 0
			local coldMedium := 0
			local hotMedium := 0
			local coldLight := 0
			local hotLight := 0
			local difference, ignore, tyre, value, temperature, type, key

			for ignore, tyre in tyres
				for ignore, value in tyreTemperatures[tyre] {
					difference := (value - idealValue)

					if (value < minThreshold)
						coldHeavy += 1
					else if (value > maxThreshold)
						hotHeavy += 1
					else if ((difference < 0) && (Abs(difference) > (Abs(idealValue - minThreshold) / 4 * 3)))
						coldMedium += 1
					else if ((difference > 0) && (Abs(difference) > (Abs(idealValue - maxThreshold) / 4 * 3)))
						hotMedium += 1
					else if ((difference < 0) && (Abs(difference) > (Abs(idealValue - minThreshold) / 2)))
						coldLight += 1
					else if ((difference > 0) && (Abs(difference) > (Abs(idealValue - maxThreshold) / 2)))
						hotLight += 1
				}

			for ignore, temperature in ["Cold", "Hot"] {
				key := ("Tyre.Temperatures." . temperature . "." . category . ".Around")

				for ignore, type in ["Heavy", "Medium", "Light"] {
					%temperature%%type% /= 2

					if %temperature%%type%
						if issues.Has(key)
							issues[key].Push({Severity: type, Frequency: Round(%temperature%%type% / count * 100)})
						else
							issues[key] := [{Severity: type, Frequency: Round(%temperature%%type% / count * 100)}]
				}
			}
		}

		computeOIIssues(category, tyres, oiThreshold) {
			local overInner := 0
			local overOuter := 0
			local ignore, tyre, value, type, key, severity

			getSeverity(key) {
				local severity := 0
				local ignore, issue

				if issues.Has(key)
					for ignore, issue in issues[key]
						severity := Max(severity, inList(["Light", "Medium", "Heavy"], issue.Severity))

				return (severity ? ["Light", "Medium", "Heavy"][severity] : false)
			}

			for ignore, tyre in tyres
				for ignore, value in tyreOITemperatureDifferences[tyre]
					if (Abs(value) > oiThreshold)
						if (value < 0)
							overOuter += 1
						else
							overInner += 1

			for ignore, temperature in ["Cold", "Hot"]
				for ignore, type in ["Inner", "Outer"] {
					over%type% /= 2

					if over%type% {
						key := ("Tyre.Temperatures." . temperature . "." . category . "." . type)

						severity := getSeverity("Tyre.Temperatures." . temperature . "." . category . ".Around")

						if severity
							if issues.Has(key)
								issues[key].Push({Severity: severity, Frequency: Round(over%type% / count * 100)})
							else
								issues[key] := [{Severity: severity, Frequency: Round(over%type% / count * 100)}]
					}
				}
		}

		computeBrakeIssues(category, positions, minThreshold, maxThreshold, idealValue) {
			local coldHeavy, hotHeavy, coldMedium, hotMedium, coldLight, hotLight, difference
			local ignore, position, value, key, type

			coldHeavy := 0
			hotHeavy := 0
			coldMedium := 0
			hotMedium := 0
			coldLight := 0
			hotLight := 0

			for ignore, position in positions
				for ignore, value in brakeTemperatures[position] {
					difference := (value - idealValue)

					if (value < minThreshold)
						coldHeavy += 1
					else if (value > maxThreshold)
						hotHeavy += 1
					else if ((difference < 0) && (Abs(difference) > (Abs(idealValue - minThreshold) / 4 * 3)))
						coldMedium += 1
					else if ((difference > 0) && (Abs(difference) > (Abs(idealValue - maxThreshold) / 4 * 3)))
						hotMedium += 1
					else if ((difference < 0) && (Abs(difference) > (Abs(idealValue - minThreshold) / 2)))
						coldLight += 1
					else if ((difference > 0) && (Abs(difference) > (Abs(idealValue - maxThreshold) / 2)))
						hotLight += 1
				}

			for ignore, temperature in ["Hot"] {
				key := ("Brake.Temperatures." . category)

				for ignore, type in ["Heavy", "Medium", "Light"] {
					%temperature%%type% /= 2

					if %temperature%%type%
						if issues.Has(key)
							issues[key].Push({Severity: type, Frequency: Round(%temperature%%type% / count * 100)})
						else
							issues[key] := [{Severity: type, Frequency: Round(%temperature%%type% / count * 100)}]
				}
			}
		}

		issues.Default := []

		getTemperatures("Tyre", tyreTemperatures)

		computeTyreIssues("Front", [1, 2], this.FrontTyreTemperatures[1], this.FrontTyreTemperatures[3], this.FrontTyreTemperatures[2])
		computeTyreIssues("Rear", [3, 4], this.RearTyreTemperatures[1], this.RearTyreTemperatures[3], this.RearTyreTemperatures[2])

		getOIDifferences()

		computeOIIssues("Front", [1, 2], this.OITemperatureDifference)
		computeOIIssues("Rear", [3, 4], this.OITemperatureDifference)

		getTemperatures("Brake", brakeTemperatures)

		computeBrakeIssues("Front", [1, 2], this.FrontBrakeTemperatures[1], this.FrontBrakeTemperatures[3], this.FrontBrakeTemperatures[2])
		computeBrakeIssues("Rear", [3, 4], this.RearBrakeTemperatures[1], this.RearBrakeTemperatures[3], this.RearBrakeTemperatures[2])

		return issues
	}

}

;;;-------------------------------------------------------------------------;;;
;;;                        Private Function Section                         ;;;
;;;-------------------------------------------------------------------------;;;

setAnalyzerSetting(analyzer, key, value) {
	local car := analyzer.Car
	local track := analyzer.Track
	local prefix := (analyzer.Simulator . "." . (car ? car : "*") . "." . (track ? track : "*") . ".")
	local settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

	setMultiMapValue(settings, "Setup Workbench", prefix . key, value)

	writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)
}

runAnalyzer(commandOrAnalyzer := false, arguments*) {
	local x, y, ignore, widget, workbench, row, include
	local issues, filteredHandling, issue, temperatures, type, speed, severity, where, value, newValue, frequency
	local characteristic, characteristicLabels, fromEdit
	local calibration, theListView, chosen, tabView
	local category, temperature, position, key

	static analyzerGui

	static activateButton
	static calibrateButton

	static steerLockEdit
	static steerRatioEdit
	static wheelbaseEdit
	static trackWidthEdit
	static lowspeedThresholdEdit
	static heavyOversteerThresholdSlider
	static mediumOversteerThresholdSlider
	static lightOversteerThresholdSlider
	static heavyUndersteerThresholdSlider
	static mediumUndersteerThresholdSlider
	static lightUndersteerThresholdSlider
	static heavyOversteerThresholdEdit
	static mediumOversteerThresholdEdit
	static lightOversteerThresholdEdit
	static heavyUndersteerThresholdEdit
	static mediumUndersteerThresholdEdit
	static lightUndersteerThresholdEdit

	static acousticFeedbackDropDown

	static minFrontTyreTemperatureEdit
	static maxFrontTyreTemperatureEdit
	static idealFrontTyreTemperatureEdit
	static minRearTyreTemperatureEdit
	static maxRearTyreTemperatureEdit
	static idealRearTyreTemperatureEdit
	static maxOITemperatureDifferenceEdit

	static minFrontBrakeTemperatureEdit
	static maxFrontBrakeTemperatureEdit
	static idealFrontBrakeTemperatureEdit
	static minRearBrakeTemperatureEdit
	static maxRearBrakeTemperatureEdit
	static idealRearBrakeTemperatureEdit

	static issuesListView

	static resultListView
	static applyThresholdSlider

	static result := false
	static analyzer := false
	static state := "Prepare"

	static prepareWidgets := []
	static runWidgets := []
	static analyzeWidgets := []

	static updateTask := false

	validateTemperature(field, *) {
		local value := internalValue("Float", field.Text)

		if (!isNumber(value) || (value <= 0)) {
			field.Text := (field.HasProp("ValidText") ? field.ValidText : "")

			loop 10
				SendInput("{Right}")
		}
		else
			field.ValidText := field.Text
	}

	createTemperatureUpdater(name, widgets) {
		local ignore, widget

		updateTemperature(widget, *) {
			validateTemperature(widget)

			analyzer.%name% := [convertUnit("Temperature", internalValue("Float", widgets[1].Text))
							  , convertUnit("Temperature", internalValue("Float", widgets[2].Text))
							  , convertUnit("Temperature", internalValue("Float", widgets[3].Text))]
		}

		for ignore, widget in widgets
			widget.OnEvent("Change", updateTemperature.Bind(widget))
	}

	updateTemperature(name, widget, *) {
		validateTemperature(widget)

		analyzer.%name% := convertUnit("Temperature", internalValue("Float", widget.Text))
	}

	noSelect(listView, *) {
		loop listView.GetCount()
			listView.Modify(A_Index, "-Select")
	}

	if (commandOrAnalyzer == kCancel) {
		if updateTask
			updateTask.stop()

		analyzer.stopTelemetryAnalyzer()

		result := kCancel
	}
	else if (commandOrAnalyzer == "UpdateSlider") {
		fromEdit := ((arguments.Length > 0) && arguments[1])

		for ignore, type in ["Oversteer", "Understeer"]
			for ignore, severity in ["Light", "Medium", "Heavy"] {
				if fromEdit {
					value := %severity . type . "ThresholdEdit"%.Text

					if !isInteger(value) {
						%severity . type . "ThresholdEdit"%.Text := 0
						value := 0
					}

					newValue := Min(Max(value, kMinThreshold), kMaxThreshold)

					%severity . type . "ThresholdSlider"%.Value := newValue

					if (newValue != value)
						%severity . type . "ThresholdEdit"%.Text := newValue
				}
				else
					%severity . type . "ThresholdEdit"%.Text := %severity . type . "ThresholdSlider"%.Value
			}
	}
	else if (commandOrAnalyzer == "Calibrate") {
		analyzerGui.Block()

		try {
			calibration := runCalibrator(analyzer, analyzerGui)

			if calibration {
				analyzer.UnderSteerThresholds := calibration[1]
				analyzer.OverSteerThresholds := calibration[2]

				heavyOversteerThresholdSlider.Value := analyzer.OversteerThresholds[3]
				heavyOversteerThresholdEdit.Text := analyzer.OversteerThresholds[3]
				mediumOversteerThresholdSlider.Value := analyzer.OversteerThresholds[2]
				mediumOversteerThresholdEdit.Text := analyzer.OversteerThresholds[2]
				lightOversteerThresholdSlider.Value := analyzer.OversteerThresholds[1]
				lightOversteerThresholdEdit.Text := analyzer.OversteerThresholds[1]
				lightUndersteerThresholdSlider.Value := analyzer.UndersteerThresholds[1]
				lightUndersteerThresholdEdit.Text := analyzer.UndersteerThresholds[1]
				mediumUndersteerThresholdSlider.Value := analyzer.UndersteerThresholds[2]
				mediumUndersteerThresholdEdit.Text := analyzer.UndersteerThresholds[2]
				heavyUndersteerThresholdSlider.Value := analyzer.UndersteerThresholds[3]
				heavyUndersteerThresholdEdit.Text := analyzer.UndersteerThresholds[3]
			}
		}
		finally {
			analyzerGui.Unblock()
		}
	}
	else if ((commandOrAnalyzer == "Activate") && (state = "Prepare")) {
		calibrateButton.Enabled := false

		if analyzer.settingAvailable("SteerLock")
			analyzer.SteerLock := steerLockEdit.Text

		if analyzer.settingAvailable("SteerRatio")
			analyzer.SteerRatio := steerRatioEdit.Text

		if analyzer.settingAvailable("Wheelbase")
			analyzer.Wheelbase := wheelbaseEdit.Text

		if analyzer.settingAvailable("TrackWidth")
			analyzer.TrackWidth := trackWidthEdit.Text

		if analyzer.settingAvailable("LowspeedThreshold")
			analyzer.LowspeedThreshold := lowspeedThresholdEdit.Text

		if analyzer.settingAvailable("OversteerThresholds")
			analyzer.OversteerThresholds := [lightOversteerThresholdSlider.Value, mediumOversteerThresholdSlider.Value, heavyOversteerThresholdSlider.Value]

		if analyzer.settingAvailable("UndersteerThresholds")
			analyzer.UndersteerThresholds := [lightUndersteerThresholdSlider.Value, mediumUndersteerThresholdSlider.Value, heavyUndersteerThresholdSlider.Value]

		analyzer.AcousticFeedback := ((acousticFeedbackDropDown.Value = 1) ? true : false)

		for ignore, widget in prepareWidgets {
			widget.Enabled := false
			widget.Visible := false
		}

		for ignore, widget in runWidgets
			widget.Visible := true

		activateButton.Text := translate("Stop")

		state := "Run"

		analyzer.startTelemetryAnalyzer()

		updateTask := PeriodicTask(runAnalyzer.Bind("UpdateSamples"), 5000)

		updateTask.start()
	}
	else if ((commandOrAnalyzer == "Activate") && (state = "Run")) {
		updateTask.stop()

		updateTask := false

		analyzer.stopTelemetryAnalyzer()

		for ignore, widget in runWidgets {
			widget.Enabled := false
			widget.Visible := false
		}

		for ignore, widget in analyzeWidgets
			widget.Visible := true

		activateButton.Text := translate("Apply")

		state := "Analyze"

		runAnalyzer("UpdateTelemetry", runAnalyzer("FilterHandling"), runAnalyzer("FilterTemperatures"))
	}
	else if (commandOrAnalyzer == "Threshold")
		runAnalyzer("UpdateTelemetry", runAnalyzer("FilterHandling"), runAnalyzer("FilterTemperatures"))
	else if (commandOrAnalyzer == "UpdateSamples")
		runAnalyzer("UpdateTelemetry", analyzer.Handling, analyzer.Temperatures)
	else if (commandOrAnalyzer == "FilterHandling") {
		workbench := analyzer.Workbench
		characteristicLabels := getMultiMapValues(workbench.Definition, "Workbench.Characteristics.Labels")
		final := ((arguments.Length > 0) && arguments[1])

		issues := analyzer.Handling.Clone()

		for ignore, type in ["Oversteer", "Understeer"]
			for ignore, speed in ["Slow", "Fast"]
				for ignore, where in ["Entry", "Apex", "Exit"] {
					where := (type . ".Corner." . where . "." . speed)
					filteredHandling := []

					for ignore, issue in issues[where] {
						severity := issue.Severity

						include := (issue.Frequency >= applyThresholdSlider.Value)

						if (include && final) {
							include := false

							characteristic := characteristicLabels[where]

							row := resultListView.GetNext(0, "C")

							while row {
								value := resultListView.GetText(row)

								if (value = characteristic) {
									include := true

									break
								}
								else
									row := resultListView.GetNext(row, "C")
							}
						}

						if include
							filteredHandling.Push(issue)
					}

					issues[where] := filteredHandling
				}

		return issues
	}
	else if (commandOrAnalyzer == "FilterTemperatures") {
		workbench := analyzer.Workbench
		characteristicLabels := getMultiMapValues(workbench.Definition, "Workbench.Characteristics.Labels")
		final := ((arguments.Length > 0) && arguments[1])

		issues := analyzer.Temperatures.Clone()

		for ignore, category in ["Around", "Inner", "Outer"]
			for ignore, temperature in ["Cold", "Hot"]
				for ignore, position in ["Front", "Rear"] {
					key := ("Tyre.Temperatures." . temperature . "." . position . "." . category)

					filteredHandling := []

					for ignore, issue in issues[key] {
						severity := issue.Severity

						include := (issue.Frequency >= applyThresholdSlider.Value)

						if (include && final) {
							include := false

							characteristic := characteristicLabels[key]

							row := resultListView.GetNext(0, "C")

							while row {
								value := resultListView.GetText(row)

								if (value = characteristic) {
									include := true

									break
								}
								else
									row := resultListView.GetNext(row, "C")
							}
						}

						if include
							filteredHandling.Push(issue)
					}

					issues[key] := filteredHandling
				}

		for ignore, category in ["Front", "Rear"] {
			key := ("Brake.Temperatures." . category)

			filteredHandling := []

			for ignore, issue in issues[key] {
				severity := issue.Severity

				include := (issue.Frequency >= applyThresholdSlider.Value)

				if (include && final) {
					include := false

					characteristic := characteristicLabels[key]

					row := resultListView.GetNext(0, "C")

					while row {
						value := resultListView.GetText(row)

						if (value = characteristic) {
							include := true

							break
						}
						else
							row := resultListView.GetNext(row, "C")
					}
				}

				if include
					filteredHandling.Push(issue)
			}

			issues[key] := filteredHandling
		}

		return issues
	}
	else if (commandOrAnalyzer == "UpdateTelemetry") {
		workbench := analyzer.Workbench
		characteristicLabels := getMultiMapValues(workbench.Definition, "Workbench.Characteristics.Labels")
		handling := arguments[1]
		temperatures := arguments[2]

		theListView := ((state = "Run") ? issuesListView : resultListView)

		theListView.Delete()

		for ignore, type in ["Oversteer", "Understeer"]
			for ignore, speed in ["Slow", "Fast"]
				for ignore, where in ["Entry", "Apex", "Exit"] {
					characteristic := (type . ".Corner." . where . "." . speed)

					for ignore, issue in handling[characteristic]
						theListView.Add((state = "Analyze") ? "Check" : "", characteristicLabels[characteristic]
																		  , translate(issue.Severity), issue.Frequency)
				}

		for ignore, category in ["Around", "Inner", "Outer"]
			for ignore, temperature in ["Cold", "Hot"]
				for ignore, position in ["Front", "Rear"] {
					characteristic := ("Tyre.Temperatures." . temperature . "." . position . "." . category)

					for ignore, issue in temperatures[characteristic]
						theListView.Add((state = "Analyze") ? "Check" : "", characteristicLabels[characteristic]
																		  , translate(issue.Severity), issue.Frequency)
				}

		for ignore, category in ["Front", "Rear"] {
			characteristic := ("Brake.Temperatures." . category)

			for ignore, issue in temperatures[characteristic]
				theListView.Add((state = "Analyze") ? "Check" : "", characteristicLabels[characteristic]
																  , translate(issue.Severity), issue.Frequency)
		}

		theListView.ModifyCol()

		loop 3
			theListView.ModifyCol(A_Index, "AutoHdr")
	}
	else if ((commandOrAnalyzer == "Activate") && (state = "Analyze"))
		result := combine(runAnalyzer("FilterHandling", true), runAnalyzer("FilterTemperatures", true))
	else {
		analyzer := commandOrAnalyzer
		updateTask := false

		state := "Prepare"
		result := false

		prepareWidgets := []
		runWidgets := []
		analyzeWidgets := []

		analyzerGui := Window({Descriptor: "Setup Workbench.Analyzer", Options: "0x400000"})

		analyzerGui.SetFont("s10 Bold", "Arial")

		analyzerGui.Add("Text", "w340 Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(analyzerGui, "Setup Workbench.Analyzer"))

		analyzerGui.SetFont("s9 Norm", "Arial")

		analyzerGui.Add("Documentation", "x86 YP+20 w192 Center", translate("Telemetry Analyzer")
					  , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench#real-time-telemetry-analyzer")

		analyzerGui.SetFont("s8 Norm", "Arial")

		analyzerGui.Add("Text", "x16 yp+30 w130 h23 +0x200", translate("Simulator"))
		analyzerGui.Add("Text", "x158 yp w180 h23 +0x200", analyzer.Simulator)

		analyzerGui.Add("Text", "x16 yp+24 w130 h23 +0x200", translate("Car"))
		analyzerGui.Add("Text", "x158 yp w180 h23 +0x200", (analyzer.Car ? analyzer.Car : translate("Unknown")))

		if analyzer.Track {
			analyzerGui.Add("Text", "x16 yp+24 w130 h23 +0x200", translate("Track"))
			analyzerGui.Add("Text", "x158 yp w180 h23 +0x200", SessionDatabase.getTrackName(analyzer.Simulator, analyzer.Track))
		}

		tabView := analyzerGui.Add("Tab3", "x16 yp+30 w340 h348 Section", collect(["Handling", "Temperatures"], translate))
		widget36 := tabView

		tabView .UseTab(1)

		widget1 := analyzerGui.Add("Text", "x24 yp+30 w130 h23 +0x200", translate("Steering Lock / Ratio"))
		steerLockEdit := analyzerGui.Add("Edit", "x166 yp w45 h23 +0x200", analyzer.SteerLock)
		widget2 := steerLockEdit
		steerRatioEdit := analyzerGui.Add("Edit", "x216 yp w45 h23 Limit2 Number", analyzer.SteerRatio)
		widget3 := steerRatioEdit
		widget4 := analyzerGui.Add("UpDown", "x246 yp w18 h23 Range1-99", analyzer.SteerRatio)

		widget27 := analyzerGui.Add("Text", "x24 yp+30 w130 h23 +0x200", translate("Wheelbase / Track Width"))
		wheelbaseEdit := analyzerGui.Add("Edit", "x166 yp w45 h23 +0x200 Number Limit3", analyzer.Wheelbase)
		widget28 := wheelbaseEdit
		widget29 := analyzerGui.Add("UpDown", "x196 yp w18 h23 Range1-999", analyzer.Wheelbase)
		trackWidthEdit := analyzerGui.Add("Edit", "x216 yp w45 h23 +0x200 Number Limit3", analyzer.TrackWidth)
		widget30 := trackWidthEdit
		widget31 := analyzerGui.Add("UpDown", "x246 yp w18 h23 Range1-999", analyzer.TrackWidth)
		widget32 := analyzerGui.Add("Text", "x265 yp w50 h23 +0x200", translate("cm"))

		if !analyzer.settingAvailable("SteerLock") {
			steerLockEdit.Enabled := false
			steerLockEdit.Text := ""
		}

		if !analyzer.settingAvailable("SteerRatio") {
			steerRatioEdit.Enabled := false
			steerRatioEdit.Text := ""
		}

		if !analyzer.settingAvailable("Wheelbase") {
			wheelbaseEdit.Enabled := false
			wheelbaseEdit.Text := ""
		}

		if !analyzer.settingAvailable("TrackWidth") {
			trackWidthEdit.Enabled := false
			trackWidthEdit.Text := ""
		}

		analyzerGui.SetFont("Italic", "Arial")

		widget5 := analyzerGui.Add("GroupBox", "x24 yp+34 w320 h215", translate("Thresholds"))

		analyzerGui.SetFont("Norm", "Arial")

		widget6 := analyzerGui.Add("Text", "x32 yp+21 w130 h23 +0x200", translate("Consider less than"))
		lowspeedThresholdEdit := analyzerGui.Add("Edit", "x166 yp w45 h23 +0x200 Number Limit3", analyzer.LowspeedThreshold)
		widget7 := lowspeedThresholdEdit
		widget33 := analyzerGui.Add("UpDown", "x196 yp w18 h23 Range1-999", analyzer.LowspeedThreshold)
		widget8 := analyzerGui.Add("Text", "x215 yp w120 h23 +0x200", translate("km/h as low speed"))

		if !analyzer.settingAvailable("LowspeedThreshold") {
			lowspeedThresholdEdit.Enabled := false
			lowspeedThresholdEdit.Text := ""
		}

		widget9 := analyzerGui.Add("Text", "x32 yp+30 w130 h20 +0x200", translate("Heavy Oversteer"))
		heavyOversteerThresholdSlider := analyzerGui.Add("Slider", "Center Thick15 x166 yp+2 w132 0x10 Range" . kMinThreshold . "-" . kMaxThreshold . " ToolTip", analyzer.OversteerThresholds[3])
		heavyOversteerThresholdSlider.OnEvent("Change", runAnalyzer.Bind("UpdateSlider", false))
		widget10 := heavyOversteerThresholdSlider
		heavyOversteerThresholdEdit := analyzerGui.Add("Edit", "x301 yp w35 +0x200", analyzer.OversteerThresholds[3])
		heavyOversteerThresholdEdit.OnEvent("Change", runAnalyzer.Bind("UpdateSlider", true))
		widget21 := heavyOversteerThresholdEdit

		widget11 := analyzerGui.Add("Text", "x32 yp+22 w130 h20 +0x200", translate("Medium Oversteer"))
		mediumOversteerThresholdSlider := analyzerGui.Add("Slider", "Center Thick15 x166 yp+2 w132 0x10 Range" . kMinThreshold . "-" . kMaxThreshold . " ToolTip", analyzer.OversteerThresholds[2])
		mediumOversteerThresholdSlider.OnEvent("Change", runAnalyzer.Bind("UpdateSlider", false))
		widget12 := mediumOversteerThresholdSlider
		mediumOversteerThresholdEdit := analyzerGui.Add("Edit", "x301 yp w35 +0x200", analyzer.OversteerThresholds[2])
		mediumOversteerThresholdEdit.OnEvent("Change", runAnalyzer.Bind("UpdateSlider", true))
		widget22 := mediumOversteerThresholdEdit

		widget13 := analyzerGui.Add("Text", "x32 yp+22 w130 h20 +0x200", translate("Light Oversteer"))
		lightOversteerThresholdSlider := analyzerGui.Add("Slider", "Center Thick15 x166 yp+2 w132 0x10 Range" . kMinThreshold . "-" . kMaxThreshold . " ToolTip", analyzer.OversteerThresholds[1])
		lightOversteerThresholdSlider.OnEvent("Change", runAnalyzer.Bind("UpdateSlider", false))
		widget14 := lightOversteerThresholdSlider
		lightOversteerThresholdEdit := analyzerGui.Add("Edit", "x301 yp w35 +0x200", analyzer.OversteerThresholds[1])
		lightOversteerThresholdEdit.OnEvent("Change", runAnalyzer.Bind("UpdateSlider", true))
		widget23 := lightOversteerThresholdEdit

		widget15 := analyzerGui.Add("Text", "x32 yp+30 w130 h20 +0x200", translate("Light Understeer"))
		lightUndersteerThresholdSlider := analyzerGui.Add("Slider", "Center Thick15 x166 yp+2 w132 0x10 Range" . kMinThreshold . "-" . kMaxThreshold . " ToolTip", analyzer.UndersteerThresholds[1])
		lightUndersteerThresholdSlider.OnEvent("Change", runAnalyzer.Bind("UpdateSlider", false))
		widget16 := lightUndersteerThresholdSlider
		lightUndersteerThresholdEdit := analyzerGui.Add("Edit", "x301 yp w35 +0x200", analyzer.UndersteerThresholds[1])
		lightUndersteerThresholdEdit.OnEvent("Change", runAnalyzer.Bind("UpdateSlider", true))
		widget24 := lightUndersteerThresholdEdit

		widget17 := analyzerGui.Add("Text", "x32 yp+22 w130 h20 +0x200", translate("Medium Understeer"))
		mediumUndersteerThresholdSlider := analyzerGui.Add("Slider", "Center Thick15 x166 yp+2 w132 0x10 Range" . kMinThreshold . "-" . kMaxThreshold . " ToolTip", analyzer.UndersteerThresholds[2])
		mediumUndersteerThresholdSlider.OnEvent("Change", runAnalyzer.Bind("UpdateSlider", false))
		widget18 := mediumUndersteerThresholdSlider
		mediumUndersteerThresholdEdit := analyzerGui.Add("Edit", "x301 yp w35 +0x200", analyzer.UndersteerThresholds[2])
		mediumUndersteerThresholdEdit.OnEvent("Change", runAnalyzer.Bind("UpdateSlider", true))
		widget25 := mediumUndersteerThresholdEdit

		widget19 := analyzerGui.Add("Text", "x32 yp+22 w130 h20 +0x200", translate("Heavy Understeer"))
		heavyUndersteerThresholdSlider := analyzerGui.Add("Slider", "Center Thick15 x166 yp+2 w132 0x10 Range" . kMinThreshold . "-" . kMaxThreshold . " ToolTip", analyzer.UndersteerThresholds[3])
		heavyUndersteerThresholdSlider.OnEvent("Change", runAnalyzer.Bind("UpdateSlider", false))
		widget20 := heavyUndersteerThresholdSlider
		heavyUndersteerThresholdEdit := analyzerGui.Add("Edit", "x301 yp w35 +0x200", analyzer.UndersteerThresholds[3])
		heavyUndersteerThresholdEdit.OnEvent("Change", runAnalyzer.Bind("UpdateSlider", true))
		widget26 := heavyUndersteerThresholdEdit

		chosen := (analyzer.AcousticFeedback ? 1 : 2)

		widget34 := analyzerGui.Add("Text", "x24 yp+42 w130 h20 +0x200", translate("Acoustic feedback"))
		widget35 := analyzerGui.Add("DropDownList", "x166 yp w45 Choose" . chosen, [translate("Yes"), translate("No")])
		acousticFeedbackDropDown := widget35

		if !analyzer.settingAvailable("OversteerThresholds") {
			heavyOversteerThresholdSlider.Enabled := false
			heavyOversteerThresholdSlider.Value := 0
			mediumOversteerThresholdSlider.Enabled := false
			mediumOversteerThresholdSlider.Value := 0
			lightOversteerThresholdSlider.Enabled := false
			lightOversteerThresholdSlider.Value := 0
		}

		if !analyzer.settingAvailable("UndersteerThresholds") {
			heavyUndersteerThresholdSlider.Enabled := false
			heavyUndersteerThresholdSlider.Value := 0
			mediumUndersteerThresholdSlider.Enabled := false
			mediumUndersteerThresholdSlider.Value := 0
			lightUndersteerThresholdSlider.Enabled := false
			lightUndersteerThresholdSlider.Value := 0
		}

		tabView .UseTab(2)

		analyzerGui.SetFont("Italic", "Arial")

		widget37 := analyzerGui.Add("GroupBox", "x24 ys+30 w320 h130", translate("Tyres"))

		analyzerGui.SetFont("Norm", "Arial")

		widget38 := analyzerGui.Add("Text", "x174 yp+17 w45 h23 +0x200 Center", translate("Min"))
		widget39 := analyzerGui.Add("Text", "x224 yp w45 h23 +0x200 Center", translate("Max"))
		widget40 := analyzerGui.Add("Text", "x274 yp w45 h23 +0x200 Center", translate("Ideal"))

		widget41 := analyzerGui.Add("Text", "x32 yp+24 w130 h23 +0x200", translate("Target Front"))
		minFrontTyreTemperatureEdit := analyzerGui.Add("Edit", "x174 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", 70)))
		maxFrontTyreTemperatureEdit := analyzerGui.Add("Edit", "x224 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", 95)))
		idealFrontTyreTemperatureEdit := analyzerGui.Add("Edit", "x274 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", 80)))
		widget42 := minFrontTyreTemperatureEdit
		widget43 := maxFrontTyreTemperatureEdit
		widget44 := idealFrontTyreTemperatureEdit

		widget45 := analyzerGui.Add("Text", "x32 yp+24 w130 h23 +0x200", translate("Target Rear"))
		minRearTyreTemperatureEdit := analyzerGui.Add("Edit", "x174 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", 70)))
		maxRearTyreTemperatureEdit := analyzerGui.Add("Edit", "x224 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", 95)))
		idealRearTyreTemperatureEdit := analyzerGui.Add("Edit", "x274 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", 80)))
		widget46 := minRearTyreTemperatureEdit
		widget47 := maxRearTyreTemperatureEdit
		widget48 := idealRearTyreTemperatureEdit

		widget49 := analyzerGui.Add("Text", "x32 yp+30 w130 h23 +0x200", translate("Max OI difference"))
		maxOITemperatureDifferenceEdit := analyzerGui.Add("Edit", "x174 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", 10)))
		widget50 := maxOITemperatureDifferenceEdit

		widget51 := analyzerGui.Add("GroupBox", "x24 yp+42 w320 h100", translate("Brakes"))

		analyzerGui.SetFont("Norm", "Arial")

		widget52 := analyzerGui.Add("Text", "x174 yp+17 w45 h23 +0x200 Center", translate("Min"))
		widget53 := analyzerGui.Add("Text", "x224 yp w45 h23 +0x200 Center", translate("Max"))
		widget54 := analyzerGui.Add("Text", "x274 yp w45 h23 +0x200 Center", translate("Ideal"))

		widget55 := analyzerGui.Add("Text", "x32 yp+24 w130 h23 +0x200", translate("Target Front"))
		minFrontBrakeTemperatureEdit := analyzerGui.Add("Edit", "x174 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", 300)))
		maxFrontBrakeTemperatureEdit := analyzerGui.Add("Edit", "x224 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", 680)))
		idealFrontBrakeTemperatureEdit := analyzerGui.Add("Edit", "x274 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", 550)))
		widget56 := minFrontBrakeTemperatureEdit
		widget57 := maxFrontBrakeTemperatureEdit
		widget58 := idealFrontBrakeTemperatureEdit

		widget59 := analyzerGui.Add("Text", "x32 yp+24 w130 h23 +0x200", translate("Target Rear"))
		minRearBrakeTemperatureEdit := analyzerGui.Add("Edit", "x174 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", 300)))
		maxRearBrakeTemperatureEdit := analyzerGui.Add("Edit", "x224 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", 680)))
		idealRearBrakeTemperatureEdit := analyzerGui.Add("Edit", "x274 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", 550)))
		widget60 := minRearBrakeTemperatureEdit
		widget61 := maxRearBrakeTemperatureEdit
		widget62 := idealRearBrakeTemperatureEdit

		createTemperatureUpdater("FrontTyreTemperatures"
							   , [minFrontTyreTemperatureEdit, idealFrontTyreTemperatureEdit, maxFrontTyreTemperatureEdit])
		createTemperatureUpdater("RearTyreTemperatures"
							   , [minRearTyreTemperatureEdit, idealRearTyreTemperatureEdit, maxRearTyreTemperatureEdit])

		maxOITemperatureDifferenceEdit.OnEvent("Change", updateTemperature.Bind("OITemperatureDifference", maxOITemperatureDifferenceEdit))

		createTemperatureUpdater("FrontBrakeTemperatures"
							   , [minFrontBrakeTemperatureEdit, idealFrontBrakeTemperatureEdit, maxFrontBrakeTemperatureEdit])
		createTemperatureUpdater("RearBrakeTemperatures"
							   , [minRearBrakeTemperatureEdit, idealRearBrakeTemperatureEdit, maxRearBrakeTemperatureEdit])

		for ignore, widget in [minFrontTyreTemperatureEdit, idealFrontTyreTemperatureEdit, maxFrontTyreTemperatureEdit
							 , minRearTyreTemperatureEdit, idealRearTyreTemperatureEdit, maxRearTyreTemperatureEdit
							 , maxOITemperatureDifferenceEdit
							 , minRearBrakeTemperatureEdit, idealRearBrakeTemperatureEdit, maxRearBrakeTemperatureEdit
							 , minRearBrakeTemperatureEdit, idealRearBrakeTemperatureEdit, maxRearBrakeTemperatureEdit]
			widget.OnEvent("Change", validateTemperature.Bind(widget))

		loop 62
			prepareWidgets.Push(%"widget" . A_Index%)

		tabView .UseTab(0)

		widget1 := analyzerGui.Add("ListView", "x16 ys w336 h214 -Multi -LV0x10 NoSort NoSortHdr  Hidden", collect(["Characteristic", "Intensity", "Frequency (%)"], translate))
		widget1.OnEvent("Click", noSelect)
		widget1.OnEvent("DoubleClick", noSelect)

		issuesListView := widget1

		analyzerGui.SetFont("s14", "Arial")

		widget2 := analyzerGui.Add("Text", "x16 ys+224 w336 h200 Wrap Hidden", translate("Go to the track and run some decent laps. Then click on `"Stop`" to analyze the telemetry data."))

		analyzerGui.SetFont("Norm s8", "Arial")

		loop 2
			runWidgets.Push(%"widget" . A_Index%)

		widget1 := analyzerGui.Add("ListView", "x16 ys w336 h254 -Multi -LV0x10 Checked NoSort NoSortHdr  Hidden", collect(["Characteristic", "Intensity", "Frequency (%)"], translate))
		widget1.OnEvent("Click", noSelect)
		widget1.OnEvent("DoubleClick", noSelect)

		resultListView := widget1

		widget2 := analyzerGui.Add("Text", "x16 yp+262 w130 h23 +0x200 Hidden", translate("Threshold"))
		applyThresholdSlider := analyzerGui.Add("Slider", "x158 yp w60 0x10 Range0-25 ToolTip Hidden", 0)
		applyThresholdSlider.OnEvent("Change", runAnalyzer.Bind("Threshold"))
		widget3 := applyThresholdSlider
		widget4 := analyzerGui.Add("Text", "x220 yp+3 Hidden", translate("%"))

		loop 4
			analyzeWidgets.Push(%"widget" . A_Index%)

		tabView.UseTab(0)

		calibrateButton := analyzerGui.Add("Button", "x16 ys+366 w80 h23 ", translate("Calibrate..."))
		calibrateButton.OnEvent("Click", runAnalyzer.Bind("Calibrate"))
		activateButton := analyzerGui.Add("Button", "x176 yp w80 h23 Default", translate("Start"))
		activateButton.OnEvent("Click", runAnalyzer.Bind("Activate"))
		analyzerGui.Add("Button", "xp+98 yp w80 h23", translate("Cancel")).OnEvent("Click", runAnalyzer.Bind(kCancel))

		analyzerGui.Opt("+Owner" . analyzer.Workbench.Window.Hwnd)

		try {
			if getWindowPosition("Setup Workbench.Analyzer", &x, &y)
				analyzerGui.Show("AutoSize x" . x . " y" . y)
			else
				analyzerGui.Show("AutoSize Center")

			while !result
				Sleep(100)
		}
		finally {
			if updateTask
				updateTask.stop()

			updateTask := false

			analyzer.stopTelemetryAnalyzer()
		}

		analyzerGui.Destroy()

		return ((result == kCancel) ? false : result)
	}
}

runCalibrator(commandOrAnalyzer, *) {
	local lightOversteerThreshold := 0
	local heavyOversteerThreshold := 0
	local lightUndersteerThreshold := 0
	local heavyUndersteerThreshold := 0
	local mediumOversteerThreshold, mediumUndersteerThreshold
	local x, y, ignore, type, speed, where, value, variable

	static calibratorGui
	static activateButton
	static infoText

	static result := false
	static analyzer := false
	static state := "Start"

	static cleanValues := CaseInsenseMap()
	static overValues := CaseInsenseMap()

	if (commandOrAnalyzer == kCancel) {
		analyzer.stopTelemetryAnalyzer()

		result := kCancel
	}
	else if ((commandOrAnalyzer == "Activate") && (state = "Start")) {
		infoText.Text := translate("Drive at least two consecutive clean laps without under- or oversteering the car. Then press `"Next`".")
		activateButton.Text := translate("Next")

		state := "Clean"

		analyzer.startTelemetryAnalyzer(true)
	}
	else if ((commandOrAnalyzer == "Activate") && (state = "Clean")) {
		cleanValues := analyzer.Handling

		analyzer.stopTelemetryAnalyzer()

		infoText.Text := translate("Drive at least two consecutive hard laps and provoke under- and oversteering to the max but stay on the track. Then press `"Finish`".")
		activateButton.Text := translate("Finish")

		state := "Push"

		analyzer.startTelemetryAnalyzer(true)
	}
	else if ((commandOrAnalyzer == "Activate") && (state = "Push")) {
		overValues := analyzer.Handling

		analyzer.stopTelemetryAnalyzer()

		result := [cleanValues, overValues]
	}
	else {
		analyzer := commandOrAnalyzer

		state := "Start"
		result := false

		cleanValues := CaseInsenseMap()
		overValues := CaseInsenseMap()

		calibratorGui := Window({Descriptor: "Setup Workbench.Calibrator", Options: "0x400000"})

		calibratorGui.SetFont("s10 Bold", "Arial")

		calibratorGui.Add("Text", "w324 Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(calibratorGui, "Setup Workbench.Calibrator"))

		calibratorGui.SetFont("s9 Norm", "Arial")

		calibratorGui.Add("Documentation", "x78 YP+20 w184 Center", translate("Telemetry Analyzer")
						, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench#real-time-telemetry-analyzer")

		calibratorGui.SetFont("Norm s14", "Arial")

		infoText := calibratorGui.Add("Text", "x16 yp+30 w320 h140 Wrap", translate("Start a practice session and prepare for a run. Then press `"Start`"."))

		calibratorGui.SetFont("Norm s8", "Arial")

		activateButton := calibratorGui.Add("Button", "x92 yp+145 w80 h23 Default", translate("Start"))
		activateButton.OnEvent("Click", runCalibrator.Bind("Activate"))
		calibratorGui.Add("Button", "xp+100 yp w80 h23", translate("Cancel")).OnEvent("Click", runCalibrator.Bind(kCancel))

		try {
			if getWindowPosition("Setup Workbench.Calibrator", &x, &y)
				calibratorGui.Show("AutoSize x" . x . " y" . y)
			else
				calibratorGui.Show("AutoSize Center")

			while !result
				Sleep(100)
		}
		finally {
			analyzer.stopTelemetryAnalyzer()
		}

		calibratorGui.Destroy()

		if (result != kCancel) {
			for ignore, type in ["Oversteer", "Understeer"] {
				variable := ("light" . type . "Threshold")

				for ignore, speed in ["Slow", "Fast"]
					for ignore, where in ["Entry", "Apex", "Exit"] {
						value := result[1][type . ".Corner." . where . "." . speed]

						if value
							if (type = "Understeer")
								%variable% := Max(%variable%, value)
							else
								%variable% := Min(%variable%, value)
					}
			}

			for ignore, type in ["Oversteer", "Understeer"] {
				variable := ("heavy" . type . "Threshold")

				for ignore, speed in ["Slow", "Fast"]
					for ignore, where in ["Entry", "Apex", "Exit"] {
						value := result[2][type . ".Corner." . where . "." . speed]

						if value
							if (type = "Understeer")
								%variable% := Max(%variable%, value)
							else
								%variable% := Min(%variable%, value)
					}
			}

			value := Max(lightOversteerThreshold, heavyOversteerThreshold, kMinThreshold)
			heavyOversteerThreshold := Min(lightOversteerThreshold, heavyOversteerThreshold, 0)
			lightOversteerThreshold := value

			value := Min(lightUndersteerThreshold, heavyUndersteerThreshold, kMaxThreshold)
			heavyUndersteerThreshold := Max(lightUndersteerThreshold, heavyUndersteerThreshold, 0)
			lightUndersteerThreshold := value

			heavyOversteerThreshold := Round(heavyOversteerThreshold * 0.9)
			heavyUndersteerThreshold := Round(heavyUndersteerThreshold * 0.9)
			mediumOversteerThreshold := Round(lightOversteerThreshold + (heavyOversteerThreshold - lightOversteerThreshold) / 2)
			mediumUndersteerThreshold := Round(lightUndersteerThreshold + (heavyUndersteerThreshold - lightUndersteerThreshold) / 2)

			return [[lightUndersteerThreshold, mediumUndersteerThreshold, heavyUndersteerThreshold]
				  , [lightOversteerThreshold, mediumOversteerThreshold, heavyOversteerThreshold]]
		}
		else
			return false
	}
}