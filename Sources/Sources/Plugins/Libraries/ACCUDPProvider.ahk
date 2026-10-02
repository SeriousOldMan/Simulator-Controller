;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - ACC UDP Provider                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Extensions\Task.ahk"
#Include "..\..\Framework\Extensions\JSON.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class ACCUDPProvider {
	iUDPClient := false
	iUDPConnection := false

	iExitCallback := false

	class StandingsDataFuture extends Task {
		iUDPProvider := false

		iRequested := false
		iTries := 0

		iStandingsData := kUndefined

		StandingsData {
			Get {
				local standingsData := this.iStandingsData

				while (standingsData == kUndefined) {
					Task.yield(false)

					standingsData := this.iStandingsData
				}

				return standingsData
			}
		}

		__New(udpProvider) {
			this.iUDPProvider := udpProvider

			super.__New(false, 0, kInterruptPriority)

			Task.startTask(this)
		}

		requestStandingsData() {
			loop 5
				try {
					FileAppend("Read`n", kTempDirectory . "ACCUDP.cmd")

					break
				}
				catch Any as exception {
					if (A_Index = 5)
						logError(exception)
					else
						Sleep(10)
				}
		}

		readStandingsData() {
			local fileName, standingsData

			if FileExist(kTempDirectory . "ACCUDP.cmd")
				return false
			else {
				fileName := (kTempDirectory . "ACCUDP.out")

				if !FileExist(fileName)
					return false
				else {
					standingsData := readMultiMap(fileName)

					deleteFile(fileName)

					return standingsData
				}
			}
		}

		run() {
			local standingsData

			if !this.iRequested {
				this.iUDPProvider.startup()

				this.requestStandingsData()

				this.iRequested := true

				return Task.CurrentTask
			}
			else {
				if (this.iTries++ <= 40) {
					standingsData := this.readStandingsData()

					if standingsData
						this.iStandingsData := standingsData
					else {
						Task.CurrentTask.Sleep := 50

						return Task.CurrentTask
					}
				}
				else
					this.iStandingsData := false
			}
		}
	}

	UDPConnection {
		Get {
			return this.iUDPConnection
		}
	}

	UDPClient {
		Get {
			return this.iUDPClient
		}
	}

	__New(udpConnection := false) {
		local accUdpConfig, udpConfig, udpConfigValid

		parseConfig(config) {
			config := JSON.parse(config)

			if ((config.Has("udpListenerPort") || config.Has("updListenerPort")) && config.Has("connectionPassword"))
				return config
			else
				throw "Invalid broadcasting configuration..."
		}

		this.iUDPConnection := udpConnection

		try
			FileCopy(kResourcesDirectory . "Simulator Data\ACC\broadcasting.json"
				   , A_MyDocuments . "\Assetto Corsa Competizione\Config\broadcasting.json", 1)

		if FileExist(A_MyDocuments . "\Assetto Corsa Competizione\Config\broadcasting.json") {
			try {
				try {
					try {
						try {
							try {
								accUdpConfig := parseConfig(FileRead(A_MyDocuments . "\Assetto Corsa Competizione\Config\broadcasting.json", "`n"))
							}
							catch Any {
								accUdpConfig := parseConfig(FileRead(A_MyDocuments . "\Assetto Corsa Competizione\Config\broadcasting.json", "`n CP0"))
							}
						}
						catch Any {
							try {
								accUdpConfig := parseConfig(FileRead(A_MyDocuments . "\Assetto Corsa Competizione\Config\broadcasting.json", "`n UTF-8"))
							}
							catch Any {
								accUdpConfig := parseConfig(FileRead(A_MyDocuments . "\Assetto Corsa Competizione\Config\broadcasting.json", "`n UTF-8-RAW"))
							}
						}
					}
					catch Any {
						try {
							accUdpConfig := parseConfig(FileRead(A_MyDocuments . "\Assetto Corsa Competizione\Config\broadcasting.json", "`n UTF-16"))
						}
						catch Any {
							accUdpConfig := parseConfig(FileRead(A_MyDocuments . "\Assetto Corsa Competizione\Config\broadcasting.json", "`n UTF-16-RAW"))
						}
					}
				}
				catch Any {
					accUdpConfig := parseConfig(StrReplace(StrGet(FileRead(A_MyDocuments . "\Assetto Corsa Competizione\Config\broadcasting.json", "Raw"))
														 , "`r`n", "`n"))
				}
			}
			catch Any as exception {
				logError(exception, true)

				accUdpConfig := CaseInsenseMap()
			}

			try {
				udpConfig := (this.iUDPConnection ? string2Values(",", this.iUDPConnection) : ["127.0.0.1", 9000, "asd", ""])

				if (udpConfig.Length = 3)
					udpConfig.Push("")

				if (accUdpConfig.Has("udpListenerPort") && (accUdpConfig["udpListenerPort"] = udpConfig[2]))
					udpConfigValid := true
				else if (accUdpConfig.Has("updListenerPort") && (accUdpConfig["updListenerPort"] = udpConfig[2]))
					udpConfigValid := true
				else
					udpConfigValid := false

				if (!accUdpConfig.Has("connectionPassword") || (accUdpConfig["connectionPassword"] != udpConfig[3]))
					udpConfigValid := false
				else if (accUdpConfig.Has("commandPassword") && (accUdpConfig["commandPassword"] != udpConfig[4]))
					udpConfigValid := false
			}
			catch Any as exception {
				logError(exception, true)

				udpConfigValid := false
			}

			if !udpConfigValid
				logMessage(kLogInfo, translate("The UDP configuration for Assetto Corsa Competizione is not valid - please consult the documentation for the ACC plugin"))
		}
	}

	acquire() {
		local exePath := (kBinariesDirectory . "Providers\ACC UDP Provider.exe")
		local fileName := temporaryFileName("Positions", "data")
		local options

		try {
			deleteFile(fileName)

			options := ""

			if this.UDPConnection
				options := ("-Connect " . this.UDPConnection)

			Run("`"" . exePath . "`" -Collect `"" . fileName . "`" " . options, kBinariesDirectory, "Hide", &udpClient)

			if udpClient {
				while ProcessExist(udpClient)
					Sleep(100)

				return readMultiMap(fileName)
			}
		}
		catch Any as exception {
			logError(exception, true)

			logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider ("), {simulator: "ACC", protocol: "UDP"})
								   . exePath . translate(") - please rebuild the applications in the binaries folder (")
								   . kBinariesDirectory . translate(")"))

			if !kSilentMode
				showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration...")
											  , {exePath: exePath, simulator: "ACC", protocol: "UDP"})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
		finally {
			deleteFile(fileName)
		}
	}

	startup(force := false) {
		local exePath, options, udpClient

		if (this.UDPClient = "Starting")
			return

		if (!this.UDPClient || !ProcessExist("ACC UDP Provider.exe") || force) {
			if force
				this.shutdown(force)

			this.iUDPClient := "Starting"

			exePath := (kBinariesDirectory . "Providers\ACC UDP Provider.exe")

			try {
				if FileExist(kTempDirectory . "ACCUDP.cmd")
					deleteFile(kTempDirectory . "ACCUDP.cmd")

				if FileExist(kTempDirectory . "ACCUDP.out")
					deleteFile(kTempDirectory . "ACCUDP.out")

				options := ""

				if this.UDPConnection
					options := ("-Connect " . this.UDPConnection)

				Run("`"" . exePath . "`" -Persistent `"" . kTempDirectory . "ACCUDP.cmd`" `"" . kTempDirectory . "ACCUDP.out`" " . options, kBinariesDirectory, "Hide", &udpClient)

				if udpClient {
					this.iUDPClient := udpClient

					if !this.iExitCallback {
						this.iExitCallback := ObjBindMethod(this, "shutdown", true)

						OnExit(this.iExitCallback)
					}
				}
			}
			catch Any as exception {
				logError(exception, true)

				logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider ("), {simulator: "ACC", protocol: "UDP"})
									   . exePath . translate(") - please rebuild the applications in the binaries folder (")
									   . kBinariesDirectory . translate(")"))

				if !kSilentMode
					showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration...")
												  , {exePath: exePath, simulator: "ACC", protocol: "UDP"})
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

				this.iUDPClient := false
			}
		}
	}

	shutdown(force := false, arguments*) {
		if ((arguments.Length > 0) && inList(["Logoff", "Shutdown"], arguments[1]))
			return false

		if ((this.UDPClient || force) && ProcessExist("ACC UDP Provider.exe")) {
			loop 5 {
				try {
					FileAppend("Exit`n", kTempDirectory . "ACCUDP.cmd")
				}
				catch Any as exception {
					if (A_Index = 5)
						logError(exception)
				}

				Sleep(250)

				if !ProcessExist("ACC UDP Provider.exe")
					break
			}

			if (this.UDPClient && isNumber(this.UDPClient) && ProcessExist(this.UDPClient))
				ProcessClose(this.UDPClient)

			this.iUDPClient := false
		}

		return false
	}

	getStandingsDataFuture(restart := false) {
		if restart
			this.startup(true)

		return ACCUDPProvider.StandingsDataFuture(this)
	}
}