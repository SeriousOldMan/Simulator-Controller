;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Translator Editor Test          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#Requires AutoHotkey >=2.0
#SingleInstance Force			; Ony one instance allowed
#Warn							; Enable warnings to assist with detecting common errors.
#Warn LocalSameAsGlobal, Off

SendMode("Input")				; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir)		; Ensures a consistent starting directory.


global kBuildConfiguration := "Development"


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Framework.ahk"
#Include "..\Configuration\Libraries\ConfigurationEditor.ahk"
#Include "..\Configuration\Libraries\TranslatorEditor.ahk"
#Include "AHKUnit\AHKUnit.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                              Test Section                               ;;;
;;;-------------------------------------------------------------------------;;;

exit() {
	ExitApp(0)
}

class TranslatorEditorTest extends Assert {
	Setup() {
		; Create a temporary test configuration directory
		this.testConfigDir := A_Temp . "\SimControllerTest_" . A_TickCount
		DirCreate(this.testConfigDir)
	}

	Teardown() {
		; Clean up test configuration directory
		try DirDelete(this.testConfigDir, true)
	}

	Configuration_SaveLoad_Test() {
		local editor, config, testConfig, loaded

		; Create test configuration
		testConfig := newMultiMap()
		
		; Test data for Driving Coach
		setMultiMapValue(testConfig, "Driving Coach.Translation", "Enabled", true)
		setMultiMapValue(testConfig, "Driving Coach.Translation", "TargetLanguage", "Spanish")
		setMultiMapValue(testConfig, "Driving Coach.Translation", "Service", "Google")
		setMultiMapValue(testConfig, "Driving Coach.Translation", "APIKey", "test-google-key-123")
		setMultiMapValue(testConfig, "Driving Coach.Translation", "Endpoint", "")
		setMultiMapValue(testConfig, "Driving Coach.Translation", "Additional", "")

		; Create editor instance
		editor := TranslatorEditor("Driving Coach", testConfig)

		; Load configuration into editor
		editor.loadFromConfiguration(testConfig)

		; Verify loaded values
		this.AssertEqual(true, editor.Value["translatorEnabled"], "Enabled flag not loaded correctly")
		this.AssertEqual("Spanish", editor.Value["translatorTargetLanguage"], "Target language not loaded correctly")
		this.AssertEqual("Google", editor.Value["translatorService"], "Service not loaded correctly")
		this.AssertEqual("test-google-key-123", editor.Value["translatorAPIKey"], "API key not loaded correctly")

		; Modify values
		editor.Control["translatorEnabledCheck"].Value := false
		editor.Control["translatorTargetLanguageDropDown"].Text := "French"
		editor.Control["translatorServiceDropDown"].Text := "Azure"
		editor.Control["translatorAPIKeyEdit"].Text := "test-azure-key-456"
		editor.Control["translatorEndpointEdit"].Text := "https://test.cognitiveservices.azure.com/"
		editor.Control["translatorAdditionalEdit"].Text := "eastus"

		; Save configuration
		config := newMultiMap()
		editor.saveToConfiguration(config)

		; Verify saved values
		this.AssertEqual(false, getMultiMapValue(config, "Driving Coach.Translation", "Enabled"), "Enabled flag not saved correctly")
		this.AssertEqual("French", getMultiMapValue(config, "Driving Coach.Translation", "TargetLanguage"), "Target language not saved correctly")
		this.AssertEqual("Azure", getMultiMapValue(config, "Driving Coach.Translation", "Service"), "Service not saved correctly")
		this.AssertEqual("test-azure-key-456", getMultiMapValue(config, "Driving Coach.Translation", "APIKey"), "API key not saved correctly")
		this.AssertEqual("https://test.cognitiveservices.azure.com/", getMultiMapValue(config, "Driving Coach.Translation", "Endpoint"), "Endpoint not saved correctly")
		this.AssertEqual("eastus", getMultiMapValue(config, "Driving Coach.Translation", "Additional"), "Additional field not saved correctly")
	}

	Service_Google_Fields_Test() {
		local editor, config

		; Create editor with Google service
		config := newMultiMap()
		setMultiMapValue(config, "Race Engineer.Translation", "Service", "Google")
		
		editor := TranslatorEditor("Race Engineer", config)
		editor.loadFromConfiguration(config)
		
		; Set service to Google
		editor.Control["translatorServiceDropDown"].Text := "Google"
		editor.updateTranslatorFields()

		; Verify Google-specific field visibility
		this.AssertEqual(false, editor.Control["translatorEndpointLabel"].Visible, "Endpoint label should be hidden for Google")
		this.AssertEqual(false, editor.Control["translatorEndpointEdit"].Visible, "Endpoint field should be hidden for Google")
		this.AssertEqual(false, editor.Control["translatorAdditionalLabel"].Visible, "Additional label should be hidden for Google")
		this.AssertEqual(false, editor.Control["translatorAdditionalEdit"].Visible, "Additional field should be hidden for Google")
	}

	Service_Azure_Fields_Test() {
		local editor, config

		; Create editor with Azure service
		config := newMultiMap()
		setMultiMapValue(config, "Race Engineer.Translation", "Service", "Azure")
		
		editor := TranslatorEditor("Race Engineer", config)
		editor.loadFromConfiguration(config)
		
		; Set service to Azure
		editor.Control["translatorServiceDropDown"].Text := "Azure"
		editor.updateTranslatorFields()

		; Verify Azure-specific field visibility
		this.AssertEqual(true, editor.Control["translatorEndpointLabel"].Visible, "Endpoint label should be visible for Azure")
		this.AssertEqual(true, editor.Control["translatorEndpointEdit"].Visible, "Endpoint field should be visible for Azure")
		this.AssertEqual("Endpoint", editor.Control["translatorEndpointLabel"].Text, "Endpoint label text incorrect for Azure")
		this.AssertEqual(true, editor.Control["translatorAdditionalLabel"].Visible, "Additional label should be visible for Azure")
		this.AssertEqual(true, editor.Control["translatorAdditionalEdit"].Visible, "Additional field should be visible for Azure")
		this.AssertEqual("Region", editor.Control["translatorAdditionalLabel"].Text, "Additional label text should be 'Region' for Azure")
	}

	Service_DeepL_Fields_Test() {
		local editor, config

		; Create editor with DeepL service
		config := newMultiMap()
		setMultiMapValue(config, "Race Spotter.Translation", "Service", "DeepL")
		
		editor := TranslatorEditor("Race Spotter", config)
		editor.loadFromConfiguration(config)
		
		; Set service to DeepL
		editor.Control["translatorServiceDropDown"].Text := "DeepL"
		editor.updateTranslatorFields()

		; Verify DeepL-specific field visibility
		this.AssertEqual(true, editor.Control["translatorEndpointLabel"].Visible, "Endpoint label should be visible for DeepL")
		this.AssertEqual(true, editor.Control["translatorEndpointEdit"].Visible, "Endpoint field should be visible for DeepL")
		this.AssertEqual("API URL", editor.Control["translatorEndpointLabel"].Text, "Endpoint label text incorrect for DeepL")
		this.AssertEqual(false, editor.Control["translatorAdditionalLabel"].Visible, "Additional label should be hidden for DeepL")
		this.AssertEqual(false, editor.Control["translatorAdditionalEdit"].Visible, "Additional field should be hidden for DeepL")
	}

	Service_OpenRouter_Fields_Test() {
		local editor, config

		; Create editor with OpenRouter service
		config := newMultiMap()
		setMultiMapValue(config, "Race Strategist.Translation", "Service", "OpenRouter")
		
		editor := TranslatorEditor("Race Strategist", config)
		editor.loadFromConfiguration(config)
		
		; Set service to OpenRouter
		editor.Control["translatorServiceDropDown"].Text := "OpenRouter"
		editor.updateTranslatorFields()

		; Verify OpenRouter-specific field visibility
		this.AssertEqual(false, editor.Control["translatorEndpointLabel"].Visible, "Endpoint label should be hidden for OpenRouter")
		this.AssertEqual(false, editor.Control["translatorEndpointEdit"].Visible, "Endpoint field should be hidden for OpenRouter")
		this.AssertEqual(true, editor.Control["translatorAdditionalLabel"].Visible, "Additional label should be visible for OpenRouter")
		this.AssertEqual(true, editor.Control["translatorAdditionalEdit"].Visible, "Additional field should be visible for OpenRouter")
		this.AssertEqual("Model", editor.Control["translatorAdditionalLabel"].Text, "Additional label text should be 'Model' for OpenRouter")
	}

	MultiAssistant_Independence_Test() {
		local config, editor1, editor2

		config := newMultiMap()

		; Configure Driving Coach with Google
		setMultiMapValue(config, "Driving Coach.Translation", "Enabled", true)
		setMultiMapValue(config, "Driving Coach.Translation", "Service", "Google")
		setMultiMapValue(config, "Driving Coach.Translation", "TargetLanguage", "Spanish")
		setMultiMapValue(config, "Driving Coach.Translation", "APIKey", "google-key-123")

		; Configure Race Engineer with Azure
		setMultiMapValue(config, "Race Engineer.Translation", "Enabled", true)
		setMultiMapValue(config, "Race Engineer.Translation", "Service", "Azure")
		setMultiMapValue(config, "Race Engineer.Translation", "TargetLanguage", "French")
		setMultiMapValue(config, "Race Engineer.Translation", "APIKey", "azure-key-456")
		setMultiMapValue(config, "Race Engineer.Translation", "Endpoint", "https://azure.endpoint.com")
		setMultiMapValue(config, "Race Engineer.Translation", "Additional", "westeurope")

		; Test Driving Coach configuration
		editor1 := TranslatorEditor("Driving Coach", config)
		editor1.loadFromConfiguration(config)
		
		this.AssertEqual("Google", editor1.Value["translatorService"], "Driving Coach should have Google service")
		this.AssertEqual("Spanish", editor1.Value["translatorTargetLanguage"], "Driving Coach should have Spanish language")
		this.AssertEqual("google-key-123", editor1.Value["translatorAPIKey"], "Driving Coach API key incorrect")

		; Test Race Engineer configuration
		editor2 := TranslatorEditor("Race Engineer", config)
		editor2.loadFromConfiguration(config)
		
		this.AssertEqual("Azure", editor2.Value["translatorService"], "Race Engineer should have Azure service")
		this.AssertEqual("French", editor2.Value["translatorTargetLanguage"], "Race Engineer should have French language")
		this.AssertEqual("azure-key-456", editor2.Value["translatorAPIKey"], "Race Engineer API key incorrect")
		this.AssertEqual("https://azure.endpoint.com", editor2.Value["translatorEndpoint"], "Race Engineer endpoint incorrect")
		this.AssertEqual("westeurope", editor2.Value["translatorAdditional"], "Race Engineer region incorrect")
	}

	DefaultValues_Test() {
		local editor, config

		; Create editor with empty configuration
		config := newMultiMap()
		editor := TranslatorEditor("Race Strategist", config)
		editor.loadFromConfiguration(config)

		; Verify default values
		this.AssertEqual(false, editor.Value["translatorEnabled"], "Default enabled should be false")
		this.AssertEqual("Spanish", editor.Value["translatorTargetLanguage"], "Default language should be Spanish")
		this.AssertEqual("Google", editor.Value["translatorService"], "Default service should be Google")
		this.AssertEqual("", editor.Value["translatorEndpoint"], "Default endpoint should be empty")
		this.AssertEqual("", editor.Value["translatorAPIKey"], "Default API key should be empty")
		this.AssertEqual("", editor.Value["translatorAdditional"], "Default additional should be empty")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

AHKUnit.AddTestClass(TranslatorEditorTest)

AHKUnit.Run()
