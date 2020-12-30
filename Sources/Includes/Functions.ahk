;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Global Functions                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2020) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Constants.ahk
#Include ..\Includes\Variables.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vDebug = false
global vLogLevel = kLogWarn

global vTargetLanguage = "en"

global vSplashCounter = 0
global vLastImage
global vVideoPlayer
global vVideoIsPlaying = false
global vSongIsPlaying = false

global vEventHandlers = Object()
global vWaitingEvents = []

global vPendingTrayMessages = []
global vTrayMessageDuration = 1500


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

changeProtection(up) {
	static level := 0
	
	level := (up ? level + 1 : level - 1)
	
	if (level == 1) {
        Critical On
		BlockInput On
	}
	else if (level == 0) {
		BlockInput Off
        Critical Off
	}
	else if (level <= 0)
		Throw "Nesting error in protection level in changeProtection..."
}

playThemeSong(songFile) {
	songFile := getFileName(songFile, kUserSplashMediaDirectory, kSplashMediaDirectory)
	
	if FileExist(songFile)
		SoundPlay %songFile%
}

eventMessageQueue() {
	if (vWaitingEvents.Length() > 0) {
		event := vWaitingEvents.RemoveAt(1)
	
		%event%()
	}
}

trayMessageQueue() {
	if (vPendingTrayMessages.Length() > 0) {
		protectionOn()
	
		try {
			if (vPendingTrayMessages.Length() = 0)
				return
			else {
				message := vPendingTrayMessages.RemoveAt(1)
	
				SetTimer trayMessageQueue, Off
		
				protectionOff()
		
				try {
					duration := message[3]
					title := message[1]
					message := message[2]
		
					TrayTip %title%, %message%
		
					Sleep %duration%

					TrayTip
				}
				finally {
					protectionOn()
		
					SetTimer trayMessageQueue, On
				}
			}
		}
		finally {
			protectionOff()
		}
	}
}

encodeDWORD(string) {
	result := 0
	
	Loop % StrLen(string) {
        result <<= 8
        result += Asc(SubStr(string, A_Index, 1))
    }
	
    return result
}

decodeDWORD(data) {
	result := ""
	
    Loop 4 {
        result := Chr(data & 0xFF) . result
        data >>= 8
    }
	
    return result
}

unknownEventHandler(event, data) {
	logMessage(kLogCritical, translate("Unhandled event ") . event . translate(": ") . data)
}

dispatchEvent(wParam, lParam) {
	;---------------------------------------------------------------------------
    ; retrieve info from COPYDATASTRUCT
    ;---------------------------------------------------------------------------
    dwData := NumGet(lParam + A_PtrSize * 0)    ; DWORD encoded request
    cbData := NumGet(lParam + A_PtrSize * 1)    ; length of DATA string (incl ZERO)
    lpData := NumGet(lParam + A_PtrSize * 2)    ; pointer to DATA string

	;---------------------------------------------------------------------------
    ; interpret available info
    ;---------------------------------------------------------------------------
    request := decodeDWORD(dwData)              ; 4-char decoded request
    length  := (cbData - 1) / (A_IsUnicode + 1) ; length of DATA string (excl ZERO)
    data    := StrGet(lpData, length)           ; DATA string from pointer
	
	if (request != "EVNT")
		Throw % "Unhandled message received: " . request . " in dispatchEvent..."

    data := StrSplit(data, ":", , 2)
	event := data[1]
	
	eventHandler := vEventHandlers[event]
	
	if (!eventHandler)
		eventHandler := vEventHandlers["*"]
	
	logMessage(kLogInfo, translate("Dispatching event """) . event . (data[2] ? translate(""": ") . data[2] : translate("""")))
	
	vWaitingEvents.Push(Func(eventHandler).Bind(event, data[2]))
}

initializeEventSystem() {
	OnMessage(0x4a, "dispatchEvent") 
	
	registerEventHandler("*", "unknownEventHandler")
	
	SetTimer eventMessageQueue, 200
}

logError(exception) {
	logMessage(kLogCritical, translate("Unhandled exception encountered in ") . exception.File . translate(" at line ") . exception.Line . translate(": ") . exception.Message)
	
	return (vDebug ? false : true)
}

initializeLoggingSystem() {
	OnError("logError")
}

initializeTrayMessageQueue() {
	SetTimer trayMessageQueue, 500
}

loadSimulatorConfiguration() {
	kSimulatorConfiguration := readConfiguration(kSimulatorConfigurationFile)
	vTargetLanguage := getConfigurationValue(kSimulatorConfiguration, "Configuration", "Language", "en")
	
	kVersion := getConfigurationValue(readConfiguration(kHomeDirectory . "VERSION"), "Version", "Current", "0.0.0")
	
	logMessage(kLogCritical, "---------------------------------------------------------------")
	logMessage(kLogCritical, translate("           Running ") . StrSplit(A_ScriptName, ".")[1] . " (" . kVersion . ")")
	logMessage(kLogCritical, "---------------------------------------------------------------")
	
	if (kSimulatorConfiguration.Count() == 0)
		logMessage(kLogCritical, translate("No configuration found - please run the setup tool"))
	
	path := getConfigurationValue(kSimulatorConfiguration, "Configuration", "Home Path")
	if path {
		kHomeDirectory := path . "\"
		
		logMessage(kLogInfo, translate("Installation path set to ") . path)
	}
	else
		logMessage(kLogWarn, translate("Installation path not set"))
	
	path := getConfigurationValue(kSimulatorConfiguration, "Configuration", "AHK Path")
	if path {
		kAHKDirectory := path . "\"
		
		logMessage(kLogInfo, translate("AutoHotkey path set to ") . path)
	}
	else
		logMessage(kLogWarn, translate("AutoHotkey path not set"))
	
	path := getConfigurationValue(kSimulatorConfiguration, "Configuration", "NirCmd Path")
	if path {
		kNirCmd := path . "\NirCmd.exe"
		
		logMessage(kLogInfo, translate("NirCmd executable set to ") . kNirCmd)
	}
	else
		logMessage(kLogWarn, translate("NirCmd executable not configured"))
	
	kSilentMode := getConfigurationValue(kSimulatorConfiguration, "Configuration", "Silent Mode", false)
	
	vDebug := (!A_IsCompiled || getConfigurationValue(kSimulatorConfiguration, "Configuration", "Debug", false))
	vLogLevel := inList(["Info", "Warn", "Critical", "Off"], getConfigurationValue(kSimulatorConfiguration, "Configuration", "Log Level", "Warn"))
}

initializeEnvironment() {	
	FileCreateDir %A_MyDocuments%\Simulator Controller
	FileCreateDir %A_MyDocuments%\Simulator Controller\Config
	FileCreateDir %A_MyDocuments%\Simulator Controller\Logs
	FileCreateDir %A_MyDocuments%\Simulator Controller\Splash Media
	FileCreateDir %A_MyDocuments%\Simulator Controller\Plugins
	
	if !FileExist(A_MyDocuments . "\Simulator Controller\Plugins\Plugins.ahk")
		FileCopy %kResourcesDirectory%Templates\Plugins.ahk, %A_MyDocuments%\Simulator Controller\Plugins
	
	if !FileExist(kUserConfigDirectory . "Controller Plugin Labels.ini")
		FileCopy %kResourcesDirectory%Templates\Controller Plugin Labels.ini, %kUserConfigDirectory%
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

showSplash(image, alwaysOnTop := true) {
	image := getFileName(image, kUserSplashMediaDirectory, kSplashMediaDirectory)
	
	lastSplash := vSplashCounter
	vSplashCounter += 1
	vLastImage := image
	
	if (vSplashCounter > 10)
		vSplashCounter := 1
		
	image :=  vSplashCounter . ":" . image
	options := "B FS8 CWD0D0D0 w800 x" . Round((A_ScreenWidth - 800) / 2) . " y" . Round(A_ScreenHeight / 4) . " ZH439 ZW780"
	
	if !alwaysOnTop
		options := "A " . options
	
	title := substituteVariables(getConfigurationValue(kSimulatorConfiguration, "Splash Window", "Title", ""))
	subtitle := substituteVariables(getConfigurationValue(kSimulatorConfiguration, "Splash Window", "Subtitle", ""))
	
	SplashImage %image%, %options%, %subtitle%, %title%
	
	if (lastSplash > 0)
		hideSplash(lastSplash)
}

hideSplash(splashCounter := false) {
	if !splashCounter
		splashCounter := vSplashCounter
		
	SplashImage %splashCounter%:Off
}
	
rotateSplash(alwaysOnTop := true) {
	static number := 1
	static images := false
	static numImages := 0
	
	if !images {
		images := getFileNames("*.jpg", kUserSplashMediaDirectory, kSplashMediaDirectory)
		
		numImages := images.Length()
	}
	
	if (number > numImages)
		number := 1
	
	if (number <= numImages)
		showSplash(images[number++], alwaysOnTop)
}

showSplashAnimation(video) {
	video := getFileName(video, kUserSplashMediaDirectory, kSplashMediaDirectory)
	
	Gui VP:-Border -Caption ; borderless
	Gui VP:Add, ActiveX, x0 y0 w780 h415 vvVideoPlayer, shell explorer

	vVideoPlayer.Navigate("about:blank")
	
	html := "<html><body style='background-color: #000000' style='overflow:hidden' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><img src='" video "' width=780 height=390 border=0 padding=0></body></html>"

	vVideoPlayer.document.write(html)
	
	y := Round(A_ScreenHeight / 4) + 50
	
	Gui VP:Margin, 0, 0
	Gui VP:+AlwaysOnTop
	Gui VP:Show, AutoSize xCenter y%y%
}

hideSplashAnimation() {
	Gui VP:Destroy
}

showSplashTheme(theme := "__Undefined__", songHandler := false, alwaysOnTop := true) {
	static images := false
	static number := 1
	static numImages := 0
	static onTop := false
	
	vVideoIsPlaying := false
	vSongIsPlaying := false
	
	if !songHandler
		songHandler := "playThemeSong"
		
	if (theme == kUndefined) {
		if (number > numImages)
			number := 1
		
		if (number <= numImages)
			showSplash(images[number++], onTop)
			
		return
	}
	
	song := false
	duration := 3000
	type := getConfigurationValue(kSimulatorConfiguration, "Splash Themes", theme . ".Type", false)
	
	if (type == "Video") {
		song := getConfigurationValue(kSimulatorConfiguration, "Splash Themes", theme . ".Song", false)
		video := getConfigurationValue(kSimulatorConfiguration, "Splash Themes", theme . ".Video")
	
		showSplash(video)
		showSplashAnimation(video)
		
		vVideoIsPlaying := true
		
		if song {
			vSongIsPlaying := true
			
			%songHandler%(song)
		}
		
		return
	}
	else if (type == "Picture Carousel") {
		duration := getConfigurationValue(kSimulatorConfiguration, "Splash Themes", theme . ".Duration", 5000)
		song := getConfigurationValue(kSimulatorConfiguration, "Splash Themes", theme . ".Song", false)
		images := string2Values(",", getConfigurationValue(kSimulatorConfiguration, "Splash Themes", theme . ".Images", false))
	}
	else {
		logMessage(kLogCritical, translate("Theme """) . theme . translate(""" not found - please check the setup"))
		
		images := getFileNames("*.jpg", kUserSplashMediaDirectory, kSplashMediaDirectory)
	}
	
	numImages := images.Length()
	onTop := alwaysOnTop
	
	showSplashTheme()
	
	SetTimer showSplashTheme, %duration%
	
	if song {
		vSongIsPlaying := true
		
		%songHandler%(song)
	}
}

hideSplashTheme() {
	SetTimer showSplashTheme, Off
	
	if vVideoIsPlaying
		hideSplashAnimation()

	if vSongIsPlaying
		try {
			SoundPlay NonExistent.avi
		}
		catch ignore {
			; Ignore
		}
			
	hideSplash()
}

getAllThemes() {
	themes := []
	
	for descriptor, value in getConfigurationSectionValues(kSimulatorConfiguration, "Splash Themes", Object()) {
		theme := StrSplit(descriptor, ".")[1]
		
		if !inList(themes, theme)
			themes.Push(theme)
	}
	
	return themes
}

moveByMouse(window) {
	curCoordMode := A_CoordModeMouse
	
	CoordMode Mouse, Screen
		
	try {	
		MouseGetPos anchorX, anchorY
		WinGetPos winX, winY, w, h, %A_ScriptName%
		
		newX := winX
		newY := winY
		
		while GetKeyState("LButton", "P") {
			MouseGetPos x, y
		
			newX := winX + (x - anchorX)
			newY := winY + (y - anchorY)
			
			Gui %window%:Show, X%newX% Y%newY%
		}
	}
	finally {
		CoordMode Mouse, curCoordMode
	}
}

isDebug() {
	return vDebug
}

getLogLevel() {
	return vLogLevel
}

logMessage(logLevel, message) {
	if (logLevel >= vLogLevel) {
		level := ""
		
		switch logLevel {
			case kLogInfo:
				level := "Info    "
			case kLogWarn:
				level := "Warn    "
			case kLogCritical:
				level := "Critical"
			case kLogOff:
				level := "Off     "
			default:
				Throw "Unknown log level (" . logLevel . ") encountered in logMessage..."
		}
	
		fileName := kLogsDirectory . StrSplit(A_ScriptName, ".")[1] . " Logs.txt"
		message := "[" level . " - " . A_Now . "]: " . message . "`n"
		
		SplitPath fileName, , directory
		FileCreateDir %directory%
		FileAppend %message%, %fileName%
	}
}

availableLanguages() {
	translations := {en: "English"}
	
	for ignore, fileName in getFileNames("Translations.*", kConfigDirectory, kUserConfigDirectory) {
		SplitPath fileName, , , languageCode
		
		translations[languageCode] := readTranslations(languageCode)[languageCode]
	}
	
	return translations
}

readTranslations(targetLanguage) {
	translations := {}
	
	Loop Read, % getFileName("Translations." . targetLanguage, kUserConfigDirectory, kConfigDirectory)
	{
		translation := StrSplit(A_LoopReadLine, "=>")
		enString := translation[1]
		
		if (enString[1] != "[")
			if (translations.HasKey(enString) && (translations[enString] != translation[2]))
				Throw "Inconsistent translation encountered for """ . enString . """ in readTranslations..."
			else
				translations[enString] := translation[2]
	}
	
	return translations
}

translate(string) {
	static currentLanguage := "en"
	static translations := false
	
	if (vTargetLanguage != "en") {
		if (vTargetLanguage != currentLanguage) {
			currentLanguage := vTargetLanguage
			
			translations := readTranslations(currentLanguage)
		}
		
		return (translations.HasKey(string) ? translations[string] : string)
	}
	else
		return string
}

setLanguage(language) {
	vTargetLanguage := language
}

getLanguage() {
	return vTargetLanguage
}

protectionOn() {
	changeProtection(true)
}

protectionOff() {
	changeProtection(false)
}

withProtection(function, params*) {
	protectionOn()
	
	try {
		%function%(params*)
	}
	finally {
		protectionOff()
	}
}

getFileName(fileName, directories*) {
	SplitPath fileName, , , , , driveName

	if (driveName && (driveName != ""))
		return fileName
	else {
		for ignore, directory in directories
			if FileExist(directory . fileName)
				return (directory . fileName)
		
		if (directories.Length() > 0)
			return (directories[1] . fileName)
		else
			return fileName
	}
}

getFileNames(filePattern, directories*) {
	files := []
	
	for ignore, directory in directories
		Loop Files, % directory . filePattern
			files.Push(A_LoopFileLongPath)
	
	return files
}

normalizeFilePath(filePath) {
	Loop {
		position := InStr(filePath, "\..")
		
		if position {
			index := position - 1
			
			Loop {
				if (index == 0)
					return filePath
				else if (SubStr(filePath, index, 1) == "\") {
					filePath := StrReplace(filePath, SubStr(filePath, index, position + 3 - index), "")
					
					break
				}
				
				index -= 1
			}
		}
		else
			return filePath
	}
}

substituteVariables(string, values := false) {
	result := string
	
	Loop {
		startPos := InStr(result, "%")
		
		if startPos {
			startPos += 1
			endPos := InStr(result, "%", false, startPos)
			
			if endPos {
				variable := SubStr(result, startPos, endPos - startPos)
				
				value := (values && values.HasKey(variable)) ? values[variable] : %variable%
				
				result := StrReplace(result, "%" . variable . "%", value)
			}
			else
				Throw "Second % not found while scanning (" . string . ") for variables in substituteVariables..."
		}
		else
			break
	}
		
	return result
}

string2Values(delimiter, string, count := false) {
	return (count ? StrSplit(string, delimiter, " `t", count) : StrSplit(string, delimiter, " `t"))
}

values2String(delimiter, values*) {
	result := ""
	
	for index, value in values {
		if (index > 1)
			result .= delimiter
			
		result .= value
	}

	return result
}
	
inList(list, value) {
	for index, candidate in list
		if (candidate = value)
			return index
			
	return false
}

concatenate(arrays*) {
	result := []
	
	for ignore, array in arrays
		for index, value in array
			result.Push(value)
			
	return result
}

map(list, function) {
	result := []
	
	for ignore, value in list
		result.Push(%function%(value))
	
	return result
}

bubbleSort(ByRef array, comparator) {
	n := array.Length()

	while (n > 1) {
		newN := 1
		i := 0
      
		while (++i < n) {
			j := i + 1
         
			if %comparator%(lineI := array[i], lineJ := array[j]) {
				array[i] := lineJ
				array[J] := lineI
			
				newN := j
			}
		}
		
		n := newN
	}
}

registerEventHandler(event, handler) {
	vEventHandlers[event] := handler
}

raiseEvent(target, event, data) {
	if !target {
		logMessage(kLogInfo, translate("Raising event """) . event . (data ? translate(""": ") . data : translate("""")) . translate(" in current process"))
		
		eventHandler := vEventHandlers[event]
	
		if (!eventHandler)
			eventHandler := vEventHandlers["*"]
	
		logMessage(kLogInfo, translate("Dispatching event """) . event . (data ? translate(""": ") . data : translate("""")))
		
		vWaitingEvents.Push(Func(eventHandler).Bind(event, data))
	
		%eventHandler%(event, data)
	}
	else {
		logMessage(kLogInfo, translate("Raising event """) . event . (data ? translate(""": ") . data : translate("""")) . translate(" in target ") . target)
		
		curDetectHiddenWindows := A_DetectHiddenWindows
		curTitleMatchMode := A_TitleMatchMode
		
		event := event . ":" . data
		
		;---------------------------------------------------------------------------
		; construct the message to send
		;---------------------------------------------------------------------------
		dwData := encodeDWORD("EVNT")
		cbData := StrLen(event) * (A_IsUnicode + 1) + 1 ; length of DATA string (incl. ZERO)
		lpData := &event                                ; pointer to DATA string

		;---------------------------------------------------------------------------
		; put the message in a COPYDATASTRUCT
		;---------------------------------------------------------------------------
		VarSetCapacity(struct, A_PtrSize * 3, 0)        ; initialize COPYDATASTRUCT
		NumPut(dwData, struct, A_PtrSize * 0, "UInt")   ; DWORD
		NumPut(cbData, struct, A_PtrSize * 1, "UInt")   ; DWORD
		NumPut(lpData, struct, A_PtrSize * 2, "UInt")   ; 32bit pointer

		;---------------------------------------------------------------------------
		; parameters for SendMessage command
		;---------------------------------------------------------------------------
		message := 0x4a     ; WM_COPYDATA
		wParam  := ""       ; not used
		lParam  := &struct  ; COPYDATASTRUCT
		control := ""       ; not needed

		SetTitleMatchMode 2 ; match part of the title
		DetectHiddenWindows On ; needed for sending messages
		
		try {
			SendMessage %message%, %wParam%, %lParam%, %control%, %target%
		}
		catch exception {
		}
		
		DetectHiddenWindows %curDetectHiddenWindows%
		SetTitleMatchMode %curTitleMatchMode%
	}
}

trayMessage(title, message, duration := false) {
	if !duration
		duration := vTrayMessageDuration
	
	if duration {
		protectionOn()
	
		try {
			vPendingTrayMessages.Push(Array(title, message, duration))
		}
		finally {
			protectionOff()
		}
	}
}

disableTrayMessages() {
	vTrayMessageDuration := false
}

enableTrayMessages(duration := 1500) {
	vTrayMessageDuration := duration
}

translateMsgBoxButtons() {
    DetectHiddenWindows, On
    Process, Exist
    
	If (WinExist("ahk_class #32770 ahk_pid " . ErrorLevel)) {
		ControlGetText label, Button1
		
		if (label != "Ok") {
			ControlSetText Button1, % translate("Yes")
			ControlSetText Button2, % translate("No")
		}
    }
}

readConfiguration(configFile) {
	configFile := getFileName(configFile, kUserConfigDirectory, kConfigDirectory)
	
	configuration := Object()
	
	IniRead sections, %configFile%
	
	sections := StrSplit(sections, "`n")
	
	for i, section in sections {
		IniRead keyValues, %configFile%, %section%
		
		keyValues := StrSplit(keyValues, "`n")
		sectionValues := Object()
		
		for j, keyValue in keyValues {
			keyValue := StrSplit(keyValue, "=")
			
			value := keyValue[2]
			
			sectionValues[keyValue[1]] := ((value == kTrue) ? true : ((value == kFalse) ? false : value))
		}
		
		configuration[section] := sectionValues
	}
	
	return configuration
}

writeConfiguration(configFile, configuration) {
	configFile := getFileName(configFile, kUserConfigDirectory)
	
	SplitPath configFile, , directory
	FileCreateDir %directory%
		
	for section, keyValues in configuration {
		pairs := ""
		
		IniDelete %configFile%, %section%
		
		for key, value in keyValues
			pairs := pairs . "`n" . key . "=" . ((value == true) ? kTrue : ((value == false) ? kFalse : value))
			
		section := "[" . section . "]" . pairs . "`n"
		
		FileAppend %section%, %configFile%
	}
}

getConfigurationValue(configuration, section, key, default := false) {
	if configuration.HasKey(section) {
		value := configuration[section]
		
		if value.HasKey(key)
			return value[key]
	}
	
	return default
}

getConfigurationSectionValues(configuration, section, default := false) {
	return configuration.HasKey(section) ? configuration[section].Clone() : default
}

newConfiguration() {
	return Object()
}

setConfigurationValue(configuration, section, key, value) {
	configuration[section, key] := value
}

setConfigurationSectionValues(configuration, section, values) {
	for key, value in values
		setConfigurationValue(configuration, section, key, value)
}

setConfigurationValues(configuration, otherConfiguration) {
	for section, values in otherConfiguration
		setConfigurationSectionValues(configuration, section, values)
}

removeConfigurationValue(configuration, section, key) {
	if configuration.HasKey(section)
		configuration[section].Delete(key)
}


;;;-------------------------------------------------------------------------;;;
;;;                        Controller Action Section                        ;;;
;;;-------------------------------------------------------------------------;;;

setDebug(debug) {
	vDebug := debug
	
	state := debug ? translate("Enabled") : translate("Disabled")
	
	TrayTip Modular Simulator Controller System, Debug: %state%
}

setLogLevel(level) {
	switch level {
		case "Info":
			level := kLogInfo
		case "Warn":
			level := kLogWarn
		case "Critical":
			level := kLogCritical
		case "Off":
			level := kLogOff
	}
	
	vLogLevel := Min(kLogOff, Max(level, kLogInfo))
	
	state := translate("Unknown")
	
	switch vLogLevel {
		case kLogInfo:
			state := translate("Info")
		case kLogWarn:
			state := translate("Warn")
		case kLogCritical:
			state := translate("Critical")
		case kLogOff:
			state := translate("Off")
	}

	TrayTip Modular Simulator Controller System, % translate("Log Level: ") . %state%
}

increaseLogLevel() {
	setLogLevel(getLogLevel() - 1)
}

decreaseLogLevel() {
	setLogLevel(getLogLevel() + 1)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeEnvironment()
loadSimulatorConfiguration()
initializeLoggingSystem()
initializeEventSystem()
initializeTrayMessageQueue()