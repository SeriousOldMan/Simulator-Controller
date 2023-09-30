;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Strategy Representation         ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Progress.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\RuleEngine.ahk"
#Include "..\..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class StrategySimulation {
	iStrategyManager := false
	iTelemetryDatabase := false

	iFixedLapTime := false

	iTyreCompoundColors := []

	iTyreCompound := false
	iTyreCompoundColor := false
	iTyreCompoundVariation := 0

	class CancelSimulation {
	}

	StrategyManager {
		Get {
			return this.iStrategyManager
		}
	}

	TelemetryDatabase {
		Get {
			return this.iTelemetryDatabase
		}
	}

	SessionType {
		Get {
			return this.iSessionType
		}
	}

	TyreCompoundColors {
		Get {
			return this.iTyreCompoundColors
		}

		Set {
			return this.iTyreCompoundColors := value
		}
	}

	TyreCompound {
		Get {
			return this.iTyreCompound
		}

		Set {
			return this.iTyreCompound := value
		}
	}

	TyreCompoundColor {
		Get {
			return this.iTyreCompoundColor
		}

		Set {
			return this.iTyreCompoundColor := value
		}
	}

	TyreCompoundVariation {
		Get {
			return this.iTyreCompoundVariation
		}

		Set {
			return this.iTyreCompoundVariation := value
		}
	}

	FixedLapTime {
		Get {
			return this.iFixedLapTime
		}
	}

	__New(strategyManager, sessionType, telemetryDatabase) {
		this.iStrategyManager := strategyManager
		this.iSessionType := sessionType
		this.iTelemetryDatabase := telemetryDatabase
	}

	createKnowledgeBase(productions, reductions, facts := false) {
		local engine := RuleEngine(productions, reductions, facts)

		return KnowledgeBase(engine, engine.createFacts(), engine.createRules())
	}

	loadRules(compiler, validator, &productions, &reductions) {
		local rules, message, title

		rules := FileRead(kResourcesDirectory . "Strategy\Rules\Strategy Validation.rules")

		productions := false
		reductions := false

		compiler.compileRules(rules, &productions, &reductions)

		try {
			rules := FileRead(getFileName(validator . ".rules", kUserHomeDirectory . "Validators\", kResourcesDirectory . "Strategy\Validators\"))

			if (rules != "")
				compiler.compileRules(rules, &productions, &reductions)
		}
		catch Any as exception {
			message := (isObject(exception) ? exception.Message : exception)

			OnMessage(0x44, translateOkButton)
			MsgBox(translate("Cannot load the custom validation rules.") . "`n`n" . message, translate("Error"), 262192)
			OnMessage(0x44, translateOkButton, 0)
		}
	}

	dumpKnowledgeBase(knowledgeBase) {
		knowledgeBase.dumpFacts()
	}

	dumpRules(knowledgeBase) {
		knowledgeBase.dumpRules()
	}

	static scenarioCoefficient(cfs, value, step) {
		static coefficients := CaseInsenseMap("ResultMajor", 		[-0.81, -0.31, 0, 0.31, 0.81]
											, "ResultMinor",		[-0.13, 0, 0.13]
											, "FuelMax",			[-0.34, -0.22, 0, 0.22, 0.34]
											, "TyreSetsCount", 		[-0.46, -0.18, 0, 0.18, 0.46]
											, "TyreLapsMax",		[-0.76, -0.38, -0.24, 0, 0.24, 0.38, 0.76]
											, "PitstopsCount",		[-0.78, -0.52, 0, 0.52, 0.78]
											, "PitstopsPostLaps",	[-0.43, -0.25, 0, 0.25, 0.43])

		cfs := coefficients[cfs]

		return cfs[Min(cfs.Length, Max(1, Round(value / step) + ((cfs.Length - 1) >> 1) + 1))]
	}

	scenarioCoefficient(cfs, value, step) {
		return StrategySimulation.scenarioCoefficient(cfs, value, step)
	}

	scenarioValid(strategy, validator) {
		local reqPitstops := strategy.PitstopRule
		local knowledgeBase, rules, rule, resultSet, refuelRule, valid, ignore, pitstop, tyreChangeRule
		local number, pitstop, tyreCompound, tyreCompoundColor, productions, reductions

		if isObject(reqPitstops)
			reqPitstops := 1

		if (strategy.Pitstops.Length < reqPitstops)
			return false

		refuelRule := strategy.RefuelRule

		if (refuelRule = "Disallowed") {
			for ignore, pitstop in strategy.Pitstops
				if (pitstop.RefuelAmount > 0)
					return false
		}
		else if (refuelRule = "Required") {
			valid := false

			for ignore, pitstop in strategy.Pitstops
				if (pitstop.RefuelAmount > 0) {
					valid := true

					break
				}

			if !valid
				return false
		}
		else if (refuelRule = "Always") {
			valid := true

			for ignore, pitstop in strategy.Pitstops
				if (pitstop.RefuelAmount <= 0) {
					valid := false

					break
				}

			if !valid
				return false
		}

		tyreChangeRule := strategy.TyreChangeRule

		if (tyreChangeRule = "Disallowed") {
			for ignore, pitstop in strategy.Pitstops
				if pitstop.TyreChange
					return false
		}
		else if (tyreChangeRule = "Required") {
			valid := false

			for ignore, pitstop in strategy.Pitstops
				if pitstop.TyreChange {
					valid := true

					break
				}

			if !valid
				return false
		}
		else if (tyreChangeRule = "Always") {
			valid := true

			for ignore, pitstop in strategy.Pitstops
				if !pitstop.TyreChange {
					valid := false

					break
				}

			if !valid
				return false
		}

		if validator {
			static compiler := false
			static goal := false
			static lastValidator := false

			if !compiler {
				compiler := RuleCompiler()
				goal := compiler.compileGoal("validScenario()")
			}

			if (validator != lastValidator) {
				productions := false
				reductions := false

				this.loadRules(compiler, validator, &productions, &reductions)

				knowledgeBase := this.createKnowledgeBase(productions, reductions)
				rules := knowledgeBase.Rules
			}
			else {
				rules := knowledgeBase.Rules

				for ignore, rule in rules.Reductions["setup", 3].clone()
					rules.removeRule(rule)

				for ignore, rule in rules.Reductions["pitstop", 4].clone()
					rules.removeRule(rule)
			}

			knowledgeBase.addRule(compiler.compileRule("setup(" . strategy.RemainingFuel . ","
																. StrReplace(strategy.TyreCompound, A_Space, "\ ") . ","
																. StrReplace(strategy.TyreCompoundColor, A_Space, "\ ") . ")"))

			for number, pitstop in strategy.Pitstops {
				if pitstop.TyreChange {
					tyreCompound := pitstop.TyreCompound
					tyreCompoundColor := pitstop.TyreCompoundColor
				}
				else {
					tyreCompound := false
					tyreCompoundColor := false
				}

				knowledgeBase.addRule(compiler.compileRule("pitstop(" . number . "," . pitstop.Lap . "," . Round(pitstop.Time / 60) . ","
																	  . Round(pitstop.RefuelAmount) . "," . tyreCompound . "," . tyreCompoundColor . ")"))
			}

			if isDebug()
				this.dumpRules(knowledgeBase)

			resultSet := knowledgeBase.prove(goal)

			if resultSet
				resultSet.dispose()

			return (resultSet != false)
		}
		else
			return true
	}

	createStrategy(nameOrConfiguration, driver := false) {
		local strategy := this.StrategyManager.createStrategy(nameOrConfiguration, driver)

		strategy.setStrategyManager(this)

		strategy.initializeAvailableTyreSets()

		return strategy
	}

	getStrategySettings(&simulator, &car, &track, &weather, &airTemperature, &trackTemperature
					  , &sessionType, &sessionLength, &maxTyreLaps, &tyreCompound, &tyreCompoundColor, &tyrePressures) {
		return this.StrategyManager.getStrategySettings(&simulator, &car, &track, &weather, &airTemperature, &trackTemperature
													  , &sessionType, &sessionLength, &maxTyreLaps, &tyreCompound, &tyreCompoundColor, &tyrePressures)
	}

	getSessionSettings(&stintLength, &formationLap, &postRaceLap, &fuelCapacity, &safetyFuel
					 , &pitstopDelta, &pitstopFuelService, &pitstopTyreService, &pitstopServiceOrder) {
		return this.StrategyManager.getSessionSettings(&stintLength, &formationLap, &postRaceLap, &fuelCapacity, &safetyFuel
													 , &pitstopDelta, &pitstopFuelService, &pitstopTyreService, &pitstopServiceOrder)
	}

	getSessionWeather(minute, &weather, &airTemperature, &trackTemperature) {
		return this.StrategyManager.getSessionWeather(minute, &weather, &airTemperature, &trackTemperature)
	}

	getStartConditions(&initialStint, &initialLap, &initialStintTime, &initialSessionTime
					 , &initialTyreLaps, &initialFuelAmount, &initialMap, &initialFuelConsumption, &initialAvgLapTime) {
		return this.StrategyManager.getStartConditions(&initialStint, &initialLap, &initialStintTime
													 , &initialSessionTime, &initialTyreLaps, &initialFuelAmount
													 , &initialMap, &initialFuelConsumption, &initialAvgLapTime)
	}

	getSimulationSettings(&useInitialConditions, &useTelemetryData, &consumptionVariation, &initialFuelVariation
						, &tyreUsageVariation, &tyreCompoundVariation) {
		return this.StrategyManager.getSimulationSettings(&useInitialConditions, &useTelemetryData, &consumptionVariation, &initialFuelVariation
														, &tyreUsageVariation, &tyreCompoundVariation)
	}

	getPitstopRules(&validator, &pitstopRule, &refuelRule, &tyreChangeRule, &tyreSets) {
		return this.StrategyManager.getPitstopRules(&validator, &pitstopRule, &refuelRule, &tyreChangeRule, &tyreSets)
	}

	getStintDriver(stintNumber, &driverID, &driverName) {
		return this.StrategyManager.getStintDriver(stintNumber, &driverID, &driverName)
	}

	setStintDriver(stintNumber, driverID) {
		this.TelemetryDatabase.setDrivers(driverID)
	}

	calcAvgLapTime(numLaps, map, remainingFuel, fuelConsumption, weather, tyreCompound, tyreCompoundColor, tyreLaps
				 , default := false, telemetryDB := false) {
		local theMin := false
		local theMax := false
		local a, b, lapTimes, tyreLapTimes, xValues, yValues, ignore, entry
		local baseLapTime, count, avgLapTime, lapTime, candidate

		a := false
		b := false

		if !telemetryDB
			telemetryDB := this.StrategyManager.TelemetryDatabase

		lapTimes := telemetryDB.getMapLapTimes(weather, tyreCompound, tyreCompoundColor)
		tyreLapTimes := telemetryDB.getTyreLapTimes(weather, tyreCompound, tyreCompoundColor)

		if (tyreLapTimes.Length > 1) {
			xValues := []
			yValues := []

			for ignore, entry in tyreLapTimes {
				lapTime := entry["Lap.Time"]

				xValues.Push(entry["Tyre.Laps"])
				yValues.Push(lapTime)

				theMin := (theMin ? Min(theMin, lapTime) : lapTime)
				theMax := (theMax ? Max(theMax, lapTime) : lapTime)
			}

			linRegression(xValues, yValues, &a, &b)
		}

		baseLapTime := ((a && b) ? (a + (b * tyreLaps)) : false)

		count := 0
		avgLapTime := 0
		lapTime := false

		loop numLaps {
			candidate := lookupLapTime(lapTimes, map, remainingFuel - (fuelConsumption * (A_Index - 1)))

			if (!lapTime || !baseLapTime)
				lapTime := candidate
			else if (candidate < lapTime)
				lapTime := candidate

			if lapTime {
				if baseLapTime
					avgLapTime += (lapTime + ((a + (b * (tyreLaps + A_Index))) - baseLapTime))
				else
					avgLapTime += lapTime

				count += 1
			}
		}

		if (avgLapTime > 0)
			avgLapTime := (avgLapTime / count)

		if (theMin && theMax)
			avgLapTime := Max(theMin, Min(theMax, avgLapTime))

		return avgLapTime ? avgLapTime : default
	}

	getAvgLapTime(numLaps, ecuMap, remainingFuel, fuelConsumption, weather, tyreCompound, tyreCompoundColor, tyreLaps, default := false) {
		if this.FixedLapTime
			return this.FixedLapTime
		else
			return this.StrategyManager.getAvgLapTime(numLaps, ecuMap, remainingFuel, fuelConsumption, weather, tyreCompound, tyreCompoundColor, tyreLaps, default)
	}

	getTyreCompoundColors(weather, tyreCompound) {
		local tyreCompoundColors := []
		local ignore, row

		for ignore, row in this.TelemetryDatabase.getTyreCompoundColors(weather, tyreCompound)
			tyreCompoundColors.Push(row["Tyre.Compound.Color"])

		return tyreCompoundColors
	}

	setFixedLapTime(lapTime) {
		this.iFixedLapTime := lapTime
	}

	acquireElectronicsData(weather, tyreCompound, tyreCompoundColor) {
		return this.TelemetryDatabase.getMapData(weather, tyreCompound, tyreCompoundColor)
	}

	acquireTyresData(weather, tyreCompound, tyreCompoundColor) {
		return this.TelemetryDatabase.getTyreData(weather, tyreCompound, tyreCompoundColor)
	}

	acquireTelemetryData(&electronicsData, &tyresData, verbose, &progress) {
		local telemetryDB := this.TelemetryDatabase
		local simulator := false
		local car := false
		local track := false
		local weather := false
		local airTemperature := false
		local trackTemperature := false
		local sessionType := false
		local sessionLength := false
		local maxTyreLaps := false
		local tyreCompound := false
		local tyreCompoundColor := false
		local tyrePressures := false
		local message, candidate

		this.getStrategySettings(&simulator, &car, &track, &weather, &airTemperature, &trackTemperature
							   , &sessionType, &sessionLength, &maxTyreLaps, &tyreCompound, &tyreCompoundColor, &tyrePressures)

		if !telemetryDB.suitableTyreCompound(simulator, car, track, weather, compound(tyreCompound, tyreCompoundColor)) {
			candidate := telemetryDB.optimalTyreCompound(simulator, car, track, weather, airTemperature, trackTemperature)

			if candidate
				splitCompound(candidate, &tyreCompound, &tyreCompoundColor)
		}

		if verbose {
			message := translate("Reading Electronics Data...")

			showProgress({progress: progress, message: message})
		}

		electronicsData := this.acquireElectronicsData(weather, tyreCompound, tyreCompoundColor)

		Sleep(200)

		if verbose {
			message := translate("Reading Tyre Data...")

			showProgress({progress: progress + 2, message: message})
		}

		tyresData := this.acquireTyresData(weather, tyreCompound, tyreCompoundColor)

		Sleep(200)

		if verbose
			progress += 5
	}

	createScenarios(electronicsData, tyresData, verbose, &progress) {
		throw "Virtual method StrategySimulation.createScenarios must be implemented in a subclass..."
	}

	createScenarioStrategy(name, initialStint, initialLap, initialStintTime, initialSessionTime
						 , initialTyreLaps, maxTyreLaps, tyreLapsVariation
						 , stintLaps, formationLap, avgLapTime
						 , ecuMap, fuelConsumption, consumptionVariation
						 , initialFuelAmount, initialFuelVariation, fuelCapacity
						 , weather, tyreCompound, tyreCompoundColor) {
		local driverID := false
		local driverName := false
		local strategy, currentConsumption, startFuelAmount, fuelAmount, lapTime

		this.getStintDriver(initialStint, &driverID, &driverName)

		this.setStintDriver(initialStint, driverID)

		strategy := this.createStrategy(name, driverID)

		strategy.AvgLapTime["Fixed"] := this.FixedLapTime

		currentConsumption := (fuelConsumption - ((fuelConsumption / 100) * consumptionVariation))

		startFuelAmount := Min(fuelCapacity, initialFuelAmount + (initialFuelVariation / 100 * fuelCapacity))

		if formationLap {
			startFuelAmount := Max(startFuelAmount, currentConsumption * 2)

			fuelAmount := (startFuelAmount - currentConsumption)
		}
		else
			fuelAmount := startFuelAmount

		lapTime := this.getAvgLapTime(stintLaps, ecuMap, fuelAmount, currentConsumption
									, weather, tyreCompound, tyreCompoundColor, 0, avgLapTime)

		this.createStints(strategy, initialStint, initialLap, initialStintTime, initialSessionTime, initialTyreLaps
						, startFuelAmount, initialFuelVariation, fuelAmount
						, stintLaps, maxTyreLaps, tyreLapsVariation, ecuMap, currentConsumption, lapTime)

		return strategy
	}

	createStints(strategy, initialStint, initialLap, initialStintTime, initialSessionTime, initialTyreLaps
			   , startFuelAmount, startFuelVariation, fuelAmount
			   , stintLaps, maxTyreLaps, tyreLapsVariation, ecuMap, consumption, lapTime) {
		strategy.createStints(initialStint, initialLap, initialStintTime, initialSessionTime, initialTyreLaps
							, startFuelAmount, startFuelVariation, fuelAmount
							, stintLaps, maxTyreLaps, tyreLapsVariation, ecuMap, consumption, lapTime)
	}

	optimizeScenarios(scenarios, verbose, &progress) {
		local strategy, name, avgLapTime, targetTime, sessionTime, superfluousLaps, reqPitstops, message
		local avgLapTime, openingLap, closingLap, ignore, pitstop

		if (this.SessionType = "Duration")
			for name, strategy in scenarios {
				if (verbose && GetKeyState("Escape", "P"))
					throw StrategySimulation.CancelSimulation()

				if verbose {
					message := (translate("Optimizing Scenario ") . name . translate("..."))

					showProgress({progress: progress, message: message})
				}

				avgLapTime := strategy.AvgLapTime["Session"]

				targetTime := strategy.calcSessionTime(avgLapTime, false)
				sessionTime := strategy.getSessionDuration()

				superfluousLaps := -1

				while (sessionTime > targetTime) {
					superfluousLaps += 1
					sessionTime -= avgLapTime
				}

				reqPitstops := strategy.PitstopRule

				if isObject(reqPitstops) {
					avgLapTime := strategy.AvgLapTime
					openingLap := (reqPitstops[1] * 60 / avgLapTime)
					closingLap := (reqPitstops[2] * 60 / avgLapTime)

					for ignore, pitstop in strategy.Pitstops
						if ((pitstop.Lap >= openingLap) && (pitstop.Lap <= closingLap)) {
							reqPitstops := A_Index

							break
						}

					if !isNumber(reqPitstops)
						reqPitstops := false
				}

				if (superfluousLaps > 0)
					strategy.adjustLastPitstop(superfluousLaps, (strategy.Pitstops.Length > reqPitstops) || !reqPitstops)

				strategy.adjustLastPitstopRefuelAmount()

				if verbose
					progress += 1
			}

		if verbose
			progress := Floor(progress + 10)

		return scenarios
	}

	validScenario(strategy) {
		local remainingFuel := strategy.RemainingFuel[true]
		local remainingSessionLaps := strategy.RemainingSessionLaps[true]
		local fuelConsumption := strategy.FuelConsumption[true]
		local valid := ((remainingFuel - (remainingSessionLaps * fuelConsumption)) > 0)

		if !valid {
			remainingSessionLaps := (remainingFuel / fuelConsumption)

			valid := (strategy.RemainingSessionTime[true] < (remainingSessionLaps * strategy.AvgLapTime[true]))
		}

		return (valid && this.scenarioValid(strategy, strategy.Validator))
	}

	compareScenarios(scenario1, scenario2) {
		local sLaps, cLaps, sDuration, cDuration, sFuel, cFuel, sTLaps, cTLaps, sTSets, cTSets
		local sPLaps, cPLaps

		pitstopLaps(scenario) {
			local laps := 0
			local ignore, pitstop

			for ignore, pitstop in scenario.Pitstops
				laps += pitstop.StintLaps

			return laps
		}

		fuelLevel(scenario) {
			local fuelLevel := scenario.RemainingFuel
			local ignore, pitstop

			for ignore, pitstop in scenario.Pitstops
				fuelLevel := Max(fuelLevel, pitstop.RemainingFuel)

			return fuelLevel
		}

		tyreLaps(scenario, &tyreSets) {
			local tyreLaps, tyreRunningLaps, lastLap, ignore, pitstop, stintLaps

			tyreSets := 1

			if !scenario.LastPitstop
				return scenario.getSessionLaps()
			else {
				tyreLaps := 0
				tyreRunningLaps := 0
				lastLap := scenario.StartLap

				for ignore, pitstop in scenario.Pitstops {
					stintLaps := (pitstop.Lap - lastLap)
					tyreRunningLaps += stintLaps

					if pitstop.TyreChange {
						tyreLaps := Max(tyreLaps, tyreRunningLaps)
						tyreSets += 1

						tyreRunningLaps := 0
					}

					lastLap := pitstop.Lap
				}

				tyreLaps := Max(tyreLaps, tyreRunningLaps + scenario.LastPitstop.StintLaps)

				return tyreLaps
			}
		}

		sTLaps := tyreLaps(scenario1, &sTSets)
		cTLaps := tyreLaps(scenario2, &cTSets)
		sFuel := fuelLevel(scenario1)
		cFuel := fuelLevel(scenario2)
		sPLaps := pitstopLaps(scenario1)
		cPLaps := pitstopLaps(scenario2)
		sDuration := scenario1.getSessionDuration()
		cDuration := scenario2.getSessionDuration()

		; Negative => 2, Positive => 1

		result := (this.scenarioCoefficient("PitstopsCount", scenario2.Pitstops.Length - scenario1.Pitstops.Length, 1)
				 + this.scenarioCoefficient("FuelMax", cFuel - sFuel, 10)
				 + this.scenarioCoefficient("TyreSetsCount", sTSets - cTSets, 1)
				 + this.scenarioCoefficient("TyreLapsMax", cTLaps - sTLaps, 10)
				 + this.scenarioCoefficient("PitstopsPostLaps", sPLaps - cPLaps, 10))

		if (this.SessionType = "Duration") {
			sLaps := scenario1.getSessionLaps()
			cLaps := scenario2.getSessionLaps()

			result += (this.scenarioCoefficient("ResultMajor", sLaps - cLaps, 1)
					 + this.scenarioCoefficient("ResultMinor", cDuration - sDuration, (scenario1.AvgLapTime + scenario2.AvgLapTime) / 4))
		}
		else
			result += this.scenarioCoefficient("ResultMajor", cDuration - sDuration, (scenario1.AvgLapTime + scenario2.AvgLapTime) / 4)

		if (result > 0)
			return scenario1
		else if (result < 0)
			return scenario2
		else if (scenario2.getRemainingFuel() > scenario1.getRemainingFuel())
			return scenario1
		else if (scenario2.getRemainingFuel() < scenario1.getRemainingFuel())
			return scenario2
		else if ((scenario2.FuelConsumption[true] > scenario1.FuelConsumption[true]))
			return scenario1
		else
			return scenario2
	}

	evaluateScenarios(scenarios, verbose, &progress := 0) {
		local candidate := false
		local name, strategy, message

		for name, strategy in scenarios {
			if (verbose && GetKeyState("Escape", "P"))
				throw StrategySimulation.CancelSimulation()

			if this.validScenario(strategy) {
				if verbose {
					message := (translate("Evaluating Scenario ") . name . translate("..."))

					showProgress({progress: progress, message: message})
				}

				if !candidate
					candidate := strategy
				else
					candidate := this.compareScenarios(strategy, candidate)

				if verbose
					progress += 1
			}
		}

		if verbose
			progress := Floor(progress + 10)

		return candidate
	}

	chooseScenario(scenario) {
		this.StrategyManager.chooseScenario(scenario)
	}

	runSimulation(verbose := true) {
		local window := ((verbose && this.StrategyManager.HasProp("Window")) ? this.StrategyManager.Window : false)
		local progress := 0
		local electronicsData := false
		local tyresData := false
		local progressWindow, message, scenarios, scenario, ignore, disposable

		if verbose {
			progressWindow := showProgress({color: "Blue", title: translate("Acquiring Telemetry Data")})

			if window {
				progressWindow.Opt("+Owner" . window.Hwnd)

				window.Block()
			}
		}

		try {
			Sleep(200)

			this.acquireTelemetryData(&electronicsData, &tyresData, verbose, &progress)

			if verbose {
				message := translate("Creating Scenarios...")

				showProgress({progress: progress, color: "Green", title: translate("Running Simulation")})
			}

			Sleep(200)

			scenarios := this.createScenarios(electronicsData, tyresData, verbose, &progress)

			if verbose {
				message := translate("Optimizing Scenarios...")

				showProgress({progress: progress, message: message})
			}

			Sleep(200)

			scenarios := this.optimizeScenarios(scenarios, verbose, &progress)

			if verbose {
				message := translate("Evaluating Scenarios...")

				showProgress({progress: progress, message: message})
			}

			Sleep(200)

			scenario := this.evaluateScenarios(scenarios, verbose, &progress)

			if scenario {
				if verbose {
					message := translate("Choose Scenario...")

					showProgress({progress: progress, message: message})
				}

				Sleep(200)

				this.chooseScenario(scenario)
			}
			else
				this.chooseScenario(false)

			for ignore, disposable in scenarios
				if (disposable != scenario)
					disposable.dispose()
		}
		catch StrategySimulation.CancelSimulation {
			return
		}
		finally {
			if verbose {
				message := translate("Finished...")

				showProgress({progress: 100, message: message})

				Sleep(200)

				hideProgress()

				if window
					window.Unblock()
			}
		}
	}
}

class VariationSimulation extends StrategySimulation {
	createScenarios(electronicsData, tyresData, verbose, &progress) {
		local telemetryDB := this.TelemetryDatabase
		local simulator := false
		local car := false
		local track := false
		local weather := false
		local airTemperature := false
		local trackTemperature := false
		local sessionType := false
		local sessionLength := false
		local maxTyreLaps := false
		local tyreCompound := false
		local tyreCompoundColor := false
		local tyrePressures := false
		local stintLength := false
		local formationLap := false
		local postRaceLap := false
		local fuelCapacity := false
		local safetyFuel := false
		local pitstopDelta := false
		local pitstopFuelService := false
		local pitstopTyreService := false
		local pitstopServiceOrder := "Simultaneous"
		local initialStint := false
		local initialLap := false
		local initialStintTime := false
		local initialSessionTime := false
		local initialTyreLaps := false
		local initialFuelAmount := false
		local ecuMap := false
		local fuelConsumption := false
		local avgLapTime := false
		local useInitialConditions := false
		local useTelemetryData := false
		local consumption := 0
		local tyreUsage := 0
		local tyreCompoundVariation := 0
		local initialFuel := 0
		local consumptionSteps, tyreUsageSteps, tyreCompoundVariationSteps, initialFuelSteps
		local scenarios, variation, tyreCompoundColors
		local consumptionRound, initialFuelRound, tyreUsageRound, tyreCompoundVariationRound, tyreLapsVariation
		local message, stintLaps, name, driverID, driverName
		local ignore, mapData, scenarioMap, scenarioFuelConsumption, scenarioAvgLapTime
		local candidate, targetTyreCompound, targetTyreCompoundColor

		this.getStrategySettings(&simulator, &car, &track, &weather, &airTemperature, &trackTemperature
							   , &sessionType, &sessionLength, &maxTyreLaps, &tyreCompound, &tyreCompoundColor, &tyrePressures)

		this.getSessionSettings(&stintLength, &formationLap, &postRaceLap, &fuelCapacity, &safetyFuel
							  , &pitstopDelta, &pitstopFuelService, &pitstopTyreService, &pitstopServiceOrder)

		this.getStartConditions(&initialStint, &initialLap, &initialStintTime, &initialSessionTime
							  , &initialTyreLaps, &initialFuelAmount, &ecuMap, &fuelConsumption, &avgLapTime)

		if initialLap
			formationLap := false

		this.getSimulationSettings(&useInitialConditions, &useTelemetryData, &consumption, &initialFuel, &tyreUsage, &tyreCompoundVariation)

		consumptionSteps := 1
		tyreUsageSteps := tyreUsage * 2
		tyreCompoundVariationSteps := tyreCompoundVariation / 4
		initialFuelSteps := initialFuel / 5

		scenarios := CaseInsenseMap()
		variation := 1

		if (tyreCompoundVariation > 0) {
			if (useInitialConditions && useTelemetryData) {
				tyreCompoundColors := this.getTyreCompoundColors(weather, tyreCompound)

				if !inList(tyreCompoundColors, tyreCompoundColor)
					tyreCompoundColors.Push(tyreCompoundColor)
			}
			else if useTelemetryData
				tyreCompoundColors := this.getTyreCompoundColors(weather, tyreCompound)
			else
				tyreCompoundColors := [tyreCompoundColor]
		}
		else
			tyreCompoundColors := [tyreCompoundColor]

		this.TyreCompoundColors := tyreCompoundColors

		this.TyreCompound := tyreCompound
		this.TyreCompoundColor := tyreCompoundColor
		this.TyreCompoundVariation := tyreCompoundVariation

		consumptionRound := 0
		initialFuelRound := 0
		tyreUsageRound := 0
		tyreCompoundVariationRound := 0

		tyreLapsVariation := tyreUsage

		targetTyreCompound := tyreCompound
		targetTyreCompoundColor := tyreCompoundColor

		if !telemetryDB.suitableTyreCompound(simulator, car, track, weather, compound(tyreCompound, tyreCompoundColor)) {
			candidate := telemetryDB.optimalTyreCompound(simulator, car, track, weather, airTemperature, trackTemperature)

			if candidate
				splitCompound(candidate, &targetTyreCompound, &targetTyreCompoundColor)

		}

		loop { ; consumption
			loop { ; initialFuel
				loop { ; tyreUsage
					loop { ; tyreCompoundVariation
						if (verbose && GetKeyState("Escape", "P"))
							throw StrategySimulation.CancelSimulation()

						if useInitialConditions {
							if verbose {
								message := (translate("Creating Initial Scenario with Map ") . ecuMap . translate(":") . variation++ . translate("..."))

								showProgress({progress: progress, message: message})
							}

							stintLaps := Floor((stintLength * 60) / avgLapTime)

							name := (translate("Initial Conditions - Map ") . ecuMap)

							this.setFixedLapTime(avgLapTime)

							try {
								scenarios[name . translate(":") . variation]
									:= this.createScenarioStrategy(name
																 , initialStint, initialLap, initialStintTime, initialSessionTime
																 , initialTyreLaps, maxTyreLaps, tyreLapsVariation
																 , stintLaps, formationLap, avgLapTime
																 , ecuMap, fuelConsumption, consumption
																 , initialFuelAmount, initialFuelRound * 5, fuelCapacity
																 , weather, tyreCompound, tyreCompoundColor)
							}
							finally {
								this.setFixedLapTime(false)
							}

							if verbose
								progress += 1
						}

						if useTelemetryData {
							driverID := false
							driverName := false

							this.getStintDriver(initialStint, &driverID, &driverName)

							this.setStintDriver(initialStint, driverID)

							for ignore, mapData in this.acquireElectronicsData(weather, targetTyreCompound, targetTyreCompoundColor) {
								scenarioMap := mapData["Map"]
								scenarioFuelConsumption := mapData["Fuel.Consumption"]
								scenarioAvgLapTime := mapData["Lap.Time"]

								if verbose {
									message := (translate("Creating Telemetry Scenario with Map ") . scenarioMap . translate(":") . variation++ . translate("..."))

									showProgress({progress: progress, message: message})
								}

								stintLaps := Floor((stintLength * 60) / scenarioAvgLapTime)

								name := (translate("Telemetry - Map ") . scenarioMap)

								scenarios[name . translate(":") . variation]
									:= this.createScenarioStrategy(name
																 , initialStint, initialLap, initialStintTime, initialSessionTime
																 , initialTyreLaps, maxTyreLaps, tyreLapsVariation
																 , stintLaps, formationLap, scenarioAvgLapTime
																 , scenarioMap, scenarioFuelConsumption, consumption
																 , initialFuelAmount, initialFuelRound * 5, fuelCapacity
																 , weather, tyreCompound, tyreCompoundColor)

								if verbose
									progress += 1
							}
						}

						if (++tyreCompoundVariationRound >= tyreCompoundVariationSteps)
							break
					}

					if (++tyreUsageRound >= tyreUsageSteps)
						break
				}

				initialFuel -= initialFuelSteps

				if (++initialFuelRound >= initialFuelSteps)
					break
			}

			consumption -= consumptionSteps

			if (++consumptionRound >= consumptionSteps)
				break
		}

		progress := Floor(progress + 10)

		return scenarios
	}
}

class TrafficSimulation extends StrategySimulation {
	iRandomFactor := false
	iNumScenarios := false
	iVariationWindow := false
	iUseLapTimeVariation := false
	iUseDriverErrors := false
	iUsePitstops := false
	iOverTakeDelta := false
	iConsideredTraffic := false

	RandomFactor {
		Get {
			return this.iRandomFactor
		}
	}

	NumScenarios {
		Get {
			return this.iNumScenarios
		}
	}

	VariationWindow {
		Get {
			return this.iVariationWindow
		}
	}

	UseLapTimeVariation {
		Get {
			return this.iUseLapTimeVariation
		}
	}

	UseDriverErrors {
		Get {
			return this.iUseDriverErrors
		}
	}

	UsePitstops {
		Get {
			return this.iUsePitstops
		}
	}

	OverTakeDelta {
		Get {
			return this.iOverTakeDelta
		}
	}

	ConsideredTraffic {
		Get {
			return this.iConsideredTraffic
		}
	}

	setTrafficSettings(randomFactor, numScenarios, variationWindow
					 , useLapTimeVariation, useDriverErrors, usePitstops, overTakeDelta, consideredTraffic) {
		this.iRandomFactor := randomFactor
		this.iNumScenarios := numScenarios
		this.iVariationWindow := variationWindow
		this.iUseLapTimeVariation := useLapTimeVariation
		this.iUseDriverErrors := useDriverErrors
		this.iUsePitstops := usePitstops
		this.iOverTakeDelta := overTakeDelta
		this.iConsideredTraffic := consideredTraffic
	}

	getTrafficSettings(&randomFactor, &numScenarios, &variationWindow
					 , &useLapTimeVariation, &useDriverErrors, &usePitstops
					 , &overTakeDelta, &consideredTraffic) {
		return this.StrategyManager.getTrafficSettings(&randomFactor, &numScenarios, &variationWindow
													 , &useLapTimeVariation, &useDriverErrors, &usePitstops
													 , &overTakeDelta, &consideredTraffic)
	}

	getTrafficScenario(strategy, pitstop) {
		return this.StrategyManager.getTrafficScenario(strategy, pitstop, this.RandomFactor, this.NumScenarios
													 , this.UseLapTimeVariation, this.UseDriverErrors, this.UsePitstops
													 , this.OverTakeDelta)
	}

	getTrafficPositions(trafficScenario, targetLap, &driver, &positions, &runnings) {
		return this.StrategyManager.getTrafficPositions(trafficScenario, targetLap, &driver, &positions, &runnings)
	}

	compareScenarios(scenario1, scenario2) {
		local pitstops1 := scenario1.Pitstops.Length
		local pitstops2 := scenario2.Pitstops.Length
		local pitstop1, pitstop2, position1, position2, density1, density2

		if ((pitstops1 > 0) && (pitstops2 > 0)) {
			if (pitstops1 < pitstops2)
				return scenario1
			else if (pitstops1 > pitstops2)
				return scenario2
			else if ((pitstops1 > 0) && (pitstops2 > 0)) {
				pitstop1 := scenario1.Pitstops[1]
				pitstop2 := scenario2.Pitstops[1]
				position1 := pitstop1.getPosition()
				position2 := pitstop2.getPosition()

				if (position1 && position2 && (position1 < position2))
					return scenario1
				else if (position1 && position2 && (position1 > position2))
					return scenario2
				else if (pitstop1.Lap < pitstop2.Lap)
					return scenario1
				else if (pitstop1.Lap > pitstop2.Lap)
					return scenario2
				else {
					density1 := pitstop1.getTrafficDensity()
					density2 := pitstop1.getTrafficDensity()

					if (density1 < density2)
						return scenario1
					else if (density1 > density2)
						return scenario2
					else
						return super.compareScenarios(scenario1, scenario2)
				}
			}
		}
		else
			return super.compareScenarios(scenario1, scenario2)
	}

	createScenarios(electronicsData, tyresData, verbose, &progress) {
		local telemetryDB := this.TelemetryDatabase
		local simulator := false
		local car := false
		local track := false
		local weather := false
		local airTemperature := false
		local trackTemperature := false
		local sessionType := false
		local sessionLength := false
		local maxTyreLaps := false
		local tyreCompound := false
		local tyreCompoundColor := false
		local tyrePressures := false
		local stintLength := false
		local formationLap := false
		local postRaceLap := false
		local fuelCapacity := false
		local safetyFuel := false
		local pitstopDelta := false
		local pitstopFuelService := false
		local pitstopTyreService := false
		local pitstopServiceOrder := "Simultaneous"
		local randomFactor := false
		local numScenarios := false
		local variationWindow := false
		local useLapTimeVariation := false
		local useDriverErrors := false
		local usePitstops := false
		local overTakeDelta := false
		local consideredTraffic := false
		local initialStint := false
		local initialLap := false
		local initialStintTime := false
		local initialSessionTime := false
		local initialTyreLaps := false
		local initialFuelAmount := false
		local ecuMap := false
		local fuelConsumption := false
		local avgLapTime := false
		local useInitialConditions := false
		local useTelemetryData := false
		local consumption := 0
		local tyreUsage := 0
		local tyreCompoundVariation := 0
		local initialFuel := 0
		local consumptionSteps, tyreUsageSteps, tyreCompoundVariationSteps, initialFuelSteps
		local scenarios, variation, first, tyreCompoundColors, tyreLapsVariation
		local consumptionRound, initialFuelRound, tyreUsageRound, tyreCompoundVariationRound
		local message, stintLaps, name, driverID, driverName, strategy, currentConsumption
		local ignore, mapData, scenarioMap, scenarioFuelConsumption, scenarioAvgLapTime
		local candidate, targetTyreCompound, targetTyreCompoundColor

		this.getStrategySettings(&simulator, &car, &track, &weather, &airTemperature, &trackTemperature
							   , &sessionType, &sessionLength, &maxTyreLaps, &tyreCompound, &tyreCompoundColor, &tyrePressures)

		this.getSessionSettings(&stintLength, &formationLap, &postRaceLap, &fuelCapacity, &safetyFuel
							  , &pitstopDelta, &pitstopFuelService, &pitstopTyreService, &pitstopServiceOrder)

		this.getTrafficSettings(&randomFactor, &numScenarios, &variationWindow
							  , &useLapTimeVariation, &useDriverErrors, &usePitstops
							  , &overTakeDelta, &consideredTraffic)

		if ((randomFactor == 0) && (variationWindow == 0) && !useLapTimeVariation && !useDriverErrors && !usePitstops)
			numScenarios := 1

		this.setTrafficSettings(randomFactor, numScenarios, variationWindow
							  , useLapTimeVariation, useDriverErrors, usePitstops
							  , overTakeDelta, consideredTraffic)

		this.getStartConditions(&initialStint, &initialLap, &initialStintTime, &initialSessionTime
							  , &initialTyreLaps, &initialFuelAmount, &ecuMap, &fuelConsumption, &avgLapTime)

		if initialLap
			formationLap := false

		this.getSimulationSettings(&useInitialConditions, &useTelemetryData, &consumption, &initialFuel, &tyreUsage, &tyreCompoundVariation)

		consumptionSteps := 1
		tyreUsageSteps := tyreUsage * 2
		tyreCompoundVariationSteps := tyreCompoundVariation / 4
		initialFuelSteps := initialFuel / 5

		scenarios := CaseInsenseMap()
		variation := 0

		first := true
		numScenarios += 1

		loop {
			if first {
				first := false

				this.iRandomFactor := 0
			}
			else
				this.iRandomFactor := randomFactor

			if (++variation > numScenarios)
				break

			if (tyreCompoundVariation > 0) {
				if (useInitialConditions && useTelemetryData) {
					tyreCompoundColors := this.getTyreCompoundColors(weather, tyreCompound)

					if !inList(tyreCompoundColors, tyreCompoundColor)
						tyreCompoundColors.Push(tyreCompoundColor)
				}
				else if useTelemetryData
					tyreCompoundColors := this.getTyreCompoundColors(weather, tyreCompound)
				else
					tyreCompoundColors := [tyreCompoundColor]
			}
			else
				tyreCompoundColors := [tyreCompoundColor]

			this.TyreCompoundColors := tyreCompoundColors

			this.TyreCompound := tyreCompound
			this.TyreCompoundColor := tyreCompoundColor
			this.TyreCompoundVariation := tyreCompoundVariation

			targetTyreCompound := tyreCompound
			targetTyreCompoundColor := tyreCompoundColor

			if !telemetryDB.suitableTyreCompound(simulator, car, track, weather, compound(tyreCompound, tyreCompoundColor)) {
				candidate := telemetryDB.optimalTyreCompound(simulator, car, track, weather, airTemperature, trackTemperature)

				if candidate
					splitCompound(candidate, &targetTyreCompound, &targetTyreCompoundColor)

			}

			consumptionRound := 0
			initialFuelRound := 0
			tyreUsageRound := 0
			tyreCompoundVariationRound := 0

			loop { ; consumption
				loop { ; initialFuel
					loop { ; tyreUsage
						tyreLapsVariation := tyreUsage

						loop { ; tyreCompoundVariation
							if (verbose && GetKeyState("Escape", "P"))
								throw StrategySimulation.CancelSimulation()

							if useInitialConditions {
								if verbose {
									message := (translate("Creating Initial Scenario with Map ") . ecuMap  . translate(":") . variation++ . translate("..."))

									showProgress({progress: progress, message: message})
								}

								stintLaps := Floor((stintLength * 60) / avgLapTime)

								name := (translate("Initial Conditions - Map ") . ecuMap)

								this.setFixedLapTime(avgLapTime)

								try {
									scenarios[name . translate(":") . variation]
										:= this.createScenarioStrategy(name
																	 , initialStint, initialLap, initialStintTime, initialSessionTime
																	 , initialTyreLaps, maxTyreLaps, tyreLapsVariation
																	 , stintLaps, formationLap, avgLapTime
																	 , ecuMap, fuelConsumption, consumption
																	 , initialFuelAmount, initialFuelRound * 5, fuelCapacity
																	 , weather, tyreCompound, tyreCompoundColor)
								}
								finally {
									this.setFixedLapTime(false)
								}

								if verbose
									progress += 1
							}

							if useTelemetryData {
								driverID := false
								driverName := false

								this.getStintDriver(initialStint, &driverID, &driverName)

								this.setStintDriver(initialStint, driverID)

								for ignore, mapData in this.acquireElectronicsData(weather, targetTyreCompound, targetTyreCompoundColor) {
									this.getStintDriver(initialStint, &driverID, &driverName)

									this.setStintDriver(initialStint, driverID)

									scenarioMap := mapData["Map"]
									scenarioFuelConsumption := mapData["Fuel.Consumption"]
									scenarioAvgLapTime := mapData["Lap.Time"]

									if verbose {
										message := (translate("Creating Telemetry Scenario with Map ") . scenarioMap . translate(":") . variation++ . translate("..."))

										showProgress({progress: progress, message: message})
									}

									stintLaps := Floor((stintLength * 60) / scenarioAvgLapTime)

									name := (translate("Telemetry - Map ") . scenarioMap)

									scenarios[name . translate(":") . variation]
										:= this.createScenarioStrategy(name
																	 , initialStint, initialLap, initialStintTime, initialSessionTime
																	 , initialTyreLaps, maxTyreLaps, tyreLapsVariation
																	 , stintLaps, formationLap, scenarioAvgLapTime
																	 , scenarioMap, scenarioFuelConsumption, consumption
																	 , initialFuelAmount, initialFuelRound * 5, fuelCapacity
																	 , weather, tyreCompound, tyreCompoundColor)

									if verbose
										progress += 1
								}
							}

							if (++tyreCompoundVariationRound >= tyreCompoundVariationSteps)
								break
						}

						if (++tyreUsageRound >= tyreUsageSteps)
							break
					}

					if (++initialFuelRound >= initialFuelSteps)
						break
				}

				if (++consumptionRound >= consumptionSteps)
					break
			}

			if (scenarios.Count == 0)
				break
		}

		progress := Floor(progress + 10)

		return scenarios
	}
}

class Strategy extends ConfigurationItem {
	iStrategyManager := false

	iName := translate("Unnamed")
	iVersion := false

	iWeather := "Dry"
	iAirTemperature := 23
	iTrackTemperature := 27

	iWeatherForecast := []

	iSimulator := false
	iCar := false
	iTrack := false

	iSessionType := "Duration"
	iSessionLength := 0

	iMap := "n/a"
	iTC := "n/a"
	iABS := "n/a"

	iStartStint := 1
	iStartLap := 0
	iStartTyreLaps := 0
	iStintStartTime := 0
	iSessionStartTime := 0

	iStartFuelAmount := 0
	iFuelAmount := 0

	iTyreCompound := "Dry"
	iTyreCompoundColor := "Black"

	iAvailableTyreSets := CaseInsenseMap()

	iTyrePressureFL := 26.5
	iTyrePressureFR := 26.5
	iTyrePressureRL := 26.5
	iTyrePressureRR := 26.5

	iStintLength := 0
	iFormationLap := false
	iPostRaceLap := false
	iFuelCapacity := 0
	iSafetyFuel := 0

	iPitstopDelta := 0
	iPitstopFuelService := 0.0
	iPitstopTyreService := 0.0
	iPitstopSeviceOrder := "Simultaneous"

	iValidator := false

	iPitstopRule := false
	iRefuelRule := false
	iTyreChangeRule := false
	iTyreSets := []

	iStintLaps := 0
	iMaxTyreLaps := 0
	iTyreLapsVariation := 0

	iAvgLapTime := 0
	iFixedLapTime := false
	iFuelConsumption := 0
	iTyreLaps := 0

	iUseInitialConditions := false
	iUseTelemetryData := false

	iConsumptionVariation := 0
	iInitialFuelVariation := 0
	iTyreUsageVariation := 0
	iTyreCompoundVariation := 0

	iDriver := false
	iDriverName := "John Doe (JD)"

	iPitstops := []

	class Pitstop extends ConfigurationItem {
		iStrategy := false
		iNr := false
		iLap := 0

		iDriver := false
		iDriverName := "John Doe (JD)"

		iTime := 0
		iDuration := 0
		iRefuelAmount := 0
		iTyreChange := false
		iTyreCompound := false
		iTyreCompoundColor := false

		iWeather := false
		iAirTemperature := false
		iTrackTemperature := false

		iStintLaps := 0
		iFixed := false

		iMap := 1
		iFuelConsumption := 0
		iAvgLapTime := 0

		iRemainingSessionTime := 0
		iRemainingSessionLaps := 0
		iRemainingTyreLaps := 0
		iRemainingFuel := 0

		Strategy {
			Get {
				return this.iStrategy
			}
		}

		Nr {
			Get {
				return this.iNr
			}
		}

		Lap {
			Get {
				return this.iLap
			}
		}

		Driver {
			Get {
				return this.iDriver
			}
		}

		DriverName {
			Get {
				return this.iDriverName
			}
		}

		Time {
			Get {
				return this.iTime
			}
		}

		Duration {
			Get {
				return this.iDuration
			}
		}

		Weather {
			Get {
				return this.iWeather
			}
		}

		AirTemperature {
			Get {
				return this.iAirTemperature
			}
		}

		TrackTemperature {
			Get {
				return this.iTrackTemperature
			}
		}

		TyreChange {
			Get {
				return this.iTyreChange
			}
		}

		TyreCompound {
			Get {
				return this.iTyreCompound
			}
		}

		TyreCompoundColor {
			Get {
				return this.iTyreCompoundColor
			}
		}

		RefuelAmount {
			Get {
				return this.iRefuelAmount
			}
		}

		StintLaps[max := false] {
			Get {
				if (max = "Max")
					return Floor((this.Strategy.StintLength * 60) / this.AvgLapTime)
				else
					return this.iStintLaps
			}
		}

		Fixed {
			Get {
				return this.iFixed
			}
		}

		Map {
			Get {
				return this.iMap
			}
		}

		FuelConsumption {
			Get {
				return this.iFuelConsumption
			}
		}

		AvgLapTime {
			Get {
				return this.iAvgLapTime
			}
		}

		RemainingSessionLaps {
			Get {
				return this.iRemainingSessionLaps
			}
		}

		RemainingSessionTime {
			Get {
				return this.iRemainingSessionTime
			}
		}

		RemainingTyreLaps {
			Get {
				return this.iRemainingTyreLaps
			}
		}

		RemainingFuel {
			Get {
				return this.iRemainingFuel
			}
		}

		__New(strategy, nr, lap, driver, tyreCompound, tyreCompoundColor, configuration := false, adjustments := false) {
			this.iStrategy := strategy
			this.iNr := nr
			this.iLap := lap
			this.iDriver := driver

			if driver
				this.iDriverName := SessionDatabase.getDriverName(strategy.Simulator, driver)

			super.__New(configuration)

			if !configuration
				this.initialize(tyreCompound, tyreCompoundColor, adjustments)
		}

		dispose() {
			this.iStrategy := false
		}

		initialize(tyreCompound, tyreCompoundColor, adjustments := false) {
			local strategy := this.Strategy
			local nr := this.Nr
			local lap := this.Lap
			local pitstopRule := strategy.PitstopRule
			local numPitstops := (isObject(pitstopRule) ? 1 : pitstopRule)
			local refuelRule := strategy.RefuelRule
			local tyreChangeRule := strategy.TyreChangeRule
			local remainingFuel := strategy.RemainingFuel[true]
			local remainingSessionLaps := strategy.RemainingSessionLaps[true]
			local fuelConsumption := strategy.FuelConsumption[true]
			local lastStintLaps := Floor(Min(remainingFuel / fuelConsumption, strategy.LastPitstop ? (lap - strategy.LastPitstop.Lap) : ((strategy.StartLap = 0) ? lap : (lap - strategy.StartLap))))
			local stintLaps, refuelAmount, tyreChange, remainingTyreLaps, freshTyreLaps, lastPitstop, delta
			local avgLapTime, openingLap, closingLap, weather, airTemperature, trackTemperature

			if (adjustments && adjustments.Has(nr) && adjustments[nr].HasProp("RemainingSessionLaps"))
				remainingSessionLaps := (adjustments[nr].RemainingSessionLaps + lastStintLaps)

			if (adjustments && adjustments.Has(nr) && adjustments[nr].HasProp("StintLaps"))
				stintLaps := adjustments[nr].StintLaps
			else
				stintLaps := Floor(Min(remainingSessionLaps - lastStintLaps, strategy.StintLaps
									 , strategy.getMaxFuelLaps(strategy.FuelCapacity, fuelConsumption)))

			if isObject(pitstopRule) {
				avgLapTime := strategy.AvgLapTime[true]
				openingLap := (pitstopRule[1] * 60 / avgLapTime)
				closingLap := (pitstopRule[2] * 60 / avgLapTime)

				if ((lap >= openingLap) && (lap <= closingLap))
					this.iFixed := true
			}

			this.iMap := strategy.Map[true]
			this.iFuelConsumption := fuelConsumption

			if (refuelRule = "Disallowed")
				refuelAmount := 0
			else
				refuelAmount := strategy.calcRefuelAmount(stintLaps * fuelConsumption, remainingFuel, remainingSessionLaps, lastStintLaps)

			tyreChange := kUndefined

			if (adjustments && adjustments.Has(nr)) {
				if adjustments[nr].HasProp("RefuelAmount")
					refuelAmount := adjustments[nr].RefuelAmount

				if adjustments[nr].HasProp("TyreChange")
					tyreChange := (adjustments[nr].TyreChange != false)
			}

			if ((this.Fixed || (nr <= numPitstops)) && (refuelRule = "Required") && (refuelAmount <= 0))
				refuelAmount := 1
			else if ((refuelRule = "Always") && (refuelAmount <= 0))
				refuelAmount := 1
			else if (refuelAmount <= 0)
				refuelAmount := 0

			this.iRemainingSessionLaps := (remainingSessionLaps - lastStintLaps)
			this.iRemainingFuel := (remainingFuel - (lastStintLaps * fuelConsumption) + refuelAmount)

			remainingTyreLaps := (strategy.RemainingTyreLaps[true] - lastStintLaps)

			freshTyreLaps := (strategy.MaxTyreLaps + (strategy.MaxTyreLaps * strategy.TyreLapsVariation / 100 * (Min(100 - Sqrt(Random(0, 10000)), 100) / 100)))

			if (tyreChangeRule = "Always") {
				this.iTyreChange := true
				this.iRemainingTyreLaps := freshTyreLaps
			}
			else if (tyreChangeRule = "Disallowed") {
				this.iTyreChange := false
				this.iRemainingTyreLaps := remainingTyreLaps
			}
			else if (tyreChange != kUndefined) {
				this.iTyreChange := tyreChange
				this.iRemainingTyreLaps := (tyreChange ? adjustments[nr].RemainingTyreLaps : remainingTyreLaps)
			}
			else if (!tyreCompound && !tyreCompoundColor) {
				this.iTyreChange := false
				this.iRemainingTyreLaps := remainingTyreLaps
			}
			else if (tyreCompound && tyreCompoundColor
				  && ((strategy.TyreCompound[true] != tyreCompound) || (strategy.TyreCompoundColor[true] != tyreCompoundColor))) {
				this.iTyreChange := true
				this.iRemainingTyreLaps := freshTyreLaps
			}
			else if ((remainingTyreLaps - stintLaps) >= 0) {
				if ((this.Fixed || (nr <= numPitstops)) && (tyreChangeRule = "Required")) {
					this.iTyreChange := true
					this.iRemainingTyreLaps := freshTyreLaps
				}
				else {
					this.iTyreChange := false
					this.iRemainingTyreLaps := remainingTyreLaps
				}
			}
			else {
				this.iTyreChange := true
				this.iRemainingTyreLaps := freshTyreLaps
			}

			if !this.iTyreChange {
				tyreCompound := strategy.TyreCompound[true]
				tyreCompoundColor := strategy.TyreCompoundColor[true]

				this.iStintLaps := Round(stintLaps)
			}
			else
				this.iStintLaps := Round(Min(stintLaps, this.iRemainingTyreLaps))

			this.iTyreCompound := tyreCompound
			this.iTyreCompoundColor := tyreCompoundColor

			lastPitstop := strategy.LastPitstop

			if lastPitstop {
				delta := (lastPitstop.Duration + (lastPitstop.StintLaps * lastPitstop.AvgLapTime))

				this.iTime := (lastPitstop.Time + delta)
				this.iRemainingSessionTime := (lastPitstop.RemainingSessionTime - delta)
			}
			else {
				this.iTime := (strategy.SessionStartTime + (lastStintLaps * strategy.AvgLapTime))
				this.iRemainingSessionTime := (strategy.RemainingSessionTime - (lastStintLaps * strategy.AvgLapTime))
			}

			weather := false
			airTemperature := false
			trackTemperature := false

			strategy.getWeather(this.Time / 60, &weather, &airTemperature, &trackTemperature)

			this.iWeather := weather
			this.iAirTemperature := airTemperature
			this.iTrackTemperature := trackTemperature

			this.iAvgLapTime := strategy.getAvgLapTime(this.StintLaps, this.Map, this.RemainingFuel, fuelConsumption
													 , weather, tyreCompound, tyreCompoundColor
													 , Max(strategy.MaxTyreLaps - this.RemainingTyreLaps, 0))

			this.iRefuelAmount := refuelAmount
			this.iDuration := strategy.calcPitstopDuration(refuelAmount, this.TyreChange)
		}

		loadFromConfiguration(configuration) {
			local lap := this.Lap

			super.loadFromConfiguration(configuration)

			this.iDriver := getMultiMapValue(configuration, "Pitstop", "Driver." . lap, false)
			this.iDriverName := getMultiMapValue(configuration, "Pitstop", "DriverName." . lap, "John Doe (JD)")

			this.iTime := getMultiMapValue(configuration, "Pitstop", "Time." . lap, 0)
			this.iDuration := getMultiMapValue(configuration, "Pitstop", "Duration." . lap, 0)

			this.iWeather := getMultiMapValue(configuration, "Pitstop", "Weather." . lap, this.Strategy.Weather)
			this.iAirTemperature := getMultiMapValue(configuration, "Pitstop", "AirTemperature." . lap, this.Strategy.AirTemperature)
			this.iTrackTemperature := getMultiMapValue(configuration, "Pitstop", "TrackTemperature." . lap, this.Strategy.TrackTemperature)

			this.iRefuelAmount := getMultiMapValue(configuration, "Pitstop", "RefuelAmount." . lap, 0)
			this.iTyreChange := getMultiMapValue(configuration, "Pitstop", "TyreChange." . lap, false)

			if this.iTyreChange {
				this.iTyreCompound := getMultiMapValue(configuration, "Pitstop", "TyreCompound." . lap, this.Strategy.TyreCompound)
				this.iTyreCompoundColor := getMultiMapValue(configuration, "Pitstop", "TyreCompoundColor." . lap, this.Strategy.TyreCompoundColor)
			}

			this.iStintLaps := getMultiMapValue(configuration, "Pitstop", "StintLaps." . lap, 0)

			this.iMap := getMultiMapValue(configuration, "Pitstop", "Map." . lap, 0)
			this.iAvgLapTime := getMultiMapValue(configuration, "Pitstop", "AvgLapTime." . lap, 0)
			this.iFuelConsumption := getMultiMapValue(configuration, "Pitstop", "FuelConsumption." . lap, 0)

			this.iRemainingSessionLaps := getMultiMapValue(configuration, "Pitstop", "RemainingSessionLaps." . lap
														 , getMultiMapValue(configuration, "Pitstop", "RemainingLaps." . lap, 0))
			this.iRemainingSessionTime := getMultiMapValue(configuration, "Pitstop", "RemainingSessionTime." . lap
														 , getMultiMapValue(configuration, "Pitstop", "RemainingTime." . lap, 0))
			this.iRemainingTyreLaps := getMultiMapValue(configuration, "Pitstop", "RemainingTyreLaps." . lap, 0)
			this.iRemainingFuel := getMultiMapValue(configuration, "Pitstop", "RemainingFuel." . lap, 0.0)
		}

		saveToConfiguration(configuration) {
			local lap := this.Lap

			super.saveToConfiguration(configuration)

			setMultiMapValue(configuration, "Pitstop", "Driver." . lap, this.Driver)
			setMultiMapValue(configuration, "Pitstop", "DriverName." . lap, this.DriverName)

			setMultiMapValue(configuration, "Pitstop", "Time." . lap, this.Time)
			setMultiMapValue(configuration, "Pitstop", "Duration." . lap, this.Duration)

			setMultiMapValue(configuration, "Pitstop", "Weather." . lap, this.Weather)
			setMultiMapValue(configuration, "Pitstop", "AirTemperature." . lap, this.AirTemperature)
			setMultiMapValue(configuration, "Pitstop", "TrackTemperature." . lap, this.TrackTemperature)

			setMultiMapValue(configuration, "Pitstop", "RefuelAmount." . lap, Ceil(this.RefuelAmount))
			setMultiMapValue(configuration, "Pitstop", "TyreChange." . lap, this.TyreChange)

			if this.iTyreChange {
				setMultiMapValue(configuration, "Pitstop", "TyreCompound." . lap, this.TyreCompound)
				setMultiMapValue(configuration, "Pitstop", "TyreCompoundColor." . lap, this.TyreCompoundColor)
			}

			setMultiMapValue(configuration, "Pitstop", "StintLaps." . lap, this.StintLaps)

			setMultiMapValue(configuration, "Pitstop", "Map." . lap, this.Map)
			setMultiMapValue(configuration, "Pitstop", "AvgLapTime." . lap, this.AvgLapTime)
			setMultiMapValue(configuration, "Pitstop", "FuelConsumption." . lap, this.FuelConsumption)

			setMultiMapValue(configuration, "Pitstop", "RemainingSessionLaps." . lap, this.RemainingSessionLaps)
			setMultiMapValue(configuration, "Pitstop", "RemainingSessionTime." . lap, this.RemainingSessionTime)
			setMultiMapValue(configuration, "Pitstop", "RemainingTyreLaps." . lap, this.RemainingTyreLaps)
			setMultiMapValue(configuration, "Pitstop", "RemainingFuel." . lap, this.RemainingFuel)
		}
	}

	StrategyManager {
		Get {
			return this.iStrategyManager
		}
	}

	Name {
		Get {
			return this.iName
		}
	}

	Version {
		Get {
			return this.iVersion
		}
	}

	Simulator {
		Get {
			return this.iSimulator
		}
	}

	Car {
		Get {
			return this.iCar
		}
	}

	Track {
		Get {
			return this.iTrack
		}
	}

	Weather[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.Weather
			else
				return this.iWeather
		}
	}

	AirTemperature[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.AirTemperature
			else
				return this.iAirTemperature
		}
	}

	TrackTemperature[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.TrackTemperature
			else
				return this.iTrackTemperature
		}
	}

	WeatherForecast[key?] {
		Get {
			return (isSet(key) ? this.iWeatherForecast[key] : this.iWeatherForecast)
		}
	}

	SessionType {
		Get {
			return this.iSessionType
		}
	}

	SessionLength {
		Get {
			return this.iSessionLength
		}
	}

	Map[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.Map
			else
				return this.iMap
		}
	}

	TC {
		Get {
			return this.iTC
		}
	}

	ABS {
		Get {
			return this.iABS
		}
	}

	TyreCompound[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.TyreCompound
			else
				return this.iTyreCompound
		}
	}

	TyreCompoundColor[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.TyreCompoundColor
			else
				return this.iTyreCompoundColor
		}
	}

	AvailableTyreSets[key?] {
		Get {
			return (isSet(key) ? this.iAvailableTyreSets[key] : this.iAvailableTyreSets)
		}

		Set {
			return (isSet(key) ? (this.iAvailableTyreSets[key] := value) : (this.iAvailableTyreSets := value))
		}
	}

	TyrePressures[asText := false] {
		Get {
			local pressures := [this.TyrePressureFL, this.TyrePressureFR, this.TyrePressureRL, this.TyrePressureRR]

			return (asText ? values2String(", ", pressures*) : pressures)
		}
	}

	TyrePressureFL {
		Get {
			return this.iTyrePressureFL
		}
	}

	TyrePressureFR {
		Get {
			return this.iTyrePressureFR
		}
	}

	TyrePressureRL {
		Get {
			return this.iTyrePressureRL
		}
	}

	TyrePressureRR {
		Get {
			return this.iTyrePressureRR
		}
	}

	StintLength {
		Get {
			return this.iStintLength
		}
	}

	FormationLap {
		Get {
			return this.iFormationLap
		}
	}

	PostRaceLap {
		Get {
			return this.iPostRaceLap
		}
	}

	FuelCapacity {
		Get {
			return this.iFuelCapacity
		}
	}

	SafetyFuel {
		Get {
			return this.iSafetyFuel
		}
	}

	PitstopDelta {
		Get {
			return this.iPitstopDelta
		}
	}

	PitstopFuelService {
		Get {
			return this.iPitstopFuelService
		}
	}

	PitstopTyreService {
		Get {
			return this.iPitstopTyreService
		}
	}

	PitstopServiceOrder {
		Get {
			return this.iPitstopServiceOrder
		}
	}

	Validator {
		Get {
			return this.iValidator
		}
	}

	PitstopRule {
		Get {
			return this.iPitstopRule
		}

		Set {
			return (this.iPitstopRule := value)
		}
	}

	RefuelRule {
		Get {
			return this.iRefuelRule
		}
	}

	TyreChangeRule {
		Get {
			return this.iTyreChangeRule
		}
	}

	TyreSets[index := false] {
		Get {
			return (index ? this.iTyreSets[index] : this.iTyreSets)
		}
	}

	StartStint {
		Get {
			return this.iStartStint
		}
	}

	StartLap {
		Get {
			return this.iStartLap
		}
	}

	StartTyreLaps {
		Get {
			return this.iStartTyreLaps
		}
	}

	StintStartTime {
		Get {
			return this.iStintStartTime
		}
	}

	SessionStartTime {
		Get {
			return this.iSessionStartTime
		}
	}

	StintLaps[lastStint := false] {
		Get {
			if (lastStint = "Max")
				return Floor(((this.StintLength * 60) - this.StintStartTime) / this.AvgLapTime)
			else if (lastStint && this.LastPitstop)
				return this.LastPitstop.StintLaps
			else
				return this.iStintLaps
		}
	}

	MaxTyreLaps {
		Get {
			return this.iMaxTyreLaps
		}
	}

	TyreLapsVariation {
		Get {
			return this.iTyreLapsVariation
		}
	}

	Time[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.Time
			else
				return 0
		}
	}

	RemainingSessionLaps[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.RemainingSessionLaps
			else
				return (this.calcSessionLaps() - this.StartLap)
		}
	}

	RemainingSessionTime[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.RemainingSessionTime
			else
				return (this.calcSessionTime() - this.SessionStartTime)
		}
	}

	StartFuel {
		Get {
			return this.iStartFuelAmount
		}
	}

	RemainingFuel[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.RemainingFuel
			else
				return this.iFuelAmount
		}
	}

	RemainingTyreLaps[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.RemainingTyreLaps
			else
				return this.iTyreLaps
		}
	}

	AvgLapTime[lastStint := false] {
		Get {
			local lastPitstop := this.LastPitstop
			local avgLapTime, ignore, pitstop

			if (lastStint = "Fixed")
				return this.iFixedLapTime
			else if (lastStint && lastPitstop)
				return lastPitstop.AvgLapTime
			else if (lastStint = "Session") {
				avgLapTime := 0

				for ignore, pitstop in this.Pitstops
					avgLapTime += pitstop.AvgLapTime

				if (avgLapTime == 0)
					return this.iAvgLapTime
				else
					return (avgLapTime / this.Pitstops.Length)
			}
			else
				return this.iAvgLapTime
		}

		Set {
			if (lastStint = "Fixed")
				return (this.iFixedLapTime := value)
			else
				throw "Invalid arguments detected in Strategy.AvgLapTime..."
		}
	}

	FuelConsumption[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.FuelConsumption
			else
				return this.iFuelConsumption
		}
	}

	Driver {
		Get {
			return this.iDriver
		}
	}

	DriverName {
		Get {
			return this.iDriverName
		}
	}

	Pitstops[index?] {
		Get {
			return (isSet(index) ? this.iPitstops[index] : this.iPitstops)
		}
	}

	LastPitstop {
		Get {
			local length := this.Pitstops.Length

			return ((length = 0) ? false : this.Pitstops[length])
		}
	}

	UseInitialConditions {
		Get {
			return this.iUseInitialConditions
		}
	}

	UseTelemetryData {
		Get {
			return this.iUseTelemetryData
		}
	}

	ConsumptionVariation {
		Get {
			return this.iConsumptionVariation
		}
	}

	InitialFuelVariation {
		Get {
			return this.iInitialFuelVariation
		}
	}

	TyreUsageVariation {
		Get {
			return this.iTyreUsageVariation
		}
	}

	TyreCompoundVariation {
		Get {
			return this.iTyreCompoundVariation
		}
	}

	__New(strategyManager, configuration := false, driver := false) {
		local initialStint := false
		local initialLap := false
		local initialStintTime := false
		local initialSessionTime := false
		local initialTyreLaps := false
		local initialFuelAmount := false
		local ecuMap := false
		local fuelConsumption := false
		local avgLapTime := false
		local simulator, car, track, weather, airTemperature, trackTemperature, sessionType, sessionLength
		local maxTyreLaps, tyreCompound, tyreCompoundColor, tyrePressures
		local stintLength, formationLap, postRaceLap, fuelCapacity, safetyFuel, pitstopDelta
		local pitstopFuelService, pitstopTyreService, pitstopServiceOrder
		local validator, pitstopRule, refuelRule, tyreChangeRule, tyreSets
		local useInitialConditions, useTelemetryData
		local consumptionVariation, initialFuelVariation, tyreUsageVariation, tyreCompoundVariation
		local duration, minute, forecast, lastWeather, lastAirTemperature, lastTrackTemperature

		this.iStrategyManager := strategyManager
		this.iDriver := driver

		super.__New(configuration)

		if !configuration {
			simulator := false
			car := false
			track := false
			weather := false
			airTemperature := false
			trackTemperature := false
			sessionType := false
			sessionLength := false
			maxTyreLaps := false
			tyreCompound := false
			tyreCompoundColor := false
			tyrePressures := false

			this.StrategyManager.getStrategySettings(&simulator, &car, &track, &weather, &airTemperature, &trackTemperature
												   , &sessionType, &sessionLength, &maxTyreLaps
												   , &tyreCompound, &tyreCompoundColor, &tyrePressures)

			this.iSimulator := simulator
			this.iCar := car
			this.iTrack := track
			this.iWeather := weather
			this.iAirTemperature := airTemperature
			this.iTrackTemperature := trackTemperature

			this.iSessionType := sessionType
			this.iSessionLength := sessionLength

			this.iMaxTyreLaps := maxTyreLaps

			this.iTyreCompound := tyreCompound
			this.iTyreCompoundColor := tyreCompoundColor
			this.iTyrePressureFL := tyrePressures[1]
			this.iTyrePressureFR := tyrePressures[2]
			this.iTyrePressureRL := tyrePressures[3]
			this.iTyrePressureRR := tyrePressures[4]

			if driver
				this.iDriverName := SessionDatabase.getDriverName(simulator, driver)

			stintLength := false
			formationLap := false
			postRaceLap := false
			fuelCapacity := false
			safetyFuel := false
			pitstopDelta := false
			pitstopFuelService := false
			pitstopTyreService := false
			pitstopServiceOrder := "Simultaneous"

			this.StrategyManager.getSessionSettings(&stintLength, &formationLap, &postRacelap, &fuelCapacity, &safetyFuel
												  , &pitstopDelta, &pitstopFuelService, &pitstopTyreService, &pitstopServiceOrder)

			this.iStintLength := stintLength
			this.iFormationLap := formationLap
			this.iPostRaceLap := postRaceLap
			this.iFuelCapacity := fuelCapacity
			this.iSafetyFuel := safetyFuel

			this.iPitstopDelta := pitstopDelta
			this.iPitstopFuelService := pitstopFuelService
			this.iPitstopTyreService := pitstopTyreService
			this.iPitstopServiceOrder := pitstopServiceOrder

			validator := false
			pitstopRule := false
			refuelRule := false
			tyreChangeRule := false
			tyreSets := false

			this.StrategyManager.getPitstopRules(&validator, &pitstopRule, &refuelRule, &tyreChangeRule, &tyreSets)

			this.iValidator := validator
			this.iPitstopRule := pitstopRule
			this.iRefuelRule := refuelRule
			this.iTyreChangeRule := tyreChangeRule
			this.iTyreSets := tyreSets

			useInitialConditions := false
			useTelemetryData := false
			consumptionVariation := false
			initialFuelVariation := false
			tyreUsageVariation := false
			tyreCompoundVariation := false

			this.StrategyManager.getSimulationSettings(&useInitialConditions, &useTelemetryData
													 , &consumptionVariation, &initialFuelVariation, &tyreUsageVariation, &tyreCompoundVariation)

			this.iUseInitialConditions := useInitialConditions
			this.iUseTelemetryData := useTelemetryData

			this.iConsumptionVariation := consumptionVariation
			this.iInitialFuelVariation := initialFuelVariation
			this.iTyreUsageVariation := tyreUsageVariation
			this.iTyreCompoundVariation := tyreCompoundVariation

			this.StrategyManager.getStartConditions(&initialStint, &initialLap, &initialStintTime, &initialSessionTime
												  , &initialTyreLaps, &initialFuelAmount, &ecuMap, &fuelConsumption, &avgLapTime)

			duration := ((sessionType = "Duration") ? sessionLength : (sessionLength * avgLapTime))
			forecast := []
			weather := false
			airTemperature := false
			trackTemperature := false
			lastWeather := this.Weather
			lastAirTemperature := this.AirTemperature
			lastTrackTemperature := this.TrackTemperature

			loop {
				minute := (A_Index * 10)

				if (minute > duration)
					break
				else {
					this.StrategyManager.getSessionWeather(minute, &weather, &airTemperature, &trackTemperature)

					if ((weather != lastWeather) || (airTemperature != lastAirTemperature) || (trackTemperature != lastTrackTemperature)) {
						lastWeather := weather
						lastAirTemperature := airTemperature
						lastTrackTemperature := trackTemperature

						forecast.Push(Array(minute, weather, airTemperature, trackTemperature))
					}
				}
			}

			this.iWeatherForecast := forecast
		}
	}

	dispose() {
		this.iPitstops := []
	}

	setStrategyManager(strategyManager) {
		this.iStrategyManager := strategyManager
	}

	setVersion(version) {
		this.iVersion := (version . "")
	}

	loadFromConfiguration(configuration) {
		local tyreSets, defaultPressure, ignore, lap, weatherForecast

		super.loadFromConfiguration(configuration)

		this.iName := getMultiMapValue(configuration, "General", "Name", translate("Unnamed"))
		this.iVersion := getMultiMapValue(configuration, "General", "Version", false)

		this.iSimulator := getMultiMapValue(configuration, "Session", "Simulator", "Unknown")
		this.iCar := getMultiMapValue(configuration, "Session", "Car", "Unknown")
		this.iTrack := getMultiMapValue(configuration, "Session", "Track", "Unknown")

		this.iWeather := getMultiMapValue(configuration, "Weather", "Weather", "Dry")
		this.iAirTemperature := getMultiMapValue(configuration, "Weather", "AirTemperature", 23)
		this.iTrackTemperature := getMultiMapValue(configuration, "Weather", "TrackTemperature", 27)

		weatherForecast := []

		loop getMultiMapValue(configuration, "Weather", "Forecasts", 0)
			weatherForecast.Push(string2Values(",", getMultiMapValue(configuration, "Weather", "Forecast." . A_Index)))

		this.iWeatherForecast := weatherForecast

		this.iFuelCapacity := getMultiMapValue(configuration, "Settings", "FuelCapacity", 0)
		this.iSafetyFuel := getMultiMapValue(configuration, "Settings", "SafetyFuel", 0)

		this.iSessionType := getMultiMapValue(configuration, "Session", "SessionType", "Duration")
		this.iSessionLength := getMultiMapValue(configuration, "Session", "SessionLength", 0)
		this.iFormationLap := getMultiMapValue(configuration, "Session", "FormationLap", false)
		this.iPostRaceLap := getMultiMapValue(configuration, "Session", "PostRaceLap", false)

		this.iStintLength := getMultiMapValue(configuration, "Session", "StintLength", 0)

		this.iPitstopDelta := getMultiMapValue(configuration, "Settings", "PitstopDelta", 0)
		this.iPitstopFuelService := string2Values(":", getMultiMapValue(configuration, "Settings", "PitstopFuelService", 0.0))

		if (this.iPitstopFuelService.Length = 1)
			this.iPitstopFuelService := this.iPitstopFuelService[1]

		this.iPitstopTyreService := getMultiMapValue(configuration, "Settings", "PitstopTyreService", 0.0)
		this.iPitstopServiceOrder := getMultiMapValue(configuration, "Settings", "PitstopServiceOrder", "Simultaneous")

		this.iValidator := getMultiMapValue(configuration, "Settings", "Validator", false)

		this.iPitstopRule := getMultiMapValue(configuration, "Settings", "PitstopRule", kUndefined)

		if (this.iPitstopRule == kUndefined)
			this.iPitstopRule := getMultiMapValue(configuration, "Settings", "PitstopRequired", false)

		if this.iPitstopRule
			if InStr(this.iPitstopRule, "-")
				this.iPitstopRule := string2Values("-", this.iPitstopRule)

		this.iRefuelRule := getMultiMapValue(configuration, "Settings", "PitstopRefuel", "Optional")

		if (this.iRefuelRule == false)
			this.iRefuelRule := "Optional"
		else if (this.iRefuelRule == true)
			this.iRefuelRule := "Required"

		this.iTyreChangeRule := getMultiMapValue(configuration, "Settings", "PitstopTyreChange", false)

		if (this.iTyreChangeRule == false)
			this.iTyreChangeRule := "Optional"
		else if (this.iTyreChangeRule == true)
			this.iTyreChangeRule := "Required"

		tyreSets := string2Values(";", getMultiMapValue(configuration, "Settings", "TyreSets", []))

		loop tyreSets.Length
			tyreSets[A_Index] := string2Values(":", tyreSets[A_Index])

		this.iTyreSets := tyreSets

		this.iMap := getMultiMapValue(configuration, "Setup", "Map", "n/a")
		this.iTC := getMultiMapValue(configuration, "Setup", "TC", "n/a")
		this.iABS := getMultiMapValue(configuration, "Setup", "ABS", "n/a")

		this.iStartStint := getMultiMapValue(configuration, "Session", "StartStint", 1)
		this.iStartLap := getMultiMapValue(configuration, "Session", "StartLap", 0)
		this.iStartTyreLaps := getMultiMapValue(configuration, "Session", "StartTyreLaps", 0)
		this.iStintStartTime := getMultiMapValue(configuration, "Session", "StintStartTime", 0)
		this.iSessionStartTime := getMultiMapValue(configuration, "Session", "SessionStartTime"
												 , getMultiMapValue(configuration, "Session", "StartTime", 0))

		this.iFuelAmount := getMultiMapValue(configuration, "Setup", "FuelAmount", 0.0)
		this.iStartFuelAmount := getMultiMapValue(configuration, "Setup", "StartFuelAmount", this.iFuelAmount)
		this.iTyreLaps := getMultiMapValue(configuration, "Setup", "TyreLaps", 0)

		this.iTyreCompound := getMultiMapValue(configuration, "Setup", "TyreCompound", "Dry")
		this.iTyreCompoundColor := getMultiMapValue(configuration, "Setup", "TyreCompoundColor", "Black")

		defaultPressure := ((this.iTyreCompound = "Dry") ? 26.5 : 30.0)

		this.iTyrePressureFL := getMultiMapValue(configuration, "Setup", "TyrePressureFL", defaultPressure)
		this.iTyrePressureFR := getMultiMapValue(configuration, "Setup", "TyrePressureFR", defaultPressure)
		this.iTyrePressureRL := getMultiMapValue(configuration, "Setup", "TyrePressureRL", defaultPressure)
		this.iTyrePressureRR := getMultiMapValue(configuration, "Setup", "TyrePressureRR", defaultPressure)

		this.iStintLaps := getMultiMapValue(configuration, "Strategy", "StintLaps", 0)
		this.iMaxTyreLaps := getMultiMapValue(configuration, "Strategy", "MaxTyreLaps", 0)

		this.iAvgLapTime := getMultiMapValue(configuration, "Strategy", "AvgLapTime", 0)
		this.iFuelConsumption := getMultiMapValue(configuration, "Strategy", "FuelConsumption", 0)

		this.iDriver := getMultiMapValue(configuration, "Strategy", "Driver", false)
		this.iDriverName := getMultiMapValue(configuration, "Strategy", "DriverName", "John Doe (JD)")

		for ignore, lap in string2Values(",", getMultiMapValue(configuration, "Strategy", "Pitstops", ""))
			this.Pitstops.Push(this.createPitstop(this.StartStint + A_Index - 1, lap, this.Driver
												, this.TyreCompound, this.TyreCompoundColor, configuration))

		this.iUseInitialConditions := getMultiMapValue(configuration, "Simulation", "UseInitialConditions", true)
		this.iUseTelemetryData := getMultiMapValue(configuration, "Simulation", "UseTelemetryData", true)

		this.iConsumptionVariation := getMultiMapValue(configuration, "Simulation", "ConsumptionVariation", 0)
		this.iInitialFuelVariation := getMultiMapValue(configuration, "Simulation", "InitialFuelVariation", 0)
		this.iTyreUsageVariation := getMultiMapValue(configuration, "Simulation", "TyreUsageVariation", 0)
		this.iTyreCompoundVariation := getMultiMapValue(configuration, "Simulation", "TyreCompoundVariation", 0)
	}

	saveToConfiguration(configuration) {
		local pitstopRule, tyreSets, ignore, descriptor, pitstops, ignore, pitstop

		super.saveToConfiguration(configuration)

		setMultiMapValue(configuration, "General", "Name", this.Name)
		setMultiMapValue(configuration, "General", "Version", this.iVersion)

		setMultiMapValue(configuration, "Settings", "FuelCapacity", this.FuelCapacity)
		setMultiMapValue(configuration, "Settings", "SafetyFuel", this.SafetyFuel)

		setMultiMapValue(configuration, "Settings", "PitstopDelta", this.PitstopDelta)

		if isObject(this.PitstopFuelService)
			setMultiMapValue(configuration, "Settings", "PitstopFuelService", values2String(":", this.PitstopFuelService*))
		else
			setMultiMapValue(configuration, "Settings", "PitstopFuelService", this.PitstopFuelService)

		setMultiMapValue(configuration, "Settings", "PitstopTyreService", this.PitstopTyreService)
		setMultiMapValue(configuration, "Settings", "PitstopServiceOrder", this.PitstopServiceOrder)

		setMultiMapValue(configuration, "Settings", "Validator", this.Validator)

		pitstopRule := this.PitstopRule

		if isObject(pitstopRule)
			pitstopRule := values2String("-", pitstopRule*)

		setMultiMapValue(configuration, "Settings", "PitstopRule", pitstopRule)
		setMultiMapValue(configuration, "Settings", "PitstopRefuel", this.RefuelRule)
		setMultiMapValue(configuration, "Settings", "PitstopTyreChange", this.TyreChangeRule)

		tyreSets := []

		for ignore, descriptor in this.TyreSets
			tyreSets.Push(values2String(":", descriptor*))

		setMultiMapValue(configuration, "Settings", "TyreSets", values2String(";", tyreSets*))

		setMultiMapValue(configuration, "Weather", "Weather", this.Weather)
		setMultiMapValue(configuration, "Weather", "AirTemperature", this.AirTemperature)
		setMultiMapValue(configuration, "Weather", "TrackTemperature", this.TrackTemperature)

		setMultiMapValue(configuration, "Weather", "Forecasts", this.WeatherForecast.Length)

		loop this.WeatherForecast.Length
			setMultiMapValue(configuration, "Weather", "Forecast." . A_Index, values2String(",", this.WeatherForecast[A_Index]*))

		setMultiMapValue(configuration, "Session", "Simulator", this.Simulator)
		setMultiMapValue(configuration, "Session", "Car", this.Car)
		setMultiMapValue(configuration, "Session", "Track", this.Track)

		setMultiMapValue(configuration, "Session", "SessionType", this.SessionType)
		setMultiMapValue(configuration, "Session", "SessionLength", this.SessionLength)
		setMultiMapValue(configuration, "Session", "FormationLap", this.FormationLap)
		setMultiMapValue(configuration, "Session", "PostRaceLap", this.PostRaceLap)

		setMultiMapValue(configuration, "Session", "StintLength", this.StintLength)

		setMultiMapValue(configuration, "Setup", "Map", this.Map)
		setMultiMapValue(configuration, "Setup", "TC", this.TC)
		setMultiMapValue(configuration, "Setup", "ABS", this.ABS)

		setMultiMapValue(configuration, "Session", "StartStint", this.StartStint)
		setMultiMapValue(configuration, "Session", "StartLap", this.StartLap)
		setMultiMapValue(configuration, "Session", "StartTyreLaps", this.StartTyreLaps)
		setMultiMapValue(configuration, "Session", "StintStartTime", this.StintStartTime)
		setMultiMapValue(configuration, "Session", "SessionStartTime", this.SessionStartTime)

		setMultiMapValue(configuration, "Setup", "StartFuelAmount", this.StartFuel)
		setMultiMapValue(configuration, "Setup", "FuelAmount", this.RemainingFuel)
		setMultiMapValue(configuration, "Setup", "TyreLaps", this.RemainingTyreLaps)

		setMultiMapValue(configuration, "Setup", "TyreCompound", this.TyreCompound)
		setMultiMapValue(configuration, "Setup", "TyreCompoundColor", this.TyreCompoundColor)

		setMultiMapValue(configuration, "Setup", "TyrePressureFL", this.TyrePressureFL)
		setMultiMapValue(configuration, "Setup", "TyrePressureFR", this.TyrePressureFR)
		setMultiMapValue(configuration, "Setup", "TyrePressureRL", this.TyrePressureRL)
		setMultiMapValue(configuration, "Setup", "TyrePressureRR", this.TyrePressureRR)

		setMultiMapValue(configuration, "Strategy", "StintLaps", this.StintLaps)
		setMultiMapValue(configuration, "Strategy", "MaxTyreLaps", this.MaxTyreLaps)

		setMultiMapValue(configuration, "Strategy", "AvgLapTime", this.AvgLapTime)
		setMultiMapValue(configuration, "Strategy", "FuelConsumption", this.FuelConsumption)

		setMultiMapValue(configuration, "Strategy", "Driver", this.Driver)
		setMultiMapValue(configuration, "Strategy", "DriverName", this.DriverName)

		pitstops := []

		for ignore, pitstop in this.Pitstops {
			pitstops.Push(pitstop.Lap)

			pitstop.saveToConfiguration(configuration)
		}

		setMultiMapValue(configuration, "Strategy", "Pitstops", values2String(", ", pitstops*))

		setMultiMapValue(configuration, "Simulation", "UseInitialConditions", this.UseInitialConditions)
		setMultiMapValue(configuration, "Simulation", "UseTelemetryData", this.UseTelemetryData)

		setMultiMapValue(configuration, "Simulation", "ConsumptionVariation", this.ConsumptionVariation)
		setMultiMapValue(configuration, "Simulation", "InitialFuelVariation", this.InitialFuelVariation)
		setMultiMapValue(configuration, "Simulation", "TyreUsageVariation", this.TyreUsageVariation)
		setMultiMapValue(configuration, "Simulation", "TyreCompoundVariation", this.TyreCompoundVariation)
	}

	initializeAvailableTyreSets() {
		local tyreCompound := this.TyreCompound
		local tyreSets := this.TyreSets
		local availableTyreSets := CaseInsenseMap()
		local tyreCompoundColors, ignore, compoundColor, descriptor, count

		if (tyreSets.Length == 0) {
			tyreCompoundColors := this.StrategyManager.getTyreCompoundColors(this.Weather, tyreCompound)

			if !inList(tyreCompoundColors, this.TyreCompoundColor)
				tyreCompoundColors.Push(this.TyreCompoundColor)

			for ignore, compoundColor in tyreCompoundColors
				availableTyreSets[compound(tyreCompound, compoundColor)] := 99
		}
		else
			for ignore, descriptor in tyreSets {
				count := descriptor[3]

				if ((descriptor[1] = this.TyreCompound) && (descriptor[2] = this.TyreCompoundColor))
					count -= 1

				if (count > 0)
					availableTyreSets[compound(descriptor[1], descriptor[2])] := count
			}

		this.AvailableTyreSets := availableTyreSets
	}

	createPitstop(nr, lap, driver, tyreCompound, tyreCompoundColor, configuration := false, adjustments := false) {
		return Strategy.Pitstop(this, nr, lap, driver, tyreCompound, tyreCompoundColor, configuration, adjustments)
	}

	setName(name) {
		this.iName := name
	}

	getWeather(minute, &weather, &airTemperature, &trackTemperature) {
		local pitstop := false
		local forecast := false
		local ignore, candidate

		if (this.WeatherForecast.Length > 0) {
			for ignore, candidate in this.WeatherForecast
				if candidate[1] < minute
					forecast := candidate
				else
					break
		}
		else {
			for ignore, candidate in this.Pitstops
				if ((candidate.Time / 60) < minute)
					pitstop := candidate
				else
					break
		}

		if forecast {
			weather := forecast[2]
			airTemperature := forecast[3]
			trackTemperature := forecast[4]
		}
		else if pitstop {
			weather := pitstop.Weather
			airTemperature := pitstop.AirTemperature
			trackTemperature := pitstop.TrackTemperature
		}
		else {
			weather := this.Weather
			airTemperature := this.AirTemperature
			trackTemperature := this.TrackTemperature
		}
	}

	getLaps(seconds) {
		local laps := []
		local index := false
		local curTime := 0
		local maxTime := 0
		local avgLapTime := this.AvgLapTime["Session"]
		local numLaps, pitstop

		if !this.LastPitstop
			numLaps := this.getSessionLaps()
		else
			numLaps := this.Pitstops[1].Lap

		maxTime := (numLaps * (avgLapTime / 60))

		loop {
			loop
				if (curTime > maxTime)
					break
				else {
					curTime += (seconds / 60)

					laps.Push(Floor((curTime / maxTime) * numLaps))
				}

			if !index {
				if !this.LastPitstop
					return laps

				index := 1
			}
			else
				index += 1

			if (index > this.Pitstops.Length)
				return laps
			else {
				pitstop := this.Pitstops[index]

				avgLapTime := pitstop.AvgLapTime
				numLaps += pitstop.StintLaps
				maxTime := ((pitstop.Time / 60) + (pitstop.Duration / 60) + (pitstop.StintLaps * (avgLapTime / 60)))
			}
		}
	}

	getAvgLapTime(numLaps, ecuMap, remainingFuel, fuelConsumption, weather, tyreCompound, tyreCompoundColor, tyreLaps) {
		return this.StrategyManager.getAvgLapTime(numLaps, ecuMap, remainingFuel, fuelConsumption
												, weather, tyreCompound, tyreCompoundColor, tyreLaps, this.AvgLapTime["Session"])
	}

	getMaxFuelLaps(remainingFuel, fuelConsumption, withSafety := true) {
		return Max(0, Floor((remainingFuel - (withSafety ? this.SafetyFuel : 0)) / fuelConsumption))
	}

	calcSessionLaps(avgLapTime := false, formationLap := true, postRaceLap := true) {
		local sessionLength := this.SessionLength
		local hasFormationLap := this.FormationLap
		local hasPostRaceLap := this.PostRaceLap

		if !avgLapTime
			avgLapTime := this.AvgLapTime["Session"]

		if (this.SessionType = "Duration")
			return Ceil(((sessionLength * 60) / avgLapTime) + ((formationLap && hasFormationLap) ? 1 : 0) + ((postRaceLap && hasPostRaceLap) ? 1 : 0))
		else
			return (sessionLength + ((formationLap && hasFormationLap) ? 1 : 0) + ((postRaceLap && hasPostRaceLap) ? 1 : 0))
	}

	calcSessionTime(avgLapTime := false, formationLap := true, postRaceLap := true) {
		local sessionLength := this.SessionLength
		local hasFormationLap := this.FormationLap
		local hasPostRaceLap := this.PostRaceLap

		if !avgLapTime
			avgLapTime := this.AvgLapTime["Session"]

		if (this.SessionType = "Duration")
			return ((sessionLength * 60) + (((formationLap && hasFormationLap) ? 1 : 0) * avgLapTime) + (((postRaceLap && hasPostRaceLap) ? 1 : 0) * avgLapTime))
		else
			return ((sessionLength + ((formationLap && hasFormationLap) ? 1 : 0) + ((postRaceLap && hasPostRaceLap) ? 1 : 0)) * avgLapTime)
	}

	calcRefuelAmount(targetFuel, startFuel, remainingSessionLaps, stintLaps) {
		local fuelConsumption := this.FuelConsumption[true]
		local currentFuel

		if ((((remainingSessionLaps - stintLaps) - (targetFuel / fuelConsumption)) <= 0) && this.PostRaceLap)
			stintLaps += 1

		currentFuel := Max(0, startFuel - (stintLaps * fuelConsumption))

		return Min(this.FuelCapacity, targetFuel + this.SafetyFuel) - currentFuel
	}

	calcPitstopDuration(refuelAmount, changeTyres) {
		local tyreService := (changeTyres ? this.PitstopTyreService : 0)
		local refuelService := this.PitstopFuelService

		if isNumber(refuelService)
			refuelService := ((refuelAmount / 10) * refuelService)
		else if (refuelService[1] = "Fixed")
			refuelService := refuelService[2]
		else
			refuelService := ((refuelAmount / 10) * refuelService[2])

		return (this.PitstopDelta + ((this.PitstopServiceOrder = "Simultaneous") ? Max(tyreService, refuelService) : (tyreService + refuelService)))
	}

	calcRemainingLaps(pitstopNr, currentLap, remainingStintLaps, remainingTyreLaps, remainingFuel, fuelConsumption) {
		return Floor(Min(this.StintLaps, remainingStintLaps, remainingTyreLaps
					   , this.getMaxFuelLaps(remainingFuel, fuelConsumption)))
	}

	calcNextPitstopLap(pitstopNr, currentLap
					 , remainingStintLaps, remainingSessionLaps, remainingTyreLaps, remainingFuel
					 , &adjusted) {
		local telemetryDB := this.StrategyManager.TelemetryDatabase
		local simulator := this.Simulator
		local car := this.Car
		local track := this.Track
		local qualifiedCompound := compound(this.TyreCompound[true], this.TyreCompoundColor[true])
		local fuelConsumption := this.FuelConsumption[true]
		local avgLapTime := this.AvgLapTime[true]
		local weather := false
		local airTemperature := false
		local trackTemperature := false
		local targetLap, pitstopRule, avgLapTime, openingLap, closingLap, time

		adjusted := false

		if (this.LastPitstop && !this.LastPitstop.TyreChange)
			remainingTyreLaps := this.MaxTyreLaps

		targetLap := (currentLap + this.calcRemainingLaps(pitstopNr, currentLap
														, remainingStintLaps, remainingTyreLaps
														, remainingFuel, fuelConsumption))

		loop
			if (A_Index >= (targetLap - currentLap))
				break
			else {
				time := (this.Time[true] + ((A_Index - 1) * avgLapTime))

				this.getWeather(time / 60, &weather, &airTemperature, &trackTemperature)

				if (!telemetryDB.suitableTyreCompound(simulator, car, track, weather, qualifiedCompound)
				 && telemetryDB.optimalTyreCompound(simulator, car, track
												  , weather, airTemperature, trackTemperature
												  , getKeys(this.AvailableTyreSets))) {
					targetLap := (currentLap + A_Index - 1)
					adjusted := true

					break
				}
			}

		pitstopRule := this.PitstopRule

		if ((pitstopNr = 1) && ((targetLap >= remainingSessionLaps) && pitstopRule) && (pitstopRule == true))
			targetLap := remainingSessionLaps - 2
		else if isObject(pitstopRule) {
			openingLap := (pitstopRule[1] * 60 / avgLapTime)
			closingLap := (pitstopRule[2] * 60 / avgLapTime)

			if ((targetLap >= openingLap) && (currentLap <= closingLap))
				if ((pitstopNr = 1) || (this.LastPitstop && (this.LastPitstop.Lap < openingLap))) {
					targetLap := Min(targetLap, Floor((pitstopRule[1] + ((pitstopRule[2] - pitstopRule[1]) / 2)) * 60 / avgLapTime))

					adjusted := true
				}
		}

		return targetLap
	}

	consumeTyreSet(tyreCompound, tyreCompoundColor) {
		local qualifiedCompound := compound(tyreCompound, tyreCompoundColor)
		local count

		if this.AvailableTyreSets.Has(qualifiedCompound) {
			count := (this.AvailableTyreSets[qualifiedCompound] - 1)

			if (count > 0)
				this.AvailableTyreSets[qualifiedCompound] := count
			else
				this.AvailableTyreSets.Delete(qualifiedCompound)
		}
	}

	chooseTyreCompoundColor(pitstops, pitstopNr, tyreCompound, tyreCompoundColor) {
		local qualifiedCompound, count, chooseNext, availableTyreSets
		local tyreCompoundColors, numColors, tries

		if (pitstopNr <= pitstops.Length) {
			if pitstops[pitstopNr].TyreChange {
				tyreCompoundColor := pitstops[pitstopNr].TyreCompoundColor

				; this.consumeTyreSet(tyreCompound, tyreCompoundColor)

				return tyreCompoundColor
			}
		}
		else {
			chooseNext := Round(Random(0.01, 0.99) * this.StrategyManager.TyreCompoundVariation / 100)

			if !chooseNext {
				if !this.AvailableTyreSets.Has(compound(tyreCompound, tyreCompoundColor))
					chooseNext := true
				else {
					; this.consumeTyreSet(tyreCompound, tyreCompoundColor)

					return tyreCompoundColor
				}
			}

			if chooseNext {
				availableTyreSets := this.AvailableTyreSets
				tyreCompoundColors := this.StrategyManager.TyreCompoundColors.Clone()
				numColors := tyreCompoundColors.Length

				tries := (100 * numColors)

				while (tries > 0) {
					tyreCompoundColor := tyreCompoundColors[Round(Random(1, numColors))]

					if availableTyreSets.Has(compound(tyreCompound, tyreCompoundColor)) {
						this.StrategyManager.TyreCompoundColor := tyreCompoundColor

						; this.consumeTyreSet(tyreCompound, tyreCompoundColor)

						return tyreCompoundColor
					}

					tries -= 1
				}
			}
		}

		return false
	}

	createStints(currentStint, currentLap, currentStintTime, currentSessionTime
			   , currentTyreLaps, startFuel, startFuelVariation, currentFuel
			   , stintLaps, maxTyreLaps, tyreLapsVariation
			   , ecuMap, fuelConsumption, avgLapTime, adjustments := false) {
		local valid := true
		local pitstopLap := 0
		local lastPitstopLap := 0
		local pitstopNr := 0
		local pitstops, lastPitstops, ignore
		local sessionLaps, numPitstops, fuelLaps, canonicalStintLaps, remainingFuel
		local tyreChange, tyreCompound, tyreCompoundColor, driverID, driverName, pitstop, telemetryDB, candidate
		local time, weather, airTemperature, trackTemperature, pitstopRule, adjusted, lastPitstop, missed

		this.iStartStint := currentStint
		this.iStartLap := currentLap
		this.iStartTyreLaps := currentTyreLaps
		this.iStintStartTime := currentStintTime
		this.iSessionStartTime := currentSessionTime
		this.iTyreLaps := Max(maxTyreLaps - currentTyreLaps, 0)
		this.iStartFuelAmount := startFuel
		this.iFuelAmount := currentFuel

		this.iStintLaps := stintLaps
		this.iMaxTyreLaps := maxTyreLaps
		this.iTyreLapsVariation := tyreLapsVariation

		this.iTyreLaps := Max((maxTyreLaps + (maxTyreLaps * tyreLapsVariation / 100 * (Min(100 - Sqrt(Random(0, 10000)), 100) / 100))) - currentTyreLaps, 0)

		this.iMap := ecuMap
		this.iFuelConsumption := fuelConsumption
		this.iAvgLapTime := avgLapTime

		lastPitstops := this.Pitstops

		pitstops := []
		this.iPitstops := pitstops

		sessionLaps := this.RemainingSessionLaps

		pitstopRule := this.PitstopRule
		numPitstops := pitstopRule

		if isInteger(numPitstops) {
			if (numPitstops > 1) {
				fuelLaps := Max(0, (currentFuel / fuelConsumption) - 1)
				canonicalStintLaps := Round(sessionLaps / (numPitstops + 1))

				if (fuelLaps < canonicalStintLaps)
					this.iStintLaps := Min(stintLaps, Round((sessionLaps - fuelLaps) / numPitstops))
				else
					this.iStintLaps := Min(stintLaps, canonicalStintLaps)
			}
		}
		else if isObject(numPitstops) {
			valid := false

			numPitstops := 1
		}
		else
			numPitstops := false

		loop {
			if (adjustments && (A_Index > (adjustments.Count)))
				break

			missed := false

			if !valid
				if isObject(pitstopRule) {
					valid := ((pitstopLap >= (pitstopRule[1] * 60 / avgLapTime)) && (pitstopLap <= (pitstopRule[2] * 60 / avgLapTime)))

					if !valid
						missed := (pitstopLap > (pitstopRule[2] * 60 / avgLapTime))
				}
				else
					valid := (pitstopNr >= numPitstops)

			pitstopNr := (currentStint + A_Index - 1)

			if (A_Index > 1)
				currentStintTime := 0

			remainingFuel := this.RemainingFuel[true]

			if (valid || missed)
				if (this.SessionType = "Duration") {
					if (this.RemainingSessionTime[true] <= 0)
						break
				}
				else {
					if (currentLap >= this.RemainingSessionLaps)
						break
				}

			if (adjustments && adjustments.Has(pitstopNr) && adjustments[pitstopNr].HasProp("Lap"))
				pitstopLap := adjustments[pitstopNr].Lap
			else {
				pitstopLap := this.calcNextPitstopLap(pitstopNr, currentLap
													, currentStintTime ? (((this.StintLength * 60) - currentStintTime) / avgLapTime)
																	   : stintLaps
													, this.RemainingSessionLaps[true], this.RemainingTyreLaps[true], remainingFuel
													, &adjusted)

				if adjusted
					if this.LastPitstop {
						lastPitstop := pitstops.Pop()

						lastPitstop.initialize(lastPitstop.TyreCompound, lastPitstop.TyreCompoundColor
											 , Map(lastPitstop.Nr, {StintLaps: (pitstopLap - lastPitstop.Lap)}))

						pitstops.Push(lastPitstop)
					}
			}

			if (pitstopLap = lastPitstopLap)
				break
			else
				lastPitstopLap := pitstopLap

			if adjustments {
				if (adjustments.Has(pitstopNr) && adjustments[pitstopNr].HasProp("TyreChange")) {
					tyreChange := adjustments[pitstopNr].TyreChange

					tyreCompound := tyreChange[1]
					tyreCompoundColor := tyreChange[2]
				}
				else {
					tyreCompound := false
					tyreCompoundColor := false
				}
			}
			else {
				telemetryDB := this.StrategyManager.TelemetryDatabase

				this.getWeather((this.Time[true] + (pitstopLap - currentLap) * avgLapTime) / 60, &weather, &airTemperature, &trackTemperature)

				candidate := telemetryDB.optimalTyreCompound(this.Simulator, this.Car, this.Track
														   , weather, airTemperature, trackTemperature
														   , getKeys(this.AvailableTyreSets))

				if candidate
					splitCompound(candidate, &tyreCompound, &tyreCompoundColor)
				else {
					tyreCompound := this.TyreCompound[true]
					tyreCompoundColor := this.TyreCompoundColor[true]
				}

				tyreCompoundColor := this.chooseTyreCompoundColor(lastPitstops, pitstopNr, tyreCompound, tyreCompoundColor)

				if !tyreCompoundColor
					tyreCompound := false
			}

			driverID := false
			driverName := false

			this.StrategyManager.getStintDriver(pitstopNr + 1, &driverID, &driverName)

			this.StrategyManager.setStintDriver(pitstopNr + 1, driverID)

			pitstop := this.createPitstop(pitstopNr, pitstopLap, driverID, tyreCompound, tyreCompoundColor, false, adjustments)

			if ((valid || missed) && !adjustments)
				if (this.SessionType = "Duration") {
					if (pitStop.RemainingSessionTime <= 0)
						break
				}
				else {
					if (pitstop.Lap >= this.RemainingSessionLaps)
						break
				}

			if ((numPitstops && (pitstopNr <= numPitstops)) || ((pitstop.StintLaps > 0) && ((pitstop.RefuelAmount > 0) || (pitstop.TyreChange)))) {
				if (tyreCompound && pitstop.TyreChange)
					this.consumeTyreSet(tyreCompound, tyreCompoundColor)

				pitstops.Push(pitstop)
			}
			else if (valid || startFuelVariation)
				break

			avgLapTime := pitstop.AvgLapTime
			currentLap := pitstopLap
		}

		for ignore, pitstop in lastPitstops
			pitstop.dispose()
	}

	adjustLastPitstop(superfluousLaps, allowDelete) {
		local pitstop, stintLaps, delta

		while (superfluousLaps > 0) {
			pitstop := this.LastPitstop

			if pitstop {
				stintLaps := pitstop.StintLaps

				if (stintLaps <= superfluousLaps) {
					if allowDelete {
						superfluousLaps -= stintLaps

						this.Pitstops.Pop()

						continue
					}
					else
						return
				}
				else {
					pitstop.iStintLaps -= superfluousLaps

					delta := Min((superfluousLaps * pitstop.FuelConsumption), pitstop.RefuelAmount)

					pitstop.iRefuelAmount -= delta
					pitstop.iRemainingFuel -= delta

					pitstop.iDuration := pitstop.Strategy.calcPitstopDuration(pitstop.RefuelAmount, pitstop.TyreChange)
				}
			}

			break
		}
	}

	adjustLastPitstopRefuelAmount() {
		local pitstops := this.Pitstops
		local numPitstops := pitstops.Length
		local remainingSessionLaps, refuelAmount, stintLaps, adjustments, adjustment, ignore, pitstop, key, value, pitstopNr, fixedLapTime

		if ((numPitstops > 1) && !pitstops[numPitstops].Fixed && !this.ConsumptionVariation && !this.InitialFuelVariation
															  && !this.TyreUsageVariation && !this.TyreCompoundVariation
															  && !isInstance(this, TrafficStrategy)) {
			remainingSessionLaps := Ceil(pitstops[numPitstops - 1].StintLaps + pitstops[numPitstops].StintLaps)

			if (false && pitstops[numPitstops - 1].Fixed) {
				refuelAmount := pitstops[numPitstops - 1].RefuelAmount
				stintLaps := pitstops[numPitstops - 1].StintLaps
			}
			else {
				refuelAmount := Ceil((pitstops[numPitstops - 1].RefuelAmount + pitstops[numPitstops].RefuelAmount) / 2)
				stintLaps := Ceil(remainingSessionLaps / 2)
			}

			adjustments := Map()

			for ignore, pitstop in pitstops {
				pitstopNr := pitstop.Nr

				adjustments[pitstopNr] := ((pitstopNr = pitstops[numPitstops].Nr) ? {StintLaps: pitstop.StintLaps}
																				  : {StintLaps: pitstop.StintLaps
																				   , Lap: pitstop.Lap})

				adjustments[pitstopNr].RemainingTyreLaps := pitstop.RemainingTyreLaps

				if pitstop.TyreChange
					adjustments[pitstopNr].TyreChange := Array(pitstop.TyreCompound, pitstop.TyreCompoundColor)
			}

			adjustment := adjustments[pitstops[numPitstops].Nr - 1]

			adjustment.RefuelAmount := refuelAmount
			adjustment.RemainingSessionLaps := remainingSessionLaps
			adjustment.StintLaps := stintLaps

			adjustments[pitstops[numPitstops].Nr].StintLaps := stintLaps
			adjustments[pitstops[numPitstops].Nr].Lap := (pitstops[numPitstops - 1].Lap + stintLaps)

			this.initializeAvailableTyreSets()

			fixedLapTime := this.AvgLapTime["Fixed"]

			if fixedLapTime
				this.StrategyManager.setFixedLapTime(fixedLapTime)

			try {
				this.createStints(this.StartStint, this.StartLap, this.StintStartTime, this.SessionStartTime
								, this.StartTyreLaps, this.StartFuel, this.InitialFuelVariation, this.RemainingFuel
								, this.StintLaps, this.MaxTyreLaps, this.TyreLapsVariation, this.Map, this.FuelConsumption
								, this.AvgLapTime, adjustments)
			}
			finally {
				if fixedLapTime
					this.StrategyManager.setFixedLapTime(false)
			}
		}
	}

	getPitstopTime() {
		local time := 0
		local ignore, pitstop

		for ignore, pitstop in this.Pitstops
			time += pitstop.Duration

		return time
	}

	getSessionLaps() {
		local pitstop := this.LastPitstop

		if pitstop
			return (pitstop.Lap + pitstop.StintLaps)
		else
			return (this.RemainingSessionLaps + this.StartLap)
	}

	getSessionDuration() {
		local pitstop := this.LastPitstop

		if pitstop
			return (pitstop.Time + pitstop.Duration + (pitstop.StintLaps * pitstop.AvgLapTime))
		else
			return (this.RemainingSessionTime + this.SessionStartTime)
	}

	getRemainingFuel() {
		local remainingFuel := this.RemainingFuel[true]
		local laps := this.StintLaps[true]
		local fuelConsumption := this.FuelConsumption[true]

		return remainingFuel - (laps * fuelConsumption)
	}
}

class TrafficStrategy extends Strategy {
	iTrafficScenario := false

	TrafficScenario {
		Get {
			return this.iTrafficScenario
		}
	}

	class TrafficPitstop extends Strategy.Pitstop {
		getPosition() {
			local driver := true
			local positions := true
			local runnings := true

			if this.Strategy.StrategyManager.getTrafficPositions(this.Strategy.TrafficScenario, this.Lap + 1
															   , &driver, &positions, &runnings)
				return positions[driver]
			else
				return false
		}

		getTrafficDensity(&numCars := false) {
			local driver := true
			local positions := true
			local runnings := true
			local begin, end, wrap

			if this.Strategy.StrategyManager.getTrafficPositions(this.Strategy.TrafficScenario, this.Lap + 1
															   , &driver, &positions, &runnings) {
				begin := runnings[driver]
				end := (begin + (this.Strategy.StrategyManager.ConsideredTraffic / 100))

				wrap := false

				if (end > 1) {
					wrap := true

					end -= 1
				}

				numCars := 0

				loop runnings.Length
					if (A_Index != driver)
						if (wrap && ((runnings[A_Index] > begin) || (runnings[A_Index] <= end)))
							numCars += 1
						else if (!wrap && (runnings[A_Index] > begin) && (runnings[A_Index] < end))
							numCars += 1

				return (numCars / runnings.Length)
			}
			else {
				numCars := 0

				return 0.0
			}
		}
	}

	createPitstop(id, lap, driver, tyreCompound, tyreCompoundColor, configuration := false, adjustments := false) {
		local pitstop := TrafficStrategy.TrafficPitstop(this, id, lap, driver, tyreCompound, tyreCompoundColor
													  , configuration, adjustments)

		if ((id == 1) && !this.TrafficScenario)
			this.iTrafficScenario := this.StrategyManager.getTrafficScenario(this, pitstop)

		return pitstop
	}

	calcNextPitstopLap(pitstopNr, currentLap
					 , remainingStintLaps, remainingSessionLaps, remainingTyreLaps, remainingFuel
					 , &adjusted) {
		local targetLap := super.calcNextPitstopLap(pitstopNr, currentLap, remainingStintLaps, remainingSessionLaps
												  , remainingTyreLaps, remainingFuel, &adjusted)
		local pitstopRule := this.PitstopRule
		local variationWindow, moreLaps, rnd, avgLapTime, openingLap, closingLap, fuelConsumption

		if !adjusted {
			fuelConsumption := this.FuelConsumption[true]
			variationWindow := this.StrategyManager.VariationWindow

			adjusted := true

			rnd := Random(-1.0, 1.0)

			return Min(currentLap + remainingStintLaps
					 , Floor(Max(currentLap, targetLap + ((rnd > 0) ? Floor(rnd * Max(0, Min(variationWindow
																						   , ((remainingFuel - ((targetLap - currentLap) * fuelConsumption)) / fuelConsumption))))
																	: (rnd * variationWindow)))))
		}
		else
			return targetLap
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Public Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

lookupLapTime(lapTimes, ecuMap, remainingFuel) {
	local selected := false
	local ignore, candidate

	for ignore, candidate in lapTimes
		if ((candidate["Map"] = ecuMap) && (!selected || (Abs(candidate["Fuel.Remaining"] - remainingFuel) < Abs(selected["Fuel.Remaining"] - remainingFuel))))
			selected := candidate

	return (selected ? selected["Lap.Time"] : false)
}