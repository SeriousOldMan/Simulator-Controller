;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Team Server Configuration       ;;;
;;;                                         Plugin                          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Task.ahk"
#Include "..\Configuration\Libraries\TeamManagementPanel.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; TeamServerConfigurator                                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class TeamServerConfigurator extends TeamManagementPanel {
	iInitialized := false

	Initialized {
		Get {
			return this.iInitialized
		}
	}

	__New(editor, configuration := false) {
		super.__New(editor, configuration)

		TeamServerConfigurator.Instance := this
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
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeTeamServerConfigurator() {
	local editor, configurator

	launchTeam() {
		if editor.Window {
			editor.Control["configuratorTabView"].Value := inList(editor.Configurators["OBJECT"], configurator)

			configurator.activate()
		}
		else
			return Task.CurrentTask
	}

	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance
		configurator := TeamServerConfigurator(editor, editor.Configuration)

		editor.registerConfigurator(translate("Team Server"), configurator
								  , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-team-server")

		if inList(A_Args, "-Team")
			Task.startTask(launchTeam, 2000)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeTeamServerConfigurator()