;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Translation Service Test        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#Requires AutoHotkey >=2.0
#SingleInstance Force
#Warn
#Warn LocalSameAsGlobal, Off

SendMode("Input")
SetWorkingDir(A_ScriptDir)

global kBuildConfiguration := "Development"

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Framework.ahk"
#Include "..\Framework\Extensions\TranslationService.ahk"
#Include "AHKUnit\AHKUnit.ahk"

;;;-------------------------------------------------------------------------;;;
;;;                         Test Configuration                              ;;;
;;;-------------------------------------------------------------------------;;;

; API keys for live testing (optional - tests will skip if not provided)
global kGoogleAPIKey := ""
global kAzureAPIKey := ""
global kAzureEndpoint := ""
global kAzureRegion := ""
global kDeepLAPIKey := ""
global kOpenRouterAPIKey := ""  ; Add your OpenRouter API key here

;;;-------------------------------------------------------------------------;;;
;;;                              Test Section                               ;;;
;;;-------------------------------------------------------------------------;;;

exit() {
	ExitApp(0)
}

class TranslationServiceTest extends Assert {
	; Test 1: Service creation
	Creation_Test() {
		local translator
		
		; Test Google service creation
		translator := TranslationService("Google", "Spanish", "test-key", "", "", true)
		
		this.AssertEqual("Google", translator.Service, "Service should be Google")
		this.AssertEqual("Spanish", translator.TargetLanguage, "Target language should be Spanish")
		this.AssertEqual("es", translator.TargetLanguageCode, "Language code should be es")
		this.AssertEqual("test-key", translator.APIKey, "API key should match")
		this.AssertEqual(true, translator.Enabled, "Service should be enabled")
	}
	
	; Test 2: Language code mapping
	LanguageMapping_Test() {
		local translator
		
		; Test various language mappings
		translator := TranslationService("Google", "French", "key", "", "", true)
		this.AssertEqual("fr", translator.TargetLanguageCode, "French code should be fr")
		
		translator := TranslationService("Google", "German", "key", "", "", true)
		this.AssertEqual("de", translator.TargetLanguageCode, "German code should be de")
		
		translator := TranslationService("Google", "Japanese", "key", "", "", true)
		this.AssertEqual("ja", translator.TargetLanguageCode, "Japanese code should be ja")
		
		translator := TranslationService("Google", "Portuguese", "key", "", "", true)
		this.AssertEqual("pt", translator.TargetLanguageCode, "Portuguese code should be pt")
	}
	
	; Test 3: Configuration loading
	FromConfiguration_Test() {
		local config, translator
		
		; Create test configuration
		config := newMultiMap()
		setMultiMapValue(config, "Driving Coach.Translation", "Enabled", true)
		setMultiMapValue(config, "Driving Coach.Translation", "Service", "Azure")
		setMultiMapValue(config, "Driving Coach.Translation", "TargetLanguage", "French")
		setMultiMapValue(config, "Driving Coach.Translation", "APIKey", "azure-key-123")
		setMultiMapValue(config, "Driving Coach.Translation", "Endpoint", "https://test.cognitive.azure.com")
		setMultiMapValue(config, "Driving Coach.Translation", "Additional", "westus")
		
		; Create translator from configuration
		translator := TranslationService.FromConfiguration("Driving Coach", config)
		
		this.AssertNotEqual(false, translator, "Translator should be created")
		this.AssertEqual("Azure", translator.Service, "Service should be Azure")
		this.AssertEqual("French", translator.TargetLanguage, "Target language should be French")
		this.AssertEqual("azure-key-123", translator.APIKey, "API key should match")
		this.AssertEqual("https://test.cognitive.azure.com", translator.Endpoint, "Endpoint should match")
		this.AssertEqual("westus", translator.Additional, "Region should match")
	}
	
	; Test 4: Disabled translation returns original text
	DisabledTranslation_Test() {
		local translator, result
		
		; Create disabled translator
		translator := TranslationService("Google", "Spanish", "key", "", "", false)
		
		result := translator.translate("Hello")
		this.AssertEqual("Hello", result, "Disabled translator should return original text")
	}
	
	; Test 5: Cache functionality
	Cache_Test() {
		local translator, result1, result2
		
		translator := TranslationService("Google", "Spanish", "key", "", "", true)
		
		; Initial cache should be empty
		this.AssertEqual(0, translator.getCacheSize(), "Cache should be empty initially")
		
		; Manually add to cache for testing (since we don't have real API)
		translator.iCache["Google:en->es:Hello"] := "Hola"
		
		; Verify cache size
		this.AssertEqual(1, translator.getCacheSize(), "Cache should contain 1 item")
		
		; Clear cache
		translator.clearCache()
		this.AssertEqual(0, translator.getCacheSize(), "Cache should be empty after clear")
	}
	
	; Test 6: Same source and target returns original
	SameLanguage_Test() {
		local translator, result
		
		translator := TranslationService("Google", "Spanish", "key", "", "", true)
		
		; Translate from Spanish to Spanish (should return original)
		result := translator.translate("Hola", "es", "es")
		this.AssertEqual("Hola", result, "Same language should return original text")
	}
	
	; Test 7: Empty text handling
	EmptyText_Test() {
		local translator, result
		
		translator := TranslationService("Google", "Spanish", "key", "", "", true)
		
		; Empty string
		result := translator.translate("")
		this.AssertEqual("", result, "Empty string should return empty string")
		
		; Whitespace only
		result := translator.translate("   ")
		this.AssertEqual("   ", result, "Whitespace should return as-is")
	}
	
	; Test 8: Multiple service configurations
	MultipleServices_Test() {
		local google, azure, deepl, openrouter
		
		google := TranslationService("Google", "Spanish", "google-key", "", "", true)
		azure := TranslationService("Azure", "French", "azure-key", "https://endpoint", "region", true)
		deepl := TranslationService("DeepL", "German", "deepl-key", "https://api-free.deepl.com", "", true)
		openrouter := TranslationService("OpenRouter", "Italian", "or-key", "", "llama-3", true)
		
		this.AssertEqual("Google", google.Service, "Google service")
		this.AssertEqual("Azure", azure.Service, "Azure service")
		this.AssertEqual("DeepL", deepl.Service, "DeepL service")
		this.AssertEqual("OpenRouter", openrouter.Service, "OpenRouter service")
		
		this.AssertEqual("es", google.TargetLanguageCode, "Spanish code")
		this.AssertEqual("fr", azure.TargetLanguageCode, "French code")
		this.AssertEqual("de", deepl.TargetLanguageCode, "German code")
		this.AssertEqual("it", openrouter.TargetLanguageCode, "Italian code")
	}
	
	; Test 9: Live OpenRouter test (optional - requires API key)
	LiveOpenRouter_Test() {
		local translator, result
		
		if (kOpenRouterAPIKey = "") {
			this.Skip("OpenRouter API key not configured")
			return
		}
		
		translator := TranslationService("OpenRouter", "Spanish"
			, kOpenRouterAPIKey
			, ""
			, "meta-llama/llama-3.1-8b-instruct:free"
			, true)
		
		result := translator.translate("Hello")
		
		; Verify we got some translation back (not empty and different from input)
		this.AssertTrue(result != "", "Translation should not be empty")
		this.AssertTrue(InStr(result, "Hola") || InStr(result, "hola"), 
			"Spanish translation should contain 'Hola', got: " . result)
		
		; Check cache was populated
		this.AssertEqual(1, translator.getCacheSize(), "Cache should contain the translation")
		
		MsgBox("✓ Live OpenRouter Test PASSED`n`n"
			. "Original: Hello`n"
			. "Translated: " . result, "Live Test", 64)
	}
	
	; Test 10: Live Google test (optional - requires API key)
	LiveGoogle_Test() {
		local translator, result
		
		if (kGoogleAPIKey = "") {
			this.Skip("Google API key not configured")
			return
		}
		
		translator := TranslationService("Google", "Spanish", kGoogleAPIKey, "", "", true)
		
		result := translator.translate("Good morning")
		
		this.AssertTrue(result != "", "Translation should not be empty")
		this.AssertTrue(result != "Good morning", "Translation should be different from input")
		
		MsgBox("✓ Live Google Test PASSED`n`n"
			. "Original: Good morning`n"
			. "Translated: " . result, "Live Test", 64)
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

global gTestRunner := AHKUnit(TranslationServiceTest)

MsgBox("Starting TranslationService tests...`n`n"
	. "Note: Live API tests will only run if you provide API keys at the top of this file.", 
	"TranslationService Test", 64)

exitCode := gTestRunner.Run()

; Show test results
if (exitCode = 0)
	MsgBox("✓ All TranslationService tests PASSED!", "Test Results", 64)
else
	MsgBox("✗ Some TranslationService tests FAILED!`n`nCheck the output for details.", "Test Results", 16)

ExitApp(exitCode)
