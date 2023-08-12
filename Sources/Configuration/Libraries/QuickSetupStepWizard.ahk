;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Quick Setup Step Wizard         ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; QuickSetupStepWizard                                                    ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class QuickSetupStepWizard extends StepWizard {
	Pages {
		Get {
			return (1 + (this.SetupWizard.QuickSetup ? 1 : 0))
		}
	}

	saveToConfiguration(configuration) {

	}

	createGui(wizard, x, y, width, height) {

	}

	showPage(page) {
		return super.showPage(page)
	}

	hidePage(page) {
		return super.hidePage(page)
	}

	installRuntimes() {
	}

	installPlugins() {
	}

	installSoftware(software) {
		local wizard := this.SetupWizard
		local folder := getMultiMapValue(wizard.Definition, "Setup.Installation", "Installation." . software . ".Folder", false)
		local locatable, installer, extension, buttons, button

		if !wizard.isSoftwareInstalled(software)
			if folder
				Run("explore " . substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Installation", "Installation." . software)))
			else {
				locatable := getMultiMapValue(wizard.Definition, "Setup.Installation", "Installation." . software . ".Locatable", true)
				installer := substituteVariables(getMultiMapValue(wizard.Definition, "Setup.Installation", "Installation." . software))

				SplitPath(installer, , , &extension)

				if (!locatable || (extension = "EXE") || (extension = "MSI")) {
					RunWait(installer)

					wizard.locateSoftware(software)

					if (wizard.isSoftwareInstalled(software) && this.iSoftwareLocators.Has(software))
					}
				}
				else
					Run(installer)
			}
	}


	installSoftware() {
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeQuickSetupStepWizard() {
	SetupWizard.Instance.registerStepWizard(QuickSetupStepWizard(SetupWizard.Instance, "Quick", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeQuickSetupStepWizard()