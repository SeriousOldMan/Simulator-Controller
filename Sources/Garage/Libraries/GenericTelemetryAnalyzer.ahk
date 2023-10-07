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

	iAcousticFeedback := true
	static sAudioDevice := false

	iTelemetryCollector := false
	iLastIssues := false

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

	Issues {
		Get {
			if this.iTelemetryCollector
				return (this.iLastIssues := this.iTelemetryCollector.Issues)
			else if !this.iLastIssues {
				this.iLastIssues := CaseInsenseMap()
				this.iLastIssues.Default := []
			}

			return this.iLastIssues
		}
	}

	__New(workbench, simulator) {
		local selectedCar := workbench.SelectedCar[false]
		local selectedTrack := workbench.SelectedTrack[false]
		local defaultUndersteerThresholds := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "UndersteerThresholds", "40,70,100")
		local defaultOversteerThresholds := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "OversteerThresholds", "-40,-70,-100")
		local defaultLowspeedThreshold := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "LowspeedThreshold", 120)
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
		local workbench, severities, count, maxValue
		local characteristicLabels, characteristic, characteristics, ignore, type, severity, speed, where, value, issue

		if issues {
			workbench := this.Workbench
			characteristicLabels := getMultiMapValues(workbench.Definition, "Workbench.Characteristics.Labels")
			severities := CaseInsenseMap("Light", 33, "Medium", 50, "Heavy", 66)
			characteristics := CaseInsenseMap()
			count := 0
			maxValue := 0

			workbench.clearCharacteristics()

			workbench.ProgressCount := 0

			showProgress({color: "Green", width: 350, title: translate("Creating Problems"), message: translate("Preparing Characteristics...")})

			for ignore, type in ["Oversteer", "Understeer"]
				for ignore, speed in ["Slow", "Fast"]
					for ignore, where in ["Entry", "Apex", "Exit"]
						for ignore, issue in issues[type . ".Corner." . where . "." . speed]
							maxValue := Max(maxValue, issue.Value)

			for ignore, type in ["Oversteer", "Understeer"]
				for ignore, speed in ["Slow", "Fast"]
					for ignore, where in ["Entry", "Apex", "Exit"] {
						characteristic := (type . ".Corner." . where . "." . speed)

						for ignore, issue in issues[characteristic] {
							value := issue.Value
							severity := issue.Severity

							if !characteristics.Has(characteristic)
								characteristics[characteristic] := [Round(value / maxValue * 66), severities[severity]]
							else {
								characteristic := characteristics[characteristic]

								characteristic[1] := Max(characteristic[1], Round(value / maxValue * 66))
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
		local settings := {}
		local ignore, setting

		this.stopTelemetryAnalyzer()

		if !this.iTelemetryCollector {
			if !calibrate
				for ignore, setting in ["UndersteerThresholds", "OversteerThresholds"]
					if this.settingAvailable(setting)
						settings.%setting% := this.%setting%

			for ignore, setting in ["SteerLock", "SteerRatio", "WheelBase", "TrackWidth"]
				if this.settingAvailable(setting)
					settings.%setting% := this.%setting%

			this.iTelemetryCollector := %this.CollectorClass%(this.Simulator, this.Car, this.Track, settings, this.AcousticFeedback)

			this.iTelemetryCollector.startTelemetryCollector(calibrate)
		}

		return this.iTelemetryCollector
	}

	stopTelemetryAnalyzer(*) {
		local collector := this.iTelemetryCollector

		if collector
			collector.stopTelemetryCollector()

		this.iTelemetryCollector := false
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
	local issues, filteredIssues, issue, type, speed, severity, where, value, newValue, characteristic, characteristicLabels, fromEdit
	local calibration, theListView, chosen, tabView

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

		updateTask := PeriodicTask(runAnalyzer.Bind("UpdateIssues"), 5000)

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

		runAnalyzer("UpdateTelemetry", runAnalyzer("FilterTelemetry"))
	}
	else if (commandOrAnalyzer == "Threshold")
		runAnalyzer("UpdateTelemetry", runAnalyzer("FilterTelemetry"))
	else if (commandOrAnalyzer == "UpdateIssues") {
		issues := analyzer.Issues

		if (issues.Count > 0)
			runAnalyzer("UpdateTelemetry", issues)
	}
	else if (commandOrAnalyzer == "FilterTelemetry") {
		workbench := analyzer.Workbench
		characteristicLabels := getMultiMapValues(workbench.Definition, "Workbench.Characteristics.Labels")
		final := ((arguments.Length > 0) && arguments[1])

		issues := analyzer.Issues

		for ignore, type in ["Oversteer", "Understeer"]
			for ignore, speed in ["Slow", "Fast"]
				for ignore, where in ["Entry", "Apex", "Exit"] {
					where := (type . ".Corner." . where . "." . speed)
					filteredIssues := []

					for ignore, issue in issues[where] {
						value := issue.Value
						severity := issue.Severity

						include := (value >= applyThresholdSlider.Value)

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
							filteredIssues.Push(issue)
					}

					issues[where] := filteredIssues
				}

		return issues
	}
	else if (commandOrAnalyzer == "UpdateTelemetry") {
		workbench := analyzer.Workbench
		characteristicLabels := getMultiMapValues(workbench.Definition, "Workbench.Characteristics.Labels")
		issues := arguments[1]

		theListView := ((state = "Run") ? issuesListView : resultListView)

		theListView.Delete()

		for ignore, type in ["Oversteer", "Understeer"]
			for ignore, speed in ["Slow", "Fast"]
				for ignore, where in ["Entry", "Apex", "Exit"] {
					characteristic := (type . ".Corner." . where . "." . speed)

					for ignore, issue in issues[characteristic]
						theListView.Add((state = "Analyze") ? "Check" : "", characteristicLabels[characteristic]
																		  , translate(issue.Severity), issue.Value)
				}

		theListView.ModifyCol()

		loop 3
			theListView.ModifyCol(A_Index, "AutoHdr")
	}
	else if ((commandOrAnalyzer == "Activate") && (state = "Analyze"))
		result := runAnalyzer("FilterTelemetry", true)
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

		tabView := analyzerGui.Add("Tab3", "x16 yp+30 w340 h348 Section", collect(["Handling", "Tyres", "Brakes"], translate))
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

		loop 36
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
	}
	else if ((commandOrAnalyzer == "Activate") && (state = "Clean")) {
		cleanValues := analyzer.Issues

		analyzer.stopTelemetryAnalyzer()

		infoText.Text := translate("Drive at least two consecutive hard laps and provoke under- and oversteering to the max but stay on the track. Then press `"Finish`".")
		activateButton.Text := translate("Finish")

		state := "Push"

		analyzer.startTelemetryAnalyzer(true)
	}
	else if ((commandOrAnalyzer == "Activate") && (state = "Push")) {
		overValues := analyzer.Issues

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
					for ignore, where in ["Entry", "Apex", "Exit"]
						for ignore, issue in result[1][type . ".Corner." . where . "." . speed] {
							value := issue.Value

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
					for ignore, where in ["Entry", "Apex", "Exit"]
						for ignore, issue in result[2][type . ".Corner." . where . "." . speed] {
							value := issue.Value

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