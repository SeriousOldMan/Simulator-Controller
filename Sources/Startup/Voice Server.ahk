;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Voice Server                    ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#SingleInstance Force			; Ony one instance allowed
#NoEnv							; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn							; Enable warnings to assist with detecting common errors.
#Warn LocalSameAsGlobal, Off

SendMode Input					; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.

SetBatchLines -1				; Maximize CPU utilization
ListLines Off					; Disable execution history

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Microphon.ico
;@Ahk2Exe-ExeName Voice Server.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\SpeechGenerator.ahk
#Include ..\Libraries\SpeechRecognizer.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class VoiceServer extends ConfigurationItem {
	iVoiceClients := {}
	iActiveVoiceClient := false
	
	class VoiceClient {
		iCounter := 1
		
		iVoiceServer := false
		iDescriptor := false
		iPID := 0
		
		iLanguage := "en"
		iSpeaker := true
		iSpeakerVolume := 100
		iSpeakerPitch := 0
		iSpeakerSpeed := 0
		iListener := false
		iPushToTalk := false
	
		iSpeechGenerator := false
		
		iSpeechRecognizer := false
		iIsSpeaking := false
		iIsListening := false
		
		iActivationCallback := false
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
		
		ActivationCallback[] {
			Get {
				return this.iActivationCallback
			}
		}
		
		VoiceCommands[] {
			Get {
				return this.iVoiceCommands
			}
		}
	
		SpeechGenerator[create := false] {
			Get {
				if (create && this.Speaker && !this.iSpeechGenerator) {
					this.iSpeechGenerator := new SpeechGenerator(this.Speaker, this.Language)
					
					this.iSpeechGenerator.setVolume(this.iSpeakerVolume)
					this.iSpeechGenerator.setPitch(this.iSpeakerPitch)
					this.iSpeechGenerator.setRate(this.iSpeakerSpeed)
				}
				
				return this.iSpeechGenerator
			}
		}
		
		SpeechRecognizer[create := false] {
			Get {
				if (create && this.Listener && !this.iSpeechRecognizer)
					this.iSpeechRecognizer := new SpeechRecognizer(this.Listener, this.Language)
				
				return this.iSpeechRecognizer
			}
		}
		
		__New(voiceServer, descriptor, pid, language, speaker, listener, pushToTalk, speakerVolume, speakerPitch, speakerSpeed, activationCallback) {
			this.iVoiceServer := voiceServer
			this.iDescriptor := descriptor
			this.iPID := pid
			this.iLanguage := language
			this.iSpeaker := speaker
			this.iListener := listener
			this.iPushToTalk := pushToTalk
			this.iSpeakerVolume := speakerVolume
			this.iSpeakerPitch := speakerPitch
			this.iSpeakerSpeed := speakerSpeed
			this.iActivationCallback := activationCallback
		}
	
		speak(text) {
			stopped := this.VoiceServer.stopListening()
			oldSpeaking := this.Speaking
			
			this.iIsSpeaking := true
				
			try {
				try {
					this.SpeechGenerator[true].speak(text, true)
				}
				finally {
					this.iIsSpeaking := oldSpeaking
				}
			}
			finally {
				if (stopped && !this.PushToTalk)
					this.VoiceServer.startListening()
			}
		}
	
		startListening(retry := true) {
			local function
			
			if (this.SpeechRecognizer && !this.Listening)
				if !this.SpeechRecognizer.startRecognizer() {
					if retry {
						function := ObjBindMethod(this, "startListening", true)
						
						SetTimer %function%, -200
					}
					
					return false
				}
				else {
					this.iIsListening := true
				
					return true
				}
		}
		
		stopListening(retry := false) {
			local function
			
			if (this.SpeechRecognizer && this.Listening)
				if !this.SpeechRecognizer.stopRecognizer() {
					if retry {
						function := ObjBindMethod(this, "stopListening", true)
						
						SetTimer %function%, -200
					}
					
					return false
				}
				else {
					this.iIsListening := false
				
					return true
				}
		}
		
		registerChoices(name, choices*) {
			recognizer := this.SpeechRecognizer[true]
			
			recognizer.setChoices(name, values2String(",", choices*))
		}
	
		registerVoiceCommand(grammar, command, callback) {
			recognizer := this.SpeechRecognizer[true]

			if !grammar {
				for key, descriptor in this.iVoiceCommands
					if ((descriptor[1] = command) && (descriptor[2] = callback))
						return
					
				grammar := ("__Grammar." . this.iCounter++)
			}
			else if this.iVoiceCommands.HasKey(grammar) {
				descriptor := this.iVoiceCommands[grammar]
				
				if ((descriptor[1] = command) && (descriptor[2] = callback))
					return
			}
				
			if isDebug() {
				nextCharIndex := 1
				
				showMessage("Register voice command: " . new GrammarCompiler(recognizer).readGrammar(command, nextCharIndex).toString())					  
			}
			
			try {
				recognizer.loadGrammar(grammar, recognizer.compileGrammar(command), ObjBindMethod(this, "voiceCommandRecognized"))
			}
			catch exception {
				logMessage(kLogCritical, translate("Error while registering voice command """) . command . translate(""" - please check the configuration"))
			
				showMessage(substituteVariables(translate("Cannot register voice command ""%command%"" - please check the configuration..."), {command: command})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
			
			this.VoiceCommands[grammar] := Array(command, callback)
		}
		
		activate(words) {
			if (this.ActivationCallback)
				raiseEvent(kFileMessage, "Voice", this.ActivationCallback . ":" . values2String(";", words*), this.PID)
		}
		
		voiceCommandRecognized(grammar, words) {
			if isDebug()
				showMessage("Voice command recognized: " . values2String(" ", words*))
			
			descriptor := this.iVoiceCommands[grammar]
			
			raiseEvent(kFileMessage, "Voice", descriptor[2] . ":" . values2String(";", grammar, descriptor[1], words*), this.PID)
		}
	}

	iLanguage := "en"
	iSpeaker := true
	iSpeakerVolume := 100
	iSpeakerPitch := 0
	iSpeakerSpeed := 0
	iListener := false
	iPushToTalk := false
	
	iSpeechRecognizer := false
	
	iIsSpeaking := false
	iIsListening := false
	
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
	
	PushToTalk[] {
		Get {
			return this.iPushToTalk
		}
	}
		
	SpeechRecognizer[create := false] {
		Get {
			if (create && this.Listener && !this.iSpeechRecognizer) {
				this.iSpeechRecognizer := new SpeechRecognizer(this.Listener, this.Language)
				
				if !this.PushToTalk
					this.startListening()
			}
			
			return this.iSpeechRecognizer
		}
	}
	
	__New(configuration := false) {
		base.__New(configuration)
		
		VoiceServer.Instance := this
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		this.iLanguage := getConfigurationValue(configuration, "Voice Control", "Language", getLanguage())
		this.iSpeaker := getConfigurationValue(configuration, "Voice Control", "Speaker", true)
		this.iSpeakerVolume := getConfigurationValue(configuration, "Voice Control", "SpeakerVolume", 100)
		this.iSpeakerPitch := getConfigurationValue(configuration, "Voice Control", "SpeakerPitch", 0)
		this.iSpeakerSpeed := getConfigurationValue(configuration, "Voice Control", "SpeakerSpeed", 0)
		this.iListener := getConfigurationValue(configuration, "Voice Control", "Listener", false)
		this.iPushToTalk := getConfigurationValue(configuration, "Voice Control", "PushToTalk", false)
		
		if this.PushToTalk {
			listen := ObjBindMethod(this, "listen")
			
			SetTimer %listen%, 100
		}
	}
	
	listen() {
		theHotkey := this.PushToTalk
		
		if !this.Speaking && GetKeyState(theHotKey, "P")
			this.startListening()
		else if !GetKeyState(theHotKey, "P")
			this.stopListening()
	}
	
	getVoiceClient(descriptor := false) {
		if descriptor
			return this.VoiceClients[descriptor]
		else
			return this.ActiveVoiceClient
	}
	
	activateVoiceClient(descriptor, words := false) {
		if (this.ActiveVoiceClient && this.PushToTalk && this.ActiveVoiceClient.Listening)
			this.ActiveVoiceClient.stoplistening()
		
		activeVoiceClient := this.VoiceClients[descriptor]
		
		this.iActiveVoiceClient := activeVoiceClient
		
		activeVoiceClient.activate(words ? words : [])
		
		if !this.PushToTalk
			this.startListening()
	}
	
	startActivationListener(retry := false) {
		local function
			
		if (this.SpeechRecognizer && !this.Listening)
			if !this.SpeechRecognizer.startRecognizer() {
				if retry {
					function := ObjBindMethod(this, "startActivationListener", true)
					
					SetTimer %function%, -200
				}
				
				return false
			}
			else {
				this.iIsListening := true
			
				return true
			}
	}
		
	stopActivationListener(retry := false) {
		local function
		
		if (this.SpeechRecognizer && this.Listening)
			if !this.SpeechRecognizer.stopRecognizer() {
				if retry {
					function := ObjBindMethod(this, "stopActivationListener", true)
					
					SetTimer %function%, -200
				}
				
				return false
			}
			else {
				this.iIsListening := false
			
				return true
			}
	}
	
	startListening(retry := true) {
		this.startActivationListener(retry)
		
		activeClient := this.getVoiceClient()
		
		return (activeClient ? activeClient.startListening(retry) : false)
	}
	
	stopListening(retry := false) {
		this.stopActivationListener(retry)
		
		activeClient := this.getVoiceClient()
		
		return (activeClient ? activeClient.stopListening(retry) : false)
	}
	
	speak(descriptor, text, activate := false) {
		oldSpeaking := this.Speaking
		
		this.iIsSpeaking := true
		
		try {
			this.getVoiceClient(descriptor).speak(text)
			
			if activate
				this.activateVoiceClient(descriptor)
		}
		finally {
			this.iIsSpeaking := oldSpeaking
		}
	}
	
	registerVoiceClient(descriptor, pid, activationCommand := false, activationCallback := false, language := false, speaker := true, listener := false, pushToTalk := false, speakerVolume := "__Undefined__", speakerPitch := "__Undefined__", speakerSpeed := "__Undefined__") {
		static counter := 1
		
		if (speakerVolume = kUndefined)
			speakerVolume := this.iSpeakerVolume
		
		if (speakerPitch = kUndefined)
			speakerPitch := this.iSpeakerPitch
		
		if (speakerSpeed = kUndefined)
			speakerSpeed := this.iSpeakerSpeed
		
		if !pushToTalk
			pushToTalk := this.iPushToTalk
		
		if (speaker == true)
			speaker := this.iSpeaker
		
		if (listener == true)
			listener := this.iListener
		
		if (language == false)
			language := this.iLanguage
		
		client := new VoiceClient(this, descriptor, pid, language, speaker, listener, pushToTalk, speakerVolume, speakerPitch, speakerSpeed, activationCallback)
		
		this.VoiceClients[descriptor] := client
		this.VoiceClients[pid] := client
		
		if activationCommand {
			recognizer := this.SpeechRecognizer[true]
			grammar := (descriptor . "." . counter++)
			
			if isDebug() {
				nextCharIndex := 1
				
				showMessage("Register activation command: " . new GrammarCompiler(recognizer).readGrammar(activationCommand, nextCharIndex).toString())					  
			}
				
			try {
				recognizer.loadGrammar(grammar, recognizer.compileGrammar(activationCommand), ObjBindMethod(this, "activationCommandRecognized"))
			}
			catch exception {
				logMessage(kLogCritical, translate("Error while registering voice command """) . command . translate(""" - please check the configuration"))
			
				showMessage(substituteVariables(translate("Cannot register voice command ""%command%"" - please check the configuration..."), {command: command})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}
	}
	
	registerChoices(descriptor, name, choices*) {
		this.getVoiceClient(descriptor).registerChoices(name, choices*)
	}
	
	registerVoiceCommand(descriptor, grammar, command, callback) {
		this.getVoiceClient(descriptor).registerVoiceCommand(grammar, command, callback)
	}
		
	activationCommandRecognized(grammar, words) {
		if isDebug()
			showMessage("Activation command recognized: " . values2String(" ", words*))
		
		this.activateVoiceClient(ConfigurationItem.splitDescriptor(grammar)[1], words)
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeVoiceServer() {
	icon := kIconsDirectory . "Microphon.ico"
	
	Menu Tray, Icon, %icon%, , 1
	
	new VoiceServer(kSimulatorConfiguration)
	
	registerEventHandler("Voice", "handleVoiceRemoteCalls")
}


;;;-------------------------------------------------------------------------;;;
;;;                          Event Handler Section                          ;;;
;;;-------------------------------------------------------------------------;;;

handleVoiceRemoteCalls(event, data) {
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

initializeVoiceServer()