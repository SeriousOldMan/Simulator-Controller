;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Generic Issue Analyzer          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Extensions\Task.ahk"
#Include "..\..\Framework\Extensions\Messages.ahk"
#Include "..\..\Framework\Extensions\Math.ahk"
#Include "..\..\Database\Libraries\SessionDatabase.ahk"
#Include "..\..\Database\Libraries\TelemetryAnalyzer.ahk"
#Include "IssueCollector.ahk"


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
;;; GenericIssueAnalyzer                                                    ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class GenericIssueAnalyzer extends IssueAnalyzer {
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

	iWaterTemperature := [80, 90, 100]
	iOilTemperature := [80, 90, 100]

	iBottomOutThresholds := CaseInsenseMap("Light", 5, "Medium", 10, "Heavy", 15)
	iBottomOutDuration := 30
	iBottomOutGap := 100
	iSamplerSettings := CaseInsenseMap("Samples", 2, "Deflection", 5, "Acceleration", 2)

	iAcousticFeedback := true

	iIssueCollector := false
	iLastHandling := false
	iLastSuspension := false
	iLastTemperatures := false

	iExitCallback := false

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
			return "IssueCollector"
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

	WaterTemperature {
		Get {
			return this.iWaterTemperature
		}

		Set {
			setAnalyzerSetting(this, "WaterTemperature", values2String(",", value*))

			return (this.iWaterTemperature := value)
		}
	}

	OilTemperature {
		Get {
			return this.iOilTemperature
		}

		Set {
			setAnalyzerSetting(this, "OilTemperature", values2String(",", value*))

			return (this.iOilTemperature := value)
		}
	}

	BottomOutThresholds[key?] {
		Get {
			return (isSet(key) ? this.iBottomOutThresholds[key] : this.iBottomOutThresholds)
		}

		Set {
			if isSet(key) {
				this.iBottomOutThresholds[key] := value

				setAnalyzerSetting(this, "BottomOutThresholds", map2String("|", "->", this.iBottomOutThresholds))

				return value
			}
			else {
				setAnalyzerSetting(this, "BottomOutThresholds", map2String("|", "->", value))

				return (this.iBottomOutThresholds := value)
			}
		}
	}

	BottomOutDuration {
		Get {
			return this.iBottomOutDuration
		}

		Set {
			setAnalyzerSetting(this, "BottomOutDuration", value)

			return (this.iBottomOutDuration := value)
		}
	}

	BottomOutGap {
		Get {
			return this.iBottomOutGap
		}

		Set {
			setAnalyzerSetting(this, "BottomOutGap", value)

			return (this.iBottomOutGap := value)
		}
	}

	SamplerSettings[key?] {
		Get {
			return (isSet(key) ? this.iSamplerSettings[key] : this.iSamplerSettings)
		}

		Set {
			if isSet(key) {
				this.iSamplerSettings[key] := value

				setAnalyzerSetting(this, "SamplerSettings", map2String("|", "->", this.iSamplerSettings))

				return value
			}
			else {
				setAnalyzerSetting(this, "SamplerSettings", map2String("|", "->", value))

				return (this.iSamplerSettings := value)
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

	Handling {
		Get {
			if this.iIssueCollector
				return (this.iLastHandling := this.iIssueCollector.Handling)
			else if !this.iLastHandling {
				this.iLastHandling := CaseInsenseMap()
				this.iLastHandling.Default := []
			}

			return this.iLastHandling
		}

		Set {
			return (this.iLastHandling := value)
		}
	}

	Suspension {
		Get {
			if this.iIssueCollector
				return (this.iLastSuspension := this.iIssueCollector.Suspension)
			else if !this.iLastSuspension {
				this.iLastSuspension := CaseInsenseMap()
				this.iLastSuspension.Default := []
			}

			return this.iLastSuspension
		}

		Set {
			return (this.iLastSuspension := value)
		}
	}

	Temperatures {
		Get {
			if this.iIssueCollector
				this.iLastTemperatures := this.iIssueCollector.Temperatures
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
		local defaultWaterTemperature := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "WaterTemperature", "80,90,100")
		local defaultOilTemperature := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "OilTemperature", "80,90,100")
		local defaultBottomOutThresholds := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "BottomOutThresholds", "Light->5|Medium->10|Heavy->15")
		local defaultBottomOutDuration := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "BottomOutDuration", 30)
		local defaultBottomOutGap := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "BottomOutGap", 100)
		local defaultSamplerSettings := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "SamplerSettings", "Samples->2|Deflection->5|Acceleration->2")
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

			this.iSteerLock := (SessionDatabase.getCarSteerLock(simulator, selectedCar, selectedTrack) || this.SteerLock)
			this.iSteerRatio := (SessionDatabase.getCarSteerRatio(simulator, selectedCar, selectedTrack) || this.SteerRatio)
			this.iWheelbase := (SessionDatabase.getCarWheelbase(simulator, selectedCar, selectedTrack) || this.Wheelbase)
			this.iTrackWidth := (SessionDatabase.getCarTrackWidth(simulator, selectedCar, selectedTrack) || this.TrackWidth)

			if FileExist(fileName) {
				configuration := readMultiMap(fileName)

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
				defaultWaterTemperature := getMultiMapValue(configuration, "Analyzer", "WaterTemperature", defaultWaterTemperature)
				defaultOilTemperature := getMultiMapValue(configuration, "Analyzer", "OilTemperature", defaultOilTemperature)
				defaultBottomOutThresholds := getMultiMapValue(configuration, "Analyzer", "BottomOutThresholds", defaultBottomOutThresholds)
				defaultBottomOutDuration := getMultiMapValue(configuration, "Analyzer", "BottomOutDuration", defaultBottomOutDuration)
				defaultBottomOutGap := getMultiMapValue(configuration, "Analyzer", "BottomOutGap", defaultBottomOutGap)
				defaultSamplerSettings := getMultiMapValue(configuration, "Analyzer", "SamplerSettings", defaultSamplerSettings)
			}
		}

		settings := readMultiMap(kUserConfigDirectory . "Issue Collector.ini")

		prefix := (simulator . "." . (selectedCar ? selectedCar : "*") . ".*.")

		this.iSteerLock := getMultiMapValue(settings, "Settings", prefix . "SteerLock", this.SteerLock)
		this.iSteerRatio := getMultiMapValue(settings, "Settings", prefix . "SteerRatio", this.SteerRatio)
		this.iWheelbase := getMultiMapValue(settings, "Settings", prefix . "Wheelbase", this.Wheelbase)
		this.iTrackWidth := getMultiMapValue(settings, "Settings", prefix . "TrackWidth", this.TrackWidth)
		this.iAcousticFeedback := getMultiMapValue(settings, "Settings", prefix . "Feedback", true)

		defaultUndersteerThresholds := getMultiMapValue(settings, "Settings", prefix . "UndersteerThresholds", defaultUndersteerThresholds)
		defaultOversteerThresholds := getMultiMapValue(settings, "Settings", prefix . "OversteerThresholds", defaultOversteerThresholds)
		defaultLowspeedThreshold := getMultiMapValue(settings, "Settings", prefix . "LowspeedThreshold", defaultLowspeedThreshold)

		defaultFrontTyreTemperatures := getMultiMapValue(settings, "Settings", prefix . "FrontTyreTemperatures", defaultFrontTyreTemperatures)
		defaultRearTyreTemperatures := getMultiMapValue(settings, "Settings", prefix . "RearTyreTemperatures", defaultRearTyreTemperatures)
		defaultOITemperatureDifference := getMultiMapValue(settings, "Settings", prefix . "TyreOITemperatureDifference", defaultOITemperatureDifference)
		defaultFrontBrakeTemperatures := getMultiMapValue(settings, "Settings", prefix . "FrontBrakeTemperatures", defaultFrontBrakeTemperatures)
		defaultRearBrakeTemperatures := getMultiMapValue(settings, "Settings", prefix . "RearBrakeTemperatures", defaultRearBrakeTemperatures)
		defaultWaterTemperature := getMultiMapValue(settings, "Settings", prefix . "WaterTemperature", defaultWaterTemperature)
		defaultOilTemperature := getMultiMapValue(settings, "Settings", prefix . "OilTemperature", defaultOilTemperature)
		defaultBottomOutThresholds := getMultiMapValue(settings, "Settings", prefix . "BottomOutThresholds", defaultBottomOutThresholds)
		defaultBottomOutDuration := getMultiMapValue(settings, "Settings", prefix . "BottomOutDuration", defaultBottomOutDuration)
		defaultBottomOutGap := getMultiMapValue(settings, "Settings", prefix . "BottomOutGap", defaultBottomOutGap)
		defaultSamplerSettings := getMultiMapValue(settings, "Settings", prefix . "SamplerSettings", defaultSamplerSettings)

		prefix := (simulator . "." . (selectedCar ? selectedCar : "*") . "." . (selectedTrack ? selectedTrack : "*") . ".")

		this.iSteerLock := getMultiMapValue(settings, "Settings", prefix . "SteerLock", this.SteerLock)
		this.iSteerRatio := getMultiMapValue(settings, "Settings", prefix . "SteerRatio", this.SteerRatio)
		this.iWheelbase := getMultiMapValue(settings, "Settings", prefix . "Wheelbase", this.Wheelbase)
		this.iTrackWidth := getMultiMapValue(settings, "Settings", prefix . "TrackWidth", this.TrackWidth)
		this.iAcousticFeedback := getMultiMapValue(settings, "Settings", prefix . "Feedback", this.AcousticFeedback)

		this.iUndersteerThresholds := string2Values(",", getMultiMapValue(settings, "Settings"
													   , prefix . "UndersteerThresholds", defaultUndersteerThresholds))
		this.iOversteerThresholds := string2Values(",", getMultiMapValue(settings, "Settings"
													  , prefix . "OversteerThresholds", defaultOversteerThresholds))
		this.iLowspeedThreshold := getMultiMapValue(settings, "Settings", prefix . "LowspeedThreshold", defaultLowspeedThreshold)

		this.iFrontTyreTemperatures := string2Values(",", getMultiMapValue(settings, "Settings"
													    , prefix . "FrontTyreTemperatures", defaultFrontTyreTemperatures))
		this.iRearTyreTemperatures := string2Values(",", getMultiMapValue(settings, "Settings"
													   , prefix . "RearTyreTemperatures", defaultRearTyreTemperatures))
		this.iOITemperatureDifference := getMultiMapValue(settings, "Settings", prefix . "TyreOITemperatureDifference", defaultOITemperatureDifference)

		this.iFrontBrakeTemperatures := string2Values(",", getMultiMapValue(settings, "Settings"
														 , prefix . "FrontBrakeTemperatures", defaultFrontBrakeTemperatures))
		this.iRearBrakeTemperatures := string2Values(",", getMultiMapValue(settings, "Settings"
														, prefix . "RearBrakeTemperatures", defaultRearBrakeTemperatures))

		this.iWaterTemperature := string2Values(",", getMultiMapValue(settings, "Settings"
												   , prefix . "WaterTemperature", defaultWaterTemperature))
		this.iOilTemperature := string2Values(",", getMultiMapValue(settings, "Settings"
												 , prefix . "OilTemperature", defaultOilTemperature))

		this.iBottomOutThresholds := string2Map("|", "->", getMultiMapValue(settings, "Settings", prefix . "BottomOutThresholds", defaultBottomOutThresholds))
		this.iBottomOutDuration := getMultiMapValue(settings, "Settings", prefix . "BottomOutDuration", defaultBottomOutDuration)
		this.iBottomOutGap := getMultiMapValue(settings, "Settings", prefix . "BottomOutGap", defaultBottomOutGap)
		this.iSamplerSettings := string2Map("|", "->", getMultiMapValue(settings, "Settings", prefix . "SamplerSettings", defaultSamplerSettings))

		super.__New(workbench, simulator)

		if !this.iExitCallback {
			this.iExitCallback := ObjBindMethod(this, "stopIssueAnalyzer")

			OnExit(this.iExitCallback)
		}

		if first {
			registerMessageHandler("Analyzer", methodMessageHandler, GenericIssueAnalyzer)

			first := false
		}
	}

	settingAvailable(setting) {
		return true
	}

	createCharacteristics(issues := false) {
		local workbench, severities, maxFrequency
		local characteristicLabels, key, characteristic, characteristics, ignore, type, severity, speed, where, value, issue
		local temperature, position, category

		if issues {
			workbench := this.Workbench
			characteristicLabels := getMultiMapValues(workbench.Definition, "Workbench.Characteristics.Labels")
			severities := CaseInsenseMap("Light", 33, "Medium", 50, "Heavy", 66)
			characteristics := CaseInsenseMap()
			maxFrequency := 0

			workbench.clearCharacteristics()

			workbench.ProgressCount := 0

			showProgress({color: "Green", width: 350, title: translate("Creating Issues"), message: translate("Preparing Characteristics...")})

			for ignore, type in ["Oversteer", "Understeer"]
				for ignore, speed in ["Slow", "Fast"]
					for ignore, where in ["Entry", "Apex", "Exit"]
						for ignore, issue in issues[type . ".Corner." . where . "." . speed]
							maxFrequency := Max(maxFrequency, issue.Frequency)

			if (maxFrequency > 0)
				for ignore, type in ["Oversteer", "Understeer"]
					for ignore, speed in ["Slow", "Fast"]
						for ignore, where in ["Entry", "Apex", "Exit"] {
							key := (type . ".Corner." . where . "." . speed)

							for ignore, issue in issues[key] {
								value := issue.Frequency
								severity := issue.Severity

								if !characteristics.Has(key)
									characteristics[key] := [Round(value / maxFrequency * 66), severities[severity]]
								else {
									characteristic := characteristics[key]

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

			if (maxFrequency > 0)
				for ignore, category in ["Around", "Inner", "Outer"]
					for ignore, temperature in ["Cold", "Hot"]
						for ignore, position in ["Front", "Rear"] {
							key := ("Tyre.Temperatures." . temperature . "." . position . "." . category)

							for ignore, issue in issues[key] {
								value := issue.Frequency
								severity := issue.Severity

								if !characteristics.Has(key)
									characteristics[key] := [Round(value / maxFrequency * 66), severities[severity]]
								else {
									characteristic := characteristics[key]

									characteristic[1] := Max(characteristic[1], Round(value / maxFrequency * 66))
									characteristic[2] := Max(characteristic[2], severities[severity])
								}
							}
						}

			maxFrequency := 0

			for ignore, category in ["Front", "Rear"]
				for ignore, temperature in ["Cold", "Hot"]
					for ignore, issue in issues["Brake.Temperatures." . temperature . "." . category]
						maxFrequency := Max(maxFrequency, issue.Frequency)

			if (maxFrequency > 0)
				for ignore, category in ["Front", "Rear"]
					for ignore, temperature in ["Cold", "Hot"] {
						key := ("Brake.Temperatures." . temperature . "." category)

						for ignore, issue in issues[key] {
							value := issue.Frequency
							severity := issue.Severity

							if !characteristics.Has(key)
								characteristics[key] := [Round(value / maxFrequency * 66), severities[severity]]
							else {
								characteristic := characteristics[key]

								characteristic[1] := Max(characteristic[1], Round(value / maxFrequency * 66))
								characteristic[2] := Max(characteristic[2], severities[severity])
							}
						}
					}

			maxFrequency := 0

			for ignore, category in ["Water", "Oil"]
				for ignore, temperature in ["Cold", "Hot"]
					for ignore, issue in issues["Engine.Temperatures." . temperature . "." . category]
						maxFrequency := Max(maxFrequency, issue.Frequency)

			if (maxFrequency > 0)
				for ignore, category in ["Water", "Oil"]
					for ignore, temperature in ["Cold", "Hot"] {
						key := ("Engine.Temperatures." . temperature . "." . category)

						for ignore, issue in issues[key] {
							value := issue.Frequency
							severity := issue.Severity

							if !characteristics.Has(key)
								characteristics[key] := [Round(value / maxFrequency * 66), severities[severity]]
							else {
								characteristic := characteristics[key]

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

	startIssueAnalyzer(calibrate := false) {
		local settings := {Handling: true, Suspension: true, Temperatures: true, Frequency: 2000}
		local ignore, setting

		this.stopIssueAnalyzer()

		if !this.iIssueCollector {
			if !calibrate
				for ignore, setting in ["UndersteerThresholds", "OversteerThresholds"]
					if this.settingAvailable(setting)
						settings.%setting% := this.%setting%

			for ignore, setting in ["LowSpeedThreshold", "SteerLock", "SteerRatio", "WheelBase", "TrackWidth"]
				if this.settingAvailable(setting)
					settings.%setting% := this.%setting%

			this.iIssueCollector := %this.CollectorClass%(this.Simulator, this.Car, this.Track, settings, this.AcousticFeedback)

			this.iIssueCollector.startIssueCollector(calibrate)
		}

		return this.iIssueCollector
	}

	stopIssueAnalyzer(arguments*) {
		local collector := this.iIssueCollector

		if ((arguments.Length > 0) && inList(["Logoff", "Shutdown"], arguments[1]))
			return false

		if collector {
			this.iLastHandling := collector.Handling
			this.iLastSuspension := collector.Suspension

			collector.stopIssueCollector()
		}

		this.iIssueCollector := false

		return false
	}

	computeTemperatures(samples) {
		local count := samples.Length
		local tyreTemperatures := [[], [], [], []]
		local brakeTemperatures := [[], [], [], []]
		local tyreOITemperatureDifferences := [[], [], [], []]
		local waterTemperatures := []
		local oilTemperatures := []
		local issues := CaseInsenseMap()

		getTemperatures(category, temperatures) {
			local ignore, sample

			for ignore, sample in samples
				if sample.HasProp(category . "Temperatures")
					loop 4
						temperatures[A_Index].Push(sample.%category%Temperatures[A_Index])
		}

		getEngineTemperatures(category, temperatures) {
			local ignore, sample

			for ignore, sample in samples
				if sample.HasProp(category . "Temperature")
					temperatures.Push(sample.%category%Temperature)
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
			local coldHeavy := 0
			local hotHeavy := 0
			local coldMedium := 0
			local hotMedium := 0
			local coldLight := 0
			local hotLight := 0
			local difference, ignore, position, value, key, type

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

			for ignore, temperature in ["Cold", "Hot"] {
				key := ("Brake.Temperatures." . temperature . "." . category)

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

		computeEngineIssues(category, samples, minThreshold, maxThreshold, idealValue) {
			local coldHeavy := 0
			local hotHeavy := 0
			local coldMedium := 0
			local hotMedium := 0
			local coldLight := 0
			local hotLight := 0
			local difference, ignore, position, value, key, type

			for ignore, value in samples {
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
				key := ("Engine.Temperatures." . temperature . "." . category)

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

		if (count > 0) {
			getTemperatures("Tyre", tyreTemperatures)

			computeTyreIssues("Front", [1, 2], this.FrontTyreTemperatures[1], this.FrontTyreTemperatures[3], this.FrontTyreTemperatures[2])
			computeTyreIssues("Rear", [3, 4], this.RearTyreTemperatures[1], this.RearTyreTemperatures[3], this.RearTyreTemperatures[2])

			getOIDifferences()

			computeOIIssues("Front", [1, 2], this.OITemperatureDifference)
			computeOIIssues("Rear", [3, 4], this.OITemperatureDifference)

			getTemperatures("Brake", brakeTemperatures)

			computeBrakeIssues("Front", [1, 2], this.FrontBrakeTemperatures[1], this.FrontBrakeTemperatures[3], this.FrontBrakeTemperatures[2])
			computeBrakeIssues("Rear", [3, 4], this.RearBrakeTemperatures[1], this.RearBrakeTemperatures[3], this.RearBrakeTemperatures[2])

			getEngineTemperatures("Water", waterTemperatures)
			getEngineTemperatures("Oil", oilTemperatures)

			computeEngineIssues("Water", waterTemperatures, this.WaterTemperature[1], this.WaterTemperature[3], this.WaterTemperature[2])
			computeEngineIssues("Oil", oilTemperatures, this.OilTemperature[1], this.OilTemperature[3], this.OilTemperature[2])
		}

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
	local settings := readMultiMap(kUserConfigDirectory . "Issue Collector.ini")

	setMultiMapValue(settings, "Settings", prefix . key, value)

	writeMultiMap(kUserConfigDirectory . "Issue Collector.ini", settings)
}

runAnalyzer(commandOrAnalyzer := false, arguments*) {
	local x, y, ignore, widget, workbench, row, include
	local issues, issue, handling, suspension, temperatures, filteredHandling, filteredSuspension, filteredTemperatures
	local type, speed, severity, where, value, newValue, frequency
	local characteristic, characteristicLabels, fromEdit
	local calibration, theListView, chosen, tabView
	local category, temperature, position, key, info, simulator, car, track, fileName
	local telemetries, theAnalyzer, thresholds

	static analyzerGui

	static telemetryButton
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

	static minWaterTemperatureEdit
	static maxWaterTemperatureEdit
	static idealWaterTemperatureEdit
	static minOilTemperatureEdit
	static maxOilTemperatureEdit
	static idealOilTemperatureEdit
	static lightBottomOutEdit
	static mediumBottomOutEdit
	static heavyBottomOutEdit
	static durationBottomOutEdit
	static gapBottomOutEdit
	static minSamplesEdit
	static deflectionWindowEdit
	static accelerationWindowEdit

	static issuesListView

	static resultListView
	static applyThresholdSlider, applyThresholdDropDown

	static result := false
	static analyzer := false
	static state := "Prepare"

	static prepareWidgets := []
	static runWidgets := []
	static analyzeWidgets := []

	static updateTask := false

	validateInteger(minValue, maxValue, field, operation, value?) {
		if (operation = "Validate")
			return (isInteger(value) && (value >= minValue) && (value <= maxValue))
	}

	validateTemperature(field, operation, value?) {
		if (operation = "Validate") {
			value := internalValue("Float", value)

			return (isNumber(value) && (value > 0))
		}
	}

	createTemperatureUpdater(name, widgets) {
		local ignore, widget

		updateTemperature(widget, *) {
			if widget.Validate()
				analyzer.%name% := [convertUnit("Temperature", internalValue("Float", widgets[1].Text), false)
								  , convertUnit("Temperature", internalValue("Float", widgets[2].Text), false)
								  , convertUnit("Temperature", internalValue("Float", widgets[3].Text), false)]
		}

		for ignore, widget in widgets
			widget.OnEvent("Change", updateTemperature.Bind(widget))
	}

	updateTemperature(name, widget, *) {
		analyzer.%name% := convertUnit("Temperature", internalValue("Float", widget.Text), false)
	}

	noSelect(listView, *) {
		loop listView.GetCount()
			listView.Modify(A_Index, "-Select")
	}

	if (commandOrAnalyzer == kCancel) {
		if updateTask
			updateTask.stop()

		analyzer.stopIssueAnalyzer()

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
	else if (commandOrAnalyzer == "UpdateBOThresholds") {
		value := lightBottomOutEdit.Text

		if isInteger(value)
			analyzer.BottomOutThresholds["Light"] := value
		else
			analyzer.BottomOutThresholds["Light"] := lightBottomOutEdit.Text := 5

		value := mediumBottomOutEdit.Text

		if isInteger(value)
			analyzer.BottomOutThresholds["Medium"] := value
		else
			analyzer.BottomOutThresholds["Medium"] := lightBottomOutEdit.Text := 10

		value := heavyBottomOutEdit.Text

		if isInteger(value)
			analyzer.BottomOutThresholds["Heavy"] := value
		else
			analyzer.BottomOutThresholds["Heavy"] := lightBottomOutEdit.Text := 15
	}
	else if (commandOrAnalyzer == "UpdateBOTimings") {
		if !validateInteger(10, 200, durationBottomOutEdit, "Validate", durationBottomOutEdit.Text)
			durationBottomOutEdit.Text := 30

		if !validateInteger(50, 500, gapBottomOutEdit, "Validate", gapBottomOutEdit.Text)
			gapBottomOutEdit.Text := 100

		analyzer.BottomOutDuration := durationBottomOutEdit.Text
		analyzer.BottomOutGap := gapBottomOutEdit.Text
	}
	else if (commandOrAnalyzer == "UpdateBOSamples") {
		value := deflectionWindowEdit.Text

		if isInteger(value)
			analyzer.SamplerSettings["Deflection"] := value
		else
			analyzer.SamplerSettings["Deflection"] := deflectionWindowEdit.Text := 5

		value := accelerationWindowEdit.Text

		if isInteger(value)
			analyzer.SamplerSettings["Acceleration"] := value
		else
			analyzer.SamplerSettings["Acceleration"] := accelerationWindowEdit.Text := 2

		if !validateInteger(1, 10, minSamplesEdit, "Validate", minSamplesEdit.Text)
			minSamplesEdit.Text := 2

		analyzer.SamplerSettings["Samples"] := minSamplesEdit.Text
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
	else if (((commandOrAnalyzer == "Activate") || (commandOrAnalyzer == "Telemetry")) && (state = "Prepare")) {
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

		if ((commandOrAnalyzer == "Telemetry") && analyzer.Car && analyzer.Track) {
			analyzerGui.Opt("+OwnDialogs")

			analyzerGui.Block()

			try {
				fileName := browseLapTelemetries(analyzerGui, &simulator := analyzer.Simulator
															, &car := analyzer.Car
															, &track := analyzer.Track
															, &info)
			}
			finally {
				analyzerGui.Unblock()
			}

			if (fileName && (fileName != "")) {
				theAnalyzer := TelemetryAnalyzer(analyzer.Simulator, analyzer.Track)
				telemetries := []

				if isObject(fileName) {
					loop fileName.Length
						telemetries.Push(theAnalyzer.createTelemetry(A_Index, fileName[A_Index]))
				}
				else
					telemetries.Push(theAnalyzer.createTelemetry(1, fileName))

				thresholds := {LowSpeed: analyzer.LowspeedThreshold
							 , LightOversteer: analyzer.OversteerThresholds[1]
							 , MediumOversteer: analyzer.OversteerThresholds[2]
							 , HeavyOversteer: analyzer.OversteerThresholds[3]
							 , LightUndersteer: analyzer.UndersteerThresholds[1]
							 , MediumUndersteer: analyzer.UndersteerThresholds[2]
							 , HeavyUndersteer: analyzer.UndersteerThresholds[3]}

				analyzerGui.Block()

				try {
					withTask(ProgressTask(translate("Analyzing Data")), () {
						issues := theAnalyzer.analyzeHandling(telemetries, analyzer.SteerLock, analyzer.SteerRatio
																		 , analyzer.WheelBase, analyzer.TrackWidth
																		 , thresholds)

						issues := IssueCollector.createHandling(issues)

						analyzer.Handling := issues

						issues := theAnalyzer.analyzeSuspension(telemetries, thresholds)

						issues := IssueCollector.createSuspension(issues)

						analyzer.Suspension := issues
					})
				}
				finally {
					analyzerGui.Unblock()
				}

				for ignore, widget in prepareWidgets {
					widget.Enabled := false
					widget.Visible := false
				}

				for ignore, widget in analyzeWidgets
					widget.Visible := true

				activateButton.Text := translate("Apply")

				state := "Analyze"

				runAnalyzer("UpdateTelemetry", runAnalyzer("FilterHandling"), runAnalyzer("FilterSuspension"))
			}
		}
		else {
			for ignore, widget in prepareWidgets {
				widget.Enabled := false
				widget.Visible := false
			}

			for ignore, widget in runWidgets
				widget.Visible := true

			activateButton.Text := translate("Stop")

			state := "Run"

			analyzer.startIssueAnalyzer()

			updateTask := PeriodicTask(runAnalyzer.Bind("UpdateSamples"), 5000)

			updateTask.start()
		}
	}
	else if ((commandOrAnalyzer == "Activate") && (state = "Run")) {
		updateTask.stop()

		updateTask := false

		analyzer.stopIssueAnalyzer()

		for ignore, widget in runWidgets {
			widget.Enabled := false
			widget.Visible := false
		}

		for ignore, widget in analyzeWidgets
			widget.Visible := true

		activateButton.Text := translate("Apply")

		state := "Analyze"

		runAnalyzer("UpdateTelemetry", runAnalyzer("FilterHandling")
									 , runAnalyzer("FilterSuspension")
									 , runAnalyzer("FilterTemperatures"))
	}
	else if (commandOrAnalyzer == "Threshold")
		runAnalyzer("UpdateTelemetry", runAnalyzer("FilterHandling")
									 , runAnalyzer("FilterSuspension")
									 , runAnalyzer("FilterTemperatures"))
	else if (commandOrAnalyzer == "UpdateSamples")
		runAnalyzer("UpdateTelemetry", analyzer.Handling, analyzer.Suspension, analyzer.Temperatures)
	else if (commandOrAnalyzer == "FilterHandling") {
		workbench := analyzer.Workbench
		characteristicLabels := getMultiMapValues(workbench.Definition, "Workbench.Characteristics.Labels")
		final := ((arguments.Length > 0) && arguments[1])

		issues := ((arguments.Length > 1) ? arguments[2] : analyzer.Handling.Clone())

		for ignore, type in ["Oversteer", "Understeer"]
			for ignore, speed in ["Slow", "Fast"]
				for ignore, where in ["Entry", "Apex", "Exit"] {
					where := (type . ".Corner." . where . "." . speed)
					filteredHandling := []

					if issues.Has(where) {
						for ignore, issue in issues[where] {
							severity := issue.Severity

							include := ((issue.Frequency >= applyThresholdSlider.Value)
									 && (inList(["Light", "Medium", "Heavy"], issue.Severity) >= applyThresholdDropDown.Value))

							if (include && final) {
								include := false

								characteristic := characteristicLabels[where]

								row := resultListView.GetNext(0, "C")

								while row
									if (resultListView.GetText(row) = characteristic) {
										include := true

										break
									}
									else
										row := resultListView.GetNext(row, "C")
							}

							if include
								filteredHandling.Push(issue)
						}

						issues[where] := filteredHandling
					}
				}

		return issues
	}
	else if (commandOrAnalyzer == "FilterSuspension") {
		workbench := analyzer.Workbench
		characteristicLabels := getMultiMapValues(workbench.Definition, "Workbench.Characteristics.Labels")
		final := ((arguments.Length > 0) && arguments[1])

		issues := ((arguments.Length > 1) ? arguments[2] : analyzer.Suspension.Clone())

		for ignore, type in ["Suspension.Bottom.Out"]
			for ignore, where in ["Front", "Rear"] {
				where := (type . "." . where)
				filteredSuspension := []

				if issues.Has(where) {
					for ignore, issue in issues[where] {
						severity := issue.Severity

						include := ((issue.Frequency >= applyThresholdSlider.Value)
								 && (inList(["Light", "Medium", "Heavy"], issue.Severity) >= applyThresholdDropDown.Value))

						if (include && final) {
							include := false

							characteristic := characteristicLabels[where]

							row := resultListView.GetNext(0, "C")

							while row
								if (resultListView.GetText(row) = characteristic) {
									include := true

									break
								}
								else
									row := resultListView.GetNext(row, "C")
						}

						if include
							filteredSuspension.Push(issue)
					}

					issues[where] := filteredSuspension
				}
			}

		if issues.Has("Suspension.Sway") {
			for ignore, issue in issues["Suspension.Sway"] {
				severity := issue.Severity

				include := ((issue.Frequency >= applyThresholdSlider.Value)
						 && (inList(["Light", "Medium", "Heavy"], issue.Severity) >= applyThresholdDropDown.Value))

				if (include && final) {
					include := false

					characteristic := characteristicLabels["Suspension.Sway"]

					row := resultListView.GetNext(0, "C")

					while row
						if (resultListView.GetText(row) = characteristic) {
							include := true

							break
						}
						else
							row := resultListView.GetNext(row, "C")
				}

				if include
					filteredSuspension.Push(issue)
			}

			issues["Suspension.Sway"] := filteredSuspension
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

					filteredTemperatures := []

					for ignore, issue in issues[key] {
						severity := issue.Severity

						include := ((issue.Frequency >= applyThresholdSlider.Value)
								 && (inList(["Light", "Medium", "Heavy"], issue.Severity) >= applyThresholdDropDown.Value))

						if (include && final) {
							include := false

							characteristic := characteristicLabels[key]

							row := resultListView.GetNext(0, "C")

							while row
								if (resultListView.GetText(row) = characteristic) {
									include := true

									break
								}
								else
									row := resultListView.GetNext(row, "C")
						}

						if include
							filteredTemperatures.Push(issue)
					}

					issues[key] := filteredTemperatures
				}

		for ignore, category in ["Front", "Rear"]
			for ignore, temperature in ["Cold", "Hot"] {
				key := ("Brake.Temperatures." . temperature . "." category)

				filteredTemperatures := []

				for ignore, issue in issues[key] {
					severity := issue.Severity

					include := ((issue.Frequency >= applyThresholdSlider.Value)
							 && (inList(["Light", "Medium", "Heavy"], issue.Severity) >= applyThresholdDropDown.Value))

					if (include && final) {
						include := false

						characteristic := characteristicLabels[key]

						row := resultListView.GetNext(0, "C")

						while row
							if (resultListView.GetText(row) = characteristic) {
								include := true

								break
							}
							else
								row := resultListView.GetNext(row, "C")
					}

					if include
						filteredTemperatures.Push(issue)
				}

				issues[key] := filteredTemperatures
			}

		for ignore, category in ["Water", "Oil"]
			for ignore, temperature in ["Cold", "Hot"] {
				key := ("Engine.Temperatures." . temperature . "." category)

				filteredTemperatures := []

				for ignore, issue in issues[key] {
					severity := issue.Severity

					include := ((issue.Frequency >= applyThresholdSlider.Value)
							 && (inList(["Light", "Medium", "Heavy"], issue.Severity) >= applyThresholdDropDown.Value))

					if (include && final) {
						include := false

						characteristic := characteristicLabels[key]

						row := resultListView.GetNext(0, "C")

						while row
							if (resultListView.GetText(row) = characteristic) {
								include := true

								break
							}
							else
								row := resultListView.GetNext(row, "C")
					}

					if include
						filteredTemperatures.Push(issue)
				}

				issues[key] := filteredTemperatures
			}

		return issues
	}
	else if (commandOrAnalyzer == "UpdateTelemetry") {
		workbench := analyzer.Workbench
		characteristicLabels := getMultiMapValues(workbench.Definition, "Workbench.Characteristics.Labels")
		handling := ((arguments.Length > 0) ? arguments[1] : false)
		suspension := ((arguments.Length > 1) ? arguments[2] : false)
		temperatures := ((arguments.Length > 2) ? arguments[3] : false)

		theListView := ((state = "Run") ? issuesListView : resultListView)

		theListView.Delete()

		if handling
			for ignore, type in ["Oversteer", "Understeer"]
				for ignore, speed in ["Slow", "Fast"]
					for ignore, where in ["Entry", "Apex", "Exit"] {
						characteristic := (type . ".Corner." . where . "." . speed)

						if handling.Has(characteristic)
							for ignore, issue in handling[characteristic]
								theListView.Add((state = "Analyze") ? "Check" : "", characteristicLabels[characteristic]
																				  , translate(issue.Severity), issue.Frequency)
					}

		if suspension {
			for ignore, type in ["Suspension.Bottom.Out"]
				for ignore, where in ["Front", "Rear"] {
					characteristic := (type . "." . where)

					if suspension.Has(characteristic)
						for ignore, issue in suspension[characteristic]
							theListView.Add((state = "Analyze") ? "Check" : "", characteristicLabels[characteristic]
																			  , translate(issue.Severity), issue.Frequency)
				}

			if suspension.Has("Suspension.Sway")
				for ignore, issue in suspension["Suspension.Sway"]
					theListView.Add((state = "Analyze") ? "Check" : "", characteristicLabels["Suspension.Sway"]
																	  , translate(issue.Severity), issue.Frequency)
		}

		if temperatures {
			for ignore, category in ["Around", "Inner", "Outer"]
				for ignore, temperature in ["Cold", "Hot"]
					for ignore, position in ["Front", "Rear"] {
						characteristic := ("Tyre.Temperatures." . temperature . "." . position . "." . category)

						if temperatures.Has(characteristic)
							for ignore, issue in temperatures[characteristic]
								theListView.Add((state = "Analyze") ? "Check" : "", characteristicLabels[characteristic]
																				  , translate(issue.Severity), issue.Frequency)
					}

			for ignore, category in ["Front", "Rear"]
				for ignore, temperature in ["Cold", "Hot"] {
					characteristic := ("Brake.Temperatures." . temperature . "." . category)

					if temperatures.Has(characteristic)
						for ignore, issue in temperatures[characteristic]
							theListView.Add((state = "Analyze") ? "Check" : "", characteristicLabels[characteristic]
																			  , translate(issue.Severity), issue.Frequency)
				}

			for ignore, category in ["Water", "Oil"]
				for ignore, temperature in ["Cold", "Hot"] {
					characteristic := ("Engine.Temperatures." . temperature . "." . category)

					if temperatures.Has(characteristic)
						for ignore, issue in temperatures[characteristic]
							theListView.Add((state = "Analyze") ? "Check" : "", characteristicLabels[characteristic]
																			  , translate(issue.Severity), issue.Frequency)
				}
		}

		theListView.ModifyCol()

		loop 3
			theListView.ModifyCol(A_Index, "AutoHdr")
	}
	else if ((commandOrAnalyzer == "Activate") && (state = "Analyze"))
		result := combine(runAnalyzer("FilterHandling", true)
						, runAnalyzer("FilterSuspension", true)
						, runAnalyzer("FilterTemperatures", true))
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

		analyzerGui.Add("Documentation", "x86 YP+20 w192 Center", translate("Issue Analyzer")
					  , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench#real-time-issue-analyzer")

		analyzerGui.SetFont("s8 Norm", "Arial")

		analyzerGui.Add("Text", "x16 yp+30 w130 h23 +0x200", translate("Simulator"))
		analyzerGui.Add("Text", "x158 yp w180 h23 +0x200", analyzer.Simulator)

		analyzerGui.Add("Text", "x16 yp+24 w130 h23 +0x200", translate("Car"))
		analyzerGui.Add("Text", "x158 yp w180 h23 +0x200", (analyzer.Car ? analyzer.Car : translate("Unknown")))

		if analyzer.Track {
			analyzerGui.Add("Text", "x16 yp+24 w130 h23 +0x200", translate("Track"))
			analyzerGui.Add("Text", "x158 yp w180 h23 +0x200", SessionDatabase.getTrackName(analyzer.Simulator, analyzer.Track))
		}

		tabView := analyzerGui.Add("Tab3", "x16 yp+30 w340 h388 Section", collect(["Handling", "Suspension", "Temperatures"], translate))
		widget36 := tabView

		tabView .UseTab(1)

		widget1 := analyzerGui.Add("Text", "x24 yp+30 w130 h23 +0x200", translate("Steering Lock / Ratio"))
		steerLockEdit := analyzerGui.Add("Edit", "x166 yp w45 h23 +0x200", analyzer.SteerLock)
		steerLockEdit.OnValidate("LoseFocus", validateInteger.Bind(0, 2000))
		widget2 := steerLockEdit
		steerRatioEdit := analyzerGui.Add("Edit", "x216 yp w45 h23 Limit2 Number", analyzer.SteerRatio)
		steerRatioEdit.OnValidate("LoseFocus", validateInteger.Bind(1, 99))
		widget3 := steerRatioEdit
		widget4 := analyzerGui.Add("UpDown", "x246 yp w18 h23 Range1-99", analyzer.SteerRatio)

		widget27 := analyzerGui.Add("Text", "x24 yp+30 w130 h23 +0x200", translate("Wheelbase / Track Width"))
		wheelbaseEdit := analyzerGui.Add("Edit", "x166 yp w45 h23 +0x200 Number Limit3", analyzer.Wheelbase)
		wheelBaseEdit.OnValidate("LoseFocus", validateInteger.Bind(1, 999))
		widget28 := wheelbaseEdit
		widget29 := analyzerGui.Add("UpDown", "x196 yp w18 h23 Range1-999", analyzer.Wheelbase)
		trackWidthEdit := analyzerGui.Add("Edit", "x216 yp w45 h23 +0x200 Number Limit3", analyzer.TrackWidth)
		trackWidthEdit.OnValidate("LoseFocus", validateInteger.Bind(1, 999))
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
		lowspeedThresholdEdit.OnValidate("LoseFocus", validateInteger.Bind(1, 999))
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

		calibrateButton := analyzerGui.Add("Button", "x264 yp w80 h23 ", translate("Calibrate..."))
		calibrateButton.OnEvent("Click", runAnalyzer.Bind("Calibrate"))
		widget75 := calibrateButton

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

		widget76 := analyzerGui.Add("GroupBox", "x24 ys+30 w320 h130", translate("Bottom Out"))

		analyzerGui.SetFont("Norm", "Arial")

		widget77 := analyzerGui.Add("Text", "x174 yp+17 w45 h23 +0x200 Center", translate("Light"))
		widget78 := analyzerGui.Add("Text", "x224 yp w45 h23 +0x200 Center", translate("Medium"))
		widget79 := analyzerGui.Add("Text", "x274 yp w45 h23 +0x200 Center", translate("Heavy"))

		widget80 := analyzerGui.Add("Text", "x32 yp+24 w130 h23 +0x200", translate("Thresholds (m/s²)"))
		lightBottomOutEdit := analyzerGui.Add("Edit", "x174 yp w45 h23 +0x200 Number", analyzer.BottomOutThresholds["Light"])
		widget84 := analyzerGui.Add("UpDown", "x174 yp w45 h23 Range0-99", analyzer.BottomOutThresholds["Light"])
		mediumBottomOutEdit := analyzerGui.Add("Edit", "x224 yp w45 h23 +0x200", analyzer.BottomOutThresholds["Medium"])
		widget85 := analyzerGui.Add("UpDown", "x224 yp w45 h23 Range0-99", analyzer.BottomOutThresholds["Medium"])
		heavyBottomOutEdit := analyzerGui.Add("Edit", "x274 yp w45 h23 +0x200", analyzer.BottomOutThresholds["Heavy"])
		widget86 := analyzerGui.Add("UpDown", "x274 yp w45 h23 Range0-99", analyzer.BottomOutThresholds["Heavy"])
		widget81 := lightBottomOutEdit
		widget82 := mediumBottomOutEdit
		widget83 := heavyBottomOutEdit

		lightBottomOutEdit.OnEvent("LoseFocus", runAnalyzer.Bind("UpdateBOThresholds"))
		mediumBottomOutEdit.OnEvent("LoseFocus", runAnalyzer.Bind("UpdateBOThresholds"))
		heavyBottomOutEdit.OnEvent("LoseFocus", runAnalyzer.Bind("UpdateBOThresholds"))

		widget87 := analyzerGui.Add("Text", "x32 yp+30 w130 h23 +0x200", translate("Minimum Length"))
		durationBottomOutEdit := analyzerGui.Add("Edit", "x174 yp w45 h23 +0x200 Number", analyzer.BottomOutDuration)
		widget88 := durationBottomOutEdit
		widget89 := analyzerGui.Add("UpDown", "x224 yp w45 h23 Range10-200", analyzer.BottomOutDuration)
		widget90 := analyzerGui.Add("Text", "x220 yp w40 h23 +0x200", translate("ms"))

		widget91 := analyzerGui.Add("Text", "x32 yp+24 w130 h23 +0x200", translate("Minimum Gap"))
		gapBottomOutEdit := analyzerGui.Add("Edit", "x174 yp w45 h23 +0x200 Number", analyzer.BottomOutGap)
		widget92 := gapBottomOutEdit
		widget93 := analyzerGui.Add("UpDown", "x224 yp w45 h23 Range50-500", analyzer.BottomOutGap)
		widget94 := analyzerGui.Add("Text", "x220 yp w40 h23 +0x200", translate("ms"))

		durationBottomOutEdit.OnEvent("LoseFocus", runAnalyzer.Bind("UpdateBOTimings"))
		gapBottomOutEdit.OnEvent("LoseFocus", runAnalyzer.Bind("UpdateBOTimings"))

		analyzerGui.SetFont("Italic", "Arial")

		widget95 := analyzerGui.Add("GroupBox", "x24 yp+42 w320 h108", translate("Samples && Smoothing"))

		analyzerGui.SetFont("Norm", "Arial")

		widget96 := analyzerGui.Add("Text", "x32 yp+24 w130 h23 +0x200", translate("Minimum Length"))
		minSamplesEdit := analyzerGui.Add("Edit", "x174 yp w45 h23 +0x200 Number", analyzer.SamplerSettings["Samples"])
		widget97 := minSamplesEdit
		widget98 := analyzerGui.Add("UpDown", "x224 yp w45 h23 Range1-10", analyzer.SamplerSettings["Samples"])
		widget99 := analyzerGui.Add("Text", "x220 yp w80 h23 +0x200", translate("Samples"))

		minSamplesEdit.OnEvent("LoseFocus", runAnalyzer.Bind("UpdateBOSamples"))

		widget100 := analyzerGui.Add("Text", "x32 yp+30 w130 h23 +0x200", translate("Deflection"))
		deflectionWindowEdit := analyzerGui.Add("Edit", "x174 yp w45 h23 +0x200 Number", analyzer.SamplerSettings["Deflection"])
		widget101 := analyzerGui.Add("UpDown", "x174 yp w45 h23 Range1-20", analyzer.SamplerSettings["Deflection"])
		widget102 := analyzerGui.Add("Text", "x220 yp w80 h23 +0x200", translate("Samples"))

		widget103 := analyzerGui.Add("Text", "x32 yp+24 w130 h23 +0x200", translate("Acceleration"))
		accelerationWindowEdit := analyzerGui.Add("Edit", "x174 yp w45 h23 +0x200", analyzer.SamplerSettings["Acceleration"])
		widget104 := analyzerGui.Add("UpDown", "x174 yp w45 h23 Range1-20", analyzer.SamplerSettings["Acceleration"])
		widget105 := analyzerGui.Add("Text", "x220 yp w80 h23 +0x200", translate("Samples"))

		widget106 := deflectionWindowEdit
		widget107 := accelerationWindowEdit

		deflectionWindowEdit.OnEvent("LoseFocus", runAnalyzer.Bind("UpdateBOSamples"))
		accelerationWindowEdit.OnEvent("LoseFocus", runAnalyzer.Bind("UpdateBOSamples"))

		tabView .UseTab(3)

		analyzerGui.SetFont("Italic", "Arial")

		widget37 := analyzerGui.Add("GroupBox", "x24 ys+30 w320 h130", translate("Tyres"))

		analyzerGui.SetFont("Norm", "Arial")

		widget38 := analyzerGui.Add("Text", "x174 yp+17 w45 h23 +0x200 Center", translate("Min"))
		widget39 := analyzerGui.Add("Text", "x224 yp w45 h23 +0x200 Center", translate("Max"))
		widget40 := analyzerGui.Add("Text", "x274 yp w45 h23 +0x200 Center", translate("Ideal"))

		widget41 := analyzerGui.Add("Text", "x32 yp+24 w130 h23 +0x200", translate("Target Front"))
		minFrontTyreTemperatureEdit := analyzerGui.Add("Edit", "x174 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", analyzer.FrontTyreTemperatures[1])))
		maxFrontTyreTemperatureEdit := analyzerGui.Add("Edit", "x224 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", analyzer.FrontTyreTemperatures[3])))
		idealFrontTyreTemperatureEdit := analyzerGui.Add("Edit", "x274 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", analyzer.FrontTyreTemperatures[2])))
		widget42 := minFrontTyreTemperatureEdit
		widget43 := maxFrontTyreTemperatureEdit
		widget44 := idealFrontTyreTemperatureEdit

		widget45 := analyzerGui.Add("Text", "x32 yp+24 w130 h23 +0x200", translate("Target Rear"))
		minRearTyreTemperatureEdit := analyzerGui.Add("Edit", "x174 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", analyzer.RearTyreTemperatures[1])))
		maxRearTyreTemperatureEdit := analyzerGui.Add("Edit", "x224 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", analyzer.RearTyreTemperatures[3])))
		idealRearTyreTemperatureEdit := analyzerGui.Add("Edit", "x274 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", analyzer.RearTyreTemperatures[2])))
		widget46 := minRearTyreTemperatureEdit
		widget47 := maxRearTyreTemperatureEdit
		widget48 := idealRearTyreTemperatureEdit

		widget49 := analyzerGui.Add("Text", "x32 yp+30 w130 h23 +0x200", translate("Max OI difference"))
		maxOITemperatureDifferenceEdit := analyzerGui.Add("Edit", "x174 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", analyzer.OITemperatureDifference)))
		widget50 := maxOITemperatureDifferenceEdit

		widget51 := analyzerGui.Add("GroupBox", "x24 yp+42 w320 h100", translate("Brakes"))

		analyzerGui.SetFont("Norm", "Arial")

		widget52 := analyzerGui.Add("Text", "x174 yp+17 w45 h23 +0x200 Center", translate("Min"))
		widget53 := analyzerGui.Add("Text", "x224 yp w45 h23 +0x200 Center", translate("Max"))
		widget54 := analyzerGui.Add("Text", "x274 yp w45 h23 +0x200 Center", translate("Ideal"))

		widget55 := analyzerGui.Add("Text", "x32 yp+24 w130 h23 +0x200", translate("Target Front"))
		minFrontBrakeTemperatureEdit := analyzerGui.Add("Edit", "x174 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", analyzer.FrontBrakeTemperatures[1])))
		maxFrontBrakeTemperatureEdit := analyzerGui.Add("Edit", "x224 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", analyzer.FrontBrakeTemperatures[3])))
		idealFrontBrakeTemperatureEdit := analyzerGui.Add("Edit", "x274 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", analyzer.FrontBrakeTemperatures[2])))
		widget56 := minFrontBrakeTemperatureEdit
		widget57 := maxFrontBrakeTemperatureEdit
		widget58 := idealFrontBrakeTemperatureEdit

		widget59 := analyzerGui.Add("Text", "x32 yp+24 w130 h23 +0x200", translate("Target Rear"))
		minRearBrakeTemperatureEdit := analyzerGui.Add("Edit", "x174 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", analyzer.RearBrakeTemperatures[1])))
		maxRearBrakeTemperatureEdit := analyzerGui.Add("Edit", "x224 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", analyzer.RearBrakeTemperatures[3])))
		idealRearBrakeTemperatureEdit := analyzerGui.Add("Edit", "x274 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", analyzer.RearBrakeTemperatures[2])))
		widget60 := minRearBrakeTemperatureEdit
		widget61 := maxRearBrakeTemperatureEdit
		widget62 := idealRearBrakeTemperatureEdit

		widget63 := analyzerGui.Add("GroupBox", "x24 yp+42 w320 h100", translate("Engine"))

		analyzerGui.SetFont("Norm", "Arial")

		widget64 := analyzerGui.Add("Text", "x174 yp+17 w45 h23 +0x200 Center", translate("Min"))
		widget65 := analyzerGui.Add("Text", "x224 yp w45 h23 +0x200 Center", translate("Max"))
		widget66 := analyzerGui.Add("Text", "x274 yp w45 h23 +0x200 Center", translate("Ideal"))

		widget67 := analyzerGui.Add("Text", "x32 yp+24 w130 h23 +0x200", translate("Target Water"))
		minWaterTemperatureEdit := analyzerGui.Add("Edit", "x174 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", analyzer.WaterTemperature[1])))
		maxWaterTemperatureEdit := analyzerGui.Add("Edit", "x224 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", analyzer.WaterTemperature[3])))
		idealWaterTemperatureEdit := analyzerGui.Add("Edit", "x274 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", analyzer.WaterTemperature[2])))
		widget68 := minWaterTemperatureEdit
		widget69 := maxWaterTemperatureEdit
		widget70 := idealWaterTemperatureEdit

		widget71 := analyzerGui.Add("Text", "x32 yp+24 w130 h23 +0x200", translate("Target Oil"))
		minOilTemperatureEdit := analyzerGui.Add("Edit", "x174 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", analyzer.OilTemperature[1])))
		maxOilTemperatureEdit := analyzerGui.Add("Edit", "x224 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", analyzer.OilTemperature[3])))
		idealOilTemperatureEdit := analyzerGui.Add("Edit", "x274 yp w45 h23 +0x200", displayValue("Float", convertUnit("Temperature", analyzer.OilTemperature[2])))
		widget72 := minOilTemperatureEdit
		widget73 := maxOilTemperatureEdit
		widget74 := idealOilTemperatureEdit

		createTemperatureUpdater("FrontTyreTemperatures"
							   , [minFrontTyreTemperatureEdit, idealFrontTyreTemperatureEdit, maxFrontTyreTemperatureEdit])
		createTemperatureUpdater("RearTyreTemperatures"
							   , [minRearTyreTemperatureEdit, idealRearTyreTemperatureEdit, maxRearTyreTemperatureEdit])

		maxOITemperatureDifferenceEdit.OnEvent("Change", updateTemperature.Bind("OITemperatureDifference", maxOITemperatureDifferenceEdit))

		createTemperatureUpdater("FrontBrakeTemperatures"
							   , [minFrontBrakeTemperatureEdit, idealFrontBrakeTemperatureEdit, maxFrontBrakeTemperatureEdit])
		createTemperatureUpdater("RearBrakeTemperatures"
							   , [minRearBrakeTemperatureEdit, idealRearBrakeTemperatureEdit, maxRearBrakeTemperatureEdit])

		createTemperatureUpdater("WaterTemperature", [minWaterTemperatureEdit, idealWaterTemperatureEdit, maxWaterTemperatureEdit])
		createTemperatureUpdater("OilTemperature", [minOilTemperatureEdit, idealOilTemperatureEdit, maxOilTemperatureEdit])

		for ignore, widget in [minFrontTyreTemperatureEdit, idealFrontTyreTemperatureEdit, maxFrontTyreTemperatureEdit
							 , minRearTyreTemperatureEdit, idealRearTyreTemperatureEdit, maxRearTyreTemperatureEdit
							 , maxOITemperatureDifferenceEdit
							 , minFrontBrakeTemperatureEdit, idealFrontBrakeTemperatureEdit, maxFrontBrakeTemperatureEdit
							 , minRearBrakeTemperatureEdit, idealRearBrakeTemperatureEdit, maxRearBrakeTemperatureEdit
							 , minWaterTemperatureEdit, idealWaterTemperatureEdit, maxWaterTemperatureEdit
							 , minOilTemperatureEdit, idealOilTemperatureEdit, maxOilTemperatureEdit]
			widget.OnValidate("LoseFocus", validateTemperature)

		loop 107
			prepareWidgets.Push(%"widget" . A_Index%)

		tabView .UseTab(0)

		widget1 := analyzerGui.Add("ListView", "x16 ys w336 h254 -Multi -LV0x10 NoSort NoSortHdr  Hidden", collect(["Characteristic", "Intensity", "Frequency (%)"], translate))
		widget1.OnEvent("Click", noSelect)
		widget1.OnEvent("DoubleClick", noSelect)

		issuesListView := widget1

		analyzerGui.SetFont("s14", "Arial")

		widget2 := analyzerGui.Add("Text", "x16 ys+264 w336 h140 Wrap Hidden", translate("Go to the track and run some decent laps. Then click on `"Stop`" to analyze the telemetry data."))

		analyzerGui.SetFont("Norm s8", "Arial")

		loop 2
			runWidgets.Push(%"widget" . A_Index%)

		widget1 := analyzerGui.Add("ListView", "x16 ys w336 h254 -Multi -LV0x10 Checked NoSort NoSortHdr Hidden", collect(["Characteristic", "Intensity", "Frequency (%)"], translate))
		widget1.OnEvent("Click", noSelect)
		widget1.OnEvent("DoubleClick", noSelect)

		resultListView := widget1

		widget2 := analyzerGui.Add("Text", "x16 yp+262 w130 h23 +0x200 Hidden", translate("Threshold"))

		applyThresholdDropDown := analyzerGui.Add("DropDownList", "x158 yp w75 Choose1 Hidden", [translate("Light"), translate("Medium"), translate("Heavy")])
		applyThresholdDropDown.OnEvent("Change", runAnalyzer.Bind("Threshold"))
		widget5 := applyThresholdDropDown

		applyThresholdSlider := analyzerGui.Add("Slider", "x158 yp+24 w60 Thick15 0x10 Range0-25 ToolTip Hidden", 0)
		applyThresholdSlider.OnEvent("Change", runAnalyzer.Bind("Threshold"))
		widget3 := applyThresholdSlider
		widget4 := analyzerGui.Add("Text", "x220 yp+3 Hidden", translate("%"))

		loop 5
			analyzeWidgets.Push(%"widget" . A_Index%)

		tabView.UseTab(0)

		telemetryButton := analyzerGui.Add("Button", "x16 ys+406 w80 h23 ", translate("Telemetry..."))
		telemetryButton.OnEvent("Click", runAnalyzer.Bind("Telemetry"))

		telemetryButton.Enabled := (analyzer.Simulator && analyzer.Car && analyzer.Track)

		prepareWidgets.Push(telemetryButton)

		activateButton := analyzerGui.Add("Button", "x176 ys+406 w80 h23 Default", translate("Start"))
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

			analyzer.stopIssueAnalyzer()
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
		analyzer.stopIssueAnalyzer()

		result := kCancel
	}
	else if ((commandOrAnalyzer == "Activate") && (state = "Start")) {
		infoText.Text := translate("Drive at least two consecutive clean laps without under- or oversteering the car. Then press `"Next`".")
		activateButton.Text := translate("Next")

		state := "Clean"

		analyzer.startIssueAnalyzer(true)
	}
	else if ((commandOrAnalyzer == "Activate") && (state = "Clean")) {
		cleanValues := analyzer.Handling

		addMultiMapValues(cleanValues, analyzer.Suspension)

		analyzer.stopIssueAnalyzer()

		infoText.Text := translate("Drive at least two consecutive hard laps and provoke under- and oversteering to the max but stay on the track. Then press `"Finish`".")
		activateButton.Text := translate("Finish")

		state := "Push"

		analyzer.startIssueAnalyzer(true)
	}
	else if ((commandOrAnalyzer == "Activate") && (state = "Push")) {
		overValues := analyzer.Handling

		addMultiMapValues(overValues, analyzer.Suspension)

		analyzer.stopIssueAnalyzer()

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

		calibratorGui.Add("Documentation", "x78 YP+20 w184 Center", translate("Issue Analyzer")
						, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench#real-time-issue-analyzer")

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
			analyzer.stopIssueAnalyzer()
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