;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Strategy Representation         ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

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
	
	iFuelAmount := 0
		
	iTyreCompound := "Dry"
	iTyreCompoundColor := "Black"
	iTyrePressureFL := "2.7"
	iTyrePressureFR := "2.7"
	iTyrePressureRL := "2.7"
	iTyrePressureRR := "2.7"
	
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
				pitstopRequired := false
				refuelRequired := false
				tyreChangeRequired := false
				
				strategy.StrategyManager.getPitstopRules(pitstopRequired, refuelRequired, tyreChangeRequired)
			
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
				this.iAvgLapTime := strategy.getAvgLapTime(this.Map, this.RemainingFuel) ; strategy.AvgLapTime[true]
				
				remainingTyreLaps := (strategy.RemainingTyreLaps[true] - lastStintLaps)
			
				if (tyreChange != kUndefined) {
					this.iTyreChange := tyreChange
					
					if tyreChange
						this.iRemainingTyreLaps := strategy.RemainingTyreLaps
					else
						this.iRemainingTyreLaps := remainingTyreLaps
				}
				else if ((remainingTyreLaps - stintLaps) >= 0) {
					if ((id == 1) && tyreChangeRequired && (remainingTyreLaps >= this.iRemainingLaps)) {
						this.iTyreChange := true
						this.iRemainingTyreLaps := strategy.RemainingTyreLaps
					}
					else
						this.iRemainingTyreLaps := remainingTyreLaps
				}
				else {
					this.iTyreChange := true
					this.iRemainingTyreLaps := strategy.RemainingTyreLaps
				}
				
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
				return this.calcSessionLaps()
		}
	}

	RemainingTime[lastStint := false] {
		Get {
			if (lastStint && this.LastPitstop)
				return this.LastPitstop.RemainingTime
			else
				return this.calcSessionTime()
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
			
			this.iTyreCompound := tyreCompound
			this.iTyreCompoundColor := tyreCompoundColor
			this.iTyrePressureFL := tyrePressures[1]
			this.iTyrePressureFR := tyrePressures[2]
			this.iTyrePressureRL := tyrePressures[3]
			this.iTyrePressureRR := tyrePressures[4]
		}
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
		
		this.iSessionType := getConfigurationValue(configuration, "Session", "SessionType", "Duration")
		this.iSessionLength := getConfigurationValue(configuration, "Session", "SessionLength", 0)
		
		this.iMap := getConfigurationValue(configuration, "Setup", "Map", "n/a")
		this.iTC := getConfigurationValue(configuration, "Setup", "TC", "n/a")
		this.iABS := getConfigurationValue(configuration, "Setup", "ABS", "n/a")
		
		this.iFuelAmount := getConfigurationValue(configuration, "Setup", "FuelAmount", 0.0)
		
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
		this.iTyreLaps:= getConfigurationValue(configuration, "Strategy", "TyreLaps", 0)
		
		for ignore, lap in string2Values(",", getConfigurationValue(configuration, "Strategy", "Pitstops", ""))
			this.Pitstops.Push(new this.Pitstop(this, A_Index, lap, configuration))
	}
	
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		setConfigurationValue(configuration, "General", "Name", this.Name)
		
		setConfigurationValue(configuration, "Weather", "Weather", this.Weather)
		setConfigurationValue(configuration, "Weather", "AirTemperature", this.AirTemperature)
		setConfigurationValue(configuration, "Weather", "TrackTemperature", this.TrackTemperature)
		
		setConfigurationValue(configuration, "Session", "Simulator", this.Simulator)
		setConfigurationValue(configuration, "Session", "Car", this.Car)
		setConfigurationValue(configuration, "Session", "Track", this.Track)
		
		setConfigurationValue(configuration, "Session", "SessionType", this.SessionType)
		setConfigurationValue(configuration, "Session", "SessionLength", this.SessionLength)
		
		setConfigurationValue(configuration, "Setup", "Map", this.Map)
		setConfigurationValue(configuration, "Setup", "TC", this.TC)
		setConfigurationValue(configuration, "Setup", "ABS", this.ABS)
		
		setConfigurationValue(configuration, "Setup", "FuelAmount", this.RemainingFuel)
		
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
		setConfigurationValue(configuration, "Strategy", "TyreLaps", this.RemainingTyreLaps)
		
		pitstops := []
		
		for ignore, pitstop in this.Pitstops {
			pitstops.Push(pitstop.Lap)
		
			pitstop.saveToConfiguration(configuration)
		}
		
		setConfigurationValue(configuration, "Strategy", "Pitstops", values2String(", ", pitstops*))
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
	
	calcSessionLaps() {
		return this.StrategyManager.calcSessionLaps(this.AvgLapTime)
	}
	
	calcSessionTime() {
		return this.StrategyManager.calcSessionTime(this.AvgLapTime)
	}
	
	getAvgLapTime(map, remainingFuel) {
		return this.StrategyManager.getAvgLapTime(map, remainingFuel, this.AvgLapTime)
	}
	
	getMaxFuelLaps(fuelConsumption) {
		return this.StrategyManager.getMaxFuelLaps(fuelConsumption)
	}
	
	calcRefuelAmount(targetFuel, startFuel, remainingLaps, stintLaps) {
		remainingFuel := Max(0, startFuel - (stintLaps * this.FuelConsumption[true]))
		
		return this.StrategyManager.calcRefuelAmount(targetFuel, remainingFuel)
	}

	calcPitstopDuration(refuelAmount, changeTyres) {
		return this.StrategyManager.calcPitstopDuration(refuelAmount, changeTyres)
	}
	
	calcNextPitstopLap(pitstopNr, currentLap, remainingLaps, remainingTyreLaps, remainingFuel) {
		fuelConsumption := this.FuelConsumption[true]
		targetLap := (currentLap + Floor(Min(this.StintLaps, remainingTyreLaps, remainingFuel / fuelConsumption, this.getMaxFuelLaps(fuelConsumption))))
		
		if (pitstopNr = 1) {
			pitstopRequired := false
			refuelRequired := false
			tyreChangeRequired := false
			
			this.StrategyManager.getPitstopRules(pitstopRequired, refuelRequired, tyreChangeRequired)
			
			if (((targetLap >= remainingLaps) && pitstopRequired) || IsObject(pitstopRequired)) {
				if (pitstopRequired == true)
					targetLap := remainingLaps - 2
				else
					targetLap := Min(targetLap, Floor((pitstopRequired[1] + ((pitstopRequired[2] - pitstopRequired[1]) / 2)) * 60 / this.AvgLapTime))
			}
		}
		
		return targetLap
	}
	
	createStints(startFuel, stintLaps, tyreLaps, map, fuelConsumption, avgLapTime, adjustments := false) {
		this.iFuelAmount := startFuel
		this.iStintLaps := stintLaps
		this.iTyreLaps := tyreLaps
		
		this.iMap := map
		this.iFuelConsumption := fuelConsumption
		this.iAvgLapTime := avgLapTime
		
		this.iPitstops := []
		
		currentLap := 0
		
		sessionLaps := this.RemainingLaps
		
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
			
			pitstop := new this.Pitstop(this, A_Index, pitstopLap, false, adjustments)
			
			if (this.SessionType = "Duration") {
				if (pitStop.RemainingTime <= 0)
					break
			}
			else {
				if (pitstop.Lap >= this.RemainingLaps)
					break
			}
			
			currentLap := pitstopLap
		
			if ((pitstop.StintLaps > 0) && ((pitstop.RefuelAmount > 0) || (pitstop.TyreChange)))
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
			
			this.createStints(this.RemainingFuel, this.StintLaps, this.RemainingTyreLaps, this.Map, this.FuelConsumption, this.AvgLapTime, adjustments)
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