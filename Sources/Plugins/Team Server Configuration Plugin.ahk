;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Team Server Configuration       ;;;
;;;                                         Plugin                          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\CLR.ahk"
#Include "..\Libraries\Task.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; TeamServerConfigurator                                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class TeamServerConfigurator extends ConfiguratorPanel {
	iConnector := false
	iToken := false
	iInitialized := false

	iTeams := CaseInsenseMap()
	iSelectedTeam := false

	iDrivers := CaseInsenseMap()
	iSelectedDriver := false

	iSessions := CaseInsenseMap()
	iSelectedSession := false

	Connector {
		Get {
			return this.iConnector
		}
	}

	Token {
		Get {
			return this.iToken
		}
	}

	Initialized {
		Get {
			return this.iInitialized
		}
	}

	Teams[key?] {
		Get {
			return (isSet(key) ? this.iTeams[key] : this.iTeams)
		}
	}

	SelectedTeam {
		Get {
			return this.iSelectedTeam
		}
	}

	Drivers[key?] {
		Get {
			return (isSet(key) ? this.iDrivers[key] : this.iDrivers)
		}
	}

	SelectedDriver {
		Get {
			return this.iSelectedDriver
		}
	}

	Sessions[key?] {
		Get {
			return (isSet(key) ? this.iSessions[key] : this.iSessions)
		}
	}

	SelectedSession {
		Get {
			return this.iSelectedSession
		}
	}

	__New(editor, configuration := false) {
		local dllName, dllFile

		this.Editor := editor

		super.__New(configuration)

		dllName := "Team Server Connector.dll"
		dllFile := kBinariesDirectory . dllName

		try {
			if (!FileExist(dllFile)) {
				logMessage(kLogCritical, translate("Team Server Connector.dll not found in ") . kBinariesDirectory)

				throw "Unable to find Team Server Connector.dll in " . kBinariesDirectory . "..."
			}

			this.iConnector := CLR_LoadLibrary(dllFile).CreateInstance("TeamServer.TeamServerConnector")
		}
		catch Any as exception {
			logMessage(kLogCritical, translate("Error while initializing Team Server Connector - please rebuild the applications"))

			showMessage(translate("Error while initializing Team Server Connector - please rebuild the applications") . translate("...")
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}

		TeamServerConfigurator.Instance := this
	}

	createGui(editor, x, y, width, height) {
		local window := editor.Window
		local x0, x1, w1, w2, x2, w4, x4, w3, x3, x5, w5, x6, x7, lineX, lineW
		local settings, serverURLs, choosen

		chooseSessionStorePath(*) {
			local directory, translator

			window.Opt("+OwnDialogs")

			translator := translateMsgBoxButtons.Bind(["Select", "Select", "Cancel"])

			OnMessage(0x44, translator)
			directory := DirSelect("*" window["sessionStorePathEdit"].Text, 0, translate("Select local Session Folder..."))
			OnMessage(0x44, translator, 0)

			if (directory != "")
				window["sessionStorePathEdit"].Text := directory
		}

		copyURL(*) {
			if (Trim(window["teamServerURLEdit"].Text) != "") {
				A_Clipboard := Trim(window["teamServerURLEdit"].Text)

				showMessage(translate("Server URL copied to the clipboard."))
			}
		}

		changePassword(*) {
			local result, password, firstPassword, secondPassword

			errorMessage(message) {
				OnMessage(0x44, translateOkButton)
				MsgBox(message, translate("Error"), 262160)
				OnMessage(0x44, translateOkButton, 0)
			}

			if this.Token {
				window.Opt("+OwnDialogs")

				result := InputBox(translate("Please enter your current password:"), translate("Team Server"), "Password w200 h150")

				password := this.Control["teamServerPasswordEdit"].Text

				if (result.Result != "Ok")
					return
				else if (password != result.Value) {
					errorMessage(translate("Invalid password."))

					return
				}

				result := InputBox(translate("Please enter your new password:"), translate("Team Server"), "Password w200 h150")

				if (result.Result != "Ok")
					return
				else
					firstPassword := result.Value

				result := InputBox(translate("Please re-enter your new password:"), translate("Team Server"), "Password w200 h150")

				if (result.Result != "Ok")
					return
				else
					secondPassword := result.Value

				if (firstPassword != secondPassword) {
					errorMessage(translate("The passwords do not match."))

					return
				}

				try {
					this.Connector.ChangePassword(firstPassword)

					window["teamServerPasswordEdit"].Text := firstPassword
				}
				catch Any as exception {
					errorMessage(translate("Error while executing command.") . "`n`n" . translate("Error: ") . exception.Message)
				}
			}
			else {
				OnMessage(0x44, translateOkButton)
				MsgBox(translate("You must be connected to the Server to change your password."), translate("Error"), 262160)
				OnMessage(0x44, translateOkButton, 0)
			}
		}

		teamServerLogin(*) {
			this.connect()
		}

		copySessionToken(*) {
			if (Trim(window["teamServerSessionTokenEdit"].Text) != "") {
				A_Clipboard := Trim(window["teamServerSessionTokenEdit"].Text)

				showMessage(translate("Token copied to the clipboard."))
			}
		}

		copyDataToken(*) {
			if (Trim(window["teamServerDataTokenEdit"].Text) != "") {
				A_Clipboard := Trim(window["teamServerDataTokenEdit"].Text)

				showMessage(translate("Token copied to the clipboard."))
			}
		}

		renewDataToken(*) {
			local msgResult

			OnMessage(0x44, translateYesNoButtons)
			msgResult := MsgBox(translate("Do you really want to renew the data token? The current token will become invalid for all users."), translate("Renew"), 262436)
			OnMessage(0x44, translateYesNoButtons, 0)

			if (msgResult = "Yes")
				this.renewDataToken()
		}

		selectTeam(*) {
			local teams := []
			local name, ignore

			for name, ignore in this.Teams
				teams.Push(name)

			this.selectTeam(teams[window["teamDropDownList"].Value])
		}

		newTeam(*) {
			local result := InputBox(translate("Please enter the name of the new team:"), translate("Team Server"), "w300 h200")

			if ((result.Result = "Ok") && (StrLen(Trim(result.Value)) > 0))
				this.withExceptionHandler(ObjBindMethod(this, "addTeam"), Trim(result.Value))
		}

		deleteTeam(*) {
			local msgResult

			OnMessage(0x44, translateYesNoButtons)
			msgResult := MsgBox(translate("Do you really want to delete the selected team?"), translate("Delete"), 262436)
			OnMessage(0x44, translateYesNoButtons, 0)

			if (msgResult = "Yes")
				this.withExceptionHandler(ObjBindMethod(this, "deleteTeam"), this.SelectedTeam)
		}

		renameTeam(*) {
			local result := InputBox(translate("Please enter the new name for the selected team:"), translate("Team Server"), "w300 h200", this.SelectedTeam)

			if ((result.Result = "Ok") && (StrLen(Trim(result.Value)) > 0))
				this.withExceptionHandler(ObjBindMethod(this, "renameTeam"), this.SelectedTeam, Trim(result.Value))
		}

		selectDriver(*) {
			local drivers := []
			local name, ignore

			for name, ignore in this.Drivers
				drivers.Push(name)

			this.withExceptionHandler(ObjBindMethod(this, "selectDriver"), drivers[window["driverListBox"].Value])
		}

		newDriver(*) {
			local result := InputBox(translate("Please enter the name of the new driver (Format: FirstName LastName (NickName)):"), translate("Team Server"), "w300 h200")

			if ((result.Result = "Ok") && (StrLen(Trim(result.Value)) > 0))
				this.withExceptionHandler(ObjBindMethod(this, "addDriver"), Trim(result.Value))
		}

		deleteDriver(*) {
			local msgResult

			OnMessage(0x44, translateYesNoButtons)
			msgResult := MsgBox(translate("Do you really want to delete the selected driver?"), translate("Delete"), 262436)
			OnMessage(0x44, translateYesNoButtons, 0)

			if (msgResult = "Yes")
				this.withExceptionHandler(ObjBindMethod(this, "deleteDriver"), this.SelectedDriver)
		}

		renameDriver(*) {
			local result := InputBox(translate("Please enter the new name for the selected driver (Format: FirstName LastName (NickName)):"), translate("Team Server"), "w300 h200", this.SelectedDriver)

			if ((result.Result = "Ok") && (StrLen(Trim(result.Value)) > 0))
				this.withExceptionHandler(ObjBindMethod(this, "renameDriver"), this.SelectedDriver, Trim(result.Value))
		}

		selectSession(*) {
			local sessions := []
			local name, ignore

			for name, ignore in this.Sessions
				sessions.Push(name)

			this.withExceptionHandler(ObjBindMethod(this, "selectSession"), sessions[window["sessionListBox"].Value])
		}

		newSession(*) {
			local result := InputBox(translate("Please enter the name of the new session:"), translate("Team Server"), "w300 h200")

			if ((result.Result = "Ok") && (StrLen(Trim(result.Value)) > 0))
				this.withExceptionHandler(ObjBindMethod(this, "addSession"), Trim(result.Value))
		}

		renameSession(*) {
			local result := InputBox(translate("Please enter the new name for the selected session:"), translate("Team Server"), "w300 h200", this.SelectedSession)

			if ((result.Result = "Ok") && (StrLen(Trim(result.Value)) > 0))
				this.withExceptionHandler(ObjBindMethod(this, "renameSession"), this.SelectedSession, Trim(result.Value))
		}

		deleteSession(*) {
			local msgResult

			OnMessage(0x44, translateYesNoButtons)
			msgResult := MsgBox(translate("Do you really want to delete the selected session?"), translate("Delete"), 262436)
			OnMessage(0x44, translateYesNoButtons, 0)

			if (msgResult = "Yes")
				this.withExceptionHandler(ObjBindMethod(this, "deleteSession"), this.SelectedSession)
		}

		window.SetFont("Norm", "Arial")

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

		widget1 := window.Add("Text", "x" . x0 . " y" . y . " w160 h23 +0x200 Hidden", translate("Local Session Folder"))

		widget2 := window.Add("Edit", "x" . x1 . " yp w" . w4 . " h21 W:Grow VsessionStorePathEdit Hidden", this.Value["sessionStorePath"])

		widget3 := window.Add("Button", "x" . x4 . " yp-1 w23 h23 X:Move Hidden", translate("..."))
		widget3.OnEvent("Click", chooseSessionStorePath)

		lineX := x + 20
		lineW := width - 40

		widget4 := window.Add("Text", "x" . lineX . " yp+30 w" . lineW . " W:Grow 0x10 Hidden")

		settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

		serverURLs := string2Values(";", getMultiMapValue(settings, "Team Server", "Server URLs", ""))

		chosen := inList(serverURLs, this.Value["teamServerURL"])
		if (!chosen && (serverURLs.Length > 0))
			chosen := 1

		widget5 := window.Add("Text", "x" . x0 . " yp+10 w90 h23 +0x200 Hidden", translate("Server URL"))
		widget6 := window.Add("ComboBox", "x" . x1 . " yp+1 w" . w4 . " W:Grow Choose" . chosen . " VteamServerURLEdit Hidden", serverURLs)
		widget7 := window.Add("Button", "x" . x4 . " yp-1 w23 h23 X:Move Center +0x200  Hidden")
		widget7.OnEvent("Click", copyURL)
		setButtonIcon(widget7, kIconsDirectory . "Copy.ico", 1, "L4 T4 R4 B4")

		widget8 := window.Add("Text", "x" . x0 . " yp+23 w90 h23 +0x200 Hidden", translate("Login Credentials"))
		widget9 := window.Add("Edit", "x" . x1 . " yp+1 w" . w3 . " h21 W:Grow(0.5) VteamServerNameEdit Hidden", this.Value["teamServerName"])
		widget10 := window.Add("Edit", "x" . x3 . " yp w" . w3 . " h21 X:Move(0.5) W:Grow(0.5) Password VteamServerPasswordEdit Hidden")
		widget11 := window.Add("Button", "x" . x2 . " yp-1 w23 h23 Center +0x200  Hidden")
		widget11.OnEvent("Click", teamServerLogin)
		setButtonIcon(widget11, kIconsDirectory . "Authorize.ico", 1, "L4 T4 R4 B4")
		widget12 := window.Add("Button", "x" . x5 . " yp-1 w23 h23 X:Move Center +0x200 vchangePasswordButton  Hidden")
		widget12.OnEvent("Click", changePassword)
		setButtonIcon(widget12, kIconsDirectory . "Pencil.ico", 1, "L4 T4 R4 B4")

		widget13 := window.Add("Text", "x" . x0 . " yp+26 w90 h23 +0x200 Hidden", translate("Contingent"))

		widget14 := window.Add("Text", "x" . x1 . " yp+4 w" . w1 . " h21 VteamServerTimeText Hidden c" . this.Window.Theme.TextColor["Disabled"]
							 , translate("Please Login for actual data..."))

		widget15 := window.Add("Text", "x" . x0 . " yp+31 w90 h23 +0x200 Hidden", translate("Session Token"))

		widget16 := window.Add("Edit", "x" . x1 . " yp-1 w" . w4 . " h21 W:Grow ReadOnly VteamServerSessionTokenEdit Hidden", this.Value["teamServerSessionToken"])
		widget17 := window.Add("Button", "x" . x4 . " yp w23 h23 X:Move Center +0x200  Hidden")
		widget17.OnEvent("Click", copySessionToken)
		setButtonIcon(widget17, kIconsDirectory . "Copy.ico", 1, "L4 T4 R4 B4")

		widget18 := window.Add("Text", "x" . x0 . " yp+26 w90 h23 +0x200 Hidden", translate("Data Token"))
		widget19 := window.Add("Edit", "x" . x1 . " yp-1 w" . w4 . " h21 W:Grow ReadOnly VteamServerDataTokenEdit Hidden", this.Value["teamServerDataToken"])
		widget20 := window.Add("Button", "x" . x4 . " yp w23 h23 X:Move Center +0x200  Hidden")
		widget20.OnEvent("Click", copyDataToken)
		setButtonIcon(widget20, kIconsDirectory . "Copy.ico", 1, "L4 T4 R4 B4")
		widget21 := window.Add("Button", "x" . x2 . " yp-1 w23 h23 Center +0x200 vrenewDataTokenButton  Hidden")
		widget21.OnEvent("Click", renewDataToken)
		setButtonIcon(widget21, kIconsDirectory . "Renew.ico", 1, "L4 T4 R4 B4")

		window.SetFont("Norm", "Arial")

		window.SetFont("Italic", "Arial")

		widget22 := window.Add("GroupBox", "x" . x . " yp+36 w" . width . " h214 H:Grow W:Grow Hidden", translate("Teams"))

		window.SetFont("Norm", "Arial")

		x5 := x1 + w3 + 3
		x6 := x5 + 24
		x7 := x6 + 24

		widget23 := window.Add("Text", "x" . x0 . " yp+24 w90 h23 +0x200 Hidden", translate("Team"))
		widget24 := window.Add("DropDownList", "x" . x1 . " yp w" . w3 . " W:Grow(0.5) vteamDropDownList Hidden")
		widget24.OnEvent("Change", selectTeam)
		widget25 := window.Add("Button", "x" . x5 . " yp w23 h23 Center +0x200 X:Move(0.5) vaddTeamButton Hidden")
		widget25.OnEvent("Click", newTeam)
		setButtonIcon(widget25, kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		widget26 := window.Add("Button", "x" . x6 . " yp w23 h23 Center +0x200 X:Move(0.5) vdeleteTeamButton Hidden")
		widget26.OnEvent("Click", deleteTeam)
		setButtonIcon(widget26, kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")
		widget27 := window.Add("Button", "x" . x7 . " yp w23 h23 Center +0x200 X:Move(0.5) veditTeamButton Hidden")
		widget27.OnEvent("Click", renameTeam)
		setButtonIcon(widget27, kIconsDirectory . "Pencil.ico", 1, "L4 T4 R4 B4")

		widget28 := window.Add("Text", "x" . x0 . " yp+26 w90 h23 +0x200 Hidden", translate("Drivers"))

		widget29:= window.Add("ListBox", "x" . x1 . " yp w" . w3 . " h96 AltSubmit H:Grow(0.3) W:Grow(0.5) vdriverListBox Hidden")
		widget29.OnEvent("DoubleClick", selectDriver)

		widget30 := window.Add("Button", "x" . x5 . " yp w23 h23 Center +0x200 X:Move(0.5) vaddDriverButton Hidden")
		widget30.OnEvent("Click", newDriver)
		setButtonIcon(widget30, kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		widget31 := window.Add("Button", "x" . x6 . " yp w23 h23 Center +0x200 X:Move(0.5) vdeleteDriverButton Hidden")
		widget31.OnEvent("Click", deleteDriver)
		setButtonIcon(widget31, kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")
		widget32 := window.Add("Button", "x" . x7 . " yp w23 h23 Center +0x200 X:Move(0.5) veditDriverButton Hidden")
		widget32.OnEvent("Click", renameDriver)
		setButtonIcon(widget32, kIconsDirectory . "Pencil.ico", 1, "L4 T4 R4 B4")

		widget33 := window.Add("Text", "x" . x0 . " yp+92 w90 h23 Y:Move(0.3) +0x200 Hidden", translate("Sessions"))

		widget34 := window.Add("ListBox", "x" . x1 . " yp w" . w3 . " h72 AltSubmit Y:Move(0.3) H:Grow(0.7) W:Grow(0.5) vsessionListBox Hidden")
		widget34.OnEvent("DoubleClick", selectSession)

		widget35 := window.Add("Button", "x" . x5 . " yp w23 h23 Center +0x200 X:Move(0.5) Y:Move(0.3) vaddSessionButton Hidden")
		widget35.OnEvent("Click", newSession)
		setButtonIcon(widget35, kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		widget36 := window.Add("Button", "x" . x6 . " yp w23 h23 Center +0x200 X:Move(0.5) Y:Move(0.3) vdeleteSessionButton Hidden")
		widget36.OnEvent("Click", deleteSession)
		setButtonIcon(widget36, kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")
		widget37 := window.Add("Button", "x" . x7 . " yp w23 h23 Center +0x200 X:Move(0.5) Y:Move(0.3) veditSessionButton Hidden")
		widget37.OnEvent("Click", renameSession)
		setButtonIcon(widget37, kIconsDirectory . "Pencil.ico", 1, "L4 T4 R4 B4")

		loop 37
			editor.registerWidget(this, widget%A_Index%)

		this.updateState()
	}

	loadFromConfiguration(configuration) {
		super.loadFromConfiguration(configuration)

		if FileExist(kUserConfigDirectory . "Team Server.ini")
			configuration := readMultiMap(kUserConfigDirectory . "Team Server.ini")

		this.Value["teamServerURL"] := getMultiMapValue(configuration, "Team Server", "Server.URL", "https://localhost:5001")
		this.Value["teamServerName"] := getMultiMapValue(configuration, "Team Server", "Account.Name", "")
		this.iToken := getMultiMapValue(configuration, "Team Server", "Account.Token", "")
		this.Value["teamServerSessionToken"] := getMultiMapValue(configuration, "Team Server", "Session.Token", "")
		this.Value["teamServerDataToken"] := getMultiMapValue(configuration, "Team Server", "Data.Token", "")

		this.Value["sessionStorePath"] := getMultiMapValue(configuration, "Team Server", "Session.Folder", "")

		if !this.Value["teamServerSessionToken"]
			this.Value["teamServerSessionToken"] := ""

		if !this.Value["teamServerDataToken"]
			this.Value["teamServerDataToken"] := ""
	}

	saveToConfiguration(configuration) {
		local tsConfiguration

		super.saveToConfiguration(configuration)

		setMultiMapValue(configuration, "Team Server", "Server.URL", this.Control["teamServerURLEdit"].Text)
		setMultiMapValue(configuration, "Team Server", "Session.Token", this.Control["teamServerSessionTokenEdit"].Text)
		setMultiMapValue(configuration, "Team Server", "Data.Token", this.Control["teamServerDataTokenEdit"].Text)
		setMultiMapValue(configuration, "Team Server", "Account.Name", this.Control["teamServerNameEdit"].Text)
		setMultiMapValue(configuration, "Team Server", "Account.Token", this.Token)

		setMultiMapValue(configuration, "Team Server", "Session.Folder", this.Control["sessionStorePathEdit"].Text)

		tsConfiguration := newMultiMap()

		setMultiMapValues(tsConfiguration, "Team Server", getMultiMapValues(configuration, "Team Server"))

		writeMultiMap(kUserConfigDirectory . "Team Server.ini", tsConfiguration)
	}

	activate() {
		if !this.Initialized {
			this.iInitialized := true

			this.Window.Block()

			try {
				this.connect(true, true)
			}
			finally {
				this.Window.Unblock()
			}
		}
	}

	connect(message := true, reconnect := false) {
		local connector := this.Connector
		local token, availableMinutes, connection
		local settings, serverURLs, chosen

		static keepAliveTask := false

		if ((Trim(this.Control["teamServerURLEdit"].Text) != "") && (Trim(this.Control["teamServerNameEdit"].Text) != "")) {
			try {
				connector.Initialize(Trim(this.Control["teamServerURLEdit"].Text))

				if (this.Token && (this.Token != "") && reconnect) {
					connector.Token := this.Token

					token := this.Token
				}
				else {
					token := connector.Login(Trim(this.Control["teamServerNameEdit"].Text), this.Control["teamServerPasswordEdit"].Text)

					this.iToken := token
				}

				connection := connector.Connect(token, SessionDatabase.ID, SessionDatabase.getUserName(), "Manager")

				if keepAliveTask
					keepAliveTask.stop()

				keepAliveTask := PeriodicTask(ObjBindMethod(connector, "KeepAlive", connection), 120000, kLowPriority)

				keepAliveTask.start()

				availableMinutes := connector.GetAvailableMinutes()

				this.Control["teamServerTimeText"].Text := (availableMinutes . translate(" Minutes"))
				this.Control["teamServerTimeText"].Opt("+c" . this.Window.Theme.TextColor["Normal"])

				try {
					this.Control["teamServerSessionTokenEdit"].Text := connector.GetSessionToken()
				}
				catch Any as exception {
					this.Control["teamServerSessionTokenEdit"].Text := ""
				}

				try {
					this.Control["teamServerDataTokenEdit"].Text := connector.GetDataToken()
				}
				catch Any as exception {
					this.Control["teamServerDataTokenEdit"].Text := ""
				}

				settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

				serverURLs := string2Values(";", getMultiMapValue(settings, "Team Server", "Server URLs", ""))

				if !inList(serverURLs, this.Control["teamServerURLEdit"].Text) {
					serverURLs.Push(this.Control["teamServerURLEdit"].Text)

					setMultiMapValue(settings, "Team Server", "Server URLs", values2String(";", serverURLs*))

					writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)

					this.Control["teamServerURLEdit"].Delete
					this.Control["teamServerURLEdit"].Add(serverURLs)
					this.Control["teamServerURLEdit"].Choose(serverURLs.Length)
				}

				showMessage(translate("Successfully connected to the Team Server."))
			}
			catch Any as exception {
				this.Control["teamServerSessionTokenEdit"].Text := ""
				this.Control["teamServerDataTokenEdit"].Text := ""
				this.Control["teamServerTimeText"].Opt("+c" . this.Window.Theme.TextColor["Disabled"])
				this.Control["teamServerTimeText"].Text := translate("Please Login for actual data...")

				if message {
					OnMessage(0x44, translateOkButton)
					MsgBox((translate("Cannot connect to the Team Server.") . "`n`n" . translate("Error: ") . exception.Message), translate("Error"), 262160)
					OnMessage(0x44, translateOkButton, 0)
				}

				this.iToken := false
			}
		}
		else {
			this.Control["teamServerSessionTokenEdit"].Text := ""
			this.Control["teamServerDataTokenEdit"].Text := ""
			this.Control["teamServerTimeText"].Opt("+c" . this.Window.Theme.TextColor["Disabled"])
			this.Control["teamServerTimeText"].Text := translate("Please Login for actual data...")

			this.iToken := false
		}

		this.loadTeams()
	}

	updateState() {
		this.Control["changePasswordButton"].Enabled := false
		this.Control["addTeamButton"].Enabled := false
		this.Control["deleteTeamButton"].Enabled := false
		this.Control["editTeamButton"].Enabled := false

		this.Control["addDriverButton"].Enabled := false
		this.Control["deleteDriverButton"].Enabled := false
		this.Control["editDriverButton"].Enabled := false

		this.Control["addSessionButton"].Enabled := false
		this.Control["deleteSessionButton"].Enabled := false
		this.Control["editSessionButton"].Enabled := false

		if ((Trim(this.Control["teamServerURLEdit"].Text) = "") || (Trim(this.Control["teamServerNameEdit"].Text) = "")) {
			this.Control["teamServerSessionTokenEdit"].Text := ""
			this.Control["teamServerDataTokenEdit"].Text := ""
		}

		if this.Token {
			this.Control["changePasswordButton"].Enabled := true
			this.Control["addTeamButton"].Enabled := true

			if this.SelectedTeam {
				this.Control["deleteTeamButton"].Enabled := true
				this.Control["editTeamButton"].Enabled := true

				this.Control["addDriverButton"].Enabled := true
				this.Control["addSessionButton"].Enabled := true

				if this.SelectedDriver {
					this.Control["deleteDriverButton"].Enabled := true
					this.Control["editDriverButton"].Enabled := true
				}

				if this.SelectedSession {
					this.Control["deleteSessionButton"].Enabled := true
					this.Control["editSessionButton"].Enabled := true
				}
			}
		}

		if (this.Control["teamServerDataTokenEdit"].Text != "")
			this.Control["renewDataTokenButton"].Enabled := true
		else
			this.Control["renewDataTokenButton"].Enabled := false
	}

	parseObject(properties) {
		local result := Object()
		local property

		properties := StrReplace(properties, "`r", "")

		loop Parse, properties, "`n" {
			property := string2Values("=", A_LoopField)

			result.%property[1]% := property[2]
		}

		return result
	}

	renewDataToken() {
		try {
			this.Control["teamServerDataTokenEdit"].Text := this.Connector.RenewDataToken()
		}
		catch Any as exception {
			this.Control["teamServerDataTokenEdit"].Text := ""
		}

		this.updateState()
	}

	loadTeams() {
		local connector := this.Connector
		local identifiers, ignore, identifier, team, teams, name

		this.iTeams := CaseInsenseMap()

		if this.Token {
			try {
				identifiers := string2Values(";", connector.GetAllTeams())
			}
			catch Any as exception {
				identifiers := []
			}

			for ignore, identifier in identifiers
				try {
					team := this.parseObject(connector.GetTeam(identifier))

					if (StrLen(Trim(team.Name)) = 0)
						connector.DeleteTeam(identifier)
					else
						this.iTeams[team.Name] := team.Identifier
				}
				catch Any as exception {
					logError(exception)
				}
		}

		teams := []

		for name, ignore in this.Teams
			teams.Push(name)

		this.Control["teamDropDownList"].Delete()
		this.Control["teamDropDownList"].Add(teams)

		this.SelectTeam(((teams.Length > 0) ? teams[1] : false))
	}

	loadDrivers() {
		local connector := this.Connector
		local identifiers, ignore, identifier, drivers, driver, name

		this.iDrivers := CaseInsenseMap()

		if this.SelectedTeam {
			try {
				identifiers := string2Values(";", connector.GetTeamDrivers(this.Teams[this.SelectedTeam]))
			}
			catch Any as exception {
				identifiers := []
			}

			for ignore, identifier in identifiers {
				try {
					driver := this.parseObject(connector.GetDriver(identifier))

					name := driverName(driver.ForName, driver.SurName, driver.NickName)

					if (StrLen(Trim(name)) = 0)
						connector.DeleteDriver(identifier)
					else
						this.iDrivers[name] := driver.Identifier
				}
				catch Any as exception {
					logError(exception)
				}
			}
		}

		drivers := []

		for name, ignore in this.Drivers
			drivers.Push(name)

		this.Control["driverListBox"].Delete()
		this.Control["driverListBox"].Add(drivers)

		this.selectDriver((drivers.Length > 0) ? drivers[1] : false)
	}

	loadSessions() {
		local connector := this.Connector
		local identifiers, ignore, identifier, session, sessions, infos, name, stints, laps

		this.iSessions := CaseInsenseMap()

		if this.SelectedTeam {
			try {
				identifiers := string2Values(";", connector.GetTeamSessions(this.Teams[this.SelectedTeam]))
			}
			catch Any as exception {
				identifiers := []
			}

			for ignore, identifier in identifiers {
				try {
					session := this.parseObject(connector.GetSession(identifier))

					if (StrLen(Trim(session.Name)) = 0)
						connector.DeleteSession(identifier)
					else
						this.iSessions[session.Name] := session.Identifier
				}
				catch Any as exception {
					logError(exception)
				}
			}
		}

		sessions := []
		infos := []

		for name, identifier in this.Sessions {
			try {
				stints := string2Values(";", connector.GetSessionStints(identifier)).Length
			}
			catch Any as exception {
				stints := 0
			}

			laps := 0

			if (stints > 0)
				try {
					laps := this.parseObject(connector.GetLap(connector.GetSessionLastLap(identifier))).Nr
				}
				catch Any as exception {
					logError(exception)
				}

			sessions.Push(name)

			infos.Push(name . translate(" (") . stints . translate(" stints, ") . laps . translate(" laps)"))
		}

		this.Control["sessionListBox"].Delete()
		this.Control["sessionListBox"].Add(infos)

		this.selectSession((sessions.Length > 0) ? sessions[1] : false)
	}

	selectTeam(team) {
		local teams, name, ignore

		this.iSelectedTeam := team

		teams := []

		for name, ignore in this.Teams
			teams.Push(name)

		this.Control["teamDropDownList"].Choose(inList(teams, team))

		this.loadDrivers()
		this.loadSessions()
	}

	selectDriver(driver) {
		local drivers, name, ignore

		this.iSelectedDriver := driver

		drivers := []

		for name, ignore in this.Drivers
			drivers.Push(name)

		this.Control["driverListBox"].Choose(inList(drivers, driver))

		this.updateState()
	}

	selectSession(session) {
		local sessions, name, ignore

		this.iSelectedSession := session

		sessions := []

		for name, ignore in this.Sessions
			sessions.Push(name)

		this.Control["sessionListBox"].Choose(inList(sessions, session))

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
		this.Window.Block()

		try {
			this.Connector.DeleteTeam(this.Teams[name])
		}
		finally {
			this.Window.Unblock()
		}

		this.loadTeams()
	}

	normalizeDriverName(name) {
		local forName := ""
		local surName := ""
		local nickName := ""
		local initialForName, initialSurName

		parseDriverName(name, &forName, &surName, &nickName)

		if (Trim(nickName) = "") {
			initialForName := StrUpper(SubStr(forName, 1, 1))
			initialSurName := StrUpper(SubStr(surName, 1, 1))

			nickName := (initialForName . initialSurName)
		}

		nickName := SubStr(nickName, 1, 3)

		return driverName(forName, surName, nickName)
	}

	addDriver(name) {
		local drivers := this.Drivers
		local forName := ""
		local surName := ""
		local nickName := ""
		local identifier

		name := this.normalizeDriverName(name)

		parseDriverName(name, &forName, &surName, &nickName)

		identifier := this.Connector.CreateDriver(this.Teams[this.SelectedTeam], forName, surName, nickName)

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
		this.Window.Block()

		try {
			this.Connector.DeleteDriver(this.Drivers[name])
		}
		finally {
			this.Window.Unblock()
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
		this.Window.Block()

		try {
			this.Connector.DeleteSession(this.Sessions[name])
		}
		finally {
			this.Window.Unblock()
		}

		this.loadSessions()
	}

	withExceptionHandler(function, arguments*) {
		try {
			return function.Call(arguments*)
		}
		catch Any as exception {
			local message := exception

			if message.HasProp("Message")
				message := message.Message

			OnMessage(0x44, translateOkButton)
			MsgBox((translate("Error while executing command.") . "`n`n" . translate("Error: ") . message), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeTeamServerConfigurator() {
	local editor

	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance

		editor.registerConfigurator(translate("Team Server"), TeamServerConfigurator(editor, editor.Configuration)
								  , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-team-server")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeTeamServerConfigurator()