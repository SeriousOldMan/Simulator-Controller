;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Plugin for Sector397 simulators ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "SimulatorPlugin.ahk"
#Include "..\..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kChatMode := "Chat"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class Sector397Plugin extends RaceAssistantSimulatorPlugin {
	iOpenPitstopMFDHotkey := false
	iClosePitstopMFDHotkey := false
	iRequestPitstopHotkey := false

	iOpenChatHotkey := false

	iPitstopMode := false
	iChatMode := false

	iChatActivation := false

	class ChatMode extends ControllerMode {
		Mode {
			Get {
				return kChatMode
			}
		}

		updateActions(session) {
		}

		handleChatMessage(message) {
			throw "Virtual method Sector397Plugin.ChatMode.handleChatMessage must be implemented in a subclass..."
		}
	}

	class ChatAction extends ControllerAction {
		iMode := false
		iMessage := ""

		Mode {
			Get {
				return this.iMode
			}
		}

		Message {
			Get {
				return this.iMessage
			}
		}

		__New(mode, function, label, message) {
			this.iMode := mode
			this.iMessage := message

			super.__New(function, label)
		}

		fireAction(function, trigger) {
			this.Mode.handleChatMessage(this.Message)
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

	RequestPitstopHotkey {
		Get {
			return this.iRequestPitstopHotkey
		}
	}

	OpenChatHotkey {
		Get {
			return this.iOpenChatHotkey
		}
	}

	__New(controller, name, simulator, configuration := false, register := true) {
		super.__New(controller, name, simulator, configuration, true)

		if (this.Active || (isDebug() && isDevelopment())) {
			this.iPitstopMode := this.findMode(kPitstopMode)

			this.iOpenChatHotkey := this.getArgumentValue("openChat", false)

			if (this.iChatMode && this.OpenChatHotkey && (Trim(this.OpenChatHotkey) != ""))
				this.registerMode(this.iChatMode)
			else
				this.iChatMode := false

			if !inList(A_Args, "-Replay")
				this.iOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", false)
			else
				this.iOpenPitstopMFDHotkey := "Off"

			if (this.OpenPitstopMFDHotkey && (this.OpenPitstopMFDHotkey != "Off"))
				this.iClosePitstopMFDHotkey := this.getArgumentValue("closePitstopMFD", false)

			this.iRequestPitstopHotkey := this.getArgumentValue("requestPitstop", false)

			if this.RequestPitstopHotkey {
				this.iRequestPitstopHotkey := Trim(this.RequestPitstopHotkey)

				if (this.RequestPitstopHotkey = "")
					this.iRequestPitstopHotkey := false
			}
		}
	}

	loadFromConfiguration(configuration) {
		local function, descriptor, message

		super.loadFromConfiguration(configuration)

		this.iChatActivation := getMultiMapValue(configuration, "Voice Control", "ChatActivation", false)

		if this.iChatActivation
			if !this.iChatMode
				this.iChatMode := this.createChatMode()

		for descriptor, message in getMultiMapValues(configuration, "Chat Messages") {
			function := this.Controller.findFunction(descriptor)

			if (function != false) {
				message := string2Values("|", message)

				if !this.iChatMode
					this.iChatMode := Sector397Plugin.ChatMode(this)

				this.iChatMode.registerAction(Sector397Plugin.ChatAction(this.iChatMode, function
																	   , message[1], message[2]))
			}
			else
				this.logFunctionNotFound(descriptor)
		}
	}

	createChatMode() {
		throw "Virtual method Sector397Plugin.createChatMode must be implemented in a subclass..."
	}

	simulatorStartup(simulator) {
		super.simulatorStartup(simulator)

		if ((simulator = this.Simulator[true]) && this.iChatActivation)
			this.Controller.connectChat(this, this.iChatActivation)
	}

	simulatorShutdown(simulator) {
		super.simulatorShutdown(simulator)

		if ((simulator = this.Simulator[true]) && this.iChatActivation)
			this.Controller.disconnectChat(this)
	}

	handleChatMessage(message) {
		local chatMode := this.findMode(kChatMode)

		if (chatMode && (this.Session >= kSessionOther))
			chatMode.handleChatMessage(message)
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
	}

	openPitstopMFD(descriptor := false) {
		static reported := false

		if this.OpenPitstopMFDHotkey {
			if (this.OpenPitstopMFDHotkey != "Off") {
				if this.activateWindow() {
					this.sendCommand(this.OpenPitstopMFDHotkey)

					return true
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

			if !kSilentMode
				showMessage(translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

			return false
		}
	}

	closePitstopMFD() {
		if this.ClosePitstopMFDHotkey {
			if (this.OpenPitstopMFDHotkey != "Off")
				if this.activateWindow()
					this.sendCommand(this.ClosePitstopMFDHotkey)
		}
	}

	requirePitstopMFD() {
		static nextRequest := 0

		if (A_TickCount > nextRequest) {
			nextRequest := (A_TickCount + 20000)

			if (this.OpenPitstopMFDHotkey && (this.OpenPitstopMFDHotkey != "Off"))
				return this.openPitstopMFD()
			else
				return true
		}
		else
			return true
	}

	selectPitstopOption(option) {
		local actions := false
		local ignore := false
		local candidate

		this.getPitstopActions(&actions, &ignore)

		for ignore, candidate in actions
			if (candidate = option)
				return true

		return false
	}
}