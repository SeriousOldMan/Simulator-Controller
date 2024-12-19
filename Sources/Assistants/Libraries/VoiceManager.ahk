;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Voice Chat Manager              ;;;
;;;                                         Client for Voice Server         ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Global Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\Task.ahk"
#Include "..\..\Libraries\Messages.ahk"
#Include "..\..\Libraries\SpeechSynthesizer.ahk"
#Include "..\..\Libraries\SpeechRecognizer.ahk"
#Include "..\..\Libraries\LLMBooster.ahk"


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

class VoiceManager extends ConfigurationItem {
	static sInterruptable := getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))
											, "Voice", "Interruptable", false)

	iDebug := kDebugOff

	iLanguage := "en"

	iName := false

	iSynthesizer := "dotNET"
	iSpeaker := false
	iSpeakerVolume := 100
	iSpeakerPitch := 0
	iSpeakerSpeed := 0
	iSpeakerBooster := false

	iMuted := false

	iRecognizer := "Desktop"
	iListener := false
	iListenerBooster := false

	iBooster := false

	iRecognizerMode := "Grammar"

	iVoiceServer := false
	iGrammars := CaseInsenseMap()

	iPushToTalk := false
	iPushToTalkMode := "Hold"

	iSpeechSynthesizer := false
	iSpeechRecognizer := false
	iUseTalking := true
	iIsSpeaking := false
	iIsListening := false

	iContinuation := false

	class RemoteSpeaker {
		iVoiceManager := false
		iFragments := CaseInsenseWeakMap()
		iPhrases := CaseInsenseMap()

		iSpeaker := false
		iLanguage := false

		iIsTalking := false
		iText := ""
		iFocus := false

		VoiceManager {
			Get {
				return this.iVoiceManager
			}
		}

		Speaking {
			Get {
				return this.VoiceManager.Speaking
			}

			Set {
				return (this.VoiceManager.Speaking := value)
			}
		}

		UseTalking {
			Get {
				return this.VoiceManager.UseTalking
			}
		}

		Talking {
			Get {
				return this.iIsTalking
			}
		}

		Phrases[key?] {
			Get {
				return (isSet(key) ? this.iPhrases[key] : this.iPhrases)
			}
		}

		Fragments[key?] {
			Get {
				return (isSet(key) ? this.iFragments[key] : this.iFragments)
			}
		}

		__New(voiceManager, synthesizer, speaker, language, fragments, phrases) {
			this.iVoiceManager := voiceManager
			this.iFragments := toMap(fragments, CaseInsenseWeakMap)
			this.iFragments.Default := ""
			this.iPhrases := phrases

			this.iSpeaker := speaker
			this.iLanguage := language
		}

		beginTalk(force := false) {
			if (force || this.UseTalking)
				this.iIsTalking := true
		}

		endTalk(options := false) {
			local text, focus

			if this.Talking {
				text := this.iText
				focus := this.iFocus

				this.iText := ""
				this.iFocus := false
				this.iIsTalking := false

				if (StrLen(Trim(text)) > 0)
					this.speak(text, focus, false, options)
			}
		}

		speak(text, focus := false, cache := false, options := false) {
			text := StrReplace(text, ";", ",")

			if this.Talking {
				this.iText .= (A_Space . text)
				this.iFocus := (this.iFocus || focus)

				if options
					throw "Options are not supported while talking..."
			}
			else
				messageSend(kFileMessage, "Voice", "speak:" . values2String(";", this.VoiceManager.Name, text, focus, options ? map2String("|", "->", toMap(options)) : false)
										, this.VoiceManager.VoiceServer)
		}

		getPhrase(phrase, variables := false, cache := false) {
			local phrases := this.Phrases
			local index

			if phrases.Has(phrase) {
				phrases := phrases[phrase]

				index := Round(Random(0.55, phrases.Length + 0.45))

				if cache
					cache .= ("." . index)

				phrase := substituteVariables(phrases[index], this.VoiceManager.getPhraseVariables(variables))
			}

			return phrase
		}

		speakPhrase(phrase, variables := false, focus := false, cache := false, options := false) {
			phrase := this.getPhrase(phrase, variables, cache)

			if phrase
				this.speak(phrase, focus, cache, options)
		}

		number2Speech(number, precision := kUndefined) {
			static divider := false

			if (precision != kUndefined)
				if (precision = 0)
					return Round(number)
				else
					number := Round(number, precision)

			if !divider
				divider := (A_Space . this.Fragments[(getFormat("Float") = "#.##") ? "Point" : "Comma"] . A_Space)

			return StrReplace(number, ".", divider)
		}
	}

	class LocalSpeaker extends SpeechSynthesizer {
		iVoiceManager := false
		iFragments := CaseInsenseWeakMap()
		iPhrases := CaseInsenseMap()

		iBooster := false

		iIsTalking := false
		iText := ""
		iFocus := false

		Routing {
			Get {
				return this.VoiceManager.Routing
			}
		}

		VoiceManager {
			Get {
				return this.iVoiceManager
			}
		}

		Booster {
			Get {
				return this.iBooster
			}
		}

		Speaking {
			Get {
				return (this.VoiceManager.Speaking || super.Speaking)
			}

			Set {
				return (this.VoiceManager.Speaking := value)
			}
		}

		UseTalking {
			Get {
				return this.VoiceManager.UseTalking
			}
		}

		Talking {
			Get {
				return this.iIsTalking
			}
		}

		Phrases[key?] {
			Get {
				return (isSet(key) ? this.iPhrases[key] : this.iPhrases)
			}
		}

		Fragments[key?] {
			Get {
				return (isSet(key) ? this.iFragments[key] : this.iFragments)
			}
		}

		__New(voiceManager, synthesizer, speaker, language, fragments, phrases) {
			local booster

			this.iVoiceManager := voiceManager
			this.iFragments := fragments
			this.iPhrases := phrases

			if voiceManager.SpeakerBooster {
				booster := SpeechBooster(voiceManager.SpeakerBooster, voiceManager.Configuration, this.VoiceManager.Language)

				if (booster.Model && booster.Active)
					this.iBooster := booster
			}

			super.__New(synthesizer, speaker, language)
		}

		beginTalk(options := false) {
			if ((options && options.HasProp("Talking") && options.Talking) || this.UseTalking)
				this.iIsTalking := true
		}

		endTalk(options := false) {
			local text, focus

			if this.Talking {
				text := this.iText
				focus := this.iFocus

				this.iText := ""
				this.iFocus := false
				this.iIsTalking := false

				if (StrLen(Trim(text)) > 0)
					this.speak(text, focus, false, options)
			}
		}

		speak(text, focus := false, cache := false, options := false) {
			local booster, stopped

			if this.Talking {
				this.iText .= (A_Space . text)
				this.iFocus := (this.iFocus || focus)

				if options
					throw "Options are not supported while talking..."
			}
			else {
				stopped := this.VoiceManager.stopListening()

				try {
					booster := this.Booster

					if booster {
						if options {
							options := toMap(options)

							text := booster.speak(text, Map("Rephrase", (!options.Has("Rephrase") || options["Rephrase"])
														  , "Translate", (options.Has("Translate") && options["Tranlate"])
														  , "Variables", {assistant: this.VoiceManager.Routing}))
						}
						else
							text := booster.speak(text, Map("Variables", {assistant: this.VoiceManager.Routing}))
					}

					this.Speaking := true

					try {
						super.speak(text, !this.Awaitable, cache, options)
					}
					finally {
						this.Speaking := false
					}
				}
				finally {
					if (stopped && !this.VoiceManager.PushToTalk)
						this.VoiceManager.startListening()
				}
			}
		}

		getPhrase(phrase, variables := false, cache := false) {
			local phrases := this.Phrases
			local index

			if phrases.Has(phrase) {
				phrases := phrases[phrase]

				index := Round(Random(0.55, phrases.Length + 0.45))

				if cache
					cache .= ("." . index)

				phrase := substituteVariables(phrases[index], this.VoiceManager.getPhraseVariables(variables))
			}

			return phrase
		}

		speakPhrase(phrase, variables := false, focus := false, cache := false, options := false) {
			phrase := this.getPhrase(phrase, variables, cache)

			if phrase
				this.speak(phrase, focus, cache, options)
		}

		number2Speech(number, precision := kUndefined) {
			static divider := false

			if (precision != kUndefined)
				if (precision = 0)
					return Round(number)
				else
					number := Round(number, precision)

			if !divider
				divider := (A_Space . this.Fragments[(getFormat("Float") = "#.##") ? "Point" : "Comma"] . A_Space)

			return StrReplace(number, ".", divider)
		}
	}

	class LocalRecognizer extends SpeechRecognizer {
		iVoiceManager := false

		iBooster := false

		Routing {
			Get {
				return this.VoiceManager.Routing
			}
		}

		VoiceManager {
			Get {
				return this.iVoiceManager
			}
		}

		Booster {
			Get {
				return this.iBooster
			}
		}

		__New(voiceManager, arguments*) {
			local booster

			this.iVoiceManager := voiceManager

			if voiceManager.ListenerBooster {
				booster := RecognitionBooster(voiceManager.ListenerBooster, voiceManager.Configuration, voiceManager.Language)

				if (booster.Model && booster.Active)
					this.iBooster := booster
			}

			super.__New(arguments*)
		}

		textRecognized(text) {
			this.VoiceManager.raiseTextRecognized("Text", text)
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

			if this.Grammars.Has("?") {
				this.VoiceManager.unknownRecognized(text)

				return false
			}
			else
				return super.unknownRecognized(&text)
		}
	}

	class VoiceContinuation {
		iManager := false
		iContinuation := false

		Manager {
			Get {
				return this.iManager
			}
		}

		Continuation {
			Get {
				return this.iContinuation
			}
		}

		__New(manager, continuation := false) {
			this.iManager := manager
			this.iContinuation := continuation
		}

		next() {
			local continuation := this.Continuation

			if isInstance(continuation, VoiceManager.VoiceContinuation)
				continuation.next()
			else if continuation
				continuation()
		}

		cancel() {
		}
	}

	class ReplyContinuation extends VoiceManager.VoiceContinuation {
		iAccept := false
		iReject := false

		Accept {
			Get {
				return this.iAccept
			}
		}

		Reject {
			Get {
				return this.iReject
			}
		}

		__New(manager, continuation := false, accept := false, reject := false) {
			this.iAccept := accept
			this.iReject := reject

			super.__New(manager, continuation)
		}

		next() {
			if (this.Manager.Speaker && this.Accept)
				this.Manager.getSpeaker().speakPhrase(this.Accept)

			super.next()
		}

		cancel() {
			if (this.Manager.Speaker && this.Reject)
				this.Manager.getSpeaker().speakPhrase(this.Reject)

			super.cancel()
		}
	}

	Debug[option] {
		Get {
			return (this.iDebug & option)
		}
	}

	VoiceServer {
		Get {
			return this.iVoiceServer
		}
	}

	Language {
		Get {
			return this.iLanguage
		}
	}

	Name {
		Get {
			return this.iName
		}
	}

	Routing {
		Get {
			throw "Virtual property VoiceManager.Routing must be implemented in a subclass..."
		}
	}

	Synthesizer {
		Get {
			return this.iSynthesizer
		}
	}

	Muted {
		Get {
			return this.iMuted
		}

		Set {
			return (this.iMuted := value)
		}
	}

	Speaker[force := true] {
		Get {
			return (force || !this.Muted) ? this.iSpeaker : false
		}
	}

	UseTalking {
		Get {
			return this.iUseTalking
		}

		Set {
			return (this.iUseTalking := value)
		}
	}

	static Interruptable {
		Get {
			return VoiceManager.sInterruptable
		}
	}

	Interruptable {
		Get {
			return VoiceManager.Interruptable
		}
	}

	Speaking {
		Get {
			return this.iIsSpeaking
		}

		Set {
			return (this.iIsSpeaking := value)
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

	ListenerBooster {
		Get {
			return this.iListenerBooster
		}
	}

	Booster {
		Get {
			local booster

			if (this.ListenerBooster && !this.iBooster) {
				booster := RecognitionBooster(this.ListenerBooster, this.Configuration, this.Language)

				if (booster.Model && booster.Active)
					this.iBooster := booster
			}

			return this.iBooster
		}
	}

	Listening {
		Get {
			return this.iIsListening
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

	Grammars[key?] {
		Get {
			return (isSet(key) ? this.iGrammars[key] : this.iGrammars)
		}

		Set {
			return (isSet(key) ? (this.iGrammars[key] := value) : (this.iGrammars := value))
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

	User {
		Get {
			throw "Virtual property VoiceManager.User must be implemented in a subclass..."
		}
	}

	Continuation {
		Get {
			return this.iContinuation
		}
	}

	__New(name, configuration, options) {
		this.iName := name

		super.__New(configuration)

		this.initialize(options)

		if !this.Speaker
			this.iListener := false

		registerMessageHandler("Voice", methodMessageHandler, this)

		if (!this.VoiceServer && this.PushToTalk)
			this.initializePushToTalk()

		if this.VoiceServer
			OnExit(ObjBindMethod(this, "shutdownVoiceManager"))
	}

	shutdownVoiceManager(arguments*) {
		if ((arguments.Length > 0) && inList(["Logoff", "Shutdown"], arguments[1]))
			return false

		if (this.VoiceServer && this.iSpeechSynthesizer) {
			messageSend(kFileMessage, "Voice", "unregisterVoiceClient:" . values2String(";", this.Name, ProcessExist()), this.VoiceServer)

			Sleep(2000)
		}

		return false
	}

	initialize(options) {
		local vocalics

		if options.Has("Vocalics") {
			vocalics := options["Vocalics"]

			if !options.Has("SpeakerVolume")
				options["SpeakerVolume"] := vocalics[1]

			if !options.Has("SpeakerPitch")
				options["SpeakerPitch"] := vocalics[2]

			if !options.Has("SpeakerSpeed")
				options["SpeakerSpeed"] := vocalics[3]
		}

		if options.Has("Language")
			this.iLanguage := options["Language"]

		if options.Has("Synthesizer")
			this.iSynthesizer := options["Synthesizer"]

		if options.Has("UseTalking")
			this.iUseTalking := options["UseTalking"]

		if options.Has("Speaker")
			this.iSpeaker := options["Speaker"]

		if options.Has("SpeakerVolume")
			this.iSpeakerVolume := options["SpeakerVolume"]

		if options.Has("SpeakerPitch")
			this.iSpeakerPitch := options["SpeakerPitch"]

		if options.Has("SpeakerSpeed")
			this.iSpeakerSpeed := options["SpeakerSpeed"]

		if options.Has("SpeakerBooster")
			this.iSpeakerBooster := options["SpeakerBooster"]

		if options.Has("Recognizer")
			this.iRecognizer := options["Recognizer"]

		if options.Has("Listener")
			this.iListener := options["Listener"]

		if options.Has("ListenerBooster") {
			this.iListenerBooster := options["ListenerBooster"]
		}

		if options.Has("PushToTalk")
			this.iPushToTalk := options["PushToTalk"]

		if options.Has("PushToTalkMode")
			this.iPushToTalkMode := options["PushToTalkMode"]

		if options.Has("VoiceServer")
			this.iVoiceServer := options["VoiceServer"]
	}

	hasPushtoTalk() {
		return ((this.PushToTalkMode = "Custom") || this.PushToTalk)
	}

	initializePushToTalk() {
		local p2tHotkey := this.PushToTalk

		switch this.PushToTalkMode, false {
			case "Press":
				if p2THotkey
					Hotkey(p2tHotkey, ObjBindMethod(this, "listen", true), "On")
			case "Hold":
				if p2THotkey
					PeriodicTask(ObjBindMethod(this, "listen", false), 50, kInterruptPriority).start()
			case "Custom":
				PeriodicTask(ObjBindMethod(this, "processExternalCommand"), 50, kInterruptPriority).start()
		}
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

				deleteFile(fileName)

				if ((command = "Activation") || (command = "Listen"))
					this.startListening(false)
				else if (command = "Stop")
					this.stopListening()
			}
		}
		catch Any {
		}
	}

	listen(toggle, down := true) {
		local listen := false
		local pressed := false

		static isPressed := false
		static lastDown := 0
		static lastUp := 0
		static clicks := 0
		static activation := false
		static listening := false

		static listenTask := false

		static speed := getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))
									   , "Voice", "Activation Speed", DllCall("GetDoubleClickTime"))

		try
			pressed := toggle ? down : GetKeyState(this.PushToTalk)

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
		if enabled
			this.iDebug := (this.iDebug | option)
		else if (this.Debug[option] == option)
			this.iDebug := (this.iDebug - option)
	}

	getPhraseVariables(variables := false) {
		if variables {
			variables := variables.Clone()

			if isInstance(variables, Map) {
				variables["Name"] := this.Name
				variables["User"] := this.User
			}
			else {
				variables.Name := this.Name
				variables.User := this.User
			}

			return variables
		}
		else
			return {Name: this.Name, User: this.User}
	}

	getSpeaker() {
		local pid, activationCommand, mode

		if (this.Speaker && !this.iSpeechSynthesizer) {
			if this.VoiceServer {
				pid := ProcessExist()

				activationCommand := getMultiMapValue(this.getGrammars(this.Language), "Listener Grammars", "Call", false)
				activationCommand := substituteVariables(activationCommand, {name: this.Name})

				mode := getMultiMapValue(this.getGrammars(this.Language), "Configuration", "Recognizer", "Grammar")

				if (mode = "Mixed")
					mode := "Text"

				messageSend(kFileMessage, "Voice"
										, "registerVoiceClient:" . values2String(";", this.Name, this.Routing, ProcessExist()
																					, StrReplace(activationCommand, ";", ",")
																					, "remoteActivationRecognized", "remoteDeactivationRecognized"
																					, "remoteSpeakingStatusUpdate"
																					, this.Language, this.Synthesizer, this.Speaker
																					, this.Recognizer, this.Listener
																					, this.SpeakerVolume, this.SpeakerPitch, this.SpeakerSpeed
																					, this.SpeakerBooster, this.ListenerBooster
																					, mode)
										, this.VoiceServer)

				this.iSpeechSynthesizer := VoiceManager.RemoteSpeaker(this, this.Synthesizer, this.Speaker, this.Language
																	, this.buildFragments(this.Language)
																	, this.buildPhrases(this.Language))
			}
			else {
				this.iSpeechSynthesizer := VoiceManager.LocalSpeaker(this, this.Synthesizer, this.Speaker, this.Language
																   , this.buildFragments(this.Language)
																   , this.buildPhrases(this.Language))

				this.iSpeechSynthesizer.setVolume(this.SpeakerVolume)
				this.iSpeechSynthesizer.setPitch(this.SpeakerPitch)
				this.iSpeechSynthesizer.setRate(this.SpeakerSpeed)
			}

			this.startListener()
		}

		return this.iSpeechSynthesizer
	}

	startListener() {
		local recognizer, mode

		static initialized := false

		if (!initialized && this.Listener && !this.iSpeechRecognizer) {
			initialized := true

			if this.VoiceServer
				this.buildGrammars(false, this.Language)
			else {
				mode := getMultiMapValue(this.getGrammars(this.Language), "Configuration", "Recognizer", "Grammar")

				if (mode = "Mixed")
					mode := "Text"

				recognizer := VoiceManager.LocalRecognizer(this, this.Recognizer, this.Listener, this.Language, false, mode)

				this.buildGrammars(recognizer, this.Language)

				if !this.PushToTalk
					recognizer.startRecognizer()

				this.iSpeechRecognizer := recognizer
			}
		}
	}

	startActivationListener(retry := true) {
		this.startListening(retry)
	}

	startListening(retry := true) {
		static audioDevice := getMultiMapValue(readMultiMap(kUserConfigDirectory . "Audio Settings.ini"), "Output", "Activation.AudioDevice", false)
		static talkSound := getFileName("Talk.wav", kUserHomeDirectory . "Sounds\", kResourcesDirectory . "Sounds\")

		if (this.iSpeechRecognizer && !this.Listening)
			if !this.iSpeechRecognizer.startRecognizer() {
				if retry
					Task.startTask(ObjBindMethod(this, "startListening", true), 200)

				return false
			}
			else {
				if this.Interruptable
					this.interrupt(true)

				playSound("VMSoundPlayer.exe", talkSound, audioDevice)

				this.iIsListening := true

				return true
			}
	}

	stopActivationListener(retry := false) {
		this.stopListening(retry)
	}

	stopListening(retry := false) {
		if (this.iSpeechRecognizer && this.Listening)
			if !this.iSpeechRecognizer.stopRecognizer() {
				if retry
					Task.startTask(ObjBindMethod(this, "stopListening", true), 200)

				return false
			}
			else {
				this.iIsListening := false

				return true
			}
	}

	interrupt(all := false) {
		local voiceServer := this.VoiceServer
		local speaker

		if voiceServer {
			if all
				messageSend(kWindowMessage, "Voice", "interrupt", "ahk_pid " . this.VoiceServer, "INTR")
			else
				messageSend(kWindowMessage, "Voice", "interrupt:" . this.Name, "ahk_pid " . this.VoiceServer, "INTR")
		}
		else {
			speaker := this.getSpeaker()

			if speaker
				speaker.stop()
		}
	}

	mute() {
		local voiceServer := this.VoiceServer

		if voiceServer
			try {
				FileAppend("TRUE", kTempDirectory . "Voice.mute")
			}
			catch Any as exception {
				logError(exception)
			}
	}

	unmute() {
		local voiceServer := this.VoiceServer

		if voiceServer
			deleteFile(kTempDirectory . "Voice.mute")
	}

	getGrammars(language) {
		throw "Virtual method VoiceManager.getGrammars must be implemented in a subclass..."
	}

	buildFragments(language) {
		local fragments := CaseInsenseWeakMap()
		local grammars := this.getGrammars(language)
		local fragment, word

		prepareGrammar(name, grammar) {
			local start := A_TickCount

			grammar.Phrases

			if isDebug()
				logMessage(kLogDebug, "Preparing grammar " . name . " took " . (A_TickCount - start) . " ms")
		}

		for fragment, word in getMultiMapValues(grammars, "Fragments")
			fragments[fragment] := word

		return fragments
	}

	buildPhrases(language, section := "Speaker Phrases") {
		local phrases := CaseInsenseMap()
		local grammars := this.getGrammars(language)
		local key, value

		for key, value in getMultiMapValues(grammars, section) {
			key := ConfigurationItem.splitDescriptor(key)[1]

			if this.Debug[kDebugPhrases]
				showMessage("Register voice phrase: " . key . " = " . value)

			if phrases.Has(key)
				phrases[key].Push(value)
			else
				phrases[key] := Array(value)
		}

		return phrases
	}

	buildGrammars(spRecognizer, language) {
		local grammars := this.getGrammars(language)
		local mode := getMultiMapValue(grammars, "Configuration", "Recognizer", "Grammar")
		local compilerRecognizer := SpeechRecognizer("Compiler", true, this.Language, false, "Text")
		local booster := this.Booster
		local grammar, definition, name, choices, nextCharIndex

		this.iRecognizerMode := mode

		for name, choices in getMultiMapValues(grammars, "Choices") {
			compilerRecognizer.setChoices(name, choices)

			if booster
				booster.setChoices(name, choices)

			if spRecognizer {
				spRecognizer.setChoices(name, choices)

				if spRecognizer.Booster
					spRecognizer.Booster.setChoices(name, choices)
			}
			else
				messageSend(kFileMessage, "Voice", "registerChoices:" . values2String(";", this.Name, name, string2Values(",", StrReplace(choices, ";", ","))*)
										, this.VoiceServer)
		}

		for grammar, definition in getMultiMapValues(grammars, "Listener Grammars") {
			definition := substituteVariables(definition, {name: this.Name})

			if booster
				booster.setGrammar(grammar, definition)

			if (spRecognizer && spRecognizer.Booster)
				spRecognizer.Booster.setGrammar(grammar, definition)

			if (mode = "Mixed") {
				if !compilerRecognizer {
					compilerRecognizer := SpeechRecognizer("Compiler", true, this.Language, false, "Text")

					for name, choices in getMultiMapValues(grammars, "Choices")
						compilerRecognizer.setChoices(name, choices)
				}

				if this.Debug[kDebugGrammars] {
					nextCharIndex := 1

					showMessage("Register command phrase: " . GrammarCompiler(compilerRecognizer).readGrammar(&definition, &nextCharIndex).toString())
				}

				this.Grammars[grammar] := compilerRecognizer.compileGrammar(definition)
			}

			if ((mode != "Mixed") || (grammar = "Call"))
				if spRecognizer {
					if (mode = "Text") {
						if (grammar != "Call")
							throw "Listener grammars are not supported in continuous text recognition..."

						continue
					}

					if this.Debug[kDebugGrammars] {
						nextCharIndex := 1

						showMessage("Register command phrase: " . GrammarCompiler(spRecognizer).readGrammar(&definition, &nextCharIndex).toString())
					}

					if ((grammar != "Call") || (mode = "Grammar"))
						try {
							if !spRecognizer.loadGrammar(grammar, spRecognizer.compileGrammar(definition), ObjBindMethod(this, "raisePhraseRecognized"))
								throw "Recognizer not running..."
						}
						catch Any as exception {
							logError(exception, true)

							logMessage(kLogCritical, translate("Error while registering voice command `"") . definition . translate("`" - please check the configuration"))

							if !kSilentMode
								showMessage(substituteVariables(translate("Cannot register voice command `"%command%`" - please check the configuration..."), {command: definition})
										  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
						}
				}
				else if (grammar != "Call") {
					this.Grammars[grammar] := compilerRecognizer.compileGrammar(definition)

					if (mode = "Text")
						throw "Listener grammars are not supported in continuous text recognition..."

					messageSend(kFileMessage, "Voice", "registerVoiceCommand:" . values2String(";", this.Name, grammar, StrReplace(definition, ";", ","), "remoteCommandRecognized")
											, this.VoiceServer)
				}
		}

		if !spRecognizer
			messageSend(kFileMessage, "Voice", "registerVoiceCommand:" . values2String(";", this.Name, "Text", "*", "remoteTextRecognized")
									, this.VoiceServer)

		if (mode = "Grammar") {
			this.Grammars["?"] := compilerRecognizer.compileGrammar("[Unknown]")

			if spRecognizer {
				try {
					spRecognizer.loadGrammar("?", spRecognizer.compileGrammar("[Unknown]"), ObjBindMethod(this, "raisePhraseRecognized"))
				}
				catch Any as exception {
					logError(exception, true)
				}
			}
			else
				messageSend(kFileMessage, "Voice", "registerVoiceCommand:" . values2String(";", this.Name, "?", "[Unknown]", "remoteCommandRecognized")
										, this.VoiceServer)
		}
	}

	unknownRecognized(text) {
		this.raiseTextRecognized("Text", text)
	}

	raisePhraseRecognized(grammar, words) {
		messageSend(kLocalMessage, "Voice", "localPhraseRecognized:" . values2String(";", grammar, words*))
	}

	raiseTextRecognized(grammar, text) {
		messageSend(kLocalMessage, "Voice", "localTextRecognized:" . values2String(";", grammar, text))
	}

	localPhraseRecognized(grammar, words*) {
		this.phraseRecognized(grammar, words)
	}

	localTextRecognized(grammar, text) {
		if (Trim(text) != "")
			this.textRecognized(grammar, text)
	}

	remoteActivationRecognized(words*) {
		if (words.Length > 0)
			this.phraseRecognized("Call", words, true)
	}

	remoteDeactivationRecognized(words*) {
		; this.clearContinuation()
	}

	remoteSpeakingStatusUpdate(status) {
		if (status = "Start")
			this.Speaking := true
		else if (status = "Stop")
			this.Speaking := false
	}

	remoteCommandRecognized(grammar, command, words*) {
		this.phraseRecognized(grammar, words, true)
	}

	remoteTextRecognized(grammar, command, text) {
		if (Trim(text) != "")
			this.textRecognized(grammar, text, true)
	}

	matchCommand(text, &words) {
		local index, literal, bestRating, bestMatch, ignore, grammar, name

		allMatches(string, minRating, maxRating, strings*) {
			local ratings := []
			local index, value, rating
			local dllFile

			static recognizer := false

			if !recognizer {
				dllFile := (kBinariesDirectory . "Microsoft\Microsoft.Speech.Recognizer.dll")

				try {
					if (!FileExist(dllFile)) {
						logMessage(kLogCritical, translate("Speech.Recognizer.dll not found in ") . kBinariesDirectory)

						throw "Unable to find Speech.Recognizer.dll in " . kBinariesDirectory . "..."
					}

					recognizer := CLR_LoadLibrary(dllFile).CreateInstance("Speech.MicrosoftSpeechRecognizer")
				}
				catch Any as exception {
					logError(exception, true)

					logMessage(kLogCritical, translate("Error while initializing speech recognition module - please install the speech recognition software"))

					if !kSilentMode
						showMessage(translate("Error while initializing speech recognition module - please install the speech recognition software") . translate("...")
											, translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				}
			}

			if recognizer
				for index, value in strings {
					rating := recognizer.Compare(string, value)

					if (rating > minRating) {
						ratings.Push({Rating: rating, Target: value})

						if (rating > maxRating)
							break
					}
				}

			if (ratings.Length > 0) {
				bubbleSort(&ratings, (r1, r2) => r1.Rating < r2.Rating)

				return {BestMatch: ratings[1], Ratings: ratings}
			}
			else
				return {Ratings: []}
		}

		match(string, grammar, minRating?, maxRating?) {
			local matches, settings

			static ratingLow := kUndefined
			static ratingHigh := kUndefined

			if (ratingLow = kUndefined) {
				settings := readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))

				ratingLow := getMultiMapValue(settings, "Voice", "Low Rating", 0.7)
				ratingHigh := getMultiMapValue(settings, "Voice", "High Rating", 0.85)
			}

			matches := allMatches(string, isSet(minRating) ? minRating : ratingLow
										, isSet(maxRating) ? maxRating : ratingHigh
										, grammar.Phrases*)

			return (matches.HasProp("BestMatch") ? matches.BestMatch.Rating : false)
		}

		bestRating := 0
		bestMatch := false

		for name, grammar in this.Grammars {
			rating := match(text, grammar)

			if (rating > bestRating) {
				bestRating := rating
				bestMatch := name
			}
		}

		if bestMatch {
			words := string2Values(A_Space, text)

			for index, literal in words {
				literal := StrReplace(literal, ".", "")
				literal := StrReplace(literal, ",", "")
				literal := StrReplace(literal, ";", "")
				literal := StrReplace(literal, "?", "")
				literal := StrReplace(literal, "-", "")

				words[index] := literal
			}

			return bestMatch
		}
		else
			return false
	}

	recognize(text) {
		if this.VoiceServer
			messageSend(kFileMessage, "Voice", "recognize:" . values2String(";", this.VoiceManager.Name, text), this.VoiceServer)
		else
			this.iSpeechRecognizer.recognize(text)
	}

	phraseRecognized(grammar, words, remote := false) {
		if (this.Debug[kDebugRecognitions] && !remote)
			showMessage("Command phrase recognized: " . grammar . " => " . values2String(A_Space, words*))

		protectionOn()

		try {
			this.handleVoiceCommand(grammar, words)
		}
		finally {
			protectionOff()
		}
	}

	textRecognized(grammar, text, remote := false) {
		local matchText := text
		local alternateText, words, recognizedGrammar

		if (this.Debug[kDebugRecognitions] && !remote)
			showMessage("Text recognized: " . text)

		protectionOn()

		try {
			if (this.iRecognizerMode = "Mixed") {
				if (this.Booster && (this.Booster.Mode = "Always")) {
					alternateText := this.Booster.recognize(matchText)

					if (alternateText && (alternateText != ""))
						matchText := alternateText
				}

				recognizedGrammar := this.matchCommand(matchText, &words)

				if (this.Booster && !recognizedGrammar && (this.Booster.Mode = "Unknown")) {
					alternateText := this.Booster.recognize(matchText)

					if (alternateText && (alternateText != ""))
						matchText := alternateText

					recognizedGrammar := this.matchCommand(matchText, &words)
				}
			}
			else
				recognizedGrammar := false

			if recognizedGrammar
				this.handleVoiceCommand(recognizedGrammar, words)
			else
				this.handleVoiceText(grammar, text)
		}
		finally {
			protectionOff()
		}
	}

	recognizeActivation(grammar, words) {
		messageSend(kFileMessage, "Voice", "recognizeActivation:" . values2String(";", this.Name, grammar, words*), this.VoiceServer)
	}

	recognizeCommand(grammar, words) {
		if this.VoiceServer
			messageSend(kFileMessage, "Voice", "recognizeCommand:" . values2String(";", grammar, words*), this.VoiceServer)
		else if this.Grammars.Has(grammar)
			this.phraseRecognized(grammar, words)
	}

	setContinuation(continuation) {
		if continuation
			this.iContinuation := continuation
		else
			this.clearContinuation()
	}

	clearContinuation() {
		this.iContinuation := false
	}

	handleVoiceCommand(grammar, words) {
		throw "Virtual method VoiceManager.handleVoiceCommand must be implemented in a subclass..."
	}

	handleVoiceText(grammar, text) {
		throw "Virtual method VoiceManager.handleVoiceText must be implemented in a subclass..."
	}
}