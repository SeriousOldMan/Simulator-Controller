;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Generic Telemetry Analyzer      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Task.ahk
#Include ..\Libraries\Math.ahk
#Include ..\Assistants\Libraries\SessionDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kClose := "close"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; GenericTelemetryAnalyzer                                              ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class GenericTelemetryAnalyzer extends TelemetryAnalyzer {
	iCar := false

	iUndersteerThresholds := [12, 16, 20]
	iOversteerThresholds := [2, -4, -12]
	iLowspeedThreshold := 100

	iSteerLock := 900
	iSteerRatio := 12

	iAnalyzerPID := false

	Car[] {
		Get {
			return this.iCar
		}
	}

	UndersteerThresholds[key := false] {
		Get {
			return (key ? this.iUndersteerThresholds[key] : this.iUndersteerThresholds)
		}

		Set {
			if key {
				this.iUndersteerThresholds[key] := value

				setAnalyzerSetting(this, "UndersteerThresholds" . code, values2String(",", this.iUndersteerThresholds*))

				return value
			}
			else {
				setAnalyzerSetting(this, "UndersteerThresholds", values2String(",", value*))

				return (this.iUndersteerThresholds := value)
			}
		}
	}

	OversteerThresholds[key := false] {
		Get {
			return (key ? this.iOversteerThresholds[key] : this.iOversteerThresholds)
		}

		Set {
			if key {
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

	LowspeedThreshold[] {
		Get {
			return this.iLowspeedThreshold
		}

		Set {
			setAnalyzerSetting(this, "LowspeedThreshold", value)

			return (this.iLowspeedThreshold := value)
		}
	}

	SteerLock[] {
		Get {
			return this.iSteerLock
		}

		Set {
			setAnalyzerSetting(this, "SteerLock", value)

			return (this.iSteerLock := value)
		}
	}

	SteerRatio[] {
		Get {
			return this.iSteerRatio
		}

		Set {
			setAnalyzerSetting(this, "SteerRatio", value)

			return (this.iSteerRatio := value)
		}
	}

	__New(advisor, simulator) {
		local selectedCar := advisor.SelectedCar[false]
		local fileName, configuration, settings, prefix

		simulator := new SessionDatabase().getSimulatorName(simulator)

		if (selectedCar == true)
			selectedCar := false

		this.iCar := selectedCar

		settings := readConfiguration(kUserConfigDirectory . "Application Settings.ini")

		prefix := (simulator . "." . (selectedCar ? selectedCar : "*") . ".")

		this.iSteerLock := getConfigurationValue(settings, "Setup Advisor", prefix . "SteerLock", 900)

		if selectedCar {
			fileName := getFileName("Advisor\Definitions\Cars\" . simulator . "." . selectedCar . ".ini", kResourcesDirectory, kUserHomeDirectory)

			if FileExist(fileName) {
				configuration := readConfiguration(fileName)

				this.iSteerLock := getConfigurationValue(configuration, "Setup.General", "SteerLock", this.iSteerLock)
			}
		}

		this.iUndersteerThresholds := string2Values(",", getConfigurationValue(settings, "Setup Advisor"
																					   , prefix . "UndersteerThresholds", "12,16,20"))
		this.iOversteerThresholds := string2Values(",", getConfigurationValue(settings, "Setup Advisor"
																					  , prefix . "OversteerThresholds", "2,-4,-12"))
		this.iLowspeedThreshold := getConfigurationValue(settings, "Setup Advisor", prefix . "LowspeedThreshold", 100)
		this.iSteerRatio := getConfigurationValue(settings, "Setup Advisor", prefix . "SteerRatio", 12)

		base.__New(advisor, simulator)

		OnExit(ObjBindMethod(this, "stopTelemetryAnalyzer", true))
	}

	createCharacteristics(telemetry := false) {
		local advisor, severities, count, maxValue
		local characteristicLabels, characteristic, characteristics, ignore, type, severity, speed, key, value

		if telemetry {
			advisor := this.Advisor
			characteristicLabels := getConfigurationSectionValues(advisor.Definition, "Setup.Characteristics.Labels")
			severities := {Light: 33, Medium: 50, Heavy: 66}
			characteristics := {}
			count := 0
			maxValue := 0

			advisor.clearCharacteristics()

			advisor.ProgressCount := 0

			showProgress({color: "Green", width: 350, title: translate("Loading Problems"), message: translate("Preparing Characteristics...")})

			for ignore, type in ["Oversteer", "Understeer"]
				for ignore, speed in ["Slow", "Fast"]
					for ignore, severity in ["Light", "Medium", "Heavy"]
						for ignore, key in ["Entry", "Apex", "Exit"]
							maxValue := Max(maxValue, getConfigurationValue(telemetry, type . "." . speed . "." . severity, key, 0))

			for ignore, type in ["Oversteer", "Understeer"]
				for ignore, speed in ["Slow", "Fast"]
					for ignore, severity in ["Light", "Medium", "Heavy"]
						for ignore, key in ["Entry", "Apex", "Exit"] {
							value := getConfigurationValue(telemetry, type . "." . speed . "." . severity, key, false)

							if value {
								characteristic := (type . ".Corner." . key . "." . speed)

								if !characteristics.HasKey(characteristic)
									characteristics[characteristic] := [Round(value / maxValue * 66), severities[severity]]
								else {
									characteristic := characteristics[characteristic]

									characteristic[1] := Max(characteristic[1], Round(value / maxValue * 66))
									characteristic[2] := Max(characteristic[2], severities[severity])
								}
							}
						}

			Sleep 500

			for characteristic, value in characteristics {
				showProgress({progress: (advisor.ProgressCount += 10), message: translate("Load ") . characteristicLabels[characteristic] . translate("...")})

				advisor.addCharacteristic(characteristic, value[1], value[2], false)
			}

			advisor.updateRecommendations()

			advisor.updateState()

			showProgress({progress: 100, message: translate("Finished...")})

			Sleep 500

			hideProgress()
		}
		else {
			telemetry := runAnalyzer(this)

			if telemetry
				Task.startTask(ObjBindMethod(this, "createCharacteristics", telemetry), 100)
		}
	}

	startTelemetryAnalyzer(dataFile) {
		local pid, options, code, message

		this.stopTelemetryAnalyzer()

		if !this.iAnalyzerPID {
			try {
				options := ("-Analyze """ . dataFile . """")
				options .= (A_Space . values2String(A_Space, this.UndersteerThresholds*))
				options .= (A_Space . values2String(A_Space, this.OversteerThresholds*))
				options .= (A_Space . this.LowspeedThreshold)
				options .= (A_Space . this.SteerLock)
				options .= (A_Space . this.SteerRatio)

				code := new SessionDatabase().getSimulatorCode(this.Simulator)

				Run %kBinariesDirectory%%code% SHM Spotter.exe %options%, %kBinariesDirectory%, UserErrorLevel Hide, pid
			}
			catch exception {
				message := substituteVariables(translate("Cannot start %simulator% %protocol% Spotter (%exePath%) - please check the configuration...")
													   , {simulator: code, protocol: "SHM", exePath: kBinariesDirectory . code . " SHM Spotter.exe"})

				logMessage(kLogCritical, message)

				showMessage(message, translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

				pid := false
			}

			this.iAnalyzerPID := pid
		}
	}

	stopTelemetryAnalyzer() {
		local pid := this.iAnalyzerPID
		local tries

		if pid {
			tries := 5

			while (tries-- > 0) {
				Process Exist, %pid%

				if ErrorLevel {
					Process Close, %pid%

					Sleep 500
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
	local prefix := (analyzer.Simulator . "." . (car ? car : "*") . ".")
	local settings := readConfiguration(kUserConfigDirectory . "Application Settings.ini")

	setConfigurationValue(settings, "Setup Advisor", prefix . key, value)

	writeConfiguration(kUserConfigDirectory . "Application Settings.ini", settings)
}

runAnalyzer(commandOrAnalyzer := false, arguments*) {
	local window, aWindow, x, y, ignore, widget, advisor
	local data, type, speed, severity, key, value, characteristic, characteristicLabels

	static activateButton

	static steerLockEdit
	static steerRatioEdit
	static lowspeedThresholdEdit
	static heavyOversteerThresholdSlider
	static mediumOversteerThresholdSlider
	static lightOversteerThresholdSlider
	static heavyUndersteerThresholdSlider
	static mediumUndersteerThresholdSlider
	static lightUndersteerThresholdSlider

	static resultListView
	static applyThresholdSlider

	static result := false
	static analyzer := false
	static state := "Prepare"
	static dataFile := false

	static prepareWidgets := []
	static runWidgets := []
	static analyzeWidgets := []

	if (commandOrAnalyzer == kCancel)
		result := kCancel
	else if ((commandOrAnalyzer == "Activate") && (state = "Prepare")) {
		GuiControlGet steerLockEdit
		GuiControlGet steerRatioEdit
		GuiControlGet lowspeedThresholdEdit
		GuiControlGet heavyOversteerThresholdSlider
		GuiControlGet mediumOversteerThresholdSlider
		GuiControlGet lightOversteerThresholdSlider
		GuiControlGet heavyUndersteerThresholdSlider
		GuiControlGet mediumUndersteerThresholdSlider
		GuiControlGet lightUndersteerThresholdSlider

		analyzer.SteerLock := steerLockEdit
		analyzer.SteerRatio := steerRatioEdit
		analyzer.LowspeedThreshold := lowspeedThresholdEdit
		analyzer.OversteerThresholds := [lightOversteerThresholdSlider, mediumOversteerThresholdSlider, heavyOversteerThresholdSlider]
		analyzer.UndersteerThresholds := [lightUndersteerThresholdSlider, mediumUndersteerThresholdSlider, heavyUndersteerThresholdSlider]

		dataFile := temporaryFileName("Analyzer", "data")

		for ignore, widget in prepareWidgets {
			GuiControl Disable, %widget%
			GuiControl Hide, %widget%
		}

		for ignore, widget in runWidgets
			GuiControl Show, %widget%

		GuiControl, , activateButton, % translate("Stop")

		state := "Run"

		analyzer.startTelemetryAnalyzer(dataFile)
	}
	else if ((commandOrAnalyzer == "Activate") && (state = "Run")) {
		analyzer.stopTelemetryAnalyzer()

		for ignore, widget in runWidgets {
			GuiControl Disable, %widget%
			GuiControl Hide, %widget%
		}

		for ignore, widget in analyzeWidgets
			GuiControl Show, %widget%

		GuiControl, , activateButton, % translate("Apply")

		runAnalyzer("UpdateTelemetry", runAnalyzer("FilterTelemetry"))

		state := "Analyze"
	}
	else if (commandOrAnalyzer == "Threshold")
		runAnalyzer("UpdateTelemetry", runAnalyzer("FilterTelemetry"))
	else if (commandOrAnalyzer == "FilterTelemetry") {
		GuiControlGet applyThresholdSlider

		data := readConfiguration(dataFile)

		for ignore, type in ["Oversteer", "Understeer"]
			for ignore, speed in ["Slow", "Fast"]
				for ignore, severity in ["Light", "Medium", "Heavy"]
					for ignore, key in ["Entry", "Apex", "Exit"] {
						value := getConfigurationValue(data, type . "." . speed . "." . severity, key, kUndefined)

						if ((value != kUndefined) && (value < applyThresholdSlider))
							setConfigurationValue(data, type . "." . speed . "." . severity, key, 0)
					}

		return data
	}
	else if (commandOrAnalyzer == "UpdateTelemetry") {
		advisor := analyzer.Advisor
		characteristicLabels := getConfigurationSectionValues(advisor.Definition, "Setup.Characteristics.Labels")
		data := arguments[1]

		Gui ListView, % resultListView

		LV_Delete()

		for ignore, type in ["Oversteer", "Understeer"]
			for ignore, speed in ["Slow", "Fast"]
				for ignore, severity in ["Light", "Medium", "Heavy"]
					for ignore, key in ["Entry", "Apex", "Exit"] {
						value := getConfigurationValue(data, type . "." . speed . "." . severity, key, false)

						if value {
							characteristic := (type . ".Corner." . key . "." . speed)

							LV_Add("", characteristicLabels[characteristic], translate(severity), value)
						}
					}

		LV_ModifyCol()

		loop 3
			LV_ModifyCol(A_Index, "AutoHdr")
	}
	else if ((commandOrAnalyzer == "Activate") && (state = "Analyze"))
		result := runAnalyzer("FilterTelemetry")
	else {
		analyzer := commandOrAnalyzer

		state := "Prepare"
		dataFile := false
		result := false

		prepareWidgets := []
		runWidgets := []
		analyzeWidgets := []

		aWindow := SetupAdvisor.Instance.Window
		window := "TAN"

		Gui %window%:New

		Gui %window%:Default

		Gui %window%:-Border ; -Caption
		Gui %window%:Color, D0D0D0, D8D8D8

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Text, w324 Center gmoveAnalyzer, % translate("Modular Simulator Controller System")

		Gui %window%:Font, s9 Norm, Arial
		Gui %window%:Font, Italic Underline, Arial

		Gui %window%:Add, Text, x78 YP+20 w184 cBlue Center gopenAnalyzerDocumentation, % translate("Telemetry Analyzer")

		Gui %window%:Font, s8 Norm, Arial

		Gui %window%:Add, Text, x16 yp+30 w180 h23 +0x200, % translate("Simulator")
		Gui %window%:Add, Text, x128 yp w180 h23 +0x200, % analyzer.Simulator

		Gui %window%:Add, Text, x16 yp+24 w100 h23 +0x200, % translate("Car")
		Gui %window%:Add, Text, x128 yp w100 h23 +0x200, % (analyzer.Car ? analyzer.Car : translate("Unknown"))

		Gui %window%:Add, Text, x16 yp+30 w100 h23 +0x200 Section HWNDwidget1, % translate("Steering Lock / Ratio")
		Gui %window%:Add, Edit, x128 yp w40 h23 +0x200 HWNDwidget2 vsteerLockEdit, % analyzer.SteerLock
		Gui %window%:Add, Edit, x173 yp w40 h23 Limit4 Number HWNDwidget3 vsteerRatioEdit, % analyzer.SteerRatio
		Gui %window%:Add, UpDown, x198 yp w18 h23 Range1-20 HWNDwidget4, % analyzer.SteerRatio

		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x16 yp+34 w320 h215 HWNDwidget5, % translate("Thresholds")

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x24 yp+21 w100 h23 +0x200 HWNDwidget6, % translate("Consider less than")
		Gui %window%:Add, Edit, x128 yp w35 h23 +0x200 HWNDwidget7 vlowspeedThresholdEdit, % analyzer.LowspeedThreshold
		Gui %window%:Add, Text, x167 yp w100 h23 +0x200 HWNDwidget8, % translate("km/h as low speed")

		Gui %window%:Add, Text, x24 yp+30 w100 h20 +0x200 HWNDwidget9, % translate("Heavy Oversteer")
		Gui %window%:Add, Slider, Center Thick15 x128 yp+2 w200 0x10 Range-25-25 ToolTip HWNDwidget10 vheavyOversteerThresholdSlider, % analyzer.OversteerThresholds[3]

		Gui %window%:Add, Text, x24 yp+22 w100 h20 +0x200 HWNDwidget11, % translate("Medium Oversteer")
		Gui %window%:Add, Slider, Center Thick15 x128 yp+2 w200 0x10 Range-25-25 ToolTip HWNDwidget12 vmediumOversteerThresholdSlider, % analyzer.OversteerThresholds[2]

		Gui %window%:Add, Text, x24 yp+22 w100 h20 +0x200 HWNDwidget13, % translate("Light Oversteer")
		Gui %window%:Add, Slider, Center Thick15 x128 yp+2 w200 0x10 Range-25-25 ToolTip HWNDwidget14 vlightOversteerThresholdSlider, % analyzer.OversteerThresholds[1]

		Gui %window%:Add, Text, x24 yp+30 w100 h20 +0x200 HWNDwidget15, % translate("Light Understeer")
		Gui %window%:Add, Slider, Center Thick15 x128 yp+2 w200 0x10 Range-25-25 ToolTip HWNDwidget16 vlightUndersteerThresholdSlider, % analyzer.UndersteerThresholds[1]

		Gui %window%:Add, Text, x24 yp+22 w100 h20 +0x200 HWNDwidget17, % translate("Medium Understeer")
		Gui %window%:Add, Slider, Center Thick15 x128 yp+2 w200 0x10 Range-25-25 ToolTip HWNDwidget18 vmediumUndersteerThresholdSlider, % analyzer.UndersteerThresholds[2]

		Gui %window%:Add, Text, x24 yp+22 w100 h20 +0x200 HWNDwidget19, % translate("Heavy Understeer")
		Gui %window%:Add, Slider, Center Thick15 x128 yp+2 w200 0x10 Range-25-25 ToolTip HWNDwidget20 vheavyUndersteerThresholdSlider, % analyzer.UndersteerThresholds[3]

		loop 20
			prepareWidgets.Push(widget%A_Index%)

		Gui %window%:Font, s14, Arial

		Gui %window%:Add, Text, x16 ys+40 w320 h200 HWNDwidget1 Wrap Hidden, % translate("Go to the track and run some decent laps. Then click on ""Stop"" to analyze the telemetry data.")

		Gui %window%:Font, Norm s8, Arial

		loop 1
			runWidgets.Push(widget%A_Index%)

		Gui %window%:Add, ListView, x16 ys w320 h200 -Multi -LV0x10 NoSort NoSortHdr HWNDwidget1 gnoSelect Hidden, % values2String("|", map(["Characteristic", "Intensity", "Frequency (%)"], "translate")*)

		resultListView := widget1

		Gui %window%:Add, Text, x16 yp+208 w100 h23 +0x200 HWNDwidget2 Hidden, % translate("Threshold")
		Gui %window%:Add, Slider, x128 yp w60 0x10 Range0-25 ToolTip HWNDwidget3 vapplyThresholdSlider gupdateThreshold Hidden, 0
		Gui %window%:Add, Text, x190 yp+3 HWNDwidget4 Hidden, % translate("%")

		loop 4
			analyzeWidgets.Push(widget%A_Index%)

		Gui %window%:Add, Button, x92 ys+260 w80 h23 Default vactivateButton gactivateAnalyzer, % translate("Start")
		Gui %window%:Add, Button, xp+100 yp w80 h23 gcancelAnalyzer, % translate("Cancel")

		Gui %window%:+Owner%aWindow%
		Gui %aWindow%:+Disabled

		try {
			if getWindowPosition("Setup Advisor.Analyzer", x, y)
				Gui %window%:Show, AutoSize x%x% y%y%
			else
				Gui %window%:Show, AutoSize Center

			while !result
				Sleep 100
		}
		finally {
			Gui %aWindow%:-Disabled

			if dataFile
				deleteFile(dataFile)
		}

		Gui %window%:Destroy

		return ((result == kCancel) ? false : result)
	}
}

noSelect() {
	loop % LV_GetCount()
		LV_Modify(A_Index, "-Select")
}

activateAnalyzer() {
	runAnalyzer("Activate")
}

cancelAnalyzer() {
	runAnalyzer(kCancel)
}

updateThreshold() {
	runAnalyzer("Threshold")
}

moveAnalyzer() {
	moveByMouse("TAN", "Setup Advisor.Analyzer")
}

openAnalyzerDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Advisor#real--time-telemetry-analyzer
}