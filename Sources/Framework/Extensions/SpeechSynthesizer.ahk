;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Speech Synthesizer              ;;;
;;;                                                                         ;;;
;;;   Part of this code is based on work of evilC and Learning one.         ;;;
;;;   See www.autohotkey.com/forum/topic57773.html and                      ;;;
;;;   https://www.autohotkey.com/boards/viewtopic.php?t=71363 and also      ;;;
;;;   http://msdn.microsoft.com/en-us/library/ms717077(v=vs.85).aspx        ;;;
;;;   for more information about the technical details.                     ;;;
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
#Include "Task.ahk"
#Include "CLR.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kAzureVoices := Map("de", [["de-AT", "de-AT-IngridNeural"], ["de-AT", "de-AT-JonasNeural"]
								, ["de-DE", "de-DE-KatjaNeural"], ["de-DE", "de-DE-ConradNeural"]
								, ["de-CH", "de-CH-LeniNeural"], ["de-CH", "de-CH-JanNeural"]]
						 , "en", [["en-AU", "en-AU-NatashaNeural"], ["en-AU", "en-AU-WilliamNeural"]
								, ["en-CA", "en-CA-ClaraNeural"], ["en-CA", "en-CA-LiamNeural"]
								, ["en-HK", "en-HK-YanNeural Neu"], ["en-HK", "en-HK-SamNeural Neu"]
								, ["en-IN", "en-IN-NeerjaNeural"], ["en-IN", "en-IN-PrabhatNeural"]
								, ["en-GB", "en-GB-LibbyNeural"], ["en-GB", "en-GB-MiaNeural"], ["en-GB", "en-GB-RyanNeural"]
								, ["en-US", "en-US-AriaNeural"], ["en-US", "en-US-JennyNeural"], ["en-US", "en-US-GuyNeural"]])


;;;-------------------------------------------------------------------------;;;
;;;                          Public Class Section                           ;;;
;;;-------------------------------------------------------------------------;;;

class SpeechSynthesizer {
	iSynthesizer := "Windows"

	iAPIKey := ""

	iSpeechSynthesizer := false
	iVoices := []

	iLanguage := ""
	iLocale := ""
	iVoice := ""

	iRate := 0
	iPitch := 0
	iVolume := 100

	iCache := CaseInsenseMap()
	iCacheDirectory := false

	static sAudioRoutingInitialized := false

	static sSampleFrequency := false

	iSoundPlayer := false
	iSoundPlayerLevel := 1.0
	iPlaysCacheFile := false

	iSpeechStatusCallback := false

	iGoogleMode := "HTTP"

	class WAVHeader {
		riff		: u32
		fLength		: i32
		wave    	: u32
		fmt			: u32
		fSize		: i32
		fTag		: i16
		nChans		: i16
		sRate		: i32
		bytesPerSec	: i32
		bytesPerSmp	: i16
		bitsPerSmp	: i16
		data		: u32
		dLength		: i32

		__New(rate := 16000, bits := 16, channels := 1) {
			encodeDWORD(string) {
				local result := 0

				loop StrLen(string) {
					result <<= 8

					result += Ord(SubStr(string, A_Index, 1))
				}

				return result
			}

			this.riff := encodeDWORD("FFIR")
			this.wave := encodeDWORD("EVAW")
			this.fmt := encodeDWORD(" tmf")
			this.fSize := 16
			this.fTag := 1
			this.nChans := channels
			this.sRate := rate
			this.bytesPerSec := (rate * (bits / 8) * channels)
			this.bytesPerSmp := ((bits / 8) * channels)
			this.bitsPerSmp	:= bits
			this.data := encodeDWORD("atad")
		}

		setLength(length) {
			this.dLength := length

			this.fLength := (ObjGetDataSize(this) + length - 8)
		}
	}

	Synthesizer {
		Get {
			return this.iSynthesizer
		}
	}

	Routing {
		Get {
			return "Standard"
		}
	}

	Voices[language := false] {
		Get {
			local voices, voice, lcid, ignore, candidate, name

			if (!language || (this.Synthesizer = "ElevenLabs"))
				return this.iVoices
			else {
				voices := []

				if this.iSpeechSynthesizer
					if (this.Synthesizer = "Windows") {
						loop this.iSpeechSynthesizer.GetVoices.Count {
							voice := this.iSpeechSynthesizer.GetVoices.Item(A_Index - 1)
							lcid := voice.GetAttribute("Language")

							if (getLanguageFromLCID(lcid) = language)
								voices.Push(voice.GetAttribute("Name"))
						}
					}
					else if inList(["dotNet", "Azure", "Google"], this.Synthesizer) {
						for ignore, candidate in this.iVoices {
							name := string2Values("(", candidate)

							if (InStr(name[2], language) == 1)
								voices.Push(candidate)
						}
					}

				return voices
			}
		}
	}

	Language {
		Get {
			return this.iLanguage
		}
	}

	Awaitable {
		Get {
			return (kSox != false)
		}
	}

	Stoppable {
		Get {
			return true
		}
	}

	Locale {
		Get {
			return this.iLocale
		}
	}

	Voice {
		Get {
			return this.iVoice
		}
	}

	Speaking {
		Get {
			return this.isSpeaking()
		}
	}

	AudioDevice {
		Get {
			return getAudioSetting(this.Routing)
		}
	}

	SpeechStatusCallback {
		Get {
			return this.iSpeechStatusCallback
		}

		Set {
			return (this.iSpeechStatusCallback := value)
		}
	}

	__New(synthesizer, voice := false, language := false) {
		local dllName, dllFile, voices, languageCode, voiceInfos, ignore, voiceInfo, dirName, configuration
		local settings

		dirName := ("PhraseCache." . StrSplit(A_ScriptName, ".")[1] . "." . kVersion)

		DirCreate(kTempDirectory . dirName)

		this.iCacheDirectory := (kTempDirectory . dirName . "\")

		this.clearCache()

		OnExit(ObjBindMethod(this, "clearCache"))

		if (synthesizer = "Windows") {
			this.iSynthesizer := "Windows"

			try {
				this.iSpeechSynthesizer := ComObject("SAPI.SpVoice")

				this.iVoices := this.getVoices()

				this.setVoice(language, this.computeVoice(voice, language))
			}
			catch Any as exception {
				logError(exception, true)

				logMessage(kLogCritical, translate("Error while initializing speech synthesizer module - please install the speech synthesizer software"))

				if !kSilentMode
					showMessage(translate("Error while initializing speech synthesizer module - please install the speech synthesizer software") . translate("...")
										, translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}
		else if (synthesizer = "dotNET") {
			this.iSynthesizer := "dotNET"

			dllName := "Microsoft.Speech.Synthesizer.dll"
			dllFile := (kBinariesDirectory . "Microsoft\" . dllName)

			try {
				if (!FileExist(dllFile)) {
					logMessage(kLogCritical, translate("Speech.Synthesizer.dll not found in ") . kBinariesDirectory)

					throw "Unable to find Speech.Synthesizer.dll in " . kBinariesDirectory . "..."
				}

				this.iSpeechSynthesizer := CLR_LoadLibrary(dllFile).CreateInstance("Speech.MicrosoftSpeechSynthesizer")

				this.iVoices := this.getVoices()

				this.setVoice(language, this.computeVoice(voice, language))
			}
			catch Any as exception {
				logError(exception, true)

				logMessage(kLogCritical, translate("Error while initializing speech synthesizer module - please install the speech synthesizer software"))

				if !kSilentMode
					showMessage(translate("Error while initializing speech synthesizer module - please install the speech synthesizer software") . translate("...")
										, translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

				voices := []
			}
		}
		else if (InStr(synthesizer, "Azure|") == 1) {
			this.iSynthesizer := "Azure"

			dllName := "Microsoft.Speech.Synthesizer.dll"
			dllFile := (kBinariesDirectory . "Microsoft\" . dllName)

			try {
				if (!FileExist(dllFile)) {
					logMessage(kLogCritical, translate("Speech.Synthesizer.dll not found in ") . kBinariesDirectory)

					throw "Unable to find Speech.Synthesizer.dll in " . kBinariesDirectory . "..."
				}

				this.iSpeechSynthesizer := CLR_LoadLibrary(dllFile).CreateInstance("Speech.MicrosoftSpeechSynthesizer")

				synthesizer := string2Values("|", synthesizer, 3)

				this.iAPIKey := synthesizer[3]

				if !this.iSpeechSynthesizer.Connect(synthesizer[2], synthesizer[3]) {
					logMessage(kLogCritical, translate("Could not communicate with speech synthesizer library (") . dllName . translate(")"))
					logMessage(kLogCritical, translate("Try running the Powershell command `"Get-ChildItem -Path '.' -Recurse | Unblock-File`" in the Binaries folder"))

					throw "Could not communicate with speech synthesizer library (" . dllName . ")..."
				}

				this.iVoices := this.getVoices()

				this.setVoice(language, this.computeVoice(voice, language))
			}
			catch Any as exception {
				logError(exception, true)

				logMessage(kLogCritical, translate("Error while initializing speech synthesizer module - please install the speech synthesizer software"))

				if !kSilentMode
					showMessage(translate("Error while initializing speech synthesizer module - please install the speech synthesizer software") . translate("...")
										, translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

				voices := ""
			}
		}
		else if (InStr(synthesizer, "Google|") == 1) {
			this.iSynthesizer := "Google"

			dllName := "Google.Speech.Synthesizer.dll"
			dllFile := (kBinariesDirectory . "Google\" . dllName)

			try {
				if (!FileExist(dllFile)) {
					logMessage(kLogCritical, translate("Speech.Synthesizer.dll not found in ") . kBinariesDirectory)

					throw "Unable to find Speech.Synthesizer.dll in " . kBinariesDirectory . "..."
				}

				this.iSpeechSynthesizer := CLR_LoadLibrary(dllFile)
				this.iSpeechSynthesizer := this.iSpeechSynthesizer.CreateInstance("Speech.GoogleSpeechSynthesizer")

				synthesizer := string2Values("|", synthesizer, 2)

				if (this.iGoogleMode = "RPC")
					EnvSet("GOOGLE_APPLICATION_CREDENTIALS", synthesizer[2])
				else
					this.iAPIKey := synthesizer[2]

				if !this.iSpeechSynthesizer.Connect(this.iGoogleMode, synthesizer[2]) {
					logMessage(kLogCritical, translate("Could not communicate with speech synthesizer library (") . dllName . translate(")"))
					logMessage(kLogCritical, translate("Try running the Powershell command `"Get-ChildItem -Path '.' -Recurse | Unblock-File`" in the Binaries folder"))

					throw "Could not communicate with speech synthesizer library (" . dllName . ")..."
				}

				this.iVoices := this.getVoices()

				this.setVoice(language, this.computeVoice(voice, language))
			}
			catch Any as exception {
				logError(exception, true)

				logMessage(kLogCritical, translate("Error while initializing speech synthesizer module - please install the speech synthesizer software"))

				if !kSilentMode
					showMessage(translate("Error while initializing speech synthesizer module - please install the speech synthesizer software") . translate("...")
										, translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}
		else if (InStr(synthesizer, "ElevenLabs|") == 1) {
			this.iSynthesizer := "ElevenLabs"

			try {
				this.iAPIKey := string2Values("|", synthesizer, 2)[2]

				this.iVoices := this.getVoices()

				this.setVoice(language, this.computeVoice(voice, language))
			}
			catch Any as exception {
				logError(exception, true)

				logMessage(kLogCritical, translate("Error while initializing speech synthesizer module - please install the speech synthesizer software"))

				if !kSilentMode
					showMessage(translate("Error while initializing speech synthesizer module - please install the speech synthesizer software") . translate("...")
										, translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}
		else
			throw "Unsupported speech synthesizer service detected in SpeechSynthesizer.__New..."

		if !SpeechSynthesizer.sSampleFrequency {
			settings := readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))

			SpeechSynthesizer.sSampleFrequency := getMultiMapValue(settings, "Voice", "ElevenLabs.Sample Frequency"
																 , getMultiMapValue(settings, "Voice", "Sample Frequency", 16000))
		}

		if kSox {
			if !SpeechSynthesizer.sAudioRoutingInitialized {
				SpeechSynthesizer.sAudioRoutingInitialized := true

				configuration := readMultiMap(kUserConfigDirectory . "Audio Settings.ini")
			}
		}

		this.setVolume(100)
		this.setRate(0)
		this.setPitch(0)
	}

	getVoices() {
		local result, voices, languageCode, voiceInfos, ignore, voiceInfo

		if (this.Synthesizer = "Windows") {
			result := []

			loop this.iSpeechSynthesizer.GetVoices.Count
				result.Push(this.iSpeechSynthesizer.GetVoices.Item(A_Index - 1).GetAttribute("Name"))

			return result
		}
		else if (this.Synthesizer = "dotNET")
			return string2Values("|", this.iSpeechSynthesizer.GetVoices())
		else if (this.Synthesizer = "Azure") {
			if (Trim(this.iAPIKey) != "") {
				voices := this.iSpeechSynthesizer.GetVoices()

				if (voices = "") {
					result := []

					for languageCode, voiceInfos in kAzureVoices
						for ignore, voiceInfo in voiceInfos
							result.Push(voiceInfo[2] . " (" . voiceInfo[1] . ")")

					return result
				}
				else
					return string2Values("|", voices)
			}
			else
				return []
		}
		else if (this.Synthesizer = "ElevenLabs") {
			voices := []

			if (Trim(this.iAPIKey) != "") {
				result := WinHttpRequest().GET("https://api.elevenlabs.io/v2/voices?voice_type=default", ""
											 , Map("xi-api-key", this.iAPIKey), {Encoding: "UTF-8"})

				if ((result.Status >= 200) && (result.Status < 300))
					for ignore, voiceInfo in result.JSON["voices"]
						voices.Push(voiceInfo["name"] . " (" . voiceInfo["voice_id"] . ")")

				result := WinHttpRequest().GET("https://api.elevenlabs.io/v2/voices?voice_type=personal", ""
											 , Map("xi-api-key", this.iAPIKey), {Encoding: "UTF-8"})

				if ((result.Status >= 200) && (result.Status < 300))
					for ignore, voiceInfo in result.JSON["voices"]
						voices.Push(voiceInfo["name"] . " (" . voiceInfo["voice_id"] . ")")

				result := WinHttpRequest().GET("https://api.elevenlabs.io/v2/voices?voice_type=workspace", ""
											 , Map("xi-api-key", this.iAPIKey), {Encoding: "UTF-8"})

				if ((result.Status >= 200) && (result.Status < 300))
					for ignore, voiceInfo in result.JSON["voices"]
						voices.Push(voiceInfo["name"] . " (" . voiceInfo["voice_id"] . ")")
			}

			return voices
		}
		else if (this.iGoogleMode = "HTTP") {
			if (Trim(this.iAPIKey) != "") {
				result := WinHttpRequest().GET("https://texttospeech.googleapis.com/v1/voices?key=" . this.iAPIKey, "", Map(), {Encoding: "UTF-8"})

				if ((result.Status >= 200) && (result.Status < 300)) {
					voices := []

					for ignore, voiceInfo in result.JSON["voices"]
						voices.Push(voiceInfo["name"] . " - " . voiceInfo["ssmlGender"] . " (" . voiceInfo["languageCodes"][1] . ")")

					return voices
				}
				else
					return []
			}
			else
				return []
		}
		else
			return string2Values("|", this.iSpeechSynthesizer.GetVoices())
	}

	setPlayerLevel(level) {
		global kNirCmd

		local pid := this.iSoundPlayer

		this.iSoundPlayerLevel := level

		if (pid && kNirCmd) {
			if ProcessExist(pid) {
				try {
					Run("`"" . kNirCmd . "`" setappvolume /" . pid . A_Space . level)
				}
				catch Any as exception {
					logError(exception, true)

					kNirCmd := false

					if !kSilentMode
						showMessage(substituteVariables(translate("Cannot start NirCmd (%kNirCmd%) - please check the configuration..."))
								  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				}
			}
		}
	}

	mute() {
		this.setPlayerLevel(0.4)
	}

	unmute() {
		this.setPlayerLevel(1.0)
	}

	updateSpeechStatus(pid) {
		local callback

		if ProcessExist(pid) {
			Task.CurrentTask.Sleep := 50

			return Task.CurrentTask
		}
		else {
			this.iSoundPlayer := false
			this.iPlaysCacheFile := false

			callback := this.SpeechStatusCallback

			callback.Call("Stop")

			return false
		}
	}

	playSound(soundFile, wait := true) {
		global kNirCmd

		local callback, pid, level, audioDevice

		callback := this.SpeechStatusCallback

		if kSox {
			audioDevice := this.AudioDevice

			pid := playSound(wait ? "SoundPlayerSync.exe" : "SoundPlayerAsync.exe", soundFile
						   , audioDevice ? audioDevice : false)

			if callback
				callback.Call("Start")

			Sleep(500)

			this.iSoundPlayer := pid

			if kNirCmd
				try {
					level := this.iSoundPlayerLevel

					Run("`"" . kNirCmd . "`" setappvolume /" . pid . A_Space . level)
				}
				catch Any as exception {
					logError(exception, true)

					kNirCmd := false

					if !kSilentMode
						showMessage(substituteVariables(translate("Cannot start NirCmd (%kNirCmd%) - please check the configuration..."))
													  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				}

			if wait {
				loop {
					if ProcessExist(pid)
						Sleep(50)
					else
						break
				}

				this.iSoundPlayer := false

				if callback
					callback.Call("Stop")
			}
			else if callback
				Task.startTask(ObjBindMethod(this, "updateSpeechStatus", pid), 500, kHighPriority)
		}
		else {
			if wait {
				if callback
					callback.Call("Start")

				playSound("System", soundFile, "Wait")

				if callback
					callback.Call("Stop")
			}
			else {
				if callback
					callback.Call("Play")

				playSound("System", soundFile)
			}
		}
	}

	clearCache(*) {
		local directory := this.iCacheDirectory

		if directory
			deleteFile(directory . "Unnamed*.*")

		return false
	}

	cacheFileName(cacheKey, fileName := false) {
		if this.iCache.Has(cacheKey)
			return this.iCache[cacheKey]
		else {
			fileName := (this.iCacheDirectory . (fileName ? fileName : cacheKey) . ".wav")

			this.iCache[cacheKey] := fileName

			return fileName
		}
	}

	speak(text, wait := true, cache := false, options := false) {
		global kSox

		local cacheFileName, tempName, temp1Name, temp2Name, callback, volume
		local overdriveGain, overdriveColor, filterHighpass, filterLowpass, noiseVolume, clickVolume

		static counter := 1

		if (options && !isInstance(options, Map))
			options := toMap(options)

		if (Trim(Text) = "")
			return

		this.wait()

		if (cache && (cache == true))
			cache := text

		if cache {
			if (cache == true)
				cacheFileName := this.cacheFileName(text, "Unnamed_" . counter++)
			else
				cacheFileName := this.cacheFileName(cache)

			if FileExist(cacheFileName) {
				if (wait || !cache)
					this.playSound(cacheFileName, true)
				else {
					this.playSound(cacheFileName, false)

					this.iPlaysCacheFile := true
				}

				return
			}
		}
		else
			cacheFileName := false

		if kSoX {
			temp1Name := temporaryFileName("temp1", "wav")

			if cacheFileName
				temp2Name := cacheFileName
			else
				temp2Name := temporaryFileName("temp2", "wav")

			this.speakToFile(temp1Name, text)

			if !FileExist(temp1Name) {
				callback := this.SpeechStatusCallback

				if (this.Synthesizer = "Windows") {
					if callback
						callback.Call(wait ? "Start" : "Play")

					this.iSpeechSynthesizer.Speak(text, (wait ? 0x0 : 0x1))

					if (callback && wait)
						callback.Call("Stop")
				}

				return
			}

			if (!options || !options.Has("Distort") || options["Distort"]) {
				overdriveGain := getMultiMapValue(kSimulatorConfiguration, "Voice Control", "Speaker.Overdrive", 20)
				overdriveColor := getMultiMapValue(kSimulatorConfiguration, "Voice Control", "Speaker.Color", 20)
				filterHighpass := getMultiMapValue(kSimulatorConfiguration, "Voice Control", "Speaker.HighPass", 800)
				filterLowpass := getMultiMapValue(kSimulatorConfiguration, "Voice Control", "Speaker.LowPass", 1800)

				if !isInteger(overDriveGain)
					overDriveGain := 20

				if !isInteger(overDriveColor)
					overDriveColor := 20

				if !isInteger(filterHighpass)
					filterHighpass := 800

				if !isInteger(filterLowpass)
					filterLowpass := 1800
			}
			else {
				overdriveGain := 0
				overdriveColor := 0
				filterHighpass := 50
				filterLowpass := 10800
			}

			try {
				if (!options || !options.Has("Noise") || options["Noise"])
					noiseVolume := Round(0.3 * getMultiMapValue(kSimulatorConfiguration, "Voice Control", "Speaker.NoiseVolume", 66) / 100, 2)
				else
					noiseVolume := 0
			}
			catch Any as exception {
				logError(exception, true)

				noiseVolume := Round(0.3 * 66 / 100, 2)
			}

			try {
				if (!options || !options.Has("Click") || options["Click"])
					clickVolume := Round(0.6 * getMultiMapValue(kSimulatorConfiguration, "Voice Control", "Speaker.ClickVolume", 80) / 100, 2)
				else
					clickVolume := 0
			}
			catch Any as exception {
				logError(exception, true)

				clickVolume := Round(0.6 * 66 / 100, 2)
			}

			try {
				try {
					RunWait("`"" . kSoX . "`" `"" . temp1Name . "`" `"" . temp2Name . "`" rate 16k channels 1 overdrive " . overdriveGain . A_Space . overdriveColor
																					. " highpass " . filterHighpass . " lowpass " . filterLowpass . " Norm", , "Hide")

					if (noiseVolume > 0)
						RunWait("`"" . kSoX . "`" -m -v " . noiseVolume . " `"" . kResourcesDirectory . "Sounds\Noise.wav`" `""
														  . temp2Name . "`" `"" . temp1Name . "`" channels 1 reverse vad -p 1 reverse", , "Hide")
					else
						RunWait("`"" . kSoX . "`" `"" . temp2Name . "`" `"" . temp1Name . "`" channels 1 reverse vad -p 1 reverse", , "Hide")

					volume := Round(this.iVolume / 100, 2)

					if (clickVolume > 0)
						RunWait("`"" . kSoX . "`" -v " . clickVolume . " `"" . kResourcesDirectory . "Sounds\Click.wav`" `"" . temp1Name . "`" `"" . temp2Name . "`" norm vol " . volume, , "Hide")
					else
						RunWait("`"" . kSoX . "`" `"" . temp1Name . "`" `"" . temp2Name . "`" norm vol " . volume, , "Hide")
				}
				catch Any as exception {
					logError(exception, true)

					kSox := false

					if !kSilentMode
						showMessage(substituteVariables(translate("Cannot start SoX (%kSoX%) - please check the configuration..."))
								  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

					if (this.Synthesizer = "Windows")
						this.iSpeechSynthesizer.Speak(text, (wait ? 0x0 : 0x1))
				}

				if (wait || !cache)
					this.playSound(temp2Name, true)
				else {
					this.playSound(temp2Name, false)

					this.iPlaysCacheFile := true
				}
			}
			finally {
				try {
					if FileExist(temp1Name)
						deleteFile(temp1Name)

					if (!cache && FileExist(temp2Name))
						deleteFile(temp2Name)
				}
				catch Any as exception {
					logError(exception)
				}
			}
		}
		else if (this.Synthesizer = "Windows")
			this.iSpeechSynthesizer.Speak(text, (wait ? 0x0 : 0x1))
		else if inList(["dotNet", "Azure", "Google", "ElevenLabs"], this.Synthesizer) {
			tempName := (cache ? cacheFileName : temporaryFileName("temp", "wav"))

			this.speakToFile(tempName, text)

			if !FileExist(tempName)
				return

			this.playSound(tempName, wait || !cache)

			if !cache
				deleteFile(tempName)
		}
	}

	speakToFile(fileName, text) {
		local oldStream, stream, ssml, name, voice, request, result, header, file, id

		this.stop()

		if (this.Synthesizer = "Windows") {
			oldStream := this.iSpeechSynthesizer.AudioOutputStream

			stream := ComObject("Sapi.SpFileStream")

			try {
				stream.Open(fileName, 0x3, 0)

				this.iSpeechSynthesizer.AudioOutputStream := stream

				this.iSpeechSynthesizer.Speak(text, 0x0)
			}
			finally {
				stream.Close()

				this.iSpeechSynthesizer.AudioOutputStream := oldStream
			}
		}
		else if inList(["dotNet", "Azure", "Google"], this.Synthesizer) {
			if ((this.Synthesizer = "Google") && (this.iGoogleMode = "RPC")) {
				name := string2Values(" - ", this.Voice)
				voice := string2Values("-", this.Voice)

				this.iSpeechSynthesizer.SetVoice(name[1], name[2], voice[1] . "-" . voice[2])
			}

			ssml := "<speak version=`"1.0`" xmlns=`"http://www.w3.org/2001/10/synthesis`" xml:lang=`"%language%`">"
		    if (this.Synthesizer != "Google")
				ssml .= " <voice name=`"%voice%`">"

			if ((this.Synthesizer = "Azure") || (this.Synthesizer = "Google")) {
				ssml .= "  <prosody pitch=`"%pitch%`" rate=`"%rate%`""

				if !kSoX
					ssml .= " volume=`"%volume%`""

				ssml .= ">"
			}
			else
				ssml .= "  <prosody pitch=`"%pitch%`">"

			ssml .= "  %text%"
			ssml .= "  </prosody>"
			if (this.Synthesizer != "Google")
				ssml .= " </voice>"
			ssml .= "</speak>"

			ssml := substituteVariables(ssml, {volume: this.iVolume, pitch: ((this.iPitch > 0) ? "+" : "-") . Abs(this.iPitch) . "st", rate: 1 + (0.05 * this.iRate)
											 , language: this.Locale, voice: this.Voice, text: StrReplace(text, "%", "|||percent|||")})

			ssml := StrReplace(ssml, "|||percent|||", "%")

			try {
				if ((this.Synthesizer = "Google") && (this.iGoogleMode = "HTTP")) {
					name := string2Values(" - ", this.Voice)
					voice := string2Values("-", this.Voice)

					request := Map("input", Map("ssml", ssml)
								 , "voice", Map("languageCode", voice[1] . "-" . voice[2], "name", name[1], "ssmlGender", name[2])
								 , "audioConfig", Map("audioEncoding", "LINEAR16"))

					result := WinHttpRequest().POST("https://texttospeech.googleapis.com/v1/text:synthesize?key=" . this.iAPIKey
												  , JSON.print(request), Map("Content-Type", "application/json"), {Object: true, Encoding: "UTF-8"})

					if ((result.Status >= 200) && (result.Status < 300))
						this.iSpeechSynthesizer.WriteAudio(result.JSON["audioContent"], fileName)
					else
						throw "Error during speech synthesis..."
				}
				else if !this.iSpeechSynthesizer.SpeakSsmlToFile(fileName, ssml)
					throw "Error during speech synthesis..."
			}
			catch Any as exception {
				logError(exception, true)

				if (this.Synthesizer = "Azure")
					SpeechSynthesizer("Windows", true, "EN").speak("Error while calling Azure Cognitive Services. Maybe your monthly contingent is exhausted.")
				else if (this.Synthesizer = "Google")
					SpeechSynthesizer("Windows", true, "EN").speak("Error while calling Google Speech Services. Maybe your monthly contingent is exhausted.")
			}
		}
		else if (this.Synthesizer = "ElevenLabs") {
			try {
				id := (InStr(this.Voice, "(") ? StrReplace(string2Values("(", this.Voice)[2], ")", "") : this.Voice)

				result := WinHttpRequest().POST("https://api.elevenlabs.io/v1/text-to-speech/" . id
											  . "?output_format=pcm_" . SpeechSynthesizer.sSampleFrequency
											  , JSON.print(Map("text", text))
											  , Map("xi-api-key", this.iAPIKey
												  , "Content-Type", "application/json")
											  , {Raw: true})

				if ((result.Status >= 200) && (result.Status < 300)) {
					header := SpeechSynthesizer.WAVHeader(SpeechSynthesizer.sSampleFrequency)

					header.setLength(result.Raw.Size)

					file := FileOpen(fileName, "w")

					file.RawWrite(ObjGetDataPtr(header), ObjGetDataSize(header))
					file.RawWrite(result.Raw)

					file.Close()
				}
				else
					throw "Error during speech synthesis..."
			}
			catch Any as exception {
				logError(exception, true)

				SpeechSynthesizer("Windows", true, "EN").speak("Error while calling ElevenLabs. Maybe your contingent is exhausted.")
			}
		}
	}

	speakTest() {
		switch this.Language, false {
			case "DE":
				this.speak("Falsches Üben von Xylophonmusik quält jeden größeren Zwerg")
			case "ES":
				this.speak("Extraño pan de col y kiwi se quemó bajo fugaz vaho")
			case "FR":
				this.speak("Portez ce vieux whisky au juge blond qui fume")
			case "IT":
				this.speak("Che tempi brevi zio, quando solfeggi")
			case "PT":
				this.speak("Zebras caolhas de Java querem mandar fax para moça gigante de New York")
			case "ZH":
				this.speak("潮水冲淡了他们留在沙滩上的脚印")
			case "JA":
				this.speak("素早い茶色のキツネが怠け者の犬を飛び越える")
			default:
				this.speak("The quick brown fox jumps over the lazy dog")
		}
	}

	isSpeaking() {
		if this.iSoundPlayer {
			if ProcessExist(this.iSoundPlayer)
				return true
			else {
				this.iSoundPlayer := false
				this.iPlaysCacheFile := false

				return false
			}
		}
		else
			return false
	}

	pause() {
		local status

		if (this.Synthesizer = "Windows") {
			status := this.iSpeechSynthesizer.Status.RunningState

			if (status = 0)
				this.iSpeechSynthesizer.Resume
			else if (status = 2)
				this.iSpeechSynthesizer.Pause
		}
	}

	wait() {
		if this.iSoundPlayer {
			while this.isSpeaking()
				Sleep(1)
		}
		else
			this.stop()
	}

	stop() {
		local pid := this.iSoundPlayer
		local status

		if pid {
			if ProcessExist(pid) {
				ProcessClose(pid)

				this.iSoundPlayer := false
				this.iPlaysCacheFile := false
			}

			return true
		}
		else if (this.iPlaysCacheFile || inList(["dotNet", "Azure", "Google", "ElevenLabs"], this.Synthesizer)) {
			try
				playSound("System", "NonExistent.avi")

			if this.iPlaysCacheFile {
				this.iPlaysCacheFile := false

				return true
			}
		}
		else if (this.Synthesizer = "Windows") {
			status := this.iSpeechSynthesizer.Status.RunningState

			if (status = 0)
				this.iSpeechSynthesizer.Resume

			this.iSpeechSynthesizer.Speak("", 0x1 | 0x2)
		}

		return false
	}

	setRate(rate) {
		this.iRate := rate

		if (this.Synthesizer = "Windows")
			this.iSpeechSynthesizer.Rate := rate
		else if (this.Synthesizer = "dotNET")
			this.iSpeechSynthesizer.SetProsody(rate, kSoX ? 100 : this.iVolume)
	}

	setVolume(volume) {
		this.iVolume := volume

		if (this.Synthesizer = "Windows")
			this.iSpeechSynthesizer.Volume := (kSoX ? 100 : this.iVolume)
		else if (this.Synthesizer = "dotNET")
			this.iSpeechSynthesizer.SetProsody(this.iRate, kSoX ? 100 : this.iVolume)
	}

	setPitch(pitch) {
		this.iPitch := pitch

		if (this.Synthesizer = "Windows")
			this.iSpeechSynthesizer.Speak("<pitch absmiddle = '" pitch "'/>", 0x20)
	}

	computeVoice(voice, language, randomize := true) {
		local availableVoices := []
		local voices := this.Voices
		local count, locale, ignore, candidate, id

		if inList(voices, voice)
			return voice

		if InStr(voice, "(") {
			if (this.Synthesizer != "ElevenLabs")
				id := StrReplace(string2Values("(", voice)[2], ")", "")
			else {
				locale := StrReplace(string2Values("(", voice)[2], ")", "")

				if (InStr(locale, language) != 1)
					voice := false
			}
		}

		if (this.Synthesizer = "Windows") {
			if language
				availableVoices := this.Voices[language]

			if ((voice == true) && language) {
				count := availableVoices.Length

				if (count == 0)
					voice := false
				else if randomize
					voice := availableVoices[Round(Random(1, count))]
				else
					voice := availableVoices[1]
			}
		}
		else if inList(["dotNet", "Azure", "Google"], this.Synthesizer) {
			if language {
				availableVoices := []

				for ignore, candidate in voices {
					locale := StrReplace(string2Values("(", candidate)[2], ")", "")

					if (InStr(locale, language) == 1)
						availableVoices.Push(candidate)
				}
			}

			if ((voice == true) && language) {
				count := availableVoices.Length

				if (count == 0)
					voice := false
				else if randomize
					voice := availableVoices[Round(Random(1, count))]
				else
					voice := availableVoices[1]
			}
		}
		else if (this.Synthesizer = "ElevenLabs") {
			if (voice == true) {
				count := availableVoices.Length

				if (count == 0)
					voice := false
				else if randomize
					voice := availableVoices[Round(Random(1, count))]
				else
					voice := availableVoices[1]
			}
			else if (voice && InStr(voice, "("))
				return voice
		}

		if (availableVoices.Length > 0)
			if (voice && (voice != true) && inList(availableVoices, voice))
				return voice

		if (voices.Length > 0) {
			if (voice && (voice != true) && inList(voices, voice))
				return voice
			else
				return ((availableVoices.Length > 0) ? availableVoices[1] : voices[1])
		}
		else
			return ((availableVoices.Length > 0) ? availableVoices[1] : "")
	}

	setVoice(language, name) {
		if (Trim(name) = "")
			return false

		if (this.Synthesizer = "Windows") {
			if !inList(this.Voices, name)
				return false

			while !(this.iSpeechSynthesizer.Status.RunningState = 1)
				Sleep(200)

			this.iSpeechSynthesizer.Voice := this.iSpeechSynthesizer.GetVoices("Name=" . name).Item(0)
			this.iLanguage := language
			this.iVoice := name
		}
		else if inList(["dotNet", "Azure", "Google"], this.Synthesizer) {
			name := string2Values("(", name)

			this.iLanguage := language
			this.iVoice := name[1]
			this.iLocale := StrReplace(name[2], ")", "")
		}
		else if (this.Synthesizer = "ElevenLabs") {
			this.iLanguage := language
			this.iVoice := name
		}

		return true
	}
}