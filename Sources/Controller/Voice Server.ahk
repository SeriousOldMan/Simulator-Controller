;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Voice Server                    ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

;@SC-IF %configuration% == Development
#Include ..\Includes\Development.ahk
;@SC-EndIF

;@SC-If %configuration% == Production
;@SC #Include ..\Includes\Production.ahk
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Microphon.ico
;@Ahk2Exe-ExeName Voice Server.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Task.ahk
#Include ..\Libraries\Messages.ahk
#Include ..\Libraries\SpeechSynthesizer.ahk
#Include ..\Libraries\SpeechRecognizer.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kDebugOff := 0
global kDebugGrammars := 1
global kDebugPhrases := 2
global kDebugRecognitions := 4


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class VoiceServer extends ConfigurationItem {
	iDebug := kDebugOff

	iVoiceClients := {}
	iActiveVoiceClient := false

	iLanguage := "en"
	iSynthesizer := "dotNET"
	iSpeaker := true
	iSpeakerVolume := 100
	iSpeakerPitch := 0
	iSpeakerSpeed := 0
	iRecognizer := "Desktop"
	iListener := false
	iPushToTalk := false

	iSpeechRecognizer := false

	iSpeaking := false
	iListening := false

	iPendingCommands := []
	iHasPendingActivation := false
	iLastCommand := A_TickCount

	class VoiceClient {
		iCounter := 1

		iVoiceServer := false
		iDescriptor := false
		iPID := 0

		iLanguage := "en"
		iSynthesizer := "dotNET"
		iSpeaker := true
		iSpeakerVolume := 100
		iSpeakerPitch := 0
		iSpeakerSpeed := 0
		iRecognizer := "Desktop"
		iListener := false

		iSpeechSynthesizer := false

		iMuted := false
		iInterrupted := false
		iInterruptable := false

		iSpeechRecognizer := false
		iSpeaking := false
		iListening := false

		iActivationCallback := false
		iDeactivationCallback := false
		iVoiceCommands := {}

		VoiceServer[] {
			Get {
				return this.iVoiceServer
			}
		}

		Descriptor[] {
			Get {
				return this.iDescriptor
			}
		}

		PID[] {
			Get {
				return this.iPID
			}
		}

		Language[] {
			Get {
				return this.iLanguage
			}
		}

		Synthesizer[] {
			Get {
				return this.iSynthesizer
			}
		}

		Speaker[] {
			Get {
				return this.iSpeaker
			}
		}

		Speaking[] {
			Get {
				return this.iSpeaking
			}
		}

		Recognizer[] {
			Get {
				return this.iRecognizer
			}
		}

		Listener[] {
			Get {
				return this.iListener
			}
		}

		Listening[] {
			Get {
				return this.iListening
			}
		}

		SpeakerVolume[] {
			Get {
				return this.iSpeakerVolume
			}
		}

		SpeakerPitch[] {
			Get {
				return this.iSpeakerPitch
			}
		}

		SpeakerSpeed[] {
			Get {
				return this.iSpeakerSpeed
			}
		}

		ActivationCallback[] {
			Get {
				return this.iActivationCallback
			}
		}

		DeactivationCallback[] {
			Get {
				return this.iDeactivationCallback
			}
		}

		VoiceCommands[key := "__Undefined__"] {
			Get {
				if (key != kUndefined)
					return this.iVoiceCommands[key]
				else
					return this.iVoiceCommands
			}

			Set {
				if (key != kUndefined)
					return this.iVoiceCommands[key] := value
				else
					return this.iVoiceCommands := value
			}
		}

		SpeechSynthesizer[create := false] {
			Get {
				if (!this.iSpeechSynthesizer && create && this.Speaker) {
					this.iSpeechSynthesizer := new SpeechSynthesizer(this.Synthesizer, this.Speaker, this.Language)

					this.iSpeechSynthesizer.setVolume(this.SpeakerVolume)
					this.iSpeechSynthesizer.setPitch(this.SpeakerPitch)
					this.iSpeechSynthesizer.setRate(this.SpeakerSpeed)
				}

				return this.iSpeechSynthesizer
			}
		}

		Muted[] {
			Get {
				return this.iMuted
			}
		}

		Interrupted[] {
			Get {
				return this.iInterrupted
			}
		}

		Interruptable[] {
			Get {
				return this.iInterruptable
			}
		}

		SpeechRecognizer[create := false] {
			Get {
				if (!this.iSpeechRecognizer && create && this.Listener)
					this.iSpeechRecognizer := new SpeechRecognizer(this.Recognizer, this.Listener, this.Language)

				return this.iSpeechRecognizer
			}
		}

		__New(voiceServer, descriptor, pid, language, synthesizer, speaker, recognizer, listener, speakerVolume, speakerPitch, speakerSpeed, activationCallback, deactivationCallback) {
			this.iVoiceServer := voiceServer
			this.iDescriptor := descriptor
			this.iPID := pid
			this.iLanguage := language
			this.iSynthesizer := synthesizer
			this.iSpeaker := speaker
			this.iRecognizer := recognizer
			this.iListener := listener
			this.iSpeakerVolume := speakerVolume
			this.iSpeakerPitch := speakerPitch
			this.iSpeakerSpeed := speakerSpeed
			this.iActivationCallback := activationCallback
			this.iDeactivationCallback := deactivationCallback
		}

		speak(text) {
			local tries := 3
			local stopped, oldSpeaking

			while this.Muted
				Sleep 100

			this.iInterrupted := false

			stopped := this.VoiceServer.stopListening()
			oldSpeaking := this.Speaking

			this.iSpeaking := true

			try {
				try {
					while (tries-- > 0) {
						if (tries == 0)
							this.iInterruptable := false

						if !this.Interrupted
							this.SpeechSynthesizer[true].speak(text, true)

						if this.Interrupted {
							Sleep 2000

							this.iInterrupted := false
						}
						else
							break
					}
				}
				finally {
					this.iInterruptable := true
					this.iSpeaking := oldSpeaking
				}
			}
			finally {
				if stopped
					this.VoiceServer.startListening()
			}
		}

		startListening(retry := true) {
			if (this.SpeechRecognizer[true] && !this.Listening)
				if !this.SpeechRecognizer.startRecognizer() {
					if retry
						Task.startTask(ObjBindMethod(this, "startListening", true), 200)

					return false
				}
				else {
					if this.VoiceServer.PushToTalk
						SoundPlay %kResourcesDirectory%Sounds\Talk.wav

					this.iListening := true

					return true
				}
		}

		stopListening(retry := false) {
			if (this.SpeechRecognizer && this.Listening)
				if !this.SpeechRecognizer.stopRecognizer() {
					if retry
						Task.startTask(ObjBindMethod(this, "stopListening", true), 200)

					return false
				}
				else {
					this.iListening := false

					return true
				}
		}

		mute() {
			local synthesizer

			if !this.Muted {
				this.iMuted := true

				synthesizer := this.SpeechSynthesizer

				if synthesizer {
					if (this.Speaking && synthesizer.Stoppable && this.Interruptable) {
						this.iInterrupted := true

						synthesizer.stop()
					}

					synthesizer.mute()
				}
			}
		}

		unmute() {
			local synthesizer

			if this.Muted {
				this.iMuted := false

				synthesizer := this.SpeechSynthesizer

				if synthesizer
					synthesizer.unmute()
			}
		}

		registerChoices(name, choices*) {
			local recognizer := this.SpeechRecognizer[true]

			recognizer.setChoices(name, values2String(",", choices*))
		}

		registerVoiceCommand(grammar, command, callback) {
			local recognizer := this.SpeechRecognizer[true]
			local key, descriptor, nextCharIndex

			if !grammar {
				for key, descriptor in this.iVoiceCommands
					if ((descriptor[1] = command) && (descriptor[2] = callback))
						return

				grammar := ("__Grammar." . this.iCounter++)
			}
			else if this.VoiceCommands.HasKey(grammar) {
				descriptor := this.VoiceCommands[grammar]

				if ((descriptor[1] = command) && (descriptor[2] = callback))
					return
			}

			if this.VoiceServer.Debug[kDebugGrammars] {
				nextCharIndex := 1

				showMessage("Register command phrase: " . new GrammarCompiler(recognizer).readGrammar(command, nextCharIndex).toString())
			}

			try {
				if !recognizer.loadGrammar(grammar, recognizer.compileGrammar(command), ObjBindMethod(this.VoiceServer, "recognizeVoiceCommand", this))
					throw "Recognizer not running..."
			}
			catch exception {
				logMessage(kLogCritical, translate("Error while registering voice command """) . command . translate(""" - please check the configuration"))

				showMessage(substituteVariables(translate("Cannot register voice command ""%command%"" - please check the configuration..."), {command: command})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}

			this.VoiceCommands[grammar] := Array(command, callback)
		}

		activate(words := false) {
			if this.ActivationCallback {
				if !words
					words := []

				sendMessage(kFileMessage, "Voice", this.ActivationCallback . ":" . values2String(";", words*), this.PID)
			}
		}

		deactivate() {
			if this.DeactivationCallback
				sendMessage(kFileMessage, "Voice", this.DeactivationCallback, this.PID)
		}

		recognizeVoiceCommand(grammar, words) {
			if this.VoiceCommands.HasKey(grammar)
				this.VoiceServer.recognizeVoiceCommand(this, grammar, words)
		}
	}

	Debug[option] {
		Get {
			return (this.iDebug & option)
		}
	}

	VoiceClients[] {
		Get {
			return this.iVoiceClients
		}
	}

	ActiveVoiceClient[] {
		Get {
			return this.iActiveVoiceClient
		}
	}

	Language[] {
		Get {
			return this.iLanguage
		}
	}

	Synthesizer[] {
		Get {
			return this.iSynthesizer
		}
	}

	Speaker[] {
		Get {
			return this.iSpeaker
		}
	}

	Speaking[] {
		Get {
			return this.iSpeaking
		}
	}

	Recognizer[] {
		Get {
			return this.iRecognizer
		}
	}

	Listener[] {
		Get {
			return this.iListener
		}
	}

	Listening[] {
		Get {
			return this.iListening
		}
	}

	SpeakerVolume[] {
		Get {
			return this.iSpeakerVolume
		}
	}

	SpeakerPitch[] {
		Get {
			return this.iSpeakerPitch
		}
	}

	SpeakerSpeed[] {
		Get {
			return this.iSpeakerSpeed
		}
	}

	PushToTalk[] {
		Get {
			return this.iPushToTalk
		}
	}

	SpeechRecognizer[create := false] {
		Get {
			if (create && this.Listener && !this.iSpeechRecognizer) {
				try {
					try {
						this.iSpeechRecognizer := new SpeechRecognizer("Server", true, this.Language, true)

						if (this.iSpeechRecognizer.Recognizers.Length() = 0)
							throw "Server speech recognizer engine not installed..."
					}
					catch exception {
						this.iSpeechRecognizer := new SpeechRecognizer("Desktop", true, this.Language, true)

						if (this.iSpeechRecognizer.Recognizers.Length() = 0)
							throw "Desktop speech recognizer engine not installed..."
					}
				}
				catch exception {
					this.iSpeechRecognizer := new SpeechRecognizer(this.Recognizer, this.Listener, this.Language)
				}

				if !this.PushToTalk
					this.startListening()
			}

			return this.iSpeechRecognizer
		}
	}

	__New(configuration := false) {
		local label, callback

		this.iDebug := (isDebug() ? (kDebugGrammars + kDebugPhrases + kDebugRecognitions) : kDebugOff)

		base.__New(configuration)

		VoiceServer.Instance := this

		new PeriodicTask(ObjBindMethod(this, "runPendingCommands"), 500).start()
		new PeriodicTask(ObjBindMethod(this, "unregisterStaleVoiceClients"), 5000, kLowPriority).start()

		deleteFile(kTempDirectory . "Voice.mute")

		new PeriodicTask(ObjBindMethod(this, "muteVoiceClients"), 50, kInterruptPriority).start()
	}

	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)

		this.iLanguage := getConfigurationValue(configuration, "Voice Control", "Language", getLanguage())
		this.iSynthesizer := getConfigurationValue(configuration, "Voice Control", "Synthesizer"
												 , getConfigurationValue(configuration, "Voice Control", "Service", "dotNET"))
		this.iSpeaker := getConfigurationValue(configuration, "Voice Control", "Speaker", true)
		this.iSpeakerVolume := getConfigurationValue(configuration, "Voice Control", "SpeakerVolume", 100)
		this.iSpeakerPitch := getConfigurationValue(configuration, "Voice Control", "SpeakerPitch", 0)
		this.iSpeakerSpeed := getConfigurationValue(configuration, "Voice Control", "SpeakerSpeed", 0)
		this.iRecognizer := getConfigurationValue(configuration, "Voice Control", "Recognizer", "Desktop")
		this.iListener := getConfigurationValue(configuration, "Voice Control", "Listener", false)
		this.iPushToTalk := getConfigurationValue(configuration, "Voice Control", "PushToTalk", false)

		if this.PushToTalk
			new PeriodicTask(ObjBindMethod(this, "listen"), 50, kHighPriority).start()
	}

	listen() {
		static isPressed := false
		static lastDown := 0
		static lastUp := 0
		static clicks := 0
		static activation := false
		static lastPressed := false

		pressed := GetKeyState(this.PushToTalk, "P")

		if (!pressed && !lastPressed)
			return
		else
			lastPressed := pressed

		if (pressed && !isPressed) {
			lastDown := A_TickCount
			isPressed := true

			if (((lastDown - lastUp) < 400) && (clicks == 1))
				activation := true
			else {
				clicks := 0

				activation := false
			}
		}
		else if (!pressed && isPressed) {
			lastUp := A_TickCount
			isPressed := false

			if ((lastUp - lastDown) < 400)
				clicks += 1
			else
				clicks := 0
		}

		if (((A_TickCount - lastDown) < 200) && !activation)
			pressed := false

		if !this.Speaking && pressed {
			if activation
				this.startActivationListener()
			else
				this.startListening(false)
		}
		else if !pressed {
			this.stopActivationListener()
			this.stopListening()
		}
	}

	setDebug(option, enabled) {
		local label := false

		if enabled
			this.iDebug := (this.iDebug | option)
		else if (this.Debug[option] == option)
			this.iDebug := (this.iDebug - option)

		switch option {
			case kDebugRecognitions:
				label := translate("Debug Recognitions")
			case kDebugGrammars:
				label := translate("Debug Grammars")
		}

		if label
			if enabled
				Menu SupportMenu, Check, %label%
			else
				Menu SupportMenu, Uncheck, %label%
	}

	toggleDebug(option) {
		this.setDebug(option, !this.Debug[option])
	}

	getVoiceClient(descriptor := false) {
		if descriptor
			return this.VoiceClients[descriptor]
		else
			return this.ActiveVoiceClient
	}

	activateVoiceClient(descriptor, words := false) {
		local activeVoiceClient

		if (this.ActiveVoiceClient && (this.ActiveVoiceClient.Descriptor = descriptor))
			this.ActiveVoiceClient.activate(words)
		else {
			if this.ActiveVoiceClient
				this.deactivateVoiceClient(this.ActiveVoiceClient.Descriptor)

			activeVoiceClient := this.VoiceClients[descriptor]

			this.iActiveVoiceClient := activeVoiceClient

			activeVoiceClient.activate(words)

			if !this.PushToTalk
				this.startListening()
		}
	}

	deactivateVoiceClient(descriptor) {
		local activeVoiceClient := this.ActiveVoiceClient

		if (activeVoiceClient && (activeVoiceClient.Descriptor = descriptor)) {
			activeVoiceClient.stopListening()

			this.iActiveVoiceClient := false

			activeVoiceClient.deactivate()
		}
	}

	startActivationListener(retry := false) {
		if (this.SpeechRecognizer && !this.Listening)
			if !this.SpeechRecognizer.startRecognizer() {
				if retry
					Task.startTask(ObjBindMethod(this, "startActivationListener", true), 200)

				return false
			}
			else {
				if this.PushToTalk
					SoundPlay %kResourcesDirectory%Sounds\Talk.wav

				this.iListening := true

				return true
			}
	}

	stopActivationListener(retry := false) {
		if (this.SpeechRecognizer && this.Listening)
			if !this.SpeechRecognizer.stopRecognizer() {
				if retry
					Task.startTask(ObjBindMethod(this, "stopActivationListener", true), 200)

				return false
			}
			else {
				this.iListening := false

				return true
			}
	}

	startListening(retry := true) {
		local activeClient := this.getVoiceClient()

		return (activeClient ? activeClient.startListening(retry) : false)
	}

	stopListening(retry := false) {
		local activeClient := this.getVoiceClient()

		return (activeClient ? activeClient.stopListening(retry) : false)
	}

	muteVoiceClients() {
		local ignore, client

		if FileExist(kTempDirectory . "Voice.mute")
			for ignore, client in this.VoiceClients
				client.mute()
		else
			for ignore, client in this.VoiceClients
				client.unmute()
	}

	speak(descriptor, text, activate := false) {
		local oldSpeaking := this.Speaking

		this.iSpeaking := true

		try {
			this.getVoiceClient(descriptor).speak(text)

			if activate
				this.activateVoiceClient(descriptor)

		}
		finally {
			this.iSpeaking := oldSpeaking
		}
	}

	registerVoiceClient(descriptor, pid, activationCommand := false, activationCallback := false, deactivationCallback := false, language := false, synthesizer := true, speaker := true, recognizer := false, listener := false, speakerVolume := "__Undefined__", speakerPitch := "__Undefined__", speakerSpeed := "__Undefined__") {
		local grammar, client, nextCharIndex, command, theDescriptor, ignore

		static counter := 1

		if (speakerVolume = kUndefined)
			speakerVolume := this.SpeakerVolume

		if (speakerPitch = kUndefined)
			speakerPitch := this.SpeakerPitch

		if (speakerSpeed = kUndefined)
			speakerSpeed := this.SpeakerSpeed

		if (synthesizer == true)
			synthesizer := this.Synthesizer

		if (speaker == true)
			speaker := this.Speaker

		if (recognizer == true)
			recognizer := this.Recognizer

		if (listener == true)
			listener := this.Listener

		if (language == false)
			language := this.Language

		client := this.VoiceClients[descriptor]

		if (client && (this.ActiveVoiceClient == client))
			this.deactivateVoiceClient(descriptor)

		client := new this.VoiceClient(this, descriptor, pid, language, synthesizer, speaker, recognizer, listener, speakerVolume, speakerPitch, speakerSpeed, activationCallback, deactivationCallback)

		this.VoiceClients[descriptor] := client

		if (activationCommand && (StrLen(Trim(activationCommand)) > 0) && listener) {
			recognizer := this.SpeechRecognizer[true]

			grammar := (descriptor . "." . counter++)

			if this.Debug[kDebugGrammars] {
				nextCharIndex := 1

				showMessage("Register activation phrase: " . new GrammarCompiler(recognizer).readGrammar(activationCommand, nextCharIndex).toString())
			}

			try {
				command := recognizer.compileGrammar(activationCommand)

				if !recognizer.loadGrammar(grammar, command, ObjBindMethod(this, "recognizeActivationCommand", client))
					throw "Recognizer not running..."
			}
			catch exception {
				logMessage(kLogCritical, translate("Error while registering voice command """) . activationCommand . translate(""" - please check the configuration"))

				showMessage(substituteVariables(translate("Cannot register voice command ""%command%"" - please check the configuration..."), {command: activationCommand})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}

		if (this.VoiceClients.Count() = 1)
			this.activateVoiceClient(descriptor)
		else if (this.VoiceClients.Count() > 1) {
			for theDescriptor, ignore in this.VoiceClients
				if (descriptor != theDescriptor)
					this.deactivateVoiceClient(theDescriptor)

			if !this.PushToTalk
				this.startActivationListener()
		}
	}

	unregisterVoiceClient(descriptor, pid) {
		local client := this.VoiceClients[descriptor]
		local theDescriptor, ignore

		if (client && (this.ActiveVoiceClient == client))
			this.deactivateVoiceClient(descriptor)

		this.VoiceClients.Delete(descriptor)

		if (this.VoiceClients.Count() = 1) {
			for theDescriptor, ignore in this.VoiceClients
				this.activateVoiceClient(theDescriptor)

			if !this.PushToTalk
				this.stopActivationListener()
		}
	}

	unregisterStaleVoiceClients() {
		local descriptor, voiceClient, pid

		protectionOn()

		try {
			for descriptor, voiceClient in this.VoiceClients {
				pid := voiceClient.PID

				Process Exist, %pid%

				if !ErrorLevel {
					this.unregisterVoiceClient(descriptor, pid)

					this.unregisterStaleVoiceClients()

					break
				}
			}
		}
		finally {
			protectionOff()
		}
	}

	registerChoices(descriptor, name, choices*) {
		this.getVoiceClient(descriptor).registerChoices(name, choices*)
	}

	registerVoiceCommand(descriptor, grammar, command, callback) {
		this.getVoiceClient(descriptor).registerVoiceCommand(grammar, command, callback)
	}

	recognizeActivation(descriptor, grammar, words*) {
		local voiceClient := this.VoiceClients[descriptor]

		if voiceClient
			this.recognizeActivationCommand(voiceClient, voiceClient.Descriptor, words)
	}

	recognizeCommand(grammar, words*) {
		local ignore, voiceClient

		for ignore, voiceClient in this.VoiceClients
			voiceClient.recognizeVoiceCommand(grammar, words)
	}

	recognizeActivationCommand(voiceClient, grammar, words) {
		this.addPendingCommand(ObjBindMethod(this, "activationCommandRecognized", voiceClient, grammar, words), voiceClient)
	}

	recognizeVoiceCommand(voiceClient, grammar, words) {
		this.addPendingCommand(ObjBindMethod(this, "voiceCommandRecognized", voiceClient, grammar, words))
	}

	addPendingCommand(command, activation := false) {
		if activation
			if (activation != this.ActiveVoiceClient)
				this.iPendingCommands := []
			else if (this.iPendingCommands.Length() > 0)
				return

		this.iLastCommand := A_TickCount

		if !activation
			this.clearPendingActivations()

		this.iPendingCommands.Push(Array(activation, command))
	}

	clearPendingActivations() {
		local index, command

		for index, command in this.iPendingCommands
			if command[1] {
				this.iPendingCommands.RemoveAt(index)

				this.clearPendingActivations()

				break
			}
	}

	runPendingCommands() {
		local command

		if (A_TickCount < (this.iLastCommand + 1000))
			return

		protectionOn()

		try {
			if (this.iPendingCommands.Length() == 0)
				return
			else {
				command := this.iPendingCommands.RemoveAt(1)

				if command {
					command := command[2]

					%command%()
				}
			}
		}
		finally {
			protectionOff()
		}
	}

	activationCommandRecognized(voiceClient, grammar, words) {
		if this.Debug[kDebugRecognitions]
			showMessage("Activation phrase recognized: " . values2String(A_Space, words*))

		this.activateVoiceClient(ConfigurationItem.splitDescriptor(grammar)[1], words)
	}

	voiceCommandRecognized(voiceClient, grammar, words) {
		local descriptor := voiceClient.VoiceCommands[grammar]

		if this.Debug[kDebugRecognitions]
			showMessage("Command phrase recognized: " . grammar . " => " . values2String(A_Space, words*), false, "Information.png", 5000)

		sendMessage(kFileMessage, "Voice", descriptor[2] . ":" . values2String(";", grammar, descriptor[1], words*), voiceClient.PID)
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

startupVoiceServer() {
	local icon := kIconsDirectory . "Microphon.ico"
	local debug, index, server

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Voice Server

	debug := false

	index := 1

	while (index < A_Args.Length()) {
		switch A_Args[index] {
			case "-Debug":
				debug := (((A_Args[index + 1] = kTrue) || (A_Args[index + 1] = true)) ? true : false)
				index += 2
			default:
				index += 1
		}
	}

	if debug
		setDebug(true)

	server := new VoiceServer(kSimulatorConfiguration)

	Menu SupportMenu, Insert, 1&

	label := translate("Debug Recognitions")
	callback := ObjBindMethod(server, "toggleDebug", kDebugRecognitions)

	Menu SupportMenu, Insert, 1&, %label%, %callback%

	if server.Debug[kDebugRecognitions]
		Menu SupportMenu, Check, %label%

	label := translate("Debug Grammars")
	callback := ObjBindMethod(server, "toggleDebug", kDebugGrammars)

	Menu SupportMenu, Insert, 1&, %label%, %callback%

	if server.Debug[kDebugGrammars]
		Menu SupportMenu, Check, %label%

	registerMessageHandler("Voice", "handleVoiceMessage")

	return
}


;;;-------------------------------------------------------------------------;;;
;;;                         Message Handler Section                         ;;;
;;;-------------------------------------------------------------------------;;;

handleVoiceMessage(category, data) {
	if InStr(data, ":") {
		data := StrSplit(data, ":", , 2)

		if (data[1] = "Shutdown") {
			Sleep 30000

			ExitApp 0
		}

		return withProtection(ObjBindMethod(VoiceServer.Instance, data[1]), string2Values(";", data[2])*)
	}
	else if (data = "Shutdown") {
		Sleep 30000

		ExitApp 0
	}
	else
		return withProtection(ObjBindMethod(VoiceServer.Instance, data))
}


;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

startupVoiceServer()