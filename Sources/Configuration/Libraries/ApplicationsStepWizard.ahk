;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Applications Step Wizard        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Private Constant Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global ApplicationClass := Application	; Spooky, sometimes the reference to Application is lost


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ApplicationsStepWizard                                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ApplicationsStepWizard extends StepWizard {
	iSimulatorsListView := false
	iApplicationsListView := false

	Pages[] {
		Get {
			return 2
		}
	}

	saveToConfiguration(configuration) {
		local wizard := this.SetupWizard
		local definition := this.Definition
		local groups := {}
		local simulators := []
		local ignore, applications, theApplication, descriptor, exePath, workingDirectory, hooks, group

		base.saveToConfiguration(configuration)

		for ignore, applications in concatenate([definition[1]], string2Values(",", definition[2]))
			for theApplication, ignore in getConfigurationSectionValues(wizard.Definition, applications)
				if (((applications != "Applications.Simulators") || wizard.isApplicationInstalled(theApplication)) && wizard.isApplicationSelected(theApplication)) {
					descriptor := getApplicationDescriptor(theApplication)

					exePath := wizard.applicationPath(theApplication)

					if !exePath
						exePath := ""

					SplitPath exePath, , workingDirectory

					hooks := string2Values(";", descriptor[5])

					new ApplicationClass(theApplication, false, exePath, workingDirectory, descriptor[4], hooks[1], hooks[2], hooks[3]).saveToConfiguration(configuration)

					group := ConfigurationItem.splitDescriptor(applications)[2]

					if (group = "Simulators") {
						simulators.Push(theApplication)

						group := "Other"
					}

					if !groups.HasKey(group)
						groups[group] := []

					groups[group].Push(theApplication)
				}

		for group, applications in groups
			for ignore, theApplication in applications
				setConfigurationValue(configuration, "Applications", group . "." . A_Index, theApplication)
	}

	createGui(wizard, x, y, width, height) {
		local window := this.Window
		local simulatorsIconHandle := false
		local simulatorsLabelHandle := false
		local simulatorsListViewHandle := false
		local simulatorsInfoTextHandle := false
		local applicationsIconHandle := false
		local applicationsLabelHandle := false
		local applicationsListViewHandle := false
		local applicationsInfoTextHandle
		local labelWidth := width - 30
		local labelX := x + 35
		local labelY := y + 8
		local application, info, html

		static simulatorsInfoText

		Gui %window%:Default

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDsimulatorsIconHandle Hidden, %kResourcesDirectory%Setup\Images\Gaming Wheel.ico
		Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h26 HWNDsimulatorsLabelHandle Hidden, % translate("Simulations")

		Gui %window%:Font, s8 Norm, Arial

		Gui %window%:Add, ListView, x%x% yp+30 w%width% h200 -Multi -LV0x10 Checked NoSort NoSortHdr HWNDsimulatorsListViewHandle Hidden, % values2String("|", map(["Simulation", "Path"], "translate")*)

		info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Applications", "Applications.Simulators.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='width: 90%'>" . info . "</div>"

		Sleep 200

		Gui %window%:Add, ActiveX, x%x% yp+205 w%width% h180 HWNDsimulatorsInfoTextHandle VsimulatorsInfoText Hidden, shell.explorer

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		simulatorsInfoText.Navigate("about:blank")
		simulatorsInfoText.Document.Write(html)

		this.iSimulatorsListView := simulatorsListViewHandle

		this.registerWidgets(1, simulatorsIconHandle, simulatorsLabelHandle, simulatorsListViewHandle, simulatorsInfoTextHandle)

		applicationsIconHandle := false
		applicationsLabelHandle := false
		applicationsListViewHandle := false
		applicationsInfoTextHandle := false

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDapplicationsIconHandle Hidden, %kResourcesDirectory%Setup\Images\Tool Chest.ico
		Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h26 HWNDapplicationsLabelHandle Hidden, % translate("Applications && Tools")

		Gui %window%:Font, s8 Norm, Arial

		Gui %window%:Add, ListView, x%x% yp+30 w%width% h260 -Multi -LV0x10 AltSubmit Checked NoSort NoSortHdr HWNDapplicationsListViewHandle GupdateSelectedApplications Hidden, % values2String("|", map(["Category", "Application", "Path"], "translate")*)

		info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Applications", "Applications.Applications.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='width: 90%'>" . info . "</div>"

		Sleep 200

		Gui %window%:Add, ActiveX, x%x% yp+265 w%width% h120 HWNDapplicationsInfoTextHandle VapplicationsInfoText Hidden, shell.explorer

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		applicationsInfoText.Navigate("about:blank")
		applicationsInfoText.Document.Write(html)

		this.iApplicationsListView := applicationsListViewHandle

		this.registerWidgets(2, applicationsIconHandle, applicationsLabelHandle, applicationsListViewHandle, applicationsInfoTextHandle)
	}

	loadStepDefinition(definition) {
		base.loadStepDefinition(definition)

		if !FileExist(kUserHomeDirectory . "Setup\Simulator Setup.data")
			this.updateAvailableApplications(true)
	}

	reset() {
		base.reset()

		this.iSimulatorsListView := false
		this.iApplicationsListView := false
	}

	updateState() {
		base.updateState()

		if (this.Definition && (SetupWizard.Instance.Step == this))
			this.updateAvailableApplications()
	}

	showPage(page) {
		local wizard := this.SetupWizard
		local definition := this.Definition
		local icons := []
		local rows := []
		local application, simulator, descriptor, executable, iconFile
		local listViewIcons, ignore, icon, row, ignore, section, category, descriptor

		this.updateAvailableApplications()

		base.showPage(page)

		static first1 := true
		static first2 := true

		if (page == 1) {
			Gui ListView, % this.iSimulatorsListView

			LV_Delete()

			for simulator, descriptor in getConfigurationSectionValues(wizard.Definition, definition[1]) {
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

					rows.Push(Array((wizard.isApplicationSelected(simulator) ? "Check Icon" : "Icon") . (rows.Length() + 1), simulator, executable ? executable : translate("Not installed")))
				}
			}

			listViewIcons := IL_Create(icons.Length())

			for ignore, icon in icons
				IL_Add(listViewIcons, icon)

			LV_SetImageList(listViewIcons)

			for ignore, row in rows
				LV_Add(row*)

			if first1 {
				LV_ModifyCol(1, "AutoHdr")
				LV_ModifyCol(2, "AutoHdr")

				first1 := false
			}
		}
		else if (page == 2) {
			Gui ListView, % this.iApplicationsListView

			LV_Delete()

			for ignore, section in string2Values(",", definition[2]) {
				category := ConfigurationItem.splitDescriptor(section)[2]

				for application, descriptor in getConfigurationSectionValues(wizard.Definition, section) {
					if (wizard.isApplicationSelected(application) || wizard.isApplicationInstalled(application) || !wizard.isApplicationOptional(application)) {
						descriptor := string2Values("|", descriptor)

						executable := wizard.applicationPath(application)

						LV_Add(wizard.isApplicationSelected(application) ? "Check" : "", category, application, executable ? executable : translate("Not installed"))
					}
				}
			}

			if first2 {
				LV_ModifyCol(1, "AutoHdr")
				LV_ModifyCol(2, "AutoHdr")
				LV_ModifyCol(3, "AutoHdr")

				first2 := false
			}
		}
	}

	hidePage(page) {
		this.updateSelectedApplications(page, false)

		return base.hidePage(page)
	}

	updateAvailableApplications(initialize := false) {
		local wizard := this.SetupWizard
		local definition := this.Definition
		local application, ignore, section, application, category

		for ignore, section in concatenate([definition[1]], string2Values(",", definition[2])) {
			category := ConfigurationItem.splitDescriptor(section)[2]

			for application, ignore in getConfigurationSectionValues(wizard.Definition, section) {
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
		local checked := {}
		local row := 0
		local name

		Gui ListView, % ((page == 1) ? [this.iSimulatorsListView] : [this.iApplicationsListView])

		loop {
			row := LV_GetNext(row, "C")

			if row {
				LV_GetText(name, row, column)

				checked[name] := true
			}
			else
				break
		}

		loop % LV_GetCount()
		{
			LV_GetText(name, A_Index, column)

			if wizard.isApplicationOptional(name)
				wizard.selectApplication(name, checked.HasKey(name) ? checked[name] : false, false)
			else
				LV_Modify(A_Index, "Check")
		}

		if update
			wizard.updateState()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

updateSelectedApplications() {
	loop % LV_GetCount()
		LV_Modify(A_Index, "-Select")

	if ((A_GuiEvent = "Normal") || (A_GuiEvent = "RightClick"))
		SetupWizard.Instance.StepWizards["Applications"].updateSelectedApplications(SetupWizard.Instance.Page, false)
}

initializeApplicationsStepWizard() {
	SetupWizard.Instance.registerStepWizard(new ApplicationsStepWizard(SetupWizard.Instance, "Applications", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeApplicationsStepWizard()