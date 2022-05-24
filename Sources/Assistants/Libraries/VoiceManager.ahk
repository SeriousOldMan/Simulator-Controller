;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Voice Chat Manager              ;;;
;;;                                         Client for Voice Server         ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Global Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

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

class VoiceManager {
	iDebug := kDebugOff

	iLanguage := "en"

	iName := false

	iSynthesizer := "dotNET"
	iSpeaker := false
	iSpeakerVolume := 100
	iSpeakerPitch := 0
	iSpeakerSpeed := 0

	iRecognizer := "Desktop"
	iListener := false

	iVoiceServer := false
	iGrammars := {}

	iPushToTalk := false

	iSpeechSynthesizer := false
	iSpeechRecognizer := false
	iIsSpeaking := false
	iIsListening := false

	iContinuation := false

	class RemoteSpeaker {
		iVoiceManager := false
		iFragments := {}
		iPhrases := {}

		iSpeaker := false
		iLanguage := false

		iIsTalking := false
		iText := ""
		iFocus := false

		VoiceManager[] {
			Get {
				return this.iVoiceManager
			}
		}

		Speaking[] {
			Get {
				return this.VoiceManager.Speaking
			}

			Set {
				return (this.VoiceManager.Speaking := value)
			}
		}

		Talking[] {
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

		startTalk() {
			this.iIsTalking := true
		}

		finishTalk() {
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
				raiseEvent(kFileMessage, "Voice", "speak:" . values2String(";", this.VoiceManager.Name, text, focus), this.VoiceManager.VoiceServer)
		}

		speakPhrase(phrase, variables := false, focus := false, cache := false) {
			phrases := this.Phrases

			if phrases.HasKey(phrase) {
				phrases := phrases[phrase]

				Random index, 1, % phrases.Length()

				if cache
					cache .= ("." . index)

				phrase := substituteVariables(phrases[Round(index)], this.VoiceManager.getPhraseVariables(variables))
			}

			if phrase
				this.speak(phrase, focus, cache)
		}
	}

	class LocalSpeaker extends SpeechSynthesizer {
		iVoiceManager := false
		iFragments := {}
		iPhrases := {}

		iIsTalking := false
		iText := ""
		iFocus := false

		VoiceManager[] {
			Get {
				return this.iVoiceManager
			}
		}

		Speaking[] {
			Get {
				return (this.VoiceManager.Speaking || base.Speaking)
			}

			Set {
				return (this.VoiceManager.Speaking := value)
			}
		}

		Talking[] {
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

			base.__New(synthesizer, speaker, language)
		}

		startTalk() {
			this.iIsTalking := true
		}

		finishTalk() {
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
			else {
				stopped := this.VoiceManager.stopListening()

				try {
					this.Speaking := true

					try {
						base.speak(text, !this.Awaitable, cache)
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
			phrases := this.Phrases

			if phrases.HasKey(phrase) {
				phrases := phrases[phrase]

				Random index, 1, % phrases.Length()

				if cache
					cache .= ("." . index)

				phrase := substituteVariables(phrases[Round(index)], this.VoiceManager.getPhraseVariables(variables))
			}

			if phrase
				this.speak(phrase, focus, cache)
		}
	}

	class VoiceContinuation {
		iVoiceManager := false
		iContinuation := false
		iReply := false

		VoiceManager[] {
			Get {
				return this.iVoiceManager
			}
		}

		Continuation[] {
			Get {
				return this.iContinuation
			}
		}

		Reply[] {
			Get {
				return this.iReply
			}
		}

		__New(voiceManager, continuation, reply := false) {
			this.iVoiceManager := voiceManager
			this.iContinuation := continuation
			this.iReply := reply
		}

		continue() {
			if (this.VoiceManager.Speaker && this.Reply)
				this.VoiceManager.getSpeaker().speakPhrase(this.Reply)

			continuation := this.Continuation

			if isInstance(continuation, this.VoiceContinuation)
				continuation.continue()
			else if continuation
				%continuation%()
		}
	}

	Debug[option] {
		Get {
			return (this.iDebug & option)
		}
	}

	VoiceServer[] {
		Get {
			return this.iVoiceServer
		}
	}

	Language[] {
		Get {
			return this.iLanguage
		}
	}

	Name[] {
		Get {
			return this.iName
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
			return this.iIsSpeaking
		}

		Set {
			return (this.iIsSpeaking := value)
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
			return this.iIsListening
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

	Grammars[] {
		Get {
			return this.iGrammars
		}
	}

	PushToTalk[] {
		Get {
			return this.iPushToTalk
		}
	}

	User[] {
		Get {
			Throw "Virtual property VoiceManager.User must be implemented in a subclass..."
		}
	}

	Continuation[] {
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

		registerEventHandler("Voice", ObjBindMethod(this, "handleVoiceCalls"))

		if (!this.VoiceServer && this.PushToTalk) {
			listen := ObjBindMethod(this, "listen")

			SetTimer %listen%, 100
		}

		if this.VoiceServer
			OnExit(ObjBindMethod(this, "shutdownVoiceManager"))
	}

	shutdownVoiceManager() {
		if (this.VoiceServer && this.iSpeechSynthesizer) {
			Process Exist

			processID := ErrorLevel

			raiseEvent(kFileMessage, "Voice", "unregisterVoiceClient:" . values2String(";", this.Name, processID), this.VoiceServer)
		}

		return false
	}

	initialize(options) {
		if options.HasKey("Vocalics") {
			vocalics := options["Vocalics"]

			if !options.HasKey("SpeakerVolume")
				options["SpeakerVolume"] := vocalics[1]

			if !options.HasKey("SpeakerPitch")
				options["SpeakerPitch"] := vocalics[2]

			if !options.HasKey("SpeakerSpeed")
				options["SpeakerSpeed"] := vocalics[3]
		}

		if options.HasKey("Language")
			this.iLanguage := options["Language"]

		if options.HasKey("Synthesizer")
			this.iSynthesizer := options["Synthesizer"]

		if options.HasKey("Speaker")
			this.iSpeaker := options["Speaker"]

		if options.HasKey("SpeakerVolume")
			this.iSpeakerVolume := options["SpeakerVolume"]

		if options.HasKey("SpeakerPitch")
			this.iSpeakerPitch := options["SpeakerPitch"]

		if options.HasKey("SpeakerSpeed")
			this.iSpeakerSpeed := options["SpeakerSpeed"]

		if options.HasKey("Recognizer")
			this.iRecognizer := options["Recognizer"]

		if options.HasKey("Listener")
			this.iListener := options["Listener"]

		if options.HasKey("PushToTalk")
			this.iPushToTalk := options["PushToTalk"]

		if options.HasKey("VoiceServer")
			this.iVoiceServer := options["VoiceServer"]
	}

	listen() {
		theHotkey := this.PushToTalk

		if !this.Speaking && GetKeyState(theHotKey, "P")
			this.startListening()
		else if !GetKeyState(theHotKey, "P")
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

			variables["Name"] := this.Name
			variables["User"] := this.User

			return variables
		}
		else
			return {Name: this.Name, User: this.User}
	}

	getSpeaker() {
		if (this.Speaker && !this.iSpeechSynthesizer) {
			if this.VoiceServer {
				Process Exist

				processID := ErrorLevel

				activationCommand := getConfigurationValue(this.getGrammars(this.Language), "Listener Grammars", "Call", false)
				activationCommand := substituteVariables(activationCommand, {name: this.Name})

				raiseEvent(kFileMessage, "Voice"
						 , "registerVoiceClient:" . values2String(";", this.Name, processID
																, activationCommand, "remoteActivationRecognized", "remoteDeactivationRecognized"
																, this.Language, this.Synthesizer, this.Speaker
																, this.Recognizer, this.Listener
																, this.SpeakerVolume, this.SpeakerPitch, this.SpeakerSpeed), this.VoiceServer)

				this.iSpeechSynthesizer := new this.RemoteSpeaker(this, this.Synthesizer, this.Speaker, this.Language
																, this.buildFragments(this.Language), this.buildPhrases(this.Language))
			}
			else {
				this.iSpeechSynthesizer := new this.LocalSpeaker(this, this.Synthesizer, this.Speaker, this.Language
															   , this.buildFragments(this.Language), this.buildPhrases(this.Language))

				this.iSpeechSynthesizer.setVolume(this.SpeakerVolume)
				this.iSpeechSynthesizer.setPitch(this.SpeakerPitch)
				this.iSpeechSynthesizer.setRate(this.SpeakerSpeed)
			}

			this.startListener()
		}

		return this.iSpeechSynthesizer
	}

	startListener() {
		static initialized := false

		if (!initialized && this.Listener && !this.iSpeechRecognizer) {
			initialized := true

			if this.VoiceServer
				this.buildGrammars(false, this.Language)
			else {
				recognizer := new SpeechRecognizer(this.Recognizer, this.Listener, this.Language)

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
				if retry {
					callback := ObjBindMethod(this, "startListening", true)

					SetTimer %callback%, -200
				}

				return false
			}
			else {
				SoundPlay %kResourcesDirectory%Sounds\Talk.wav

				this.iIsListening := true

				return true
			}
	}

	stopListening(retry := false) {
		local function

		if this.iSpeechRecognizer && this.Listening
			if !this.iSpeechRecognizer.stopRecognizer() {
				if retry {
					callback := ObjBindMethod(this, "stopListening", true)

					SetTimer %callback%, -200
				}

				return false
			}
			else {
				this.iIsListening := false

				return true
			}
	}

	mute() {
		if this.VoiceServer
			try {
				FileAppend TRUE, %kTempDirectory%Voice.mute
			}
			catch exception {
				; ignore
			}
	}

	unmute() {
		if this.VoiceServer
			try {
				FileDelete %kTempDirectory%Voice.mute
			}
			catch exception {
				; ignore
			}
	}

	getGrammars(language) {
		Throw "Virtual method VoiceManager.getGrammars must be implemented in a subclass..."
	}

	buildFragments(language) {
		fragments := {}

		grammars := this.getGrammars(language)

		for fragment, word in getConfigurationSectionValues(grammars, "Fragments", {})
			fragments[fragment] := word

		return fragments
	}

	buildPhrases(language, section := "Speaker Phrases") {
		phrases := {}

		grammars := this.getGrammars(language)

		for key, value in getConfigurationSectionValues(grammars, section, {}) {
			key := ConfigurationItem.splitDescriptor(key)[1]

			if this.Debug[kDebugPhrases]
				showMessage("Register voice phrase: " . key . " = " . value)

			if phrases.HasKey(key)
				phrases[key].Push(value)
			else
				phrases[key] := Array(value)
		}

		return phrases
	}

	buildGrammars(speechRecognizer, language) {
		local grammar

		grammars := this.getGrammars(language)

		for name, choices in getConfigurationSectionValues(grammars, "Choices", {})
			if speechRecognizer
				speechRecognizer.setChoices(name, choices)
			else
				raiseEvent(kFileMessage, "Voice", "registerChoices:" . values2String(";", this.Name, name, string2Values(",", choices)*), this.VoiceServer)

		for grammar, definition in getConfigurationSectionValues(grammars, "Listener Grammars", {}) {
			definition := substituteVariables(definition, {name: this.Name})

			this.Grammars[grammar] := definition

			if speechRecognizer {
				if this.Debug[kDebugGrammars] {
					nextCharIndex := 1

					showMessage("Register command phrase: " . new GrammarCompiler(speechRecognizer).readGrammar(definition, nextCharIndex).toString())
				}

				speechRecognizer.loadGrammar(grammar, speechRecognizer.compileGrammar(definition), ObjBindMethod(this, "raisePhraseRecognized"))
			}
			else if (grammar != "Call")
				raiseEvent(kFileMessage, "Voice", "registerVoiceCommand:" . values2String(";", this.Name, grammar, definition, "remoteCommandRecognized"), this.VoiceServer)
		}

		if speechRecognizer
			speechRecognizer.loadGrammar("?", speechRecognizer.compileGrammar("[Unknown]"), ObjBindMethod(this, "raisePhraseRecognized"))
		else
			raiseEvent(kFileMessage, "Voice", "registerVoiceCommand:" . values2String(";", this.Name, "?", "[Unknown]", "remoteCommandRecognized"), this.VoiceServer)
	}

	handleVoiceCalls(event, data) {
		if InStr(data, ":") {
			data := StrSplit(data, ":", , 2)

			return withProtection(ObjBindMethod(this, data[1]), string2Values(";", data[2])*)
		}
		else
			return withProtection(ObjBindMethod(this, data))
	}

	raisePhraseRecognized(grammar, words) {
		raiseEvent(kLocalMessage, "Voice", "localPhraseRecognized:" . values2String(";", grammar, words*))
	}

	localPhraseRecognized(grammar, words*) {
		this.phraseRecognized(grammar, words)
	}

	remoteActivationRecognized(words*) {
		if (words.Length() > 0)
			this.phraseRecognized("Call", words, true)
	}

	remoteDeactivationRecognized(words*) {
		this.clearContinuation()
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
		raiseEvent(kFileMessage, "Voice", "recognizeActivation:" . values2String(";", this.Name, grammar, words*), this.VoiceServer)
	}

	recognizeCommand(grammar, words) {
		if this.VoiceServer
			raiseEvent(kFileMessage, "Voice", "recognizeCommand:" . values2String(";", grammar, words*), this.VoiceServer)
		else if this.Grammars.HasKey(grammar)
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
		Throw "Virtual method VoiceManager.handleVoiceCommand must be implemented in a subclass..."
	}
}