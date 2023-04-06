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

	iAnalyzerPID := false

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

	__New(workbench, simulator) {
		local selectedCar := workbench.SelectedCar[false]
		local selectedTrack := workbench.SelectedTrack[false]
		local defaultUndersteerThresholds := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "UndersteerThresholds", "40,70,100")
		local defaultOversteerThresholds := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "OversteerThresholds", "-40,-70,-100")
		local defaultLowspeedThreshold := getMultiMapValue(workbench.SimulatorDefinition, "Analyzer", "LowspeedThreshold", 120)
		local fileName, configuration, settings, prefix

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
			fileName := getFileName("Workbench\Definitions\Cars\" . simulator . "." . selectedCar . ".ini", kResourcesDirectory, kUserHomeDirectory)

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

		defaultUndersteerThresholds := getMultiMapValue(settings, "Setup Workbench", prefix . "UndersteerThresholds", defaultUndersteerThresholds)
		defaultOversteerThresholds := getMultiMapValue(settings, "Setup Workbench", prefix . "OversteerThresholds", defaultOversteerThresholds)
		defaultLowspeedThreshold := getMultiMapValue(settings, "Setup Workbench", prefix . "LowspeedThreshold", defaultLowspeedThreshold)

		prefix := (simulator . "." . (selectedCar ? selectedCar : "*") . "." . (selectedTrack ? selectedTrack : "*") . ".")

		this.iSteerLock := getMultiMapValue(settings, "Setup Workbench", prefix . "SteerLock", this.SteerLock)
		this.iSteerRatio := getMultiMapValue(settings, "Setup Workbench", prefix . "SteerRatio", this.SteerRatio)
		this.iWheelbase := getMultiMapValue(settings, "Setup Workbench", prefix . "Wheelbase", this.Wheelbase)
		this.iTrackWidth := getMultiMapValue(settings, "Setup Workbench", prefix . "TrackWidth", this.TrackWidth)

		this.iUndersteerThresholds := string2Values(",", getMultiMapValue(settings, "Setup Workbench"
													   , prefix . "UndersteerThresholds", defaultUndersteerThresholds))
		this.iOversteerThresholds := string2Values(",", getMultiMapValue(settings, "Setup Workbench"
													  , prefix . "OversteerThresholds", defaultOversteerThresholds))
		this.iLowspeedThreshold := getMultiMapValue(settings, "Setup Workbench", prefix . "LowspeedThreshold", defaultLowspeedThreshold)

		super.__New(workbench, simulator)

		OnExit(ObjBindMethod(this, "stopTelemetryAnalyzer", true))
	}

	settingAvailable(setting) {
		return true
	}

	createCharacteristics(telemetry := false) {
		local workbench, severities, count, maxValue
		local characteristicLabels, characteristic, characteristics, ignore, type, severity, speed, key, value

		if telemetry {
			workbench := this.Workbench
			characteristicLabels := getMultiMapValues(workbench.Definition, "Setup.Characteristics.Labels")
			severities := CaseInsenseMap("Light", 33, "Medium", 50, "Heavy", 66)
			characteristics := CaseInsenseMap()
			count := 0
			maxValue := 0

			workbench.clearCharacteristics()

			workbench.ProgressCount := 0

			showProgress({color: "Green", width: 350, title: translate("Creating Problems"), message: translate("Preparing Characteristics...")})

			for ignore, type in ["Oversteer", "Understeer"]
				for ignore, speed in ["Slow", "Fast"]
					for ignore, severity in ["Light", "Medium", "Heavy"]
						for ignore, key in ["Entry", "Apex", "Exit"]
							maxValue := Max(maxValue, getMultiMapValue(telemetry, type . "." . speed . "." . severity, key, 0))

			for ignore, type in ["Oversteer", "Understeer"]
				for ignore, speed in ["Slow", "Fast"]
					for ignore, severity in ["Light", "Medium", "Heavy"]
						for ignore, key in ["Entry", "Apex", "Exit"] {
							value := getMultiMapValue(telemetry, type . "." . speed . "." . severity, key, false)

							if value {
								characteristic := (type . ".Corner." . key . "." . speed)

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
			telemetry := runAnalyzer(this)

			if telemetry
				Task.startTask(ObjBindMethod(this, "createCharacteristics", telemetry), 100)
		}
	}

	startTelemetryAnalyzer(dataFile, calibrate := false) {
		local pid, options, code, message

		this.stopTelemetryAnalyzer()

		if !this.iAnalyzerPID {
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

				code := SessionDatabase.getSimulatorCode(this.Simulator)

				Run(kBinariesDirectory . code . " SHM Spotter.exe " . options, kBinariesDirectory, "Hide", &pid)
			}
			catch Any as exception {
				message := substituteVariables(translate("Cannot start %simulator% %protocol% Spotter (%exePath%) - please check the configuration...")													   , {simulator: code, protocol: "SHM", exePath: kBinariesDirectory . code . " SHM Spotter.exe"})

				logMessage(kLogCritical, message)

				showMessage(message, translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

				pid := false
			}

			this.iAnalyzerPID := pid
		}
	}

	stopTelemetryAnalyzer(*) {
		local pid := this.iAnalyzerPID
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

			this.iAnalyzerPID := false
		}

		return false
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
	local tries, data, type, speed, severity, key, value, newValue, characteristic, characteristicLabels, fromEdit
	local calibration, theListView

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

	static issuesListView

	static resultListView
	static applyThresholdSlider

	static result := false
	static analyzer := false
	static state := "Prepare"
	static dataFile := false

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
		analyzerGui.Opt("+Disabled")

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
			analyzerGui.Opt("-Disabled")
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

		dataFile := temporaryFileName("Analyzer", "data")

		for ignore, widget in prepareWidgets {
			widget.Enabled := false
			widget.Visible := false
		}

		for ignore, widget in runWidgets
			widget.Visible := true

		activateButton.Text := translate("Stop")

		state := "Run"

		analyzer.startTelemetryAnalyzer(dataFile)

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
		tries := 10

		while (tries-- > 0) {
			data := readMultiMap(dataFile)

			if (data.Count > 0) {
				runAnalyzer("UpdateTelemetry", data)

				break
			}
			else
				Sleep(20)
		}
	}
	else if (commandOrAnalyzer == "FilterTelemetry") {
		workbench := analyzer.Workbench
		characteristicLabels := getMultiMapValues(workbench.Definition, "Setup.Characteristics.Labels")
		final := ((arguments.Length > 0) && arguments[1])

		data := readMultiMap(dataFile)

		for ignore, type in ["Oversteer", "Understeer"]
			for ignore, speed in ["Slow", "Fast"]
				for ignore, severity in ["Light", "Medium", "Heavy"]
					for ignore, key in ["Entry", "Apex", "Exit"] {
						value := getMultiMapValue(data, type . "." . speed . "." . severity, key, kUndefined)

						include := ((value != kUndefined) && (value >= applyThresholdSlider.Value))

						if (include && final) {
							include := false

							characteristic := characteristicLabels[type . ".Corner." . key . "." . speed]

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

						if !include
							setMultiMapValue(data, type . "." . speed . "." . severity, key, 0)
					}

		return data
	}
	else if (commandOrAnalyzer == "UpdateTelemetry") {
		workbench := analyzer.Workbench
		characteristicLabels := getMultiMapValues(workbench.Definition, "Setup.Characteristics.Labels")
		data := arguments[1]

		theListView := ((state = "Run") ? issuesListView : resultListView)

		theListView.Delete()

		for ignore, type in ["Oversteer", "Understeer"]
			for ignore, speed in ["Slow", "Fast"]
				for ignore, severity in ["Light", "Medium", "Heavy"]
					for ignore, key in ["Entry", "Apex", "Exit"] {
						value := getMultiMapValue(data, type . "." . speed . "." . severity, key, false)

						if value {
							characteristic := (type . ".Corner." . key . "." . speed)

							theListView.Add((state = "Analyze") ? "Check" : "", characteristicLabels[characteristic], translate(severity), value)
						}
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
		dataFile := false
		result := false

		prepareWidgets := []
		runWidgets := []
		analyzeWidgets := []

		analyzerGui := Window()

		analyzerGui.SetFont("s10 Bold", "Arial")

		analyzerGui.Add("Text", "w324 Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(analyzerGui, "Setup Workbench.Analyzer"))

		analyzerGui.SetFont("s9 Norm", "Arial")
		analyzerGui.SetFont("Italic Underline", "Arial")

		analyzerGui.Add("Text", "x78 YP+20 w184 cBlue Center", translate("Telemetry Analyzer")).OnEvent("Click", openDocumentation.Bind(analyzerGui, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench#real-time-telemetry-analyzer"))

		analyzerGui.SetFont("s8 Norm", "Arial")

		analyzerGui.Add("Text", "x16 yp+30 w130 h23 +0x200", translate("Simulator"))
		analyzerGui.Add("Text", "x158 yp w180 h23 +0x200", analyzer.Simulator)

		analyzerGui.Add("Text", "x16 yp+24 w130 h23 +0x200", translate("Car"))
		analyzerGui.Add("Text", "x158 yp w180 h23 +0x200", (analyzer.Car ? analyzer.Car : translate("Unknown")))

		if analyzer.Track {
			analyzerGui.Add("Text", "x16 yp+24 w130 h23 +0x200", translate("Track"))
			analyzerGui.Add("Text", "x158 yp w180 h23 +0x200", SessionDatabase.getTrackName(analyzer.Simulator, analyzer.Track))
		}

		widget1 := analyzerGui.Add("Text", "x16 yp+30 w130 h23 +0x200 Section", translate("Steering Lock / Ratio"))
		steerLockEdit := analyzerGui.Add("Edit", "x158 yp w45 h23 +0x200", analyzer.SteerLock)
		widget2 := steerLockEdit
		steerRatioEdit := analyzerGui.Add("Edit", "x208 yp w45 h23 Limit2 Number", analyzer.SteerRatio)
		widget3 := steerRatioEdit
		widget4 := analyzerGui.Add("UpDown", "x238 yp w18 h23 Range1-99", analyzer.SteerRatio)

		widget27 := analyzerGui.Add("Text", "x16 yp+30 w130 h23 +0x200", translate("Wheelbase / Track Width"))
		wheelbaseEdit := analyzerGui.Add("Edit", "x158 yp w45 h23 +0x200 Number Limit3", analyzer.Wheelbase)
		widget29 := analyzerGui.Add("UpDown", "x188 yp w18 h23 Range1-999", analyzer.Wheelbase)
		trackWidthEdit := analyzerGui.Add("Edit", "x208 yp w45 h23 +0x200 Number Limit3", analyzer.TrackWidth)
		widget30 := trackWidthEdit
		widget31 := analyzerGui.Add("UpDown", "x238 yp w18 h23 Range1-999", analyzer.TrackWidth)
		widget32 := analyzerGui.Add("Text", "x257 yp w50 h23 +0x200", translate("cm"))

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

		widget5 := analyzerGui.Add("GroupBox", "-Theme x16 yp+34 w320 h215", translate("Thresholds"))

		analyzerGui.SetFont("Norm", "Arial")

		widget6 := analyzerGui.Add("Text", "x24 yp+21 w130 h23 +0x200", translate("Consider less than"))
		lowspeedThresholdEdit := analyzerGui.Add("Edit", "x158 yp w45 h23 +0x200 Number Limit3", analyzer.LowspeedThreshold)
		widget7 := lowspeedThresholdEdit
		widget33 := analyzerGui.Add("UpDown", "x188 yp w18 h23 Range1-999", analyzer.LowspeedThreshold)
		widget8 := analyzerGui.Add("Text", "x207 yp w120 h23 +0x200", translate("km/h as low speed"))

		if !analyzer.settingAvailable("LowspeedThreshold") {
			lowspeedThresholdEdit.Enabled := false
			lowspeedThresholdEdit.Text := ""
		}

		widget9 := analyzerGui.Add("Text", "x24 yp+30 w130 h20 +0x200", translate("Heavy Oversteer"))
		heavyOversteerThresholdSlider := analyzerGui.Add("Slider", "Center Thick15 x158 yp+2 w132 0x10 Range" . kMinThreshold . "-" . kMaxThreshold . " ToolTip", analyzer.OversteerThresholds[3])
		heavyOversteerThresholdSlider.OnEvent("Change", runAnalyzer.Bind("UpdateSlider"))
		widget10 := heavyOversteerThresholdSlider
		heavyOversteerThresholdEdit := analyzerGui.Add("Edit", "x293 yp w35 +0x200", analyzer.OversteerThresholds[3])
		heavyOversteerThresholdEdit.OnEvent("Change", runAnalyzer.Bind("UpdateSlider", true))
		widget21 := heavyOversteerThresholdEdit

		widget11 := analyzerGui.Add("Text", "x24 yp+22 w130 h20 +0x200", translate("Medium Oversteer"))
		mediumOversteerThresholdSlider := analyzerGui.Add("Slider", "Center Thick15 x158 yp+2 w132 0x10 Range" . kMinThreshold . "-" . kMaxThreshold . " ToolTip", analyzer.OversteerThresholds[2])
		mediumOversteerThresholdSlider.OnEvent("Change", runAnalyzer.Bind("UpdateSlider"))
		widget12 := mediumOversteerThresholdSlider
		mediumOversteerThresholdEdit := analyzerGui.Add("Edit", "x293 yp w35 +0x200", analyzer.OversteerThresholds[2])
		mediumOversteerThresholdEdit.OnEvent("Change", runAnalyzer.Bind("UpdateSlider", true))
		widget22 := mediumOversteerThresholdEdit

		widget13 := analyzerGui.Add("Text", "x24 yp+22 w130 h20 +0x200", translate("Light Oversteer"))
		lightOversteerThresholdSlider := analyzerGui.Add("Slider", "Center Thick15 x158 yp+2 w132 0x10 Range" . kMinThreshold . "-" . kMaxThreshold . " ToolTip", analyzer.OversteerThresholds[1])
		lightOversteerThresholdSlider.OnEvent("Change", runAnalyzer.Bind("UpdateSlider"))
		widget14 := lightOversteerThresholdSlider
		lightOversteerThresholdEdit := analyzerGui.Add("Edit", "x293 yp w35 +0x200", analyzer.OversteerThresholds[1])
		lightOversteerThresholdEdit.OnEvent("Change", runAnalyzer.Bind("UpdateSlider", true))
		widget23 := lightOversteerThresholdEdit

		widget15 := analyzerGui.Add("Text", "x24 yp+30 w130 h20 +0x200", translate("Light Understeer"))
		lightUndersteerThresholdSlider := analyzerGui.Add("Slider", "Center Thick15 x158 yp+2 w132 0x10 Range" . kMinThreshold . "-" . kMaxThreshold . " ToolTip", analyzer.UndersteerThresholds[1])
		lightUndersteerThresholdSlider.OnEvent("Change", runAnalyzer.Bind("UpdateSlider"))
		widget16 := lightUndersteerThresholdSlider
		lightUndersteerThresholdEdit := analyzerGui.Add("Edit", "x293 yp w35 +0x200", analyzer.UndersteerThresholds[1])
		lightUndersteerThresholdEdit.OnEvent("Change", runAnalyzer.Bind("UpdateSlider", true))
		widget24 := lightUndersteerThresholdEdit

		widget17 := analyzerGui.Add("Text", "x24 yp+22 w130 h20 +0x200", translate("Medium Understeer"))
		mediumUndersteerThresholdSlider := analyzerGui.Add("Slider", "Center Thick15 x158 yp+2 w132 0x10 Range" . kMinThreshold . "-" . kMaxThreshold . " ToolTip", analyzer.UndersteerThresholds[2])
		mediumUndersteerThresholdSlider.OnEvent("Change", runAnalyzer.Bind("UpdateSlider"))
		widget18 := mediumUndersteerThresholdSlider
		mediumUndersteerThresholdEdit := analyzerGui.Add("Edit", "x293 yp w35 +0x200", analyzer.UndersteerThresholds[2])
		mediumUndersteerThresholdEdit.OnEvent("Change", runAnalyzer.Bind("UpdateSlider", true))
		widget25 := mediumUndersteerThresholdEdit

		widget19 := analyzerGui.Add("Text", "x24 yp+22 w130 h20 +0x200", translate("Heavy Understeer"))
		heavyUndersteerThresholdSlider := analyzerGui.Add("Slider", "Center Thick15 x158 yp+2 w132 0x10 Range" . kMinThreshold . "-" . kMaxThreshold . " ToolTip", analyzer.UndersteerThresholds[3])
		heavyUndersteerThresholdSlider.OnEvent("Change", runAnalyzer.Bind("UpdateSlider"))
		widget20 := heavyUndersteerThresholdSlider
		heavyUndersteerThresholdEdit := analyzerGui.Add("Edit", "x293 yp w35 +0x200", analyzer.UndersteerThresholds[3])
		heavyUndersteerThresholdEdit.OnEvent("Change", runAnalyzer.Bind("UpdateSlider", true))
		widget26 := heavyUndersteerThresholdEdit

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

		loop 33
			if (A_Index != 28)
				prepareWidgets.Push(%"widget" . A_Index%)

		widget1 := analyzerGui.Add("ListView", "x16 ys w320 h190 -Multi -LV0x10 NoSort NoSortHdr  Hidden", collect(["Characteristic", "Intensity", "Frequency (%)"], translate))
		widget1.OnEvent("Click", noSelect)
		widget1.OnEvent("DoubleClick", noSelect)

		issuesListView := widget1

		analyzerGui.SetFont("s14", "Arial")

		widget2 := analyzerGui.Add("Text", "x16 ys+200 w320 h200 Wrap Hidden", translate("Go to the track and run some decent laps. Then click on `"Stop`" to analyze the telemetry data."))

		analyzerGui.SetFont("Norm s8", "Arial")

		loop 2
			runWidgets.Push(%"widget" . A_Index%)

		widget1 := analyzerGui.Add("ListView", "x16 ys w320 h230 -Multi -LV0x10 Checked NoSort NoSortHdr  Hidden", collect(["Characteristic", "Intensity", "Frequency (%)"], translate))
		widget1.OnEvent("Click", noSelect)
		widget1.OnEvent("DoubleClick", noSelect)

		resultListView := widget1

		widget2 := analyzerGui.Add("Text", "x16 yp+238 w130 h23 +0x200 Hidden", translate("Threshold"))
		applyThresholdSlider := analyzerGui.Add("Slider", "x158 yp w60 0x10 Range0-25 ToolTip Hidden", 0)
		applyThresholdSlider.OnEvent("Change", runAnalyzer.Bind("Threshold"))
		widget3 := applyThresholdSlider
		widget4 := analyzerGui.Add("Text", "x220 yp+3 Hidden", translate("%"))

		loop 4
			analyzeWidgets.Push(%"widget" . A_Index%)

		calibrateButton := analyzerGui.Add("Button", "x16 ys+290 w80 h23 ", translate("Calibrate..."))
		calibrateButton.OnEvent("Click", runAnalyzer.Bind("Calibrate"))
		activateButton := analyzerGui.Add("Button", "x158 yp w80 h23 Default", translate("Start"))
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
			if dataFile
				deleteFile(dataFile)

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
	local x, y, ignore, type, speed, key, value, variable

	static calibratorGui
	static activateButton
	static infoText

	static result := false
	static analyzer := false
	static state := "Start"
	static dataFile := false

	static cleanValues := CaseInsenseMap()
	static overValues := CaseInsenseMap()

	if (commandOrAnalyzer == kCancel) {
		analyzer.stopTelemetryAnalyzer()

		result := kCancel
	}
	else if ((commandOrAnalyzer == "Activate") && (state = "Start")) {
		infoText.Text := translate("Drive at least two consecutive clean laps without under- or oversteering the car. Then press `"Next`".")
		activateButton.Text := translate("Next")

		dataFile := temporaryFileName("Calibrator", "data")

		state := "Clean"

		analyzer.startTelemetryAnalyzer(dataFile, true)
	}
	else if ((commandOrAnalyzer == "Activate") && (state = "Clean")) {
		analyzer.stopTelemetryAnalyzer()

		cleanValues := readMultiMap(dataFile)

		infoText.Text := translate("Drive at least two consecutive hard laps and provoke under- and oversteering to the max but stay on the track. Then press `"Finish`".")
		activateButton.Text := translate("Finish")

		state := "Push"

		dataFile := temporaryFileName("Calibrator", "data")

		analyzer.startTelemetryAnalyzer(dataFile, true)
	}
	else if ((commandOrAnalyzer == "Activate") && (state = "Push")) {
		analyzer.stopTelemetryAnalyzer()

		overValues := readMultiMap(dataFile)

		result := [cleanValues, overValues]
	}
	else {
		analyzer := commandOrAnalyzer

		state := "Start"
		dataFile := false
		result := false

		cleanValues := CaseInsenseMap()
		overValues := CaseInsenseMap()

		calibratorGui := Window()

		calibratorGui.SetFont("s10 Bold", "Arial")

		calibratorGui.Add("Text", "w324 Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(calibratorGui, "Setup Workbench.Calibrator"))

		calibratorGui.SetFont("s9 Norm", "Arial")
		calibratorGui.SetFont("Italic Underline", "Arial")

		calibratorGui.Add("Text", "x78 YP+20 w184 cBlue Center", translate("Telemetry Analyzer")).OnEvent("Click", openDocumentation.Bind(calibratorGui, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench#real-time-telemetry-analyzer"))

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
			; if dataFile
			; 	deleteFile(dataFile)

			analyzer.stopTelemetryAnalyzer()
		}

		calibratorGui.Destroy()

		if (result != kCancel) {
			for ignore, type in ["Oversteer", "Understeer"] {
				variable := ("light" . type . "Threshold")

				for ignore, speed in ["Slow", "Fast"]
					for ignore, key in ["Entry", "Apex", "Exit"] {
						value := getMultiMapValue(result[1], type . "." . speed, key, kUndefined)

						if (value && (value != kUndefined))
							if (type = "Understeer")
								%variable% := Max(%variable%, value)
							else
								%variable% := Min(%variable%, value)
					}
			}

			for ignore, type in ["Oversteer", "Understeer"] {
				variable := ("heavy" . type . "Threshold")

				for ignore, speed in ["Slow", "Fast"]
					for ignore, key in ["Entry", "Apex", "Exit"] {
						value := getMultiMapValue(result[2], type . "." . speed, key, kUndefined)

						if (value && (value != kUndefined))
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