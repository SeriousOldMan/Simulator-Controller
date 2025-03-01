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

	iSecondMonitorTask := false

	class SecondMonitorRESTProvider {
		iTelemetryCollector := false
		iEndpointURL := false

		iLoadedLaps := Map()

		TelemetryCollector {
			Get {
				return this.iTelemetryCollector
			}
		}

		EndpointURL {
			Get {
				return this.iEndpointURL
			}
		}

		LoadedLaps {
			Get {
				return this.iLoadedLaps
			}
		}

		__New(collector, endpointURL) {
			try {
				if (SubStr(endpointURL, StrLen(endpointURL), 1) != "/")
					endpointURL .= "/"
			}
			catch Any as exception {
				logError(exception)
			}

			this.iTelemetryCollector := collector
			this.iEndpointURL := endpointURL
		}

		read(endpoint, type := "JSON") {
			local data

			try {
				data := WinHttpRequest({Timeouts: [0, 500, 500, 500]}).GET(this.EndpointURL . endpoint, "", false, {Encoding: "UTF-8"})

				return ((type = "JSON") ? data.JSON : data.Text)
			}
			catch Any as exception {
				logError(exception)

				data := false
			}

			return data
		}

		availableLaps() {
			local laps := []
			local lastLap

			try {
				info := this.read("DriversInfo")

				loop choose(info, (di) => di["isPlayer"])[1]["completedLaps"]
					if !this.LoadedLaps.Has(A_Index)
						laps.Push(A_Index)
			}
			catch Any as exception {
				logError(exception)
			}

			return laps
		}

		loadLaps() {
			do(this.availableLaps(), (lap) => this.loadLap(lap))
		}

		loadLap(lap) {
			local inputFileName, importFileName, text, pid

			lap := Integer(lap)

			inputFileName := temporaryFileName("Telemetry", "json")
			importFileName := (normalizeDirectoryPath(this.TelemetryCollector.TelemetryDirectory)
							 . "\Lap " . lap . ".telemetry")

			deleteFile(inputFileName)
			deleteFile(importFileName)

			try {
				text := this.read("TelemetryInfo/GetForPlayerAndLap?lapNumber=" . lap, "Text")

				if (!text || (Trim(text) = ""))
					throw "Empty data received in TelemetryCollector.SecondMonitorRESTProvider.loadLap..."

				FileAppend(text, inputFileName)

				Run("`"" . kBinariesDirectory . "Connectors\Second Monitor Reader\Second Monitor Reader.exe`" `"" . inputFileName . "`" `"" . importFileName . "`"", , "Hide", &pid)

				Sleep(500)

				count := 0

				while (ProcessExist(pid) && (count++ < 100))
					Sleep(100)

				this.LoadedLaps[lap] := lap

				return importFileName
			}
			catch Any as exception {
				logError(exception)
			}
			finally {
				deleteFile(inputFileName)
			}
		}

		loadSection(startTime) {
			local directory := (normalizeDirectoryPath(this.TelemetryCollector.TelemetryDirectory) . "\")
			local inputFileName := temporaryFileName("Telemetry", "json")
			local importFileName := temporaryFileName("Import", "telemetry")
			local text, pid

			deleteFile(inputFileName)
			deleteFile(importFileName)

			try {
				text := this.read("TelemetryInfo/GetForPlayerSinceTime?sessionTimeSeconds=" . startTime, "Text")

				if (!text || (Trim(text) = ""))
					throw "Empty data received in TelemetryCollector.SecondMonitorRESTProvider.loadSection..."

				FileAppend(text, inputFileName)

				Run("`"" . kBinariesDirectory . "Connectors\Second Monitor Reader\Second Monitor Reader.exe`" `"" . inputFileName . "`" `"" . importFileName . "`"", , "Hide", &pid)

				Sleep(500)

				count := 0

				while (ProcessExist(pid) && (count++ < 100))
					Sleep(100)

				return importFileName
			}
			catch Any as exception {
				logError(exception)

				return false
			}
			finally {
				deleteFile(inputFileName)
			}
		}
	}

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

			Set {
				if value
					this.Collected := true

				return (this.iFileName := value)
			}
		}

		Collected {
			Get {
				return this.iCollected
			}

			Set {
				return (this.iCollected := value)
			}
		}

		__New(collector) {
			this.iTelemetryCollector := collector
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
		}
	}

	class IntegratedTelemetryFuture extends TelemetryCollector.TelemetryFuture {
		__New(collector) {
			super.__New(collector)

			local directory := (normalizeDirectoryPath(collector.TelemetryDirectory) . "\")

			if FileExist(directory . "Telemetry.cmd")
				throw "Partial telemetry collection still running in TelemetryCollector.IntegratedTelemetryFuture.__New..."
			else {
				deleteFile(directory . "\Telemetry.section")

				FileAppend("COLLECT", directory . "\Telemetry.cmd")
			}
		}

		stop() {
			local directory, inFileName, outFileName

			if !this.Collected {
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

					this.FileName := outFileName
				}

				this.Collected := true
			}
		}
	}

	class SecondMonitorTelemetryFuture extends TelemetryCollector.TelemetryFuture {
		iSecondMonitorProvider := false
		iStartTime := false

		__New(collector) {
			super.__New(collector)

			this.iSecondMonitorProvider := TelemetryCollector.SecondMonitorRESTProvider(collector, collector.ProviderURL)

			try {
				this.iStartTime := this.iSecondMonitorProvider.read("SessionInfo")["sessionIdentification"]["sessionTimeInSeconds"]
			}
			catch Any as exception {
				logError(exception)
			}
		}

		stop() {
			local directory, inFileName, outFileName

			if !this.Collected {
				this.FileName := this.iSecondMonitorProvider.loadSection(this.iStartTime)

				this.Collected := true
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
		else {
			if (this.iSecondMonitorTask && restart)
				this.shutdown(true)

			if !this.iSecondMonitorTask {
				this.iSecondMonitorTask := PeriodicTask(ObjBindMethod(TelemetryCollector.SecondMonitorRESTProvider(this, this.ProviderURL)
																	, "loadLaps")
													  , 5000, kLowPriority)

				this.iSecondMonitorTask.start()

				return true
			}
			else
				return false
		}
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
		else if (this.Provider = "Second Monitor")
			if this.iSecondMonitorTask {
				this.iSecondMonitorTask.stop()

				this.iSecondMonitorTask := false
			}

		return false
	}

	collectTelemetry() {
		if (this.Provider = "Integrated")
			return TelemetryCollector.IntegratedTelemetryFuture(this)
		else
			return TelemetryCollector.SecondMonitorTelemetryFuture(this)
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