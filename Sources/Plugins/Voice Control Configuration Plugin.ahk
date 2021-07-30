;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Voice Control Configuration     ;;;
;;;                                         Plugin                          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\SpeechSynthesizer.ahk
#Include ..\Libraries\SpeechRecognizer.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; VoiceControlConfigurator                                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global voiceLanguageDropDown
global voiceSynthesizerDropDown

global windowsSpeakerLabel
global windowsSpeakerDropDown
global windowsSpeakerVolumeLabel
global speakerVolumeSlider
global windowsSpeakerPitchLabel
global speakerPitchSlider
global windowsSpeakerSpeedLabel
global speakerSpeedSlider

global azureSubscriptionKeyLabel
global azureSubscriptionKeyEdit = ""
global azureTokenIssuerLabel
global azureTokenIssuerEdit = ""
global azureSpeakerLabel
global azureSpeakerDropDown

global soXPathLabel1
global soXPathLabel2
global soXPathEdit = ""
global soXPathButton
global listenerLabel
global listenerDropDown
global pushToTalkLabel
global pushToTalkEdit = ""
global pushToTalkButton
global activationCommandLabel
global activationCommandEdit = ""

class VoiceControlConfigurator extends ConfigurationItem {
	iEditor := false
	
	iWindowsVoiceWidgets := []
	iAzureVoiceWidgets := []
	iOtherWidgets := []
	
	Editor[] {
		Get {
			return this.iEditor
		}
	}
	
	__New(editor, configuration) {
		this.iEditor := editor
		
		base.__New(configuration)
		
		VoiceControlConfigurator.Instance := this
	}
	
	createGui(editor, x, y, width, height) {
		window := editor.Window
		
		Gui %window%:Font, Norm, Arial
		
		choices := []
		chosen := 0
		enIndex := 0
		languageCode := "en"
		
		languages := availableLanguages()
		
		for code, language in languages {
			choices.Push(language)
			
			if (language == voiceLanguageDropDown) {
				chosen := A_Index
				languageCode := code
			}
				
			if (code = "en")
				enIndex := A_Index
		}
			
		for ignore, grammarFile in getFileNames("Race Engineer.grammars.*", kUserGrammarsDirectory, kGrammarsDirectory) {
			SplitPath grammarFile, , , code
		
			if !languages.HasKey(code) {
				choices.Push(code)
				
				if (code == voiceLanguageDropDown) {
					chosen := choices.Length()
					languageCode := code
				}
					
				if (code = "en")
					enIndex := choices.Length()
			}
		}
		
		if (chosen == 0)
			chosen := enIndex
		
		Gui %window%:Add, Text, x16 y80 w110 h23 +0x200, % translate("Language")
		Gui %window%:Add, DropDownList, x134 yp w160 Choose%chosen% VvoiceLanguageDropDown GupdateVoices, % values2String("|", choices*)
		
		choices := choices := ["Windows Speech", "Azure Cognitive Services"]
		chosen := voiceSynthesizerDropDown
		
		Gui %window%:Add, Text, x16 yp+32 w110 h23 +0x200 Section, % translate("Speech Synthesizer")
		Gui %window%:Add, DropDownList, AltSubmit x134 yp w160 Choose%chosen% gchooseVoiceSynthesizer VvoiceSynthesizerDropDown, % values2String("|", map(choices, "translate")*)
		
		voices := [translate("Automatic"), translate("Deactivated")]
		
		Gui %window%:Add, Text, x16 ys+24 w110 h23 +0x200 VwindowsSpeakerLabel, % translate("Voice")
		Gui %window%:Add, DropDownList, x134 yp w340 VwindowsSpeakerDropDown, % values2String("|", voices*)
		
		Gui %window%:Add, Text, x16 ys+24 w110 h23 +0x200 VwindowsSpeakerVolumeLabel, % translate("Volume")
		Gui %window%:Add, Slider, x134 yp w135 0x10 Range0-100 ToolTip VspeakerVolumeSlider, % speakerVolumeSlider
		
		Gui %window%:Add, Text, x16 yp+24 w110 h23 +0x200 VwindowsSpeakerPitchLabel, % translate("Pitch")
		Gui %window%:Add, Slider, x134 yp w135 0x10 Range-10-10 ToolTip VspeakerPitchSlider, % speakerPitchSlider
		
		Gui %window%:Add, Text, x16 yp+24 w110 h23 +0x200 VwindowsSpeakerSpeedLabel, % translate("Speed")
		Gui %window%:Add, Slider, x134 yp w135 0x10 Range-10-10 ToolTip VspeakerSpeedSlider, % speakerSpeedSlider
		
		this.iWindowsVoiceWidgets := [["windowsSpeakerLabel", "windowsSpeakerDropDown"]]
		
		Gui %window%:Add, Text, x16 yp+24 w140 h23 +0x200 VsoXPathLabel1, % translate("SoX Folder (optional)")
		Gui %window%:Font, c505050 s8
		Gui %window%:Add, Text, x24 yp+18 w133 h23 VsoXPathLabel2, % translate("(Post Processing)")
		Gui %window%:Font
		Gui %window%:Add, Edit, x134 yp-18 w314 h21 VsoXPathEdit, %soXPathEdit%
		Gui %window%:Add, Button, x450 yp w23 h23 gchooseSoXPath VsoXPathButton, % translate("...")

		recognizers := new SpeechRecognizer(false, false, true).getRecognizerList().Clone()
		
		Loop % recognizers.Length()
			recognizers[A_Index] := recognizers[A_Index].Name
		
		recognizers.InsertAt(1, translate("Deactivated"))
		recognizers.InsertAt(1, translate("Automatic"))
		
		chosen := inList(recognizers, listenerDropDown)
		
		if (chosen == 0)
			chosen := 1
		
		Gui %window%:Add, Text, x16 yp+42 w110 h23 +0x200 VlistenerLabel, % translate("Speech Recognizer")
		Gui %window%:Add, DropDownList, x134 yp w340 Choose%chosen% VlistenerDropDown, % values2String("|", recognizers*)
		
		Gui %window%:Add, Text, x16 yp+24 w110 h23 +0x200 VpushToTalkLabel, % translate("Push To Talk")
		Gui %window%:Add, Edit, x134 yp w110 h21 VpushToTalkEdit, %pushToTalkEdit%
		Gui %window%:Add, Button, x246 yp-1 w23 h23 ggetPTTHotkey HwnddetectPTTButtonHandle VpushToTalkButton
		setButtonIcon(detectPTTButtonHandle, kIconsDirectory . "Key.ico", 1)
		
		Gui %window%:Add, Text, x16 yp+24 w110 h23 +0x200 VactivationCommandLabel, % translate("Activation Command")
		Gui %window%:Add, Edit, x134 yp w135 h21 VactivationCommandEdit, %activationCommandEdit%
		
		this.iOtherWidgets := [["windowsSpeakerVolumeLabel", "speakerVolumeSlider"]
							 , ["windowsSpeakerPitchLabel", "speakerPitchSlider"]
							 , ["windowsSpeakerSpeedLabel", "speakerSpeedSlider"]
							 , ["soXPathLabel1", "soXPathLabel2", "soXPathEdit", "soXPathButton"]
							 , ["listenerLabel", "listenerDropDown"], ["pushToTalkLabel", "pushToTalkEdit", "pushToTalkButton"],
							 , ["activationCommandLabel", "activationCommandEdit"]]
		
		Gui %window%:Add, Text, x16 ys+24 w140 h23 +0x200 VazureSubscriptionKeyLabel, % translate("Subscription Key")
		Gui %window%:Add, Edit, x134 yp w340 h21 VazureSubscriptionKeyEdit GupdateAzureVoices, %azureSubscriptionKeyEdit%
		
		Gui %window%:Add, Text, x16 yp+24 w140 h23 +0x200 VazureTokenIssuerLabel, % translate("Token Issuer Endpoint")
		Gui %window%:Add, Edit, x134 yp w340 h21 VazureTokenIssuerEdit GupdateAzureVoices, %azureTokenIssuerEdit%
		
		voices := [translate("Automatic"), translate("Deactivated")]
		
		Gui %window%:Add, Text, x16 yp+24 w110 h23 +0x200 VazureSpeakerLabel, % translate("Voice")
		Gui %window%:Add, DropDownList, x134 yp w340 VazureSpeakerDropDown, % values2String("|", voices*)
		
		this.iAzureVoiceWidgets := [["azureSubscriptionKeyLabel", "azureSubscriptionKeyEdit"], ["azureTokenIssuerLabel", "azureTokenIssuerEdit"], ["azureSpeakerLabel", "azureSpeakerDropDown"]]

		this.updateVoices()
		
		hideWidgets(this.iWindowsVoiceWidgets)
		hideWidgets(this.iAzureVoiceWidgets)
		hideWidgets(this.iOtherWidgets)
		
		if (voiceSynthesizerDropDown == 1)
			this.showWindowsVoiceEditor()
		else
			this.showAzureVoiceEditor()
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		languageCode := getConfigurationValue(configuration, "Voice Control", "Language", getLanguage())
		languages := availableLanguages()
		
		if languages.HasKey(languageCode)
			voiceLanguageDropDown := languages[languageCode]
		else
			voiceLanguageDropDown := languageCode
		
		voiceSynthesizerDropDown := inList(["Windows", "Azure"], getConfigurationValue(configuration, "Voice Control", "Synthesizer", "Windows"))
		
		azureSpeakerDropDown := getConfigurationValue(configuration, "Voice Control", "Speaker.Azure", true)
		windowsSpeakerDropDown := getConfigurationValue(configuration, "Voice Control", "Speaker.Windows",  getConfigurationValue(configuration, "Voice Control", "Speaker", true))
		
		azureSubscriptionKeyEdit := getConfigurationValue(configuration, "Voice Control", "SubscriptionKey", "")
		azureTokenIssuerEdit := getConfigurationValue(configuration, "Voice Control", "TokenIssuer", "")
		
		speakerVolumeSlider := getConfigurationValue(configuration, "Voice Control", "SpeakerVolume", 100)
		speakerPitchSlider := getConfigurationValue(configuration, "Voice Control", "SpeakerPitch", 0)
		speakerSpeedSlider := getConfigurationValue(configuration, "Voice Control", "SpeakerSpeed", 0)
		
		soXPathEdit := getConfigurationValue(configuration, "Voice Control", "SoX Path", "")
		
		listenerDropDown := getConfigurationValue(configuration, "Voice Control", "Listener", false)
		pushToTalkEdit := getConfigurationValue(configuration, "Voice Control", "PushToTalk", false)
		activationCommandEdit := getConfigurationValue(configuration, "Voice Control", "ActivationCommand", false)
		
		if (pushToTalkEdit = false)
			pushToTalkEdit := ""
		
		if (activationCommandEdit = false)
			activationCommandEdit := ""
		
		if (windowsSpeakerDropDown == true)
			windowsSpeakerDropDown := translate("Automatic")
		else if (windowsSpeakerDropDown == false)
			windowsSpeakerDropDown := translate("Deactivated")
		
		if (listenerDropDown == true)
			listenerDropDown := translate("Automatic")
		else if (listenerDropDown == false)
			listenerDropDown := translate("Deactivated")
	}
	
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		setConfigurationValue(configuration, "Voice Control", "Language", this.getCurrentLanguage())
			
		GuiControlGet voiceSynthesizerDropDown
		
		setConfigurationValue(configuration, "Voice Control", "Synthesizer", ["Windows", "Azure"][voiceSynthesizerDropDown])
		
		GuiControlGet windowsSpeakerDropDown
		GuiControlGet azureSpeakerDropDown
		GuiControlGet azureSubscriptionKeyEdit
		GuiControlGet azureTokenIssuerEdit
		
		if (windowsSpeakerDropDown = translate("Automatic"))
			windowsSpeakerDropDown := true
		else if ((windowsSpeakerDropDown = translate("Deactivated")) || (windowsSpeakerDropDown = " "))
			windowsSpeakerDropDown := false

		setConfigurationValue(configuration, "Voice Control", "Speaker.Windows", windowsSpeakerDropDown)
		setConfigurationValue(configuration, "Voice Control", "Speaker.Azure", azureSpeakerDropDown)
		
		if (voiceSynthesizerDropDown == 1) {
			setConfigurationValue(configuration, "Voice Control", "Service", "Windows")
			setConfigurationValue(configuration, "Voice Control", "Speaker", windowsSpeakerDropDown)
		}
		else {
			setConfigurationValue(configuration, "Voice Control", "Service", "Azure|" . azureTokenIssuerEdit . "|" . azureSubscriptionKeyEdit)
			setConfigurationValue(configuration, "Voice Control", "Speaker", azureSpeakerDropDown)
		}

		setConfigurationValue(configuration, "Voice Control", "SubscriptionKey", azureSubscriptionKeyEdit)
		setConfigurationValue(configuration, "Voice Control", "TokenIssuer", azureTokenIssuerEdit)

		GuiControlGet speakerVolumeSlider
		GuiControlGet speakerPitchSlider
		GuiControlGet speakerSpeedSlider
		GuiControlGet soXPathEdit
		GuiControlGet listenerDropDown
		GuiControlGet pushToTalkEdit
		GuiControlGet activationCommandEdit
		
		setConfigurationValue(configuration, "Voice Control", "SpeakerVolume", speakerVolumeSlider)
		setConfigurationValue(configuration, "Voice Control", "SpeakerPitch", speakerPitchSlider)
		setConfigurationValue(configuration, "Voice Control", "SpeakerSpeed", speakerSpeedSlider)
		setConfigurationValue(configuration, "Voice Control", "SoX Path", soXPathEdit)
				
		if (listenerDropDown = translate("Automatic"))
			listenerDropDown := true
		else if ((listenerDropDown = translate("Deactivated")) || (listenerDropDown = " "))
			listenerDropDown := false
		
		setConfigurationValue(configuration, "Voice Control", "Listener", listenerDropDown)
		setConfigurationValue(configuration, "Voice Control", "PushToTalk", (Trim(pushToTalkEdit) = "") ? false : pushToTalkEdit)
		setConfigurationValue(configuration, "Voice Control", "ActivationCommand", (Trim(activationCommandEdit) = "") ? false : activationCommandEdit)
	}
	
	showWindowsVoiceEditor() {
		showWidgets(this.iWindowsVoiceWidgets)
		translateWidgets(this.iOtherWidgets, 24 * this.iWindowsVoiceWidgets.Length())
		showWidgets(this.iOtherWidgets)
	}
	
	hideWindowsVoiceEditor() {
		hideWidgets(this.iWindowsVoiceWidgets)
		hideWidgets(this.iOtherWidgets)
		translateWidgets(this.iOtherWidgets, -24 * this.iWindowsVoiceWidgets.Length())
	}
	
	showAzureVoiceEditor() {
		showWidgets(this.iAzureVoiceWidgets)
		translateWidgets(this.iOtherWidgets, 24 * this.iAzureVoiceWidgets.Length())
		showWidgets(this.iOtherWidgets)
	}
	
	hideAzureVoiceEditor() {
		hideWidgets(this.iAzureVoiceWidgets)
		hideWidgets(this.iOtherWidgets)
		translateWidgets(this.iOtherWidgets, -24 * this.iAzureVoiceWidgets.Length())
	}
	
	getCurrentLanguage() {
		GuiControlGet voiceLanguageDropDown
		
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
		
		return languageCode
	}
	
	updateVoices() {
		this.updateWindowsVoices()
		this.updateAzureVoices()
	}
	
	updateWindowsVoices() {
		voices := []
		
		GuiControlGet windowsSpeakerDropDown
		
		if !windowsSpeakerDropDown
			windowsSpeakerDropDown := getConfigurationValue(this.Configuration, "Voice Control", "Speaker.Windows",  getConfigurationValue(this.Configuration, "Voice Control", "Speaker", true))
			
		
		language := this.getCurrentLanguage()
			
		voices := new SpeechSynthesizer("Windows", true, language).Voices[language].Clone()
		
		voices.InsertAt(1, translate("Deactivated"))
		voices.InsertAt(1, translate("Automatic"))
		
		chosen := inList(voices, windowsSpeakerDropDown)
		
		if (chosen == 0)
			chosen := 1
		
		GuiControl, , windowsSpeakerDropDown, % "|" . values2String("|", voices*)
		GuiControl Choose, windowsSpeakerDropDown, % chosen
	}
	
	updateAzureVoices() {
		voices := []
		
		GuiControlGet azureSubscriptionKeyEdit
		GuiControlGet azureTokenIssuerEdit
		GuiControlGet azureSpeakerDropDown
		
		if !azureSpeakerDropDown
			azureSpeakerDropDown := getConfigurationValue(this.Configuration, "Voice Control", "Speaker.Azure", true)
		
		if ((azureSubscriptionKeyEdit != "") && (azureTokenIssuerEdit)) {
			language := this.getCurrentLanguage()
			
			voices := new SpeechSynthesizer("Azure|" . azureTokenIssuerEdit . "|" . azureSubscriptionKeyEdit, true, language).Voices[language].Clone()
		}
		
		voices.InsertAt(1, translate("Deactivated"))
		voices.InsertAt(1, translate("Automatic"))
		
		chosen := inList(voices, azureSpeakerDropDown)
		
		if (chosen == 0)
			chosen := 1
		
		GuiControl, , azureSpeakerDropDown, % "|" . values2String("|", voices*)
		GuiControl Choose, azureSpeakerDropDown, % chosen
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

updateVoices() {
	VoiceControlConfigurator.Instance.updateVoices()
}

updateAzureVoices() {
	VoiceControlConfigurator.Instance.updateAzureVoices()
}

showWidgets(widgets) {
	for ignore, widget in widgets
		for ignore, widgetPart in widget {
			GuiControl Enable, %widgetPart%
			GuiControl Show, %widgetPart%
		}
}

hideWidgets(widgets) {
	for ignore, widget in widgets
		for ignore, widgetPart in widget {
			GuiControl Disable, %widgetPart%
			GuiControl Hide, %widgetPart%
		}
}

translateWidgets(widgets, offset) {
	correction := 71
	
	for ignore, widget in widgets
		for ignore, widgetPart in widget {
			GuiControlGet tempPos, Pos, %widgetPart%
		
			tempPosY := tempPosY + offset - correction
			tempPosX := tempPosX
			
			GuiControl Move, %widgetPart%, y%tempPosY%
			
			GuiControlGet tempPos, Pos, %widgetPart%
	}
}

chooseVoiceSynthesizer() {
	oldChoice := voiceSynthesizerDropDown
	
	GuiControlGet voiceSynthesizerDropDown
	
	if (oldChoice == 1)
		VoiceControlConfigurator.Instance.hideWindowsVoiceEditor()
	else
		VoiceControlConfigurator.Instance.hideAzureVoiceEditor()
	
	if (voiceSynthesizerDropDown == 1)
		VoiceControlConfigurator.Instance.showWindowsVoiceEditor()
	else
		VoiceControlConfigurator.Instance.showAzureVoiceEditor()
}

setPTTHotkey(hotkey) {
	if hotkey is not integer
	{
		pushToTalkEdit := hotkey
		
		window := ConfigurationEditor.Instance.Window
		
		SoundPlay %kResourcesDirectory%Sounds\Activated.wav
		
		Gui %window%:Default
		GuiControl Text, pushToTalkEdit, %pushToTalkEdit%
		
		ConfigurationEditor.Instance.toggleTriggerDetector()
	}
}

getPTTHotkey() {
	protectionOn()
	
	try {
		ConfigurationEditor.Instance.toggleTriggerDetector("setPTTHotkey")
	}
	finally {
		protectionOff()
	}
}

chooseSoXPath() {
	protectionOn()
	
	try{
		FileSelectFolder directory, *%soXPathEdit%, 0, % translate("Select SoX folder...")
	
		if (directory != "")
			GuiControl Text, soXPathEdit, %directory%
	}
	finally {
		protectionOff()
	}
}

initializeVoiceControlConfigurator() {
	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance
		
		editor.registerConfigurator(translate("Voice Control"), new VoiceControlConfigurator(editor, editor.Configuration))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeVoiceControlConfigurator()