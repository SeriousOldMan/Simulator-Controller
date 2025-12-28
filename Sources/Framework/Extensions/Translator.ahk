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
;;;                          Public Class Section                           ;;;
;;;-------------------------------------------------------------------------;;;

class Translator {
	static kTranslatorLanguages := CaseInsenseMap("English", {Code: "en", Name: "English"},
												  "Spanish", {Code: "es", Name: "Español"},
												  "French", {Code: "fr", Name: "Français"},
												  "German", {Code: "de", Name: "Deutsch"},
												  "Italian", {Code: "it", Name: "Italiano"},
												  "Portuguese", {Code: "pt", Name: "Português"},
												  "Japanese", {Code: "ja", Name: "日本語"},
												  "Chinese", {Code: "zh", Name: "简体中文"},
												  "Korean", {Code: "ko", Name: "한국어"},
												  "Russian", {Code: "ru", Name: "Русский"},
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
												  "Romanian", {Code: "ro", Name: "Română"},
												  "Lithuanian", {Code: "lt", Name: "Lietuvių"})
	static sTranslatorLanguages := CaseInsenseMap()

	iService := "Google"

	iServiceURL := false
	iAPIKey := false
	iArguments := []

	iSourceLanguage := "English"
	iSourceLanguageCode := "en"

	iTargetLanguage := "Dutch"
	iTargetLanguageCode := "nl"

	iCache := CaseInsenseMap()

	static Languages[type := false] {
		Get {
			if (this.sTranslatorLanguages.Count = 0)
				this.initializeLanguages()

			if type
				return this.sTranslatorLanguages
			else
				return this.kTranslatorLanguages
		}
	}

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

	__New(service, sourceLanguage := false, targetLanguage := false, apiKey := false, arguments*) {
		local endpoint, region, model, url

		if InStr(service, "|") {
			service := string2Values("|", service)

			if (service.Length = 5) {
				sourceLanguage := service[2]
				targetLanguage := service[3]
				apiKey := service[4]
				arguments := string2Values(",", service[5])
			}
			else {
				sourceLanguage := "English"
				targetLanguage := service[2]
				apiKey := service[3]
				arguments := string2Values(",", service[4])
			}
		}

		if !Translator.Languages["All"].Has(sourceLanguage)
			throw "Source language '" . sourceLanguage . "' not recognized in Translator.__New..."

		if !Translator.Languages["All"].Has(targetLanguage)
			throw "Target language '" . targetLanguage . "' not recognized in Translator.__New..."

		this.iSourceLanguage := Translator.Languages["All"][sourceLanguage].Identifier
		this.iSourceLanguageCode := Translator.Languages["All"][sourceLanguage].Code

		this.iTargetLanguage := Translator.Languages["All"][targetLanguage].Identifier
		this.iTargetLanguageCode := Translator.Languages["All"][targetLanguage].Code

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

				if ((arguments.Length > 0) && (Trim(arguments[1]) != "")) {
					url := Trim(arguments[1])

					if InStr(url, "/v2/translate")
						url := StrReplace(url, "/v2/translate", "")

					if (SubStr(url, StrLen(url)) = "/")
						url := SubStr(url, 1, StrLen(url) - 1)

					this.iServiceURL := (url . "/v2/translate")
				}
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

	static initializeLanguages() {
		local identifier, language, ignore, fileName

		for ignore, fileName in [kTranslationsDirectory . "Translator Languages.csv"
							   , kUserTranslationsDirectory . "Translator Languages.csv"]
			if FileExist(fileName)
				loop Read, fileName
					if ((Trim(A_LoopReadLine) != "") && (SubStr(Trim(A_LoopReadLine), 1, 1) != ";")) {
						language := string2Values(",", Trim(A_LoopReadLine))

						if (language.Length = 3)
							if this.kTranslatorLanguages.Has(language[1]) {
								kTranslatorLanguages[language[1]].Code := language[2]
								kTranslatorLanguages[language[1]].Name := language[3]
							}
							else
								kTranslatorLanguages[language[1]] := {Code: language[2], Name: language[3]}
					}

		for identifier, language in this.kTranslatorLanguages {
			language.Identifier := identifier

			this.sTranslatorLanguages[identifier] := language
			this.sTranslatorLanguages[language.Code] := language
		}

		if isDebug()
			logMessage(kLogDebug, "Language keys: " . values2String(", ", getKeys(this.sTranslatorLanguages)*))
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

			if isDebug()
				logMessage(kLogDebug, "Translating `"" . SubStr(text, 1, 20) . "...`" to `"" . SubStr(result, 1, 20) . "...`"")

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
