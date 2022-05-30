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

#Include ..\Libraries\Math.ahk
#Include ..\Libraries\RuleEngine.ahk
#Include ..\Assistants\Libraries\RaceAssistant.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Public Constant Section                          ;;;
;;;-------------------------------------------------------------------------;;;

global kDebugPositions = 2


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class CarInfo {
	iNr := false
	iCar := false
	iDriver := false

	iLastLap := false
	iLastSector := false

	iPosition := false

	iPitstops := []
	iLastPitstop := false

	iLapTimes := []

	iDeltas := {}
	iLastDeltas := {}

	iInvalidLaps := []
	iIncidents := false

	Nr[] {
		Get {
			return this.iNr
		}
	}

	Car[] {
		Get {
			return this.iCar
		}
	}

	Driver[] {
		Get {
			return this.iDriver
		}
	}

	LastLap[] {
		Get {
			return this.iLastLap
		}
	}

	Position[] {
		Get {
			return this.iPosition
		}
	}

	Pitstops[] {
		Get {
			return (key ? this.iPitstops[key] : this.iPitstops)
		}
	}

	LastPitstop[] {
		Get {
			return this.iLastPitstop
		}
	}

	LapTimes[key := false] {
		Get {
			return (key ? this.iLapTimes[key] : this.iLapTimes)
		}

		Set {
			return (key ? (this.iLapTimes[key] := value) : (this.iLapTimes := value))
		}
	}

	LastLapTime[] {
		Get {
			if (this.LastLap > 0)
				return this.LapTimes[this.LapTimes.Length()]
			else
				return false
		}
	}

	AverageLapTime[count := 3] {
		Get {
			lapTimes := []
			numLapTimes := this.LapTimes.Length()

			Loop % Min(count, numLapTimes)
				lapTimes.Push(this.LapTimes[numLapTimes - A_Index + 1])

			return Round(average(lapTimes), 1)
		}
	}

	LapTime[average := false] {
		Get {
			return (average ? this.AverageLapTime : this.LastLapTime)
		}
	}

	Deltas[sector := false, key := false] {
		Get {
			if sector {
				if this.iDeltas.HasKey(sector)
					return (key ? this.iDeltas[sector][key] : this.iDeltas[sector])
				else
					return []
			}
			else
				return this.iDeltas
		}
	}

	LastDelta[sector] {
		Get {
			return (this.iLastDeltas.HasKey(sector) ? this.iLastDeltas[sector] : false)
		}
	}

	AverageDelta[sector, count := 3] {
		Get {
			deltas := []
			numDeltas := this.Deltas[sector].Length()

			Loop % Min(count, numDeltas)
				deltas.Push(this.Deltas[sector][numDeltas - A_Index + 1])

			return Round(average(deltas), 1)
		}
	}

	Delta[sector, average := false] {
		Get {
			return (average ? this.AverageDelta[sector] : this.LastDelta[sector])
		}
	}

	InvalidLaps[] {
		Get {
			return this.iInvalidLaps
		}
	}

	Incidents[] {
		Get {
			return this.iIncidents
		}
	}

	__New(nr, car) {
		this.iNr := nr
		this.iCar := car
	}

	update(driver, position, lastLap, sector, lapTime, valid, incidents, delta, pitstop := false) {
		this.iDriver := driver
		this.iPosition := position

		if ((lastLap > this.LastLap) && (lapTime > 0)) {
			this.LapTimes.Push(lapTime)

			if (this.LapTimes.Length() > 20)
				this.LapTimes.RemoveAt(1)

			this.iLastLap := lastLap

			if (!valid && !inList(this.InvalidLaps, lastLap))
				this.InvalidLaps.Push(lastLap)
		}

		this.iIncidents := incidents

		if (sector != this.iLastSector) {
			this.iLastSector := sector

			if this.iDeltas.HasKey(sector)
				deltas := this.iDeltas[sector]
			else {
				deltas := []

				this.iDeltas[sector] := deltas
			}

			deltas.Push(delta)

			if (deltas.Length() > 20)
				deltas.RemoveAt(1)

			this.iLastDeltas[sector] := delta
		}

		if (pitstop && !inList(this.Pitstops, lastLap)) {
			this.Pitstops.Push(lastLap)
			this.iLastPitstop := lastLap
		}
	}

	isFaster(sector) {
		xValues := []
		yValues := []

		for index, delta in this.Deltas[sector] {
			xValues.Push(index)
			yValues.Push(delta)
		}

		a := false
		b := false

		linRegression(xValues, yValues, a, b)

		return (b < 0)
	}
}

class PositionInfo {
	iSpotter := false
	iCar := false

	iObserved := false
	iStartingDeltas := {}

	iReported := false

	Type[] {
		Get {
			Throw "Virtual property PositionInfo.Type must be implemented in a subclass..."
		}
	}

	Spotter[] {
		Get {
			return this.iSpotter
		}
	}

	Car[] {
		Get {
			return this.iCar
		}
	}

	OpponentType[] {
		Get {
			local knowledgeBase := this.Spotter.KnowledgeBase

			lastLap := knowledgeBase.getValue("Lap")
			position := knowledgeBase.getValue("Position")

			if (Abs(position - this.Car.Position) == 1)
				return "Position"
			else if (lastLap > this.Car.LastLap)
				return "LapDown"
			else
				return "LapUp"
		}
	}

	Observed[] {
		Get {
			return this.iObserved
		}
	}

	StartingDelta[sector] {
		Get {
			return (this.iStartingDeltas.HasKey(sector) ? this.iStartingDeltas[sector] : false)
		}
	}

	LastDelta[sector] {
		Get {
			return this.Car.LastDelta[sector]
		}
	}

	Delta[sector, average := false] {
		Get {
			return this.Car.Delta[sector, average]
		}
	}

	DeltaDifference[sector] {
		Get {
			return (this.StartingDelta[sector] - this.Delta[sector])
		}
	}

	LapTimeDifference[average := false] {
		Get {
			local knowledgeBase := this.Spotter.KnowledgeBase

			return (Round(knowledgeBase.getValue("Lap." . knowledgeBase.getValue("Lap") . ".Time") / 1000, 1) - this.Car.LapTime[average])
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

	__New(spotter, car) {
		this.iSpotter := spotter
		this.iCar := car

		for sector, ignore in car.Deltas
			this.iStartingDeltas[sector] := car.Delta[sector]
	}

	inDelta(sector, threshold := 2) {
		return (Abs(this.Delta[sector, true]) <= threshold)
	}

	isFaster(sector) {
		return ((this.StartingDelta[sector] - this.Delta[Sector]) > 0)
	}

	closingIn(sector, threshold := 0.5) {
		difference := this.DeltaDifference[sector]

		if this.inFront()
			return ((difference < 0) && (Abs(difference) > threshold))
		else
			return ((difference > 0) && (difference > threshold))
	}

	runningAway(sector, threshold := 2) {
		difference := this.DeltaDifference[sector]

		if this.inFront()
			return ((difference > 0) && (difference > threshold))
		else
			return ((difference < 0) && (Abs(difference) > threshold))
	}

	inFront(standings := true) {
		local knowledgeBase := this.Spotter.KnowledgeBase

		if standings
			return (this.Car.Position < knowledgeBase.getValue("Position"))
		else {
			frontCar := knowledgeBase.getValue("Position.Track.Front.Car", false)

			if frontCar
				return (this.Car.Nr = knowledgeBase.getValue("Standings.Lap." . knowledgeBase.getValue("Lap") . ".Car." . frontCar . ".Nr"))
			else
				return false
		}
	}

	atBehind(standings := true) {
		local knowledgeBase := this.Spotter.KnowledgeBase

		if standings
			return (this.Car.Position > knowledgeBase.getValue("Position"))
		else {
			behindCar := knowledgeBase.getValue("Position.Track.Behind.Car", false)

			if behindCar
				return (this.Car.Nr = knowledgeBase.getValue("Standings.Lap." . knowledgeBase.getValue("Lap") . ".Car." . behindCar . ".Nr"))
			else
				return false
		}
	}

	forPosition() {
		local knowledgeBase := this.Spotter.KnowledgeBase

		position := knowledgeBase.getValue("Position")

		if ((position - this.Car.Position) == 1)
			return "Front"
		else if ((position - this.Car.Position) == -1)
			return "Behind"
		else
			return false
	}

	reset(full := false) {
		if full
			this.Reported := false

		sectors := []

		for sector, ignore in this.Car.Deltas
			if !inList(sectors, sector)
				sectors.Push(sector)

		this.iStartingDeltas := {}

		for ignore, sector in sectors
			this.iStartingDeltas[sector] := this.Car.Delta[sector]
	}

	checkpoint(sector) {
		trackFront := this.inFront(false)
		trackBehind := this.atBehind(false)
		position := this.forPosition()

		if (trackFront || trackBehind || position) {
			type := ((trackFront != false) . (trackBehind != false) . (position = "Front") . (position = "Behind"))
			observed := this.Observed

			if (!observed || (observed != type))
				this.reset(true)

			this.iObserved := type
		}
		else {
			this.iObserved := false

			this.reset(true)
		}
	}
}

class RaceSpotter extends RaceAssistant {
	iSpotterPID := false

	iSessionDataActive := false

	iGridPosition := false

	iLastDistanceInformationLap := false
	iPositionInfos := {}

	iDriverCar := false
	iOtherCars := {}

	iRaceStartSummarized := false
	iFinalLapsAnnounced := false

	iPendingAlerts := []

	class SpotterVoiceManager extends RaceAssistant.RaceVoiceManager {
		iFastSpeechSynthesizer := false

		class FastSpeaker extends VoiceManager.LocalSpeaker {
			speak(arguments*) {
				if (this.VoiceManager.RaceAssistant.Session >= kSessionPractice)
					base.speak(arguments*)
			}

			speakPhrase(phrase, arguments*) {
				if this.Awaitable {
					this.wait()

					if this.VoiceManager.RaceAssistant.skipAlert(phrase)
						return
				}

				base.speakPhrase(phrase, arguments*)
			}
		}

		getSpeaker(fast := false) {
			if fast {
				if !this.iFastSpeechSynthesizer {
					synthesizer := new this.FastSpeaker(this, this.Synthesizer, this.Speaker, this.Language
													  , this.buildFragments(this.Language), this.buildPhrases(this.Language, true))

					this.iFastSpeechSynthesizer := synthesizer

					synthesizer.setVolume(this.SpeakerVolume)
					synthesizer.setPitch(this.SpeakerPitch)
					synthesizer.setRate(this.SpeakerSpeed)

					synthesizer.SpeechStatusCallback := ObjBindMethod(this, "updateSpeechStatus")
				}

				return this.iFastSpeechSynthesizer
			}
			else
				return base.getSpeaker()
		}

		updateSpeechStatus(status) {
			if (status = "Start")
				this.mute()
			else if (status = "Stop")
				this.unmute()
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

	DriverCar[] {
		Get {
			return this.iDriverCar
		}
	}

	OtherCars[key := false] {
		Get {
			return (key ? this.iOtherCars[key] : this.iOtherCars)
		}

		Set {
			return (key ? (this.iOtherCars[key] := value) : (this.iOtherCars := value))
		}
	}

	GridPosition[] {
		Get {
			return this.iGridPosition
		}
	}

	PositionInfos[key := false] {
		Get {
			return (key ? this.iPositionInfos[key] : this.iPositionInfos)
		}

		Set {
			return (key ? (this.iPositionInfos[key] := value) : (this.iPositionInfos := value))
		}
	}

	__New(configuration, remoteHandler, name := false, language := "__Undefined__"
		, synthesizer := false, speaker := false, vocalics := false, recognizer := false, listener := false, voiceServer := false) {
		base.__New(configuration, "Race Spotter", remoteHandler, name, language, synthesizer, speaker, vocalics, recognizer, listener, voiceServer)

		this.iDebug := (true || isDebug() ? (kDebugKnowledgeBase + kDebugPositions) : kDebugOff)

		OnExit(ObjBindMethod(this, "shutdownSpotter"))
	}

	createVoiceManager(name, options) {
		return new this.SpotterVoiceManager(this, name, options)
	}

	updateSessionValues(values) {
		base.updateSessionValues(values)

		if (values.HasKey("Session") && (values["Session"] == kSessionFinished)) {
			this.iLastDistanceInformationLap := false
			this.iDriverCar := false
			this.OtherCars := {}
			this.PositionInfos := {}
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
				speaker.speakPhrase("TrackGapToFront", {delta: printNumber(Abs(delta / 1000), 1)})

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
			delta := Abs(knowledgeBase.getValue("Position.Standings.Front.Delta", 0) / 1000)

			this.getSpeaker().speakPhrase("StandingsGapToFront", {delta: printNumber(delta, 1)})
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
				speaker.speakPhrase("TrackGapToBehind", {delta: printNumber(Abs(delta / 1000), 1)})

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
			delta := Abs(knowledgeBase.getValue("Position.Standings.Behind.Delta", 0) / 1000)

			this.getSpeaker().speakPhrase("StandingsGapToBehind", {delta: printNumber(delta, 1)})
		}
	}

	gapToLeaderRecognized(words) {
		local knowledgeBase := this.KnowledgeBase

		if !this.hasEnoughData()
			return

		if (Round(knowledgeBase.getValue("Position", 0)) = 1)
			this.getSpeaker().speakPhrase("NoGapToFront")
		else {
			delta := Abs(knowledgeBase.getValue("Position.Standings.Leader.Delta", 0) / 1000)

			this.getSpeaker().speakPhrase("GapToLeader", {delta: printNumber(delta, 1)})
		}
	}

	reportLapTime(phrase, driverLapTime, car) {
		lapTime := this.KnowledgeBase.getValue("Car." . car . ".Time", false)

		if lapTime {
			lapTime /= 1000

			speaker := this.getSpeaker()
			fragments := speaker.Fragments

			speaker.speakPhrase(phrase, {time: printNumber(lapTime, 1)})

			delta := (driverLapTime - lapTime)

			if (Abs(delta) > 0.5)
				speaker.speakPhrase("LapTimeDelta", {delta: printNumber(Abs(delta), 1)
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

		driverLapTime := (knowledgeBase.getValue("Car." . car . ".Time") / 1000)
		speaker := this.getSpeaker()

		if (lap == 0)
			speaker.speakPhrase("Later")
		else {
			speaker.startTalk()

			try {
				speaker.speakPhrase("LapTime", {time: printNumber(driverLapTime, 1)})

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
		return this.VoiceManager.getSpeaker(fast)
	}

	updateCarInfos(lastLap, sector) {
		local knowledgeBase = this.KnowledgeBase

		lastLap := knowledgeBase.getValue("Lap", 0)

		if (lastLap > 0) {
			driver := knowledgeBase.getValue("Driver.Car", 0)

			otherCars := this.OtherCars

			Loop % knowledgeBase.getValue("Car.Count", 0)
			{
				carNr := knowledgeBase.getValue("Car." . A_Index . ".Nr", false)

				if (A_Index != driver) {
					if otherCars.HasKey(carNr)
						info := otherCars[carNr]
					else {
						info := new CarInfo(carNr, knowledgeBase.getValue("Car." . A_Index . ".Car", "Unknown"))

						otherCars[carNr] := info
					}
				}
				else {
					info := this.DriverCar

					if !info {
						info := new CarInfo(carNr, knowledgeBase.getValue("Car." . A_Index . ".Car", "Unknown"), driverName)

						this.iDriverCar := info
					}
				}

				info.update(computeDriverName(knowledgeBase.getValue("Car." . A_Index . ".Driver.Forname", "John")
											, knowledgeBase.getValue("Car." . A_Index . ".Driver.Surname", "Doe")
											, knowledgeBase.getValue("Car." . A_Index . ".Driver.Nickname", "JD"))
						  , knowledgeBase.getValue("Car." . A_Index . ".Position")
						  , knowledgeBase.getValue("Car." . A_Index . ".Lap", 0), sector
						  , Round(knowledgeBase.getValue("Car." . A_Index . ".Time", false) / 1000, 1)
						  , knowledgeBase.getValue("Car." . A_Index . ".Lap.Valid", true)
						  , knowledgeBase.getValue("Car." . A_Index . ".Incidents", 0)
						  , Round(knowledgeBase.getValue("Standings.Lap." . lastLap . ".Car." . A_Index . ".Delta") / 1000, 1))
			}
		}
	}

	updatePositionInfos(lastLap, sector) {
		this.updateCarInfos(lastLap, sector)

		positionInfos := this.PositionInfos

		if this.Debug[kDebugPositions]
			FileAppend ---------------------------------`n`n, %kTempDirectory%Race Spotter.positions

		for nr, car in this.OtherCars {
			if positionInfos.HasKey(nr)
				position := positionInfos[nr]
			else {
				position := new PositionInfo(this, car)

				positionInfos[nr] := position
			}

			if this.Debug[kDebugPositions] {
				info := values2String(", ", position.Car.Nr, position.Car.Car, position.Car.Driver, position.Car.Position
										  , values2String("|", position.Car.LapTimes*), position.Car.LapTime[true]
										  , values2String("|", position.Car.Deltas[sector]*), position.Delta[sector]
										  , position.inFront(), position.atBehind(), position.inFront(false), position.atBehind(false), position.forPosition()
										  , position.DeltaDifference[sector], position.LapTimeDifference[true]
										  , position.isFaster(sector), position.closingIn(sector, 0.2), position.runningAway(sector, 0.3))

				FileAppend %info%`n, %kTempDirectory%Race Spotter.positions
			}

			position.checkpoint(sector)
		}

		if this.Debug[kDebugPositions]
			FileAppend `n---------------------------------`n`n, %kTempDirectory%Race Spotter.positions
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

	getPositionInfos(ByRef standingsFront, ByRef standingsBehind, ByRef trackFront, ByRef trackBehind) {
		local knowledgeBase := this.KnowledgeBase

		standingsFront := false
		standingsBehind := false
		trackFront := false
		trackBehind := false

		for nr, candidate in this.PositionInfos {
			if candidate.inFront(false)
				trackFront := candidate
			else if candidate.atBehind(false)
				trackBehind := candidate

			type := candidate.forPosition()

			if (type = "Front")
				standingsFront := candidate
			else if (type = "Behind")
				standingsBehind := candidate
		}
	}

	summarizeOpponents(lastLap, sector, regular) {
		local knowledgeBase := this.KnowledgeBase

		standingsFront := false
		standingsBehind := false
		trackFront := false
		trackBehind := false

		this.getPositionInfos(standingsFront, standingsBehind, trackFront, trackBehind)

		speaker := this.getSpeaker(true)

		informed := false

		speaker.startTalk()

		try {
			if (trackFront && (trackFront != standingsFront) && trackFront.inDelta(2) && !trackFront.isFaster(sector)) {
				if (!trackFront.Reported && (sector > 1)) {
					if (trackFront.OpponentType = "LapDown")
						speaker.speakPhrase("LapDownDriver")
					else if (trackFront.OpponentType = "LapUp")
						speaker.speakPhrase("LapUpDriver")

					trackFront.Reported := true
				}
			}
			else if standingsFront {
				delta := Abs(standingsFront.Delta[sector])
				deltaDifference := Abs(standingsFront.DeltaDifference[sector])
				lapTimeDifference := Abs(standingsFront.LapTimeDifference)

				if this.Debug[kDebugPositions] {
					info := values2String(", ", standingsFront.Car.Nr, values2String("|", standingsFront.Car.LapTimes*), standingsFront.Car.LapTime[true]
											  , values2String("|", standingsFront.Car.Deltas[sector]*), standingsFront.Delta[sector], standingsFront.Delta[sector, true]
											  , standingsFront.inFront(), standingsFront.atBehind(), standingsFront.inFront(false), standingsFront.atBehind(false), standingsFront.forPosition()
											  , standingsFront.DeltaDifference[sector], standingsFront.LapTimeDifference[true]
											  , standingsFront.isFaster(sector), standingsFront.closingIn(sector, 0.2), standingsFront.runningAway(sector, 0.3))

					FileAppend =================================`n%info%`n=================================`n`n, %kTempDirectory%Race Spotter.positions
				}

				if ((delta <= 0.8) && !standingsFront.isFaster(sector) && !standingsFront.Reported) {
					speaker.speakPhrase("GotHim", {delta: printNumber(delta, 1)
												 , gained: printNumber(deltaDifference, 1)
												 , lapTime: printNumber(lapTimeDifference, 1)})

					car := standingsFront.Car

					if (car.Incidents > 0)
						speaker.speakPhrase("UnsafeDriverFront")
					else if (car.InvalidLaps.Length() > 3)
						speaker.speakPhrase("InconsistentDriverFront")

					standingsFront.Reported := true

					standingsFront.reset()
				}
				else if (regular && standingsFront.closingIn(sector, 0.3) && !standingsFront.Reported) {
					speaker.speakPhrase("GainedFront", {delta: (delta > 5) ? Round(delta) : printNumber(delta, 1)
													  , gained: printNumber(deltaDifference, 1)
													  , lapTime: printNumber(lapTimeDifference, 1)})

					remaining := Min(knowledgeBase.getValue("Session.Time.Remaining"), knowledgeBase.getValue("Driver.Time.Stint.Remaining"))

					if ((remaining > 0) && (lapTimeDifference > 0))
						if (((remaining / 1000) / this.DriverCar.LapTime[true]) > (delta / lapTimeDifference))
							speaker.speakPhrase("CanDoIt")
						else
							speaker.speakPhrase("CantDoIt")

					informed := true

					standingsFront.reset()
				}
				else if (regular && standingsFront.runningAway(sector, 1.0)) {
					speaker.speakPhrase("LostFront", {delta: (delta > 5) ? Round(delta) : printNumber(delta, 1)
													, lost: printNumber(deltaDifference, 1)
													, lapTime: printNumber(lapTimeDifference, 1)})

					standingsFront.reset(true)
				}
			}

			if standingsBehind {
				delta := Abs(standingsBehind.Delta[sector])
				deltaDifference := Abs(standingsBehind.DeltaDifference[sector])
				lapTimeDifference := Abs(standingsBehind.LapTimeDifference)

				if this.Debug[kDebugPositions] {
					info := values2String(", ", standingsBehind.Car.Nr, values2String("|", standingsBehind.Car.LapTimes*), standingsBehind.Car.LapTime[true]
											  , values2String("|", standingsBehind.Car.Deltas[sector]*), standingsBehind.Delta[sector], standingsBehind.Delta[sector, true]
											  , standingsBehind.inFront(), standingsBehind.atBehind(), standingsBehind.inFront(false), standingsBehind.atBehind(false), standingsBehind.forPosition()
											  , standingsBehind.DeltaDifference[sector], standingsBehind.LapTimeDifference[true]
											  , standingsBehind.isFaster(sector), standingsBehind.closingIn(sector, 0.2), standingsBehind.runningAway(sector, 0.3))

					FileAppend =================================`n%info%`n=================================`n`n, %kTempDirectory%Race Spotter.positions
				}

				if ((delta <= 0.8) && standingsBehind.isFaster(sector) && !standingsBehind.Reported) {
					speaker.speakPhrase("ClosingIn", {delta: printNumber(delta, 1)
													, lost: printNumber(deltaDifference, 1)
													, lapTime: printNumber(lapTimeDifference, 1)})

					car := standingsFront.Car

					if (car.Incidents > 0)
						speaker.speakPhrase("UnsafeDriveBehind")
					else if (car.InvalidLaps.Length() > 3)
						speaker.speakPhrase("InconsistentDriverBehind")

					standingsBehind.Reported := true

					standingsBehind.reset()
				}
				else if (regular && standingsBehind.closingIn(sector, 0.3) && !standingsBehind.Reported) {
					speaker.speakPhrase("LostBehind", {delta: (delta > 5) ? Round(delta) : printNumber(delta, 1)
													 , lost: printNumber(deltaDifference, 1)
													 , lapTime: printNumber(lapTimeDifference, 1)})

					if !informed
						speaker.speakPhrase("Focus")

					standingsBehind.reset()
				}
				else if (regular && standingsBehind.runningAway(sector, 1.0)) {
					speaker.speakPhrase("GainedBehind", {delta: (delta > 5) ? Round(delta) : printNumber(delta, 1)
													   , gained: printNumber(deltaDifference, 1)
													   , lapTime: printNumber(lapTimeDifference, 1)})

					standingsBehind.reset(true)
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
			if (lastLap > 1)
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
					else if this.hasEnoughData(false) {
						distanceInformation := this.Warnings["DistanceInformation"]

						if distanceInformation {
							if (distanceInformation = "S")
								regular := true
							else {
								regular := (lastLap >= (this.iLastDistanceInformationLap + distanceInformation))

								if regular
									this.iLastDistanceInformationLap := lastLap
							}

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

	pendingAlert(alert, match := false) {
		if match {
			for ignore, candidate in this.iPendingAlerts
				if InStr(candidate, alert)
					return true

			return false
		}
		else
			return inList(this.iPendingAlerts, alert)
	}

	pendingAlerts(alerts, match := false) {
		for ignore, alert in alerts
			if match {
				for ignore, candidate in this.iPendingAlerts
					if InStr(candidate, alert)
						return true
			}
			else
				if inList(this.iPendingAlerts, alert)
					return true

		return false
	}

	skipAlert(alert) {
		result := false

		if ((alert = "Hold") && this.pendingAlerts(["ClearAll", "ClearLeft", "ClearRight"]))
			result := true
		else if ((alert = "Left") && (this.pendingAlerts(["ClearAll", "ClearLeft"]) || this.pendingAlerts(["Left", "Three"])))
			result := true
		else if ((alert = "Right") && (this.pendingAlerts(["ClearAll", "ClearRight"]) || this.pendingAlerts(["Right", "Three"])))
			result := true
		else if ((alert = "Three") && this.pendingAlert("Clear", true))
			result := true
		else if ((alert = "Side") && this.pendingAlert("Clear", true))
			result := true
		else if (InStr(alert, "Clear") && this.pendingAlerts(["Left", "Right", "Three", "Side", "ClearAll"]))
			result := true
		else if (InStr(alert, "Behind") && (this.pendingAlert("Behind", true) || this.pendingAlerts(["Left", "Right", "Three"]) || this.pendingAlert("Clear", true)))
			result := true
		else if (InStr(alert, "Yellow") && this.pendingAlert("YellowClear"))
			result := true
		else if ((alert = "YellowClear") && this.pendingAlert("Yellow", true))
			result := true

		return result
	}

	proximityAlert(alert) {
		static alerting := false

		if this.Speaker {
			speaker := this.getSpeaker(true)

			if alert {
				this.iPendingAlerts.Push(alert)

				if (alerting || speaker.isSpeaking()) {
					callback := ObjBindMethod(this, "proximityAlert", false)

					SetTimer %callback%, -1000

					return
				}
			}
			else if (alerting || speaker.isSpeaking()) {
				callback := ObjBindMethod(this, "proximityAlert", false)

				SetTimer %callback%, -100

				return
			}

			alerting := true

			try {
				Loop {
					if (this.iPendingAlerts.Length() > 0)
						alert := this.iPendingAlerts.RemoveAt(1)
					else
						break

					if (InStr(alert, "Behind") == 1)
						type := "Behind"
					else
						type := alert

					if (((type != "Behind") && this.Warnings["SideProximity"]) || ((type = "Behind") && this.Warnings["RearProximity"])) {
						if (!this.SpotterSpeaking || (type != "Hold")) {
							this.SpotterSpeaking := true

							try {
								speaker.speakPhrase(alert, false, false, alert)
							}
							finally {
								this.SpotterSpeaking := false
							}
						}
					}
				}
			}
			finally {
				alerting := false
			}
		}
	}

	yellowFlag(alert, arguments*) {
		if (this.Warnings["YellowFlags"] && this.Speaker) { ; && !this.SpotterSpeaking) {
			this.SpotterSpeaking := true

			try {
				switch alert {
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

		if (this.Warnings["BlueFlags"] && this.Speaker) { ; && !this.SpotterSpeaking) {
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
		if (this.Warnings["PitWindow"] && this.Speaker && (this.Session = kSessionRace)) { ; && !this.SpotterSpeaking ) {
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
		this.iDriverCar := false
		this.OtherCars := {}
		this.PositionInfos := {}
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
			this.PositionInfos := {}
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

		this.PositionInfos := {}
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