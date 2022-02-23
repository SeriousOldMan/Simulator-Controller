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
	iDebug := kDebugOff
	
	iSelectedSimulator := false
	iSelectedCar := false
	iSelectedTrack := false
	iSelectedWeather := "Dry"
	
	iKnowledgeBase := false
	
	Debug[option] {
		Get {
			return (this.iDebug & option)
		}
	}
	
	SelectedSimulator[] {
		Get {
			return this.iSelectedSimulator
		}
	}
	
	SelectedCar[] {
		Get {
			return this.iSelectedCar
		}
	}
	
	SelectedTrack[] {
		Get {
			return this.iSelectedTrack
		}
	}
	
	SelectedWeather[] {
		Get {
			return this.iSelectedWeather
		}
	}
	
	KnowledgeBase[] {
		Get {
			return this.iKnowledgeBase
		}
	}
	
	setDebug(option, enabled) {
		if enabled
			this.iDebug := (this.iDebug | option)
		else if (this.Debug[option] == option)
			this.iDebug := (this.iDebug - option)
	}
	
	loadRules(definition, ByRef productions, ByRef reductions) {
		local rules
		
		FileRead rules, % kResourcesDirectory . "Advisor\Rules\Setup Advisor.rules"
		
		productions := false
		reductions := false

		compiler := new RuleCompiler()
		
		compiler.compileRules(rules, productions, reductions)
		
		fileName := substituteVariables(getConfigurationValue(definition, "Simulator", "Rules", ""))
		
		if (fileName && (fileName != "")) {
			FileRead rules, %fileName%
			
			compiler.compileRules(rules, productions, reductions)
		}
	}
	
	createKnowledgeBase(facts, productions, reductions) {
		engine := new RuleEngine(productions, reductions, facts)
		
		return new KnowledgeBase(engine, engine.createFacts(), engine.createRules())
	}
	
	loadSimulator(simulator, force := false) {
		local knowledgeBase
		
		if (force || (simulator != this.SelectedSimulator)) {
			window := this.Window
		
			Gui %window%:Default
			
			this.iSelectedSimulator := simulator
			
			definition := readConfiguration(kResourcesDirectory . "Advisor\Definitions\" . simulator . ".ini")
			
			productions := false
			reductions := false
		
			this.loadRules(definition, productions, reductions)
			
			this.iKnowledgeBase := this.createKnowledgeBase({}, productions, reductions)
			
			this.KnowledgeBase.addFact("Initialize", true)
				
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