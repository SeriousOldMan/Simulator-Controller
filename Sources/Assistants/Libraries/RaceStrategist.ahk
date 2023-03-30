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

		PlannedLap {
			Get {
				return this.iPlannedLap
			}
		}

		__New(manager, plannedLap, arguments*) {
			this.iPlannedLap := plannedLap

			super.__New(manager, arguments*)
		}

		cancel() {
			if ProcessExist("Race Engineer.exe") {
				this.Manager.getSpeaker().speakPhrase("ConfirmInformEngineerAnyway", false, true)

				this.Manager.setContinuation(ObjBindMethod(this.Manager, "planPitstop", this.PlannedLap))
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
							if ((candidate.Map = entry.Map) && (candidate["Lap.Time"] = entry["Lap.Time"])
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

	class RaceStrategySimulationTask extends Task {
		iRaceStrategist := false
		iTelemetryDatabase := false

		iLap := false

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

		Lap {
			Get {
				return this.iLap
			}
		}

		Pitstops[key := false] {
			Get {
				return (key ? this.iPitstops[key] : this.iPitstops)
			}
		}

		UsedTyreSets[key := false] {
			Get {
				return (key ? this.iUsedTyreSets[key] : this.iUsedTyreSets)
			}
		}

		__New(strategist, configuration) {
			local knowledgeBase := strategist.KnowledgeBase

			super.__New(false, 0, kLowPriority)

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
			VariationSimulation(this.RaceStrategist
							  , (this.RaceStrategist.KnowledgeBase.getValue("Session.Format") = "Time") ? "Duration" : "Laps"
							  , this.TelemetryDatabase).runSimulation(isDebug())

			return false
		}
	}

	class RaceStrategy extends Strategy {
		initializeAvailableTyreSets() {
			super.initializeAvailableTyreSets()

			this.StrategyManager.StrategyManager.initializeAvailableTyreSets(this)
		}
	}

	RaceInfo[key := false] {
		Get {
			return (key ? this.iRaceInfo[key] : this.iRaceInfo)
		}
	}

	Strategy[original := false] {
		Get {
			return (original ? this.iOriginalStrategy : this.iStrategy)
		}
	}

	StrategyReported {
		Get {
			return this.iStrategyReported
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

	__New(configuration, remoteHandler, name := false, language := "__Undefined__"
		, synthesizer := false, speaker := false, vocalics := false, recognizer := false, listener := false, muted := false, voiceServer := false) {
		super.__New(configuration, "Race Strategist", remoteHandler, name, language, synthesizer, speaker, vocalics, recognizer, listener, muted, voiceServer)

		this.updateConfigurationValues({Announcements: {WeatherUpdate: true}})

		deleteDirectory(kTempDirectory . "Race Strategist")

		DirCreate(kTempDirectory "Race . Strategist")

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
	}

	updateSessionValues(values) {
		super.updateSessionValues(values)

		if values.HasProp("TelemetryDatabase")
			this.iTelemetryDatabase := values.TelemetryDatabase

		if values.HasProp("OriginalStrategy")
			this.iOriginalStrategy := values.OriginalStrategy

		if values.HasProp("Strategy")
			this.iStrategy := values.Strategy

		if values.HasProp("RaceInfo")
			this.iRaceInfo := values.RaceInfo
	}

	updateDynamicValues(values) {
		super.updateDynamicValues(values)

		if values.HasProp("HasTelemetryData")
			this.iHasTelemetryData := values.HasTelemetryData

		if values.HasProp("StrategyReported")
			this.iStrategyReported := values.StrategyReported
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

	handleVoiceCommand(grammar, words) {
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
				this.clearContinuation()

				this.getSpeaker().speakPhrase("Confirm")

				Task.yield()

				loop 10
					Sleep(500)

				this.recommendStrategyRecognized(words)
			case "PitstopRecommend":
				this.clearContinuation()

				this.getSpeaker().speakPhrase("Confirm")

				Task.yield()

				loop 10
					Sleep(500)

				this.recommendPitstopRecognized(words)
			case "PitstopSimulate":
				this.clearContinuation()

				this.getSpeaker().speakPhrase("Confirm")

				Task.yield()

				loop 10
					Sleep(500)

				this.simulatePitstopRecognized(words)
			default:
				super.handleVoiceCommand(grammar, words)
		}
	}

	lapsRemainingRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker, remainingFuelLaps, remainingSessionLaps, remainingStintLaps

		if !this.hasEnoughData()
			return

		speaker := this.getSpeaker()
		remainingFuelLaps := Round(knowledgeBase.getValue("Lap.Remaining.Fuel", 0))

		if (remainingFuelLaps == 0)
			speaker.speakPhrase("Later")
		else {
			speaker.beginTalk()

			try {
				speaker.speakPhrase("LapsFuel", {laps: remainingFuelLaps})

				remainingSessionLaps := Round(knowledgeBase.getValue("Lap.Remaining.Session"))
				remainingStintLaps := Round(knowledgeBase.getValue("Lap.Remaining.Stint"))

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
		local speaker, overallPosition, classPosition

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

				if (delta = 0) {
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

		if (this.getPosition(false, "Class") = this.getCars("Class").Length())
			speaker.speakPhrase("NoGapToBehind")
		else {
			speaker.beginTalk()

			try {
				lap := knowledgeBase.getValue("Lap")
				car := knowledgeBase.getValue("Position.Standings.Class.Behind.Car")
				delta := Abs(knowledgeBase.getValue("Position.Standings.Class.Behind.Delta", 0) / 1000)
				inPit := (knowledgeBase.getValue("Car." . car . ".InPitLane", false) || knowledgeBase.getValue("Car." . car . ".InPit", false))
				lapped := false

				if (delta = 0) {
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

	lapTimesRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local car, lap, position, cars, driverLapTime, speaker, minute, seconds

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
					this.reportLapTime("LapTimeFront", driverLapTime, knowledgeBase.getValue("Position.Standings.Class.Ahead.Car", 0))

				if (position < cars)
					this.reportLapTime("LapTimeBehind", driverLapTime, knowledgeBase.getValue("Position.Standings.Class.Behind.Car", 0))

				if (position > 1)
					this.reportLapTime("LapTimeLeader", driverLapTime, knowledgeBase.getValue("Position.Standings.Class.Leader.Car", 0))
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
				this.getSpeaker().speakPhrase("ActiveCarsClass", {overallCars: this.getCars().Length(), classCars: this.getCars("Class").Length()})
			else
				this.getSpeaker().speakPhrase("ActiveCars", {cars: this.getCars().Length()})
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

	loadStrategy(facts, strategy, lap := false) {
		local pitstop, count, ignore, pitstopLap, first

		facts["Strategy.Name"] := strategy.Name

		facts["Strategy.Weather"] := strategy.Weather
		facts["Strategy.Weather.Temperature.Air"] := strategy.AirTemperature
		facts["Strategy.Weather.Temperature.Track"] := strategy.TrackTemperature

		facts["Strategy.Tyre.Compound"] := strategy.TyreCompound
		facts["Strategy.Tyre.Compound.Color"] := strategy.TyreCompoundColor

		facts["Strategy.Map"] := strategy.Map
		facts["Strategy.TC"] := strategy.TC
		facts["Strategy.ABS"] := strategy.ABS

		count := 0

		for ignore, pitstop in strategy.Pitstops {
			pitstopLap := pitstop.Lap

			if (lap && (pitstopLap < lap))
				continue

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

	readSettings(&settings) {
		return combine(super.readSettings(&settings)
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
																													  , "Strategy.Window.Considered", 2)))
	}

	prepareSession(&settings, &data) {
		local raceData, carCount,  carNr

		this.updateSessionValues({RaceInfo: false})

		super.prepareSession(&settings, &data)

		raceData := newMultiMap()

		carCount := getMultiMapValue(data, "Position Data", "Car.Count")

		setMultiMapValue(raceData, "Cars", "Count", carCount)
		setMultiMapValue(raceData, "Cars", "Driver", getMultiMapValue(data, "Position Data", "Driver.Car"))

		loop carCount {
			carNr := getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Nr")

			setMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Nr", carNr)
			setMultiMapValue(raceData, "Cars", "Car." . A_Index . ".ID"
									 , getMultiMapValue(data, "Position Data", "Car." . A_Index . ".ID", A_Index))
			setMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Class"
									 , getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Class", kUnknown))
			setMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Position"
									 , getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Position"))
		}

		this.updateRaceInfo(raceData)
	}

	createSession(&settings, &data) {
		local facts := super.createSession(&settings, &data)
		local simulatorName := this.SettingsDatabase.getSimulatorName(facts["Session.Simulator"])
		local theStrategy, applicableStrategy, simulator, car, track
		local sessionType, sessionLength, duration, laps, configuration

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

				if applicableStrategy {
					this.loadStrategy(facts, theStrategy)

					this.updateSessionValues({OriginalStrategy: theStrategy, Strategy: theStrategy})
				}
			}
		}

		configuration := this.Configuration

		facts["Session.Settings.Lap.Learning.Laps"]
			:= getMultiMapValue(configuration, "Race Strategist Analysis", simulatorName . ".LearningLaps", 1)
		facts["Session.Settings.Lap.History.Considered"]
			:= getMultiMapValue(configuration, "Race Strategist Analysis", simulatorName . ".ConsideredHistoryLaps", 5)
		facts["Session.Settings.Lap.History.Damping"]
			:= getMultiMapValue(configuration, "Race Strategist Analysis", simulatorName . ".HistoryLapsDamping", 0.2)

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
								, StrategyReported: false, HasTelemetryData: false})
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
		if this.RemoteHandler {
			this.setContinuation(RaceStrategist.RaceReviewContinuation(this, ObjBindMethod(this, "finishSession", shutdown, false)))

			this.RemoteHandler.reviewRace()
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

	addLap(lapNumber, &data) {
		local knowledgeBase := this.KnowledgeBase
		local driverForname := ""
		local driverSurname := ""
		local driverNickname := ""
		local compound, result, gapAhead, gapBehind, lap, simulator, car, track
		local pitstop, prefix, validLap, weather, airTemperature, trackTemperature, compound, compoundColor
		local fuelConsumption, fuelRemaining, lapTime, map, tc, abs, pressures, temperatures, wear, multiClass

		static lastLap := 0

		static adjustGaps := true
		static lastGapAhead := kUndefined
		static lastGapBehind := kUndefined
		static sameGapCount := 0

		if (lapNumber <= lastLap)
			lastLap := 0
		else if ((lastLap == 0) && (lapNumber > 1))
			lastLap := (lapNumber - 1)

		if (this.Speaker && (lapNumber > 1)) {
			driverForname := knowledgeBase.getValue("Driver.Forname", "John")
			driverSurname := knowledgeBase.getValue("Driver.Surname", "Doe")
			driverNickname := knowledgeBase.getValue("Driver.Nickname", "JDO")
		}

		result := super.addLap(lapNumber, &data)

		if !result
			return false

		knowledgeBase := this.KnowledgeBase

		if (this.Speaker && (lastLap < (lapNumber - 2))
		 && (computeDriverName(driverForname, driverSurname, driverNickname) != this.DriverFullName))
			this.getSpeaker().speakPhrase(ProcessExist("Race Engineer.exe") ? "" : "WelcomeBack")

		lastLap := lapNumber

		if (!this.StrategyReported && this.hasEnoughData(false) && this.Strategy && (this.Strategy == this.Strategy[true])) {
			if this.Speaker[false] {
				this.getSpeaker().speakPhrase("ConfirmReportStrategy", false, true)

				this.setContinuation(ObjBindMethod(this, "reportStrategy"))
			}

			this.updateDynamicValues({StrategyReported: lapNumber})
		}

		if !this.MultiClass {
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

			if adjustGaps {
				if ((gapAhead != kUndefined) && (gapAhead != 0)) {
					knowledgeBase.setFact("Position.Standings.Class.Ahead.Delta", gapAhead)

					if (knowledgeBase.getValue("Position.Track.Ahead.Car", -1) = knowledgeBase.getValue("Position.Standings.Class.Ahead.Car", 0))
						knowledgeBase.setFact("Position.Track.Ahead.Delta", gapAhead)
				}

				if ((gapBehind != kUndefined) && (gapBehind != 0)) {
					knowledgeBase.setFact("Position.Standings.Class.Behind.Delta", gapBehind)

					if (knowledgeBase.getValue("Position.Track.Behind.Car", -1) = knowledgeBase.getValue("Position.Standings.Class.Behind.Car", 0))
						knowledgeBase.setFact("Position.Track.Behind.Delta", gapBehind)
				}
			}
		}

		loop knowledgeBase.getValue("Car.Count") {
			lap := knowledgeBase.getValue("Car." . A_Index . ".Lap", 0)

			if (lap != knowledgeBase.getValue("Car." . A_Index . ".Valid.LastLap", 0)) {
				knowledgeBase.setFact("Car." . A_Index . ".Valid.LastLap", lap)

				if (knowledgeBase.getValue("Car." . A_Index . ".Lap.Valid", kUndefined) == kUndefined)
					knowledgeBase.addFact("Car." . A_Index . ".Lap.Valid", knowledgeBase.getValue("Car." . A_Index . ".Valid.Running", true))

				if knowledgeBase.getValue("Car." . A_Index . ".Lap.Valid", true)
					knowledgeBase.setFact("Car." . A_Index . ".Valid.Laps", knowledgeBase.getValue("Car." . A_Index . ".Valid.Laps", 0) +  1)
			}
		}

		simulator := knowledgeBase.getValue("Session.Simulator")
		car := knowledgeBase.getValue("Session.Car")
		track := knowledgeBase.getValue("Session.Track")

		pitstop := knowledgeBase.getValue("Pitstop.Last", false)

		if pitstop
			pitstop := (Abs(lapNumber - (knowledgeBase.getValue("Pitstop." . pitstop . ".Lap"))) <= 2)

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
				abs := knowledgeBase.getValue(prefix . ".ABS")

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
									 , fuelConsumption, fuelRemaining, lapTime, pitstop, map, tc, abs
									 , compound, compoundColor, pressures, temperatures, wear)
			}
		}

		this.saveStandingsData(lapNumber, simulator, car, track)

		return result
	}

	updateLap(lapNumber, &data) {
		local knowledgeBase := this.KnowledgeBase
		local sector, result, gapAhead, gapBehind, valid

		static lastSector := 1

		if !isObject(data)
			data := readMultiMap(data)

		sector := getMultiMapValue(data, "Stint Data", "Sector", 0)

		if (sector != lastSector) {
			lastSector := sector

			this.KnowledgeBase.addFact("Sector", sector)
		}

		result := super.updateLap(lapNumber, &data)

		loop knowledgeBase.getValue("Car.Count") {
			valid := knowledgeBase.getValue("Car." . A_Index . ".Lap.Running.Valid", kUndefined)

			if (valid != kUndefined)
				knowledgeBase.setFact("Car." . A_Index . ".Valid.Running", valid)
		}

		if !this.MultiClass {
			gapAhead := getMultiMapValue(data, "Stint Data", "GapAhead", kUndefined)

			if (gapAhead != kUndefined) {
				knowledgeBase.setFact("Position.Standings.Class.Ahead.Delta", gapAhead)

				if (knowledgeBase.getValue("Position.Track.Ahead.Car", -1) = knowledgeBase.getValue("Position.Standings.Class.Ahead.Car", 0))
					knowledgeBase.setFact("Position.Track.Ahead.Delta", gapAhead)
			}

			gapBehind := getMultiMapValue(data, "Stint Data", "GapBehind", kUndefined)

			if (gapBehind != kUndefined) {
				knowledgeBase.setFact("Position.Standings.Class.Behind.Delta", gapBehind)

				if (knowledgeBase.getValue("Position.Track.Behind.Car", -1) = knowledgeBase.getValue("Position.Standings.Class.Behind.Car", 0))
					knowledgeBase.setFact("Position.Track.Behind.Delta", gapBehind)
			}
		}

		return result
	}

	requestInformation(category, arguments*) {
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

	reportStrategy(options := true) {
		local knowledgeBase := this.KnowledgeBase
		local reported := false
		local strategyName, speaker, nextPitstop, lap, refuel, tyreChange, map

		if this.Speaker {
			strategyName := knowledgeBase.getValue("Strategy.Name", false)
			speaker := this.getSpeaker()

			if strategyName {
				speaker.beginTalk()

				try {
					if ((options == true) || (options.Has("Strategy") && options.Strategy))
						speaker.speakPhrase("Strategy")

					if ((options == true) || (options.Has("Pitstops") && options.Pitstops)) {
						speaker.speakPhrase("Pitstops", {pitstops: knowledgeBase.getValue("Strategy.Pitstop.Count")})

						reported := true
					}

					nextPitstop := knowledgeBase.getValue("Strategy.Pitstop.Next", false)

					if nextPitstop {
						if ((options == true) || (options.Has("NextPitstop") && options.NextPitstop)) {
							lap := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Lap")
							refuel := Round(knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Fuel.Amount"))
							tyreChange := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Tyre.Change")

							speaker.speakPhrase("NextPitstop", {pitstopLap: lap})

							if ((options == true) || (options.Has("Refuel") && options.Refuel))
								speaker.speakPhrase((refuel > 0) ? "Refuel" : "NoRefuel"
												  , {fuel: displayValue("Float", convertUnit("Volume", refuel)), unit: speaker.Fragments[getUnit("Volume")]})

							if ((options == true) || (options.Has("TyreChange") && options.TyreChange))
								speaker.speakPhrase(tyreChange ? "TyreChange" : "NoTyreChange")
						}
					}
					else if ((options == true) || (options.Has("NextPitstop") && options.NextPitstop))
						if !reported
							speaker.speakPhrase("NoNextPitstop")

					if ((options == true) || (options.Has("Map") && options.Map)) {
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

	cancelStrategy(confirm := true) {
		local knowledgeBase := this.KnowledgeBase
		local hasStrategy := knowledgeBase.getValue("Strategy.Name", false)
		local fact

		if (this.Speaker && confirm) {
			if hasStrategy {
				this.getSpeaker().speakPhrase("ConfirmCancelStrategy", false, true)

				this.setContinuation(ObjBindMethod(this, "cancelStrategy", false))
			}
			else
				this.getSpeaker().speakPhrase("NoStrategy")

			return
		}

		if hasStrategy {
			this.clearStrategy()

			if this.Speaker
				this.getSpeaker().speakPhrase("StrategyCanceled")

			this.updateSessionValues({OriginalStrategy: false, Strategy: false})
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

		this.iStrategy := false
	}

	recommendStrategy(options := true) {
		local knowledgeBase := this.KnowledgeBase
		local engineerPID

		if !this.hasEnoughData()
			return

		if knowledgeBase.getValue("Strategy.Name", false) {
			engineerPID := ProcessExist("Race Engineer.exe")

			if engineerPID
				messageSend(kFileMessage, "Race Engineer", "requestPitstopHistory:Race Strategist;runSimulation;" . ProcessExist(), engineerPID)
			else if this.Speaker
				this.getSpeaker().speakPhrase("NoStrategyRecommendation")
		}
		else if this.Speaker
			this.getSpeaker().speakPhrase("NoStrategy")
	}

	updateStrategy(strategy, original := true) {
		local knowledgeBase := this.KnowledgeBase
		local fact, value

		this.updateDynamicValues({StrategyReported: true})

		if strategy {
			if (this.Session == kSessionRace) {
				if !isObject(strategy)
					strategy := Strategy(this, readMultiMap(strategy))

				this.clearStrategy()

				for fact, value in this.loadStrategy(CaseInsenseMap(), strategy, knowledgeBase.getValue("Lap") + 1)
					knowledgeBase.setFact(fact, value)

				this.dumpKnowledgeBase(knowledgeBase)

				if original
					this.updateSessionValues({OriginalStrategy: strategy, Strategy: strategy})
				else {
					this.updateSessionValues({Strategy: strategy})

					this.reportStrategy({Strategy: true, Pitstops: false, NextPitstop: true, TyreChange: true, Refuel: true})
				}
			}
		}
		else
			this.cancelStrategy(false)
	}

	runSimulation(pitstopHistory) {
		local data

		if !isObject(pitstopHistory) {
			data := readMultiMap(pitstopHistory)

			if !isDebug()
				deleteFile(pitstopHistory)
		}

		RaceStrategist.RaceStrategySimulationTask(this, data).start()
	}

	createStrategy(nameOrConfiguration, driver := false) {
		local name := nameOrConfiguration
		local theStrategy

		if !isObject(nameOrConfiguration)
			nameOrConfiguration := false

		theStrategy := RaceStrategist.RaceStrategy(this, nameOrConfiguration, driver)

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

		if strategy {
			consumptionVariation := strategy.ConsumptionVariation
			initialFuelVariation := strategy.InitialFuelVariation
			tyreUsageVariation := strategy.TyreUsageVariation
			tyreCompoundVariation := strategy.TyreCompoundVariation
		}
		else {
			consumptionVariation := 0
			initialFuelVariation := 0
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
		local knowledgeBase := this.KnowledgeBase
		local telemetryDB := Task.CurrentTask.TelemetryDatabase
		local lapTimes := telemetryDB.getMapLapTimes(weather, tyreCompound, tyreCompoundColor)
		local tyreLapTimes := telemetryDB.getTyreLapTimes(weather, tyreCompound, tyreCompoundColor)
		local a := false
		local b := false
		local xValues, yValues, ignore, entry, baseLapTime, count, avgLapTime, lapTime, candidate

		if (tyreLapTimes.Length > 1) {
			xValues := []
			yValues := []

			for ignore, entry in tyreLapTimes {
				xValues.Push(entry["Tyre.Laps"])
				yValues.Push(entry["Lap.Time"])
			}

			linRegression(xValues, yValues, a, b)
		}

		baseLapTime := ((a && b) ? (a + (tyreLaps * b)) : false)

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

		return avgLapTime ? avgLapTime : (default ? default : this.Strategy.AvgLapTime)
	}

	computeAvailableTyreSets(availableTyreSets, usedTyreSets) {
		local compound, ignore, tyreSet, count

		availableTyreSets := availableTyreSets.Clone()

		for ignore, tyreSet in usedTyreSets {
			compound := compound(tyreSet.Compound, tyreSet.CompoundColor)

			if availableTyreSets.Has(compound) {
				count := (availableTyreSets[compound] - 1)

				if (count > 0)
					availableTyreSets[compound] := count
				else
					availableTyreSets.Delete(compound)
			}
		}

		return availableTyreSets
	}

	initializeAvailableTyreSets(strategy) {
		strategy.AvailableTyreSets := this.computeAvailableTyreSets(strategy.AvailableTyreSets, Task.CurrentTask.UsedTyreSets)
	}

	chooseScenario(strategy) {
		local configuration, fileName

		if strategy {
			if this.Strategy[true]
				strategy.PitstopRule := this.Strategy[true].PitstopRule

			if (isDebug() && !this.RemoteHandler) {
				configuration := newMultiMap()

				strategy.saveToConfiguration(configuration)

				writeMultiMap(kTempDirectory . "Race Strategist.strategy", configuration)
			}

			strategy.setVersion(A_Now . "")

			Task.startTask(ObjBindMethod(this, "updateStrategy", strategy, false), 1000)

			if this.RemoteHandler {
				fileName := temporaryFileName("Race Strategy", "update")
				configuration := newMultiMap()

				strategy.saveToConfiguration(configuration)

				writeMultiMap(fileName, configuration)

				if isDebug()
					try {
						FileCopy(fileName, kTempDirectory . "Race Strategist.strategy", 1)
					}
					catch Any as exception {
						logError(exception)
					}

				this.RemoteHandler.updateStrategy(fileName)
			}
		}
		else {
			Task.startTask(ObjBindMethod(this, "cancelStrategy", false), 1000)

			if isDebug()
				deleteFile(kTempDirectory . "Race Strategist.strategy")

			if this.RemoteHandler
				this.RemoteHandler.updateStrategy(false)
		}
	}

	recommendPitstop(lap := false) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local strategyLap, lastLap, plannedLap, position, traffic, hasEngineer

		if !this.hasEnoughData()
			return

		if !lap {
			strategyLap := knowledgeBase.getValue("Strategy.Pitstop.Lap", false)
			lap := strategyLap

			if (lap && (lap >= (knowledgeBase.getValue("Lap") - knowledgeBase.getValue("Session.Settings.Lap.PitstopWarning"))))
				lap := false

			lastLap := knowledgeBase.getValue("Lap")

			if (strategyLap && ((Abs(strategyLap - lastLap) / lastLap) > 0.1))
				strategyLap := false
		}

		knowledgeBase.setFact("Pitstop.Strategy.Plan", lap ? lap : true)

		knowledgeBase.produce()

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledgeBase(this.KnowledgeBase)

		plannedLap := knowledgeBase.getValue("Pitstop.Strategy.Lap", kUndefined)

		hasEngineer := (ProcessExist("Race Engineer.exe") != 0)

		if (plannedLap == kUndefined) {
			if (hasEngineer && strategyLap) {
				speaker.speakPhrase("PitstopLap", {lap: Max(strategyLap, lastLap + 1)})

				speaker.speakPhrase("ConfirmInformEngineer", false, true)

				this.setContinuation(ObjBindMethod(this, "planPitstop", strategyLap))
			}
			else
				speaker.speakPhrase("NoPlannedPitstop")
		}
		else if !plannedLap
			speaker.speakPhrase("NoPitstopNeeded")
		else {
			speaker.beginTalk()

			try {
				speaker.speakPhrase("PitstopLap", {lap: plannedLap})

				speaker.speakPhrase("Explain", false, true)

				if hasEngineer
					this.setContinuation(RaceStrategist.ExplainPitstopContinuation(this, plannedLap
																				 , ObjBindMethod(this, "explainPitstopRecommendation", plannedLap)
																				 , false, "Okay"))
				else
					this.setContinuation(ObjBindMethod(this, "explainPitstopRecommendation", plannedLap))
			}
			finally {
				speaker.endTalk()
			}
		}
	}

	explainPitstopRecommendation(plannedLap) {
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
				speaker.speakPhrase("EvaluatedLaps", {laps: laps.Length, first: laps[1], last: laps[laps.Length()]})

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

				this.setContinuation(ObjBindMethod(this, "planPitstop", plannedLap))
			}
		}
	}

	planPitstop(plannedLap := false, refuel := "__Undefined__", tyreChange := "__Undefined__"
			  , tyreCompound := "__Undefined__", tyreCompoundColor := "__Undefined__") {
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

		if (nextPitstop && (nextPitstop != knowledgeBase.getValue("Strategy.Pitstop.Next", false))) {
			map := knowledgeBase.getValue("Strategy.Pitstop." . nextPitstop . ".Map", "n/a")

			if ((map != "n/a") && (map != knowledgeBase.getValue("Lap." . knowledgeBase.getValue("Lap") . ".Map", "n/a")))
				this.getSpeaker().speakPhrase("StintMap", {map: map})
		}

		return result
	}

	callRecommendPitstop() {
		this.clearContinuation()

		this.getSpeaker().speakPhrase("Confirm")

		Task.yield()

		loop 10
			Sleep(500)

		this.recommendPitstop()
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

		if (this.Speaker[false] && (this.Session == kSessionRace) && this.Announcements["WeatherUpdate"]) {
			speaker := this.getSpeaker()

			speaker.speakPhrase(change ? "WeatherChange" : "WeatherNoChange", {minutes: minutes})
		}
	}

	weatherTyreChangeRecommendation(minutes, recommendedCompound) {
		local knowledgeBase := this.KnowledgeBase
		local speaker, fragments

		if (knowledgeBase.getValue("Lap.Remaining") > 3)
			if (this.Speaker[false] && (this.Session == kSessionRace)) {
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

		if this.Speaker[false] {
			speaker := this.getSpeaker()

			if this.hasEnoughData(false) {
				knowledgeBase.setFact("Pitstop.Strategy.Plan", plannedPitstopLap)

				knowledgeBase.produce()

				if this.Debug[kDebugKnowledgeBase]
					this.dumpKnowledgeBase(this.KnowledgeBase)

				plannedLap := knowledgeBase.getValue("Pitstop.Strategy.Lap", kUndefined)

				if (plannedLap && (plannedLap != kUndefined))
					plannedPitstopLap := plannedLap
			}

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
		local slots := false
		local carNr, carID, carClass, carPosition

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
			carClass := getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Class", "Unknown")
			carPosition := getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Position")

			if slots {
				slots["#" . carNr] := A_Index
				slots["!" . carID] := A_Index
			}

			grid.Push(carPosition)
			classes.Push(carClass)

			raceInfo["#" . carNr] := A_Index
			raceInfo["!" . carID] := A_Index
		}

		raceInfo["Grid"] := grid
		raceInfo["Classes"] := classes

		if slots
			raceInfo["Slots"] := slots

		this.updateSessionValues({RaceInfo: raceInfo})
	}

	saveStandingsData(lapNumber, simulator, car, track) {
		local knowledgeBase := this.KnowledgeBase
		local driver, carCount, data, raceInfo, slots, grid, carNr, carID, key, fileName, slotsString
		local data, pitstop, pitstops, prefix, times, positions, drivers, laps, carPrefix, carIndex
		local driverForname, driverSurname, driverNickname, carCar

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
							setMultiMapValue(data, "Cars", "Car." . carIndex . ".Class"
												 , knowledgeBase.getValue("Car." . A_Index . ".Class", kUnknown))
							setMultiMapValue(data, "Cars", "Car." . carIndex . ".Car", carCar)

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

				if carIndex {
					times[carIndex] := knowledgeBase.getValue(carPrefix . ".Time", "-")
					positions[carIndex] := knowledgeBase.getValue(carPrefix . ".Position", "-")
					laps[carIndex] := Floor(knowledgeBase.getValue(carPrefix . ".Laps", "-"))

					driverForname := knowledgeBase.getValue(carPrefix . ".Driver.Forname")
					driverSurname := knowledgeBase.getValue(carPrefix . ".Driver.Surname")
					driverNickname := knowledgeBase.getValue(carPrefix . ".Driver.Nickname")

					drivers[carIndex] := computeDriverName(driverForname, driverSurname, driverNickname)
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
	context.KnowledgeBase.RaceAssistant.weatherChangeNotification(change, minutes)

	return true
}

weatherTyreChangeRecommendation(context, minutes, recommendedCompound) {
	context.KnowledgeBase.RaceAssistant.weatherTyreChangeRecommendation(minutes, recommendedCompound)

	return true
}

reportUpcomingPitstop(context, lap) {
	context.KnowledgeBase.RaceAssistant.reportUpcomingPitstop(lap)

	return true
}