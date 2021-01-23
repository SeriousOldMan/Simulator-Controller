;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Speach Generator                ;;;
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

#Include ..\Includes\Constants.ahk
#Include ..\Includes\Variables.ahk
#Include ..\Includes\Functions.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Class Section                           ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    SpeechGenerator                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SpeechGenerator {
	iVoices := []
	iActiveVoice := ""
	
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
	
	__New(voice := false) {
		this.iSpeechGenerator := ComObjCreate("SAPI.SpVoice")
		
		Loop, % this.iSpeechGenerator.GetVoices.Count
			this.Voices.Push(this.iSpeechGenerator.GetVoices.Item(A_Index-1).GetAttribute("Name"))
	
		if !voice {
			voices := this.Voices
			
			voice := voices[1]
		}
		
		this.setVoice(voice)
	}

	speak(text, wait := false) {
		this.stop()
		
		this.iSpeechGenerator.Speak(text, (wait ? 0x0 : 0x1))
	}
	
	pause() {
		status := this.iSpeechGenerator.Status.RunningState
		
		if (status = 0)
			this.iSpeechGenerator.Resume
		else if (status = 2)
			this.iSpeechGenerator.Pause
	}
	
	stop() {
		status := this.iSpeechGenerator.Status.RunningState
		
		if (status = 0)
			this.iSpeechGenerator.Resume
		
		this.iSpeechGenerator.Speak("",0x1 | 0x2)
	}
	
	setRate(rate) {
		this.iSpeechGenerator.Rate := rate
	}
	
	setVolume(volume) {
		this.iSpeechGenerator.Volume := volume
	}
	
	setPitch(pitch) {
		this.iSpeechGenerator.Speak("<pitch absmiddle = '" pitch "'/>", 0x20)
	}

	setVoice(name) {
		if !inList(this.Voices, name)
			return false
		
		while !(this.iSpeechGenerator.Status.RunningState = 1)
			Sleep 200
		
		this.iSpeechGenerator.Voice := this.iSpeechGenerator.GetVoices("Name=" . name).Item(0) 
		this.iActiveVoice := name
		
		return true
	}
}