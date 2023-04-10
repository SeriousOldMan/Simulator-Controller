;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Voice Control Configuration     ;;;
;;;                                         Plugin                          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\SpeechSynthesizer.ahk"
#Include "..\Libraries\SpeechRecognizer.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; VoiceControlConfigurator                                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class VoiceControlConfigurator extends ConfiguratorPanel {
	iLanguages := []
	iRecognizers := []

	iSynthesizerMode := false
	iRecognizerMode := false

	iTopWidgets := []
	iBottomWidgets := []
	iWindowsSynthesizerWidgets := []
	iAzureSynthesizerWidgets := []
	iAzureRecognizerWidgets := []
	iOtherWidgets := []

	iTopAzureCredentialsVisible := false
	iBottomAzureCredentialsVisible := false

	iSoundProcessingSettings := false

	class VoiceResizer extends Window.Resizer {
		iPanel := false
		iStart := false

		__New(window, panel, start) {
			this.iPanel := panel
			this.iStart := start

			super.__New(window)
		}
		/*
		Resize(arguments*) {
			if this.iStart
				this.iPanel.hideWidgets()
			else
				this.iPanel.showWidgets()

			super.Resize(arguments*)
		}
		*/
	}

	__New(editor, configuration := false) {
		super.__New(configuration)

		this.Editor := editor

		VoiceControlConfigurator.Instance := this
	}

	createGui(editor, x, y, width, height) {
		local window := editor.Window
		local choices := []
		local chosen := 0
		local enIndex := 0
		local languageCode := "en"
		local languages := availableLanguages()
		local code, language, ignore, grammarFile, x0, x1, x2, w1, w2, x3, w3, x4, w4, voices, recognizers

		updateLanguage(*) {
			this.updateLanguage()
		}

		updateAzureVoices(*) {
			this.updateAzureVoices()
		}

		chooseVoiceSynthesizer(*) {
			local voiceSynthesizerDropDown := this.Control["voiceSynthesizerDropDown"]
			local oldChoice := voiceSynthesizerDropDown.LastValue

			if (oldChoice == 1)
				this.hideWindowsSynthesizerEditor()
			else if (oldChoice == 2)
				this.hideDotNETSynthesizerEditor()
			else
				this.hideAzureSynthesizerEditor()

			if (voiceSynthesizerDropDown.Value == 1)
				this.showWindowsSynthesizerEditor()
			else if (voiceSynthesizerDropDown.Value == 2)
				this.showDotNETSynthesizerEditor()
			else
				this.showAzureSynthesizerEditor()

			if (voiceSynthesizerDropDown.Value <= 2)
				this.updateLanguage(false)

			voiceSynthesizerDropDown.LastValue := voiceSynthesizerDropDown.Value
		}

		chooseVoiceRecognizer(*) {
			local voiceRecognizerDropDown := this.Control["voiceRecognizerDropDown"]
			local oldChoice := voiceRecognizerDropDown.LastValue
			local recognizers, chosen

			if (oldChoice == 1)
				this.hideServerRecognizerEditor()
			else if (oldChoice == 2)
				this.hideDesktopRecognizerEditor()
			else
				this.hideAzureRecognizerEditor()

			if (voiceRecognizerDropDown.Value == 1)
				this.showServerRecognizerEditor()
			else if (voiceRecognizerDropDown.Value == 2)
				this.showDesktopRecognizerEditor()
			else {
				recognizers := SpeechRecognizer("Azure|" . this.Control["azureTokenIssuerEdit"].Text . "|" . this.Control["azureSubscriptionKeyEdit"].Text
											  , false, this.getCurrentLanguage(), true).Recognizers[this.getCurrentLanguage()].Clone()

				this.showAzureRecognizerEditor()
			}

			if (voiceRecognizerDropDown.Value <= 2)
				recognizers := SpeechRecognizer((voiceRecognizerDropDown.Value = 1) ? "Server" : "Desktop"
											  , false, this.getCurrentLanguage(), true).Recognizers[this.getCurrentLanguage()].Clone()

			recognizers.InsertAt(1, translate("Deactivated"))
			recognizers.InsertAt(1, translate("Automatic"))

			chosen := 1

			this.Control["listenerDropDown"].Delete()
			this.Control["listenerDropDown"].Add(recognizers)
			this.Control["listenerDropDown"].Choose(1)

			voiceRecognizerDropDown.LastValue := voiceRecognizerDropDown.Value
		}

		getPTTHotkey(*) {
			setPTTHotkey(hotkey) {
				if !isInteger(hotkey) {
					SoundPlay(kResourcesDirectory . "Sounds\Activated.wav")

					this.Control["pushToTalkEdit"].Text := hotkey

					this.Editor.toggleTriggerDetector()
				}
			}

			protectionOn()

			try {
				this.Editor.toggleTriggerDetector(setPTTHotkey)
			}
			finally {
				protectionOff()
			}
		}

		chooseSoXPath(*) {
			local directory, translator

			this.Window.Opt("+OwnDialogs")

			translator := translateMsgBoxButtons.Bind(["Select", "Select", "Cancel"])

			OnMessage(0x44, translator)
			directory := DirSelect("*" . this.Control["soXPathEdit"].Text, 0, translate("Select SoX folder..."))
			OnMessage(0x44, translator, 0)

			if (directory != "") {
				this.Control["soXPathEdit"].Text := directory

				this.Control["soXConfigurationButton"].Enabled := true
			}
		}

		updateConfigurationButton(*) {
			if (this.Control["soXPathEdit"].Text != "")
				this.Control["soXConfigurationButton"].Enabled := true
			else
				this.Control["soXConfigurationButton"].Enabled := false
		}

		editSoXConfiguration(*) {
			protectionOn()

			try {
				this.editSoundProcessing()
			}
			finally {
				protectionOff()
			}
		}

		window.SetFont("Norm", "Arial")

		chosen := 0

		for code, language in languages {
			choices.Push(language)

			if (code = "en")
				enIndex := A_Index
		}

		for ignore, grammarFile in concatenate(getFileNames("Race Engineer.grammars.*", kUserGrammarsDirectory, kGrammarsDirectory)
											 , getFileNames("Race Strategist.grammars.*", kUserGrammarsDirectory, kGrammarsDirectory)
											 , getFileNames("Race Spotter.grammars.*", kUserGrammarsDirectory, kGrammarsDirectory)) {
			SplitPath(grammarFile, , , &code)

			if !languages.Has(code) {
				choices.Push(code)

				if (code = "en")
					enIndex := choices.Length
			}
		}

		this.iLanguages := choices

		x0 := x + 8
		x1 := x + 118
		x2 := x + 230

		w1 := width - (x1 - x)
		w2 := w1 - 26 - 26

		x3 := x1 + w2 + 2
		x4 := x2 + 24 + 8
		w4 := width - (x4 - x)
		x5 := x3 + 24

		window.Add(VoiceControlConfigurator.VoiceResizer(window, this, true))

		widget1 := window.Add("Text", "x" . x . " y" . y . " w110 h23 +0x200 Hidden", translate("Language"))
		widget2 := window.Add("DropDownList", "x" . x1 . " yp w160 W:Grow(0.3) Choose" . chosen . " VvoiceLanguageDropDown Hidden", choices)
		widget2.OnEvent("Change", updateLanguage)

		choices := ["Windows (Win32)", "Windows (.NET)", "Azure Cognitive Services"]
		chosen := 0

		widget3 := window.Add("Text", "x" . x . " yp+32 w110 h23 +0x200 Section Hidden", translate("Speech Synthesizer"))
		widget4 := window.Add("DropDownList", "AltSubmit x" . x1 . " yp w160 W:Grow(0.3) Choose" . chosen . "  VvoiceSynthesizerDropDown Hidden", choices)
		widget4.LastValue := chosen
		widget4.OnEvent("Change", chooseVoiceSynthesizer)

		this.iTopWidgets := [[widget1, widget2], [widget3, widget4]]

		voices := [translate("Automatic"), translate("Deactivated")]

		widget5 := window.Add("Text", "x" . x . " ys+24 w110 h23 +0x200 VwindowsSpeakerLabel Hidden", translate("Voice"))
		widget6 := window.Add("DropDownList", "x" . x1 . " yp w" . w1 . " W:Grow VwindowsSpeakerDropDown Hidden", voices)

		widget7 := window.Add("Text", "x" . x . " ys+24 w110 h23 +0x200 VwindowsSpeakerVolumeLabel Hidden", translate("Level"))
		widget8 := window.Add("Slider", "Center Thick15 x" . x1 . " yp+2 w160 W:Grow(0.3) 0x10 Range0-100 ToolTip VspeakerVolumeSlider Hidden")

		widget9 := window.Add("Text", "x" . x . " yp+22 w110 h23 +0x200 VwindowsSpeakerPitchLabel Hidden", translate("Pitch"))
		widget10 := window.Add("Slider", "Center Thick15 x" . x1 . " yp+2 w160 W:Grow(0.3) 0x10 Range-10-10 ToolTip VspeakerPitchSlider Hidden")

		widget11 := window.Add("Text", "x" . x . " yp+22 w110 h23 +0x200 VwindowsSpeakerSpeedLabel Hidden", translate("Speed"))
		widget12 := window.Add("Slider", "Center Thick15 x" . x1 . " yp+2 w160 W:Grow(0.3) 0x10 Range-10-10 ToolTip VspeakerSpeedSlider Hidden")

		this.iWindowsSynthesizerWidgets := [[window["windowsSpeakerLabel"], window["windowsSpeakerDropDown"]]]

		widget13 := window.Add("Text", "x" . x . " yp+26 w110 h23 +0x200 VsoXPathLabel1 Hidden", translate("SoX Folder (optional)"))

		window.SetFont("c505050 s8")

		widget14 := window.Add("Text", "x" . x0 . " yp+18 w110 h23 VsoXPathLabel2 Hidden", translate("(Post Processing)"))

		window.SetFont()

		widget15 := window.Add("Edit", "x" . x1 . " yp-19 w" . w2 . " h21 W:Grow VsoXPathEdit Hidden")
		widget15.OnEvent("Change", updateConfigurationButton)

		widget16 := window.Add("Button", "x" . x3 . " yp w23 h23 X:Move VsoXPathButton Hidden", translate("..."))
		widget16.OnEvent("Click", chooseSoXPath)

		widget17 := window.Add("Button", "x" . x5 . " yp w23 h23 X:Move Disabled VsoXConfigurationButton Hidden")
		widget17.OnEvent("Click", editSoXConfiguration)

		setButtonIcon(widget17, kIconsDirectory . "General Settings.ico", 1)

		choices := ["Windows (Server)", "Windows (Desktop)", "Azure Cognitive Services"]
		chosen := 0

		widget18 := window.Add("Text", "x" . x . " yp+42 w110 h23 +0x200 vvoiceRecognizerLabel Hidden", translate("Speech Recognizer"))
		widget19 := window.Add("DropDownList", "AltSubmit x" . x1 . " yp w160 W:Grow(0.3) Choose" . chosen . "  VvoiceRecognizerDropDown Hidden", choices)
		widget19.LastValue := chosen
		widget19.OnEvent("Change", chooseVoiceRecognizer)

		recognizers := []

		recognizers.InsertAt(1, translate("Deactivated"))
		recognizers.InsertAt(1, translate("Automatic"))

		chosen := 0

		this.iRecognizers := recognizers

		widget20 := window.Add("Text", "x" . x . " yp+24 w110 h23 +0x200 VlistenerLabel Hidden", translate("Recognizer Engine"))
		widget21 := window.Add("DropDownList", "x" . x1 . " yp w" . w1 . " W:Grow Choose" . chosen . " VlistenerDropDown Hidden", recognizers)

		widget22 := window.Add("Text", "x" . x . " yp+24 w110 h23 +0x200 VpushToTalkLabel Hidden", translate("P2T / Activation"))
		widget23 := window.Add("Edit", "x" . x1 . " yp w110 h21 VpushToTalkEdit Hidden")
		widget24 := window.Add("Button", "x" . x2 . " yp-1 w23 h23 VpushToTalkButton Hidden")
		widget24.OnEvent("Click", getPTTHotkey)
		setButtonIcon(widget24, kIconsDirectory . "Key.ico", 1)
		widget25 := window.Add("Edit", "x" . x4 . " yp+1 w" . w4 . " h21 W:Grow VactivationCommandEdit Hidden")

		this.iBottomWidgets := [[window["listenerLabel"], window["listenerDropDown"]]
							  , [window["pushToTalkLabel"], window["pushToTalkEdit"], window["pushToTalkButton"], window["activationCommandEdit"]]]
		this.iOtherWidgets := [[window["windowsSpeakerVolumeLabel"], window["speakerVolumeSlider"]]
							 , [window["windowsSpeakerPitchLabel"], window["speakerPitchSlider"]]
							 , [window["windowsSpeakerSpeedLabel"], window["speakerSpeedSlider"]]
							 , [window["soXPathLabel1"], window["soXPathLabel2"], window["soXPathEdit"], window["soXPathButton"], window["soXConfigurationButton"]]
							 , [window["voiceRecognizerLabel"], window["voiceRecognizerDropDown"]], [window["listenerLabel"], window["listenerDropDown"]]
							 , [window["pushToTalkLabel"], window["pushToTalkEdit"], window["pushToTalkButton"], window["activationCommandEdit"]]]

		widget26 := window.Add("Text", "x" . x . " ys+24 w140 h23 +0x200 VazureSubscriptionKeyLabel Hidden", translate("Subscription Key"))
		widget27 := window.Add("Edit", "x" . x1 . " yp w" . w1 . " h21 W:Grow VazureSubscriptionKeyEdit Hidden")
		widget27.OnEvent("Change", updateAzureVoices)

		widget28 := window.Add("Text", "x" . x . " yp+24 w140 h23 +0x200 VazureTokenIssuerLabel Hidden", translate("Token Issuer Endpoint"))
		widget29 := window.Add("Edit", "x" . x1 . " yp w" . w1 . " h21 W:Grow VazureTokenIssuerEdit Hidden")
		widget29.OnEvent("Change", updateAzureVoices)

		voices := [translate("Automatic"), translate("Deactivated")]

		widget30 := window.Add("Text", "x" . x . " yp+24 w110 h23 +0x200 VazureSpeakerLabel Hidden", translate("Voice"))
		widget31 := window.Add("DropDownList", "x" . x1 . " yp w" . w1 . " W:Grow VazureSpeakerDropDown Hidden", voices)

		; window.Add(VoiceControlConfigurator.VoiceResizer(window, this, false))

		this.iAzureSynthesizerWidgets := [[window["azureSubscriptionKeyLabel"], window["azureSubscriptionKeyEdit"]]
										, [window["azureTokenIssuerLabel"], window["azureTokenIssuerEdit"]]
										, [window["azureSpeakerLabel"], window["azureSpeakerDropDown"]]]
		this.iAzureRecognizerWidgets := [[window["azureSubscriptionKeyLabel"], window["azureSubscriptionKeyEdit"]]
									   , [window["azureTokenIssuerLabel"], window["azureTokenIssuerEdit"]]]

		this.updateLanguage(false)

		loop 31
			editor.registerWidget(this, widget%A_Index%)

		this.hideControls(this.iTopWidgets)
		this.hideControls(this.iWindowsSynthesizerWidgets)
		this.hideControls(this.iAzureSynthesizerWidgets)
		this.hideControls(this.iOtherWidgets)

		this.iSynthesizerMode := "Init"
	}

	loadFromConfiguration(configuration, load := false) {
		local languageCode, languages, synthesizer, recognizer

		super.loadFromConfiguration(configuration)

		if load {
			languageCode := getMultiMapValue(configuration, "Voice Control", "Language", getLanguage())
			languages := availableLanguages()

			if languages.Has(languageCode)
				this.Value["voiceLanguage"] := languages[languageCode]
			else
				this.Value["voiceLanguage"] := languageCode

			synthesizer := getMultiMapValue(configuration, "Voice Control", "Synthesizer", "dotNET")
			if (InStr(synthesizer, "Azure") == 1)
				synthesizer := "Azure"

			recognizer := getMultiMapValue(configuration, "Voice Control", "Recognizer", "Desktop")
			if (InStr(recognizer, "Azure") == 1)
				recognizer := "Azure"

			this.Value["voiceSynthesizer"] := inList(["Windows", "dotNET", "Azure"], synthesizer)
			this.Value["voiceRecognizer"] := inList(["Server", "Desktop", "Azure"], recognizer)

			this.Value["azureSpeaker"] := getMultiMapValue(configuration, "Voice Control", "Speaker.Azure", true)
			this.Value["windowsSpeaker"] := getMultiMapValue(configuration, "Voice Control", "Speaker.Windows",  getMultiMapValue(configuration, "Voice Control", "Speaker", true))

			this.Value["azureSubscriptionKey"] := getMultiMapValue(configuration, "Voice Control", "SubscriptionKey", "")
			this.Value["azureTokenIssuer"] := getMultiMapValue(configuration, "Voice Control", "TokenIssuer", "")

			this.Value["speakerVolume"] := getMultiMapValue(configuration, "Voice Control", "SpeakerVolume", 100)
			this.Value["speakerPitch"] := getMultiMapValue(configuration, "Voice Control", "SpeakerPitch", 0)
			this.Value["speakerSpeed"] := getMultiMapValue(configuration, "Voice Control", "SpeakerSpeed", 0)

			this.Value["soXPath"] := getMultiMapValue(configuration, "Voice Control", "SoX Path", "")

			this.Value["listener"] := getMultiMapValue(configuration, "Voice Control", "Listener", true)
			this.Value["pushToTalk"] := getMultiMapValue(configuration, "Voice Control", "PushToTalk", false)
			this.Value["activationCommand"] := getMultiMapValue(configuration, "Voice Control", "ActivationCommand", false)

			if (this.Value["pushToTalk"] = false)
				this.Value["pushToTalk"] := ""

			if (this.Value["activationCommand"] = false)
				this.Value["activationCommand"] := ""

			if this.Configuration {
				if (this.Value["windowsSpeaker"] == true)
					this.Value["windowsSpeaker"] := translate("Automatic")
				else if (this.Value["windowsSpeaker"] == false)
					this.Value["windowsSpeaker"] := translate("Deactivated")

				if (this.Value["azureSpeaker"] == true)
					this.Value["azureSpeaker"] := translate("Automatic")
				else if (this.Value["azureSpeaker"] == false)
					this.Value["azureSpeaker"] := translate("Deactivated")

				if (this.Value["listener"] == true)
					this.Value["listener"] := translate("Automatic")
				else if (this.Value["listener"] == false)
					this.Value["listener"] := translate("Deactivated")
			}

			this.iSoundProcessingSettings := [getMultiMapValue(configuration, "Voice Control", "Speaker.ClickVolume", 80)
											, getMultiMapValue(configuration, "Voice Control", "Speaker.NoiseVolume", 66)
											, getMultiMapValue(configuration, "Voice Control", "Speaker.Overdrive", 20)
											, getMultiMapValue(configuration, "Voice Control", "Speaker.Color", 20)
											, getMultiMapValue(configuration, "Voice Control", "Speaker.HighPass", 800)
											, getMultiMapValue(configuration, "Voice Control", "Speaker.LowPass", 1800)]
		}
	}

	saveToConfiguration(configuration) {
		local windowsSpeaker := this.Control["windowsSpeakerDropDown"].Text
		local azureSpeaker := this.Control["azureSpeakerDropDown"].Text
		local listener := this.Control["listenerDropDown"].Text

		super.saveToConfiguration(configuration)

		setMultiMapValue(configuration, "Voice Control", "Language", this.getCurrentLanguage())

		if (windowsSpeaker = translate("Automatic"))
			windowsSpeaker := true
		else if ((windowsSpeaker = translate("Deactivated")) || (windowsSpeaker = A_Space))
			windowsSpeaker := false

		if (azureSpeaker = translate("Automatic"))
			azureSpeaker := true
		else if ((azureSpeaker = translate("Deactivated")) || (azureSpeaker = A_Space))
			azureSpeaker := false

		if (this.Control["voiceSynthesizerDropDown"].Value = 1) {
			setMultiMapValue(configuration, "Voice Control", "Synthesizer", "Windows")
			setMultiMapValue(configuration, "Voice Control", "Speaker", windowsSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Windows", windowsSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", true)
		}
		else if (this.Control["voiceSynthesizerDropDown"].Value = 2) {
			setMultiMapValue(configuration, "Voice Control", "Synthesizer", "dotNET")
			setMultiMapValue(configuration, "Voice Control", "Speaker", windowsSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Windows", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", windowsSpeaker)
		}
		else {
			setMultiMapValue(configuration, "Voice Control", "Synthesizer", "Azure|" . this.Control["azureTokenIssuerEdit"].Text . "|" . this.Control["azureSubscriptionKeyEdit"].Text)
			setMultiMapValue(configuration, "Voice Control", "Speaker", azureSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Windows", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", true)
		}

		setMultiMapValue(configuration, "Voice Control", "Speaker.Azure", azureSpeaker)
		setMultiMapValue(configuration, "Voice Control", "SubscriptionKey", this.Control["azureSubscriptionKeyEdit"].Text)
		setMultiMapValue(configuration, "Voice Control", "TokenIssuer", this.Control["azureTokenIssuerEdit"].Text)

		setMultiMapValue(configuration, "Voice Control", "SpeakerVolume", this.Control["speakerVolumeSlider"].Value)
		setMultiMapValue(configuration, "Voice Control", "SpeakerPitch", this.Control["speakerPitchSlider"].Value)
		setMultiMapValue(configuration, "Voice Control", "SpeakerSpeed", this.Control["speakerSpeedSlider"].Value)
		setMultiMapValue(configuration, "Voice Control", "SoX Path", this.Control["soXPathEdit"].Text)

		if (listener = translate("Automatic"))
			listener := true
		else if ((listener = translate("Deactivated")) || (listener = A_Space))
			listener := false

		if (this.Control["voiceRecognizerDropDown"].Value <= 2)
			setMultiMapValue(configuration, "Voice Control", "Recognizer", ["Server", "Desktop"][this.Control["voiceRecognizerDropDown"].Value])
		else
			setMultiMapValue(configuration, "Voice Control", "Recognizer", "Azure|" . this.Control["azureTokenIssuerEdit"].Text . "|" . this.Control["azureSubscriptionKeyEdit"].Text)

		setMultiMapValue(configuration, "Voice Control", "Listener", listener)
		setMultiMapValue(configuration, "Voice Control", "PushToTalk", (Trim(this.Control["pushToTalkEdit"].Text) = "") ? false : this.Control["pushToTalkEdit"].Text)
		setMultiMapValue(configuration, "Voice Control", "ActivationCommand", (Trim(this.Control["activationCommandEdit"].Text) = "") ? false : this.Control["activationCommandEdit"].Text)

		setMultiMapValue(configuration, "Voice Control", "Speaker.ClickVolume", this.iSoundProcessingSettings[1])
		setMultiMapValue(configuration, "Voice Control", "Speaker.NoiseVolume", this.iSoundProcessingSettings[2])
		setMultiMapValue(configuration, "Voice Control", "Speaker.Overdrive", this.iSoundProcessingSettings[3])
		setMultiMapValue(configuration, "Voice Control", "Speaker.Color", this.iSoundProcessingSettings[4])
		setMultiMapValue(configuration, "Voice Control", "Speaker.HighPass", this.iSoundProcessingSettings[5])
		setMultiMapValue(configuration, "Voice Control", "Speaker.LowPass", this.iSoundProcessingSettings[6])
	}

	loadConfigurator(configuration) {
		local choices := []
		local chosen := 0
		local enIndex := 0
		local languageCode := "en"
		local languages := availableLanguages()
		local code, language, ignore, grammarFile, voices, recognizers, listener

		this.loadFromConfiguration(configuration, true)

		for code, language in languages {
			choices.Push(language)

			if (language == this.Value["voiceLanguage"]) {
				chosen := A_Index
				languageCode := code
			}

			if (code = "en")
				enIndex := A_Index
		}

		for ignore, grammarFile in getFileNames("Race Engineer.grammars.*", kUserGrammarsDirectory, kGrammarsDirectory) {
			SplitPath(grammarFile, , , &code)

			if !languages.Has(code) {
				choices.Push(code)

				if (code == this.Value["voiceLanguage"]) {
					chosen := choices.Length
					languageCode := code
				}

				if (code = "en")
					enIndex := choices.Length
			}
		}

		this.Control["voiceLanguageDropDown"].Choose(chosen)

		this.Control["voiceSynthesizerDropDown"].Choose(this.Value["voiceSynthesizer"])
		this.Control["voiceRecognizerDropDown"].Choose(this.Value["voiceRecognizer"])

		this.Control["voiceSynthesizerDropDown"].LastValue := this.Value["voiceSynthesizer"]
		this.Control["voiceRecognizerDropDown"].LastValue := this.Value["voiceRecognizer"]

		this.Control["azureSubscriptionKeyEdit"].Text := this.Value["azureSubscriptionKey"]
		this.Control["azureTokenIssuerEdit"].Text := this.Value["azureTokenIssuer"]

		if (this.Value["voiceSynthesizer"] = 1)
			this.updateWindowsVoices(configuration)
		else if (this.Value["voiceSynthesizer"] = 2)
			this.updateDotNETVoices(configuration)

		this.updateAzureVoices(configuration)

		this.Control["speakerVolumeSlider"].Value := this.Value["speakerVolume"]
		this.Control["speakerPitchSlider"].Value := this.Value["speakerPitch"]
		this.Control["speakerSpeedSlider"].Value := this.Value["speakerSpeed"]

		this.Control["soXPathEdit"].Text := this.Value["soXPath"]

		if (this.Value["soXPath"] != "")
			this.Control["soXConfigurationButton"].Enabled := true
		else
			this.Control["soXConfigurationButton"].Enabled := false

		listener := getMultiMapValue(configuration, "Voice Control", "Listener", true)

		if (listener == true)
			listener := translate("Automatic")
		else if (listener == false)
			listener := translate("Deactivated")

		if (this.Control["voiceRecognizerDropDown"].Value = 3)
			recognizers := SpeechRecognizer("Azure|" . this.Control["azureTokenIssuerEdit"].Text . "|" . this.Control["azureSubscriptionKeyEdit"].Text
										  , false, this.getCurrentLanguage(), true).Recognizers[this.getCurrentLanguage()].Clone()
		else
			recognizers := SpeechRecognizer((this.Control["voiceRecognizerDropDown"].Value = 1) ? "Server" : "Desktop"
										  , false, this.getCurrentLanguage(), true).Recognizers[this.getCurrentLanguage()].Clone()

		recognizers.InsertAt(1, translate("Deactivated"))
		recognizers.InsertAt(1, translate("Automatic"))

		chosen := inList(recognizers, listener)

		if (chosen == 0)
			chosen := "1"

		this.Control["listenerDropDown"].Delete()
		this.Control["listenerDropDown"].Add(recognizers)
		this.Control["listenerDropDown"].Choose(chosen)

		this.Control["pushToTalkEdit"].Text := this.Value["pushToTalk"]
		this.Control["activationCommandEdit"].Text := this.Value["activationCommand"]
	}

	show() {
		super.show()

		this.loadConfigurator(this.Configuration)

		/*
		if (this.Control["voiceSynthesizerDropDown"].Value == 1)
			this.showWindowsSynthesizerEditor()
		else if (this.Control["voiceSynthesizerDropDown"].Value == 2)
			this.showDotNETSynthesizerEditor()
		else
			this.showAzureSynthesizerEditor()

		if (this.Control["voiceRecognizerDropDown"].Value == 1)
			this.showServerRecognizerEditor()
		else if (this.Control["voiceRecognizerDropDown"].Value == 2)
			this.showDesktopRecognizerEditor()
		else
			this.showAzureRecognizerEditor()
		*/

		this.showWidgets()
	}

	showWidgets() {
		local voiceSynthesizer := this.Control["voiceSynthesizerDropDown"].Value
		local voiceRecognizer := this.Control["voiceRecognizerDropDown"].Value

		if !voiceSynthesizer
			voiceSynthesizer := 1

		if (voiceSynthesizer == 1)
			this.showWindowsSynthesizerEditor()
		else if (voiceSynthesizer == 2)
			this.showDotNETSynthesizerEditor()
		else
			this.showAzureSynthesizerEditor()

		if !voiceRecognizer
			voiceRecognizer := 1

		if (voiceRecognizer == 1)
			this.showServerRecognizerEditor()
		else if (voiceRecognizer == 2)
			this.showDesktopRecognizerEditor()
		else
			this.showAzureRecognizerEditor()
	}

	hideWidgets() {
		if (this.iSynthesizerMode = "Windows")
			this.hideWindowsSynthesizerEditor()
		else if (this.iSynthesizerMode = "dotNET")
			this.hideDotNETSynthesizerEditor()
		else if (this.iSynthesizerMode = "Azure")
			this.hideAzureSynthesizerEditor()
		else {
			this.hideControls(this.iTopWidgets)
			this.hideControls(this.iWindowsSynthesizerWidgets)
			this.hideControls(this.iAzureSynthesizerWidgets)
			this.hideControls(this.iOtherWidgets)
		}

		if (this.iRecognizerMode = "Server")
			this.hideServerRecognizerEditor()
		else if (this.iRecognizerMode = "Desktop")
			this.hideDesktopRecognizerEditor()
		else if (this.iRecognizerMode = "Azure")
			this.hideAzureRecognizerEditor()

		this.iTopAzureCredentialsVisible := false
		this.iBottomAzureCredentialsVisible := false
	}

	showWindowsSynthesizerEditor() {
		this.showControls(this.iTopWidgets)
		this.showControls(this.iWindowsSynthesizerWidgets)

		if ((this.iSynthesizerMode == false) || (this.iSynthesizerMode = "Init"))
			this.transposeControls(this.iOtherWidgets, 24 * this.iWindowsSynthesizerWidgets.Length, this.Window.TitleBarHeight)
		else
			throw "Internal error detected in VoiceControlConfigurator.showWindowsSynthesizerEditor..."

		this.showControls(this.iOtherWidgets)

		this.iSynthesizerMode := "Windows"
	}

	showDotNETSynthesizerEditor() {
		this.showWindowsSynthesizerEditor()

		this.iSynthesizerMode := "dotNET"
	}

	hideWindowsSynthesizerEditor() {
		this.hideControls(this.iTopWidgets)
		this.hideControls(this.iWindowsSynthesizerWidgets)
		this.hideControls(this.iOtherWidgets)

		if ((this.iSynthesizerMode == "Windows") || (this.iSynthesizerMode == "dotNET"))
			this.transposeControls(this.iOtherWidgets, -24 * this.iWindowsSynthesizerWidgets.Length, this.Window.TitleBarHeight)
		else if (this.iSynthesizerMode != "Init")
			throw "Internal error detected in VoiceControlConfigurator.hideWindowsSynthesizerEditor..."

		this.iSynthesizerMode := false
	}

	hideDotNETSynthesizerEditor() {
		this.hideWindowsSynthesizerEditor()
	}

	showAzureSynthesizerEditor() {
		local wasOpen := false

		if this.iBottomAzureCredentialsVisible {
			wasOpen := true

			this.hideAzureRecognizerEditor()
		}

		this.showControls(this.iTopWidgets)
		this.showControls(this.iAzureSynthesizerWidgets)

		this.iTopAzureCredentialsVisible := true

		if ((this.iSynthesizerMode == false) || (this.iSynthesizerMode = "Init"))
			this.transposeControls(this.iOtherWidgets, 24 * this.iAzureSynthesizerWidgets.Length, this.Window.TitleBarHeight)
		else
			throw "Internal error detected in VoiceControlConfigurator.showAzureSynthesizerEditor..."

		if wasOpen
			this.showAzureRecognizerEditor()

		this.showControls(this.iOtherWidgets)

		this.iSynthesizerMode := "Azure"
	}

	hideAzureSynthesizerEditor() {
		local wasOpen := false

		if (this.iRecognizerMode = "Azure") {
			wasOpen := true

			this.hideAzureRecognizerEditor()
		}

		this.hideControls(this.iTopWidgets)
		this.hideControls(this.iAzureSynthesizerWidgets)
		this.hideControls(this.iOtherWidgets)

		this.iTopAzureCredentialsVisible := false

		if (this.iSynthesizerMode == "Azure")
			this.transposeControls(this.iOtherWidgets, -24 * this.iAzureSynthesizerWidgets.Length, this.Window.TitleBarHeight)
		else if (this.iSynthesizerMode != "Init")
			throw "Internal error detected in VoiceControlConfigurator.hideAzureSynthesizerEditor..."

		if wasOpen
			this.showAzureRecognizerEditor()

		this.iSynthesizerMode := false
	}

	showServerRecognizerEditor() {
		this.iRecognizerMode := "Server"
	}

	hideServerRecognizerEditor() {
		this.iRecognizerMode := false
	}

	showDesktopRecognizerEditor() {
		this.iRecognizerMode := "Desktop"
	}

	hideDesktopRecognizerEditor() {
		this.iRecognizerMode := false
	}

	showAzureRecognizerEditor() {
		local titleBarHeight := this.Window.TitleBarHeight

		if !this.iTopAzureCredentialsVisible {
			if ((this.iRecognizerMode == false) || (this.iRecognizerMode != "Init")) {
				this.transposeControls(this.iAzureRecognizerWidgets, (24 * 7) - 3, titleBarHeight)
				this.showControls(this.iAzureRecognizerWidgets)
				this.transposeControls(this.iBottomWidgets, 24 * this.iAzureRecognizerWidgets.Length, titleBarHeight)
			}
			else
				throw "Internal error detected in VoiceControlConfigurator.showAzureRecognizerEditor..."

			this.iBottomAzureCredentialsVisible := true
		}

		this.iRecognizerMode := "Azure"
	}

	hideAzureRecognizerEditor() {
		local titleBarHeight := this.Window.TitleBarHeight

		if !this.iTopAzureCredentialsVisible {
			if (this.iRecognizerMode == "Azure") {
				this.hideControls(this.iAzureRecognizerWidgets)
				this.transposeControls(this.iAzureRecognizerWidgets, (-24 * 7) + 3, titleBarHeight)
				this.transposeControls(this.iBottomWidgets, -24 * this.iAzureRecognizerWidgets.Length, titleBarHeight)
			}
			else if (this.iRecognizerMode != "Init")
				throw "Internal error detected in VoiceControlConfigurator.hideAzureRecognizerEditor..."

			this.iBottomAzureCredentialsVisible := false
		}

		this.iRecognizerMode := false
	}

	getCurrentLanguage() {
		local voiceLanguage := this.Control["voiceLanguageDropDown"].Text
		local languageCode := "en"
		local languages := availableLanguages()
		local found := false
		local code, language, ignore, grammarFile, grammarLanguageCode

		for code, language in availableLanguages()
			if (language = voiceLanguage) {
				found := true

				languageCode := code
			}

		if !found
			for ignore, grammarFile in getFileNames("Race Engineer.grammars.*", kUserGrammarsDirectory, kGrammarsDirectory) {
				SplitPath(grammarFile, , , &grammarLanguageCode)

				if languages.Has(grammarLanguageCode)
					language := languages[grammarLanguageCode]
				else
					language := grammarLanguageCode

				if (language = voiceLanguage) {
					languageCode := grammarLanguageCode

					break
				}
			}

		return languageCode
	}

	updateLanguage(recognizer := true) {
		local recognizers, chosen

		if (this.Control["voiceSynthesizerDropDown"].Value = 1)
			this.updateWindowsVoices()
		else if (this.Control["voiceSynthesizerDropDown"].Value = 2)
			this.updateDotNETVoices()

		this.updateAzureVoices()

		if recognizer {
			if (this.Control["voiceRecognizerDropDown"].Value <= 2)
				recognizers := SpeechRecognizer((this.Control["voiceRecognizerDropDown"].Value = 1) ? "Server" : "Desktop"
											  , false, this.getCurrentLanguage(), true).Recognizers[this.getCurrentLanguage()]
			else
				recognizers := SpeechRecognizer("Azure|" . this.Control["azureTokenIssuerEdit"].Text . "|" . this.Control["azureSubscriptionKeyEdit"].Text
											  , false, this.getCurrentLanguage(), true).Recognizers[this.getCurrentLanguage()]

			recognizers.InsertAt(1, translate("Deactivated"))
			recognizers.InsertAt(1, translate("Automatic"))

			this.Control["listenerDropDown"].Delete()
			this.Control["listenerDropDown"].Add(recognizers)
			this.Control["listenerDropDown"].Choose(1)
		}
	}

	loadVoices(synthesizer, configuration) {
		local language := this.getCurrentLanguage()
		local voices := SpeechSynthesizer(synthesizer, true, language).Voices[language].Clone()

		voices.InsertAt(1, translate("Deactivated"))
		voices.InsertAt(1, translate("Automatic"))

		return voices
	}

	loadWindowsVoices(configuration, &windowsSpeaker) {
		if configuration
			windowsSpeaker := getMultiMapValue(configuration, "Voice Control", "Speaker.Windows", getMultiMapValue(this.Configuration, "Voice Control", "Speaker", true))
		else {
			windowsSpeaker := this.Control["windowsSpeakerDropDown"].Text

			configuration := this.Configuration
		}

		return this.loadVoices("Windows", configuration)
	}

	loadDotNETVoices(configuration, &dotNETSpeaker)	{
		if configuration
			dotNETSpeaker := getMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", true)
		else {
			dotNETSpeaker := this.Control["windowsSpeakerDropDown"].Text

			configuration := this.Configuration
		}

		return this.loadVoices("dotNET", configuration)
	}

	updateWindowsVoices(configuration := false) {
		local windowsSpeaker, voices, chosen

		voices := this.loadWindowsVoices(configuration, &windowsSpeaker)
		chosen := inList(voices, windowsSpeaker)

		if (chosen == 0)
			chosen := 1

		this.Control["windowsSpeakerDropDown"].Delete()
		this.Control["windowsSpeakerDropDown"].Add(voices)
		this.Control["windowsSpeakerDropDown"].Choose(chosen)
	}

	updateDotNETVoices(configuration := false) {
		local dotNETSpeaker, voices, chosen

		voices := this.loadDotNETVoices(configuration, &dotNETSpeaker)
		chosen := inList(voices, dotNETSpeaker)

		if (chosen == 0)
			chosen := 1

		this.Control["windowsSpeakerDropDown"].Delete()
		this.Control["windowsSpeakerDropDown"].Add(voices)
		this.Control["windowsSpeakerDropDown"].Choose(chosen)
	}

	updateAzureVoices(configuration := false) {
		local voices := []
		local language, chosen, azureSpeaker

		if configuration
			azureSpeaker := getMultiMapValue(configuration, "Voice Control", "Speaker.Azure", true)
		else {
			configuration := this.Configuration

			azureSpeaker := this.Control["azureSpeakerDropDown"].Text
		}

		if (configuration && !azureSpeaker)
			azureSpeaker := getMultiMapValue(configuration, "Voice Control", "Speaker.Azure", true)

		if ((this.Control["azureSubscriptionKeyEdit"].Text != "") && (this.Control["azureTokenIssuerEdit"].Text != "")) {
			language := this.getCurrentLanguage()

			voices := SpeechSynthesizer("Azure|" . this.Control["azureTokenIssuerEdit"].Text . "|" . this.Control["azureSubscriptionKeyEdit"].Text, true, language).Voices[language].Clone()
		}

		voices.InsertAt(1, translate("Deactivated"))
		voices.InsertAt(1, translate("Automatic"))

		chosen := inList(voices, azureSpeaker)

		if (chosen == 0)
			chosen := 1

		this.Control["azureSpeakerDropDown"].Delete()
		this.Control["azureSpeakerDropDown"].Add(voices)
		this.Control["azureSpeakerDropDown"].Choose(chosen)
	}

	editSoundProcessing() {
		local newSettings

		this.Window.Opt("+Disabled")

		try {
			newSettings := editSoundProcessing(this, this.iSoundProcessingSettings)

			if newSettings
				this.iSoundProcessingSettings := newSettings
		}
		finally {
			this.Window.Opt("-Disabled")
		}
	}

	showControls(widgets) {
		local ignore, widget, widgetPart

		for ignore, widget in widgets
			for ignore, widgetPart in widget {
				widgetPart.Enabled := true
				widgetPart.Visible := true
			}

		if (this.Control["soXPathEdit"].Text = "")
			this.Control["soXConfigurationButton"].Enabled := false
	}

	hideControls(widgets) {
		local ignore, widget, widgetPart

		for ignore, widget in widgets
			for ignore, widgetPart in widget {
				widgetPart.Enabled := false
				widgetPart.Visible := false
			}
	}

	transposeControls(widgets, offset, correction) {
		local ignore, widget, widgetPart
		local posY

		correction := 0

		for ignore, widget in widgets
			for ignore, widgetPart in widget {
				ControlGetPos( , &posY, , , widgetPart)

				posY := (posY + offset - correction)

				ControlMove( , posY, , , widgetPart)

				for ignore, resizer in this.Window.Resizers[widgetPart]
					resizer.OriginalY := posY
			}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

editSoundProcessing(editorOrCommand := false, settings := false, *) {
	local title, eWindow

	static result := false

	static editorGui

	if (editorOrCommand == kOk)
		result := kOk
	else if (editorOrCommand == kCancel)
		result := kCancel
	else {
		result := false

		editorGui := Window()

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Text", "x16 y16 w100 h23 +0x200", translate("Click"))
		editorGui.Add("Slider", "Center Thick15 x120 yp+2 w150 0x10 Range0-100 ToolTip vclickVolume", settings[1])

		editorGui.Add("Text", "x16 yp+24 w100 h23 +0x200", translate("Noise && Crackle"))
		editorGui.Add("Slider", "Center Thick15 x120 yp+2 w150 0x10 Range0-100 ToolTip vnoiseVolume", settings[2])

		editorGui.Add("Text", "x16 yp+24 w100 h23 +0x200", translate("Gain"))
		editorGui.Add("Slider", "Center Thick15 x120 yp+2 w150 0x10 Range0-30 ToolTip vdistortionGain", settings[3])

		editorGui.Add("Text", "x16 yp+24 w100 h23 +0x200", translate("Harmonics"))
		editorGui.Add("Slider", "Center Thick15 x120 yp+2 w150 0x10 Range0-30 ToolTip vdistortionHarmonics", settings[4])

		editorGui.Add("Text", "x16 yp+24 w100 h23 +0x200", translate("Highpass"))
		editorGui.Add("Slider", "Center Thick15 x120 yp+2 w150 0x10 Range20-4000 ToolTip vhighpassFrequency", settings[5])

		editorGui.Add("Text", "x16 yp+24 w100 h23 +0x200", translate("Lowpass"))
		editorGui.Add("Slider", "Center Thick15 x120 yp+2 w150 0x10 Range20-4000 ToolTip vlowpassFrequency", settings[6])

		editorGui.Add("Button", "x60 yp+35 w80 h23 Default", translate("Ok")).OnEvent("Click", editSoundProcessing.Bind(kOk))
		editorGui.Add("Button", "x146 yp w80 h23", translate("&Cancel")).OnEvent("Click", editSoundProcessing.Bind(kCancel))

		editorGui.Opt("+Owner" . editorOrCommand.Window.Hwnd)

		editorGui.Show("AutoSize Center")

		while !result
			Sleep(100)

		try {
			if (result == kCancel)
				return false
			else if (result == kOk)
				return [editorGui["clickVolume"], editorGui["noiseVolume"]
					  , editorGui["distortionGain"], editorGui["distortionHarmonics"]
					  , editorGui["highpassFrequency"], editorGui["lowpassFrequency"]]
		}
		finally {
			editorGui.Destroy()
		}
	}
}

initializeVoiceControlConfigurator() {
	local editor

	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance

		editor.registerConfigurator(translate("Voice Control"), VoiceControlConfigurator(editor, editor.Configuration))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeVoiceControlConfigurator()