;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Server Administration Tool      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

;@SC-IF %configuration% == Development
#Include "..\Framework\Development.ahk"
;@SC-EndIF

;@SC-If %configuration% == Production
;@SC #Include "..\Framework\Production.ahk"
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Server Administration.ico
;@Ahk2Exe-ExeName Server Administration.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Application.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\CLR.ahk"
#Include "..\Libraries\Task.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                   Private Constant Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

global kClose := "Close"
global kConnect := "Connect"
global kEvent := "Event"
global kToken := "Token"


;;;-------------------------------------------------------------------------;;;
;;;                   Private Classes Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

class AdministrationResizer extends Window.Resizer {
	RestrictResize(&deltaWidth, &deltaHeight) {
		if (deltaWidth > 100) {
			deltaWidth := 100

			return true
		}
		else
			return false
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

generatePassword(length) {
	local valid := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
	local result := ""

	while (0 < length--)
		result .= SubStr(valid, Round(Random(1, StrLen(valid))), 1)

	return result
}

administrationEditor(configurationOrCommand, arguments*) {
	local task, ignore, identifier, type, which, contract
	local dllFile, sessionDB, connection, administrationConfig
	local x, y, w, h, width, x0, x1, w1, w2, x2, w4, x4, w3, x3, x4, x5, w5, x6, x7
	local button, administrationTab, progress, compacting

	static administrationGui

	static accountsListView
	static connectionsListView
	static objectsListView

	static connector := false
	static done := false
	static accounts := CaseInsenseMap()
	static tasks := CaseInsenseMap()
	static account := false

	static token := false

	static keepAliveTask := false

	parseObject(properties) {
		local result := CaseInsenseMap()
		local property

		properties := StrReplace(properties, "`r", "")

		loop Parse, properties, "`n" {
			property := string2Values("=", A_LoopField)

			result[property[1]] := property[2]
		}

		return result
	}

	updateTask(connector, tasks, task, which, operation, frequency) {
		if isInteger(operation)
			operation := ["Delete", "Cleanup", "Reset", "Renew"][operation]

		if isInteger(frequency)
			frequency := ["Never", "Daily", "Weekly", "Monthly"][frequency]

		if (frequency = "Never") {
			if task {
				connector.DeleteTask(task)

				tasks.Delete(which)
			}
		}
		else if task
			connector.UpdateTask(task, operation, frequency, true)
		else
			tasks[which] := connector.CreateTask((which = "Quota") ? "Account" : which, operation, frequency)

		return tasks
	}

	loadAccounts(connector, listView) {
		local accounts := CaseInsenseMap()
		local ignore, identifier, account, index

		listView.Delete()

		if administrationEditor(kToken) {
			for ignore, identifier in string2Values(";", connector.GetAllAccounts()) {
				account := parseObject(connector.GetAccount(identifier))

				accounts[A_Index] := account
				accounts[account["Name"]] := account

				index := inList(["Expired", "OneTime", "FixedMinutes", "AdditionalMinutes", "Unlimited"], account["Contract"])

				listView.Add("", account["Name"], account["EMail"]
							   , (account["SessionAccess"] = "true") ? translate("Yes") : translate("No")
							   , (account["DataAccess"] = "true") ? translate("Yes") : translate("No")
							   , translate(["Expired", "One-Time", "Fixed", "Additional", "Unlimited"][index]) . translate(" (") . account["ContractMinutes"] . translate(")")
							   , account["AvailableMinutes"])
			}
		}

		listView.ModifyCol()

		loop 6
			listView.ModifyCol(A_Index, "AutoHdr")

		return accounts
	}

	loadConnections(connector, listView) {
		local ignore, identifier, connection, session

		listView.Delete()

		if administrationEditor(kToken) {
			for ignore, identifier in string2Values(";", connector.GetAllConnections()) {
				try {
					connection := parseObject(connector.GetConnection(identifier))

					session := connection["Session"]

					if (session && (session != ""))
						session := parseObject(connector.GetSession(session))["Name"]

					listView.Add("", translate(connection["Type"]), connection["Name"], connection["Created"], session)
				}
				catch Any as exception {
					logError(exception)
				}
			}
		}

		listView.ModifyCol()

		loop 4
			listView.ModifyCol(A_Index, "AutoHdr")
	}

	loadObjects(connector, listView) {
		local ignore, objectInfo

		listView.Delete()

		try {
			if administrationEditor(kToken)
				for ignore, objectInfo in string2Values(";", connector.GetAllObjects()) {
					objectInfo := string2Values("=", objectInfo)

					listView.Add("", objectInfo[1], objectInfo[2])
				}

			listView.ModifyCol()

			loop 2
				listView.ModifyCol(A_Index, "AutoHdr")
		}
		catch Any as exception {
			logError(exception, true)
		}
	}

	changePassword(*) {
		if administrationEditor(kToken) {
			local teamServerNameEdit := administrationGui["teamServerNameEdit"].Text
			local teamServerPasswordEdit := administrationGui["teamServerPasswordEdit"].Text
			local title := translate("Team Server")
			local password, firstPassword, secondPassword, result

			administrationGui.Opt("+OwnDialogs")

			result := withBlockedWindows(InputBox, translate("Please enter your current password:"), title, "Password w200 h150")

			if (result.Result = "Ok") {
				password := result.Value

				if (teamServerPasswordEdit != password) {
					OnMessage(0x44, translateOkButton)
					withBlockedWindows(MsgBox, translate("Invalid password."), translate("Error"), 262160)
					OnMessage(0x44, translateOkButton, 0)

					return
				}

				result := withBlockedWindows(InputBox, translate("Please enter your new password:"), title, "Password w200 h150")

				if (result.Result = "Ok") {
					firstPassword := result.Value

					withBlockedWindows(InputBox, translate("Please re-enter your new password:"), title, "Password w200 h150")

					if (result.Result = "Ok") {
						secondPassword := result.Value

						if (firstPassword != secondPassword) {
							OnMessage(0x44, translateOkButton)
							withBlockedWindows(MsgBox, translate("The passwords do not match."), translate("Error"), 262160)
							OnMessage(0x44, translateOkButton, 0)

							return
						}

						administrationEditor(kEvent, "PasswordChange", firstPassword)
					}
				}
			}
		}
		else {
			OnMessage(0x44, translateOkButton)
			withBlockedWindows(MsgBox, translate("You must be connected to the Server to change your password."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)
		}
	}

	selectAccount(listView, line, selected) {
		if selected
			chooseAccount(listView, line)
	}

	chooseAccount(listView, line, *) {
		if line
			administrationEditor(kEvent, "AccountLoad", line)
		else
			administrationEditor(kEvent, "AccountClear")
	}

	deleteAccount(*) {
		local msgResult

		OnMessage(0x44, translateYesNoButtons)
		msgResult := withBlockedWindows(MsgBox, translate("Do you really want to delete the selected account?"), translate("Delete"), 262436)
		OnMessage(0x44, translateYesNoButtons, 0)

		if (msgResult = "Yes")
			administrationEditor(kEvent, "AccountDelete")
	}

	noSelect(listView, *) {
		loop listView.GetCount()
			listView.Modify(A_Index, "-Select")
	}

	if (configurationOrCommand == kClose)
		done := true
	else if (configurationOrCommand == kConnect) {
		try {
			connector.Initialize(administrationGui["teamServerURLEdit"].Text)

			token := connector.Login(administrationGui["teamServerNameEdit"].Text, administrationGui["teamServerPasswordEdit"].Text)

			if (token = "")
				token := false

			if token {
				connection := connector.Connect(token, SessionDatabase.ID, SessionDatabase.getUserName(), "Admin")

				administrationConfig := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

				setMultiMapValue(administrationConfig, "Server Administration", "ServerURL", administrationGui["teamServerURLEdit"].Text)
				setMultiMapValue(administrationConfig, "Server Administration", "Login", administrationGui["teamServerNameEdit"].Text)

				writeMultiMap(kUserConfigDirectory . "Application Settings.ini", administrationConfig)

				if keepAliveTask
					keepAliveTask.stop()

				keepAliveTask := PeriodicTask(ObjBindMethod(connector, "KeepAlive", connection), 120000, kLowPriority)

				keepAliveTask.start()

				accounts := loadAccounts(connector, accountsListView)

				administrationEditor(kEvent, "TasksLoad")
				administrationEditor(kEvent, "AccountClear")

				loadConnections(connector, connectionsListView)

				loadObjects(connector, objectsListView)

				showMessage(translate("Successfully connected to the Team Server."))
			}
		}
		catch Any as exception {
			token := false

			accounts := loadAccounts(connector, accountsListView)
			account := false

			administrationEditor(kEvent, "TasksReset")
			administrationEditor(kEvent, "AccountClear")

			OnMessage(0x44, translateOkButton)
			withBlockedWindows(MsgBox, (translate("Cannot connect to the Team Server.") . "`n`n" . translate("Error: ") . exception.Message), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)
		}
	}
	else if (configurationOrCommand = kToken)
		return token
	else if (configurationOrCommand == kEvent) {
		try {
			if (arguments[1] = "TasksReset") {
				 administrationGui["taskTokenOperationDropDown"].Choose(1)
				 administrationGui["taskTokenFrequencyDropDown"].Choose(1)
				 administrationGui["taskSessionOperationDropDown"].Choose(3)
				 administrationGui["taskSessionFrequencyDropDown"].Choose(1)
				 administrationGui["taskQuotaOperationDropDown"].Choose(1)
				 administrationGui["taskQuotaFrequencyDropDown"].Choose(1)
				 administrationGui["taskAccountOperationDropDown"].Choose(1)
				 administrationGui["taskAccountFrequencyDropDown"].Choose(1)
			}
			else if (arguments[1] = "TasksLoad") {
				administrationEditor(kEvent, "TasksReset")

				tasks := CaseInsenseMap()

				for ignore, identifier in string2Values(";", connector.GetAllTasks()) {
					task := parseObject(connector.GetTask(identifier))

					if ((task["Which"] = "Account") && (task["What"] = "Renew"))
						type := "Quota"
					else
						type := task["Which"]

					tasks[type] := task["Identifier"]

					if (type = "Token") {
						administrationGui["taskTokenOperationDropDown"].Choose(inList(["Delete", "Cleanup", "Reset", "Renew"], task["What"]))
						administrationGui["taskTokenFrequencyDropDown"].Choose(inList(["Never", "Daily", "Weekly", "Monthly"], task["When"]))
					}
					else if (type = "Session") {
						administrationGui["taskSessionOperationDropDown"].Choose(inList(["Delete", "Cleanup", "Reset", "Renew"], task["What"]))
						administrationGui["taskSessionFrequencyDropDown"].Choose(inList(["Never", "Daily", "Weekly", "Monthly"], task["When"]))
					}
					else if (type = "Quota") {
						administrationGui["taskQuotaOperationDropDown"].Choose(inList(["Delete", "Cleanup", "Reset", "Renew"], task["What"]) - 3)
						administrationGui["taskQuotaFrequencyDropDown"].Choose(inList(["Never", "Daily", "Weekly", "Monthly"], task["When"]))
					}
					else if (type = "Account") {
						administrationGui["taskAccountOperationDropDown"].Choose(inList(["Delete"], task["What"]))
						administrationGui["taskAccountFrequencyDropDown"].Choose(inList(["Never", "Daily", "Weekly", "Monthly"], task["When"]))
					}
				}
			}
			else if (arguments[1] = "TaskUpdate") {
				which := arguments[2]

				task := (tasks.Has(which) ? tasks[which] : false)

				switch which, false {
					case "Token":
						tasks := updateTask(connector, tasks, task, which, administrationGui["taskTokenOperationDropDown"].Value
																		 , administrationGui["taskTokenFrequencyDropDown"].Value)
					case "Session":
						tasks := updateTask(connector, tasks, task, which, administrationGui["taskSessionOperationDropDown"].Value
																		 , administrationGui["taskSessionFrequencyDropDown"].Value)
					case "Quota":
						tasks := updateTask(connector, tasks, task, which, administrationGui["taskQuotaOperationDropDown"].Value + 3
																		 , administrationGui["taskQuotaFrequencyDropDown"].Value)
					case "Account":
						tasks := updateTask(connector, tasks, task, which, administrationGui["taskAccountOperationDropDown"].Value
																		 , administrationGui["taskAccountFrequencyDropDown"].Value)
				}
			}
			else if (arguments[1] = "PasswordChange") {
				connector.ChangePassword(arguments[2])

				administrationGui["teamServerPasswordEdit"].Value := arguments[2]
			}
			else if (arguments[1] = "AccountLoad") {
				account := accounts[arguments[2]]

				administrationGui["accountNameEdit"].Text := account["Name"]
				administrationGui["accountEMailEdit"].Text := account["EMail"]
				administrationGui["accountPasswordEdit"].Text := ""
				administrationGui["accountContractDropDown"].Choose(inList(["Expired", "OneTime", "FixedMinutes", "AdditionalMinutes", "Unlimited"], account["Contract"]))
				administrationGui["accountMinutesEdit"].Text := account["ContractMinutes"]
				administrationGui["accountSessionAccessCheck"].Value := (account["SessionAccess"] = kTrue)
				administrationGui["accountDataAccessCheck"].Value := (account["DataAccess"] = kTrue)

				administrationEditor(kEvent, "UpdateState")
			}
			else if (arguments[1] = "AccountNew") {
				administrationEditor(kEvent, "AccountClear")

				administrationGui["accountContractDropDown"].Choose(2)
				administrationGui["accountMinutesEdit"].Text := 120

				account := true

				administrationEditor(kEvent, "UpdateState")
			}
			else if (arguments[1] = "AccountSave") {
				local accountNameEdit := administrationGui["accountNameEdit"].Text
				local accountEMailEdit := administrationGui["accountEMailEdit"].Text
				local accountPasswordEdit := administrationGui["accountPasswordEdit"].Text
				local accountContractDropDown := administrationGui["accountContractDropDown"].Value
				local accountMinutesEdit := administrationGui["accountMinutesEdit"].Text
				local accountSessionAccessCheck := administrationGui["accountSessionAccessCheck"].Value
				local accountDataAccessCheck := administrationGui["accountDataAccessCheck"].Value

				contract := ["Expired", "OneTime", "FixedMinutes", "AdditionalMinutes", "Unlimited"][accountContractDropDown]

				if (account == true) {
					connector.CreateAccount(accountNameEdit, accountEMailEdit, accountPasswordEdit
										  , accountSessionAccessCheck ? kTrue : kFalse
										  , accountDataAccessCheck ? kTrue : kFalse
										  , accountMinutesEdit, contract, accountMinutesEdit)
				}
				else {
					if (accountPasswordEdit != "")
						connector.ChangeAccountPassword(account["Identifier"], accountPasswordEdit)

					if ((account["Contract"] != contract) || (account["ContractMinutes"] != accountMinutesEdit)) {
						connector.ChangeAccountContract(account["Identifier"], contract, accountMinutesEdit)

						account["Contract"] := contract
						account["ContractMinutes"] := accountMinutesEdit
					}

					if (accountEMailEdit != account["EMail"]) {
						connector.ChangeAccountEMail(account["Identifier"], accountEMailEdit)

						account["EMail"] := accountEMailEdit
					}

					connector.ChangeAccountAccess(account["Identifier"], accountSessionAccessCheck ? kTrue : kFalse
																	   , accountDataAccessCheck ? kTrue : kFalse)
				}

				accounts := loadAccounts(connector, accountsListView)

				administrationEditor(kEvent, "AccountClear")
			}
			else if (arguments[1] = "AccountDelete") {
				connector.DeleteAccount(account["Identifier"])

				accounts := loadAccounts(connector, accountsListView)

				administrationEditor(kEvent, "AccountClear")
			}
			else if (arguments[1] = "AccountClear") {
				account := false

				administrationGui["accountNameEdit"].Text := ""
				administrationGui["accountEMailEdit"].Text := ""
				administrationGui["accountPasswordEdit"].Text := ""
				administrationGui["accountSessionAccessCheck"].Value := 0
				administrationGui["accountDataAccessCheck"].Value := 0
				administrationGui["accountContractDropDown"].Choose(0)
				administrationGui["accountMinutesEdit"].Text := ""

				administrationEditor(kEvent, "UpdateState")
			}
			else if (arguments[1] = "UpdateAvailableMinutes") {
				if (account == true) {
					OnMessage(0x44, translateOkButton)
					withBlockedWindows(MsgBox, translate("You must save the account before you can change the number of available minutes."), translate("Error"), 262160)
					OnMessage(0x44, translateOkButton, 0)
				}
				else {
					administrationGui.Opt("+OwnDialogs")

					result := withBlockedWindows(InputBox, translate("Please enter the amount of available minutes:"), translate("Team Server"), "w200 h150", account["AvailableMinutes"])

					if (result.Result = "Ok") {
						connector.SetAccountMinutes(account.Identifier, result.Value)

						accounts := loadAccounts(connector, accountsListView)

						administrationEditor(kEvent, "AccountClear")
					}
				}
			}
			else if (arguments[1] = "UpdateState") {
				if token {
					administrationGui["changePasswordButton"].Enabled := true
					administrationGui["addAccountButton"].Enabled := true

					administrationGui["taskTokenOperationDropDown"].Enabled := true
					administrationGui["taskTokenFrequencyDropDown"].Enabled := true
					administrationGui["taskSessionOperationDropDown"].Enabled := true
					administrationGui["taskSessionFrequencyDropDown"].Enabled := true
					administrationGui["taskQuotaOperationDropDown"].Enabled := true
					administrationGui["taskQuotaFrequencyDropDown"].Enabled := true
					administrationGui["taskAccountOperationDropDown"].Enabled := true
					administrationGui["taskAccountFrequencyDropDown"].Enabled := true

					administrationGui["refreshConnectionsListButton"].Enabled := true
					administrationGui["refreshObjectsListButton"].Enabled := true
				}
				else {
					administrationGui["changePasswordButton"].Enabled := false
					administrationGui["addAccountButton"].Enabled := false

					administrationGui["taskTokenOperationDropDown"].Enabled := false
					administrationGui["taskTokenFrequencyDropDown"].Enabled := false
					administrationGui["taskSessionOperationDropDown"].Enabled := false
					administrationGui["taskSessionFrequencyDropDown"].Enabled := false
					administrationGui["taskQuotaOperationDropDown"].Enabled := false
					administrationGui["taskQuotaFrequencyDropDown"].Enabled := false
					administrationGui["taskAccountOperationDropDown"].Enabled := false
					administrationGui["taskAccountFrequencyDropDown"].Enabled := false

					administrationGui["refreshConnectionsListButton"].Enabled := false
					administrationGui["refreshObjectsListButton"].Enabled := false

					connectionsListView.Delete()
				}

				if account {
					if (account == true)
						administrationGui["accountNameEdit"].Enabled := true
					else
						administrationGui["accountNameEdit"].Enabled := false

					administrationGui["accountEMailEdit"].Enabled := true
					administrationGui["accountPasswordEdit"].Enabled := true
					administrationGui["accountSessionAccessCheck"].Enabled := true
					administrationGui["accountDataAccessCheck"].Enabled := true
					administrationGui["accountContractDropDown"].Enabled := true

					if (administrationGui["accountContractDropDown"].Value > 1) {
						administrationGui["availableMinutesButton"].Enabled := true
						administrationGui["accountMinutesEdit"].Enabled := true
					}
					else {
						administrationGui["availableMinutesButton"].Enabled := false
						administrationGui["accountMinutesEdit"].Enabled := false
					}

					administrationGui["copyPasswordButton"].Enabled := true

					administrationGui["createPasswordButton"].Enabled := true

					administrationGui["deleteAccountButton"].Enabled := true
					administrationGui["saveAccountButton"].Enabled := true
				}
				else {
					administrationGui["accountNameEdit"].Enabled := false
					administrationGui["accountEMailEdit"].Enabled := false
					administrationGui["accountPasswordEdit"].Enabled := false
					administrationGui["accountSessionAccessCheck"].Enabled := false
					administrationGui["accountDataAccessCheck"].Enabled := false
					administrationGui["accountContractDropDown"].Enabled := false
					administrationGui["accountMinutesEdit"].Enabled := false

					administrationGui["copyPasswordButton"].Enabled := false

					administrationGui["createPasswordButton"].Enabled := false
					administrationGui["availableMinutesButton"].Enabled := false

					administrationGui["deleteAccountButton"].Enabled := false
					administrationGui["saveAccountButton"].Enabled := false
				}
			}
			else if (arguments[1] = "PasswordCreate") {
				administrationGui["copyPasswordButton"].Enabled := true

				administrationGui["accountPasswordEdit"].Text := generatePassword(20)
			}
			else if (arguments[1] = "PasswordCopy") {
				local accountPasswordEdit := administrationGui["accountPasswordEdit"].Text

				if (accountPasswordEdit && (accountPasswordEdit != "")) {
					A_Clipboard := accountPasswordEdit

					showMessage(translate("Password copied to the clipboard."))
				}
			}
			else if (arguments[1] = "LoadConnections")
				loadConnections(connector, connectionsListView)
			else if (arguments[1] = "LoadObjects")
				loadObjects(connector, objectsListView)
			else if (arguments[1] = "CompactDatabase") {
				OnMessage(0x44, translateYesNoButtons)
				msgResult := withBlockedWindows(MsgBox, translate("Do you really want to compact the database? This can take quite a while and cannot be interrupted..."), translate("Compact"), 262436)
				OnMessage(0x44, translateYesNoButtons, 0)

				if (msgResult = "Yes")
					try {
						progress := 0

						showProgress({color: "Green", title: translate("Compacting Database")})

						try {
							connector.CompactDatabase()

							loop {
								Sleep(1000)

								showProgress({progress: progress++})

								if (progress > 100)
									progress := 0

								compacting := connector.CompactingDatabase()
							}
							until (!compacting || (compacting = kFalse))

							while (progress < 100) {
								showProgress({progress: progress++})

								Sleep(100)
							}
						}
						finally {
							hideProgress()
						}
					}
					catch Any as exception {
						logError(exception, true)
					}

				loadObjects(connector, objectsListView)
			}
		}
		catch Any as exception {
			OnMessage(0x44, translateOkButton)
			withBlockedWindows(MsgBox, (translate("Error while executing command.") . "`n`n" . translate("Error: ") . exception.Message), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)
		}
	}
	else {
		dllFile := (kBinariesDirectory . "Connectors\Team Server Connector.dll")

		try {
			if (!FileExist(dllFile)) {
				logMessage(kLogCritical, translate("Team Server Connector.dll not found in ") . kBinariesDirectory)

				throw "Unable to find Team Server Connector.dll in " . kBinariesDirectory . "..."
			}

			connector := CLR_LoadLibrary(dllFile).CreateInstance("TeamServer.TeamServerConnector")
		}
		catch Any as exception {
			logMessage(kLogCritical, translate("Error while initializing Team Server Connector - please rebuild the applications"))

			showMessage(translate("Error while initializing Team Server Connector - please rebuild the applications") . translate("...")
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}

		administrationConfig := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

		administrationGui := Window({Descriptor: "Server Administration", Resizeable: true, Closeable: true, Options: "-MaximizeBox"})

		administrationGui.SetFont("Bold", "Arial")

		administrationGui.Add("Text", "w388 Center H:Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(administrationGui, "Server Administration"))

		administrationGui.SetFont("Norm", "Arial")

		administrationGui.Add("Documentation", "x118 YP+20 w168 Center H:Center", translate("Server Administration")
							, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#server-administration")

		administrationGui.SetFont("Norm", "Arial")

		/*
		administrationGui.Add("Text", "x24 yp+30 w356 0x10")

		administrationGui.Add("Button", "x164 y474 w80 h23 Y:Move H:Center", translate("Close")).OnEvent("Click", administrationEditor.Bind(kClose))
		*/

		x := 8
		y := 68
		width := 388

		x0 := x + 8
		x1 := x + 132

		w1 := width - (x1 - x + 8)

		w2 := w1 - 70

		x2 := x1 - 25

		w4 := w1 - 25
		x4 := x1 + w4 + 2

		w3 := Round((w4 / 2) - 3)
		x3 := x1 + w3 + 6

		x4 := x3 + 64

		x5 := x3 + w3 + 2
		w5 := w3 - 25

		administrationGui.Add("Text", "x" . x0 . " y" . y . " w90 h23 +0x200", translate("Server URL"))
		administrationGui.Add("Edit", "x" . x1 . " yp+1 w" . w4 . " h21 W:Grow VteamServerURLEdit", getMultiMapValue(administrationConfig, "Server Administration", "ServerURL", "https://localhost:5001"))

		administrationGui.Add("Text", "x" . x0 . " yp+23 w90 h23 +0x200", translate("Login Credentials"))
		administrationGui.Add("Edit", "x" . x1 . " yp+1 w" . w3 . " h21 W:Grow(0.5) VteamServerNameEdit", getMultiMapValue(administrationConfig, "Server Administration", "Login", ""))
		administrationGui.Add("Edit", "x" . x3 . " yp w" . w3 . " h21 X:Move(0.5) W:Grow(0.5) Password VteamServerPasswordEdit", "")

		button := administrationGui.Add("Button", "x" . x2 . " yp-1 w23 h23 Default Center +0x200")
		button.OnEvent("Click", administrationEditor.Bind(kConnect))
		setButtonIcon(button, kIconsDirectory . "Authorize.ico", 1, "L4 T4 R4 B4")
		button := administrationGui.Add("Button", "x" . x5 . " yp-1 w23 h23 X:Move Center +0x200 vchangePasswordButton")
		button.OnEvent("Click", changePassword)
		setButtonIcon(button, kIconsDirectory . "Pencil.ico", 1, "L4 T4 R4 B4")

		administrationTab := administrationGui.Add("Tab3", "x8 y122 w388 h343 W:Grow H:Grow -Wrap", collect(["Accounts", "Jobs", "Connections", "Database"], translate))

		x0 := 16
		y := 152

		administrationTab.UseTab(1)

		accountsListView := administrationGui.Add("ListView", "x" . x0 . " y" . y . " w372 h146 W:Grow H:Grow -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Account", "E-Mail", "Session", "Data", "Quota", "Available"], translate))
		accountsListView.OnEvent("Click", chooseAccount)
		accountsListView.OnEvent("DoubleClick", chooseAccount)
		accountsListView.OnEvent("ItemSelect", selectAccount)

		administrationGui.Add("Text", "x" . x0 . " yp+150 w90 h23 Y:Move +0x200", translate("Name"))
		administrationGui.Add("Edit", "x" . x1 . " yp+1 w" . w3 . " W:Grow(0.5) Y:Move vaccountNameEdit")

		administrationGui.Add("Text", "x" . x0 . " yp+24 w90 h23 Y:Move +0x200", translate("Password"))
		administrationGui.Add("Edit", "x" . x1 . " yp+1 w" . w4 . " W:Grow Y:Move ReadOnly Password vaccountPasswordEdit")
		administrationGui.Add("Button", "x" . x2 . " yp-1 w23 h23 Y:Move Center +0x200 vcreatePasswordButton").OnEvent("Click", administrationEditor.Bind(kEvent, "PasswordCreate"))
		setButtonIcon(administrationGui["createPasswordButton"], kIconsDirectory . "Authorize.ico", 1, "L4 T4 R4 B4")
		administrationGui.Add("Button", "x" . x5 . " yp w23 h23 X:Move Y:Move Center +0x200 vcopyPasswordButton").OnEvent("Click", administrationEditor.Bind(kEvent, "PasswordCopy"))
		setButtonIcon(administrationGui["copyPasswordButton"], kIconsDirectory . "Copy.ico", 1, "L4 T4 R4 B4")

		administrationGui.Add("Text", "x" . x0 . " yp+24 w90 h23 Y:Move +0x200", translate("E-Mail"))
		administrationGui.Add("Edit", "x" . x1 . " yp+1 w" . w4 . " W:Grow Y:Move vaccountEMailEdit")

		administrationGui.Add("Text", "x" . x0 . " yp+24 w90 h23 Y:Move +0x200", translate("Session / Data"))
		administrationGui.Add("CheckBox", "x" . x1 . " yp+3 w23 Y:Move vaccountSessionAccessCheck")
		administrationGui.Add("CheckBox", "xp+24 yp w23 Y:Move vaccountDataAccessCheck")

		administrationGui.Add("Text", "x" . x0 . " yp+22 w90 h23 Y:Move +0x200", translate("Contingent"))
		administrationGui.Add("DropDownList", "x" . x1 . " yp+1 w" . w3 . " W:Grow Y:Move Choose2 vaccountContractDropDown", collect(["Expired", "One-Time", "Fixed", "Additional", "Unlimited"], translate)).OnEvent("Change", administrationEditor.Bind(kEvent, "UpdateState"))
		administrationGui.Add("Edit", "x" . x3 . " yp w60 h21 X:Move Y:Move Number vaccountMinutesEdit")
		administrationGui.Add("Text", "x" . x4 . " yp w90 h23 X:Move Y:Move +0x200", translate("Minutes"))
		administrationGui.Add("Button", "x" . x2 . " yp-1 w23 h23 Y:Move Center +0x200 vavailableMinutesButton").OnEvent("Click", administrationEditor.Bind(kEvent, "UpdateAvailableMinutes"))
		setButtonIcon(administrationGui["availableMinutesButton"], kIconsDirectory . "Watch.ico", 1, "L4 T4 R4 B4")

		x5 := x4 - 1
		x6 := x5 + 24
		x7 := x6 + 24

		administrationGui.Add("Button", "x" . x5 . " yp+30 w23 h23 X:Move Y:Move Center +0x200 vaddAccountButton").OnEvent("Click", administrationEditor.Bind(kEvent, "AccountNew"))
		setButtonIcon(administrationGui["addAccountButton"], kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		administrationGui.Add("Button", "x" . x6 . " yp w23 h23 X:Move Y:Move Center +0x200 vdeleteAccountButton").OnEvent("Click", deleteAccount)
		setButtonIcon(administrationGui["deleteAccountButton"], kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")
		administrationGui.Add("Button", "x" . x7 . " yp w23 h23 X:Move Y:Move Center +0x200 vsaveAccountButton").OnEvent("Click", administrationEditor.Bind(kEvent, "AccountSave"))
		setButtonIcon(administrationGui["saveAccountButton"], kIconsDirectory . "Save.ico", 1, "L5 T5 R5 B5")

		administrationTab.UseTab(2)

		administrationGui.Add("Text", "x" . x0 . " y" . y . " w120 h23 +0x200", translate("Expired Tokens"))
		administrationGui.Add("DropDownList", "x" . x1 . " yp+1 w" . w3 . " W:Grow(0.5) Choose1 vtaskTokenOperationDropDown", [translate("Delete")]).OnEvent("Change", administrationEditor.Bind(kEvent, "TaskUpdate", "Token"))
		administrationGui.Add("DropDownList", "x" . x3 . " yp+1 w" . w3 . " X:Move(0.5) W:Grow(0.5) Choose1 vtaskTokenFrequencyDropDown", collect(["Never", "Daily", "Weekly"], translate)).OnEvent("Change", administrationEditor.Bind(kEvent, "TaskUpdate", "Token"))

		administrationGui.Add("Text", "x" . x0 . " yp+23 w120 h23 +0x200", translate("Expired Accounts"))
		administrationGui.Add("DropDownList", "x" . x1 . " yp+1 w" . w3 . " W:Grow(0.5) Choose1 vtaskAccountOperationDropDown", [translate("Delete")]).OnEvent("Change", administrationEditor.Bind(kEvent, "TaskUpdate", "Account"))
		administrationGui.Add("DropDownList", "x" . x3 . " yp+1 w" . w3 . " X:Move(0.5) W:Grow(0.5) Choose1 vtaskAccountFrequencyDropDown", collect(["Never", "Daily", "Weekly", "1st of Month"], translate)).OnEvent("Change", administrationEditor.Bind(kEvent, "TaskUpdate", "Account"))

		administrationGui.Add("Text", "x" . x0 . " yp+23 w120 h23 +0x200", translate("Finished Sessions"))
		administrationGui.Add("DropDownList", "x" . x1 . " yp+1 w" . w3 . " W:Grow(0.5) Choose3 vtaskSessionOperationDropDown", collect(["Delete", "Clear", "Reset"], translate)).OnEvent("Change", administrationEditor.Bind(kEvent, "TaskUpdate", "Session"))
		administrationGui.Add("DropDownList", "x" . x3 . " yp+1 w" . w3 . " X:Move(0.5) W:Grow(0.5) Choose1 vtaskSessionFrequencyDropDown", collect(["Never", "Daily", "Weekly"], translate)).OnEvent("Change", administrationEditor.Bind(kEvent, "TaskUpdate", "Session"))

		administrationGui.Add("Text", "x" . x0 . " yp+23 w120 h23 +0x200", translate("Quotas"))
		administrationGui.Add("DropDownList", "x" . x1 . " yp+1 w" . w3 . " W:Grow(0.5) Choose1 vtaskQuotaOperationDropDown", collect(["Renew"], translate)).OnEvent("Change", administrationEditor.Bind(kEvent, "TaskUpdate", "Quota"))
		administrationGui.Add("DropDownList", "x" . x3 . " yp+1 w" . w3 . " X:Move(0.5) W:Grow(0.5) Choose1 vtaskQuotaFrequencyDropDown", collect(["Never", "Daily", "Weekly", "1st of Month"], translate)).OnEvent("Change", administrationEditor.Bind(kEvent, "TaskUpdate", "Quota"))

		administrationTab.UseTab(3)

		connectionsListView := administrationGui.Add("ListView", "x" . x0 . " y" . y . " w372 h270 W:Grow H:Grow -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Role", "Name", "Since", "Session"], translate))
		connectionsListView.OnEvent("Click", noSelect)
		connectionsListView.OnEvent("DoubleClick", noSelect)

		administrationGui.Add("Button", "x" . x0 . " y430 w80 h23 Y:Move vrefreshConnectionsListButton", translate("Refresh")).OnEvent("Click", administrationEditor.Bind(kEvent, "LoadConnections"))

		administrationTab.UseTab(4)

		objectsListView := administrationGui.Add("ListView", "x" . x0 . " y" . y . " w372 h270 W:Grow H:Grow -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Type", "#"], translate))
		objectsListView.OnEvent("Click", noSelect)
		objectsListView.OnEvent("DoubleClick", noSelect)

		administrationGui.Add("Button", "x" . x0 . " y430 w80 h23 Y:Move vrefreshObjectsListButton", translate("Refresh")).OnEvent("Click", administrationEditor.Bind(kEvent, "LoadObjects"))

		administrationGui.Add("Button", "x" . (x0 + 372 - 80) . " y430 w80 h23 Y:Move X:Move vcleanupDatabaseButton", translate("Compact...")).OnEvent("Click", administrationEditor.Bind(kEvent, "CompactDatabase"))

		administrationGui.Add(AdministrationResizer(administrationGui))

		if getWindowPosition("Server Administration", &x, &y)
			administrationGui.Show("x" . x . " y" . y)
		else
			administrationGui.Show()

		if getWindowSize("Server Administration", &w, &h)
			administrationGui.Resize("Initialize", w, h)

		ControlFocus(administrationGui["teamServerNameEdit"])

		administrationEditor(kEvent, "AccountClear")

		loop
			Sleep(1000)
		until done
	}
}

startupServerAdministration() {
	local icon := kIconsDirectory . "Server Administration.ico"

	TraySetIcon(icon, "1")
	A_IconTip := "Server Administration"

	startupApplication()

	try {
		administrationEditor(kSimulatorConfiguration)
	}
	catch Any as exception {
		logError(exception, true)

		OnMessage(0x44, translateOkButton)
		withBlockedWindows(MsgBox, substituteVariables(translate("Cannot start %application% due to an internal error..."), {application: "Server Administration"}), translate("Error"), 262160)
		OnMessage(0x44, translateOkButton, 0)

		ExitApp(1)
	}

	ExitApp(0)
}


;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

startupServerAdministration()