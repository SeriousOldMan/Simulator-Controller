;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Installation Step Wizard        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; InstallationStepWizard                                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class InstallationStepWizard extends StepWizard {
	iPages := CaseInsenseMap()
	iSoftwareLocators := CaseInsenseMap()

	Pages {
		Get {
			return (this.SetupWizard.BasicSetup ? 0 : Ceil(this.Definition.Length / 3))
		}
	}

	createGui(wizard, x, y, width, height) {
		local window := this.Window
		local definition := this.Definition
		local startY := y
		local ignore, software, installer, folder, locatable, info, label, installed, buttonX
		local labelWidth, labelX, labelY, buttonY, page, html, factor

		installSoftware(software, *) {
			this.installSoftware(software)
		}

		locateSoftware(software, *) {
			local definition := this.Definition
			local folder := getMultiMapValue(this.SetupWizard.Definition, "Setup.Installation", "Installation." . software . ".Folder", false)
			local fileName

			if folder
				Run("explore " . substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Installation", "Installation." . software)))
			else {
				window.Opt("+OwnDialogs")

				OnMessage(0x44, translateSelectCancelButtons)
				fileName := FileSelect(1, "", substituteVariables(translate("Select %name% executable..."), {name: software}), "Executable (*.exe)")
				OnMessage(0x44, translateSelectCancelButtons, 0)

				if (fileName != "")
					this.locateSoftware(software, fileName)
			}
		}

		for ignore, software in this.Definition {
			installer := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Installation", "Installation." . software))
			folder := getMultiMapValue(this.SetupWizard.Definition, "Setup.Installation", "Installation." . software . ".Folder", false)
			locatable := getMultiMapValue(this.SetupWizard.Definition, "Setup.Installation", "Installation." . software . ".Locatable", true)
			info := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Installation", "Installation." . software . ".Info." . getLanguage()))

			label := (translate("Software: ") . software)
			info := "<div style='font-family: Arial, Helvetica, sans-serif; font-size: 11px'><hr style='border-width:1pt;border-color:#AAAAAA;color:#AAAAAA;width: 90%'>" . info . "</div>"

			installed := (folder ? false : this.SetupWizard.isSoftwareInstalled(software))

			buttonX := x + width - 90

			if locatable
				buttonX -= 95

			labelWidth := width - 60 - 90 - (locatable * 95)
			labelX := x + 35
			labelY := y + 8

			factor := (Mod(A_Index - 1, 3) * 0.33)

			widget1 := window.Add("Picture", "x" . x . " y" . y . " w30 h30 Y:Move(" . factor . ") Hidden", kResourcesDirectory . "Setup\Images\Install.png")

			window.SetFont("s10 Bold", "Arial")

			widget2 := window.Add("Text", "x" . labelX . " y" . labelY . " w" . labelWidth . " h26 Y:Move(" . factor . ") Hidden", label)

			window.SetFont("s8 Norm", "Arial")

			buttonY := y + 5

			widget3 := window.Add("Button", "x" . buttonX . " y" . buttonY . " w90 h23 X:Move Y:Move(" . factor . ") Hidden"
								, folder ? translate("Open...") : (InStr(installer, "http") = 1) ? translate("Download...") : translate("Install..."))
			widget3.OnEvent("Click", installSoftware.Bind(software))

			if locatable {
				buttonX += 95

				widget4 := window.Add("Button", "x" . buttonX . " y" . buttonY . " w90 h23 X:Move Y:Move(" . factor . ") Hidden"
									, installed ? translate("Installed") : translate("Locate..."))
				widget4.OnEvent("Click", locateSoftware.Bind(software))
			}

			widget5 := window.Add("HTMLViewer", "x" . x . " yp+33 w" . width . " h117 Y:Move(" . factor . ") W:Grow H:Grow(0.33) Hidden")

			html := "<html><body style='background-color: #" . window.BackColor . "' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

			widget5.document.write(html)

			y += 163

			page := Ceil(A_Index / 3)

			this.registerWidgets(page, widget1, widget2, widget3, widget5)

			if locatable
				this.registerWidget(page, widget4)

			this.iSoftwareLocators[software] := (locatable ? [widget3, widget4] : [widget3])

			if !this.iPages.Has(page)
				this.iPages[page] := CaseInsenseMap()

			this.iPages[page][software] := (locatable ? [widget3, widget4] : [widget3])

			if (((A_Index / 3) - Floor(A_Index / 3)) == 0)
				y := startY
		}
	}

	startSetup(new) {
		local ignore, software

		for ignore, software in this.Definition
			if new
				this.SetupWizard.locateSoftware(software)
			else
				this.SetupWizard.locateSoftware(software, "CHECK")
	}

	reset() {
		super.reset()

		this.iPages := CaseInsenseMap()
		this.iSoftwareLocators := CaseInsenseMap()
	}

	installSoftware(software) {
		local wizard := this.SetupWizard
		local folder := getMultiMapValue(wizard.Definition, "Setup.Installation", "Installation." . software . ".Folder", false)
		local locatable, installer, extension, buttons, button

		if folder
			Run("explore " . substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Installation", "Installation." . software)))
		else {
			locatable := getMultiMapValue(wizard.Definition, "Setup.Installation", "Installation." . software . ".Locatable", true)
			installer := substituteVariables(getMultiMapValue(wizard.Definition, "Setup.Installation", "Installation." . software))

			SplitPath(installer, , , &extension)

			if (!locatable || (extension = "EXE") || (extension = "MSI")) {
				RunWait(installer)

				wizard.locateSoftware(software)

				if (wizard.isSoftwareInstalled(software) && this.iSoftwareLocators.Has(software)) {
					buttons := this.iSoftwareLocators[software]

					buttons[1].Enabled := false

					if (buttons.Length > 1) {
						button := buttons[2]

						button.Enabled := false
						button.Text := translate("Installed")
					}
					else {
						button := buttons[1]

						button.Text := translate("Installed")
					}
				}
			}
			else
				Run(installer)
		}
	}

	locateSoftware(software, executable) {
		local buttons, button

		this.SetupWizard.locateSoftware(software, executable)

		buttons := this.iSoftwareLocators[software]

		buttons[1].Enabled := false

		button := buttons[2]

		button.Enabled := false
		button.Text := translate("Installed")
	}

	showPage(page) {
		local software, widgets, ignore, widget, buttons, button

		super.showPage(page)

		for software, widgets in this.iPages[page]
			if !getMultiMapValue(this.SetupWizard.Definition, "Setup.Installation", "Installation." . software . ".Folder", false)
				if !this.SetupWizard.isSoftwareRequested(software) {
					for ignore, widget in widgets
						widget.Enabled := false
				}
				else {
					this.SetupWizard.locateSoftware(software)

					if (this.SetupWizard.isSoftwareInstalled(software) && this.iSoftwareLocators.Has(software)) {
						buttons := this.iSoftwareLocators[software]

						buttons[1].Enabled := false

						if (buttons.Length > 1) {
							button := buttons[2]

							button.Enabled := false
							button.Text := translate("Installed")
						}
						else {
							button := buttons[1]

							button.Text := translate("Installed")
						}
					}
				}
	}

	hidePage(page) {
		local wizard := this.SetupWizard
		local done := true
		local software, ignore, msgResult

		for software, ignore in this.iPages[page]
			if (wizard.isSoftwareRequested(software) && !wizard.isSoftwareOptional(software) && !wizard.isSoftwareInstalled(software)) {
				done := false

				break
			}

		if !done {
			OnMessage(0x44, translateYesNoButtons)
			msgResult := MsgBox(translate("Not all required software components have been installed. Do you really want to proceed?"), translate("Setup "), 262436)
			OnMessage(0x44, translateYesNoButtons, 0)

			if (msgResult = "No")
				return false
		}

		return super.hidePage(page)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeInstallationStepWizard() {
	SetupWizard.Instance.registerStepWizard(InstallationStepWizard(SetupWizard.Instance, "Installation", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeInstallationStepWizard()

