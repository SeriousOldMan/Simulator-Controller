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
	iSelectedCar := false

	iUndersteerThresholds := [12, 24, 36]
	iOversteerThresholds := [2, -4, -12]
	iLowspeedThreshold := 100

	iSteerLock := 900
	iSteerRatio := 14

	iAnalyzerPID := false
	iDataFile := false

	__New(advisor, simulator) {
		this.iSelectedCar := advisor.SelectedCar

		base.__New(advisor, simulator)
	}

	createCharacteristics() {
		local telemetry

		OnExit(ObjBindMethod(this, "shutdownTelemetryAnalyzer", true))

		try {
			this.startupTelemetryAnalyzer()

			analyzerPopup()

			if this.iDataFile {
				telemetry := readConfiguration(this.iDataFile)

				this.Advisor.clearCharacteristics()
			}
		}
		catch exception {
			logError(exception)
		}
		finally {
			this.shutdownTelemetryAnalyzer()
		}
	}

	startupTelemetryAnalyzer() {
		local dataFile, pid, options

		if (!this.iAnalyzerPID && this.Simulator) {
			dataFile := temporaryFileName("Telemetry", "data")

			deleteFile(dataFile)

			try {
				options := ("-Analyze """ . dataFile . """")
				options .= (A_Space . values2String(A_Space, this.iUndersteerThresholds*))
				options .= (A_Space . values2String(A_Space, this.iOversteerThresholds*))
				options .= (A_Space . this.iLowspeedThreshold)
				options .= (A_Space . this.iSteerLock)
				options .= (A_Space . this.iSteerRatio)

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

analyzerPopup(command := false) {
	local window, aWindow, x, y

	static result := false

	if (command == kClose)
		result := kClose
	else {
		aWindow := SetupAdvisor.Instance.Window
		window := "TAN"
		result := false

		Gui %window%:New

		Gui %window%:Default

		Gui %window%:-Border ; -Caption
		Gui %window%:Color, D0D0D0, D8D8D8

		Gui %window%:Font, Bold s10, Arial

		Gui %window%:Add, Text, x16 y16 w320 h23 Center gmoveAnalyzerPopup, % translate("Scanning telemetry data.")

		Gui %window%:Font, Norm s10, Arial

		Gui %window%:Add, Text, x16 y40 w320 h23 Center gmoveAnalyzerPopup, % translate("Go to the track and drive some laps.")

		Gui %window%:Font, Norm s8, Arial

		Gui %window%:Add, Button, x136 yp+30 w80 h23 Default gstopAnalyzer, % translate("Done")

		Gui %window%:+Owner%aWindow%
		Gui %aWindow%:+Disabled

		try {
			if getWindowPosition("Setup Advisor.Analyzer Popup", x, y)
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

		if (result == kClose)
			return false
	}
}

stopAnalyzer() {
	analyzerPopup(kClose)
}

moveAnalyzerPopup() {
	moveByMouse("TAN", "Setup Advisor.Analyzer Popup")
}

