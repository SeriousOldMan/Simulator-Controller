;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Translation Service             ;;;
;;;                                                                         ;;;
;;;   Provides text translation services using multiple providers:          ;;;
;;;   - Google Cloud Translation API v2                                     ;;;
;;;   - Azure Cognitive Services Translator                                 ;;;
;;;   - DeepL Translation API                                               ;;;
;;;   - OpenRouter (LLM-based translation)                                  ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "HTTP.ahk"
#Include "JSON.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

; Language code mappings for different services
global kLanguageMapping := Map(
	"Spanish", Map("code", "es", "name", "Spanish"),
	"French", Map("code", "fr", "name", "French"),
	"German", Map("code", "de", "name", "German"),
	"Italian", Map("code", "it", "name", "Italian"),
	"Portuguese", Map("code", "pt", "name", "Portuguese"),
	"Japanese", Map("code", "ja", "name", "Japanese"),
	"Chinese", Map("code", "zh", "name", "Chinese"),
	"Korean", Map("code", "ko", "name", "Korean"),
	"Russian", Map("code", "ru", "name", "Russian"),
	"Arabic", Map("code", "ar", "name", "Arabic"),
	"Dutch", Map("code", "nl", "name", "Dutch"),
	"Polish", Map("code", "pl", "name", "Polish"),
	"Swedish", Map("code", "sv", "name", "Swedish"),
	"Turkish", Map("code", "tr", "name", "Turkish"),
	"Hindi", Map("code", "hi", "name", "Hindi"),
	"Thai", Map("code", "th", "name", "Thai"),
	"Vietnamese", Map("code", "vi", "name", "Vietnamese"),
	"Czech", Map("code", "cs", "name", "Czech"),
	"Danish", Map("code", "da", "name", "Danish"),
	"Finnish", Map("code", "fi", "name", "Finnish"),
	"Norwegian", Map("code", "no", "name", "Norwegian"),
	"Hungarian", Map("code", "hu", "name", "Hungarian"),
	"Romanian", Map("code", "ro", "name", "Romanian")
)


;;;-------------------------------------------------------------------------;;;
;;;                          Public Class Section                           ;;;
;;;-------------------------------------------------------------------------;;;

class TranslationService {
	iService := "Google"
	iEnabled := false
	
	iAPIKey := ""
	iEndpoint := ""
	iAdditional := ""
	
	iTargetLanguage := "Spanish"
	iTargetLanguageCode := "es"
	
	iCache := CaseInsenseMap()
	
	Service {
		Get {
			return this.iService
		}
	}
	
	Enabled {
		Get {
			return this.iEnabled
		}
	}
	
	APIKey {
		Get {
			return this.iAPIKey
		}
	}
	
	Endpoint {
		Get {
			return this.iEndpoint
		}
	}
	
	Additional {
		Get {
			return this.iAdditional
		}
	}
	
	TargetLanguage {
		Get {
			return this.iTargetLanguage
		}
	}
	
	TargetLanguageCode {
		Get {
			return this.iTargetLanguageCode
		}
	}
	
	__New(service := "Google", targetLanguage := "Spanish", apiKey := "", endpoint := "", additional := "", enabled := true) {
		global kLanguageMapping
		
		this.iService := service
		this.iTargetLanguage := targetLanguage
		this.iAPIKey := apiKey
		this.iEndpoint := endpoint
		this.iAdditional := additional
		this.iEnabled := enabled
		
		; Set language code from mapping
		if kLanguageMapping.Has(targetLanguage)
			this.iTargetLanguageCode := kLanguageMapping[targetLanguage]["code"]
		else
			this.iTargetLanguageCode := "es"  ; Default to Spanish
	}
	
	/**
	 * Create TranslationService from configuration for a specific assistant
	 * @param assistant - Name of the assistant (e.g., "Driving Coach")
	 * @param configuration - Configuration MultiMap
	 * @returns TranslationService instance or false if not enabled
	 */
	static FromConfiguration(assistant, configuration) {
		local enabled, service, targetLanguage, apiKey, endpoint, additional
		
		enabled := getMultiMapValue(configuration, assistant . ".Translation", "Enabled", false)
		
		if !enabled
			return false
		
		service := getMultiMapValue(configuration, assistant . ".Translation", "Service", "Google")
		targetLanguage := getMultiMapValue(configuration, assistant . ".Translation", "TargetLanguage", "Spanish")
		apiKey := getMultiMapValue(configuration, assistant . ".Translation", "APIKey", "")
		endpoint := getMultiMapValue(configuration, assistant . ".Translation", "Endpoint", "")
		additional := getMultiMapValue(configuration, assistant . ".Translation", "Additional", "")
		
		return TranslationService(service, targetLanguage, apiKey, endpoint, additional, enabled)
	}
	
	/**
	 * Main translation method - translates text to target language
	 * @param text - Text to translate
	 * @param sourceLang - Source language code (default: "en" for English)
	 * @param targetLang - Override target language code (optional)
	 * @returns Translated text or original text on error
	 */
	translate(text, sourceLang := "en", targetLang := "") {
		local result, cacheKey
		
		if !this.iEnabled {
			logMessage(kLogInfo, translate("Translation disabled, returning original text"))
			return text
		}
		
		if (text = "") || (Trim(text) = "")
			return text
		
		; Use configured target language if not overridden
		if (targetLang = "")
			targetLang := this.iTargetLanguageCode
		
		; No translation needed if source and target are the same
		if (sourceLang = targetLang)
			return text
		
		; Check cache
		cacheKey := this.iService . ":" . sourceLang . "->" . targetLang . ":" . text
		
		if this.iCache.Has(cacheKey) {
			logMessage(kLogDebug, translate("Translation cache hit: ") . text)
			return this.iCache[cacheKey]
		}
		
		; Route to appropriate service
		try {
			switch this.iService {
				case "Google":
					result := this.translateGoogle(text, sourceLang, targetLang)
				case "Azure":
					result := this.translateAzure(text, sourceLang, targetLang)
				case "DeepL":
					result := this.translateDeepL(text, sourceLang, targetLang)
				case "OpenRouter":
					result := this.translateOpenRouter(text, sourceLang, targetLang)
				default:
					logMessage(kLogWarn, translate("Unknown translation service: ") . this.iService)
					result := text
			}
			
			; Cache the result
			if (result != text)
				this.iCache[cacheKey] := result
			
			return result
		}
		catch Any as exception {
			logError(exception, true)
			logMessage(kLogCritical, translate("Translation failed, returning original text"))
			return text
		}
	}
	
	/**
	 * Google Cloud Translation API v2
	 */
	translateGoogle(text, sourceLang, targetLang) {
		local url, body, result, responseText, translatedText
		
		if (Trim(this.iAPIKey) = "") {
			logMessage(kLogCritical, translate("Google API key not configured"))
			return text
		}
		
		; Build API URL
		url := "https://translation.googleapis.com/language/translate/v2?key=" . this.iAPIKey
		
		; Escape text for JSON
		escapedText := StrReplace(text, "\", "\\")
		escapedText := StrReplace(escapedText, '"', '\"')
		escapedText := StrReplace(escapedText, "`n", "\n")
		escapedText := StrReplace(escapedText, "`r", "\r")
		escapedText := StrReplace(escapedText, "`t", "\t")
		
		; Build request body
		body := '{"q": "' . escapedText . '", "source": "' . sourceLang . '", "target": "' . targetLang . '", "format": "text"}'
		
		; Make API request
		result := WinHttpRequest().POST(url, body, Map("Content-Type", "application/json"), {Encoding: "UTF-8"})
		
		if ((result.Status >= 200) && (result.Status < 300)) {
			responseText := result.Text
			
			; Parse JSON response
			if (InStr(responseText, '"translatedText"')) {
				startPos := InStr(responseText, '"translatedText": "') + 19
				endPos := InStr(responseText, '"', false, startPos)
				translatedText := SubStr(responseText, startPos, endPos - startPos)
				
				; Unescape JSON
				translatedText := StrReplace(translatedText, "\n", "`n")
				translatedText := StrReplace(translatedText, "\r", "`r")
				translatedText := StrReplace(translatedText, "\t", "`t")
				translatedText := StrReplace(translatedText, '\"', '"')
				translatedText := StrReplace(translatedText, "\\", "\")
				
				logMessage(kLogInfo, translate("Google translation: ") . text . " -> " . translatedText)
				return translatedText
			}
			else {
				logMessage(kLogCritical, translate("Google API response missing translatedText field"))
				return text
			}
		}
		else {
			logMessage(kLogCritical, translate("Google API error: Status ") . result.Status)
			return text
		}
	}
	
	/**
	 * Azure Cognitive Services Translator API v3
	 */
	translateAzure(text, sourceLang, targetLang) {
		local url, body, result, responseText, translatedText, endpoint, region
		
		endpoint := this.iEndpoint
		region := this.iAdditional
		
		if (Trim(this.iAPIKey) = "") {
			logMessage(kLogCritical, translate("Azure API key not configured"))
			return text
		}
		
		if (Trim(endpoint) = "") {
			logMessage(kLogCritical, translate("Azure endpoint not configured"))
			return text
		}
		
		if (Trim(region) = "") {
			logMessage(kLogCritical, translate("Azure region not configured"))
			return text
		}
		
		; Build API URL
		url := endpoint
		if !InStr(url, "/translate")
			url .= "/translate"
		url .= "?api-version=3.0&from=" . sourceLang . "&to=" . targetLang
		
		; Escape text for JSON
		escapedText := StrReplace(text, "\", "\\")
		escapedText := StrReplace(escapedText, '"', '\"')
		escapedText := StrReplace(escapedText, "`n", "\n")
		escapedText := StrReplace(escapedText, "`r", "\r")
		escapedText := StrReplace(escapedText, "`t", "\t")
		
		; Build request body
		body := '[{"text": "' . escapedText . '"}]'
		
		; Make API request
		result := WinHttpRequest().POST(url, body
			, Map("Content-Type", "application/json"
				, "Ocp-Apim-Subscription-Key", this.iAPIKey
				, "Ocp-Apim-Subscription-Region", region)
			, {Encoding: "UTF-8"})
		
		if ((result.Status >= 200) && (result.Status < 300)) {
			responseText := result.Text
			
			; Parse JSON response - get second "text" field (first is input, second is translation)
			if (InStr(responseText, '"text"')) {
				firstTextPos := InStr(responseText, '"text": "')
				startPos := InStr(responseText, '"text": "', false, firstTextPos + 10) + 9
				endPos := InStr(responseText, '"', false, startPos)
				translatedText := SubStr(responseText, startPos, endPos - startPos)
				
				; Unescape JSON
				translatedText := StrReplace(translatedText, "\n", "`n")
				translatedText := StrReplace(translatedText, "\r", "`r")
				translatedText := StrReplace(translatedText, "\t", "`t")
				translatedText := StrReplace(translatedText, '\"', '"')
				translatedText := StrReplace(translatedText, "\\", "\")
				
				logMessage(kLogInfo, translate("Azure translation: ") . text . " -> " . translatedText)
				return translatedText
			}
			else {
				logMessage(kLogCritical, translate("Azure API response missing text field"))
				return text
			}
		}
		else {
			logMessage(kLogCritical, translate("Azure API error: Status ") . result.Status)
			return text
		}
	}
	
	/**
	 * DeepL Translation API
	 */
	translateDeepL(text, sourceLang, targetLang) {
		local url, body, result, responseText, translatedText
		
		if (Trim(this.iAPIKey) = "") {
			logMessage(kLogCritical, translate("DeepL API key not configured"))
			return text
		}
		
		; Use custom endpoint if provided, otherwise use free tier
		if (Trim(this.iEndpoint) != "")
			url := this.iEndpoint
		else
			url := "https://api-free.deepl.com/v2/translate"
		
		; URL encode the text
		encodedText := text
		encodedText := StrReplace(encodedText, "&", "%26")
		encodedText := StrReplace(encodedText, "=", "%3D")
		encodedText := StrReplace(encodedText, "+", "%2B")
		encodedText := StrReplace(encodedText, " ", "+")
		encodedText := StrReplace(encodedText, "`n", "%0A")
		encodedText := StrReplace(encodedText, "`r", "%0D")
		
		; Build request body (URL encoded)
		; DeepL uses uppercase language codes for target
		body := "text=" . encodedText . "&source_lang=" . StrUpper(sourceLang) . "&target_lang=" . StrUpper(targetLang) . "&auth_key=" . this.iAPIKey
		
		; Make API request
		result := WinHttpRequest().POST(url, body
			, Map("Content-Type", "application/x-www-form-urlencoded")
			, {Encoding: "UTF-8"})
		
		if ((result.Status >= 200) && (result.Status < 300)) {
			responseText := result.Text
			
			; Parse JSON response
			if (InStr(responseText, '"text"')) {
				startPos := InStr(responseText, '"text":"') + 8
				endPos := InStr(responseText, '"', false, startPos)
				translatedText := SubStr(responseText, startPos, endPos - startPos)
				
				; Unescape JSON
				translatedText := StrReplace(translatedText, "\n", "`n")
				translatedText := StrReplace(translatedText, "\r", "`r")
				translatedText := StrReplace(translatedText, "\t", "`t")
				translatedText := StrReplace(translatedText, '\"', '"')
				translatedText := StrReplace(translatedText, "\\", "\")
				
				logMessage(kLogInfo, translate("DeepL translation: ") . text . " -> " . translatedText)
				return translatedText
			}
			else {
				logMessage(kLogCritical, translate("DeepL API response missing text field"))
				return text
			}
		}
		else {
			logMessage(kLogCritical, translate("DeepL API error: Status ") . result.Status)
			return text
		}
	}
	
	/**
	 * OpenRouter (LLM-based translation via chat completion)
	 */
	translateOpenRouter(text, sourceLang, targetLang) {
		global kLanguageMapping
		
		local url, body, result, responseText, translatedText, model, targetLangName, prompt
		
		if (Trim(this.iAPIKey) = "") {
			logMessage(kLogCritical, translate("OpenRouter API key not configured"))
			return text
		}
		
		; Get model from Additional field or use default
		model := (Trim(this.iAdditional) != "") ? this.iAdditional : "meta-llama/llama-3.1-8b-instruct:free"
		
		; Get language name for prompt
		targetLangName := this.iTargetLanguage
		
		; Build API URL
		url := "https://openrouter.ai/api/v1/chat/completions"
		
		; Escape text for JSON
		escapedText := StrReplace(text, "\", "\\")
		escapedText := StrReplace(escapedText, '"', '\"')
		escapedText := StrReplace(escapedText, "`n", "\n")
		escapedText := StrReplace(escapedText, "`r", "\r")
		escapedText := StrReplace(escapedText, "`t", "\t")
		
		; Build prompt
		prompt := "Translate the following text to " . targetLangName . ". Only provide the translation, no explanations or additional text: " . escapedText
		
		; Escape prompt for JSON
		escapedPrompt := StrReplace(prompt, "\", "\\")
		escapedPrompt := StrReplace(escapedPrompt, '"', '\"')
		escapedPrompt := StrReplace(escapedPrompt, "`n", "\n")
		escapedPrompt := StrReplace(escapedPrompt, "`r", "\r")
		escapedPrompt := StrReplace(escapedPrompt, "`t", "\t")
		
		; Build request body
		body := '{"model": "' . model . '", "messages": [{"role": "user", "content": "' . escapedPrompt . '"}]}'
		
		; Make API request
		result := WinHttpRequest().POST(url, body
			, Map("Content-Type", "application/json"
				, "Authorization", "Bearer " . this.iAPIKey
				, "HTTP-Referer", "https://github.com/SeriousOldMan/Simulator-Controller"
				, "X-Title", "Simulator Controller Translation")
			, {Encoding: "UTF-8"})
		
		if ((result.Status >= 200) && (result.Status < 300)) {
			responseText := result.Text
			
			; Parse JSON response - extract content from chat completion
			if (InStr(responseText, '"content"')) {
				startPos := InStr(responseText, '"content": "') + 12
				endPos := InStr(responseText, '"', false, startPos)
				translatedText := SubStr(responseText, startPos, endPos - startPos)
				
				; Unescape JSON
				translatedText := StrReplace(translatedText, "\n", "`n")
				translatedText := StrReplace(translatedText, "\r", "`r")
				translatedText := StrReplace(translatedText, "\t", "`t")
				translatedText := StrReplace(translatedText, '\"', '"')
				translatedText := StrReplace(translatedText, "\\", "\")
				
				; Clean up any extra formatting from LLM (sometimes adds quotes or explanations)
				translatedText := Trim(translatedText)
				
				logMessage(kLogInfo, translate("OpenRouter translation: ") . text . " -> " . translatedText)
				return translatedText
			}
			else {
				logMessage(kLogCritical, translate("OpenRouter API response missing content field"))
				return text
			}
		}
		else {
			logMessage(kLogCritical, translate("OpenRouter API error: Status ") . result.Status)
			return text
		}
	}
	
	/**
	 * Clear translation cache
	 */
	clearCache() {
		this.iCache := CaseInsenseMap()
		logMessage(kLogInfo, translate("Translation cache cleared"))
	}
	
	/**
	 * Get cache size
	 */
	getCacheSize() {
		return this.iCache.Count
	}
}
