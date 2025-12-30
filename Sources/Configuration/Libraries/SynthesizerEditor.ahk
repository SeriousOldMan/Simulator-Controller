;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Synthesizer Editor              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Extensions\Task.ahk"
#Include "..\..\Framework\Extensions\SpeechSynthesizer.ahk"
#Include "..\..\Framework\Extensions\Translator.ahk"
#Include "ConfigurationEditor.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; SynthesizerEditor                                                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SynthesizerEditor extends ConfiguratorPanel {
	iResult := false

	iManager := false
	iAssistant := false
	iLanguage := "English"

	iWindow := false

	iSynthesizerMode := false

	iTopWidgets := []
	iBottomWidgets := []
	iWindowsSynthesizerWidgets := []
	iAzureSynthesizerWidgets := []
	iGoogleSynthesizerWidgets := []
	iOpenAISynthesizerWidgets := []
	iElevenLabsSynthesizerWidgets := []
	iOtherWidgets := []

	iTopAzureCredentialsVisible := false
	iTopGoogleCredentialsVisible := false
	iTopOpenAICredentialsVisible := false
	iTopElevenLabsCredentialsVisible := false

	Manager {
		Get {
			return this.iManager
		}
	}

	Assistant {
		Get {
			return this.iAssistant
		}
	}

	Window {
		Get {
			return this.iWindow
		}
	}

	__New(manager, assistant, configuration := false) {
		this.iManager := manager
		this.iAssistant := assistant

		super.__New(configuration)
	}

	createGui(configuration) {
		local choices := []
		local chosen := 0
		local x := 8
		local width := 380
		local editorGui, x0, x1, x2, w1, w2, x3, w3, x4, w4, voices, halfWidth

		updateAzureVoices(*) {
			this.updateAzureVoices()
		}

		updateGoogleVoices(*) {
			this.updateGoogleVoices()
		}

		updateElevenLabsVoices(*) {
			this.updateElevenLabsVoices()
		}

		chooseVoiceSynthesizer(*) {
			local voiceSynthesizerDropDown := this.Control["basicVoiceSynthesizerDropDown"]
			local oldChoice := voiceSynthesizerDropDown.LastValue

			if (oldChoice == 1)
				this.hideWindowsSynthesizerEditor()
			else if (oldChoice == 2)
				this.hideDotNETSynthesizerEditor()
			else if (oldChoice == 3)
				this.hideAzureSynthesizerEditor()
			else if (oldChoice == 4)
				this.hideGoogleSynthesizerEditor()
			else if (oldChoice == 5)
				this.hideOpenAISynthesizerEditor()
			else
				this.hideElevenLabsSynthesizerEditor()

			if (voiceSynthesizerDropDown.Value == 1)
				this.showWindowsSynthesizerEditor()
			else if (voiceSynthesizerDropDown.Value == 2)
				this.showDotNETSynthesizerEditor()
			else if (voiceSynthesizerDropDown.Value == 3)
				this.showAzureSynthesizerEditor()
			else if (voiceSynthesizerDropDown.Value == 4)
				this.showGoogleSynthesizerEditor()
			else if (voiceSynthesizerDropDown.Value == 5)
				this.showOpenAISynthesizerEditor()
			else
				this.showElevenLabsSynthesizerEditor()

			if ((voiceSynthesizerDropDown.Value <= 2) || (voiceSynthesizerDropDown.Value >= 4))
				this.updateLanguage()

			voiceSynthesizerDropDown.LastValue := voiceSynthesizerDropDown.Value
		}

		chooseAPIKeyFilePath(*) {
			local file, translator

			this.Window.Opt("+OwnDialogs")

			translator := translateMsgDlgButtons.Bind(["Select", "Select", "Cancel"])

			OnMessage(0x44, translator)
			file := withBlockedWindows(FileSelect, 1, this.Control["basicGoogleAPIKeyFileEdit"].Text, translate("Select Google Credentials File..."), "JSON (*.json)")
			OnMessage(0x44, translator, 0)

			if (file != "") {
				this.Control["basicGoogleAPIKeyFileEdit"].Text := file

				this.updateGoogleVoices()
			}
		}

		editorGui := Window({Descriptor: "Synthesizer Editor", Options: "0x400000"})

		this.iWindow := editorGui

		editorGui.SetFont("Bold", "Arial")

		editorGui.Add("Text", "w388 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(editorGui, "Synthesizer Editor"))

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Documentation", "x138 YP+20 w128 H:Center Center", translate("Voice Configuration")
					, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control")

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Text", "x8 yp+30 w388 W:Grow 0x10")

		x0 := x + 8
		x1 := x + 118
		x2 := x + 230

		w1 := width - (x1 - x)
		w2 := w1 - 26 - 26

		x3 := x1 + w2 + 2
		x4 := x2 + 24 + 8
		w4 := width - (x4 - x)
		x5 := x3 + 24

		choices := ["Windows (Win32)", "Windows (.NET)", "Azure Cognitive Services", "Google Speech Services", "OpenAI API", "ElevenLabs"]
		chosen := 0

		widget1 := editorGui.Add("Text", "x" . x0 . " yp+10 w110 h23 +0x200 Section Hidden", translate("Speech Synthesizer"))
		widget1.Info := "Basic.Synthesizer.Info"
		widget2 := editorGui.Add("DropDownList", "x" . x1 . " yp w156 W:Grow(0.3) Choose" . chosen . "  VbasicVoiceSynthesizerDropDown Hidden", choices)
		widget2.Info := "Basic.Synthesizer.Info"
		widget2.LastValue := chosen
		widget2.OnEvent("Change", chooseVoiceSynthesizer)

		widget3 := editorGui.Add("Button", "xp+157 yp-1 w23 h23 X:Move(0.3) vbasicWindowsSettingsButton Hidden")
		widget3.Info := "Basic.Synthesizer.Settings.Info"
		widget3.OnEvent("Click", (*) => Run("explorer.exe ms-settings:speech"))
		setButtonIcon(widget3, kIconsDirectory . "General Settings.ico", 1)

		this.iTopWidgets := [[widget1, widget2, widget3]]

		voices := [translate("Deactivated"), translate("Random")]

		widget3 := editorGui.Add("Text", "x" . x0 . " ys+24 w110 h23 +0x200 VbasicWindowsSpeakerLabel Hidden", translate("Voice"))
		widget3.Info := "Basic.Synthesizer.Info"
		widget4 := editorGui.Add("DropDownList", "x" . (x1 + 24) . " yp w" . (w1 - 24) . " W:Grow VbasicWindowsSpeakerDropDown Hidden", voices)
		widget4.Info := "Basic.Synthesizer.Info"

		widget17 := editorGui.Add("Button", "x" . x1 . " yp w23 h23 Default")
		widget17.Info := "Basic.Synthesizer.Play.Info"
		widget17.OnEvent("Click", (*) => this.testSpeaker())
		setButtonIcon(widget17, kIconsDirectory . "Start.ico", 1, "L4 T4 R4 B4")

		widget5 := editorGui.Add("Text", "x" . x0 . " ys+24 w110 h23 +0x200 VbasicWindowsSpeakerVolumeLabel Hidden", translate("Level"))
		widget5.Info := "Basic.Synthesizer.Vocalics.Info"
		widget6 := editorGui.Add("Slider", "Center Thick15 x" . x1 . " yp+2 w180 W:Grow(0.3) 0x10 Range0-100 ToolTip VbasicSpeakerVolumeSlider Hidden")
		widget6.Info := "Basic.Synthesizer.Vocalics.Info"

		widget7 := editorGui.Add("Text", "x" . x0 . " yp+22 w110 h23 +0x200 VbasicWindowsSpeakerPitchLabel Hidden", translate("Pitch"))
		widget7.Info := "Basic.Synthesizer.Vocalics.Info"
		widget8 := editorGui.Add("Slider", "Center Thick15 x" . x1 . " yp+2 w180 W:Grow(0.3) 0x10 Range-10-10 ToolTip VbasicSpeakerPitchSlider Hidden")
		widget8.Info := "Basic.Synthesizer.Vocalics.Info"

		widget9 := editorGui.Add("Text", "x" . x0 . " yp+22 w110 h23 +0x200 VbasicWindowsSpeakerSpeedLabel Hidden", translate("Speed"))
		widget9.Info := "Basic.Synthesizer.Vocalics.Info"
		widget10 := editorGui.Add("Slider", "Center Thick15 x" . x1 . " yp+2 w180 W:Grow(0.3) 0x10 Range-10-10 ToolTip VbasicSpeakerSpeedSlider Hidden")
		widget10.Info := "Basic.Synthesizer.Vocalics.Info"

		this.iWindowsSynthesizerWidgets := [[editorGui["basicWindowsSpeakerLabel"], editorGui["basicWindowsSpeakerDropDown"], widget17]]

		this.iOtherWidgets := [[editorGui["basicWindowsSpeakerVolumeLabel"], editorGui["basicSpeakerVolumeSlider"]]
							 , [editorGui["basicWindowsSpeakerPitchLabel"], editorGui["basicSpeakerPitchSlider"]]
							 , [editorGui["basicWindowsSpeakerSpeedLabel"], editorGui["basicSpeakerSpeedSlider"]]]

		widget11 := editorGui.Add("Text", "x" . x0 . " ys+24 w140 h23 +0x200 VbasicAzureSubscriptionKeyLabel Hidden", translate("Subscription Key"))
		widget11.Info := "Basic.Synthesizer.Info"
		widget12 := editorGui.Add("Edit", "x" . x1 . " yp w" . w1 . " h21 Password W:Grow VbasicAzureSubscriptionKeyEdit Hidden")
		widget12.Info := "Basic.Synthesizer.Info"
		widget12.OnEvent("Change", updateAzureVoices)

		widget13 := editorGui.Add("Text", "x" . x0 . " yp+24 w140 h23 +0x200 VbasicAzureTokenIssuerLabel Hidden", translate("Token Issuer Endpoint"))
		widget13.Info := "Basic.Synthesizer.Info"
		widget14 := editorGui.Add("Edit", "x" . x1 . " yp w" . w1 . " h21 W:Grow VbasicAzureTokenIssuerEdit Hidden")
		widget14.Info := "Basic.Synthesizer.Info"
		widget14.OnEvent("Change", updateAzureVoices)

		voices := [translate("Deactivated"), translate("Random")]

		widget15 := editorGui.Add("Text", "x" . x0 . " yp+24 w110 h23 +0x200 VbasicAzureSpeakerLabel Hidden", translate("Voice"))
		widget15.Info := "Basic.Synthesizer.Info"
		widget16 := editorGui.Add("DropDownList", "x" . (x1 + 24) . " yp w" . (w1 - 24) . " W:Grow VbasicAzureSpeakerDropDown Hidden", voices)
		widget16.Info := "Basic.Synthesizer.Info"

		widget18 := editorGui.Add("Button", "x" . x1 . " yp w23 h23 Default")
		widget18.Info := "Basic.Synthesizer.Play.Info"
		widget18.OnEvent("Click", (*) => this.testSpeaker())
		setButtonIcon(widget18, kIconsDirectory . "Start.ico", 1, "L4 T4 R4 B4")

		editorGui.Add("Text", "x8 yp+106 w388 W:Grow 0x10")

		editorGui.Add("Button", "x120 yp+10 w80 h23 Default", translate("Ok")).OnEvent("Click", (*) => this.iResult := kOk)
		editorGui.Add("Button", "x206 yp w80 h23", translate("&Cancel")).OnEvent("Click", (*) => this.iResult := kCancel)

		this.iAzureSynthesizerWidgets := [[editorGui["basicAzureSubscriptionKeyLabel"], editorGui["basicAzureSubscriptionKeyEdit"]]
										, [editorGui["basicAzureTokenIssuerLabel"], editorGui["basicAzureTokenIssuerEdit"]]
										, [editorGui["basicAzureSpeakerLabel"], editorGui["basicAzureSpeakerDropDown"], widget18]]

		widget19 := editorGui.Add("Text", "x" . x0 . " ys+24 w110 h23 +0x200 VbasicGoogleAPIKeyFileLabel Hidden", translate("Service Key"))
		widget19.Info := "Basic.Synthesizer.Info"
		widget20 := editorGui.Add("Edit", "x" . x1 . " yp w" . (w1 - 24) . " h21 Password W:Grow VbasicGoogleAPIKeyFileEdit Hidden")
		widget20.Info := "Basic.Synthesizer.Info"
		widget20.OnEvent("Change", updateGoogleVoices)

		widget21 := editorGui.Add("Button", "x" . (x1 + w1 - 23) . " yp w23 h23 X:Move Disabled VbasicGoogleAPIKeyFilePathButton Hidden", translate("..."))
		widget21.Info := "Basic.Synthesizer.Info"
		widget21.OnEvent("Click", chooseAPIKeyFilePath)

		voices := [translate("Deactivated"), translate("Random")]

		widget22 := editorGui.Add("Text", "x" . x0 . " yp+24 w110 h23 +0x200 VbasicGoogleSpeakerLabel Hidden", translate("Voice"))
		widget22.Info := "Basic.Synthesizer.Info"
		widget23 := editorGui.Add("DropDownList", "x" . (x1 + 24) . " yp w" . (w1 - 24) . " W:Grow VbasicGoogleSpeakerDropDown Hidden", voices)
		widget23.Info := "Basic.Synthesizer.Info"

		widget24 := editorGui.Add("Button", "x" . x1 . " yp w23 h23 Default Hidden")
		widget24.Info := "Basic.Synthesizer.Play.Info"
		widget24.OnEvent("Click", (*) => this.testSpeaker())
		setButtonIcon(widget24, kIconsDirectory . "Start.ico", 1, "L4 T4 R4 B4")

		this.iGoogleSynthesizerWidgets := [[editorGui["basicGoogleAPIKeyFileLabel"], editorGui["basicGoogleAPIKeyFileEdit"], widget21]
										 , [editorGui["basicGoogleSpeakerLabel"], editorGui["basicGoogleSpeakerDropDown"], widget24]]

		widget30 := editorGui.Add("Text", "x" . x0 . " ys+24 w112 h23 +0x200 VbasicOpenAISpeakerServerURLLabel Hidden", translate("Server URL"))
		widget30.Info := "Basic.Synthesizer.Info"
		widget31 := editorGui.Add("Edit", "x" . x1 . " yp w" . w1 . " h21 W:Grow VbasicOpenAISpeakerServerURLEdit Hidden")
		widget31.Info := "Basic.Synthesizer.Info"

		widget32 := editorGui.Add("Text", "x" . x0 . " yp+24 w112 h23 +0x200 VbasicOpenAISpeakerAPIKeyLabel Hidden", translate("Service Key"))
		widget32.Info := "Basic.Synthesizer.Info"
		widget33 := editorGui.Add("Edit", "x" . x1 . " yp w" . w1 . " h21 Password W:Grow VbasicOpenAISpeakerAPIKeyEdit Hidden")
		widget33.Info := "Basic.Synthesizer.Info"

		widget34 := editorGui.Add("Text", "x" . x0 . " yp+24 w112 h23 +0x200 VbasicOpenAISpeakerLabel Hidden", translate("Model / Voice"))
		widget34.Info := "Basic.Synthesizer.Info"

		halfWidth := (Floor((w1 - 48) / 2) - 2)

		widget35 := editorGui.Add("Edit", "x" . (x1 + 24) . " yp w" . halfWidth . " W:Grow(0.5) VbasicOpenAISpeakerModelEdit Hidden")
		widget35.Info := "Basic.Synthesizer.Info"
		widget36 := editorGui.Add("Edit", "x" . ((x1 + 24) + (halfWidth + 3)) . " yp w" . (halfWidth - 1) . " X:Move(0.5) W:Grow(0.5) VbasicOpenAISpeakerVoiceEdit Hidden")
		widget36.Info := "Basic.Synthesizer.Info"

		widget37 := editorGui.Add("Button", "x" . x1 . " yp w23 h23 Default Hidden")
		widget37.Info := "Basic.Synthesizer.Play.Info"
		widget37.OnEvent("Click", (*) => this.testSpeaker())
		setButtonIcon(widget37, kIconsDirectory . "Start.ico", 1, "L4 T4 R4 B4")

		widget38 := editorGui.Add("Button", "x" . (x1 + 24 + 5) + (halfWidth * 2) . " yp w23 h23 X:Move Default Hidden")
		widget38.Info := "Basic.Synthesizer.Info"
		widget38.OnEvent("Click", (*) => this.editInstructions())
		setButtonIcon(widget38, kIconsDirectory . "General Settings.ico", 1, "L4 T4 R4 B4")

		this.iOpenAISynthesizerWidgets := [[editorGui["basicOpenAISpeakerServerURLLabel"], editorGui["basicOpenAISpeakerServerURLEdit"]]
										 , [editorGui["basicOpenAISpeakerAPIKeyLabel"], editorGui["basicOpenAISpeakerAPIKeyEdit"]]
										 , [editorGui["basicOpenAISpeakerLabel"], editorGui["basicOpenAISpeakerModelEdit"]
										  , editorGui["basicOpenAISpeakerVoiceEdit"], widget37, widget38]]

		widget25 := editorGui.Add("Text", "x" . x0 . " ys+24 w110 h23 +0x200 VbasicElevenLabsAPIKeyLabel Hidden", translate("Service Key"))
		widget25.Info := "Basic.Synthesizer.Info"
		widget26 := editorGui.Add("Edit", "x" . x1 . " yp w" . w1 . " h21 Password W:Grow VbasicElevenLabsAPIKeyEdit Hidden")
		widget26.Info := "Basic.Synthesizer.Info"
		widget26.OnEvent("Change", updateElevenLabsVoices)

		voices := [translate("Deactivated"), translate("Random")]

		widget27 := editorGui.Add("Text", "x" . x0 . " yp+24 w110 h23 +0x200 VbasicElevenLabsSpeakerLabel Hidden", translate("Voice"))
		widget27.Info := "Basic.Synthesizer.Info"
		widget28 := editorGui.Add("DropDownList", "x" . (x1 + 24) . " yp w" . (w1 - 24) . " W:Grow VbasicElevenLabsSpeakerDropDown Hidden", voices)
		widget28.Info := "Basic.Synthesizer.Info"

		widget29 := editorGui.Add("Button", "x" . x1 . " yp w23 h23 Default Hidden")
		widget29.Info := "Basic.Synthesizer.Play.Info"
		widget29.OnEvent("Click", (*) => this.testSpeaker())
		setButtonIcon(widget29, kIconsDirectory . "Start.ico", 1, "L4 T4 R4 B4")

		this.iElevenLabsSynthesizerWidgets := [[editorGui["basicElevenLabsAPIKeyLabel"], editorGui["basicElevenLabsAPIKeyEdit"]]
											 , [editorGui["basicElevenLabsSpeakerLabel"], editorGui["basicElevenLabsSpeakerDropDown"], widget29]]

		this.updateLanguage()

		this.hideControls(this.iTopWidgets)
		this.hideControls(this.iWindowsSynthesizerWidgets)
		this.hideControls(this.iAzureSynthesizerWidgets)
		this.hideControls(this.iGoogleSynthesizerWidgets)
		this.hideControls(this.iOpenAISynthesizerWidgets)
		this.hideControls(this.iElevenLabsSynthesizerWidgets)
		this.hideControls(this.iOtherWidgets)

		this.iSynthesizerMode := "Init"
	}

	loadFromConfiguration(configuration, load := false) {
		local synthesizer, languageCode, languages, ignore, speaker

		super.loadFromConfiguration(configuration)

		if load {
			languageCode := getMultiMapValue(configuration, "Voice Control", "Language", getLanguage())
			languages := availableLanguages()

			if languages.Has(languageCode)
				this.iLanguage := languages[languageCode]
			else
				this.iLanguage := languageCode

			synthesizer := getMultiMapValue(configuration, "Voice Control", "Synthesizer", "dotNET")

			if (InStr(synthesizer, "Azure") == 1)
				synthesizer := "Azure"

			if (InStr(synthesizer, "Google") == 1)
				synthesizer := "Google"

			if (InStr(synthesizer, "OpenAI") == 1)
				synthesizer := "OpenAI"

			if (InStr(synthesizer, "ElevenLabs") == 1)
				synthesizer := "ElevenLabs"

			this.Value["voiceSynthesizer"] := inList(["Windows", "dotNET", "Azure", "Google", "OpenAI", "ElevenLabs"], synthesizer)

			this.Value["azureSpeaker"] := getMultiMapValue(configuration, "Voice Control", "Speaker.Azure", true)
			this.Value["windowsSpeaker"] := getMultiMapValue(configuration, "Voice Control", "Speaker.Windows", getMultiMapValue(configuration, "Voice Control", "Speaker", true))
			this.Value["dotNETSpeaker"] := getMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", true)
			this.Value["googleSpeaker"] := getMultiMapValue(configuration, "Voice Control", "Speaker.Google", true)
			this.Value["openAISpeaker"] := getMultiMapValue(configuration, "Voice Control", "Speaker.OpenAI", "/")
			this.Value["elevenLabsSpeaker"] := getMultiMapValue(configuration, "Voice Control", "Speaker.ElevenLabs", true)

			this.Value["azureSubscriptionKey"] := getMultiMapValue(configuration, "Voice Control", "Azure.SubscriptionKey"
																				, getMultiMapValue(configuration, "Voice Control"
																												, "SubscriptionKey", ""))
			this.Value["azureTokenIssuer"] := getMultiMapValue(configuration, "Voice Control", "Azure.TokenIssuer"
																			, getMultiMapValue(configuration, "Voice Control"
																											, "TokenIssuer", ""))

			this.Value["googleAPIKeyFile"] := getMultiMapValue(configuration, "Voice Control", "Google.APIKeyFile"
																			, getMultiMapValue(configuration, "Voice Control"
																											, "APIKeyFile", ""))

			this.Value["openAISpeakerServerURL"] := getMultiMapValue(configuration, "Voice Control", "OpenAI.SpeakerServerURL", "")
			this.Value["openAISpeakerAPIKey"] := getMultiMapValue(configuration, "Voice Control", "OpenAI.SpeakerAPIKey", "")
			this.Value["openAISpeakerModel"] := getMultiMapValue(configuration, "Voice Control", "OpenAI.SpeakerModel", "")
			this.Value["openAISpeakerVoice"] := getMultiMapValue(configuration, "Voice Control", "OpenAI.SpeakerVoice", "")
			this.Value["openAISpeakerInstructions"] := StrReplace(getMultiMapValue(configuration, "Voice Control", "OpenAI.SpeakerInstructions", ""), "\n", "`n")

			this.Value["elevenLabsAPIKey"] := getMultiMapValue(configuration, "Voice Control", "ElevenLabs.APIKey"
																			, getMultiMapValue(configuration, "Voice Control", "APIKey", ""))

			this.Value["speakerVolume"] := getMultiMapValue(configuration, "Voice Control", "SpeakerVolume", 100)
			this.Value["speakerPitch"] := getMultiMapValue(configuration, "Voice Control", "SpeakerPitch", 0)
			this.Value["speakerSpeed"] := getMultiMapValue(configuration, "Voice Control", "SpeakerSpeed", 0)

			this.Value[synthesizer . "Speaker"] := getMultiMapValue(configuration, "Voice Control", "Speaker"
																				 , this.Value[synthesizer . "Speaker"])

			switch synthesizer, false {
				case "Azure":
					this.Value["azureSubscriptionKey"] := string2Values("|", getMultiMapValue(configuration, "Voice Control", "Synthesizer"))[3]
					this.Value["azureAPIKey"] := string2Values("|", getMultiMapValue(configuration, "Voice Control", "Synthesizer"))[3]
				case "Google":
					this.Value["googleAPIKeyFile"] := string2Values("|", getMultiMapValue(configuration, "Voice Control", "Synthesizer"))[2]
				case "OpenAI":
					this.Value["openAISpeakerServerURL"] := string2Values("|", getMultiMapValue(configuration, "Voice Control", "Synthesizer"))[2]
					this.Value["openAISpeakerAPIKey"] := string2Values("|", getMultiMapValue(configuration, "Voice Control", "Synthesizer"))[3]

					try
						this.Value["openAISpeakerModel"] := string2Values("/", getMultiMapValue(configuration, "Voice Control", "Speaker"
																											 , this.Value["openAISpeakerModel"] . "/"))[1]

					try
						this.Value["openAISpeakerVoice"] := string2Values("/", getMultiMapValue(configuration, "Voice Control", "Speaker"
																											 , "/" . this.Value["openAISpeakerVoice"]))[2]

					this.Value["openAISpeakerInstructions"] := string2Values("|", getMultiMapValue(configuration, "Voice Control", "Synthesizer"))[4]
				case "ElevenLabs":
					this.Value["elevenLabsAPIKey"] := string2Values("|", getMultiMapValue(configuration, "Voice Control", "Synthesizer"))[2]
			}

			if this.Configuration
				for ignore, speaker in ["windowsSpeaker", "dotNETSpeaker", "azureSpeaker", "googleSpeaker", "elevenLabsSpeaker"]
					if (this.Value[speaker] == true)
						this.Value[speaker] := translate("Random")
					else if (this.Value[speaker] == false)
						this.Value[speaker] := translate("Deactivated")
		}
	}

	saveToConfiguration(configuration) {
		local windowsSpeaker := this.Control["basicWindowsSpeakerDropDown"].Text
		local azureSpeaker := this.Control["basicAzureSpeakerDropDown"].Text
		local googleSpeaker := this.Control["basicGoogleSpeakerDropDown"].Text
		local elevenLabsSpeaker := this.Control["basicElevenLabsSpeakerDropDown"].Text

		super.saveToConfiguration(configuration)

		setMultiMapValue(configuration, "Voice Control", "Language", this.getCurrentLanguage())

		if (windowsSpeaker = translate("Random"))
			windowsSpeaker := true
		else if ((windowsSpeaker = translate("Deactivated")) || (windowsSpeaker = A_Space))
			windowsSpeaker := false

		if (azureSpeaker = translate("Random"))
			azureSpeaker := true
		else if ((azureSpeaker = translate("Deactivated")) || (azureSpeaker = A_Space))
			azureSpeaker := false

		if (this.Control["basicVoiceSynthesizerDropDown"].Value = 1) {
			setMultiMapValue(configuration, "Voice Control", "Synthesizer", "Windows")
			setMultiMapValue(configuration, "Voice Control", "Speaker", windowsSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Windows", windowsSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Google", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.OpenAI", "/")
			setMultiMapValue(configuration, "Voice Control", "Speaker.ElevenLabs", true)
		}
		else if (this.Control["basicVoiceSynthesizerDropDown"].Value = 2) {
			setMultiMapValue(configuration, "Voice Control", "Synthesizer", "dotNET")
			setMultiMapValue(configuration, "Voice Control", "Speaker", windowsSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Windows", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", windowsSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Google", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.OpenAI", "/")
			setMultiMapValue(configuration, "Voice Control", "Speaker.ElevenLabs", true)
		}
		else if (this.Control["basicVoiceSynthesizerDropDown"].Value = 3) {
			setMultiMapValue(configuration, "Voice Control", "Synthesizer", "Azure|" . Trim(this.Control["basicAzureTokenIssuerEdit"].Text) . "|" . Trim(this.Control["basicAzureSubscriptionKeyEdit"].Text))
			setMultiMapValue(configuration, "Voice Control", "Speaker", azureSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Windows", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Google", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.OpenAI", "/")
			setMultiMapValue(configuration, "Voice Control", "Speaker.ElevenLabs", true)
		}
		else if (this.Control["basicVoiceSynthesizerDropDown"].Value = 4) {
			setMultiMapValue(configuration, "Voice Control", "Synthesizer", "Google|" . Trim(this.Control["basicGoogleAPIKeyFileEdit"].Text))
			setMultiMapValue(configuration, "Voice Control", "Speaker", googleSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Windows", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Google", googleSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.OpenAI", "/")
			setMultiMapValue(configuration, "Voice Control", "Speaker.ElevenLabs", true)
		}
		else if (this.Control["basicVoiceSynthesizerDropDown"].Value = 5) {
			setMultiMapValue(configuration, "Voice Control", "Synthesizer"
										  , "OpenAI|" . Trim(this.Control["basicOpenAISpeakerServerURLEdit"].Text) . "|"
													  . Trim(this.Control["basicOpenAISpeakerAPIKeyEdit"].Text) . "|"
													  . StrReplace(StrReplace(Trim(this.Value["openAISpeakerInstructions"]), "`r`n", "\n"), "`n", "\n"))
			setMultiMapValue(configuration, "Voice Control", "Speaker", Trim(this.Control["basicOpenAISpeakerModelEdit"].Text) . "/" . Trim(this.Control["basicOpenAISpeakerVoiceEdit"].Text))
			setMultiMapValue(configuration, "Voice Control", "Speaker.Google", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Windows", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.ElevenLabs", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", true)
		}
		else {
			setMultiMapValue(configuration, "Voice Control", "Synthesizer", "ElevenLabs|" . Trim(this.Control["basicElevenLabsAPIKeyEdit"].Text))
			setMultiMapValue(configuration, "Voice Control", "Speaker", elevenLabsSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.ElevenLabs", elevenLabsSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Windows", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Google", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.OpenAI", "/")
		}

		setMultiMapValue(configuration, "Voice Control", "Speaker.Azure", azureSpeaker)
		setMultiMapValue(configuration, "Voice Control", "Azure.SubscriptionKey", Trim(this.Control["basicAzureSubscriptionKeyEdit"].Text))
		setMultiMapValue(configuration, "Voice Control", "Azure.TokenIssuer", Trim(this.Control["basicAzureTokenIssuerEdit"].Text))

		setMultiMapValue(configuration, "Voice Control", "Speaker.Google", googleSpeaker)
		setMultiMapValue(configuration, "Voice Control", "Google.APIKeyFile", Trim(this.Control["basicGoogleAPIKeyFileEdit"].Text))

		setMultiMapValue(configuration, "Voice Control", "Speaker.OpenAI", Trim(this.Control["basicOpenAISpeakerModelEdit"].Text) . "/" . Trim(this.Control["basicOpenAISpeakerVoiceEdit"].Text))
		setMultiMapValue(configuration, "Voice Control", "OpenAI.SpeakerServerURL", Trim(this.Control["basicOpenAISpeakerServerURLEdit"].Text))
		setMultiMapValue(configuration, "Voice Control", "OpenAI.SpeakerAPIKey", Trim(this.Control["basicOpenAISpeakerAPIKeyEdit"].Text))
		setMultiMapValue(configuration, "Voice Control", "OpenAI.SpeakerModel", Trim(this.Control["basicOpenAISpeakerModelEdit"].Text))
		setMultiMapValue(configuration, "Voice Control", "OpenAI.SpeakerVoice", Trim(this.Control["basicOpenAISpeakerVoiceEdit"].Text))
		setMultiMapValue(configuration, "Voice Control", "OpenAI.SpeakerInstructions"
													   , StrReplace(StrReplace(Trim(this.Value["openAISpeakerInstructions"]), "`r`n", "\n"), "`n", "\n"))

		setMultiMapValue(configuration, "Voice Control", "Speaker.ElevenLabs", elevenLabsSpeaker)
		setMultiMapValue(configuration, "Voice Control", "ElevenLabs.APIKey", Trim(this.Control["basicElevenLabsAPIKeyEdit"].Text))

		setMultiMapValue(configuration, "Voice Control", "SpeakerVolume", this.Control["basicSpeakerVolumeSlider"].Value)
		setMultiMapValue(configuration, "Voice Control", "SpeakerPitch", this.Control["basicSpeakerPitchSlider"].Value)
		setMultiMapValue(configuration, "Voice Control", "SpeakerSpeed", this.Control["basicSpeakerSpeedSlider"].Value)
	}

	loadConfigurator(configuration) {
		this.loadFromConfiguration(configuration, true)

		this.Control["basicVoiceSynthesizerDropDown"].Choose(this.Value["voiceSynthesizer"])
		this.Control["basicVoiceSynthesizerDropDown"].LastValue := this.Value["voiceSynthesizer"]

		this.Control["basicAzureSubscriptionKeyEdit"].Text := this.Value["azureSubscriptionKey"]
		this.Control["basicAzureTokenIssuerEdit"].Text := this.Value["azureTokenIssuer"]

		this.Control["basicGoogleAPIKeyFileEdit"].Text := this.Value["googleAPIKeyFile"]

		this.Control["basicGoogleAPIKeyFilePathButton"].Enabled := false

		this.Control["basicOpenAISpeakerServerURLEdit"].Text := this.Value["openAISpeakerServerURL"]
		this.Control["basicOpenAISpeakerAPIKeyEdit"].Text := this.Value["openAISpeakerAPIKey"]
		this.Control["basicOpenAISpeakerModelEdit"].Text := this.Value["openAISpeakerModel"]
		this.Control["basicOpenAISpeakerVoiceEdit"].Text := this.Value["openAISpeakerVoice"]

		this.Control["basicElevenLabsAPIKeyEdit"].Text := this.Value["elevenLabsAPIKey"]

		if (this.Value["voiceSynthesizer"] = 1)
			this.updateWindowsVoices(configuration)
		else if (this.Value["voiceSynthesizer"] = 2)
			this.updateDotNETVoices(configuration)

		this.updateAzureVoices(configuration)
		this.updateGoogleVoices(configuration)
		this.updateOpenAIVoices(configuration)
		this.updateElevenLabsVoices(configuration)

		this.Control["basicSpeakerVolumeSlider"].Value := this.Value["speakerVolume"]
		this.Control["basicSpeakerPitchSlider"].Value := this.Value["speakerPitch"]
		this.Control["basicSpeakerSpeedSlider"].Value := this.Value["speakerSpeed"]
	}

	findWidget(x, y, test := (*) => true) {
		local ignore, widget, cX, cY, cW, cH

		try {
			for ignore, widget in this.Window {
				ControlGetPos(&cX, &cY, &cW, &cH, widget)

				if ((x >= cX) && (x <= (cX + cW)) && (y >= cY) && (y <= (cY + cH)))
					if test(widget)
						return widget
			}
		}
		catch Any as exception {
			logError(exception)
		}

		return false
	}

	editSynthesizer(owner := false) {
		local hoverTask := false
		local window, x, y, w, h, configuration, hoverInfo

		this.createGui(this.Configuration)

		window := this.Window

		if owner
			window.Opt("+Owner" . owner.Hwnd)

		if getWindowPosition("Synthesizer Editor", &x, &y)
			window.Show("x" . x . " y" . y)
		else
			window.Show()

		this.loadConfigurator(this.Configuration)

		this.showWidgets()

		if (isSet(StepWizard) && isInstance(this.Manager, StepWizard)) {
			hoverInfo := (*) => this.Manager.SetupWizard.showInfo()
			hoverTask := PeriodicTask(() {
							 if WinActive(window)
								 OnMessage(0x0200, hoverInfo)
							 else
								 OnMessage(0x0200, hoverInfo, 0)
						 }, 1000, kLowPriority)

			hoverTask.Start()
		}

		try {
			loop
				Sleep(200)
			until this.iResult
		}
		finally {
			if hoverTask {
				hoverTask.Stop()

				OnMessage(0x0200, hoverInfo, 0)
			}
		}

		try {
			if (this.iResult = kOk) {
				configuration := newMultiMap()

				this.saveToConfiguration(configuration)

				return configuration
			}
			else
				return false
		}
		finally {
			window.Destroy()
		}
	}

	showWidgets() {
		local voiceSynthesizer := this.Control["basicVoiceSynthesizerDropDown"].Value

		if !voiceSynthesizer
			voiceSynthesizer := 1

		if (voiceSynthesizer == 1)
			this.showWindowsSynthesizerEditor()
		else if (voiceSynthesizer == 2)
			this.showDotNETSynthesizerEditor()
		else if (voiceSynthesizer == 3)
			this.showAzureSynthesizerEditor()
		else if (voiceSynthesizer == 4)
			this.showGoogleSynthesizerEditor()
		else if (voiceSynthesizer == 5)
			this.showOpenAISynthesizerEditor()
		else
			this.showElevenLabsSynthesizerEditor()
	}

	showWindowsSynthesizerEditor() {
		this.showControls(this.iTopWidgets)
		this.showControls(this.iWindowsSynthesizerWidgets)

		if ((this.iSynthesizerMode == false) || (this.iSynthesizerMode = "Init"))
			this.transposeControls(this.iOtherWidgets, 24 * this.iWindowsSynthesizerWidgets.Length, this.Window.TitleBarHeight)
		else
			throw "Internal error detected in SynthesizerEditor.showWindowsSynthesizerEditor..."

		this.showControls(this.iOtherWidgets)

		this.Control["basicWindowsSettingsButton"].Enabled := false

		this.iSynthesizerMode := "Windows"
	}

	showDotNETSynthesizerEditor() {
		this.showWindowsSynthesizerEditor()

		this.Control["basicWindowsSettingsButton"].Enabled := true

		this.iSynthesizerMode := "dotNET"
	}

	hideWindowsSynthesizerEditor() {
		this.hideControls(this.iTopWidgets)
		this.hideControls(this.iWindowsSynthesizerWidgets)
		this.hideControls(this.iOtherWidgets)

		if ((this.iSynthesizerMode == "Windows") || (this.iSynthesizerMode == "dotNET"))
			this.transposeControls(this.iOtherWidgets, -24 * this.iWindowsSynthesizerWidgets.Length, this.Window.TitleBarHeight)
		else if (this.iSynthesizerMode != "Init")
			throw "Internal error detected in SynthesizerEditor.hideWindowsSynthesizerEditor..."

		this.Control["basicWindowsSettingsButton"].Enabled := false

		this.iSynthesizerMode := false
	}

	hideDotNETSynthesizerEditor() {
		this.hideWindowsSynthesizerEditor()

		this.Control["basicWindowsSettingsButton"].Enabled := false
	}

	showAzureSynthesizerEditor() {
		this.showControls(this.iTopWidgets)
		this.showControls(this.iAzureSynthesizerWidgets)

		this.iTopAzureCredentialsVisible := true

		if ((this.iSynthesizerMode == false) || (this.iSynthesizerMode = "Init"))
			this.transposeControls(this.iOtherWidgets, 24 * this.iAzureSynthesizerWidgets.Length, this.Window.TitleBarHeight)
		else
			throw "Internal error detected in SynthesizerEditor.showAzureSynthesizerEditor..."

		this.showControls(this.iOtherWidgets)

		this.Control["basicWindowsSettingsButton"].Enabled := false

		this.iSynthesizerMode := "Azure"
	}

	hideAzureSynthesizerEditor() {
		this.hideControls(this.iTopWidgets)
		this.hideControls(this.iAzureSynthesizerWidgets)
		this.hideControls(this.iOtherWidgets)

		this.iTopAzureCredentialsVisible := false

		if (this.iSynthesizerMode == "Azure")
			this.transposeControls(this.iOtherWidgets, -24 * this.iAzureSynthesizerWidgets.Length, this.Window.TitleBarHeight)
		else if (this.iSynthesizerMode != "Init")
			throw "Internal error detected in SynthesizerEditor.hideAzureSynthesizerEditor..."

		this.Control["basicWindowsSettingsButton"].Enabled := false

		this.iSynthesizerMode := false
	}

	showGoogleSynthesizerEditor() {
		this.showControls(this.iTopWidgets)
		this.showControls(this.iGoogleSynthesizerWidgets)

		this.iTopGoogleCredentialsVisible := true

		if ((this.iSynthesizerMode == false) || (this.iSynthesizerMode = "Init"))
			this.transposeControls(this.iOtherWidgets, 24 * this.iGoogleSynthesizerWidgets.Length, this.Window.TitleBarHeight)
		else
			throw "Internal error detected in SynthesizerEditor.showGoogleSynthesizerEditor..."

		this.showControls(this.iOtherWidgets)

		this.Control["basicWindowsSettingsButton"].Enabled := false

		this.iSynthesizerMode := "Google"
	}

	hideGoogleSynthesizerEditor() {
		this.hideControls(this.iTopWidgets)
		this.hideControls(this.iGoogleSynthesizerWidgets)
		this.hideControls(this.iOtherWidgets)

		this.iTopGoogleCredentialsVisible := false

		if (this.iSynthesizerMode == "Google")
			this.transposeControls(this.iOtherWidgets, -24 * this.iGoogleSynthesizerWidgets.Length, this.Window.TitleBarHeight)
		else if (this.iSynthesizerMode != "Init")
			throw "Internal error detected in SynthesizerEditor.hideGoogleSynthesizerEditor..."

		this.Control["basicWindowsSettingsButton"].Enabled := false

		this.iSynthesizerMode := false
	}

	showOpenAISynthesizerEditor() {
		this.showControls(this.iTopWidgets)
		this.showControls(this.iOpenAISynthesizerWidgets)

		this.iTopOpenAICredentialsVisible := true

		if ((this.iSynthesizerMode == false) || (this.iSynthesizerMode = "Init"))
			this.transposeControls(this.iOtherWidgets, 24 * this.iOpenAISynthesizerWidgets.Length, this.Window.TitleBarHeight)
		else
			throw "Internal error detected in SynthesizerEditor.showOpenAISynthesizerEditor..."

		this.showControls(this.iOtherWidgets)

		this.Control["basicWindowsSettingsButton"].Enabled := false

		this.iSynthesizerMode := "OpenAI"
	}

	hideOpenAISynthesizerEditor() {
		this.hideControls(this.iTopWidgets)
		this.hideControls(this.iOpenAISynthesizerWidgets)
		this.hideControls(this.iOtherWidgets)

		this.iTopOpenAICredentialsVisible := false

		if (this.iSynthesizerMode == "OpenAI")
			this.transposeControls(this.iOtherWidgets, -24 * this.iOpenAISynthesizerWidgets.Length, this.Window.TitleBarHeight)
		else if (this.iSynthesizerMode != "Init")
			throw "Internal error detected in SynthesizerEditor.hideOpenAISynthesizerEditor..."

		this.Control["basicWindowsSettingsButton"].Enabled := false

		this.iSynthesizerMode := false
	}

	showElevenLabsSynthesizerEditor() {
		this.showControls(this.iTopWidgets)
		this.showControls(this.iElevenLabsSynthesizerWidgets)

		this.iTopElevenLabsCredentialsVisible := true

		if ((this.iSynthesizerMode == false) || (this.iSynthesizerMode = "Init"))
			this.transposeControls(this.iOtherWidgets, 24 * this.iElevenLabsSynthesizerWidgets.Length, this.Window.TitleBarHeight)
		else
			throw "Internal error detected in SynthesizerEditor.showElevenLabsSynthesizerEditor..."

		this.showControls(this.iOtherWidgets)

		this.Control["basicWindowsSettingsButton"].Enabled := false

		this.iSynthesizerMode := "ElevenLabs"
	}

	hideElevenLabsSynthesizerEditor() {
		this.hideControls(this.iTopWidgets)
		this.hideControls(this.iElevenLabsSynthesizerWidgets)
		this.hideControls(this.iOtherWidgets)

		this.iTopElevenLabsCredentialsVisible := false

		if (this.iSynthesizerMode == "ElevenLabs")
			this.transposeControls(this.iOtherWidgets, -24 * this.iElevenLabsSynthesizerWidgets.Length, this.Window.TitleBarHeight)
		else if (this.iSynthesizerMode != "Init")
			throw "Internal error detected in SynthesizerEditor.hideWindowsSynthesizerEditor..."

		this.Control["basicWindowsSettingsButton"].Enabled := false

		this.iSynthesizerMode := false
	}

	getCurrentLanguage() {
		local voiceLanguage := this.iLanguage
		local languages := availableLanguages()
		local languageCode, code, language, ignore, grammarFile, grammarLanguageCode

		for code, language in availableLanguages()
			if (language = voiceLanguage)
				return code

		for ignore, grammarFile in getFileNames(this.Assistant . ".grammars.*", kUserGrammarsDirectory, kGrammarsDirectory) {
			SplitPath(grammarFile, , , &grammarLanguageCode)

			if languages.Has(grammarLanguageCode)
				language := languages[grammarLanguageCode]
			else
				language := grammarLanguageCode

			if (language = voiceLanguage)
				return grammarLanguageCode
		}

		return voiceLanguage
	}

	updateLanguage() {
		if (this.Control["basicVoiceSynthesizerDropDown"].Value = 1)
			this.updateWindowsVoices()
		else if (this.Control["basicVoiceSynthesizerDropDown"].Value = 2)
			this.updateDotNETVoices()

		this.updateAzureVoices()
		this.updateGoogleVoices()
		this.updateOpenAIVoices()
		this.updateElevenLabsVoices()
	}

	loadVoices(synthesizer, configuration) {
		local language := this.getCurrentLanguage()
		local voices := SpeechSynthesizer(synthesizer, true, language).Voices[language].Clone()

		voices.InsertAt(1, translate("Random"))
		voices.InsertAt(1, translate("Deactivated"))

		return voices
	}

	loadWindowsVoices(configuration, &windowsSpeaker) {
		if configuration
			windowsSpeaker := getMultiMapValue(configuration, "Voice Control", "Speaker.Windows", getMultiMapValue(this.Configuration, "Voice Control", "Speaker", true))
		else {
			windowsSpeaker := this.Control["basicWindowsSpeakerDropDown"].Text

			configuration := this.Configuration
		}

		return this.loadVoices("Windows", configuration)
	}

	loadDotNETVoices(configuration, &dotNETSpeaker)	{
		if configuration
			dotNETSpeaker := getMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", true)
		else {
			dotNETSpeaker := this.Control["basicWindowsSpeakerDropDown"].Text

			configuration := this.Configuration
		}

		return this.loadVoices("dotNET", configuration)
	}

	updateWindowsVoices(configuration := false) {
		local windowsSpeaker, voices, chosen

		voices := this.loadWindowsVoices(configuration, &windowsSpeaker)

		if (windowsSpeaker == false)
			chosen := 1
		else {
			chosen := inList(voices, windowsSpeaker)

			if (chosen == 0)
				chosen := 2
		}

		this.Control["basicWindowsSpeakerDropDown"].Delete()
		this.Control["basicWindowsSpeakerDropDown"].Add(voices)
		this.Control["basicWindowsSpeakerDropDown"].Choose(chosen)
	}

	updateDotNETVoices(configuration := false) {
		local dotNETSpeaker, voices, chosen

		voices := this.loadDotNETVoices(configuration, &dotNETSpeaker)

		if (dotNETSpeaker == false)
			chosen := 1
		else {
			chosen := inList(voices, dotNETSpeaker)

			if (chosen == 0)
				chosen := 2
		}

		this.Control["basicWindowsSpeakerDropDown"].Delete()
		this.Control["basicWindowsSpeakerDropDown"].Add(voices)
		this.Control["basicWindowsSpeakerDropDown"].Choose(chosen)
	}

	updateGoogleVoices(configuration := false) {
		local voices := []
		local googleSpeaker, chosen, language

		if configuration
			googleSpeaker := getMultiMapValue(configuration, "Voice Control", "Speaker.Google", true)
		else {
			googleSpeaker := this.Control["basicGoogleSpeakerDropDown"].Text

			configuration := this.Configuration
		}

		if (configuration && !googleSpeaker)
			googleSpeaker := getMultiMapValue(configuration, "Voice Control", "Speaker.Google", true)

		if (Trim(this.Control["basicGoogleAPIKeyFileEdit"].Text) != "") {
			language := this.getCurrentLanguage()

			voices := SpeechSynthesizer("Google|" . Trim(this.Control["basicGoogleAPIKeyFileEdit"].Text), true, language).Voices[language].Clone()
		}

		voices.InsertAt(1, translate("Random"))
		voices.InsertAt(1, translate("Deactivated"))

		if (googleSpeaker == false)
			chosen := 1
		else {
			chosen := inList(voices, googleSpeaker)

			if (chosen == 0)
				chosen := 2
		}

		this.Control["basicGoogleSpeakerDropDown"].Delete()
		this.Control["basicGoogleSpeakerDropDown"].Add(voices)
		this.Control["basicGoogleSpeakerDropDown"].Choose(chosen)
	}

	updateAzureVoices(configuration := false) {
		local voices := []
		local language, chosen, azureSpeaker

		if configuration
			azureSpeaker := getMultiMapValue(configuration, "Voice Control", "Speaker.Azure", true)
		else {
			configuration := this.Configuration

			azureSpeaker := this.Control["basicAzureSpeakerDropDown"].Text
		}

		if (configuration && !azureSpeaker)
			azureSpeaker := getMultiMapValue(configuration, "Voice Control", "Speaker.Azure", true)

		if ((Trim(this.Control["basicAzureSubscriptionKeyEdit"].Text) != "") && (Trim(this.Control["basicAzureTokenIssuerEdit"].Text) != "")) {
			language := this.getCurrentLanguage()

			voices := SpeechSynthesizer("Azure|" . Trim(this.Control["basicAzureTokenIssuerEdit"].Text) . "|" . Trim(this.Control["basicAzureSubscriptionKeyEdit"].Text), true, language).Voices[language].Clone()
		}

		voices.InsertAt(1, translate("Random"))
		voices.InsertAt(1, translate("Deactivated"))

		if (azureSpeaker == false)
			chosen := 1
		else {
			chosen := inList(voices, azureSpeaker)

			if (chosen == 0)
				chosen := 2
		}

		this.Control["basicAzureSpeakerDropDown"].Delete()
		this.Control["basicAzureSpeakerDropDown"].Add(voices)
		this.Control["basicAzureSpeakerDropDown"].Choose(chosen)
	}

	updateOpenAIVoices(configuration := false) {
	}

	updateElevenLabsVoices(configuration := false) {
		local voices := []
		local elevenLabsSpeaker, chosen, language

		if configuration
			elevenLabsSpeaker := getMultiMapValue(configuration, "Voice Control", "Speaker.ElevenLabs", true)
		else {
			elevenLabsSpeaker := this.Control["basicElevenLabsSpeakerDropDown"].Text

			configuration := this.Configuration
		}

		if (configuration && !elevenLabsSpeaker)
			elevenLabsSpeaker := getMultiMapValue(configuration, "Voice Control", "Speaker.ElevenLabs", true)

		if (Trim(this.Control["basicElevenLabsAPIKeyEdit"].Text) != "") {
			language := this.getCurrentLanguage()

			voices := SpeechSynthesizer("ElevenLabs|" . Trim(this.Control["basicElevenLabsAPIKeyEdit"].Text), true, language).Voices[language].Clone()
		}

		voices.InsertAt(1, translate("Random"))
		voices.InsertAt(1, translate("Deactivated"))

		if (elevenLabsSpeaker == false)
			chosen := 1
		else {
			chosen := inList(voices, elevenLabsSpeaker)

			if (chosen == 0)
				chosen := 2
		}

		this.Control["basicElevenLabsSpeakerDropDown"].Delete()
		this.Control["basicElevenLabsSpeakerDropDown"].Add(voices)
		this.Control["basicElevenLabsSpeakerDropDown"].Choose(chosen)
	}

	showControls(widgets) {
		local ignore, widget, widgetPart

		for ignore, widget in widgets
			for ignore, widgetPart in widget {
				widgetPart.Enabled := true
				widgetPart.Visible := true
			}
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

	testSpeaker() {
		global kSimulatorConfiguration

		local configuration, synthesizer, language, voice, curSimulatorConfiguration

		if (isSet(StepWizard) && isInstance(this.Manager, StepWizard)) {
			configuration := newMultiMap()

			this.Manager.SetupWizard.saveToConfiguration(configuration)
		}
		else
			configuration := this.Manager.getConfiguration()

		this.saveToConfiguration(configuration)

		curSimulatorConfiguration := kSimulatorConfiguration

		kSimulatorConfiguration := configuration

		SpeechSynthesizer.initializePostProcessing()

		try {
			synthesizer := getMultiMapValue(configuration, "Voice Control", "Synthesizer", "dotNET")
			language := getMultiMapValue(configuration, "Voice Control", "Language", getLanguage())
			voice := getMultiMapValue(configuration, "Voice Control", "Speaker")

			synthesizer := SpeechSynthesizer(synthesizer, voice, language)

			synthesizer.setVolume(getMultiMapValue(configuration, "Voice Control", "SpeakerVolume"))
			synthesizer.setPitch(getMultiMapValue(configuration, "Voice Control", "SpeakerPitch"))
			synthesizer.setRate(getMultiMapValue(configuration, "Voice Control", "SpeakerSpeed"))

			if (isSet(StepWizard) && isInstance(this.Manager, StepWizard))
				language := this.Manager.assistantLanguage(this.Assistant, true)
			else
				language := this.Manager.getLanguage()

			if isObject(language) {
				synthesizer.setTranslator(Translator(language.Service, "English", language.Language, language.APIKey, language.Arguments*))

				synthesizer.speakTest("en")
			}
			else
				synthesizer.speakTest()
		}
		finally {
			kSimulatorConfiguration := curSimulatorConfiguration

			SpeechSynthesizer.initializePostProcessing()
		}
	}

	editInstructions(command := false, *) {
		local x, y, w, h, instructionsGui

		static result

		if (command == kOk)
			result := kOk
		else if (command == kCancel)
			result := kCancel
		else {
			result := false

			instructionsGui := Window({Descriptor: "Voice Synthesizer Editor.Instructions", Resizeable: true, Options: "0x400000"}
									, translate("Instructions"))

			instructionsGui.SetFont("Norm", "Arial")

			instructionsGui.Add("Edit", "x16 y16 w454 h200 W:Grow H:Grow Multi vinstructionEdit", this.Value["openAISpeakerInstructions"])

			instructionsGui.Add("Button", "x160 yp+210 w80 h23 Default Y:Move X:Move(0.5)", translate("Ok")).OnEvent("Click", ObjBindMethod(this, "editInstructions", kOk))
			instructionsGui.Add("Button", "x246 yp w80 h23 Y:Move X:Move(0.5)", translate("&Cancel")).OnEvent("Click", ObjBindMethod(this, "editInstructions", kCancel))

			instructionsGui.Opt("+Owner" . this.Window.Hwnd)

			this.Window.Block()

			try {
				instructionsGui.Show("AutoSize Center")

				if getWindowPosition("Voice Synthesizer Editor.Instructions", &x, &y)
					instructionsGui.Show("x" . x . " y" . y)
				else
					instructionsGui.Show("AutoSize Center")

				if getWindowSize("Voice Synthesizer Editor.Instructions", &w, &h)
					instructionsGui.Resize("Initialize", w, h)

				while !result
					Sleep(100)

				try {
					if (result == kCancel)
						return false
					else if (result == kOk)
						return (this.Value["openAISpeakerInstructions"] := instructionsGui["instructionEdit"].Text)
				}
				finally {
					instructionsGui.Destroy()
				}
			}
			finally {
				this.Window.Unblock()
			}
		}
	}
}