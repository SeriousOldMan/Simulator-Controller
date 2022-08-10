;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Team Server Configuration       ;;;
;;;                                         Plugin                          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\CLR.ahk
#Include ..\Assistants\Libraries\SessionDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; TeamServerConfigurator                                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global teamServerURLEdit := "https://localhost:5001"
global teamServerNameEdit := ""
global teamServerPasswordEdit := ""
global teamServerTokenEdit := ""
global teamServerTimeText := ""

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

global sessionStorePathEdit := ""

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
		local dllName, dllFile

		this.iEditor := editor

		base.__New(configuration)

		dllName := "Team Server Connector.dll"
		dllFile := kBinariesDirectory . dllName

		try {
			if (!FileExist(dllFile)) {
				logMessage(kLogCritical, translate("Team Server Connector.dll not found in ") . kBinariesDirectory)

				throw "Unable to find Team Server Connector.dll in " . kBinariesDirectory . "..."
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
		local window := editor.Window
		local x0, x1, w1, w2, x2, w4, x4, w3, x3, x5, w5, x6, x7, lineX, lineW

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

		x5 := x3 + w3 + 2
		w5 := w3 - 25

		Gui %window%:Add, Text, x%x0% y%y% w160 h23 +0x200 HWNDwidget31 Hidden, % translate("Local Session Folder")
		Gui %window%:Add, Edit, x%x1% yp w%w4% h21 VsessionStorePathEdit HWNDwidget32 Hidden, %sessionStorePathEdit%
		Gui %window%:Add, Button, x%x4% yp-1 w23 h23 gchooseSessionStorePath HWNDwidget33 Hidden, % translate("...")

		lineX := x + 20
		lineW := width - 40

		Gui %window%:Add, Text, x%lineX% yp+30 w%lineW% 0x10 HWNDwidget30 Hidden

		Gui %window%:Add, Text, x%x0% yp+10 w90 h23 +0x200 HWNDwidget1 Hidden, % translate("Server URL")
		Gui %window%:Add, Edit, x%x1% yp+1 w%w4% h21 VteamServerURLEdit HWNDwidget2 Hidden, %teamServerURLEdit%
		Gui %window%:Add, Button, x%x4% yp-1 w23 h23 Center +0x200 gcopyURL HWNDwidget26 Hidden
		setButtonIcon(widget26, kIconsDirectory . "Copy.ico", 1, "L4 T4 R4 B4")

		Gui %window%:Add, Text, x%x0% yp+23 w90 h23 +0x200 HWNDwidget3 Hidden, % translate("Login Credentials")
		Gui %window%:Add, Edit, x%x1% yp+1 w%w3% h21 VteamServerNameEdit HWNDwidget4 Hidden, %teamServerNameEdit%
		Gui %window%:Add, Edit, x%x3% yp w%w3% h21 Password VteamServerPasswordEdit HWNDwidget5 Hidden, %teamServerPasswordEdit%
		Gui %window%:Add, Button, x%x5% yp-1 w23 h23 Center +0x200 gchangePassword HWNDwidget29 Hidden
		setButtonIcon(widget29, kIconsDirectory . "Pencil.ico", 1, "L4 T4 R4 B4")

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

		loop 33
			editor.registerWidget(this, widget%A_Index%)

		this.updateState()
	}

	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)

		if FileExist(kUserConfigDirectory . "Team Server.ini")
			configuration := readConfiguration(kUserConfigDirectory . "Team Server.ini")

		teamServerURLEdit := getConfigurationValue(configuration, "Team Server", "Server.URL", "https://localhost:5001")
		teamServerNameEdit := getConfigurationValue(configuration, "Team Server", "Account.Name", "")
		teamServerPasswordEdit := getConfigurationValue(configuration, "Team Server", "Account.Password", "")
		teamServerTokenEdit := getConfigurationValue(configuration, "Team Server", "Server.Token", "")

		sessionStorePathEdit := getConfigurationValue(configuration, "Team Server", "Session.Folder", "")

		if !teamServerTokenEdit
			teamServerTokenEdit := ""
	}

	saveToConfiguration(configuration) {
		local window := this.Editor.Window
		local tsConfiguration

		base.saveToConfiguration(configuration)

		Gui %window%:Default

		GuiControlGet teamServerURLEdit
		GuiControlGet teamServerNameEdit
		GuiControlGet teamServerPasswordEdit
		GuiControlGet teamServerTokenEdit
		GuiControlGet sessionStorePathEdit

		setConfigurationValue(configuration, "Team Server", "Server.URL", teamServerURLEdit)
		setConfigurationValue(configuration, "Team Server", "Server.Token", teamServerTokenEdit)
		setConfigurationValue(configuration, "Team Server", "Account.Name", teamServerNameEdit)
		setConfigurationValue(configuration, "Team Server", "Account.Password", teamServerPasswordEdit)

		setConfigurationValue(configuration, "Team Server", "Session.Folder", sessionStorePathEdit)

		tsConfiguration := newConfiguration()

		setConfigurationSectionValues(tsConfiguration, "Team Server", getConfigurationSectionValues(configuration, "Team Server"))

		writeConfiguration(kUserConfigDirectory . "Team Server.ini", tsConfiguration)
	}

	activate() {
		local window

		if !this.Token {
			window := this.Editor.Window

			Gui %window%:+Disabled

			try {
				this.connect()
			}
			finally {
				Gui %window%:-Disabled
			}
		}
	}

	connect(message := true) {
		local connector := this.Connector
		local window := this.Editor.Window
		local token, availableMinutes, title

		Gui %window%:Default

		GuiControlGet teamServerURLEdit
		GuiControlGet teamServerNameEdit
		GuiControlGet teamServerPasswordEdit

		if ((teamServerURLEdit != "") && (teamServerNameEdit != "") && (teamServerPasswordEdit != ""))
			try {
				connector.Connect(teamServerURLEdit)

				token := connector.Login(teamServerNameEdit, teamServerPasswordEdit)

				this.iToken := token

				availableMinutes := connector.GetAvailableMinutes()

				teamServerTokenEdit := token
				teamServerTimeText := (availableMinutes . translate(" Minutes"))

				GuiControl Text, teamServerTokenEdit, %teamServerTokenEdit%
				GuiControl +cBlack, teamServerTimeText
				GuiControl Text, teamServerTimeText, %teamServerTimeText%

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

				this.iToken := false
			}
		else
			this.iToken := false

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
		local result := {}
		local property

		properties := StrReplace(properties, "`r", "")

		loop Parse, properties, `n
		{
			property := string2Values("=", A_LoopField)

			result[property[1]] := property[2]
		}

		return result
	}

	loadTeams() {
		local window := this.Editor.Window
		local connector := this.Connector
		local identifiers, ignore, identifier, team, teams, name

		this.iTeams := {}

		if this.Token {
			try {
				identifiers := string2Values(";", connector.GetAllTeams())
			}
			catch exception {
				identifiers := []
			}

			for ignore, identifier in identifiers
				try {
					team := this.parseObject(connector.GetTeam(identifier))

					this.iTeams[team.Name] := team.Identifier
				}
				catch exception {
					; ignore
				}
		}

		Gui %window%:Default

		teams := []

		for name, ignore in this.Teams
			teams.Push(name)

		GuiControl, , teamDropDownList, % ("|" . values2String("|", teams*))

		this.SelectTeam(((teams.Length() > 0) ? teams[1] : false))
	}

	loadDrivers() {
		local window := this.Editor.Window
		local connector := this.Connector
		local identifiers, ignore, identifier, drivers, driver, name

		Gui %window%:Default

		GuiControl, , driverListBox, |

		this.iDrivers := {}

		if this.SelectedTeam {
			try {
				identifiers := string2Values(";", connector.GetTeamDrivers(this.Teams[this.SelectedTeam]))
			}
			catch exception {
				identifiers := []
			}

			for ignore, identifier in identifiers {
				try {
					driver := this.parseObject(connector.GetDriver(identifier))

					name := computeDriverName(driver.ForName, driver.SurName, driver.NickName)

					this.iDrivers[name] := driver.Identifier
				}
				catch exception {
					; ignore
				}
			}
		}

		drivers := []

		for name, ignore in this.Drivers
			drivers.Push(name)

		GuiControl, , driverListBox, % ("|" . values2String("|", drivers*))

		this.selectDriver((drivers.Length() > 0) ? drivers[1] : false)
	}

	loadSessions() {
		local window := this.Editor.Window
		local connector := this.Connector
		local identifiers, ignore, identifier, session, sessions, infos, name, stints, laps

		Gui %window%:Default

		GuiControl, , sessionListBox, |

		this.iSessions := {}

		if this.SelectedTeam {
			try {
				identifiers := string2Values(";", connector.GetTeamSessions(this.Teams[this.SelectedTeam]))
			}
			catch exception {
				identifiers := []
			}

			for ignore, identifier in identifiers {
				try {
					session := this.parseObject(connector.GetSession(identifier))

					this.iSessions[session.Name] := session.Identifier
				}
				catch exception {
					; ignore
				}
			}
		}

		sessions := []
		infos := []

		for name, identifier in this.Sessions {
			try {
				stints := string2Values(";", connector.GetSessionStints(identifier)).Length()
			}
			catch exception {
				stints := 0
			}

			laps := 0

			if (stints > 0)
				try {
					laps := this.parseObject(connector.GetLap(connector.GetSessionLastLap(identifier))).Nr
				}
				catch exception {
					; ignore
				}

			sessions.Push(name)
			infos.Push(name . translate(" (") . stints . translate(" stints, ") . laps . translate(" laps)"))
		}

		GuiControl, , sessionListBox, % ("|" . values2String("|", infos*))

		this.selectSession((sessions.Length() > 0) ? sessions[1] : false)
	}

	selectTeam(team) {
		local window := this.Editor.Window
		local teams, name, ignore

		this.iSelectedTeam := team

		Gui %window%:Default

		teams := []

		for name, ignore in this.Teams
			teams.Push(name)

		GuiControl Choose, teamDropDownList, % inList(teams, team)

		this.loadDrivers()
		this.loadSessions()
	}

	selectDriver(driver) {
		local window := this.Editor.Window
		local drivers, name, ignore

		this.iSelectedDriver := driver

		Gui %window%:Default

		drivers := []

		for name, ignore in this.Drivers
			drivers.Push(name)

		GuiControl Choose, driverListBox, % inList(drivers, driver)

		this.updateState()
	}

	selectSession(session) {
		local window := this.Editor.Window
		local sessions, name, ignore

		this.iSelectedSession := session

		Gui %window%:Default

		sessions := []

		for name, ignore in this.Sessions
			sessions.Push(name)

		GuiControl Choose, sessionListBox, % inList(sessions, session)

		this.updateState()
	}

	addTeam(name) {
		local identifier := this.Connector.CreateTeam(name)
		local teams := this.Teams

		teams[name] := identifier

		this.loadTeams()
		this.selectTeam(name)
	}

	renameTeam(oldName, newName) {
		local identifier := this.Teams[oldName]

		this.Connector.UpdateTeam(this.Teams[oldName], "Name=" . newName)

		this.loadTeams()
		this.selectTeam(newName)
	}

	deleteTeam(name) {
		local window := this.Editor.Window

		Gui %window%:+Disabled

		try {
			this.Connector.DeleteTeam(this.Teams[name])
		}
		finally {
			Gui %window%:-Disabled
		}

		this.loadTeams()
	}

	normalizeDriverName(name) {
		local forName := ""
		local surName := ""
		local nickName := ""

		parseDriverName(name, forName, surName, nickName)

		if (nickName = "") {
			StringUpper initialForName, % SubStr(forName, 1, 1)
			StringUpper initialSurName, % SubStr(surName, 1, 1)

			nickName := (initialForName . initialSurName)
		}

		nickName := SubStr(nickName, 1, 3)

		return computeDriverName(forName, surName, nickName)
	}

	addDriver(name) {
		local forName := ""
		local surName := ""
		local nickName := ""
		local identifier, drivers

		name := this.normalizeDriverName(name)

		parseDriverName(name, forName, surName, nickName)

		identifier := this.Connector.CreateDriver(this.Teams[this.SelectedTeam], forName, surName, nickName)

		drivers := this.Drivers

		drivers[name] := identifier

		this.loadDrivers()
		this.selectDriver(name)
	}

	renameDriver(oldName, newName) {
		local identifier := this.Drivers[oldName]
		local parts

		newName := this.normalizeDriverName(newName)

		parts := string2Values(A_Space, newName)

		this.Connector.UpdateDriver(this.Drivers[oldName], "ForName=" . parts[1] . "`n" . "SurName=" . parts[2] . "`n" . "NickName=" . StrReplace(StrReplace(parts[3], "(", ""), ")", ""))

		this.loadDrivers()
		this.selectDriver(newName)
	}

	deleteDriver(name) {
		local window := this.Editor.Window

		Gui %window%:+Disabled

		try {
			this.Connector.DeleteDriver(this.Drivers[name])
		}
		finally {
			Gui %window%:-Disabled
		}

		this.loadDrivers()
	}

	addSession(name) {
		local identifier := this.Connector.CreateSession(this.Teams[this.SelectedTeam], name)
		local sessions := this.Sessions

		sessions[name] := identifier

		this.loadSessions()
		this.selectSession(name)
	}

	renameSession(oldName, newName) {
		local identifier := this.Sessions[oldName]

		this.Connector.UpdateSession(this.Sessions[oldName], "Name=" . newName)

		this.loadSessions()
		this.selectSession(newName)
	}

	deleteSession(name) {
		local window := this.Editor.Window

		Gui %window%:+Disabled

		try {
			this.Connector.DeleteSession(this.Sessions[name])
		}
		finally {
			Gui %window%:-Disabled
		}

		this.loadSessions()
	}

	withExceptionHandler(function, arguments*) {
		local title

		try {
			return %function%(arguments*)
		}
		catch exception {
			title := translate("Error")

			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			MsgBox 262160, %title%, % (translate("Error while executing command.") . "`n`n" . translate("Error: ") . exception.Message)
			OnMessage(0x44, "")
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

chooseSessionStorePath() {
	local directory


	GuiControlGet sessionStorePathEdit

	Gui +OwnDialogs

	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Select", "Select", "Cancel"]))
	FileSelectFolder directory, *%sessionStorePathEdit%, 0, % translate("Select local Session Folder...")
	OnMessage(0x44, "")

	if (directory != "")
		GuiControl Text, sessionStorePathEdit, %directory%
}

copyURL() {
	GuiControlGet teamServerURLEdit

	if (teamServerURLEdit && (teamServerURLEdit != "")) {
		Clipboard := teamServerURLEdit

		showMessage(translate("Server URL copied to the clipboard."))
	}
}

changePassword() {
	local configurator := TeamServerConfigurator.Instance
	local errorTitle := translate("Error")
	local title, errorTitle, prompt, window, locale, password, firstPassword, secondPassword

	if configurator.Token {
		title := translate("Team Server")
		prompt := translate("Please enter your current password:")

		window := configurator.Editor.Window

		Gui %window%:Default

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

		try {
			configurator.Connector.ChangePassword(firstPassword)

			GuiControl, , teamServerPasswordEdit, % firstPassword
		}
		catch exception {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			MsgBox 262160, %errorTitle%, % (translate("Error while executing command.") . "`n`n" . translate("Error: ") . exception.Message)
			OnMessage(0x44, "")
		}
	}
	else {
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
		MsgBox 262160, %errorTitle%, % translate("You must be connected to the Server to change your password.")
		OnMessage(0x44, "")
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
	local configurator := TeamServerConfigurator.Instance
	local window := configurator.Editor.Window
	local teams, name, ignore

	Gui %window%:Default

	GuiControlGet teamDropDownList

	teams := []

	for name, ignore in configurator.Teams
		teams.Push(name)

	configurator.selectTeam(teams[teamDropDownList])
}

newTeam() {
	local title := translate("Team Server")
	local prompt := translate("Please enter the name of the new team:")
	local configurator := TeamServerConfigurator.Instance
	local window := configurator.Editor.Window
	local locale, name

	Gui %window%:Default

	locale := ((getLanguage() = "en") ? "" : "Locale")

	InputBox name, %title%, %prompt%, , 300, 200, , , %locale%

	if !ErrorLevel
		configurator.withExceptionHandler(ObjBindMethod(configurator, "addTeam"), name)
}

deleteTeam() {
	local configurator := TeamServerConfigurator.Instance
	local title := translate("Delete")

	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
	MsgBox 262436, %title%, % translate("Do you really want to delete the selected team?")
	OnMessage(0x44, "")

	IfMsgBox Yes
		configurator.withExceptionHandler(ObjBindMethod(configurator, "deleteTeam"), TeamServerConfigurator.Instance.SelectedTeam)
}

renameTeam() {
	local title := translate("Team Server")
	local prompt := translate("Please enter the new name for the selected team:")
	local configurator := TeamServerConfigurator.Instance
	local window := configurator.Editor.Window
	local locale, name

	Gui %window%:Default

	locale := ((getLanguage() = "en") ? "" : "Locale")

	InputBox name, %title%, %prompt%, , 300, 200, , , %locale%, , % configurator.SelectedTeam

	if !ErrorLevel
		configurator.withExceptionHandler(ObjBindMethod(configurator, "renameTeam"), configurator.SelectedTeam, name)
}

selectDriver() {
	local configurator := TeamServerConfigurator.Instance
	local window := configurator.Editor.Window
	local drivers, name, ignore

	Gui %window%:Default

	GuiControlGet driverListBox

	drivers := []

	for name, ignore in configurator.Drivers
		drivers.Push(name)

	configurator.withExceptionHandler(ObjBindMethod(configurator, "selectDriver"), drivers[driverListBox])
}

newDriver() {
	local title := translate("Team Server")
	local prompt := translate("Please enter the name of the new driver (Format: FirstName LastName (NickName)):")
	local configurator := TeamServerConfigurator.Instance
	local window := configurator.Editor.Window
	local locale, name

	Gui %window%:Default

	locale := ((getLanguage() = "en") ? "" : "Locale")

	InputBox name, %title%, %prompt%, , 300, 200, , , %locale%

	if !ErrorLevel
		configurator.withExceptionHandler(ObjBindMethod(configurator, "addDriver"), name)
}

deleteDriver() {
	local configurator := TeamServerConfigurator.Instance
	local title := translate("Delete")

	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
	MsgBox 262436, %title%, % translate("Do you really want to delete the selected driver?")
	OnMessage(0x44, "")

	IfMsgBox Yes
		configurator.withExceptionHandler(ObjBindMethod(configurator, "deleteDriver"), TeamServerConfigurator.Instance.SelectedDriver)
}

renameDriver() {
	local title := translate("Team Server")
	local prompt := translate("Please enter the new name for the selected driver (Format: FirstName LastName (NickName)):")
	local configurator := TeamServerConfigurator.Instance
	local window := configurator.Editor.Window
	local locale, name

	Gui %window%:Default

	locale := ((getLanguage() = "en") ? "" : "Locale")

	InputBox name, %title%, %prompt%, , 300, 200, , , %locale%, , % configurator.SelectedDriver

	if !ErrorLevel
		configurator.withExceptionHandler(ObjBindMethod(configurator, "renameDriver"), configurator.SelectedDriver, name)
}

selectSession() {
	local configurator := TeamServerConfigurator.Instance
	local window := configurator.Editor.Window
	local sessions, name, ignore

	Gui %window%:Default

	GuiControlGet sessionListBox

	sessions := []

	for name, ignore in configurator.Sessions
		sessions.Push(name)

	configurator.withExceptionHandler(ObjBindMethod(configurator, "selectSession"), sessions[sessionListBox])
}

newSession() {
	local title := translate("Team Server")
	local prompt := translate("Please enter the name of the new session:")
	local configurator := TeamServerConfigurator.Instance
	local window := configurator.Editor.Window
	local locale, name

	Gui %window%:Default

	locale := ((getLanguage() = "en") ? "" : "Locale")

	InputBox name, %title%, %prompt%, , 300, 200, , , %locale%

	if !ErrorLevel
		configurator.withExceptionHandler(ObjBindMethod(configurator, "addSession"), name)
}

renameSession() {
	local title := translate("Team Server")
	local prompt := translate("Please enter the new name for the selected session:")
	local configurator := TeamServerConfigurator.Instance
	local window := configurator.Editor.Window
	local locale, name

	Gui %window%:Default

	locale := ((getLanguage() = "en") ? "" : "Locale")

	InputBox name, %title%, %prompt%, , 300, 200, , , %locale%, , % configurator.SelectedSession

	if !ErrorLevel
		configurator.withExceptionHandler(ObjBindMethod(configurator, "renameSession"), configurator.SelectedSession, name)
}

deleteSession() {
	local configurator := TeamServerConfigurator.Instance
	local title := translate("Delete")

	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
	MsgBox 262436, %title%, % translate("Do you really want to delete the selected session?")
	OnMessage(0x44, "")

	IfMsgBox Yes
		configurator.withExceptionHandler(ObjBindMethod(configurator, "deleteSession"), TeamServerConfigurator.Instance.SelectedSession)
}

initializeTeamServerConfigurator() {
	local editor

	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance

		editor.registerConfigurator(translate("Team Server"), new TeamServerConfigurator(editor, editor.Configuration))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeTeamServerConfigurator()