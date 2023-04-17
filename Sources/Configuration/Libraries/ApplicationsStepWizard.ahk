;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Applications Step Wizard        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ApplicationsStepWizard                                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ApplicationsStepWizard extends StepWizard {
	iSimulatorsListView := false
	iApplicationsListView := false

	Pages {
		Get {
			return 2
		}
	}

	saveToConfiguration(configuration) {
		local wizard := this.SetupWizard
		local definition := this.Definition
		local groups := CaseInsenseMap()
		local simulators := []
		local stdApplications := []
		local ignore, applications, theApplication, descriptor, exePath, workingDirectory, hooks, group

		super.saveToConfiguration(configuration)

		for ignore, applications in concatenate([definition[1]], string2Values(",", definition[2]))
			for theApplication, ignore in getMultiMapValues(wizard.Definition, applications)
				if (((applications != "Applications.Simulators") || wizard.isApplicationInstalled(theApplication)) && wizard.isApplicationSelected(theApplication)) {
					descriptor := getApplicationDescriptor(theApplication)

					exePath := wizard.applicationPath(theApplication)

					if !exePath
						exePath := ""

					SplitPath(exePath, , &workingDirectory)

					hooks := string2Values(";", descriptor[5])

					Application(theApplication, false, exePath, workingDirectory, descriptor[4], hooks[1], hooks[2], hooks[3]).saveToConfiguration(configuration)

					group := ConfigurationItem.splitDescriptor(applications)[2]

					if (group = "Simulators") {
						simulators.Push(theApplication)

						group := "Other"
					}

					if !groups.Has(group)
						groups[group] := []

					groups[group].Push(theApplication)

					stdApplications.Push(theApplication)
				}

		for ignore, theApplication in wizard.installedApplications()
			if !inList(stdApplications, theApplication) {
				if !groups.Has("Other")
					groups["Other"] := []

				groups["Other"].Push(theApplication)
			}

		for group, applications in groups
			for ignore, theApplication in applications
				setMultiMapValue(configuration, "Applications", group . "." . A_Index, theApplication)
	}

	createGui(wizard, x, y, width, height) {
		local window := this.Window
		local labelWidth := width - 30
		local labelX := x + 35
		local labelY := y + 8
		local application, info, html, buttonX

		noSelect(listView, *) {
			loop listView.GetCount()
				listView.Modify(A_Index, "-Select")
		}

		locateSimulator(*) {
			local fileName, simulator

			window.Opt("+OwnDialogs")

			OnMessage(0x44, translateSelectCancelButtons)
			fileName := FileSelect(1, "", substituteVariables(translate("Select %name% executable..."), {name: translate("Simulator")}), "Executable (*.exe)")
			OnMessage(0x44, translateSelectCancelButtons, 0)

			if (fileName != "") {
				simulator := standardApplication(this.SetupWizard.Definition, ["Applications.Simulators"], fileName)

				if simulator
					this.locateSimulator(simulator, fileName)
			}
		}

		locateApplication(*) {
			local fileName, application

			window.Opt("+OwnDialogs")

			OnMessage(0x44, translateSelectCancelButtons)
			fileName := FileSelect(1, "", substituteVariables(translate("Select %name% executable..."), {name: translate("Application")}), "Executable (*.exe)")
			OnMessage(0x44, translateSelectCancelButtons, 0)

			if (fileName != "") {
				application := standardApplication(this.SetupWizard.Definition, ["Applications.Core", "Applications.Feedback", "Applications.Other"], fileName)

				if application
					this.locateApplication(application, fileName)
				else {
					SplitPath(file, , , , &application)

					this.locateApplication(application, fileName)
				}
			}
		}

		updateSelectedApplications(*) {
			this.updateSelectedApplications(SetupWizard.Instance.Page, false)

			noSelect(this.iApplicationsListView)
		}

		window.SetFont("s10 Bold", "Arial")

		widget1 := window.Add("Picture", "x" . x . " y" . y . " w30 h30 Hidden", kResourcesDirectory . "Setup\Images\Gaming Wheel.ico")
		widget2 := window.Add("Text", "x" . labelX . " y" . labelY . " w" . labelWidth . " h26 Hidden", translate("Simulations"))

		window.SetFont("s8 Norm", "Arial")

		widget3 := window.Add("ListView", "x" . x . " yp+30 w" . width . " h170 H:Grow(0.5) W:Grow Section -Multi -LV0x10 Checked NoSort NoSortHdr Hidden", collect(["Simulation", "Path"], translate))
		widget3.OnEvent("Click", noSelect)
		widget3.OnEvent("DoubleClick", noSelect)
		widget3.OnEvent("ContextMenu", noSelect)

		buttonX := x + width - 90

		widget4 := window.Add("Button", "x" . buttonX . " yp+177 w90 h23 Y:Move(0.5) X:Move Hidden", translate("Locate..."))
		widget4.OnEvent("Click", locateSimulator)

		info := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Applications", "Applications.Simulators.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='border-width:1pt;border-color:#AAAAAA;color:#AAAAAA;width: 90%'>" . info . "</div>"

		widget5 := window.Add("ActiveX", "x" . x . " ys+205 w" . width . " h180 Y:Move(0.5) W:Grow VsimulatorsInfoText Hidden", "shell.explorer")

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		widget5.Value.navigate("about:blank")
		widget5.Value.document.write(html)

		this.iSimulatorsListView := widget3

		this.registerWidgets(1, widget1, widget2, widget3, widget4, widget5)

		window.SetFont("s10 Bold", "Arial")

		widget1 := window.Add("Picture", "x" . x . " y" . y . " w30 h30 Hidden", kResourcesDirectory . "Setup\Images\Tool Chest.ico")
		widget2 := window.Add("Text", "x" . labelX . " y" . labelY . " w" . labelWidth . " h26 Hidden", translate("Applications && Tools"))

		window.SetFont("s8 Norm", "Arial")

		widget3 := window.Add("ListView", "x" . x . " yp+30 w" . width . " h230 H:Grow(0.5) W:Grow Section -Multi -LV0x10 AltSubmit Checked NoSort NoSortHdr Hidden", collect(["Category", "Application", "Path"], translate))
		widget3.OnEvent("Click", updateSelectedApplications)
		widget3.OnEvent("DoubleClick", updateSelectedApplications)
		widget3.OnEvent("ContextMenu", noSelect)

		buttonX := x + width - 90

		widget4 := window.Add("Button", "x" . buttonX . " yp+237 w90 h23 Y:Move(0.5) X:Move Hidden", translate("Locate..."))
		widget4.OnEvent("Click", locateApplication)

		info := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Applications", "Applications.Applications.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='border-width:1pt;border-color:#AAAAAA;color:#AAAAAA;width: 90%'>" . info . "</div>"

		widget5 := window.Add("ActiveX", "x" . x . " ys+265 w" . width . " h120 Y:Move(0.5) W:Grow VapplicationsInfoText Hidden", "shell.explorer")

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		widget5.Value.navigate("about:blank")
		widget5.Value.document.write(html)

		this.iApplicationsListView := widget3

		this.registerWidgets(2, widget1, widget2, widget3, widget4, widget5)
	}

	loadStepDefinition(definition) {
		super.loadStepDefinition(definition)

		if !FileExist(kUserHomeDirectory . "Setup\Simulator Setup.data")
			this.updateAvailableApplications(true)
	}

	reset() {
		super.reset()

		this.iSimulatorsListView := false
		this.iApplicationsListView := false
	}

	updateState() {
		super.updateState()

		if (this.Definition && (SetupWizard.Instance.Step == this))
			this.updateAvailableApplications()
	}

	showPage(page) {
		this.updateAvailableApplications()

		super.showPage(page)

		this.loadApplications(page == 1)
	}

	hidePage(page) {
		this.updateSelectedApplications(page, false)

		return super.hidePage(page)
	}

	updateAvailableApplications(initialize := false) {
		local wizard := this.SetupWizard
		local definition := this.Definition
		local application, ignore, section, application, category

		for ignore, section in concatenate([definition[1]], string2Values(",", definition[2])) {
			category := ConfigurationItem.splitDescriptor(section)[2]

			for application, ignore in getMultiMapValues(wizard.Definition, section) {
				if !wizard.isApplicationInstalled(application) {
					wizard.locateApplication(application, false, false)

					if (initialize && wizard.isApplicationInstalled(application))
						wizard.selectApplication(application, true, false)
				}
				else if initialize
					wizard.selectApplication(application, true, false)
			}
		}
	}

	updateSelectedApplications(page, update := true) {
		local wizard := this.SetupWizard
		local column := ((page == 1) ? 1 : 2)
		local listView := ((page == 1) ? this.iSimulatorsListView : this.iApplicationsListView)
		local checked := CaseInsenseMap()
		local row := 0
		local name

		loop {
			row := listView.GetNext(row,"C")

			if row {
				name := listView.GetText(row, column)

				checked[name] := true
			}
			else
				break
		}

		loop listView.GetCount() {
			name := listView.GetText(A_Index, column)

			if wizard.isApplicationOptional(name)
				wizard.selectApplication(name, checked.Has(name) ? checked[name] : false, false)
			else
				listView.Modify(A_Index, "Check")
		}

		if update
			wizard.updateState()
	}

	loadApplications(simulators := true) {
		local wizard := this.SetupWizard
		local definition := this.Definition
		local icons := []
		local rows := []
		local stdApplications := []
		local application, simulator, descriptor, executable, iconFile
		local listViewIcons, ignore, icon, row, ignore, section, category, descriptor

		static first1 := true
		static first2 := true

		if simulators {
			this.iSimulatorsListView.Delete()

			for simulator, descriptor in getMultiMapValues(wizard.Definition, definition[1]) {
				if wizard.isApplicationInstalled(simulator) {
					descriptor := string2Values("|", descriptor)

					executable := wizard.applicationPath(simulator)

					iconFile := findInstallProperty(simulator, "DisplayIcon")

					if iconFile
						icons.Push(iconFile)
					else if executable
						icons.Push(executable)
					else
						icons.Push("")

					rows.Push(Array((wizard.isApplicationSelected(simulator) ? "Check Icon" : "Icon") . (rows.Length + 1), simulator, executable ? executable : translate("Not installed")))
				}
			}

			listViewIcons := IL_Create(icons.Length)

			for ignore, icon in icons
				IL_Add(listViewIcons, icon)

			this.iSimulatorsListView.SetImageList(listViewIcons)

			for ignore, row in rows
				this.iSimulatorsListView.Add(row*)

			if first1 {
				this.iSimulatorsListView.ModifyCol(1, "AutoHdr")
				this.iSimulatorsListView.ModifyCol(2, "AutoHdr")

				first1 := false
			}
		}
		else {
			this.iApplicationsListView.Delete()

			for ignore, section in string2Values(",", definition[2]) {
				category := ConfigurationItem.splitDescriptor(section)[2]

				for application, descriptor in getMultiMapValues(wizard.Definition, section) {
					if (wizard.isApplicationSelected(application) || wizard.isApplicationInstalled(application) || !wizard.isApplicationOptional(application)) {
						descriptor := string2Values("|", descriptor)

						executable := wizard.applicationPath(application)

						this.iApplicationsListView.Add(wizard.isApplicationSelected(application) ? "Check" : "", translate(category), application, executable ? executable : translate("Not installed"))

						stdApplications.Push(application)
					}
				}
			}

			for ignore, application in wizard.installedApplications()
				if !inList(stdApplications, application) {
					executable := wizard.applicationPath(application)

					this.iApplicationsListView.Add(wizard.isApplicationSelected(application) ? "Check" : "", translate("Other"), application, executable ? executable : translate("Not installed"))
				}

			if first2 {
				this.iApplicationsListView.ModifyCol(1, "AutoHdr")
				this.iApplicationsListView.ModifyCol(2, "AutoHdr")
				this.iApplicationsListView.ModifyCol(3, "AutoHdr")

				first2 := false
			}
		}
	}

	locateSimulator(name, fileName) {
		local wizard := this.SetupWizard
		local wasInstalled := wizard.isApplicationInstalled(name)

		wizard.locateApplication(name, fileName, false)

		if !wasInstalled
			wizard.selectApplication(name, true, false)

		this.loadApplications(true)
	}

	locateApplication(name, fileName) {
		local wizard := this.SetupWizard
		local wasInstalled := wizard.isApplicationInstalled(name)

		wizard.locateApplication(name, fileName, false)

		if !wasInstalled
			wizard.selectApplication(name, true, false)

		this.loadApplications(false)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeApplicationsStepWizard() {
	SetupWizard.Instance.registerStepWizard(ApplicationsStepWizard(SetupWizard.Instance, "Applications", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeApplicationsStepWizard()