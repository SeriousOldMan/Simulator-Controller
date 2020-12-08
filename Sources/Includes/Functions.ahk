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

global vSplashCounter = 0
global vLastImage
global vVideoPlayer

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
	logMessage(kLogCritical, "Unhandled event " . event . ": " . data . "received")
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
	
	logMessage(kLogInfo, "Dispatching event " . event . (data[2] ? ": " . data[2] : ""))
	
	vWaitingEvents.Push(Func(eventHandler).Bind(event, data[2]))
}

initializeEventSystem() {
	OnMessage(0x4a, "dispatchEvent") 
	
	registerEventHandler("*", "unknownEventHandler")
	
	SetTimer eventMessageQueue, 200
}

logError(exception) {
	logMessage(kLogCritical, "Unhandled exception encountered in " . exception.File . " at line " . exception.Line . ": " . exception.Message)
	
	return (vDebug ? false : true)
}

initializeLoggingSystem() {
	OnError("logError")
}

initializeTrayMessageQueue() {
	SetTimer trayMessageQueue, 500
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

showSplash(image, alwaysOnTop := true) {
	vSplashCounter += 1
	vLastImage := image
	
	info := kVersion . " - 2020 by Oliver Juwig, Creative Commons - BY-NC-SA"
	image :=  vSplashCounter . ":" . kSplashImagesDirectory . image
	options := "B FS8 CWD0D0D0 w800 x" . Round((A_ScreenWidth - 800) / 2) . " y" . Round(A_ScreenHeight / 4) . " ZH-1 ZW780"
	
	if !alwaysOnTop
		options := "A " . options
	
	SplashImage %image%, %options%, %info%, Modular Simulator Controller System
}

hideSplash() {
	SplashImage %vSplashCounter%:Off
}

showSplashAnimation(gif) {
	video := kSplashImagesDirectory . gif

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

isDebug() {
	return vDebug
}

setDebug(debug) {
	vDebug := debug
	
	state := debug ? "Enabled" : "Disabled"
	
	TrayTip Modular Simulator Controller System, Debug: %state%
}

getLogLevel() {
	return vLogLevel
}

setLogLevel(level) {
	vLogLevel := Min(kLogOff, Max(level, kLogInfo))
	
	state := "Unknown"
	
	switch vLogLevel {
		case kLogInfo:
			state := "Info"
		case kLogWarn:
			state := "Warn"
		case kLogCritical:
			state := "Critical"
		case kLogOff:
			state := "Off"
	}

	TrayTip Modular Simulator Controller System, Log Level: %state%
}

increaseLogLevel() {
	setLogLevel(getLogLevel() - 1)
}

decreaseLogLevel() {
	setLogLevel(getLogLevel() + 1)
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
		logMessage(kLogInfo, "Raising event " . event . (data ? ": " . data : "") . " in current process")
		
		eventHandler := vEventHandlers[event]
	
		if (!eventHandler)
			eventHandler := vEventHandlers["*"]
	
		logMessage(kLogInfo, "Dispatching event " . event . (data ? ": " . data : ""))
		
		vWaitingEvents.Push(Func(eventHandler).Bind(event, data))
	
		%eventHandler%(event, data)
	}
	else {
		logMessage(kLogInfo, "Raising event " . event . (data ? ": " . data : "") . " in target " . target)
		
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
			ControlSetText Button1, Yes
			ControlSetText Button2, No
		}
    }
}

readConfiguration(configFile) {
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

loadSimulatorConfiguration() {
	kVersion := getConfigurationValue(readConfiguration(kHomeDirectory . "VERSION"), "Version", "Current", "0.0.0")
	
	logMessage(kLogCritical, "---------------------------------------------------------------")
	logMessage(kLogCritical, "           Running " . StrSplit(A_ScriptName, ".")[1] . " (" . kVersion . ")")
	logMessage(kLogCritical, "---------------------------------------------------------------")
		
	kSimulatorConfiguration := readConfiguration(kSimulatorConfigurationFile)
	
	if (kSimulatorConfiguration.Count() == 0)
		logMessage(kLogCritical, "No configuration found - please run the Setup tool...")	
	
	path := getConfigurationValue(kSimulatorConfiguration, "Configuration", "Home Path")
	if path {
		kHomeDirectory := path . "\"
		
		logMessage(kLogInfo, "Home path set to " . path)
	}
	else
		logMessage(kLogWarn, "Home path not set")
	
	path := getConfigurationValue(kSimulatorConfiguration, "Configuration", "AHK Path")
	if path {
		kAHKDirectory := path . "\"
		
		logMessage(kLogInfo, "AutoHotkey path set to " . path)
	}
	else
		logMessage(kLogWarn, "AutoHotkey path not set")
	
	path := getConfigurationValue(kSimulatorConfiguration, "Configuration", "NirCmd Path")
	if path {
		kNirCmd := path . "\NirCmd.exe"
		
		logMessage(kLogInfo, "NirCmd executable set to " . kNirCmd)
	}
	else
		logMessage(kLogWarn, "NirCmd executable not configured")
		
	vDebug := getConfigurationValue(kSimulatorConfiguration, "Configuration", "Debug", false)
	vLogLevel := inList(["Info", "Warn", "Critical", "Off"], getConfigurationValue(kSimulatorConfiguration, "Configuration", "Log Level", "Warn"))
		
	kSilentMode := getConfigurationValue(kSimulatorConfiguration, "Configuration", "Silent Mode", false)
}

setConfigurationValue(configuration, section, key, value) {
	configuration[section, key] := value
}

removeConfigurationValue(configuration, section, key) {
	if configuration.HasKey(section)
		configuration[section].Delete(key)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

loadSimulatorConfiguration()
initializeLoggingSystem()
initializeEventSystem()
initializeTrayMessageQueue()