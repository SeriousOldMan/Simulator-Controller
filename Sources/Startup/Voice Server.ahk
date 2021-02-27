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
	iLanguage := "en"
	iSpeaker := true
	iListener := false
	iPushTalk := false
	
	iSpeechGenerator := false
	
	iSpeechRecognizer := false
	iIsSpeaking := false
	iIsListening := false
	
	iVoiceCommands := {}
	
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
	
	PushTalk[] {
		Get {
			return this.iPushTalk
		}
	}
	
	SpeechGenerator[create := false] {
		Get {
			if (create && this.Speaker && !this.iSpeechGenerator)
				this.iSpeechGenerator := new SpeechGenerator(this.Speaker, this.Language)
			
			return this.iSpeechGenerator
		}
	}
	
	SpeechRecognizer[create := false] {
		Get {
			if (create && this.Listener && !this.iSpeechRecognizer) {
				this.iSpeechRecognizer := new SpeechRecognizer(this.Listener, this.Language)
				
				if !this.PushTalk
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
		this.iListener := getConfigurationValue(configuration, "Voice Control", "Listener", false)
		this.iPushTalk := getConfigurationValue(configuration, "Voice Control", "PushToTalk", false)
		
		if this.PushTalk {
			pushToTalk := ObjBindMethod(this, "pushToTalk")
			
			SetTimer %pushToTalk%, 100
		}
	}
	
	pushToTalk() {
		theHotkey := this.PushTalk
		
		if !this.Speaking && GetKeyState(theHotKey, "P")
			this.startListening()
		else if !GetKeyState(theHotKey, "P")
			this.stopListening()
	}
	
	speak(text) {
		stopped := this.stopListening()
			
		try {
			this.iIsSpeaking := true
			
			try {
				this.SpeechGenerator[true].speak(text, true)
			}
			finally {
				this.iIsSpeaking := false
			}
		}
		finally {
			if (stopped && !this.PushTalk)
				this.startListening()
		}
	}
	
	speakWith(speaker, language, text) {
		generator := this.SpeechGenerator[true]
		currentVoice := generator.ActiveVoice
		
		generator.setVoice(generator.computeVoice(speaker, language, false))
		
		try {
			this.speak(text)
		}
		finally {
			generator.setVoice(currentVoice)
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
	
	registerVoiceCommand(grammar, command, pid, callback) {
		static counter := 1
		
		recognizer := this.SpeechRecognizer[true]

		if !grammar {
			for key, descriptor in this.iVoiceCommands
				if ((descriptor[1] = command) && (descriptor[3] = callback)) {
					descriptor[2] := pid
					
					return
				}
				
			grammar := ("__Grammar." . counter++)
		}
		else if this.iVoiceCommands.HasKey(grammar) {
			descriptor := this.iVoiceCommands[grammar]
			
			if ((descriptor[1] = command) && (descriptor[3] = callback)) {
				descriptor[2] := pid
				
				return
			}
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
		
		this.iVoiceCommands[grammar] := Array(command, pid, callback)
	}
	
	voiceCommandRecognized(grammar, words) {
		if isDebug()
			showMessage("Voice command recognized: " . values2String(" ", words*))
		
		descriptor := this.iVoiceCommands[grammar]
		
		raiseEvent(kFileMessage, "Voice", descriptor[3] . ":" . values2String(";", grammar, descriptor[1], words*), descriptor[2])
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