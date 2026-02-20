;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AI Race Strategist              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Global Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Extensions\Task.ahk"
#Include "..\..\Framework\Extensions\RuleEngine.ahk"
#Include "..\..\Framework\Extensions\Database.ahk"
#Include "..\..\Framework\Extensions\JSON.ahk"
#Include "..\..\Framework\Extensions\LLMConnector.ahk"
#Include "..\..\Plugins\Libraries\SimulatorProvider.ahk"
#Include "..\..\Database\Libraries\SessionDatabase.ahk"
#Include "..\..\Database\Libraries\LapsDatabase.ahk"
#Include "RaceAssistant.ahk"
#Include "Strategy.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kStrategyProtocol := 4


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;


class StrategistEvent extends AssistantEvent {
	Asynchronous {
		Get {
			return true
		}
	}
}

class PitstopUpcomingEvent extends StrategistEvent {
	createTrigger(event, phrase, arguments) {
		return ("The next pitstop is upcoming in lap " . arguments[1] . ".")
	}

	handleEvent(event, arguments*) {
		if !super.handleEvent(event, arguments*)
			this.Assistant.reportUpcomingPitstop(arguments*)

		return true
	}
}

class WeatherForecastEvent extends StrategistEvent {
	createTrigger(event, phrase, arguments) {
		local trigger := ("The weather will change to " . arguments[1] . " in " . arguments[2] . ".")

		if (arguments.Has(4) && arguments[3])
			return (trigger . A_Space . " We should plan a pitstop and mount " . arguments[4] . " tyres.")
		else
			return (trigger . " A tyre change will not be necessary.")
	}

	handleEvent(event, arguments*) {
		if !super.handleEvent(event, arguments*)
			if (arguments.Has(4) && arguments[3])
				this.Assistant.requestTyreChange(arguments[1], arguments[2], arguments[4])
			else
				this.Assistant.weatherForecast(arguments[1], arguments[2], arguments[3])

		return true
	}
}

class RecommendPitstopEvent extends StrategistEvent {
	Asynchronous {
		Get {
			return false
		}
	}

	handledEvent(event) {
		return (super.handledEvent(event) && this.Assistant.hasEnoughData(false))
	}

	createTrigger(event, phrase, arguments) {
		local knowledgeBase := this.Assistant.KnowledgeBase
		local targetLap := (arguments.Has(1) ? arguments[1] : kUndefined)
		local targetLapRule

		static instructions := false

		if !instructions {
			instructions := readMultiMap(kResourcesDirectory . "Instructions\Race Strategist.instructions.en")

			addMultiMapValues(instructions, readMultiMap(kUserHomeDirectory . "Instructions\Race Strategist.instructions.en"))
		}

		if (targetLap = "Now")
			targetLap := (knowledgeBase.getValue("Lap", 0) + 1)

		if (targetLap && (targetLap != kUndefined))
			targetLapRule := substituteVariables(getMultiMapValue(instructions, "Rules", "TargetLapRuleFixed")
											   , {targetLap: targetLap
												, deltaLaps: knowledgeBase.getValue("Session.Settings.Standings.Extrapolation.Laps", 3)})
		else
			targetLapRule := getMultiMapValue(instructions, "Rules", "TargetLapRuleVariable")

		return substituteVariables(getMultiMapValue(instructions, "Instructions", "PitstopRecommend"), {targetLapRule: targetLapRule})
	}

	handleEvent(event, arguments*) {
		if !super.handleEvent(event, arguments*)
			this.Assistant.recommendPitstop(arguments.Has(1) ? arguments[1] : kUndefined)

		return true
	}
}

class SimulateStrategyEvent extends StrategistEvent {
	iStrategyOptions := false

	StrategyOptions {
		Get {
			return this.iStrategyOptions
		}
	}

	handledEvent(event) {
		return (super.handledEvent(event) && this.Assistant.Strategy && this.Assistant.hasEnoughData(false))
	}

	createTrigger(event, phrase, arguments) {
		local knowledgeBase := this.Assistant.KnowledgeBase
		local options := this.StrategyOptions
		local fullCourseYellow := (options.HasProp("FullCourseYellow") ? options.FullCourseYellow : false)
		local forcedPitstop := (options.HasProp("Pitstop") ? options.Pitstop : false)
		local pitstopRule, weatherRule, weatherChange, minutes

		static instructions := false

		if !instructions {
			instructions := readMultiMap(kResourcesDirectory . "Instructions\Race Strategist.instructions.en")

			addMultiMapValues(instructions, readMultiMap(kUserHomeDirectory . "Instructions\Race Strategist.instructions.en"))
		}

		if fullCourseYellow
			pitstopRule := getMultiMapValue(instructions, "Rules", "PitstopRuleFullCourseYellow")
		else if forcedPitstop
			pitstopRule := substituteVariables(getMultiMapValue(instructions, "Rules", "PitstopRuleFixed"), {lap: forcedPitstop})
		else
			pitstopRule := getMultiMapValue(instructions, "Rules", "PitstopRuleVariable")

		if this.Assistant.weatherChange(&weather, &minutes)
			weatherRule := substituteVariables(getMultiMapValue(instructions, "Rules", "WeatherRuleChange"), {weather: weather, minutes: minutes})
		else
			weatherRule := getMultiMapValue(instructions, "Rules", "WeatherRuleStable")

		return substituteVariables(getMultiMapValue(instructions, "Instructions", "StrategyRecommend")
								 , {pitstopRule: pitstopRule, weatherRule: weatherRule
								  , strategy: JSON.print(this.Assistant.Strategy.Descriptor, isDebug() ? "  " : "")})
	}

	handleEvent(event, arguments*) {
		local targetLap := (arguments.Has(1) ? arguments[1] : kUndefined)
		local options

		if arguments.Has(2) {
			options := toObject(string2Map("|", "->", arguments[2]))

			arguments.RemoveAt(2)
		}
		else
			options := {}

		if targetLap
			options.Pitstop := targetLap

		this.iStrategyOptions := options

		if !super.handleEvent(event, arguments*)
			this.Assistant.recommendStrategy(options)

		return true
	}
}

class RaceStrategist extends GridRaceAssistant {
	iRaceInfo := false
	iRaceInfoSaved := false

	iOriginalStrategy := false
	iStrategy := false
	iStrategyReported := false
	iLastStrategyUpdate := 0
	iRejectedStrategy := false

	iStrategyCreated := false

	iPitstopHistory := false
	iUsedTyreSets := false

	iUseTraffic := false

	iCollectLaps := true
	iSaveTelemetry := kAlways
	iSaveRaceReport := false
	iRaceReview := false

	iHasLapsData := false

	iLapsDatabaseDirectory := false

	iLapsDatabase := false

	iSessionReportsDatabase := false
	iSessionDataActive := false

	iDebugStrategyCounter := [1, 1, 1]

	class RaceStrategistRemoteHandler extends RaceAssistant.RaceAssistantRemoteHandler {
		__New(remotePID) {
			super.__New("Race Strategist", remotePID)
		}

		saveStandingsData(arguments*) {
			this.callRemote("saveStandingsData", arguments*)
		}

		saveLapData(arguments*) {
			this.callRemote("saveLapData", arguments*)
		}

		updateLapsDatabase(arguments*) {
			this.callRemote("updateLapsDatabase", arguments*)
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

	class ConfirmStrategyUpdateContinuation extends VoiceManager.QuestionContinuation {
		iStrategy := false
		iRemember := false

		__New(strategist, strategy, remember) {
			this.iStrategy := strategy
			this.iRemember := remember

			super.__New(strategist, ObjBindMethod(strategist, "chooseScenario", strategy, false)
								  , false
								  , "Roger", "Okay")
		}

		abort() {
			if this.iRemember
				this.Manager.updateDynamicValues({RejectedStrategy: this.iStrategy})

			super.abort()
		}
	}

	class TyreChangeContinuation extends VoiceManager.QuestionContinuation {
		abort() {
			if ProcessExist("Race Engineer.exe") {
				if this.Manager.Listener {
					this.Manager.getSpeaker().speakPhrase("ConfirmInformEngineerAnyway", false, true)

					this.Manager.setContinuation(ObjBindMethod(this.Manager, "planPitstop"))
				}
				else
					super.abort()
			}
			else
				super.abort()
		}
	}

	class ExplainPitstopContinuation extends VoiceManager.QuestionContinuation {
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

		abort() {
			if ProcessExist("Race Engineer.exe") {
				if this.Manager.Listener {
					this.Manager.getSpeaker().speakPhrase("ConfirmInformEngineerAnyway", false, true)

					this.Manager.setContinuation(ObjBindMethod(this.Manager, "planPitstop", this.PlannedLap, this.PitstopOptions*))
				}
				else
					super.abort()
			}
			else
				super.abort()
		}
	}

	class RaceReviewContinuation extends VoiceManager.Continuation {
	}

	class SessionLapsDatabase extends LapsDatabase {
		iRaceStrategist := false
		iLapsDatabase := false

		RaceStrategist {
			Get {
				return this.iRaceStrategist
			}
		}

		LapsDatabase {
			Get {
				return this.iLapsDatabase
			}
		}

		__New(strategist, simulator := false, car := false, track := false) {
			this.iRaceStrategist := strategist

			super.__New()

			this.Shared := false

			this.setDatabase(Database(strategist.LapsDatabaseDirectory, kLapsSchemas))

			if simulator
				this.iLapsDatabase := LapsDatabase(simulator, car, track)
		}

		setDrivers(drivers) {
			super.setDrivers(drivers)

			if this.LapsDatabase
				this.LapsDatabase.setDrivers(drivers)
		}

		getMapData(weather, compound, compoundColor) {
			local entries := []
			local newEntries, ignore, entry, ignore, entry, found, candidate

			for ignore, entry in super.getMapData(weather, compound, compoundColor)
				if ((entry["Fuel.Consumption"] > 0) && (entry["Lap.Time"] > 0))
					entries.Push(entry)

			if this.LapsDatabase {
				newEntries := []

				for ignore, entry in this.LapsDatabase.getMapData(weather, compound, compoundColor) {
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

			if this.LapsDatabase {
				newEntries := []

				for ignore, entry in this.LapsDatabase.getTyreData(weather, compound, compoundColor) {
					if (entry["Lap.Time"] > 0) {
						found := false

						for ignore, candidate in entries
							if ((candidate["Tyre.Laps.Front.Left"] = entry["Tyre.Laps.Front.Left"])
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

		getMapLapTimes(weather, compound, compoundColor) {
			local entries := []
			local newEntries, ignore, entry, found, candidate

			for ignore, entry in super.getMapLapTimes(weather, compound, compoundColor)
				if (entry["Lap.Time"] > 0)
					entries.Push(entry)

			if this.LapsDatabase {
				newEntries := []

				for ignore, entry in this.LapsDatabase.getMapLapTimes(weather, compound, compoundColor) {
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

			if this.LapsDatabase {
				newEntries := []

				for ignore, entry in this.LapsDatabase.getTyreLapTimes(weather, compound, compoundColor) {
					if (entry["Lap.Time"] > 0) {
						found := false

						for ignore, candidate in entries
							if ((candidate["Tyre.Laps.Front.Left"] = entry["Tyre.Laps.Front.Left"])
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
	}

	class RaceStrategySimulationContinuation extends VoiceManager.Continuation {
		iData := false
		iConfirm := false
		iRequest := false

		iFullCourseYellow := false
		iForcedPitstop := false

		__New(manager, data, confirm, request, fullCourseYellow, forcedPitstop) {
			this.iData := data
			this.iConfirm := confirm
			this.iRequest := request
			this.iFullCourseYellow := fullCourseYellow
			this.iForcedPitstop := forcedPitstop

			super.__New(manager)
		}

		continue(statistics) {
			RaceStrategist.RaceStrategySimulationTask(this.Manager, this.iData, this.iRequest, this.iConfirm
													, statistics, this.iFullCourseYellow, this.iForcedPitstop).start()
		}
	}

	class RaceStrategyTask extends Task {
		iConfirm := false
		iRequest := "User"

		iRaceStrategist := false

		iFullCourseYellow := false
		iForcedPitstop := false

		RaceStrategist {
			Get {
				return this.iRaceStrategist
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

		FullCourseYellow {
			Get {
				return this.iFullCourseYellow
			}
		}

		ForcedPitstop {
			Get {
				return this.iForcedPitstop
			}
		}

		ExplainStrategy {
			Get {
				throw "Virtual property RaceStrategist.RaceStrategyTask.ExplainStrategy must be implemented in a subclass..."
			}
		}

		__New(strategist, request := "User", confirm := false, fullCourseYellow := false, forcedPitstop := false) {
			this.iRaceStrategist := strategist

			super.__New(false, 0, kLowPriority)

			this.iConfirm := confirm
			this.iRequest := request

			this.iFullCourseYellow := fullCourseYellow
			this.iForcedPitstop := forcedPitstop
		}
	}

	class RaceStrategyUpdateTask extends RaceStrategist.RaceStrategyTask {
		iStrategy := false

		Strategy {
			Get {
				return this.iStrategy
			}
		}

		ExplainStrategy {
			Get {
				return false
			}
		}

		__New(strategist, strategy, request := "User", confirm := false, fullCourseYellow := false, forcedPitstop := false) {
			this.iStrategy := strategy

			super.__New(strategist, request, confirm, fullCourseYellow, forcedPitstop)
		}

		run() {
			this.RaceStrategist.chooseScenario(this.Strategy)
		}
	}

	class RaceStrategySimulationTask extends RaceStrategist.RaceStrategyTask {
		iLapsDatabase := false

		iSimulation := false

		iLap := false

		iStatistics := false
		iPitstops := []
		iUsedTyreSets := []

		LapsDatabase {
			Get {
				return this.iLapsDatabase
			}
		}

		Simulation {
			Get {
				return this.iSimulation
			}
		}

		ExplainStrategy {
			Get {
				return false
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

		__New(strategist, pitstopHistory, request := "User", confirm := false, statistics := false, fullCourseYellow := false, forcedPitstop := false) {
			super.__New(strategist, request, confirm, fullCourseYellow, forcedPitstop)

			this.iStatistics := statistics
			this.iLap := strategist.KnowledgeBase.getValue("Lap")
			this.iLapsDatabase := RaceStrategist.SessionLapsDatabase(strategist, strategist.Simulator, strategist.Car, strategist.Track)

			this.loadPitstopHistory(pitstopHistory)
		}

		loadPitstopHistory(pitstopHistory) {
			local usedTyreSets

			this.iPitstops := this.RaceStrategist.createPitstopHistory(pitstopHistory, &usedTyreSets)
			this.iUsedTyreSets := usedTyreSets
		}

		run() {
			if this.RaceStrategist.UseTraffic
				this.iSimulation := TrafficSimulation(this.RaceStrategist, this.LapsDatabase
												    , (this.RaceStrategist.KnowledgeBase.getValue("Session.Format") = "Time") ? "Duration" : "Laps"
													, this.RaceStrategist.KnowledgeBase.getValue("Session.AdditionalLaps", 0))
			else
				this.iSimulation := VariationSimulation(this.RaceStrategist, this.LapsDatabase
													  , (this.RaceStrategist.KnowledgeBase.getValue("Session.Format") = "Time") ? "Duration" : "Laps"
													  , this.RaceStrategist.KnowledgeBase.getValue("Session.AdditionalLaps", 0))

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
		iCompletedPitstops := []

		iRunningPitstops := 0
		iRunningLaps := 0
		iRunningTime := 0

		iFullCourseYellow := false
		iForcedPitstop := false

		CompletedPitstops {
			Get {
				return this.iCompletedPitstops
			}
		}

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

		FullCourseYellow {
			Get {
				return this.iFullCourseYellow
			}

			Set {
				return (this.iFullCourseYellow := value)
			}
		}

		ForcedPitstop {
			Get {
				return this.iForcedPitstop
			}

			Set {
				return (this.iForcedPitstop := value)
			}
		}

		__New(strategyManager, configuration, driver, completedPitstops, fullCourseYellow := false, forcedPitstop := false) {
			this.iCompletedPitstops := completedPitstops
			this.iFullCourseYellow := fullCourseYellow
			this.iForcedPitstop := forcedPitstop

			super.__New(strategyManager, configuration, driver)
		}

		initializeTyreSets() {
			super.initializeTyreSets()

			this.StrategyManager.StrategyManager.initializeTyreSets(this)
		}

		calcRemainingLaps(pitstopNr, currentLap, remainingStintLaps, remainingTyreLaps, remainingFuel, fuelConsumption) {
			local strategist := this.StrategyManager.StrategyManager
			local remainingLaps

			if this.StrategyManager.StrategyManager.unplannedPitstop(pitstopNr, currentLap, &remainingLaps)
				return remainingLaps
			else
				return super.calcRemainingLaps(pitstopNr, currentLap, remainingStintLaps, remainingTyreLaps, remainingFuel, fuelConsumption)
		}
	}

	class TrafficRaceStrategy extends TrafficStrategy {
		iCompletedPitstops := []

		iRunningPitstops := 0
		iRunningLaps := 0
		iRunningTime := 0

		iFullCourseYellow := false
		iForcedPitstop := false

		CompletedPitstops {
			Get {
				return this.iCompletedPitstops
			}
		}

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

		FullCourseYellow {
			Get {
				return this.iFullCourseYellow
			}

			Set {
				return (this.iFullCourseYellow := value)
			}
		}

		ForcedPitstop {
			Get {
				return this.iForcedPitstop
			}

			Set {
				return (this.iForcedPitstop := value)
			}
		}

		__New(strategyManager, configuration, driver, completedPitstops, fullCourseYellow := false, forcedPitstop := false) {
			this.iCompletedPitstops := completedPitstops
			this.iFullCourseYellow := fullCourseYellow
			this.iForcedPitstop := forcedPitstop

			super.__New(strategyManager, configuration, driver)
		}

		initializeTyreSets() {
			super.initializeTyreSets()

			this.StrategyManager.StrategyManager.initializeTyreSets(this)
		}

		calcRemainingLaps(pitstopNr, currentLap, remainingStintLaps, remainingTyreLaps, remainingFuel, fuelConsumption) {
			local strategist := this.StrategyManager.StrategyManager
			local remainingLaps

			if this.StrategyManager.StrategyManager.unplannedPitstop(pitstopNr, currentLap, &remainingLaps)
				return remainingLaps
			else
				return super.calcRemainingLaps(pitstopNr, currentLap, remainingStintLaps, remainingTyreLaps, remainingFuel, fuelConsumption)
		}
	}

	Knowledge {
		Get {
			static knowledge := concatenate(super.Knowledge, ["Strategy", "Pitstops"])

			return knowledge
		}
	}

	RaceInfo[key?] {
		Get {
			return (isSet(key) ? this.iRaceInfo[key] : this.iRaceInfo)
		}
	}

	Strategy[original := false] {
		Get {
			return (original ? ((original = "Rejected") ? this.iRejectedStrategy : this.iOriginalStrategy)
							 : this.iStrategy)
		}
	}

	StrategyCreated {
		Get {
			return this.iStrategyCreated
		}
	}

	StrategyReported {
		Get {
			return this.iStrategyReported
		}
	}

	PitstopHistory {
		Get {
			return this.iPitstopHistory
		}
	}

	UsedTyreSets {
		Get {
			return this.iUsedTyreSets
		}
	}

	UseTraffic {
		Get {
			return this.iUseTraffic
		}
	}

	CollectLaps {
		Get {
			return this.iCollectLaps
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

	HasLapsData {
		Get {
			return this.iHasLapsData
		}
	}

	LapsDatabase {
		Get {
			return this.iLapsDatabase
		}
	}

	LapsDatabaseDirectory {
		Get {
			return this.iLapsDatabaseDirectory
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

	__New(configuration, remoteHandler, name := false, language := kUndefined, translator := kUndefined
		, synthesizer := false, speaker := false, vocalics := false, speakerBooster := false
		, recognizer := false, listener := false, listenerBooster := false, conversationBooster := false, agentBooster := false
		, muted := false, voiceServer := false) {
		local settings

		super.__New(configuration, "Race Strategist", remoteHandler, name, language, translator
													, synthesizer, speaker, vocalics, speakerBooster
													, recognizer, listener, listenerBooster, conversationBooster, agentBooster
													, muted, voiceServer)

		this.updateConfigurationValues({Announcements: {WeatherUpdate: true, StrategySummary: true, StrategyUpdate: true, StrategyPitstop: false}})

		deleteDirectory(kTempDirectory . "Race Strategist")

		DirCreate(kTempDirectory . "Race Strategist")

		settings := readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))

		if getMultiMapValue(settings, "Strategy", "Protocol", getMultiMapValue(settings, "Debug", "DebugStrategy", false))
			this.setDebug(kStrategyProtocol, true)

		this.iLapsDatabaseDirectory := (kTempDirectory . "Race Strategist\")
	}

	updateConfigurationValues(values) {
		super.updateConfigurationValues(values)

		if values.HasProp("SessionReportsDatabase")
			this.iSessionReportsDatabase := values.SessionReportsDatabase

		if values.HasProp("CollectLaps")
			this.iCollectLaps := values.CollectLaps

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
			this.iRaceInfoSaved := false

			this.iPitstopHistory := false
			this.iUsedTyreSets := false
		}
	}

	updateSessionValues(values) {
		super.updateSessionValues(values)

		if values.HasProp("LapsDatabase")
			this.iLapsDatabase := values.LapsDatabase

		if values.HasProp("OriginalStrategy")
			this.iOriginalStrategy := values.OriginalStrategy

		if values.HasProp("Strategy") {
			if this.iRejectedStrategy {
				if isInstance(this.iRejectedStrategy, Strategy)
					this.iRejectedStrategy.dispose()

				this.iRejectedStrategy := false
			}

			this.iStrategy := values.Strategy
		}

		if values.HasProp("RaceInfo")
			this.iRaceInfo := values.RaceInfo
	}

	updateDynamicValues(values) {
		super.updateDynamicValues(values)

		if values.HasProp("HasLapsData")
			this.iHasLapsData := values.HasLapsData

		if values.HasProp("StrategyReported")
			this.iStrategyReported := values.StrategyReported

		if values.HasProp("StrategyCreated")
			this.iStrategyCreated := values.StrategyCreated

		if values.HasProp("RejectedStrategy") {
			if (this.iRejectedStrategy && (this.iRejectedStrategy != values.RejectedStrategy))
				if isInstance(this.iRejectedStrategy, Strategy)
					this.iRejectedStrategy.dispose()

			this.iRejectedStrategy := values.RejectedStrategy
		}

		if values.HasProp("PitstopHistory")
			this.iPitstopHistory := values.PitstopHistory

		if values.HasProp("UsedTyreSets")
			this.iUsedTyreSets := values.UsedTyreSets
	}

	confirmAction(action) {
		local confirmation := getMultiMapValue(this.Settings, "Assistant.Strategist", "Confirm." . action, "Always")

		switch confirmation, false {
			case "Always":
				confirmation := true
			case "Never":
				confirmation := false
			case "Listening":
				confirmation := (this.Listener != false)
			default:
				throw "Unsupported action confirmation detected in RaceStrategist.confirmAction..."
		}

		switch action, false {
			case "Pitstop.Plan", "Strategy.Update", "Strategy.Explain":
				if inList(["Yes", true], this.Autonomy)
					return false
				else if inList(["No", false], this.Autonomy)
					return true
				else
					return confirmation
			case "Strategy.Weather", "Strategy.Cancel":
				return confirmation
			default:
				return super.confirmAction(action)
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
				switch getMultiMapValue(this.Settings, "Assistant.Strategist", "CarCategories", "Classes"), false {
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

	getCarIndicatorFragment(speaker, number, position) {
		local indicator := getMultiMapValue(this.Settings, "Assistant.Strategist", "CarIndicator", "Position")

		if ((indicator = "Position") && position)
			return substituteVariables(this.getSpeaker().Fragments["CarPosition"], {position: position})
		else if ((indicator = "Both") && number && position)
			return substituteVariables(this.getSpeaker().Fragments["CarBoth"], {number: number, position: position})
		else if ((indicator = "Number") && number)
			return substituteVariables(this.getSpeaker().Fragments["CarNumber"], {number: number})

		return super.getCarIndicatorFragment(speaker, number, position)
	}

	handleVoiceCommand(grammar, words) {
		switch grammar, false {
			case "LapsRemaining":
				this.lapsRemainingRecognized(words)
			case "Weather":
				this.weatherRecognized(words)
			case "FuturePosition":
				this.futurePositionRecognized(words)
			case "StrategyOverview":
				this.strategyOverviewRecognized(words)
			case "CancelStrategy":
				this.cancelStrategyRecognized(words)
			case "NextPitstop":
				this.nextPitstopRecognized(words)
			case "StrategyRecommend":
				if !this.confirmCommand()
					return

				this.recommendStrategyRecognized(words)
			case "FCYRecommend":
				if !this.confirmCommand()
					return

				this.fullCourseYellowRecognized(words)
			case "PitstopRecommend":
				if !this.confirmCommand()
					return

				this.recommendPitstopRecognized(words)
			case "PitstopSimulate":
				if !this.confirmCommand()
					return

				this.simulatePitstopRecognized(words)
			default:
				super.handleVoiceCommand(grammar, words)
		}
	}

	getKnowledge(type, options := false) {
		local knowledgeBase := this.KnowledgeBase
		local knowledge := super.getKnowledge(type, options)
		local volumeUnit := ((type != "Agent") ? (A_Space . getUnit("Volume")) : " Liters")
		local percent := " %"
		local strategy, nextPitstop, pitstop, pitstops
		local availableTyreSets, tyreSets, tyreSet, ignore, tyreLife, strategy, rules
		local fuelService, tyreService, brakeService, repairService, supportTyreSets, tyreCompound, tyreCompoundColor, tcCandidate
		local lapNumber, lap, lapNr, tyres, tyreWear, postfix, tyre

		convert(unit, value, arguments*) {
			if (type != "Agent")
				return convertUnit(unit, value, arguments*)
			else if isNumber(value)
				return Round(value, 2)
			else
				return value
		}

		getPastPitstop(pitstop) {
			local tyreChange := false
			local pastPitstop, repairs
			local index, tyre, axle

			try {
				pastPitstop := Map("Nr", pitstop.Nr, "Lap", pitstop.Lap)

				if fuelService
					pastPitstop["Refuel"] := (pitstop["Refuel"] . " Liters")

				if (repairService.Length > 0) {
					repairs := (pitstop.RepairBodywork || pitstop.RepairSusension || pitstop.RepairEngine)

					pastPitstop["Repairs"] := (repairs ? kTrue : kFalse)
				}

				if tyreService {
					if (tyreService = "Wheel") {
						for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
							pastPitstop["TyreChange" . tyre] := ((pitstop.%"TyreCompound" . tyre%) ? kTrue : kFalse)

							if (pastPitstop["TyreChange" . tyre] = kTrue) {
								tyreChange := true

								pastPitstop["TyreCompound" . tyre] := compound(pitstop.%"TyreCompound" . tyre%, pitstop.%"TyreCompoundColor" . tyre%)
							}
						}
					}
					else if (tyreService = "Axle") {
						for index, axle in ["Front", "Rear"] {
							pastPitstop["TyreChange" . axle] := ((pitstop.%"TyreCompound" . axle%) ? kTrue : kFalse)

							if (pastPitstop["TyreChange" . axle] = kTrue) {
								tyreChange := true

								pastPitstop["TyreCompound" . axle] := compound(pitstop.%"TyreCompound" . axle%, pitstop.%"TyreCompoundColor" . axle%)
							}
						}
					}
					else {
						tyreChange := pitstop.TyreCompound

						if tyreChange
							pastPitstop["TyreCompound"] := compound(pitstop.TyreCompound, pitstop.TyreCompoundColor)
					}

					pastPitstop["TyreChange"] := (tyreChange ? kTrue : kFalse)

					if (tyreChange && supportTyreSets && pastPitstop.HasProp("TyreSet"))
						pastPitstop["TyreSet"] := pastPitstop.TyreSet
				}

				return pastPitstop
			}
			catch Any as exception {
				logError(exception)

				return false
			}
		}

		if knowledgeBase {
			this.Provider.supportsPitstop(&fuelService, &tyreService, &brakeService, &repairService)
			this.Provider.supportsTyreManagement( , &supportTyreSets)

			if this.activeTopic(options, "Session") {
				strategy := this.Strategy

				if strategy {
					try {
						rules := {RequiredPitstops: strategy.PitstopRule
								, Refuel: strategy.RefuelRule, TyreChange: strategy.TyreChangeRule
								, MaxStintDuration: strategy.StintLength . " Minutes"}

						if isObject(strategy.PitstopWindow) {
							rules.PitstopFrom := (strategy.PitstopWindow[1] . " Minute")
							rules.PitstopTo := (strategy.PitstopWindow[2] . " Minute")
						}

						knowledge["Session"]["Rules"] := toMap(rules)

						availableTyreSets := strategy.AvailableTyreSets
						tyreSets := knowledge["Session"]["AvailableTyres"]

						for ignore, tyreCompound in SessionDatabase.getTyreCompounds(this.Simulator, this.Car, this.Track) {
							tcCandidate := tyreCompound

							tyreSet := first(tyreSets, (ts) => (ts["Compound"] = tcCandidate))

							if (tyreSet && availableTyreSets.Has(tyreCompound))
								if (availableTyreSets[tyreCompound][2].Length > 0) {
									tyreSet["Sets"] := availableTyreSets[tyreCompound][2].Length

									tyreSet["UsableLaps"] := availableTyreSets[tyreCompound][1]
								}
								else
									tyreSets.RemoveAt(inList(tyreSets, tyreSet))
						}
					}
					catch Any as exception {
						logError(exception, true)
					}
				}
				else
					try {
						tyreSets := knowledge["Session"]["AvailableTyres"]

						for ignore, tyreCompound in SessionDatabase.getTyreCompounds(this.Simulator, this.Car, this.Track) {
							tcCandidate := tyreCompound

							splitCompound(tyreCompound, &tyreCompound, &tyreCompoundColor)

							tyreLife := knowledgeBase.getValue("Session.Settings.Tyre." . tyreCompound . "." . tyreCompoundColor . ".Laps.Max"
															 , kUndefined)

							if (tyreLife != kUndefined) {
								tyreSet := first(tyreSets, (ts) => (ts["Compound"] = tcCandidate))

								if tyreSet
									tyreSet["UsableLaps"] := tyreLife
							}
						}
					}
					catch Any as exception {
						logError(exception, true)
					}
			}

			if (knowledgeBase.getValue("Strategy.Name", false) && this.activeTopic(options, "Strategy"))
				try {
					strategy := Map("NumPitstops", knowledgeBase.getValue("Strategy.Pitstop.Count"))

					knowledge["Strategy"] := strategy

					nextPitstop := knowledgeBase.getValue("Strategy.Pitstop.Next", false)

					if nextPitstop {
						pitstop := Map("Nr", nextPitstop
									 , "Lap", (knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Lap")))

						if fuelService
							pitstop["Refuel"] := (convert("Volume", knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Fuel.Amount")) . volumeUnit)

						if knowledgeBase.getValue("Strategy.Pitstop.Position", false)
							pitstop["Position"] := knowledgeBase.getValue("Strategy.Pitstop.Position")

						if knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Change", false) {
							pitstop["TyreChange"] := kTrue

							tyreCompound := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Compound")
							tyreCompoundColor := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Compound.Color")

							pitstop["TyreCompound"] := compound(tyreCompound, tyreCompoundColor)

							if (tyreService = "Wheel") {
								for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"]
									pitstop["TyreCompound" . tyre] := pitstop["TyreCompound"]
							}
							else if (tyreService = "Axle")
								for index, axle in ["Front", "Rear"]
									pitstop["TyreCompound" . axle] := pitstop["TyreCompound"]
						}
						else
							pitstop["TyreChange"] := kFalse

						strategy["NextPitstop"] := pitstop
					}
				}
				catch Any as exception {
					logError(exception, true)
				}

			if (this.activeTopic(options, "Laps") && knowledge.Has("Laps"))
				try {
					for ignore, lap in knowledge["Laps"] {
						lapNr := lap["Nr"]

						if (knowledgeBase.getValue("Lap." . lapNr . ".Tyre.Wear.FL", kUndefined) != kUndefined) {
							tyreWear := Map()

							for postfix, tyre in Map("FL", "FrontLeft", "FR", "FrontRight"
												   , "RL", "RearLeft", "RR", "RearRight")
								tyreWear[tyre] := (knowledgeBase.getValue("Lap." . lapNr . ".Tyre.Wear." . postfix, 0) . percent)

							tyres := Map()
							tyres["Wear"] := tyreWear

							lap["Tyres"] := tyres
						}
					}
				}
				catch Any as exception {
					logError(exception, true)
				}

			if this.activeTopic(options, "Tyres")
				try {
					lapNumber := knowledgeBase.getValue("Lap", 0)

					if (knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Wear.FL", kUndefined) != kUndefined)
						knowledge["Tyres"]["Wear"]
							:= Map("FrontLeft", (knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Wear.FL", 0) . percent)
							     , "FrontRight", (knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Wear.FR", 0) . percent)
							     , "RearLeft", (knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Wear.RL", 0) . percent)
							     , "RearRight", (knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Wear.RR", 0) . percent))
				}
				catch Any as exception {
					logError(exception, true)
				}

			if this.activeTopic(options, "Pitstops") {
				pitstops := []

				if ((type = "Agent") && this.PitstopHistory) {
					try {
						pitstops := collect(this.PitstopHistory, getPastPitstop)

						if (this.UsedTyreSets && (this.UsedTyreSets.Length > 0))
							knowledge["TyreSets"] := collect(this.UsedTyreSets, (ts) {
														 local tyreSet := Map("Laps", ts.Laps
																			, "TyreCompound", compound(ts.Compound, ts.CompoundColor))

														 if ts.HasProp("Set")
															 tyreSet["Set"] := ts.Set

														 return tyreSet
													 })
					}
					catch Any as exception {
						logError(exception, true)
					}
				}
				else
					try {
						loop knowledgeBase.getValue("Pitstop.Last", 0)
							if (knowledgeBase.getValue("Pitstop." . A_Index . ".Lap", kUndefined) != kUndefined)
								pitstops.Push(Map("Nr", pitstops.Length + 1
												, "Lap", knowledgeBase.getValue("Pitstop." . A_Index . ".Lap")))
					}
					catch Any as exception {
						logError(exception, true)
					}

				knowledge["Pitstops"] := pitstops
			}
		}

		return knowledge
	}

	requestInformation(category, arguments*) {
		switch category, false {
			case "LapsRemaining":
				this.lapsRemainingRecognized([])
			case "Weather":
				this.weatherRecognized([])
			case "StrategyOverview":
				this.strategyOverviewRecognized([])
			case "NextPitstop":
				this.nextPitstopRecognized([])
			default:
				super.requestInformation(category, arguments*)
		}
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

	positionRecognized(words) {
		if inList(words, this.getSpeaker().Fragments["Laps"])
			this.futurePositionRecognized(words)
		else
			super.positionRecognized(words)
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
		local pitstopLap

		if !this.hasEnoughData()
			return

		this.reportStrategy({Strategy: false, Pitstops: false, NextPitstop: true})

		pitstopLap := this.KnowledgeBase.getValue("Strategy.Pitstop.Lap", false)

		if (pitstopLap && ProcessExist("Race Engineer.exe"))
			this.confirmNextPitstop(pitstopLap, true)
	}

	recommendStrategyRecognized(words) {
		if !this.hasEnoughData()
			return

		this.proposeStrategy()
	}

	fullCourseYellowRecognized(words) {
		if !this.hasEnoughData()
			return

		this.proposeStrategy({FullCourseYellow: true})
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

		this.proposePitstop(lap)
	}

	confirmNextPitstop(pitstopLap, confirm := false) {
		local knowledgeBase := this.KnowledgeBase
		local nextPitstop, refuel, tyreChange, tyreCompound, tyreCompoundColor

		if ProcessExist("Race Engineer.exe") {
			nextPitstop := knowledgeBase.getValue("Strategy.Pitstop.Next")

			refuel := Round(knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Fuel.Amount"), 1)
			tyreChange := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Change")

			if tyreChange {
				tyreCompound := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Compound")
				tyreCompoundColor := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Compound.Color")
			}
			else {
				tyreCompound := false
				tyreCompoundColor := false
			}

			if (knowledgeBase.getValue("Strategy.Pitstop.Count") > nextPitstop)
				refuel := ("!" . refuel)

			if (confirm || this.confirmAction("Pitstop.Plan")) {
				this.getSpeaker().speakPhrase("ConfirmInformEngineer", false, true)

				this.setContinuation(ObjBindMethod(this, "planPitstop", pitstopLap, refuel, "!" . tyreChange, tyreCompound, tyreCompoundColor))
			}
			else
				this.planPitstop(pitstopLap, refuel, "!" . tyreChange, tyreCompound, tyreCompoundColor)
		}
	}

	reviewRace(multiClass, cars, laps, position, leaderAvgLapTime
			 , driverAvgLapTime, driverMinLapTime, driverMaxLapTime, driverLapTimeStdDev) {
		local knowledgeBase := this.KnowledgeBase
		local split, class, speaker, continuation, only, driver, goodPace

		try {
			if ((this.Session = kSessionRace) && this.hasEnoughData(false) && (position != 0) && isInteger(position) && this.Speaker) {
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
		}
		catch Any as exception {
			logError(exception)
		}

		continuation := this.ActiveContinuation

		if isInstance(continuation, RaceStrategist.RaceReviewContinuation) {
			this.clearContinuation()

			continuation.continue()
		}
	}

	updateCarStatistics(statistics) {
		local continuation := this.ActiveContinuation
		local fileName

		if !isObject(statistics) {
			fileName := statistics

			statistics := readMultiMap(fileName)

			if !isDebug()
				deleteFile(fileName)
		}

		if isInstance(continuation, RaceStrategist.RaceStrategySimulationContinuation) {
			this.clearContinuation()

			continuation.continue(statistics)
		}
	}

	collectLapsData() {
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
			case kSessionTimeTrial:
				session := "Time Trial"
		}

		return getMultiMapValue(this.Settings, "Session Settings", "Telemetry." . session, default)
	}

	loadStrategy(strategy, facts, lastLap := false, lastPitstop := false, lastPitstopLap := false) {
		local pitstopWindow := (this.Settings ? getMultiMapValue(this.Settings, "Strategy Settings", "Strategy.Window.Considered", 3) : 3)
		local fullCourseYellow, forcedPitstop, pitstop, count, ignore, pitstopLap, pitstopMaxLap, rootStrategy, pitstopDeviation, skip

		facts.Delete("Strategy.Pitstop.Next")

		if !strategy.HasProp("RunningPitstops")
			strategy.RunningPitstops := 0
		if !strategy.HasProp("RunningLaps")
			strategy.RunningLaps := 0
		if !strategy.HasProp("RunningTime")
			strategy.RunningTime := 0
		if !strategy.HasProp("FullCourseYellow")
			strategy.FullCourseYellow := false
		if !strategy.HasProp("ForcedPitstop")
			strategy.ForcedPitstop := false

		fullCourseYellow := strategy.FullCourseYellow
		forcedPitstop := strategy.ForcedPitstop

		facts["Strategy.Name"] := strategy.Name
		facts["Strategy.Version"] := strategy.Version

		facts["Strategy.Weather"] := strategy.Weather
		facts["Strategy.Weather.Temperature.Air"] := strategy.AirTemperature
		facts["Strategy.Weather.Temperature.Track"] := strategy.TrackTemperature

		facts["Strategy.Tyre.Compound"] := strategy.TyreCompound
		facts["Strategy.Tyre.Compound.Color"] := strategy.TyreCompoundColor

		facts["Strategy.Map"] := strategy.Map
		facts["Strategy.TC"] := strategy.TC
		facts["Strategy.ABS"] := strategy.ABS
		facts["Strategy.BB"] := strategy.BB

		pitstopDeviation := getMultiMapValue(this.Settings, "Strategy Settings", "Strategy.Update.Pitstop", 0)

		facts["Strategy.Pitstop.Deviation"] := Max(3, pitstopDeviation, pitstopWindow)

		pitstopMaxLap := (strategy.StartLap + strategy.StintLaps["Max"])

		count := 0

		for ignore, pitstop in strategy.Pitstops {
			skip := false

			if !fullCourseYellow
				if ((lastPitstop && (pitstop.Nr <= lastPitstop)) || (lastPitstopLap && (Abs(pitstop.Lap - lastPitstopLap) <= pitstopWindow))
																 || (lastLap && (pitstop.Lap < lastLap)))
					skip := true

			pitstopLap := pitstop.Lap

			count += 1

			if (!skip && !facts.Has("Strategy.Pitstop.Next")) {
				facts["Strategy.Pitstop.Next"] := count
				facts["Strategy.Pitstop.Lap"] := pitstopLap

				if isInstance(strategy, RaceStrategist.TrafficRaceStrategy)
					facts["Strategy.Pitstop.Position"] := pitstop.getPosition()
			}

			facts["Strategy.Pitstop." . A_Index . ".Lap"] := pitstopLap
			facts["Strategy.Pitstop." . A_Index . ".Lap.Max"] := pitstopMaxLap
			facts["Strategy.Pitstop." . A_Index . ".Fuel.Amount"] := pitstop.RefuelAmount
			facts["Strategy.Pitstop." . A_Index . ".Tyre.Change"] := pitstop.TyreChange
			facts["Strategy.Pitstop." . A_Index . ".Tyre.Compound"] := pitstop.TyreCompound
			facts["Strategy.Pitstop." . A_Index . ".Tyre.Compound.Color"] := pitstop.TyreCompoundColor
			facts["Strategy.Pitstop." . A_Index . ".Map"] := pitstop.Map

			pitstopMaxLap := (pitstopLap + pitstop.StintLaps["Max"])
		}

		facts["Strategy.Pitstop.Count"] := count

		return facts
	}

	readSettings(simulator, car, track, &settings) {
		local facts, compound, tyreLife, tyreCompound, tyreCompoundColor

		facts := combine(super.readSettings(simulator, car, track, &settings)
					   , CaseInsenseMap("Session.Settings.Standings.Extrapolation.Laps", getMultiMapValue(settings, "Strategy Settings"
																												  , "Extrapolation.Laps", 3)
									  , "Session.Settings.Standings.Extrapolation.Overtake.Delta", Round(getMultiMapValue(settings
																													    , "Strategy Settings"
																													    , "Overtake.Delta", 1) * 1000)
									  , "Session.Settings.Strategy.Traffic.Considered", (getMultiMapValue(settings, "Strategy Settings"
																												  , "Traffic.Considered", 5) / 100)
									  , "Session.Settings.Pitstop.Delta", getMultiMapValue(settings, "Strategy Settings", "Pitstop.Delta"
																								   , getMultiMapValue(settings, "Session Settings"
																															, "Pitstop.Delta", 60))
									  , "Session.Settings.Pitstop.Service.Last", getMultiMapValue(settings, "Session Settings", "Pitstop.Service.Last", 5)
									  , "Session.Settings.Pitstop.Service.Refuel.Rule", getMultiMapValue(settings, "Strategy Settings"
																											     , "Service.Refuel.Rule", "Dynamic")
									  , "Session.Settings.Pitstop.Service.Refuel.Duration", getMultiMapValue(settings, "Strategy Settings"
																												     , "Service.Refuel", 1.8)
									  , "Session.Settings.Pitstop.Service.Tyres.Duration", getMultiMapValue(settings, "Strategy Settings"
																											        , "Service.Tyres", 30)
									  , "Session.Settings.Pitstop.Service.Order", getMultiMapValue(settings, "Strategy Settings"
																										   , "Service.Order", "Simultaneous")
									  , "Session.Settings.Pitstop.Strategy.Window.Considered", getMultiMapValue(settings, "Strategy Settings"
																													  , "Strategy.Window.Considered", 3)))

		this.updateConfigurationValues({UseTraffic: getMultiMapValue(settings, "Strategy Settings", "Traffic.Simulation", false)})

		if (getMultiMapValue(settings, "Session Settings", "Tyre.Compound.Usage", kUndefined) != kUndefined)
			for compound, tyreLife in string2Map(";", "->", getMultiMapValue(settings, "Session Settings", "Tyre.Compound.Usage")) {
				splitCompound(compound, &tyreCompound, &tyreCompoundColor)

				facts["Session.Settings.Tyre." . tyreCompound . "." . tyreCompoundColor . ".Laps.Max"] := tyreLife
			}

		return facts
	}

	createRaceData(data) {
		local raceData := newMultiMap()
		local carCount := getMultiMapValue(data, "Position Data", "Car.Count", 0)
		local carCategory

		setMultiMapValue(raceData, "Cars", "Count", carCount)
		setMultiMapValue(raceData, "Cars", "Driver", getMultiMapValue(data, "Position Data", "Driver.Car"))

		loop carCount {
			setMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Nr", getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Nr", "-"))
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

		return raceData
	}

	prepareSession(&settings, &data, formationLap?) {
		local prepared := this.Prepared
		local simulatorName, theStrategy, applicableStrategy, simulator, car, track, facts
		local sessionType, sessionLength, duration, laps

		facts := super.prepareSession(&settings, &data, formationLap?)

		if (!prepared && (getMultiMapValue(data, "Stint Data", "Laps", 0) = 0))
			this.updateSessionValues({RaceInfo: false})

		if (!prepared && settings)
			this.updateConfigurationValues({UseTalking: getMultiMapValue(settings, "Assistant.Strategist", "Voice.UseTalking", false)
										  , UseTraffic: getMultiMapValue(settings, "Strategy Settings", "Traffic.Simulation", false)})

		if (!this.RaceInfo || (isSet(formationLap) && formationLap))
			this.updateRaceInfo(this.createRaceData(data))

		if ((this.Session == kSessionRace) && (getMultiMapValue(data, "Stint Data", "Laps", 0) < 5)
										   && FileExist(kUserConfigDirectory . "Race.strategy")
										   && (!this.Strategy || !this.KnowledgeBase || (this.KnowledgeBase.getValue("Strategy.Name", false) != this.Strategy.Name))) {
			theStrategy := RaceStrategist.RaceStrategy(this, readMultiMap(kUserConfigDirectory . "Race.strategy"), SessionDatabase.ID, [])

			applicableStrategy := false

			simulator := theStrategy.Simulator
			car := theStrategy.Car
			track := theStrategy.Track

			if ((simulator = this.SettingsDatabase.getSimulatorName(this.Simulator)) && (car = facts["Session.Car"]) && (track = facts["Session.Track"]))
				applicableStrategy := true

			if applicableStrategy {
				sessionType := theStrategy.SessionType
				sessionLength := theStrategy.SessionLength

				if ((sessionType = "Duration") && (facts["Session.Format"] = "Time")) {
					duration := (facts["Session.Duration"] / 60)

					if ((duration = 0) || ((Abs(sessionLength - duration) / duration) >  0.1))
						applicableStrategy := false
				}
				else if ((sessionType = "Laps") && (facts["Session.Format"] = "Laps")) {
					laps := facts["Session.Laps"]

					if ((Abs(sessionLength - laps) / laps) >  0.05)
						applicableStrategy := false
				}
				else
					applicableStrategy := false

				if applicableStrategy {
					this.loadStrategy(theStrategy, facts)

					this.updateSessionValues({OriginalStrategy: theStrategy, Strategy: theStrategy})

					if this.Debug[kStrategyProtocol] {
						DirCreate(kTempDirectory . "Race Strategist\Strategy")

						FileCopy(kUserConfigDirectory . "Race.strategy"
							   , kTempDirectory . "Race Strategist\Strategy\Original " . this.iDebugStrategyCounter[1]++ . ".strategy", 1)
					}
				}
			}
		}

		return facts
	}

	loadRules(data) {
		if ((this.Session == kSessionRace) && (getMultiMapValue(this.Settings, "Session Rules", "Strategy", "No") = "Yes")
		 && !this.Strategy && !this.StrategyCreated && (getMultiMapValue(data, "Stint Data", "Laps", 0) <= 10)
		 && this.hasEnoughData(false)) {
			this.recommendStrategy({Silent: true, Confirm: false, Request: "Rules"})

			if this.Strategy
				this.updateDynamicValues({StrategyCreated: true})
		}
	}

	updateSettings(settings, edit := false) {
		super.updateSettings(settings)

		if (settings && edit)
			this.updateConfigurationValues({UseTraffic: getMultiMapValue(settings, "Strategy Settings", "Traffic.Simulation", false)})
	}

	startSession(settings, data) {
		local configuration := this.Configuration
		local facts := this.prepareSession(&settings, &data, false)
		local raceEngineer := (ProcessExist("Race Engineer.exe") > 0)
		local simulator, saveSettings, deprecated, lapsDB

		if raceEngineer
			saveSettings := kNever
		else {
			deprecated := getMultiMapValue(configuration, "Race Engineer Shutdown", this.Simulator . ".SaveSettings", kNever)
			saveSettings := getMultiMapValue(configuration, "Race Assistant Shutdown", this.Simulator . ".SaveSettings", deprecated)
		}

		this.updateConfigurationValues({LearningLaps: getMultiMapValue(configuration, "Race Strategist Analysis", this.Simulator . ".LearningLaps", 1)
									  , SessionReportsDatabase: normalizeDirectoryPath(getMultiMapValue(configuration, "Race Strategist Reports", "Database", false))
									  , CollectLaps: this.collectLapsData()
									  , SaveTelemetry: getMultiMapValue(configuration, "Race Strategist Shutdown", this.Simulator . ".SaveTelemetry", kAlways)
									  , SaveRaceReport: getMultiMapValue(configuration, "Race Strategist Shutdown", this.Simulator . ".SaveRaceReport", kNever)
									  , RaceReview: (getMultiMapValue(configuration, "Race Strategist Shutdown", this.Simulator . ".RaceReview", "Yes") = "Yes")
									  , SaveSettings: saveSettings})

		lapsDB := RaceStrategist.SessionLapsDatabase(this)

		lapsDB.Database.clear("Electronics")
		lapsDB.Database.clear("Tyres")
		lapsDB.Database.flush()

		this.updateSessionValues({LapsDatabase: lapsDB})

		if !this.KnowledgeBase
			this.updateDynamicValues({KnowledgeBase: this.createKnowledgeBase(facts)})

		this.updateDynamicValues({HasLapsData: false, BestLapTime: 0, OverallTime: 0
								, LastFuelAmount: 0, InitialFuelAmount: 0, LastEnergyAmount: 0, InitialEnergyAmount: 0
								, EnoughData: false, StrategyReported: (getMultiMapValue(data, "Stint Data", "Laps", 0) > 1)})

		if (this.Speaker[false] && !raceEngineer && (this.Session = kSessionRace) && !this.Greeted) {
			this.getSpeaker().speakPhrase("Greeting")

			this.updateDynamicValues({Greeted: true})
		}

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledgeBase(this.KnowledgeBase)
	}

	finishSession(shutdown := true, review := true) {
		local knowledgeBase := this.KnowledgeBase
		local lastLap, asked

		forceFinishSession() {
			if !this.SessionDataActive {
				if (this.KnowledgeBase && this.RemoteHandler)
					this.RemoteHandler.shutdown(ProcessExist())

				this.updateDynamicValues({KnowledgeBase: false, Prepared: false, Greeted: false})

				this.finishSession()

				return false
			}
			else {
				Task.CurrentTask.Sleep := 5000

				return Task.CurrentTask
			}
		}

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

			if (shutdown && !review && !ProcessExist("Race Engineer.exe") && this.Speaker[false])
				this.getSpeaker().speakPhrase("Bye")

			if (shutdown && (lastLap > this.LearningLaps)) {
				this.shutdownSession("Before")

				asked := true

				if this.Speaker[false] {
					if ProcessExist("Solo Center.exe") {
						if (((this.SaveSettings = kAsk) && (this.Session == kSessionRace))
						 && ((this.SaveRaceReport = kAsk) && (this.Session == kSessionRace)))
							this.getSpeaker().speakPhrase("ConfirmSaveSettingsAndRaceReport", false, true)
						else if ((this.SaveRaceReport = kAsk) && (this.Session == kSessionRace))
							this.getSpeaker().speakPhrase("ConfirmSaveRaceReport", false, true)
						else if ((this.SaveSettings = kAsk) && (this.Session == kSessionRace))
							this.getSpeaker().speakPhrase("ConfirmSaveSettings", false, true)
						else
							asked := false
					}
					else {
						if ((((this.SaveSettings = kAsk) && (this.Session == kSessionRace))
						  || (this.CollectLaps && (this.SaveTelemetry = kAsk) && this.HasLapsData))
						 && ((this.SaveRaceReport = kAsk) && (this.Session == kSessionRace)))
							this.getSpeaker().speakPhrase("ConfirmSaveSettingsAndRaceReport", false, true)
						else if ((this.SaveRaceReport = kAsk) && (this.Session == kSessionRace))
							this.getSpeaker().speakPhrase("ConfirmSaveRaceReport", false, true)
						else if (((this.SaveSettings = kAsk) && (this.Session == kSessionRace))
							  || (this.CollectLaps && (this.SaveTelemetry = kAsk) && this.HasLapsData))
							this.getSpeaker().speakPhrase("ConfirmSaveSettings", false, true)
						else
							asked := false
					}
				}
				else
					asked := false

				if asked {
					this.setContinuation(ObjBindMethod(this, "shutdownSession", "After", true)
									   , ObjBindMethod(this, "shutdownSession", "After", false))

					Task.startTask(forceFinishSession, 120000, kLowPriority)

					return
				}
				else
					this.shutdownSession("After")
			}

			if this.RemoteHandler
				this.RemoteHandler.shutdown(ProcessExist())

			this.updateDynamicValues({KnowledgeBase: false, Prepared: false, Greeted: false})
		}

		this.updateDynamicValues({OverallTime: 0, BestLapTime: 0
								, LastFuelAmount: 0, InitialFuelAmount: 0, LastEnergyAmount: 0, InitialEnergyAmount: 0
								, EnoughData: false
								, StrategyReported: false, RejectedStrategy: false, StrategyCreated: false
								, HasLapsData: false})
		this.updateSessionValues({Simulator: "", Car: "", Track: "", Session: kSessionFinished
								, OriginalStrategy: false, Strategy: false, SessionTime: false})
	}

	finishSessionWithReview(shutdown) {
		local categories

		if this.RemoteHandler {
			this.setContinuation(RaceStrategist.RaceReviewContinuation(this, ObjBindMethod(this, "finishSession", shutdown, false)))

			switch getMultiMapValue(this.Settings, "Assistant.Strategist", "CarCategories", "Classes"), false {
				case "All":
					categories := ["Class", "Cup"]
				case "Classes":
					categories := ["Class"]
				case "Cups":
					categories := ["Cup"]
				default:
					categories := ["Class"]
			}

			Task.startTask(() => this.RemoteHandler.reviewRace(values2String("|", categories*)), 5000, kLowPriority)
		}
		else
			this.finishSession(shutdown, false)
	}

	shutdownSession(phase, confirmed := false) {
		local reportSaved := false

		this.iSessionDataActive := true

		try {
			if ((phase = "Before") && this.CollectSessionKnowledge)
				this.saveSessionKnowledge("Finish")

			if (((phase = "After") && (this.SaveSettings = kAsk) && confirmed) || ((phase = "Before") && (this.SaveSettings = kAlways)))
				if (this.Session == kSessionRace)
					this.saveSessionSettings()

			if (((phase = "After") && (this.SaveRaceReport = kAsk) && confirmed) || ((phase = "Before") && (this.SaveRaceReport = kAlways)))
				if (this.Session == kSessionRace) {
					reportSaved := true

					this.createRaceReport()
				}

			if (((phase = "After") && (this.SaveTelemetry = kAsk) && confirmed) || ((phase = "Before") && (this.SaveTelemetry = kAlways)))
				if (this.HasLapsData && this.CollectLaps && !ProcessExist("Solo Center.exe"))
					this.updateLapsDatabase()
		}
		finally {
			this.iSessionDataActive := false
		}

		if (phase = "After") {
			if (this.Speaker[false] && reportSaved)
				this.getSpeaker().speakPhrase("RaceReportSaved")

			if (this.KnowledgeBase && this.RemoteHandler)
				this.RemoteHandler.shutdown(ProcessExist())

			this.updateDynamicValues({KnowledgeBase: false, HasLapsData: false})

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

	createSessionInfo(simulator, car, track, lapNumber, valid, data) {
		local knowledgeBase := this.KnowledgeBase
		local sessionInfo := super.createSessionInfo(simulator, car, track, lapNumber, valid, data)
		local lastPitstop := knowledgeBase.getValue("Pitstop.Last", false)
		local tyreLaps := false
		local nextPitstop, pitstop, ignore, theFact
		local fuelService, tyreService, index, tyre, axle, tyreCompound, tyreCompoundColor
		local ignore, pitstop, stintLaps

		if (knowledgeBase && knowledgeBase.getValue("Strategy.Name", false)) {
			this.Provider.supportsPitstop(&fuelService, &tyreService)

			setMultiMapValue(sessionInfo, "Strategy", "Pitstops", knowledgeBase.getValue("Strategy.Pitstop.Count"))

			nextPitstop := knowledgeBase.getValue("Strategy.Pitstop.Next", false)

			if nextPitstop {
				setMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next", nextPitstop)

				setMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Lap", knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Lap"))

				if fuelService
					setMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Refuel", Round(knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Fuel.Amount"), 1))

				if knowledgeBase.getValue("Strategy.Pitstop.Position", false)
					setMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Position", knowledgeBase.getValue("Strategy.Pitstop.Position"))

				if knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Change", false) {
					tyreCompound := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Compound")
					tyreCompoundColor := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Compound.Color")
				}
				else {
					tyreCompound := false
					tyreCompoundColor := false
				}

				setMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Tyre.Compound", tyreCompound)
				setMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Tyre.Compound.Color", tyreCompoundColor)

				/*
				if (tyreService = "Wheel") {
					for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
						setMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Tyre.Compound." . tyre, tyreCompound)
						setMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Tyre.Compound.Color." . tyre, tyreCompoundColor)
					}
				}
				else if (tyreService = "Axle")
					for index, axle in ["Front", "Rear"] {
						setMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Tyre.Compound." . axle, tyreCompound)
						setMultiMapValue(sessionInfo, "Strategy", "Pitstop.Next.Tyre.Compound.Color." . axle, tyreCompoundColor)
					}
				*/
			}

			setMultiMapValue(sessionInfo, "Strategy", "Pitstop.Count"
						   , knowledgeBase.getValue("Strategy.Pitstop.Count", 0))

			loop getMultiMapValue(sessionInfo, "Strategy", "Pitstop.Count") {
				pitstop := A_Index

				for ignore, theFact in [".Fuel.Amount", ".Tyre.Change", ".Tyre.Compound", ".Tyre.Compound.Color", ".Map"]
					setMultiMapValue(sessionInfo, "Strategy", "Pitstop." . pitstop . theFact
								   , knowledgeBase.getValue("Strategy.Pitstop." . pitstop . theFact))

				setMultiMapValue(sessionInfo, "Strategy", "Pitstop." . pitstop . ".Lap"
							   , knowledgeBase.getValue("Strategy.Pitstop." . pitstop . ".Lap"))
			}
		}

		if (this.PitstopHistory && (this.PitstopHistory.Length > 0)) {
			pitstop := this.PitstopHistory[this.PitstopHistory.Length]

			stintLaps := (lapNumber - pitstop.Lap)

			if (pitstop.Nr >= lastPitstop)
				tyreLaps := values2String(",", pitstop.TyreLapsFrontLeft + stintLaps, pitstop.TyreLapsFrontRight + stintLaps
											 , pitstop.TyreLapsRearLeft + stintLaps, pitstop.TyreLapsRearRight + stintLaps)
		}
		else if lastPitstop
			stintLaps := (lapNumber - (knowledgeBase.getValue("Pitstop." . lastPitstop . ".Lap")))
		else
			stintLaps := lapNumber

		if !tyreLaps
			tyreLaps := values2String(",", lapNumber, lapNumber, lapNumber, lapNumber)

		setMultiMapValue(sessionInfo, "Tyres", "Laps", tyreLaps)

		return sessionInfo
	}

	updateSession(simulator, car, track, lapNumber, validLap, data) {
		local knowledgeBase := this.KnowledgeBase
		local engineerPID := ProcessExist("Race Engineer.exe")
		local strategy, tyreSets, ignore, descriptor, filename

		static lastTyreSets := false
		static lastStrategy := false
		static lastPitstop := false

		if knowledgeBase {
			if engineerPID {
				strategy := this.Strategy

				if strategy {
					tyreSets := []

					for ignore, descriptor in strategy.TyreSets
						if descriptor
							tyreSets.Push(values2String("#", descriptor[1], descriptor[2], descriptor[3], descriptor[4]))

					tyreSets := values2String("|", tyreSets*)

					if (tyreSets != lastTyreSets) {
						lastTyreSets := tyreSets

						messageSend(kFileMessage, "Race Engineer", "updateTyreUsage:" . tyreSets, engineerPID)
					}

					if (strategy != lastStrategy) {
						lastStrategy := strategy
						fileName := temporaryFilename("Race Rules", "json")

						rules := {RequiredPitstops: strategy.PitstopRule
								, Refuel: strategy.RefuelRule, TyreChange: strategy.TyreChangeRule
								, MaxStintDuration: strategy.StintLength . " Minutes"}

						if isObject(strategy.PitstopWindow) {
							rules.PitstopFrom := (strategy.PitstopWindow[1] . " Minute")
							rules.PitstopTo := (strategy.PitstopWindow[2] . " Minute")
						}

						FileAppend(JSON.print(rules, isDebug() ? "  " : ""), fileName)

						messageSend(kFileMessage, "Race Engineer", "updateRaceRules:" . fileName, engineerPID)
					}
				}

				if (this.TeamSession && (lastPitstop != knowledgeBase.getValue("Pitstop.Last", false))) {
					lastPitstop := knowledgeBase.getValue("Pitstop.Last", false)

					Task.startTask(() => messageSend(kFileMessage, "Race Engineer"
																 , "requestPitstopHistory:Race Strategist;updatePitstopHistory;" . ProcessExist()
																 , engineerPID)
												   , 60000, kLowPriority)
				}
			}

			this.saveSessionInfo(simulator, car, track, lapNumber
							   , this.createSessionInfo(simulator, car, track, lapNumber, validLap, data))
		}
	}

	addLap(lapNumber, &data) {
		local started := (lapNumber > 0)
		local driverForname := ""
		local driverSurname := ""
		local driverNickname := ""
		local knowledgeBase, result, lap, simulator, car, track, frequency, curContinuation
		local pitstop, prefix, validLap, lapState, weather, airTemperature, trackTemperature
		local mixedCompounds, compound, compoundColor
		local fuelConsumption, fuelRemaining, lapTime, map, tc, antiBS, bb, pressures, temperatures, wear, multiClass
		local sessionInfo, driverCar, driverID, lastTime, waterTemperature, oilTemperature

		static lastLap := 0

		if started {
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

			curContinuation := this.ActiveContinuation
		}
		else
			curContinuation := this.ActiveContinuation

		result := super.addLap(lapNumber, &data)

		knowledgeBase := this.KnowledgeBase

		simulator := knowledgeBase.getValue("Session.Simulator")
		car := knowledgeBase.getValue("Session.Car")
		track := knowledgeBase.getValue("Session.Track")

		if started {
			if !this.Strategy
				this.loadRules(data)

			if (lapNumber > 1) {
				driverForname := knowledgeBase.getValue("Driver.Forname", "John")
				driverSurname := knowledgeBase.getValue("Driver.Surname", "Doe")
				driverNickname := knowledgeBase.getValue("Driver.Nickname", "JD")
			}

			if ((lastLap < (lapNumber - 2)) && (driverName(driverForname, driverSurname, driverNickname) != this.DriverFullName))
				if this.Speaker[false]
					this.getSpeaker().speakPhrase(ProcessExist("Race Engineer.exe") ? "" : "WelcomeBack")

			lastLap := lapNumber

			if this.Strategy {
				lastTime := (getMultiMapValue(data, "Stint Data", "LapLastTime", 0) / 1000)

				this.Strategy.RunningLaps += 1
				this.Strategy.RunningTime += lastTime

				if (this.Strategy["Rejected"] && isInstance(this.Strategy["Rejected"], Strategy)) {
					this.Strategy["Rejected"].RunningLaps += 1
					this.Strategy["Rejected"].RunningTime += lastTime
				}

				if (!this.StrategyReported && this.hasEnoughData(false) && (this.Strategy == this.Strategy["Original"])) {
					if (this.Speaker[false] && this.Announcements["StrategySummary"])
						if this.confirmAction("Strategy.Explain") {
							this.getSpeaker().speakPhrase("ConfirmReportStrategy", false, true)

							this.setContinuation(ObjBindMethod(this, "reportStrategy"))
						}
						else {
							this.getSpeaker().speakPhrase("ReportStrategy")

							this.reportStrategy()
						}

					this.updateDynamicValues({StrategyReported: lapNumber})
				}
			}

			if !this.MultiClass
				this.adjustGaps(data)

			driverCar := knowledgeBase.getValue("Driver.Car", 0)
			validLap := true

			loop knowledgeBase.getValue("Car.Count") {
				lap := knowledgeBase.getValue("Car." . A_Index . ".Laps", knowledgeBase.getValue("Car." . A_Index . ".Lap", 0))

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

			if (this.Session = kSessionRace) {
				pitstop := knowledgeBase.getValue("Pitstop.Last", false)

				if pitstop
					pitstop := (lapNumber == (knowledgeBase.getValue("Pitstop." . pitstop . ".Lap") + 1))
			}
			else {
				pitstop := false
				driverID := knowledgeBase.getValue("Car." . driverCar . ".ID", kUndefined)

				if (driverID != kUndefined)
					for index, pitstop in this.Pitstops[driverID]
						if (pitstop.Lap = lapNumber)
							pitstop := true

				if pitstop
					this.updateDynamicValues({EnoughData: false})
			}

			if this.CollectLaps {
				prefix := "Lap." . lapNumber

				if validLap
					validLap := knowledgeBase.getValue(prefix . ".Valid", validLap)

				if !validLap
					lapState := "Invalid"
				else if this.hasEnoughData(false)
					lapState := "Valid"
				else
					lapState := "Warmup"

				weather := knowledgeBase.getValue(prefix . ".Weather")
				airTemperature := knowledgeBase.getValue(prefix . ".Temperature.Air")
				trackTemperature := knowledgeBase.getValue(prefix . ".Temperature.Track")
				compound := knowledgeBase.getValue(prefix . ".Tyre.Compound")
				compoundColor := knowledgeBase.getValue(prefix . ".Tyre.Compound.Color")
				fuelConsumption := Round(knowledgeBase.getValue(prefix . ".Fuel.Consumption"), 1)
				fuelRemaining := Round(knowledgeBase.getValue(prefix . ".Fuel.Remaining"), 1)
				lapTime := Round(knowledgeBase.getValue(prefix . ".Time") / 1000, 1)

				this.Provider.supportsTyreManagement(&mixedCompounds)

				if (mixedCompounds = "Wheel") {
					compound := collect(["FrontLeft", "FrontRight", "RearLeft", "RearRight"], (tyre) {
									return knowledgeBase.getValue(prefix . ".Tyre.Compound." . tyre, compound)
								})
					compoundColor := collect(["FrontLeft", "FrontRight", "RearLeft", "RearRight"], (tyre) {
										 return knowledgeBase.getValue(prefix . ".Tyre.Compound.Color." . tyre, compoundColor)
									 })

					combineCompounds(&compound, &compoundColor)
				}
				else if (mixedCompounds = "Axle") {
					compound := collect(["Front", "Rear"], (axle) {
									return knowledgeBase.getValue(prefix . ".Tyre.Compound." . axle, compound)
								})
					compoundColor := collect(["Front", "Rear"], (axle) {
										 return knowledgeBase.getValue(prefix . ".Tyre.Compound.Color." . axle, compoundColor)
									 })

					combineCompounds(&compound, &compoundColor)
				}
				else {
					compound := [compound]
					compoundColor := [compoundColor]
				}

				map := knowledgeBase.getValue(prefix . ".Map")
				tc := knowledgeBase.getValue(prefix . ".TC")
				antiBS := knowledgeBase.getValue(prefix . ".ABS")
				bb := knowledgeBase.getValue(prefix . ".BB")

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

				waterTemperature := knowledgeBase.getValue(prefix . ".Engine.Temperature.Water", kNull)
				oilTemperature := knowledgeBase.getValue(prefix . ".Engine.Temperature.Oil", kNull)

				this.saveLapData(lapNumber, simulator, car, track, weather, airTemperature, trackTemperature
							   , fuelConsumption, fuelRemaining, lapTime, pitstop, map, tc, antiBS, bb
							   , values2String(",", compound*), values2String(",", compoundColor*)
							   , pressures, temperatures, wear, lapState
							   , waterTemperature, oilTemperature)
			}

			if this.Strategy {
				frequency := getMultiMapValue(this.Settings, "Strategy Settings", "Strategy.Update.Laps", false)

				if (frequency && this.hasEnoughData(false)
							  && (lapNumber >= (this.BaseLap + knowledgeBase.getValue("Session.Settings.Lap.History.Considered", 5)))) {
					if ((lapNumber > (this.iLastStrategyUpdate + frequency)) && (curContinuation = this.ActiveContinuation))
						knowledgeBase.setFact("Strategy.Recalculate", "Regular")
				}
				else
					this.iLastStrategyUpdate := (lapNumber - 1)
			}

			if (!this.RaceInfo || (this.RaceInfo["Cars"] = 0))
				this.updateRaceInfo(this.createRaceData(data))

			if (this.GridPosition && knowledgeBase.getValue("Car.Count", false))
				this.saveStandingsData(lapNumber, simulator, car, track)
		}
		else
			validLap := knowledgeBase.getValue("Lap." . lapNumber . ".Valid", true)

		Task.startTask((*) => this.updateSession(simulator, car, track, lapNumber, validLap, data), 1000, kLowPriority)

		return result
	}

	updateLap(lapNumber, &data) {
		local knowledgeBase := this.KnowledgeBase
		local noGrid := !this.GridPosition
		local updateStrategy := false
		local started := (lapNumber > 0)
		local sector, result, valid
		local simulator, car, track

		static lastSector := 1

		if started {
			if !isObject(data)
				data := readMultiMap(data)

			sector := getMultiMapValue(data, "Stint Data", "Sector", 0)

			if (sector != lastSector) {
				lastSector := sector

				knowledgeBase.addFact("Sector", sector)

				updateStrategy := knowledgeBase.getValue("Strategy.Recalculate", false)
			}
		}

		result := super.updateLap(lapNumber, &data)

		if started {
			loop knowledgeBase.getValue("Car.Count") {
				valid := knowledgeBase.getValue("Car." . A_Index . ".Lap.Running.Valid", kUndefined)

				if (valid == false)
					knowledgeBase.setFact("Car." . A_Index . ".Valid.Running", false)
			}

			if !this.MultiClass
				this.adjustGaps(data)

			if (updateStrategy && this.hasEnoughData(false))
				this.recommendStrategy({Silent: true, Confirm: true, Request: updateStrategy})
		}

		simulator := knowledgeBase.getValue("Session.Simulator")
		car := knowledgeBase.getValue("Session.Car")
		track := knowledgeBase.getValue("Session.Track")

		if started {
			if (!this.RaceInfo || (this.RaceInfo["Cars"] = 0))
				this.updateRaceInfo(this.createRaceData(data))

			if (noGrid && this.GridPosition && (lapNumber < 5))
				this.saveStandingsData(lapNumber, simulator, car, track)
		}

		Task.startTask((*) => this.updateSession(simulator, car, track, lapNumber
											   , knowledgeBase.getValue("Lap." . lapNumber . ".Valid", true)
											   , data), 1000, kLowPriority)

		return result
	}

	createSessionKnowledge(lapNumber) {
		return this.getKnowledge("Agent", {include: ["Session", "Strategy"]})
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

					nextPitstop := ((strategy.Pitstops.Length > 0) ? strategy.Pitstops[1] : false)

					reported := (!nextPitstop && ((options == true) || (options.HasProp("NextPitstop") && options.NextPitstop)))

					if ((options == true) || (options.HasProp("Strategy") && options.Strategy)) {
						if !reported
							speaker.speakPhrase("Strategy")
					}
					else if (options.HasProp("FullCourseYellow") && options.FullCourseYellow)
						speaker.speakPhrase("FCYStrategy")

					if reported
						speaker.speakPhrase("NoNextPitstop")

					if !reported {
						if ((options == true) || (options.HasProp("Pitstops") && options.Pitstops)) {
							speaker.speakPhrase("Pitstops", {pitstops: strategy.Pitstops.Length})

							if activeStrategy {
								difference := (strategy.Pitstops.Length - (activeStrategy.Pitstops.Length - activeStrategy.RunningPitstops))

								if ((difference != 0) && ((difference > 0) || (strategy.Pitstops.Length > 0)))
									speaker.speakPhrase("PitstopsDifference", {difference: Abs(difference), pitstops: strategy.Pitstops.Length - difference
																			 , direction: (difference < 0) ? fragments["Less"] : fragments["More"]})
							}

							reported := (strategy.Pitstops.Length = 0)
						}

						if nextPitstop {
							lap := nextPitstop.Lap
							refuel := nextPitstop.RefuelAmount
							tyreChange := nextPitstop.TyreChange
							activePitstop := false

							if (activeStrategy && ((activeStrategy.Pitstops.Length - activeStrategy.RunningPitstops) > 0))
								activePitstop := activeStrategy.Pitstops[strategy.RunningPitstops + 1]

							if ((options == true) || (options.HasProp("NextPitstop") && options.NextPitstop)) {
								speaker.speakPhrase("NextPitstop", {pitstopLap: lap})

								if activePitstop {
									difference := (lap - activePitstop.Lap)

									if (difference != 0)
										speaker.speakPhrase("LapsDifference", {difference: Abs(difference), lap: activePitstop.Lap
																			 , label: (Abs(difference) = 1) ? fragments["Lap"] : fragments["Laps"]
																			 , direction: (difference < 0) ? fragments["Earlier"] : fragments["Later"]})
								}
							}

							if ((options == true) || (options.HasProp("Refuel") && options.Refuel)) {
								speaker.speakPhrase((refuel > 0) ? "Refuel" : "NoRefuel"
												  , {fuel: speaker.number2Speech(convertUnit("Volume", refuel), 1), unit: speaker.Fragments[getUnit("Volume")]})

								if activePitstop {
									difference := (refuel - activePitstop.RefuelAmount)

									if (difference != 0)
										speaker.speakPhrase("RefuelDifference", {difference: speaker.number2Speech(convertUnit("Volume", Abs(difference)), 1)
																			   , refuel: speaker.number2Speech(convertUnit("Volume", activePitstop.RefuelAmount), 1)
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
						else if ((options == true) || (options.HasProp("NextPitstop") && options.NextPitstop))
							if !reported
								speaker.speakPhrase("NoNextPitstop")
					}

					if ((options == true) || (options.HasProp("Map") && options.Map)) {
						map := strategy.Map

						if (map && (map != "n/a") && (map != knowledgeBase.getValue("Lap." . knowledgeBase.getValue("Lap") . ".Map", "n/a")))
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
						nextPitstop := knowledgeBase.getValue("Strategy.Pitstop.Next", false)

						reported := (!nextPitstop && ((options == true) || (options.HasProp("NextPitstop") && options.NextPitstop)))

						if !reported {
							if ((options == true) || (options.HasProp("Strategy") && options.Strategy))
								speaker.speakPhrase("Strategy")

							if ((options == true) || (options.HasProp("Pitstops") && options.Pitstops)) {
								speaker.speakPhrase("Pitstops", {pitstops: knowledgeBase.getValue("Strategy.Pitstop.Count")})

								reported := (knowledgeBase.getValue("Strategy.Pitstop.Count") = 0)
							}
						}

						if nextPitstop {
							if ((options == true) || (options.HasProp("NextPitstop") && options.NextPitstop)) {
								lap := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Lap")
								refuel := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Fuel.Amount")
								tyreChange := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Change")

								speaker.speakPhrase("NextPitstop", {pitstopLap: lap})

								if ((options == true) || (options.HasProp("Refuel") && options.Refuel))
									speaker.speakPhrase((refuel > 0) ? "Refuel" : "NoRefuel"
													  , {fuel: speaker.number2Speech(convertUnit("Volume", refuel), 1), unit: speaker.Fragments[getUnit("Volume")]})

								if ((options == true) || (options.HasProp("TyreChange") && options.TyreChange))
									speaker.speakPhrase(tyreChange ? "TyreChange" : "NoTyreChange")
							}
						}
						else if ((options == true) || (options.HasProp("NextPitstop") && options.NextPitstop))
							speaker.speakPhrase("NoNextPitstop")

						if ((options == true) || (options.HasProp("Map") && options.Map)) {
							map := knowledgeBase.getValue("Strategy.Map")

							if (map && (map != "n/a") && (map != knowledgeBase.getValue("Lap." . knowledgeBase.getValue("Lap") . ".Map", "n/a")))
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

	cancelStrategy(confirm := true, report := true, remote := true, reject := false) {
		local knowledgeBase := this.KnowledgeBase
		local hasStrategy := knowledgeBase.getValue("Strategy.Name", false)

		cancelStrategy() {
			if reject
				this.updateDynamicValues({RejectedStrategy: "CANCEL"})

			this.cancelStrategy(false, report, remote)
		}

		if (this.Speaker && confirm) {
			if hasStrategy {
				if this.confirmAction("Strategy.Cancel") {
					this.getSpeaker().speakPhrase("ConfirmCancelStrategy", false, true)

					this.setContinuation(cancelStrategy)
				}
				else
					cancelStrategy()
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

		for ignore, theFact in ["Name", "Version", "Weather", "Weather.Temperature.Air", "Weather.Temperature.Track"
							  , "Tyre.Compound", "Tyre.Compound.Color", "Map", "TC", "ABS", "BB"
							  , "Pitstop.Next", "Pitstop.Lap", "Pitstop.Position"
							  , "Pitstop.Lap.Warning", "Pitstop.Deviation"]
			knowledgeBase.clearFact("Strategy." . theFact)

		loop knowledgeBase.getValue("Strategy.Pitstop.Count", 0) {
			pitstop := A_Index

			for ignore, theFact in [".Lap", ".Lap.Max", ".Fuel.Amount", ".Tyre.Change", ".Tyre.Compound", ".Tyre.Compound.Color", ".Map"]
				knowledgeBase.clearFact("Strategy.Pitstop." . pitstop . theFact)
		}

		knowledgeBase.clearFact("Strategy.Pitstop.Count")

		this.iStrategy := false
	}

	recommendStrategyAction(lap := false) {
		if lap
			this.proposeStrategy({Pitstop: lap, Confirm: true})
		else
			this.proposeStrategy({Confirm: true})
	}

	updateStrategyAction(strategy?) {
		local options := this.findEvent("SimulateStrategy").StrategyOptions

		if isSet(strategy) {
			if !isObject(strategy)
				strategy := JSON.parse(strategy)

			if isDebug() {
				deleteFile(kTempDirectory . "Strategy.json")

				FileAppend(JSON.print(strategy, "  "), kTempDirectory . "Strategy.json")
			}

			try {
				RaceStrategist.RaceStrategyUpdateTask(this, this.createStrategy(strategy), "User"
														  , options.HasProp("Confirm") && options.Confirm
														  , options.HasProp("FullCourseYellow") && options.FullCourseYellow
														  , options.HasProp("Pitstop") && options.Pitstop).start()
			}
			catch Any as exception {
				logError(exception, true)

				if (this.Speaker && (!options.HasProp("Silent") || !options.Silent))
					this.getSpeaker().speakPhrase("NoValidStrategy")
			}
		}
		else if (this.Speaker && (!options.HasProp("Silent") || !options.Silent))
			this.getSpeaker().speakPhrase("NoValidStrategy")
	}

	proposeStrategy(options := {}) {
		if (this.AgentBooster && this.handledEvent("SimulateStrategy") && this.findAction("update_strategy"))
			this.handleEvent("SimulateStrategy", options.HasProp("Pitstop") && options.Pitstop, map2String("|", "->", toMap(options)))
		else
			this.recommendStrategy(options)
	}

	recommendStrategy(options := {}) {
		local knowledgeBase := this.KnowledgeBase
		local request := (options.HasProp("Request") ? options.Request : "User")
		local fullCourseYellow := (options.HasProp("FullCourseYellow") ? options.FullCourseYellow : false)
		local forcedPitstop := (options.HasProp("Pitstop") ? options.Pitstop : false)
		local engineerPID, speaker

		this.clearContinuation()

		if !this.hasEnoughData()
			return

		knowledgeBase.clearFact("Strategy.Recalculate")

		this.iLastStrategyUpdate := (knowledgeBase.getValue("Lap") + 1)

		if (this.Strategy || (getMultiMapValue(this.Settings, "Session Rules", "Strategy", "No") = "Yes")) {
			engineerPID := ProcessExist("Race Engineer.exe")

			if engineerPID
				messageSend(kFileMessage, "Race Engineer", "requestPitstopHistory:Race Strategist;runSimulation;"
														 . values2String(";", ProcessExist()
																			, options.HasProp("Confirm") && options.Confirm
																			, request, fullCourseYellow, forcedPitstop)
										, engineerPID)
			else if isDebug()
				this.runSimulation(newMultiMap(), options.HasProp("Confirm") && options.Confirm, request, fullCourseYellow, forcedPitstop)
			else if (this.Speaker && (!options.HasProp("Silent") || !options.Silent))
				this.getSpeaker().speakPhrase("NoStrategyRecommendation")
		}
		else if (this.Speaker && (!options.HasProp("Silent") || !options.Silent)) {
			speaker := this.getSpeaker()

			speaker.beginTalk()

			try {
				speaker.speakPhrase("NoStrategy")
				speaker.speakPhrase("FCYPitstop")
			}
			finally {
				speaker.endTalk()
			}
		}
	}

	updateStrategy(newStrategy, original := true, report := true, version := false, origin := "Assistant", remote := true) {
		local knowledgeBase := this.KnowledgeBase
		local fact, value, fileName, configuration, lastPitstop

		if version
			if (this.Strategy && (this.Strategy.Version = version))
				return
			else if (this.Strategy["Original"] && (this.Strategy["Original"].Version = version))
				return
			else if (knowledgeBase.getValue("Strategy.Version", false) = version)
				report := false

		if newStrategy {
			if (this.Session == kSessionRace) {
				if !isObject(newStrategy)
					newStrategy := RaceStrategist.RaceStrategy(this, readMultiMap(newStrategy), SessionDatabase.ID, [])

				this.clearStrategy()

				lastPitstop := knowledgeBase.getValue("Pitstop.Last", false)

				for fact, value in this.loadStrategy(newStrategy, CaseInsenseMap()
												   , knowledgeBase.getValue("Lap", false)
												   , lastPitstop, lastPitstop ? knowledgeBase.getValue("Pitstop." . lastPitstop . ".Lap") : false)
					knowledgeBase.setFact(fact, value)

				if this.Debug[kDebugKnowledgeBase]
					this.dumpKnowledgeBase(knowledgeBase)

				if original
					this.updateSessionValues({OriginalStrategy: newStrategy, Strategy: newStrategy})
				else
					this.updateSessionValues({Strategy: newStrategy})

				if (report && (this.StrategyReported || this.hasEnoughData(false) || !original)) {
					if this.Announcements["StrategyUpdate"]
						this.reportStrategy({Strategy: true, Pitstops: false, NextPitstop: true, TyreChange: true, Refuel: true, Map: true})

					this.updateDynamicValues({StrategyReported: true})
				}

				if (remote && this.RemoteHandler) {
					fileName := temporaryFileName("Race Strategy", "update")
					configuration := newMultiMap()

					newStrategy.saveToConfiguration(configuration)

					writeMultiMap(fileName, configuration)

					if (isDebug() || this.Debug[kStrategyProtocol])
						try {
							DirCreate(kTempDirectory . "Race Strategist\Strategy")

							FileCopy(fileName, kTempDirectory . "Race Strategist.strategy", 1)
						}
						catch Any as exception {
							logError(exception)
						}

					this.RemoteHandler.updateStrategy(fileName, newStrategy.Version)
				}
				else if (isDebug() || this.Debug[kStrategyProtocol]) {
					configuration := newMultiMap()

					newStrategy.saveToConfiguration(configuration)

					writeMultiMap(kTempDirectory . "Race Strategist.strategy", configuration)
				}

				if this.Debug[kStrategyProtocol] {
					DirCreate(kTempDirectory . "Race Strategist\Strategy")

					FileCopy(kTempDirectory . "Race Strategist.strategy"
						   , kTempDirectory . (original ? ("Race Strategist\Strategy\Original " . this.iDebugStrategyCounter[1]++ . ".strategy")
														: ("Race Strategist\Strategy\Updated " . this.iDebugStrategyCounter[2]++ . ".strategy"))
						   , 1)
				}
			}
		}
		else {
			this.cancelStrategy(false, report, remote)

			this.updateDynamicValues({StrategyReported: true})
		}

		this.updateDynamicValues({RejectedStrategy: false})
	}

	runSimulation(pitstopHistory, confirm := false, request := "User", fullCourseYellow := false, forcedPitstop := false) {
		local knowledgeBase := this.KnowledgeBase
		local data, lap

		if (pitstopHistory == true)
			data := true
		else if !isObject(pitstopHistory) {
			data := readMultiMap(pitstopHistory)

			if !isDebug()
				deleteFile(pitstopHistory)
		}
		else
			data := pitstopHistory

		if (this.UseTraffic && this.RemoteHandler) {
			this.setContinuation(RaceStrategist.RaceStrategySimulationContinuation(this, data, confirm, request, fullCourseYellow, forcedPitstop))

			lap := knowledgeBase.getValue("Lap")

			this.RemoteHandler.computeCarStatistics(Max(1, lap - 10), lap)
		}
		else
			RaceStrategist.RaceStrategySimulationTask(this, data, request, confirm, false, fullCourseYellow, forcedPitstop).start()
	}

	createStrategy(nameOrConfiguration, driver := false) {
		local name := nameOrConfiguration
		local theStrategy, theTask

		if !isObject(nameOrConfiguration)
			nameOrConfiguration := false

		theTask := Task.CurrentTask

		if (isObject(nameOrConfiguration) && nameOrConfiguration.Has("Name"))
			theStrategy := RaceStrategist.RaceStrategy(this, nameOrConfiguration, SessionDatabase.ID, [])
		else
			theStrategy := (this.UseTraffic ? RaceStrategist.TrafficRaceStrategy(this, nameOrConfiguration, driver
																			   , theTask.Pitstops, theTask.FullCourseYellow, theTask.ForcedPitstop)
											: RaceStrategist.RaceStrategy(this, nameOrConfiguration, driver
																		, theTask.Pitstops, theTask.FullCourseYellow, theTask.ForcedPitstop))

		if (name && !isObject(name))
			theStrategy.setName(name)

		return theStrategy
	}

	getStintDriver(stintNumber, &driverID, &driverName) {
		local strategy := this.Strategy["Original"]
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
					  , &sessionType, &sessionLength, &additionalLaps
					  , &tyreCompound, &tyreCompoundColor, &tyrePressures) {
		local knowledgeBase := this.KnowledgeBase
		local strategy := this.Strategy["Original"]
		local lap := Task.CurrentTask.Lap
		local availableTyreSets, strategyTask, lapsDB, candidate, mixedCompounds

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

			if this.Provider.supportsTyreManagement(&mixedCompounds) {
				if (mixedCompounds = "Wheel") {
					tyreCompound := knowledgeBase.getValue("Lap." . lap . ".Tyre.Compound.FrontLeft", false)
					tyreCompoundColor := knowledgeBase.getValue("Lap." . lap . ".Tyre.Compound.Color.FrontLeft", false)
				}
				else if (mixedCompounds = "Axle") {
					tyreCompound := knowledgeBase.getValue("Lap." . lap . ".Tyre.Compound.Front", false)
					tyreCompoundColor := knowledgeBase.getValue("Lap." . lap . ".Tyre.Compound.Color.Front", false)
				}
			}

			if !tyreCompound {
				tyreCompound := strategy.TyreCompound
				tyreCompoundColor := strategy.TyreCompoundColor
			}

			weather := knowledgeBase.getValue("Weather.Weather.10Min", strategy.Weather)
			strategyTask := Task.CurrentTask
			lapsDB := strategyTask.LapsDatabase

			if !lapsDB.suitableTyreCompound(simulator, car, track, weather, compound(tyreCompound, tyreCompoundColor)) {
				candidate := lapsDB.optimalTyreCompound(simulator, car, track, weather, airTemperature, trackTemperature
													  , getKeys(this.computeAvailableTyreSets(strategy.AvailableTyreSets, strategyTask.UsedTyreSets)))

				if candidate
					splitCompound(candidate, &tyreCompound, &tyreCompoundColor)
			}

			sessionType := strategy.SessionType
			sessionLength := strategy.SessionLength
			additionalLaps := strategy.AdditionalLaps
			tyrePressures := strategy.TyrePressures

			return true
		}
		else if (getMultiMapValue(this.Settings, "Session Rules", "Strategy", "No") = "Yes") {
			simulator := this.Simulator
			car := this.Car
			track := this.Track

			weather := knowledgeBase.getValue("Weather.Weather.10Min", false)
			airTemperature := Round(knowledgeBase.getValue("Weather.Temperature.Air", 0))
			trackTemperature := Round(knowledgeBase.getValue("Weather.Temperature.Track", 0))

			tyreCompound := knowledgeBase.getValue("Lap." . lap . ".Tyre.Compound", false)
			tyreCompoundColor := knowledgeBase.getValue("Lap." . lap . ".Tyre.Compound.Color", false)

			if this.Provider.supportsTyreManagement(&mixedCompounds) {
				if (mixedCompounds = "Wheel") {
					tyreCompound := knowledgeBase.getValue("Lap." . lap . ".Tyre.Compound.FrontLeft", false)
					tyreCompoundColor := knowledgeBase.getValue("Lap." . lap . ".Tyre.Compound.Color.FrontLeft", false)
				}
				else if (mixedCompounds = "Axle") {
					tyreCompound := knowledgeBase.getValue("Lap." . lap . ".Tyre.Compound.Front", false)
					tyreCompoundColor := knowledgeBase.getValue("Lap." . lap . ".Tyre.Compound.Color.Front", false)
				}
			}

			weather := knowledgeBase.getValue("Weather.Weather.10Min", "Dry")
			strategyTask := Task.CurrentTask
			lapsDB := strategyTask.LapsDatabase

			if !lapsDB.suitableTyreCompound(simulator, car, track, weather, compound(tyreCompound, tyreCompoundColor)) {
				candidate := lapsDB.optimalTyreCompound(simulator, car, track, weather, airTemperature, trackTemperature
													  , getKeys(this.computeAvailableTyreSets(strategy.AvailableTyreSets, strategyTask.UsedTyreSets)))

				if candidate
					splitCompound(candidate, &tyreCompound, &tyreCompoundColor)
			}

			if (knowledgeBase.getValue("Session.Format", "Time") = "Time") {
				sessionType := "Duration"
				sessionLength := (knowledgeBase.getValue("Session.Duration") / 60)
			}
			else {
				sessionType := "Laps"
				sessionLength := knowledgeBase.getValue("Session.Laps")
			}

			additionalLaps := knowledgeBase.getValue("Session.AdditionalLaps", 0)
			tyrePressures := [Round(knowledgeBase.getValue("Lap." . lap . ".Tyre.Pressure.FL"), 1)
							, Round(knowledgeBase.getValue("Lap." . lap . ".Tyre.Pressure.FR"), 1)
							, Round(knowledgeBase.getValue("Lap." . lap . ".Tyre.Pressure.RL"), 1)
							, Round(knowledgeBase.getValue("Lap." . lap . ".Tyre.Pressure.RR"), 1)]

			return true
		}
		else
			return false
	}

	getSessionSettings(&stintLength, &formationLap, &postRaceLap, &fuelCapacity, &safetyFuel
					 , &pitstopDelta, &pitstopFuelService, &pitstopTyreService, &pitstopServiceOrder) {
		local knowledgeBase := this.KnowledgeBase
		local strategy := this.Strategy["Original"]

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
		else if (getMultiMapValue(this.Settings, "Session Rules", "Strategy", "No") = "Yes") {
			stintLength := getMultiMapValue(this.Settings, "Session Rules", "Stint.Length", 70)
			formationLap := knowledgeBase.getValue("Session.Settings.Lap.Formation", true)
			postRaceLap := knowledgeBase.getValue("Session.Settings.Lap.PostRace", true)

			fuelCapacity := knowledgeBase.getValue("Session.Settings.Fuel.Max", 0)
			safetyFuel := knowledgeBase.getValue("Session.Settings.Fuel.SafetyMargin", 4)

			pitstopDelta := knowledgeBase.getValue("Session.Settings.Pitstop.Delta", 60)
			pitstopFuelService := [knowledgeBase.getValue("Session.Settings.Pitstop.Service.Refuel.Rule", "Dynamic")
								 , knowledgeBase.getValue("Session.Settings.Pitstop.Service.Refuel.Duration", 1.8)]
			pitstopTyreService := knowledgeBase.getValue("Session.Settings.Pitstop.Service.Tyres.Duration", 30)
			pitstopServiceOrder := knowledgeBase.getValue("Session.Settings.Pitstop.Service.Order", "Simultaneous")

			return true
		}
		else
			return false
	}

	getSessionWeather(minute, &weather, &airTemperature, &trackTemperature) {
		local knowledgeBase := this.KnowledgeBase
		local strategy := this.Strategy["Original"]

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
		else if (getMultiMapValue(this.Settings, "Session Rules", "Strategy", "No") = "Yes") {
			weather := knowledgeBase.getValue("Weather.Weather.10Min", false)
			airTemperature := Round(knowledgeBase.getValue("Weather.Temperature.Air"))
			trackTemperature := Round(knowledgeBase.getValue("Weather.Temperature.Track"))
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
					 , &initialTyreSet, &initialTyreLaps, &initialFuelAmount
					 , &initialMap, &initialFuelConsumption, &initialAvgLapTime) {
		local knowledgeBase := this.KnowledgeBase
		local strategy := this.Strategy["Original"]
		local ruleBased := (getMultiMapValue(this.Settings, "Session Rules", "Strategy", "No") = "Yes")
		local goal, resultSet, tyreSets, consumption, stintLength

		if (strategy || ruleBased) {
			initialLap := Task.CurrentTask.Lap

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

			initialTyreSet := knowledgeBase.getValue("Tyre.Set", false)
			initialMap := knowledgeBase.getValue("Lap." . initialLap . ".Map")

			If strategy {
				stintLength := strategy.StintLength

				initialStint := (Task.CurrentTask.Pitstops.Length + 1)
				initialStintTime := Ceil((stintLength * 60) - (knowledgeBase.getValue("Driver.Time.Stint.Remaining") / 1000))
				initialSessionTime := (this.OverallTime / 1000)

				if !Task.CurrentTask.LapsDatabase.suitableTyreCompound(this.Simulator, this.Car, this.Track
																     , knowledgeBase.getValue("Weather.Weather.10Min", "Dry")
																	 , compound(knowledgeBase.getValue("Tyre.Compound", "Dry")
																			  , knowledgeBase.getValue("Tyre.Compound.Color", "Black")))
					initialTyreLaps := 999
				else if (initialStint > 1)
					initialTyreLaps := Max(0, (initialLap - Task.CurrentTask.Pitstops[initialStint - 1].Lap))
				else
					initialTyreLaps := initialLap

				initialFuelAmount := knowledgeBase.getValue("Lap." . initialLap . ".Fuel.Remaining")
			}
			else {
				stintLength := getMultiMapValue(this.Settings, "Session Rules", "Stint.Length", 70)

				initialStint := 1
				initialStintTime := 0
				initialSessionTime := 0
				initialTyreLaps := 0

				initialFuelAmount := (knowledgeBase.getValue("Lap." . initialLap . ".Fuel.Remaining") + (initialLap * consumption))

				initialLap := 0
			}

			return true
		}
		else
			return false
	}

	getSimulationSettings(&useInitialConditions, &useTelemetryData
						, &consumptionVariation, &initialFuelVariation, &refuelVariation
						, &tyreUsageVariation, &tyreCompoundVariation
						, &firstStintWeight, &lastStintWeight) {
		local strategy := this.Strategy["Original"]

		useInitialConditions := false
		useTelemetryData := true

		initialFuelVariation := 0

		if strategy {
			consumptionVariation := strategy.ConsumptionVariation
			refuelVariation := strategy.RefuelVariation

			tyreUsageVariation := strategy.TyreUsageVariation
			tyreCompoundVariation := strategy.TyreCompoundVariation

			firstStintWeight := strategy.FirstStintWeight
			lastStintWeight := strategy.LastStintWeight
		}
		else {
			consumptionVariation := 0
			refuelVariation := 0

			tyreUsageVariation := 0
			tyreCompoundVariation := 0

			firstStintWeight := 0
			lastStintWeight := 0
		}

		return (strategy != false)
	}

	getPitstopRules(&validator, &pitstopRule, &pitstopWindow, &refuelRule, &tyreChangeRule, &tyreSets) {
		local strategy := this.Strategy
		local ignore, tyreSetLaps, tyreCompounds

		if strategy {
			validator := strategy.Validator
			pitstopRule := strategy.PitstopRule
			pitstopWindow := strategy.PitstopWindow
			refuelRule := strategy.RefuelRule
			tyreChangeRule := strategy.TyreChangeRule
			tyreSets := strategy.TyreSets

			if (pitstopRule > 0)
				pitstopRule := Max(0, pitstopRule - Task.CurrentTask.Pitstops.Length)

			return true
		}
		else if (getMultiMapValue(this.Settings, "Session Rules", "Strategy", "No") = "Yes") {
			validator := false
			pitstopRule := getMultiMapValue(this.Settings, "Session Rules", "Pitstop.Rule", false)
			pitstopWindow := getMultiMapValue(this.Settings, "Session Rules", "Pitstop.Window", false)

			if (pitstopWindow && InStr(pitstopWindow, "-"))
				pitstopWindow := string2Values("-", pitstopWindow)

			refuelRule := getMultiMapValue(this.Settings, "Session Rules", "Pitstop.Refuel", "Optional")
			tyreChangeRule := getMultiMapValue(this.Settings, "Session Rules", "Pitstop.Tyre", "Optional")

			tyreCompounds := SessionDatabase.getTyreCompounds(this.Simulator, this.Car, this.Track)
			tyreSets := string2Values(";", getMultiMapValue(this.Settings, "Session Rules", "Tyre.Sets", ""))

			loop tyreSets.Length
				if InStr(tyreSets[A_Index], ":") {
					tyreSets[A_Index] := string2Values(":", tyreSets[A_Index])

					if !inList(tyreCompounds, compound(tyreSets[A_Index][1], tyreSets[A_Index][2]))
						tyreSets[A_Index] := false
					else if (tyreSets[A_Index].Length < 4) {
						tyreSets[A_Index].Push(50)

						tyreSetLaps := []

						loop tyreSets[A_Index][3]
							tyreSetLaps.Push(0)

						tyreSets[A_Index].Push(tyreSetLaps)
					}
					else {
						tyreSets[A_Index].InsertAt(4, 50)

						tyreSets[A_Index][5] := string2Values("|", tyreSets[A_Index][5])
					}
				}
				else {
					tyreSets[A_Index] := string2Values("#", tyreSets[A_Index])

					if !inList(tyreCompounds, compound(tyreSets[A_Index][1], tyreSets[A_Index][2]))
						tyreSets[A_Index] := false
					else if (tyreSets[A_Index].Length < 5) {
						tyreSetsLaps := []

						loop tyreSets[A_Index][3]
							tyreSetsLaps.Push(0)

						tyreSets[A_Index].Push(tyreSetsLaps)
					}
					else
						tyreSets[A_Index][5] := string2Values("|", tyreSets[A_Index][5])
				}

			tyreSets := choose(tyreSets, (ts) => (ts != false))

			if (pitstopRule > 0)
				pitstopRule := Max(0, pitstopRule - Task.CurrentTask.Pitstops.Length)

			return true
		}
		else
			return false
	}

	getFixedPitstops() {
		return Map()
	}

	getAvgLapTime(numLaps, map, remainingFuel, fuelConsumption, weather, tyreCompound, tyreCompoundColor, tyreLaps, default := false) {
		return Task.CurrentTask.Simulation.calcAvgLapTime(numLaps, map, remainingFuel, fuelConsumption, weather
														, tyreCompound, tyreCompoundColor, tyreLaps
														, default ? default : this.Strategy.AvgLapTime
														, Task.CurrentTask.LapsDatabase)
	}

	unplannedPitstop(pitstopNr, currentLap, &remainingLaps) {
		if ((pitstopNr = (Task.CurrentTask.Pitstops.Length + 1)) && Task.CurrentTask.FullCourseYellow) {
			remainingLaps := 0

			return true
		}
		else if ((pitstopNr = (Task.CurrentTask.Pitstops.Length + 1)) && Task.CurrentTask.ForcedPitstop) {
			remainingLaps := Max(0, Task.CurrentTask.ForcedPitstop - currentLap)

			return true
		}
		else
			return false
	}

	computeAvailableTyreSets(availableTyreSets, usedTyreSets) {
		local tyreCompound, ignore, tyreSet, tyreSets

		this.Provider.supportsTyreManagement( , &tyreSets)

		if tyreSets
			for ignore, tyreSet in usedTyreSets {
				tyreCompound := compound(tyreSet.Compound, tyreSet.CompoundColor)

				if (tyreSet.HasProp("Set") && availableTyreSets.Has(tyreCompound)
										   && availableTyreSets[tyreCompound][2].Has(tyreSet.Set))
					availableTyreSets[tyreCompound][2][tyreSet.Set] += tyreSet.Laps
			}

		return availableTyreSets
	}

	initializeTyreSets(strategy) {
		strategy.AvailableTyreSets := this.computeAvailableTyreSets(strategy.AvailableTyreSets, Task.CurrentTask.UsedTyreSets)
	}

	getTrafficScenario(strategy, targetPitstop, randomFactor, numScenarios, useLapTimeVariation, useDriverErrors, usePitstops, overTakeDelta) {
		local targetLap := targetPitstop.Lap
		local knowledgeBase := this.KnowledgeBase
		local pitstopWindow := knowledgeBase.getValue("Session.Settings.Pitstop.Strategy.Window.Considered")
		local pitstops := CaseInsenseMap()
		local carStatistics := CaseInsenseMap()
		local goal, resultSet
		local startLap, endLap, avgLapTime, driver, stintLength, formationLap, postRaceLap
		local fuelCapacity, safetyFuel, pitstopDelta, pitstopFuelService, pitstopTyreService, pitstopServiceOrder
		local lastPositions, lastRunnings, count, laps, curLap, carPositions, nextRunnings
		local lapTime, potential, raceCraft, speed, consistency, carControl
		local delta, running, nr, position, ignore, nextPositions, runnings, car

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
				carPitstops := this.Pitstops[knowledgeBase.getValue("Car." . car . ".ID", car)]

				if (carPitstops.Length > 0) {
					loop carPitstops.Length
						stintLength += (carPitstops[A_Index].Lap - ((A_Index > 1) ? carPitstops[A_Index - 1].Lap : 0))

					if (Abs(carPitstops[carPitstops.Length].Lap + Round(stintLength / carPitstops.Length) - lap) < pitstopWindow) {
						pitstops[car] := true

						return true
					}
				}
				else  if (Random(0.0, 1.0) < (randomFactor / 100)) {
					pitstops[car] := true

					return true
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

			try {
				lastRunnings.Push(knowledgeBase.getValue("Car." . A_Index . ".Laps", knowledgeBase.getValue("Car." . A_Index . ".Lap", 0))
								+ knowledgeBase.getValue("Car." . A_Index . ".Lap.Running", 0))
			}
			catch Any as exception {
				logError(exception)

				lastRunnings.Push(0)
			}
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

				if useLapTimeVariation
					lapTime += (Random(-1.0, 1.0) * ((5 - consistency) / 5) * (randomFactor / 100))

				if useDriverErrors
					lapTime += (Random(0.0, 1.0) * ((5 - carControl) / 5) * (randomFactor / 100))

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

	betterScenario(strategy, scenario, &report := true, extended := true) {
		local knowledgeBase := this.KnowledgeBase
		local sPitstops, cPitstops, sLaps, cLaps, sDuration, cDuration, sFuel, cFuel, sPLaps, cPLaps, sTLaps, cTLaps, sTSets, cTSets
		local result, ignore, pitstop, nextPitstop, maxLap

		pitstopLaps(strategy, skip := 0) {
			local laps := 0
			local nr, pitstop

			for nr, pitstop in strategy.Pitstops
				if (nr > skip)
					laps += pitstop.StintLaps

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

		if (cPitstops && sPitstops) {
			; Current strategy exceeds stint timer

			nextPitstop := (knowledgeBase.getValue("Pitstop.Last", 0) + 1)
			maxLap := (knowledgeBase.getValue("Lap") + Floor(((strategy.StintLength * 60) - scenario.StintStartTime) / scenario.AvgLapTime))

			for ignore, pitstop in strategy.Pitstops
				if (nextPitstop = pitstop.Nr)
					if ((pitstop.Lap >= maxLap) && (scenario.Pitstops[1].Lap < pitstop.Lap))
						return true
		}
		else if (!cPitstops && !sPitstops) {
			; Nothing to see here, move on

			return false
		}

		; if (!sPitstops && cPitstops)
		;	extended := false

		; Negative => Better, Positive => Worse

		result := (StrategySimulation.scenarioCoefficient("PitstopsCount", cPitstops - sPitstops, 1)
				 + StrategySimulation.scenarioCoefficient("TyreSetsCount", sTSets - cTSets, 1))

		if extended {
			result += (StrategySimulation.scenarioCoefficient("FuelMax", cFuel - sFuel, 10)
					 + StrategySimulation.scenarioCoefficient("TyreLapsMax", cTLaps - sTLaps, 10)
					 + StrategySimulation.scenarioCoefficient("PitstopsPostLaps", sPLaps - cPLaps, 10))

			if (scenario.SessionType = "Duration") {
				if (!scenario.FullCourseYellow || (result != 0)) {
					result += StrategySimulation.scenarioCoefficient("ResultMajor", sLaps - cLaps, 1)

					result += StrategySimulation.scenarioCoefficient("ResultMinor", cDuration - sDuration, (strategy.AvgLapTime + scenario.AvgLapTime) / 4)
				}
			}
			else
				result += StrategySimulation.scenarioCoefficient("ResultMajor", cDuration - sDuration, (strategy.AvgLapTime + scenario.AvgLapTime) / 4)
		}

		if ((cPitstops > 0) && !scenario.FullCourseYellow &&  (scenario.Pitstops[1].Lap <= (knowledgeBase.getValue("Lap") + 1)))
			result := false
		else if (!sPitstops && (cPitstops = 1) && !scenario.Pitstops[1].TyreCompound
							&& (scenario.Pitstops[1].RefuelAmount <= scenario.SafetyFuel))
			return false
		else if (result > 0)
			result := false
		else if (result < 0)
			result := true
		else if extended {
			if (scenario.getRemainingFuel() > strategy.getRemainingFuel())
				result := false
			else if (scenario.getRemainingFuel() < strategy.getRemainingFuel())
				result := true
			else if ((scenario.FuelConsumption[true] > strategy.FuelConsumption[true]))
				result := false
			else
				result := true
		}
		else
			result := true

		if result {
			if (sPitstops != cPitstops)
				report := true
			else if (cPitstops != 0) {
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

	chooseScenario(scenario, confirm?) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local hadScenario := (scenario != false)
		local dispose := true
		local request := false
		local fullCourseYellow, forcedPitstop, explain, report

		static wasSkipped := false

		if scenario
			wasSkipped := false

		try {
			if !isSet(confirm) {
				request := Task.CurrentTask.Request
				fullCourseYellow := Task.CurrentTask.FullCourseYellow
				forcedPitstop := Task.CurrentTask.ForcedPitstop
				explain := Task.CurrentTask.ExplainStrategy

				if (scenario && fullCourseYellow)
					if (scenario.Pitstops.Length > 0)
						scenario.FullCourseYellow := true
					else {
						scenario.dispose()

						scenario := false
					}

				if (request = "User") {
					confirm := true

					if scenario {
						if (fullCourseYellow || forcedPitstop) {
							if this.betterScenario(this.Strategy, scenario, &report, false) {
								this.reportStrategy({Strategy: false, FullCourseYellow: fullCourseYellow, ForcedPitstop: forcedPitstop
												   , NextPitstop: false, TyreChange: true, Refuel: true}, scenario)

								if this.Speaker {
									if this.confirmAction("Strategy.Update") {
										speaker.speakPhrase("ConfirmUpdateStrategy", false, true)

										this.setContinuation(RaceStrategist.ConfirmStrategyUpdateContinuation(this, scenario, false))
									}
									else
										this.chooseScenario(scenario, false)

									dispose := false

									return
								}
							}
							else
								scenario := false
						}
						else {
							this.reportStrategy({Strategy: false, Pitstops: true, NextPitstop: true
											   , TyreChange: true, Refuel: true, Map: true, Active: this.Strategy}, scenario)

							if (explain && ((this.Strategy != this.Strategy["Original"]) || isDebug()))
								this.explainStrategyRecommendation(scenario)

							if this.Speaker {
								if this.confirmAction("Strategy.Update") {
									speaker.speakPhrase("ConfirmUpdateStrategy", false, true)

									this.setContinuation(RaceStrategist.ConfirmStrategyUpdateContinuation(this, scenario, false))
								}
								else
									this.chooseScenario(scenario, false)

								dispose := false

								return
							}
						}
					}
				}
				else {
					confirm := false

					if scenario {
						report := true

						if (request = "Rules")
							report := false
						else if (request != "Pitstop")
							if (this.Strategy["Rejected"] && isInstance(this.Strategy["Rejected"], Strategy) && !this.betterScenario(this.Strategy["Rejected"], scenario, &report))
								return
							else if ((this.Strategy != this.Strategy["Original"]) && !this.betterScenario(this.Strategy, scenario, &report))
								return
							else if ((this.Strategy.RunningPitstops > 0) && !this.betterScenario(this.Strategy, scenario, &report))
								return

						if (report && this.Speaker) {
							if this.Announcements["StrategyUpdate"] {
								speaker.speakPhrase("StrategyUpdate")

								this.reportStrategy({Strategy: false, Pitstops: true, NextPitstop: true
												   , TyreChange: true, Refuel: true, Map: true, Active: this.Strategy}, scenario)

								if (explain && ((this.Strategy != this.Strategy["Original"]) || isDebug()))
									this.explainStrategyRecommendation(scenario)
							}

							if Task.CurrentTask.Confirm {
								if this.confirmAction("Strategy.Update") {
									speaker.speakPhrase("ConfirmUpdateStrategy", false, true)

									this.setContinuation(RaceStrategist.ConfirmStrategyUpdateContinuation(this, scenario, true))
								}
								else
									this.chooseScenario(scenario, false)

								dispose := false

								return
							}
						}
					}
					else {
						if (this.Strategy["Rejected"] = "CANCEL")
							return
						else if (request != "Pitstop")
							return
						else {
							if wasSkipped {
								wasSkipped := false

								confirm := true
							}
							else {
								wasSkipped := true

								return
							}
						}
					}
				}
			}

			if scenario {
				if this.Strategy["Original"]
					scenario.PitstopRule := this.Strategy["Original"].PitstopRule

				scenario.setVersion(A_Now)

				dispose := false

				Task.startTask(ObjBindMethod(this, "updateStrategy", scenario, (request = "Rules")
																   , false, scenario.Version), 1000)
			}
			else {
				if (confirm && this.Speaker)
					if fullCourseYellow {
						if hadScenario
							speaker.speakPhrase("NoFCYStrategy")
						else {
							speaker.beginTalk()

							try {
								speaker.speakPhrase("NoValidStrategy")
								speaker.speakPhrase("FCYPitstop")
							}
							finally {
								speaker.endTalk()
							}
						}
					}
					else
						speaker.speakPhrase("NoValidStrategy")

				if (!fullCourseYellow && !forcedPitstop)
					Task.startTask(ObjBindMethod(this, "cancelStrategy", confirm, true, true, true), 1000)
			}
		}
		finally {
			if (dispose && scenario)
				scenario.dispose()
		}
	}

	proposePitstop(lap := false) {
		if (this.AgentBooster && this.handledEvent("RecommendPitstop") && this.findAction("recommend_pitstop"))
			this.handleEvent("RecommendPitstop", lap)
		else
			this.recommendPitstop(lap)
	}

	recommendPitstop(lap := false, fixed := false) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local refuel := kUndefined
		local tyreChange := kUndefined
		local tyreCompound := kUndefined
		local tyreCompoundColor := kUndefined
		local strategyLap := false
		local maxLap := false
		local lastLap, plannedLap, position, traffic, hasEngineer, nextPitstop, pitstopOptions

		this.clearContinuation()

		if !this.hasEnoughData()
			return

		strategyLap := knowledgeBase.getValue("Strategy.Pitstop.Lap", false)
		lastLap := knowledgeBase.getValue("Lap")

		if strategyLap {
			nextPitstop := knowledgeBase.getValue("Strategy.Pitstop.Next")

			maxLap := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Lap.Max", false)
			refuel := Round(knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Fuel.Amount"))
			tyreChange := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Change")
			tyreCompound := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Compound")
			tyreCompoundColor := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Compound.Color")

			if (knowledgeBase.getValue("Strategy.Pitstop.Count") > nextPitstop)
				refuel := ("!" . refuel)
		}

		if !lap
			lap := strategyLap

		if !fixed {
			knowledgeBase.setFact("Pitstop.Strategy.Plan", lap ? lap : true)

			if maxLap
				knowledgeBase.setFact("Pitstop.Strategy.Lap.Max", maxLap)

			knowledgeBase.produce()

			if this.Debug[kDebugKnowledgeBase]
				this.dumpKnowledgeBase(this.KnowledgeBase)

			plannedLap := knowledgeBase.getValue("Pitstop.Strategy.Lap", kUndefined)
		}
		else
			plannedLap := lap

		hasEngineer := (ProcessExist("Race Engineer.exe") != 0)

		if fixed {
			if isInteger(plannedLap) {
				if plannedLap {
					speaker.speakPhrase("PitstopLap", {lap: Max(lap, lastLap + 1)}, false, false, {Important: true})

					if hasEngineer {
						speaker.speakPhrase("ConfirmInformEngineer", false, true)

						this.setContinuation(ObjBindMethod(this, "planPitstop", lap))
					}
				}
				else
					speaker.speakPhrase("NoPitstopNeeded")
			}
			else
				speaker.speakPhrase("NoPlannedPitstop")
		}
		else if (plannedLap == kUndefined) {
			if strategyLap {
				speaker.speakPhrase("PitstopLap", {lap: Max(strategyLap, lastLap + 1)}, false, false, {Important: true})

				if hasEngineer {
					speaker.speakPhrase("ConfirmInformEngineer", false, true)

					this.setContinuation(ObjBindMethod(this, "planPitstop", strategyLap, refuel, tyreChange, tyreCompound, tyreCompoundColor))
				}
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

			speaker.speakPhrase("PitstopLap", {lap: plannedLap}, false, false, {Important: true})

			if this.confirmAction("Strategy.Explain") {
				speaker.speakPhrase("Explain", false, true)

				if hasEngineer
					this.setContinuation(RaceStrategist.ExplainPitstopContinuation(this, plannedLap, pitstopOptions
																				 , ObjBindMethod(this, "explainPitstopRecommendation", plannedLap, pitstopOptions, true)
																				 , false
																				 , false, "Okay"))
				else
					this.setContinuation(ObjBindMethod(this, "explainPitstopRecommendation", plannedLap))
			}
			else if hasEngineer
				this.explainPitstopRecommendation(plannedLap, pitstopOptions, true)
			else
				this.explainPitstopRecommendation(plannedLap)
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
				speaker.speakPhrase("EvaluatedLaps", {laps: ((pitstopWindow * 2) + 1), first: (pitstopLap - pitstopWindow), last: (pitstopLap + pitstopWindow)})

				if position
					speaker.speakPhrase("EvaluatedBestPosition", {lap: pitstopLap, position: position})

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

	explainPitstopRecommendation(plannedLap, pitstopOptions := [], confirm := false) {
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

				if position
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

			if ProcessExist("Race Engineer.exe")
				if (confirm || this.confirmAction("Pitstop.Plan")) {
					speaker.speakPhrase("ConfirmInformEngineer", false, true)

					this.setContinuation(ObjBindMethod(this, "planPitstop", plannedLap, pitstopOptions*))
				}
				else
					this.planPitstop(plannedLap, pitstopOptions*)
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
					messageSend(kFileMessage, "Race Engineer", (this.TeamSession ? "planDriverSwap:" : "planPitstop:") . "!" . plannedLap, engineerPID)
			}
			else
				messageSend(kFileMessage, "Race Engineer", this.TeamSession ? "planDriverSwap" : "planPitstop:Now", engineerPID)

		if this.Debug[kStrategyProtocol] {
			DirCreate(kTempDirectory . "Race Strategist\Strategy")

			FileAppend("Lap: " . (plannedLap ? plannedLap : "?") . "`n"
					 . "Refuel: " . ((refuel != kUndefined) ? StrReplace(refuel, "!", "") : "?") . "`n"
					 . "Tyre Change: " . ((tyreChange != kUndefined) ? ((StrCompare(StrReplace(tyreChange, "!", ""), "0") != 0) ? "Yes" : "No") : "?") . "`n"
					 . "Tyre Compound: " ((tyreCompound != kUndefined) ? (tyreCompound ? compound(tyreCompound, tyreCompoundColor) : "-") : "?")
					 , kTempDirectory . "Race Strategist\Strategy\Pitstop " . this.iDebugStrategyCounter[3]++ . ".pitstop")
		}
	}

	createPitstopHistory(pitstopHistory, &tyreSets?) {
		local knowledgeBase := this.KnowledgeBase
		local pitstops := []
		local lapNumber, mixedCompounds, tyreSet, tyreService, brakeService, tyreCompound, tyreCompoundColor, pitstop
		local index, tyre, axle

		tyreSets := []

		try {
			this.Provider.supportsTyreManagement(&mixedCompounds, &tyreSet)
			this.Provider.supportsPitstop(&mixedCompounds, &tyreService, &brakeService)

			loop getMultiMapValue(pitstopHistory, "Pitstops", "Count", 0)
				if (getMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".Lap", kUndefined) != kUndefined) {
					pitstop := {Nr: A_Index
							  , Time: getMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".Time")
							  , Lap: getMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".Lap")
							  , RefuelAmount: getMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".Refuel", 0)
							  , TyreChange: getMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".TyreChange")
							  , TyreCompound: getMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".TyreCompound", false)
							  , TyreCompoundColor: getMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".TyreCompoundColor", false)
							  , TyreLapsFrontLeft: getMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".TyreLapsFrontLeft", 0)
							  , TyreLapsFrontRight: getMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".TyreLapsFrontRight", 0)
							  , TyreLapsRearLeft: getMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".TyreLapsRearLeft", 0)
							  , TyreLapsRearRight: getMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".TyreLapsRearRight", 0)
							  , RepairBodywork: getMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".RepairBodywork", false)
							  , RepairSuspension: getMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".RepairSuspension", false)
							  , RepairEngine: getMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".RepairEngine", false)}

					if tyreSet
						pitstop.TyreSet := getMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".TyreSet", false)

					if brakeService
						pitstop.BrakeChange := getMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".BrakeChange", false)

					if (mixedCompounds = "Wheel") {
						for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
							pitstop.%"TyreCompound" . tyre% := getMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".TyreCompound" . tyre, false)
							pitstop.%"TyreCompoundColor" . tyre% := getMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".TyreCompoundColor" . tyre, false)
						}
					}
					else if (mixedCompounds = "Axle") {
						for index, axle in ["Front", "Rear"] {
							pitstop.%"TyreCompound" . axle% := getMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".TyreCompound" . axle, false)
							pitstop.%"TyreCompoundColor" . axle% := getMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".TyreCompoundColor" . axle, false)
						}
					}

					pitstops.Push(pitstop)
				}

			loop getMultiMapValue(pitstopHistory, "TyreSets", "Count", 0) {
				tyreSets.Push({Laps: getMultiMapValue(pitstopHistory, "TyreSets", A_Index . ".Laps")
							 , Compound: getMultiMapValue(pitstopHistory, "TyreSets", A_Index . ".Compound")
							 , CompoundColor: getMultiMapValue(pitstopHistory, "TyreSets", A_Index . ".CompoundColor")})

				if tyreSet
					tyreSets[tyreSets.Length].Set := getMultiMapValue(pitstopHistory, "TyreSets", A_Index . ".Set")
			}

			if (tyreSets.Length = 0) {
				lapNumber := knowledgeBase.getValue("Lap")

				tyreCompound := knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Compound", "Dry")
				tyreCompoundColor := knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Compound.Color", "Black")

				if (mixedCompounds = "Wheel") {
					tyreCompound := knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Compound.FrontLeft", tyreCompound)
					tyreCompoundColor := knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Compound.Color.FrontLeft", tyreCompoundColor)
				}
				else if (mixedCompounds = "Axle") {
					tyreCompound := knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Compound.Front", tyreCompound)
					tyreCompoundColor := knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Compound.Color.Front", tyreCompoundColor)
				}

				if tyreSet
					tyreSets.Push({Laps: lapNumber
								 , Compound: tyreCompound, CompoundColor: tyreCompoundColor})
				else
					tyreSets.Push({Laps: lapNumber, Compound: tyreCompound, CompoundColor: tyreCompoundColor})
			}
		}
		catch Any as exception {
			logError(exception, knowledgeBase != false)

			pitstops := []
			tyreSets := []
		}

		return pitstops
	}

	updatePitstopHistory(pitstopHistory) {
		local data, pitstops, usedTyreSets

		if this.KnowledgeBase {
			if !isObject(pitstopHistory) {
				data := readMultiMap(pitstopHistory)

				if !isDebug()
					deleteFile(pitstopHistory)
			}
			else
				data := pitstopHistory

			pitstops := this.createPitstopHistory(data, &usedTyreSets)

			this.updateDynamicValues({PitstopHistory: pitstops, UsedTyreSets: usedTyreSets})
		}
	}

	executePitstop(lapNumber) {
		local knowledgeBase := this.KnowledgeBase
		local nextPitstop, result, map, engineerPID

		if this.Strategy
			nextPitstop := knowledgeBase.getValue("Strategy.Pitstop.Next", false)
		else
			nextPitstop := false

		result := super.executePitstop(lapNumber)

		knowledgeBase.clearFact("Strategy.Recalculate")

		this.iLastStrategyUpdate := lapNumber

		if nextPitstop
			if (nextPitstop != knowledgeBase.getValue("Strategy.Pitstop.Next", false)) {
				map := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Map", "n/a")

				if ((map != "n/a") && (map != knowledgeBase.getValue("Lap." . knowledgeBase.getValue("Lap") . ".Map", "n/a")))
					if this.Speaker[false]
						this.getSpeaker().speakPhrase("StintMap", {map: map}, false, false, {Important: true})
			}
			else if getMultiMapValue(this.Settings, "Strategy Settings", "Strategy.Update.Pitstop", false)
				knowledgeBase.setFact("Strategy.Recalculate", "Pitstop")

		this.updateDynamicValues({RejectedStrategy: false})

		if !this.TeamSession {
			engineerPID := ProcessExist("Race Engineer.exe")

			if engineerPID
				Task.startTask(() => messageSend(kFileMessage, "Race Engineer"
															 , "requestPitstopHistory:Race Strategist;updatePitstopHistory;" . ProcessExist()
															 , engineerPID)
							 , 60000, kLowPriority)
		}

		return result
	}

	pitstopPerformed(pitstopNr) {
		if this.Strategy
			this.Strategy.RunningPitstops += 1

		if (this.Strategy["Rejected"] && isInstance(this.Strategy["Rejected"], Strategy))
			this.Strategy["Rejected"].RunningPitstops += 1
	}

	callRecommendPitstop(lapNumber := false) {
		if !this.confirmCommand(false)
			return

		this.proposePitstop(lapNumber)
	}

	callRecommendStrategy() {
		if !this.confirmCommand(false)
			return

		this.proposeStrategy()
	}

	callRecommendFullCourseYellow() {
		if !this.confirmCommand(false)
			return

		this.proposeStrategy({FullCourseYellow: true})
	}

	weatherChange(&weather, &minutes) {
		local knowledgeBase := this.KnowledgeBase
		local weatherNow

		if knowledgeBase {
			weatherNow := knowledgeBase.getValue("Weather.Weather.Now", "Dry")

			if (weatherNow != knowledgeBase.getValue("Weather.Weather.10Min", "Dry")) {
				weather := knowledgeBase.getValue("Weather.Weather.10Min", "Dry")
				minutes := 10

				return true
			}
			else if (weatherNow != knowledgeBase.getValue("Weather.Weather.30Min", "Dry")) {
				weather := knowledgeBase.getValue("Weather.Weather.30Min", "Dry")
				minutes := 30

				return true
			}
			else
				return false
		}
		else
			return false
	}

	weatherForecast(weather, minutes, changeTyres) {
		if (this.Speaker[false] && (this.Session == kSessionRace) && this.Announcements["WeatherUpdate"])
			this.getSpeaker().speakPhrase(changeTyres ? "WeatherChange" : "WeatherNoChange", {minutes: minutes})
	}

	requestTyreChange(weather, minutes, recommendedCompound) {
		local knowledgeBase := this.KnowledgeBase
		local speaker, fragments

		if ((knowledgeBase.getValue("Lap.Remaining.Session", knowledgeBase.getValue("Lap.Remaining", 0))
		   > knowledgeBase.getValue("Session.Settings.Pitstop.Service.Last", 5))
		 && this.Speaker[false] && (this.Session == kSessionRace)) {
			speaker := this.getSpeaker()
			fragments := speaker.Fragments

			speaker.beginTalk()

			try {
				speaker.speakPhrase(((recommendedCompound = "Wet") || (recommendedCompound = "Intermediate")) ? "TrackRainChange"
																											  : "TrackDryChange"
								  , {minutes: minutes, compound: fragments[recommendedCompound . "Tyre"]})

				if this.hasEnoughData(false)
					if this.Strategy {
						if this.confirmAction("Strategy.Weather") {
							speaker.speakPhrase("ConfirmUpdateStrategy", false, true)

							this.setContinuation(RaceStrategist.TyreChangeContinuation(this, ObjBindMethod(this, "recommendStrategy")
																						   , false
																						   , "Confirm", "Okay"))
						}
						else
							this.recommendStrategy()
					}
					else if ProcessExist("Race Engineer.exe")
						if this.confirmAction("Strategy.Weather") {
							speaker.speakPhrase("ConfirmInformEngineer", false, true)

							this.setContinuation(ObjBindMethod(this, "planPitstop"))
						}
						else
							this.planPitstop()
			}
			finally {
				speaker.endTalk({Important: true})
			}
		}
	}

	reportUpcomingPitstop(plannedPitstopLap, planPitstop := true) {
		local knowledgeBase := this.KnowledgeBase
		local lastLap := knowledgeBase.getValue("Lap")
		local fullCourseYellow, forcedPitstop, speaker, plannedLap, nextPitstop, maxLap
		local refuel, tyreChange, tyreCompound, tyreCompoundColor

		if this.Speaker {
			speaker := this.getSpeaker()

			nextPitstop := knowledgeBase.getValue("Strategy.Pitstop.Next")
			fullCourseYellow := (this.Strategy && (this.Strategy.FullCourseYellow = nextPitstop))
			forcedPitstop := (this.Strategy && (this.Strategy.ForcedPitstop > lastLap))

			if (!fullCourseYellow && !forcedPitstop && !this.Strategy.PitstopWindow) {
				knowledgeBase.setFact("Pitstop.Strategy.Plan", plannedPitstopLap)

				maxLap := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Lap.Max", false)

				if maxLap
					knowledgeBase.setFact("Pitstop.Strategy.Lap.Max", maxLap)

				knowledgeBase.produce()

				if this.Debug[kDebugKnowledgeBase]
					this.dumpKnowledgeBase(this.KnowledgeBase)

				plannedLap := knowledgeBase.getValue("Pitstop.Strategy.Lap", kUndefined)

				if (plannedLap && (plannedLap != kUndefined)) {
					if this.Debug[kStrategyProtocol] {
						DirCreate(kTempDirectory . "Race Strategist\Strategy")

						FileAppend("Original Lap: " . plannedPitstopLap . "`nNew lap: " . plannedLap
								 , kTempDirectory . "Race Strategist\Strategy\Pitstop " . this.iDebugStrategyCounter[3] . ".recommendation")
					}

					plannedPitstopLap := plannedLap
				}
			}

			knowledgeBase.clearFact("Strategy.Recalculate")

			plannedPitstopLap := Max(lastLap + 1, plannedPitstopLap)

			this.iLastStrategyUpdate := plannedPitstopLap

			speaker.beginTalk()

			try {
				if !fullCourseYellow {
					if this.Announcements["StrategyPitstop"]
						this.reportStrategy({Strategy: true, Pitstops: true, NextPitstop: false, TyreChange: true, Refuel: true})

					speaker.speakPhrase("PitstopAhead", {lap: plannedPitstopLap, laps: (plannedPitstopLap - (lastLap + 1))})
				}

				if (ProcessExist("Race Engineer.exe") && planPitstop)
					if fullCourseYellow {
						refuel := Round(knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Fuel.Amount"), 1)
						tyreChange := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Change")

						if tyreChange {
							tyreCompound := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Compound")
							tyreCompoundColor := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Compound.Color")
						}
						else {
							tyreCompound := false
							tyreCompoundColor := false
						}

						if (knowledgeBase.getValue("Strategy.Pitstop.Count") > nextPitstop)
							refuel := ("!" . refuel)

						this.planPitstop(plannedPitstopLap, refuel, "!" . tyreChange, tyreCompound, tyreCompoundColor)
					}
					else
						this.confirmNextPitstop(plannedPitstopLap)
			}
			finally {
				speaker.endTalk({Important: true})

				if fullCourseYellow
					this.Strategy.FullCourseYellow := false

				if forcedPitstop
					this.Strategy.ForcedPitstop := false
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
		local duplicateNr := false
		local duplicateID := false
		local driverID := getMultiMapValue(raceData, "Cars", "Driver.ID", kUndefined)
		local driverNr := getMultiMapValue(raceData, "Cars", "Driver.Nr", kUndefined)
		local carNr, carID, carClass, carCategory, carPosition, nrKey, idKey

		raceInfo["Driver"] := getMultiMapValue(raceData, "Cars", "Driver")
		raceInfo["Cars"] := getMultiMapValue(raceData, "Cars", "Count")

		if (raceInfo["Cars"] = 0)
			return

		if getMultiMapValue(raceData, "Cars", "Slots", false)
			raceInfo["Slots"] := string2Map("|", "->", getMultiMapValue(raceData, "Cars", "Slots"))
		else if this.RaceInfo
			raceInfo["Slots"] := this.RaceInfo["Slots"]
		else
			slots := CaseInsenseMap()

		loop raceInfo["Cars"] {
			carNr := getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Nr", "-")
			carID := getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".ID", A_Index)
			carPosition := getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Position")
			carClass := getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Class", "Unknown")
			carCategory := getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Category", false)

			nrKey := ("#" . carNr)
			idKey := ("!" . carID)

			if slots {
				if slots.Has(nrKey)
					duplicateNr := true

				if slots.Has(idKey)
					duplicateID := true

				slots[nrKey] := A_Index
				slots[idKey] := A_Index
			}

			grid.Push(carPosition)
			classes.Push(carClass)
			categories.Push(carCategory)

			if raceInfo.Has(nrKey)
				duplicateNr := true

			if raceInfo.Has(idKey)
				duplicateID := true

			raceInfo[nrKey] := A_Index
			raceInfo[idKey] := A_Index
		}

		if duplicateNr
			loop raceInfo["Cars"] {
				nrKey := ("#" . getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Nr", "-"))

				if raceInfo.Has(nrKey)
					raceInfo.Delete(nrKey)

				if (slots && slots.Has(nrKey))
					slots.Delete(nrKey)
			}

		if duplicateID
			loop raceInfo["Cars"] {
				idKey := ("!" . getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".ID", A_Index))

				if raceInfo.Has(idKey)
					raceInfo.Delete(idKey)

				if (slots && slots.Has(idKey))
					slots.Delete(idKey)
			}

		raceInfo["HasNr"] := !duplicateNr
		raceInfo["HasID"] := !duplicateID

		if (!duplicateID && (driverID != kUndefined)) {
			loop raceInfo["Cars"]
				if (driverID = getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".ID", A_Index)) {
					raceInfo["Driver"] := A_Index

					break
				}
		}
		else if (!duplicateNr && (driverNr != kUndefined) && (driverNr != "-"))
			loop raceInfo["Cars"]
				if (driverNr = getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Nr", "-")) {
					raceInfo["Driver"] := A_Index

					break
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
		local validLap := true
		local driver, driverID, carCount, data, raceInfo, slots, grid, carNr, carID, key, fileName, slotsString
		local data, pitstop, pitstops, prefix, times, position, positions, drivers, laps, carPrefix, carIndex
		local driverForname, driverSurname, driverNickname, driverCategory, carCar, carCategory, lapState
		local mixedCompounds, index, tyre, axle, tyreCompound, tyreCompoundColor

		if this.RemoteHandler {
			driver := knowledgeBase.getValue("Driver.Car", 0)
			carCount := knowledgeBase.getValue("Car.Count", 0)

			if ((driver == 0) || (carCount == 0))
				return

			if ((lapNumber < 5) && !this.iRaceInfoSaved) {
				this.iRaceInfoSaved := true

				data := newMultiMap()

				setMultiMapValue(data, "Session", "Time", this.SessionTime)
				setMultiMapValue(data, "Session", "Simulator", knowledgeBase.getValue("Session.Simulator"))
				setMultiMapValue(data, "Session", "Car", knowledgeBase.getValue("Session.Car"))
				setMultiMapValue(data, "Session", "Track", knowledgeBase.getValue("Session.Track"))
				setMultiMapValue(data, "Session", "Duration", (Round((knowledgeBase.getValue("Session.Duration") / 60) / 5) * 300))
				setMultiMapValue(data, "Session", "Format", knowledgeBase.getValue("Session.Format"))

				setMultiMapValue(data, "Cars", "Count", carCount)
				setMultiMapValue(data, "Cars", "Driver", driver)
				setMultiMapValue(data, "Cars", "Driver.Nr", knowledgeBase.getValue("Car." . driver . ".Nr", "-"))
				setMultiMapValue(data, "Cars", "Driver.ID", knowledgeBase.getValue("Car." . driver . ".ID", driver))

				raceInfo := this.RaceInfo
				grid := (raceInfo ? raceInfo["Grid"] : false)
				slots := (raceInfo ? raceInfo["Slots"] : false)

				if isDebug()
					logMessage(kLogDebug, "RaceInfo - Lap: " . lapNumber . "; Grid: " . (grid ? kTrue : kFalse) . "; Slots: " . (slots ? kTrue : kFalse))

				if slots
					setMultiMapValue(data, "Cars", "Slots", map2String("|", "->", slots))

				loop carCount {
					carNr := knowledgeBase.getValue("Car." . A_Index . ".Nr", "-")
					carID := knowledgeBase.getValue("Car." . A_Index . ".ID", A_Index)

					carIndex := false

					if slots {
						key := ("#" . carNr)

						carIndex := (slots.Has(key) ? slots[key] : false)

						if !carIndex {
							key := ("!" . carID)

							carIndex := (slots.Has(key) ? slots[key] : A_Index)
						}
					}

					if !carIndex {
						key := ("#" . carNr)

						if ((raceInfo != false) && raceInfo.Has(key))
							carIndex := grid[raceInfo[key]]
						else {
							key := ("!" . carID)

							if ((raceInfo != false) && raceInfo.Has(key))
								carIndex := grid[raceInfo[key]]
							else
								carIndex := A_Index
						}
					}

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

							position := knowledgeBase.getValue("Car." . A_Index . ".Position", A_Index)

							if grid
								if (raceInfo && raceInfo.Has(key) && grid.Has(raceInfo[key]))
									position := grid[raceInfo[key]]
								else if grid.Has(carIndex)
									position := grid[carIndex]

							setMultiMapValue(data, "Cars", "Car." . carIndex . ".Position", position)

							if (A_Index = driver) {
								validLap := knowledgeBase.getValue("Car." . A_Index . ".Lap.Valid")

								if isDebug()
									logMessage(kLogDebug, "RaceInfo - Driver Position: " . getMultiMapValue(data, "Cars", "Car." . carIndex . ".Position"))
							}
						}
					}
				}

				this.updateRaceInfo(data)

				setMultiMapValue(data, "Cars", "Driver", this.RaceInfo["Driver"])
				setMultiMapValue(data, "Cars", "Slots", map2String("|", "->", this.RaceInfo["Slots"]))

				fileName := temporaryFileName("Race Strategist Race", "info")

				writeMultiMap(fileName, data)

				this.RemoteHandler.saveRaceInfo(lapNumber, fileName)
			}

			data := newMultiMap()

			if (this.Session = kSessionRace) {
				pitstop := knowledgeBase.getValue("Pitstop.Last", false)

				if pitstop {
					pitstops := []

					loop pitstop
						pitstops.Push(knowledgeBase.getValue("Pitstop." . A_Index . ".Lap"))

					setMultiMapValue(data, "Pitstop", "Laps", values2String(",", pitstops*))

					pitstop := (lapNumber == (knowledgeBase.getValue("Pitstop." . pitstop . ".Lap") + 1))
				}
			}
			else {
				pitstop := false

				driverID := knowledgeBase.getValue("Car." . driver . ".ID", kUndefined)

				if (driverID != kUndefined)
					for index, pitstop in this.Pitstops[driverID]
						if (pitstop.Lap = lapNumber)
							pitstop := true
			}

			this.Provider.supportsTyreManagement(&mixedCompounds)

			prefix := "Lap." . lapNumber

			tyreCompound := knowledgeBase.getValue(prefix . ".Tyre.Compound", "Dry")
			tyreCompoundColor := knowledgeBase.getValue(prefix . ".Tyre.Compound.Color", "Black")

			if (mixedCompounds = "Wheel") {
				tyreCompound := collect(["FrontLeft", "FrontRight", "RearLeft", "RearRight"], (tyre) {
									return knowledgeBase.getValue(prefix . ".Tyre.Compound." . tyre, tyreCompound)
								})
				tyreCompoundColor := collect(["FrontLeft", "FrontRight", "RearLeft", "RearRight"], (tyre) {
										 return knowledgeBase.getValue(prefix . ".Tyre.Compound.Color." . tyre, tyreCompoundColor)
									 })

				combineCompounds(&tyreCompound, &tyreCompoundColor)
			}
			else if (mixedCompounds = "Axle") {
				tyreCompound := collect(["Front", "Rear"], (axle) {
									return knowledgeBase.getValue(prefix . ".Tyre.Compound." . axle, tyreCompound)
								})
				tyreCompoundColor := collect(["Front", "Rear"], (axle) {
										 return knowledgeBase.getValue(prefix . ".Tyre.Compound.Color." . axle, tyreCompoundColor)
									 })

				combineCompounds(&tyreCompound, &tyreCompoundColor)
			}
			else {
				tyreCompound := [tyreCompound]
				tyreCompoundColor := [tyreCompoundColor]
			}

			if validLap
				validLap := knowledgeBase.getValue(prefix . ".Valid", validLap)

			if !validLap
				lapState := "Invalid"
			else if this.hasEnoughData(false)
				lapState := "Valid"
			else
				lapState := "Warmup"

			setMultiMapValue(data, "Lap", "Lap", lapNumber)

			setMultiMapValue(data, "Lap", prefix . ".Weather", knowledgeBase.getValue("Standings.Lap." . lapNumber . ".Weather"))
			setMultiMapValue(data, "Lap", prefix . ".LapTime", knowledgeBase.getValue(prefix . ".Time"))
			setMultiMapValue(data, "Lap", prefix . ".Compound", values2String(",", tyreCompound*))
			setMultiMapValue(data, "Lap", prefix . ".CompoundColor", values2String(",", tyreCompoundColor*))
			setMultiMapValue(data, "Lap", prefix . ".Map", knowledgeBase.getValue(prefix . ".Map", "n/a"))
			setMultiMapValue(data, "Lap", prefix . ".TC", knowledgeBase.getValue(prefix . ".TC", "n/a"))
			setMultiMapValue(data, "Lap", prefix . ".ABS", knowledgeBase.getValue(prefix . ".ABS", "n/a"))
			setMultiMapValue(data, "Lap", prefix . ".BB", knowledgeBase.getValue(prefix . ".BB", "n/a"))
			setMultiMapValue(data, "Lap", prefix . ".Consumption", knowledgeBase.getValue(prefix . ".Fuel.Consumption", "n/a"))
			setMultiMapValue(data, "Lap", prefix . ".Pitstop", pitstop)
			setMultiMapValue(data, "Lap", prefix . ".State", lapState)

			raceInfo := this.RaceInfo
			slots := false

			if raceInfo {
				slots := raceInfo["Slots"]

				if slots {
					if (raceInfo["HasNr"] && raceInfo["HasID"])
						carCount := Floor(slots.Count / 2)
					else if (raceInfo["HasNr"] || raceInfo["HasID"])
						carCount := slots.Count
					else
						carCount := raceInfo["Cars"]
				}
				else
					carCount := raceInfo["Cars"]
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

				carNr := knowledgeBase.getValue(carPrefix . ".Nr", "-")

				carIndex := false

				if slots {
					key := ("#" . carNr)

					if slots.Has(key)
						carIndex := slots[key]
					else {
						key := ("!" . carID)

						if slots.Has(key)
							carIndex := slots[key]
					}
				}

				if !carIndex {
					key := ("#" . carNr)

					if raceInfo.Has(key)
						carIndex := raceInfo[key]
					else {
						key := ("!" . carID)

						if raceInfo.Has(key)
							carIndex := raceInfo[key]
					}
				}

				if !carIndex
					carIndex := A_Index

				if times.Has(carIndex) {
					times[carIndex] := knowledgeBase.getValue(carPrefix . ".Time", "-")
					positions[carIndex] := knowledgeBase.getValue(carPrefix . ".Position", "-")
					laps[carIndex] := (isNumber(knowledgeBase.getValue(carPrefix . ".Laps", "-")) ? Floor(knowledgeBase.getValue(carPrefix . ".Laps")) : "-")

					driverForname := knowledgeBase.getValue(carPrefix . ".Driver.Forname")
					driverSurname := knowledgeBase.getValue(carPrefix . ".Driver.Surname")
					driverNickname := knowledgeBase.getValue(carPrefix . ".Driver.Nickname")

					drivers[carIndex] := driverName(driverForname, driverSurname, driverNickname)

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
		if isDebug()
			logMessage(kLogDebug, "Restore Race Info...")

		this.updateRaceInfo(readMultiMap(raceInfoFile))

		deleteFile(raceInfoFile)
	}

	createRaceReport() {
		if this.RemoteHandler
			this.RemoteHandler.createRaceReport()
	}

	saveLapData(lapNumber, simulator, car, track, weather, airTemperature, trackTemperature
			  , fuelConsumption, fuelRemaining, lapTime, pitstop, map, tc, abs, bb
			  , compound, compoundColor, pressures, temperatures, wear, lapState
			  , waterTemperature, oilTemperature) {
		local knowledgeBase := this.KnowledgeBase
		local lastPitstop := knowledgeBase.getValue("Pitstop.Last", false)
		local lapsDB := this.LapsDatabase
		local tyreLaps := false
		local stintLaps, ignore, thePitstop

		if (this.PitstopHistory && (this.PitstopHistory.Length > 0)) {
			thePitstop := this.PitstopHistory[this.PitstopHistory.Length]

			stintLaps := (lapNumber - thePitstop.Lap)

			tyreLaps := values2String(",", thePitstop.TyreLapsFrontLeft + stintLaps
										 , thePitstop.TyreLapsFrontRight + stintLaps
										 , thePitstop.TyreLapsRearLeft + stintLaps
										 , thePitstop.TyreLapsRearRight + stintLaps)
		}
		else if lastPitstop
			stintLaps := (lapNumber - (knowledgeBase.getValue("Pitstop." . lastPitstop . ".Lap")))
		else
			stintLaps := lapNumber

		if !tyreLaps
			tyreLaps := values2String(",", lapNumber, lapNumber, lapNumber, lapNumber)

		if ((lapState = "Valid") && !pitstop) {
			lapsDB.addElectronicEntry(weather, airTemperature, trackTemperature, compound, compoundColor
											 , map, tc, abs, bb, fuelConsumption, fuelRemaining, lapTime
											 , isDebug() ? SessionDatabase.getDriverID(this.Simulator, this.DriverFullName) : false)

			if (stintLaps > 1)
				lapsDB.addTyreEntry(weather, airTemperature, trackTemperature
										   , compound, compoundColor, tyreLaps
										   , pressures[1], pressures[2], pressures[3], pressures[4]
										   , temperatures[1], temperatures[2], temperatures[3], temperatures[4]
										   , wear ? wear[1] : kNull, wear ? wear[2] : kNull
										   , wear ? wear[3] : kNull, wear ? wear[4] : kNull
										   , fuelConsumption, fuelRemaining, lapTime
										   , isDebug() ? SessionDatabase.getDriverID(this.Simulator, this.DriverFullName) : false)
		}

		if pitstop
			tyreLaps := kNull

		if (this.RemoteHandler && this.CollectLaps) {
			this.updateDynamicValues({HasLapsData: true})

			this.RemoteHandler.saveLapData(lapNumber, simulator, car, track, weather, airTemperature, trackTemperature
										  , fuelConsumption, fuelRemaining, lapTime, pitstop, map, tc, abs, bb
										  , compound, compoundColor, tyreLaps, values2String(",", pressures*), values2String(",", temperatures*)
										  , wear ? values2String(",", wear*) : false
										  , lapState, waterTemperature, oilTemperature)
		}
	}

	updateLapsDatabase() {
		if (this.RemoteHandler && this.CollectLaps)
			this.RemoteHandler.updateLapsDatabase()

		this.updateDynamicValues({HasLapsData: false})
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                  Internal Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

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

notifyWeatherForecast(context, weather, minutes, change) {
	context.KnowledgeBase.RaceAssistant.weatherForecast(weather, minutes, change)

	return true
}

requestTyreChange(context, weather, minutes, recommendedCompound) {
	context.KnowledgeBase.RaceAssistant.clearContinuation()

	context.KnowledgeBase.RaceAssistant.requestTyreChange(weather, minutes, recommendedCompound)

	return true
}

reportUpcomingPitstop(context, lap) {
	context.KnowledgeBase.RaceAssistant.clearContinuation()

	context.KnowledgeBase.RaceAssistant.reportUpcomingPitstop(lap)

	return true
}

pitstopPerformed(context, pitstopNr) {
	context.KnowledgeBase.RaceAssistant.pitstopPerformed(pitstopNr)

	return true
}