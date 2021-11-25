;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Team Server Configuration       ;;;
;;;                                         Plugin                          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\CLR.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; TeamServerConfigurator                                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global teamServerURLEdit = "https://localhost:5001"
global teamServerNameEdit = ""
global teamServerPasswordEdit = ""
global teamServerTokenEdit = ""
global teamServerTimeText = ""

global teamDropDownList
global driverListBox

global addTeamButton
global deleteTeamButton
global editTeamButton
global addDriverButton
global deleteDriverButton
global editDriverButton

global sessionListBox

global addSessionButton
global deleteSessionButton
global editSessionButton

class TeamServerConfigurator extends ConfigurationItem {
	iEditor := false
	
	iConnector := false
	iToken := false
	
	iTeams := {}
	iSelectedTeam := false
	
	iDrivers := {}
	iSelectedDriver := false
	
	iSessions := {}
	iSelectedSession := false
	
	Editor[] {
		Get {
			return this.iEditor
		}
	}
	
	Connector[] {
		Get {
			return this.iConnector
		}
	}
	
	Token[] {
		Get {
			return this.iToken
		}
	}
	
	Teams[key := false] {
		Get {
			return (key ? this.iTeams[key] : this.iTeams)
		}
	}
	
	SelectedTeam[] {
		Get {
			return this.iSelectedTeam
		}
	}
	
	Drivers[key := false] {
		Get {
			return (key ? this.iDrivers[key] : this.iDrivers)
		}
	}
	
	SelectedDriver[] {
		Get {
			return this.iSelectedDriver
		}
	}
	
	Sessions[key := false] {
		Get {
			return (key ? this.iSessions[key] : this.iSessions)
		}
	}
	
	SelectedSession[] {
		Get {
			return this.iSelectedSession
		}
	}
	
	__New(editor, configuration := false) {
		this.iEditor := editor
		
		base.__New(configuration)
		
		dllName := "Team Server Connector.dll"
		dllFile := kBinariesDirectory . dllName
		
		try {
			if (!FileExist(dllFile)) {
				logMessage(kLogCritical, translate("Team Server Connector.dll not found in ") . kBinariesDirectory)
				
				Throw "Unable to find Team Server Connector.dll in " . kBinariesDirectory . "..."
			}

			this.iConnector := CLR_LoadLibrary(dllFile).CreateInstance("TeamServer.TeamServerConnector")
		}
		catch exception {
			logMessage(kLogCritical, translate("Error while initializing Team Server Connector - please rebuild the applications"))
			
			showMessage(translate("Error while initializing Team Server Connector - please rebuild the applications") . translate("...")
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
		
		TeamServerConfigurator.Instance := this
	}
	
	createGui(editor, x, y, width, height) {
		window := editor.Window
		
		Gui %window%:Font, Norm, Arial
		
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
		
		Gui %window%:Add, Text, x%x0% y%y% w90 h23 +0x200 HWNDwidget1 Hidden, % translate("Server URL")
		Gui %window%:Add, Edit, x%x1% yp+1 w%w4% h21 VteamServerURLEdit HWNDwidget2 Hidden, %teamServerURLEdit%
		Gui %window%:Add, Button, x%x4% yp-1 w23 h23 Center +0x200 gcopyURL HWNDwidget26 Hidden
		setButtonIcon(widget26, kIconsDirectory . "Copy.ico", 1, "L4 T4 R4 B4")
		
		Gui %window%:Add, Text, x%x0% yp+23 w90 h23 +0x200 HWNDwidget3 Hidden, % translate("Login Credentials")
		Gui %window%:Add, Edit, x%x1% yp+1 w%w3% h21 VteamServerNameEdit HWNDwidget4 Hidden, %teamServerNameEdit%
		Gui %window%:Add, Edit, x%x3% yp w%w3% h21 Password VteamServerPasswordEdit HWNDwidget5 Hidden, %teamServerPasswordEdit%
		
		Gui %window%:Add, Text, x%x0% yp+26 w90 h23 +0x200 HWNDwidget7 Hidden, % translate("Access Token")
		Gui %window%:Add, Edit, x%x1% yp-1 w%w4% h21 ReadOnly VteamServerTokenEdit HWNDwidget8 Hidden, %teamServerTokenEdit%
		Gui %window%:Add, Button, x%x2% yp-1 w23 h23 Center +0x200 grenewToken HWNDwidget6 Hidden
		setButtonIcon(widget6, kIconsDirectory . "Authorize.ico", 1, "L4 T4 R4 B4")
		Gui %window%:Add, Button, x%x4% yp w23 h23 Center +0x200 gcopyToken HWNDwidget11 Hidden
		setButtonIcon(widget11, kIconsDirectory . "Copy.ico", 1, "L4 T4 R4 B4")
		
		Gui %window%:Add, Text, x%x0% yp+26 w90 h23 +0x200 HWNDwidget9 Hidden, % translate("Contingent")
		
		Gui %window%:Font, cGray
		
		Gui %window%:Add, Text, x%x1% yp+4 w%w1% h21 VteamServerTimeText HWNDwidget10 Hidden, % translate("Please Login for actual data...")
		
		Gui %window%:Font, cBlack Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, -Theme x%x% yp+30 w%width% h214 HWNDwidget12 Hidden, % translate("Teams")
		
		Gui %window%:Font, Norm, Arial
		
		x5 := x1 + w3 + 3
		x6 := x5 + 24
		x7 := x6 + 24
		
		Gui %window%:Add, Text, x%x0% yp+24 w90 h23 +0x200 HWNDwidget13 Hidden, % translate("Team")
		Gui %window%:Add, DropDownList, x%x1% yp w%w3% AltSubmit gselectTeam vteamDropDownList HWNDwidget14 Hidden
		Gui %window%:Add, Button, x%x5% yp w23 h23 Center +0x200 vaddTeamButton gnewTeam HWNDwidget15 Hidden
		setButtonIcon(widget15, kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		Gui %window%:Add, Button, x%x6% yp w23 h23 Center +0x200 vdeleteTeamButton gdeleteTeam HWNDwidget16 Hidden
		setButtonIcon(widget16, kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")
		Gui %window%:Add, Button, x%x7% yp w23 h23 Center +0x200 veditTeamButton grenameTeam HWNDwidget17 Hidden
		setButtonIcon(widget17, kIconsDirectory . "Pencil.ico", 1, "L4 T4 R4 B4")
		
		Gui %window%:Add, Text, x%x0% yp+26 w90 h23 +0x200 HWNDwidget18 Hidden, % translate("Drivers")
		Gui %window%:Add, ListBox, x%x1% yp w%w3% h96 AltSubmit gselectDriver vdriverListBox HWNDwidget19 Hidden
		Gui %window%:Add, Button, x%x5% yp w23 h23 Center +0x200 vaddDriverButton gnewDriver HWNDwidget20 Hidden
		setButtonIcon(widget20, kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		Gui %window%:Add, Button, x%x6% yp w23 h23 Center +0x200 vdeleteDriverButton gdeleteDriver HWNDwidget21 Hidden
		setButtonIcon(widget21, kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")
		Gui %window%:Add, Button, x%x7% yp w23 h23 Center +0x200 veditDriverButton grenameDriver HWNDwidget22 Hidden
		setButtonIcon(widget22, kIconsDirectory . "Pencil.ico", 1, "L4 T4 R4 B4")
		
		Gui %window%:Add, Text, x%x0% yp+92 w90 h23 +0x200 HWNDwidget23 Hidden, % translate("Sessions")
		Gui %window%:Add, ListBox, x%x1% yp w%w3% h72 AltSubmit gselectSession vsessionListBox HWNDwidget24 HiddenHidden
		Gui %window%:Add, Button, x%x5% yp w23 h23 Center +0x200 vaddSessionButton gnewSession HWNDwidget27 Hidden
		setButtonIcon(widget27, kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		Gui %window%:Add, Button, x%x6% yp w23 h23 Center +0x200 vdeleteSessionButton gdeleteSession HWNDwidget25 Hidden
		setButtonIcon(widget25, kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")
		Gui %window%:Add, Button, x%x7% yp w23 h23 Center +0x200 veditSessionButton grenameSession HWNDwidget28 Hidden
		setButtonIcon(widget28, kIconsDirectory . "Pencil.ico", 1, "L4 T4 R4 B4")
		
		Loop 28
			editor.registerWidget(this, widget%A_Index%)
		
		this.connect(false)
		
		this.updateState()
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		teamServerURLEdit := getConfigurationValue(configuration, "Team Server", "Server.URL", "https://localhost:5001")
		teamServerNameEdit := getConfigurationValue(configuration, "Team Server", "Account.Name", "")
		teamServerPasswordEdit := getConfigurationValue(configuration, "Team Server", "Account.Password", "")
		teamServerTokenEdit := getConfigurationValue(configuration, "Team Server", "Server.Token", "")
	}
	
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)

		window := this.Editor.Window
		
		Gui %window%:Default

		GuiControlGet teamServerURLEdit
		GuiControlGet teamServerNameEdit
		GuiControlGet teamServerPasswordEdit
		GuiControlGet teamServerTokenEdit
		
		setConfigurationValue(configuration, "Team Server", "Server.URL", teamServerURLEdit)
		setConfigurationValue(configuration, "Team Server", "Server.Token", teamServerTokenEdit)
		setConfigurationValue(configuration, "Team Server", "Account.Name", teamServerNameEdit)
		setConfigurationValue(configuration, "Team Server", "Account.Password", teamServerPasswordEdit)
	}
	
	connect(message := true) {
		connector := this.Connector

		window := this.Editor.Window
		
		Gui %window%:Default
		
		GuiControlGet teamServerURLEdit
		GuiControlGet teamServerNameEdit
		GuiControlGet teamServerPasswordEdit

		try {
			connector.Connect(teamServerURLEdit)
			
			connector.Login(teamServerNameEdit, teamServerPasswordEdit)
			
			this.iToken := connector.Token
			minutesLeft := connector.GetMinutesLeft()
			
			GuiControl, , teamServerTokenEdit, % this.Token
			GuiControl +cBlack, teamServerTimeText
			GuiControl, , teamServerTimeText, % (minutesLeft . translate(" Minutes"))
			
			showMessage(translate("Successfully connected to the Team Server."))
		}
		catch exception {
			GuiControl, , teamServerTokenEdit, % ""
			GuiControl, , teamServerTimeText, % ""
			
			if message {
				title := translate("Error")
				
				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
				MsgBox 262160, %title%, % (translate("Cannot connect to the Team Server.") . "`n`n" . translate("Error: ") . exception.Message)
				OnMessage(0x44, "")
			}
			
			this.Token := false
		}
		
		this.loadTeams()
	}
	
	updateState() {
		GuiControl Disable, addTeamButton
		GuiControl Disable, deleteTeamButton
		GuiControl Disable, editTeamButton
		
		GuiControl Disable, addDriverButton
		GuiControl Disable, deleteDriverButton
		GuiControl Disable, editDriverButton
		
		GuiControl Disable, addSessionButton
		GuiControl Disable, deleteSessionButton
		GuiControl Disable, editSessionButton
		
		if this.Token {
			GuiControl Enable, addTeamButton
			
			if this.SelectedTeam {
				GuiControl Enable, deleteTeamButton
				GuiControl Enable, editTeamButton
				
				GuiControl Enable, addDriverButton
				GuiControl Enable, addSessionButton
				
				if this.SelectedDriver {
					GuiControl Enable, deleteDriverButton
					GuiControl Enable, editDriverButton
				}
				
				if this.SelectedSession {
					GuiControl Enable, deleteSessionButton
					GuiControl Enable, editSessionButton
				}
			}
		}	
	}
	
	parseObject(properties) {
		result := {}
		
		properties := StrReplace(properties, "`r", "")
		
		Loop Parse, properties, `n
		{
			property := string2Values("=", A_LoopField)
			
			result[property[1]] := property[2]
		}
		
		return result
	}
	
	loadTeams() {
		connector := this.Connector
		
		this.iTeams := {}
		
		if this.Token
			for ignore, identifier in string2Values(";", connector.GetAllTeams())
				try {
					team := this.parseObject(connector.GetTeam(identifier))
					
					this.iTeams[team.Name] := team.Identifier
				}
				catch exception {
					; ignore
				}

		window := this.Editor.Window
		
		Gui %window%:Default
		
		teams := []
		
		for name, ignore in this.Teams
			teams.Push(name)
		
		GuiControl, , teamDropDownList, % ("|" . values2String("|", teams*))
		
		this.SelectTeam(((teams.Length() > 0) ? teams[1] : false))
	}
	
	loadDrivers() {
		connector := this.Connector
		
		window := this.Editor.Window
		
		Gui %window%:Default
	
		GuiControl, , driverListBox, |
		
		this.iDrivers := {}
	
		if this.SelectedTeam
			for ignore, identifier in string2Values(";", connector.GetTeamDrivers(this.Teams[this.SelectedTeam])) {
				try {
					driver := this.parseObject(connector.GetDriver(identifier))
					
					name := (driver.ForName . A_Space . driver.SurName . A_Space . translate("(") . driver.NickName . translate(")"))
					
					this.iDrivers[name] := driver.Identifier
				}
				catch exception {
					; ignore
				}
			}			
		
		drivers := []
		
		for name, ignore in this.Drivers
			drivers.Push(name)
		
		GuiControl, , driverListBox, % ("|" . values2String("|", drivers*))
		
		this.selectDriver((drivers.Length() > 0) ? drivers[1] : false)
	}
	
	loadSessions() {
		connector := this.Connector
		
		window := this.Editor.Window
		
		Gui %window%:Default
	
		GuiControl, , sessionListBox, |
		
		this.iSessions := {}
	
		if this.SelectedTeam
			for ignore, identifier in string2Values(";", connector.GetTeamSessions(this.Teams[this.SelectedTeam])) {
				try {
					session := this.parseObject(connector.GetSession(identifier))
					
					this.iSessions[session.Name] := session.Identifier
				}
				catch exception {
					; ignore
				}
			}			
		
		sessions := []
		infos := []
		
		for name, identifier in this.Sessions {
			stints := string2Values(";", connector.GetSessionStints(identifier)).Length()
			laps := 0
			
			if (stints > 0) {
				stint := this.parseObject(connector.GetStint(connector.GetSessionStint(identifier)))
				
				laps := (stint.Lap + (string2Values(";", connector.GetSessionStints(stint.Identifier)).Length()))
			}
				
			sessions.Push(name)
			infos.Push(name . translate(" (") . stints . translate(" stints, ") . laps . translate(" laps)"))
		}
		
		GuiControl, , sessionListBox, % ("|" . values2String("|", infos*))
		
		this.selectSession((sessions.Length() > 0) ? sessions[1] : false)
	}
	
	selectTeam(team) {
		this.iSelectedTeam := team
		
		window := this.Editor.Window
		
		Gui %window%:Default
		
		teams := []
		
		for name, ignore in this.Teams
			teams.Push(name)
		
		GuiControl Choose, teamDropDownList, % inList(teams, team)
		
		this.loadDrivers()
		this.loadSessions()
	}
	
	selectDriver(driver) {
		this.iSelectedDriver := driver
		
		window := this.Editor.Window
		
		Gui %window%:Default
		
		drivers := []
		
		for name, ignore in this.Drivers
			drivers.Push(name)
		
		GuiControl Choose, driverListBox, % inList(drivers, driver)
		
		this.updateState()
	}
	
	selectSession(session) {
		this.iSelectedSession := session
		
		window := this.Editor.Window
		
		Gui %window%:Default
		
		sessions := []
		
		for name, ignore in this.Sessions
			sessions.Push(name)
		
		GuiControl Choose, sessionListBox, % inList(sessions, session)
		
		this.updateState()
	}
	
	addTeam(name) {
		identifier := this.Connector.CreateTeam(name)
		
		teams := this.Teams
		
		teams[name] := identifier
		
		this.loadTeams()
		this.selectTeam(name)
	}
	
	renameTeam(oldName, newName) {
		identifier := this.Teams[oldName]
		
		this.Connector.UpdateTeam(this.Teams[oldName], "Name=" . newName)
		
		this.loadTeams()
		this.selectTeam(newName)
	}
	
	deleteTeam(name) {
		this.Connector.DeleteTeam(this.Teams[name])
		
		this.loadTeams()
	}
	
	normalizeDriverName(name) {
		parts := string2Values(A_Space, name)
		
		forName := ""
		surName := ""
		nickName := ""
		
		if (parts.Length() > 0)
			forName := parts[1]
		
		if (parts.Length() > 1)
			surName := parts[2]
		
		if (parts.Length() > 2) {
			parts.RemoveAt(1, 2)
			
			nickName := Trim(StrReplace(StrReplace(values2String(A_Space, parts*), "(", ""), ")", ""))
		}
		else {
			StringUpper initialForName, % SubStr(forName, 1, 1)
			StringUpper initialSurName, % SubStr(surName, 1, 1)
			
			nickName := (initialForName . initialSurName)
		}
		
		nickName := SubStr(nickName, 1, 3)
		
		return (forName . A_Space . surName . A_Space . translate("(") . nickName . translate(")"))
	}
	
	addDriver(name) {
		name := this.normalizeDriverName(name)
		
		parts := string2Values(A_Space, name)
		
		identifier := this.Connector.CreateDriver(this.Teams[this.SelectedTeam], parts[1], parts[2], StrReplace(StrReplace(parts[3], "(", ""), ")", ""))
		
		drivers := this.Drivers
		
		drivers[name] := identifier
		
		this.loadDrivers()
		this.selectDriver(name)
	}
	
	renameDriver(oldName, newName) {
		identifier := this.Drivers[oldName]
		
		newName := this.normalizeDriverName(newName)
		
		parts := string2Values(A_Space, newName)
		
		this.Connector.UpdateDriver(this.Drivers[oldName], "ForName=" . parts[1] . "`n" . "SurName=" . parts[2] . "`n" . "NickName=" . StrReplace(StrReplace(parts[3], "(", ""), ")", ""))
		
		this.loadDrivers()
		this.selectDriver(newName)
	}
	
	deleteDriver(name) {
		this.Connector.DeleteDriver(this.Drivers[name])
		
		this.loadDrivers()
	}
	
	addSession(name) {
		identifier := this.Connector.CreateSession(this.Teams[this.SelectedTeam], name)
		
		sessions := this.Sessions
		
		sessions[name] := identifier
		
		this.loadSessions()
		this.selectSession(name)
	}
	
	renameSession(oldName, newName) {
		identifier := this.Sessions[oldName]
		
		this.Connector.UpdateSession(this.Sessions[oldName], "Name=" . newName)
		
		this.loadSessions()
		this.selectSession(newName)
	}
	
	deleteSession(name) {
		this.Connector.DeleteSession(this.Sessions[name])
		
		this.loadSessions()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

copyURL() {
	GuiControlGet teamServerURLEdit
	
	if (teamServerURLEdit && (teamServerURLEdit != "")) {
		Clipboard := teamServerURLEdit
		
		showMessage(translate("Server URL copied to the clipboard."))
	}
}

renewToken() {
	TeamServerConfigurator.Instance.connect()
}

copyToken() {
	GuiControlGet teamServerTokenEdit
	
	if (teamServerTokenEdit && (teamServerTokenEdit != "")) {
		Clipboard := teamServerTokenEdit
		
		showMessage(translate("Access token copied to the clipboard."))
	}
}

selectTeam() {
	configurator := TeamServerConfigurator.Instance
	
	window := configurator.Editor.Window

	Gui %window%:Default
	
	GuiControlGet teamDropDownList
		
	teams := []
	
	for name, ignore in configurator.Teams
		teams.Push(name)
	
	configurator.selectTeam(teams[teamDropDownList])
}

newTeam() {
	title := translate("Team Server")
	prompt := translate("Please enter the name of the new team:")
	
	configurator := TeamServerConfigurator.Instance
	
	window := configurator.Editor.Window

	Gui %window%:Default
	
	locale := ((getLanguage() = "en") ? "" : "Locale")
	
	InputBox name, %title%, %prompt%, , 300, 200, , , %locale%
	
	if !ErrorLevel
		configurator.addTeam(name)
}

deleteTeam() {
	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
	title := translate("Delete")
	MsgBox 262436, %title%, % translate("Do you really want to delete the selected team?")
	OnMessage(0x44, "")
	
	IfMsgBox Yes
		TeamServerConfigurator.Instance.deleteTeam(TeamServerConfigurator.Instance.SelectedTeam)
}

renameTeam() {
	title := translate("Team Server")
	prompt := translate("Please enter the new name for the selected team:")
	
	configurator := TeamServerConfigurator.Instance
	
	window := configurator.Editor.Window

	Gui %window%:Default
	
	locale := ((getLanguage() = "en") ? "" : "Locale")
	
	InputBox name, %title%, %prompt%, , 300, 200, , , %locale%, , % configurator.SelectedTeam
	
	if !ErrorLevel
		configurator.renameTeam(configurator.SelectedTeam, name)
}

selectDriver() {
	configurator := TeamServerConfigurator.Instance
	
	window := configurator.Editor.Window

	Gui %window%:Default
	
	GuiControlGet driverListBox
		
	drivers := []
	
	for name, ignore in configurator.Drivers
		drivers.Push(name)
	
	configurator.selectDriver(drivers[driverListBox])
}

newDriver() {
	title := translate("Team Server")
	prompt := translate("Please enter the name of the new driver (Format: FirstName LastName (NickName)):")
	
	configurator := TeamServerConfigurator.Instance
	
	window := configurator.Editor.Window

	Gui %window%:Default
	
	locale := ((getLanguage() = "en") ? "" : "Locale")
	
	InputBox name, %title%, %prompt%, , 300, 200, , , %locale%
	
	if !ErrorLevel
		configurator.addDriver(name)
}

deleteDriver() {
	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
	title := translate("Delete")
	MsgBox 262436, %title%, % translate("Do you really want to delete the selected driver?")
	OnMessage(0x44, "")
	
	IfMsgBox Yes
		TeamServerConfigurator.Instance.deleteDriver(TeamServerConfigurator.Instance.SelectedDriver)
}

renameDriver() {
	title := translate("Team Server")
	prompt := translate("Please enter the new name for the selected driver (Format: FirstName LastName (NickName)):")
	
	configurator := TeamServerConfigurator.Instance
	
	window := configurator.Editor.Window

	Gui %window%:Default
	
	locale := ((getLanguage() = "en") ? "" : "Locale")
	
	InputBox name, %title%, %prompt%, , 300, 200, , , %locale%, , % configurator.SelectedDriver
	
	if !ErrorLevel
		configurator.renameDriver(configurator.SelectedDriver, name)
}

selectSession() {
	configurator := TeamServerConfigurator.Instance
	
	window := configurator.Editor.Window

	Gui %window%:Default
	
	GuiControlGet sessionListBox
	
	configurator.selectSession(sessionListBox)
}

newSession() {
	title := translate("Team Server")
	prompt := translate("Please enter the name of the new session:")
	
	configurator := TeamServerConfigurator.Instance
	
	window := configurator.Editor.Window

	Gui %window%:Default
	
	locale := ((getLanguage() = "en") ? "" : "Locale")
	
	InputBox name, %title%, %prompt%, , 300, 200, , , %locale%
	
	if !ErrorLevel
		configurator.addSession(name)
}

renameSession() {
	title := translate("Team Server")
	prompt := translate("Please enter the new name for the selected session:")
	
	configurator := TeamServerConfigurator.Instance
	
	window := configurator.Editor.Window

	Gui %window%:Default
	
	locale := ((getLanguage() = "en") ? "" : "Locale")
	
	InputBox name, %title%, %prompt%, , 300, 200, , , %locale%, , % configurator.SelectedSession
	
	if !ErrorLevel
		configurator.renameSession(configurator.SelectedSession, name)
}

deleteSession() {
	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
	title := translate("Delete")
	MsgBox 262436, %title%, % translate("Do you really want to delete the selected session?")
	OnMessage(0x44, "")
	
	IfMsgBox Yes
		TeamServerConfigurator.Instance.deleteSession(TeamServerConfigurator.Instance.SelectedSession)
}

initializeTeamServerConfigurator() {
	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance
		
		editor.registerConfigurator(translate("Team Server"), new TeamServerConfigurator(editor, editor.Configuration))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeTeamServerConfigurator()