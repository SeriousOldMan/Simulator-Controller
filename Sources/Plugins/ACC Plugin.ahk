;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - ACC Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Task.ahk"
#Include "..\Libraries\JSON.ahk"
#Include "..\Libraries\Math.ahk"
#Include "Libraries\SimulatorPlugin.ahk"
#Include "..\Database\Libraries\SettingsDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kACCApplication := "Assetto Corsa Competizione"

global kACCPlugin := "ACC"
global kChatMode := "Chat"


;;;-------------------------------------------------------------------------;;;
;;;                         Private Constant Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kPSMutatingOptions := ["Strategy", "Change Tyres", "Tyre Compound", "Change Brakes"]


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class ACCPlugin extends RaceAssistantSimulatorPlugin {
	static kUnknown := false

	iUDPClient := false
	iUDPConnection := false

	iSessionID := 0

	iOpenPitstopMFDHotkey := false
	iClosePitstopMFDHotkey := false

	iImageSearch := kUndefined

	iNoImageSearch := false
	iNextPitstopMFDOptionsUpdate := false

	iPSOptions := ["Pit Limiter", "Strategy", "Refuel"
				 , "Change Tyres", "Tyre Set", "Tyre Compound", "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right"
				 , "Change Brakes", "Front Brake", "Rear Brake", "Repair Suspension", "Repair Bodywork"]

	iPSTyreOptionPosition := inList(this.iPSOptions, "Change Tyres")
	iPSTyreOptions := 7
	iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")
	iPSBrakeOptions := 2

	iPSIsOpen := false
	iPSSelectedOption := 1
	iPSChangeTyres := false
	iPSChangeBrakes := false

	iOldChangeBrakes := false

	iLastTyreCompound := false

	iPSImageSearchArea := false

	iChatMode := false
	iPitstopMode := false

	iRepairSuspensionChosen := true
	iRepairBodyworkChosen := true

	iSelectedDriver := false

	iPositionsDataFuture := false

	static sCarData := false

	class PositionsDataFuture extends Task {
		iSimulator := false

		iRestart := false
		iRequested := false
		iTries := 0

		iPositionsData := kUndefined

		PositionsData {
			Get {
				local positionsData := this.iPositionsData

				while (positionsData == kUndefined) {
					Task.yield(false)

					positionsData := this.iPositionsData
				}

				return positionsData
			}
		}

		__New(simulator, restart := false) {
			this.iSimulator := simulator
			this.iRestart := false

			super.__New(false, 0, kInterruptPriority)

			Task.startTask(this)
		}

		requestPositionsData() {
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

		readPositionsData() {
			local fileName, positionsData

			if FileExist(kTempDirectory . "ACCUDP.cmd")
				return false
			else {
				fileName := (kTempDirectory . "ACCUDP.out")

				if !FileExist(fileName)
					return false
				else {
					positionsData := readMultiMap(fileName)

					deleteFile(fileName)

					return positionsData
				}
			}
		}

		run() {
			local positionsData

			if !this.iRequested {
				this.iSimulator.requireUDPClient(this.iRestart)

				this.requestPositionsData()

				this.iRequested := true

				return Task.CurrentTask
			}
			else {
				if (this.iTries++ <= 40) {
					positionsData := this.readPositionsData()

					if positionsData
						this.iPositionsData := positionsData
					else {
						Task.CurrentTask.Sleep := 50

						return Task.CurrentTask
					}
				}
				else
					this.iPositionsData := false
			}
		}
	}

	class ChatMode extends ControllerMode {
		Mode {
			Get {
				return kChatMode
			}
		}

		updateActions(session) {
		}
	}

	class ChatAction extends ControllerAction {
		iMessage := ""

		Message {
			Get {
				return this.iMessage
			}
		}

		__New(function, label, message) {
			this.iMessage := message

			super.__New(function, label)
		}

		fireAction(function, trigger) {
			local message := this.Message

			if this.Controller.findPlugin(kACCPlugin).activateWindow() {
				Send("{Enter}")
				Sleep(100)
				Send(message)
				Sleep(100)
				Send("{Enter}")
			}
		}
	}

	Car {
		Set {
			this.iImageSearch := kUndefined

			return (super.Car := value)
		}
	}

	Track {
		Set {
			this.iImageSearch := kUndefined

			return (super.Track := value)
		}
	}

	OpenPitstopMFDHotkey {
		Get {
			return this.iOpenPitstopMFDHotkey
		}
	}

	ClosePitstopMFDHotkey {
		Get {
			return this.iClosePitstopMFDHotkey
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

	__New(controller, name, simulator, configuration := false) {
		if !ACCPlugin.kUnknown
			ACCPlugin.kUnknown := translate("Unknown")

		super.__New(controller, name, simulator, configuration)

		if (this.Active || (isDebug() && isDevelopment())) {
			this.iPitstopMode := this.findMode(kPitstopMode)

			if this.iChatMode
				this.registerMode(this.iChatMode)

			if !inList(A_Args, "-Replay")
				this.iOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", false)
			else
				this.iOpenPitstopMFDHotkey := "Off"

			this.iClosePitstopMFDHotkey := this.getArgumentValue("closePitstopMFD", false)

			this.iUDPConnection := this.getArgumentValue("udpConnection", false)

			controller.registerPlugin(this)

			OnExit(ObjBindMethod(this, "shutdownUDPClient", true))
		}
	}

	loadFromConfiguration(configuration) {
		local function, descriptor, message

		super.loadFromConfiguration(configuration)

		for descriptor, message in getMultiMapValues(configuration, "Chat Messages") {
			function := this.Controller.findFunction(descriptor)

			if (function != false) {
				message := string2Values("|", message)

				if !this.iChatMode
					this.iChatMode := ACCPlugin.ChatMode(this)

				this.iChatMode.registerAction(ACCPlugin.ChatAction(function, message[1], message[2]))
			}
			else
				this.logFunctionNotFound(descriptor)
		}
	}

	getPitstopActions(&allActions, &selectActions) {
		allActions := CaseInsenseMap("Strategy", "Strategy", "NoRefuel", "No Refuel", "Refuel", "Refuel"
								   , "TyreChange", "Change Tyres", "TyreSet", "Tyre Set"
								   , "TyreCompound", "Tyre Compound", "TyreAllAround", "All Around"
								   , "TyreFrontLeft", "Front Left", "TyreFrontRight", "Front Right", "TyreRearLeft", "Rear Left", "TyreRearRight", "Rear Right"
								   , "BrakeChange", "Change Brakes", "FrontBrake", "Front Brake", "RearBrake", "Rear Brake", "DriverSelect", "Driver"
								   , "SuspensionRepair", "Repair Suspension", "BodyworkRepair", "Repair Bodywork")

		selectActions := ["NoRefuel", "TyreChange", "BrakeChange", "SuspensionRepair", "BodyworkRepair"]
	}

	static requireCarDatabase() {
		local data

		if !ACCPlugin.sCarData {
			data := readMultiMap(kResourcesDirectory . "Simulator Data\ACC\Car Data.ini")

			if FileExist(kUserHomeDirectory . "Simulator Data\ACC\Car Data.ini")
				addMultiMapValues(data, readMultiMap(kUserHomeDirectory . "Simulator Data\ACC\Car Data.ini"))

			ACCPlugin.sCarData := data
		}
	}

	simulatorStartup(simulator) {
		if (simulator = kACCApplication)
			Task.startTask(ObjBindMethod(ACCPlugin, "requireCarDatabase"), 1000, kLowPriority)

		super.simulatorStartup(simulator)
	}

	startupUDPClient(force := false) {
		local exePath, options, udpClient

		if (!this.UDPClient || force) {
			this.shutdownUDPClient(force)

			exePath := kBinariesDirectory . "Providers\ACC UDP Provider.exe"

			try {
				if FileExist(kTempDirectory . "ACCUDP.cmd")
					deleteFile(kTempDirectory . "ACCUDP.cmd")

				if FileExist(kTempDirectory . "ACCUDP.out")
					deleteFile(kTempDirectory . "ACCUDP.out")

				options := ""

				if this.UDPConnection
					options := ("-Connect " . this.UDPConnection)

				Run("`"" . exePath . "`" `"" . kTempDirectory . "ACCUDP.cmd`" `"" . kTempDirectory . "ACCUDP.out`" " . options, kBinariesDirectory, "Hide", &udpClient)

				this.iUDPClient := udpClient
			}
			catch Any as exception {
				logError(exception, true)

				logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider ("), {simulator: "ACC", protocol: "UDP"})
									   . exePath . translate(") - please rebuild the applications in the binaries folder (")
									   . kBinariesDirectory . translate(")"))

				showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration...")
											  , {exePath: exePath, simulator: "ACC", protocol: "UDP"})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

				this.iUDPClient := false
			}
		}
	}

	shutdownUDPClient(force := false, *) {
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

			this.iUDPClient := false
		}

		return false
	}

	requireUDPClient(restart := false) {
		if !ProcessExist("ACC UDP Provider.exe")
			this.iUDPClient := false

		this.startupUDPClient(restart)
	}

	driverActive(data, driverForName, driverSurName) {
		return this.sessionActive(data)
	}

	updateSession(session, force := false) {
		local lastSession := this.Session
		local activeModes

		super.updateSession(session, force)

		activeModes := this.Controller.ActiveModes

		if (inList(activeModes, this.iChatMode))
			this.iChatMode.updateActions(session)

		if (inList(activeModes, this.iPitstopMode))
			this.iPitstopMode.updateActions(session)

		if (session == kSessionRace)
			this.requireUDPClient((lastSession != kSessionRace) && (lastSession != kSessionPaused))
		else {
			if (session == kSessionFinished) {
				this.iRepairSuspensionChosen := true
				this.iRepairBodyworkChosen := true

				this.iLastTyreCompound := false
			}

			if (session != kSessionPaused)
				this.shutdownUDPClient(true)
		}
	}

	acquireTelemetryData() {
		local telemetryData := super.acquireTelemetryData()

		if (getMultiMapValues(telemetryData, "Setup Data", false) && (this.iLastTyreCompound && this.iPSChangeTyres)) {
			setMultiMapValue(telemetryData, "Setup Data", "TyreCompound", this.iLastTyreCompound)
			setMultiMapValue(telemetryData, "Setup Data", "TyreCompoundColor", "Black")
		}

		return telemetryData
	}

	acquireSessionData(&telemetryData, &positionsData) {
		if !this.iPositionsDataFuture
			this.iPositionsDataFuture := ACCPlugin.PositionsDataFuture(this)

		return super.acquireSessionData(&telemetryData, &positionsData)
	}

	acquirePositionsData(telemetryData) {
		local positionsData, session
		local lap, restart, fileName, tries
		local driverID, driverForname, driverSurname, driverNickname, lapTime, driverCar, driverCarCandidate, carID, car

		static carIDs := false
		static lastDriverCar := false
		static lastRead := false
		static sessionID := 0
		static lastLap := 0

		if !carIDs {
			ACCPlugin.requireCarDatabase()

			carIDs := getMultiMapValues(ACCPlugin.sCarData, "Car IDs")
		}

		lap := getMultiMapValue(telemetryData, "Stint Data", "Laps", 0)

		if ((lastLap > lap) && (this.iSessionID = sessionID)) {
			sessionID += 1

			restart := true
		}
		else
			restart := false

		this.iSessionID := sessionID

		lastLap := lap

		if (restart || !this.iPositionsDataFuture)
			this.iPositionsDataFuture := ACCPlugin.PositionsDataFuture(this, restart)

		try {
			positionsData := this.iPositionsDataFuture.PositionsData
		}
		finally {
			this.iPositionsDataFuture := false
		}

		if positionsData {
			session := getMultiMapValue(positionsData, "Session Data", "Session", kUndefined)

			if (session != kUndefined) {
				removeMultiMapValues(positionsData, "Session Data")

				setMultiMapValue(telemetryData, "Session Data", "Session", session)
			}

			if ((lap <= 1) || restart)
				lastDriverCar := false

			driverForname := getMultiMapValue(telemetryData, "Stint Data", "DriverForname", "John")
			driverSurname := getMultiMapValue(telemetryData, "Stint Data", "DriverSurname", "Doe")
			driverNickname := getMultiMapValue(telemetryData, "Stint Data", "DriverNickname", "JD")
			driverID := getMultiMapValue(telemetryData, "Session Data", "ID", kUndefined)

			lapTime := getMultiMapValue(telemetryData, "Stint Data", "LapLastTime", 0)

			driverCar := false
			driverCarCandidate := false

			loop {
				carID := getMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".Car", kUndefined)

				if (carID == kUndefined)
					break
				else {
					car := (carIDs.Has(carID) ? carIDs[carID] : ACCPlugin.kUnknown)

					if ((car = ACCPlugin.kUnknown) && isDebug())
						showMessage("Unknown car with ID " . carID . " detected...")

					setMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".Car", car)

					if (getMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".ID", false) = driverID) {
						driverCar := A_Index

						lastDriverCar := driverCar
					}
					else if !driverCar
						if ((getMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".Driver.Forname") = driverForname)
						 && (getMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".Driver.Surname") = driverSurname)) {
							driverCar := A_Index

							lastDriverCar := driverCar
						}
				}
			}

			if !driverCar
				loop {
					carID := getMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".Car", kUndefined)

					if (carID == kUndefined)
						break
					else if (getMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".Position")
						   = getMultiMapValue(telemetryData, "Stint Data", "Position", kUndefined)) {
						driverCar := A_Index

						lastDriverCar := driverCar

						break
					}
					else if (getMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".Time") = lapTime)
						driverCarCandidate := A_Index
				}

			if !driverCar
				driverCar := (lastDriverCar ? lastDriverCar : driverCarCandidate)

			setMultiMapValue(positionsData, "Position Data", "Driver.Car", driverCar)

			return this.correctPositionsData(positionsData)
		}
		else {
			this.shutdownUDPClient(true)

			return newMultiMap()
		}
	}

	computeBrakePadWear(location, compound, thickness) {
		if (location = "Front") {
			switch compound {
				case 1, 4:
					return Max(0, Min(100, 100 - ((thickness - 15) / 14 * 100)))
				case 2:
					return Max(0, Min(100, 100 - ((thickness - 13) / 16 * 100)))
				case 3:
					return Max(0, Min(100, 100 - ((thickness - 12) / 17 * 100)))
				default:
					return Max(0, Min(100, 100 - ((thickness - 14.5) / 14.5 * 100)))
			}
		}
		else
			switch compound {
				case 1, 4:
					return Max(0, Min(100, 100 - ((thickness - 15.5) / 13.5 * 100)))
				case 2:
					return Max(0, Min(100, 100 - ((thickness - 12.5) / 16.5 * 100)))
				case 3:
					return Max(0, Min(100, 100 - ((thickness - 12) / 17 * 100)))
				default:
					return Max(0, Min(100, 100 - ((thickness - 14.5) / 14.5 * 100)))
			}
	}

	updatePositionsData(data) {
		local car, carCategory, cupCategory

		static carCategories := false

		super.updatePositionsData(data)

		if !carCategories {
			ACCPlugin.requireCarDatabase()

			carCategories := getMultiMapValues(ACCPlugin.sCarData, "Car Categories")
		}

		loop {
			car := getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Car", kUndefined)

			if (car == kUndefined)
				break
			else
				setMultiMapValue(data, "Position Data", "Car." . A_Index . ".Class", carCategories.Has(car) ? carCategories[car] : ACCPlugin.kUnknown)
		}
	}

	updateTelemetryData(data) {
		local brakePadThickness, frontBrakePadCompound, rearBrakePadCompound, brakePadWear

		super.updateTelemetryData(data)

		if !getMultiMapValue(data, "Stint Data", "InPit", false)
			if (getMultiMapValue(data, "Car Data", "FuelRemaining", 0) = 0)
				setMultiMapValue(data, "Session Data", "Paused", true)

		if (getMultiMapValue(data, "Session Data", "Active", false) && !getMultiMapValue(data, "Session Data", "Paused", false)) {
			brakePadThickness := string2Values(",", getMultiMapValue(data, "Car Data", "BrakePadLifeRaw"))
			frontBrakePadCompound := getMultiMapValue(data, "Car Data", "FrontBrakePadCompoundRaw")
			rearBrakePadCompound := getMultiMapValue(data, "Car Data", "RearBrakePadCompoundRaw")

			brakePadWear := [this.computeBrakePadWear("Front", frontBrakePadCompound, brakePadThickness[1])
						   , this.computeBrakePadWear("Front", frontBrakePadCompound, brakePadThickness[2])
						   , this.computeBrakePadWear("Rear", frontBrakePadCompound, brakePadThickness[3])
						   , this.computeBrakePadWear("Rear", frontBrakePadCompound, brakePadThickness[4])]

			setMultiMapValue(data, "Car Data", "BrakeWear", values2String(",", brakePadWear*))

			if !isDebug() {
				removeMultiMapValue(data, "Car Data", "BrakePadLifeRaw")
				removeMultiMapValue(data, "Car Data", "BrakeDiscLifeRaw")
				removeMultiMapValue(data, "Car Data", "FrontBrakePadCompoundRaw")
				removeMultiMapValue(data, "Car Data", "RearBrakePadCompoundRaw")
			}
		}
	}

	sendCommand(command, count?) {
		if isSet(count) {
			loop count
				super.sendCommand(command, 0)
		}
		else
			super.sendCommand(command)
	}

	openPitstopMFD(descriptor := false, update := kUndefined) {
		local car, track, settings, imgSearch, wasOpen

		static reported := false

		if (this.iImageSearch = kUndefined) {
			car := (this.Car ? this.Car : "*")
			track := (this.Track ? this.Track : "*")

			settings := SettingsDatabase().loadSettings(this.Simulator[true], car, track, "*")

			this.iImageSearch := getMultiMapValue(settings, "Simulator.Assetto Corsa Competizione", "Pitstop.ImageSearch", false)
		}

		imgSearch := (this.iImageSearch && !this.iNoImageSearch)

		if (update = kUndefined)
			update := (imgSearch ? true : (A_TickCount > this.iNextPitstopMFDOptionsUpdate))

		this.iNextPitstopMFDOptionsUpdate := (A_TickCount + 60000)

		if this.OpenPitstopMFDHotkey {
			if (this.OpenPitstopMFDHotkey != "Off") {
				if this.activateWindow() {
					this.sendCommand(this.OpenPitstopMFDHotkey)

					Sleep(200)

					this.sendCommand(this.OpenPitstopMFDHotkey)

					if !imgSearch {
						if update {
							this.initializePitstopMFD()

							update := false
						}

						this.iPSIsOpen := true
					}

					wasOpen := this.iPSIsOpen

					this.iPSIsOpen := true
					this.iPSSelectedOption := 1

					if (imgSearch && (update || !wasOpen)) {
						if this.updatePitStopState()
							this.openPitstopMFD(false, false)

						if this.iPSIsOpen
							Task.startTask("updatePitstopState", 5000, kLowPriority)
					}

					return this.iPSIsOpen
				}
				else
					return false
			}
			else
				return false
		}
		else if !reported {
			reported := true

			logMessage(kLogCritical, translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration"))

			showMessage(translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration...")
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

			return false
		}
	}

	resetPitstopMFD(descriptor := false) {
		this.iNextPitstopMFDOptionsUpdate := 0
	}

	closePitstopMFD() {
		static reported := false

		if this.ClosePitstopMFDHotkey {
			if (this.OpenPitstopMFDHotkey != "Off") {
				if this.activateWindow() {
					this.sendCommand(this.ClosePitstopMFDHotkey)

					this.iPSIsOpen := false
				}
			}
		}
		else if !reported {
			reported := true

			logMessage(kLogCritical, translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration"))

			showMessage(translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration...")
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
	}

	requirePitstopMFD(retry := false) {
		static reported := false

		if retry
			this.iNoImageSearch := false

		this.openPitstopMFD()

		if (this.OpenPitstopMFDHotkey = "Off")
			return false
		else if this.iPSIsOpen
			return true
		else {
			if !reported {
				reported := true

				logMessage(kLogCritical, translate("Cannot locate the Pitstop MFD - please consult the documentation for the ACC plugin"))

				loop 2
					SoundPlay(kResourcesDirectory . "Sounds\Critical.wav", "Wait")
			}

			SoundPlay(kResourcesDirectory . "Sounds\Critical.wav")

			this.iNoImageSearch := true

			this.openPitstopMFD(false, true)

			return this.iPSIsOpen
		}
	}

	checkRestart() {
		if GetKeyState("Ctrl", "P")
			throw "Restart"
	}

	initializePitstopMFD() {
		local repairBodyworkChosen := this.iRepairBodyworkChosen
		local repairSuspensionChosen := this.iRepairSuspensionChosen
		local availableOptions, currentPressures, tyreChange

		loop {
			protectionOn(true, true)

			try {
				this.sendCommand(this.OpenPitstopMFDHotkey)

				Sleep(200)

				this.sendCommand(this.OpenPitstopMFDHotkey)

				availableOptions := ["Pit Limiter", "Strategy", "Refuel"
								   , "Change Tyres", "Tyre Set", "Tyre Compound", "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right"
								   , "Change Brakes", "Front Brake", "Rear Brake", "Driver", "Repair Suspension", "Repair Bodywork"]

				currentPressures := this.getPitstopOptionValues("Tyre Pressures")

				if !this.isStrategyAvailable(availableOptions, currentPressures)
					availableOptions.RemoveAt(inList(availableOptions, "Strategy"))

				tyreChange := this.isTyreChangeSelected(availableOptions, currentPressures)

				if !tyreChange {
					this.sendCommand(this.OpenPitstopMFDHotkey)

					this.sendCommand("{Down}", inList(availableOptions, "Change Tyres") - 1)

					this.sendCommand("{Right}")
				}

				this.iPSChangeTyres := true

				if this.isWetTyreSelected(availableOptions, currentPressures) {
					this.iPSTyreOptions := 6

					availableOptions.RemoveAt(inList(availableOptions, "Tyre Set"))
				}
				else
					this.iPSTyreOptions := 7

				if this.isBrakeChangeSelected(availableOptions, currentPressures)
					this.iPSChangeBrakes := true
				else
					this.iPSChangeBrakes := false

				if !this.isDriverAvailable(availableOptions, currentPressures)
					availableOptions.RemoveAt(inList(availableOptions, "Driver"))

				if !tyreChange {
					this.sendCommand(this.OpenPitstopMFDHotkey)

					this.sendCommand("{Down}", inList(availableOptions, "Change Tyres") - 1)

					this.sendCommand("{Left}")

					this.iPSChangeTyres := false
				}

				this.iPSOptions := availableOptions

				this.iPSTyreOptionPosition := inList(this.iPSOptions, "Change Tyres")
				this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")

				this.sendCommand(this.OpenPitstopMFDHotkey)

				this.toggleActivity("Repair Suspension")
				this.toggleActivity("Repair Suspension")
				this.toggleActivity("Repair Bodywork")

				if repairBodyworkChosen
					this.toggleActivity("Repair Bodywork")

				if repairSuspensionChosen
					this.toggleActivity("Repair Suspension")

				this.iRepairSuspensionChosen := repairSuspensionChosen
				this.iRepairBodyworkChosen := (repairBodyworkChosen || repairSuspensionChosen)

				if this.iPSChangeTyres
					this.iLastTyreCompound := (inList(this.iPSOptions, "Tyre Set") ? "Dry" : "Wet")
				else
					this.iLastTyreCompound := false

				break
			}
			catch Any as exception {
				if (exception != "Restart")
					throw exception
			}
			finally {
				protectionOff(true, true)
			}
		}
	}

	isStrategyAvailable(options, currentPressures) {
		local modifiedPressures

		this.checkRestart()

		this.sendCommand(this.OpenPitstopMFDHotkey)

		this.sendCommand("{Down}", inList(options, "Change Tyres") - 1 + 3)

		this.checkRestart()

		this.sendCommand("{Right}")

		modifiedPressures := this.getPitstopOptionValues("Tyre Pressures")

		this.sendCommand("{Left}")

		this.checkRestart()

		if listEqual(currentPressures, modifiedPressures) {
			this.sendCommand(this.OpenPitstopMFDHotkey)

			this.sendCommand("{Down}", inList(options, "Change Tyres") - 1)

			this.checkRestart()

			this.sendCommand("{Right}")

			this.sendCommand("{Down}", 3)

			this.sendCommand("{Right}")

			modifiedPressures := this.getPitstopOptionValues("Tyre Pressures")

			this.sendCommand("{Left}")

			this.sendCommand("{Up}", 3)

			this.sendCommand("{Left}")

			if listEqual(currentPressures, modifiedPressures)
				return false
		}

		return true
	}

	isTyreChangeSelected(options, currentPressures) {
		local modifiedPressures

		this.checkRestart()

		this.sendCommand(this.OpenPitstopMFDHotkey)

		this.sendCommand("{Down}", inList(options, "Change Tyres") - 1 + 3)

		this.checkRestart()

		this.sendCommand("{Right}")

		modifiedPressures := this.getPitstopOptionValues("Tyre Pressures")

		this.sendCommand("{Left}")

		return !listEqual(currentPressures, modifiedPressures)
	}

	isWetTyreSelected(options, currentPressures) {
		local index, modifiedPressures, pressure

		this.checkRestart()

		if this.iPSChangeTyres {
			this.sendCommand(this.OpenPitstopMFDHotkey)

			this.sendCommand("{Down}", inList(options, "Change Tyres") - 1 + 4)

			this.checkRestart()

			this.sendCommand("{Right}")

			modifiedPressures := this.getPitstopOptionValues("Tyre Pressures")

			this.sendCommand("{Left}")

			for index, pressure in currentPressures
				if (modifiedPressures[index] != pressure)
					return (index = 2)
		}
		else
			return false
	}

	isBrakeChangeSelected(options, currentPressures) {
		local index, modifiedPressures, pressure

		this.checkRestart()

		this.sendCommand(this.OpenPitstopMFDHotkey)

		this.sendCommand("{Down}", inList(options, "Change Brakes") - 1)

		this.sendCommand("{Down}", 13 - (inList(options, "Strategy") ? 0 : 1) - (7 - this.iPSTyreOptions))

		this.checkRestart()

		this.sendCommand("{Right}")

		modifiedPressures := this.getPitstopOptionValues("Tyre Pressures")

		this.sendCommand("{Left}")

		for index, pressure in currentPressures
			if (modifiedPressures[index] != pressure)
				if ((index = 1) || (index = 2))
					return true

		return false
	}

	isDriverAvailable(options, currentPressures) {
		local modifiedPressures

		this.checkRestart()

		this.sendCommand(this.OpenPitstopMFDHotkey)

		this.sendCommand("{Down}", inList(options, "Change Brakes") - 1 + 12 + (this.iPSChangeBrakes ? this.iPSBrakeOptions : 0)
																	+ (inList(options, "Strategy") ? 1 : 0) - (7 - this.iPSTyreOptions))

		this.checkRestart()

		this.sendCommand("{Right}")

		modifiedPressures := this.getPitstopOptionValues("Tyre Pressures")

		this.sendCommand("{Left}")

		return (currentPressures[3] != modifiedPressures[3])
	}

	selectPitstopOption(option, retry := true) {
		local delta, targetSelectedOption

		if (option = "No Refuel")
			return this.selectPitstopOption("Refuel", retry)
		else {
			protectionOn(true, true)

			try {
				if (this.OpenPitstopMFDHotkey != "Off") {
					targetSelectedOption := inList(this.iPSOptions, option)

					if targetSelectedOption {
						delta := 0

						if (targetSelectedOption > this.iPSTyreOptionPosition) {
							if (targetSelectedOption <= (this.iPSTyreOptionPosition + this.iPSTyreOptions)) {
								if !this.iPSChangeTyres {
									this.toggleActivity("Change Tyres")

									return (retry && this.selectPitstopOption(option, false))
								}
							}
							else
								if !this.iPSChangeTyres
									delta -= this.iPSTyreOptions
						}

						if (targetSelectedOption > this.iPSBrakeOptionPosition) {
							if (targetSelectedOption <= (this.iPSBrakeOptionPosition + this.iPSBrakeOptions)) {
								if !this.iPSChangeBrakes {
									this.toggleActivity("Change Brakes")

									return (retry && this.selectPitstopOption(option, false))
								}
							}
							else
								if !this.iPSChangeBrakes
									delta -= this.iPSBrakeOptions
						}

						targetSelectedOption += delta

						if this.activateWindow() {
							delta := ((this.iPSOptions.Length - (this.iPSChangeTyres ? 0 : this.iPSTyreOptions)
															  - (this.iPSChangeBrakes ? 0 : this.iPSBrakeOptions))
									- targetSelectedOption + this.iPSSelectedOption)

							if (Abs(targetSelectedOption - this.iPSSelectedOption) <= delta) {
								if (targetSelectedOption > this.iPSSelectedOption)
									this.sendCommand("{Down}", targetSelectedOption - this.iPSSelectedOption)
								else
									this.sendCommand("{Up}", this.iPSSelectedOption - targetSelectedOption)
							}
							else
								this.sendCommand("{Up}", delta)

							this.iPSSelectedOption := targetSelectedOption

							return true
						}
						else
							return false
					}
					else
						return false
				}
				else
					return false
			}
			finally {
				protectionOff(true, true)
			}
		}
	}

	changePitstopOption(option, direction, steps := 1) {
		protectionOn(true, true)

		try {
			if (this.OpenPitstopMFDHotkey != "Off") {
				if (option = "No Refuel")
					this.changePitstopOption("Refuel", "Decrease", this.getPitstopOptionValues("Refuel")[1])
				else {
					switch direction, false {
						case "Increase":
							if this.activateWindow()
								this.sendCommand("{Right}", steps)
						case "Decrease":
							if this.activateWindow()
								this.sendCommand("{Left}", steps)
						default:
							throw "Unsupported change operation `"" . direction . "`" detected in ACCPlugin.changePitstopOption..."
					}

					if (option = "Repair Suspension") {
						this.iRepairSuspensionChosen := !this.iRepairSuspensionChosen

						if this.iRepairSuspensionChosen
							this.iRepairBodyworkChosen := true
					}
					else if (option = "Repair Bodywork")
						this.iRepairBodyworkChosen := !this.iRepairBodyworkChosen

						if !this.iRepairBodyworkChosen
							this.iRepairSuspensionChosen := false
				}

				this.resetPitstopState(inList(kPSMutatingOptions, option))
			}
		}
		finally {
			protectionOff(true, true)
		}
	}

	updatePitstopOption(option, action, steps := 1) {
		protectionOn(true, true)

		try {
			if (this.OpenPitstopMFDHotkey != "Off") {
				if inList(["No Refuel", "Change Tyres", "Change Brakes", "Repair Bodywork", "Repair Suspension"], option)
					this.toggleActivity(option)
				else
					switch option, false {
						case "Strategy":
							this.changeStrategy(action, steps)
						case "Refuel":
							this.changeFuelAmount(action, steps)
						case "Tyre Compound":
							this.changeTyreCompound(action)
						case "Tyre Set":
							this.changeTyreSet(action, steps)
						case "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right":
							this.changeTyrePressure(option, action, steps)
						case "Front Brake", "Rear Brake":
							this.changeBrakeType(option, action)
						case "Driver":
							this.changeDriver(action)
						default:
							super.updatePitstopOption(option, action, steps)
					}
			}
		}
		finally {
			protectionOff(true, true)
		}
	}

	toggleActivity(activity) {
		protectionOn(true, true)

		try {
			if this.requirePitstopMFD()
				switch activity, false {
					case "No Refuel":
						this.changeFuelAmount("Decrease", this.getPitstopOptionValues("Refuel")[1])
					case "Change Tyres", "Change Brakes", "Repair Bodywork", "Repair Suspension":
						if this.selectPitstopOption(activity)
							this.changePitstopOption(activity, "Increase")
					default:
						throw "Unsupported activity `"" . activity . "`" detected in ACCPlugin.toggleActivity..."
				}
		}
		finally {
			protectionOff(true, true)
		}
	}

	notifyPitstopChanged(option) {
		local newValues

		if this.RaceEngineer
			switch option, false {
				case "Change Tyres":
					newValues := this.getPitstopOptionValues("Tyre Compound")

					if newValues
						this.RaceEngineer.pitstopOptionChanged("Tyre Compound", true, newValues*)
				default:
					super.notifyPitstopChanged((option = "No Refuel") ? "Refuel" : option)
			}
	}

	changeStrategy(selection, steps := 1) {
		protectionOn(true, true)

		try {
			if (this.requirePitstopMFD() && this.selectPitstopOption("Strategy"))
				switch selection, false {
					case "Next":
						this.changePitstopOption("Strategy", "Increase")
					case "Previous":
						this.changePitstopOption("Strategy", "Decrease")
					case "Increase", "Decrease":
						this.changePitstopOption("Strategy", selection)
					default:
						throw "Unsupported selection `"" . selection . "`" detected in ACCPlugin.changeStrategy..."
				}
		}
		finally {
			protectionOff(true, true)
		}
	}

	changeFuelAmount(direction, liters := 5) {
		protectionOn(true, true)

		try {
			if (this.requirePitstopMFD() && this.selectPitstopOption("Refuel"))
				this.changePitstopOption("Refuel", direction, liters)
		}
		finally {
			protectionOff(true, true)
		}
	}

	changeTyreCompound(selection) {
		protectionOn(true, true)

		try {
			if (this.requirePitstopMFD() && this.selectPitstopOption("Tyre Compound"))
				if (InStr(selection, "Wet") = 1) {
					this.changePitstopOption("Tyre Compound", "Increase")

					this.iLastTyreCompound := "Wet"
				}
				else if (InStr(selection, "Dry") = 1) {
					this.changePitstopOption("Tyre Compound", "Decrease")

					this.iLastTyreCompound := "Dry"
				}
				else
					switch selection, false {
						case "Increase", "Decrease":
							this.changePitstopOption("Tyre Compound", selection)

							this.iLastTyreCompound := ((selection = "Increase") ? "Wet" : "Dry")
						default:
							throw "Unsupported selection `"" . selection . "`" detected in ACCPlugin.changeTyreCompound..."
					}
		}
		finally {
			protectionOff(true, true)
		}
	}

	changeTyreSet(selection, steps := 1) {
		protectionOn(true, true)

		try {
			if (this.requirePitstopMFD() && this.selectPitstopOption("Tyre set"))
				switch selection, false {
					case "Next":
						this.changePitstopOption("Tyre set", "Increase", steps)
					case "Previous":
						this.changePitstopOption("Tyre set", "Decrease", steps)
					case "Increase", "Decrease":
						this.changePitstopOption("Tyre Set", selection, steps)
					default:
						throw "Unsupported selection `"" . selection . "`" detected in ACCPlugin.changeTyreSet..."
				}
		}
		finally {
			protectionOff(true, true)
		}
	}

	changeTyrePressure(tyre, direction, increments := 1) {
		local found

		protectionOn(true, true)

		try {
			if this.requirePitstopMFD() {
				found := false

				switch tyre, false {
					case "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right":
						found := this.selectPitstopOption(tyre)
					default:
						throw "Unsupported tyre position `"" . tyre . "`" detected in ACCPlugin.changeTyrePressure..."
				}

				if found
					this.changePitstopOption(tyre, direction, increments)
			}
		}
		finally {
			protectionOff(true, true)
		}
	}

	changeBrakeType(brake, selection) {
		local found

		protectionOn(true, true)

		try {
			if this.requirePitstopMFD() {
				found := false

				switch brake, false {
					case "Front Brake", "Rear Brake":
						found := this.selectPitstopOption(brake)
					default:
						throw "Unsupported brake `"" . brake . "`" detected in ACCPlugin.changeBrakeType..."
				}

				if found
					switch selection, false {
						case "Next":
							this.changePitstopOption(brake, "Increase")
						case "Previous":
							this.changePitstopOption(brake, "Decrease")
						case "Increase", "Decrease":
							this.changePitstopOption(brake, selection)
						default:
							throw "Unsupported selection `"" . selection . "`" detected in ACCPlugin.changeBrakeType..."
					}
			}
		}
		finally {
			protectionOff(true, true)
		}
	}

	changeDriver(selection) {
		protectionOn(true, true)

		try {
			if (this.requirePitstopMFD() && this.selectPitstopOption("Driver"))
				switch selection, false {
					case "Next":
						this.changePitstopOption("Driver", "Increase")
					case "Previous":
						this.changePitstopOption("Driver", "Decrease")
					case "Increase", "Decrease":
						this.changePitstopOption("Driver", selection)
					default:
						throw "Unsupported selection `"" . selection . "`" detected in ACCPlugin.changeDriver..."
				}
		}
		finally {
			protectionOff(true, true)
		}
	}

	getLabelFileNames(labelNames*) {
		local fileNames := []
		local ignore, labelName, fileName

		for ignore, labelName in labelNames {
			labelName := ("ACC\" . labelName)

			fileName := getFileName(labelName . ".png", kUserScreenImagesDirectory)

			if FileExist(fileName)
				fileNames.Push(fileName)

			fileName := getFileName(labelName . ".jpg", kUserScreenImagesDirectory)

			if FileExist(fileName)
				fileNames.Push(fileName)

			fileName := getFileName(labelName . ".png", kScreenImagesDirectory)

			if FileExist(fileName)
				fileNames.Push(fileName)

			fileName := getFileName(labelName . ".jpg", kScreenImagesDirectory)

			if FileExist(fileName)
				fileNames.Push(fileName)
		}

		if (fileNames.Length == 0) {
			if isDebug()
				showMessage("Unknown label '" . labelName . "' detected in ACCPlugin.getLabelFileName...")
		}
		else {
			if isDebug()
				showMessage("Labels: " . values2String(", ", labelNames*) . "; Images: " . values2String(", ", fileNames*), "Pitstop MFD Image Search", "Information.png", 5000)

			return fileNames
		}
	}

	markFoundLabel(image, x, y) {
		local labelGui

		if isDebug() {
			SplitPath(image, &fileName)

			labelGui := Window({Options: "+AlwaysOnTop"})

			labelGui.Add("Text", "x0 y0 w100 h23 +0x200 +0x1 BackgroundTrans", fileName)

			labelGui.Show("AutoSize x" . x . " y" . y)

			Sleep(1000)

			labelGui.Destroy()
		}
	}

	searchPitstopLabel(images) {
		local curTickCount, imageX, imageY, localLabels, ignore, fileName, pitstopLabel, lastY

		static kSearchAreaLeft := 350
		static kSearchAreaRight := 250
		static pitstopLabels := false

		if !pitstopLabels
			pitstopLabels := this.getLabelFileNames("PITSTOP")

		if this.activateWindow() {
			curTickCount := A_TickCount

			imageX := kUndefined
			imageY := kUndefined

			localLabels := false

			for ignore, fileName in pitstopLabels
				if InStr(fileName, kUserScreenImagesDirectory) {
					localLabels := true

					break
				}

			loop (localLabels ? 3 : 1) {
				loop pitstopLabels.Length {
					pitstopLabel := pitstopLabels[A_Index]

					if !this.iPSImageSearchArea {
						ImageSearch(&imageX, &imageY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*100 " . pitstopLabel)

						if isLogLevel(kLogInfo)
							logMessage(kLogInfo, substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "PITSTOP", ticks: A_TickCount - curTickCount}))
					}
					else {
						ImageSearch(&imageX, &imageY
								  , this.iPSImageSearchArea[1], this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4]
								  , "*100 " . pitstopLabel)

						if isLogLevel(kLogInfo)
							logMessage(kLogInfo, substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "PITSTOP", ticks: A_TickCount - curTickCount}))
					}

					if isInteger(imageX) {
						if isDebug() {
							images.Push(pitstopLabel)

							this.markFoundLabel(pitstopLabel, imageX, imageY)
						}

						break
					}
				}

				if isInteger(imageX)
					break
				else
					Sleep(500)
			}

			lastY := false

			if isInteger(imageX) {
				lastY := imageY

				if !this.iPSImageSearchArea
					this.iPSImageSearchArea := [Max(0, imageX - kSearchAreaLeft), 0, Min(imageX + kSearchAreaRight, A_ScreenWidth), A_ScreenHeight]
			}
			else {
				this.iPSIsOpen := false
			}

			return lastY
		}
		else
			return false
	}

	searchStrategyLabel(&lastY, images) {
		local curTickCount, reload, imageX, imageY, pitStrategyLabel, position

		static pitStrategyLabels := false

		curTickCount := A_TickCount
		reload := false

		if !pitStrategyLabels
			pitStrategyLabels := this.getLabelFileNames("Pit Strategy 1", "Pit Strategy 2")

		if this.activateWindow() {
			imageX := kUndefined
			imageY := kUndefined

			loop pitStrategyLabels.Length {
				pitStrategyLabel := pitStrategyLabels[A_Index]

				if !this.iPSImageSearchArea
					ImageSearch(&imageX, &imageY, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, "*100 " . pitStrategyLabel)
				else
					ImageSearch(&imageX, &imageY
							  , this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4]
							  , "*100 " . pitStrategyLabel)

				if isInteger(imageX) {
					if isDebug() {
						images.Push(pitStrategyLabel)

						this.markFoundLabel(pitStrategyLabel, imageX, imageY)
					}

					break
				}
			}

			if isLogLevel(kLogInfo)
				if !this.iPSImageSearchArea
					logMessage(kLogInfo, substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "Pit Strategy", ticks: A_TickCount - curTickCount}))
				else
					logMessage(kLogInfo, substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "Pit Strategy", ticks: A_TickCount - curTickCount}))

			if isInteger(imageX) {
				if !inList(this.iPSOptions, "Strategy") {
					this.iPSOptions.InsertAt(inList(this.iPSOptions, "Pit Limiter") + 1, "Strategy")

					this.iPSTyreOptionPosition := inList(this.iPSOptions, "Change Tyres")
					this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")

					reload := true
				}

				lastY := imageY

				if isLogLevel(kLogInfo)
					logMessage(kLogInfo, translate("'Pit Strategy' detected, adjusting pitstop options: ") . values2String(", ", this.iPSOptions*))
			}
			else {
				position := inList(this.iPSOptions, "Strategy")

				if position {
					this.iPSOptions.RemoveAt(position)

					this.iPSTyreOptionPosition := inList(this.iPSOptions, "Change Tyres")
					this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")

					reload := true
				}

				if isLogLevel(kLogInfo)
					logMessage(kLogInfo, translate("'Pit Strategy' not detected, adjusting pitstop options: ") . values2String(", ", this.iPSOptions*))
			}

			return reload
		}
		else
			return false
	}

	searchNoRefuelLabel(&lastY, images) {
		local curTickCount := A_TickCount
		local reload := false
		local imageX, imageY, position, noRefuelLabel

		static noRefuelLabels := false

		if !noRefuelLabels
			noRefuelLabels := this.getLabelFileNames("No Refuel")

		if this.activateWindow() {
			imageX := kUndefined
			imageY := kUndefined

			loop noRefuelLabels.Length {
				noRefuelLabel := noRefuelLabels[A_Index]

				if !this.iPSImageSearchArea
					ImageSearch(&imageX, &imageY, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, "*25 " . noRefuelLabel)
				else
					ImageSearch(&imageX, &imageY
							  , this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4]
							  , "*25 " . noRefuelLabel)

				if isInteger(imageX) {
					if isDebug() {
						images.Push(noRefuelLabel)

						this.markFoundLabel(noRefuelLabel, imageX, imageY)
					}

					break
				}
			}

			if isLogLevel(kLogInfo)
				if !this.iPSImageSearchArea
					logMessage(kLogInfo, substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "Refuel", ticks: A_TickCount - curTickCount}))
				else
					logMessage(kLogInfo, substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "Refuel", ticks: A_TickCount - curTickCount}))

			if isInteger(imageX) {
				position := inList(this.iPSOptions, "Refuel")

				if position {
					this.iPSOptions.RemoveAt(position)

					this.iPSTyreOptionPosition := inList(this.iPSOptions, "Change Tyres")
					this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")

					reload := true
				}

				lastY := imageY

				if isLogLevel(kLogInfo)
					logMessage(kLogInfo, translate("'Refuel' not detected, adjusting pitstop options: ") . values2String(", ", this.iPSOptions*))
			}
			else {
				if !inList(this.iPSOptions, "Refuel") {
					this.iPSOptions.InsertAt(inList(this.iPSOptions, "Change Tyres"), "Refuel")

					this.iPSTyreOptionPosition := inList(this.iPSOptions, "Change Tyres")
					this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")

					reload := true
				}

				if isLogLevel(kLogInfo)
					logMessage(kLogInfo, translate("'Refuel' detected, adjusting pitstop options: ") . values2String(", ", this.iPSOptions*))
			}

			return reload
		}
		else
			return false
	}

	searchTyreLabel(&lastY, images) {
		local curTickCount := A_TickCount
		local reload := false
		local imageX, imageY, position, wetLabel, compoundLabel

		static wetLabels := false
		static compoundLabels := false

		if !wetLabels {
			wetLabels := this.getLabelFileNames("Wet 1", "Wet 2")
			compoundLabels := this.getLabelFileNames("Compound 1", "Compound 2")
		}

		if this.activateWindow() {
			imageX := kUndefined
			imageY := kUndefined

			loop wetLabels.Length {
				wetLabel := wetLabels[A_Index]

				if !this.iPSImageSearchArea
					ImageSearch(&imageX, &imageY, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, "*100 " . wetLabel)
				else
					ImageSearch(&imageX, &imageY
							  , this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4]
							  , "*100 " . wetLabel)

				if isInteger(imageX) {
					if isDebug() {
						images.Push(wetLabel)

						this.markFoundLabel(wetLabel, imageX, imageY)
					}

					break
				}
			}

			if isInteger(imageX) {
				position := inList(this.iPSOptions, "Tyre Set")

				if position {
					this.iPSOptions.RemoveAt(position)
					this.iPSTyreOptions := 6

					this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")

					reload := true
				}
			}
			else {
				if !inList(this.iPSOptions, "Tyre Set") {
					this.iPSOptions.InsertAt(inList(this.iPSOptions, "Tyre Compound"), "Tyre Set")
					this.iPSTyreOptions := 7

					this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")

					reload := true
				}

				imageX := kUndefined
				imageY := kUndefined

				loop compoundLabels.Length {
					compoundLabel := compoundLabels[A_Index]

					if !this.iPSImageSearchArea
						ImageSearch(&imageX, &imageY, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, "*100 " . compoundLabel)
					else
						ImageSearch(&imageX, &imageY
								  , this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4]
								  , "*100 " . compoundLabel)

					if isInteger(imageX) {
						if isDebug() {
							images.Push(compoundLabel)

							this.markFoundLabel(compoundLabel, imageX, imageY)
						}

						break
					}
				}
			}

			if isLogLevel(kLogInfo)
				if !this.iPSImageSearchArea
					logMessage(kLogInfo, substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "Tyre Set", ticks: A_TickCount - curTickCount}))
				else
					logMessage(kLogInfo, substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "Tyre Set", ticks: A_TickCount - curTickCount}))

			if isInteger(imageX) {
				this.iPSChangeTyres := true

				lastY := imageY

				if isLogLevel(kLogInfo)
					logMessage(kLogInfo, translate("Pitstop: Tyres are selected for change"))
			}
			else {
				this.iPSChangeTyres := false

				if isLogLevel(kLogInfo)
					logMessage(kLogInfo, translate("Pitstop: Tyres are not selected for change"))
			}

			return reload
		}
		else
			return false
	}

	searchBrakeLabel(&lastY, images) {
		local curTickCount := A_TickCount
		local reload := false
		local imageX, imageY, position, frontBrakeLabel

		static frontBrakeLabels := false

		if !frontBrakeLabels
			frontBrakeLabels := this.getLabelFileNames("Front Brake 1", "Front Brake 2")

		if this.activateWindow() {
			imageX := kUndefined
			imageY := kUndefined

			loop frontBrakeLabels.Length {
				frontBrakeLabel := frontBrakeLabels[A_Index]

				if !this.iPSImageSearchArea
					ImageSearch(&imageX, &imageY, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, "*100 " . frontBrakeLabel)
				else
					ImageSearch(&imageX, &imageY
							  , this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4]
							  , "*100 " . frontBrakeLabel)

				if isInteger(imageX) {
					if isDebug() {
						images.Push(frontBrakeLabel)

						this.markFoundLabel(frontBrakeLabel, imageX, imageY)
					}

					break
				}
			}

			if isLogLevel(kLogInfo)
				if !this.iPSImageSearchArea
					logMessage(kLogInfo, substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "Front Brake", ticks: A_TickCount - curTickCount}))
				else
					logMessage(kLogInfo, substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "Front Brake", ticks: A_TickCount - curTickCount}))

			if isInteger(imageX) {
				this.iPSChangeBrakes := true

				if isLogLevel(kLogInfo)
					logMessage(kLogInfo, translate("Pitstop: Brakes are selected for change"))
			}
			else {
				this.iPSChangeBrakes := false

				if isLogLevel(kLogInfo)
					logMessage(kLogInfo, translate("Pitstop: Brakes are not selected for change"))
			}

			return reload
		}
		else
			return false
	}

	searchDriverLabel(&lastY, images) {
		local curTickCount := A_TickCount
		local reload := false
		local imageX, imageY, position, selectDriverLabel

		static selectDriverLabels := false

		if !selectDriverLabels
			selectDriverLabels := this.getLabelFileNames("Select Driver 1", "Select Driver 2")

		if this.activateWindow() {
			imageX := kUndefined
			imageY := kUndefined

			loop selectDriverLabels.Length {
				selectDriverLabel := selectDriverLabels[A_Index]

				if !this.iPSImageSearchArea
					ImageSearch(&imageX, &imageY, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, "*100 " . selectDriverLabel)
				else
					ImageSearch(&imageX, &imageY
							  , this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4]
							  , "*100 " . selectDriverLabel)

				if isInteger(imageX) {
					if isDebug() {
						images.Push(selectDriverLabel)

						this.markFoundLabel(selectDriverLabel, imageX, imageY)
					}

					break
				}
			}

			if isLogLevel(kLogInfo)
				if !this.iPSImageSearchArea
					logMessage(kLogInfo, substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "Select Driver", ticks: A_TickCount - curTickCount}))
				else
					logMessage(kLogInfo, substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "Select Driver", ticks: A_TickCount - curTickCount}))

			if isInteger(imageX) {
				if !inList(this.iPSOptions, "Driver") {
					this.iPSOptions.InsertAt(inList(this.iPSOptions, "Repair Suspension"), "Driver")

					reload := true
				}

				if isLogLevel(kLogInfo)
					logMessage(kLogInfo, translate("'Select Driver' detected, adjusting pitstop options: ") . values2String(", ", this.iPSOptions*))
			}
			else {
				position := inList(this.iPSOptions, "Driver")

				if position {
					this.iPSOptions.RemoveAt(position)

					reload := true
				}

				if isLogLevel(kLogInfo)
					logMessage(kLogInfo, translate("'Select Driver' not detected, adjusting pitstop options: ") . values2String(", ", this.iPSOptions*))
			}

			return reload
		}
		else
			return false
	}

	updatePitstopState(fromTask := false) {
		local beginTickCount, lastY, images, reload

		if isACCRunning() {
			beginTickCount := A_TickCount
			lastY := 0
			images := []

			try {
				if (fromTask || !this.iPSImageSearchArea)
					lastY := this.searchPitstopLabel(images)

				if (!fromTask && this.iPSIsOpen) {
					reload := this.searchStrategyLabel(&lastY, images)

					; reload := (this.searchNoRefuelLabel(&lastY, images) || reload)

					reload := (this.searchTyreLabel(&lastY, images) || reload)

					reload := (this.searchBrakeLabel(&lastY, images) || reload)

					reload := (this.searchDriverLabel(&lastY, images) || reload)

					if isLogLevel(kLogInfo)
						logMessage(kLogInfo, translate("Complete update of pitstop state took ") . A_TickCount - beginTickCount . translate(" ms"))

					if isDebug()
						showMessage("Found images: " . values2String(", ", images*), "Pitstop MFD Image Search", "Information.png", 5000)

					return reload
				}
			}
			catch Any as exception {
				this.iPSOpen := false
			}

			if (fromTask && this.iPSOpen && !this.iNoImageSearch) {
				Task.CurrentTask.NextExecution := (A_TickCount + 5000)

				return Task.CurrentTask
			}

			return false
		}

		return false
	}

	resetPitstopState(update := false) {
		this.openPitstopMFD(false, update)
	}

	supportsPitstop() {
		return true
	}

	supportsTrackMap() {
		return true
	}

	supportsSetupImport() {
		return true
	}

	restoreSessionState(&sessionSettings, &sessionState) {
		super.restoreSessionState(&sessionSettings, &sessionState)

		this.iLastTyreCompound := false
	}

	supportsRaceAssistant(assistantPlugin) {
		if ((assistantPlugin = kRaceStrategistPlugin) || (assistantPlugin = kRaceSpotterPlugin))
			return ((FileExist(kBinariesDirectory . "Providers\ACC UDP Provider.exe") != false) && super.supportsRaceAssistant(assistantPlugin))
		else
			return super.supportsRaceAssistant(assistantPlugin)
	}

	getPitstopOptionValues(option) {
		local data

		if (this.OpenPitstopMFDHotkey != "Off") {
			switch option, false {
				case "Pit Limiter":
					data := this.readSessionData("Setup=true")

					return [getMultiMapValue(data, "Car Data", "PitLimiter", false)]
				case "Refuel":
					data := this.readSessionData("Setup=true")

					return [getMultiMapValue(data, "Setup Data", "FuelAmount", 0)]
				case "Tyre Pressures":
					data := this.readSessionData("Setup=true")

					return [getMultiMapValue(data, "Setup Data", "TyrePressureFL", 26.1), getMultiMapValue(data, "Setup Data", "TyrePressureFR", 26.1)
						  , getMultiMapValue(data, "Setup Data", "TyrePressureRL", 26.1), getMultiMapValue(data, "Setup Data", "TyrePressureRR", 26.1)]
				case "Tyre Set":
					data := this.readSessionData("Setup=true")

					return [getMultiMapValue(data, "Setup Data", "TyreSet", 0)]
				case "Tyre Compound":
					if this.iPSChangeTyres {
						return (inList(this.iPSOptions, "Tyre Set") ? ["Dry", "Black"] : ["Wet", "Black"])

						/*
						data := this.readSessionData("Setup=true")

						return [getMultiMapValue(data, "Setup Data", "TyreCompound", false), getMultiMapValue(data, "Setup Data", "TyreCompoundColor", false)]
						*/
					}
					else
						return [false, false]
				case "Repair Suspension":
					return [this.iRepairSuspensionChosen]
				case "Repair Bodywork":
					return [this.iRepairBodyworkChosen]
				default:
					return super.getPitstopOptionValues(option)
			}
		}
		else
			return false
	}

	performPitstop(lap, options) {
		super.performPitstop(lap, options)

		this.iSelectedDriver := false
	}

	startPitstopSetup(pitstopNumber) {
		super.startPitstopSetup(pitstopNumber)

		withProtection(ObjBindMethod(this, "requirePitstopMFD", this.iNoImageSearch))

		this.iOldChangeBrakes := this.iPSChangeBrakes
	}

	finishPitstopSetup(pitstopNumber) {
		super.finishPitstopSetup(pitstopNumber)

		if (this.iOldChangeBrakes != this.iPSChangeBrakes)
			loop 3
				SoundPlay(kResourcesDirectory . "Sounds\Critical.wav", "Wait")

		closePitstopMFD()
	}

	pitstopFinished(pitstopNumber, async := false) {
		local retry, updateTime, carState, pitstopState, currentDriver, currentTyreSet, tyreStates, pitstopData
		local pressures, index, pressure, ignore, tyreSet, wearState, tread, section, grain, blister, flatSpot, marbles
		local data, tyre, key, value, wear

		static updateTask := false

		if !async {
			if updateTask {
				updateTask.stop()

				updateTask := false
			}

			super.pitstopFinished(pitstopNumber)
		}

		if this.RaceEngineer {
			if async {
				try {
					retry := false

					if FileExist(A_MyDocuments . "\Assetto Corsa Competizione\Debug\swap_dump_carjson.json") {
						updateTime := DateAdd(FileGetTime(A_MyDocuments . "\Assetto Corsa Competizione\Debug\swap_dump_carjson.json", "M"), 5, "Minutes")

						if (updateTime < A_Now)
							retry := true
						else
							Sleep(5000)
					}
					else
						retry := true

					if retry {
						Task.CurrentTask.NextExecution := (A_TickCount + 10000)

						return Task.CurrentTask
					}
					else {
						carState := JSON.parse(FileRead(A_MyDocuments . "\Assetto Corsa Competizione\Debug\swap_dump_carjson.json"))
						pitstopState := carState["pitstopMFD"]

						currentDriver := pitstopState["driversNames"][pitstopState["currentDriverIndex"] + 1]

						pitstopData := newSectionMap("Pitstop", pitstopNumber
												   , "Service.Time", pitstopState["timeRequired"]
												   , "Service.Lap", carState["lapCount"]
												   , "Service.Driver.Previous", currentDriver
												   , "Service.Driver.Next", pitstopState["newDriverNameToDisplay"]
												   , "Service.Refuel", pitstopState["fuelToAdd"]
												   , "Service.Bodywork.Repair", (pitstopState["repairBody"] ? true : false)
												   , "Service.Suspension.Repair", (pitstopState["repairSuspension"] ? true : false)
												   , "Service.Engine.Repair", (pitstopState["repairEngine"] ? true : false))

						if !listEqual(pitstopState["tyreToChange"], [false, false, false, false]) {
							pitstopData["Service.Tyre.Compound"] := ((pitstopState["newTyreCompound"] = 0) ? "Dry" : "Wet")
							pitstopData["Service.Tyre.Compound.Color"] := "Black"
							pitstopData["Service.Tyre.Set"] := ((pitstopState["newTyreCompound"] = 0) ? pitstopState["tyreSet"] : false)

							pressures := pitstopState["tyrePressures"]

							for index, pressure in pressures
								pressures[index] := Round(pressure, 1)

							pitstopData["Service.Tyre.Pressures"] := values2String(",", pressures*)
						}

						data := newMultiMap()
						tyreStates := []

						if (carState["currentTyreCompound"] = 0) {
							currentTyreSet := carState["currentTyreSet"]

							for ignore, tyreSet in carState["tyreSets"]
								if (tyreSet["tyreSet"] = currentTyreSet) {
									for ignore, tyre in ["Front.Left", "Front.Right", "Rear.Left", "Rear.Right"] {
										wearState := tyreSet["wearStatus"][A_Index]
										tread := wearState["treadMM"].Clone()

										wear := Round(100 - ((Max(0, average(tread) - 1.5) / 1.5) * 100))

										for index, section in tread
											tread[index] := Round(section, 2)

										marbles := Round(wearState["marblesLevel"], 2)
										grain := Round(wearState["grain"], 2)
										blister := Round(wearState["blister"], 2)
										flatSpot := Round(wearState["flatSpot"], 2)

										tyreStates.Push(CaseInsenseMap("Tyre", tyre, "Tread", tread, "Wear", wear
																	 , "Grain", grain, "Blister", blister, "FlatSpot", flatSpot, "Marbles", marbles))
									}

									pitstopData["Tyre.Driver"] := currentDriver
									pitstopData["Tyre.Laps"] := false
									pitstopData["Tyre.Compound"] := "Dry"
									pitstopData["Tyre.Compound.Color"] := "Black"
									pitstopData["Tyre.Set"] := currentTyreSet
									pitstopData["Tyre.State"] := tyreSet["state"]

									for ignore, tyre in ["Front.Left", "Front.Right", "Rear.Left", "Rear.Right"]
										for key, value in tyreStates[A_Index]
											setMultiMapValue(data, "Pitstop Data", "Tyre." . key . "." . tyre, isObject(value) ? values2String(",", value*) : value)

									break
								}
						}
						else {
							pitstopData["Tyre.Driver"] := currentDriver
							pitstopData["Tyre.Laps"] := false
							pitstopData["Tyre.Compound"] := "Wet"
							pitstopData["Tyre.Compound.Color"] := "Black"
						}

						setMultiMapValues(data, "Pitstop Data", pitstopData, false)

						writeMultiMap(kTempDirectory . "Pitstop " . pitstopNumber . ".ini", data)

						this.RaceEngineer.updatePitstopState(data)
					}
				}
				catch Any as exception {
					logError(exception)
				}

				return false
			}
			else {
				updateTask := Task(ObjBindMethod(this, "pitstopFinished", pitstopNumber, true), 10000, kLowPriority)

				updateTask.start()
			}
		}
	}

	setPitstopRefuelAmount(pitstopNumber, liters) {
		local litersIncrement

		liters := Ceil(liters)

		super.setPitstopRefuelAmount(pitstopNumber, liters)

		if this.requirePitstopMFD()
			loop 3 {
				litersIncrement := Round(liters - this.getPitstopOptionValues("Refuel")[1])

				if (litersIncrement != 0)
					changePitstopFuelAmount((litersIncrement > 0) ? "Increase" : "Decrease", Abs(litersIncrement))
				else
					break
			}
	}

	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
		local tyreSetIncrement, finished

		super.setPitstopTyreSet(pitstopNumber, compound, compoundColor, set)

		if this.requirePitstopMFD()
			if compound {
				loop 3 {
					finished := true

					if (this.getPitstopOptionValues("Tyre Compound")[1] != compound) {
						finished := false

						changePitstopTyreCompound((compound = "Wet") ? "Increase" : "Decrease")
					}

					if (set && (compound = "Dry")) {
						tyreSetIncrement := Round(set - this.getPitstopOptionValues("Tyre Set")[1])

						if (tyreSetIncrement != 0) {
							finished := false

							changePitstopTyreSet((tyreSetIncrement > 0) ? "Next" : "Previous", Abs(tyreSetIncrement))
						}
					}

					if finished
						break
				}
			}
			else if this.iPSChangeTyres
				this.toggleActivity("Change Tyres")
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		local pressures, pressureFLIncrement, pressureFRIncrement, pressureRLIncrement, pressureRRIncrement, finished

		super.setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)

		if this.requirePitstopMFD()
			loop 3 {
				finished := true

				pressures := this.getPitstopOptionValues("Tyre Pressures")

				pressureFLIncrement := Round(pressureFL - pressures[1], 1)
				pressureFRIncrement := Round(pressureFR - pressures[2], 1)
				pressureRLIncrement := Round(pressureRL - pressures[3], 1)
				pressureRRIncrement := Round(pressureRR - pressures[4], 1)

				if (pressureFLIncrement != 0) {
					finished := false

					changePitstopTyrePressure("Front Left", (pressureFLIncrement > 0) ? "Increase" : "Decrease", Abs(Round(pressureFLIncrement * 10)))
				}

				if (pressureFRIncrement != 0) {
					finished := false

					changePitstopTyrePressure("Front Right", (pressureFRIncrement > 0) ? "Increase" : "Decrease", Abs(Round(pressureFRIncrement * 10)))
				}

				if (pressureRLIncrement != 0) {
					finished := false

					changePitstopTyrePressure("Rear Left", (pressureRLIncrement > 0) ? "Increase" : "Decrease", Abs(Round(pressureRLIncrement * 10)))
				}

				if (pressureRRIncrement != 0) {
					finished := false

					changePitstopTyrePressure("Rear Right", (pressureRRIncrement > 0) ? "Increase" : "Decrease", Abs(Round(pressureRRIncrement * 10)))
				}

				if finished
					break
			}
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine := false) {
		super.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine)

		if this.requirePitstopMFD() {
			this.toggleActivity("Repair Suspension")
			this.toggleActivity("Repair Suspension")
			this.toggleActivity("Repair Bodywork")

			if repairBodywork
				this.toggleActivity("Repair Bodywork")

			if repairSuspension
				this.toggleActivity("Repair Suspension")

			this.iRepairSuspensionChosen := repairSuspension
			this.iRepairBodyworkChosen := (repairBodywork || repairSuspension)
		}
	}

	requestPitstopDriver(pitstopNumber, driver) {
		local delta, currentDriver, nextDriver

		super.requestPitstopDriver(pitstopNumber, driver)

		if this.requirePitstopMFD()
			if driver {
				driver := string2Values("|", driver)

				nextDriver := string2Values(":", driver[2])
				currentDriver := string2Values(":", driver[1])

				if !this.iSelectedDriver
					this.iSelectedDriver := currentDriver[2]

				delta := (nextDriver[2] - this.iSelectedDriver)

				loop Abs(delta)
					this.changeDriver((delta < 0) ? "Previous" : "Next")

				this.iSelectedDriver := nextDriver[2]
			}
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startACC() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kACCPlugin).Simulator
													 , "Simulator Splash Images\ACC Splash.jpg")
}

stopACC() {
	if isACCRunning() {
		if SimulatorController.Instance.findPlugin(kACCPlugin).activateWindow() {
			MouseClick("Left", 2093, 1052)
			Sleep(500)
			MouseClick("Left", 2614, 643)
			Sleep(500)
			MouseClick("Left", 2625, 619)
			Sleep(500)
		}
	}
}

isACCRunning() {
	local thePlugin

	if !ProcessExist("acc.exe") {
		try {
			thePlugin := SimulatorController.Instance.findPlugin("ACC")

			if (thePlugin && SimulatorController.Instance.isActive(thePlugin)) {
				thePlugin.iRepairSuspensionChosen := true
				thePlugin.iRepairBodyworkChosen := true

				thePlugin.iLastTyreCompound := false
			}
		}
		catch Any as exception {
			logError(exception)
		}

		return false
	}
	else
		return true
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

updatePitstopState() {
	protectionOn()

	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).updatePitstopState(true)
	}
	finally {
		protectionOff()
	}
}

initializeACCPlugin() {
	local controller := SimulatorController.Instance

	ACCPlugin(controller, kACCPLugin, kACCApplication, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeACCPlugin()