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
;;;                       Public Constants Section                          ;;;
;;;-------------------------------------------------------------------------;;;

global kTelemetryChannels := [{Name: "Speed", Indices: [7], Size: 1, Channels: ["Speed"], Converter: [(s) => isNumber(s) ? convertUnit("Speed", s) : kNull]}
							, {Name: "Throttle", Indices: [2], Size: 0.5, Channels: ["Throttle"]}
							, {Name: "Brake", Indices: [3], Size: 0.5, Channels: ["Brake"]}
							, {Name: "Throttle/Brake", Indices: [2, 3], Size: 0.5, Channels: ["Throttle", "Brake"]}
							, {Name: "Steering", Indices: [4], Size: 0.8, Channels: ["Steering"]}
							, {Name: "TC", Indices: [8], Size: 0.3, Channels: ["TC"]}
							, {Name: "ABS", Indices: [9], Size: 0.3, Channels: ["ABS"]}
							, {Name: "TC/ABS", Indices: [8, 9], Size: 0.3, Channels: ["TC", "ABS"]}
							, {Name: "RPM", Indices: [6], Size: 0.5, Channels: ["RPM"]}
							, {Name: "Gear", Indices: [5], Size: 0.5, Channels: ["Gear"]}
							, {Name: "Long G", Indices: [10], Size: 1, Channels: ["Long G"]}
							, {Name: "Lat G", Indices: [11], Size: 1, Channels: ["Lat G"]}
							, {Name: "Long G/Lat G", Indices: [10, 11], Size: 1, Channels: ["Long G", "Lat G"]}
							, {Name: "Curvature", Function: computeCurvature, Indices: [false], Size: 1, Channels: ["Curvature"]}
							, {Name: "Time", Indices: [14], Size: 1, Channels: ["Time"], Converter: [(t) => isNumber(t) ? t / 1000 : kNull]}]


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class TelemetryCollector {
	iSimulator := false
	iTrack := false
	iTrackLength := false

	iTelemetryDirectory := false
	iTelemetryCollectorPID := false

	iExitCallback := false

	Simulator {
		Get {
			return this.iSimulator
		}
	}

	Track {
		Get {
			return this.iTrack
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

	__New(telemetryDirectory, simulator, track, trackLength) {
		this.iSimulator := simulator
		this.iTrack := track
		this.iTrackLength := trackLength
		this.iTelemetryDirectory := telemetryDirectory
	}

	startup(force := false) {
		local sessionDB := SessionDatabase()
		local code, exePath, pid, trackData

		if (this.iTelemetryCollectorPID && force)
			this.shutdown(true)

		if (this.iTelemetryCollectorPID && !ProcessExist(this.iTelemetryCollectorPID))
			this.iTelemetryCollectorPID := false

		if !this.iTelemetryCollectorPID {
			code := sessionDB.getSimulatorCode(this.iSimulator)
			exePath := (kBinariesDirectory . "Providers\" . code . " SHM Spotter.exe")
			pid := false

			try {
				if !FileExist(exePath)
					throw "File not found..."

				DirCreate(this.TelemetryDirectory)

				trackData := sessionDB.getTrackData(code, this.Track)

				Run("`"" . exePath . "`" -Telemetry " . this.iTrackLength
				  . " `"" . normalizeDirectoryPath(this.TelemetryDirectory) . "`"" . (trackData ? (" `"" . trackData . "`"") : "")
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

				if !this.iExitCallback {
					this.iExitCallback := ObjBindMethod(this, "shutdown", true)

					OnExit(this.iExitCallback)
				}

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


;;;-------------------------------------------------------------------------;;;
;;;                      Private Functions Section                          ;;;
;;;-------------------------------------------------------------------------;;;

computeCurvature(data) {
	local absG

	if data.Has(11) {
		absG := Abs(data[11])

		if (absG > 0.1)
			return - Log(((data[7] / 3.6) ** 2) / ((absG = 0) ? 0.00001 : absG))
		else
			return kNull
	}
	else
		return kNull
}