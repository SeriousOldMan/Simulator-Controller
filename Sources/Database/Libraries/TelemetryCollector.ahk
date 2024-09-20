;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Telemetry Collector             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class TelemetryCollector {
	iSimulator := false
	iTrackLength := false

	iTelemetryDirectory := false
	iTelemetryCollectorPID := false

	Simulator {
		Get {
			return this.iSimulator
		}
	}

	TrackLength {
		Get {
			return this.iTrackLength
		}
	}

	TelemetryDirectory {
		Get {
			return this.iTelemetryDirectory
		}
	}

	__New(telemetryDirectory, simulator, trackLength) {
		this.iTelemetryDirectory := telemetryDirectory

		OnExit(ObjBindMethod(this, "shutdown", true))
	}

	startup(force := false) {
		local code, exePath, pid

		if (this.iTelemetryCollectorPID && force)
			this.shutdown(true)

		if !this.iTelemetryCollectorPID {
			code := SessionDatabase.getSimulatorCode(this.iSimulator)
			exePath := (kBinariesDirectory . "Providers\" . code . " SHM Spotter.exe")
			pid := false

			try {
				if !FileExist(exePath)
					throw "File not found..."

				Run("`"" . exePath . "`" -Telemetry " . this.iTrackLength . " `"" . normalizeDirectoryPath(this.TelemetryDirectory) . "`""
				  , kBinariesDirectory, "Hide", &pid)
			}
			catch Any as exception {
				logError(exception, true)

				logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Spotter (")
														   , {simulator: code, protocol: "SHM"})
									   . exePath . translate(") - please rebuild the applications in the binaries folder (")
									   . kBinariesDirectory . translate(")"))

				showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Spotter (%exePath%) - please check the configuration...")
											  , {exePath: exePath, simulator: code, protocol: "SHM"})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}

			if pid {
				this.iTelemetryCollectorPID := pid

				return true
			}
			else
				return false
		}
		else
			return true
	}

	shutdown(force := false, arguments*) {
		local pid := this.iTelemetryCollectorPID
		local tries

		if ((arguments.Length > 0) && inList(["Logoff", "Shutdown"], arguments[1]))
			return false

		if pid {
			ProcessClose(pid)

			if (force && ProcessExist(pid)) {
				Sleep(500)

				tries := 5

				while (tries-- > 0) {
					pid := ProcessExist(pid)

					if pid {
						ProcessClose(pid)

						Sleep(500)
					}
					else
						break
				}
			}

			this.iTelemetryCollectorPID := false
		}

		return false
	}
}