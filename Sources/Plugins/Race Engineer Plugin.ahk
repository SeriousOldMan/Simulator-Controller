;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Engineer Plugin            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Plugins\Libraries\Simulator Plugin.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kRaceEngineerPlugin = "Race Engineer"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceEngineerPlugin extends ControllerPlugin  {
	iRaceEngineerEnabled := false
	iRaceEngineerName := false
	iRaceEngineerLogo := false
	iRaceEngineerSpeaker := false
	iRaceEngineerListener := false
	
	iRaceEngineer := false
	iPitstopPending := false
	
	iSimulator := false
	
	class RemoteRaceEngineer {
		iRemotePID := false
		
		RemotePID[] {
			Get {
				return this.iRemotePID
			}
		}
		
		__New(remotePID) {
			this.iRemotePID := remotePID
		}
		
		callRemote(function, arguments*) {
			raiseEvent(kFileMessage, "Race", function . ":" . values2String(";", arguments*), this.RemotePID)
		}
		
		shutdown(arguments*) {
			this.callRemote("shutdown", arguments*)
		}
		
		startSession(arguments*) {
			this.callRemote("startSession", arguments*)
		}
		
		updateSession(arguments*) {
			this.callRemote("updateSession", arguments*)
		}
		
		finishSession(arguments*) {
			this.callRemote("finishSession", arguments*)
		}
		
		addLap(arguments*) {
			this.callRemote("addLap", arguments*)
		}
		
		updateLap(arguments*) {
			this.callRemote("updateLap", arguments*)
		}
		
		planPitstop(arguments*) {
			this.callRemote("planPitstop", arguments*)
		}
		
		preparePitstop(arguments*) {
			this.callRemote("preparePitstop", arguments*)
		}
		
		performPitstop(arguments*) {
			this.callRemote("performPitstop", arguments*)
		}
	}

	class RaceEngineerAction extends ControllerAction {
		iAction := false
		
		Action[] {
			Get {
				return this.iAction
			}
		}
		
		__New(function, label, action) {
			this.iAction := action
			
			base.__New(function, label)
		}
		
		fireAction(function, trigger) {
			local plugin := this.Controller.findPlugin(kRaceEngineerPlugin)
			
			if plugin.RaceEngineer
				switch this.Action {
					case "PitstopPlan":
						plugin.planPitstop()
					case "PitstopPrepare":
						plugin.preparePitstop()
					default:
						Throw "Invalid action """ . this.Action . """ detected in RaceEngineerAction.fireAction...."
				}
		}
	}

	class RaceEngineerSettingsAction extends RaceEngineerPlugin.RaceEngineerAction {
		fireAction(function, trigger) {
			if (this.Action = "RaceEngineerOpenSettings")
				openRaceEngineerSettings()
			else if (this.Action = "RaceEngineerImportSettings")
				openRaceEngineerSettings(true)
		}
	}
	
	class RaceEngineerToggleAction extends ControllerAction {
		fireAction(function, trigger) {
			local plugin := this.Controller.findPlugin(kRaceEngineerPlugin)
			
			if plugin.RaceEngineerName
				if (plugin.RaceEngineerEnabled && ((trigger = "Off") || (trigger == "Push"))) {
					plugin.disableRaceEngineer()
				
					trayMessage(plugin.actionLabel(this), translate("State: Off"))
				
					function.setText(plugin.actionLabel(this), "Black")
				}
				else if (!plugin.RaceEngineerEnabled && ((trigger = "On") || (trigger == "Push"))) {
					plugin.enableRaceEngineer()
				
					trayMessage(plugin.actionLabel(this), translate("State: On"))
				
					function.setText(plugin.actionLabel(this), "Green")
				}
		}
	}
	
	Simulator[] {
		Get {
			return this.iSimulator
		}
	}
	
	RaceEngineer[] {
		Get {
			return this.iRaceEngineer
		}
	}
	
	RaceEngineerEnabled[] {
		Get {
			return this.iRaceEngineerEnabled
		}
	}
	
	RaceEngineerName[] {
		Get {
			return this.iRaceEngineerName
		}
	}
	
	RaceEngineerLogo[] {
		Get {
			return this.iRaceEngineerLogo
		}
	}
	
	RaceEngineerSpeaker[] {
		Get {
			return this.iRaceEngineerSpeaker
		}
	}
	
	RaceEngineerListener[] {
		Get {
			return this.iRaceEngineerListener
		}
	}
	
	PitstopPending[] {
		Get {
			return this.iPitstopPending
		}
	}
	
	__New(controller, name, configuration := false) {
		base.__New(controller, name, configuration)
		
		this.iRaceEngineerName := this.getArgumentValue("raceEngineerName", false)
		this.iRaceEngineerLogo := this.getArgumentValue("raceEngineerLogo", false)
		
		raceEngineerToggle := this.getArgumentValue("raceEngineer", false)
		
		if raceEngineerToggle {
			arguments := string2Values(A_Space, raceEngineerToggle)
			
			this.iRaceEngineerEnabled := (arguments[1] = "On")
			
			this.createRaceEngineerAction(controller, "RaceEngineer", arguments[2])
		}
		else
			this.iRaceEngineerEnabled := (this.iRaceEngineerName != false)
		
		raceEngineerOpenSettings := this.getArgumentValue("raceEngineerOpenSettings", false)
		
		if raceEngineerOpenSettings
			this.createRaceEngineerAction(controller, "RaceEngineerOpenSettings", raceEngineerOpenSettings)
		
		raceEngineerImportSettings := this.getArgumentValue("raceEngineerImportSettings", false)
		
		if raceEngineerImportSettings
			this.createRaceEngineerAction(controller, "RaceEngineerImportSettings", raceEngineerImportSettings)
		
		for ignore, theAction in string2Values(",", this.getArgumentValue("raceEngineerCommands", ""))
			this.createRaceEngineerAction(controller, string2Values(A_Space, theAction)*)
		
		engineerSpeaker := this.getArgumentValue("raceEngineerSpeaker", false)
		
		if ((engineerSpeaker != false) && (engineerSpeaker != kFalse)) {
			this.iRaceEngineerSpeaker := ((engineerSpeaker = kTrue) ? true : engineerSpeaker)
		
			engineerListener := this.getArgumentValue("raceEngineerListener", false)
			
			if ((engineerListener != false) && (engineerListener != kFalse))
				this.iRaceEngineerListener := ((engineerListener = kTrue) ? true : engineerListener)
		}
		
		controller.registerPlugin(this)
	
		if (this.RaceEngineerName)
			SetTimer collectSessionData, 10000
		else
			SetTimer updateSessionState, 5000
	}
	
	createRaceEngineerAction(controller, action, actionFunction) {
		local function := controller.findFunction(actionFunction)
		
		if (function != false) {
			if ((action = "PitstopPlan") || (action = "PitstopPrepare"))
				this.registerAction(new this.RaceEngineerAction(function, this.getLabel(ConfigurationItem.descriptor(action, "Activate"), action), action))
			else if (action = "RaceEngineer")
				this.registerAction(new this.RaceEngineerToggleAction(function, this.getLabel(ConfigurationItem.descriptor(action, "Toggle"), action)))
			else if ((action = "RaceEngineerOpenSettings") || (action = "RaceEngineerImportSettings"))
				this.registerAction(new this.RaceEngineerSettingsAction(function, this.getLabel(ConfigurationItem.descriptor(action, "Activate")), action))
			else
				logMessage(kLogWarn, translate("Action """) . action . translate(""" not found in plugin ") . translate(this.Plugin) . translate(" - please check the configuration"))
		}
		else
			this.logFunctionNotFound(actionFunction)
	}
	
	activate() {
		base.activate()
		
		this.updateActions(kSessionFinished)
	}
		
	updateActions(sessionState) {
		for ignore, theAction in this.Actions
			if isInstance(theAction, RaceEngineerPlugin.RaceEngineerToggleAction) {
				theAction.Function.setText(this.actionLabel(theAction), this.RaceEngineerName ? (this.RaceEngineerEnabled ? "Green" : "Black") : "Gray")
				
				if !this.RaceEngineerName
					theAction.Function.disable()
			}
			else if isInstance(theAction, RaceEngineerPlugin.RaceEngineerAction)
				if (theAction.Action = "RaceEngineerOpenSettings") {
					theAction.Function.enable(kAllTrigger)
					theAction.Function.setText(theAction.Label)
				}
				else if (theAction.Action = "RaceEngineerImportSettings") {
					if this.Simulator {
						theAction.Function.enable(kAllTrigger)
						theAction.Function.setText(theAction.Label)
					}
					else {
						theAction.Function.disable(kAllTrigger)
						theAction.Function.setText(theAction.Label, "Gray")
					}
				}
				else if ((sessionState == kSessionRace) && (this.RaceEngineer != false)) {
					theAction.Function.enable(kAllTrigger)
					theAction.Function.setText(theAction.Label)
				}
				else {
					theAction.Function.disable(kAllTrigger)
					theAction.Function.setText(theAction.Label, "Gray")
				}
	}
	
	enableRaceEngineer() {
		this.iRaceEngineerEnabled := this.iRaceEngineerName
	}
	
	disableRaceEngineer() {
		this.iRaceEngineerEnabled := false
		
		if this.RaceEngineer
			this.finishSession()
	}
	
	startupRaceEngineer() {
		if (this.RaceEngineerEnabled) {
			Process Exist
			
			controllerPID := ErrorLevel
			raceEngineerPID := 0
								
			try {
				logMessage(kLogInfo, translate("Starting ") . translate("Race Engineer"))
				
				options := " -Settings """ . getFileName("Race Engineer.settings", kUserConfigDirectory, kConfigDirectory) . """"
				
				if this.Simulator.supportsPitstop()
					options .= " -Remote " . controllerPID
				
				if this.RaceEngineerName
					options .= " -Name """ . this.RaceEngineerName . """"
				
				if this.RaceEngineerLogo
					options .= " -Logo """ . this.RaceEngineerLogo . """"
				
				if this.RaceEngineerSpeaker
					options .= " -Speaker """ . this.RaceEngineerSpeaker . """"
				
				if this.RaceEngineerListener
					options .= " -Listener """ . this.RaceEngineerListener . """"
				
				if this.Controller.VoiceServer
					options .= " -Voice """ . this.Controller.VoiceServer . """"
				
				exePath := kBinariesDirectory . "Race Engineer.exe" . options 
				
				Run %exePath%, %kBinariesDirectory%, , raceEngineerPID
				
				Sleep 5000
			}
			catch exception {
				logMessage(kLogCritical, translate("Cannot start Race Engineer (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))
			
				showMessage(substituteVariables(translate("Cannot start Race Engineer (%kBinariesDirectory%Race Engineer.exe) - please rebuild the applications..."))
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				
				return false
			}
			
			this.iRaceEngineer := new this.RemoteRaceEngineer(raceEngineerPID)
		}
	}
	
	shutdownRaceEngineer() {
		local raceEngineer := this.RaceEngineer
		
		this.iRaceEngineer := false
		
		if raceEngineer
			raceEngineer.shutdown()
	}
	
	reloadSettings(pid, settingsFileName) {
		Process Exist, %pid%
		
		if ErrorLevel {
			callback := ObjBindMethod(this, "reloadSettings", pid, settingsFileName)
		
			SetTimer %callback%, -1000
		}
		else if this.RaceEngineer
			this.RaceEngineer.updateSession(settingsFileName)
	}
	
	startSession(dataFile) {
		if this.RaceEngineer
			this.finishSession(false)
		else
			this.startupRaceEngineer()
	
		if this.RaceEngineer
			this.RaceEngineer.startSession(dataFile)
	}
	
	finishSession(shutdown := true) {
		if this.RaceEngineer {
			this.RaceEngineer.finishSession()
			
			if shutdown
				this.shutdownRaceEngineer()
			
			this.iPitstopPending := false
		}
	}
	
	addLap(lapNumber, dataFile) {
		if this.RaceEngineer
			this.RaceEngineer.addLap(lapNumber, dataFile)
	}
	
	updateLap(lapNumber, dataFile) {
		if this.RaceEngineer
			this.RaceEngineer.updateLap(lapNumber, dataFile)
	}
	
	supportsPitstop() {
		return (this.Simulator ? this.Simulator.supportsPitstop() : false)
	}
	
	planPitstop() {
		if this.RaceEngineer
			this.RaceEngineer.planPitstop()
	}
	
	preparePitstop(lap := false) {
		if this.RaceEngineer
			this.RaceEngineer.preparePitstop(lap)
	}
	
	performPitstop(lapNumber) {
		if this.RaceEngineer {
			this.RaceEngineer.performPitstop(lapNumber)
		
			this.iPitstopPending := false
					
			SetTimer collectSessionData, 10000
		}
	}
	
	pitstopPlanned(pitstopNumber) {
		this.Simulator.pitstopPlanned(pitstopNumber)
	}
	
	pitstopPrepared(pitstopNumber) {
		this.iPitstopPending := true
		
		this.Simulator.pitstopPrepared(pitstopNumber)
		
		SetTimer collectSessionData, 5000
	}
	
	pitstopFinished(pitstopNumber) {
		this.iPitstopPending := false
		
		this.Simulator.pitstopFinished(pitstopNumber)
		
		SetTimer collectSessionData, 10000
	}
	
	startSimulation(simulator) {
		if (this.Simulator && (this.Simulator != simulator))
			Throw "Inconsistent state detected in RaceEngineerPlugin.simulatorStartup..."
		else if (this.Simulator != simulator) {
			this.iSimulator := simulator
		
			code := simulator.Code
			
			FileCreateDir %kTempDirectory%%code% Data
			
			Loop Files, %kTempDirectory%%code% Data\*.*
				FileDelete %A_LoopFilePath%
		}		
	}
	
	stopSimulation(simulator) {
		if (this.Simulator != simulator)
			Throw "Inconsistent state detected in RaceEngineerPlugin.simulatorShutdown..."
		else
			this.iSimulator := false
	}
	
	startPitstopSetup(pitstopNumber) {
		this.Simulator.startPitstopSetup(pitstopNumber)
	}

	finishPitstopSetup(pitstopNumber) {
		this.Simulator.finishPitstopSetup(pitstopNumber)
	}

	setPitstopRefuelAmount(pitstopNumber, litres) {
		this.Simulator.setPitstopRefuelAmount(pitstopNumber, litres)
	}
	
	setPitstopTyreSet(pitstopNumber, compound, compoundColor, set := false) {
		this.Simulator.setPitstopTyreSet(pitstopNumber, compound, compoundColor, set)
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		this.Simulator.setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork) {
		this.Simulator.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork)
	}
	
	getSessionState(data := false) {
		if this.Simulator {
			if !data
				data := readSharedMemory(this.Simulator.Code)
			
			if getConfigurationValue(data, "Session Data", "Active", false) {
				if getConfigurationValue(data, "Session Data", "Paused", false)
					return kSessionPaused
				else
					switch getConfigurationValue(data, "Session Data", "Session", "Other") {
						case "Race":
							return kSessionRace
						case "Practice":
							return kSessionPractice
						case "Qualification":
							return kSessionQualification
						default:
							return kSessionOther
					}
			}
			else
				return kSessionFinished
		}
		else
			return kSessionFinished
	}

	updateSessionState(sessionState := "__Undefined__") {
		if (sessionState == kUndefined)
			sessionState := this.getSessionState()
		
		if this.Simulator
			this.Simulator.updateSessionState(sessionState)
		else
			sessionState := kSessionFinished
		
		this.updateActions(sessionState)
	}
	
	collectSessionData() {
		static lastLap := 0
		static lastLapCounter := 0
		static inPit := false
		
		if this.Simulator {
			code := this.Simulator.Code
			
			data := readSharedMemory(code)
			
			this.Simulator.updateSimulatorData(data)
			
			dataLastLap := getConfigurationValue(data, "Stint Data", "Laps", 0)
			
			if false && isDebug() {
				testData := getConfigurationSectionValues(data, "Test Data", Object())
				
				if (testData.Count() > 0) {
					message := "Raw Data`n`n"
					
					for key, value in testData
						message := message . key . " = " . value . "`n"

					showMessage(message, translate("Modular Simulator Controller System"), "Information.png", 5000, "Left", "Bottom", 400, 400)
				}
			}
			
			protectionOn()
			
			try {
				sessionState := this.getSessionState(data)
				
				this.updateSessionState(sessionState)
				
				if (sessionState == kSessionPaused)
					return
				else if (sessionState < kSessionPractice) {
					; Not on track
				
					lastLap := 0
			
					if this.RaceEngineer
						this.finishSession()
					
					return
				}
				
				if ((dataLastLap <= 1) && (dataLastLap < lastLap)) {
					; Start of new race without finishing previous race first
				
					lastLap := 0
			
					if this.RaceEngineer
						this.finishSession()
				}
				
				if this.RaceEngineerEnabled {
					if (this.PitstopPending && getConfigurationValue(data, "Stint Data", "InPit", false) && !inPit) {
						; Car is in the Pit
						
						this.performPitstop(dataLastLap)
						
						inPit := true
					}
					else if (dataLastLap > 0) {
						; Car is on the track
					
						if ((dataLastLap > 1) && (lastLap == 0))
							return
						
						firstLap := (lastLap == 0)
						newLap := (dataLastLap > lastLap)
					
						inPit := false
						
						if newLap {
							lastLap := dataLastLap
							lastLapCounter := 0
						}
						
						newDataFile := kTempDirectory . code . " Data\Lap " . lastLap . "." . ++lastLapCounter . ".data"
							
						writeConfiguration(newDataFile, data)		; FileCopy %dataFile%, %newDataFile%, 1
						
						if firstLap
							this.startSession(newDataFile)
						
						if newLap
							this.addLap(dataLastLap, newDataFile)
						else	
							this.updateLap(dataLastLap, newDataFile)
					}
				}
				else {
					lastLap := 0
					inPit := false
				}
			}
			finally {
				protectionOff()
			}
		}
		else {
			if this.RaceEngineer
				Loop 10 {
					if this.Simulator
						return
					
					Sleep 500
				}
			
			lastLap := 0
		
			if this.RaceEngineer
				this.finishSession()
			
			this.updateSessionState(kSessionFinished)
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Controller Action Section                       ;;;
;;;-------------------------------------------------------------------------;;;

planPitstop() {
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kRaceEngineerPlugin).planPitstop()
	}
	finally {
		protectionOff()
	}
}

preparePitstop() {
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kRaceEngineerPlugin).preparePitstop()
	}
	finally {
		protectionOff()
	}
}

openRaceEngineerSettings(import := false) {
	local plugin
	
	exePath := kBinariesDirectory . "Race Engineer Settings.exe"
	
	try {
		controller := SimulatorController.Instance
		plugin := controller.findPlugin(kRaceEngineerPlugin)
		
		if import {
			options := "-Import"
			
			if (plugin && plugin.Simulator)
				options := (options . " """ . controller.ActiveSimulator . """ " . plugin.Simulator.Code)
			
			Run "%exePath%" %options%, %kBinariesDirectory%, , pid
		}
		else
			Run "%exePath%", %kBinariesDirectory%, , pid
		
		if pid {
			callback := ObjBindMethod(plugin, "reloadSettings", pid, getFileName("Race Engineer.settings", kUserConfigDirectory, kConfigDirectory))
			
			SetTimer %callback%, -1000
		}
	}
	catch exception {
		logMessage(kLogCritical, translate("Cannot start the Race Engineers Settings tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))
			
		showMessage(substituteVariables(translate("Cannot start the Race Engineers Settings tool (%exePath%) - please check the configuration..."), {exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

readSharedMemory(simulator, options := "", dataFile := false) {
	exePath := kBinariesDirectory . simulator . " SHM Reader.exe"
	
	if !dataFile
		dataFile := kTempDirectory . simulator . " Data\SHM.data"
	
	try {
		RunWait %ComSpec% /c ""%exePath%" %options% > "%dataFile%"", , Hide
	}
	catch exception {
		logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% SHM Reader ("), {simulator: simulator})
												   . exePath . translate(") - please rebuild the applications in the binaries folder (")
												   . kBinariesDirectory . translate(")"))
			
		showMessage(substituteVariables(translate("Cannot start %simulator% SHM Reader (%exePath%) - please check the configuration...")
									  , {exePath: exePath, simulator: simulator})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
	
	data := readConfiguration(dataFile)
	
	setConfigurationValue(data, "Session Data", "Simulator", simulator)
	
	return data
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

updateSessionState() {
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kRaceEngineerPlugin).updateSessionState()
	}
	finally {
		protectionOff()
	}
}

collectSessionData() {
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kRaceEngineerPlugin).collectSessionData()
	}
	finally {
		protectionOff()
	}
}

initializeRaceEngineerPlugin() {
	local controller := SimulatorController.Instance
	
	new RaceEngineerPlugin(controller, kRaceEngineerPlugin, controller.Configuration)
	
	registerEventHandler("Pitstop", "handlePitstopRemoteCalls")
}


;;;-------------------------------------------------------------------------;;;
;;;                          Event Handler Section                          ;;;
;;;-------------------------------------------------------------------------;;;

handlePitstopRemoteCalls(event, data) {
	if InStr(data, ":") {
		data := StrSplit(data, ":", , 2)
		
		return withProtection(ObjBindMethod(SimulatorController.Instance.findPlugin(kRaceEngineerPlugin), data[1]), string2Values(";", data[2])*)
	}
	else
		return withProtection(ObjBindMethod(SimulatorController.Instance.findPlugin(kRaceEngineerPlugin), data))
}

;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceEngineerPlugin()