;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AI Race Engineer                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\RuleEngine.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kAlways = "Always"

global kFront = 0
global kRear = 1
global kLeft = 2
global kRight = 3
global kCenter = 4


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceEngineer extends ConfigurationItem {
	iPlugin := false
	iSettings := false
	iKnowledgeBase := false
	iOverallTime := 0
	iLastLap := 0
	iLastFuelAmount := 0
	iInitialFuelAmount := 0
	
	class RaceKnowledgeBase extends KnowledgeBase {
		iEngineer := false
		
		RaceEngineer[] {
			Get {
				return this.iRaceEngineer
			}
		}
		
		__New(raceEngineer, ruleEngine, facts, rules) {
			this.iRaceEngineer := raceEngineer
			
			base.__New(ruleEngine, facts, rules)
		}
	}
	
	Plugin[] {
		Get {
			return this.iPlugin
		}
	}
	
	Settings[] {
		Get {
			return this.iSettings
		}
	}
	
	KnowledgeBase[] {
		Get {
			return this.iKnowledgeBase
		}
	}
	
	OverallTime[] {
		Get {
			return this.iOverallTime
		}
	}
	
	LastLap[] {
		Get {
			return this.iLastLap
		}
	}
	
	InitialFuelAmount[] {
		Get {
			return this.iInitialFuelAmount
		}
	}
	
	LastFuelAmount[] {
		Get {
			return this.iLastFuelAmount
		}
	}
	
	__New(plugin, configuration, settings) {
		this.iPlugin := plugin
		this.iSettings := settings
		
		base.__New(configuration)
	}
	
	createRace(data) {
		local facts
		
		settings := this.Settings
		
		duration := Round((getConfigurationValue(data, "Stint Data", "TimeRemaining", 0) + getConfigurationValue(data, "Stint Data", "LapLastTime", 0)) / 1000)
		
		facts := {"Race.Car": getConfigurationValue(data, "Race Data", "Car", "")
				, "Race.Track": getConfigurationValue(data, "Race Data", "Track", "")
				, "Race.Duration": duration
				, "Race.Settings.OutLap": getConfigurationValue(settings, "Race Settings", "OutLap", true)
				, "Race.Settings.InLap": getConfigurationValue(settings, "Race Settings", "InLap", true)
				, "Race.Settings.Fuel.AvgConsumption": getConfigurationValue(settings, "Race Settings", "Fuel.AvgConsumption", 0)
				, "Race.Settings.Fuel.SafetyMargin": getConfigurationValue(settings, "Race Settings", "Fuel.SafetyMargin", 5)
				, "Race.Settings.Lap.PitstopWarning": getConfigurationValue(settings, "Race Settings", "Lap.PitstopWarning", 5)
				, "Race.Settings.Lap.AvgTime": getConfigurationValue(settings, "Race Settings", "Lap.AvgTime", 0)
				, "Race.Settings.Lap.Considered": getConfigurationValue(settings, "Race Settings", "Lap.Considered", 5)
				, "Race.Settings.Damage.Suspension.Repair": getConfigurationValue(settings, "Race Settings", "Damage.Suspension.Repair", "Always")
				, "Race.Settings.Damage.Suspension.Repair.Threshold": getConfigurationValue(settings, "Race Settings", "Damage.Suspension.Repair.Threshold", 0)
				, "Race.Settings.Damage.Bodywork.Repair": getConfigurationValue(settings, "Race Settings", "Damage.Bodywork.Repair", "Threshold")
				, "Race.Settings.Damage.Bodywork.Repair.Threshold": getConfigurationValue(settings, "Race Settings", "Damage.Bodywork.Repair.Threshold", 20)
				, "Race.Settings.Tyre.Dry.Pressure.Target.FL": getConfigurationValue(settings, "Race Settings", "Tyre.Dry.Pressure.Target.FL", 27.7)
				, "Race.Settings.Tyre.Dry.Pressure.Target.FR": getConfigurationValue(settings, "Race Settings", "Tyre.Dry.Pressure.Target.FR", 27.7)
				, "Race.Settings.Tyre.Dry.Pressure.Target.RL": getConfigurationValue(settings, "Race Settings", "Tyre.Dry.Pressure.Target.RL", 27.7)
				, "Race.Settings.Tyre.Dry.Pressure.Target.RR": getConfigurationValue(settings, "Race Settings", "Tyre.Dry.Pressure.Target.RR", 27.7)
				, "Race.Settings.Tyre.Wet.Pressure.Target.FL": getConfigurationValue(settings, "Race Settings", "Tyre.Wet.Pressure.Target.FL", 30.0)
				, "Race.Settings.Tyre.Wet.Pressure.Target.FR": getConfigurationValue(settings, "Race Settings", "Tyre.Wet.Pressure.Target.FR", 30.0)
				, "Race.Settings.Tyre.Wet.Pressure.Target.RL": getConfigurationValue(settings, "Race Settings", "Tyre.Wet.Pressure.Target.RL", 30.0)
				, "Race.Settings.Tyre.Wet.Pressure.Target.RR": getConfigurationValue(settings, "Race Settings", "Tyre.Wet.Pressure.Target.RR", 30.0)
				, "Race.Settings.Tyre.Pressure.Deviation": getConfigurationValue(settings, "Race Settings", "Tyre.Pressure.Deviation", 0.2)
				, "Race.Settings.Tyre.Set.Fresh": getConfigurationValue(settings, "Race Settings", "Tyre.Set.Fresh", 8)
				, "Race.Setup.Tyre.Compound": getConfigurationValue(settings, "Race Setup", "Tyre.Compound", "Dry")
				, "Race.Setup.Tyre.Set": getConfigurationValue(settings, "Race Setup", "Tyre.Set", 7)
				, "Race.Setup.Tyre.Pressure.FL": getConfigurationValue(settings, "Race Setup", "Tyre.Pressure.FL", 26.1)
				, "Race.Setup.Tyre.Pressure.FR": getConfigurationValue(settings, "Race Setup", "Tyre.Pressure.FR", 26.1)
				, "Race.Setup.Tyre.Pressure.RL": getConfigurationValue(settings, "Race Setup", "Tyre.Pressure.RL", 26.1)
				, "Race.Setup.Tyre.Pressure.RR": getConfigurationValue(settings, "Race Setup", "Tyre.Pressure.RR", 26.1)}
				
		return facts
	}
	
	startRace(data) {
		local facts := this.createRace(data)
		
		FileRead engineerRules, % getFileName("Race Engineer.rules", kConfigDirectory, kUserConfigDirectory)
		
		productions := false
		reductions := false

		new RuleCompiler().compileRules(engineerRules, productions, reductions)

		engine := new RuleEngine(productions, reductions, facts)
		
		this.iKnowledgeBase := new this.RaceKnowledgeBase(this, engine, engine.createFacts(), engine.createRules())
		this.iLastLap := 0
		this.iOverallTime := 0
		this.iLastFuelAmount := 0
		this.iInitialFuelAmount := 0
		
		this.KnowledgeBase.produce()
	}
	
	finishRace() {
		this.iKnowledgeBase := false
		this.iLastLap := 0
		this.iOverallTime := 0
		this.iLastFuelAmount := 0
		this.iInitialFuelAmount := 0
	}
	
	addLap(lapNumber, data) {
		local knowledgeBase
		local facts
		
		if !this.KnowledgeBase
			this.startRace(this.createRace(data))
		
		knowledgeBase := this.KnowledgeBase
		facts := knowledgeBase.Facts
		
		if (lapNumber == 1)
			facts.addFact("Lap", 2)
		else
			facts.setValue("Lap", lapNumber + 1)
			
		facts.addFact("Lap." . lapNumber . ".Driver", getConfigurationValue(data, "Race Data", "DriverName", ""))
		
		lapTime := getConfigurationValue(data, "Stint Data", "LapLastTime", 0)
		
		facts.addFact("Lap." . lapNumber . ".Time", lapTime)
		facts.addFact("Lap." . lapNumber . ".Time.Start", this.OverallTime)
		this.iOverallTime := this.OverallTime + lapTime
		facts.addFact("Lap." . lapNumber . ".Time.End", this.OverallTime)
		
		fuelRemaining := getConfigurationValue(data, "Car Data", "FuelRemaining", 0)
		
		facts.addFact("Lap." . lapNumber . ".Fuel.Remaining", Round(fuelRemaining, 2))
		
		if (lapNumber == 1) {
			this.iInitialFuelAmount := fuelRemaining
			this.iLastFuelAmount := fuelRemaining
			
			facts.addFact("Lap." . lapNumber . ".Fuel.AvgConsumption", 0)
			facts.addFact("Lap." . lapNumber . ".Fuel.Consumption", 0)
		}
		else {
			facts.addFact("Lap." . lapNumber . ".Fuel.AvgConsumption", Round((this.InitialFuelAmount - fuelRemaining) / (lapNumber - 1), 2))
			facts.addFact("Lap." . lapNumber . ".Fuel.Consumption", Round(this.iLastFuelAmount - fuelRemaining, 2))
			
			this.iLastFuelAmount := fuelRemaining
		}
		
		tyrePressures := string2Values(",", getConfigurationValue(data, "Car Data", "TyrePressure", ""))
		
		facts.addFact("Lap." . lapNumber . ".Tyre.Pressure.FL", Round(tyrePressures[1], 2))
		facts.addFact("Lap." . lapNumber . ".Tyre.Pressure.FR", Round(tyrePressures[2], 2))		
		facts.addFact("Lap." . lapNumber . ".Tyre.Pressure.RL", Round(tyrePressures[3], 2))
		facts.addFact("Lap." . lapNumber . ".Tyre.Pressure.RR", Round(tyrePressures[4], 2))
		
		tyreTemperatures := string2Values(",", getConfigurationValue(data, "Car Data", "TyreTemperature", ""))
		
		facts.addFact("Lap." . lapNumber . ".Tyre.Temperature.FL", Round(tyreTemperatures[1], 1))
		facts.addFact("Lap." . lapNumber . ".Tyre.Temperature.FR", Round(tyreTemperatures[2], 1))		
		facts.addFact("Lap." . lapNumber . ".Tyre.Temperature.RL", Round(tyreTemperatures[3], 1))
		facts.addFact("Lap." . lapNumber . ".Tyre.Temperature.RR", Round(tyreTemperatures[4], 1))
			
		facts.addFact("Lap." . lapNumber . ".Weather", 0)
		facts.addFact("Lap." . lapNumber . ".Temperature.Air", Round(getConfigurationValue(data, "Car Data", "AirTemperature", 0)))
		facts.addFact("Lap." . lapNumber . ".Temperature.Track", Round(getConfigurationValue(data, "Car Data", "RoadTemperature", 0)))
		
		bodyworkDamage := string2Values(",", getConfigurationValue(data, "Car Data", "BodyworkDamage", ""))
		
		facts.addFact("Lap." . lapNumber . ".Damage.Bodywork.Front", Round(bodyworkDamage[1], 2))
		facts.addFact("Lap." . lapNumber . ".Damage.Bodywork.Rear", Round(bodyworkDamage[2], 2))
		facts.addFact("Lap." . lapNumber . ".Damage.Bodywork.Left", Round(bodyworkDamage[3], 2))
		facts.addFact("Lap." . lapNumber . ".Damage.Bodywork.Right", Round(bodyworkDamage[4], 2))
		facts.addFact("Lap." . lapNumber . ".Damage.Bodywork.Center", Round(bodyworkDamage[5], 2))
		
		suspensionDamage := string2Values(",", getConfigurationValue(data, "Car Data", "SuspensionDamage", ""))
		
		facts.addFact("Lap." . lapNumber . ".Damage.Suspension.FL", Round(suspensionDamage[1], 2))
		facts.addFact("Lap." . lapNumber . ".Damage.Suspension.FR", Round(suspensionDamage[2], 2))
		facts.addFact("Lap." . lapNumber . ".Damage.Suspension.RL", Round(suspensionDamage[3], 2))
		facts.addFact("Lap." . lapNumber . ".Damage.Suspension.RR", Round(suspensionDamage[4], 2))
		
		knowledgeBase.produce()
	}
	
	hasPlannedPitstop() {
		return this.KnowledgeBase.getValue("Pitstop.Planned", false)
	}
	
	hasPreparedPitstop() {
		return this.KnowledgeBase.getValue("Pitstop.Prepared", false)
	}
	
	planPitstop(createDescription := false) {
		local knowledgeBase := this.KnowledgeBase
		
		knowledgeBase.addFact("Pitstop.Plan", true)
		
		result := knowledgeBase.produce()
		
		if createDescription {
			description := translate("Ok, we have the following for Pitstop number ") . kb.getValue("Pitstop.Planned.Nr") . translate(".")
				
			fuel := knowledgeBase.getValue("Pitstop.Planned.Fuel", 0)
			if (fuel == 0)
				description .= "`n" . translate("Refueling is not necessary.")
			else
				description .= "`n" . translate("We have to refuel ") . Round(fuel) . translate(" litres.")
			
			description .= "`n" . translate("We will use ") . kb.getValue("Pitstop.Planned.Tyre.Compound")
			description .= translate(" tyre compound and tyre set number ") . kb.getValue("Pitstop.Planned.Tyre.Set") . translate(".")
			
			description .= "`n" . translate("Pressure front left ") . Round(kb.getValue("Pitstop.Planned.Tyre.Pressure.FL"), 1) . translate(".")
			description .= "`n" . translate("Pressure front right ") . Round(kb.getValue("Pitstop.Planned.Tyre.Pressure.FR"), 1) . translate(".")
			description .= "`n" . translate("Pressure rear left ") . Round(kb.getValue("Pitstop.Planned.Tyre.Pressure.RL"), 1) . translate(".")
			description .= "`n" . translate("Pressure rear right ") . Round(kb.getValue("Pitstop.Planned.Tyre.Pressure.RR"), 1) . translate(".")

			if knowledgeBase.getValue("Pitstop.Planned.Repair.Suspension", false)
				description .= "`n" . translate("We will repair the suspension.")
			else
				description .= "`n" . translate("The suspension looks fine.")

			if kb.getValue("Pitstop.Planned.Repair.Bodywork", false)
				description .= "`n" . translate("Bodywork and aerodynamic elements should be repaired.")
			else
				description .= "`n" . translate("Bodywork and aerodynamic elements should be good.")
			
			return description
		}
		else
			return result
	}
	
	preparePitstop(lap := false) {
		if lap
			this.KnowledgeBase.addFact("Pitstop.Prepare", true)
		else
			this.KnowledgeBase.addFact("Pitstop.Planned.Lap", lap - 1)
		
		return this.KnowledgeBase.produce()
	}
	
	performPitstop() {
		this.KnowledgeBase.addFact("Pitstop.Lap", this.KnowledgeBase.getValue("Lap") - 1)
		
		return this.KnowledgeBase.produce()
	}
	
	upcomingPitstopWarning(remainingLaps) {
		this.Plugin.upcomingPitstopWarning(remainingLaps)
	}
	
	beginPitstopSettings() {
		this.Plugin.beginPitstopSettings()
	}

	endPitstopSettings() {
		this.Plugin.KnowledgeBase.endPitstopSettings()
	}

	updatePitstopFuelSettings(fuel) {
		this.Plugin.KnowledgeBase.updatePitstopFuelSettings(fuel)
	}

	updatePitstopTyreSettings(compound, set, pressureFL, pressureFR, pressureRL, pressureRR) {
		this.Plugin.KnowledgeBase.updatePitstopTyreSettings(compound, set, pressureFL, pressureFR, pressureRL, pressureRR)
	}

	updatePitstopRepairSettings(repairSuspension, repairBodywork) {
		this.Plugin.KnowledgeBase.updatePitstopRepairSettings(repairSuspension, repairBodywork)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

upcomingPitstopWarning(knowledgeBase, remainingLaps) {
	knowledgeBase.RaceEngineer.upcomingPitstopWarning(remainingLaps)
}

beginPitstopSettings(resultSet) {
	resultSet.KnowledgeBase.RaceEngineer.beginPitstopSettings()
}

endPitstopSettings(resultSet) {
	resultSet.KnowledgeBase.RaceEngineer.endPitstopSettings()
}

updatePitstopFuelSettings(resultSet, fuel) {
	resultSet.KnowledgeBase.RaceEngineer.updatePitstopFuelSettings(fuel)
}

updatePitstopTyreSettings(resultSet, compound, set, pressureFL, pressureFR, pressureRL, pressureRR) {
	resultSet.KnowledgeBase.RaceEngineer.updatePitstopTyreSettings(compound, set, pressureFL, pressureFR, pressureRL, pressureRR)
}

updatePitstopRepairSettings(resultSet, repairSuspension, repairBodywork) {
	resultSet.KnowledgeBase.RaceEngineer.updatePitstopRepairSettings(repairSuspension, repairBodywork)
}