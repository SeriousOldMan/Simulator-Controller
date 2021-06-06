;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Voice Control Configuration     ;;;
;;;                                         Plugin                          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; VoiceControlConfigurator                                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global voiceLanguageDropDown
global speakerDropDown
global speakerVolumeSlider
global speakerPitchSlider
global speakerSpeedSlider
global listenerDropDown
global pushToTalkEdit = ""
global activationCommandEdit = ""

class VoiceControlConfigurator extends ConfigurationItem {
	__New(configuration) {
		base.__New(configuration)
		
		VoiceControlConfigurator.Instance := this
	}
	
	createGui(editor, x, y, width, height) {
		window := editor.Window
		
		Gui %window%:Font, Norm, Arial
		
		choices := []
		chosen := 0
		enIndex := 0
		
		languages := availableLanguages()
		
		for code, language in languages {
			choices.Push(language)
			
			if (language == voiceLanguageDropDown)
				chosen := A_Index
				
			if (code = "en")
				enIndex := A_Index
		}
			
		for ignore, grammarFile in getFileNames("Race Engineer.grammars.*", kUserGrammarsDirectory, kGrammarsDirectory) {
			SplitPath grammarFile, , , languageCode
		
			if !languages.HasKey(languageCode) {
				choices.Push(languageCode)
				
				if (languageCode == voiceLanguageDropDown)
					chosen := choices.Length()
					
				if (languageCode = "en")
					enIndex := choices.Length()
			}
		}
		
		if (chosen == 0)
			chosen := enIndex
			
		Gui %window%:Add, Text, x16 y80 w110 h23 +0x200, % translate("Language")
		Gui %window%:Add, DropDownList, x134 y80 w135 Choose%chosen% VvoiceLanguageDropDown, % values2String("|", choices*)
		
		voices := new SpeechGenerator().Voices.Clone()
		
		voices.InsertAt(1, translate("Deactivated"))
		voices.InsertAt(1, translate("Automatic"))
		
		chosen := inList(voices, speakerDropDown)
		
		if (chosen == 0)
			chosen := 1
		
		Gui %window%:Add, Text, x16 y112 w110 h23 +0x200, % translate("Speech Generator")
		Gui %window%:Add, DropDownList, x134 y112 w340 Choose%chosen% VspeakerDropDown, % values2String("|", voices*)
		
		Gui %window%:Add, Text, x16 y136 w110 h23 +0x200, % translate("Volume")
		Gui %window%:Add, Slider, x134 y136 w135 Range0-100 ToolTip VspeakerVolumeSlider, % speakerVolumeSlider
		
		Gui %window%:Add, Text, x16 y160 w110 h23 +0x200, % translate("Pitch")
		Gui %window%:Add, Slider, x134 y160 w135 Range-10-10 ToolTip VspeakerPitchSlider, % speakerPitchSlider
		
		Gui %window%:Add, Text, x16 y184 w110 h23 +0x200, % translate("Speed")
		Gui %window%:Add, Slider, x134 y184 w135 Range-10-10 ToolTip VspeakerSpeedSlider, % speakerSpeedSlider
		
		recognizers := new SpeechRecognizer().getRecognizerList().Clone()
		
		Loop % recognizers.Length()
			recognizers[A_Index] := recognizers[A_Index].Name
		
		recognizers.InsertAt(1, translate("Deactivated"))
		recognizers.InsertAt(1, translate("Automatic"))
		
		chosen := inList(recognizers, listenerDropDown)
		
		if (chosen == 0)
			chosen := 1
		
		Gui %window%:Add, Text, x16 y216 w110 h23 +0x200, % translate("Speech Recognizer")
		Gui %window%:Add, DropDownList, x134 y216 w340 Choose%chosen% VlistenerDropDown, % values2String("|", recognizers*)
		
		Gui %window%:Add, Text, x16 y240 w110 h23 +0x200, % translate("Push To Talk")
		Gui %window%:Add, Edit, x134 y240 w110 h21 VpushToTalkEdit, %pushToTalkEdit%
		Gui %window%:Add, Button, x246 y239 w23 h23 ggetPTTHotkey HwnddetectPTTButtonHandle
		setButtonIcon(detectPTTButtonHandle, kIconsDirectory . "Key.ico", 1)
		
		Gui %window%:Add, Text, x16 y264 w110 h23 +0x200, % translate("Activation Command")
		Gui %window%:Add, Edit, x134 y264 w135 h21 VactivationCommandEdit, %activationCommandEdit%
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		languageCode := getConfigurationValue(configuration, "Voice Control", "Language", getLanguage())
		languages := availableLanguages()
		
		if languages.HasKey(languageCode)
			voiceLanguageDropDown := languages[languageCode]
		else
			voiceLanguageDropDown := languageCode
		
		speakerDropDown := getConfigurationValue(configuration, "Voice Control", "Speaker", true)
		speakerVolumeSlider := getConfigurationValue(configuration, "Voice Control", "SpeakerVolume", 100)
		speakerPitchSlider := getConfigurationValue(configuration, "Voice Control", "SpeakerPitch", 0)
		speakerSpeedSlider := getConfigurationValue(configuration, "Voice Control", "SpeakerSpeed", 0)
		
		listenerDropDown := getConfigurationValue(configuration, "Voice Control", "Listener", false)
		pushToTalkEdit := getConfigurationValue(configuration, "Voice Control", "PushToTalk", false)
		activationCommandEdit := getConfigurationValue(configuration, "Voice Control", "ActivationCommand", false)
		
		if (pushToTalkEdit = false)
			pushToTalkEdit := ""
		
		if (activationCommandEdit = false)
			activationCommandEdit := ""
		
		if (speakerDropDown == true)
			speakerDropDown := translate("Automatic")
		else if (speakerDropDown == false)
			speakerDropDown := translate("Deactivated")
		
		if (listenerDropDown == true)
			listenerDropDown := translate("Automatic")
		else if (listenerDropDown == false)
			listenerDropDown := translate("Deactivated")
	}
	
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		GuiControlGet voiceLanguageDropDown
		GuiControlGet speakerDropDown
		GuiControlGet speakerVolumeSlider
		GuiControlGet speakerPitchSlider
		GuiControlGet speakerSpeedSlider
		GuiControlGet listenerDropDown
		GuiControlGet pushToTalkEdit
		GuiControlGet activationCommandEdit
		
		languageCode := "en"
		languages := availableLanguages()
		
		found := false

		for code, language in availableLanguages()
			if (language = voiceLanguageDropDown) {
				found := true
				
				languageCode := code
			}
			
		if !found
			for ignore, grammarFile in getFileNames("Race Engineer.grammars.*", kUserGrammarsDirectory, kGrammarsDirectory) {
				SplitPath grammarFile, , , grammarLanguageCode
			
				if languages.HasKey(grammarLanguageCode)
					language := languages[grammarLanguageCode]
				else
					language := grammarLanguageCode
				
				if (language = voiceLanguageDropDown) {
					languageCode := grammarLanguageCode
					
					break
				}
			}
		
		if (speakerDropDown = translate("Automatic"))
			speakerDropDown := true
		else if ((speakerDropDown = translate("Deactivated")) || (speakerDropDown = " "))
			speakerDropDown := false
		
		if (listenerDropDown = translate("Automatic"))
			listenerDropDown := true
		else if ((listenerDropDown = translate("Deactivated")) || (listenerDropDown = " "))
			listenerDropDown := false
		
		setConfigurationValue(configuration, "Voice Control", "Language", languageCode)
		setConfigurationValue(configuration, "Voice Control", "Speaker", speakerDropDown)
		setConfigurationValue(configuration, "Voice Control", "SpeakerVolume", speakerVolumeSlider)
		setConfigurationValue(configuration, "Voice Control", "SpeakerPitch", speakerPitchSlider)
		setConfigurationValue(configuration, "Voice Control", "SpeakerSpeed", speakerSpeedSlider)
		setConfigurationValue(configuration, "Voice Control", "Listener", listenerDropDown)
		setConfigurationValue(configuration, "Voice Control", "PushToTalk", (Trim(pushToTalkEdit) = "") ? false : pushToTalkEdit)
		setConfigurationValue(configuration, "Voice Control", "ActivationCommand", (Trim(activationCommandEdit) = "") ? false : activationCommandEdit)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

setPTTHotkey(hotkey) {
	if hotkey is not integer
	{
		pushToTalkEdit := hotkey
		
		window := ConfigurationEditor.Instance.Window
		
		Gui %window%:Default
		GuiControl Text, pushToTalkEdit, %pushToTalkEdit%
		
		ConfigurationEditor.Instance.toggleKeyDetector()
	}
}

getPTTHotkey() {
	protectionOn()
	
	try {
		ConfigurationEditor.Instance.toggleKeyDetector("setPTTHotkey")
	}
	finally {
		protectionOff()
	}
}

initializeVoiceControlConfigurator() {
	editor := ConfigurationEditor.Instance
	
	editor.registerConfigurator(translate("Voice Control"), new VoiceControlConfigurator(editor.Configuration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeVoiceControlConfigurator()