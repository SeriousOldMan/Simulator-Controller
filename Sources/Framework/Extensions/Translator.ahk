;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Translator                      ;;;
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
global kSupportedLanguages := CaseInsenseMap("English", {Code: "en", Name: "English"},
											 "Spanish", {Code: "es", Name: "Spanish"},
											 "French", {Code: "fr", Name: "French"},
											 "German", {Code: "de", Name: "German"},
											 "Italian", {Code: "it", Name: "Italian"},
											 "Portuguese", {Code: "pt", Name: "Portuguese"},
											 "Japanese", {Code: "ja", Name: "Japanese"},
											 "Chinese", {Code: "zh", Name: "Chinese"},
											 "Korean", {Code: "ko", Name: "Korean"},
											 "Russian", {Code: "ru", Name: "Russian"},
											 "Arabic", {Code: "ar", Name: "Arabic"},
											 "Dutch", {Code: "nl", Name: "Dutch"},
											 "Polish", {Code: "pl", Name: "Polish"},
											 "Swedish", {Code: "sv", Name: "Swedish"},
											 "Turkish", {Code: "tr", Name: "Turkish"},
											 "Hindi", {Code: "hi", Name: "Hindi"},
											 "Thai", {Code: "th", Name: "Thai"},
											 "Vietnamese", {Code: "vi", Name: "Vietnamese"},
											 "Czech", {Code: "cs", Name: "Czech"},
											 "Danish", {Code: "da", Name: "Danish"},
											 "Finnish", {Code: "fi", Name: "Finnish"},
											 "Norwegian", {Code: "no", Name: "Norwegian"},
											 "Hungarian", {Code: "hu", Name: "Hungarian"},
											 "Romanian", {Code: "ro", Name: "Romanian"})


;;;-------------------------------------------------------------------------;;;
;;;                          Public Class Section                           ;;;
;;;-------------------------------------------------------------------------;;;

class Translator {
	iService := "Google"

	iServiceURL := false
	iAPIKey := false
	iArguments := []

	iSourceLanguage := "English"
	iSourceLanguageCode := "en"

	iTargetLanguage := "Dutch"
	iTargetLanguageCode := "nl"

	iCache := CaseInsenseMap()

	Service {
		Get {
			return this.iService
		}
	}

	ServiceURL {
		Get {
			return this.iServiceURL
		}
	}

	APIKey {
		Get {
			return this.iAPIKey
		}
	}

	Arguments {
		Get {
			return this.iArguments
		}
	}

	Endpoint {
		Get {
			return this.Arguments[1]
		}
	}

	Region {
		Get {
			return this.Arguments[2]
		}
	}

	Model {
		Get {
			return this.Arguments[1]
		}
	}

	SourceLanguage {
		Get {
			return this.iSourceLanguage
		}
	}

	SourceLanguageCode {
		Get {
			return this.iSourceLanguageCode
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

	__New(service, sourceLanguage, targetLanguage, apiKey := "", arguments*) {
		local endpoint, region, model, url

		if !kSupportedLanguages.Has(sourceLanguage)
			throw "Source language not recognized in Translator.__New..."

		if !kSupportedLanguages.Has(targetLanguage)
			throw "Target language not recognized in Translator.__New..."

		this.iSourceLanguage := sourceLanguage
		this.iSourceLanguageCode := kSupportedLanguages[sourceLanguage].Code

		this.iTargetLanguage := targetLanguage
		this.iTargetLanguageCode := kSupportedLanguages[targetLanguage].Code

		apiKey := Trim(apiKey)

		switch service, false {
			case "Google":
				if !apiKey
					throw "Invalid Google API key detected in Translator.__New..."

				this.iServiceURL := ("https://translation.googleapis.com/language/translate/v2?key=" . apiKey)
			case "Azure":
				if !apiKey
					throw "Invalid Azure API key detected in Translator.__New..."

				endpoint := Trim(arguments[1])

				if !endpoint
					throw "Invalid Azure Endpoint detected in Translator.__New..."

				if !Trim(arguments[2])
					throw "Invalid Azure Region detected in Translator.__New..."

				/*
				if ((endpoint != "") && !InStr(endpoint, "translator/text/v3.0"))
					endpoint .= ((SubStr(endpoint, StrLen(endpoint), 1) = "/") ? "translator/text/v3.0"
																			   : "/translator/text/v3.0")
				*/

				if (SubStr(endpoint, StrLen(endpoint), 1) != "/")
					endpoint .= "/"

				arguments[1] := endpoint

				this.iServiceURL := (endpoint . (!InStr(endpoint, "/translate") ? "translate" : "")
											  . "?api-version=3.0&from=" . this.SourceLanguageCode
											  . "&to=" . this.TargetLanguageCode)

				; this.iServiceURL := (endpoint . "&to=" . this.TargetLanguageCode)
			case "deepL":
				if !apiKey
					throw "Invalid deepL API key detected in Translator.__New..."

				if ((arguments.Length > 0) && (Trim(arguments[1]) != ""))
					this.iServiceURL := Trim(arguments[1])
				else
					this.iServiceURL := "https://api-free.deepl.com/v2/translate"
			case "OpenRouter":
				if !apiKey
					throw "Invalid OpenRouter API key detected in Translator.__New..."

				if ((arguments.Length = 0) && (Trim(arguments[1]) = ""))
					throw "Invalid OpenRouter model detected in Translator.__New..."

				this.iServiceURL := "https://openrouter.ai/api/v1/chat/completions"
			default:
				throw "Unsupported service detected in Translator.__New..."
		}

		this.iService := service
		this.iAPIKey := apiKey
		this.iArguments := arguments
	}

	/**
	 * Main translation method - translates text to target language
	 * @param text - Text to translate
	 * @param sourceLang - Source language code (default: "en" for English)
	 * @param targetLang - Override target language code (optional)
	 * @returns Translated text or original text on error
	 */
	translate(text) {
		local result, cacheKey

		if !Trim(text)
			return text

		; No translation needed if source and target are the same
		if (this.SourceLanguageCode = this.TargetLanguageCode)
			return text

		; Check cache
		cacheKey := (this.iService . ":" . this.SourceLanguageCode . "->" . this.TargetLanguageCode . ":" . text)

		if this.iCache.Has(cacheKey) {
			logMessage(kLogDebug, translate("Translation cache hit: ") . text)

			return this.iCache[cacheKey]
		}

		; Route to appropriate service
		try {
			switch this.iService, false {
				case "Google":
					result := this.translateGoogle(text)
				case "Azure":
					result := this.translateAzure(text)
				case "DeepL":
					result := this.translateDeepL(text)
				case "OpenRouter":
					result := this.translateOpenRouter(text)
			}

			; Cache the result
			if (result != text)
				this.iCache[cacheKey] := result

			return result
		}
		catch Any as exception {
			logError(exception, true)

			return text
		}
	}

	text2JSON(text) {
		return StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(text, "\", "\\"), '"', '\"'), "`n", "\n"), "`r", "\r"), "`t", "\t")
	}

	json2Text(jsonText) {
		return StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(jsonText, "\n", "`n"), "\r", "`r"), "\t", "`t"), '\"', '"'), "\\", "\")
	}

	text2URL(text) {
		return StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(text, "&", "%26"), "=", "%3D"), "+", "%2B"), " ", "+"), "`n", "%0A"), "`r", "%0D")
	}

	/**
	 * Google Cloud Translation API v2
	 */
	translateGoogle(text) {
		local body, result

		; Build request body
		body := '{"q": "' . this.text2JSON(text) . '", "source": "' . this.SourceLanguageCode
												 . '", "target": "' . this.TargetLanguageCode . '", "format": "text"}'

		try {
			result := WinHttpRequest().POST(this.ServiceURL, body, Map("Content-Type", "application/json"), {Encoding: "UTF-8"})

			if ((result.Status >= 200) && (result.Status < 300))
				return this.json2Text(JSON.parse(result.Text)["data"]["translations"][1]["translatedText"])
			else
				throw "Translation failed in Translator.translateGoogle..."
		}
		catch Any as exception {
			logError(exception, true)

			return text
		}
	}

	/**
	 * Azure Cognitive Services Translator API v3
	 */
	translateAzure(text) {
		local result

		try {
			; Make API request
			result := WinHttpRequest().POST(this.ServiceURL, '[{"text": "' . this.text2JSON(text) . '"}]'
										  , Map("Content-Type", "application/json"
											  , "Ocp-Apim-Subscription-Key", this.APIKey
											  , "Ocp-Apim-Subscription-Region", this.Region)
										  , {Encoding: "UTF-8"})

			if ((result.Status >= 200) && (result.Status < 300))
				return this.json2Text(JSON.parse(result.Text)[1]["translations"][1]["text"])
			else
				throw "Translation failed in Translator.translateAzure..."
		}
		catch Any as exception {
			logError(exception, true)

			return text
		}
	}

	/**
	 * DeepL Translation API
	 */
	translateDeepL(text) {
		local body, result

		try {
			; Build request body (JSON encoded)
			body := '{"text": ["' . this.text2JSON(text) . '"], "source_lang": "' . StrUpper(this.SourceLanguageCode)
														 . '", "target_lang": "' . StrUpper(this.TargetLanguageCode) . '"}'

			; Make API request
			result := WinHttpRequest().POST(this.ServiceURL, body
										  , Map("Content-Type", "application/json"
											  , "Authorization", "DeepL-Auth-Key " . this.APIKey)
										  , {Encoding: "UTF-8"})

			if ((result.Status >= 200) && (result.Status < 300))
				return this.json2Text(JSON.parse(result.Text)["translations"][1]["text"])
			else
				throw "Translation failed in Translator.translateDeepL..."
		}
		catch Any as exception {
			logError(exception, true)

			return text
		}
	}

	/**
	 * OpenRouter (LLM-based translation via chat completion)
	 */
	translateOpenRouter(text) {
		local prompt, body, result

		try {
			; Build prompt
			prompt := ("Translate the following text from " . this.SourceLanguage . " to " . this.TargetLanguage . ". Only provide the translation, no explanations or additional text:\n" . this.text2JSON(text))

			; Build request body
			body := '{"model": "' . this.Model . '", "messages": [{"role": "user", "content": "' . prompt . '"}]}'

			; Make API request
			result := WinHttpRequest().POST(this.ServiceURL, body
										  , Map("Content-Type", "application/json"
											  , "Authorization", "Bearer " . this.APIKey)
										  , {Encoding: "UTF-8"})
			if ((result.Status >= 200) && (result.Status < 300))
				return this.json2Text(JSON.parse(result.Text)["choices"][1]["message"]["content"])
			else
				throw "Translation failed in Translator.translateOpenRouter..."
		}
		catch Any as exception {
			logError(exception, true)

			return text
		}
	}
}
