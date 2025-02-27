;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Telemetry Collector             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                       Public Constants Section                          ;;;
;;;-------------------------------------------------------------------------;;;

global kTelemetryChannels := [{Name: "Distance", Indices: [1], Channels: []}
							, {Name: "Speed", Indices: [7], Size: 1, Channels: ["Speed"], Converter: [(s) => isNumber(s) ? convertUnit("Speed", s) : kNull]}
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
							, {Name: "Lat G/Long G", Indices: [10, 11], Size: 1, Channels: ["Long G", "Lat G"]}
							, {Name: "Curvature", Function: computeCurvature, Indices: [false], Size: 1, Channels: ["Curvature"]}
							, {Name: "Time", Indices: [14], Size: 1, Channels: ["Time"], Converter: [(t) => isNumber(t) ? (t / 1000) : kNull]}
							, {Name: "PosX", Indices: [12], Channels: []}
							, {Name: "PosY", Indices: [13], Channels: []}]


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class TelemetryCollector {
	iProvider := "Integrated"
	iProviderURL := false

	iSimulator := false
	iTrack := false
	iTrackLength := false

	iTelemetryDirectory := false
	iTelemetryCollectorPID := false

	iExitCallback := false

	class TelemetryFuture {
		iTelemetryCollector := false
		iFileName := false

		iCollected := false

		TelemetryCollector {
			Get {
				return this.iTelemetryCollector
			}
		}

		FileName {
			Get {
				this.stop()

				return this.iFileName
			}
		}

		__New(collector) {
			local directory := (normalizeDirectoryPath(collector.TelemetryDirectory) . "\")

			this.iTelemetryCollector := collector

			if FileExist(directory . "Telemetry.cmd")
				throw "Partial telemetry collection still running in TelemetryCollector.TelemetryFuture.__New..."
			else {
				deleteFile(directory . "\Telemetry.section")

				FileAppend("COLLECT", directory . "\Telemetry.cmd")
			}
		}

		__Delete() {
			this.dispose()
		}

		dispose() {
			this.stop()

			if this.FileName
				deleteFile(this.FileName)
		}

		stop() {
			local directory, inFileName, outFileName

			if !this.iCollected {
				directory := (normalizeDirectoryPath(this.TelemetryCollector.TelemetryDirectory) . "\")
				inFileName := (directory . "Telemetry.section")
				outFileName := temporaryFileName("Telemetry", "section")

				deleteFile(directory . "Telemetry.cmd")

				if FileExist(inFileName) {
					loop
						try {
							FileMove(inFileName, outFileName, 1)

							break
						}
						catch Any as exception {
							logError(exception)

							Sleep(1)
						}

					this.iFileName := outFileName
				}

				this.iCollected := true
			}
		}
	}

	Provider {
		Get {
			return this.iProvider
		}
	}

	ProviderURL {
		Get {
			return this.iProviderURL
		}
	}

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

	__New(provider, telemetryDirectory, simulator, track, trackLength) {
		if (provider != "Integrated") {
			provider := string2Values("|", provider)

			this.iProvider := provider[1]

			if (provider.Length > 1)
				this.iProviderURL := provider[2]
		}

		this.iTelemetryDirectory := telemetryDirectory

		this.initialize(simulator, track, trackLength)
	}

	initialize(simulator, track, trackLength) {
		this.iSimulator := simulator
		this.iTrack := track
		this.iTrackLength := trackLength
	}

	startup(restart := false) {
		local sessionDB := SessionDatabase()
		local code, exePath, pid, trackData

		if (this.Provider = "Integrated") {
			if (this.iTelemetryCollectorPID && restart)
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

					if !kSilentMode
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
		else
			return false
	}

	shutdown(force := false, arguments*) {
		local pid := this.iTelemetryCollectorPID
		local tries

		if ((arguments.Length > 0) && inList(["Logoff", "Shutdown"], arguments[1]))
			return false

		if ((this.Provider = "Integrated") && pid) {
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

	collectTelemetry() {
		if (this.Provider = "Integrated")
			return TelemetryCollector.TelemetryFuture(this)
		else
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
			return - Log(((data[7] / 3.6) ** 2) / absG)
		else
			return kNull
	}
	else
		return kNull
}