;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Telemetry Analyzer for ACC      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Math.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kClose := "close"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ACCTelemetryAnalyzer                                                    ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ACCTelemetryAnalyzer extends TelemetryAnalyzer {
	iCar := false

	iUndersteerThresholds := [12, 16, 20]
	iOversteerThresholds := [2, -4, -12]
	iLowspeedThreshold := 100

	iSteerLock := 900
	iSteerRatio := 12

	iAnalyzerPID := false
	iDataFile := false

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

				setAnalyzerSetting("ACCUndersteerThresholds", values2String(",", this.iUndersteerThresholds*))

				return value
			}
			else {
				setAnalyzerSetting("ACCUndersteerThresholds", values2String(",", value*))

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

				setAnalyzerSetting("ACCOversteerThresholds", values2String(",", this.iOversteerThresholds*))

				return value
			}
			else {
				setAnalyzerSetting("ACCOversteerThresholds", values2String(",", value*))

				return (this.iOversteerThresholds := value)
			}
		}
	}

	LowspeedThreshold[] {
		Get {
			return this.iLowspeedThreshold
		}

		Set {
			setAnalyzerSetting("ACCLowspeedThreshold", value)

			return (this.iLowspeedThreshold := value)
		}
	}

	SteerLock[] {
		Get {
			return this.iSteerLock
		}

		Set {
			setAnalyzerSetting("ACCSteerLock", value)

			return (this.iSteerLock := value)
		}
	}

	SteerRatio[] {
		Get {
			return this.iSteerRatio
		}

		Set {
			setAnalyzerSetting("ACCSteerRatio", value)

			return (this.iSteerRatio := value)
		}
	}

	__New(advisor, simulator) {
		local selectedCar := advisor.SelectedCar[false]
		local fileName, configuration, settings

		if (selectedCar == true)
			selectedCar := false

		this.iCar := selectedCar

		settings := readConfiguration(kUserConfigDirectory . "Application Settings.ini")

		this.iSteerLock := getConfigurationValue(settings, "Setup Advisor", "ACCSteerLock", 900)

		if selectedCar {
			fileName := ("Advisor\Definitions\Cars\" . simulator . "." . selectedCar . ".ini")

			configuration := readConfiguration(getFileName(fileName, kResourcesDirectory, kUserHomeDirectory))

			this.iSteerLock := getConfigurationValue(configuration, "Setup.General", "SteerLock", this.iSteerLock)
		}

		this.iUndersteerThresholds := string2Values(",", getConfigurationValue(settings, "Setup Advisor"
																					   , "ACCUndersteerThresholds", "12,16,20"))
		this.iOversteerThresholds := string2Values(",", getConfigurationValue(settings, "Setup Advisor"
																					  , "ACCOversteerThresholds", "2,-4,-12"))
		this.iLowspeedThreshold := getConfigurationValue(settings, "Setup Advisor", "ACCLowspeedThreshold", 100)
		this.iSteerRatio := getConfigurationValue(settings, "Setup Advisor", "ACCSteerRatio", 12)

		base.__New(advisor, simulator)

		OnExit(ObjBindMethod(this, "shutdownTelemetryAnalyzer", true))
	}

	createCharacteristics() {
		local telemetry := runAnalyzer(this)

		if telemetry {
			this.Advisor.clearCharacteristics()
		}
	}

	startupTelemetryAnalyzer(dataFile) {
		local pid, options

		this.shutdownTelemetryAnalyzer()

		if !this.iAnalyzerPID {
			try {
				options := ("-Analyze """ . dataFile . """")
				options .= (A_Space . values2String(A_Space, this.UndersteerThresholds*))
				options .= (A_Space . values2String(A_Space, this.OversteerThresholds*))
				options .= (A_Space . this.LowspeedThreshold)
				options .= (A_Space . this.SteerLock)
				options .= (A_Space . this.SteerRatio)

				Run %kBinariesDirectory%ACC SHM Spotter.exe %options%, %kBinariesDirectory%, UserErrorLevel Hide, pid
			}
			catch exception {
				logMessage(kLogCritical, translate("Cannot start Track Mapper - please rebuild the applications..."))

				showMessage(translate("Cannot start Track Mapper - please rebuild the applications...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

				pid := false
				dataFile := false
			}

			this.iAnalyzerPID := pid
			this.iDataFile := dataFile
		}
	}

	shutdownTelemetryAnalyzer() {
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

		if this.iDataFile {
			deleteFile(this.iDataFile)

			this.iDataFile := false
		}

		return false
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                        Private Function Section                         ;;;
;;;-------------------------------------------------------------------------;;;

setAnalyzerSetting(key, value) {
	local settings := readConfiguration(kUserConfigDirectory . "Application Settings.ini")

	setConfigurationValue(settings, "Setup Advisor", key, value)

	writeConfiguration(kUserConfigDirectory . "Application Settings.ini", settings)
}

runAnalyzer(commandOrAnalyzer := false) {
	local window, aWindow, x, y

	static result := false
	static analyzer := false

	if (commandOrAnalyzer == kCancel)
		result := kCancel
	else {
		aWindow := SetupAdvisor.Instance.Window
		window := "TAN"
		result := false
		analyzer := commandOrAnalyzer

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

		Gui %window%:Add, Text, x16 yp+24 w100 h23 +0x200, % translate("Steering Lock / Ratio")
		Gui %window%:Add, Edit, x128 yp w40 h23 +0x200
		Gui %window%:Add, Edit, x173 yp w40 h23 Limit4 Number
		Gui %window%:Add, UpDown, x198 yp w18 h23 Range1-20

		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x16 yp+34 w320 h215, % translate("Thresholds")

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x24 yp+21 w100 h23 +0x200, % translate("Low Speed <")
		Gui %window%:Add, Edit, x128 yp w35 h23 +0x200
		Gui %window%:Add, Text, x167 yp w100 h23 +0x200, % translate("km/h")

		Gui %window%:Add, Text, x24 yp+30 w100 h20 +0x200, % translate("Heavy Oversteer")
		Gui %window%:Add, Slider, Center Thick15 x128 yp+2 w200 0x10 Range-25-25 ToolTip, % analyzer.OversteerThresholds[3]

		Gui %window%:Add, Text, x24 yp+22 w100 h20 +0x200, % translate("Normal Oversteer")
		Gui %window%:Add, Slider, Center Thick15 x128 yp+2 w200 0x10 Range-25-25 ToolTip, % analyzer.OversteerThresholds[2]

		Gui %window%:Add, Text, x24 yp+22 w100 h20 +0x200, % translate("Light Oversteer")
		Gui %window%:Add, Slider, Center Thick15 x128 yp+2 w200 0x10 Range-25-25 ToolTip, % analyzer.OversteerThresholds[1]

		Gui %window%:Add, Text, x24 yp+30 w100 h20 +0x200, % translate("Light Understeer")
		Gui %window%:Add, Slider, Center Thick15 x128 yp+2 w200 0x10 Range-25-25 ToolTip, % analyzer.UndersteerThresholds[1]

		Gui %window%:Add, Text, x24 yp+22 w100 h20 +0x200, % translate("Normal Understeer")
		Gui %window%:Add, Slider, Center Thick15 x128 yp+2 w200 0x10 Range-25-25 ToolTip, % analyzer.UndersteerThresholds[2]

		Gui %window%:Add, Text, x24 yp+22 w100 h20 +0x200, % translate("Heavy Understeer")
		Gui %window%:Add, Slider, Center Thick15 x128 yp+2 w200 0x10 Range-25-25 ToolTip, % analyzer.UndersteerThresholds[3]

		Gui %window%:Add, Button, x92 yp+50 w80 h23 Default, % translate("Start")
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
		}

		Gui %window%:Submit
		Gui %window%:Destroy

		if (result == kCancel)
			return false
		else {
		}
	}
}

cancelAnalyzer() {
	runAnalyzer(kCancel)
}

moveAnalyzer() {
	moveByMouse("TAN", "Setup Advisor.Analyzer")
}

openAnalyzerDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Advisor#telemetry-analyzer
}