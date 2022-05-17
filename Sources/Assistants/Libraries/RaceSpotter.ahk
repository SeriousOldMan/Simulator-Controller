;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AI Race Spotter                 ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Global Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\RuleEngine.ahk
#Include ..\Assistants\Libraries\RaceAssistant.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class PositionInfo {
	iCar := false

	iOriginalDelta := false

	iCarLapTime := false
	iDriverLapTime := false

	iCurrentDelta := false

	iReported := false

	Type[] {
		Get {
			Throw "Virtual property PositionInfo.Type must be implemented in a subclass..."
		}
	}

	Car[] {
		Get {
			return this.iCar
		}
	}

	OriginalDelta[] {
		Get {
			return this.iOriginalDelta
		}
	}

	DriverLapTime[] {
		Get {
			return this.iDriverLapTime
		}
	}

	CarLapTime[] {
		Get {
			return this.iCarLapTime
		}
	}

	CurrentDelta[] {
		Get {
			return this.iCurrentDelta
		}
	}

	Delta[] {
		Get {
			return this.CurrentDelta
		}
	}

	DeltaDifference[] {
		Get {
			return (this.OriginalDelta - this.CurrentDelta)
		}
	}

	LapTimeDifference[] {
		Get {
			Throw "Virtual property PositionInfo.LapTimeDifference must be implemented in a subclass..."
		}
	}

	Reported[] {
		Get {
			return this.iReported
		}

		Set {
			return (this.iReported := value)
		}
	}

	__New(car, delta) {
		this.iCar := car

		this.iOriginalDelta := Abs(delta)
	}

	hasGained(threshold := 0.5) {
		return (this.DeltaDifference >= threshold)
	}

	hasDelta(threshold := 2) {
		return (this.Delta <= threshold)
	}

	recalibrate(full := false) {
		; logMessage(kLogCritical, this.Type . " Recalibrate")

		this.iOriginalDelta := this.CurrentDelta

		if full
			this.iReported := false
	}

	checkpoint(delta, driverLapTime, carLapTime) {
		this.iCurrentDelta := Abs(delta)
		this.iDriverLapTime := driverLapTime
		this.iCarLapTime := carLapTime

		; logMessage(kLogCritical, this.Type . " Checkpoint: " . this.Car . " " . this.iOriginalDelta . " " . this.iCurrentDelta . " " . this.DeltaDifference . " " . this.LapTimeDifference)
	}

	checkReset(delta := -2.5) {
		if (this.DeltaDifference < delta) {
			; logMessage(kLogCritical, "Reset: " . this.Type . ": " . this.car . " " . this.CurrentDelta . " " . this.DeltaDifference . " " . this.LapTimeDifference)

			this.recalibrate(true)
		}
	}
}

class FrontPositionInfo extends PositionInfo {
	LapTimeDifference[] {
		Get {
			return (this.CarLapTime - this.DriverLapTime)
		}
	}
}

class BehindPositionInfo extends PositionInfo {
	LapTimeDifference[] {
		Get {
			return (this.DriverLapTime - this.CarLapTime)
		}
	}

	checkReset(delta := -1.5) {
		base.checkReset(delta)
	}
}

class StandingsFrontInfo extends FrontPositionInfo {
	Type[] {
		Get {
			return "StandingsFront"
		}
	}
}

class StandingsBehindInfo extends BehindPositionInfo {
	Type[] {
		Get {
			return "StandingsBehind"
		}
	}
}

class TrackFrontInfo extends FrontPositionInfo {
	iOpponentType := false

	Type[] {
		Get {
			return "TrackFront"
		}
	}

	OpponentType[] {
		Get {
			return this.iOpponentType
		}
	}

	__New(car, delta, opponentType) {
		this.iOpponentType := opponentType

		base.__New(car, delta)
	}
}

class RaceSpotter extends RaceAssistant {
	iSpotterPID := false

	iSessionDataActive := false

	iGridPosition := false

	iLastDistanceInformationLap := false
	iPositionInfos := {}

	iRaceStartSummarized := false
	iFinalLapsAnnounced := false

	class SpotterVoiceAssistant extends RaceAssistant.RaceVoiceAssistant {
		iFastSpeechSynthesizer := false

		class FastSpeaker extends VoiceAssistant.LocalSpeaker {
			iLastSpeech := 0

			speak(text, focus := false, cache := false, wait := true) {
				if ((A_Now - this.iLastSpeech) < 2000) {
					SoundPlay NonExistent.avi

					Sleep 200
				}

				this.iLastSpeech := A_Now

				base.speak(text, focus, cache, false)
			}
		}

		getSpeaker(fast := false) {
			if fast {
				if !this.iFastSpeechSynthesizer {
					this.iFastSpeechSynthesizer := new this.FastSpeaker(this, this.Synthesizer, this.Speaker, this.Language
																	  , this.buildFragments(this.Language), this.buildPhrases(this.Language, true))

					this.iFastSpeechSynthesizer.setVolume(this.SpeakerVolume)
					this.iFastSpeechSynthesizer.setPitch(this.SpeakerPitch)
					this.iFastSpeechSynthesizer.setRate(this.SpeakerSpeed)
				}

				return this.iFastSpeechSynthesizer
			}
			else
				return base.getSpeaker()
		}

		buildPhrases(language, fast := false) {
			if fast
				return base.buildPhrases(language, "Spotter Phrases")
			else
				return base.buildPhrases(language)
		}
	}

	class RaceSpotterRemoteHandler extends RaceAssistant.RaceAssistantRemoteHandler {
		__New(remotePID) {
			base.__New("Race Spotter", remotePID)
		}
	}

	SessionDataActive[] {
		Get {
			return this.iSessionDataActive
		}
	}

	SpotterSpeaking[] {
		Get {
			return this.getSpeaker(true).Speaking
		}

		Set {
			return (this.getSpeaker(true).Speaking := value)
		}
	}

	GridPosition[] {
		Get {
			return this.iGridPosition
		}
	}

	PositionInfos[sector := false] {
		Get {
			if sector {
				if !this.iPositionInfos.HasKey(sector)
					this.iPositionInfos[sector] := {}

				return this.iPositionInfos[sector]
			}
			else
				return this.iPositionInfos
		}
	}

	__New(configuration, remoteHandler, name := false, language := "__Undefined__"
		, synthesizer := false, speaker := false, vocalics := false, recognizer := false, listener := false, voiceServer := false) {
		base.__New(configuration, "Race Spotter", remoteHandler, name, language, synthesizer, speaker, vocalics, recognizer, listener, voiceServer)

		OnExit(ObjBindMethod(this, "shutdownSpotter"))
	}

	createVoiceAssistant(name, options) {
		return new this.SpotterVoiceAssistant(this, name, options)
	}

	updateSessionValues(values) {
		base.updateSessionValues(values)

		if (values.HasKey("Session") && (values["Session"] == kSessionFinished)) {
			this.iLastDistanceInformationLap := false
			this.iPositionInfos := {}
			this.iGridPosition := false

			this.iRaceStartSummarized := false
			this.iFinalLapsAnnounced := false
		}
	}

	updateDynamicValues(values) {
		base.updateDynamicValues(values)
	}

	handleVoiceCommand(grammar, words) {
		switch grammar {
			case "Position":
				this.positionRecognized(words)
			case "LapTimes":
				this.lapTimesRecognized(words)
			case "GapToFront":
				this.gapToFrontRecognized(words)
			case "GapToBehind":
				this.gapToBehindRecognized(words)
			case "GapToLeader":
				this.gapToLeaderRecognized(words)
			default:
				base.handleVoiceCommand(grammar, words)
		}
	}

	positionRecognized(words) {
		local knowledgeBase := this.KnowledgeBase

		speaker := this.getSpeaker()
		position := Round(knowledgeBase.getValue("Position", 0))

		if (position == 0)
			speaker.speakPhrase("Later")
		else if inList(words, speaker.Fragments["Laps"])
			this.futurePositionRecognized(words)
		else {
			speaker.startTalk()

			try {
				speaker.speakPhrase("Position", {position: position})

				if (position <= 3)
					speaker.speakPhrase("Great")
			}
			finally {
				speaker.finishTalk()
			}
		}
	}

	gapToFrontRecognized(words) {
		local knowledgeBase := this.KnowledgeBase

		if !this.hasEnoughData()
			return

		if inList(words, this.getSpeaker().Fragments["Car"])
			this.trackGapToFrontRecognized(words)
		else
			this.standingsGapToFrontRecognized(words)
	}

	trackGapToFrontRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		speaker := this.getSpeaker()

		delta := knowledgeBase.getValue("Position.Track.Front.Delta", 0)

		if (delta != 0) {
			speaker.startTalk()

			try {
				speaker.speakPhrase("TrackGapToFront", {delta: Format("{:.1f}", Abs(Round(delta / 1000, 1)))})

				lap := knowledgeBase.getValue("Lap")
				driverLap := floor(knowledgeBase.getValue("Standings.Lap." . lap . ".Car." . knowledgeBase.getValue("Driver.Car") . ".Laps"))
				otherLap := floor(knowledgeBase.getValue("Standings.Lap." . lap . ".Car." . knowledgeBase.getValue("Position.Track.Front.Car") . ".Laps"))

				if (driverLap < otherLap)
				  speaker.speakPhrase("NotTheSameLap")
			}
			finally {
				speaker.finishTalk()
			}
		}
		else
			speaker.speakPhrase("NoTrackGap")
	}

	standingsGapToFrontRecognized(words) {
		local knowledgeBase := this.KnowledgeBase

		if (Round(knowledgeBase.getValue("Position", 0)) = 1)
			this.getSpeaker().speakPhrase("NoGapToFront")
		else {
			delta := Abs(Round(knowledgeBase.getValue("Position.Standings.Front.Delta", 0) / 1000, 1))

			this.getSpeaker().speakPhrase("StandingsGapToFront", {delta: Format("{:.1f}", delta)})
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
		speaker := this.getSpeaker()

		delta := knowledgeBase.getValue("Position.Track.Behind.Delta", 0)

		if (delta != 0) {
			speaker.startTalk()

			try {
				speaker.speakPhrase("TrackGapToBehind", {delta: Format("{:.1f}", Abs(Round(delta / 1000, 1)))})

				lap := knowledgeBase.getValue("Lap")
				driverLap := floor(knowledgeBase.getValue("Standings.Lap." . lap . ".Car." . knowledgeBase.getValue("Driver.Car") . ".Laps"))
				otherLap := floor(knowledgeBase.getValue("Standings.Lap." . lap . ".Car." . knowledgeBase.getValue("Position.Track.Behind.Car") . ".Laps"))

				if (driverLap > (otherLap + 1))
				  speaker.speakPhrase("NotTheSameLap")
			}
			finally {
				speaker.finishTalk()
			}
		}
		else
			speaker.speakPhrase("NoTrackGap")
	}

	standingsGapToBehindRecognized(words) {
		local knowledgeBase := this.KnowledgeBase

		if (Round(knowledgeBase.getValue("Position", 0)) = Round(knowledgeBase.getValue("Car.Count", 0)))
			this.getSpeaker().speakPhrase("NoGapToBehind")
		else {
			delta := Abs(Round(knowledgeBase.getValue("Position.Standings.Behind.Delta", 0) / 1000, 1))

			this.getSpeaker().speakPhrase("StandingsGapToBehind", {delta: Format("{:.1f}", delta)})
		}
	}

	gapToLeaderRecognized(words) {
		local knowledgeBase := this.KnowledgeBase

		if !this.hasEnoughData()
			return

		if (Round(knowledgeBase.getValue("Position", 0)) = 1)
			this.getSpeaker().speakPhrase("NoGapToFront")
		else {
			delta := Abs(Round(knowledgeBase.getValue("Position.Standings.Leader.Delta", 0) / 1000, 1))

			this.getSpeaker().speakPhrase("GapToLeader", {delta: Format("{:.1f}", delta)})
		}
	}

	reportLapTime(phrase, driverLapTime, car) {
		lapTime := this.KnowledgeBase.getValue("Car." . car . ".Time", false)

		if lapTime {
			lapTime := Round(lapTime / 1000, 1)

			speaker := this.getSpeaker()
			fragments := speaker.Fragments

			speaker.speakPhrase(phrase, {time: Format("{:.1f}", lapTime)})

			delta := (driverLapTime - lapTime)

			if (Abs(delta) > 0.5)
				speaker.speakPhrase("LapTimeDelta", {delta: Format("{:.1f}", Abs(delta))
												   , difference: (delta > 0) ? fragments["Faster"] : fragments["Slower"]})
		}
	}

	lapTimesRecognized(words) {
		local knowledgeBase := this.KnowledgeBase

		if !this.hasEnoughData()
			return

		car := knowledgeBase.getValue("Driver.Car")
		lap := knowledgeBase.getValue("Lap")
		position := Round(knowledgeBase.getValue("Position"))
		cars := Round(knowledgeBase.getValue("Car.Count"))

		driverLapTime := Round(knowledgeBase.getValue("Car." . car . ".Time") / 1000, 1)
		speaker := this.getSpeaker()

		if (lap == 0)
			speaker.speakPhrase("Later")
		else {
			speaker.startTalk()

			try {
				speaker.speakPhrase("LapTime", {time: Format("{:.1f}", driverLapTime)})

				if (position > 2)
					this.reportLapTime("LapTimeFront", driverLapTime, knowledgeBase.getValue("Position.Standings.Front.Car", 0))

				if (position < cars)
					this.reportLapTime("LapTimeBehind", driverLapTime, knowledgeBase.getValue("Position.Standings.Behind.Car", 0))

				if (position > 1)
					this.reportLapTime("LapTimeLeader", driverLapTime, knowledgeBase.getValue("Position.Standings.Leader.Car", 0))
			}
			finally {
				speaker.finishTalk()
			}
		}
	}

	updateAnnouncement(announcement, value) {
		if (value && (announcement = "DistanceInformation")) {
			value := getConfigurationValue(this.Configuration, "Race Spotter Announcements", this.Simulator . ".PerformanceUpdates", 2)
			value := getConfigurationValue(this.Configuration, "Race Spotter Announcements", this.Simulator . ".DistanceInformation", value)

			if !value
				value := 2
		}

		base.updateAnnouncement(announcement, value)
	}

	getSpeaker(fast := false) {
		return this.VoiceAssistant.getSpeaker(fast)
	}

	updateOpponentReported(positionType, car, reported) {
		for ignore, positionInfos in this.PositionInfos
			if (positionInfos.HasKey(positionType) && (positionInfos[positionType].Car = car))
				positionInfos[positionType].Reported := reported
	}

	updateOpponentInfo(positionInfos, positionType, opponentType, driverLapTime, car, delta) {
		local knowledgeBase := this.KnowledgeBase

		if (positionInfos.HasKey(positionType) && (positionInfos[positionType].Car != car))
			positionInfos.Delete(positionType)

		carLapTime := Round(knowledgeBase.getValue("Car." . car . ".Time", false) / 1000, 1)

		if carLapTime {
			if !positionInfos.HasKey(positionType) {
				; logMessage(kLogCritical, "Creating " . positionType)

				switch positionType {
					case "StandingsFront":
						positionInfos[positionType] := new StandingsFrontInfo(car, delta)
					case "StandingsBehind":
						positionInfos[positionType] := new StandingsBehindInfo(car, delta)
					case "TrackFront":
						positionInfos[positionType] := new TrackFrontInfo(car, delta, opponentType)
					default:
						Throw "Unknown position type detected in RaceSpotter.updateOpponentInfo..."
				}
			}

			positionInfos[positionType].checkpoint(delta, driverLapTime, carLapTime)
			positionInfos[positionType].checkReset()
		}
	}

	updatePositionInfos(lastLap, sector) {
		local knowledgeBase = this.KnowledgeBase

		positionInfos := this.PositionInfos[sector]

		driver := knowledgeBase.getValue("Driver.Car")
		driverLapTime := Round(knowledgeBase.getValue("Car." . driver . ".Time") / 1000, 1)

		if driverLapTime {
			position := Round(knowledgeBase.getValue("Position", 0))

			frontTrackDelta := Round(Abs(knowledgeBase.getValue("Position.Track.Front.Delta", 0)) / 1000, 1)
			frontTrackCar := knowledgeBase.getValue("Position.Track.Front.Car", false)
			frontStandingsDelta := Round(Abs(knowledgeBase.getValue("Position.Standings.Front.Delta", 0)) / 1000, 1)
			frontStandingsCar := knowledgeBase.getValue("Position.Standings.Front.Car", false)

			if ((frontTrackCar != frontStandingsCar)
			 || (knowledgeBase.getValue("Car." . frontTrackCar . ".Lap") != knowledgeBase.getValue("Car." . driver . ".Lap"))) {
				if (position < knowledgeBase.getValue("Car." . frontTrackCar . ".Position"))
					opponentType := "LapDown"
				else
					opponentType := "LapUp"

				this.updateOpponentInfo(positionInfos, "TrackFront", opponentType, driverLapTime, frontTrackCar, frontTrackDelta)
			}
			else {
				positionInfos.Delete("TrackFront")

				; logMessage(kLogCritical, "Cleared TrackFront")
			}

			if (!frontStandingsCar || (frontStandingsDelta = 0) || (position = 1)) {
				; logMessage(kLogCritical, "Clearing StandingsFront")

				positionInfos.Delete("StandingsFront")
			}
			else
				this.updateOpponentInfo(positionInfos, "StandingsFront", "Position", driverLapTime, frontStandingsCar, frontStandingsDelta)

			behindStandingsDelta := Round(knowledgeBase.getValue("Position.Standings.Behind.Delta", 0) / 1000, 1)
			behindStandingsCar := knowledgeBase.getValue("Position.Standings.Behind.Car", false)

			if (!behindStandingsCar || (behindStandingsDelta = 0) || (position = Round(knowledgeBase.getValue("Car.Count", 0)))) {
				; logMessage(kLogCritical, "Clearing StandingsBehind")

				positionInfos.Delete("StandingsBehind")
			}
			else
				this.updateOpponentInfo(positionInfos, "StandingsBehind", "Position", driverLapTime, behindStandingsCar, behindStandingsDelta)
		}
	}

	summarizeRaceStart(lastLap) {
		local knowledgeBase = this.KnowledgeBase

		if (this.Session == kSessionRace) {
			speaker := this.getSpeaker(true)
			driver := knowledgeBase.getValue("Driver.Car", false)

			if (driver && this.GridPosition) {
				currentPosition := knowledgeBase.getValue("Car." . driver . ".Position")

				speaker.startTalk()

				try {
					if (currentPosition = this.GridPosition)
						speaker.speakPhrase("GoodStart")
					else if (currentPosition < this.GridPosition) {
						speaker.speakPhrase("GreatStart")

						if (currentPosition = 1)
							speaker.speakPhrase("Leader")
						else
							speaker.speakPhrase("PositionsGained", {positions: Abs(currentPosition - this.GridPosition)})
					}
					else if (currentPosition > this.GridPosition) {
						speaker.speakPhrase("BadStart")

						speaker.speakPhrase("PositionsLost", {positions: Abs(currentPosition - this.GridPosition)})

						speaker.speakPhrase("Fight")
					}
				}
				finally {
					speaker.finishTalk()
				}

				return true
			}
			else
				return false
		}
		else
			return false
	}

	summarizeOpponents(lastLap, sector, regular) {
		local knowledgeBase := this.KnowledgeBase

		speaker := this.getSpeaker(true)
		positionInfos := this.PositionInfos[sector]

		informed := false

		speaker.startTalk()

		try {
			if (positionInfos.HasKey("TrackFront") && positionInfos["TrackFront"].hasGained(0.5)
												   && (positionInfos["TrackFront"].hasDelta(2))) {
				if !positionInfos["TrackFront"].Reported {
					if (positionInfos["TrackFront"].OpponentType = "LapDown")
						speaker.speakPhrase("LapDownDriver")
					else if (positionInfos["TrackFront"].OpponentType = "LapUp")
						speaker.speakPhrase("LapUpDriver")

					this.updateOpponentReported("TrackFront", positionInfos["TrackFront"].Car, true)
				}
			}
			else if (positionInfos.HasKey("StandingsFront") && positionInfos["StandingsFront"].hasGained(0.3)) {
				delta := positionInfos["StandingsFront"].Delta
				deltaDifference := positionInfos["StandingsFront"].DeltaDifference
				lapTimeDifference := positionInfos["StandingsFront"].LapTimeDifference

				if (delta <= 0.8) {
					if !positionInfos["StandingsFront"].Reported {
						speaker.speakPhrase("GotHim", {delta: Round(delta, 1)
													 , gained: Round(Abs(deltaDifference), 1)
													 , lapTime: Round(lapTimeDifference, 1)})

						car := positionInfos["StandingsFront"].Car

						if !positionInfos["StandingsFront"].HasKey("RatedDriver") {
							if knowledgeBase.getValue("Car." . car . ".Incidents", false)
								speaker.speakPhrase("UnsafeDriver")
							else if ((knowledgeBase.getValue("Lap", 0) - knowledgeBase.getValue("Car." . car . ".ValidLaps", 0)) > 3)
								speaker.speakPhrase("InconsistentDriver")

							positionInfos["StandingsFront"].RatedDriver := true
						}

						this.updateOpponentReported("StandingsFront", car, true)

						informed := true

						positionInfos["StandingsFront"].recalibrate()
					}
				}
				else if (regular && positionInfos["StandingsFront"].hasGained(0.5)) {
					if (knowledgeBase.getValue("Session.Lap.Remaining") > (delta / lapTimeDifference)) {
						speaker.speakPhrase("GainedFront", {delta: (delta > 5) ? Round(delta) : Round(delta, 1)
														  , gained: Round(Abs(deltaDifference), 1)
														  , lapTime: Round(lapTimeDifference, 1)})

						speaker.speakPhrase("CanDoIt")
					}
					else {
						speaker.speakPhrase("GainedFront", {delta: (delta > 5) ? Round(delta) : Round(delta, 1)
														  , gained: Round(Abs(deltaDifference), 1)
														  , lapTime: Round(lapTimeDifference, 1)})

						speaker.speakPhrase("CantDoIt")
					}

					informed := true

					positionInfos["StandingsFront"].recalibrate()
				}
			}

			if (positionInfos.HasKey("StandingsBehind") && positionInfos["StandingsBehind"].hasGained(0.3)) {
				delta := positionInfos["StandingsBehind"].Delta
				deltaDifference := positionInfos["StandingsBehind"].DeltaDifference
				lapTimeDifference := positionInfos["StandingsBehind"].LapTimeDifference

				if (delta <= 0.8) {
					if !positionInfos["StandingsBehind"].Reported {
						speaker.speakPhrase("ClosingIn", {delta: Round(delta, 1)
														, lost: Round(Abs(deltaDifference), 1)
														, lapTime: Round(lapTimeDifference, 1)})

						this.updateOpponentReported("StandingsBehind", positionInfos["StandingsBehind"].Car, true)
					}

					positionInfos["StandingsBehind"].recalibrate()
				}
				else if (regular && positionInfos["StandingsBehind"].hasGained(0.5)) {
					speaker.speakPhrase("LostBehind", {delta: (delta > 5) ? Round(delta) : Round(delta, 1)
													 , lost: Round(Abs(deltaDifference), 1)
													 , lapTime: Round(lapTimeDifference, 1)})

					if !informed
						speaker.speakPhrase("Focus")

					positionInfos["StandingsBehind"].recalibrate()
				}
			}
		}
		finally {
			speaker.finishTalk()
		}
	}

	announceFinalLaps(lastLap) {
		local knowledgeBase = this.KnowledgeBase

		speaker := this.getSpeaker(true)
		position := Round(knowledgeBase.getValue("Position", 0))

		speaker.startTalk()

		try {
			speaker.speakPhrase("LastLaps")

			if (position <= 3) {
				if (position == 1)
					speaker.speakPhrase("Leader")
				else
					speaker.speakPhrase("Position", {position: position})

				speaker.speakPhrase("BringItHome")
			}
			else
				speaker.speakPhrase("Focus")
			}
		finally {
			speaker.finishTalk()
		}
	}

	updateDriver(lastLap, sector) {
		local knowledgeBase = this.KnowledgeBase

		if (this.Speaker && (this.Session = kSessionRace)) {
			this.updatePositionInfos(lastLap, sector)

			if !this.SpotterSpeaking {
				this.SpotterSpeaking := true

				try {
					if ((lastLap > 5) && this.Warnings["FinalLaps"] && !this.iFinalLapsAnnounced && (knowledgeBase.getValue("Session.Lap.Remaining") <= 3)) {
						this.iFinalLapsAnnounced := true

						this.announceFinalLaps(lastLap)
					}
					else if (this.Warnings["StartSummary"] && !this.iRaceStartSummarized && (lastLap == 2)) {
						if this.summarizeRaceStart(lastLap)
							this.iRaceStartSummarized := true
					}
					else if (lastLap > 2) {
						distanceInformation := this.Warnings["DistanceInformation"]

						if distanceInformation {
							regular := (lastLap >= (this.iLastDistanceInformationLap + distanceInformation))

							if regular
								this.iLastDistanceInformationLap := lastLap

							this.summarizeOpponents(lastLap, sector, regular)
						}
					}
				}
				finally {
					this.SpotterSpeaking := false
				}
			}
		}
	}

	proximityAlert(message, variables := false) {
		if (InStr(message, "Behind") == 1)
			type := "Behind"
		else
			type := message

		if (((type != "Behind") && this.Warnings["SideProximity"]) || ((type = "Behind") && this.Warnings["RearProximity"])) {
			if (variables && !IsObject(variables)) {
				values := {}

				for ignore, value in string2Values(",", variables) {
					value := string2Values(":", value)

					values[value[1]] := value[2]
				}

				variables := values
			}

			if (this.Speaker && !this.SpotterSpeaking) {
				this.SpotterSpeaking := true

				try {
					if variables
						this.getSpeaker(true).speakPhrase(message, variables)
					else
						this.getSpeaker(true).speakPhrase(message, false, false, message)
				}
				finally {
					this.SpotterSpeaking := false
				}
			}
		}
	}

	yellowFlag(message, arguments*) {
		if (this.Warnings["YellowFlags"] && this.Speaker && !this.SpotterSpeaking) {
			this.SpotterSpeaking := true

			try {
				switch message {
					case "Full":
						this.getSpeaker(true).speakPhrase("YellowFull", false, false, "YellowFull")
					case "Sector":
						if (arguments.Length() > 1)
							this.getSpeaker(true).speakPhrase("YellowDistance", {sector: arguments[1], distance: arguments[2]})
						else
							this.getSpeaker(true).speakPhrase("YellowSector", {sector: arguments[1]})
					case "Clear":
						this.getSpeaker(true).speakPhrase("YellowClear", false, false, "YellowClear")
					case "Ahead":
						this.getSpeaker(true).speakPhrase("YellowAhead", false, false, "YellowAhead")
				}
			}
			finally {
				this.SpotterSpeaking := false
			}
		}
	}

	blueFlag() {
		local knowledgeBase := this.KnowledgeBase

		if (this.Warnings["BlueFlags"] && this.Speaker && !this.SpotterSpeaking) {
			this.SpotterSpeaking := true

			try {
				position := knowledgeBase.getValue("Position", false)
				delta := knowledgeBase.getValue("Position.Standings.Behind.Delta", false)

				if (knowledgeBase.getValue("Position.Standings.Behind.Car", false) && delta && (delta < 2000))
					this.getSpeaker(true).speakPhrase("BlueForPosition", false, false, "BlueForPosition")
				else
					this.getSpeaker(true).speakPhrase("Blue", false, false, "Blue")
			}
			finally {
				this.SpotterSpeaking := false
			}
		}
	}

	pitWindow(state) {
		if (this.Warnings["PitWindow"] && this.Speaker && !this.SpotterSpeaking && (this.Session = kSessionRace)) {
			this.SpotterSpeaking := true

			try {
				if (state = "Open")
					this.getSpeaker(true).speakPhrase("PitWindowOpen", false, false, "PitWindowOpen")
				else if (state = "Closed")
					this.getSpeaker(true).speakPhrase("PitWindowClosed", false, false, "PitWindowClosed")
			}
			finally {
				this.SpotterSpeaking := false
			}
		}
	}

	startupSpotter() {
		if !this.iSpotterPID {
			code := this.SettingsDatabase.getSimulatorCode(this.Simulator)

			exePath := (kBinariesDirectory . code . " SHM Spotter.exe")

			if FileExist(exePath) {
				this.shutdownSpotter()

				Run %exePath%, %kBinariesDirectory%, Hide UseErrorLevel, spotterPID

				if ((ErrorLevel != "Error") && spotterPID)
					this.iSpotterPID := spotterPID
			}
		}
	}

	shutdownSpotter() {
		if this.iSpotterPID {
			spotterPID := this.iSpotterPID

			Process Close, %spotterPID%
		}

		processName := (this.SettingsDatabase.getSimulatorCode(this.Simulator) . " SHM Spotter.exe")

		tries := 5

		while (tries-- > 0) {
			Process Exist, %processName%

			if ErrorLevel {
				Process Close, %ErrorLevel%

				Sleep 500
			}
			else
				break
		}

		this.iSpotterPID := false

		return false
	}

	createSession(settings, data) {
		local facts := base.createSession(settings, data)

		simulatorName := this.SettingsDatabase.getSimulatorName(facts["Session.Simulator"])
		configuration := this.Configuration
		settings := this.Settings

		facts["Session.Settings.Lap.Learning.Laps"] := getConfigurationValue(configuration, "Race Spotter Analysis", simulatorName . ".LearningLaps", 1)
		facts["Session.Settings.Lap.History.Considered"] := getConfigurationValue(configuration, "Race Spotter Analysis", simulatorName . ".ConsideredHistoryLaps", 5)
		facts["Session.Settings.Lap.History.Damping"] := getConfigurationValue(configuration, "Race Spotter Analysis", simulatorName . ".HistoryLapsDamping", 0.2)

		return facts
	}

	updateSession(settings) {
		local knowledgeBase := this.KnowledgeBase
		local facts

		if knowledgeBase {
			if !IsObject(settings)
				settings := readConfiguration(settings)

			facts := {}

			for key, value in facts
				knowledgeBase.setFact(key, value)

			base.updateSession(settings)
		}
	}

	initializeWarnings(data) {
		simulator := getConfigurationValue(data, "Session Data", "Simulator", "Unknown")
		simulatorName := this.SettingsDatabase.getSimulatorName(simulator)

		if (!this.Warnings || (this.Warnings.Count() = 0)) {
			configuration := this.Configuration

			warnings := {}

			for ignore, key in ["SideProximity", "RearProximity", "YellowFlags", "BlueFlags"
							  , "StartSummary", "FinalLaps", "PitWindow"]
				warnings[key] := getConfigurationValue(configuration, "Race Spotter Announcements", simulatorName . "." . key, true)

			default := getConfigurationValue(configuration, "Race Spotter Announcements", this.Simulator . ".PerformanceUpdates", 2)

			warnings["DistanceInformation"] := getConfigurationValue(configuration, "Race Spotter Announcements", simulatorName . ".DistanceInformation", default)

			this.updateConfigurationValues({Warnings: warnings})
		}
	}

	initializeGridPosition(data) {
		driver := getConfigurationValue(data, "Position Data", "Driver.Car", false)

		if driver
			this.iGridPosition := getConfigurationValue(data, "Position Data", "Car." . driver . ".Position")
	}

	prepareSession(settings, data) {
		base.prepareSession(settings, data)

		this.initializeWarnings(data)
		this.initializeGridPosition(data)

		if this.Speaker
			this.getSpeaker().speakPhrase("Greeting")

		callback := ObjBindMethod(this, "startupSpotter")

		SetTimer %callback%, -10000
	}

	startSession(settings, data) {
		local facts

		joined := (!this.Warnings || (this.Warnings.Count() = 0))

		if !IsObject(settings)
			settings := readConfiguration(settings)

		if !IsObject(data)
			data := readConfiguration(data)

		if joined {
			this.initializeWarnings(data)

			if this.Speaker
				this.getSpeaker().speakPhrase("Greeting")
		}

		facts := this.createSession(settings, data)

		simulatorName := this.Simulator
		configuration := this.Configuration

		Process Exist, Race Engineer.exe

		if (ErrorLevel > 0)
			saveSettings := kNever
		else {
			Process Exist, Race Strategist.exe

			if (ErrorLevel > 0)
				saveSettings := kNever
			else
				saveSettings := getConfigurationValue(configuration, "Race Assistant Shutdown", simulatorName . ".SaveSettings")
		}

		this.updateConfigurationValues({LearningLaps: getConfigurationValue(configuration, "Race Spotter Analysis", simulatorName . ".LearningLaps", 1)
									  , SaveSettings: saveSettings})

		this.updateDynamicValues({KnowledgeBase: this.createKnowledgeBase(facts)
							    , BestLapTime: 0, OverallTime: 0, LastFuelAmount: 0, InitialFuelAmount: 0
								, EnoughData: false})

		this.iFinalLapsAnnounced := false
		this.iPositionInfos := {}
		this.iLastDistanceInformationLap := false
		this.iRaceStartSummarized := false

		if !this.GridPosition
			this.initializeGridPosition(data)

		if joined {
			callback := ObjBindMethod(this, "startupSpotter")

			SetTimer %callback%, -10000
		}
		else
			this.startupSpotter()

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledge(this.KnowledgeBase)
	}

	finishSession(shutdown := true) {
		local knowledgeBase := this.KnowledgeBase

		if knowledgeBase {
			if (shutdown && (knowledgeBase.getValue("Lap", 0) > this.LearningLaps)) {
				this.shutdownSession("Before")

				if this.Listener {
					asked := true

					if ((this.SaveSettings == kAsk) && (this.Session == kSessionRace))
						this.getSpeaker().speakPhrase("ConfirmSaveSettings", false, true)
					else
						asked := false
				}
				else
					asked := false

				if asked {
					this.setContinuation(ObjBindMethod(this, "shutdownSession", "After"))

					callback := ObjBindMethod(this, "forceFinishSession")

					SetTimer %callback%, -120000

					return
				}
			}

			this.shutdownSpotter()

			this.updateDynamicValues({KnowledgeBase: false})
		}

		this.updateDynamicValues({OverallTime: 0, BestLapTime: 0, LastFuelAmount: 0, InitialFuelAmount: 0, EnoughData: false})
		this.updateSessionValues({Simulator: "", Session: kSessionFinished, SessionTime: false})
	}

	forceFinishSession() {
		if !this.SessionDataActive {
			this.updateDynamicValues({KnowledgeBase: false})

			this.finishSession()
		}
		else {
			callback := ObjBindMethod(this, "forceFinishSession")

			SetTimer %callback%, -5000
		}
	}

	prepareData(lapNumber, data) {
		local knowledgeBase

		data := base.prepareData(lapNumber, data)

		knowledgeBase := this.KnowledgeBase

		for key, value in getConfigurationSectionValues(data, "Position Data", Object())
			knowledgeBase.setFact(key, value)

		return data
	}

	addLap(lapNumber, data) {
		local knowledgeBase

		result := base.addLap(lapNumber, data)

		knowledgeBase := this.KnowledgeBase

		Loop % knowledgeBase.getValue("Car.Count")
		{
			validLaps := knowledgeBase.getValue("Car." . A_Index . ".ValidLaps", 0)

			if knowledgeBase.getValue("Car." . A_Index . ".Lap.Valid", true)
				knowledgeBase.setFact("Car." . A_Index . ".ValidLaps", validLaps +  1)
		}

		lastPitstop := knowledgeBase.getValue("Pitstop.Last", false)

		if (lastPitstop && (Abs(lapNumber - lastPitstop) <= 2)) {
			this.iPositionInfos := {}
			this.iLastDistanceInformationLap := false
		}

		if !this.GridPosition
			this.initializeGridPosition(data)

		return result
	}

	updateLap(lapNumber, data) {
		static lastSector := 1

		update := false

		if !IsObject(data)
			data := readConfiguration(data)

		sector := getConfigurationValue(data, "Stint Data", "Sector", 0)

		if (sector != lastSector) {
			lastSector := sector

			update := true

			this.KnowledgeBase.addFact("Sector", sector)
		}

		result := base.updateLap(lapNumber, data)

		if update
			this.updateDriver(lapNumber, sector)

		return result
	}

	performPitstop(lapNumber := false) {
		local knowledgeBase := this.KnowledgeBase

		this.iPositionInfos := {}
		this.iLastDistanceInformationLap := false

		this.startPitstop(lapNumber)

		base.performPitstop(lapNumber)

		knowledgeBase.addFact("Pitstop.Lap", lapNumber ? lapNumber : knowledgeBase.getValue("Lap"))

		result := knowledgeBase.produce()

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledge(knowledgeBase)

		this.finishPitstop(lapNumber)

		return result
	}

	requestInformation(category, arguments*) {
		switch category {
			case "Time":
				this.timeRecognized([])
			case "Position":
				this.positionRecognized([])
			case "LapTimes":
				this.lapTimesRecognized([])
			case "GapToFrontStandings":
				this.gapToFrontRecognized([])
			case "GapToFrontTrack":
				this.gapToFrontRecognized(Array(this.getSpeaker().Fragments["Car"]))
			case "GapToFront":
				this.gapToFrontRecognized(inList(arguments, "Track") ? Array(this.getSpeaker().Fragments["Car"]) : [])
			case "GapToBehindStandings":
				this.gapToBehindRecognized([])
			case "GapToBehindTrack":
				this.gapToBehindRecognized(Array(this.getSpeaker().Fragments["Car"]))
			case "GapToBehind":
				this.gapToBehindRecognized(inList(arguments, "Track") ? Array(this.getSpeaker().Fragments["Car"]) : [])
			case "GapToLeader":
				this.gapToLeaderRecognized([])
		}
	}

	shutdownSession(phase) {
		this.iSessionDataActive := true

		try {
			if ((this.Session == kSessionRace) && (this.SaveSettings = ((phase = "Before") ? kAlways : kAsk)))
				this.saveSessionSettings()
		}
		finally {
			this.iSessionDataActive := false
		}

		if (phase = "After") {
			this.updateDynamicValues({KnowledgeBase: false})

			this.finishSession()
		}
	}
}