;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Voice Chat Assistant            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
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

class VoiceAssistant {
	iDebug := kDebugOff
	
	iLanguage := "en"
	
	iName := false
	
	iService := "Windows"
	iSpeaker := false
	iSpeakerVolume := 100
	iSpeakerPitch := 0
	iSpeakerSpeed := 0
	
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
		iAssistant := false
		iFragments := {}
		iPhrases := {}
		
		iSpeaker := false
		iLanguage := false
		
		Assistant[] {
			Get {
				return this.iAssistant
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
		
		__New(assistant, service, speaker, language, fragments, phrases) {
			this.iAssistant := assistant
			this.iFragments := fragments
			this.iPhrases := phrases
			
			this.iSpeaker := speaker
			this.iLanguage := language
		}
		
		speak(text, question := false) {
			raiseEvent(kFileMessage, "Voice", "speak:" . values2String(";", this.Assistant.Name, text, question), this.Assistant.VoiceServer)
		}
		
		speakPhrase(phrase, variables := false, question := false) {
			phrases := this.Phrases
			
			if phrases.HasKey(phrase) {
				phrases := phrases[phrase]
				
				Random index, 1, % phrases.Length()
				
				phrase := substituteVariables(phrases[Round(index)], this.Assistant.getPhraseVariables(variables))
			}
			
			if phrase
				this.speak(phrase, question)
		}
	}
	
	class LocalSpeaker extends SpeechSynthesizer {
		iAssistant := false
		iFragments := {}
		iPhrases := {}
		
		Assistant[] {
			Get {
				return this.iAssistant
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
		
		__New(assistant, service, speaker, language, fragments, phrases) {
			this.iAssistant := assistant
			this.iFragments := fragments
			this.iPhrases := phrases
			
			base.__New(service, speaker, language)
		}
		
		speak(text, focus := false) {
			stopped := this.Assistant.stopListening()
			
			try {
				this.iIsSpeaking := true
			
				try {
					base.speak(text, true)
				}
				finally {
					this.iIsSpeaking := false
				}
			}
			finally {
				if (stopped && !this.Assistant.PushToTalk)
					this.Assistant.startListening()
			}
		}
		
		speakPhrase(phrase, variables := false, focus := false) {
			phrases := this.Phrases
			
			if phrases.HasKey(phrase) {
				phrases := phrases[phrase]
				
				Random index, 1, % phrases.Length()
				
				phrase := substituteVariables(phrases[Round(index)], this.Assistant.getPhraseVariables(variables))
			}
			
			if phrase
				this.speak(phrase, focus)
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
	
	Service[] {
		Get {
			return this.iService
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
			Throw "Virtual property VoiceAssistant.User must be implemented in a subclass..."
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
			OnExit(ObjBindMethod(this, "shutdownVoiceAssistant"))
	}
	
	shutdownVoiceAssistant() {
		if (this.VoiceServer && this.iSpeechSynthesizer) {
			Process Exist
			
			processID := ErrorLevel
				
			raiseEvent(kFileMessage, "Voice", "unregisterVoiceClient:" . values2String(";", this.Name, processID), this.VoiceServer)
		}
		
		return false
	}
	
	initialize(options) {
		if options.HasKey("Language")
			this.iLanguage := options["Language"]
		
		if options.HasKey("Service")
			this.iService := options["Service"]
		
		if options.HasKey("Speaker")
			this.iSpeaker := options["Speaker"]
		
		if options.HasKey("SpeakerVolume")
			this.iSpeakerVolume := options["SpeakerVolume"]
		
		if options.HasKey("SpeakerPitch")
			this.iSpeakerPitch := options["SpeakerPitch"]
		
		if options.HasKey("SpeakerSpeed")
			this.iSpeakerSpeed := options["SpeakerSpeed"]
		
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
																							
				raiseEvent(kFileMessage, "Voice", "registerVoiceClient:" . values2String(";", this.Name, processID
																							, activationCommand, "remoteActivationRecognized", "remoteDeactivationRecognized",
																							, this.Language, this.Service, this.Speaker, this.Listener), this.VoiceServer)
																						
				this.iSpeechSynthesizer := new this.RemoteSpeaker(this, this.Service, this.Speaker, this.Language
																, this.buildFragments(this.Language), this.buildPhrases(this.Language))
			}
			else {
				this.iSpeechSynthesizer := new this.LocalSpeaker(this, this.Service, this.Speaker, this.Language
															   , this.buildFragments(this.Language), this.buildPhrases(this.Language))
			
				this.iSpeechSynthesizer.setVolume(this.iSpeakerVolume)
				this.iSpeechSynthesizer.setPitch(this.iSpeakerPitch)
				this.iSpeechSynthesizer.setRate(this.iSpeakerSpeed)
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
				recognizer := new SpeechRecognizer(this.Listener, this.Language)
				
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
	
	getGrammars(language) {
		Throw "Virtual method VoiceAssistant.getGrammars must be implemented in a subclass..."
	}
	
	buildFragments(language) {
		fragments := {}
		
		grammars := this.getGrammars(language)
		
		for fragment, word in getConfigurationSectionValues(grammars, "Fragments", {})
			fragments[fragment] := word
		
		return fragments
	}
	
	buildPhrases(language) {
		phrases := {}
		
		grammars := this.getGrammars(language)
		
		for key, value in getConfigurationSectionValues(grammars, "Speaker Phrases", {}) {
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
			showMessage("Command phrase recognized: " . values2String(" ", words*))
		
		protectionOn()
		
		try {
			this.handleVoiceCommand(grammar, words)
		}
		finally {
			protectionOff()
		}
	}
	
	recognizeCommand(grammar, words) {
		if this.Grammars.HasKey(grammar)
			if this.VoiceServer
				raiseEvent(kFileMessage, "Voice", "recognizeCommand:" . values2String(";", grammar, words*), this.VoiceServer)
			else
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
		Throw "Virtual method VoiceAssistant.handleVoiceCommand must be implemented in a subclass..."
	}
}