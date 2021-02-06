;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Engineer                   ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#SingleInstance Force			; Ony one instance allowed
#NoEnv							; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn							; Enable warnings to assist with detecting common errors.
#Warn LocalSameAsGlobal, Off

SendMode Input					; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.

SetBatchLines -1				; Maximize CPU utilization
ListLines Off					; Disable execution history

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Artificial Intelligence.ico
;@Ahk2Exe-ExeName Race Engineer.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\RuleEngine.ahk
#Include ..\Libraries\RaceEngineer.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vRemotePID = 0


;;;-------------------------------------------------------------------------;;;
;;;                         Private Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RemotePitstopHandler {
	iRemotePID := false
	
	RemotePID[] {
		Get {
			return this.iRemotePID
		}
	}
	
	__New(remotePID) {
		this.iRemotePID := remotePID
	}
		
	callRemote(function, synchronous, arguments*) {
		if synchronous
			return raiseEvent("Pitstop", function . ":" . values2String(";", arguments*))
		else
			return deliverMessage("ahk_pid " . this.RemotePID, "Pitstop", function . ":" . values2String(";", arguments*))
	}
	
	pitstopPlanned(arguments*) {
		return this.callRemote("pitstopPlanned", false, arguments*)
	}
	
	pitstopPrepared(arguments*) {
		return this.callRemote("pitstopPrepared", true, arguments*)
	}
	
	pitstopFinished(arguments*) {
		return this.callRemote("pitstopFinished", false, arguments*)
	}
	
	startPitstopSetup(arguments*) {
		return this.callRemote("startPitstopSetup", true, arguments*)
	}

	finishPitstopSetup(arguments*) {
		return this.callRemote("finishPitstopSetup", true, arguments*)
	}

	setPitstopRefuelAmount(arguments*) {
		return this.callRemote("setPitstopRefuelAmount", true, arguments*)
	}
	
	setPitstopTyreSet(arguments*) {
		return this.callRemote("setPitstopTyreSet", true, arguments*)
	}

	setPitstopTyrePressures(arguments*) {
		return this.callRemote("setPitstopTyrePressures", true, arguments*)
	}

	requestPitstopRepairs(arguments*) {
		return this.callRemote("requestPitstopRepairs", true, arguments*)
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

showMessageReceiver() {
	title1 := translate("Modular Simulator Controller System")
	title2 := translate("Jona - The Virtual Race Engineer")
	
	Gui RE:-border -Caption
	Gui RE:Color, D0D0D0
	Gui RE:Add, Text, X10 Y10, % title1
	Gui RE:Add, Text, , % title2
	
	Gui RE:Margin, 10, 10
	Gui RE:Show, Hide AutoSize X0 Y0
}

showLogo() {
	static videoPlayer

	info := kVersion . " - 2021, Oliver Juwig`nCreative Commons - BY-NC-SA"
	logo := kResourcesDirectory . "Rotating Brain.gif"
	image := "1:" . logo

	SysGet mainScreen, MonitorWorkArea
	
	x := mainScreenRight - 299
	y := mainScreenBottom - 234

	title1 := translate("Modular Simulator Controller System")
	title2 := translate("Jona - The Virtual Race Engineer")
	SplashImage %image%, B FS8 CWD0D0D0 w299 x%x% y%y% ZH155 ZW279, %info%, %title1%`n%title2%

	Gui Logo:-Border -Caption 
	Gui Logo:Add, ActiveX, x0 y0 w279 h155 VvideoPlayer, shell explorer

	videoPlayer.Navigate("about:blank")

	html := "<html><body style='background-color: transparent' style='overflow:hidden' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><img src='" . logo . "' width=279 height=155 border=0 padding=0></body></html>"

	videoPlayer.document.write(html)

	x += 10
	y += 40

	Gui Logo:Margin, 0, 0
	Gui Logo:+AlwaysOnTop
	Gui Logo:Show, AutoSize x%x% y%y%
}

hideLogo() {
	Gui Logo:Destroy
	SplashImage 1:Off
}
	
checkRemoteProcessAlive() {
	Process Exist, %vRemotePID%
	
	if !ErrorLevel
		ExitApp 0
}

startRaceEngineer() {
	icon := kIconsDirectory . "Artificial Intelligence.ico"
	
	Menu Tray, Icon, %icon%, , 1
	
	remotePID := 0
	remoteHandle := false
	engineerName := "Jona"
	engineerLogo := false
	engineerLanguage := false
	engineerSpeaker := false
	engineerListener:= false
	raceSettingsFile := getFileName("Race Engineer.settings", kUserConfigDirectory, kConfigDirectory)
	
	index := 1
	
	while (index < A_Args.Length()) {
		switch A_Args[index] {
			case "-Remote":
				remotePID := A_Args[index + 1]
				index += 2
			case "-Name":
				engineerName := A_Args[index + 1]
				index += 2
			case "-Logo":
				engineerLogo := (A_Args[index + 1] = "true") ? true : false
				index += 2
			case "-Language":
				engineerLanguage := A_Args[index + 1]
				index += 2
			case "-Speaker":
				engineerSpeaker := A_Args[index + 1]
				index += 2
			case "-Listener":
				engineerListener := A_Args[index + 1]
				index += 2
			case "-Settings":
				raceSettingsFile := A_Args[index + 1]
				index += 2
		}
	}
	
	registerEventHandler("Race", "handleRemoteCalls")
	
	RaceEngineer.Instance := new RaceEngineer(kSimulatorConfiguration, readConfiguration(raceSettingsFile)
											, remotePID ? new RemotePitstopHandler(remotePID) : false, engineerName, engineerLanguage, engineerSpeaker, engineerListener)
	
	showMessageReceiver()
	
	if engineerLogo
		showLogo()
	
	if (remotePID != 0) {
		vRemotePID := remotePID
		
		SetTimer checkRemoteProcessAlive, 10000
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                          Event Handler Section                          ;;;
;;;-------------------------------------------------------------------------;;;

handleRemoteCalls(event, data) {
	local function
	
	if InStr(data, ":") {
		data := StrSplit(data, ":", , 2)
		
		if (data[1] = "Shutdown")
			ExitApp 0
	
		function := ObjBindMethod(RaceEngineer.Instance, data[1])
		arguments := string2Values(";", data[2])
		
		return withProtection(function, arguments*)
	}
	else if (data = "Shutdown") {
		Sleep 30000
		
		ExitApp 0
	}
	else
		return withProtection(ObjBindMethod(RaceEngineer.Instance, data))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

startRaceEngineer()