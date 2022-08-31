;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Strategy Representation         ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\RuleEngine.ahk
#Include ..\Assistants\Libraries\SessionDatabase.ahk


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

	StrategyManager[] {
		Get {
			return this.iStrategyManager
		}
	}

	TelemetryDatabase[] {
		Get {
			return this.iTelemetryDatabase
		}
	}

	SessionType[] {
		Get {
			return this.iSessionType
		}
	}

	TyreCompoundColors[] {
		Get {
			return this.iTyreCompoundColors
		}

		Set {
			return this.iTyreCompoundColors := value
		}
	}

	TyreCompound[] {
		Get {
			return this.iTyreCompound
		}

		Set {
			return this.iTyreCompound := value
		}
	}

	TyreCompoundColor[] {
		Get {
			return this.iTyreCompoundColor
		}

		Set {
			return this.iTyreCompoundColor := value
		}
	}

	TyreCompoundVariation[] {
		Get {
			return this.iTyreCompoundVariation
		}

		Set {
			return this.iTyreCompoundVariation := value
		}
	}

	__New(strategyManager, sessionType, telemetryDatabase) {
		this.iStrategyManager := strategyManager
		this.iSessionType := sessionType
		this.iTelemetryDatabase := telemetryDatabase
	}

	createKnowledgeBase(facts, productions, reductions) {
		local engine := new RuleEngine(productions, reductions, facts)

		return new KnowledgeBase(engine, engine.createFacts(), engine.createRules())
	}

	loadRules(compiler, validator, ByRef productions, ByRef reductions) {
		local rules, message, title

		FileRead rules, % kResourcesDirectory . "Strategy\Rules\Strategy Validation.rules"

		productions := false
		reductions := false

		compiler.compileRules(rules, productions, reductions)

		try {
			FileRead rules, % getFileName(validator . ".rules", kUserHomeDirectory . "Validators\", kResourcesDirectory . "Strategy\Validators\")

			if (rules != "")
				compiler.compileRules(rules, productions, reductions)
		}
		catch exception {
			message := (IsObject(exception) ? exception.Message : exception)
			title := translate("Error")

			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			MsgBox 262192, %title%, % translate("Cannot load the custom validation rules.") . "`n`n" . message
			OnMessage(0x44, "")
		}
	}

	scenarioValid(strategy, validator) {
		local reqPitstops := strategy.PitstopRule
		local knowledgeBase, rules, rule, resultSet, refuelRule, valid, ignore, pitstop, tyreChangeRule
		local number, pitstop, tyreCompound, tyreCompoundColor, productions, reductions

		if IsObject(reqPitstops)
			reqPitstops := 1

		if (strategy.Pitstops.Length() < reqPitstops)
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
				compiler := new RuleCompiler()
				goal := compiler.compileGoal("validScenario()")
			}

			if (validator != lastValidator) {
				productions := false
				reductions := false

				this.loadRules(compiler, validator, productions, reductions)

				knowledgeBase := this.createKnowledgeBase({}, productions, reductions)
			}

			rules := knowledgeBase.Rules

			for ignore, rule in rules.Reductions["setup", 3].clone()
				rules.removeRule(rule)

			for ignore, rule in rules.Reductions["pitstop", 4].clone()
				rules.removeRule(rule)

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

				knowledgeBase.addRule(compiler.compileRule("pitstop(" . number . "," . Round(pitstop.RefuelAmount) . ","
																	  . tyreCompound . "," . tyreCompoundColor . ")"))
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

	getStrategySettings(ByRef simulator, ByRef car, ByRef track, ByRef weather, ByRef airTemperature, ByRef trackTemperature
					  , ByRef sessionType, ByRef sessionLength
					  , ByRef maxTyreLaps, ByRef tyreCompound, ByRef tyreCompoundColor, ByRef tyrePressures) {
		return this.StrategyManager.getStrategySettings(simulator, car, track, weather, airTemperature, trackTemperature
													  , sessionType, sessionLength, maxTyreLaps, tyreCompound, tyreCompoundColor, tyrePressures)
	}

	getSessionSettings(ByRef stintLength, ByRef formationLap, ByRef postRaceLap, ByRef fuelCapacity, ByRef safetyFuel
					 , ByRef pitstopDelta, ByRef pitstopFuelService, ByRef pitstopTyreService, ByRef pitstopServiceOrder) {
		return this.StrategyManager.getSessionSettings(stintLength, formationLap, postRaceLap, fuelCapacity, safetyFuel
													 , pitstopDelta, pitstopFuelService, pitstopTyreService, pitstopServiceOrder)
	}

	getSessionWeather(minute, ByRef weather, ByRef airTemperature, ByRef trackTemperature) {
		return this.StrategyManager.getSessionWeather(minute, weather, airTemperature, trackTemperature)
	}

	getStartConditions(ByRef initialStint, ByRef initialLap, ByRef initialStintTime, ByRef initialSessionTime
					 , ByRef initialTyreLaps, ByRef initialFuelAmount
					 , ByRef initialMap, ByRef initialFuelConsumption, ByRef initialAvgLapTime) {
		return this.StrategyManager.getStartConditions(initialStint, initialLap, initialStintTime
													 , initialSessionTime, initialTyreLaps, initialFuelAmount
													 , initialMap, initialFuelConsumption, initialAvgLapTime)
	}

	getSimulationSettings(ByRef useInitialConditions, ByRef useTelemetryData, ByRef consumptionVariation, ByRef initialFuelVariation
						, ByRef tyreUsageVariation, ByRef tyreCompoundVariation) {
		return this.StrategyManager.getSimulationSettings(useInitialConditions, useTelemetryData, consumptionVariation, initialFuelVariation
														, tyreUsageVariation, tyreCompoundVariation)
	}

	getPitstopRules(ByRef validator, ByRef pitstopRule, ByRef refuelRule, ByRef tyreChangeRule, ByRef tyreSets) {
		return this.StrategyManager.getPitstopRules(validator, pitstopRule, refuelRule, tyreChangeRule, tyreSets)
	}

	getStintDriver(stintNumber, ByRef driverID, ByRef driverName) {
		return this.StrategyManager.getStintDriver(stintNumber, driverID, driverName)
	}

	setStintDriver(stintNumber, driverID) {
		this.TelemetryDatabase.setDrivers(driverID)
	}

	getAvgLapTime(numLaps, map, remainingFuel, fuelConsumption, weather, tyreCompound, tyreCompoundColor, tyreLaps, default := false) {
		if this.iFixedLapTime
			return this.iFixedLapTime
		else
			return this.StrategyManager.getAvgLapTime(numLaps, map, remainingFuel, fuelConsumption, weather, tyreCompound, tyreCompoundColor, tyreLaps, default)
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

	acquireTelemetryData(ByRef electronicsData, ByRef tyresData, verbose, ByRef progress) {
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
		local message, compound, candidate

		this.getStrategySettings(simulator, car, track, weather, airTemperature, trackTemperature
							   , sessionType, sessionLength, maxTyreLaps, tyreCompound, tyreCompoundColor, tyrePressures)

		compound := compound(tyreCompound, tyreCompoundColor)

		if !telemetryDB.suitableTyreCompound(simulator, car, track, weather, compound) {
			candidate := telemetryDB.optimalTyreCompound(simulator, car, track, weather, airTemperature, trackTemperature)

			if candidate
				splitCompound(candidate, tyreCompound, tyreCompoundColor)
		}

		if verbose {
			message := translate("Reading Electronics Data...")

			showProgress({progress: progress, message: message})
		}

		electronicsData := this.acquireElectronicsData(weather, tyreCompound, tyreCompoundColor)

		Sleep 200

		if verbose {
			message := translate("Reading Tyre Data...")

			showProgress({progress: progress + 2, message: message})
		}

		tyresData := this.acquireTyresData(weather, tyreCompound, tyreCompoundColor)

		Sleep 200

		if verbose
			progress += 5
	}

	createScenarios(electronicsData, tyresData, verbose, ByRef progress) {
		throw "Virtual method StrategySimulation.createScenarios must be implemented in a subclass..."
	}

	createScenarioStrategy(name, initialStint, initialLap, initialStintTime, initialSessionTime
						 , initialTyreLaps, maxTyreLaps, tyreLapsVariation
						 , stintLaps, formationLap, avgLapTime
						 , map, fuelConsumption, consumptionVariation
						 , initialFuelAmount, initialFuelVariation, fuelCapacity
						 , weather, tyreCompound, tyreCompoundColor) {
		local driverID := false
		local driverName := false
		local strategy, currentConsumption, rnd, startFuel, startFuelAmount, lapTime

		this.getStintDriver(initialStint, driverID, driverName)

		this.setStintDriver(initialStint, driverID)

		strategy := this.createStrategy(name, driverID)

		currentConsumption := (fuelConsumption - ((fuelConsumption / 100) * consumptionVariation))

		Random rnd, 0, 1

		if (Round(rnd) = 1)
			startFuel := initialFuelAmount + (initialFuelVariation / 100 * fuelCapacity)
		else
			startFuel := initialFuelAmount - (initialFuelVariation / 100 * fuelCapacity)

		startFuelAmount := Min(fuelCapacity, Max(startFuel, initialFuelAmount / 2))

		if formationLap
			startFuelAmount -= currentConsumption

		lapTime := this.getAvgLapTime(stintLaps, map, startFuelAmount, currentConsumption
									, weather, tyreCompound, tyreCompoundColor, 0, avgLapTime)

		this.createStints(strategy, initialStint, initialLap, initialStintTime, initialSessionTime, initialTyreLaps, startFuelAmount
						, stintLaps, maxTyreLaps, tyreLapsVariation, map, currentConsumption, lapTime)

		return strategy
	}

	createStints(strategy, initialStint, initialLap, initialStintTime, initialSessionTime, initialTyreLaps, initialFuelAmount
			   , stintLaps, maxTyreLaps, tyreLapsVariation, map, consumption, lapTime) {
		strategy.createStints(initialStint, initialLap, initialStintTime, initialSessionTime, initialTyreLaps, initialFuelAmount
							, stintLaps, maxTyreLaps, tyreLapsVariation, map, consumption, lapTime)
	}

	optimizeScenarios(scenarios, verbose, ByRef progress) {
		local strategy, name, avgLapTime, targetTime, sessionTime, superfluousLaps, reqPitstops, message
		local avgLapTime, openingLap, closingLap, ignore, pitstop

		if (this.SessionType = "Duration")
			for name, strategy in scenarios {
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

				if IsObject(reqPitstops) {
					avgLapTime := strategy.AvgLapTime
					openingLap := (reqPitstops[1] * 60 / avgLapTime)
					closingLap := (reqPitstops[2] * 60 / avgLapTime)

					for ignore, pitstop in strategy.Pitstops
						if ((pitstop.Lap >= openingLap) && (pitstop.Lap <= closingLap)) {
							reqPitstops := A_Index

							break
						}
				}

				if (superfluousLaps > 0)
					strategy.adjustLastPitstop(superfluousLaps, (strategy.Pitstops.Length() > reqPitstops) || !reqPitstops)

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
		local sLaps, cLaps, sTime, cTime

		if (this.SessionType = "Duration") {
			sLaps := scenario1.getSessionLaps()
			cLaps := scenario2.getSessionLaps()
			sTime := scenario1.getSessionDuration()
			cTime := scenario2.getSessionDuration()

			if (sLaps > cLaps)
				return scenario1
			else if ((sLaps = cLaps) && (sTime < cTime))
				return scenario1
			else if ((sLaps = cLaps) && (sTime = cTime) && (scenario2.FuelConsumption[true] > scenario1.FuelConsumption[true] ))
				return scenario1
			else
				return scenario2
		}
		else {
			if (scenario1.getSessionDuration() < scenario2.getSessionDuration())
				return scenario1
			else if ((scenario1.getSessionDuration() = scenario2.getSessionDuration())
				  && ((scenario2.FuelConsumption[true] > scenario1.FuelConsumption[true])
				   || (scenario2.RemainingFuel[true] > scenario1.RemainingFuel[true])))
				return scenario1
			else
				return scenario2
		}
	}

	evaluateScenarios(scenarios, verbose, ByRef progress) {
		local candidate := false
		local name, strategy, message

		for name, strategy in scenarios {
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
		local window := (verbose ? this.StrategyManager.Window : false)
		local progress := 0
		local electronicsData := false
		local tyresData := false
		local x, y, progressWindow, message, scenarios, scenario, ignore, disposable

		if verbose {
			x := Round((A_ScreenWidth - 300) / 2)
			y := A_ScreenHeight - 150

			progressWindow := showProgress({x: x, y: y, color: "Blue", title: translate("Acquiring Telemetry Data")})

			if window {
				Gui %progressWindow%:+Owner%window%
				Gui %window%:+Disabled
			}
		}

		Sleep 200

		this.acquireTelemetryData(electronicsData, tyresData, verbose, progress)

		if verbose {
			message := translate("Creating Scenarios...")

			showProgress({progress: progress, color: "Green", title: translate("Running Simulation")})
		}

		Sleep 200

		scenarios := this.createScenarios(electronicsData, tyresData, verbose, progress)

		if verbose {
			message := translate("Optimizing Scenarios...")

			showProgress({progress: progress, message: message})
		}

		Sleep 200

		scenarios := this.optimizeScenarios(scenarios, verbose, progress)

		if verbose {
			message := translate("Evaluating Scenarios...")

			showProgress({progress: progress, message: message})
		}

		Sleep 200

		scenario := this.evaluateScenarios(scenarios, verbose, progress)

		if scenario {
			if verbose {
				message := translate("Choose Scenario...")

				showProgress({progress: progress, message: message})
			}

			Sleep 200

			this.chooseScenario(scenario)
		}
		else
			this.chooseScenario(false)

		for ignore, disposable in scenarios
			if (disposable != scenario)
				disposable.dispose()

		if verbose {
			message := translate("Finished...")

			showProgress({progress: 100, message: message})

			Sleep 200

			hideProgress()

			if window
				Gui %window%:-Disabled
		}
	}
}

class VariationSimulation extends StrategySimulation {
	createScenarios(electronicsData, tyresData, verbose, ByRef progress) {
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
		local map := false
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

		this.getStrategySettings(simulator, car, track, weather, airTemperature, trackTemperature
							   , sessionType, sessionLength, maxTyreLaps, tyreCompound, tyreCompoundColor, tyrePressures)

		this.getSessionSettings(stintLength, formationLap, postRaceLap, fuelCapacity, safetyFuel
							  , pitstopDelta, pitstopFuelService, pitstopTyreService, pitstopServiceOrder)

		this.getStartConditions(initialStint, initialLap, initialStintTime, initialSessionTime
							  , initialTyreLaps, initialFuelAmount, map, fuelConsumption, avgLapTime)

		if initialLap
			formationLap := false

		this.getSimulationSettings(useInitialConditions, useTelemetryData, consumption, initialFuel, tyreUsage, tyreCompoundVariation)

		consumptionSteps := 1
		tyreUsageSteps := tyreUsage
		tyreCompoundVariationSteps := tyreCompoundVariation / 4
		initialFuelSteps := initialFuel / 10

		scenarios := {}
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
				splitCompound(candidate, targetTyreCompound, targetTyreCompoundColor)

		}

		loop { ; consumption
			loop { ; initialFuel
				loop { ; tyreUsage
					loop { ; tyreCompoundVariation
						if useInitialConditions {
							if verbose {
								message := (translate("Creating Initial Scenario with Map ") . simMapEdit . translate(":") . variation++ . translate("..."))

								showProgress({progress: progress, message: message})
							}

							stintLaps := Floor((stintLength * 60) / avgLapTime)

							name := (translate("Initial Conditions - Map ") . map)

							this.setFixedLapTime(avgLapTime)

							try {
								scenarios[name . translate(":") . variation]
									:= this.createScenarioStrategy(name
																 , initialStint, initialLap, initialStintTime, initialSessionTime
																 , initialTyreLaps, maxTyreLaps, tyreLapsVariation
																 , stintLaps, formationLap, avgLapTime
																 , map, fuelConsumption, consumption
																 , initialFuelAmount, initialFuel, fuelCapacity
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

							this.getStintDriver(initialStint, driverID, driverName)

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
																 , initialFuelAmount, initialFuel, fuelCapacity
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

	RandomFactor[] {
		Get {
			return this.iRandomFactor
		}
	}

	NumScenarios[] {
		Get {
			return this.iNumScenarios
		}
	}

	VariationWindow[] {
		Get {
			return this.iVariationWindow
		}
	}

	UseLapTimeVariation[] {
		Get {
			return this.iUseLapTimeVariation
		}
	}

	UseDriverErrors[] {
		Get {
			return this.iUseDriverErrors
		}
	}

	UsePitstops[] {
		Get {
			return this.iUsePitstops
		}
	}

	OverTakeDelta[] {
		Get {
			return this.iOverTakeDelta
		}
	}

	ConsideredTraffic[] {
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

	getTrafficSettings(ByRef randomFactor, ByRef numScenarios, ByRef variationWindow
					 , ByRef useLapTimeVariation, ByRef useDriverErrors, ByRef usePitstops
					 , ByRef overTakeDelta, ByRef consideredTraffic) {
		return this.StrategyManager.getTrafficSettings(randomFactor, numScenarios, variationWindow
													 , useLapTimeVariation, useDriverErrors, usePitstops
													 , overTakeDelta, consideredTraffic)
	}

	getTrafficScenario(strategy, pitstop) {
		return this.StrategyManager.getTrafficScenario(strategy, pitstop.Lap + 1, this.RandomFactor, this.NumScenarios
													 , this.UseLapTimeVariation, this.UseDriverErrors, this.UsePitstops
													 , this.OverTakeDelta)
	}

	getTrafficPositions(trafficScenario, targetLap, ByRef driver, ByRef positions, ByRef runnings) {
		return this.StrategyManager.getTrafficPositions(trafficScenario, targetLap, driver, positions, runnings)
	}

	compareScenarios(scenario1, scenario2) {
		local pitstops1 := scenario1.Pitstops.Length()
		local pitstops2 := scenario2.Pitstops.Length()
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

				if (position1 < position2)
					return scenario1
				else if (position1 > position2)
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
						return base.compareScenarios(scenario1, scenario2)
				}
			}
		}
		else
			return base.compareScenarios(scenario1, scenario2)
	}

	createScenarios(electronicsData, tyresData, verbose, ByRef progress) {
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
		local map := false
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

		this.getStrategySettings(simulator, car, track, weather, airTemperature, trackTemperature
							   , sessionType, sessionLength, maxTyreLaps, tyreCompound, tyreCompoundColor, tyrePressures)

		this.getSessionSettings(stintLength, formationLap, postRaceLap, fuelCapacity, safetyFuel
							  , pitstopDelta, pitstopFuelService, pitstopTyreService, pitstopServiceOrder)

		this.getTrafficSettings(randomFactor, numScenarios, variationWindow
							  , useLapTimeVariation, useDriverErrors, usePitstops
							  , overTakeDelta, consideredTraffic)

		if ((randomFactor == 0) && (variationWindow == 0) && !useLapTimeVariation && !useDriverErrors && !usePitstops)
			numScenarios := 1

		this.setTrafficSettings(randomFactor, numScenarios, variationWindow
							  , useLapTimeVariation, useDriverErrors, usePitstops
							  , overTakeDelta, consideredTraffic)

		this.getStartConditions(initialStint, initialLap, initialStintTime, initialSessionTime
							  , initialTyreLaps, initialFuelAmount
							  , map, fuelConsumption, avgLapTime)

		if initialLap
			formationLap := false

		this.getSimulationSettings(useInitialConditions, useTelemetryData, consumption, initialFuel, tyreUsage, tyreCompoundVariation)

		consumptionSteps := 1
		tyreUsageSteps := tyreUsage
		tyreCompoundVariationSteps := tyreCompoundVariation / 4
		initialFuelSteps := initialFuel / 10

		scenarios := {}
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
					splitCompound(candidate, targetTyreCompound, targetTyreCompoundColor)

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
							if useInitialConditions {
								if verbose {
									message := (translate("Creating Initial Scenario with Map ") . simMapEdit  . translate(":") . variation++ . translate("..."))

									showProgress({progress: progress, message: message})
								}

								stintLaps := Floor((stintLength * 60) / avgLapTime)

								name := (translate("Initial Conditions - Map ") . map)

								this.setFixedLapTime(avgLapTime)

								try {
									scenarios[name . translate(":") . variation]
										:= this.createScenarioStrategy(name
																	 , initialStint, initialLap, initialStintTime, initialSessionTime
																	 , initialTyreLaps, maxTyreLaps, tyreLapsVariation
																	 , stintLaps, formationLap, avgLapTime
																	 , map, fuelConsumption, consumption
																	 , initialFuelAmount, initialFuel, fuelCapacity
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

								this.getStintDriver(initialStint, driverID, driverName)

								this.setStintDriver(initialStint, driverID)

								for ignore, mapData in this.acquireElectronicsData(weather, targetTyreCompound, targetTyreCompoundColor) {
									this.getStintDriver(initialStint, driverID, driverName)

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
																	 , initialFuelAmount, initialFuel, fuelCapacity
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

			if (scenarios.Count() == 0)
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
	iStintStartTime := 0
	iSessionStartTime := 0

	iFuelAmount := 0

	iTyreCompound := "Dry"
	iTyreCompoundColor := "Black"

	iAvailableTyreSets := {}

	iTyrePressureFL := "2.7"
	iTyrePressureFR := "2.7"
	iTyrePressureRL := "2.7"
	iTyrePressureRR := "2.7"

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

		Strategy[]  {
			Get {
				return this.iStrategy
			}
		}

		Nr[]  {
			Get {
				return this.iNr
			}
		}

		Lap[]  {
			Get {
				return this.iLap
			}
		}

		Driver[]  {
			Get {
				return this.iDriver
			}
		}

		DriverName[]  {
			Get {
				return this.iDriverName
			}
		}

		Time[]  {
			Get {
				return this.iTime
			}
		}

		Duration[] {
			Get {
				return this.iDuration
			}
		}

		Weather[] {
			Get {
				return this.iWeather
			}
		}

		AirTemperature[] {
			Get {
				return this.iAirTemperature
			}
		}

		TrackTemperature[] {
			Get {
				return this.iTrackTemperature
			}
		}

		TyreChange[] {
			Get {
				return this.iTyreChange
			}
		}

		TyreCompound[] {
			Get {
				return this.iTyreCompound
			}
		}

		TyreCompoundColor[] {
			Get {
				return this.iTyreCompoundColor
			}
		}

		RefuelAmount[] {
			Get {
				return this.iRefuelAmount
			}
		}

		StintLaps[] {
			Get {
				return this.iStintLaps
			}
		}

		Fixed[] {
			Get {
				return this.iFixed
			}
		}

		Map[] {
			Get {
				return this.iMap
			}
		}

		FuelConsumption[] {
			Get {
				return this.iFuelConsumption
			}
		}

		AvgLapTime[] {
			Get {
				return this.iAvgLapTime
			}
		}

		RemainingSessionLaps[] {
			Get {
				return this.iRemainingSessionLaps
			}
		}

		RemainingSessionTime[] {
			Get {
				return this.iRemainingSessionTime
			}
		}

		RemainingTyreLaps[] {
			Get {
				return this.iRemainingTyreLaps
			}
		}

		RemainingFuel[] {
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
				this.iDriverName := new SessionDatabase().getDriverName(strategy.Simulator, driver)

			base.__New(configuration)

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
			local refuelRule := strategy.RefuelRule
			local tyreChangeRule := strategy.TyreChangeRule
			local remainingFuel := strategy.RemainingFuel[true]
			local remainingSessionLaps := strategy.RemainingSessionLaps[true]
			local fuelConsumption := strategy.FuelConsumption[true]
			local lastStintLaps := Floor(Min(remainingFuel / fuelConsumption, strategy.LastPitstop ? (lap - strategy.LastPitstop.Lap) : lap))
			local stintLaps, refuelAmount, tyreChange, remainingTyreLaps, variation, freshTyreLaps, lastPitstop, delta, rnd
			local avgLapTime, openingLap, closingLap, weather, airTemperature, trackTemperature

			if (adjustments && adjustments.HasKey(nr) && adjustments[nr].HasKey("RemainingSessionLaps"))
				remainingSessionLaps := (adjustments[nr].RemainingSessionLaps + lastStintLaps)

			if (adjustments && adjustments.HasKey(nr) && adjustments[nr].HasKey("StintLaps"))
				stintLaps := adjustments[nr].StintLaps
			else
				stintLaps := Floor(Min(remainingSessionLaps - lastStintLaps, strategy.StintLaps
									 , strategy.getMaxFuelLaps(strategy.FuelCapacity, fuelConsumption)))

			if IsObject(pitstopRule) {
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

			if (adjustments && adjustments.HasKey(nr)) {
				if adjustments[nr].HasKey("RefuelAmount")
					refuelAmount := adjustments[nr].RefuelAmount

				if adjustments[nr].HasKey("TyreChange")
					tyreChange := (adjustments[nr].TyreChange != false)
			}

			if (this.Fixed && (refuelRule = "Required") && (refuelAmount <= 0))
				refuelAmount := 1
			else if ((refuelRule = "Always") && (refuelAmount <= 0))
				refuelAmount := 1
			else if (refuelAmount <= 0)
				refuelAmount := 0

			this.iRemainingSessionLaps := (remainingSessionLaps - lastStintLaps)
			this.iRemainingFuel := (remainingFuel - (lastStintLaps * fuelConsumption) + refuelAmount)

			remainingTyreLaps := (strategy.RemainingTyreLaps[true] - lastStintLaps)

			Random rnd, -10, 100

			variation := (strategy.TyreLapsVariation / 100 * rnd)

			freshTyreLaps := (strategy.MaxTyreLaps + (strategy.MaxTyreLaps / 100 * variation))

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
				this.iRemainingTyreLaps := (tyreChange ? freshTyreLaps : remainingTyreLaps)
			}
			else if (!tyreCompound && !tyreCompoundColor)
				this.iRemainingTyreLaps := remainingTyreLaps
			else if (tyreCompound && tyreCompoundColor
				  && ((strategy.TyreCompound[true] != tyreCompound) || (strategy.TyreCompoundColor[true] != tyreCompoundColor))) {
				this.iTyreChange := true
				this.iRemainingTyreLaps := freshTyreLaps
			}
			else if ((remainingTyreLaps - stintLaps) >= 0) {
				if (this.Fixed && (tyreChangeRule = "Required") && (IsObject(pitstopRule) || (remainingTyreLaps >= this.iRemainingSessionLaps))) {
					this.iTyreChange := true
					this.iRemainingTyreLaps := freshTyreLaps
				}
				else
					this.iRemainingTyreLaps := remainingTyreLaps
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

			strategy.getWeather(this.Time / 60, weather, airTemperature, trackTemperature)

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

			base.loadFromConfiguration(configuration)

			this.iDriver := getConfigurationValue(configuration, "Pitstop", "Driver." . lap, false)
			this.iDriverName := getConfigurationValue(configuration, "Pitstop", "DriverName." . lap, "John Doe (JD)")

			this.iTime := getConfigurationValue(configuration, "Pitstop", "Time." . lap, 0)
			this.iDuration := getConfigurationValue(configuration, "Pitstop", "Duration." . lap, 0)

			this.iWeather := getConfigurationValue(configuration, "Pitstop", "Weather." . lap, this.Strategy.Weather)
			this.iAirTemperature := getConfigurationValue(configuration, "Pitstop", "AirTemperature." . lap, this.Strategy.AirTemperature)
			this.iTrackTemperature := getConfigurationValue(configuration, "Pitstop", "TrackTemperature." . lap, this.Strategy.TrackTemperature)

			this.iRefuelAmount := getConfigurationValue(configuration, "Pitstop", "RefuelAmount." . lap, 0)
			this.iTyreChange := getConfigurationValue(configuration, "Pitstop", "TyreChange." . lap, false)

			if this.iTyreChange {
				this.iTyreCompound := getConfigurationValue(configuration, "Pitstop", "TyreCompound." . lap, this.Strategy.TyreCompound)
				this.iTyreCompoundColor := getConfigurationValue(configuration, "Pitstop", "TyreCompoundColor." . lap, this.Strategy.TyreCompoundColor)
			}

			this.iStintLaps := getConfigurationValue(configuration, "Pitstop", "StintLaps." . lap, 0)

			this.iMap := getConfigurationValue(configuration, "Pitstop", "Map." . lap, 0)
			this.iAvgLapTime := getConfigurationValue(configuration, "Pitstop", "AvgLapTime." . lap, 0)
			this.iFuelConsumption := getConfigurationValue(configuration, "Pitstop", "FuelConsumption." . lap, 0)

			this.iRemainingSessionLaps := getConfigurationValue(configuration, "Pitstop", "RemainingSessionLaps." . lap
															  , getConfigurationValue(configuration, "Pitstop", "RemainingLaps." . lap, 0))
			this.iRemainingSessionTime := getConfigurationValue(configuration, "Pitstop", "RemainingSessionTime." . lap
															  , getConfigurationValue(configuration, "Pitstop", "RemainingTime." . lap, 0))
			this.iRemainingTyreLaps := getConfigurationValue(configuration, "Pitstop", "RemainingTyreLaps." . lap, 0)
			this.iRemainingFuel := getConfigurationValue(configuration, "Pitstop", "RemainingFuel." . lap, 0.0)
		}

		saveToConfiguration(configuration) {
			local lap := this.Lap

			base.saveToConfiguration(configuration)

			setConfigurationValue(configuration, "Pitstop", "Driver." . lap, this.Driver)
			setConfigurationValue(configuration, "Pitstop", "DriverName." . lap, this.DriverName)

			setConfigurationValue(configuration, "Pitstop", "Time." . lap, this.Time)
			setConfigurationValue(configuration, "Pitstop", "Duration." . lap, this.Duration)

			setConfigurationValue(configuration, "Pitstop", "Weather." . lap, this.Weather)
			setConfigurationValue(configuration, "Pitstop", "AirTemperature." . lap, this.AirTemperature)
			setConfigurationValue(configuration, "Pitstop", "TrackTemperature." . lap, this.TrackTemperature)

			setConfigurationValue(configuration, "Pitstop", "RefuelAmount." . lap, Ceil(this.RefuelAmount))
			setConfigurationValue(configuration, "Pitstop", "TyreChange." . lap, this.TyreChange)

			if this.iTyreChange {
				setConfigurationValue(configuration, "Pitstop", "TyreCompound." . lap, this.TyreCompound)
				setConfigurationValue(configuration, "Pitstop", "TyreCompoundColor." . lap, this.TyreCompoundColor)
			}

			setConfigurationValue(configuration, "Pitstop", "StintLaps." . lap, this.StintLaps)

			setConfigurationValue(configuration, "Pitstop", "Map." . lap, this.Map)
			setConfigurationValue(configuration, "Pitstop", "AvgLapTime." . lap, this.AvgLapTime)
			setConfigurationValue(configuration, "Pitstop", "FuelConsumption." . lap, this.FuelConsumption)

			setConfigurationValue(configuration, "Pitstop", "RemainingSessionLaps." . lap, this.RemainingSessionLaps)
			setConfigurationValue(configuration, "Pitstop", "RemainingSessionTime." . lap, this.RemainingSessionTime)
			setConfigurationValue(configuration, "Pitstop", "RemainingTyreLaps." . lap, this.RemainingTyreLaps)
			setConfigurationValue(configuration, "Pitstop", "RemainingFuel." . lap, this.RemainingFuel)
		}
	}

	StrategyManager[] {
		Get {
			return this.iStrategyManager
		}
	}

	Name[] {
		Get {
			return this.iName
		}
	}

	Version[] {
		Get {
			return this.iVersion
		}
	}

	Simulator[] {
		Get {
			return this.iSimulator
		}
	}

	Car[] {
		Get {
			return this.iCar
		}
	}

	Track[] {
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

	WeatherForecast[key := false] {
		Get {
			return (key ? this.iWeatherForecast[key] : this.iWeatherForecast)
		}
	}

	SessionType[] {
		Get {
			return this.iSessionType
		}
	}

	SessionLength[] {
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

	TC[] {
		Get {
			return this.iTC
		}
	}

	ABS[] {
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

	AvailableTyreSets[key := false] {
		Get {
			return (key ? this.iAvailableTyreSets[key] : this.iAvailableTyreSets)
		}

		Set {
			return (key ? (this.iAvailableTyreSets[key] := value) : (this.iAvailableTyreSets := value))
		}
	}

	TyrePressures[asText := false] {
		Get {
			local pressures := [this.TyrePressureFL, this.TyrePressureFR, this.TyrePressureRL, this.TyrePressureRR]

			return (asText ? values2String(", ", pressures*) : pressures)
		}
	}

	TyrePressureFL[] {
		Get {
			return this.iTyrePressureFL
		}
	}

	TyrePressureFR[] {
		Get {
			return this.iTyrePressureFR
		}
	}

	TyrePressureRL[] {
		Get {
			return this.iTyrePressureRL
		}
	}

	TyrePressureRR[] {
		Get {
			return this.iTyrePressureRR
		}
	}

	StintLength[] {
		Get {
			return this.iStintLength
		}
	}

	FormationLap[] {
		Get {
			return this.iFormationLap
		}
	}

	PostRaceLap[] {
		Get {
			return this.iPostRaceLap
		}
	}

	FuelCapacity[] {
		Get {
			return this.iFuelCapacity
		}
	}

	SafetyFuel[] {
		Get {
			return this.iSafetyFuel
		}
	}

	PitstopDelta[] {
		Get {
			return this.iPitstopDelta
		}
	}

	PitstopFuelService[] {
		Get {
			return this.iPitstopFuelService
		}
	}

	PitstopTyreService[] {
		Get {
			return this.iPitstopTyreService
		}
	}

	PitstopServiceOrder[] {
		Get {
			return this.iPitstopServiceOrder
		}
	}

	Validator[] {
		Get {
			return this.iValidator
		}
	}

	PitstopRule[] {
		Get {
			return this.iPitstopRule
		}

		Set {
			return (this.iPitstopRule := value)
		}
	}

	RefuelRule[] {
		Get {
			return this.iRefuelRule
		}
	}

	TyreChangeRule[] {
		Get {
			return this.iTyreChangeRule
		}
	}

	TyreSets[index := false] {
		Get {
			return (index ? this.iTyreSets[index] : this.iTyreSets)
		}
	}

	StartStint[] {
		Get {
			return this.iStartStint
		}
	}

	StartLap[] {
		Get {
			return this.iStartLap
		}
	}

	StintStartTime[] {
		Get {
			return this.iStintStartTime
		}
	}

	SessionStartTime[] {
		Get {
			return this.iSessionStartTime
		}
	}

	StintLaps[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.StintLaps
			else
				return this.iStintLaps
		}
	}

	MaxTyreLaps[] {
		Get {
			return this.iMaxTyreLaps
		}
	}

	TyreLapsVariation[] {
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

			if (lastStint && lastPitstop)
				return lastPitstop.AvgLapTime
			else if (lastStint = "Session") {
				avgLapTime := 0

				for ignore, pitstop in this.Pitstops
					avgLapTime += pitstop.AvgLapTime

				if (avgLapTime == 0)
					return this.iAvgLapTime
				else
					return (avgLapTime / this.Pitstops.Length())
			}
			else
				return this.iAvgLapTime
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

	Driver[] {
		Get {
			return this.iDriver
		}
	}

	DriverName[] {
		Get {
			return this.iDriverName
		}
	}

	Pitstops[index := false] {
		Get {
			return (index ? this.iPitstops[index] : this.iPitstops)
		}
	}

	LastPitstop[] {
		Get {
			local length := this.Pitstops.Length()

			return ((length = 0) ? false : this.Pitstops[length])
		}
	}

	UseInitialConditions[] {
		Get {
			return this.iUseInitialConditions
		}
	}

	UseTelemetryData[] {
		Get {
			return this.iUseTelemetryData
		}
	}

	ConsumptionVariation[] {
		Get {
			return this.iConsumptionVariation
		}
	}

	InitialFuelVariation[] {
		Get {
			return this.iInitialFuelVariation
		}
	}

	TyreUsageVariation[] {
		Get {
			return this.iTyreUsageVariation
		}
	}

	TyreCompoundVariation[] {
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
		local map := false
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

		base.__New(configuration)

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

			this.StrategyManager.getStrategySettings(simulator, car, track, weather, airTemperature, trackTemperature
												   , sessionType, sessionLength, maxTyreLaps
												   , tyreCompound, tyreCompoundColor, tyrePressures)

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
				this.iDriverName := new SessionDatabase().getDriverName(simulator, driver)

			stintLength := false
			formationLap := false
			postRaceLap := false
			fuelCapacity := false
			safetyFuel := false
			pitstopDelta := false
			pitstopFuelService := false
			pitstopTyreService := false
			pitstopServiceOrder := "Simultaneous"

			this.StrategyManager.getSessionSettings(stintLength, formationLap, postRacelap, fuelCapacity, safetyFuel
												  , pitstopDelta, pitstopFuelService, pitstopTyreService, pitstopServiceOrder)

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

			this.StrategyManager.getPitstopRules(validator, pitstopRule, refuelRule, tyreChangeRule, tyreSets)

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

			this.StrategyManager.getSimulationSettings(useInitialConditions, useTelemetryData
													 , consumptionVariation, initialFuelVariation, tyreUsageVariation, tyreCompoundVariation)

			this.iUseInitialConditions := useInitialConditions
			this.iUseTelemetryData := useTelemetryData

			this.iConsumptionVariation := consumptionVariation
			this.iInitialFuelVariation := initialFuelVariation
			this.iTyreUsageVariation := tyreUsageVariation
			this.iTyreCompoundVariation := tyreCompoundVariation

			this.StrategyManager.getStartConditions(initialStint, initialLap, initialStintTime, initialSessionTime
												  , initialTyreLaps, initialFuelAmount, map, fuelConsumption, avgLapTime)

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
					this.StrategyManager.getSessionWeather(minute, weather, airTemperature, trackTemperature)

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

		base.loadFromConfiguration(configuration)

		this.iName := getConfigurationValue(configuration, "General", "Name", translate("Unnamed"))
		this.iVersion := getConfigurationValue(configuration, "General", "Version", false)

		this.iSimulator := getConfigurationValue(configuration, "Session", "Simulator", "Unknown")
		this.iCar := getConfigurationValue(configuration, "Session", "Car", "Unknown")
		this.iTrack := getConfigurationValue(configuration, "Session", "Track", "Unknown")

		this.iWeather := getConfigurationValue(configuration, "Weather", "Weather", "Dry")
		this.iAirTemperature := getConfigurationValue(configuration, "Weather", "AirTemperature", 23)
		this.iTrackTemperature := getConfigurationValue(configuration, "Weather", "TrackTemperature", 27)

		weatherForecast := []

		loop % getConfigurationValue(configuration, "Weather", "Forecasts", 0)
			weatherForecast.Push(string2Values(",", getConfigurationValue(configuration, "Weather", "Forecast." . A_Index)))

		this.iWeatherForecast := weatherForecast

		this.iFuelCapacity := getConfigurationValue(configuration, "Settings", "FuelCapacity", 0)
		this.iSafetyFuel := getConfigurationValue(configuration, "Settings", "SafetyFuel", 0)

		this.iSessionType := getConfigurationValue(configuration, "Session", "SessionType", "Duration")
		this.iSessionLength := getConfigurationValue(configuration, "Session", "SessionLength", 0)
		this.iFormationLap := getConfigurationValue(configuration, "Session", "FormationLap", false)
		this.iPostRaceLap := getConfigurationValue(configuration, "Session", "PostRaceLap", false)

		this.iStintLength := getConfigurationValue(configuration, "Session", "StintLength", 0)

		this.iPitstopDelta := getConfigurationValue(configuration, "Settings", "PitstopDelta", 0)
		this.iPitstopFuelService := getConfigurationValue(configuration, "Settings", "PitstopFuelService", 0.0)
		this.iPitstopTyreService := getConfigurationValue(configuration, "Settings", "PitstopTyreService", 0.0)
		this.iPitstopServiceOrder := getConfigurationValue(configuration, "Settings", "PitstopServiceOrder", "Simultaneous")

		this.iValidator := getConfigurationValue(configuration, "Settings", "Validator", false)

		this.iPitstopRule := getConfigurationValue(configuration, "Settings", "PitstopRule", kUndefined)

		if (this.iPitstopRule == kUndefined)
			this.iPitstopRule := getConfigurationValue(configuration, "Settings", "PitstopRequired", false)

		if this.iPitstopRule
			if InStr(this.iPitstopRule, "-")
				this.iPitstopRule := string2Values("-", this.iPitstopRule)

		this.iRefuelRule := getConfigurationValue(configuration, "Settings", "PitstopRefuel", "Optional")

		if (this.iRefuelRule == false)
			this.iRefuelRule := "Optional"
		else if (this.iRefuelRule == true)
			this.iRefuelRule := "Required"

		this.iTyreChangeRule := getConfigurationValue(configuration, "Settings", "PitstopTyreChange", false)

		if (this.iTyreChangeRule == false)
			this.iTyreChangeRule := "Optional"
		else if (this.iTyreChangeRule == true)
			this.iTyreChangeRule := "Required"

		tyreSets := string2Values(";", getConfigurationValue(configuration, "Settings", "TyreSets", []))

		loop % tyreSets.Length()
			tyreSets[A_Index] := string2Values(":", tyreSets[A_Index])

		this.iTyreSets := tyreSets

		this.iMap := getConfigurationValue(configuration, "Setup", "Map", "n/a")
		this.iTC := getConfigurationValue(configuration, "Setup", "TC", "n/a")
		this.iABS := getConfigurationValue(configuration, "Setup", "ABS", "n/a")

		this.iStartStint := getConfigurationValue(configuration, "Session", "StartStint", 1)
		this.iStartLap := getConfigurationValue(configuration, "Session", "StartLap", 0)
		this.iStintStartTime := getConfigurationValue(configuration, "Session", "StintStartTime", 0)
		this.iSessionStartTime := getConfigurationValue(configuration, "Session", "SessionStartTime"
													  , getConfigurationValue(configuration, "Session", "StartTime", 0))

		this.iFuelAmount := getConfigurationValue(configuration, "Setup", "FuelAmount", 0.0)
		this.iTyreLaps:= getConfigurationValue(configuration, "Setup", "TyreLaps", 0)

		this.iTyreCompound := getConfigurationValue(configuration, "Setup", "TyreCompound", "Dry")
		this.iTyreCompoundColor := getConfigurationValue(configuration, "Setup", "TyreCompoundColor", "Black")

		defaultPressure := ((this.iTyreCompound = "Dry") ? 27.7 : 30.0)

		this.iTyrePressureFL := getConfigurationValue(configuration, "Setup", "TyrePressureFL", defaultPressure)
		this.iTyrePressureFR := getConfigurationValue(configuration, "Setup", "TyrePressureFR", defaultPressure)
		this.iTyrePressureRL := getConfigurationValue(configuration, "Setup", "TyrePressureRL", defaultPressure)
		this.iTyrePressureRR := getConfigurationValue(configuration, "Setup", "TyrePressureRR", defaultPressure)

		this.iStintLaps := getConfigurationValue(configuration, "Strategy", "StintLaps", 0)
		this.iMaxTyreLaps := getConfigurationValue(configuration, "Strategy", "MaxTyreLaps", 0)

		this.iAvgLapTime := getConfigurationValue(configuration, "Strategy", "AvgLapTime", 0)
		this.iFuelConsumption := getConfigurationValue(configuration, "Strategy", "FuelConsumption", 0)

		this.iDriver := getConfigurationValue(configuration, "Strategy", "Driver", false)
		this.iDriverName := getConfigurationValue(configuration, "Strategy", "DriverName", "John Doe (JD)")

		for ignore, lap in string2Values(",", getConfigurationValue(configuration, "Strategy", "Pitstops", ""))
			this.Pitstops.Push(this.createPitstop(this.StartStint + A_Index - 1, lap, this.Driver
												, this.TyreCompound, this.TyreCompoundColor, configuration))

		this.iUseInitialConditions := getConfigurationValue(configuration, "Simulation", "UseInitialConditions", true)
		this.iUseTelemetryData := getConfigurationValue(configuration, "Simulation", "UseTelemetryData", true)

		this.iConsumptionVariation := getConfigurationValue(configuration, "Simulation", "ConsumptionVariation", 0)
		this.iInitialFuelVariation := getConfigurationValue(configuration, "Simulation", "InitialFuelVariation", 0)
		this.iTyreUsageVariation := getConfigurationValue(configuration, "Simulation", "TyreUsageVariation", 0)
		this.iTyreCompoundVariation := getConfigurationValue(configuration, "Simulation", "TyreCompoundVariation", 0)
	}

	saveToConfiguration(configuration) {
		local pitstopRule, tyreSets, ignore, descriptor, pitstops, ignore, pitstop

		base.saveToConfiguration(configuration)

		setConfigurationValue(configuration, "General", "Name", this.Name)
		setConfigurationValue(configuration, "General", "Version", this.iVersion)

		setConfigurationValue(configuration, "Settings", "FuelCapacity", this.FuelCapacity)
		setConfigurationValue(configuration, "Settings", "SafetyFuel", this.SafetyFuel)

		setConfigurationValue(configuration, "Settings", "PitstopDelta", this.PitstopDelta)
		setConfigurationValue(configuration, "Settings", "PitstopFuelService", this.PitstopFuelService)
		setConfigurationValue(configuration, "Settings", "PitstopTyreService", this.PitstopTyreService)
		setConfigurationValue(configuration, "Settings", "PitstopServiceOrder", this.PitstopServiceOrder)

		setConfigurationValue(configuration, "Settings", "Validator", this.Validator)

		pitstopRule := this.PitstopRule

		if IsObject(pitstopRule)
			pitstopRule := values2String("-", pitstopRule*)

		setConfigurationValue(configuration, "Settings", "PitstopRule", pitstopRule)
		setConfigurationValue(configuration, "Settings", "PitstopRefuel", this.RefuelRule)
		setConfigurationValue(configuration, "Settings", "PitstopTyreChange", this.TyreChangeRule)

		tyreSets := []

		for ignore, descriptor in this.TyreSets
			tyreSets.Push(values2String(":", descriptor*))

		setConfigurationValue(configuration, "Settings", "TyreSets", values2String(";", tyreSets*))

		setConfigurationValue(configuration, "Weather", "Weather", this.Weather)
		setConfigurationValue(configuration, "Weather", "AirTemperature", this.AirTemperature)
		setConfigurationValue(configuration, "Weather", "TrackTemperature", this.TrackTemperature)

		setConfigurationValue(configuration, "Weather", "Forecasts", this.WeatherForecast.Length())

		loop % this.WeatherForecast.Length()
			setConfigurationValue(configuration, "Weather", "Forecast." . A_Index, values2String(",", this.WeatherForecast[A_Index]*))

		setConfigurationValue(configuration, "Session", "Simulator", this.Simulator)
		setConfigurationValue(configuration, "Session", "Car", this.Car)
		setConfigurationValue(configuration, "Session", "Track", this.Track)

		setConfigurationValue(configuration, "Session", "SessionType", this.SessionType)
		setConfigurationValue(configuration, "Session", "SessionLength", this.SessionLength)
		setConfigurationValue(configuration, "Session", "FormationLap", this.FormationLap)
		setConfigurationValue(configuration, "Session", "PostRaceLap", this.PostRaceLap)

		setConfigurationValue(configuration, "Session", "StintLength", this.StintLength)

		setConfigurationValue(configuration, "Setup", "Map", this.Map)
		setConfigurationValue(configuration, "Setup", "TC", this.TC)
		setConfigurationValue(configuration, "Setup", "ABS", this.ABS)

		setConfigurationValue(configuration, "Session", "StartStint", this.StartStint)
		setConfigurationValue(configuration, "Session", "StartLap", this.StartLap)
		setConfigurationValue(configuration, "Session", "StintStartTime", this.StintStartTime)
		setConfigurationValue(configuration, "Session", "SessionStartTime", this.SessionStartTime)

		setConfigurationValue(configuration, "Setup", "FuelAmount", this.RemainingFuel)
		setConfigurationValue(configuration, "Setup", "TyreLaps", this.RemainingTyreLaps)

		setConfigurationValue(configuration, "Setup", "TyreCompound", this.TyreCompound)
		setConfigurationValue(configuration, "Setup", "TyreCompoundColor", this.TyreCompoundColor)

		setConfigurationValue(configuration, "Setup", "TyrePressureFL", this.TyrePressureFL)
		setConfigurationValue(configuration, "Setup", "TyrePressureFR", this.TyrePressureFR)
		setConfigurationValue(configuration, "Setup", "TyrePressureRL", this.TyrePressureRL)
		setConfigurationValue(configuration, "Setup", "TyrePressureRR", this.TyrePressureRR)

		setConfigurationValue(configuration, "Strategy", "StintLaps", this.StintLaps)
		setConfigurationValue(configuration, "Strategy", "MaxTyreLaps", this.MaxTyreLaps)

		setConfigurationValue(configuration, "Strategy", "AvgLapTime", this.AvgLapTime)
		setConfigurationValue(configuration, "Strategy", "FuelConsumption", this.FuelConsumption)

		setConfigurationValue(configuration, "Strategy", "Driver", this.Driver)
		setConfigurationValue(configuration, "Strategy", "DriverName", this.DriverName)

		pitstops := []

		for ignore, pitstop in this.Pitstops {
			pitstops.Push(pitstop.Lap)

			pitstop.saveToConfiguration(configuration)
		}

		setConfigurationValue(configuration, "Strategy", "Pitstops", values2String(", ", pitstops*))

		setConfigurationValue(configuration, "Simulation", "UseInitialConditions", this.UseInitialConditions)
		setConfigurationValue(configuration, "Simulation", "UseTelemetryData", this.UseTelemetryData)

		setConfigurationValue(configuration, "Simulation", "ConsumptionVariation", this.ConsumptionVariation)
		setConfigurationValue(configuration, "Simulation", "InitialFuelVariation", this.InitialFuelVariation)
		setConfigurationValue(configuration, "Simulation", "TyreUsageVariation", this.TyreUsageVariation)
		setConfigurationValue(configuration, "Simulation", "TyreCompoundVariation", this.TyreCompoundVariation)
	}

	initializeAvailableTyreSets() {
		local tyreCompound := this.TyreCompound
		local tyreSets := this.TyreSets
		local availableTyreSets := {}
		local tyreCompoundColors, ignore, compoundColor, descriptor, count

		if (tyreSets.Length() == 0) {
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
		return new this.Pitstop(this, nr, lap, driver, tyreCompound, tyreCompoundColor, configuration, adjustments)
	}

	setName(name) {
		this.iName := name
	}

	getWeather(minute, ByRef weather, ByRef airTemperature, ByRef trackTemperature) {
		local pitstop := false
		local forecast := false
		local ignore, candidate

		if (this.WeatherForecast.Length() > 0) {
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

			if (index > this.Pitstops.Length())
				return laps
			else {
				pitstop := this.Pitstops[index]

				avgLapTime := pitstop.AvgLapTime
				numLaps += pitstop.StintLaps
				maxTime := ((pitstop.Time / 60) + (pitstop.Duration / 60) + (pitstop.StintLaps * (avgLapTime / 60)))
			}
		}
	}

	getAvgLapTime(numLaps, map, remainingFuel, fuelConsumption, weather, tyreCompound, tyreCompoundColor, tyreLaps) {
		return this.StrategyManager.getAvgLapTime(numLaps, map, remainingFuel, fuelConsumption
												, weather, tyreCompound, tyreCompoundColor, tyreLaps, this.AvgLapTime["Session"])
	}

	getMaxFuelLaps(remainingFuel, fuelConsumption, withSafety := true) {
		return Floor((remainingFuel - (withSafety ? this.SafetyFuel : 0)) / fuelConsumption)
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
		local refuelService := ((refuelAmount / 10) * this.PitstopFuelService)

		return (this.PitstopDelta + ((this.PitstopServiceOrder = "Simultaneous") ? Max(tyreService, refuelService) : (tyreService + refuelService)))
	}

	calcNextPitstopLap(pitstopNr, currentLap
					 , remainingStintLaps, remainingSessionLaps, remainingTyreLaps, remainingFuel
					 , ByRef adjusted) {
		local telemetryDB := this.StrategyManager.TelemetryDatabase
		local simulator := this.Simulator
		local car := this.Car
		local track := this.Track
		local compound := compound(this.TyreCompound[true], this.TyreCompoundColor[true])
		local fuelConsumption := this.FuelConsumption[true]
		local avgLapTime := this.AvgLapTime[true]
		local weather := false
		local airTemperature := false
		local trackTemperature := false
		local targetLap, pitstopRule, avgLapTime, openingLap, closingLap, time

		adjusted := false

		if (this.LastPitstop && !this.LastPitstop.TyreChange)
			remainingTyreLaps := this.MaxTyreLaps

		targetLap := (currentLap + Floor(Min(this.StintLaps, remainingStintLaps, remainingTyreLaps
										   , this.getMaxFuelLaps(remainingFuel, fuelConsumption))))

		loop
			if (A_Index >= (targetLap - currentLap))
				break
			else {
				time := (this.Time[true] + ((A_Index - 1) * avgLapTime))

				this.getWeather(time / 60, weather, airTemperature, trackTemperature)

				if (!telemetryDB.suitableTyreCompound(simulator, car, track, weather, compound)
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
		else if IsObject(pitstopRule) {
			openingLap := (pitstopRule[1] * 60 / avgLapTime)
			closingLap := (pitstopRule[2] * 60 / avgLapTime)

			if ((targetLap >= openingLap) && (currentLap <= closingLap))
				if ((pitstopNr = 1) || (this.LastPitstop.Lap < openingLap)) {
					targetLap := Min(targetLap, Floor((pitstopRule[1] + ((pitstopRule[2] - pitstopRule[1]) / 2)) * 60 / avgLapTime))

					adjusted := true
				}
		}

		return targetLap
	}

	chooseTyreCompoundColor(pitstops, pitstopNr, tyreCompound, tyreCompoundColor) {
		local qualifiedCompound, count, chooseNext, availableTyreSets
		local tyreCompoundColors, numColors, tries, rnd

		if (pitstopNr <= pitstops.Length()) {
			if pitstops[pitstopNr].TyreChange {
				tyreCompoundColor := pitstops[pitstopNr].TyreCompoundColor
				qualifiedCompound := compound(pitstops[pitstopNr].TyreCompound, tyreCompoundColor)

				if this.AvailableTyreSets.HasKey(qualifiedCompound) {
					count := (this.AvailableTyreSets[qualifiedCompound] - 1)

					if (count > 0)
						this.AvailableTyreSets[qualifiedCompound] := count
					else
						this.AvailableTyreSets.Delete(qualifiedCompound)
				}

				return tyreCompoundColor
			}
		}
		else {
			Random rnd, 0.01, 0.99

			chooseNext := Round(rnd * this.StrategyManager.TyreCompoundVariation / 100)

			if !chooseNext {
				qualifiedCompound := compound(tyreCompound, tyreCompoundColor)

				if !this.AvailableTyreSets.HasKey(qualifiedCompound)
					chooseNext := true
				else {
					count := (this.AvailableTyreSets[qualifiedCompound] - 1)

					if (count > 0)
						this.AvailableTyreSets[qualifiedCompound] := count
					else
						this.AvailableTyreSets.Delete(qualifiedCompound)

					return tyreCompoundColor
				}
			}

			if chooseNext {
				availableTyreSets := this.AvailableTyreSets
				tyreCompoundColors := this.StrategyManager.TyreCompoundColors.Clone()
				numColors := tyreCompoundColors.Length()

				tries := (100 * numColors)

				while (tries > 0) {
					Random rnd, 1, %numColors%

					tyreCompoundColor := tyreCompoundColors[Round(rnd)]
					qualifiedCompound := compound(tyreCompound, tyreCompoundColor)

					if availableTyreSets.HasKey(qualifiedCompound) {
						this.StrategyManager.TyreCompoundColor := tyreCompoundColor

						count := (availableTyreSets[qualifiedCompound] - 1)

						if (count > 0)
							availableTyreSets[qualifiedCompound] := count
						else
							availableTyreSets.Delete(qualifiedCompound)

						return tyreCompoundColor
					}

					tries -= 1
				}
			}
		}

		return false
	}

	createStints(currentStint, currentLap, currentStintTime, currentSessionTime
			   , currentTyreLaps, currentFuel, stintLaps, maxTyreLaps, tyreLapsVariation
			   , map, fuelConsumption, avgLapTime, adjustments := false) {
		local valid := true
		local pitstopLap := 0
		local pitstopNr := 0
		local rnd, variation, pitstops, lastPitstops, ignore
		local sessionLaps, numPitstops, fuelLaps, canonicalStintLaps, remainingFuel
		local tyreChange, tyreCompound, tyreCompoundColor, driverID, driverName, pitstop, telemetryDB, candidate
		local time, weather, airTemperature, trackTemperature, pitstopRule, adjusted, lastPitstop

		this.iStartStint := currentStint
		this.iStartLap := currentLap
		this.iStintStartTime := currentStintTime
		this.iSessionStartTime := currentSessionTime
		this.iTyreLaps := Max(maxTyreLaps - currentTyreLaps, 0)
		this.iFuelAmount := currentFuel

		this.iStintLaps := stintLaps
		this.iMaxTyreLaps := maxTyreLaps
		this.iTyreLapsVariation := tyreLapsVariation

		Random rnd, -10, 100

		variation := (tyreLapsVariation / 100 * rnd)

		this.iTyreLaps := Max((maxTyreLaps + (maxTyreLaps / 100 * variation)) - currentTyreLaps, 0)

		this.iMap := map
		this.iFuelConsumption := fuelConsumption
		this.iAvgLapTime := avgLapTime

		lastPitstops := this.Pitstops

		pitstops := []
		this.iPitstops := pitstops

		sessionLaps := this.RemainingSessionLaps

		pitstopRule := this.PitstopRule
		numPitstops := pitstopRule

		if numPitstops is Integer
		{
			if (numPitstops > 1) {
				fuelLaps := Max(0, (currentFuel / fuelConsumption) - 1)
				canonicalStintLaps := Round(sessionLaps / (numPitstops + 1))

				if (fuelLaps < canonicalStintLaps)
					this.iStintLaps := Min(stintLaps, Round((sessionLaps - fuelLaps) / numPitstops))
				else
					this.iStintLaps := Min(stintLaps, canonicalStintLaps)
			}
		}
		else if IsObject(numPitstops) {
			valid := false

			numPitstops := 1
		}
		else
			numPitstops := false

		loop {
			if (adjustments && (A_Index > (adjustments.Count())))
				break

			if !valid
				if IsObject(pitstopRule)
					valid := ((pitstopLap >= (pitstopRule[1] * 60 / avgLapTime)) && (pitstopLap <= (pitstopRule[2] * 60 / avgLapTime)))
				else
					valid := (pitstopNr >= numPitstops)

			pitstopNr := (currentStint + A_Index - 1)

			if (A_Index > 1)
				currentStintTime := 0

			remainingFuel := this.RemainingFuel[true]

			if valid
				if (this.SessionType = "Duration") {
					if (this.RemainingSessionTime[true] <= 0)
						break
				}
				else {
					if (currentLap >= this.RemainingSessionLaps)
						break
				}

			if (adjustments && adjustments.HasKey(pitstopNr) && adjustments[pitstopNr].HasKey("Lap"))
				pitstopLap := adjustments[pitstopNr]["Lap"]
			else {
				pitstopLap := this.calcNextPitstopLap(pitstopNr, currentLap
													, currentStintTime ? (((this.StintLength * 60) - currentStintTime) / avgLapTime)
																	   : stintLaps
													, this.RemainingSessionLaps[true], this.RemainingTyreLaps[true], remainingFuel
													, adjusted)

				if adjusted
					if (this.LastPitstop) {
						lastPitstop := pitstops.Pop()

						lastPitstop.initialize(lastPitstop.TyreCompound, lastPitstop.TyreCompoundColor
											 , {lastPitstop.Nr: {StintLaps: (pitstopLap - lastPitstop.Lap)}})

						pitstops.Push(lastPitstop)
					}
			}

			if adjustments {
				if (adjustments.HasKey(pitstopNr) && adjustments[pitstopNr].HasKey("TyreChange")) {
					tyreChange := adjustments[pitstopNr]["TyreChange"]

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

				this.getWeather((this.Time[true] + (pitstopLap - currentLap) * avgLapTime) / 60, weather, airTemperature, trackTemperature)

				candidate := telemetryDB.optimalTyreCompound(this.Simulator, this.Car, this.Track
														   , weather, airTemperature, trackTemperature
														   , getKeys(this.AvailableTyreSets))

				if candidate
					splitCompound(candidate, tyreCompound, tyreCompoundColor)
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

			this.StrategyManager.getStintDriver(pitstopNr + 1, driverID, driverName)

			this.StrategyManager.setStintDriver(pitstopNr + 1, driverID)

			pitstop := this.createPitstop(pitstopNr, pitstopLap, driverID, tyreCompound, tyreCompoundColor, false, adjustments)

			if (valid && !adjustments)
				if (this.SessionType = "Duration") {
					if (pitStop.RemainingSessionTime <= 0)
						break
				}
				else {
					if (pitstop.Lap >= this.RemainingSessionLaps)
						break
				}

			if ((numPitstops && (pitstopNr <= numPitstops)) || ((pitstop.StintLaps > 0) && ((pitstop.RefuelAmount > 0) || (pitstop.TyreChange))))
				pitstops.Push(pitstop)
			else if valid
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

					delta := Min((superfluousLaps * pitstop.FuelConsumption), pitstop.iRefuelAmount)

					pitstop.iRefuelAmount -= delta
					pitstop.iRemainingFuel -= delta

					pitstop.iDuration := pitstop.Strategy.calcPitstopDuration(this.RefuelAmount, this.TyreChange)
				}
			}

			break
		}
	}

	adjustLastPitstopRefuelAmount() {
		local pitstops := this.Pitstops
		local numPitstops := pitstops.Length()
		local remainingSessionLaps, refuelAmount, stintLaps, adjustments, ignore, pitstop, key, value, pitstopNr

		if ((numPitstops > 1) && !pitstops[numPitstops].Fixed) {
			remainingSessionLaps := Ceil(pitstops[numPitstops - 1].StintLaps + pitstops[numPitstops].StintLaps)

			if pitstops[numPitstops - 1].Fixed {
				refuelAmount := pitstops[numPitstops - 1].RefuelAmount
				stintLaps := pitstops[numPitstops - 1].StintLaps
			}
			else {
				refuelAmount := Ceil((pitstops[numPitstops - 1].RefuelAmount + pitstops[numPitstops].RefuelAmount) / 2)
				stintLaps := Ceil(remainingSessionLaps / 2)
			}

			adjustments := {}

			for ignore, pitstop in pitstops {
				pitstopNr := pitstop.Nr

				adjustments[pitstopNr] := ((pitstopNr = pitstops[numPitstops].Nr) ? {StintLaps: pitstop.StintLaps}
																				  : {StintLaps: pitstop.StintLaps
																				   , Lap: pitstop.Lap})

				if pitstop.TyreChange
					adjustments[pitstopNr]["TyreChange"] := Array(pitstop.TyreCompound, pitstop.TyreCompoundColor)
			}

			for key, value in {RefuelAmount: refuelAmount, RemainingSessionLaps: remainingSessionLaps, StintLaps: stintLaps}
				adjustments[pitstops[numPitstops].Nr - 1][key] := value

			adjustments[pitstops[numPitstops].Nr]["StintLaps"] := stintLaps

			this.initializeAvailableTyreSets()

			this.createStints(this.StartStint, this.StartLap, this.StintStartTime, this.SessionStartTime
							, Max(this.MaxTyreLaps - this.RemainingTyreLaps, 0), this.RemainingFuel
							, this.StintLaps, this.MaxTyreLaps, this.TyreLapsVariation, this.Map, this.FuelConsumption
							, this.AvgLapTime, adjustments)
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
			return this.RemainingSessionLaps
	}

	getSessionDuration() {
		local pitstop := this.LastPitstop

		if pitstop
			return (pitstop.Time + pitstop.Duration + (pitstop.StintLaps * pitstop.AvgLapTime))
		else
			return this.RemainingSessionTime
	}
}

class TrafficStrategy extends Strategy {
	iTrafficScenario := false

	TrafficScenario[] {
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
															   , driver, positions, runnings)
				return positions[driver]
			else
				return false
		}

		getTrafficDensity() {
			local driver := true
			local positions := true
			local runnings := true
			local begin, end, wrap, numCars

			if this.Strategy.StrategyManager.getTrafficPositions(this.Strategy.TrafficScenario, this.Lap + 1
															   , driver, positions, runnings) {
				begin := runnings[driver]
				end := (begin + (this.Strategy.StrategyManager.ConsideredTraffic / 100))

				wrap := false

				if (end > 1) {
					wrap := true

					end -= 1
				}

				numCars := 0

				loop % runnings.Length()
					if (A_Index != driver)
						if (wrap && ((runnings[A_Index] > begin) || (runnings[A_Index] <= end)))
							numCars += 1
						else if (!wrap && (runnings[A_Index] > begin) && (runnings[A_Index] < end))
							numCars += 1

				return (numCars / runnings.Length())
			}
			else
				return 0.0
		}
	}

	createPitstop(id, lap, driver, tyreCompound, tyreCompoundColor, configuration := false, adjustments := false) {
		local pitstop := new this.TrafficPitstop(this, id, lap, driver, tyreCompound, tyreCompoundColor
											   , configuration, adjustments)

		if ((id == 1) && !this.TrafficScenario)
			this.iTrafficScenario := this.StrategyManager.getTrafficScenario(this, pitstop)

		return pitstop
	}

	calcNextPitstopLap(pitstopNr, currentLap
					 , remainingStintLaps, remainingSessionLaps, remainingTyreLaps, remainingFuel
					 , ByRef adjusted) {
		local targetLap := base.calcNextPitstopLap(pitstopNr, currentLap, remainingStintLaps, remainingSessionLaps
												 , remainingTyreLaps, remainingFuel, adjusted)
		local pitstopRule := this.PitstopRule
		local variationWindow, moreLaps, rnd, avgLapTime, openingLap, closingLap

		if !adjusted {
			variationWindow := this.StrategyManager.VariationWindow
			moreLaps := Min(variationWindow, (remainingFuel / this.FuelConsumption[true]))

			adjusted := true

			Random rnd, -1.0, 1.0

			return Round(Max(currentLap, targetLap + ((rnd > 0) ? Floor(rnd * moreLaps) : (rnd * variationWindow))))
		}
		else
			return targetLap
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Public Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

lookupLapTime(lapTimes, map, remainingFuel) {
	local selected := false
	local ignore, candidate

	for ignore, candidate in lapTimes
		if ((candidate.Map = map) && (!selected || (Abs(candidate["Fuel.Remaining"] - remainingFuel) < Abs(selected["Fuel.Remaining"] - remainingFuel))))
			selected := candidate

	return (selected ? selected["Lap.Time"] : false)
}
