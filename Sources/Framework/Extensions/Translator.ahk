;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Translator                      ;;;
;;;                                                                         ;;;
;;;   Provides text translation services using multiple providers:          ;;;
;;;   - Google Cloud Translation API v2                                     ;;;
;;;   - Azure Cognitive Services Translator                                 ;;;
;;;   - DeepL Translation API                                               ;;;
;;;   - OpenAI (LLM-based translation)                                      ;;;
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
;;;                        Public Constant Section                          ;;;
;;;-------------------------------------------------------------------------;;;

global kTranslatorLanguages := CaseInsenseMap("English", {Code: "en", Name: "English"},
											  "Spanish", {Code: "es", Name: "Español"},
											  "French", {Code: "fr", Name: "Français"},
											  "German", {Code: "de", Name: "Deutsch"},
											  "Italian", {Code: "it", Name: "Italiano"},
											  "Portuguese", {Code: "pt", Name: "Português"},
											  "Japanese", {Code: "ja", Name: "日本語"},
											  "Chinese", {Code: "zh", Name: "简体中文"},
											  "Korean", {Code: "ko", Name: "한국어"},
											  "Russian", {Code: "ru", Name: "Русский язык"},
											  "Arabic", {Code: "ar", Name: "اَلْعَرَبِيَّةُ"},
											  "Dutch", {Code: "nl", Name: "Nederlands"},
											  "Polish", {Code: "pl", Name: "Polski"},
											  "Swedish", {Code: "sv", Name: "Svenska"},
											  "Turkish", {Code: "tr", Name: "Türkçe"},
											  "Hindi", {Code: "hi", Name: "हिन्दी"},
											  "Thai", {Code: "th", Name: "ภาษาไทย"},
											  "Vietnamese", {Code: "vi", Name: "Tiếng Việt"},
											  "Czech", {Code: "cs", Name: "Čeština"},
											  "Danish", {Code: "da", Name: "Dansk"},
											  "Finnish", {Code: "fi", Name: "Suomi"},
											  "Norwegian", {Code: "no", Name: "Norsk"},
											  "Hungarian", {Code: "hu", Name: "Magyar"},
											  "Romanian", {Code: "ro", Name: "Română"})


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

		if !kTranslatorLanguages.Has(sourceLanguage)
			throw "Source language not recognized in Translator.__New..."

		if !kTranslatorLanguages.Has(targetLanguage)
			throw "Target language not recognized in Translator.__New..."

		this.iSourceLanguage := sourceLanguage
		this.iSourceLanguageCode := kTranslatorLanguages[sourceLanguage].Code

		this.iTargetLanguage := targetLanguage
		this.iTargetLanguageCode := kTranslatorLanguages[targetLanguage].Code

		apiKey := Trim(apiKey)

		switch service, false {
			case "Google":
				if !apiKey
					throw "Invalid Google API key detected in Translator.__New..."

				this.iServiceURL := ("https://translation.googleapis.com/language/translate/v2?key=" . apiKey)
			case "Azure":
				if !apiKey
					throw "Invalid Azure API key detected in Translator.__New..."

				if ((arguments.Length = 0) || (Trim(arguments[1]) = ""))
					throw "Invalid Azure Endpoint detected in Translator.__New..."
				else
					endpoint := Trim(arguments[1])

				if ((arguments.Length < 2) || (Trim(arguments[2]) = ""))
					throw "Invalid Azure Region detected in Translator.__New..."

				if (SubStr(endpoint, StrLen(endpoint), 1) != "/")
					endpoint .= "/"

				arguments[1] := endpoint

				this.iServiceURL := (endpoint . (!InStr(endpoint, "/translate") ? "translate" : "")
											  . "?api-version=3.0&from=" . this.SourceLanguageCode
											  . "&to=" . this.TargetLanguageCode)
			case "DeepL":
				if !apiKey
					throw "Invalid deepL API key detected in Translator.__New..."

				if ((arguments.Length > 0) && (Trim(arguments[1]) != ""))
					this.iServiceURL := Trim(arguments[1])
				else
					this.iServiceURL := "https://api-free.deepl.com/v2/translate"
			case "OpenAI":
				if !apiKey
					throw "Invalid OpenAI API key detected in Translator.__New..."

				if ((arguments.Length = 0) || (Trim(arguments[1]) = ""))
					throw "Invalid OpenAI URL detected in Translator.__New..."
				else {
					url := Trim(arguments[1])

					if InStr(url, "/v1/chat/completions")
						url := StrReplace(url, "/v1/chat/completions", "")

					if (SubStr(url, StrLen(url)) = "/")
						url := SubStr(url, 1, StrLen(url) - 1)
				}

				if ((arguments.Length < 2) || (Trim(arguments[2]) = ""))
					throw "Invalid OpenAI model detected in Translator.__New..."
				else
					arguments := [Trim(arguments[2])]

				this.iServiceURL := (url . "/v1/chat/completions")
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
				case "OpenAI":
					result := this.translateOpenAI(text)
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
	 * OpenAI (LLM-based translation via chat completion)
	 */
	translateOpenAI(text) {
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
				throw "Translation failed in Translator.translateOpenAI..."
		}
		catch Any as exception {
			logError(exception, true)

			return text
		}
	}
}
