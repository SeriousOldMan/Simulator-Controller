;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Server Administration Tool      ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Server Administration.ico
;@Ahk2Exe-ExeName Server Administration.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\CLR.ahk


;;;-------------------------------------------------------------------------;;;
;;;                   Private Constant Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

global kClose = "Close"
global kCancel = "Cancel"
global kConnect = "Connect"
global kEvent = "Event"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vToken := false
	
	
;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

setButtonIcon(buttonHandle, file, index := 1, options := "") {
;   Parameters:
;   1) {Handle} 	HWND handle of Gui button
;   2) {File} 		File containing icon image
;   3) {Index} 		Index of icon in file
;						Optional: Default = 1
;   4) {Options}	Single letter flag followed by a number with multiple options delimited by a space
;						W = Width of Icon (default = 16)
;						H = Height of Icon (default = 16)
;						S = Size of Icon, Makes Width and Height both equal to Size
;						L = Left Margin
;						T = Top Margin
;						R = Right Margin
;						B = Botton Margin
;						A = Alignment (0 = left, 1 = right, 2 = top, 3 = bottom, 4 = center; default = 4)

	RegExMatch(options, "i)w\K\d+", W), (W="") ? W := 16 :
	RegExMatch(options, "i)h\K\d+", H), (H="") ? H := 16 :
	RegExMatch(options, "i)s\K\d+", S), S ? W := H := S :
	RegExMatch(options, "i)l\K\d+", L), (L="") ? L := 0 :
	RegExMatch(options, "i)t\K\d+", T), (T="") ? T := 0 :
	RegExMatch(options, "i)r\K\d+", R), (R="") ? R := 0 :
	RegExMatch(options, "i)b\K\d+", B), (B="") ? B := 0 :
	RegExMatch(options, "i)a\K\d+", A), (A="") ? A := 4 :

	ptrSize := A_PtrSize = "" ? 4 : A_PtrSize, DW := "UInt", Ptr := A_PtrSize = "" ? DW : "Ptr"

	VarSetCapacity(button_il, 20 + ptrSize, 0)

	NumPut(normal_il := DllCall("ImageList_Create", DW, W, DW, H, DW, 0x21, DW, 1, DW, 1), button_il, 0, Ptr)	; Width & Height
	NumPut(L, button_il, 0 + ptrSize, DW)		; Left Margin
	NumPut(T, button_il, 4 + ptrSize, DW)		; Top Margin
	NumPut(R, button_il, 8 + ptrSize, DW)		; Right Margin
	NumPut(B, button_il, 12 + ptrSize, DW)		; Bottom Margin	
	NumPut(A, button_il, 16 + ptrSize, DW)		; Alignment

	SendMessage, BCM_SETIMAGELIST := 5634, 0, &button_il,, AHK_ID %buttonHandle%

	return IL_Add(normal_il, file, index)
}

createPassword(length) {
	valid = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
	result := ""
	
	while (0 < length--) {
		Random index, 1, % StrLen(valid)
	
		result .= SubStr(valid, Round(index), 1)
	}
            
	return result
}

global teamServerURLEdit = "https://localhost:5001"
global teamServerNameEdit = ""
global teamServerPasswordEdit = ""
global teamServerTokenEdit = ""
global accountsListView

administrationEditor(configurationOrCommand, arguments*) {
	static connector := false
	static done := false
	
	if (configurationOrCommand == kClose)
		done := true
	else if (configurationOrCommand == kConnect) {
		GuiControlGet teamServerURLEdit
		GuiControlGet teamServerNameEdit
		GuiControlGet teamServerPasswordEdit
		
		try {
			connector.Connect(teamServerURLEdit)
			vToken := connector.Login(teamServerNameEdit, teamServerPasswordEdit)
			
			GuiControl, , teamServerTokenEdit, % vToken
			
			showMessage(translate("Successfully connected to the Team Server."))
		}
		catch exception {
			title := translate("Error")
		
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			MsgBox 262160, %title%, % (translate("Cannot connect to the Team Server.") . "`n`n" . translate("Error: ") . exception.Message)
			OnMessage(0x44, "")
		}
	}
	else if (configurationOrCommand == kEvent) {
		if (arguments[1] = "PasswordChange") {
			connector.ChangePassword(arguments[2])
			
			GuiControl, , teamServerPasswordEdit, % arguments[2]
		}
	}
	else {
		dllName := "Team Server Connector.dll"
		dllFile := kBinariesDirectory . dllName
		
		try {
			if (!FileExist(dllFile)) {
				logMessage(kLogCritical, translate("Team Server Connector.dll not found in ") . kBinariesDirectory)
				
				Throw "Unable to find Team Server Connector.dll in " . kBinariesDirectory . "..."
			}

			connector := CLR_LoadLibrary(dllFile).CreateInstance("TeamServer.TeamServerConnector")
		}
		catch exception {
			logMessage(kLogCritical, translate("Error while initializing Team Server Connector - please rebuild the applications"))
			
			showMessage(translate("Error while initializing Team Server Connector - please rebuild the applications") . translate("...")
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
	
		Gui ADM:Default
			
		Gui ADM:-Border ; -Caption
		Gui ADM:Color, D0D0D0, D8D8D8

		Gui ADM:Font, Bold, Arial

		Gui ADM:Add, Text, w388 Center gmoveAdministrationEditor, % translate("Modular Simulator Controller System") 

		Gui ADM:Font, Norm, Arial
		Gui ADM:Font, Italic Underline, Arial

		Gui ADM:Add, Text, YP+20 w388 cBlue Center gopenAdministrationDocumentation, % translate("Server Administration")
		
		Gui ADM:Add, Text, x24 yp+30 w356 0x10

		Gui ADM:Font, Norm, Arial
				
		Gui ADM:Add, Button, x164 y450 w80 h23 gcloseAdministrationEditor, % translate("Close")
		
		x := 8
		y := 68
		width := 388
		
		x0 := x + 8
		x1 := x + 132
		
		w1 := width - (x1 - x + 8)
		
		w2 := w1 - 70
		
		x2 := x + 172
		
		x2 := x1 - 25
		
		w4 := w1 - 25
		x4 := x1 + w4 + 2
		
		w3 := Round((w4 / 2) - 3)
		x3 := x1 + w3 + 6
		
		x4 := x3 + 64
		
		x5 := x3 + w3 + 2
		w5 := w3 - 25
		
		Gui ADM:Add, Text, x%x0% y%y% w90 h23 +0x200, % translate("Server URL")
		Gui ADM:Add, Edit, x%x1% yp+1 w%w4% h21 VteamServerURLEdit, %teamServerURLEdit%
		
		Gui ADM:Add, Text, x%x0% yp+23 w90 h23 +0x200, % translate("Login Credentials")
		Gui ADM:Add, Edit, x%x1% yp+1 w%w3% h21 HWNDloginHandle VteamServerNameEdit, %teamServerNameEdit%
		Gui ADM:Add, Edit, x%x3% yp w%w3% h21 Password VteamServerPasswordEdit, %teamServerPasswordEdit%
		Gui ADM:Add, Button, x%x5% yp-1 w23 h23 Center +0x200 HWNDchangePasswordButton gchangePassword
		setButtonIcon(changePasswordButton, kIconsDirectory . "Pencil.ico", 1, "L4 T4 R4 B4")
		
		Gui ADM:Add, Text, x%x0% yp+26 w90 h23 +0x200, % translate("Access Token")
		Gui ADM:Add, Edit, x%x1% yp-1 w%w4% h21 ReadOnly VteamServerTokenEdit, %teamServerTokenEdit%
		Gui ADM:Add, Button, x%x2% yp-1 w23 h23 Default Center +0x200 HWNDconnectButton grenewToken
		setButtonIcon(connectButton, kIconsDirectory . "Authorize.ico", 1, "L4 T4 R4 B4")

		Gui ADM:Add, Tab3, x8 y148 w388 h293 -Wrap, % values2String("|", map(["Accounts", "Jobs"], "translate")*)
		
		x0 := 16
		y := 178
		
		Gui Tab, 1
		
		Gui ADM:Add, ListView, x%x0% y%y% w372 h120 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndaccountsListView gaccountsListEvent, % values2String("|", map(["Account", "eMail", "Type"], "translate")*)
		
		Gui ADM:Add, Text, x%x0% yp+124 w90 h23 +0x200, % translate("Name")
		Gui ADM:Add, Edit, x%x1% yp+1 w%w3%
		
		Gui ADM:Add, Text, x%x0% yp+24 w90 h23 +0x200, % translate("Password")
		Gui ADM:Add, Edit, x%x1% yp+1 w%w4% Disabled Password, % createPassword(20)
		Gui ADM:Add, Button, x%x5% yp-1 w23 h23 Center +0x200 HWNDcopyPasswordButton
		setButtonIcon(copyPasswordButton, kIconsDirectory . "Copy.ico", 1, "L4 T4 R4 B4")
		
		Gui ADM:Add, Text, x%x0% yp+24 w90 h23 +0x200, % translate("E-Mail")
		Gui ADM:Add, Edit, x%x1% yp+1 w%w4%
		
		Gui ADM:Add, Text, x%x0% yp+24 w90 h23 +0x200, % translate("Contract")
		Gui ADM:Add, DropDownList, x%x1% yp+1 w%w3% Choose2, % values2String("|", map(["One-Time", "Monthly Fixed", "Monthly Additional"], "translate")*)
		Gui ADM:Add, Edit, x%x3% yp w60 h21
		Gui ADM:Add, Text, x%x4% yp w90 h23 +0x200, % translate("Minutes")
		
		Gui Tab, 2
		
		Gui ADM:Add, Text, x%x0% y%y% w90 h23 +0x200, % translate("Delete Tokens")
		Gui ADM:Add, DropDownList, x%x1% yp+1 w%w3% Choose2, % values2String("|", map(["Never", "Daily", "Weekly", "1st of Month"], "translate")*)
		
		Gui ADM:Add, Text, x%x0% yp+23 w90 h23 +0x200, % translate("Cleanup Sessions")
		Gui ADM:Add, DropDownList, x%x1% yp+1 w%w3% Choose2, % values2String("|", map(["Never", "Daily", "Weekly", "1st of Month"], "translate")*)
		
		Gui ADM:Add, Text, x%x0% yp+23 w90 h23 +0x200, % translate("Renew Accounts")
		Gui ADM:Add, DropDownList, x%x1% yp+1 w%w3% Choose3, % values2String("|", map(["Never", "Daily", "Weekly", "1st of Month"], "translate")*)
		
		Gui ADM:Show, AutoSize Center
		
		ControlFocus, , ahk_id %loginHandle%
		
		Loop {
			Sleep 1000
		} until done
	}
}

moveAdministrationEditor() {
	moveByMouse("ADM")
}

closeAdministrationEditor() {
	administrationEditor(kClose)
}

openAdministrationDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#server-administration
}

renewToken() {
	administrationEditor(kConnect)
}

changePassword() {
	errorTitle := translate("Error")
	
	if vToken {
		title := translate("Team Server")
		prompt := translate("Please enter your current password:")
		
		Gui ADM:Default
		
		GuiControlGet teamServerPasswordEdit
		
		locale := ((getLanguage() = "en") ? "" : "Locale")
		
		InputBox password, %title%, %prompt%, Hide, 200, 150, , , %locale%
		
		if ErrorLevel
			return

		if (teamServerPasswordEdit != password) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			MsgBox 262160, %errorTitle%, % translate("Invalid password.")
			OnMessage(0x44, "")
			
			return
		}
		
		prompt := translate("Please enter your new password:")
		
		InputBox firstPassword, %title%, %prompt%, Hide, 200, 150, , , %locale%
		
		if ErrorLevel
			return
		
		prompt := translate("Please re-enter your new password:")
		
		InputBox secondPassword, %title%, %prompt%, Hide, 200, 150, , , %locale%
		
		if ErrorLevel
			return
		
		if (firstPassword != secondPassword) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			MsgBox 262160, %errorTitle%, % translate("The passwords do not match.")
			OnMessage(0x44, "")
			
			return
		}
		
		administrationEditor(kEvent, "PasswordChange", firstPassword)
	}
	else {
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
		MsgBox 262160, %errorTitle%, % translate("You must be connected to the Team Server to change your password.")
		OnMessage(0x44, "")
	}
}

accountsListEvent() {
}

startupServerAdministration() {
	icon := kIconsDirectory . "Server Administration.ico"
	
	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Server Administration
	
	administrationEditor(kSimulatorConfiguration)
	
	ExitApp 0
}


;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

startupServerAdministration()