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
	iSpeechGenerator := false
	
	iSpeechRecognizer := false
	iIsListening := false
	
	iVoiceCommands := {}
	
	SpeechGenerator[create := false] {
		Get {
			if (create && !this.iSpeechGenerator)
				this.iSpeechGenerator := new SpeechGenerator(true, getLanguage())
			
			return this.iSpeechGenerator
		}
	}
	
	SpeechRecognizer[create := false] {
		Get {
			if (create && !this.iSpeechRecognizer) {
				this.iSpeechRecognizer := new SpeechRecognizer(true, getLanguage())
				
				this.startListening()
			}
			
			return this.iSpeechRecognizer
		}
	}
	
	__New(configuration := false) {
		base.__New(configuration)
		
		VoiceServer.Instance := this
	}
	
	speak(text) {
		stopped := this.stopListening()
			
		try {
			this.SpeechGenerator[true].speak(text, true)
		}
		finally {
			if stopped
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
		
		if this.SpeechRecognizer && !this.iIsListening
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
		
		if this.SpeechRecognizer && this.iIsListening
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

		if !grammar
			grammar := ("__Grammar." . counter++)
			
		if this.iVoiceCommands.HasKey(grammar) {
			descriptor := this.iVoiceCommands[grammar]
			
			if ((descriptor[1] = command) && (descriptor[3] = callback)) {
				descriptor[2] := pid
				
				return
			}
		}
			
		if isDebug() {
			nextCharIndex := 1
			SplashTextOn 400, 100, , % "Register voice command: " . new GrammarCompiler(recognizer).readGrammar(command, nextCharIndex).toString()
			Sleep 1000
			SplashTextOff
		}
		
		try {
			recognizer.loadGrammar(grammar, recognizer.compileGrammar(command), ObjBindMethod(this, "voiceCommandRecognized"))
		}
		catch exception {
			logMessage(kLogCritical, translate("Error while registering voice command """) . command . translate(""" - please check the configuration"))
		
			title := translate("Modular Simulator Controller System")
			
			SplashTextOn 800, 60, %title%, % substituteVariables(translate("Cannot register voice command ""%command%"" - please check the configuration..."), {command: command})
					
			Sleep 5000
						
			SplashTextOff
		}
		
		this.iVoiceCommands[grammar] := Array(command, pid, callback)
	}
	
	voiceCommandRecognized(grammar, words) {
		if isDebug() {
			SplashTextOn 400, 100, , % "Voice command recognized: " . values2String(" ", words*)
			Sleep 1000
			SplashTextOff
		}
		
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