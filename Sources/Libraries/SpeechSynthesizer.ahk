;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Speech Synthesizer              ;;;
;;;                                                                         ;;;
;;;   Part of this code is based on work of evilC and Learning one.         ;;;
;;;   See www.autohotkey.com/forum/topic57773.html and                      ;;;
;;;   https://www.autohotkey.com/boards/viewtopic.php?t=71363 and also      ;;;
;;;   http://msdn.microsoft.com/en-us/library/ms717077(v=vs.85).aspx        ;;;
;;;   for more information about the technical details.                     ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\CLR.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kLanguageVoices = {de: ["Microsoft Hedda Desktop", "Microsoft Katja Desktop", "Microsoft Stefan Desktop"]
						, en: ["Microsoft David Desktop", "Microsoft Mark Desktop", "Microsoft Zira Desktop"]
						, fr: ["Microsoft Hortence Desktop", "Microsoft Julie Desktop", "Microsoft Paul Desktop"]}


;;;-------------------------------------------------------------------------;;;
;;;                          Public Class Section                           ;;;
;;;-------------------------------------------------------------------------;;;

class SpeechSynthesizer {
	iService := "Windows"
	iVoices := []
	iActiveVoice := ""
	
	Service[] {
		Get {
			return this.iService
		}
	}
	
	Voices[] {
		Get {
			return this.iVoices
		}
	}
	
	ActiveVoice[] {
		Get {
			return this.iActiveVoice
		}
	}
	
	__New(service, voice := false, language := false) {
		if (service = "Windows") {
			this.iSpeechSynthesizer := ComObjCreate("SAPI.SpVoice")
			
			Loop, % this.iSpeechSynthesizer.GetVoices.Count
				this.Voices.Push(this.iSpeechSynthesizer.GetVoices.Item(A_Index-1).GetAttribute("Name"))
			
			this.setVoice(this.computeVoice(voice, language))
		}
		else if (InStr(service, "Azure|") == 1) {
			dllName := "Speech.Synthesizer.dll"
			dllFile := kBinariesDirectory . dllName
			
			try {
				if (!FileExist(dllFile)) {
					logMessage(kLogCritical, translate("Speech.Synthesizer.dll not found in " . kBinariesDirectory))
					
					Throw "Unable to find Speech.Synthesizer.dll in " . kBinariesDirectory . "..."
				}

				this.iSpeechSynthesizer := CLR_LoadLibrary(dllFile).CreateInstance("CSSpeech.SpeechSynthesizer")
				
				service := string2Values("|", service)
				
				if !this.iSpeechSynthesizer.Connect(service[2], service[3])
					MsgBox Oops
				
				msgbox % this.iSpeechSynthesizer.GetAccessToken()
			}
			catch exception {
				logMessage(kLogCritical, translate("Error while initializing speech synthesizer module - please install the speech synthesizer software"))
				
				showMessage(translate("Error while initializing speech synthesizer module - please install the speech synthesizer software") . translate("...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}
	}

	speak(text, wait := true) {
		this.stop()

		if kSoX {
			Random postfix, 1, 1000000
			
			postfix := Round(postfix)
	
			temp1Name := kTempDirectory . "temp1_" . postfix . ".wav"
			temp2Name := kTempDirectory . "temp2_" . postfix . ".wav"
			
			this.speakToFile(temp1Name, text)
			
			try {
				RunWait "%kSoX%" "%temp1Name%" "%temp2Name%" rate 16k channels 1 overdrive 20 20 highpass 800 lowpass 1800, , Hide
				RunWait "%kSoX%" -m -v 0.2 "%kResourcesDirectory%Sounds\Noise.wav" "%temp2Name%" "%temp1Name%" channels 1 reverse vad -p 1 reverse, , Hide
				RunWait "%kSoX%" "%kResourcesDirectory%Sounds\Click.wav" "%temp1Name%" "%temp2Name%" norm, , Hide
				
				SoundPlay %temp2Name%, Wait
			}
			catch exception {
				showMessage(substituteVariables(translate("Cannot start SoX (%kSoX%) - please check the configuration..."))
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
					  
				this.iSpeechSynthesizer.Speak(text, (wait ? 0x0 : 0x1))
			}
			finally {
				if FileExist(temp1Name)
					FileDelete %temp1Name%
				
				if FileExist(temp2Name)
					FileDelete %temp2Name%
			}
		}
		else
			this.iSpeechSynthesizer.Speak(text, (wait ? 0x0 : 0x1))
	}

	speakToFile(fileName, text) {
		this.stop()
		
		oldStream := this.iSpeechSynthesizer.AudioOutputStream
		
		stream := ComObjCreate("Sapi.SpFileStream")
		
		try {
			stream.Open(fileName, 0x3, 0)
		
			this.iSpeechSynthesizer.AudioOutputStream := stream
		
			this.iSpeechSynthesizer.Speak(text, 0x0)
		}
		finally {
			stream.Close()
			
			this.iSpeechSynthesizer.AudioOutputStream := oldStream
		}
	}
	
		
	
	pause() {
		status := this.iSpeechSynthesizer.Status.RunningState
		
		if (status = 0)
			this.iSpeechSynthesizer.Resume
		else if (status = 2)
			this.iSpeechSynthesizer.Pause
	}
	
	stop() {
		status := this.iSpeechSynthesizer.Status.RunningState
		
		if (status = 0)
			this.iSpeechSynthesizer.Resume
		
		this.iSpeechSynthesizer.Speak("", 0x1 | 0x2)
	}
	
	setRate(rate) {
		this.iSpeechSynthesizer.Rate := rate
	}
	
	setVolume(volume) {
		this.iSpeechSynthesizer.Volume := volume
	}
	
	setPitch(pitch) {
		this.iSpeechSynthesizer.Speak("<pitch absmiddle = '" pitch "'/>", 0x20)
	}

	computeVoice(voice, language, randomize := true) {
		voices := this.Voices
	
		if ((voice == true) && language && kLanguageVoices.HasKey(language)) {
			availableVoices := []
			
			for ignore, candidate in kLanguageVoices[language]
				if inList(voices, candidate)
					availableVoices.Push(candidate)
			
			count := availableVoices.Length()
			
			if (count == 0)
				voice := false
			else if randomize {
				Random index, 1, count
			
				voice := availableVoices[Round(index)]
			}
			else
				voice := availableVoices[1]
		}
		
		if (voice && (voice != true))
			voice := inList(voices, voice)
		
		if !voice
			voice := 1
		
		return voices[voice]
	}
	
	setVoice(name) {
		if !inList(this.Voices, name)
			return false
		
		while !(this.iSpeechSynthesizer.Status.RunningState = 1)
			Sleep 200
		
		this.iSpeechSynthesizer.Voice := this.iSpeechSynthesizer.GetVoices("Name=" . name).Item(0) 
		this.iActiveVoice := name
		
		return true
	}
}