;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Speech Recognizer               ;;;
;;;                                                                         ;;;
;;;   Part of this code is based on work of evilC. See the GitHub page      ;;;
;;;   https://github.com/evilC/HotVoice for mor information.                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "CLR.ahk"
#Include "HTTP.ahk"
#Include "Task.ahk"
#Include "SpeechSynthesizer.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kAzureLanguages := Map("af-ZA", "Afrikaans (South Africa)"
							, "am-ET", "Amharic (Ethiopia)"
							, "ar-DZ", "Arabic (Algeria)"
							, "ar-BH", "Arabic (Bahrain)"
							, "ar-EG", "Arabic (Egypt)"
							, "ar-IQ", "Arabic (Iraq)"
							, "ar-IL", "Arabic (Israel)"
							, "ar-JO", "Arabic (Jordan)"
							, "ar-KW", "Arabic (Kuwait)"
							, "ar-LB", "Arabic (Lebanon)"
							, "ar-LY", "Arabic (Libya)"
							, "ar-MA", "Arabic (Morocco)"
							, "ar-OM", "Arabic (Oman)"
							, "ar-PS", "Arabic (Palestinian Authority)"
							, "ar-QA", "Arabic (Qatar)"
							, "ar-SA", "Arabic (Saudi Arabia)"
							, "ar-SY", "Arabic (Syria)"
							, "ar-TN", "Arabic (Tunisia)"
							, "ar-AE", "Arabic (United Arab Emirates)"
							, "ar-YE", "Arabic (Yemen)"
							, "bg-BG", "Bulgarian (Bulgaria)"
							, "my-MM", "Burmese (Myanmar)"
							, "ca-ES", "Catalan (Spain)"
							, "zh-HK", "Chinese (Cantonese, Traditional)"
							, "zh-CN", "Chinese (Mandarin, Simplified)"
							, "zh-TW", "Chinese (Taiwanese Mandarin)"
							, "hr-HR", "Croatian (Croatia)"
							, "cs-CZ", "Czech (Czech)"
							, "da-DK", "Danish (Denmark)"
							, "nl-BE", "Dutch (Belgium)"
							, "nl-NL", "Dutch (Netherlands)"
							, "en-AU", "English (Australia)"
							, "en-CA", "English (Canada)"
							, "en-GH", "English (Ghana)"
							, "en-HK", "English (Hong Kong)"
							, "en-IN", "English (India)"
							, "en-IE", "English (Ireland)"
							, "en-KE", "English (Kenya)"
							, "en-NZ", "English (New Zealand)"
							, "en-NG", "English (Nigeria)"
							, "en-PH", "English (Philippines)"
							, "en-SG", "English (Singapore)"
							, "en-ZA", "English (South Africa)"
							, "en-TZ", "English (Tanzania)"
							, "en-GG", "English (United Kingdom)"
							, "en-US", "English (United States)")

initializeAzureLanguages() {
	local culture, name

	for culture, name in Map("et-EE", "Estonian (Estonia)"
						   , "fil-PH", "Filipino (Philippines)"
						   , "fi-FI", "Finnish (Finland)"
						   , "fr-BE", "French (Belgium)"
						   , "fr-CA", "French (Canada)"
						   , "fr-FR", "French (France)"
						   , "fr-CH", "French (Switzerland)"
						   , "de-AT", "German (Austria)"
						   , "de-DE", "German (Germany)"
						   , "de-CH", "German (Switzerland)"
						   , "el-GR", "Greek (Greece)"
						   , "gu-IN", "Gujarati (Indian)"
						   , "he-IL", "Hebrew (Israel)"
						   , "hi-IN", "Hindi (India)"
						   , "hu-HU", "Hungarian (Hungary)"
						   , "is-IS", "Icelandic (Iceland)"
						   , "id-ID", "Indonesian (Indonesia)"
						   , "ga-IE", "Irish (Ireland)"
						   , "it-IT", "Italian (Italy)"
						   , "ja-JP", "Japanese (Japan)"
						   , "jv-ID", "Javanese (Indonesia)"
						   , "kn-IN", "Kannada (India)"
						   , "km-KH", "Khmer (Cambodia)"
						   , "ko-KR", "Korean (Korea)"
						   , "lo-LA", "Lao (Laos)"
						   , "lv-LV", "Latvian (Latvia)"
						   , "lt-LT", "Lithuanian (Lithuania)"
						   , "mk-MK", "Macedonian (North Macedonia)"
						   , "ms-MY", "Malay (Malaysia)"
						   , "mt-MT", "Maltese (Malta)"
						   , "mr-IN", "Marathi (India)"
						   , "nb-NO", "Norwegian (Bokmal, Norway)"
						   , "fa-IR", "Persian (Iran)"
						   , "pl-PL", "Polish (Poland)"
						   , "pt-BR", "Portuguese (Brazil)"
						   , "pt-PT", "Portuguese (Portugal)"
						   , "ro-RO", "Romanian (Romania)"
						   , "ru-RU", "Russian (Russia)"
						   , "sr-RS", "Serbian (Serbia)"
						   , "si-LK", "Sinhala (Sri Lanka)"
						   , "sk-SK", "Slovak (Slovakia)"
						   , "sl-SI", "Slovenian (Slovenia)"
						   , "es-AR", "Spanish (Argentina)"
						   , "es-BO", "Spanish (Bolivia)"
						   , "es-CL", "Spanish (Chile)"
						   , "es-CO", "Spanish (Colombia)"
						   , "es-CR", "Spanish (Costa Rica)"
						   , "es-CU", "Spanish (Cuba)"
						   , "es-DO", "Spanish (Dominican Republic)"
						   , "es-EC", "Spanish (Ecuador)"
						   , "es-SV", "Spanish (El Salvador)"
						   , "es-GQ", "Spanish (Equatorial Guinea)"
						   , "es-GT", "Spanish (Guatemala)"
						   , "es-HN", "Spanish (Honduras)"
						   , "es-MX", "Spanish (Mexico)"
						   , "es-NI", "Spanish (Nicaragua)"
						   , "es-PA", "Spanish (Panama)"
						   , "es-PY", "Spanish (Paraguay)"
						   , "es-PE", "Spanish (Peru)"
						   , "es-PR", "Spanish (Puerto Rico)"
						   , "es-ES", "Spanish (Spain)"
						   , "es-UY", "Spanish (Uruguay)"
						   , "es-US", "Spanish (USA)"
						   , "es-VE", "Spanish (Venezuela)"
						   , "sw-KE", "Swahili (Kenya)"
						   , "sw-TZ", "Swahili (Tanzania)"
						   , "sv-SE", "Swedish (Sweden)"
						   , "ta-IN", "Tamil (India)"
						   , "te-IN", "Telugu (India)"
						   , "th-TH", "Thai (Thailand)"
						   , "tr-TR", "Turkish (Turkey)"
						   , "uk-UA", "Ukrainian (Ukraine)"
						   , "uz-UZ", "Uzbek (Uzbekistan)"
						   , "vi-VN", "Vietnamese (Vietnam)"
						   , "zu-ZA", "Zulu (South Africa)")
		kAzureLanguages[culture] := name
}

initializeAzureLanguages()

global kGoogleLanguages := Map()

initializeGoogleLanguages() {
	local ignore, culture

	for ignore, culture in ["am-ET", "ar-DZ", "ar-BH", "ar-EG", "ar-IQ", "ar-IL", "ar-JO", "ar-KW", "ar-LB", "ar-LY"
						  , "ar-MA", "ar-OM", "ar-PS", "ar-QA", "ar-SA", "ar-SY", "ar-TN", "ar-AE", "ar-YE", "bg-BG"
						  , "my-MM", "ca-ES", "zh-HK", "zh-CN", "zh-TW", "hr-HR", "cs-CZ", "da-DK", "nl-BE", "nl-NL"
						  , "en-AU", "en-CA", "en-GH", "en-HK", "en-IN", "en-IE", "en-KE", "en-NZ", "en-NG", "en-PH"
						  , "en-SG", "en-ZA", "en-TZ", "en-GG", "en-US", "et-EE", "fil-PH", "fi-FI", "fr-BE", "fr-CA"
						  , "fr-FR", "fr-CH", "de-AT", "de-DE", "de-CH", "el-GR", "gu-IN", "he-IL", "hi-IN", "hu-HU"
						  , "is-IS", "id-ID", "ga-IE", "it-IT", "ja-JP", "jv-ID", "kn-IN", "km-KH", "ko-KR", "lo-LA"
						  , "lv-LV", "lt-LT", "mk-MK", "ms-MY", "mt-MT", "mr-IN", "nb-NO", "fa-IR", "pl-PL", "pt-BR"
						  , "pt-PT", "ro-RO", "ru-RU", "sr-RS", "si-LK", "sk-SK", "sl-SI", "es-AR", "es-BO", "es-CL"
						  , "es-CO", "es-CR", "es-CU", "es-DO", "es-EC", "es-SV", "es-GQ", "es-GT", "es-HN", "es-MX"
						  , "es-NI", "es-PA", "es-PY", "es-PE", "es-PR", "es-ES", "es-UY", "es-US", "es-VE", "sw-KE"
						  , "sw-TZ", "sv-SE", "ta-IN", "te-IN", "th-TH", "tr-TR", "uk-UA", "uz-UZ", "vi-VN", "zu-ZA"]
		kGoogleLanguages[culture] := ["Long Speech (latest_long)", "Short Speech (latest_short)"]
}

initializeGoogleLanguages()


;;;-------------------------------------------------------------------------;;;
;;;                          Public Class Section                           ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    SpeechRecognizer                               ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SpeechRecognizer {
	iEngine := false
	iChoices := CaseInsenseMap()

	iMode := "Grammar"

	iGoogleMode := "HTTP"
	iGoogleAPIKey := false
	iGoogleCapturedAudioFile := false

	static sAudioRoutingInitialized := false
	static sRecognizerAudioDevice := false
	static sDefaultAudioDevice := false

	_grammarCallbacks := CaseInsenseMap()
	_grammars := CaseInsenseMap()

	_recognitionHandlers := []

	Routing {
		Get {
			return "Standard"
		}
	}

	Engine {
		Get {
			return this.iEngine
		}
	}

	Method {
		Get {
			return (inList(["Azure", "Google"], this.Engine) ? "Text" : "Pattern")
		}
	}

	Choices[name?] {
		Get {
			return this.getChoices(name?)
		}
	}

	Grammars[name?] {
		Get {
			return (isSet(name) ? this._grammars[name] : this._grammars)
		}

		Set {
			return (isSet(name) ? (this._grammars[name] := value) : (this._grammars := value))
		}
	}

	Recognizers[language := false] {
		Get {
			local result := []
			local ignore, recognizer

			for ignore, recognizer in this.getRecognizerList()
				if language {
					if (recognizer.Language = language)
						result.Push(recognizer.Name)
				}
				else
					result.Push(recognizer.Name)

			return result
		}
	}

	__New(engine, recognizer := false, language := false, silent := false, mode := "Grammar") {
		local dllName := ((InStr(engine, "Google|") = 1) ? "Google.Speech.Recognizer.dll" : "Microsoft.Speech.Recognizer.dll")
		local dllFile := (kBinariesDirectory . ((InStr(engine, "Google|") = 1) ? "Google\" : "Microsoft\") . dllName)
		local instance, choices, found, ignore, recognizerDescriptor, configuration, audioDevice

		this.iEngine := engine
		this.Instance := false
		this.RecognizerList := []
		this.iMode := mode

		try {
			if (!FileExist(dllFile)) {
				logMessage(kLogCritical, translate("Speech.Recognizer.dll not found in ") . kBinariesDirectory)

				throw "Unable to find Speech.Recognizer.dll in " . kBinariesDirectory . "..."
			}

			if !SpeechRecognizer.sAudioRoutingInitialized {
				SpeechRecognizer.sAudioRoutingInitialized := true

				configuration := readMultiMap(kUserConfigDirectory . "Audio Settings.ini")

				SpeechRecognizer.sRecognizerAudioDevice := getMultiMapValue(configuration, "Input", this.Routing . ".AudioDevice", false)
				SpeechRecognizer.sDefaultAudioDevice := getMultiMapValue(configuration, "Input", "Default.AudioDevice", SpeechRecognizer.sRecognizerAudioDevice)
			}

			if (SpeechRecognizer.sRecognizerAudioDevice && kNirCmd) {
				audioDevice := SpeechRecognizer.sRecognizerAudioDevice

				try {
					Run("`"" . kNirCmd . "`" setdefaultsounddevice `"" . audioDevice . "`"")
				}
				catch Any as exception {
					logError(exception, true)

					showMessage(substituteVariables(translate("Cannot start NirCmd (%kNirCmd%) - please check the configuration..."))
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				}
			}

			if !language
				language := "en"

			if ((InStr(engine, "Azure|") == 1) || (engine = "Compiler")) {
				instance := CLR_LoadLibrary(dllFile).CreateInstance("Speech.MicrosoftSpeechRecognizer")

				this.Instance := instance

				this.iEngine := ((engine = "Compiler") ? "Compiler" : string2Values("|", engine)[1])

				if (engine != "Compiler") {
					engine := string2Values("|", engine)

					if !instance.Connect(engine[2], engine[3], ObjBindMethod(this, "_onTextCallback")) {
						logMessage(kLogCritical, translate("Could not communicate with speech recognizer library (") . dllName . translate(")"))
						logMessage(kLogCritical, translate("Try running the Powershell command `"Get-ChildItem -Path '.' -Recurse | Unblock-File`" in the Binaries folder"))

						throw "Could not communicate with speech recognizer library (" . dllName . ")..."
					}
				}

				choices := []

				loop 101
					choices.Push((A_Index - 1) . "")

				this.setChoices("Number", choices)

				choices := []

				loop 10
					choices.Push((A_Index - 1) . "")

				this.setChoices("Digit", choices)
			}
			else if (InStr(engine, "Google|") == 1) {
				instance := CLR_LoadLibrary(dllFile).CreateInstance("Speech.GoogleSpeechRecognizer")

				this.Instance := instance

				this.iEngine := "Google"

				engine := string2Values("|", engine)

				if (this.iGoogleMode = "RPC")
					EnvSet("GOOGLE_APPLICATION_CREDENTIALS", engine[2])
				else
					this.iGoogleAPIKey := engine[2]

				if !instance.Connect(this.iGoogleMode, engine[2], ObjBindMethod(this, "_onTextCallback")) {
					logMessage(kLogCritical, translate("Could not communicate with speech recognizer library (") . dllName . translate(")"))
					logMessage(kLogCritical, translate("Try running the Powershell command `"Get-ChildItem -Path '.' -Recurse | Unblock-File`" in the Binaries folder"))

					throw "Could not communicate with speech recognizer library (" . dllName . ")..."
				}

				choices := []

				loop 101
					choices.Push((A_Index - 1) . "")

				this.setChoices("Number", choices)

				choices := []

				loop 10
					choices.Push((A_Index - 1) . "")

				this.setChoices("Digit", choices)
			}
			else {
				instance := CLR_LoadLibrary(dllFile).CreateInstance("Speech.MicrosoftSpeechRecognizer")

				this.Instance := instance

				instance.SetEngine(engine)
			}

			this.setMode(mode)

			if (engine != "Compiler") {
				if (this.Instance.OkCheck() != "OK") {
					logMessage(kLogCritical, translate("Could not communicate with speech recognizer library (") . dllName . translate(")"))
					logMessage(kLogCritical, translate("Try running the Powershell command `"Get-ChildItem -Path '.' -Recurse | Unblock-File`" in the Binaries folder"))

					throw "Could not communicate with speech recognizer library (" . dllName . ")..."
				}

				this.RecognizerList := this.createRecognizerList()

				if (this.RecognizerList.Length == 0) {
					logMessage(kLogCritical, translate("No languages found while initializing speech recognition system - please install the speech recognition software"))

					if !silent
						showMessage(translate("No languages found while initializing speech recognition system - please install the speech recognition software") . translate("...")
								  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				}

				found := false

				if ((recognizer == true) && language) {
					for ignore, recognizerDescriptor in this.getRecognizerList()
						if ((recognizerDescriptor.Language = language) && ((this.Engine != "Google") || (recognizerDescriptor.Model = "latest_short"))) {
							recognizer := recognizerDescriptor.ID

							found := true

							break
						}
				}
				else if (recognizer && (recognizer != true))
					for ignore, recognizerDescriptor in this.getRecognizerList()
						if (recognizerDescriptor.Name = recognizer) {
							recognizer := recognizerDescriptor.ID

							found := true

							break
						}

				if !found
					recognizer := 0

				this.initialize(recognizer)
			}
		}
		catch Any as exception {
			logError(exception, true)

			logMessage(kLogCritical, translate("Error while initializing speech recognition module - please install the speech recognition software"))

			if !silent
				showMessage(translate("Error while initializing speech recognition module - please install the speech recognition software") . translate("...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

			this.Instance := false
		}
		finally {
			if (SpeechRecognizer.sDefaultAudioDevice && kNirCmd) {
				audioDevice := SpeechRecognizer.sDefaultAudioDevice

				try {
					Run("`"" . kNirCmd . "`" setdefaultsounddevice `"" . audioDevice . "`"")
				}
				catch Any as exception {
					logError(exception, true)

					showMessage(substituteVariables(translate("Cannot start NirCmd (%kNirCmd%) - please check the configuration..."))
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				}
			}
		}
	}

	createRecognizerList() {
		local recognizerList := []
		local culture, name, index, language, recognizer, ignore, model

		if ((this.Engine = "Azure") || (this.Engine = "Compiler")) {
			for culture, name in kAzureLanguages {
				index := A_Index - 1

				language := StrSplit(culture, "-")[1]

				recognizerList.Push({ID: index, Name: name . " (" . culture . ")", Culture: culture, Language: language})
			}
		}
		else if (this.Engine = "Google") {
			index := -1

			for culture, models in kGoogleLanguages
				for ignore, model in models {
					index += 1
					language := StrSplit(culture, "-")[1]

					name := model

					switch name, false {
						case "Long Speech (latest_long)":
							model := "latest_long"
						case "Short Speech (latest_short)":
							model := "latest_short"
						case "Command (command_and_search)":
							model := "command_and_search"
					}

					recognizerList.Push({ID: index, Name: name . " (" . culture . ")", Culture: culture, Language: language, Model: model})
				}
		}
		else if this.Instance {
			loop this.Instance.GetRecognizerCount() {
				index := A_Index - 1

				recognizer := {ID: index, Culture: this.Instance.GetRecognizerCultureName(index), Language: this.Instance.GetRecognizerTwoLetterISOLanguageName(index)}

				if (this.Engine = "Server")
					recognizer.Name := this.Instance.GetRecognizerName(index)
				else
					recognizer.Name := (this.Instance.GetRecognizerName(index) . " (" . recognizer.Culture . ")")

				recognizerList.Push(recognizer)
			}
		}

		return recognizerList
	}

	initialize(id) {
		local recognizer

		if this.Instance
			if ((this.Engine = "Azure") || (this.Engine = "Compiler"))
				this.Instance.SetLanguage(this.getRecognizerList()[id + 1].Culture)
			else if (this.Engine = "Google") {
				recognizer := this.getRecognizerList()[id + 1]

				this.Instance.SetLanguage(recognizer.Culture)
				this.Instance.SetModel(recognizer.Model)
			}
			else if (id > this.Instance.getRecognizerCount() - 1)
				throw "Invalid recognizer ID (" . id . ") detected in SpeechRecognizer.initialize..."
			else
				return this.Instance.Initialize(id)
	}

	startRecognizer() {
		local audioDevice := SpeechRecognizer.sRecognizerAudioDevice

		if (audioDevice && kNirCmd) {
			try {
				Run("`"" . kNirCmd . "`" setdefaultsounddevice `"" . audioDevice . "`"")
			}
			catch Any as exception {
				logError(exception, true)

				showMessage(substituteVariables(translate("Cannot start NirCmd (%kNirCmd%) - please check the configuration..."))
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}

		if this.Instance {
			if (this.Engine = "Google") {
				this.iGoogleCapturedAudioFile := temporaryFileName("capturedAudio", "wav")

				return this.Instance.StartRecognizer(this.iGoogleCapturedAudioFile)
			}
			else
				return this.Instance.StartRecognizer()
		}
		else
			return false
	}

	stopRecognizer() {
		local audioDevice := SpeechRecognizer.sDefaultAudioDevice

		try {
			if (this.Instance ? this.Instance.StopRecognizer() : false) {
				if ((this.Engine = "Google") && (this.iGoogleMode = "HTTP") && this.iGoogleCapturedAudioFile)
					try {
						this.processAudio(this.iGoogleCapturedAudioFile)
					}
					finally {
						if !isDebug()
							deleteFile(this.iGoogleCapturedAudioFile)

						this.iGoogleCapturedAudioFile := false
					}

				return true
			}
			else
				return false
		}
		finally {
			if (audioDevice && kNirCmd) {
				try {
					Run("`"" . kNirCmd . "`" setdefaultsounddevice `"" . audioDevice . "`"")
				}
				catch Any as exception {
					logError(exception, true)

					showMessage(substituteVariables(translate("Cannot start NirCmd (%kNirCmd%) - please check the configuration..."))
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				}
			}
		}
	}

	processAudio(audioFile) {
		request := Map("config", Map("languageCode", this.Instance.GetLanguage(), "model", this.Instance.GetModel()
								   , "useEnhanced", true)
					 , "audio", Map("content", this.Instance.ReadAudio(audioFile)))

		result := WinHttpRequest().POST("https://speech.googleapis.com/v1/speech:recognize?key=" . this.iGoogleAPIKey
									  , JSON.print(request), Map("Content-Type", "application/json"), {Object: true, Encoding: "UTF-8"})

		try {
			if ((result.Status >= 200) && (result.Status < 300)) {
				result := result.JSON

				if result.Has("results")
					this._onTextCallback(result["results"][1]["alternatives"][1]["transcript"])
			}
			else
				throw "Error while speech recognition..."
		}
		catch Any as exception {
			logError(exception, true)

			SpeechSynthesizer("Windows", true, "EN").speak("Error while calling Google Speech Services. Maybe your monthly contingent is exhausted.")
		}
	}

	getRecognizerList() {
		return this.RecognizerList
	}

	getWords(list) {
		local result := []

		loop list.MaxIndex() + 1
			result.Push(list[A_Index - 1])

		return result
	}

	getChoices(name?) {
		if isSet(name) {
			if this.iChoices.Has(name)
				return this.iChoices[name]
			else if ((this.Engine = "Azure") || (this.Engine = "Google") || (this.Engine = "Compiler"))
				return []
			else
				return (this.Instance ? ((this.Engine = "Server") ? this.Instance.GetServerChoices(name) : this.Instance.GetDesktopChoices(name)) : [])
		}
		else
			return this.iChoices
	}

	setChoices(name, choices) {
		this.iChoices[name] := this.newChoices(choices)
	}

	setMode(mode) {
		this.iMode := mode

		if ((mode = "Text") && this.Instance)
			switch this.Engine, false {
				case "Desktop", "Server":
					this.Instance.SetContinuous(true, this._onGrammarCallback.Bind(this))
				case "Azure", "Google", "Compiler":
					this.Instance.SetContinuous(true)
			}
	}

	newGrammar() {
		if this.Instance {
			switch this.Engine, false {
				case "Desktop":
					return this.Instance.NewDesktopGrammar()
				case "Azure", "Google", "Compiler":
					return Grammar()
				case "Server":
					return this.Instance.NewServerGrammar()
			}
		}
		else
			return false
	}

	newChoices(choices) {
		if this.Instance {
			switch this.Engine, false {
				case "Desktop":
					return this.Instance.NewDesktopChoices(isObject(choices) ? values2String(", ", choices*) : choices)
				case "Azure", "Google", "Compiler":
					return Grammar.Choices(!isObject(choices) ? string2Values(",", choices) : choices)
				case "Server":
					return this.Instance.NewServerChoices(isObject(choices) ? values2String(", ", choices*) : choices)
			}
		}
		else
			return false
	}

	registerRecognitionHandler(owner, handler) {
		if inList(["Azure", "Google"], this.Engine)
			this._recognitionHandlers.Push(Array(owner, handler))
	}

	loadGrammar(name, theGrammar, callback) {
		prepareGrammar(theName, theGrammar) {
			local start := A_TickCount
			local ignore

			if isInstance(theGrammar, Grammar)
				try {
					ignore := theGrammar.Phrases

					if isDebug()
						logMessage(kLogDebug, "Preparing grammar " . theName . " took " . (A_TickCount - start) . " ms")
				}
				catch Any as exception {
					logError(exception)
				}
		}

		if (this._grammarCallbacks.Has(name))
			throw "Grammar " . name . " already exists in SpeechRecognizer.loadGrammar..."

		this._grammarCallbacks[name] := callback

		if ((this.Engine = "Azure") || (this.Engine = "Google") || (this.Engine = "Compiler")) {
			Task.startTask(prepareGrammar.Bind(name, theGrammar), 1000, kLowPriority)

			theGrammar := {Name: name, Grammar: theGrammar, Callback: callback}

			this.Grammars[name] := theGrammar

			return theGrammar
		}
		else if this.Instance {
			Task.startTask(prepareGrammar.Bind(name, theGrammar), 1000, kLowPriority)

			this.Grammars[name] := {Name: name, Grammar: theGrammar, Callback: callback}

			return this.Instance.LoadGrammar(theGrammar, name, this._onGrammarCallback.Bind(this))
		}
		else
			return false
	}

	compileGrammar(text) {
		return GrammarCompiler(this).compileGrammar(text)
	}

	allMatches(string, minRating, maxRating, strings*) {
		local ratings := []
		local index, value, rating

		if this.Instance
			for index, value in strings {
				rating := this.Instance.Compare(string, value)

				if (rating > minRating) {
					ratings.Push({Rating: rating, Target: value})

					if (rating > maxRating)
						break
				}
			}

		if (ratings.Length > 0) {
			bubbleSort(&ratings, (r1, r2) => r1.Rating < r2.Rating)

			return {BestMatch: ratings[1], Ratings: ratings}
		}
		else
			return {Ratings: []}
	}

	bestMatch(string, minRating, maxRating, strings*) {
		local highestRating := 0
		local bestMatch := false
		local key, value, rating

		if this.Instance
			for key, value in strings {
				rating := this.Instance.Compare(string, value)

				if ((rating > minRating) && (highestRating < rating)) {
					highestRating := rating

					bestMatch := value

					if (rating > maxRating)
						break
				}
			}

		return bestMatch
	}

	splitText(text) {
		local words := string2Values(A_Space, text)
		local index, literal

		for index, literal in words {
			literal := StrReplace(literal, ".", "")
			literal := StrReplace(literal, ",", "")
			literal := StrReplace(literal, ";", "")
			literal := StrReplace(literal, "?", "")
			literal := StrReplace(literal, "-", "")

			words[index] := literal
		}

		return words
	}

	textRecognized(text) {
	}

	unknownRecognized(&text) {
		if this.Grammars.Has("?")
			callback := this.Grammars["?"].Callback.Call("?", this.splitText(text))

		return false
	}

	_onGrammarCallback(name, wordArr) {
		if (this.iMode = "Text")
			this.textRecognized(values2String(A_Space, this.getWords(wordArr)*))
		else
			this._grammarCallbacks[name].Call(name, this.getWords(wordArr))
	}

	_onTextCallback(text) {
		local words, ignore, name, grammar, rating, bestRating, bestMatch, handler

		loop 2 {
			words := this.splitText(text)

			for ignore, handler in this._recognitionHandlers
				if handler[2].Call(handler[1], words*)
					return

			if (this.iMode = "Text")
				this.textRecognized(text)
			else if true {
				bestRating := 0
				bestMatch := false

				for ignore, grammar in this.Grammars {
					rating := this.match(text, grammar.Grammar)

					if (rating > bestRating) {
						bestRating := rating
						bestMatch := grammar
					}
				}

				if bestMatch
					bestMatch.Callback.Call(bestMatch.Name, words)
				else if this.unknownRecognized(&text)
					continue
			}
			else {
				for name, grammar in this.Grammars
					if grammar.Grammar.match(words) {
						grammar.Callback.Call(name, words)

						return
					}

				if this.unknownRecognized(&text)
					continue
			}

			break
		}
	}

	match(words, grammar, minRating?, maxRating?) {
		local matches, settings

		static ratingLow := kUndefined
		static ratingHigh := kUndefined

		if (ratingLow = kUndefined) {
			settings := readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))

			ratingLow := getMultiMapValue(settings, "Voice", "Low Rating", 0.7)
			ratingHigh := getMultiMapValue(settings, "Voice", "High Rating", 0.85)
		}

		matches := this.allMatches(words, isSet(minRating) ? minRating : ratingLow
										, isSet(maxRating) ? maxRating : ratingHigh
										, grammar.Phrases*)

		return (matches.HasProp("BestMatch") ? matches.BestMatch.Rating : false)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    GrammarCompiler                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class GrammarCompiler {
	iSpeechRecognizer := false

	SpeechRecognizer {
		Get {
			return this.iSpeechRecognizer
		}
	}

	__New(recognizer) {
		this.iSpeechRecognizer := recognizer
	}

	compileGrammars(text) {
		local grammars := []
		local incompleteLine := false
		local line, one

		loop Parse, text, "`n", "`r" {
			line := Trim(A_LoopField)

			one := 1

			if ((line != "") && this.skipDelimiter(";", &line, &one, false))
				line := ""

			if (incompleteLine && (line != "")) {
				line := incompleteLine . line
				incompleteLine := false
			}

			if ((line != "") && (SubStr(line, StrLen(line), 1) == "\"))
				incompleteLine := SubStr(line, 1, StrLen(line) - 1)

			if (!incompleteLine && (line != ""))
				grammars.Push(this.compileGrammar(line))
		}

		return grammars
	}

	compileGrammar(text) {
		local grammar
		local nextCharIndex := 1

		grammar := this.readGrammar(&text, &nextCharIndex)

		if !grammar
			throw "Syntax error detected in `"" . text . "`" at 1 in GrammarCompiler.compileGrammar..."

		return this.parseGrammar(grammar)
	}

	readGrammar(&text, &nextCharIndex, level := 0) {
		this.skipWhiteSpace(&text, &nextCharIndex)

		if (SubStr(text, nextCharIndex, 1) = "[") {
			if (level = 0)
				return this.readGrammars(&text, &nextCharIndex, level)
			else
				throw "Syntax error detected in `"" . text . "`" at " . nextCharIndex . " in GrammarCompiler.readGrammar..."
		}
		else
			return this.readList(&text, &nextCharIndex)
	}

	readGrammars(&text, &nextCharIndex, level := 0) {
		local grammars := []

		this.skipDelimiter("[", &text, &nextCharIndex)

		loop {
			grammars.Push(this.readGrammar(&text, &nextCharIndex, level + 1))

			if !this.skipDelimiter(",", &text, &nextCharIndex, false)
				break
		}

		this.skipDelimiter("]", &text, &nextCharIndex)

		return GrammarGrammars(grammars)
	}

	readList(&text, &nextCharIndex) {
		local grammars := []
		local literalValue

		while !this.isEmpty(&text, &nextCharIndex) {
			this.skipWhiteSpace(&text, &nextCharIndex)

			if (SubStr(text, nextCharIndex, 1) = "{")
				grammars.Push(this.readChoices(&text, &nextCharIndex))
			else if (SubStr(text, nextCharIndex, 1) = "(")
				grammars.Push(this.readBuiltinChoices(&text, &nextCharIndex))
			else {
				literalValue := this.readLiteral(&text, &nextCharIndex)

				if literalValue
					grammars.Push(literalValue)
				else
					break
			}
		}

		return GrammarList(grammars)
	}

	readChoices(&text, &nextCharIndex) {
		local grammars := []
		local literalValue

		this.skipDelimiter("{", &text, &nextCharIndex)

		loop {
			literalValue := this.readLiteral(&text, &nextCharIndex)

			if literalValue
				grammars.Push(literalValue)
			else
				throw "Syntax error detected in `"" . text . "`" at " . nextCharIndex . " in GrammarCompiler.readChoices..."

			if !this.skipDelimiter(",", &text, &nextCharIndex, false)
				break
		}

		this.skipDelimiter("}", &text, &nextCharIndex)

		return GrammarChoices(grammars)
	}

	readBuiltinChoices(&text, &nextCharIndex) {
		local builtin := false
		local literalValue

		this.skipDelimiter("(", &text, &nextCharIndex)

		literalValue := this.readLiteral(&text, &nextCharIndex)

		if literalValue {
			builtin := literalValue.Value

			try {
				if !this.SpeechRecognizer.Choices[builtin]
					throw "Syntax error detected in `"" . text . "`" at " . nextCharIndex . " in GrammarCompiler.readBuiltinChoices..."
			}
			catch Any {
				throw "Syntax error detected in `"" . text . "`" at " . nextCharIndex . " in GrammarCompiler.readBuiltinChoices..."
			}
		}
		else
			throw "Syntax error detected in `"" . text . "`" at " . nextCharIndex . " in GrammarCompiler.readBuiltinChoices..."

		this.skipDelimiter(")", &text, &nextCharIndex)

		return GrammarBuiltinChoices(builtin)
	}

	readLiteral(&text, &nextCharIndex, delimiters := "{}[]()`,") {
		local length := StrLen(text)
		local literal, beginCharIndex, character

		this.skipWhiteSpace(&text, &nextCharIndex)

		beginCharIndex := nextCharIndex

		loop {
			character := SubStr(text, nextCharIndex, 1)

			if ((nextCharIndex > length) || InStr(delimiters, character)) {
				if (beginCharIndex == nextCharIndex)
					return false
				else
					return GrammarLiteral(SubStr(text, beginCharIndex, nextCharIndex - beginCharIndex))
			}
			else
				nextCharIndex += 1
		}
	}

	isEmpty(&text, &nextCharIndex) {
		local remainingText := Trim(SubStr(text, nextCharIndex))
		local one := 1

		if ((remainingText != "") && this.skipDelimiter(";", &remainingText, &one, false))
			remainingText := ""

		return (remainingText == "")
	}

	skipWhiteSpace(&text, &nextCharIndex) {
		local length := StrLen(text)

		loop {
			if (nextCharIndex > length)
				return

			if InStr(" `t`n`r", SubStr(text, nextCharIndex, 1))
				nextCharIndex += 1
			else
				return
		}
	}

	skipDelimiter(delimiter, &text, &nextCharIndex, throwError := true) {
		local length := StrLen(delimiter)

		this.skipWhiteSpace(&text, &nextCharIndex)

		if (SubStr(text, nextCharIndex, length) = delimiter) {
			nextCharIndex += length

			return true
		}
		else if throwError
			throw "Syntax error detected in `"" . text . "`" at " . nextCharIndex . " in GrammarCompiler.skipDelimiter..."
		else
			return false
	}

	parseGrammar(grammar) {
		return this.createGrammarParser(grammar).parse(grammar)
	}

	createGrammarParser(grammar) {
		return GrammarParser(this)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    Grammar                                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Grammar {
	iParts := []
	iPhrases := false

	class Choices {
		iChoices := []

		Choices[key?] {
			Get {
				return (isSet(key) ? this.iChoices[key] : this.iChoices)
			}
		}

		__New(choices) {
			local index, choice

			for index, choice in choices
				if !isObject(choice)
					choices[index] := Grammar.Words(choice)

			this.iChoices := choices
		}

		matchWords(words, &index) {
			local running := index
			local ignore, choice

			for ignore, choice in this.Choices
				if choice.matchWords(words, &running) {
					index := running

					return true
				}

			return false
		}

		combinePhrases(phrases) {
			local ignore, choice

			for ignore, choice in this.Choices
				choice.combinePhrases(phrases)
		}
	}

	class Words {
		iWords := []

		Words {
			Get {
				return this.iWords
			}
		}

		__New(string) {
			local index, literal

			if !isObject(string)
				string := string2Values(A_Space, string)

			for index, literal in string {
				literal := StrReplace(literal, ".", "")
				literal := StrReplace(literal, ",", "")
				literal := StrReplace(literal, ";", "")
				literal := StrReplace(literal, "?", "")
				literal := StrReplace(literal, "-", "")

				string[index] := literal
			}

			this.iWords := string
		}

		matchWords(words, &index) {
			local running := index
			local ignore, word

			for ignore, word in this.Words
				if (words.Length < running)
					return false
				else if !this.matchWord(words[running++], word)
					return false

			index := running

			return true
		}

		combinePhrases(phrases) {
			phrases.Push(values2String(A_Space, this.Words*))
		}

		matchWord(word1, word2) {
			return (word1 = word2)
		}
	}

	Parts {
		Get {
			return this.iParts
		}
	}

	Phrases {
		Get {
			if !this.iPhrases
				this.iPhrases := this.allPhrases()

			return this.iPhrases
		}
	}

	AppendChoices(choices) {
		this.iParts.Push(choices)
	}

	AppendString(string) {
		this.iParts.Push(Grammar.Words(string))
	}

	AppendGrammars(grammars*) {
		this.AppendChoices(Grammar.Choices(grammars))
	}

	match(words) {
		local index := 1

		return this.matchWords(words, &index)
	}

	matchWords(words, &index) {
		local alternatives, running, ignore, part

		if (words.Length < index)
			return true
		else {
			alternatives := false
			running := index

			for ignore, part in this.Parts {
				if ((A_Index == 1) && isInstance(part, Grammar))
					alternatives := true

				if alternatives {
					if part.matchWords(words, &index)
						return true
				}
				else {
					if !part.matchWords(words, &running)
						return false
				}
			}

			if alternatives
				return false
			else {
				index := running

				return true
			}
		}
	}

	allPhrases() {
		local result := []

		this.combinePhrases(result)

		return result
	}

	combinePhrases(phrases) {
		local alternatives := false
		local pPhrases := []
		local index, part, temp, parts, pParts, ignore, p1, p2

		for index, part in this.Parts {
			if ((index == 1) && isInstance(part, Grammar))
				alternatives := true

			if alternatives
				part.combinePhrases(phrases)
			else {
				temp := []

				part.combinePhrases(temp)

				pPhrases.Push(temp)
			}
		}

		if !alternatives {
			parts := []

			for index, pParts in reverse(pPhrases) {
				if (index == 1)
					parts := pParts
				else {
					temp := []

					for ignore, p2 in parts
						for ignore, p1 in pParts
							temp.Push(p1 . A_Space . p2)

					parts := temp
				}
			}

			for ignore, part in parts
				phrases.Push(part)
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    GrammarParser                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class GrammarParser {
	iCompiler := false

	Compiler {
		Get {
			return this.iCompiler
		}
	}

	__New(compiler) {
		this.iCompiler := compiler
	}

	parse(grammar) {
		local newGrammar

		if isInstance(grammar, GrammarList)
			return this.parseList(grammar)
		else if isInstance(grammar, GrammarGrammars)
			return grammar.parse(this)
		else if isInstance(grammar, GrammarChoices) {
			newGrammar := this.Compiler.SpeechRecognizer.newGrammar()

			newGrammar.AppendChoices(grammar.parse(this))

			return newGrammar
		}
		else
			throw "Grammars may only contain literals, choices or other grammars in GrammarParser.parse..."
	}

	parseList(grammarList) {
		local ignore, grammar, newGrammar

		newGrammar := this.Compiler.SpeechRecognizer.newGrammar()

		for ignore, grammar in grammarList.List
			if isInstance(grammar, GrammarLiteral)
				newGrammar.AppendString(grammar.Value)
			else if (isInstance(grammar, GrammarChoices) || isInstance(grammar, GrammarBuiltinChoices))
				newGrammar.AppendChoices(grammar.parse(this))
			else
				throw "Grammar lists may only contain literals or choices in GrammarParser.parseList..."

		return newGrammar
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    GrammarGrammars                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class GrammarGrammars {
	iGrammarLists := []

	GrammarLists {
		Get {
			return this.iGrammarLists
		}
	}

	__New(grammarLists) {
		this.iGrammarLists := grammarLists
	}

	toString() {
		local result := "["
		local ignore, list

		for ignore, list in this.GrammarLists {
			if (A_Index > 1)
				result .= ", "

			result .= list.toString()
		}

		return (result . "]")
	}

	parse(parser) {
		local grammars := []
		local grammar, ignore, list

		for ignore, list in this.GrammarLists
			grammars.Push(parser.parseList(list))

		grammar := parser.Compiler.SpeechRecognizer.newGrammar()

		grammar.AppendGrammars(grammars*)

		return grammar
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    GrammarChoices                                 ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class GrammarChoices {
	iChoices := []

	Choices[key?] {
		Get {
			return (isSet(key) ? this.iChoices[key] : this.iChoices)
		}
	}

	__New(choices) {
		this.iChoices := choices
	}

	toString() {
		local result := "{"
		local ignore, choice

		for ignore, choice in this.Choices {
			if (A_Index > 1)
				result .= ", "

			result .= choice.toString()
		}

		return (result . "}")
	}

	parse(parser) {
		local choices := []
		local ignore, choice

		for ignore, choice in this.Choices {
			if !isInstance(choice, GrammarLiteral)
				throw "Invalid choice (" . choice.toString() . ") detected in GrammarChoices.parse..."

			choices.Push(choice.Value)
		}

		return parser.Compiler.SpeechRecognizer.newChoices(choices)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    GrammarBuiltinChoices                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class GrammarBuiltinChoices {
	iBuiltin := false

	Builtin {
		Get {
			return this.iBuiltin
		}
	}

	__New(builtin) {
		this.iBuiltin := builtin
	}

	toString() {
		return "(" . this.Builtin . ")"
	}

	parse(parser) {
		return parser.Compiler.SpeechRecognizer.getChoices(this.Builtin)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    GrammarList                                    ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class GrammarList {
	iList := []

	List {
		Get {
			return this.iList
		}
	}

	__New(list) {
		this.iList := list
	}

	toString() {
		local result := ""
		local ignore, value

		for ignore, value in this.List {
			if (A_Index > 1)
				result .= A_Space

			result .= value.toString()
		}

		return result
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    GrammarLiteral                                 ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class GrammarLiteral {
	iValue := []

	Value {
		Get {
			return this.iValue
		}
	}

	__New(value) {
		this.iValue := value
	}

	toString() {
		return this.Value
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

matchWords(string1, string2) {
	local dllFile

	static recognizer := false

	if !recognizer {
		dllFile := (kBinariesDirectory . "Microsoft\Microsoft.Speech.Recognizer.dll")

		try {
			if (!FileExist(dllFile)) {
				logMessage(kLogCritical, translate("Speech.Recognizer.dll not found in ") . kBinariesDirectory)

				throw "Unable to find Speech.Recognizer.dll in " . kBinariesDirectory . "..."
			}

			recognizer := CLR_LoadLibrary(dllFile).CreateInstance("Speech.MicrosoftSpeechRecognizer")
		}
		catch Any as exception {
			logError(exception, true)

			logMessage(kLogCritical, translate("Error while initializing speech recognition module - please install the speech recognition software"))

			showMessage(translate("Error while initializing speech recognition module - please install the speech recognition software") . translate("...")
								, translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
	}

	return (recognizer ? recognizer.Compare(string1, string2) : false)
}