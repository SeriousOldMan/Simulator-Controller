;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Strategy Representation         ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class StrategySimulation {
	iStrategyManager := false
	iTelemetryDatabase := false
	
	iFixedLapTime := false
	
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
	
	__New(strategyManager, sessionType, telemetryDatabase) {
		this.iStrategyManager := strategyManager
		this.iSessionType := sessionType
		this.iTelemetryDatabase := telemetryDatabase
	}
	
	createStrategy(nameOrConfiguration := false) {
		local strategy := this.StrategyManager.createStrategy(nameOrConfiguration)
		
		strategy.setStrategyManager(this)
		
		return strategy
	}
	
	getStrategySettings(ByRef simulator, ByRef car, ByRef track, ByRef weather, ByRef airTemperature, ByRef trackTemperature
					  , ByRef sessionType, ByRef sessionLength
					  , ByRef maxTyreLaps, ByRef tyreCompound, ByRef tyreCompoundColor, ByRef tyrePressures) {
		return this.StrategyManager.getStrategySettings(simulator, car, track, weather, airTemperature, trackTemperature
													  , sessionType, sessionLength, maxTyreLaps, tyreCompound, tyreCompoundColor, tyrePressures)
	}
	
	getSessionSettings(ByRef stintLength, ByRef formationLap, ByRef postRaceLap, ByRef fuelCapacity, ByRef safetyFuel
					 , ByRef pitstopDelta, ByRef pitstopRefuelService, ByRef pitstopTyreService) {
		return this.StrategyManager.getSessionSettings(stintLength, formationLap, postRaceLap, fuelCapacity, safetyFuel
													 , pitstopDelta, pitstopRefuelService, pitstopTyreService)
	}
	
	getStartConditions(ByRef initialLap, ByRef initialStintTime, ByRef initialTyreLaps, ByRef initialFuelAmount
					 , ByRef initialMap, ByRef initialFuelConsumption, ByRef initialAvgLapTime) {
		return this.StrategyManager.getStartConditions(initialLap, initialStintTime, initialTyreLaps, initialFuelAmount
													 , initialMap, initialFuelConsumption, initialAvgLapTime)
	}
	
	getSimulationSettings(ByRef useStartConditions, ByRef useTelemetryData, ByRef consumptionWeight, ByRef initialFuelWeight, ByRef tyreUsageWeight) {
		return this.StrategyManager.getSimulationSettings(useStartConditions, useTelemetryData, consumptionWeight, initialFuelWeight, tyreUsageWeight)
	}
	
	getPitstopRules(ByRef pitstopRequired, ByRef refuelRequired, ByRef tyreChangeRequired) {
		return this.StrategyManager.getPitstopRules(pitstopRequired, refuelRequired, tyreChangeRequired)
	}
	
	getAvgLapTime(numLaps, map, remainingFuel, fuelConsumption, tyreCompound, tyreCompoundColor, tyreLaps, default := false) {
		if this.iFixedLapTime
			return this.iFixedLapTime
		else
			return this.StrategyManager.getAvgLapTime(numLaps, map, remainingFuel, fuelConsumption, tyreCompound, tyreCompoundColor, tyreLaps, default)
	}
	
	setFixedLapTime(lapTime) {
		this.iFixedLapTime := lapTime
	}
	
	acquireTelemetryData(ByRef electronicsData, ByRef tyreData, verbose, ByRef progress) {
		telemetryDB := this.TelemetryDatabase
		
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
		
		this.getStrategySettings(simulator, car, track, weather, airTemperature, trackTemperature
							   , sessionType, sessionLength, maxTyreLaps, tyreCompound, tyreCompoundColor, tyrePressures)
		
		if verbose {
			message := translate("Reading Electronics Data...")
			
			showProgress({progress: progress, message: message})
		}
		
		electronicsData := telemetryDB.getMapData(weather, tyreCompound, tyreCompoundColor)
		
		if verbose {
			Sleep 200
			
			message := translate("Reading Tyre Data...")
			
			showProgress({progress: progress, message: message})
		}
		
		tyreData := telemetryDB.getTyreData(weather, tyreCompound, tyreCompoundColor)
		
		if verbose {
			Sleep 200
			
			progress += 5
		}
	}
	
	createScenarios(electronicsData, tyreData, verbose, ByRef progress) {
		Throw "Virtual method StrategySimulation.createScenarios must be implemented in a subclass..."
	}
	
	createStints(strategy, initialLap, initialStintTime, initialTyreLaps, initialFuelAmount
			   , stintLaps, maxTyreLaps, map, consumption, lapTime) {
		strategy.createStints(initialLap, initialStintTime, initialTyreLaps, initialFuelAmount
							, stintLaps, maxTyreLaps, map, consumption, lapTime)
	}
	
	optimizeScenarios(scenarios, verbose, ByRef progress) {
		local strategy
		
		if (this.SessionType = "Duration")
			for name, strategy in scenarios {
				if verbose {
					message := (translate("Optimizing Stint length for Scenario ") . name . translate("..."))
				
					showProgress({progress: progress, message: message})
				}
				
				avgLapTime := strategy.AvgLapTime[true]

				targetTime := strategy.calcSessionTime(avgLapTime, false)
				sessionTime := strategy.getSessionDuration()
				
				superfluousLaps := -1
				
				while (sessionTime > targetTime) {
					superfluousLaps += 1
					sessionTime -= avgLapTime
				}
				
				reqPitstops := strategy.PitstopRequired
				
				if IsObject(reqPitstops)
					reqPitstops := 1
				
				if ((strategy.Pitstops.Length() > reqPitstops) || !reqPitstops)
					strategy.adjustLastPitstop(superfluousLaps)
				
				strategy.adjustLastPitstopRefuelAmount()
				
				if verbose {
					Sleep 500
					
					progress += 1
				}
			}
		
		if verbose
			progress := Floor(progress + 10)
		
		return scenarios
	}
	
	evaluateScenarios(scenarios, verbose, ByRef progress) {
		local strategy
		
		candidate := false
		
		for name, strategy in scenarios {
			if verbose {
				message := (translate("Evaluating Scenario ") . name . translate("..."))
				
				showProgress({progress: progress, message: message})
			}
			
			if !candidate
				candidate := strategy
			else {
				if (this.SessionType = "Duration") {
					sLaps := strategy.getSessionLaps()
					cLaps := candidate.getSessionLaps()
					sTime := strategy.getSessionDuration()
					cTime := candidate.getSessionDuration()
					
					if (sLaps > cLaps)
						candidate := strategy
					else if ((sLaps = cLaps) && (sTime < cTime))
						candidate := strategy
					else if ((sLaps = cLaps) && (sTime = cTime) && (candidate.FuelConsumption[true] > strategy.FuelConsumption[true] ))
						candidate := strategy
				}
				else if (strategy.getSessionDuration() < candidate.getSessionDuration())
					candidate := strategy
			}
			
			if verbose {
				progress += 1
			
				Sleep 500
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
		window := this.StrategyManager.Window
		
		if verbose {
			x := Round((A_ScreenWidth - 300) / 2)
			y := A_ScreenHeight - 150
				
			progressWindow := showProgress({x: x, y: y, color: "Blue", title: translate("Acquiring Telemetry Data")})
		
			if window {
				Gui %progressWindow%:+Owner%window%
				Gui %window%:+Disabled
			}
		}
		
		if verbose
			Sleep 200
		
		progress := 0
		
		electronicsData := false
		tyreData := false
		
		this.acquireTelemetryData(electronicsData, tyreData, verbose, progress)
		
		if verbose {
			message := translate("Creating Scenarios...")
			
			showProgress({progress: progress, color: "Green", title: translate("Running Simulation")})
			
			Sleep 200
		}
		
		scenarios := this.createScenarios(electronicsData, tyreData, verbose, progress)
		
		if verbose {
			message := translate("Optimizing Scenarios...")
			
			showProgress({progress: progress, message: message})
			
			Sleep 200
		}
		
		scenarios := this.optimizeScenarios(scenarios, verbose, progress)
		
		if verbose {
			message := translate("Evaluating Scenarios...")
			
			showProgress({progress: progress, message: message})
			
			Sleep 200
		}
		
		scenario := this.evaluateScenarios(scenarios, verbose, progress)
		
		if scenario {
			if verbose {
				message := translate("Choose Scenario...")
				
				showProgress({progress: progress, message: message})
				
				Sleep 200
			}
			
			this.chooseScenario(scenario)
		}
		else
			this.chooseScenario(false)
		
		if verbose {
			message := translate("Finished...")
			
			showProgress({progress: 100, message: message})
			
			Sleep 1000
			
			hideProgress()
		
			if window
				Gui %window%:-Disabled
		}
	}
}

class VariationSimulation extends StrategySimulation {
	createScenarios(electronicsData, tyreData, verbose, ByRef progress) {
		local strategy

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
		
		this.getStrategySettings(simulator, car, track, weather, airTemperature, trackTemperature
							   , sessionType, sessionLength, maxTyreLaps, tyreCompound, tyreCompoundColor, tyrePressures)
		
		stintLength := false
		formationLap := false
		postRaceLap := false
		fuelCapacity := false
		safetyFuel := false
		pitstopDelta := false
		pitstopFuelService := false
		pitstopTyreService := false
		
		this.getSessionSettings(stintLength, formationLap, postRaceLap, fuelCapacity, safetyFuel, pitstopDelta, pitstopFuelService, pitstopTyreService)
	
		initialLap := false
		initialStintTime := false
		initialTyreLaps := false
		initialFuelAmount := false
		map := false
		fuelConsumption := false
		avgLapTime := false
	
		this.getStartConditions(initialLap, initialStintTime, initialTyreLaps, initialFuelAmount, map, fuelConsumption, avgLapTime)
		
		useStartConditions := false
		useTelemetryData := false
		consumption := 0
		tyreUsage := 0
		initialFuel := 0
		
		this.getSimulationSettings(useStartConditions, useTelemetryData, consumption, initialFuel, tyreUsage)
		
		consumptionStep := (consumption / 4)
		tyreUsageStep := (tyreUsage / 4)
		initialFuelStep := (initialFuel / 4)
		
		scenarios := {}
		variation := 1
		
		Loop { ; consumption
			Loop { ; initialFuel
				Loop { ; tyreUsage
					if useStartConditions {
						if map is number
						{
							message := (translate("Creating Initial Scenario with Map ") . simMapEdit . translate("..."))
								
							showProgress({progress: progress, message: message})
							
							stintLaps := Floor((stintLength * 60) / avgLapTime)
							
							name := (translate("Initial Conditions - Map ") . map)
							
							this.setFixedLapTime(avgLapTime)
							
							try {
								strategy := this.createStrategy(name)
						
								currentConsumption := (fuelConsumption - (fuelConsumption / 100 * consumption))
								
								startFuelAmount := Min(fuelCapacity, initialFuelAmount + (initialFuel / 100 * fuelCapacity))
								lapTime := this.getAvgLapTime(stintLaps, map, startFuelAmount, currentConsumption
															, tyreCompound, tyreCompoundColor, 0, avgLapTime)
							
								this.createStints(strategy, initialLap, initialStintTime, initialTyreLaps, initialFuelAmount
												, stintLaps, maxTyreLaps + (maxTyreLaps / 100 * tyreUsage), map
												, currentConsumption, lapTime)
							}
							finally {
								this.setFixedLapTime(false)
							}
							
							scenarios[name . translate(":") . variation++] := strategy
								
							Sleep 100
								
							progress += 1
						}
					}
					
					if useTelemetryData
						for ignore, mapData in electronicsData {
							scenarioMap := mapData["Map"]
							scenarioFuelConsumption := mapData["Fuel.Consumption"]
							scenarioAvgLapTime := mapData["Lap.Time"]

							if scenarioMap is number
							{
								message := (translate("Creating Telemetry Scenario with Map ") . scenarioMap . translate("..."))
								
								showProgress({progress: progress, message: message})
							
								stintLaps := Floor((stintLength * 60) / scenarioAvgLapTime)
								
								name := (translate("Telemetry - Map ") . scenarioMap)
								
								strategy := this.createStrategy(name)
							
								currentConsumption := (scenarioFuelConsumption - (scenarioFuelConsumption / 100 * consumption))
								
								startFuelAmount := Min(fuelCapacity, initialFuelAmount + (initialFuel / 100 * fuelCapacity))
								lapTime := this.getAvgLapTime(stintLaps, map, startFuelAmount, currentConsumption
															, tyreCompound, tyreCompoundColor, 0, scenarioAvgLapTime)
							
								this.createStints(strategy, initialLap, initialStintTime, initialTyreLaps, initialFuelAmount
												, stintLaps, maxTyreLaps + (maxTyreLaps / 100 * tyreUsage), scenarioMap
												, currentConsumption, lapTime)
								
								scenarios[name . translate(":") . variation++] := strategy
								
								Sleep 100
								
								progress += 1
							}
						}
				
					if (tyreUsage = 0)
						break
					else
						tyreUsage := Max(0, tyreUsage - tyreUsageStep)
				}
						
				if (initialFuel = 0)
					break
				else
					initialFuel := Max(0, initialFuel - initialFuelStep)
			}
			
			if (consumption = 0)
				break
			else
				consumption := Max(0, consumption - consumptionStep)
		}
		
		progress := Floor(progress + 10)
		
		return scenarios
	}
}

class Strategy extends ConfigurationItem {
	iStrategyManager := false
	
	iName := translate("Unnamed")
	
	iWeather := "Dry"
	iAirTemperature := 23
	iTrackTemperature := 27
	
	iSimulator := false
	iCar := false
	iTrack := false
	
	iSessionType := "Duration"
	iSessionLength := 0
	
	iMap := "n/a"
	iTC := "n/a"
	iABS := "n/a"

	iStartLap := 0
	iStartTime := 0
	
	iFuelAmount := 0
		
	iTyreCompound := "Dry"
	iTyreCompoundColor := "Black"
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
	iPitstopRefuelService := 0.0
	iPitstopTyreService := 0.0
	
	iPitstopRequired := false
	iRefuelRequired := false
	iTyreChangeRequired := false
		
	iStintLaps := 0
	iMaxTyreLaps := 0
	
	iAvgLapTime := 0
	iFuelConsumption := 0
	iTyreLaps := 0
	
	iPitstops := []
	
	class Pitstop extends ConfigurationItem {
		iStrategy := false
		iID := false
		iLap := 0
		
		iTime := 0
		iDuration := 0
		iRefuelAmount := 0
		iTyreChange := false
		
		iStintLaps := 0
		iMap := 1
		iFuelConsumption := 0
		iAvgLapTime := 0
		
		iRemainingTime := 0
		iRemainingLaps := 0
		iRemainingTyreLaps := 0
		iRemainingFuel := 0
		
		Strategy[]  {
			Get {
				return this.iStrategy
			}
		}
		
		ID[]  {
			Get {
				return this.iID
			}
		}
		
		Lap[]  {
			Get {
				return this.iLap
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
		
		TyreChange[] {
			Get {
				return this.iTyreChange
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
		
		RemainingLaps[] {
			Get {
				return this.iRemainingLaps
			}
		}
		
		RemainingTime[] {
			Get {
				return this.iRemainingTime
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
		
		__New(strategy, id, lap, configuration := false, adjustments := false) {
			this.iStrategy := strategy
			this.iID := id
			this.iLap := lap

			base.__New(configuration)
			
			if !configuration {
				pitstopRequired := strategy.PitstopRequired
				refuelRequired := strategy.RefuelRequired
				tyreChangeRequired := strategy.TyreChangeRequired
			
				remainingFuel := strategy.RemainingFuel[true]
				remainingLaps := strategy.RemainingLaps[true]
				fuelConsumption := strategy.FuelConsumption[true]
				lastStintLaps := Floor(Min(strategy.StintLaps[true], remainingFuel / fuelConsumption, strategy.LastPitstop ? (lap - strategy.LastPitstop.Lap) : lap))
				
				if (adjustments && adjustments.HasKey(id) && adjustments[id].HasKey("RemainingLaps"))
					remainingLaps := (adjustments[id].RemainingLaps + lastStintLaps)
				
				if (adjustments && adjustments.HasKey(id) && adjustments[id].HasKey("StintLaps"))
					stintLaps := adjustments[id].StintLaps
				else
					stintLaps := Floor(Min(remainingLaps - lastStintLaps, strategy.StintLaps, strategy.getMaxFuelLaps(fuelConsumption)))
				
				this.iStintLaps := stintLaps
				this.iMap := strategy.Map[true]
				this.iFuelConsumption := fuelConsumption
				
				refuelAmount := strategy.calcRefuelAmount(stintLaps * fuelConsumption, remainingFuel, remainingLaps, lastStintLaps)
				tyreChange := kUndefined
				
				if (adjustments && adjustments.HasKey(id)) {
					if adjustments[id].HasKey("RefuelAmount")
						refuelAmount := adjustments[id].RefuelAmount
					
					if adjustments[id].HasKey("TyreChange")
						tyreChange := adjustments[id].TyreChange
				}
						
				if ((id == 1) && refuelRequired && (refuelAmount <= 0))
					refuelAmount := 1
				else if (refuelAmount <= 0)
					refuelAmount := 0
				
				this.iRemainingLaps := (remainingLaps - lastStintLaps)
				this.iRemainingFuel := (remainingFuel - (lastStintLaps * fuelConsumption) + refuelAmount)
				
				remainingTyreLaps := (strategy.RemainingTyreLaps[true] - lastStintLaps)
			
				if (tyreChange != kUndefined) {
					this.iTyreChange := tyreChange
					
					if tyreChange
						this.iRemainingTyreLaps := strategy.MaxTyreLaps
					else
						this.iRemainingTyreLaps := remainingTyreLaps
				}
				else if ((remainingTyreLaps - stintLaps) >= 0) {
					if ((id == 1) && tyreChangeRequired && (remainingTyreLaps >= this.iRemainingLaps)) {
						this.iTyreChange := true
						this.iRemainingTyreLaps := strategy.MaxTyreLaps
					}
					else
						this.iRemainingTyreLaps := remainingTyreLaps
				}
				else {
					this.iTyreChange := true
					this.iRemainingTyreLaps := strategy.MaxTyreLaps
				}
				
				this.iAvgLapTime := strategy.getAvgLapTime(this.StintLaps, this.Map, this.RemainingFuel, fuelConsumption
														 , strategy.TyreCompound, strategy.TyreCompoundColor
														 , (strategy.MaxTyreLaps - this.RemainingTyreLaps))
				
				this.iRefuelAmount := refuelAmount
				this.iDuration := strategy.calcPitstopDuration(refuelAmount, this.TyreChange)
				
				lastPitstop := strategy.LastPitstop
								
				if lastPitstop {
					delta := (lastPitstop.Duration + (lastPitstop.StintLaps * lastPitstop.AvgLapTime))
				
					this.iTime := (lastPitstop.Time + delta)
					this.iRemainingTime := (lastPitstop.RemainingTime - delta)
				}
				else {
					this.iTime := (lastStintLaps * strategy.AvgLapTime[true])
					this.iRemainingTime := (strategy.RemainingTime - this.iTime)
				}
			}
		}
		
		loadFromConfiguration(configuration) {
			base.loadFromConfiguration(configuration)
			
			lap := this.Lap
			
			this.iTime := getConfigurationValue(configuration, "Pitstop", "Time." . lap, 0)
			this.iDuration := getConfigurationValue(configuration, "Pitstop", "Duration." . lap, 0)
			this.iRefuelAmount := getConfigurationValue(configuration, "Pitstop", "RefuelAmount." . lap, 0)
			this.iTyreChange := getConfigurationValue(configuration, "Pitstop", "TyreChange." . lap, false)
		
			this.iStintLaps := getConfigurationValue(configuration, "Pitstop", "StintLaps." . lap, 0)

			this.iMap := getConfigurationValue(configuration, "Pitstop", "Map." . lap, 0)
			this.iAvgLapTime := getConfigurationValue(configuration, "Pitstop", "AvgLapTime." . lap, 0)
			this.iFuelConsumption := getConfigurationValue(configuration, "Pitstop", "FuelConsumption." . lap, 0)

			this.iRemainingLaps := getConfigurationValue(configuration, "Pitstop", "RemainingLaps." . lap, 0)
			this.iRemainingTime := getConfigurationValue(configuration, "Pitstop", "RemainingTime." . lap, 0)
			this.iRemainingTyreLaps := getConfigurationValue(configuration, "Pitstop", "RemainingTyreLaps." . lap, 0)
			this.iRemainingFuel := getConfigurationValue(configuration, "Pitstop", "RemainingFuel." . lap, 0.0)
		}
		
		saveToConfiguration(configuration) {
			base.saveToConfiguration(configuration)
			
			lap := this.Lap
			
			setConfigurationValue(configuration, "Pitstop", "Time." . lap, this.Time)
			setConfigurationValue(configuration, "Pitstop", "Duration." . lap, this.Duration)
			setConfigurationValue(configuration, "Pitstop", "RefuelAmount." . lap, Ceil(this.RefuelAmount))
			setConfigurationValue(configuration, "Pitstop", "TyreChange." . lap, this.TyreChange)
			
			setConfigurationValue(configuration, "Pitstop", "StintLaps." . lap, this.StintLaps)
			
			setConfigurationValue(configuration, "Pitstop", "Map." . lap, this.Map)
			setConfigurationValue(configuration, "Pitstop", "AvgLapTime." . lap, this.AvgLapTime)
			setConfigurationValue(configuration, "Pitstop", "FuelConsumption." . lap, this.FuelConsumption)
			
			setConfigurationValue(configuration, "Pitstop", "RemainingLaps." . lap, this.RemainingLaps)
			setConfigurationValue(configuration, "Pitstop", "RemainingTime." . lap, this.RemainingTime)
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
	
	TyreCompound[colored := false] {
		Get {
			if colored
				return qualifiedCompound(this.iTyreCompound, this.iTyreCompoundColor)
			else
				return this.iTyreCompound
		}
	}
	
	TyreCompoundColor[] {
		Get {
			return this.iTyreCompoundColor
		}
	}
	
	TyrePressures[asText := false] {
		Get {
			pressures := [this.TyrePressureFL, this.TyrePressureFR, this.TyrePressureRL, this.TyrePressureRR]
			
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
	
	PitstopRefuelService[] {
		Get {
			return this.iPitstopRefuelService
		}
	}
	
	PitstopTyreService[] {
		Get {
			return this.iPitstopTyreService
		}
	}
	
	PitstopRequired[] {
		Get {
			return this.iPitstopRequired
		}
	}
	
	RefuelRequired[] {
		Get {
			return this.iRefuelRequired
		}
	}
	
	TyreChangeRequired[] {
		Get {
			return this.iTyreChangeRequired
		}
	}

	StartLap[] {
		Get {
			return this.iStartLap
		}
	}

	StartTime[] {
		Get {
			return this.iStartTime
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

	RemainingLaps[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.RemainingLaps
			else
				return (this.calcSessionLaps() - this.StartLap)
		}
	}

	RemainingTime[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.RemainingTime
			else
				return (this.calcSessionTime() - this.StartTime)
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
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.AvgLapTime
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
	
	Pitstops[index := false] {
		Get {
			return (index ? this.iPitstops[index] : this.iPitstops)
		}
	}
	
	LastPitstop[] {
		Get {
			length := this.Pitstops.Length()
			
			return ((length = 0) ? false : this.iPitstops[length])
		}
	}
	
	__New(strategyManager, configuration := false) {
		this.iStrategyManager := strategyManager
		
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
			
			this.StrategyManager.getStrategySettings(simulator, car, track,weather, airTemperature, trackTemperature
												   , sessionType, sessionLength, maxTyreLaps, tyreCompound, tyreCompoundColor, tyrePressures)
			
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
			
			stintLength := false
			formationLap := false
			postRaceLap := false
			fuelCapacity := false
			safetyFuel := false
			pitstopDelta := false
			pitstopFuelService := false
			pitstopTyreService := false
			
			this.StrategyManager.getSessionSettings(stintLength, formationLap, postRacelap, fuelCapacity, safetyFuel
												  , pitstopDelta, pitstopFuelService, pitstopTyreService)
			
			this.iStintLength := stintLength
			this.iFormationLap := formationLap
			this.iPostRaceLap := postRaceLap
			this.iFuelCapacity := fuelCapacity
			this.iSafetyFuel := safetyFuel
			
			this.iPitstopDelta := pitstopDelta
			this.iPitstopFuelService := pitstopFuelService
			this.iPitstopTyreService := pitstopTyreService
			
			pitstopRequired := false
			refuelRequired := false
			tyreChangeRequired := false
			
			this.StrategyManager.getPitstopRules(pitstopRequired, refuelRequired, tyreChangeRequired)

			if !pitstopRequired {
				refuelRequired := false
				tyreChangeRequired := false
			}
			
			this.iPitstopRequired := pitstopRequired
			this.iRefuelRequired := refuelRequired
			this.iTyreChangeRequired := tyreChangeRequired
		}
	}
	
	setStrategyManager(strategyManager) {
		this.iStrategyManager := strategyManager
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		this.iName := getConfigurationValue(configuration, "General", "Name", translate("Unnamed"))
		
		this.iSimulator := getConfigurationValue(configuration, "Session", "Simulator", "Unknown")
		this.iCar := getConfigurationValue(configuration, "Session", "Car", "Unknown")
		this.iTrack := getConfigurationValue(configuration, "Session", "Track", "Unknown")
	
		this.iWeather := getConfigurationValue(configuration, "Weather", "Weather", "Dry")
		this.iAirTemperature := getConfigurationValue(configuration, "Weather", "AirTemperature", 23)
		this.iTrackTemperature := getConfigurationValue(configuration, "Weather", "TrackTemperature", 27)
		
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
		
		this.iPitstopRequired := getConfigurationValue(configuration, "Settings", "PitstopRequired", false)
		
		if this.iPitstopRequired
			if InStr(this.iPitstopRequired, "-")
				this.iPitstopRequired := string2Values("-", this.iPitstopRequired)
		
		this.iRefuelRequired := getConfigurationValue(configuration, "Settings", "PitstopRefuel", false)
		this.iTyreChangeRequired := getConfigurationValue(configuration, "Settings", "PitstopTyreChange", false)
		
		this.iMap := getConfigurationValue(configuration, "Setup", "Map", "n/a")
		this.iTC := getConfigurationValue(configuration, "Setup", "TC", "n/a")
		this.iABS := getConfigurationValue(configuration, "Setup", "ABS", "n/a")
		
		this.iStartLap := getConfigurationValue(configuration, "Session", "StartLap", 0)
		this.iStartTime := getConfigurationValue(configuration, "Session", "StartTime", 0)
		
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
		
		for ignore, lap in string2Values(",", getConfigurationValue(configuration, "Strategy", "Pitstops", ""))
			this.Pitstops.Push(this.createPitstop(A_Index, lap, configuration))
	}
	
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		setConfigurationValue(configuration, "General", "Name", this.Name)
		
		setConfigurationValue(configuration, "Settings", "FuelCapacity", this.FuelCapacity)
		setConfigurationValue(configuration, "Settings", "SafetyFuel", this.SafetyFuel)
		
		setConfigurationValue(configuration, "Settings", "PitstopDelta", this.iPitstopDelta)
		setConfigurationValue(configuration, "Settings", "PitstopFuelService", this.iPitstopFuelService)
		setConfigurationValue(configuration, "Settings", "PitstopTyreService", this.iPitstopTyreService)
		
		pitstopRequired := this.PitstopRequired
		
		if IsObject(pitstopRequired)
			pitstopRequired := values2String("-", pitstopRequired*)
		
		setConfigurationValue(configuration, "Settings", "PitstopRequired", pitstopRequired)
		setConfigurationValue(configuration, "Settings", "PitstopRefuel", this.RefuelRequired)
		setConfigurationValue(configuration, "Settings", "PitstopTyreChange", this.TyreChangeRequired)
		
		setConfigurationValue(configuration, "Weather", "Weather", this.Weather)
		setConfigurationValue(configuration, "Weather", "AirTemperature", this.AirTemperature)
		setConfigurationValue(configuration, "Weather", "TrackTemperature", this.TrackTemperature)
		
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
		
		setConfigurationValue(configuration, "Session", "StartLap", this.StartLap)
		setConfigurationValue(configuration, "Session", "StartTime", this.StartTime)
		
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
		setConfigurationValue(configuration, "Strategy", "FuelConsumption", this.FUelConsumption)
		
		pitstops := []
		
		for ignore, pitstop in this.Pitstops {
			pitstops.Push(pitstop.Lap)
		
			pitstop.saveToConfiguration(configuration)
		}
		
		setConfigurationValue(configuration, "Strategy", "Pitstops", values2String(", ", pitstops*))
	}
	
	createPitstop(id, lap, configuration := false, adjustments := false) {
		return new this.Pitstop(this, id, lap, configuration, adjustments)
	}
	
	setName(name) {
		this.iName := name
	}
	
	getLaps(seconds) {
		laps := []
		
		index := false
		curTime := 0
		maxTime := 0
		avgLapTime := this.AvgLapTime
		
		if !this.LastPitstop
			numLaps := this.getSessionLaps()
		else
			numLaps := this.Pitstops[1].Lap
		
		maxTime := (numLaps * (avgLapTime / 60))
			
		Loop {
			Loop
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
	
	getAvgLapTime(numLaps, map, remainingFuel, fuelConsumption, tyreCompound, tyreCompoundColor, tyreLaps) {
		return this.StrategyManager.getAvgLapTime(numLaps, map, remainingFuel, fuelConsumption
												, tyreCompound, tyreCompoundColor, tyreLaps, this.AvgLapTime)
	}
	
	getMaxFuelLaps(fuelConsumption, withSafety := true) {
		return Floor((this.FuelCapacity - (withSafety ? this.SafetyFuel : 0)) / fuelConsumption)
	}
	
	calcSessionLaps(avgLapTime := false, formationLap := true, postRaceLap := true) {
		sessionLength := this.SessionLength
		hasFormationLap := this.FormationLap
		hasPostRaceLap := this.PostRaceLap
		
		if !avgLapTime
			avgLapTime := this.AvgLapTime
		
		if (this.SessionType = "Duration")
			return Ceil(((sessionLength * 60) / avgLapTime) + ((formationLap && hasFormationLap) ? 1 : 0) + ((postRaceLap && hasPostRaceLap) ? 1 : 0))
		else
			return (sessionLength + ((formationLap && hasFormationLap) ? 1 : 0) + ((postRaceLap && hasPostRaceLap) ? 1 : 0))
	}
	
	calcSessionTime(avgLapTime := false, formationLap := true, postRaceLap := true) {
		sessionLength := this.SessionLength
		hasFormationLap := this.FormationLap
		hasPostRaceLap := this.PostRaceLap
		
		if !avgLapTime
			avgLapTime := this.AvgLapTime
		
		if (this.SessionType = "Duration")
			return ((sessionLength * 60) + (((formationLap && hasFormationLap) ? 1 : 0) * avgLapTime) + (((postRaceLap && hasPostRaceLap) ? 1 : 0) * avgLapTime))
		else
			return ((sessionLength + ((formationLap && hasFormationLap) ? 1 : 0) + ((postRaceLap && hasPostRaceLap) ? 1 : 0)) * avgLapTime)
	}
	
	calcRefuelAmount(targetFuel, startFuel, remainingLaps, stintLaps) {
		currentFuel := Max(0, startFuel - (stintLaps * this.FuelConsumption[true]))
	
		return (Min(this.FuelCapacity, targetFuel + this.SafetyFuel) - currentFuel)
	}
	
	calcPitstopDuration(refuelAmount, changeTyres) {
		return (this.PitstopDelta + (changeTyres ? this.PitstopTyreService : 0) + ((refuelAmount / 10) * this.PitstopRefuelService))
	}
	
	calcNextPitstopLap(pitstopNr, currentLap, remainingLaps, remainingTyreLaps, remainingFuel) {
		fuelConsumption := this.FuelConsumption[true]
		targetLap := (currentLap + Floor(Min(this.StintLaps, remainingTyreLaps, remainingFuel / fuelConsumption, this.getMaxFuelLaps(fuelConsumption))))
		
		if (pitstopNr = 1) {
			pitstopRequired := this.PitstopRequired
			
			if (((targetLap >= remainingLaps) && pitstopRequired) || IsObject(pitstopRequired)) {
				if (pitstopRequired == true)
					targetLap := remainingLaps - 2
				else {
					closingLap := (pitstopRequired[2] * 60 / this.AvgLapTime)
				
					if (currentLap < closingLap)
						targetLap := Min(targetLap, Floor((pitstopRequired[1] + ((pitstopRequired[2] - pitstopRequired[1]) / 2)) * 60 / this.AvgLapTime))
				}
			}
		}
		
		return targetLap
	}
	
	createStints(currentLap, currentSessionTime, currentTyreLaps, currentFuel, stintLaps, maxTyreLaps, map, fuelConsumption, avgLapTime, adjustments := false) {
		this.iStartLap := currentLap
		this.iStartTime := currentSessionTime
		this.iTyreLaps := (maxTyreLaps - currentTyreLaps)
		this.iFuelAmount := currentFuel
		
		this.iStintLaps := stintLaps
		this.iMaxTyreLaps := maxTyreLaps
		
		this.iMap := map
		this.iFuelConsumption := fuelConsumption
		this.iAvgLapTime := avgLapTime
		
		this.iPitstops := []
		
		sessionLaps := this.RemainingLaps
		
		numPitstops := this.PitstopRequired
		
		if numPitstops is Integer
		{
			if numPitstops > 1
				this.iStintLaps := Round(sessionLaps / (numPitstops + 1))
			else
				numPitstops := false
		}
		else
			numPitstops := false
			
		Loop {
			remainingFuel := this.RemainingFuel[true]
		
			if (this.SessionType = "Duration") {
				if (this.RemainingTime[true] <= 0)
					break
			}
			else {
				if (currentLap >= this.RemainingLaps)
					break
			}
			
			pitstopLap := this.calcNextPitstopLap(A_Index, currentLap, this.RemainingLaps[true], this.RemainingTyreLaps[true], remainingFuel)
			
			pitstop := this.createPitstop(A_Index, pitstopLap, false, adjustments)
			
			if (this.SessionType = "Duration") {
				if (pitStop.RemainingTime <= 0)
					break
			}
			else {
				if (pitstop.Lap >= this.RemainingLaps)
					break
			}
			
			currentLap := pitstopLap
		
			if (numPitstops || ((pitstop.StintLaps > 0) && ((pitstop.RefuelAmount > 0) || (pitstop.TyreChange))))
				this.Pitstops.Push(pitstop)
			else
				break
		}
	}
	
	adjustLastPitstop(superfluousLaps) {
		while (superfluousLaps > 0) {
			pitstop := this.LastPitstop
		
			if pitstop {
				stintLaps := pitstop.StintLaps
				
				if (stintLaps <= superfluousLaps) {
					superfluousLaps -= stintLaps
				
					this.Pitstops.Pop()
					
					continue
				}
				else {
					pitstop.iStintLaps -= superfluousLaps
				
					delta := Min((superfluousLaps * pitstop.FuelConsumption), pitstop.iRefuelAmount)
					
					pitstop.iRefuelAmount -= delta
					pitstop.iRemainingFuel -= delta
					
					this.iDuration := pitstop.Strategy.calcPitstopDuration(this.RefuelAmount, this.TyreChange)
				}
			}
			
			break
		}
	}
	
	adjustLastPitstopRefuelAmount() {
		pitstops := this.Pitstops
		numPitstops := pitstops.Length()
		
		if (pitstops.Length() > 1) {
			refuelAmount := Ceil((pitstops[numPitstops - 1].RefuelAmount + pitstops[numPitstops].RefuelAmount) / 2)
			remainingLaps := Ceil(pitstops[numPitstops - 1].StintLaps + pitstops[numPitstops].StintLaps)
			stintLaps := Ceil(remainingLaps / 2)
			
			adjustments := {}
			adjustments[numPitstops - 1] := {RefuelAmount: refuelAmount, RemainingLaps: remainingLaps, StintLaps: stintLaps}
			adjustments[numPitstops] := {StintLaps: stintLaps}
			
			this.createStints(this.StartLap, this.StartTime, this.MaxTyreLaps - this.RemainingTyreLaps, this.RemainingFuel
							, this.StintLaps, this.MaxTyreLaps, this.Map, this.FuelConsumption, this.AvgLapTime, adjustments)
		}
	}
	
	getPitstopTime() {
		time := 0
		
		for ignore, pitstop in this.Pitstops
			time += pitstop.Duration
		
		return time
	}
	
	getSessionLaps() {
		pitstop := this.LastPitstop

		if pitstop
			return (pitstop.Lap + pitstop.StintLaps)
		else
			return this.RemainingLaps
	}
	
	getSessionDuration() {
		pitstop := this.LastPitstop

		if pitstop
			return (pitstop.Time + pitstop.Duration + (pitstop.StintLaps * pitstop.AvgLapTime))
		else
			return this.RemainingTime
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Public Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

qualifiedCompound(compound, compoundColor) {
	if (compound= "Dry") {
		if (compoundColor = "Black")
			return "Dry"
		else
			return ("Dry (" . compoundColor . ")")
	}
	else
		return "Wet"
}

splitQualifiedCompound(qualifiedCompound, ByRef compound, ByRef compoundColor) {
	compoundColor := "Black"
	
	index := inList(kQualifiedTyreCompounds, qualifiedCompound)
	
	if (index == 1)
		compound := "Wet"
	else {
		compound := "Dry"
	
		if (index > 2)
			compoundColor := ["Red", "White", "Blue"][index - 2]
	}
}

lookupLapTime(lapTimes, map, remainingFuel) {
	selected := false
	
	for ignore, candidate in lapTimes
		if ((candidate.Map = map) && (!selected || (Abs(candidate["Fuel.Remaining"] - remainingFuel) < Abs(selected["Fuel.Remaining"] - remainingFuel))))
			selected := candidate

	return (selected ? selected["Lap.Time"] : false)
}
