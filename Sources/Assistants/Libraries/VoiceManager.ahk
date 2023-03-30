;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Voice Chat Manager              ;;;
;;;                                         Client for Voice Server         ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
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

class VoiceManager {
	iDebug := kDebugOff

	iLanguage := "en"

	iName := false

	iSynthesizer := "dotNET"
	iSpeaker := false
	iSpeakerVolume := 100
	iSpeakerPitch := 0
	iSpeakerSpeed := 0

	iMuted := false

	iRecognizer := "Desktop"
	iListener := false

	iVoiceServer := false
	iGrammars := CaseInsenseMap()

	iPushToTalk := false

	iSpeechSynthesizer := false
	iSpeechRecognizer := false
	iIsSpeaking := false
	iIsListening := false

	iContinuation := false

	class RemoteSpeaker {
		iVoiceManager := false
		iFragments := CaseInsenseMap()
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

		Talking {
			Get {
				return this.iIsTalking
			}
		}

		Phrases[key := false] {
			Get {
				if key
					return this.iPhrases[key]
				else
					return this.iPhrases
			}
		}

		Fragments[key := false] {
			Get {
				if key
					return this.iFragments[key]
				else
					return this.iFragments
			}
		}

		__New(voiceManager, synthesizer, speaker, language, fragments, phrases) {
			this.iVoiceManager := voiceManager
			this.iFragments := fragments
			this.iPhrases := phrases

			this.iSpeaker := speaker
			this.iLanguage := language
		}

		beginTalk() {
			this.iIsTalking := true
		}

		endTalk() {
			local text, focus

			if this.Talking {
				text := this.iText
				focus := this.iFocus

				this.iText := ""
				this.iFocus := false
				this.iIsTalking := false

				if (StrLen(Trim(text)) > 0)
					this.speak(text, focus)
			}
		}

		speak(text, focus := false, cache := false) {
			if this.Talking {
				this.iText .= (A_Space . text)
				this.iFocus := (this.iFocus || focus)
			}
			else
				messageSend(kFileMessage, "Voice", "speak:" . values2String(";", this.VoiceManager.Name, text, focus), this.VoiceManager.VoiceServer)
		}

		speakPhrase(phrase, variables := false, focus := false, cache := false) {
			local phrases := this.Phrases
			local index

			if phrases.Has(phrase) {
				phrases := phrases[phrase]

				index := Random(1, phrases.Length)

				if cache
					cache .= ("." . index)

				phrase := substituteVariables(phrases[Round(index)], this.VoiceManager.getPhraseVariables(variables))
			}

			if phrase
				this.speak(phrase, focus, cache)
		}

		number2Speech(number, precision := "__Undefined__") {
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
		iFragments := CaseInsenseMap()
		iPhrases := CaseInsenseMap()

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

		Speaking {
			Get {
				return (this.VoiceManager.Speaking || super.Speaking)
			}

			Set {
				return (this.VoiceManager.Speaking := value)
			}
		}

		Talking {
			Get {
				return this.iIsTalking
			}
		}

		Phrases[key := false] {
			Get {
				if key
					return this.iPhrases[key]
				else
					return this.iPhrases
			}
		}

		Fragments[key := false] {
			Get {
				if key
					return this.iFragments[key]
				else
					return this.iFragments
			}
		}

		__New(voiceManager, synthesizer, speaker, language, fragments, phrases) {
			this.iVoiceManager := voiceManager
			this.iFragments := fragments
			this.iPhrases := phrases

			super.__New(synthesizer, speaker, language)
		}

		beginTalk() {
			this.iIsTalking := true
		}

		endTalk() {
			local text, focus

			if this.Talking {
				text := this.iText
				focus := this.iFocus

				this.iText := ""
				this.iFocus := false
				this.iIsTalking := false

				if (StrLen(Trim(text)) > 0)
					this.speak(text, focus)
			}
		}

		speak(text, focus := false, cache := false) {
			local stopped

			if this.Talking {
				this.iText .= (A_Space . text)
				this.iFocus := (this.iFocus || focus)
			}
			else {
				stopped := this.VoiceManager.stopListening()

				try {
					this.Speaking := true

					try {
						super.speak(text, !this.Awaitable, cache)
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

		speakPhrase(phrase, variables := false, focus := false, cache := false) {
			local phrases := this.Phrases
			local index

			if phrases.Has(phrase) {
				phrases := phrases[phrase]

				index := Random(1, phrases.Length)

				if cache
					cache .= ("." . index)

				phrase := substituteVariables(phrases[Round(index)], this.VoiceManager.getPhraseVariables(variables))
			}

			if phrase
				this.speak(phrase, focus, cache)
		}

		number2Speech(number, precision := "__Undefined__") {
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

		__New(voiceManager, arguments*) {
			this.iVoiceManager := voiceManager

			super.__New(arguments*)
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

	Grammars {
		Get {
			return this.iGrammars
		}
	}

	PushToTalk {
		Get {
			return this.iPushToTalk
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

	__New(name, options) {
		this.iDebug := (isDebug() ? (kDebugGrammars + kDebugRecognitions) : kDebugOff)

		this.iName := name

		this.initialize(options)

		if !this.Speaker
			this.iListener := false

		registerMessageHandler("Voice", methodMessageHandler, this)

		if (!this.VoiceServer && this.PushToTalk)
			PeriodicTask(ObjBindMethod(this, "listen"), 100, kHighPriority).start()

		if this.VoiceServer
			OnExit(ObjBindMethod(this, "shutdownVoiceManager"))
	}

	shutdownVoiceManager(*) {
		if (this.VoiceServer && this.iSpeechSynthesizer)
			messageSend(kFileMessage, "Voice", "unregisterVoiceClient:" . values2String(";", this.Name, ProcessExist()), this.VoiceServer)

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

		if options.Has("Speaker")
			this.iSpeaker := options["Speaker"]

		if options.Has("SpeakerVolume")
			this.iSpeakerVolume := options["SpeakerVolume"]

		if options.Has("SpeakerPitch")
			this.iSpeakerPitch := options["SpeakerPitch"]

		if options.Has("SpeakerSpeed")
			this.iSpeakerSpeed := options["SpeakerSpeed"]

		if options.Has("Recognizer")
			this.iRecognizer := options["Recognizer"]

		if options.Has("Listener")
			this.iListener := options["Listener"]

		if options.Has("PushToTalk")
			this.iPushToTalk := options["PushToTalk"]

		if options.Has("VoiceServer")
			this.iVoiceServer := options["VoiceServer"]
	}

	listen() {
		local theHotkey := this.PushToTalk

		if !this.Speaking && GetKeyState(theHotkey, "P")
			this.startListening()
		else if !GetKeyState(theHotkey, "P")
			this.stopListening()
	}

	setDebug(option, enabled) {
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
		local pid, activationCommand

		if (this.Speaker && !this.iSpeechSynthesizer) {
			if this.VoiceServer {
				pid := ProcessExist()

				activationCommand := getMultiMapValue(this.getGrammars(this.Language), "Listener Grammars", "Call", false)
				activationCommand := substituteVariables(activationCommand, {name: this.Name})

				messageSend(kFileMessage, "Voice"
										, "registerVoiceClient:" . values2String(";", this.Name, this.Routing, ProcessExist()
																					, activationCommand
																					, "remoteActivationRecognized", "remoteDeactivationRecognized"
																					, this.Language, this.Synthesizer, this.Speaker
																					, this.Recognizer, this.Listener
																					, this.SpeakerVolume, this.SpeakerPitch, this.SpeakerSpeed)
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
		local recognizer

		static initialized := false

		if (!initialized && this.Listener && !this.iSpeechRecognizer) {
			initialized := true

			if this.VoiceServer
				this.buildGrammars(false, this.Language)
			else {
				recognizer := VoiceManager.LocalRecognizer(this, this.Recognizer, this.Listener, this.Language)

				this.buildGrammars(recognizer, this.Language)

				if !this.PushToTalk
					recognizer.startRecognizer()

				this.iSpeechRecognizer := recognizer
			}
		}
	}

	startListening(retry := true) {
		local function

		if this.iSpeechRecognizer && !this.Listening
			if !this.iSpeechRecognizer.startRecognizer() {
				if retry
					Task.startTask(ObjBindMethod(this, "startListening", true), 200)

				return false
			}
			else {
				SoundPlay(kResourcesDirectory . "Sounds\Talk.wav")

				this.iIsListening := true

				return true
			}
	}

	stopListening(retry := false) {
		local function

		if this.iSpeechRecognizer && this.Listening
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
		local fragments := CaseInsenseMap()
		local grammars := this.getGrammars(language)
		local fragment, word

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

	buildGrammars(speechRecognizer, language) {
		local grammars := this.getGrammars(language)
		local grammar, definition, name, choices, nextCharIndex

		for name, choices in getMultiMapValues(grammars, "Choices")
			if speechRecognizer
				speechRecognizer.setChoices(name, choices)
			else
				messageSend(kFileMessage, "Voice", "registerChoices:" . values2String(";", this.Name, name, string2Values(",", choices)*), this.VoiceServer)

		for grammar, definition in getMultiMapValues(grammars, "Listener Grammars") {
			definition := substituteVariables(definition, {name: this.Name})

			this.Grammars[grammar] := definition

			if speechRecognizer {
				if this.Debug[kDebugGrammars] {
					nextCharIndex := 1

					showMessage("Register command phrase: " . GrammarCompiler(speechRecognizer).readGrammar(&definition, &nextCharIndex).toString())
				}

				try {
					if !speechRecognizer.loadGrammar(grammar, speechRecognizer.compileGrammar(definition), ObjBindMethod(this, "raisePhraseRecognized"))
						throw "Recognizer not running..."
				}
				catch Any as exception {
					logMessage(kLogCritical, translate("Error while registering voice command `"") . definition . translate("`" - please check the configuration"))

					showMessage(substituteVariables(translate("Cannot register voice command `"%command%`" - please check the configuration..."), {command: definition})
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				}
			}
			else if (grammar != "Call")
				messageSend(kFileMessage, "Voice", "registerVoiceCommand:" . values2String(";", this.Name, grammar, definition, "remoteCommandRecognized"), this.VoiceServer)
		}

		/*
		if speechRecognizer {
			try {
				speechRecognizer.loadGrammar("?", speechRecognizer.compileGrammar("[Unknown]"), ObjBindMethod(this, "raisePhraseRecognized"))
			}
			catch Any as exception {
				logError(exception)^
			}
		}
		else
			messageSend(kFileMessage, "Voice", "registerVoiceCommand:" . values2String(";", this.Name, "?", "[Unknown]", "remoteCommandRecognized"), this.VoiceServer)
		*/

		if !speechRecognizer
			messageSend(kFileMessage, "Voice", "registerVoiceCommand:" . values2String(";", this.Name, "?", "[Unknown]", "remoteCommandRecognized"), this.VoiceServer)

	}

	raisePhraseRecognized(grammar, words) {
		messageSend(kLocalMessage, "Voice", "localPhraseRecognized:" . values2String(";", grammar, words*))
	}

	localPhraseRecognized(grammar, words*) {
		this.phraseRecognized(grammar, words)
	}

	remoteActivationRecognized(words*) {
		if (words.Length > 0)
			this.phraseRecognized("Call", words, true)
	}

	remoteDeactivationRecognized(words*) {
		; this.clearContinuation()
	}

	remoteCommandRecognized(grammar, command, words*) {
		this.phraseRecognized(grammar, words, true)
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
}