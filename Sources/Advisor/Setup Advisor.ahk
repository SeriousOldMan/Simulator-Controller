;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Setup Advisor                   ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#SingleInstance Force			; Ony one instance allowed
#NoEnv							; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn							; Enable warnings to assist with detecting common errors.
#Warn LocalSameAsGlobal, Off

SendMode Input					; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.

SetBatchLines -1				; Maximize CPU utilization
ListLines Off					; Disable execution history

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Setup.ico
;@Ahk2Exe-ExeName Setup Advisor.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\RuleEngine.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kOk = "ok"
global kCancel = "cancel"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Classes Section                          ;;;
;;;-------------------------------------------------------------------------;;;

class SetupAdvisor extends ConfigurationItem {
	
	createKnowledgeBase(facts, simulatorRules) {
		local rules
		
		FileRead rules, % kResourcesDirectory . "Advisor\Setup Advisor.rules"
		
		productions := false
		reductions := false

		new RuleCompiler().compileRules(rules, productions, reductions)
		
		engine := new RuleEngine(productions, reductions, facts)
		
		return new KnowledgeBase(engine, engine.createFacts(), engine.createRules())
	}
	
	loadSimulator(simulator, force := false) {
		local knowledgeBase
		
		if (force || (simulator != this.SelectedSimulator)) {
			window := this.Window
		
			Gui %window%:Default
			
			this.iSelectedSimulator := simulator
			
			if !definition
				definition := this.Definition
			
			this.iKnowledgeBase := this.createKnowledgeBase({})
			
			this.iSteps := {}
			this.iStep := 0
			this.iPage := 0
			
			count := 0
			
			for descriptor, step in getConfigurationSectionValues(definition, "Setup.Steps") {
				descriptor := ConfigurationItem.splitDescriptor(descriptor)
			
				stepWizard := this.StepWizards[step]
				
				if stepWizard {
					this.Steps[step] := stepWizard
					this.Steps[descriptor[2]] := stepWizard
					this.Steps[stepWizard] := descriptor[2]
				
					count := Max(count, descriptor[2])
				}
			}
			
			Loop %count% {
				step := this.Steps[A_Index]
			
				vProgressCount += 2
				
				showProgress({progress: vProgressCount})
			
				if step {
					stepDefinition := readConfiguration(kResourcesDirectory . "Setup\Definitions\" . step.Step . " Step.ini")
					
					setConfigurationSectionValues(definition, "Setup." . step.Step, getConfigurationSectionValues(stepDefinition, "Setup." . step.Step, Object()))
					
					step.loadDefinition(definition, getConfigurationValue(definition, "Setup." . step.Step, step.Step . ".Definition", Object()))
				}
			}
			
			this.iCount := count
			
			if (GetKeyState("Ctrl") && GetKeyState("Shift")) {
				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
				title := translate("Setup")
				MsgBox 262436, %title%, % translate("Do you really want to start with a fresh configuration?")
				OnMessage(0x44, "")
				
				IfMsgBox Yes
					initialize := true
				else
					initialize := false
			}
			else
				initialize  := false

			showProgress({progress: ++vProgressCount, message: translate("Initializing AI kernel...")})
			
			if initialize {
				for ignore, fileName in ["Button Box Configuration.ini", "Stream Deck Configuration.ini", "Voice Control Configuration.ini", "Race Engineer Configuration.ini", "Race Strategist Configuration.ini", "Simulator Settings.ini"]
					try {
						FileDelete %kUserHomeDirectory%Setup\%fileName%
					}
					catch exception {
						; ignore
					}
				
				this.KnowledgeBase.addFact("Initialize", true)
			}
			else if !this.loadKnowledgeBase()
				this.KnowledgeBase.addFact("Initialize", true)
			
			if isDebug()
				Sleep 1000

			showProgress({progress: ++vProgressCount, message: translate("Starting AI kernel...")})
				
			this.KnowledgeBase.produce()
						
			if this.Debug[kDebugKnowledgeBase]
				this.dumpKnowledge(this.KnowledgeBase)
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                        Private Function Section                         ;;;
;;;-------------------------------------------------------------------------;;;

runSetupAdvisor() {
	icon := kIconsDirectory . "Setup.ico"
	
	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Setup Advisor
}


;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

runSetupAdvisor()