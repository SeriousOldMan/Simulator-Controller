;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Simple Setup Wizard            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class SimpleSetupWizard extends StepWizard {
	iCurrentStep := 0
	iAssistantNames := CaseInsenseMap()
	iVoiceSettings := CaseInsenseMap()
	
	Pages {
		Get {
			return 6
		}
	}
	
	createGui(wizard, x, y, width, height) {
		local window := this.Window
		local labelWidth := width - 30
		local labelX := x + 35
		local labelY := y + 8
		local choices := []
		local languages := availableLanguages()
		local code, language
		
		for code, language in languages
			choices.Push(language)
		
		window.SetFont("s10 Bold", "Arial")
		
		widget1 := window.Add("Picture", "x" . x . " y" . y . " w30 h30 Hidden", kResourcesDirectory . "Setup\Images\Gears.ico")
		widget2 := window.Add("Text", "x" . labelX . " y" . labelY . " w" . labelWidth . " h26 Hidden", translate("Simple Setup"))
		
		window.SetFont("s8 Norm", "Arial")
		
		this.registerWidgets(1, widget1, widget2)
		this.createStep1Widgets(window, x, y + 40, width, height - 40)
		this.createStep2Widgets(window, x, y + 40, width, height - 40)
		this.createStep3Widgets(window, x, y + 40, width, height - 40)
		this.createStep4Widgets(window, x, y + 40, width, height - 40)
		this.createStep5Widgets(window, x, y + 40, width, height - 40)
		this.createStep6Widgets(window, x, y + 40, width, height - 40)
	}
	
	createStep1Widgets(window, x, y, width, height) {
		local languages := availableLanguages()
		local choices := []
		local code, language
		
		for code, language in languages
			choices.Push(language)
		
		window.SetFont("Bold", "Arial")
		widget1 := window.Add("Text", "x" . x . " y" . y . " w" . width . " h23 Hidden", translate("Step 1: Language Selection"))
		window.SetFont("Norm", "Arial")
		
		widget2 := window.Add("Text", "x" . x . " yp+30 w" . width . " h40 Hidden", translate("Choose your preferred language for the interface and voice assistants:"))
		widget3 := window.Add("DropDownList", "x" . x . " yp+45 w200 VsimpleLanguageDropDown Hidden", choices)
		
		this.registerWidgets(2, widget1, widget2, widget3)
	}
	
	createStep2Widgets(window, x, y, width, height) {
		window.SetFont("Bold", "Arial")
		widget1 := window.Add("Text", "x" . x . " y" . y . " w" . width . " h23 Hidden", translate("Step 2: Voice Synthesizer"))
		window.SetFont("Norm", "Arial")
		
		widget2 := window.Add("Text", "x" . x . " yp+30 w" . width . " h40 Hidden", translate("Select your voice synthesizer (API keys required for cloud services):"))
		widget3 := window.Add("DropDownList", "x" . x . " yp+45 w200 VsimpleSynthesizerDropDown Hidden", [translate("Windows"), translate("dotNET"), translate("Azure"), translate("Google"), translate("OpenAI"), translate("ElevenLabs")])
		
		widget4 := window.Add("Text", "x" . x . " yp+40 w120 h23 +0x200 VsimpleAPIKeyLabel Hidden", translate("API Key:"))
		widget5 := window.Add("Edit", "x" . (x + 125) . " yp w300 h21 Password VsimpleAPIKeyEdit Hidden")
		
		widget6 := window.Add("Text", "x" . x . " yp+30 w120 h23 +0x200 VsimpleTokenIssuerLabel Hidden", translate("Token Issuer:"))
		widget7 := window.Add("Edit", "x" . (x + 125) . " yp w300 h21 VsimpleTokenIssuerEdit Hidden")
		
		widget8 := window.Add("Text", "x" . x . " yp+30 w120 h23 +0x200 VsimpleServerURLLabel Hidden", translate("Server URL:"))
		widget9 := window.Add("Edit", "x" . (x + 125) . " yp w300 h21 VsimpleServerURLEdit Hidden")
		
		widget10 := window.Add("Text", "x" . x . " yp+30 w120 h23 +0x200 VsimpleModelLabel Hidden", translate("Model:"))
		widget11 := window.Add("Edit", "x" . (x + 125) . " yp w300 h21 VsimpleModelEdit Hidden")
		
		widget12 := window.Add("Text", "x" . x . " yp+35 w" . width . " h23 VsimpleSynthInstructionsLabel Hidden", translate("Setup Instructions:"))
		widget13 := window.Add("Edit", "x" . x . " yp+25 w" . width . " h100 ReadOnly Multi VsimpleSynthInstructionsEdit Hidden")
		
		widget3.OnEvent("Change", (*) => this.updateSynthesizerFields())
		
		this.registerWidgets(3, widget1, widget2, widget3, widget4, widget5, widget6, widget7, widget8, widget9, widget10, widget11, widget12, widget13)
	}
	
	createStep3Widgets(window, x, y, width, height) {
		local assistants := ["Driving Coach", "Race Engineer", "Race Strategist", "Race Spotter"]
		local defaultNames := ["Aiden", "Jona", "Khato", "Elisa"]
		local i, yPos, widgets := []
		
		window.SetFont("Bold", "Arial")
		widgets.Push(window.Add("Text", "x" . x . " y" . y . " w" . width . " h23 Hidden", translate("Step 3: Assistant Configuration")))
		window.SetFont("Norm", "Arial")
		
		widgets.Push(window.Add("Text", "x" . x . " yp+30 w" . width . " h40 Hidden", translate("Choose which assistants to enable and set their names:")))
		
		yPos := y + 75
		
		loop 4 {
			i := A_Index
			
			widgets.Push(window.Add("CheckBox", "x" . x . " y" . yPos . " w20 h21 Hidden Checked Vsimple" . StrReplace(assistants[i], " ", "") . "EnabledCheck"))
			widgets.Push(window.Add("Text", "x" . (x + 25) . " y" . yPos . " w150 h23 +0x200 Hidden", translate(assistants[i])))
			widgets.Push(window.Add("Edit", "x" . (x + 180) . " y" . yPos . " w150 h21 Hidden Vsimple" . StrReplace(assistants[i], " ", "") . "NameEdit", defaultNames[i]))
			
			yPos += 30
		}
		
		this.registerWidgets(4, widgets*)
	}
	
	createStep4Widgets(window, x, y, width, height) {
		window.SetFont("Bold", "Arial")
		widget1 := window.Add("Text", "x" . x . " y" . y . " w" . width . " h23 Hidden", translate("Step 4: Voice Selection"))
		window.SetFont("Norm", "Arial")
		
		widget2 := window.Add("Text", "x" . x . " yp+30 w" . width . " h40 Hidden", translate("Select voice for each enabled assistant:"))
		
		widget3 := window.Add("Text", "x" . x . " yp+45 w150 h23 +0x200 Hidden", translate("Driving Coach:"))
		widget4 := window.Add("DropDownList", "x" . (x + 155) . " yp w300 Hidden VsimpleDrivingCoachVoiceDropDown", [translate("Random")])
		
		widget5 := window.Add("Text", "x" . x . " yp+30 w150 h23 +0x200 Hidden", translate("Race Engineer:"))
		widget6 := window.Add("DropDownList", "x" . (x + 155) . " yp w300 Hidden VsimpleRaceEngineerVoiceDropDown", [translate("Random")])
		
		widget7 := window.Add("Text", "x" . x . " yp+30 w150 h23 +0x200 Hidden", translate("Race Strategist:"))
		widget8 := window.Add("DropDownList", "x" . (x + 155) . " yp w300 Hidden VsimpleRaceStrategistVoiceDropDown", [translate("Random")])
		
		widget9 := window.Add("Text", "x" . x . " yp+30 w150 h23 +0x200 Hidden", translate("Race Spotter:"))
		widget10 := window.Add("DropDownList", "x" . (x + 155) . " yp w300 Hidden VsimpleRaceSpotterVoiceDropDown", [translate("Random")])
		
		this.registerWidgets(5, widget1, widget2, widget3, widget4, widget5, widget6, widget7, widget8, widget9, widget10)
	}
	
	createStep5Widgets(window, x, y, width, height) {
		window.SetFont("Bold", "Arial")
		widget1 := window.Add("Text", "x" . x . " y" . y . " w" . width . " h23 Hidden", translate("Step 5: AI Configuration (Optional)"))
		window.SetFont("Norm", "Arial")
		
		widget2 := window.Add("Text", "x" . x . " yp+30 w" . width . " h40 Hidden", translate("Configure AI for advanced assistant features:"))
		widget3 := window.Add("CheckBox", "x" . x . " yp+45 w300 h21 Hidden VsimpleEnableAICheck", translate("Enable AI Integration"))
		widget3.OnEvent("Click", (*) => this.updateAIFields())
		
		widget4 := window.Add("Text", "x" . x . " yp+35 w120 h23 +0x200 VsimpleAIProviderLabel Hidden", translate("AI Provider:"))
		widget5 := window.Add("DropDownList", "x" . (x + 125) . " yp w200 Hidden VsimpleAIProviderDropDown", ["OpenAI", "Azure OpenAI", "Google Gemini", "Anthropic Claude"])
		widget5.OnEvent("Change", (*) => this.updateAIInstructions())
		
		widget6 := window.Add("Text", "x" . x . " yp+35 w120 h23 +0x200 VsimpleAIAPIKeyLabel Hidden", translate("API Key:"))
		widget7 := window.Add("Edit", "x" . (x + 125) . " yp w400 h21 Password VsimpleAIAPIKeyEdit Hidden")
		
		widget8 := window.Add("Text", "x" . x . " yp+35 w" . width . " h23 VsimpleAIInstructionsLabel Hidden", translate("Setup Instructions:"))
		widget9 := window.Add("Edit", "x" . x . " yp+25 w" . width . " h150 ReadOnly Multi VsimpleAIInstructionsEdit Hidden")
		
		this.registerWidgets(6, widget1, widget2, widget3, widget4, widget5, widget6, widget7, widget8, widget9)
	}
	
	createStep6Widgets(window, x, y, width, height) {
		window.SetFont("Bold", "Arial")
		widget1 := window.Add("Text", "x" . x . " y" . y . " w" . width . " h23 Hidden", translate("Step 6: Confirmation"))
		window.SetFont("Norm", "Arial")
		
		widget2 := window.Add("Text", "x" . x . " yp+30 w" . width . " h60 Hidden", translate("Review your configuration:"))
		widget3 := window.Add("Edit", "x" . x . " yp+65 w" . width . " h200 ReadOnly Multi VsimpleSummaryEdit Hidden")
		
		widget4 := window.Add("Button", "x" . (x + Round(width / 2) - 45) . " yp+210 w90 h40 Hidden", translate("Generate"))
		widget4.OnEvent("Click", (*) => this.finishSetup())
		
		this.registerWidgets(7, widget1, widget2, widget3, widget4)
	}
	
	showPage(page) {
		super.showPage(page)
		
		if (page == 2)
			this.initializeStep1()
		else if (page == 3)
			this.initializeStep2()
		else if (page == 4)
			this.initializeStep3()
		else if (page == 5)
			this.initializeStep4()
		else if (page == 6)
			this.initializeStep5()
		else if (page == 7)
			this.initializeStep6()
	}
	
	savePage(page) {
		if super.savePage(page) {
			if (page == 2)
				return this.saveStep1()
			else if (page == 3)
				return this.saveStep2()
			else if (page == 4)
				return this.saveStep3()
			else if (page == 5)
				return this.saveStep4()
			else if (page == 6)
				return this.saveStep5()
			else if (page == 7)
				return this.saveStep6()
			
			return true
		}
		
		return false
	}
	
	initializeStep1() {
		local languages := availableLanguages()
		local currentLang := getLanguage()
		local chosen := 1
		local code, language, index := 1
		
		for code, language in languages {
			if (code = currentLang)
				chosen := index
			index++
		}
		
		this.Control["simpleLanguageDropDown"].Choose(chosen)
	}
	
	saveStep1() {
		return true
	}
	
	initializeStep2() {
		this.Control["simpleSynthesizerDropDown"].Choose(1)
		this.updateSynthesizerFields()
	}
	
	saveStep2() {
		local synthIndex := this.Control["simpleSynthesizerDropDown"].Value
		
		if (synthIndex >= 3) {
			if (Trim(this.Control["simpleAPIKeyEdit"].Text) = "") {
				MsgBox(translate("Please enter an API key for the selected synthesizer."), translate("Error"), 16)
				return false
			}
		}
		
		return true
	}
	
	initializeStep3() {
	}
	
	saveStep3() {
		local hasEnabled := false
		
		if this.Control["simpleDrivingCoachEnabledCheck"].Value
			hasEnabled := true
		if this.Control["simpleRaceEngineerEnabledCheck"].Value
			hasEnabled := true
		if this.Control["simpleRaceStrategistEnabledCheck"].Value
			hasEnabled := true
		if this.Control["simpleRaceSpotterEnabledCheck"].Value
			hasEnabled := true
		
		if !hasEnabled {
			MsgBox(translate("Please enable at least one assistant."), translate("Error"), 16)
			return false
		}
		
		return true
	}
	
	initializeStep4() {
		this.loadVoicesForAssistants()
	}
	
	saveStep4() {
		return true
	}
	
	initializeStep5() {
		this.Control["simpleEnableAICheck"].Value := 0
		this.Control["simpleAIProviderDropDown"].Choose(1)
		this.updateAIFields()
	}
	
	saveStep5() {
		if this.Control["simpleEnableAICheck"].Value {
			if (Trim(this.Control["simpleAIAPIKeyEdit"].Text) = "") {
				MsgBox(translate("Please enter an API key for the selected AI provider."), translate("Error"), 16)
				return false
			}
		}
		return true
	}
	
	initializeStep6() {
		this.updateSummary()
	}
	
	saveStep6() {
		return true
	}
	
	updateSynthesizerFields() {
		local synthIndex := this.Control["simpleSynthesizerDropDown"].Value
		local window := this.Window
		
		window["simpleAPIKeyLabel"].Visible := false
		window["simpleAPIKeyEdit"].Visible := false
		window["simpleTokenIssuerLabel"].Visible := false
		window["simpleTokenIssuerEdit"].Visible := false
		window["simpleServerURLLabel"].Visible := false
		window["simpleServerURLEdit"].Visible := false
		window["simpleModelLabel"].Visible := false
		window["simpleModelEdit"].Visible := false
		window["simpleSynthInstructionsLabel"].Visible := false
		window["simpleSynthInstructionsEdit"].Visible := false
		
		if (synthIndex = 3) {
			window["simpleAPIKeyLabel"].Visible := true
			window["simpleAPIKeyEdit"].Visible := true
			window["simpleTokenIssuerLabel"].Visible := true
			window["simpleTokenIssuerEdit"].Visible := true
			window["simpleSynthInstructionsLabel"].Visible := true
			window["simpleSynthInstructionsEdit"].Visible := true
			this.updateSynthesizerInstructions("Azure")
		}
		else if (synthIndex = 4) {
			window["simpleAPIKeyLabel"].Visible := true
			window["simpleAPIKeyEdit"].Visible := true
			window["simpleSynthInstructionsLabel"].Visible := true
			window["simpleSynthInstructionsEdit"].Visible := true
			this.updateSynthesizerInstructions("Google")
		}
		else if (synthIndex = 5) {
			window["simpleServerURLLabel"].Visible := true
			window["simpleServerURLEdit"].Visible := true
			window["simpleAPIKeyLabel"].Visible := true
			window["simpleAPIKeyEdit"].Visible := true
			window["simpleModelLabel"].Visible := true
			window["simpleModelEdit"].Visible := true
			window["simpleSynthInstructionsLabel"].Visible := true
			window["simpleSynthInstructionsEdit"].Visible := true
			this.updateSynthesizerInstructions("OpenAI")
		}
		else if (synthIndex = 6) {
			window["simpleAPIKeyLabel"].Visible := true
			window["simpleAPIKeyEdit"].Visible := true
			window["simpleSynthInstructionsLabel"].Visible := true
			window["simpleSynthInstructionsEdit"].Visible := true
			this.updateSynthesizerInstructions("ElevenLabs")
		}
	}
	
	updateSynthesizerInstructions(provider) {
		local instructions := ""
		
		if (provider = "Azure")
			instructions := "1. Go to Azure Portal (portal.azure.com)`n2. Create an Azure AI Speech resource`n3. Go to Keys and Endpoint section`n4. Copy Key 1 as API Key`n5. Copy the Region (e.g., eastus) as Token Issuer`n6. Supports multiple languages and voices"
		else if (provider = "Google")
			instructions := "1. Go to Google Cloud Console`n2. Enable Cloud Text-to-Speech API`n3. Create credentials (API Key)`n4. Copy the API key`n5. Supports 220+ voices in 40+ languages"
		else if (provider = "OpenAI")
			instructions := "1. Go to https://platform.openai.com/api-keys`n2. Create an API key`n3. Enter API endpoint URL (default: https://api.openai.com/v1)`n4. Specify model (tts-1 or tts-1-hd)`n5. Supports multiple voice styles"
		else if (provider = "ElevenLabs")
			instructions := "1. Go to https://elevenlabs.io/`n2. Sign up for an account`n3. Navigate to Profile Settings`n4. Copy your API Key`n5. Offers highly realistic AI voices`n6. Free tier: 10,000 characters/month"
		
		this.Control["simpleSynthInstructionsEdit"].Text := instructions
	}
	
	loadVoicesForAssistants() {
		local synthIndex := this.Control["simpleSynthesizerDropDown"].Value
		local synthesizer := ""
		local language := this.getSelectedLanguage()
		local voices := []
		
		if (synthIndex = 1)
			synthesizer := "Windows"
		else if (synthIndex = 2)
			synthesizer := "dotNET"
		else if (synthIndex = 3)
			synthesizer := "Azure|" . Trim(this.Control["simpleTokenIssuerEdit"].Text) . "|" . Trim(this.Control["simpleAPIKeyEdit"].Text)
		else if (synthIndex = 4)
			synthesizer := "Google|" . Trim(this.Control["simpleAPIKeyEdit"].Text)
		else if (synthIndex = 5)
			synthesizer := "OpenAI|" . Trim(this.Control["simpleServerURLEdit"].Text) . "|" . Trim(this.Control["simpleAPIKeyEdit"].Text) . "|"
		else if (synthIndex = 6)
			synthesizer := "ElevenLabs|" . Trim(this.Control["simpleAPIKeyEdit"].Text)
		
		try {
			voices := SpeechSynthesizer(synthesizer, true, language).Voices[language].Clone()
		}
		catch {
			voices := []
		}
		
		voices.InsertAt(1, translate("Random"))
		
		this.Control["simpleDrivingCoachVoiceDropDown"].Delete()
		this.Control["simpleDrivingCoachVoiceDropDown"].Add(voices)
		this.Control["simpleDrivingCoachVoiceDropDown"].Choose(1)
		
		this.Control["simpleRaceEngineerVoiceDropDown"].Delete()
		this.Control["simpleRaceEngineerVoiceDropDown"].Add(voices)
		this.Control["simpleRaceEngineerVoiceDropDown"].Choose(1)
		
		this.Control["simpleRaceStrategistVoiceDropDown"].Delete()
		this.Control["simpleRaceStrategistVoiceDropDown"].Add(voices)
		this.Control["simpleRaceStrategistVoiceDropDown"].Choose(1)
		
		this.Control["simpleRaceSpotterVoiceDropDown"].Delete()
		this.Control["simpleRaceSpotterVoiceDropDown"].Add(voices)
		this.Control["simpleRaceSpotterVoiceDropDown"].Choose(1)
	}
	
	getSelectedLanguage() {
		local languages := availableLanguages()
		local selected := this.Control["simpleLanguageDropDown"].Value
		local index := 1
		local code, language
		
		for code, language in languages {
			if (index = selected)
				return code
			index++
		}
		
		return "en"
	}
	
	updateAIFields() {
		local enabled := this.Control["simpleEnableAICheck"].Value
		local window := this.Window
		
		window["simpleAIProviderLabel"].Visible := enabled
		window["simpleAIProviderDropDown"].Visible := enabled
		window["simpleAIAPIKeyLabel"].Visible := enabled
		window["simpleAIAPIKeyEdit"].Visible := enabled
		window["simpleAIInstructionsLabel"].Visible := enabled
		window["simpleAIInstructionsEdit"].Visible := enabled
		
		if enabled
			this.updateAIInstructions()
	}
	
	updateAIInstructions() {
		local provider := this.Control["simpleAIProviderDropDown"].Text
		local instructions := ""
		
		if (provider = "OpenAI")
			instructions := "1. Go to https://platform.openai.com/api-keys`n2. Sign in or create an account`n3. Click 'Create new secret key'`n4. Copy the key and paste it above`n5. Models: GPT-4, GPT-3.5-turbo"
		else if (provider = "Azure OpenAI")
			instructions := "1. Go to Azure Portal (portal.azure.com)`n2. Create an Azure OpenAI resource`n3. Go to Keys and Endpoint section`n4. Copy Key 1 and paste it above`n5. You'll also need the endpoint URL"
		else if (provider = "Google Gemini")
			instructions := "1. Go to https://makersuite.google.com/app/apikey`n2. Sign in with Google account`n3. Click 'Create API Key'`n4. Copy the key and paste it above`n5. Models: Gemini Pro, Gemini Ultra"
		else if (provider = "Anthropic Claude")
			instructions := "1. Go to https://console.anthropic.com/`n2. Sign in or create an account`n3. Navigate to API Keys section`n4. Click 'Create Key'`n5. Copy the key and paste it above`n6. Models: Claude 3 Opus, Sonnet"
		
		this.Control["simpleAIInstructionsEdit"].Text := instructions
	}
	
	updateSummary() {
		local summary := ""
		local synthNames := ["Windows", "dotNET", "Azure", "Google", "OpenAI", "ElevenLabs"]
		local synthIndex := this.Control["simpleSynthesizerDropDown"].Value
		
		summary .= translate("Language") . ": " . this.Control["simpleLanguageDropDown"].Text . "`n"
		summary .= translate("Voice Synthesizer") . ": " . synthNames[synthIndex] . "`n`n"
		
		summary .= translate("Enabled Assistants") . ":`n"
		
		if this.Control["simpleDrivingCoachEnabledCheck"].Value
			summary .= "  - " . translate("Driving Coach") . " (" . this.Control["simpleDrivingCoachNameEdit"].Text . ") - " . this.Control["simpleDrivingCoachVoiceDropDown"].Text . "`n"
		
		if this.Control["simpleRaceEngineerEnabledCheck"].Value
			summary .= "  - " . translate("Race Engineer") . " (" . this.Control["simpleRaceEngineerNameEdit"].Text . ") - " . this.Control["simpleRaceEngineerVoiceDropDown"].Text . "`n"
		
		if this.Control["simpleRaceStrategistEnabledCheck"].Value
			summary .= "  - " . translate("Race Strategist") . " (" . this.Control["simpleRaceStrategistNameEdit"].Text . ") - " . this.Control["simpleRaceStrategistVoiceDropDown"].Text . "`n"
		
		if this.Control["simpleRaceSpotterEnabledCheck"].Value
			summary .= "  - " . translate("Race Spotter") . " (" . this.Control["simpleRaceSpotterNameEdit"].Text . ") - " . this.Control["simpleRaceSpotterVoiceDropDown"].Text . "`n"
		
		if this.Control["simpleEnableAICheck"].Value
			summary .= "`n" . translate("AI Integration") . ": " . this.Control["simpleAIProviderDropDown"].Text . " (Enabled)`n"
		else
			summary .= "`n" . translate("AI Integration") . ": Disabled`n"
		
		this.Control["simpleSummaryEdit"].Text := summary
	}
	
	finishSetup() {
		local wizard := this.SetupWizard
		local synthIndex := this.Control["simpleSynthesizerDropDown"].Value
		local language := this.getSelectedLanguage()
		local synthesizer := ""
		local msgResult
		
		OnMessage(0x44, translateYesNoButtons)
		msgResult := withBlockedWindows(MsgBox, translate("Do you want to generate the configuration?"), translate("Confirmation"), 262436)
		OnMessage(0x44, translateYesNoButtons, 0)
		
		if (msgResult != "Yes")
			return
		
		wizard.selectModule("Voice Control", true, false)
		
		wizard.setModuleValue("Voice Control", "Language", language, false)
		
		if (synthIndex = 1)
			synthesizer := "Windows"
		else if (synthIndex = 2)
			synthesizer := "dotNET"
		else if (synthIndex = 3)
			synthesizer := "Azure|" . Trim(this.Control["simpleTokenIssuerEdit"].Text) . "|" . Trim(this.Control["simpleAPIKeyEdit"].Text)
		else if (synthIndex = 4)
			synthesizer := "Google|" . Trim(this.Control["simpleAPIKeyEdit"].Text)
		else if (synthIndex = 5)
			synthesizer := "OpenAI|" . Trim(this.Control["simpleServerURLEdit"].Text) . "|" . Trim(this.Control["simpleAPIKeyEdit"].Text) . "|"
		else if (synthIndex = 6)
			synthesizer := "ElevenLabs|" . Trim(this.Control["simpleAPIKeyEdit"].Text)
		
		wizard.setModuleValue("Voice Control", "Synthesizer", synthesizer, false)
		
		this.applyAssistantSettings("Driving Coach", "simpleDrivingCoachEnabledCheck", "simpleDrivingCoachNameEdit", "simpleDrivingCoachVoiceDropDown")
		this.applyAssistantSettings("Race Engineer", "simpleRaceEngineerEnabledCheck", "simpleRaceEngineerNameEdit", "simpleRaceEngineerVoiceDropDown")
		this.applyAssistantSettings("Race Strategist", "simpleRaceStrategistEnabledCheck", "simpleRaceStrategistNameEdit", "simpleRaceStrategistVoiceDropDown")
		this.applyAssistantSettings("Race Spotter", "simpleRaceSpotterEnabledCheck", "simpleRaceSpotterNameEdit", "simpleRaceSpotterVoiceDropDown")
		
		if wizard.finishSetup()
			ExitApp(0)
	}
	
	applyAssistantSettings(assistant, enabledCheck, nameEdit, voiceDropDown) {
		local wizard := this.SetupWizard
		local enabled := this.Control[enabledCheck].Value
		local voice
		
		wizard.selectModule(assistant, enabled, false)
		
		if enabled {
			wizard.setModuleValue(assistant, "Name", this.Control[nameEdit].Text, false)
			wizard.setModuleValue(assistant, "Language", this.getSelectedLanguage(), false)
			
			voice := this.Control[voiceDropDown].Text
			
			if (voice = translate("Random"))
				voice := true
			else if (voice = translate("Deactivated"))
				voice := false
			
			wizard.setModuleValue(assistant, "Voice", voice, false)
			wizard.setModuleValue(assistant, "Volume", 100, false)
			wizard.setModuleValue(assistant, "Pitch", 0, false)
			wizard.setModuleValue(assistant, "Speed", 0, false)
		}
	}
	
	saveToConfiguration(configuration) {
		super.saveToConfiguration(configuration)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeSimpleSetupWizard() {
	SetupWizard.Instance.registerStepWizard(SimpleSetupWizard(SetupWizard.Instance, "Simple", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeSimpleSetupWizard()
