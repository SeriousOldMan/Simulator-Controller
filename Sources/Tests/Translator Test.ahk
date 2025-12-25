;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Translator Test                 ;;;
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
#Include "..\Framework\Extensions\Translator.ahk"
#Include "AHKUnit\AHKUnit.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Test Configuration                              ;;;
;;;-------------------------------------------------------------------------;;;

; API keys for live testing (optional - tests will skip if not provided)
global kGoogleAPIKey := ""
global kAzureAPIKey := ""
global kAzureEndpoint := "https://api.cognitive.microsofttranslator.com/"
global kAzureRegion := ""
global kDeepLAPIKey := ""
global kOpenAIAPIKey := ""
global kOpenAIURL := "https://api.openai.com"
global kOpenAIModel := "gpt-4o-mini"


;;;-------------------------------------------------------------------------;;;
;;;                              Test Section                               ;;;
;;;-------------------------------------------------------------------------;;;

exit() {
	ExitApp(0)
}

class TranslatorTest extends Assert {
	; Test 1: Service creation
	Creation_Test() {
		local theTranslator

		; Test Google service creation
		theTranslator := Translator("Google", "English", "Spanish", "test-key")

		this.AssertEqual("Google", theTranslator.Service, "Service should be Google")
		this.AssertEqual("English", theTranslator.SourceLanguage, "Target language should be English")
		this.AssertEqual("en", theTranslator.SourceLanguageCode, "Target language code should be en")
		this.AssertEqual("Spanish", theTranslator.TargetLanguage, "Target language should be Spanish")
		this.AssertEqual("es", theTranslator.TargetLanguageCode, "Target language code should be es")
		this.AssertEqual("test-key", theTranslator.APIKey, "API key should match")
	}

	; Test 2: Language code mapping
	LanguageMapping_Test() {
		local theTranslator

		; Test various language mappings
		theTranslator := Translator("Google", "English", "French", "key")
		this.AssertEqual("fr", theTranslator.TargetLanguageCode, "French code should be fr")

		theTranslator := Translator("Google", "English", "German", "key")
		this.AssertEqual("de", theTranslator.TargetLanguageCode, "German code should be de")

		theTranslator := Translator("Google", "English", "Japanese", "key")
		this.AssertEqual("ja", theTranslator.TargetLanguageCode, "Japanese code should be ja")

		theTranslator := Translator("Google", "English", "Portuguese", "key")
		this.AssertEqual("pt", theTranslator.TargetLanguageCode, "Portuguese code should be pt")
	}

	; Test 3: Same source and target returns original
	SameLanguage_Test() {
		local theTranslator, result

		theTranslator := Translator("Google", "Spanish", "Spanish", "key")

		; Translate from Spanish to Spanish (should return original)
		result := theTranslator.translate("Hola")

		this.AssertEqual("Hola", result, "Same language should return original text")
	}

	; Test 4: Empty text handling
	EmptyText_Test() {
		local theTranslator, result

		theTranslator := Translator("Google", "English", "Spanish", "key")

		; Empty string
		result := theTranslator.translate("")
		this.AssertEqual("", result, "Empty string should return empty string")

		; Whitespace only
		result := theTranslator.translate("   ")
		this.AssertEqual("   ", result, "Whitespace should return as-is")
	}

	; Test 5: Multiple service configurations
	MultipleServices_Test() {
		local google, azure, deepl, openAI

		google := Translator("Google", "English", "Spanish", "google-key")
		azure := Translator("Azure", "English", "French", "azure-key", "https://endpoint", "region")
		deepl := Translator("DeepL", "English", "German", "deepl-key", "https://api-free.deepl.com")
		openAI := Translator("OpenAI", "English", "Italian", "or-key", "llama-3")

		this.AssertEqual("Google", google.Service, "Google service")
		this.AssertEqual("Azure", azure.Service, "Azure service")
		this.AssertEqual("DeepL", deepl.Service, "DeepL service")
		this.AssertEqual("OpenAI", openAI.Service, "OpenAI service")

		this.AssertEqual("es", google.TargetLanguageCode, "Spanish code")
		this.AssertEqual("fr", azure.TargetLanguageCode, "French code")
		this.AssertEqual("de", deepl.TargetLanguageCode, "German code")
		this.AssertEqual("it", openAI.TargetLanguageCode, "Italian code")
	}

	; Test 6: Live OpenAI test (optional - requires API key)
	LiveOpenAI_Test() {
		local theTranslator, result

		if (kOpenAIAPIKey = "") {
			; this.Skip("OpenAI API key not configured")

			return
		}

		theTranslator := Translator("OpenAI", "English", "Spanish"
								  , kOpenAIAPIKey, kOpenAIURL, kOpenAIModel)

		result := theTranslator.translate("Hello")

		; Verify we got some translation back (not empty and different from input)
		this.AssertTrue(result != "", "Translation should not be empty")
		this.AssertTrue(InStr(result, "Hola"), "Spanish translation should contain 'Hola', got: " . result)
	}

	; Test 7: Live Google test (optional - requires API key)
	LiveGoogle_Test() {
		local theTranslator, result

		if (kGoogleAPIKey = "") {
			; this.Skip("Google API key not configured")

			return
		}

		theTranslator := Translator("Google", "English", "Spanish", kGoogleAPIKey)

		result := theTranslator.translate("Good morning")

		this.AssertTrue(result != "", "Translation should not be empty")
		this.AssertTrue(result != "Good morning", "Translation should be different from input")
	}

	; Test 8: Live Azure test (optional - requires API key)
	LiveAzure_Test() {
		local theTranslator, result

		if (kAzureAPIKey = "") {
			; this.Skip("Azure API key not configured")

			return
		}

		theTranslator := Translator("Azure", "English", "Spanish", kAzureAPIKey, kAzureEndpoint, kAzureRegion)

		result := theTranslator.translate("Good morning")

		this.AssertTrue(result != "", "Translation should not be empty")
		this.AssertTrue(result != "Good morning", "Translation should be different from input")
	}

	; Test 9: Live deepL test (optional - requires API key)
	LiveDeepL_Test() {
		local theTranslator, result

		if (kDeepLAPIKey = "") {
			; this.Skip("DeepL API key not configured")

			return
		}

		theTranslator := Translator("DeepL", "English", "Spanish", kDeepLAPIKey)

		result := theTranslator.translate("Good morning")

		this.AssertTrue(result != "", "Translation should not be empty")
		this.AssertTrue(result != "Good morning", "Translation should be different from input")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

AHKUnit.AddTestClass(TranslatorTest)

AHKUnit.Run()