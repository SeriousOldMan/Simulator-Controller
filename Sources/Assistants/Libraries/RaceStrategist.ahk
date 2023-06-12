;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AI Race Strategist              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Global Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\Task.ahk"
#Include "..\..\Libraries\RuleEngine.ahk"
#Include "..\..\Libraries\Database.ahk"
#Include "RaceAssistant.ahk"
#Include "Strategy.ahk"
#Include "..\..\Database\Libraries\SessionDatabase.ahk"
#Include "..\..\Database\Libraries\TelemetryDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceStrategist extends GridRaceAssistant {
	iRaceInfo := false

	iOriginalStrategy := false
	iStrategy := false
	iStrategyReported := false
	iLastStrategyUpdate := 0
	iRejectedStrategy := false

	iUseTraffic := false

	iSaveTelemetry := kAlways
	iSaveRaceReport := false
	iRaceReview := false

	iHasTelemetryData := false

	iTelemetryDatabaseDirectory := false

	iTelemetryDatabase := false

	iSessionReportsDatabase := false
	iSessionDataActive := false

	class RaceStrategistRemoteHandler extends RaceAssistant.RaceAssistantRemoteHandler {
		__New(remotePID) {
			super.__New("Race Strategist", remotePID)
		}

		saveStandingsData(arguments*) {
			this.callRemote("saveStandingsData", arguments*)
		}

		saveTelemetryData(arguments*) {
			this.callRemote("saveTelemetryData", arguments*)
		}

		updateTelemetryDatabase(arguments*) {
			this.callRemote("updateTelemetryDatabase", arguments*)
		}

		saveRaceInfo(arguments*) {
			this.callRemote("saveRaceInfo", arguments*)
		}

		saveRaceLap(arguments*) {
			this.callRemote("saveRaceLap", arguments*)
		}

		createRaceReport(arguments*) {
			this.callRemote("createRaceReport", arguments*)
		}

		updateStrategy(arguments*) {
			this.callRemote("updateStrategy", arguments*)
		}

		reviewRace(arguments*) {
			this.callRemote("reviewRace", arguments*)
		}

		computeCarStatistics(arguments*) {
			this.callRemote("computeCarStatistics", arguments*)
		}
	}

	class ConfirmStrategyUpdateContinuation extends VoiceManager.ReplyContinuation {
		iStrategy := false
		iRemember := false

		__New(strategist, strategy, remember) {
			this.iStrategy := strategy
			this.iRemember := remember

			super.__New(strategist, ObjBindMethod(strategist, "chooseScenario", strategy, false), "Roger", "Okay")
		}

		cancel() {
			if this.iRemember
				this.Manager.updateDynamicValues({RejectedStrategy: this.iStrategy})

				super.cancel()
		}
	}

	class TyreChangeContinuation extends VoiceManager.ReplyContinuation {
		cancel() {
			if ProcessExist("Race Engineer.exe") {
				this.Manager.getSpeaker().speakPhrase("ConfirmInformEngineerAnyway", false, true)

				this.Manager.setContinuation(ObjBindMethod(this.Manager, "planPitstop"))
			}
			else
				super.cancel()
		}
	}

	class ExplainPitstopContinuation extends VoiceManager.ReplyContinuation {
		iPlannedLap := false
		iPitstopOptions := []

		PlannedLap {
			Get {
				return this.iPlannedLap
			}
		}

		PitstopOptions {
			Get {
				return this.iPitstopOptions
			}
		}

		__New(manager, plannedLap, pitstopOptions, arguments*) {
			this.iPlannedLap := plannedLap
			this.iPitstopOptions := pitstopOptions

			super.__New(manager, arguments*)
		}

		cancel() {
			if ProcessExist("Race Engineer.exe") {
				this.Manager.getSpeaker().speakPhrase("ConfirmInformEngineerAnyway", false, true)

				this.Manager.setContinuation(ObjBindMethod(this.Manager, "planPitstop", this.PlannedLap, this.PitstopOptions*))
			}
			else
				super.cancel()
		}
	}

	class RaceReviewContinuation extends VoiceManager.VoiceContinuation {
	}

	class SessionTelemetryDatabase extends TelemetryDatabase {
		iRaceStrategist := false
		iTelemetryDatabase := false

		RaceStrategist {
			Get {
				return this.iRaceStrategist
			}
		}

		TelemetryDatabase {
			Get {
				return this.iTelemetryDatabase
			}
		}

		__New(strategist, simulator := false, car := false, track := false) {
			this.iRaceStrategist := strategist

			super.__New()

			this.Shared := false

			this.setDatabase(Database(strategist.TelemetryDatabaseDirectory, kTelemetrySchemas))

			if simulator
				this.iTelemetryDatabase := TelemetryDatabase(simulator, car, track)
		}

		setDrivers(drivers) {
			super.setDrivers(drivers)

			if this.TelemetryDatabase
				this.TelemetryDatabase.setDrivers(drivers)
		}

		getMapData(weather, compound, compoundColor) {
			local entries := []
			local newEntries, ignore, entry, ignore, entry, found, candidate

			for ignore, entry in super.getMapData(weather, compound, compoundColor)
				if ((entry["Fuel.Consumption"] > 0) && (entry["Lap.Time"] > 0))
					entries.Push(entry)

			if this.TelemetryDatabase {
				newEntries := []

				for ignore, entry in this.TelemetryDatabase.getMapData(weather, compound, compoundColor) {
					if ((entry["Fuel.Consumption"] > 0) && (entry["Lap.Time"] > 0)) {
						found := false

						for ignore, candidate in entries
							if ((candidate["Map"] = entry["Map"]) && (candidate["Lap.Time"] = entry["Lap.Time"])
																  && (candidate["Fuel.Consumption"] = entry["Fuel.Consumption"])) {
								found := true

								break
							}

						if !found
							newEntries.Push(entry)
					}
				}

				for ignore, entry in newEntries
					entries.Push(entry)
			}

			return entries
		}

		getTyreData(weather, compound, compoundColor) {
			local entries := []
			local newEntries, ignore, entry, found, candidate

			for ignore, entry in super.getTyreData(weather, compound, compoundColor)
				if (entry["Lap.Time"] > 0)
					entries.Push(entry)

			if this.TelemetryDatabase {
				newEntries := []

				for ignore, entry in this.TelemetryDatabase.getTyreData(weather, compound, compoundColor) {
					if (entry["Lap.Time"] > 0) {
						found := false

						for ignore, candidate in entries
							if ((candidate["Tyre.Laps"] = entry["Tyre.Laps"]) && (candidate["Lap.Time"] = entry["Lap.Time"])) {
								found := true

								break
							}

						if !found
							newEntries.Push(entry)
					}
				}

				for ignore, entry in newEntries
					entries.Push(entry)
			}

			return entries
		}

		getMapLapTimes(weather, compound, compoundColor) {
			local entries := []
			local newEntries, ignore, entry, found, candidate

			for ignore, entry in super.getMapLapTimes(weather, compound, compoundColor)
				if (entry["Lap.Time"] > 0)
					entries.Push(entry)

			if this.TelemetryDatabase {
				newEntries := []

				for ignore, entry in this.TelemetryDatabase.getMapLapTimes(weather, compound, compoundColor) {
					if (entry["Lap.Time"] > 0) {
						found := false

						for ignore, candidate in entries
							if ((candidate["Map"] = entry["Map"]) && (candidate["Fuel.Remaining"] = entry["Fuel.Remaining"])
																  && (candidate["Lap.Time"] = entry["Lap.Time"])) {
								found := true

								break
							}

						if !found
							newEntries.Push(entry)
					}
				}

				for ignore, entry in newEntries
					entries.Push(entry)
			}

			return entries
		}

		getTyreLapTimes(weather, compound, compoundColor) {
			local entries := []
			local newEntries, ignore, entry, found, candidate

			for ignore, entry in super.getTyreLapTimes(weather, compound, compoundColor)
				if (entry["Lap.Time"] > 0)
					entries.Push(entry)

			if this.TelemetryDatabase {
				newEntries := []

				for ignore, entry in this.TelemetryDatabase.getTyreLapTimes(weather, compound, compoundColor) {
					if (entry["Lap.Time"] > 0) {
						found := false

						for ignore, candidate in entries
							if ((candidate["Tyre.Laps"] = entry["Tyre.Laps"]) && (candidate["Lap.Time"] = entry["Lap.Time"])) {
								found := true

								break
							}

						if !found
							newEntries.Push(entry)
					}
				}

				for ignore, entry in newEntries
					entries.Push(entry)
			}

			return entries
		}
	}

	class RaceStrategySimulationContinuation extends VoiceManager.VoiceContinuation {
		iData := false
		iConfirm := false
		iRequest := false

		Statistics {
			Get {
				return this.iStatistics
			}

			Set {
				return (this.iStatistics := value)
			}
		}

		__New(manager, data, confirm, request) {
			this.iData := data
			this.iConfirm := confirm
			this.iRequest := request

			super.__New(manager)
		}

		next(statistics) {
			RaceStrategist.RaceStrategySimulationTask(this.Manager, this.iData, this.iConfirm, this.iRequest, statistics).start()
		}
	}

	class RaceStrategySimulationTask extends Task {
		iConfirm := false
		iRequest := "User"

		iRaceStrategist := false
		iTelemetryDatabase := false

		iSimulation := false

		iLap := false

		iStatistics := false
		iPitstops := []
		iUsedTyreSets := []

		RaceStrategist {
			Get {
				return this.iRaceStrategist
			}
		}

		TelemetryDatabase {
			Get {
				return this.iTelemetryDatabase
			}
		}

		Confirm {
			Get {
				return this.iConfirm
			}
		}

		Request {
			Get {
				return this.iRequest
			}
		}

		Simulation {
			Get {
				return this.iSimulation
			}
		}

		Lap {
			Get {
				return this.iLap
			}
		}

		Statistics {
			Get {
				return this.iStatistics
			}
		}

		Pitstops[key?] {
			Get {
				return (isSet(key) ? this.iPitstops[key] : this.iPitstops)
			}
		}

		UsedTyreSets[key?] {
			Get {
				return (isSet(key) ? this.iUsedTyreSets[key] : this.iUsedTyreSets)
			}
		}

		__New(strategist, configuration, confirm := false, request := "User", statistics := false) {
			local knowledgeBase := strategist.KnowledgeBase

			super.__New(false, 0, kLowPriority)

			this.iConfirm := confirm
			this.iRequest := request
			this.iStatistics := statistics
			this.iRaceStrategist := strategist
			this.iLap := knowledgeBase.getValue("Lap")
			this.iTelemetryDatabase
				:= RaceStrategist.SessionTelemetryDatabase(strategist
														 , strategist.Simulator
														 , knowledgeBase.getValue("Session.Car")
														 , knowledgeBase.getValue("Session.Track"))

			this.loadFromConfiguration(configuration)
		}

		loadFromConfiguration(configuration) {
			local pitstops := []
			local tyreSets := []

			loop getMultiMapValue(configuration, "Pitstops", "Count")
				pitstops.Push({Lap: getMultiMapValue(configuration, "Pitstops", A_Index . ".Lap")
							 , Refuel: getMultiMapValue(configuration, "Pitstops", A_Index . ".Refuel", 0)
							 , TyreChange: getMultiMapValue(configuration, "Pitstops", A_Index . ".TyreChange")
							 , TyreCompound: getMultiMapValue(configuration, "Pitstops", A_Index . ".TyreCompound", false)
							 , TyreCompoundColor: getMultiMapValue(configuration, "Pitstops", A_Index . ".TyreCompoundColor", false)
							 , TyreSet: getMultiMapValue(configuration, "Pitstops", A_Index . ".TyreSet", false)
							 , RepairBodywork: getMultiMapValue(configuration, "Pitstops", A_Index . ".RepairBodywork", false)
							 , RepairSuspension: getMultiMapValue(configuration, "Pitstops", A_Index . ".RepairSuspension", false)
							 , RepairEngine: getMultiMapValue(configuration, "Pitstops", A_Index . ".RepairEngine")})

			loop getMultiMapValue(configuration, "TyreSets", "Count")
				tyreSets.Push({Laps: getMultiMapValue(configuration, "TyreSets", A_Index . ".Laps")
							 , Set: getMultiMapValue(configuration, "TyreSets", A_Index . ".Set")
							 , Compound: getMultiMapValue(configuration, "TyreSets", A_Index . ".Compound")
							 , CompoundColor: getMultiMapValue(configuration, "TyreSets", A_Index . ".CompoundColor")})

			this.iPitstops := pitstops
			this.iUsedTyreSets := tyreSets
		}

		run() {
			if this.RaceStrategist.UseTraffic
				this.iSimulation := TrafficSimulation(this.RaceStrategist
												    , (this.RaceStrategist.KnowledgeBase.getValue("Session.Format") = "Time") ? "Duration" : "Laps"
												    , this.TelemetryDatabase)
			else
				this.iSimulation := VariationSimulation(this.RaceStrategist
													  , (this.RaceStrategist.KnowledgeBase.getValue("Session.Format") = "Time") ? "Duration" : "Laps"
													  , this.TelemetryDatabase)

			try {
				this.Simulation.runSimulation(isDebug())
			}
			finally {
				this.iSimulation := false
			}

			return false
		}
	}

	class RaceStrategy extends Strategy {
		iRunningPitstops := 0
		iRunningLaps := 0
		iRunningTime := 0

		RunningPitstops {
			Get {
				return this.iRunningPitstops
			}

			Set {
				return (this.iRunningPitstops := value)
			}
		}

		RunningLaps {
			Get {
				return this.iRunningLaps
			}

			Set {
				return (this.iRunningLaps := value)
			}
		}

		RunningTime {
			Get {
				return this.iRunningTime
			}

			Set {
				return (this.iRunningTime := value)
			}
		}

		initializeAvailableTyreSets() {
			super.initializeAvailableTyreSets()

			this.StrategyManager.StrategyManager.initializeAvailableTyreSets(this)
		}
	}

	class TrafficRaceStrategy extends TrafficStrategy {
		iRunningPitstops := 0
		iRunningLaps := 0
		iRunningTime := 0

		RunningPitstops {
			Get {
				return this.iRunningPitstops
			}

			Set {
				return (this.iRunningPitstops := value)
			}
		}

		RunningLaps {
			Get {
				return this.iRunningLaps
			}

			Set {
				return (this.iRunningLaps := value)
			}
		}

		RunningTime {
			Get {
				return this.iRunningTime
			}

			Set {
				return (this.iRunningTime := value)
			}
		}

		initializeAvailableTyreSets() {
			super.initializeAvailableTyreSets()

			this.StrategyManager.StrategyManager.initializeAvailableTyreSets(this)
		}
	}

	RaceInfo[key?] {
		Get {
			return (isSet(key) ? this.iRaceInfo[key] : this.iRaceInfo)
		}
	}

	Strategy[original := false] {
		Get {
			return (original ? ((original = "Rejected") ? this.iRejectedStrategy : this.iOriginalStrategy) : this.iStrategy)
		}
	}

	StrategyReported {
		Get {
			return this.iStrategyReported
		}
	}

	UseTraffic {
		Get {
			return this.iUseTraffic
		}
	}

	SaveTelemetry {
		Get {
			return this.iSaveTelemetry
		}
	}

	SaveRaceReport {
		Get {
			return ((this.iSessionReportsDatabase != false) ? this.iSaveRaceReport : kNever)
		}
	}

	RaceReview {
		Get {
			return this.iRaceReview
		}
	}

	HasTelemetryData {
		Get {
			return this.iHasTelemetryData
		}
	}

	TelemetryDatabase {
		Get {
			return this.iTelemetryDatabase
		}
	}

	TelemetryDatabaseDirectory {
		Get {
			return this.iTelemetryDatabaseDirectory
		}
	}

	SessionReportsDatabase {
		Get {
			return this.iSessionReportsDatabase
		}
	}

	SessionDataActive {
		Get {
			return this.iSessionDataActive
		}
	}

	__New(configuration, remoteHandler, name := false, language := kUndefined
		, synthesizer := false, speaker := false, vocalics := false, recognizer := false, listener := false, muted := false, voiceServer := false) {
		super.__New(configuration, "Race Strategist", remoteHandler, name, language, synthesizer, speaker, vocalics, recognizer, listener, muted, voiceServer)

		this.updateConfigurationValues({Announcements: {WeatherUpdate: true}})

		deleteDirectory(kTempDirectory . "Race Strategist")

		DirCreate(kTempDirectory "Race Strategist")

		this.iTelemetryDatabaseDirectory := (kTempDirectory . "Race Strategist\")
	}

	updateConfigurationValues(values) {
		super.updateConfigurationValues(values)

		if values.HasProp("SessionReportsDatabase")
			this.iSessionReportsDatabase := values.SessionReportsDatabase

		if values.HasProp("SaveTelemetry")
			this.iSaveTelemetry := values.SaveTelemetry

		if values.HasProp("SaveRaceReport")
			this.iSaveRaceReport := values.SaveRaceReport

		if values.HasProp("RaceReview")
			this.iRaceReview := values.RaceReview

		if values.HasProp("UseTraffic")
			this.iUseTraffic := values.UseTraffic

		if (values.HasProp("Session") && (this.Session == kSessionFinished)) {
			this.iStrategyReported := false
			this.iLastStrategyUpdate := 0
			this.iRejectedStrategy := false
		}
	}

	updateSessionValues(values) {
		super.updateSessionValues(values)

		if values.HasProp("TelemetryDatabase")
			this.iTelemetryDatabase := values.TelemetryDatabase

		if values.HasProp("OriginalStrategy")
			this.iOriginalStrategy := values.OriginalStrategy

		if values.HasProp("Strategy") {
			if (this.iRejectedStrategy && (this.iRejectedStrategy != values.RejectedStrategy))
				this.iRejectedStrategy.dispose()

			this.iStrategy := values.Strategy
		}

		if values.HasProp("RaceInfo")
			this.iRaceInfo := values.RaceInfo
	}

	updateDynamicValues(values) {
		super.updateDynamicValues(values)

		if values.HasProp("HasTelemetryData")
			this.iHasTelemetryData := values.HasTelemetryData

		if values.HasProp("StrategyReported")
			this.iStrategyReported := values.StrategyReported

		if values.HasProp("RejectedStrategy") {
			if (this.iRejectedStrategy && (this.iRejectedStrategy != values.RejectedStrategy))
				this.iRejectedStrategy.dispose()

			this.iRejectedStrategy := values.RejectedStrategy
		}
	}

	hasEnoughData(inform := true) {
		if !inform
			return super.hasEnoughData(false)
		else if (this.Session == kSessionRace)
			return super.hasEnoughData(inform)
		else {
			if this.Speaker
				this.getSpeaker().speakPhrase("CollectingData")

			return false
		}
	}

	getClass(car := false, data := false, categories?) {
		static strategistCategories := false

		if isSet(categories)
			return super.getClass(car, data, categories)
		else {
			if !strategistCategories
				switch getMultiMapValue(this.Settings, "Assistant.Strategist", "CarCategories", "Classes") {
					case "All":
						strategistCategories := ["Class", "Cup"]
					case "Classes":
						strategistCategories := ["Class"]
					case "Cups":
						strategistCategories := ["Cup"]
					default:
						strategistCategories := ["Class"]
				}

			return super.getClass(car, data, strategistCategories)
		}
	}

	handleVoiceCommand(grammar, words) {
		local reset := true

		switch grammar, false {
			case "LapsRemaining":
				this.lapsRemainingRecognized(words)
			case "Weather":
				this.weatherRecognized(words)
			case "Position":
				this.positionRecognized(words)
			case "LapTimes":
				this.lapTimesRecognized(words)
			case "ActiveCars":
				this.activeCarsRecognized(words)
			case "FuturePosition":
				this.futurePositionRecognized(words)
			case "GapToAhead", "GapToFront":
				this.gapToAheadRecognized(words)
			case "GapToBehind":
				this.gapToBehindRecognized(words)
			case "GapToLeader":
				this.gapToLeaderRecognized(words)
			case "StrategyOverview":
				this.strategyOverviewRecognized(words)
			case "CancelStrategy":
				this.cancelStrategyRecognized(words)
			case "NextPitstop":
				this.nextPitstopRecognized(words)
			case "StrategyRecommend":
				reset := false

				this.clearContinuation()

				if !this.hasEnoughData()
					return

				this.getSpeaker().speakPhrase("Confirm")

				Task.yield()

				loop 10
					Sleep(500)

				this.recommendStrategyRecognized(words)
			case "PitstopRecommend":
				reset := false

				this.clearContinuation()

				if !this.hasEnoughData()
					return

				this.getSpeaker().speakPhrase("Confirm")

				Task.yield()

				loop 10
					Sleep(500)

				this.recommendPitstopRecognized(words)
			case "PitstopSimulate":
				reset := false

				this.clearContinuation()

				if !this.hasEnoughData()
					return

				this.getSpeaker().speakPhrase("Confirm")

				Task.yield()

				loop 10
					Sleep(500)

				this.simulatePitstopRecognized(words)
			default:
				reset := false

				super.handleVoiceCommand(grammar, words)
		}

		if reset
			this.clearContinuation()
	}

	lapsRemainingRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker, remainingFuelLaps, remainingSessionLaps, remainingStintLaps

		if !this.hasEnoughData()
			return

		speaker := this.getSpeaker()
		remainingFuelLaps := Floor(knowledgeBase.getValue("Lap.Remaining.Fuel", 0))

		if (remainingFuelLaps == 0)
			speaker.speakPhrase("Later")
		else {
			speaker.beginTalk()

			try {
				speaker.speakPhrase("LapsAlready", {laps: (knowledgeBase.getValue("Lap", 0) - this.BaseLap + 1)})

				speaker.speakPhrase("LapsFuel", {laps: remainingFuelLaps})

				remainingSessionLaps := Ceil(knowledgeBase.getValue("Lap.Remaining.Session", 0))
				remainingStintLaps := Floor(knowledgeBase.getValue("Lap.Remaining.Stint", 0))

				if ((remainingStintLaps < remainingFuelLaps) && (remainingStintLaps < remainingSessionLaps))
					speaker.speakPhrase("LapsStint", {laps: remainingSessionLaps})
				else if (remainingSessionLaps < remainingFuelLaps)
					speaker.speakPhrase("LapsSession", {laps: remainingSessionLaps})
			}
			finally {
				speaker.endTalk()
			}
		}
	}

	weatherRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local weather10Min := (knowledgeBase ? knowledgeBase.getValue("Weather.Weather.10Min", false) : false)

		if !weather10Min
			this.getSpeaker().speakPhrase("Later")
		else if (weather10Min = "Dry")
			this.getSpeaker().speakPhrase("WeatherGood")
		else
			this.getSpeaker().speakPhrase("WeatherRain")
	}

	positionRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker, position, classPosition

		if !this.hasEnoughData()
			return

		speaker := this.getSpeaker()
		position := this.getPosition()

		if (position == 0)
			speaker.speakPhrase("Later")
		else if inList(words, speaker.Fragments["Laps"])
			this.futurePositionRecognized(words)
		else {
			speaker.beginTalk()

			try {
				if this.MultiClass {
					classPosition := this.getPosition(false, "Class")

					if (position != classPosition) {
						speaker.speakPhrase("PositionClass", {positionOverall: position, positionClass: classPosition})

						position := classPosition
					}
					else
						speaker.speakPhrase("Position", {position: position})
				}
				else
					speaker.speakPhrase("Position", {position: position})

				if (position <= 3)
					speaker.speakPhrase("Great")
			}
			finally {
				speaker.endTalk()
			}
		}
	}

	futurePositionRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker, fragments, lapPosition, lapDelta, currentLap, lap, car, position

		if !this.hasEnoughData()
			return

		speaker := this.getSpeaker()
		fragments := speaker.Fragments

		lapPosition := inList(words, fragments["Laps"])

		if lapPosition {
			lapDelta := words[lapPosition - 1]

			if this.isNumber(lapDelta, &lapDelta) {
				currentLap := knowledgeBase.getValue("Lap")
				lap := (currentLap + lapDelta)

				if (lap <= currentLap)
					speaker.speakPhrase("NoFutureLap")
				else {
					car := knowledgeBase.getValue("Driver.Car")

					speaker.speakPhrase("Confirm")

					Task.yield()

					loop 10
						Sleep(500)

					knowledgeBase.setFact("Standings.Extrapolate", lap)

					knowledgeBase.produce()

					if this.Debug[kDebugKnowledgeBase]
						this.dumpKnowledgeBase(this.KnowledgeBase)

					position := knowledgeBase.getValue("Standings.Extrapolated." . lap . ".Car." . car . ".Position", false)

					if position
						speaker.speakPhrase("FuturePosition", {position: position, class: ""})
					else
						speaker.speakPhrase("NoFuturePosition")
				}

				return
			}
		}

		speaker.speakPhrase("Repeat")
	}

	gapToAheadRecognized(words) {
		local knowledgeBase := this.KnowledgeBase

		if !this.hasEnoughData()
			return

		if inList(words, this.getSpeaker().Fragments["Car"])
			this.trackGapToAheadRecognized(words)
		else
			this.standingsGapToAheadRecognized(words)
	}

	trackGapToAheadRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local car := knowledgeBase.getValue("Position.Track.Ahead.Car")
		local delta := Abs(knowledgeBase.getValue("Position.Track.Ahead.Delta", 0))
		local lap, driverLap, otherLap

		if (knowledgeBase.getValue("Car." . car . ".InPitLane", false) || knowledgeBase.getValue("Car." . car . ".InPit", false))
			speaker.speakPhrase("AheadCarInPit")
		else if (delta != 0) {
			speaker.beginTalk()

			try {
				speaker.speakPhrase("TrackGapToAhead", {delta: speaker.number2Speech(delta / 1000, 1)})

				lap := knowledgeBase.getValue("Lap")
				driverLap := Floor(knowledgeBase.getValue("Standings.Lap." . lap . ".Car." . knowledgeBase.getValue("Driver.Car") . ".Laps"))
				otherLap := Floor(knowledgeBase.getValue("Standings.Lap." . lap . ".Car." . knowledgeBase.getValue("Position.Track.Ahead.Car") . ".Laps"))

				if (driverLap != otherLap)
				  speaker.speakPhrase("NotTheSameLap")
			}
			finally {
				speaker.endTalk()
			}
		}
		else
			speaker.speakPhrase("NoTrackGap")
	}

	standingsGapToAheadRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local delta, lap, car, inPit, speaker

		if (this.getPosition(false, "Class") = 1)
			speaker.speakPhrase("NoGapToAhead")
		else {
			speaker.beginTalk()

			try {
				lap := knowledgeBase.getValue("Lap")
				car := knowledgeBase.getValue("Position.Standings.Class.Ahead.Car")
				delta := Abs(knowledgeBase.getValue("Position.Standings.Class.Ahead.Delta", 0) / 1000)
				inPit := (knowledgeBase.getValue("Car." . car . ".InPitLane", false) || knowledgeBase.getValue("Car." . car . ".InPit", false))

				if ((delta = 0) || (inPit && (Abs(delta) < 30))) {
					speaker.speakPhrase(inPit ? "AheadCarInPit" : "NoTrackGap")

					return
				}
				else if ((knowledgeBase.getValue("Car." . car . ".Lap") > lap)
					  && (Abs(delta) > (knowledgeBase.getValue("Lap." . lap . ".Time") / 1000)))
					speaker.speakPhrase("StandingsAheadLapped")
				else
					speaker.speakPhrase("StandingsGapToAhead", {delta: speaker.number2Speech(delta, 1)})

				if inPit
					speaker.speakPhrase("GapCarInPit")
			}
			finally {
				speaker.endTalk()
			}
		}
	}

	gapToBehindRecognized(words) {
		local knowledgeBase := this.KnowledgeBase

		if !this.hasEnoughData()
			return

		if inList(words, this.getSpeaker().Fragments["Car"])
			this.trackGapToBehindRecognized(words)
		else
			this.standingsGapToBehindRecognized(words)
	}

	trackGapToBehindRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local car := knowledgeBase.getValue("Position.Track.Behind.Car")
		local delta := Abs(knowledgeBase.getValue("Position.Track.Behind.Delta", 0))
		local lap, driverLap, otherLap

		if (knowledgeBase.getValue("Car." . car . ".InPitLane", false) || knowledgeBase.getValue("Car." . car . ".InPit", false))
			speaker.speakPhrase("BehindCarInPit")
		else if (delta != 0) {
			speaker.beginTalk()

			try {
				speaker.speakPhrase("TrackGapToBehind", {delta: speaker.number2Speech(delta / 1000, 1)})

				lap := knowledgeBase.getValue("Lap")
				driverLap := Floor(knowledgeBase.getValue("Standings.Lap." . lap . ".Car." . knowledgeBase.getValue("Driver.Car") . ".Laps"))
				otherLap := Floor(knowledgeBase.getValue("Standings.Lap." . lap . ".Car." . knowledgeBase.getValue("Position.Track.Behind.Car") . ".Laps"))

				if (driverLap != otherLap)
				  speaker.speakPhrase("NotTheSameLap")
			}
			finally {
				speaker.endTalk()
			}
		}
		else
			speaker.speakPhrase("NoTrackGap")
	}

	standingsGapToBehindRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local delta, car, speaker, driver, inPit, lap, lapped

		if (this.getPosition(false, "Class") = this.getCars("Class").Length)
			speaker.speakPhrase("NoGapToBehind")
		else {
			speaker.beginTalk()

			try {
				lap := knowledgeBase.getValue("Lap")
				car := knowledgeBase.getValue("Position.Standings.Class.Behind.Car")
				delta := Abs(knowledgeBase.getValue("Position.Standings.Class.Behind.Delta", 0) / 1000)
				inPit := (knowledgeBase.getValue("Car." . car . ".InPitLane", false) || knowledgeBase.getValue("Car." . car . ".InPit", false))
				lapped := false

				if ((delta = 0) || (inPit && (Abs(delta) < 30))) {
					speaker.speakPhrase(inPit ? "BehindCarInPit" : "NoTrackGap")

					return
				}
				else if ((knowledgeBase.getValue("Car." . car . ".Lap") < lap)
					  && (Abs(delta) > (knowledgeBase.getValue("Lap." . lap . ".Time") / 1000))) {
					speaker.speakPhrase("StandingsBehindLapped")

					lapped := true
				}
				else
					speaker.speakPhrase("StandingsGapToBehind", {delta: speaker.number2Speech(delta, 1)})

				if (!lapped && inPit)
					speaker.speakPhrase("GapCarInPit")
			}
			finally {
				speaker.endTalk()
			}
		}
	}

	gapToLeaderRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local delta

		if !this.hasEnoughData()
			return

		if (this.getPosition(false, "Class") = 1)
			speaker.speakPhrase("NoGapToAhead")
		else {
			delta := Abs(knowledgeBase.getValue("Position.Standings.Class.Leader.Delta", 0) / 1000)

			speaker.speakPhrase("GapToLeader", {delta: speaker.number2Speech(delta, 1)})
		}
	}

	lapTimesRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local car, lap, position, cars, driverLapTime, speaker, minute, seconds

		reportLapTime(phrase, driverLapTime, car) {
			local lapTime := this.KnowledgeBase.getValue("Car." . car . ".Time", false)
			local speaker, fragments, minute, seconds, delta

			if !this.hasEnoughData()
				return

			if lapTime {
				lapTime /= 1000

				speaker := this.getSpeaker()

				speaker.beginTalk()
				fragments := speaker.Fragments

				minute := Floor(lapTime / 60)
				seconds := (lapTime - (minute * 60))

				try {
					speaker.speakPhrase(phrase, {time: speaker.number2Speech(lapTime, 1), minute: minute, seconds: speaker.number2Speech(seconds, 1)})

					delta := (driverLapTime - lapTime)

					if (Abs(delta) > 0.5)
						speaker.speakPhrase("LapTimeDelta", {delta: speaker.number2Speech(Abs(delta), 1)
														   , difference: (delta > 0) ? fragments["Faster"] : fragments["Slower"]})
				}
				finally {
					speaker.endTalk()
				}
			}
		}

		if !this.hasEnoughData()
			return

		car := knowledgeBase.getValue("Driver.Car")
		lap := knowledgeBase.getValue("Lap", 0)
		position := this.getPosition(false, "Class")
		cars := knowledgeBase.getValue("Car.Count")

		driverLapTime := (knowledgeBase.getValue("Car." . car . ".Time") / 1000)

		if (lap == 0)
			this.getSpeaker().speakPhrase("Later")
		else {
			speaker := this.getSpeaker()

			speaker.beginTalk()

			try {
				minute := Floor(driverLapTime / 60)
				seconds := (driverLapTime - (minute * 60))

				speaker.speakPhrase("LapTime", {time: speaker.number2Speech(driverLapTime, 1), minute: minute, seconds: speaker.number2Speech(seconds, 1)})

				if (position > 2)
					reportLapTime("LapTimeFront", driverLapTime, knowledgeBase.getValue("Position.Standings.Class.Ahead.Car", 0))

				if (position < cars)
					reportLapTime("LapTimeBehind", driverLapTime, knowledgeBase.getValue("Position.Standings.Class.Behind.Car", 0))

				if (position > 1)
					reportLapTime("LapTimeLeader", driverLapTime, knowledgeBase.getValue("Position.Standings.Class.Leader.Car", 0))
			}
			finally {
				speaker.endTalk()
			}
		}
	}

	activeCarsRecognized(words) {
		if !this.Knowledgebase
			this.getSpeaker().speakPhrase("Later")
		else {
			if this.MultiClass
				this.getSpeaker().speakPhrase("ActiveCarsClass", {overallCars: this.getCars().Length, classCars: this.getCars("Class").Length})
			else
				this.getSpeaker().speakPhrase("ActiveCars", {cars: this.getCars().Length})
		}
	}

	strategyOverviewRecognized(words) {
		if !this.hasEnoughData()
			return

		this.reportStrategy()
	}

	cancelStrategyRecognized(words) {
		if !this.hasEnoughData()
			return

		this.cancelStrategy()
	}

	nextPitstopRecognized(words) {
		if !this.hasEnoughData()
			return

		this.reportStrategy({Strategy: false, Pitstops: false, NextPitstop: true})
	}

	recommendStrategyRecognized(words) {
		if !this.hasEnoughData()
			return

		this.recommendStrategy()
	}

	recommendPitstopRecognized(words) {
		if !this.hasEnoughData()
			return

		this.pitstopLapRecognized(words)
	}

	simulatePitstopRecognized(words) {
		if !this.hasEnoughData()
			return

		this.pitstopLapRecognized(words, true)
	}

	pitstopLapRecognized(words, lap := false) {
		local lapPosition

		if lap {
			lapPosition := inList(words, this.getSpeaker().Fragments["Lap"])

			if lapPosition {
				lap := words[lapPosition + 1]

				if !this.isNumber(lap, &lap)
					lap := false
			}
			else
				lap := false
		}

		this.recommendPitstop(lap)
	}

	reviewRace(multiClass, cars, laps, position, leaderAvgLapTime
			 , driverAvgLapTime, driverMinLapTime, driverMaxLapTime, driverLapTimeStdDev) {
		local knowledgeBase := this.KnowledgeBase
		local split, class, speaker, continuation, only, driver, goodPace

		if ((this.Session = kSessionRace) && this.hasEnoughData(false) && (position != 0)) {
			speaker := this.getSpeaker()

			speaker.beginTalk()

			class := (multiClass ? speaker.Fragments["Class"] : "")

			try {
				split := Max(1, (cars / 5))

				if (position <= split)
					speaker.speakPhrase("GreatRace", {position: position, class: class})
				else if (position <= (split * 3))
					speaker.speakPhrase("MediocreRace", {position: position, class: class})
				else
					speaker.speakPhrase("CatastrophicRace", {position: position, class: class})

				if (position > 1) {
					only := ""

					if (driverAvgLapTime < (leaderAvgLapTime * 1.01))
						only := speaker.Fragments["Only"]

					speaker.speakPhrase("Compare2Leader", {relative: only, seconds: speaker.number2Speech(Abs(driverAvgLapTime - leaderAvgLapTime), 1)})

					driver := knowledgeBase.getValue("Driver.Car")

					if (((laps - knowledgeBase.getValue("Car." . driver . ".Valid.Laps", laps)) > (laps * 0.08))
					 || (knowledgeBase.getValue("Car." . driver . ".Incidents", 0) > (laps * 0.08)))
						speaker.speakPhrase("InvalidCritics", {conjunction: speaker.Fragments[(only != "") ? "But" : "And"]})

					if (position <= (cars / 3))
						speaker.speakPhrase("PositiveSummary")

					if (driverMinLapTime && driverLapTimeStdDev) {
						goodPace := false

						if (driverMinLapTime <= (leaderAvgLapTime * 1.005)) {
							speaker.speakPhrase("GoodPace")

							goodPace := true
						}
						else if (driverMinLapTime <= (leaderAvgLapTime * 1.01))
							speaker.speakPhrase("MediocrePace")
						else
							speaker.speakPhrase("BadPace")

						if (driverLapTimeStdDev < (driverAvgLapTime * 0.004))
							speaker.speakPhrase("GoodConsistency", {conjunction: speaker.Fragments[goodPace ? "And" : "But"]})
						else if (driverLapTimeStdDev < (driverAvgLapTime * 0.008))
							speaker.speakPhrase("MediocreConsistency", {conjunction: speaker.Fragments[goodPace ? "But" : "And"]})
						else
							speaker.speakPhrase("BadConsistency", {conjunction: speaker.Fragments[goodPace ? "But" : "And"]})
					}
				}
			}
			finally {
				speaker.endTalk()
			}
		}

		continuation := this.Continuation

		if isInstance(continuation, RaceStrategist.RaceReviewContinuation) {
			this.clearContinuation()

			continuation.next()
		}
	}

	updateCarStatistics(statistics) {
		local continuation := this.Continuation
		local fileName

		if !isObject(statistics) {
			fileName := statistics

			statistics := readMultiMap(fileName)

			if !isDebug()
				deleteFile(fileName)
		}

		if isInstance(continuation, RaceStrategist.RaceStrategySimulationContinuation) {
			this.clearContinuation()

			continuation.next(statistics)
		}
	}

	collectTelemetryData() {
		local session := "Other"
		local default := false

		switch this.Session {
			case kSessionPractice:
				session := "Practice"
				default := true
			case kSessionQualification:
				session := "Qualification"
			case kSessionRace:
				session := "Race"
				default := true
		}

		return getMultiMapValue(this.Settings, "Session Settings", "Telemetry." . session, default)
	}

	loadStrategy(facts, strategy, lastPitstop := false) {
		local pitstopWindow := getMultiMapValue(this.Settings, "Strategy Settings", "Strategy.Window.Considered", 3)
		local pitstop, count, ignore, pitstopLap, first, rootStrategy

		strategy.RunningPitstops := 0
		strategy.RunningLaps := 0
		strategy.RunningTime := 0

		facts["Strategy.Name"] := strategy.Name

		facts["Strategy.Weather"] := strategy.Weather
		facts["Strategy.Weather.Temperature.Air"] := strategy.AirTemperature
		facts["Strategy.Weather.Temperature.Track"] := strategy.TrackTemperature

		facts["Strategy.Tyre.Compound"] := strategy.TyreCompound
		facts["Strategy.Tyre.Compound.Color"] := strategy.TyreCompoundColor

		facts["Strategy.Map"] := strategy.Map
		facts["Strategy.TC"] := strategy.TC
		facts["Strategy.ABS"] := strategy.ABS

		facts["Strategy.Pitstop.Deviation"] := getMultiMapValue(this.Settings, "Strategy Settings", "Strategy.Update.Pitstop", pitstopWindow)

		count := 0

		for ignore, pitstop in strategy.Pitstops {
			if (lastPitstop && (pitstop.Nr <= lastPitstop))
				continue

			pitstopLap := pitstop.Lap

			count += 1

			if (count == 1) {
				first := false

				facts["Strategy.Pitstop.Next"] := 1
				facts["Strategy.Pitstop.Lap"] := pitstopLap
			}

			facts["Strategy.Pitstop." . A_Index . ".Lap"] := pitstopLap
			facts["Strategy.Pitstop." . A_Index . ".Fuel.Amount"] := pitstop.RefuelAmount
			facts["Strategy.Pitstop." . A_Index . ".Tyre.Change"] := pitstop.TyreChange
			facts["Strategy.Pitstop." . A_Index . ".Tyre.Compound"] := pitstop.TyreCompound
			facts["Strategy.Pitstop." . A_Index . ".Tyre.Compound.Color"] := pitstop.TyreCompoundColor
			facts["Strategy.Pitstop." . A_Index . ".Map"] := pitstop.Map
		}

		facts["Strategy.Pitstop.Count"] := count

		return facts
	}

	readSettings(simulator, car, track, &settings) {
		return combine(super.readSettings(simulator, car, track, &settings)
					 , CaseInsenseMap("Session.Settings.Pitstop.Delta", getMultiMapValue(settings, "Strategy Settings", "Pitstop.Delta"
																								 , getMultiMapValue(settings, "Session Settings"
																															, "Pitstop.Delta", 30))
									, "Session.Settings.Standings.Extrapolation.Laps", getMultiMapValue(settings, "Strategy Settings"
																												, "Extrapolation.Laps", 2)
									, "Session.Settings.Standings.Extrapolation.Overtake.Delta", Round(getMultiMapValue(settings
																													  , "Strategy Settings"
																													  , "Overtake.Delta", 1) * 1000)
									, "Session.Settings.Strategy.Traffic.Considered", (getMultiMapValue(settings, "Strategy Settings"
																												, "Traffic.Considered", 5) / 100)
									, "Session.Settings.Pitstop.Service.Refuel", getMultiMapValue(settings, "Strategy Settings"
																										  , "Service.Refuel.Rule", "Dynamic")
									, "Session.Settings.Pitstop.Service.Refuel", getMultiMapValue(settings, "Strategy Settings"
																										  , "Service.Refuel", 1.5)
									, "Session.Settings.Pitstop.Service.Tyres", getMultiMapValue(settings, "Strategy Settings"
																										  , "Service.Tyres", 30)
									, "Session.Settings.Pitstop.Service.Order", getMultiMapValue(settings, "Strategy Settings"
																										 , "Service.Order", "Simultaneous")
									, "Session.Settings.Pitstop.Strategy.Window.Considered", getMultiMapValue(settings, "Strategy Settings"
																													  , "Strategy.Window.Considered", 3)))
	}

	prepareSession(&settings, &data) {
		local raceData, carCount,  carNr, carCategory

		this.updateSessionValues({RaceInfo: false})

		super.prepareSession(&settings, &data)

		if settings
			this.updateConfigurationValues({UseTalking: getMultiMapValue(settings, "Assistant.Strategist", "Voice.UseTalking", true)
										  , UseTraffic: getMultiMapValue(settings, "Strategy Settings", "Traffic.Simulation", false)})

		raceData := newMultiMap()

		carCount := getMultiMapValue(data, "Position Data", "Car.Count")

		setMultiMapValue(raceData, "Cars", "Count", carCount)
		setMultiMapValue(raceData, "Cars", "Driver", getMultiMapValue(data, "Position Data", "Driver.Car"))

		loop carCount {
			carNr := getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Nr")

			setMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Nr", carNr)
			setMultiMapValue(raceData, "Cars", "Car." . A_Index . ".ID"
									 , getMultiMapValue(data, "Position Data", "Car." . A_Index . ".ID", A_Index))
			setMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Position"
									 , getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Position"))
			setMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Class"
									 , getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Class", kUnknown))

			carCategory := getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Category", kUndefined)

			if (carCategory != kUndefined)
				setMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Category", carCategory)
		}

		this.updateRaceInfo(raceData)
	}

	createSession(&settings, &data) {
		local facts := super.createSession(&settings, &data)
		local simulatorName := this.SettingsDatabase.getSimulatorName(facts["Session.Simulator"])
		local theStrategy, applicableStrategy, simulator, car, track
		local sessionType, sessionLength, duration, laps

		if settings
			this.updateConfigurationValues({UseTalking: getMultiMapValue(settings, "Assistant.Strategist", "Voice.UseTalking", true)
										  , UseTraffic: getMultiMapValue(settings, "Strategy Settings", "Traffic.Simulation", false)})

		if ((this.Session == kSessionRace) && FileExist(kUserConfigDirectory . "Race.strategy")) {
			theStrategy := Strategy(this, readMultiMap(kUserConfigDirectory . "Race.strategy"))

			applicableStrategy := false

			simulator := theStrategy.Simulator
			car := theStrategy.Car
			track := theStrategy.Track

			if ((simulator = simulatorName) && (car = facts["Session.Car"]) && (track = facts["Session.Track"]))
				applicableStrategy := true

			if applicableStrategy {
				sessionType := theStrategy.SessionType
				sessionLength := theStrategy.SessionLength

				if ((sessionType = "Duration") && (facts["Session.Format"] = "Time")) {
					duration := (facts["Session.Duration"] / 60)

					if ((Abs(sessionLength - duration) / duration) >  0.05)
						applicableStrategy := false
				}
				else if ((sessionType = "Laps") && (facts["Session.Format"] = "Lap")) {
					laps := facts["Session.Laps"]

					if ((Abs(sessionLength - laps) / laps) >  0.05)
						applicableStrategy := false
				}
				else
					applicableStrategy := false

				if applicableStrategy {
					this.loadStrategy(facts, theStrategy)

					this.updateSessionValues({OriginalStrategy: theStrategy, Strategy: theStrategy})
				}
			}
		}

		return facts
	}

	startSession(settings, data) {
		local facts := this.createSession(&settings, &data)
		local simulatorName := this.Simulator
		local configuration := this.Configuration
		local raceEngineer := (ProcessExist("Race Engineer.exe") > 0)
		local saveSettings, deprecated, telemetryDB

		if raceEngineer
			saveSettings := kNever
		else {
			deprecated := getMultiMapValue(configuration, "Race Engineer Shutdown", simulatorName . ".SaveSettings", kNever)
			saveSettings := getMultiMapValue(configuration, "Race Assistant Shutdown", simulatorName . ".SaveSettings", deprecated)
		}

		this.updateConfigurationValues({LearningLaps: getMultiMapValue(configuration, "Race Strategist Analysis", simulatorName . ".LearningLaps", 1)
									  , SessionReportsDatabase: getMultiMapValue(configuration, "Race Strategist Reports", "Database", false)
									  , SaveTelemetry: getMultiMapValue(configuration, "Race Strategist Shutdown", simulatorName . ".SaveTelemetry", kAlways)
									  , SaveRaceReport: getMultiMapValue(configuration, "Race Strategist Shutdown", simulatorName . ".SaveRaceReport", kNever)
									  , RaceReview: (getMultiMapValue(configuration, "Race Strategist Shutdown", simulatorName . ".RaceReview", "Yes") = "Yes")
									  , SaveSettings: saveSettings})

		telemetryDB := RaceStrategist.SessionTelemetryDatabase(this)

		telemetryDB.Database.clear("Electronics")
		telemetryDB.Database.clear("Tyres")
		telemetryDB.Database.flush()

		this.updateSessionValues({TelemetryDatabase: telemetryDB})

		this.updateDynamicValues({KnowledgeBase: this.createKnowledgeBase(facts), HasTelemetryData: false
								, BestLapTime: 0, OverallTime: 0, LastFuelAmount: 0, InitialFuelAmount: 0
								, EnoughData: false, StrategyReported: (getMultiMapValue(data, "Stint Data", "Laps", 0) > 1)})

		if this.Speaker
			this.getSpeaker().speakPhrase(raceEngineer ? "" : "Greeting")

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledgeBase(this.KnowledgeBase)
	}

	finishSession(shutdown := true, review := true) {
		local knowledgeBase := this.KnowledgeBase
		local lastLap, asked

		if knowledgeBase {
			lastLap := knowledgeBase.getValue("Lap", 0)

			if (shutdown && review && this.RaceReview && (this.Session = kSessionRace)
						 && (lastLap > this.LearningLaps)
						 && (knowledgeBase.getValue("Lap.Penalty", false) != "DSQ")) {
				this.finishSessionWithReview(shutdown)

				return
			}
			else
				review := false

			if (shutdown && !review && !ProcessExist("Race Engineer.exe") && this.Speaker)
				this.getSpeaker().speakPhrase("Bye")

			if (shutdown && (lastLap > this.LearningLaps)) {
				this.shutdownSession("Before")

				asked := true

				if ((((this.SaveSettings = kAsk) && (this.Session == kSessionRace))
				  || (this.collectTelemetryData() && (this.SaveTelemetry = kAsk) && this.HasTelemetryData))
				 && ((this.SaveRaceReport = kAsk) && (this.Session == kSessionRace)))
					this.getSpeaker().speakPhrase("ConfirmSaveSettingsAndRaceReport", false, true)
				else if ((this.SaveRaceReport = kAsk) && (this.Session == kSessionRace))
					this.getSpeaker().speakPhrase("ConfirmSaveRaceReport", false, true)
				else if (((this.SaveSettings = kAsk) && (this.Session == kSessionRace))
					  || (this.collectTelemetryData() && (this.SaveTelemetry = kAsk) && this.HasTelemetryData))
					this.getSpeaker().speakPhrase("ConfirmSaveSettings", false, true)
				else
					asked := false

				if asked {
					this.setContinuation(ObjBindMethod(this, "shutdownSession", "After"))

					Task.startTask(ObjBindMethod(this, "forceFinishSession"), 120000, kLowPriority)

					return
				}
			}

			this.updateDynamicValues({KnowledgeBase: false})
		}

		this.updateDynamicValues({OverallTime: 0, BestLapTime: 0, LastFuelAmount: 0, InitialFuelAmount: 0, EnoughData: false
								, StrategyReported: false, RejectedStrategy: false, HasTelemetryData: false})
		this.updateSessionValues({Simulator: "", Session: kSessionFinished, OriginalStrategy: false, Strategy: false, SessionTime: false})
	}

	forceFinishSession() {
		if !this.SessionDataActive {
			this.updateDynamicValues({KnowledgeBase: false})

			this.finishSession()

			return false
		}
		else {
			Task.CurrentTask.Sleep := 5000

			return Task.CurrentTask
		}
	}

	finishSessionWithReview(shutdown) {
		local categories

		if this.RemoteHandler {
			this.setContinuation(RaceStrategist.RaceReviewContinuation(this, ObjBindMethod(this, "finishSession", shutdown, false)))

			switch getMultiMapValue(this.Settings, "Assistant.Strategist", "CarCategories", "Classes") {
				case "All":
					categories := ["Class", "Cup"]
				case "Classes":
					categories := ["Class"]
				case "Cups":
					categories := ["Cup"]
				default:
					categories := ["Class"]
			}

			this.RemoteHandler.reviewRace(values2String("|", categories*))
		}
		else
			this.finishSession(shutdown, false)
	}

	shutdownSession(phase) {
		this.iSessionDataActive := true

		try {
			if (((phase = "After") && (this.SaveSettings = kAsk)) || ((phase = "Before") && (this.SaveSettings = kAlways)))
				if (this.Session == kSessionRace)
					this.saveSessionSettings()

			if (((phase = "After") && (this.SaveRaceReport = kAsk)) || ((phase = "Before") && (this.SaveRaceReport = kAlways)))
				if (this.Session == kSessionRace)
					this.createRaceReport()

			if (((phase = "After") && (this.SaveTelemetry = kAsk)) || ((phase = "Before") && (this.SaveTelemetry = kAlways)))
				if (this.HasTelemetryData && this.collectTelemetryData())
					this.updateTelemetryDatabase()
		}
		finally {
			this.iSessionDataActive := false
		}

		if (phase = "After") {
			if this.Speaker
				this.getSpeaker().speakPhrase("RaceReportSaved")

			this.updateDynamicValues({KnowledgeBase: false, HasTelemetryData: false})

			this.finishSession()
		}
	}

	adjustGaps(data, &gapAhead := false, &gapBehind := false) {
		local knowledgeBase := this.KnowledgeBase

		static adjustGaps := true
		static lastGapAhead := kUndefined
		static lastGapBehind := kUndefined
		static sameGapCount := 0

		gapAhead := getMultiMapValue(data, "Stint Data", "GapAhead", kUndefined)
		gapBehind := getMultiMapValue(data, "Stint Data", "GapBehind", kUndefined)

		if ((gapAhead = lastGapAhead) && (gapBehind = lastGapBehind)) {
			if (adjustGaps && (sameGapCount++ > 3))
				adjustGaps := false
		}
		else {
			adjustGaps := true
			sameGapCount := 0

			lastGapAhead := gapAhead
			lastGapBehind := gapBehind
		}

		if (adjustGaps && (gapAhead != kUndefined) && (gapBehind != kUndefined)) {
			if gapAhead {
				knowledgeBase.setFact("Position.Standings.Class.Ahead.Delta", gapAhead)

				if (knowledgeBase.getValue("Position.Track.Ahead.Car", -1) = knowledgeBase.getValue("Position.Standings.Class.Ahead.Car", 0))
					knowledgeBase.setFact("Position.Track.Ahead.Delta", gapAhead)
			}

			if gapBehind {
				knowledgeBase.setFact("Position.Standings.Class.Behind.Delta", gapBehind)

				if (knowledgeBase.getValue("Position.Track.Behind.Car", -1) = knowledgeBase.getValue("Position.Standings.Class.Behind.Car", 0))
					knowledgeBase.setFact("Position.Track.Behind.Delta", gapBehind)
			}

			return (gapAhead || gapBehind)
		}
		else
			return false
	}

	createSessionInfo(lapNumber, valid, data, simulator, car, track) {
		local knowledgeBase := this.KnowledgeBase
		local sessionInfo := newMultiMap()
		local nextPitstop, position, classPosition, tyreWear, brakeWear, brakeTemperatures

		static sessionTypes := Map(kSessionPractice, "Practice", kSessionQualification, "Qualification", kSessionRace, "Race", kSessionOther, "Other")

		setMultiMapValue(sessionInfo, "Session", "Simulator", this.SettingsDatabase.getSimulatorName(simulator))
		setMultiMapValue(sessionInfo, "Session", "Car", this.SettingsDatabase.getCarName(simulator, car))
		setMultiMapValue(sessionInfo, "Session", "Track", this.SettingsDatabase.getTrackName(simulator, track))
		setMultiMapValue(sessionInfo, "Session", "Type", sessionTypes[this.Session])
		setMultiMapValue(sessionInfo, "Session", "Format", knowledgeBase.getValue("Session.Format", "Time"))
		setMultiMapValue(sessionInfo, "Session", "Laps", lapNumber)
		setMultiMapValue(sessionInfo, "Session", "Laps.Remaining", Ceil(knowledgeBase.getValue("Lap.Remaining.Session", 0)))
		setMultiMapValue(sessionInfo, "Session", "Time.Remaining", Round(getMultiMapValue(data, "Session Data", "SessionTimeRemaining", 0) / 1000))

		setMultiMapValue(sessionInfo, "Stint", "Driver", computeDriverName(getMultiMapValue(data, "Stint Data", "DriverForname", this.DriverForName)
																		 , getMultiMapValue(data, "Stint Data", "DriverSurname", "Doe")
																		 , getMultiMapValue(data, "Stint Data", "DriverNickname", "JDO")))
		setMultiMapValue(sessionInfo, "Stint", "Lap", lapNumber)
		setMultiMapValue(sessionInfo, "Stint", "Position", knowledgeBase.getValue("Position", 0))
		setMultiMapValue(sessionInfo, "Stint", "Valid", valid)
		setMultiMapValue(sessionInfo, "Stint", "Fuel.AvgConsumption", Round(knowledgeBase.getValue("Lap." . lapNumber . ".Fuel.AvgConsumption", 0), 1))
		setMultiMapValue(sessionInfo, "Stint", "Fuel.Consumption", Round(knowledgeBase.getValue("Lap." . lapNumber . ".Fuel.Consumption", 0), 1))
		setMultiMapValue(sessionInfo, "Stint", "Fuel.Remaining", Round(getMultiMapValue(data, "Car Data", "FuelRemaining", 0), 1))
		setMultiMapValue(sessionInfo, "Stint", "Laps", lapNumber - this.BaseLap + 1)
		setMultiMapValue(sessionInfo, "Stint", "Laps.Remaining.Fuel", Floor(knowledgeBase.getValue("Lap.Remaining.Fuel", 0)))
		setMultiMapValue(sessionInfo, "Stint", "Laps.Remaining.Stint", Floor(knowledgeBase.getValue("Lap.Remaining.Stint", 0)))
		setMultiMapValue(sessionInfo, "Stint", "Time.Remaining.Stint", Round(getMultiMapValue(data, "Stint Data", "StintTimeRemaining") / 1000))
		setMultiMapValue(sessionInfo, "Stint", "Time.Remaining.Driver", Round(getMultiMapValue(data, "Stint Data", "DriverTimeRemaining") / 1000))
		setMultiMapValue(sessionInfo, "Stint", "Lap.Time.Last", Round(getMultiMapValue(data, "Stint Data", "LapLastTime", 0) / 1000, 1))
		setMultiMapValue(sessionInfo, "Stint", "Lap.Time.Best", Round(getMultiMapValue(data, "Stint Data", "LapBestTime", 0) / 1000, 1))

		setMultiMapValue(sessionInfo, "Weather", "Now", getMultiMapValue(data, "Weather Data", "Weather", "Dry"))
		setMultiMapValue(sessionInfo, "Weather", "10Min", getMultiMapValue(data, "Weather Data", "Weather10Min", "Dry"))
		setMultiMapValue(sessionInfo, "Weather", "30Min", getMultiMapValue(data, "Weather Data", "Weather30Min", "Dry"))
		setMultiMapValue(sessionInfo, "Weather", "Temperature", Round(getMultiMapValue(data, "Weather Data", "Temperature", 0), 1))

		setMultiMapValue(sessionInfo, "Track", "Temperature", Round(getMultiMapValue(data, "Track Data", "Temperature", 0), 1))
		setMultiMapValue(sessionInfo, "Track", "Grip", getMultiMapValue(data, "Track Data", "Grip", "Optimum"))

		setMultiMapValue(sessionInfo, "Tyres", "Pressures", getMultiMapValue(data, "Car Data", "TyrePressure", ""))
		setMultiMapValue(sessionInfo, "Tyres", "Temperatures", getMultiMapValue(data, "Car Data", "TyreTemperature", ""))

		tyreWear := getMultiMapValue(data, "Car Data", "TyreWear", "")

		if (tyreWear != "") {
			tyreWear := string2Values(",", tyreWear)

			setMultiMapValue(sessionInfo, "Tyres", "Wear", values2String(",", Round(tyreWear[1]), Round(tyreWear[2]), Round(tyreWear[3]), Round(tyreWear[4])))
		}

		setMultiMapValue(sessionInfo, "Brakes", "Temperatures", getMultiMapValue(data, "Car Data", "BrakeTemperature", ""))

		brakeWear := getMultiMapValue(data, "Car Data", "BrakeWear", "")

		if (brakeWear != "") {
			brakeWear := string2Values(",", brakeWear)

			setMultiMapValue(sessionInfo, "Brakes", "Wear", values2String(",", Round(brakeWear[1]), Round(brakeWear[2]), Round(brakeWear[3]), Round(brakeWear[4])))
		}

		if knowledgeBase.getValue("Strategy.Name", false) {
			setMultiMapValue(sessionInfo, "Strategy", "Pitstops", knowledgeBase.getValue("Strategy.Pitstop.Count"))

			nextPitstop := knowledgeBase.getValue("Strategy.Pitstop.Next", false)

			if nextPitstop {
				setMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next", nextPitstop)

				setMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Lap", knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Lap") + 1)
				setMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Refuel", Round(knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Fuel.Amount")))

				if knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Change", false) {
					setMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Tyre.Compound", knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Compound"))
					setMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Tyre.Compound", knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Compound.Color"))
				}
				else {
					setMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Tyre.Compound", false)
					setMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Tyre.Compound", false)
				}
			}
		}

		position := this.getPosition()
		classPosition := (this.MultiClass ? this.getPosition(false, "Class") : position)

		setMultiMapValue(sessionInfo, "Standings", "Position.Overall", position)
		setMultiMapValue(sessionInfo, "Standings", "Position.Class", classPosition)

		if (classPosition != 1) {
			car := knowledgeBase.getValue("Position.Standings.Class.Leader.Car", 0)

			if car {
				setMultiMapValue(sessionInfo, "Standings", "Leader.Lap.Time", Round(knowledgeBase.getValue("Car." . car . ".Time", 0) / 1000, 1))
				setMultiMapValue(sessionInfo, "Standings", "Leader.Lap", knowledgeBase.getValue("Car." . car . ".Lap", 0))
				setMultiMapValue(sessionInfo, "Standings", "Leader.Delta", Round(knowledgeBase.getValue("Position.Standings.Class.Leader.Delta", 0) / 1000, 1))
				setMultiMapValue(sessionInfo, "Standings", "Leader.InPit", (knowledgeBase.getValue("Car." . car . ".InPitLane", false)
																		 || knowledgeBase.getValue("Car." . car . ".InPit", false)))
			}

			car := knowledgeBase.getValue("Position.Standings.Class.Ahead.Car", false)

			if car {
				setMultiMapValue(sessionInfo, "Standings", "Ahead.Lap.Time", Round(knowledgeBase.getValue("Car." . car . ".Time", 0) / 1000, 1))
				setMultiMapValue(sessionInfo, "Standings", "Ahead.Lap", knowledgeBase.getValue("Car." . car . ".Lap", 0))
				setMultiMapValue(sessionInfo, "Standings", "Ahead.Delta", Round(knowledgeBase.getValue("Position.Standings.Class.Ahead.Delta", 0) / 1000, 1))
				setMultiMapValue(sessionInfo, "Standings", "Ahead.InPit", (knowledgeBase.getValue("Car." . car . ".InPitLane", false)
																		|| knowledgeBase.getValue("Car." . car . ".InPit", false)))
			}
		}

		if (this.getPosition(false, "Class") != this.getCars("Class").Length) {
			car := knowledgeBase.getValue("Position.Standings.Class.Behind.Car")

			if car {
				setMultiMapValue(sessionInfo, "Standings", "Behind.Lap.Time", Round(knowledgeBase.getValue("Car." . car . ".Time", 0) / 1000, 1))
				setMultiMapValue(sessionInfo, "Standings", "Behind.Lap", knowledgeBase.getValue("Car." . car . ".Lap", 0))
				setMultiMapValue(sessionInfo, "Standings", "Behind.Delta", Round(knowledgeBase.getValue("Position.Standings.Class.Behind.Delta", 0) / 1000, 1))
				setMultiMapValue(sessionInfo, "Standings", "Behind.InPit", (knowledgeBase.getValue("Car." . car . ".InPitLane", false)
																		 || knowledgeBase.getValue("Car." . car . ".InPit", false)))
			}
		}

		this.saveSessionInfo(lapNumber, simulator, car, track, sessionInfo)
	}

	addLap(lapNumber, &data) {
		local knowledgeBase := this.KnowledgeBase
		local driverForname := ""
		local driverSurname := ""
		local driverNickname := ""
		local compound, result, lap, simulator, car, track, frequency, curContinuation
		local pitstop, prefix, validLap, weather, airTemperature, trackTemperature, compound, compoundColor
		local fuelConsumption, fuelRemaining, lapTime, map, tc, antiBS, pressures, temperatures, wear, multiClass
		local sessionInfo, driverCar, lastTime

		static lastLap := 0

		if (lapNumber <= lastLap) {
			lastLap := 0
			this.iLastStrategyUpdate := lapNumber
		}
		else if ((lastLap == 0) && (lapNumber > 1)) {
			lastLap := (lapNumber - 1)
			this.iLastStrategyUpdate := lapNumber
		}
		else if (lastLap < (lapNumber - 1))
			this.iLastStrategyUpdate := lapNumber

		if (this.Speaker && (lapNumber > 1)) {
			driverForname := knowledgeBase.getValue("Driver.Forname", "John")
			driverSurname := knowledgeBase.getValue("Driver.Surname", "Doe")
			driverNickname := knowledgeBase.getValue("Driver.Nickname", "JDO")
		}

		curContinuation := this.Continuation

		result := super.addLap(lapNumber, &data)

		if (this.Speaker && (lastLap < (lapNumber - 2))
		 && (computeDriverName(driverForname, driverSurname, driverNickname) != this.DriverFullName))
			this.getSpeaker().speakPhrase(ProcessExist("Race Engineer.exe") ? "" : "WelcomeBack")

		lastLap := lapNumber

		if this.Strategy {
			lastTime := (getMultiMapValue(data, "Stint Data", "LapLastTime", 0) / 1000)

			this.Strategy.RunningLaps += 1
			this.Strategy.RunningTime += lastTime

			if this.Strategy["Rejected"] {
				this.Strategy["Rejected"].RunningLaps += 1
				this.Strategy["Rejected"].RunningTime += lastTime
			}

			if (!this.StrategyReported && this.hasEnoughData(false) && (this.Strategy == this.Strategy[true])) {
				if this.Speaker[false] {
					this.getSpeaker().speakPhrase("ConfirmReportStrategy", false, true)

					this.setContinuation(ObjBindMethod(this, "reportStrategy"))
				}

				this.updateDynamicValues({StrategyReported: lapNumber})
			}
		}

		if !this.MultiClass
			this.adjustGaps(data)

		driverCar := knowledgeBase.getValue("Driver.Car", 0)
		validLap := true

		loop knowledgeBase.getValue("Car.Count") {
			lap := knowledgeBase.getValue("Car." . A_Index . ".Lap", 0)

			if (lap != knowledgeBase.getValue("Car." . A_Index . ".Valid.LastLap", 0)) {
				knowledgeBase.setFact("Car." . A_Index . ".Valid.LastLap", lap)

				if (knowledgeBase.getValue("Car." . A_Index . ".Lap.Valid", kUndefined) == kUndefined)
					knowledgeBase.addFact("Car." . A_Index . ".Lap.Valid", knowledgeBase.getValue("Car." . A_Index . ".Valid.Running", true))

				if knowledgeBase.getValue("Car." . A_Index . ".Lap.Valid", true)
					knowledgeBase.setFact("Car." . A_Index . ".Valid.Laps", knowledgeBase.getValue("Car." . A_Index . ".Valid.Laps", 0) + 1)

				if (A_Index = driverCar)
					validLap := knowledgeBase.getValue("Car." . A_Index . ".Lap.Valid")
			}
		}

		simulator := knowledgeBase.getValue("Session.Simulator")
		car := knowledgeBase.getValue("Session.Car")
		track := knowledgeBase.getValue("Session.Track")

		pitstop := knowledgeBase.getValue("Pitstop.Last", false)

		if pitstop
			pitstop := (Abs(lapNumber - knowledgeBase.getValue("Pitstop." . pitstop . ".Lap")) <= 2)

		if ((this.hasEnoughData(false) || pitstop) && this.collectTelemetryData()) {
			prefix := "Lap." . lapNumber

			validLap := knowledgeBase.getValue(prefix . ".Valid", true)

			if (validLap || pitstop) {
				weather := knowledgeBase.getValue(prefix . ".Weather")
				airTemperature := knowledgeBase.getValue(prefix . ".Temperature.Air")
				trackTemperature := knowledgeBase.getValue(prefix . ".Temperature.Track")
				compound := knowledgeBase.getValue(prefix . ".Tyre.Compound")
				compoundColor := knowledgeBase.getValue(prefix . ".Tyre.Compound.Color")
				fuelConsumption := Round(knowledgeBase.getValue(prefix . ".Fuel.Consumption"), 1)
				fuelRemaining := Round(knowledgeBase.getValue(prefix . ".Fuel.Remaining"), 1)
				lapTime := Round(knowledgeBase.getValue(prefix . ".Time") / 1000, 1)

				map := knowledgeBase.getValue(prefix . ".Map")
				tc := knowledgeBase.getValue(prefix . ".TC")
				antiBS := knowledgeBase.getValue(prefix . ".ABS")

				pressures := [Round(knowledgeBase.getValue(prefix . ".Tyre.Pressure.FL"), 1)
							, Round(knowledgeBase.getValue(prefix . ".Tyre.Pressure.FR"), 1)
						    , Round(knowledgeBase.getValue(prefix . ".Tyre.Pressure.RL"), 1)
						    , Round(knowledgeBase.getValue(prefix . ".Tyre.Pressure.RR"), 1)]

				temperatures := [Round(knowledgeBase.getValue(prefix . ".Tyre.Temperature.FL"), 1)
							   , Round(knowledgeBase.getValue(prefix . ".Tyre.Temperature.FR"), 1)
							   , Round(knowledgeBase.getValue(prefix . ".Tyre.Temperature.RL"), 1)
							   , Round(knowledgeBase.getValue(prefix . ".Tyre.Temperature.RR"), 1)]

				wear := false

				if (knowledgeBase.getValue(prefix . ".Tyre.Wear.FL", kUndefined) != kUndefined)
					wear := [Round(knowledgeBase.getValue(prefix . ".Tyre.Wear.FL"))
						   , Round(knowledgeBase.getValue(prefix . ".Tyre.Wear.FR"))
						   , Round(knowledgeBase.getValue(prefix . ".Tyre.Wear.RL"))
						   , Round(knowledgeBase.getValue(prefix . ".Tyre.Wear.RR"))]

				this.saveTelemetryData(lapNumber, simulator, car, track, weather, airTemperature, trackTemperature
									 , fuelConsumption, fuelRemaining, lapTime, pitstop, map, tc, antiBS
									 , compound, compoundColor, pressures, temperatures, wear)
			}
		}

		if this.Strategy {
			frequency := getMultiMapValue(this.Settings, "Strategy Settings", "Strategy.Update.Laps", false)

			if (frequency && this.hasEnoughData(false)
						  && (lapNumber >= this.BaseLap + knowledgeBase.getValue("Session.Settings.Lap.History.Considered", 5))) {
				if ((lapNumber > (this.iLastStrategyUpdate + frequency)) && (curContinuation = this.Continuation))
					knowledgeBase.setFact("Strategy.Recalculate", "Regular")
			}
			else
				this.iLastStrategyUpdate := (lapNumber - 1)
		}

		this.saveStandingsData(lapNumber, simulator, car, track)

		Task.startTask(ObjBindMethod(this, "createSessionInfo", lapNumber, validLap, data, simulator, car, track), 1000, kLowPriority)

		return result
	}

	updateLap(lapNumber, &data) {
		local knowledgeBase := this.KnowledgeBase
		local updateStrategy := false
		local sector, result, valid

		static lastSector := 1

		if !isObject(data)
			data := readMultiMap(data)

		sector := getMultiMapValue(data, "Stint Data", "Sector", 0)

		if (sector != lastSector) {
			lastSector := sector

			knowledgeBase.addFact("Sector", sector)

			updateStrategy := knowledgeBase.getValue("Strategy.Recalculate", false)
		}

		result := super.updateLap(lapNumber, &data)

		loop knowledgeBase.getValue("Car.Count") {
			valid := knowledgeBase.getValue("Car." . A_Index . ".Lap.Running.Valid", kUndefined)

			if (valid != kUndefined)
				knowledgeBase.setFact("Car." . A_Index . ".Valid.Running", valid)
		}

		if !this.MultiClass
			this.adjustGaps(data)

		if (updateStrategy && this.hasEnoughData(false))
			this.recommendStrategy({Silent: true, Confirm: true, Request: updateStrategy})

		Task.startTask(ObjBindMethod(this, "createSessionInfo", lapNumber, knowledgeBase.getValue("Lap." . lapNumber . ".Valid", true), data
															  , knowledgeBase.getValue("Session.Simulator")
															  , knowledgeBase.getValue("Session.Car")
															  , knowledgeBase.getValue("Session.Track")), 1000, kLowPriority)

		return result
	}

	requestInformation(category, arguments*) {
		this.clearContinuation()

		switch category, false {
			case "Time":
				this.timeRecognized([])
			case "LapsRemaining":
				this.lapsRemainingRecognized([])
			case "Weather":
				this.weatherRecognized([])
			case "Position":
				this.positionRecognized([])
			case "LapTimes":
				this.lapTimesRecognized([])
			case "ActiveCars":
				this.activeCarsRecognized([])
			case "GapToAheadStandings", "GapToFrontStandings":
				this.gapToAheadRecognized([])
			case "GapToAheadTrack", "GapToFrontTrack":
				this.gapToAheadRecognized(Array(this.getSpeaker().Fragments["Car"]))
			case "GapToAhead", "GapToAhead":
				this.gapToAheadRecognized(inList(arguments, "Track") ? Array(this.getSpeaker().Fragments["Car"]) : [])
			case "GapToBehindStandings":
				this.gapToBehindRecognized([])
			case "GapToBehindTrack":
				this.gapToBehindRecognized(Array(this.getSpeaker().Fragments["Car"]))
			case "GapToBehind":
				this.gapToBehindRecognized(inList(arguments, "Track") ? Array(this.getSpeaker().Fragments["Car"]) : [])
			case "GapToLeader":
				this.gapToLeaderRecognized([])
			case "StrategyOverview":
				this.strategyOverviewRecognized([])
			case "NextPitstop":
				this.nextPitstopRecognized([])
		}
	}

	reportStrategy(options := true, strategy := false) {
		local knowledgeBase := this.KnowledgeBase
		local reported := false
		local activeStrategy, activePitstop, strategyName, nextPitstop, lap, refuel, tyreChange, map
		local speaker, fragments

		if this.Speaker {
			speaker := this.getSpeaker()

			if strategy {
				speaker.beginTalk()

				try {
					fragments := speaker.Fragments
					activeStrategy := (isObject(options) && options.HasProp("Active") && options.Active)

					if ((options == true) || (options.HasProp("Strategy") && options.Strategy))
						speaker.speakPhrase("Strategy")

					if ((options == true) || (options.HasProp("Pitstops") && options.Pitstops)) {
						speaker.speakPhrase("Pitstops", {pitstops: strategy.Pitstops.Length})

						if activeStrategy {
							difference := (strategy.Pitstops.Length - (activeStrategy.Pitstops.Length - activeStrategy.RunningPitstops))

							if (difference != 0)
								speaker.speakPhrase("PitstopsDifference", {difference: Abs(difference), pitstops: strategy.Pitstops.Length - difference
																		 , direction: (difference < 0) ? fragments["Less"] : fragments["More"]})
						}

						reported := true
					}

					nextPitstop := ((strategy.Pitstops.Length > 0) ? strategy.Pitstops[1] : false)

					if nextPitstop {
						if ((options == true) || (options.HasProp("NextPitstop") && options.NextPitstop)) {
							activePitstop := false
							lap := nextPitstop.Lap
							refuel := Round(nextPitstop.RefuelAmount)
							tyreChange := nextPitstop.TyreChange

							if (activeStrategy && ((activeStrategy.Pitstops.Length - activeStrategy.RunningPitstops) > 0))
								activePitstop := activeStrategy.Pitstops[strategy.RunningPitstops + 1]

							speaker.speakPhrase("NextPitstop", {pitstopLap: (lap + 1)})

							if activePitstop {
								difference := (lap - activePitstop.Lap)

								if (difference != 0)
									speaker.speakPhrase("LapsDifference", {difference: Abs(difference), lap: activePitstop.Lap + 1
																		 , label: (Abs(difference) = 1) ? fragments["Lap"] : fragments["Laps"]
																		 , direction: (difference < 0) ? fragments["Earlier"] : fragments["Later"]})
							}

							if ((options == true) || (options.HasProp("Refuel") && options.Refuel)) {
								speaker.speakPhrase((refuel > 0) ? "Refuel" : "NoRefuel"
												  , {fuel: displayValue("Float", convertUnit("Volume", refuel)), unit: speaker.Fragments[getUnit("Volume")]})

								if activePitstop {
									difference := (refuel - Round(activePitstop.RefuelAmount))

									if (difference != 0)
										speaker.speakPhrase("RefuelDifference", {difference: Abs(difference), refuel: Round(activePitstop.RefuelAmount)
																			   , unit: fragments[getUnit("Volume")]
																			   , direction: (difference < 0) ? fragments["Less"] : fragments["More"]})
								}
							}

							if ((options == true) || (options.HasProp("TyreChange") && options.TyreChange)) {
								speaker.speakPhrase(tyreChange ? "TyreChange" : "NoTyreChange")

								if activePitstop
									if (nextPitstop.TyreChange && !activePitstop.TyreChange)
										speaker.speakPhrase("TyreChangeDifference")
									else if (!nextPitstop.TyreChange && activePitstop.TyreChange)
										speaker.speakPhrase("NoTyreChangeDifference")
									else if (nextPitstop.TyreChange
										  && ((nextPitstop.TyreCompound != activePitstop.TyreCompound)
										   || (nextPitstop.TyreCompoundColor != activePitstop.TyreCompoundColor)))
										speaker.speakPhrase("TyreCompoundDifference")
							}
						}
					}
					else if ((options == true) || (options.HasProp("NextPitstop") && options.NextPitstop))
						if !reported
							speaker.speakPhrase("NoNextPitstop")

					if ((options == true) || (options.HasProp("Map") && options.Map)) {
						map := strategy.Map

						if ((map != "n/a") && (map != knowledgeBase.getValue("Lap." . knowledgeBase.getValue("Lap") . ".Map", "n/a")))
							speaker.speakPhrase("StrategyMap", {map: map})
					}
				}
				finally {
					speaker.endTalk()
				}
			}
			else {
				strategyName := knowledgeBase.getValue("Strategy.Name", false)

				if strategyName {
					speaker.beginTalk()

					try {
						if ((options == true) || (options.HasProp("Strategy") && options.Strategy))
							speaker.speakPhrase("Strategy")

						if ((options == true) || (options.HasProp("Pitstops") && options.Pitstops)) {
							speaker.speakPhrase("Pitstops", {pitstops: knowledgeBase.getValue("Strategy.Pitstop.Count")})

							reported := true
						}

						nextPitstop := knowledgeBase.getValue("Strategy.Pitstop.Next", false)

						if nextPitstop {
							if ((options == true) || (options.HasProp("NextPitstop") && options.NextPitstop)) {
								lap := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Lap")
								refuel := Round(knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Fuel.Amount"))
								tyreChange := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Change")

								speaker.speakPhrase("NextPitstop", {pitstopLap: (lap + 1)})

								if ((options == true) || (options.HasProp("Refuel") && options.Refuel))
									speaker.speakPhrase((refuel > 0) ? "Refuel" : "NoRefuel"
													  , {fuel: displayValue("Float", convertUnit("Volume", refuel)), unit: speaker.Fragments[getUnit("Volume")]})

								if ((options == true) || (options.HasProp("TyreChange") && options.TyreChange))
									speaker.speakPhrase(tyreChange ? "TyreChange" : "NoTyreChange")
							}
						}
						else if ((options == true) || (options.HasProp("NextPitstop") && options.NextPitstop))
							if !reported
								speaker.speakPhrase("NoNextPitstop")

						if ((options == true) || (options.HasProp("Map") && options.Map)) {
							map := knowledgeBase.getValue("Strategy.Map")

							if ((map != "n/a") && (map != knowledgeBase.getValue("Lap." . knowledgeBase.getValue("Lap") . ".Map", "n/a")))
								speaker.speakPhrase("StrategyMap", {map: map})
						}
					}
					finally {
						speaker.endTalk()
					}
				}
				else
					speaker.speakPhrase("NoStrategy")

				this.updateDynamicValues({StrategyReported: knowledgeBase.getValue("Lap")})
			}
		}
	}

	cancelStrategy(confirm := true, report := true, remote := true) {
		local knowledgeBase := this.KnowledgeBase
		local hasStrategy := knowledgeBase.getValue("Strategy.Name", false)

		if (this.Speaker && confirm) {
			if hasStrategy {
				this.getSpeaker().speakPhrase("ConfirmCancelStrategy", false, true)

				this.setContinuation(ObjBindMethod(this, "cancelStrategy", false, report, remote))
			}
			else
				this.getSpeaker().speakPhrase("NoStrategy")

			return
		}

		if hasStrategy {
			this.clearStrategy()

			if remote {
				if isDebug()
					deleteFile(kTempDirectory . "Race Strategist.strategy")

				if this.RemoteHandler
					this.RemoteHandler.updateStrategy(false, A_Now)
			}

			if (this.Speaker && report)
				this.getSpeaker().speakPhrase("StrategyCanceled")

			this.updateSessionValues({OriginalStrategy: false, Strategy: false})
			this.updateDynamicValues({RejectedStrategy: false})
		}
	}

	clearStrategy() {
		local knowledgeBase := this.KnowledgeBase
		local ignore, pitstop, theFact

		for ignore, theFact in ["Name", "Weather", "Weather.Temperature.Air", "Weather.Temperature.Track"
							  , "Tyre.Compound", "Tyre.Compound.Color", "Map", "TC", "ABS"
							  , "Pitstop.Count", "Pitstop.Next", "Pitstop.Lap", "Pitstop.Lap.Warning"]
			knowledgeBase.clearFact("Strategy." . theFact)

		loop knowledgeBase.getValue("Strategy.Pitstop.Count", 0) {
			pitstop := A_Index

			for ignore, theFact in [".Lap", ".Fuel.Amount", ".Tyre.Change", ".Tyre.Compound", ".Tyre.Compound.Color", ".Map"]
				knowledgeBase.clearFact("Strategy.Pitstop." . pitstop . theFact)
		}

		knowledgeBase.clearFact("Strategy.Pitstop.Count")
		knowledgeBase.clearFact("Strategy.Pitstop.Deviation")

		this.iStrategy := false
	}

	recommendStrategy(options := {}) {
		local knowledgeBase := this.KnowledgeBase
		local request := (options.HasProp("Request") ? options.Request : "User")
		local engineerPID

		this.clearContinuation()

		if !this.hasEnoughData()
			return

		knowledgeBase.clearFact("Strategy.Recalculate")

		this.iLastStrategyUpdate := (knowledgeBase.getValue("Lap") + 1)

		if this.Strategy {
			engineerPID := ProcessExist("Race Engineer.exe")

			if engineerPID
				messageSend(kFileMessage, "Race Engineer", "requestPitstopHistory:Race Strategist;runSimulation;"
														 . values2String(";", ProcessExist(), options.HasProp("Confirm") && options.Confirm, request)
										, engineerPID)
			else if (this.Speaker && (!options.HasProp("Silent") || !options.Silent))
				this.getSpeaker().speakPhrase("NoStrategyRecommendation")
		}
		else if (this.Speaker && (!options.HasProp("Silent") || !options.Silent))
			this.getSpeaker().speakPhrase("NoStrategy")
	}

	updateStrategy(newStrategy, original := true, report := true, version := false, origin := "Assistant", remote := true) {
		local knowledgeBase := this.KnowledgeBase
		local fact, value, fileName, configuration

		if version
			if (this.Strategy && (this.Strategy.Version = version))
				return
			else if (this.Strategy[true] && (this.Strategy[true].Version = version))
				return

		if newStrategy {
			if (this.Session == kSessionRace) {
				if !isObject(newStrategy)
					newStrategy := Strategy(this, readMultiMap(newStrategy))

				this.clearStrategy()

				for fact, value in this.loadStrategy(CaseInsenseMap(), newStrategy, knowledgeBase.getValue("Pitstop.Last", false))
					knowledgeBase.setFact(fact, value)

				this.dumpKnowledgeBase(knowledgeBase)

				if original
					this.updateSessionValues({OriginalStrategy: newStrategy, Strategy: newStrategy})
				else
					this.updateSessionValues({Strategy: newStrategy})

				if report
					this.reportStrategy({Strategy: true, Pitstops: false, NextPitstop: true, TyreChange: true, Refuel: true, Map: true})

				if (remote && this.RemoteHandler) {
					fileName := temporaryFileName("Race Strategy", "update")
					configuration := newMultiMap()

					newStrategy.saveToConfiguration(configuration)

					writeMultiMap(fileName, configuration)

					if isDebug()
						try {
							FileCopy(fileName, kTempDirectory . "Race Strategist.strategy", 1)
						}
						catch Any as exception {
							logError(exception)
						}

					this.RemoteHandler.updateStrategy(fileName, newStrategy.Version)
				}
				else if isDebug() {
					configuration := newMultiMap()

					newStrategy.saveToConfiguration(configuration)

					writeMultiMap(kTempDirectory . "Race Strategist.strategy", configuration)
				}
			}
		}
		else
			this.cancelStrategy(false, report, remote)

		this.updateDynamicValues({StrategyReported: true, RejectedStrategy: false})
	}

	runSimulation(pitstopHistory, confirm := false, request := "User") {
		local knowledgeBase := this.KnowledgeBase
		local data, lap

		if !isObject(pitstopHistory) {
			data := readMultiMap(pitstopHistory)

			if !isDebug()
				deleteFile(pitstopHistory)
		}

		if (this.UseTraffic && this.RemoteHandler) {
			this.setContinuation(RaceStrategist.RaceStrategySimulationContinuation(this, data, confirm, request))

			lap := knowledgeBase.getValue("Lap")

			this.RemoteHandler.computeCarStatistics(Max(1, lap - 10), lap)
		}
		else
			RaceStrategist.RaceStrategySimulationTask(this, data, confirm, request).start()
	}

	createStrategy(nameOrConfiguration, driver := false) {
		local name := nameOrConfiguration
		local theStrategy

		if !isObject(nameOrConfiguration)
			nameOrConfiguration := false

		theStrategy := (this.UseTraffic ? RaceStrategist.TrafficRaceStrategy(this, nameOrConfiguration, driver)
										: RaceStrategist.RaceStrategy(this, nameOrConfiguration, driver))

		if (name && !isObject(name))
			theStrategy.setName(name)

		return theStrategy
	}

	getStintDriver(stintNumber, &driverID, &driverName) {
		local strategy := this.Strategy[true]
		local sessionDB, numPitstops, index

		if strategy {
			if (stintNumber == 1) {
				driverID := strategy.Driver
				driverName := strategy.DriverName

				return true
			}
			else {
				numPitstops := strategy.Pitstops.Length
				index := (stintNumber - 1)

				if (index <= numPitstops) {
					driverID := strategy.Pitstops[index].Driver
					driverName := strategy.Pitstops[index].DriverName

					return true
				}
			}
		}

		sessionDB := SessionDatabase()

		driverID := sessionDB.ID

		sessionDB.getDriverName(this.Simulator, driverID)

		return true
	}

	getStrategySettings(&simulator, &car, &track, &weather, &airTemperature, &trackTemperature
					  , &sessionType, &sessionLength
					  , &maxTyreLaps, &tyreCompound, &tyreCompoundColor, &tyrePressures) {
		local knowledgeBase := this.KnowledgeBase
		local strategy := this.Strategy[true]
		local lap := Task.CurrentTask.Lap
		local availableTyreSets, strategyTask, telemetryDB, candidate

		if strategy {
			simulator := strategy.Simulator
			car := strategy.Car
			track := strategy.Track

			weather := knowledgeBase.getValue("Weather.Weather.10Min", false)

			if weather {
				airTemperature := Round(knowledgeBase.getValue("Weather.Temperature.Air"))
				trackTemperature := Round(knowledgeBase.getValue("Weather.Temperature.Track"))
			}
			else {
				weather := strategy.Weather
				airTemperature := strategy.AirTemperature
				trackTemperature := strategy.TrackTemperature
			}

			tyreCompound := knowledgeBase.getValue("Lap." . lap . ".Tyre.Compound", false)
			tyreCompoundColor := knowledgeBase.getValue("Lap." . lap . ".Tyre.Compound.Color", false)

			if !tyreCompound {
				tyreCompound := strategy.TyreCompound
				tyreCompoundColor := strategy.TyreCompoundColor
			}

			weather := knowledgeBase.getValue("Weather.Weather.10Min", strategy.Weather)
			strategyTask := Task.CurrentTask
			telemetryDB := strategyTask.TelemetryDatabase

			if !telemetryDB.suitableTyreCompound(simulator, car, track, weather, compound(tyreCompound, tyreCompoundColor)) {
				candidate := telemetryDB.optimalTyreCompound(simulator, car, track, weather, airTemperature, trackTemperature
														   , getKeys(this.computeAvailableTyreSets(strategy.AvailableTyreSets, strategyTask.UsedTyreSets)))

				if candidate
					splitCompound(candidate, &tyreCompound, &tyreCompoundColor)
			}

			sessionType := strategy.SessionType
			sessionLength := strategy.SessionLength
			maxTyreLaps := strategy.MaxTyreLaps
			tyrePressures := strategy.TyrePressures

			return true
		}
		else
			return false
	}

	getSessionSettings(&stintLength, &formationLap, &postRaceLap, &fuelCapacity, &safetyFuel
					 , &pitstopDelta, &pitstopFuelService, &pitstopTyreService, &pitstopServiceOrder) {
		local strategy := this.Strategy[true]

		if strategy {
			stintLength := strategy.StintLength
			formationLap := strategy.FormationLap
			postRaceLap := strategy.PostRaceLap

			fuelCapacity := strategy.FuelCapacity
			safetyFuel := strategy.SafetyFuel

			pitstopDelta := strategy.PitstopDelta
			pitstopFuelService := strategy.PitstopFuelService
			pitstopTyreService := strategy.PitstopTyreService
			pitstopServiceOrder := strategy.PitstopServiceOrder

			return true
		}
		else
			return false
	}

	getSessionWeather(minute, &weather, &airTemperature, &trackTemperature) {
		local knowledgeBase := this.KnowledgeBase
		local strategy := this.Strategy[true]

		if strategy {
			weather := knowledgeBase.getValue("Weather.Weather.10Min", false)

			if weather {
				airTemperature := Round(knowledgeBase.getValue("Weather.Temperature.Air"))
				trackTemperature := Round(knowledgeBase.getValue("Weather.Temperature.Track"))
			}
			else {
				weather := strategy.Weather
				airTemperature := strategy.AirTemperature
				trackTemperature := strategy.TrackTemperature
			}

			return true
		}
		else
			return false
	}

	getTrafficSettings(&randomFactor, &numScenarios, &variationWindow
					 , &useLapTimeVariation, &useDriverErrors, &usePitstops
					 , &overTakeDelta, &consideredTraffic) {
		randomFactor := getMultiMapValue(this.Settings, "Strategy Settings", "Traffic.Randomness", 5)
		numScenarios := getMultiMapValue(this.Settings, "Strategy Settings", "Traffic.Scenarios", 20)
		variationWindow := this.KnowledgeBase.getValue("Session.Settings.Pitstop.Strategy.Window.Considered")

		useLapTimeVariation := getMultiMapValue(this.Settings, "Strategy Settings", "Traffic.Variation.LapTime", true)
		useDriverErrors := getMultiMapValue(this.Settings, "Strategy Settings", "Traffic.Variation.Errors", true)
		usePitstops := getMultiMapValue(this.Settings, "Strategy Settings", "Traffic.Variation.Pitstops", true)

		overTakeDelta := getMultiMapValue(this.Settings, "Strategy Settings", "Overtake.Delta", 1)
		consideredTraffic := getMultiMapValue(this.Settings, "Strategy Settings", "Traffic.Considered", 5)

		return true
	}

	getStartConditions(&initialStint, &initialLap, &initialStintTime, &initialSessionTime
					 , &initialTyreLaps, &initialFuelAmount
					 , &initialMap, &initialFuelConsumption, &initialAvgLapTime) {
		local knowledgeBase := this.KnowledgeBase
		local strategy := this.Strategy[true]
		local goal, resultSet, tyreSets, telemetryDB, consumption

		if strategy {
			initialStint := (Task.CurrentTask.Pitstops.Length + 1)
			initialLap := Task.CurrentTask.Lap
			initialStintTime := Ceil(strategy.StintLength - (knowledgeBase.getValue("Driver.Time.Stint.Remaining") / 60000))

			telemetryDB := Task.CurrentTask.TelemetryDatabase

			if !telemetryDB.suitableTyreCompound(strategy.Simulator, strategy.Car, strategy.Track
											   , knowledgeBase.getValue("Weather.Weather.10Min", strategy.Weather)
											   , compound(knowledgeBase.getValue("Tyre.Compound", "Dry")
														, knowledgeBase.getValue("Tyre.Compound.Color", "Black")))
				initialTyreLaps := 999
			else {
				tyreSets := Task.CurrentTask.UsedTyreSets

				initialTyreLaps := tyreSets[tyreSets.Length].Laps
			}

			initialFuelAmount := knowledgeBase.getValue("Lap." . initialLap . ".Fuel.Remaining")
			initialMap := knowledgeBase.getValue("Lap." . initialLap . ".Map")

			consumption := knowledgeBase.getValue("Lap." . initialLap . ".Fuel.AvgConsumption")

			if (consumption = 0)
				consumption := knowledgeBase.getValue("Session.Settings.Fuel.AvgConsumption")

			initialFuelConsumption := consumption

			goal := RuleCompiler().compileGoal("lapAvgTime(" . initialLap . ", ?lapTime)")
			resultSet := knowledgeBase.prove(goal)

			if resultSet
				initialAvgLapTime := ((resultSet.getValue(goal.Arguments[2]).toString() + 0) / 1000)
			else
				initialAvgLapTime := (knowledgeBase.getValue("Lap." . initialLap . ".Time") / 1000)

			initialSessionTime := (this.OverallTime / 1000)

			return true
		}
		else
			return false
	}

	getSimulationSettings(&useInitialConditions, &useTelemetryData
						, &consumptionVariation, &initialFuelVariation, &tyreUsageVariation, &tyreCompoundVariation) {
		local strategy := this.Strategy[true]

		useInitialConditions := false
		useTelemetryData := true

		initialFuelVariation := 0

		if strategy {
			consumptionVariation := strategy.ConsumptionVariation
			tyreUsageVariation := strategy.TyreUsageVariation
			tyreCompoundVariation := strategy.TyreCompoundVariation
		}
		else {
			consumptionVariation := 0
			tyreUsageVariation := 0
			tyreCompoundVariation := 0
		}

		return (strategy != false)
	}

	getPitstopRules(&validator, &pitstopRule, &refuelRule, &tyreChangeRule, &tyreSets) {
		local strategy := this.Strategy

		if strategy {
			validator := strategy.Validator
			pitstopRule := strategy.PitstopRule
			refuelRule := strategy.RefuelRule
			tyreChangeRule := strategy.TyreChangeRule
			tyreSets := strategy.TyreSets

			if isInteger(pitstopRule)
				if (pitstopRule > 0)
					pitstopRule := Max(0, pitstopRule - Task.CurrentTask.Pitstops.Length)

			return true
		}
		else
			return false
	}

	getAvgLapTime(numLaps, map, remainingFuel, fuelConsumption, weather, tyreCompound, tyreCompoundColor, tyreLaps, default := false) {
		return Task.CurrentTask.Simulation.calcAvgLapTime(numLaps, map, remainingFuel, fuelConsumption, weather
														, tyreCompound, tyreCompoundColor, tyreLaps
														, default ? default : this.Strategy.AvgLapTime
														, Task.CurrentTask.TelemetryDatabase)
	}

	computeAvailableTyreSets(availableTyreSets, usedTyreSets) {
		local tyreCompound, ignore, tyreSet, count

		availableTyreSets := availableTyreSets.Clone()

		for ignore, tyreSet in usedTyreSets {
			tyreCompound := compound(tyreSet.Compound, tyreSet.CompoundColor)

			if availableTyreSets.Has(tyreCompound) {
				count := (availableTyreSets[tyreCompound] - 1)

				if (count > 0)
					availableTyreSets[tyreCompound] := count
				else
					availableTyreSets.Delete(tyreCompound)
			}
		}

		return availableTyreSets
	}

	initializeAvailableTyreSets(strategy) {
		strategy.AvailableTyreSets := this.computeAvailableTyreSets(strategy.AvailableTyreSets, Task.CurrentTask.UsedTyreSets)
	}

	getTrafficScenario(strategy, targetPitstop, randomFactor, numScenarios, useLapTimeVariation, useDriverErrors, usePitstops, overTakeDelta) {
		local targetLap := targetPitstop.Lap + 1
		local knowledgeBase := this.KnowledgeBase
		local pitstopWindow := knowledgeBase.getValue("Session.Settings.Pitstop.Strategy.Window.Considered")
		local pitstops := CaseInsenseMap()
		local carStatistics := CaseInsenseMap()
		local goal, resultSet
		local startLap, endLap, avgLapTime, driver, stintLength, formationLap, postRaceLap
		local fuelCapacity, safetyFuel, pitstopDelta, pitstopFuelService, pitstopTyreService, pitstopServiceOrder
		local lastPositions, lastRunnings, count, laps, curLap, carPositions, nextRunnings
		local lapTime, potential, raceCraft, speed, consistency, carControl
		local rnd, delta, running, nr, position, ignore, nextPositions, runnings, car

		getCarStatistics(car, &lapTime, &potential, &raceCraft, &speed, &consistency, &carControl) {
			local statistics := Task.CurrentTask.Statistics

			lapTime := getMultiMapValue(statistics, "Statistics", "Car." . car . ".LapTime", 0)
			potential := getMultiMapValue(statistics, "Statistics", "Car." . A_Index . ".Potential")
			raceCraft := getMultiMapValue(statistics, "Statistics", "Car." . A_Index . ".RaceCraft")
			speed := getMultiMapValue(statistics, "Statistics", "Car." . A_Index . ".Speed")
			consistency := getMultiMapValue(statistics, "Statistics", "Car." . A_Index . ".Consistency")
			carControl := getMultiMapValue(statistics, "Statistics", "Car." . A_Index . ".CarControl")
		}

		carPitstop(car, lap) {
			local stintLength := 0
			local carPitstops

			if !pitstops.Has(car) {
				carPitstops := this.Pitstops[knowledgeBase.getValue("Car." . car . ".Nr", 0)]

				if (carPitstops.Length > 0) {
					loop carPitstops.Length
						stintLength += (carPitstops[A_Index].Lap - ((A_Index > 1) ? carPitstops[A_Index - 1].Lap : 0))

					if (Abs(carPitstops[carPitstops.Length].Lap + Round(stintLength / carPitstops.Length) - lap) < pitstopWindow) {
						pitstops[car] := true

						return true
					}
				}
				else {
					rnd := Random(0.0, 1.0)

					if (rnd < (randomFactor / 100)) {
						pitstops[car] := true

						return true
					}
				}
			}

			return false
		}

		startLap := knowledgeBase.getValue("Lap")
		endLap := targetLap

		goal := RuleCompiler().compileGoal("lapAvgTime(" . startLap . ", ?lapTime)")
		resultSet := knowledgeBase.prove(goal)

		if resultSet
			avgLapTime := ((resultSet.getValue(goal.Arguments[2]).toString() + 0) / 1000)
		else
			avgLapTime := (knowledgeBase.getValue("Lap." . startLap . ".Time") / 1000)

		driver := knowledgeBase.getValue("Driver.Car")

		stintLength := false
		formationLap := false
		postRaceLap := false
		fuelCapacity := false
		safetyFuel := false
		pitstopDelta := false
		pitstopFuelService := false
		pitstopTyreService := false
		pitstopServiceOrder := "Simultaneous"

		this.getSessionSettings(&stintLength, &formationLap, &postRaceLap, &fuelCapacity, &safetyFuel
							  , &pitstopDelta, &pitstopFuelService, &pitstopTyreService, &pitstopServiceOrder)

		lastPositions := []
		lastRunnings := []

		count := knowledgeBase.getValue("Car.Count")

		loop count {
			getCarStatistics(A_Index, &lapTime, &potential, &raceCraft, &speed, &consistency, &carControl)

			carStatistics[A_Index] := [lapTime, potential, raceCraft, speed, consistency, carControl]

			lastPositions.Push(knowledgeBase.getValue("Car." . A_Index . ".Position", 0))
			lastRunnings.Push(knowledgeBase.getValue("Car." . A_Index . ".Lap", 0)
							+ knowledgeBase.getValue("Car." . A_Index . ".Lap.Running", 0))
		}

		laps := CaseInsenseWeakMap()

		loop (endLap - startLap) {
			curLap := A_Index

			carPositions := []
			nextRunnings := []

			loop count {
				lapTime := true
				potential := true
				raceCraft := true
				speed := true
				consistency := true
				carControl := true

				lapTime := carStatistics[A_Index][1]
				potential := carStatistics[A_Index][2]
				raceCraft := carStatistics[A_Index][3]
				speed := carStatistics[A_Index][4]
				consistency := carStatistics[A_Index][5]
				carControl := carStatistics[A_Index][6]

				if useLapTimeVariation {
					rnd := Random(-1.0, 1.0)

					lapTime += (rnd * ((5 - consistency) / 5) * (randomFactor / 100))
				}

				if useDriverErrors {
					rnd := Random(0.0, 1.0)

					lapTime += (rnd * ((5 - carControl) / 5) * (randomFactor / 100))
				}

				if (usePitstops && (A_Index != driver) && carPitstop(A_Index, (startLap + curLap)))
					lapTime += strategy.calcPitstopDuration(fuelCapacity, true)

				if ((A_Index == driver) && ((startLap + curLap) == targetLap))
					lapTime += strategy.calcPitstopDuration(targetPitstop.RefuelAmount, targetPitstop.TyreChange)

				if lapTime
					delta := (((avgLapTime + lapTime) / lapTime) - 1)
				else
					delta := 0

				running := (lastRunnings[A_Index] + delta)

				nextRunnings.Push(running)
				carPositions.Push(Array(A_Index, lapTime, running))
			}

			bubbleSort(&carPositions, (a, b) => a[3] < b[3])

			for nr, position in carPositions
				position[3] += ((lastPositions[position[1]] - nr) * (overTakeDelta / (position[2] ? position[2] : 0.01)))

			bubbleSort(&carPositions, (a, b) => a[3] < b[3])

			nextPositions := []

			loop count
				nextPositions.Push(false)

			for nr, position in carPositions {
				car := position[1]

				nextPositions[car] := nr
				nextRunnings[car] := position[3]
			}

			runnings := []

			for ignore, running in nextRunnings
				runnings.Push(running - Floor(running))

			laps[startLap + A_Index] := {Positions: nextPositions, Runnings: runnings}

			lastPositions := nextPositions
			lastRunnings := nextRunnings
		}

		return {Driver: driver, Laps: laps}
	}

	getTrafficPositions(trafficScenario, targetLap, &driver, &positions, &runnings) {
		if (trafficScenario && trafficScenario.Laps.Has(targetLap)) {
			if driver
				driver := trafficScenario.Driver

			if positions
				positions := trafficScenario.Laps[targetLap].Positions

			if runnings
				runnings := trafficScenario.Laps[targetLap].Runnings

			return true
		}
		else {
			if driver
				driver := false

			if positions
				positions := []

			if runnings
				runnings := []

			return false
		}
	}

	betterScenario(strategy, scenario, &report := true) {
		local knowledgeBase := this.KnowledgeBase
		local sPitstops, cPitstops, sLaps, cLaps, sDuration, cDuration, sFuel, cFuel, sPLaps, cPLaps, sTLaps, cTLaps, sTSets, cTSets
		local result

		pitstopLaps(strategy, skip := 0) {
			local laps := 0
			local nr, pitstop

			for nr, pitstop in strategy.Pitstops
				if (nr > skip)
					laps += pitstop.Lap

			return laps
		}

		fuelLevel(strategy, skip := 0) {
			local fuelLevel := strategy.RemainingFuel
			local nr, pitstop

			for nr, pitstop in strategy.Pitstops
				if (nr > skip)
					fuelLevel := Max(fuelLevel, pitstop.RemainingFuel)

			return fuelLevel
		}

		tyreLaps(strategy, &tyreSets, skip := 0) {
			local tyreLaps, tyreRunningLaps, lastLap, nr, pitstop, stintLaps

			tyreSets := 1

			if !strategy.LastPitstop
				return strategy.getSessionLaps()
			else {
				tyreLaps := 0
				tyreRunningLaps := 0
				lastLap := 0

				for nr, pitstop in strategy.Pitstops
					if (nr > skip) {
						stintLaps := (pitstop.Lap - lastLap)
						tyreRunningLaps += stintLaps

						if pitstop.TyreChange {
							tyreLaps := Max(tyreLaps, tyreRunningLaps)
							tyreSets += 1

							tyreRunningLaps := 0
						}

						lastLap := pitstop.Lap
					}

				tyreLaps := Max(tyreLaps, tyreRunningLaps + strategy.LastPitstop.StintLaps)

				return tyreLaps
			}
		}

		sLaps := strategy.getSessionLaps()
		cLaps := scenario.getSessionLaps()
		sDuration := strategy.getSessionDuration()
		cDuration := scenario.getSessionDuration()

		cPitstops := scenario.Pitstops.Length
		sPitstops := (strategy.Pitstops.Length - strategy.RunningPitstops)
		cTLaps := tyreLaps(scenario, &cTSets)
		sTLaps := tyreLaps(strategy, &sTSets, strategy.RunningPitstops)
		cFuel := fuelLevel(scenario)
		sFuel := fuelLevel(strategy, strategy.RunningPitstops)
		cPLaps := pitstopLaps(scenario)
		sPLaps := pitstopLaps(strategy, strategy.RunningPitstops)

		if isDebug() {
			logMessage(kLogDebug, "Session Format: " . knowledgeBase.getValue("Session.Format", "Time"))

			logMessage(kLogDebug, "Strategy Laps: " . sLaps)
			logMessage(kLogDebug, "Strategy Duration: " . sDuration)
			logMessage(kLogDebug, "Strategy Pitstops: " . sPitstops)
			logMessage(kLogDebug, "Strategy Fuel: " . sFuel)
			logMessage(kLogDebug, "Strategy Tyre Laps: " . sTLaps)
			logMessage(kLogDebug, "Strategy Tyre Sets: " . sTSets)
			logMessage(kLogDebug, "Strategy Pitstop Laps: " . sPLaps)

			logMessage(kLogDebug, "Candidate Laps: " . cLaps)
			logMessage(kLogDebug, "Candidate Duration: " . cDuration)
			logMessage(kLogDebug, "Candidate Pitstops: " . cPitstops)
			logMessage(kLogDebug, "Candidate Fuel: " . cFuel)
			logMessage(kLogDebug, "Candidate Tyre Laps: " . cTLaps)
			logMessage(kLogDebug, "Candidate Tyre Sets: " . cTSets)
			logMessage(kLogDebug, "Candidate Pitstop Laps: " . cPLaps)
		}

		; Negative => Better, Positive => Worse

		result := (StrategySimulation.scenarioCoefficient("PitstopsCount", cPitstops - sPitstops, 1)
				 + StrategySimulation.scenarioCoefficient("FuelMax", cFuel - sFuel, 10)
				 + StrategySimulation.scenarioCoefficient("TyreSetsCount", sTSets - cTSets, 1)
				 + StrategySimulation.scenarioCoefficient("TyreLapsMax", cTLaps - sTLaps, 10)
				 + StrategySimulation.scenarioCoefficient("PitstopsPostLaps", sPLaps - cPLaps, 10))

		if (scenario.SessionType = "Duration")
			result += (StrategySimulation.scenarioCoefficient("ResultMajor", sLaps - cLaps, 1)
					 + StrategySimulation.scenarioCoefficient("ResultMinor", cDuration - sDuration, (strategy.AvgLapTime + scenario.AvgLapTime) / 4))
		else
			result += StrategySimulation.scenarioCoefficient("ResultMajor", cDuration - sDuration, (strategy.AvgLapTime + scenario.AvgLapTime) / 4)

		if (result > 0)
			result := false
		else if (result < 0)
			result := true
		else if (scenario.getRemainingFuel() > strategy.getRemainingFuel())
			result := false
		else if (scenario.getRemainingFuel() < strategy.getRemainingFuel())
			result := true
		else if ((scenario.FuelConsumption[true] > strategy.FuelConsumption[true]))
			result := false
		else
			result := true

		if result {
			if (sPitstops != cPitstops)
				report := true
			else if (cPitstops.Length != 0) {
				sPitstop := strategy.Pitstops[strategy.RunningPitstops + 1]
				cPitstop := scenario.Pitstops[1]

				report := ((sPitstop.Lap != cPitstop.Lap)
						|| (Abs(sPitstop.RefuelAmount - cPitstop.RefuelAmount) > (Max(strategy.SafetyFuel, scenario.SafetyFuel) / 2))
						|| (sPitstop.TyreChange != sPitstop.TyreChange)
						|| (sPitstop.TyreChange && ((sPitstop.TyreCompound != cPitstop.TyreCompound)
												 || (sPitstop.TyreCompoundColor != cPitstop.TyreCompoundColor))))
			}
			else
				report := false
		}

		return result
	}

	chooseScenario(strategy, confirm?) {
		local dispose := true
		local request, report

		try {
			if !isSet(confirm) {
				request := Task.CurrentTask.Request

				if (request = "User") {
					confirm := true

					if strategy {
						this.reportStrategy({Strategy: false, Pitstops: true, NextPitstop: true
										   , TyreChange: true, Refuel: true, Map: true, Active: this.Strategy}, strategy)

						if ((this.Strategy != this.Strategy[true]) || isDebug())
							this.explainStrategyRecommendation(strategy)

						if this.Speaker {
							this.getSpeaker().speakPhrase("ConfirmUpdateStrategy", false, true)

							this.setContinuation(RaceStrategist.ConfirmStrategyUpdateContinuation(this, strategy, false))

							dispose := false

							return
						}
					}
				}
				else {
					if strategy {
						report := true

						if (request != "Pitstop")
							if (this.Strategy["Rejected"] && !this.betterScenario(this.Strategy["Rejected"], strategy, report))
								return
							else if ((this.Strategy != this.Strategy[true]) && !this.betterScenario(this.Strategy, strategy, report))
								return

						if (report && this.Speaker) {
							this.getSpeaker().speakPhrase("StrategyUpdate")

							this.reportStrategy({Strategy: false, Pitstops: true, NextPitstop: true
											   , TyreChange: true, Refuel: true, Map: true, Active: this.Strategy}, strategy)

							if ((this.Strategy != this.Strategy[true]) || isDebug())
								this.explainStrategyRecommendation(strategy)

							if Task.CurrentTask.Confirm {
								this.getSpeaker().speakPhrase("ConfirmUpdateStrategy", false, true)

								this.setContinuation(RaceStrategist.ConfirmStrategyUpdateContinuation(this, strategy, true))

								dispose := false

								return
							}
						}
					}
					else
						return
				}
			}

			if strategy {
				if this.Strategy[true]
					strategy.PitstopRule := this.Strategy[true].PitstopRule

				strategy.setVersion(A_Now)

				dispose := false

				Task.startTask(ObjBindMethod(this, "updateStrategy", strategy, false, false, strategy.Version), 1000)
			}
			else {
				if (confirm && this.Speaker)
					this.getSpeaker().speakPhrase("NoValidStrategy")

				Task.startTask(ObjBindMethod(this, "cancelStrategy", confirm), 1000)
			}
		}
		finally {
			if (dispose && strategy)
				strategy.dispose()
		}
	}

	recommendPitstop(lap := false) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local refuel := kUndefined
		local tyreChange := kUndefined
		local tyreCompound := kUndefined
		local tyreCompoundColor := kUndefined
		local strategyLap := false
		local lastLap, plannedLap, position, traffic, hasEngineer, nextPitstop, pitstopOptions

		this.clearContinuation()

		if !this.hasEnoughData()
			return

		strategyLap := knowledgeBase.getValue("Strategy.Pitstop.Lap", false)
		lastLap := knowledgeBase.getValue("Lap")

		if strategyLap {
			nextPitstop := knowledgeBase.getValue("Strategy.Pitstop.Next")

			refuel := Round(knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Fuel.Amount"))
			tyreChange := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Change")
			tyreCompound := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Compound")
			tyreCompoundColor := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Compound.Color")

			if (knowledgeBase.getValue("Strategy.Pitstop.Count") > nextPitstop)
				refuel := ("!" . refuel)
		}

		if !lap
			lap := strategyLap

		knowledgeBase.setFact("Pitstop.Strategy.Plan", lap ? lap : true)

		knowledgeBase.produce()

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledgeBase(this.KnowledgeBase)

		plannedLap := knowledgeBase.getValue("Pitstop.Strategy.Lap", kUndefined)

		hasEngineer := (ProcessExist("Race Engineer.exe") != 0)

		if (plannedLap == kUndefined) {
			if (hasEngineer && strategyLap) {
				speaker.speakPhrase("PitstopLap", {lap: (Max(strategyLap, lastLap) + 1)})

				speaker.speakPhrase("ConfirmInformEngineer", false, true)

				this.setContinuation(ObjBindMethod(this, "planPitstop", strategyLap, refuel, tyreChange, tyreCompound, tyreCompoundColor))
			}
			else
				speaker.speakPhrase("NoPlannedPitstop")
		}
		else if !plannedLap
			speaker.speakPhrase("NoPitstopNeeded")
		else {
			if (strategyLap && (Abs(strategyLap - plannedLap) <= knowledgeBase.getValue("Session.Settings.Pitstop.Strategy.Window.Considered")))
				pitstopOptions := Array(refuel, tyreChange, tyreCompound, tyreCompoundColor)
			else
				pitstopOptions := []

			speaker.beginTalk()

			try {
				speaker.speakPhrase("PitstopLap", {lap: plannedLap})

				speaker.speakPhrase("Explain", false, true)

				if hasEngineer
					this.setContinuation(RaceStrategist.ExplainPitstopContinuation(this, plannedLap, pitstopOptions
																				 , ObjBindMethod(this, "explainPitstopRecommendation", plannedLap, pitstopOptions)
																				 , false, "Okay"))
				else
					this.setContinuation(ObjBindMethod(this, "explainPitstopRecommendation", plannedLap))
			}
			finally {
				speaker.endTalk()
			}
		}
	}

	explainStrategyRecommendation(strategy) {
		local pitstopWindow := this.KnowledgeBase.getValue("Session.Settings.Pitstop.Strategy.Window.Considered")
		local speaker, pitstop, pitstopLap, position, carsAhead

		if (isInstance(strategy, RaceStrategist.TrafficRaceStrategy) && (strategy.Pitstops.Length > 0)) {
			speaker := this.getSpeaker()

			pitstop := strategy.Pitstops[1]
			pitstopLap := pitstop.Lap
			position := pitstop.getPosition()

			pitstop.getTrafficDensity(&carsAhead)

			speaker.beginTalk()

			try {
				speaker.speakPhrase("EvaluatedLaps", {laps: ((pitstopWindow * 2) + 1), first: (pitstopLap - pitstopWindow + 1), last: (pitstopLap + pitstopWindow + 1)})

				speaker.speakPhrase("EvaluatedBestPosition", {lap: (pitstopLap + 1), position: position})

				if (carsAhead > 0)
					speaker.speakPhrase("EvaluatedTraffic", {traffic: carsAhead})
				else
					speaker.speakPhrase("EvaluatedNoTraffic")
			}
			finally {
				speaker.endTalk()
			}
		}
	}

	explainPitstopRecommendation(plannedLap, pitstopOptions := []) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local position := knowledgeBase.getValue("Pitstop.Strategy.Position", false)
		local traffic := parseList(knowledgeBase.getValue("Pitstop.Strategy.Traffic", "[]"))
		local driver := knowledgeBase.getValue("Driver.Car")
		local driverLaps := knowledgeBase.getValue("Standings.Extrapolated." . plannedLap . ".Car." . driver . ".Laps")
		local backmarkers := 0
		local laps, positions, traffics

		if position {
			laps := parseList(knowledgeBase.getValue("Pitstop.Strategy.Evaluation.Laps", "[]"))
			positions := parseList(knowledgeBase.getValue("Pitstop.Strategy.Evaluation.Positions", "[]"))
			traffics := parseList(knowledgeBase.getValue("Pitstop.Strategy.Evaluation.Traffics", "[]"))

			speaker.beginTalk()

			try {
				speaker.speakPhrase("EvaluatedLaps", {laps: laps.Length, first: laps[1], last: laps[laps.Length]})

				if (position = Min(positions*))
					speaker.speakPhrase("EvaluatedSimilarPosition", {position: position})
				else
					speaker.speakPhrase("EvaluatedBestPosition", {lap: plannedLap, position: position})

				if (traffic.Length > 0) {
					speaker.speakPhrase("EvaluatedTraffic", {traffic: traffic.Length})

					for ignore, car in traffic
						if (knowledgeBase.getValue("Standings.Extrapolated." . plannedLap . ".Car." . car . ".Laps", kUndefined) < driverLaps)
							backmarkers += 1

					if (backmarkers > 0)
						speaker.speakPhrase((backmarkers > 1) ? "EvaluatedBackmarkers" : "EvaluatedBackmarker", {backmarkers: backmarkers})
				}
				else
					speaker.speakPhrase("EvaluatedNoTraffic")
			}
			finally {
				speaker.endTalk()
			}

			if ProcessExist("Race Engineer.exe") {
				speaker.speakPhrase("ConfirmInformEngineer", false, true)

				this.setContinuation(ObjBindMethod(this, "planPitstop", plannedLap, pitstopOptions*))
			}
		}
	}

	planPitstop(plannedLap := false, refuel := kUndefined, tyreChange := kUndefined
			  , tyreCompound := kUndefined, tyreCompoundColor := kUndefined) {
		local engineerPID

		Task.yield()

		loop 10
			Sleep(500)

		engineerPID := ProcessExist("Race Engineer.exe")

		if engineerPID
			if plannedLap {
				if (refuel != kUndefined)
					messageSend(kFileMessage, "Race Engineer", (this.TeamSession ? "planDriverSwap:" : "planPitstop:")
															 . values2String(";", "!" . plannedLap, refuel, tyreChange, kUndefined
																				, tyreCompound, tyreCompoundColor), engineerPID)
				else
					messageSend(kFileMessage, "Race Engineer", (this.TeamSession ? "planDriverSwap:" : "planPitstop:") . plannedLap, engineerPID)
			}
			else
				messageSend(kFileMessage, "Race Engineer", this.TeamSession ? "planDriverSwap" : "planPitstop:Now", engineerPID)
	}

	executePitstop(lapNumber) {
		local knowledgeBase := this.KnowledgeBase
		local nextPitstop, result, map

		if (this.Strategy && this.Speaker[false])
			nextPitstop := knowledgeBase.getValue("Strategy.Pitstop.Next", false)
		else
			nextPitstop := false

		result := super.executePitstop(lapNumber)

		if nextPitstop {
			this.Strategy.RunningPitstops += 1

			if this.Strategy["Rejected"]
				this.Strategy["Rejected"].RunningPitstops += 1

			if (nextPitstop != knowledgeBase.getValue("Strategy.Pitstop.Next", false)) {
				map := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Map", "n/a")

				if ((map != "n/a") && (map != knowledgeBase.getValue("Lap." . knowledgeBase.getValue("Lap") . ".Map", "n/a")))
					this.getSpeaker().speakPhrase("StintMap", {map: map})
			}
			else
				knowledgeBase.setFact("Strategy.Recalculate", "Pitstop")
		}

		this.updateDynamicValues({RejectedStrategy: false})

		return result
	}

	callRecommendPitstop(lapNumber := false) {
		this.clearContinuation()

		this.getSpeaker().speakPhrase("Confirm")

		Task.yield()

		loop 10
			Sleep(500)

		this.recommendPitstop(lapNumber)
	}

	callRecommendStrategy() {
		this.clearContinuation()

		this.getSpeaker().speakPhrase("Confirm")

		Task.yield()

		loop 10
			Sleep(500)

		this.recommendStrategy()
	}

	weatherChangeNotification(change, minutes) {
		local knowledgeBase := this.KnowledgeBase
		local speaker

		if (this.hasEnoughData(false) && this.Speaker[false] && (this.Session == kSessionRace) && this.Announcements["WeatherUpdate"]) {
			speaker := this.getSpeaker()

			speaker.speakPhrase(change ? "WeatherChange" : "WeatherNoChange", {minutes: minutes})
		}
	}

	weatherTyreChangeRecommendation(minutes, recommendedCompound) {
		local knowledgeBase := this.KnowledgeBase
		local speaker, fragments

		if (knowledgeBase.getValue("Lap.Remaining.Session", knowledgeBase.getValue("Lap.Remaining", 0)) > 3)
			if (this.hasEnoughData(false) && this.Speaker[false] && (this.Session == kSessionRace)) {
				speaker := this.getSpeaker()
				fragments := speaker.Fragments

				speaker.beginTalk()

				try {
					speaker.speakPhrase(((recommendedCompound = "Wet") || (recommendedCompound = "Intermediate")) ? "WeatherRainChange"
																												  : "WeatherDryChange"
									  , {minutes: minutes, compound: fragments[recommendedCompound . "Tyre"]})

					if this.Strategy {
						speaker.speakPhrase("ConfirmUpdateStrategy", false, true)

						this.setContinuation(RaceStrategist.TyreChangeContinuation(this, ObjBindMethod(this, "recommendStrategy")
																				 , "Confirm", "Okay"))
					}
					else {
						if ProcessExist("Race Engineer.exe") {
							speaker.speakPhrase("ConfirmInformEngineer", false, true)

							this.setContinuation(ObjBindMethod(this, "planPitstop"))
						}
					}
				}
				finally {
					speaker.endTalk()
				}
			}
	}

	reportUpcomingPitstop(plannedPitstopLap) {
		local knowledgeBase := this.KnowledgeBase
		local speaker, plannedLap, laps, nextPitstop, refuel, tyreChange, tyreCompound, tyreCompoundColor

		if (this.Speaker[false]) {
			speaker := this.getSpeaker()

			knowledgeBase.setFact("Pitstop.Strategy.Plan", plannedPitstopLap)

			knowledgeBase.produce()

			if this.Debug[kDebugKnowledgeBase]
				this.dumpKnowledgeBase(this.KnowledgeBase)

			plannedLap := knowledgeBase.getValue("Pitstop.Strategy.Lap", kUndefined)

			if (plannedLap && (plannedLap != kUndefined))
				plannedPitstopLap := plannedLap

			laps := (plannedPitstopLap - knowledgeBase.getValue("Lap"))

			speaker.beginTalk()

			try {
				speaker.speakPhrase("PitstopAhead", {lap: plannedPitstopLap, laps: laps})

				if ProcessExist("Race Engineer.exe") {
					speaker.speakPhrase("ConfirmInformEngineer", false, true)

					nextPitstop := knowledgeBase.getValue("Strategy.Pitstop.Next")

					refuel := Round(knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Fuel.Amount"))
					tyreChange := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Change")
					tyreCompound := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Compound")
					tyreCompoundColor := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Compound.Color")

					if (knowledgeBase.getValue("Strategy.Pitstop.Count") > nextPitstop)
						refuel := ("!" . refuel)

					this.setContinuation(ObjBindMethod(this, "planPitstop", plannedPitstopLap
																		  , refuel, "!" . tyreChange, tyreCompound, tyreCompoundColor))
				}
			}
			finally {
				speaker.endTalk()
			}
		}
	}

	saveLapStandings(lapNumber, simulator, car, track) {
		local knowledgeBase := this.KnowledgeBase
		local driver, carCount, fileName, data, prefix, key, value

		if this.RemoteHandler {
			driver := knowledgeBase.getValue("Driver.Car")
			carCount := knowledgeBase.getValue("Car.Count")

			if ((driver == 0) || (carCount == 0))
				return

			fileName := temporaryFileName("Race Strategist Lap", "standings")

			data := newMultiMap()

			setMultiMapValue(data, "Lap", "Lap", lapNumber)
			setMultiMapValue(data, "Lap", "Driver", driver)
			setMultiMapValue(data, "Lap", "Cars", carCount)

			prefix := ("Standings.Lap." . lapNumber)

			for key, value in knowledgeBase.Facts.Facts
				if (InStr(key, "Position", 1) == 1)
					setMultiMapValue(data, "Position", key, value)
				else if InStr(key, prefix, 1)
					setMultiMapValue(data, "Standings", key, value)

			writeMultiMap(fileName, data)

			this.RemoteHandler.saveStandingsData(lapNumber, fileName)
		}
	}

	updateRaceInfo(raceData) {
		local raceInfo := CaseInsenseMap()
		local grid := []
		local classes := []
		local categories := []
		local slots := false
		local carNr, carID, carClass, carCategory, carPosition

		raceInfo["Driver"] := getMultiMapValue(raceData, "Cars", "Driver")
		raceInfo["Cars"] := getMultiMapValue(raceData, "Cars", "Count")

		if getMultiMapValue(raceData, "Cars", "Slots", false)
			raceInfo["Slots"] := string2Map("|", "->", getMultiMapValue(raceData, "Cars", "Slots"))
		else if this.RaceInfo
			raceInfo["Slots"] := this.RaceInfo["Slots"]
		else
			slots := CaseInsenseMap()

		loop raceInfo["Cars"] {
			carNr := getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Nr")
			carID := getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".ID", A_Index)
			carPosition := getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Position")
			carClass := getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Class", "Unknown")
			carCategory := getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Category", false)

			if slots {
				slots["#" . carNr] := A_Index
				slots["!" . carID] := A_Index
			}

			grid.Push(carPosition)
			classes.Push(carClass)
			categories.Push(carCategory)

			raceInfo["#" . carNr] := A_Index
			raceInfo["!" . carID] := A_Index
		}

		raceInfo["Grid"] := grid
		raceInfo["Classes"] := classes
		raceInfo["Categories"] := categories

		if slots
			raceInfo["Slots"] := slots

		this.updateSessionValues({RaceInfo: raceInfo})
	}

	saveStandingsData(lapNumber, simulator, car, track) {
		local knowledgeBase := this.KnowledgeBase
		local driver, carCount, data, raceInfo, slots, grid, carNr, carID, key, fileName, slotsString
		local data, pitstop, pitstops, prefix, times, positions, drivers, laps, carPrefix, carIndex
		local driverForname, driverSurname, driverNickname, driverCategory, carCar, carCategory

		if this.RemoteHandler {
			driver := knowledgeBase.getValue("Driver.Car", 0)
			carCount := knowledgeBase.getValue("Car.Count", 0)

			if ((driver == 0) || (carCount == 0))
				return

			if (lapNumber == 1) {
				data := newMultiMap()

				setMultiMapValue(data, "Session", "Time", this.SessionTime)
				setMultiMapValue(data, "Session", "Simulator", knowledgeBase.getValue("Session.Simulator"))
				setMultiMapValue(data, "Session", "Car", knowledgeBase.getValue("Session.Car"))
				setMultiMapValue(data, "Session", "Track", knowledgeBase.getValue("Session.Track"))
				setMultiMapValue(data, "Session", "Duration", (Round((knowledgeBase.getValue("Session.Duration") / 60) / 5) * 300))
				setMultiMapValue(data, "Session", "Format", knowledgeBase.getValue("Session.Format"))

				setMultiMapValue(data, "Cars", "Count", carCount)
				setMultiMapValue(data, "Cars", "Driver", driver)

				raceInfo := this.RaceInfo
				grid := (raceInfo ? raceInfo["Grid"] : false)
				slots := (raceInfo ? raceInfo["Slots"] : false)

				if slots
					setMultiMapValue(data, "Cars", "Slots", map2String("|", "->", slots))

				loop carCount {
					carNr := knowledgeBase.getValue("Car." . A_Index . ".Nr", 0)
					carID := knowledgeBase.getValue("Car." . A_Index . ".ID", A_Index)

					if slots {
						key := ("#" . carNr)

						carIndex := (slots.Has(key) ? slots[key] : false)

						if !carIndex {
							key := ("!" . carID)

							carIndex := (slots.Has(key) ? slots[key] : A_Index)
						}
					}
					else
						carIndex := A_Index

					if carIndex {
						carCar := knowledgeBase.getValue("Car." . A_Index . ".Car", false)

						if carCar {
							setMultiMapValue(data, "Cars", "Car." . carIndex . ".Nr", carNr)
							setMultiMapValue(data, "Cars", "Car." . carIndex . ".ID", carID)
							setMultiMapValue(data, "Cars", "Car." . carIndex . ".Car", carCar)
							setMultiMapValue(data, "Cars", "Car." . carIndex . ".Class"
												 , knowledgeBase.getValue("Car." . A_Index . ".Class", kUnknown))

							carCategory := knowledgeBase.getValue("Car." . A_Index . ".Category", kUndefined)

							if (carCategory != kUndefined)
								setMultiMapValue(data, "Cars", "Car." . carIndex . ".Category", carCategory)

							key := ("#" . carNr)

							if ((raceInfo != false) && raceInfo.Has(key))
								setMultiMapValue(data, "Cars", "Car." . carIndex . ".Position", grid[raceInfo[key]])
							else {
								key := ("!" . carID)

								if ((raceInfo != false) && raceInfo.Has(key))
									setMultiMapValue(data, "Cars", "Car." . carIndex . ".Position", grid[raceInfo[key]])
								else
									setMultiMapValue(data, "Cars", "Car." . carIndex . ".Position", this.getPosition(A_Index))
							}
						}
					}
				}

				this.updateRaceInfo(data)

				setMultiMapValue(data, "Cars", "Slots", map2String("|", "->", this.RaceInfo["Slots"]))

				fileName := temporaryFileName("Race Strategist Race", "info")

				writeMultiMap(fileName, data)

				this.RemoteHandler.saveRaceInfo(lapNumber, fileName)
			}

			data := newMultiMap()

			pitstop := knowledgeBase.getValue("Pitstop.Last", false)

			if pitstop {
				pitstops := []

				loop pitstop
					pitstops.Push(knowledgeBase.getValue("Pitstop." . A_Index . ".Lap"))

				setMultiMapValue(data, "Pitstop", "Laps", values2String(",", pitstops*))

				pitstop := (lapNumber == (knowledgeBase.getValue("Pitstop." . pitstop . ".Lap") + 1))
			}

			prefix := "Lap." . lapNumber

			setMultiMapValue(data, "Lap", "Lap", lapNumber)

			setMultiMapValue(data, "Lap", prefix . ".Weather", knowledgeBase.getValue("Standings.Lap." . lapNumber . ".Weather"))
			setMultiMapValue(data, "Lap", prefix . ".LapTime", knowledgeBase.getValue(prefix . ".Time"))
			setMultiMapValue(data, "Lap", prefix . ".Compound", knowledgeBase.getValue(prefix . ".Tyre.Compound", "Dry"))
			setMultiMapValue(data, "Lap", prefix . ".CompoundColor", knowledgeBase.getValue(prefix . ".Tyre.Compound.Color", "Black"))
			setMultiMapValue(data, "Lap", prefix . ".Map", knowledgeBase.getValue(prefix . ".Map", "n/a"))
			setMultiMapValue(data, "Lap", prefix . ".TC", knowledgeBase.getValue(prefix . ".TC", "n/a"))
			setMultiMapValue(data, "Lap", prefix . ".ABS", knowledgeBase.getValue(prefix . ".ABS", "n/a"))
			setMultiMapValue(data, "Lap", prefix . ".Consumption", knowledgeBase.getValue(prefix . ".Fuel.Consumption", "n/a"))
			setMultiMapValue(data, "Lap", prefix . ".Pitstop", pitstop)

			raceInfo := this.RaceInfo
			slots := false

			if raceInfo {
				slots := raceInfo["Slots"]

				carCount := (slots ? Floor(slots.Count / 2) : raceInfo["Cars"])
			}
			else
				raceInfo := CaseInsenseMap()

			times := []
			positions := []
			drivers := []
			laps := []

			loop carCount {
				times.Push("-")
				positions.Push("-")
				drivers.Push("-")
				laps.Push("-")
			}

			loop {
				carPrefix := ("Standings.Lap." . lapNumber . ".Car." . A_Index)
				carID := knowledgeBase.getValue(carPrefix . ".ID", kUndefined)

				if (carID == kUndefined)
					break

				carNr := knowledgeBase.getValue(carPrefix . ".Nr", kUndefined)

				key := ("#" . carNr)

				if slots {
					if slots.Has(key)
						carIndex := slots[key]
					else {
						key := ("!" . carID)

						if slots.Has(key)
							carIndex := slots[key]
						else if (A_Index <= carCount)
							carIndex := A_Index
						else
							carIndex := false
					}
				}
				else if raceInfo.Has(key)
					carIndex := raceInfo[key]
				else {
					key := ("!" . carID)

					if raceInfo.Has(key)
						carIndex := raceInfo[key]
					else if (A_Index <= carCount)
						carIndex := A_Index
					else
						carIndex := false
				}

				if (carIndex && times.Has(carIndex)) {
					times[carIndex] := knowledgeBase.getValue(carPrefix . ".Time", "-")
					positions[carIndex] := knowledgeBase.getValue(carPrefix . ".Position", "-")
					laps[carIndex] := Floor(knowledgeBase.getValue(carPrefix . ".Laps", "-"))

					driverForname := knowledgeBase.getValue(carPrefix . ".Driver.Forname")
					driverSurname := knowledgeBase.getValue(carPrefix . ".Driver.Surname")
					driverNickname := knowledgeBase.getValue(carPrefix . ".Driver.Nickname")

					drivers[carIndex] := computeDriverName(driverForname, driverSurname, driverNickname)

					driverCategory := knowledgeBase.getValue(carPrefix . ".Driver.Category", "Unknown")

					if (driverCategory != "Unknown")
						drivers[carIndex] .= ("|||" . driverCategory)
				}
			}

			setMultiMapValue(data, "Times", lapNumber, values2String(";", times*))
			setMultiMapValue(data, "Positions", lapNumber, values2String(";", positions*))
			setMultiMapValue(data, "Laps", lapNumber, values2String(";", laps*))
			setMultiMapValue(data, "Drivers", lapNumber, values2String(";", drivers*))

			fileName := temporaryFileName("Race Strategist Race." . lapNumber, "lap")

			writeMultiMap(fileName, data)

			this.RemoteHandler.saveRaceLap(lapNumber, fileName)
		}

		this.saveLapStandings(lapNumber, simulator, car, track)
	}

	restoreRaceInfo(raceInfoFile) {
		this.updateRaceInfo(readMultiMap(raceInfoFile))

		deleteFile(raceInfoFile)
	}

	createRaceReport() {
		if this.RemoteHandler
			this.RemoteHandler.createRaceReport()
	}

	saveTelemetryData(lapNumber, simulator, car, track, weather, airTemperature, trackTemperature
					, fuelConsumption, fuelRemaining, lapTime, pitstop, map, tc, abs
					, compound, compoundColor, pressures, temperatures, wear) {
		local knowledgeBase := this.KnowledgeBase
		local telemetryDB := this.TelemetryDatabase
		local tyreLaps, lastPitstop

		telemetryDB.addElectronicEntry(weather, airTemperature, trackTemperature, compound, compoundColor
									 , map, tc, abs, fuelConsumption, fuelRemaining, lapTime)

		lastPitstop := knowledgeBase.getValue("Pitstop.Last", false)

		if lastPitstop
			tyreLaps := (lapNumber - (knowledgeBase.getValue("Pitstop." . lastPitstop . ".Lap")))
		else
			tyreLaps := lapNumber

		if (tyreLaps > 1)
			telemetryDB.addTyreEntry(weather, airTemperature, trackTemperature, compound, compoundColor, tyreLaps
								   , pressures[1], pressures[2], pressures[3], pressures[4]
								   , temperatures[1], temperatures[2], temperatures[3], temperatures[4]
								   , wear ? wear[1] : kNull, wear ? wear[2] : kNull
								   , wear ? wear[3] : kNull, wear ? wear[4] : kNull
								   , fuelConsumption, fuelRemaining, lapTime)

		if (this.RemoteHandler && this.collectTelemetryData()) {
			this.updateDynamicValues({HasTelemetryData: true})

			this.RemoteHandler.saveTelemetryData(lapNumber, simulator, car, track, weather, airTemperature, trackTemperature
											   , fuelConsumption, fuelRemaining, lapTime, pitstop, map, tc, abs
											   , compound, compoundColor, values2String(",", pressures*), values2String(",", temperatures*)
											   , wear ? values2String(",", wear*) : false)
		}
	}

	updateTelemetryDatabase() {
		if (this.RemoteHandler && this.collectTelemetryData())
			this.RemoteHandler.updateTelemetryDatabase()

		this.updateDynamicValues({HasTelemetryData: false})
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

getTime(*) {
	return A_Now
}

updatePositions(context, futureLap) {
	local knowledgeBase := context.KnowledgeBase
	local cars := []
	local count := 0
	local laps

	compareSequences(c1, c2) {
		c1 := c1[2]
		c2 := c2[2]

		return ((c1 - Floor(c1)) < (c2 - Floor(c2)))
	}

	loop knowledgeBase.getValue("Car.Count", 0) {
		laps := knowledgeBase.getValue("Standings.Extrapolated." . futureLap . ".Car." . A_Index . ".Laps", kUndefined)

		if (laps != kUndefined) {
			cars.Push(Array(A_Index, laps))

			count += 1
		}
	}

	bubbleSort(&cars, (c1, c2) => c1[2] < c2[2])

	loop {
		if (A_Index > count)
			break

		knowledgeBase.setFact("Standings.Extrapolated." . futureLap . ".Car." . cars[A_Index][1] . ".Position", A_Index)
	}

	bubbleSort(&cars, compareSequences)

	loop {
		if (A_Index > count)
			break

		knowledgeBase.setFact("Standings.Extrapolated." . futureLap . ".Car." . cars[A_Index][1] . ".Sequence", A_Index)
	}

	return true
}

weatherChangeNotification(context, change, minutes) {
	context.KnowledgeBase.RaceAssistant.clearContinuation()

	context.KnowledgeBase.RaceAssistant.weatherChangeNotification(change, minutes)

	return true
}

weatherTyreChangeRecommendation(context, minutes, recommendedCompound) {
	context.KnowledgeBase.RaceAssistant.clearContinuation()

	context.KnowledgeBase.RaceAssistant.weatherTyreChangeRecommendation(minutes, recommendedCompound)

	return true
}

reportUpcomingPitstop(context, lap) {
	context.KnowledgeBase.RaceAssistant.clearContinuation()

	context.KnowledgeBase.RaceAssistant.reportUpcomingPitstop(lap)

	return true
}