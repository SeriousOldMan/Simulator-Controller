;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Quick Setup Step Wizard         ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\Task.ahk"


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
		this.quickSetup()

		return super.showPage(page)
	}

	hidePage(page) {
		return super.hidePage(page)
	}

	detectSimulators(&progressCount) {
		local task := PeriodicTask((*) => showProgress({progress: progressCount++, message: "Detecting Simulators..."}), 100, kHighPriority)

		try {
			task.start()

			try {
				this.SetupWizard.Steps["Applications"].updateAvailableApplications(true)

				Sleep(1000)
			}
			finally {
				task.stop()
			}
		}
		catch Any as exception {
			showProgress({color: "Red", message: translate("Error while detecting Simulators...")})

			Sleep(1000)

			logError(exception, true)
		}
	}

	installRuntimes(&progressCount) {
		local wizard := this.SetupWizard
		local runtime, definition

		for runtime, definition in getMultiMapValues(wizard.Definition, "Applications.Runtimes")
			if !wizard.isSoftwareInstalled(runtime)
				try {
					showProgress({progress: progressCount++, color: "Green", message: translate("Installing ") . runtime . translate("...")})

					definition := string2Values("|", definition)

					RunWait(kHomeDirectory . definition[2])

					wizard.locateSoftware(runtime, true)
				}
				catch Any as exception {
					showProgress({color: "Red", message: translate("Error while installing ") . runtime . translate("...")})

					Sleep(1000)

					logError(exception, true)
				}
	}

	installSoftware(&progressCount) {
		local wizard := this.SetupWizard
		local software, definition

		for software, definition in getMultiMapValues(wizard.Definition, "Applications.Special")
			if !wizard.isSoftwareInstalled(software)
				try {
					showProgress({progress: progressCount++, color: "Green", message: translate("Installing ") . software . translate("...")})

					definition := string2Values(":", string2Values("|", definition)[4])

					wizard.locateSoftware(software, %definition[1]%.Call(definition[2]), false)
				}
				catch Any as exception {
					showProgress({color: "Red", message: translate("Error while installing ") . software . translate("...")})

					Sleep(1000)

					logError(exception, true)
				}
	}

	installPlugins(&progressCount) {
		Sleep(1000)
	}

	quickSetup() {
		local progressCount := 0

		this.SetupWizard.Window.block()

		showProgress({color: "Blue", title: "Preparing Configuration"})

		try {
			showProgress({progress: ++progressCount, messsage: translate("Create Configuration...")})

			Sleep(1000)

			showProgress({progress: ++progressCount, message: translate("Parsing Registry...")})

			loop 10 {
				Sleep(500)

				showProgress({progress: ++progressCount})
			}

			showProgress({progress: progressCount++, message: translate("Detecting Simulators...")})

			this.detectSimulators(&progressCount)

			showProgress({color: "Green", title: translate("Install Runtimes")})

			this.installRuntimes(&progressCount)

			showProgress({color: "Green", title: translate("Install Software")})

			this.installSoftware(&progressCount)

			showProgress({color: "Green", title: translate("Install Plugins")})

			this.installPlugins(&progressCount)

			showProgress({progress: 100, message: translate("Finished...")})

			Sleep(1000)
		}
		finally {
			hideProgress()

			this.SetupWizard.Window.unblock()

			this.SetupWizard.updateState()
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

installMSI(command) {
	RunWait(kHomeDirectory . command)

	return false
}

installNirCmd(path) {
	DirCreate(A_Temp . "\Simulator Controller\Temp")
	DirCreate(kUserHomeDirectory . "Programs")

	RunWait("PowerShell.exe -Command Expand-Archive -LiteralPath '" . kHomeDirectory . path . "' -DestinationPath '" . A_Temp . "\Simulator Controller\Temp'", , "Hide")

	FileCopy(A_Temp . "\Simulator Controller\Temp\nircmd.exe", kUserHomeDirectory . "Programs", 1)

	return (kUserHomeDirectory . "Programs\nircmd.exe")
}

installSoX(command) {
	RunWait(kHomeDirectory . command)

	return false
}

initializeQuickSetupStepWizard() {
	SetupWizard.Instance.registerStepWizard(QuickSetupStepWizard(SetupWizard.Instance, "Quick", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeQuickSetupStepWizard()