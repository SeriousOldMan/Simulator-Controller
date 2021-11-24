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

global kAzureVoices = {de: [["de-AT", "de-AT-IngridNeural"], ["de-AT", "de-AT-JonasNeural"]
						  , ["de-DE", "de-DE-KatjaNeural"], ["de-DE", "de-DE-ConradNeural"]
						  , ["de-CH", "de-CH-LeniNeural"], ["de-CH", "de-CH-JanNeural"]]
					 , en: [["en-AU", "en-AU-NatashaNeural"], ["en-AU", "en-AU-WilliamNeural"]
						  , ["en-CA", "en-CA-ClaraNeural"], ["en-CA", "en-CA-LiamNeural"]
						  , ["en-HK", "en-HK-YanNeural Neu"], ["en-HK", "en-HK-SamNeural Neu"]
						  , ["en-IN", "en-IN-NeerjaNeural"], ["en-IN", "en-IN-PrabhatNeural"]
						  , ["en-GB", "en-GB-LibbyNeural"], ["en-GB", "en-GB-MiaNeural"], ["en-GB", "en-GB-RyanNeural"]
						  , ["en-US", "en-US-AriaNeural"], ["en-US", "en-US-JennyNeural"], ["en-US", "en-US-GuyNeural"]]}


;;;-------------------------------------------------------------------------;;;
;;;                          Public Class Section                           ;;;
;;;-------------------------------------------------------------------------;;;

class SpeechSynthesizer {
	iService := "Windows"
	iVoices := []
	
	iLanguage := ""
	iLocale := ""
	iVoice := ""
	
	iRate := 0
	iPitch := 0
	iVolume := 100
	
	Service[] {
		Get {
			return this.iService
		}
	}
	
	Voices[language := false] {
		Get {
			if !language
				return this.iVoices
			else {
				voices := []
			
				if (this.Service = "Windows") {
					Loop % this.iSpeechSynthesizer.GetVoices.Count
					{
						voice := this.iSpeechSynthesizer.GetVoices.Item(A_Index - 1)
						lcid := voice.GetAttribute("Language")
						
						if (getLanguageFromLCID(lcid) = language)
							voices.Push(voice.GetAttribute("Name"))
					}
				}
				else if (this.Service = "Azure") {
					for ignore, candidate in this.iVoices {
						name := string2Values("(", candidate)
					
						if (InStr(name[2], language) == 1)
							voices.Push(candidate)
					}
				}
				
				return voices
			}	
		}
	}
	
	Language[] {
		Get {
			return this.iLanguage
		}
	}
	
	Locale[] {
		Get {
			return this.iLocale
		}
	}
	
	Voice[] {
		Get {
			return this.iVoice
		}
	}
	
	__New(service, voice := false, language := false) {
		if (service = "Windows") {
			this.iService := "Windows"
			this.iSpeechSynthesizer := ComObjCreate("SAPI.SpVoice")
			
			Loop % this.iSpeechSynthesizer.GetVoices.Count
				this.Voices.Push(this.iSpeechSynthesizer.GetVoices.Item(A_Index - 1).GetAttribute("Name"))
			
			this.setVoice(language, this.computeVoice(voice, language))
		}
		else if (InStr(service, "Azure|") == 1) {
			this.iService := "Azure"
			
			dllName := "Speech.Synthesizer.dll"
			dllFile := kBinariesDirectory . dllName
			
			try {
				if (!FileExist(dllFile)) {
					logMessage(kLogCritical, translate("Speech.Synthesizer.dll not found in ") . kBinariesDirectory)
					
					Throw "Unable to find Speech.Synthesizer.dll in " . kBinariesDirectory . "..."
				}

				this.iSpeechSynthesizer := CLR_LoadLibrary(dllFile).CreateInstance("Speech.SpeechSynthesizer")
				
				service := string2Values("|", service)
				
				if !this.iSpeechSynthesizer.Connect(service[2], service[3]) {
					logMessage(kLogCritical, translate("Could not communicate with speech synthesizer library (") . dllName . translate(")"))
					logMessage(kLogCritical, translate("Try running the Powershell command ""Get-ChildItem -Path '.' -Recurse | Unblock-File"" in the Binaries folder"))
				
					Throw "Could not communicate with speech synthesizer library (" . dllName . ")..."
				}
			}
			catch exception {
				logMessage(kLogCritical, translate("Error while initializing speech synthesizer module - please install the speech synthesizer software"))
				
				showMessage(translate("Error while initializing speech synthesizer module - please install the speech synthesizer software") . translate("...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
			
			voices := this.iSpeechSynthesizer.GetVoices()
			
			if (voices = "") {
				for languageCode, voiceInfos in kAzureVoices
					for ignore, voiceInfo in voiceInfos
						this.Voices.Push(voiceInfo[2] . " (" . voiceInfo[1] . ")")
			}
			else {
				this.iVoices := string2Values("|", voices)
			}
			
			this.setVoice(language, this.computeVoice(voice, language))
		}
		else
			Throw "Unsupported speech synthesizer service detected in SpeechSynthesizer.__New..."
	}

	speak(text, wait := true) {
		this.stop()

		if kSoX {
			Random postfix, 1, 1000000
			
			postfix := Round(postfix)
	
			temp1Name := kTempDirectory . "temp1_" . postfix . ".wav"
			temp2Name := kTempDirectory . "temp2_" . postfix . ".wav"
			
			this.speakToFile(temp1Name, text)
			
			if !FileExist(temp1Name) {
				if (this.Service = "Windows")
					this.iSpeechSynthesizer.Speak(text, (wait ? 0x0 : 0x1))
				
				return
			}
				
			try {
				RunWait "%kSoX%" "%temp1Name%" "%temp2Name%" rate 16k channels 1 overdrive 20 20 highpass 800 lowpass 1800, , Hide
				RunWait "%kSoX%" -m -v 0.2 "%kResourcesDirectory%Sounds\Noise.wav" "%temp2Name%" "%temp1Name%" channels 1 reverse vad -p 1 reverse, , Hide
				RunWait "%kSoX%" "%kResourcesDirectory%Sounds\Click.wav" "%temp1Name%" "%temp2Name%" norm, , Hide
				
				SoundPlay %temp2Name%, Wait
			}
			catch exception {
				showMessage(substituteVariables(translate("Cannot start SoX (%kSoX%) - please check the configuration..."))
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				
				if (this.Service = "Windows")
					this.iSpeechSynthesizer.Speak(text, (wait ? 0x0 : 0x1))
			}
			finally {
				if FileExist(temp1Name)
					FileDelete %temp1Name%
				
				if FileExist(temp2Name)
					FileDelete %temp2Name%
			}
		}
		else {
			if (this.Service = "Windows")
				this.iSpeechSynthesizer.Speak(text, (wait ? 0x0 : 0x1))
			else if (this.Service = "Azure") {
				Random postfix, 1, 1000000
				
				postfix := Round(postfix)
		
				tempName := kTempDirectory . "temp_" . postfix . ".wav"

				this.SpeakToFile(tempName, text)
				
				if !FileExist(tempName)
					return
				
				if wait {
					SoundPlay %tempName%, WAIT
					
					FileDelete %tempName%
				}
				else
					SoundPlay %tempName%
			}
		}
	}

	speakToFile(fileName, text) {
		this.stop()
		
		if (this.Service = "Windows") {
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
		else if (this.Service = "Azure") {
			ssml := "<speak version=""1.0"" xmlns=""http://www.w3.org/2001/10/synthesis"" xml:lang=""%language%"">"
		    ssml .= " <voice name=""%voice%"">"
			ssml .= "  <prosody pitch=""%pitch%"" rate=""%rate%"" volume=""%volume%"">"
			ssml .= "  %text%"
			ssml .= "  </prosody>"
			ssml .= " </voice>"
			ssml .= "</speak>"
			
			ssml := substituteVariables(ssml, {volume: this.iVolume, pitch: ((this.iPitch > 0) ? "+" : "-") . Abs(this.iPitch) . "st", rate: 1 + (0.05 * this.iRate)
									  , language: this.Locale, voice: this.Voice, text: text})
			
			try {
				if !this.iSpeechSynthesizer.SpeakSsmlToFile(fileName, ssml)
					Throw "Error while speech synthesizing..."
			}
			catch exception {
				new SpeechSynthesizer("Windows", true, true).speak("Error while calling Azure Cognitive Services. Maybe your monthly contingent is exhausted.")
			}
		}
	}
	
	pause() {
		if (this.Service = "Windows") {
			status := this.iSpeechSynthesizer.Status.RunningState
			
			if (status = 0)
				this.iSpeechSynthesizer.Resume
			else if (status = 2)
				this.iSpeechSynthesizer.Pause
		}
	}
	
	stop() {
		if (this.Service = "Windows") {
			status := this.iSpeechSynthesizer.Status.RunningState
			
			if (status = 0)
				this.iSpeechSynthesizer.Resume
			
			this.iSpeechSynthesizer.Speak("", 0x1 | 0x2)
		}
		else if (this.Service = "Azure") {
			try {
				SoundPlay NonExistent.avi
			}
			catch exception {
				; Ignore
			}
		}
	}
	
	setRate(rate) {
		this.iRate := rate
		
		if (this.Service = "Windows")
			this.iSpeechSynthesizer.Rate := rate
	}
	
	setVolume(volume) {
		this.iVolume := volume
		
		if (this.Service = "Windows")
			this.iSpeechSynthesizer.Volume := volume
	}
	
	setPitch(pitch) {
		this.iPitch := pitch
		
		if (this.Service = "Windows")
			this.iSpeechSynthesizer.Speak("<pitch absmiddle = '" pitch "'/>", 0x20)
	}

	computeVoice(voice, language, randomize := true) {
		voices := this.Voices
	
		if (this.Service = "Windows") {
			if ((voice == true) && language) {
				availableVoices := this.Voices[language]
				
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
			else
				voices := this.Voices
		}
		else if (this.Service = "Azure") {
			if ((voice == true) && language) {
				availableVoices := []
				
				for ignore, candidate in voices {
					voice := string2Values("(", candidate)
					locale := StrReplace(voice[2], ")", "")
					
					if (InStr(locale, language) == 1)
						availableVoices.Push(candidate)
				}
				
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
		}
			
		if (voice && (voice != true))
			voice := inList(voices, voice)
		
		if !voice
			voice := 1
			
		return voices[voice]
	}
	
	setVoice(language, name) {
		if (this.Service = "Windows") {
			if !inList(this.Voices, name)
				return false
			
			while !(this.iSpeechSynthesizer.Status.RunningState = 1)
				Sleep 200
			
			this.iSpeechSynthesizer.Voice := this.iSpeechSynthesizer.GetVoices("Name=" . name).Item(0)
			this.iLanguage := language
			this.iVoice := name
		}
		else if (this.Service = "Azure") {
			name := string2Values("(", name)
		
			this.iLanguage := language
			this.iVoice := name[1]
			this.iLocale := StrReplace(name[2], ")", "")
		}
			
		return true
	}
}