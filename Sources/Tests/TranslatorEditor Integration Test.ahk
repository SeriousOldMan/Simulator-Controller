;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Translator Integration Test     ;;;
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
#Include "AHKUnit\AHKUnit.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Test Configuration                              ;;;
;;;-------------------------------------------------------------------------;;;

; **IMPORTANT**: Add your API credentials here before running tests
; Get your Google API key from: https://console.cloud.google.com/apis/credentials
global kGoogleAPIKey := ""  ; <-- PUT YOUR GOOGLE API KEY HERE

; Get your Azure credentials from: https://portal.azure.com/
global kAzureAPIKey := ""  ; <-- PUT YOUR AZURE API KEY HERE
global kAzureEndpoint := ""  ; <-- e.g., "https://YOUR-RESOURCE.cognitiveservices.azure.com/"
global kAzureRegion := ""  ; <-- e.g., "eastus"

; Get your DeepL API key from: https://www.deepl.com/pro-api
global kDeepLAPIKey := ""  ; <-- PUT YOUR DEEPL API KEY HERE

; Get your OpenRouter API key from: https://openrouter.ai/keys
global kOpenRouterAPIKey := ""  ; <-- OpenRouter API key provided


;;;-------------------------------------------------------------------------;;;
;;;                              Test Section                               ;;;
;;;-------------------------------------------------------------------------;;;

exit() {
	ExitApp(0)
}

class TranslatorIntegrationTest extends Assert {
	Google_Translation_Test() {
		local response, translated, url, headers, body

		; Skip if no API key provided
		if (kGoogleAPIKey = "") {
			this.Skip("Google API key not configured - add your key to kGoogleAPIKey at top of test file")
			return
		}

		; Google Cloud Translation API v2 endpoint
		url := "https://translation.googleapis.com/language/translate/v2?key=" . kGoogleAPIKey

		; Request body
		body := '{"q": "Hello, how are you?", "target": "es", "format": "text"}'

		; Make API request
		try {
			response := ComObject("WinHttp.WinHttpRequest.5.1")
			response.Open("POST", url, false)
			response.SetRequestHeader("Content-Type", "application/json")
			response.Send(body)

			; Parse response
			if (response.Status = 200) {
				responseText := response.ResponseText
				
				; Simple JSON parsing to get translated text
				if (InStr(responseText, '"translatedText"')) {
					startPos := InStr(responseText, '"translatedText": "') + 19
					endPos := InStr(responseText, '"', , startPos)
					translated := SubStr(responseText, startPos, endPos - startPos)
					
					; Verify translation contains expected Spanish text
					this.AssertTrue(InStr(translated, "Hola") > 0 || InStr(translated, "hola") > 0, 
						"Translation should contain 'Hola': " . translated)
					
					MsgBox("✓ Google Translation Test PASSED`n`nOriginal: Hello, how are you?`nTranslated: " . translated, 
						"Google API Test", 64)
				} else {
					this.Fail("Could not parse translation from response: " . responseText)
				}
			} else {
				this.Fail("Google API request failed with status " . response.Status . ": " . response.ResponseText)
			}
		} catch as e {
			this.Fail("Google API request error: " . e.Message)
		}
	}

	Azure_Translation_Test() {
		local response, translated, url, body

		; Skip if no credentials provided
		if (kAzureAPIKey = "" || kAzureEndpoint = "" || kAzureRegion = "") {
			this.Skip("Azure credentials not configured - add your endpoint, key, and region at top of test file")
			return
		}

		; Azure Translator API endpoint
		url := kAzureEndpoint . "/translate?api-version=3.0&to=es"

		; Request body
		body := '[{"text": "Hello, how are you?"}]'

		; Make API request
		try {
			response := ComObject("WinHttp.WinHttpRequest.5.1")
			response.Open("POST", url, false)
			response.SetRequestHeader("Content-Type", "application/json")
			response.SetRequestHeader("Ocp-Apim-Subscription-Key", kAzureAPIKey)
			response.SetRequestHeader("Ocp-Apim-Subscription-Region", kAzureRegion)
			response.Send(body)

			; Parse response
			if (response.Status = 200) {
				responseText := response.ResponseText
				
				; Simple JSON parsing to get translated text
				if (InStr(responseText, '"text"')) {
					; Get the second "text" field (first is input, second is translation)
					firstTextPos := InStr(responseText, '"text": "')
					startPos := InStr(responseText, '"text": "', , firstTextPos + 10) + 9
					endPos := InStr(responseText, '"', , startPos)
					translated := SubStr(responseText, startPos, endPos - startPos)
					
					; Verify translation contains expected Spanish text
					this.AssertTrue(InStr(translated, "Hola") > 0 || InStr(translated, "hola") > 0, 
						"Translation should contain 'Hola': " . translated)
					
					MsgBox("✓ Azure Translation Test PASSED`n`nOriginal: Hello, how are you?`nTranslated: " . translated, 
						"Azure API Test", 64)
				} else {
					this.Fail("Could not parse translation from response: " . responseText)
				}
			} else {
				this.Fail("Azure API request failed with status " . response.Status . ": " . response.ResponseText)
			}
		} catch as e {
			this.Fail("Azure API request error: " . e.Message)
		}
	}

	DeepL_Translation_Test() {
		local response, translated, url, body

		; Skip if no API key provided
		if (kDeepLAPIKey = "") {
			this.Skip("DeepL API key not configured - add your key to kDeepLAPIKey at top of test file")
			return
		}

		; DeepL API endpoint (use api-free for free tier, api for pro)
		url := "https://api-free.deepl.com/v2/translate"

		; Request body (URL encoded)
		body := "text=Hello, how are you?&target_lang=ES&auth_key=" . kDeepLAPIKey

		; Make API request
		try {
			response := ComObject("WinHttp.WinHttpRequest.5.1")
			response.Open("POST", url, false)
			response.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
			response.Send(body)

			; Parse response
			if (response.Status = 200) {
				responseText := response.ResponseText
				
				; Simple JSON parsing to get translated text
				if (InStr(responseText, '"text"')) {
					startPos := InStr(responseText, '"text":"') + 8
					endPos := InStr(responseText, '"', , startPos)
					translated := SubStr(responseText, startPos, endPos - startPos)
					
					; Verify translation contains expected Spanish text
					this.AssertTrue(InStr(translated, "Hola") > 0 || InStr(translated, "hola") > 0, 
						"Translation should contain 'Hola': " . translated)
					
					MsgBox("✓ DeepL Translation Test PASSED`n`nOriginal: Hello, how are you?`nTranslated: " . translated, 
						"DeepL API Test", 64)
				} else {
					this.Fail("Could not parse translation from response: " . responseText)
				}
			} else {
				this.Fail("DeepL API request failed with status " . response.Status . ": " . response.ResponseText)
			}
		} catch as e {
			this.Fail("DeepL API request error: " . e.Message)
		}
	}

	MultiLanguage_Test() {
		local languages, testPhrases, lang, phrase, response, url, body

		; Skip if no API key provided
		if (kGoogleAPIKey = "") {
			this.Skip("Google API key not configured")
			return
		}

		; Test multiple languages
		languages := Map(
			"es", "Hola",      ; Spanish
			"fr", "Bonjour",   ; French
			"de", "Hallo",     ; German
			"it", "Ciao",      ; Italian
			"pt", "Olá"        ; Portuguese
		)

		testPhrases := ""

		for langCode, expectedWord in languages {
			url := "https://translation.googleapis.com/language/translate/v2?key=" . kGoogleAPIKey
			body := '{"q": "Hello", "target": "' . langCode . '", "format": "text"}'

			try {
				response := ComObject("WinHttp.WinHttpRequest.5.1")
				response.Open("POST", url, false)
				response.SetRequestHeader("Content-Type", "application/json")
				response.Send(body)

				if (response.Status = 200) {
					responseText := response.ResponseText
					startPos := InStr(responseText, '"translatedText": "') + 19
					endPos := InStr(responseText, '"', , startPos)
					translated := SubStr(responseText, startPos, endPos - startPos)
					
					testPhrases .= langCode . ": " . translated . "`n"
					
					this.AssertTrue(InStr(translated, expectedWord) > 0, 
						"Translation to " . langCode . " should contain '" . expectedWord . "', got: " . translated)
				}
			}
		}

		if (testPhrases != "")
			MsgBox("✓ Multi-Language Test PASSED`n`n" . testPhrases, "Multi-Language Test", 64)
	}

	OpenRouter_Translation_Test() {
		local response, translated, url, body, model

		; Skip if no API key provided
		if (kOpenRouterAPIKey = "") {
			this.Skip("OpenRouter API key not configured - add your key to kOpenRouterAPIKey at top of test file")
			return
		}

		; OpenRouter uses chat completions for translation
		url := "https://openrouter.ai/api/v1/chat/completions"
		model := "meta-llama/llama-3.1-8b-instruct:free"  ; Free model for testing

		; Create chat completion request with translation prompt
		body := '{"model": "' . model . '", "messages": [{"role": "user", "content": "Translate to Spanish (only provide the translation, no explanations): Hello, how are you?"}]}'

		; Make API request
		try {
			response := ComObject("WinHttp.WinHttpRequest.5.1")
			response.Open("POST", url, false)
			response.SetRequestHeader("Content-Type", "application/json")
			response.SetRequestHeader("Authorization", "Bearer " . kOpenRouterAPIKey)
			response.SetRequestHeader("HTTP-Referer", "https://github.com/SeriousOldMan/Simulator-Controller")
			response.SetRequestHeader("X-Title", "Simulator Controller Translation Test")
			response.Send(body)

			; Parse response
			responseText := response.ResponseText
			
			; Extract content from: {"choices": [{"message": {"content": "translation"}}]}
			if (InStr(responseText, '"content"')) {
				startPos := InStr(responseText, '"content": "') + 12
				endPos := InStr(responseText, '"', , startPos)
				translated := SubStr(responseText, startPos, endPos - startPos)
				
				; Verify translation contains Spanish words
				this.AssertTrue(InStr(translated, "Hola") || InStr(translated, "hola") || InStr(translated, "¿Cómo"), 
					"OpenRouter translation should contain Spanish text, got: " . translated)
				
				MsgBox("✓ OpenRouter Translation Test PASSED`n`n" 
					. "Original: Hello, how are you?`n" 
					. "Translated: " . translated, "OpenRouter Test", 64)
			}
			else {
				this.Fail("Failed to parse OpenRouter response: " . responseText)
			}
		}
		catch as e {
			this.Fail("OpenRouter API request failed: " . e.Message)
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

AHKUnit.AddTestClass(TranslatorIntegrationTest)

AHKUnit.Run()
