﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Voice Server                    ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

;@SC-IF %configuration% == Development
#Include "..\Framework\Development.ahk"
;@SC-EndIF

;@SC-If %configuration% == Production
;@SC #Include "..\Framework\Production.ahk"
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Microphon.ico
;@Ahk2Exe-ExeName Voice Server.exe
;@Ahk2Exe-SetCompanyName Oliver Juwig (TheBigO)
;@Ahk2Exe-SetCopyright TheBigO - Creative Commons - BY-NC-SA
;@Ahk2Exe-SetProductName Simulator Controller
;@Ahk2Exe-SetVersion 0.0.0.0


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Process.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Extensions\Task.ahk"
#Include "..\Framework\Extensions\Messages.ahk"
#Include "..\Framework\Extensions\SpeechSynthesizer.ahk"
#Include "..\Framework\Extensions\SpeechRecognizer.ahk"
#Include "..\Framework\Extensions\LLMBooster.ahk"


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
	static sInterruptable := getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))
											, "Voice", "Interruptable", false)

	iDebug := kDebugOff

	iVoiceClients := CaseInsenseMap()
	iActiveVoiceClient := false

	iActivationGrammars := []

	iLanguage := "en"
	iSynthesizer := "dotNET"
	iSpeaker := true
	iSpeakerVolume := 100
	iSpeakerPitch := 0
	iSpeakerSpeed := 0
	iRecognizer := "Desktop"
	iListener := false
	iPushToTalk := false
	iPushToTalkMode := false

	iSpeechRecognizer := false

	iSpeaking := false
	iListening := false

	iListenerActive := true

	iPendingCommands := []
	iHasPendingActivation := false
	iLastCommand := A_TickCount

	iLastInterrupt := false

	class VoiceClient {
		iRouting := false

		iActive := true

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
		iSpeakerBooster := false
		iRecognizer := "Desktop"
		iListener := false
		iListenerBooster := false

		iRecognizerMode := "Grammar"

		iSpeechSynthesizer := false

		iMuted := false
		iInterrupted := false
		iInterruptable := true

		iSpeechRecognizer := false
		iSpeaking := false
		iListening := false

		iActivationCallback := false
		iDeactivationCallback := false
		iSpeakingStatusCallback := false
		iVoiceCommands := CaseInsenseMap()

		class ClientSpeechSynthesizer extends SpeechSynthesizer {
			iVoiceClient := false
			iBooster := false

			Routing {
				Get {
					return this.VoiceClient.Routing
				}
			}

			VoiceClient {
				Get {
					return this.iVoiceClient
				}
			}

			Booster {
				Get {
					return this.iBooster
				}
			}

			__New(voiceClient, arguments*) {
				local booster

				if voiceClient.SpeakerBooster {
					booster := SpeechBooster(voiceClient.SpeakerBooster, voiceClient.VoiceServer.Configuration, voiceClient.Language)

					if (booster.Model && booster.Active)
						this.iBooster := booster
				}

				this.iVoiceClient := voiceClient

				super.__New(arguments*)
			}
		}

		class ClientSpeechRecognizer extends SpeechRecognizer {
			iVoiceClient := false
			iBooster := false

			Routing {
				Get {
					return this.VoiceClient.Routing
				}
			}

			VoiceClient {
				Get {
					return this.iVoiceClient
				}
			}

			Booster {
				Get {
					return this.iBooster
				}
			}

			__New(voiceClient, arguments*) {
				local booster

				if voiceClient.ListenerBooster {
					booster := RecognitionBooster(voiceClient.ListenerBooster, voiceClient.VoiceServer.Configuration, voiceClient.Language)

					if (booster.Model && booster.Active)
						this.iBooster := booster
				}

				this.iVoiceClient := voiceClient

				super.__New(arguments*)
			}

			textRecognized(text) {
				this.VoiceClient.VoiceServer.recognizeText(this.VoiceClient, text)
			}

			parseText(&text, rephrase := false) {
				local booster := this.Booster
				local alternateText

				if (booster && rephrase && (booster.Mode = "Always")) {
					alternateText := booster.recognize(text)

					if (alternateText && (alternateText != ""))
						text := alternateText
				}

				return super.parseText(&text)
			}

			unknownRecognized(&text, rephrase := false) {
				local booster := this.Booster
				local alternateText

				if (booster && rephrase && (booster.Mode = "Unknown")) {
					alternateText := booster.recognize(text)

					if (alternateText && (alternateText != "") && (alternateText != text)) {
						text := alternateText

						return true
					}
				}

				if this.Grammars.Has("?")
					return !this.VoiceClient.VoiceServer.unknownRecognized(this.VoiceClient, text)
				else
					return super.unknownRecognized(&text)
			}
		}

		Routing {
			Get {
				return this.iRouting
			}
		}

		Active {
			Get {
				return this.iActive
			}

			Set {
				return (this.iActive := value)
			}
		}

		VoiceServer {
			Get {
				return this.iVoiceServer
			}
		}

		Descriptor {
			Get {
				return this.iDescriptor
			}
		}

		PID {
			Get {
				return this.iPID
			}
		}

		Language {
			Get {
				return this.iLanguage
			}
		}

		Synthesizer {
			Get {
				return this.iSynthesizer
			}
		}

		Speaker {
			Get {
				return this.iSpeaker
			}
		}

		Speaking {
			Get {
				return this.iSpeaking
			}
		}

		Recognizer {
			Get {
				return this.iRecognizer
			}
		}

		Listener {
			Get {
				return this.iListener
			}
		}

		RecognizerMode {
			Get {
				return this.iRecognizerMode
			}
		}

		Listening {
			Get {
				return this.iListening
			}
		}

		SpeakerVolume {
			Get {
				return this.iSpeakerVolume
			}
		}

		SpeakerPitch {
			Get {
				return this.iSpeakerPitch
			}
		}

		SpeakerSpeed {
			Get {
				return this.iSpeakerSpeed
			}
		}

		SpeakerBooster {
			Get {
				return this.iSpeakerBooster
			}
		}

		ListenerBooster {
			Get {
				return this.iListenerBooster
			}
		}

		ActivationCallback {
			Get {
				return this.iActivationCallback
			}
		}

		DeactivationCallback {
			Get {
				return this.iDeactivationCallback
			}
		}

		SpeakingStatusCallback {
			Get {
				return this.iSpeakingStatusCallback
			}
		}

		VoiceCommands[key := kUndefined] {
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
					this.iSpeechSynthesizer := VoiceServer.VoiceClient.ClientSpeechSynthesizer(this, this.Synthesizer, this.Speaker, this.Language)

					this.iSpeechSynthesizer.setVolume(this.SpeakerVolume)
					this.iSpeechSynthesizer.setPitch(this.SpeakerPitch)
					this.iSpeechSynthesizer.setRate(this.SpeakerSpeed)
				}

				return this.iSpeechSynthesizer
			}
		}

		Muted {
			Get {
				return this.iMuted
			}
		}

		Interrupted {
			Get {
				return this.iInterrupted
			}
		}

		Interruptable {
			Get {
				return this.iInterruptable
			}
		}

		SpeechRecognizer[create := false] {
			Get {
				if (!this.iSpeechRecognizer && create && this.Listener)
					this.iSpeechRecognizer := VoiceServer.VoiceClient.ClientSpeechRecognizer(this, this.Recognizer, this.Listener
																						   , this.Language, false, this.RecognizerMode)

				return this.iSpeechRecognizer
			}
		}

		__New(voiceServer, descriptor, routing, pid
			, language, synthesizer, speaker, recognizer, listener
			, speakerVolume, speakerPitch, speakerSpeed, speakerBooster, listenerBooster
			, activationCallback, deactivationCallback, speakingStatusCallback, recognizerMode) {
			this.iVoiceServer := voiceServer
			this.iDescriptor := descriptor
			this.iRouting := routing
			this.iPID := pid
			this.iLanguage := language
			this.iSynthesizer := synthesizer
			this.iSpeaker := speaker
			this.iRecognizer := recognizer
			this.iListener := listener
			this.iRecognizerMode := recognizerMode
			this.iSpeakerVolume := speakerVolume
			this.iSpeakerPitch := speakerPitch
			this.iSpeakerSpeed := speakerSpeed
			this.iSpeakerBooster := speakerBooster
			this.iListenerBooster := listenerBooster
			this.iActivationCallback := activationCallback
			this.iDeactivationCallback := deactivationCallback
			this.iSpeakingStatusCallback := speakingStatusCallback
		}

		speak(text, options := false) {
			local speaker := this.SpeechSynthesizer[true]
			local booster := speaker.Booster
			local tries, stopped, oldSpeaking, oldInterruptable, parts, ignore, part

			if booster {
				if options {
					options := toMap(options)

					text := booster.speak(text, Map("Rephrase", (!options.Has("Rephrase") || options["Rephrase"])
												  , "Translate", (options.Has("Translate") && options["Tranlate"])
												  , "Variables", {assistant: this.Routing}))
				}
				else
					text := booster.speak(text, Map("Variables", {assistant: this.Routing}))
			}

			while this.Muted
				Sleep(100)

			this.iInterrupted := false

			stopped := this.VoiceServer.stopListening()
			oldSpeaking := this.Speaking
			oldInterruptable := this.iInterruptable

			if (!options || (options.HasProp("UseTalking") && options.UseTalking))
				parts := [text]
			else {
				parts := []

				for ignore, part in string2Values(". ", text)
					parts.Push(part . ".")
			}

			try {
				if !this.Speaking
					this.startSpeaking()

				this.iSpeaking := true
				this.iInterruptable := true

				try {
					for ignore, part in parts {
						tries := 5

						while (tries-- > 0) {
							if (tries == 0)
								speaker.speak(part, true, false, options)
							else {
								if !this.Interrupted
									speaker.speak(part, true, false, options)

								if (this.Interrupted = "Abort") {
									this.iInterrupted := false

									break
								}
								else if this.Interrupted {
									Sleep(2000)

									while this.Muted {
										while this.Muted
											Sleep(100)

										Sleep(Round(Random(1, 2000)))
									}

									this.iInterrupted := false
								}
								else
									break
							}
						}
					}
				}
				finally {
					this.iInterruptable := oldInterruptable
					this.iSpeaking := oldSpeaking

					if !this.Speaking
						this.stopSpeaking()
				}
			}
			finally {
				if stopped
					this.VoiceServer.startListening()
			}
		}

		startSpeaking() {
			if this.SpeakingStatusCallback
				messageSend(kFileMessage, "Voice", this.SpeakingStatusCallback . ":Start", this.PID)
		}

		stopSpeaking() {
			if this.SpeakingStatusCallback
				messageSend(kFileMessage, "Voice", this.SpeakingStatusCallback . ":Stop", this.PID)
		}

		startListening(retry := true) {
			static audioDevice := getMultiMapValue(readMultiMap(kUserConfigDirectory . "Audio Settings.ini"), "Output", "Activation.AudioDevice", false)
			static talkSound := getFileName("Talk.wav", kUserHomeDirectory . "Sounds\", kResourcesDirectory . "Sounds\")

			if (this.SpeechRecognizer[true] && !this.Listening)
				if !this.SpeechRecognizer.startRecognizer() {
					if retry
						Task.startTask(ObjBindMethod(this, "startListening", true), 200)

					return false
				}
				else {
					if this.VoiceServer.hasPushToTalk()
						playSound("VSSoundPlayer.exe", talkSound, audioDevice)

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

		interrupt(pending := false) {
			local synthesizer := this.SpeechSynthesizer

			if (synthesizer && this.Speaking && !this.Interrupted && this.Interruptable && synthesizer.Stoppable)
				this.iInterrupted := (synthesizer.stop() ? "Abort" : false)
		}

		mute() {
			local synthesizer := this.SpeechSynthesizer

			if (synthesizer && this.Speaking && !this.Interrupted && this.Interruptable && synthesizer.Stoppable)
				this.iInterrupted := synthesizer.stop()

			if !this.Muted {
				this.iMuted := true

				if synthesizer
					synthesizer.mute()
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

			if recognizer {
				recognizer.setChoices(name, values2String(",", choices*))

				if recognizer.Booster
					recognizer.Booster.setChoices(name, choices)
			}
		}

		registerVoiceCommand(grammar, command, callback) {
			local recognizer := this.SpeechRecognizer[true]
			local key, descriptor, nextCharIndex

			if recognizer {
				if !grammar {
					for key, descriptor in this.iVoiceCommands
						if ((descriptor[1] = command) && (descriptor[2] = callback))
							return

					grammar := ("__Grammar." . this.iCounter++)
				}
				else if this.VoiceCommands.Has(grammar) {
					descriptor := this.VoiceCommands[grammar]

					if ((descriptor[1] = command) && (descriptor[2] = callback))
						return
				}

				if this.VoiceServer.Debug[kDebugGrammars] {
					nextCharIndex := 1

					showMessage("Register command phrase: " . GrammarCompiler(recognizer).readGrammar(&command, &nextCharIndex).toString())
				}

				try {
					if (grammar = "Text") {
						; if (this.RecognizerMode != "Text")
						;	throw "Continuous text is not supported in grammar based recognition..."
					}
					else if (this.RecognizerMode = "Text")
						throw "Listener grammars are not supported in continuous text recognition..."
					else {
						if !recognizer.loadGrammar(grammar, recognizer.compileGrammar(command), ObjBindMethod(this.VoiceServer, "recognizeVoiceCommand", this))
							throw "Recognizer not running..."

						if recognizer.Booster
							recognizer.Booster.setGrammar(grammar, command)
					}

					this.VoiceCommands[grammar] := Array(command, callback)
				}
				catch Any as exception {
					logError(exception, true)

					logMessage(kLogCritical, translate("Error while registering voice command `"") . command . translate("`" - please check the configuration"))

					if !kSilentMode
						showMessage(substituteVariables(translate("Cannot register voice command `"%command%`" - please check the configuration..."), {command: command})
								  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				}
			}
		}

		registerRecognitionHandler(handler) {
			this.SpeechRecognizer[true].registerRecognitionHandler(this, handler)
		}

		activate(words := false) {
			if this.ActivationCallback {
				if !words
					words := []

				if (words.Length = 0)
					messageSend(kFileMessage, "Voice", this.ActivationCallback, this.PID)
				else
					messageSend(kFileMessage, "Voice", this.ActivationCallback . ":" . values2String(";", words*), this.PID)
			}
		}

		deactivate() {
			if this.DeactivationCallback
				messageSend(kFileMessage, "Voice", this.DeactivationCallback, this.PID)
		}

		recognize(text) {
			this.SpeechRecognizer.recognize(text)
		}

		recognizeVoiceCommand(grammar, words) {
			if this.VoiceCommands.Has(grammar)
				this.VoiceServer.recognizeVoiceCommand(this, grammar, words)
		}
	}

	class ActivationSpeechRecognizer extends SpeechRecognizer {
		Routing {
			Get {
				return "Activation"
			}
		}
	}

	Debug[option] {
		Get {
			return (this.iDebug & option)
		}
	}

	VoiceClients[key?] {
		Get {
			return (isSet(key) ? this.iVoiceClients[key] : this.iVoiceClients)
		}

		Set {
			return (isSet(key) ? (this.iVoiceClients[key] := value) : (this.iVoiceClients := value))
		}
	}

	ActiveVoiceClient {
		Get {
			return this.iActiveVoiceClient
		}
	}

	ActivationGrammars {
		Get {
			return this.iActivationGrammars
		}
	}

	Language {
		Get {
			return this.iLanguage
		}
	}

	Synthesizer {
		Get {
			return this.iSynthesizer
		}
	}

	Speaker {
		Get {
			return this.iSpeaker
		}
	}

	static Interruptable {
		Get {
			return VoiceServer.sInterruptable
		}
	}

	Interruptable {
		Get {
			return VoiceServer.Interruptable
		}
	}

	Speaking {
		Get {
			return this.iSpeaking
		}
	}

	Recognizer {
		Get {
			return this.iRecognizer
		}
	}

	Listener {
		Get {
			return this.iListener
		}
	}

	Listening {
		Get {
			return this.iListening
		}
	}

	ListenerActive {
		Get {
			return this.iListenerActive
		}
	}

	SpeakerVolume {
		Get {
			return this.iSpeakerVolume
		}
	}

	SpeakerPitch {
		Get {
			return this.iSpeakerPitch
		}
	}

	SpeakerSpeed {
		Get {
			return this.iSpeakerSpeed
		}
	}

	PushToTalk {
		Get {
			return this.iPushToTalk
		}
	}

	PushToTalkMode {
		Get {
			return this.iPushToTalkMode
		}
	}

	SpeechRecognizer[create := false] {
		Get {
			local settings

			if (create && this.Listener && !this.iSpeechRecognizer) {
				try {
					try {
						settings := readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))

						this.iSpeechRecognizer := VoiceServer.ActivationSpeechRecognizer(getMultiMapValue(settings, "Voice", "Activation Recognizer"
																										, getMultiMapValue(settings, "Voice", "ActivationRecognizer", "Desktop"))
																					   , true, this.Language, true)

						if (this.iSpeechRecognizer.Recognizers.Length = 0)
							throw "Server speech recognizer engine not installed..."
					}
					catch Any as exception {
						this.iSpeechRecognizer := VoiceServer.ActivationSpeechRecognizer("Desktop", true, this.Language, true)

						if (this.iSpeechRecognizer.Recognizers.Length = 0)
							throw "Desktop speech recognizer engine not installed..."
					}
				}
				catch Any as exception {
					this.iSpeechRecognizer := VoiceServer.ActivationSpeechRecognizer(this.Recognizer, this.Listener, this.Language)
				}

				if !this.hasPushToTalk()
					this.startListening()
			}

			return this.iSpeechRecognizer
		}
	}

	__New(configuration := false) {
		super.__New(configuration)

		VoiceServer.Instance := this

		deleteFile(kTempDirectory . "Voice.cmd")

		PeriodicTask(ObjBindMethod(this, "runPendingCommands"), 500).start()
		PeriodicTask(ObjBindMethod(this, "unregisterStaleVoiceClients"), 5000, kLowPriority).start()

		deleteFile(kTempDirectory . "Voice.mute")

		PeriodicTask(ObjBindMethod(this, "muteVoiceClients"), 50, kInterruptPriority).start()
	}

	loadFromConfiguration(configuration) {
		super.loadFromConfiguration(configuration)

		this.iLanguage := getMultiMapValue(configuration, "Voice Control", "Language", getLanguage())
		this.iSynthesizer := getMultiMapValue(configuration, "Voice Control", "Synthesizer"
											, getMultiMapValue(configuration, "Voice Control", "Service", "dotNET"))
		this.iSpeaker := getMultiMapValue(configuration, "Voice Control", "Speaker", true)
		this.iSpeakerVolume := getMultiMapValue(configuration, "Voice Control", "SpeakerVolume", 100)
		this.iSpeakerPitch := getMultiMapValue(configuration, "Voice Control", "SpeakerPitch", 0)
		this.iSpeakerSpeed := getMultiMapValue(configuration, "Voice Control", "SpeakerSpeed", 0)
		this.iRecognizer := getMultiMapValue(configuration, "Voice Control", "Recognizer", "Desktop")
		this.iListener := getMultiMapValue(configuration, "Voice Control", "Listener", false)
		this.iPushToTalk := getMultiMapValue(configuration, "Voice Control", "PushToTalk", false)
		this.iPushToTalkMode := getMultiMapValue(configuration, "Voice Control", "PushToTalkMode", "Hold")

		if this.PushToTalk
			this.iPushToTalk := string2Values(InStr(this.PushToTalk, ";") ? ";" : "|", this.PushToTalk)

		this.initializePushToTalk()
	}

	hasPushtoTalk() {
		return ((this.PushToTalkMode = "Custom") || this.PushToTalk)
	}

	initializePushToTalk() {
		local p2tHotkey := this.PushToTalk
		local ignore, key

		switch this.PushToTalkMode, false {
			case "Press":
				if p2tHotkey
					for ignore, key in p2tHotkey
						Hotkey(key, ObjBindMethod(this, "listen", true), "On")
			case "Hold":
				if p2THotkey
					PeriodicTask(ObjBindMethod(this, "listen", false), 50, kInterruptPriority).start()
			case "Custom":
				PeriodicTask(ObjBindMethod(this, "processExternalCommand"), 50, kInterruptPriority).start()
		}

		if (this.PushToTalkMode != "Custom")
			PeriodicTask(ObjBindMethod(this, "processExternalCommand"), 1000).start()
	}

	processExternalCommand() {
		local fileName := (kTempDirectory . "Voice.cmd")
		local file, command, descriptor

		try {
			file := FileOpen(fileName, "r-rwd")

			if !file
				return
			else if (file.Length == 0) {
				file.Close()

				return
			}
			else {
				file.Pos := 0

				command := file.ReadLine()

				file.Close()

				if ((command != "Disable") && (command != "Enable")) {
					deleteFile(fileName)

					if !this.ListenerActive
						return
				}

				if (InStr(command, "Target:") = 1) {
					descriptor := string2Values(":", command)[2]

					this.activateVoiceClient(descriptor, ["Hey", descriptor])
				}
				else if (command = "Activation")
					this.startActivationListener()
				else if (command = "Listen")
					this.startListening(false)
				else if (command = "Stop") {
					this.stopActivationListener()
					this.stopListening()
				}
				else if (command = "Disable")
					this.disableListening()
				else if (command = "Enable")
					this.enableListening()
			}
		}
		catch Any {
		}
	}

	listen(toggle, down := true) {
		local listen := false
		local pressed := false
		local clicked := false
		local ignore, key

		static isPressed := false
		static lastDown := 0
		static lastUp := 0
		static clicks := 0
		static activation := false
		static listening := false

		static listenTask := false

		static speed := getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))
									   , "Voice", "Activation Speed", DllCall("GetDoubleClickTime"))

		if !this.ListenerActive {
			isPressed := false
			lastDown := 0
			lastUp := 0
			clicks := 0
			activation := false
			listening := false

			if listenTask {
				listenTask.stop()

				listenTask := false
			}

			this.stopListening()

			return
		}

		try {
			for ignore, key in this.PushToTalk
				clicked := (clicked || GetKeyState(key))

			pressed := (toggle ? down : clicked)
		}

		if (pressed && !isPressed) {
			lastDown := A_TickCount
			isPressed := true

			if (((lastDown - lastUp) < speed) && (clicks == 1))
				activation := true
			else {
				clicks := 0

				activation := false
			}
		}
		else if (!pressed && isPressed) {
			lastUp := A_TickCount
			isPressed := false

			if ((lastUp - lastDown) < speed)
				clicks += 1
			else
				clicks := 0
		}

		if toggle {
			if pressed {
				if (listenTask && !this.Interruptable) {
					listen := true

					listenTask.stop()

					listenTask := false
				}

				if listening {
					this.stopActivationListener()
					this.stopListening()

					if activation
						this.startActivationListener()
					else
						listening := false
				}
				else if activation {
					this.startActivationListener()

					listening := true
				}
				else if listen {
					this.startListening(false)

					listening := true
				}
				else if !listenTask {
					listenTask := Task(ObjBindMethod(this, "listen", true, true), speed, kInterruptPriority)

					Task.startTask(listenTask)
				}
			}

			if down
				this.listen(true, false)
		}
		else {
			if (((A_TickCount - lastDown) < (speed / 2)) && !activation)
				pressed := false

			if ((!this.Speaking || this.Interruptable) && pressed) {
				if activation
					this.startActivationListener()
				else
					this.startListening(false)

				listening := true
			}
			else if !pressed {
				this.stopActivationListener()
				this.stopListening()

				listening := false
			}
		}
	}

	setDebug(option, enabled, *) {
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
				SupportMenu.Check(label)
			else
				SupportMenu.Uncheck(label)
	}

	toggleDebug(option, *) {
		this.setDebug(option, !this.Debug[option])
	}

	getVoiceClient(descriptor := false) {
		try {
			if descriptor
				return this.VoiceClients[descriptor]
			else
				return this.ActiveVoiceClient
		}
		catch Any {
			return this.ActiveVoiceClient
		}
	}

	activateVoiceClient(descriptor, words := false) {
		local activeVoiceClient

		if (this.ActiveVoiceClient && (this.ActiveVoiceClient.Descriptor = descriptor))
			this.ActiveVoiceClient.activate(words)
		else {
			if this.ActiveVoiceClient
				this.deactivateVoiceClient(this.ActiveVoiceClient.Descriptor)

			if this.VoiceClients.Has(descriptor) {
				activeVoiceClient := this.VoiceClients[descriptor]

				this.iActiveVoiceClient := activeVoiceClient

				activeVoiceClient.activate(words)

				if !this.hasPushToTalk()
					this.startListening()
			}
			else
				return true
		}

		return true
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
		static audioDevice := getMultiMapValue(readMultiMap(kUserConfigDirectory . "Audio Settings.ini"), "Output", "Activation.AudioDevice", false)
		static talkSound := getFileName("Talk.wav", kUserHomeDirectory . "Sounds\", kResourcesDirectory . "Sounds\")

		if (this.SpeechRecognizer && !this.Listening)
			if !this.SpeechRecognizer.startRecognizer() {
				if retry
					Task.startTask(ObjBindMethod(this, "startActivationListener", true), 200)

				return false
			}
			else {
				if this.Interruptable
					this.interrupt(false, (this.Interruptable = "All"))

				if this.hasPushToTalk()
					playSound("VSSoundPlayer.exe", talkSound, audioDevice)

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

	enableListening() {
		this.iListenerActive := true
	}

	disableListening() {
		this.iListenerActive := false
	}

	startListening(retry := true) {
		local activeClient := this.getVoiceClient()

		if this.ListenerActive {
			if this.Interruptable
				this.interrupt(false, (this.Interruptable = "All"))

			return (activeClient ? activeClient.startListening(retry) : this.startActivationListener(retry))
		}
		else
			return false
	}

	stopListening(retry := false) {
		local activeClient := this.getVoiceClient()

		if this.ListenerActive
			return (activeClient ? activeClient.stopListening(retry) : this.stopActivationListener(retry))
		else
			return false
	}

	interrupt(descriptor := false, pending := false) {
		local ignore, client

		if pending
			this.iLastInterrupt := A_TickCount

		if descriptor
			this.getVoiceClient(descriptor).interrupt()
		else
			for ignore, client in this.VoiceClients
				client.interrupt()
	}

	mute() {
		local ignore, client

		for ignore, client in this.VoiceClients
			client.mute()
	}

	unmute() {
		local ignore, client

		for ignore, client in this.VoiceClients
			client.unmute()
	}

	muteVoiceClients() {
		if FileExist(kTempDirectory . "Voice.mute")
			this.mute()
		else
			this.unmute()
	}

	speak(descriptor, text, activate := false, options := false) {
		local oldSpeaking := this.Speaking

		text := text

		speak() {
			this.iSpeaking := true

			try {
				this.getVoiceClient(descriptor).speak(text, options ? string2Map("|", "->", options) : false)

				if activate
					this.activateVoiceClient(descriptor)
			}
			catch Any as exception {
				logError(exception)
			}
			finally {
				this.iSpeaking := oldSpeaking
			}
		}

		speakAgain() {
			if (this.iLastInterrupt < Task.CurrentTask.SpeechStart)
				if (this.Speaking || this.Listening || (choose(this.VoiceClients, (c) => (c.Speaking || c.Listening)).Length > 0))
					return this
				else
					speak()
		}

		if (this.Speaking || this.Listening || (choose(this.VoiceClients, (c) => (c.Speaking || c.Listening)).Length > 0)) {
			retryTask := Task(speakAgain)

			retryTask.SpeechStart := A_TickCount

			retryTask.start()
		}
		else
			speak()
	}

	registerVoiceClient(descriptor, routing, pid
					  , activationCommand := false, activationCallback := false, deactivationCallback := false, speakingStatusCallback := false
					  , language := false, synthesizer := true, speaker := true, recognizer := false, listener := false
					  , speakerVolume := kUndefined, speakerPitch := kUndefined, speakerSpeed := kUndefined
					  , speakerBooster := false, listenerBooster := false
					  , recognizerMode := "Grammar") {
		local grammar, client, nextCharIndex, theDescriptor, ignore, voiceClient, clientRecognizer

		static compiler := SpeechRecognizer("Compiler")
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

		client := (this.VoiceClients.Has(descriptor) ? this.VoiceClients[descriptor] : false)

		if (client && (this.ActiveVoiceClient == client))
			this.deactivateVoiceClient(descriptor)

		client := VoiceServer.VoiceClient(this, descriptor, routing, pid, language, synthesizer, speaker, recognizer, listener
											  , speakerVolume, speakerPitch, speakerSpeed, speakerBooster, listenerBooster
											  , activationCallback, deactivationCallback, speakingStatusCallback, recognizerMode)

		this.VoiceClients[descriptor] := client

		if listener {
			client.registerRecognitionHandler(ObjBindMethod(this, "handleActivationCommand"))

			if (activationCommand && (StrLen(Trim(activationCommand)) > 0)) {
				recognizer := this.SpeechRecognizer[true]

				grammar := ConfigurationItem.descriptor(descriptor, counter++)

				if this.Debug[kDebugGrammars] {
					nextCharIndex := 1

					showMessage("Register activation phrase: " . GrammarCompiler(recognizer).readGrammar(&activationCommand, &nextCharIndex).toString())
				}

				try {
					for ignore, voiceClient in this.VoiceClients
						if (voiceClient.Listener && (voiceClient.RecognizerMode = "Grammar")) {
							clientRecognizer := voiceClient.SpeechRecognizer[true]

							if ((clientRecognizer.Method = "Pattern") && (voiceClient != client))
								if !clientRecognizer.loadGrammar(ConfigurationItem.descriptor(descriptor, counter++)
															   , clientRecognizer.compileGrammar(activationCommand)
															   , ObjBindMethod(this, "recognizeActivationCommand", client))
									throw "Recognizer not running..."
						}

					if ((client.RecognizerMode = "Grammar") && client.Listener) {
						clientRecognizer := client.SpeechRecognizer[true]

						if (clientRecognizer.Method = "Pattern")
							for ignore, activationGrammer in this.ActivationGrammars
								if !clientRecognizer.loadGrammar(ConfigurationItem.descriptor(ConfigurationItem.splitDescriptor(activationGrammer.Descriptor)[1], counter++)
															   , clientRecognizer.compileGrammar(activationGrammer.Command)
															   , ObjBindMethod(this, "recognizeActivationCommand", activationGrammer.Client))
									throw "Recognizer not running..."
					}

					this.ActivationGrammars.Push({Descriptor: grammar, Client: client
												, Grammar: compiler.compileGrammar(activationCommand)
												, Command: activationCommand})


					if !recognizer.loadGrammar(grammar, recognizer.compileGrammar(activationCommand), ObjBindMethod(this, "recognizeActivationCommand", client))
						throw "Recognizer not running..."
				}
				catch Any as exception {
					logError(exception, true)

					logMessage(kLogCritical, translate("Error while registering voice command `"") . activationCommand . translate("`" - please check the configuration"))

					if !kSilentMode
						showMessage(substituteVariables(translate("Cannot register voice command `"%command%`" - please check the configuration..."), {command: activationCommand})
								  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				}
			}
		}

		if (this.VoiceClients.Count = 1)
			this.activateVoiceClient(descriptor)
		else if (this.VoiceClients.Count > 1) {
			for theDescriptor, ignore in this.VoiceClients
				if (descriptor != theDescriptor)
					this.deactivateVoiceClient(theDescriptor)

			if !this.hasPushToTalk()
				this.startActivationListener()
		}
	}

	unregisterVoiceClient(descriptor, pid) {
		local client := (this.VoiceClients.Has(descriptor) ? this.VoiceClients[descriptor] : false)
		local grammars := this.ActivationGrammars
		local theDescriptor, ignore, grammar

		if (client && (this.ActiveVoiceClient == client))
			this.deactivateVoiceClient(descriptor)

		this.VoiceClients.Delete(descriptor)

		if client
			client.Active := false

		for ignore, grammar in grammars
			if (grammar.Client = client) {
				grammars.RemoveAt(A_Index)

				break
			}

		if (this.VoiceClients.Count = 1) {
			for theDescriptor, ignore in this.VoiceClients
				this.activateVoiceClient(theDescriptor)

			if !this.hasPushToTalk()
				this.stopActivationListener()
		}
	}

	unregisterStaleVoiceClients() {
		local descriptor, voiceClient, pid

		protectionOn()

		try {
			for descriptor, voiceClient in this.VoiceClients {
				pid := voiceClient.PID

				if !ProcessExist(pid) {
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

	handleActivationCommand(client, words*) {
		local recognizer := client.SpeechRecognizer[true]
		local text := values2String(A_Space, words*)
		local bestRating := 0
		local bestMatch := false
		local ignore, grammar, rating

		static ratingHigh := kUndefined

		if (ratingHigh = kUndefined) {
			settings := readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))

			ratingHigh := getMultiMapValue(settings, "Voice", "High Rating", 0.85)
		}

		for ignore, grammar in this.ActivationGrammars {
			rating := recognizer.match(text, grammar.Grammar)

			if (rating > bestRating) {
				bestRating := rating
				bestMatch := grammar
			}
		}

		if (bestMatch && (bestRating > ratingHigh)) {
			this.recognizeActivationCommand(bestMatch.Client, bestMatch.Descriptor, words)

			return true
		}
		else
			return false
	}

	recognize(descriptor, text) {
		local voiceClient := (this.VoiceClients.Has(descriptor) ? this.VoiceClients[descriptor] : false)

		if voiceClient
			voiceClient.recognize(text)
	}

	recognizeActivation(descriptor, grammar, words*) {
		try {
			local voiceClient := (this.VoiceClients.Has(descriptor) ? this.VoiceClients[descriptor] : false)

			if voiceClient
				this.recognizeActivationCommand(voiceClient, voiceClient.Descriptor, words)
		}
		catch Any as exception {
			logError(exception)
		}
	}

	recognizeCommand(grammar, words*) {
		local ignore, voiceClient

		for ignore, voiceClient in this.VoiceClients
			voiceClient.recognizeVoiceCommand(grammar, words)
	}

	recognizeActivationCommand(voiceClient, grammar, words) {
		if voiceClient.Active
			this.addPendingCommand(ObjBindMethod(this, "activationCommandRecognized", voiceClient, grammar, words), voiceClient)
	}

	recognizeVoiceCommand(voiceClient, grammar, words) {
		this.addPendingCommand(ObjBindMethod(this, "voiceCommandRecognized", voiceClient, grammar, words))
	}

	recognizeText(voiceClient, text) {
		this.addPendingCommand(ObjBindMethod(this, "textRecognized", voiceClient, text))
	}

	addPendingCommand(command, activation := false) {
		if activation
			if (activation != this.ActiveVoiceClient)
				this.iPendingCommands := []
			else if (this.iPendingCommands.Length > 0)
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
			if (this.iPendingCommands.Length == 0)
				return
			else {
				command := this.iPendingCommands.RemoveAt(1)

				if command {
					command := command[2]

					command.Call()
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
			showMessage("Command phrase recognized: " . grammar . " => " . values2String(A_Space, words*), false, "Information.ico", 5000)

		messageSend(kFileMessage, "Voice", descriptor[2] . ":" . values2String(";", grammar, descriptor[1], words*), voiceClient.PID)
	}

	textRecognized(voiceClient, text) {
		local descriptor := voiceClient.VoiceCommands["Text"]

		if this.Debug[kDebugRecognitions]
			showMessage("Text recognized: " . text, false, "Information.ico", 5000)

		messageSend(kFileMessage, "Voice", descriptor[2] . ":" . values2String(";", "Text", descriptor[1], StrReplace(text, ";", ","))
								, voiceClient.PID)
	}

	unknownRecognized(voiceClient, text) {
		local descriptor

		if voiceClient.VoiceCommands.Has("Text") {
			descriptor := voiceClient.VoiceCommands["Text"]

			if this.Debug[kDebugRecognitions]
				showMessage("Text not recognized: " . text, false, "Information.ico", 5000)

			messageSend(kFileMessage, "Voice", descriptor[2] . ":" . values2String(";", "Text", descriptor[1], StrReplace(text, ";", ","))
									, voiceClient.PID)

			return true
		}
		else
			return false
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

startupVoiceServer() {
	local icon := kIconsDirectory . "Microphon.ico"
	local debug, index, server, label

	TraySetIcon(icon, "1")
	A_IconTip := "Voice Server"

	try {
		debug := false

		index := 1

		while (index < A_Args.Length) {
			switch A_Args[index], false {
				case "-Debug":
					debug := (((A_Args[index + 1] = kTrue) || (A_Args[index + 1] = true)) ? true : false)
					index += 2
				default:
					index += 1
			}
		}

		if debug {
			setDebug(true)

			setLogLevel(kLogDebug)
		}

		server := VoiceServer(kSimulatorConfiguration)

		SupportMenu.Insert("1&")

		label := translate("Debug Recognitions")

		SupportMenu.Insert("1&", label, ObjBindMethod(server, "toggleDebug", kDebugRecognitions))

		if server.Debug[kDebugRecognitions]
			SupportMenu.Check(label)

		label := translate("Debug Grammars")

		SupportMenu.Insert("1&", label, ObjBindMethod(server, "toggleDebug", kDebugGrammars))

		if server.Debug[kDebugGrammars]
			SupportMenu.Check(label)

		registerMessageHandler("Voice", handleVoiceMessage)

		startupProcess()
	}
	catch Any as exception {
		logError(exception, true)

		OnMessage(0x44, translateOkButton)
		withBlockedWindows(MsgBox, substituteVariables(translate("Cannot start %application% due to an internal error..."), {application: "Voice Server"}), translate("Error"), 262160)
		OnMessage(0x44, translateOkButton, 0)

		ExitApp(1)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Message Handler Section                         ;;;
;;;-------------------------------------------------------------------------;;;

handleVoiceMessage(category, data) {
	if InStr(data, ":") {
		data := StrSplit(data, ":", , 2)

		if (data[1] = "Shutdown") {
			Sleep(30000)

			ExitApp(0)
		}

		return withProtection(ObjBindMethod(VoiceServer.Instance, data[1]), string2Values(";", data[2])*)
	}
	else if (data = "Shutdown") {
		Sleep(30000)

		ExitApp(0)
	}
	else
		return withProtection(ObjBindMethod(VoiceServer.Instance, data))
}


;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

startupVoiceServer()