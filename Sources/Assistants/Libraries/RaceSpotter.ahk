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

#Include ..\Libraries\Task.ahk
#Include ..\Libraries\Math.ahk
#Include ..\Libraries\RuleEngine.ahk
#Include ..\Assistants\Libraries\RaceAssistant.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Public Constant Section                          ;;;
;;;-------------------------------------------------------------------------;;;

global kDebugPositions := 4

global kDeltaMethodStatic := 1
global kDeltaMethodDynamic := 2
global kDeltaMethodBoth := 3


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class CarInfo {
	iNr := false
	iCar := false
	iDriver := false
	iClass := false

	iLastLap := false
	iLastSector := false

	iOverallPosition := false
	iClassPosition := false

	iPitstops := []
	iLastPitstop := false
	iInPit := false

	iLapTimes := []
	iBestLapTime := false

	iDeltas := {}
	iLastDeltas := {}

	iTrackAheadDelta := false
	iTrackBehindDelta := false

	iInvalidLaps := 0
	iIncidents := 0

	iProblem := true

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

	Class[] {
		Get {
			return this.iClass
		}
	}

	BestLapTime[] {
		Get {
			return this.iBestLapTime
		}
	}

	LastLap[] {
		Get {
			return this.iLastLap
		}
	}

	Position[type := "Overall"] {
		Get {
			return ((type = "Overall") ? this.iOverallPosition : this.iClassPosition)
		}
	}

	Pitstops[key := false] {
		Get {
			return (key ? this.iPitstops[key] : this.iPitstops)
		}
	}

	LastPitstop[] {
		Get {
			return this.iLastPitstop
		}
	}

	InPit[] {
		Get {
			return this.iInPit
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
			local numLapTimes := this.LapTimes.Length()

			if (numLapTimes > 0)
				return this.LapTimes[numLapTimes]
			else
				return false
		}
	}

	AverageLapTime[count := 3] {
		Get {
			local lapTimes := []
			local numLapTimes := this.LapTimes.Length()

			loop % Min(count, numLapTimes)
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

	TrackAheadDelta[] {
		Get {
			return this.iTrackAheadDelta
		}
	}

	TrackBehindDelta[] {
		Get {
			return this.iTrackBehindDelta
		}
	}

	AverageDelta[sector, count := 3] {
		Get {
			local deltas := []
			local numDeltas, ignore, sDeltas

			if sector {
				numDeltas := this.Deltas[sector].Length()

				loop % Min(count, numDeltas)
					deltas.Push(this.Deltas[sector][numDeltas - A_Index + 1])
			}
			else
				for ignore, sDeltas in this.Deltas {
					numDeltas := sDeltas.Length()

					loop % Min(count, numDeltas)
						deltas.Push(sDeltas[numDeltas - A_Index + 1])
				}

			return Round(average(deltas), 1)
		}
	}

	Delta[sector, average := false, count := 3] {
		Get {
			if sector
				return (average ? this.AverageDelta[sector] : this.LastDelta[sector])
			else
				return (average ? this.AverageDelta[false, count] : this.LastDelta[sector])
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

	Problem[] {
		Get {
			return this.iProblem
		}
	}

	__New(nr, car, class) {
		this.iNr := nr
		this.iCar := car
		this.iClass := class
	}

	reset() {
		this.iDeltas := {}
		this.iLastDeltas := {}
	}

	update(driver, overallPosition, classPosition, lastLap, sector, lapTime, delta, trackAheadDelta, trackBehindDelta
		 , validLap, invalidLaps, incidents, inPit) {
		local avgLapTime := this.AverageLapTime
		local pitstops := this.Pitstops
		local pitted := (inPit || inList(pitstops, lastLap) || inList(pitstops, lastLap - 1) || inList(pitstops, lastLap - 2))
		local valid := true
		local deltas

		this.iProblem := false

		if ((lapTime && avgLapTime && (Abs((lapTime - avgLapTime) / avgLapTime) > 0.03)) || pitted) {
			this.reset()

			if (!pitted && (lapTime > avgLapTime))
				this.iProblem := true

			valid := false
		}

		if ((lastLap != this.LastLap) && (lapTime > 0) && !pitted) {
			this.LapTimes.Push(lapTime)

			if (this.LapTimes.Length() > 5)
				this.LapTimes.RemoveAt(1)

			if (validLap && (!this.BestLapTime || (lapTime < this.BestLapTime)))
				this.iBestLapTime := lapTime
		}

		this.iDriver := driver
		this.iOverallPosition := overallPosition
		this.iClassPosition := classPosition
		this.iLastLap := lastLap
		this.iInvalidLaps := invalidLaps
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

			if (deltas.Length() > 5)
				deltas.RemoveAt(1)

			this.iLastDeltas[sector] := delta

			this.iTrackAheadDelta := trackAheadDelta
			this.iTrackBehindDelta := trackBehindDelta
		}

		if inPit {
			if !inList(this.Pitstops, lastLap) {
				this.Pitstops.Push(lastLap)
				this.iLastPitstop := lastLap
			}

			this.iInPit := true
		}
		else
			this.iInPit := false

		return valid
	}

	hasLapTime() {
		return (this.LapTimes.Length() > 0)
	}

	hasDelta(sector := false) {
		if sector
			return (this.Deltas[sector].Count() > 0)
		else
			return (this.Deltas.Count() > 0)
	}

	hasProblem() {
		return this.Problem
	}

	isFaster(sector) {
		local xValues := []
		local yValues := []
		local index, delta, a, b

		for index, delta in this.Deltas[sector] {
			xValues.Push(index)
			yValues.Push(delta)
		}

		a := false
		b := false

		linRegression(xValues, yValues, a, b)

		return (b > 0)
	}
}

class PositionInfo {
	iSpotter := false
	iCar := false

	iBaseLap := false
	iObserved := ""
	iInitialDeltas := {}

	iReported := false

	iBestLapTime := false

	Type[] {
		Get {
			throw "Virtual property PositionInfo.Type must be implemented in a subclass..."
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

	OpponentType[sector := false] {
		Get {
			local driverCar := this.Spotter.DriverCar
			local lastLap := driverCar.LastLap
			local position := this.Spotter.Positions["Position.Overall"]

			if (((Abs(this.Delta[sector, true, 1]) * 2) < driverCar.LapTime[true]) || (Abs(position - this.Car.Position["Overall"]) == 1))
				return "Position"
			else if (lastLap > this.Car.LastLap)
				return "LapDown"
			else if (lastLap < this.Car.LastLap)
				return "LapUp"
			else
				return "Position"
		}
	}

	Observed[] {
		Get {
			return this.iObserved
		}
	}

	InitialDelta[sector] {
		Get {
			local delta

			if this.iInitialDeltas.HasKey(sector)
				return this.iInitialDeltas[sector]
			else {
				delta := this.Delta[sector]

				this.iInitialDeltas[sector] := delta

				return delta
			}
		}
	}

	Delta[sector, average := false, count := 3] {
		Get {
			return this.Car.Delta[sector, average, count]
		}
	}

	DeltaDifference[sector] {
		Get {
			return (this.Delta[sector] - this.InitialDelta[sector])
		}
	}

	LapTimeDifference[average := false] {
		Get {
			return (this.Spotter.DriverCar.LapTime[average] - this.Car.LapTime[average])
		}
	}

	LastLapTime[] {
		Get {
			return this.Car.LastLapTime
		}
	}

	BestLapTime[update := false] {
		Get {
			if update
				this.iBestLapTime := this.Car.BestLapTime

			return this.iBestLapTime
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
	}

	hasBestLapTime() {
		return (this.BestLapTime != this.Car.BestLapTime)
	}

	hasGap(sector) {
		return (this.Car.hasDelta(sector) && this.Car.hasLapTime())
	}

	hasProblem() {
		return this.Car.hasProblem()
	}

	inDelta(sector, threshold := 2.0) {
		return (Abs(this.Delta[false, true, 1]) <= threshold)
	}

	inRange(sector, track := false, threshold := 2.0) {
		local delta := this.Delta[false, true, 1]

		if track
			if InStr(this.Observed, "TA")
				delta := this.Car.TrackAheadDelta
			else if InStr(this.Observed, "TB")
				delta := this.Car.TrackBehindDelta

		return (Abs(delta) <= threshold)
	}

	isFaster(sector) {
		return (this.LapTimeDifference[true] > 0)
	}

	closingIn(sector, threshold := 0.5) {
		local difference := this.DeltaDifference[sector]

		if this.inFront()
			return ((difference < 0) && (Abs(difference) > threshold))
		else
			return ((difference > 0) && (difference > threshold))
	}

	runningAway(sector, threshold := 2) {
		local difference := this.DeltaDifference[sector]

		if this.inFront()
			return ((difference > 0) && (difference > threshold))
		else
			return ((difference < 0) && (Abs(difference) > threshold))
	}

	isLeader() {
		return ((this.Car.Position["Class"] == 1) && (this.Car.Class = this.Spotter.DriverCar.Class))
	}

	inFront(standings := true) {
		local positions := this.Spotter.Positions
		local frontCar

		if standings
			return (this.Car.Position["Overall"] < positions["Position.Overall"])
		else {
			frontCar := positions["TrackAhead"]

			return (frontCar ? (this.Car.Nr = positions[frontCar][1]) : false)
		}
	}

	atBehind(standings := true) {
		local positions := this.Spotter.Positions
		local behindCar

		if standings
			return (this.Car.Position["Overall"] > positions["Position.Overall"])
		else {
			behindCar := positions["TrackBehind"]

			return (behindCar ? (this.Car.Nr = positions[behindCar][1]) : false)
		}
	}

	forPosition() {
		local spotter := this.Spotter
		local car := this.Car
		local positions := spotter.Positions
		local position := positions["Position.Class"]

		if (car.Class = spotter.DriverCar.Class) {
			if ((position - car.Position["Class"]) == 1)
				return "Ahead"
			else if ((position - car.Position["Class"]) == -1)
				return "Behind"
			else
				return false
		}
		else
			return false
	}

	reset(sector, reset := false, full := false) {
		if reset {
			this.Reported := false
			this.iBaseLap := this.Car.LastLap
		}

		this.iInitialDeltas := {}

		if !full
			this.iInitialDeltas[sector] := this.Delta[sector]
	}

	rebase(sector) {
		if (this.Car.LastLap >= (this.iBaseLap + 3))
			this.reset(sector, true)
		else
			this.iInitialDeltas[sector] := this.Delta[sector]
	}

	checkpoint(sector) {
		local position := this.forPosition()
		local standingsAhead := (position = "Ahead")
		local standingsBehind := (position = "Behind")
		local trackAhead := this.inFront(false)
		local trackBehind := this.atBehind(false)
		local oldObserved := this.Observed
		local newObserved := ((this.isLeader() ? "L" : "") . (trackAhead ? "TA" : "") . (trackBehind ? "TB" : "")
							. (standingsAhead ? "SA" : "") . (standingsBehind ? "SB" : ""))

		if this.Car.InPit {
			if !InStr(this.iObserved, "P")
				this.iObserved .= "P"

			this.reset(sector, true, true)
		}
		else if this.Spotter.DriverCar.InPit {
			this.reset(sector, true, true)

			this.iObserved := newObserved
		}
		else if (newObserved != oldObserved) {
			if (((trackAhead && standingsBehind) || (trackBehind && standingsAhead))
			 && (this.Car.LastLap = this.Spotter.DriverCar.LastLap)) {
				; Can happen in ACC due to asynchronous position updating

				this.reset(sector, true, true)

				this.iObserved := ""
			}
			else if ((standingsBehind && InStr(oldObserved, "SA")) || (standingsAhead && InStr(oldObserved, "SB"))
				  || (trackBehind && InStr(oldObserved, "TA")) || (trackAhead && InStr(oldObserved, "TB"))) {
				; Drivers car has been overtaken

				this.reset(sector, true, true)

				this.iObserved := ""
			}
			else {
				if ((trackBehind || trackAhead) && (!InStr(oldObserved, "TB") && !InStr(oldObserved, "TA"))) {
					; Change in car ahead or behind due to an overtake

					this.reset(sector, true, true)
				}
				else
					this.Reported := false

				this.iObserved := newObserved
			}
		}
		else if ((newObserved = "") || (newObserved = "L"))
			this.rebase(sector)
	}
}

class RaceSpotter extends RaceAssistant {
	iSpotterPID := false
	iRunning := false

	iSessionDataActive := false

	iOverallGridPosition := false
	iClassGridPosition := false

	iWasStartDriver := false

	iLastDeltaInformationLap := 0
	iPositionInfos := {}
	iTacticalAdvices := {}
	iSessionInfos := {}

	iDriverCar := false
	iOtherCars := {}
	iPositions := {}

	iPendingAlerts := []

	class SpotterVoiceManager extends RaceAssistant.RaceVoiceManager {
		iFastSpeechSynthesizer := false

		class FastSpeaker extends VoiceManager.LocalSpeaker {
			speak(arguments*) {
				if (this.VoiceManager.RaceAssistant.Session >= kSessionPractice)
					base.speak(arguments*)
			}

			speakPhrase(phrase, arguments*) {
				if this.VoiceManager.RaceAssistant.skipAlert(phrase)
					return

				if this.Awaitable
					this.wait()

				base.speakPhrase(phrase, arguments*)
			}
		}

		getSpeaker(fast := false) {
			local synthesizer

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

	Running[] {
		Get {
			return this.iRunning
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

	GridPosition[type := "Overall"] {
		Get {
			return ((type = "Overall") ? this.iOverallGridPosition : this.iClassGridPosition)
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

	Positions[key := false] {
		Get {
			return (key ? this.iPositions[key] : this.iPositions)
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

	TacticalAdvices[key := false] {
		Get {
			return (key ? this.iTacticalAdvices[key] : this.iTacticalAdvices)
		}

		Set {
			return (key ? (this.iTacticalAdvices[key] := value) : (this.iTacticalAdvices := value))
		}
	}

	SessionInfos[key := false] {
		Get {
			return (key ? this.iSessionInfos[key] : this.iSessionInfos)
		}

		Set {
			return (key ? (this.iSessionInfos[key] := value) : (this.iSessionInfos := value))
		}
	}

	__New(configuration, remoteHandler, name := false, language := "__Undefined__"
		, synthesizer := false, speaker := false, vocalics := false, recognizer := false, listener := false, voiceServer := false) {
		base.__New(configuration, "Race Spotter", remoteHandler, name, language, synthesizer, speaker, vocalics, recognizer, listener, voiceServer)

		if isDebug() {
			this.setDebug(kDebugKnowledgeBase, true)
			this.setDebug(kDebugPositions, true)
		}

		this.updateConfigurationValues({Announcements: {DeltaInformation: 2, TacticalAdvices: true
													  , SideProximity: true, RearProximity: true
		 											  , YellowFlags: true, BlueFlags: true, PitWindow: true
													  , SessionInformation: true}})

		OnExit(ObjBindMethod(this, "shutdownSpotter", true))
	}

	setDebug(option, enabled) {
		local label := false

		base.setDebug(option, enabled)

		switch option {
			case kDebugPositions:
				label := translate("Debug Positions")
		}

		try {
			if label
				if enabled
					Menu SupportMenu, Check, %label%
				else
					Menu SupportMenu, Uncheck, %label%
		}
		catch exception {
			logError(exception)
		}
	}

	createVoiceManager(name, options) {
		return new this.SpotterVoiceManager(this, name, options)
	}

	updateSessionValues(values) {
		base.updateSessionValues(values)

		if values.HasKey("Running")
			this.iRunning := values["Running"]

		if (values.HasKey("Session") && (values["Session"] == kSessionFinished)) {
			this.iLastDeltaInformationLap := 0

			this.iRunning := false
			this.iDriverCar := false
			this.OtherCars := {}
			this.PositionInfos := {}
			this.TacticalAdvices := {}
			this.SessionInfos := {}
		}
	}

	updateDynamicValues(values) {
		if (values.HasKey("BaseLap") && (values["BaseLap"] != this.BaseLap))
			this.SessionInfos.Delete("AirTemperature")

		base.updateDynamicValues(values)
	}

	handleVoiceCommand(grammar, words) {
		switch grammar {
			case "Position":
				this.positionRecognized(words)
			case "LapTimes":
				this.lapTimesRecognized(words)
			case "GapToAhead":
				this.gapToAheadRecognized(words)
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
		local speaker := this.getSpeaker()
		local position := this.getPosition()
		local positionClass

		if (position == 0)
			speaker.speakPhrase("Later")
		else if inList(words, speaker.Fragments["Laps"])
			this.futurePositionRecognized(words)
		else {
			speaker.beginTalk()

			try {
				if this.MultiClass {
					positionClass := this.getPosition(false, "Class")

					if (position != positionClass) {
						speaker.speakPhrase("PositionClass", {positionOverall: position, positionClass: positionClass})

						position := positionClass
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

		if knowledgeBase.getValue("Car." . car . ".InPitLane")
			speaker.speakPhrase("AheadCarInPit")
		else if (delta != 0) {
			speaker.beginTalk()

			try {
				speaker.speakPhrase("TrackGapToAhead", {delta: printNumber(delta / 1000, 1)})

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

	standingsGapToAheadRecognized(words, standard := true) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local talking := false
		local delta, lap, car, inPit, speaker

		if (this.getPosition(false, "Class") = 1)
			speaker.speakPhrase("NoGapToAhead")
		else
			try {
				lap := knowledgeBase.getValue("Lap")
				car := knowledgeBase.getValue("Position.Standings.Class.Ahead.Car")
				delta := Abs(knowledgeBase.getValue("Position.Standings.Class.Ahead.Delta", 0) / 1000)
				inPit := knowledgeBase.getValue("Car." . car . ".InPitLane")

				if (delta = 0) {
					if standard {
						speaker.speakPhrase(inPit ? "AheadCarInPit" : "NoTrackGap")

						return true
					}
					else
						return false
				}
				else if ((knowledgeBase.getValue("Car." . car . ".Lap") > lap)
					  && (Abs(delta) > (knowledgeBase.getValue("Lap." . lap . ".Time") / 1000))) {
					if standard {
						speaker.beginTalk()

						speaker.speakPhrase("StandingsAheadLapped")
					}
					else
						return false
				}
				else {
					speaker.beginTalk()

					speaker.speakPhrase("StandingsGapToAhead", {delta: printNumber(delta, 1)})
				}

				talking := true

				if inPit
					speaker.speakPhrase("GapCarInPit")
			}
			finally {
				if talking
					speaker.endTalk()
			}

		return true
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

		if knowledgeBase.getValue("Car." . car . ".InPitLane")
			speaker.speakPhrase("BehindCarInPit")
		else if (delta != 0) {
			speaker.beginTalk()

			try {
				speaker.speakPhrase("TrackGapToBehind", {delta: printNumber(delta / 1000, 1)})

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

	standingsGapToBehindRecognized(words, standard := true) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local talking := false
		local delta, car, speaker, driver, inPit, lap, lapped

		if (this.getPosition(false, "Class") = this.getCars("Class").Length())
			speaker.speakPhrase("NoGapToBehind")
		else {
			speaker := this.getSpeaker()

			try {
				lap := knowledgeBase.getValue("Lap")
				car := knowledgeBase.getValue("Position.Standings.Class.Behind.Car")
				delta := Abs(knowledgeBase.getValue("Position.Standings.Class.Behind.Delta", 0) / 1000)
				inPit := knowledgeBase.getValue("Car." . car . ".InPitLane")
				lapped := false

				if (delta = 0) {
					if standard {
						speaker.speakPhrase(inPit ? "BehindCarInPit" : "NoTrackGap")

						return true
					}
					else
						return false
				}
				else if ((knowledgeBase.getValue("Car." . car . ".Lap") < lap)
					  && (Abs(delta) > (knowledgeBase.getValue("Lap." . lap . ".Time") / 1000))) {
					if standard {
						speaker.beginTalk()

						speaker.speakPhrase("StandingsBehindLapped")

						lapped := true
					}
					else
						return false
				}
				else {
					speaker.beginTalk()

					speaker.speakPhrase("StandingsGapToBehind", {delta: printNumber(delta, 1)})
				}

				talking := true

				if (!lapped && inPit)
					speaker.speakPhrase("GapCarInPit")
			}
			finally {
				if talking
					speaker.endTalk()
			}
		}

		return true
	}

	gapToLeaderRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local delta

		if !this.hasEnoughData()
			return

		if (this.getPosition(false, "Class") = 1)
			this.getSpeaker().speakPhrase("NoGapToAhead")
		else {
			delta := Abs(knowledgeBase.getValue("Position.Standings.Class.Leader.Delta", 0) / 1000)

			this.getSpeaker().speakPhrase("GapToLeader", {delta: printNumber(delta, 1)})
		}
	}

	reportLapTime(phrase, driverLapTime, car) {
		local lapTime := this.KnowledgeBase.getValue("Car." . car . ".Time", false)
		local speaker, fragments, minute, seconds, delta

		if lapTime {
			lapTime /= 1000

			speaker := this.getSpeaker()
			fragments := speaker.Fragments

			minute := Floor(lapTime / 60)
			seconds := (lapTime - (minute * 60))

			speaker.speakPhrase(phrase, {time: printNumber(lapTime, 1), minute: minute, seconds: printNumber(seconds, 1)})

			delta := (driverLapTime - lapTime)

			if (Abs(delta) > 0.5)
				speaker.speakPhrase("LapTimeDelta", {delta: printNumber(Abs(delta), 1)
												   , difference: (delta > 0) ? fragments["Faster"] : fragments["Slower"]})
		}
	}

	lapTimesRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local car, lap, position, cars, driverLapTime, speaker, minute, seconds

		if !this.hasEnoughData()
			return

		car := knowledgeBase.getValue("Driver.Car")
		lap := knowledgeBase.getValue("Lap")
		position := this.getPosition(false, "Class")
		cars := knowledgeBase.getValue("Car.Count")

		driverLapTime := (knowledgeBase.getValue("Car." . car . ".Time") / 1000)
		speaker := this.getSpeaker()

		if (lap == 0)
			speaker.speakPhrase("Later")
		else {
			speaker.beginTalk()

			try {
				minute := Floor(driverLapTime / 60)
				seconds := (driverLapTime - (minute * 60))

				speaker.speakPhrase("LapTime", {time: printNumber(driverLapTime, 1), minute: minute, seconds: printNumber(seconds, 1)})

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

	updateAnnouncement(announcement, value) {
		if (value && (announcement = "DeltaInformation")) {
			value := getConfigurationValue(this.Configuration, "Race Spotter Announcements", this.Simulator . ".PerformanceUpdates", 2)
			value := getConfigurationValue(this.Configuration, "Race Spotter Announcements", this.Simulator . ".DistanceInformation", value)
			value := getConfigurationValue(this.Configuration, "Race Spotter Announcements", this.Simulator . ".DeltaInformation", value)

			if !value
				value := 2
		}

		base.updateAnnouncement(announcement, value)
	}

	getSpeaker(fast := false) {
		return this.VoiceManager.getSpeaker(fast)
	}

	updateCarInfos(lastLap, sector, positions) {
		local knowledgeBase = this.KnowledgeBase
		local driver, otherCars, car, carNr, cInfo, carLaps

		if (lastLap > 0) {
			driver := positions["Driver"]

			otherCars := this.OtherCars

			loop % positions["Count"]
			{
				car := positions[A_Index]
				carNr := car[1]

				if (A_Index != driver) {
					if otherCars.HasKey(carNr)
						cInfo := otherCars[carNr]
					else {
						cInfo := new CarInfo(carNr, car[2], car[3])

						otherCars[carNr] := cInfo
					}
				}
				else {
					cInfo := this.DriverCar

					if !cInfo {
						cInfo := new CarInfo(carNr, car[2], car[3])

						this.iDriverCar := cInfo
					}
				}

				carLaps := car[7]

				if !cInfo.update(car[4], car[5], car[6], carLaps, sector
							   , Round(car[9] / 1000, 1), Round(car[10] / 1000, 1), Round(car[11] / 1000, 1), Round(car[12] / 1000, 1)
							   , car[13], (carLaps - car[14]), car[15], car[16])
					if (A_Index != driver)
						if this.PositionInfos.HasKey(cInfo.Nr)
							this.PositionInfos[cInfo.Nr].reset(sector, true, true)
			}
		}
	}

	updatePositionInfos(lastLap, sector, positions) {
		local debug := this.Debug[kDebugPositions]
		local positionInfos, position, info
		local nr, car

		this.updateCarInfos(lastLap, sector, positions)

		positionInfos := this.PositionInfos

		if debug
			FileAppend ---------------------------------`n`n, %kTempDirectory%Race Spotter.positions

		for nr, car in this.OtherCars {
			if positionInfos.HasKey(nr)
				position := positionInfos[nr]
			else {
				position := new PositionInfo(this, car)

				positionInfos[nr] := position
			}

			if debug {
				info := values2String(", ", position.Car.Nr, position.Car.Car, position.Car.Driver, position.Car.Position["Class"], position.Observed
										  , values2String("|", position.Car.LapTimes*), position.Car.LapTime[true]
										  , values2String("|", position.Car.Deltas[sector]*), position.Delta[sector]
										  , position.inFront(), position.atBehind(), position.inFront(false), position.atBehind(false), position.forPosition()
										  , position.DeltaDifference[sector], position.LapTimeDifference[true]
										  , position.isFaster(sector), position.closingIn(sector, 0.2), position.runningAway(sector, 0.3))

				FileAppend %info%`n, %kTempDirectory%Race Spotter.positions
			}

			position.checkpoint(sector)
		}

		if debug
			FileAppend `n---------------------------------`n`n, %kTempDirectory%Race Spotter.positions
	}

	getPositionInfos(ByRef standingsAhead, ByRef standingsBehind
				   , ByRef trackAhead, ByRef trackBehind, ByRef leader, inpit := false) {
		local ignore, observed, candidate, cInpit

		standingsAhead := false
		standingsBehind := false
		trackAhead := false
		trackBehind := false
		leader := false

		for ignore, candidate in this.PositionInfos {
			observed := candidate.Observed
			cInPit := InStr(observed, "P")

			if ((!inpit && cInpit) || (inpit && !cInpit))
				continue

			if !cInPit
				if InStr(observed, "TA")
					trackAhead := candidate
				else if InStr(observed, "TB")
					trackBehind := candidate

			if InStr(observed, "SA")
				standingsAhead := candidate
			else if InStr(observed, "SB")
				standingsBehind := candidate

			if InStr(observed, "L")
				leader := candidate
		}
	}

	reviewRaceStart(lastLap, sector, positions) {
		local startPosition := this.GridPosition["Class"]
		local speaker, driver, currentPosition, startPosition

		if ((this.Session == kSessionRace) && startPosition) {
			speaker := this.getSpeaker(true)
			driver := positions["Driver"]

			if driver {
				currentPosition := positions["Position.Class"]

				speaker.beginTalk()

				try {
					if (currentPosition = startPosition)
						speaker.speakPhrase("GoodStart")
					else if (currentPosition < startPosition) {
						speaker.speakPhrase("GreatStart")

						if (currentPosition = 1)
							speaker.speakPhrase("Leader")
						else
							speaker.speakPhrase("PositionsGained", {positions: Abs(currentPosition - startPosition)})
					}
					else if (currentPosition > startPosition) {
						speaker.speakPhrase("BadStart")

						speaker.speakPhrase("PositionsLost", {positions: Abs(currentPosition - startPosition)})

						speaker.speakPhrase("Fight")
					}
				}
				finally {
					speaker.endTalk()
				}

				return true
			}
			else
				return false
		}
		else
			return false
	}

	reviewHalfTime(lastLap, sector, positions) {
		local knowledgeBase, remainingSessionLaps, remainingStintLaps, remainingSessionTime
		local remainingStintTime, remainingFuelLaps, enoughFuel, speaker

		if (this.Session == kSessionRace) {
			speaker := this.getSpeaker(true)

			knowledgeBase := this.KnowledgeBase
			remainingSessionLaps := knowledgeBase.getValue("Lap.Remaining.Session")
			remainingStintLaps := knowledgeBase.getValue("Lap.Remaining.Stint")
			remainingSessionTime := Round(knowledgeBase.getValue("Session.Time.Remaining") / 60000)
			remainingStintTime := Round(knowledgeBase.getValue("Driver.Time.Stint.Remaining") / 60000)

			speaker.beginTalk()

			try {
				speaker.speakPhrase("HalfTimeIntro", {minutes: remainingSessionTime
													, laps: remainingSessionLaps
													, position: Round(positions["Position.Class"])})

				remainingFuelLaps := Floor(knowledgeBase.getValue("Lap.Remaining.Fuel"))

				if (remainingStintTime < remainingSessionTime) {
					speaker.speakPhrase("HalfTimeStint", {minutes: remainingStintTime, laps: Floor(remainingStintLaps)})

					enoughFuel := (remainingStintLaps < remainingFuelLaps)
				}
				else {
					speaker.speakPhrase("HalfTimeSession", {minutes: remainingSessionTime
														  , laps: Ceil(remainingSessionLaps)})

					enoughFuel := (remainingSessionLaps < remainingFuelLaps)
				}

				speaker.speakPhrase(enoughFuel ? "HalfTimeEnoughFuel" : "HalfTimeNotEnoughFuel"
								  , {laps: Floor(remainingFuelLaps)})
			}
			finally {
				speaker.endTalk()
			}

			return true
		}
		else
			return false
	}

	announceFinalLaps(lastLap, sector, positions) {
		local speaker := this.getSpeaker(true)
		local position := positions["Position.Class"]

		speaker.beginTalk()

		try {
			speaker.speakPhrase("LastLaps")

			if (position <= 5) {
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
			speaker.endTalk()
		}
	}

	sessionInformation(lastLap, sector, positions, regular) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker(true)
		local airTemperature := Round(knowledgebase.getValue("Weather.Temperature.Air"))
		local trackTemperature := Round(knowledgebase.getValue("Weather.Temperature.Track"))
		local remainingSessionLaps := knowledgeBase.getValue("Lap.Remaining.Session")
		local remainingStintLaps := knowledgeBase.getValue("Lap.Remaining.Stint")
		local remainingSessionTime := Round(knowledgeBase.getValue("Session.Time.Remaining") / 60000)
		local standingsAhead := false
		local standingsBehind := false
		local trackAhead := false
		local trackBehind := false
		local leader := false
		local situation, sessionDuration, lapTime, sessionEnding, minute, lastTemperature, stintLaps
		local minute, rnd, phrase, bestLapTime

		if (this.Session == kSessionRace)
			if (lastLap == 2) {
				situation := "StartSummary"

				if !this.SessionInfos.HasKey(situation) {
					this.SessionInfos[situation] := true

					if this.reviewRaceStart(lastLap, sector, positions)
						return true
				}
			}
			else if (remainingSessionLaps > 5) {
				situation := "HalfTime"

				if (!this.SessionInfos.HasKey(situation) && (Abs((this.SessionDuration / 2) - this.OverallTime) < 120000)) {
					this.SessionInfos[situation] := true

					if this.reviewHalfTime(lastLap, sector, positions)
						return true
				}
			}

		if this.hasEnoughData(false) {
			if ((remainingSessionLaps <= 3) && (Floor(remainingSessionLaps) > 1) && (this.Session = kSessionRace)) {
				situation := "FinalLaps"

				if !this.SessionInfos.HasKey(situation) {
					this.SessionInfos[situation] := true

					this.announceFinalLaps(lastLap, sector, positions)

					return true
				}
			}

			if (sector = 1) {
				stintLaps := Floor(remainingStintLaps)

				if ((this.Session = kSessionRace) && (stintLaps < 4) && (Abs(remainingStintLaps - remainingSessionLaps) > 2)) {
					if (stintLaps > 0) {
						situation := ("StintEnding " . Ceil(lastLap + stintLaps))

						if !this.SessionInfos.HasKey(situation) {
							this.SessionInfos[situation] := true

							speaker.speakPhrase("StintEnding", {laps: stintLaps})

							return true
						}
					}
				}

				if (this.BestLapTime > 0) {
					bestLapTime := Round(this.BestLapTime, 2)

					if (!this.SessionInfos.HasKey("BestLap") || (bestLapTime < this.SessionInfos["BestLap"])) {
						lapTime := (bestLapTime / 1000)

						minute := Floor(lapTime / 60)

						speaker.speakPhrase("BestLap", {time: printNumber(lapTime, 1)
													  , minute: minute, seconds: printNumber((lapTime - (minute * 60)), 1)})

						this.SessionInfos["BestLap"] := bestLapTime

						return true
					}
					else
						this.SessionInfos["BestLap"] := bestLapTime
				}
			}

			if !this.SessionInfos.HasKey("AirTemperature") {
				if (lastLap > (this.BaseLap + 1)) {
					this.SessionInfos["AirTemperature"] := airTemperature

					if (this.BaseLap > 1) {
						speaker.speakPhrase("Temperature", {air: airTemperature, track: trackTemperature})

						return true
					}
				}
			}
			else {
				lastTemperature := this.SessionInfos["AirTemperature"]

				this.SessionInfos["AirTemperature"] := airTemperature

				if (lastTemperature < airTemperature) {
					speaker.speakPhrase("TemperatureRising", {air: airTemperature, track: trackTemperature})

					return true
				}

				if (lastTemperature > airTemperature) {
					speaker.speakPhrase("TemperatureFalling", {air: airTemperature, track: trackTemperature})

					return true
				}
			}

			if (this.Session != kSessionRace) {
				sessionEnding := false

				if ((remainingSessionTime < 5) && !this.SessionInfos.HasKey("5MinAlert")) {
					this.SessionInfos["5MinAlert"] := true
					this.SessionInfos["15MinAlert"] := true
					this.SessionInfos["30MinAlert"] := true

					sessionEnding := true
				}

				if ((remainingSessionTime < 15) && !this.SessionInfos.HasKey("15MinAlert")) {
					this.SessionInfos["15MinAlert"] := true
					this.SessionInfos["30MinAlert"] := true

					sessionEnding := true
				}

				if ((remainingSessionTime < 30) && !this.SessionInfos.HasKey("30MinAlert")) {
					this.SessionInfos["30MinAlert"] := true

					sessionEnding := true
				}

				if sessionEnding {
					speaker.speakPhrase("SessionEnding", {minutes: remainingSessionTime})

					return true
				}
			}

			if ((sector = 1) && (lastLap > 2)) {
				this.getPositionInfos(standingsAhead, standingsBehind, trackAhead, trackBehind, leader)

				lapTime := false

				if (standingsAhead && standingsAhead.hasBestLapTime()) {
					lapTime := standingsAhead.BestLapTime[true]

					if (lapTime = standingsAhead.LastLapTime)
						phrase := "AheadBestLap"
					else
						lapTime := false
				}
				else if (standingsBehind && standingsBehind.hasBestLapTime()) {
					lapTime := standingsBehind.BestLapTime[true]

					if (lapTime = standingsBehind.LastLapTime)
						phrase := "BehindBestLap"
					else
						lapTime := false
				}
				else if (leader && leader.hasBestLapTime()) {
					lapTime := leader.BestLapTime[true]

					if (lapTime = leader.LastLapTime)
						phrase := "LeaderBestLap"
					else
						lapTime := false
				}

				if (!lapTime && regular && (this.Session == kSessionRace)) {
					Random rnd, 1, 10

					if (rnd > 8) {
						Random rnd, 1, 100

						if ((rnd <= 33) && standingsAhead) {
							lapTime := standingsAhead.LastLapTime
							phrase := "AheadLapTime"
						}
						else if ((rnd > 33) && (rnd <= 66) && standingsBehind) {
							lapTime := standingsBehind.LastLapTime
							phrase := "BehindLapTime"
						}
						else if ((rnd > 66) && leader) {
							lapTime := leader.LastLapTime
							phrase := "LeaderLapTime"
						}
					}
				}

				if lapTime {
					minute := Floor(lapTime / 60)

					speaker.speakPhrase(phrase, {time: printNumber(lapTime, 1), minute: minute
																			  , seconds: printNumber(lapTime - (minute * 60), 1)})

					return true
				}
			}
		}

		return false
	}

	tacticalAdvice(lastLap, sector, positions, regular) {
		local speaker := this.getSpeaker(true)
		local standingsAhead := false
		local standingsBehind := false
		local trackAhead := false
		local trackBehind := false
		local leader := false
		local situation, opponentType

		this.getPositionInfos(standingsAhead, standingsBehind, trackAhead, trackBehind, leader, true)

		if (standingsAhead && (standingsAhead != leader)) {
			situation := ("AheadPitting " . standingsAhead.Car.Nr . A_Space . standingsAhead.Car.LastLap)

			if !this.TacticalAdvices.HasKey(situation) {
				this.TacticalAdvices[situation] := true

				speaker.speakPhrase("AheadPitting")

				return true
			}
		}

		if standingsBehind {
			situation := ("BehindPitting " . standingsBehind.Car.Nr . A_Space . standingsBehind.Car.LastLap)

			if !this.TacticalAdvices.HasKey(situation) {
				this.TacticalAdvices[situation] := true

				speaker.speakPhrase("BehindPitting")

				return true
			}
		}

		if (leader && (leader.Car.Nr != this.DriverCar.Nr)) {
			situation := ("LeaderPitting " . leader.Car.Nr . A_Space . leader.Car.LastLap)

			if !this.TacticalAdvices.HasKey(situation) {
				this.TacticalAdvices[situation] := true

				speaker.speakPhrase("LeaderPitting")

				return true
			}
		}

		this.getPositionInfos(standingsAhead, standingsBehind, trackAhead, trackBehind, leader)

		if (standingsAhead && standingsAhead.hasProblem()) {
			situation := ("AheadProblem " . lastLap)

			if !this.TacticalAdvices.HasKey(situation) {
				this.TacticalAdvices[situation] := true

				speaker.speakPhrase("AheadProblem")

				return true
			}
		}

		if (regular && trackAhead && trackAhead.inRange(sector, true) && !trackAhead.isFaster(sector)
		 && standingsBehind && (standingsBehind == trackBehind)
		 && standingsBehind.hasGap(sector) && trackAhead.hasGap(sector)
		 && standingsBehind.inDelta(sector) && standingsBehind.isFaster(sector)) {
			situation := ("ProtectSlower " . trackAhead.Car.Nr . A_Space . trackBehind.Car.Nr)

			if !this.TacticalAdvices.HasKey(situation) {
				this.TacticalAdvices[situation] := true

				speaker.speakPhrase("ProtectSlower")

				return true
			}
		}

		if (sector > 1) {
			opponentType := (trackBehind ? trackBehind.OpponentType[sector] : false)

			if (regular && trackBehind && trackBehind.hasGap(sector)
			 && trackBehind.isFaster(sector) && trackBehind.inRange(sector, true)) {
				if (standingsBehind && (trackBehind != standingsBehind)
				 && standingsBehind.hasGap(sector) && standingsBehind.inDelta(sector, 4.0)
				 && standingsBehind.isFaster(sector) && (opponentType = "LapDown")) {
					situation := ("ProtectFaster " . trackBehind.Car.Nr . A_Space . standingsBehind.Car.Nr)

					if !this.TacticalAdvices.HasKey(situation) {
						this.TacticalAdvices[situation] := true

						speaker.speakPhrase("ProtectFaster")

						return true
					}
				}
				else if ((opponentType = "LapDown") || (opponentType = "LapUp")) {
					situation := (opponentType . "Faster " . trackBehind.Car.Nr)

					if !this.TacticalAdvices.HasKey(situation) {
						this.TacticalAdvices[situation] := true

						speaker.beginTalk()

						try {
							speaker.speakPhrase(opponentType . "Faster")

							speaker.speakPhrase("Slipstream")
						}
						finally {
							speaker.endTalk()
						}

						return true
					}
				}
			}
		}

		if (standingsBehind && standingsBehind.hasProblem()) {
			situation := ("BehindProblem " . lastLap)

			if !this.TacticalAdvices.HasKey(situation) {
				this.TacticalAdvices[situation] := true

				speaker.speakPhrase("BehindProblem")

				return true
			}
		}

		return false
	}

	deltaInformation(lastLap, sector, positions, regular, method) {
		local knowledgeBase := this.KnowledgeBase
		local spoken := false
		local standingsAhead, standingsBehind, trackAhead, trackBehind, leader, info, informed
		local opponentType, delta, deltaDifference, lapTimeDifference, car, remaining, speaker, rnd

		static lapUpRangeThreshold := "__Undefined__"
		static lapDownRangeThreshold := false
		static frontAttackThreshold := false
		static frontGainThreshold := false
		static frontLostThreshold := false
		static behindAttackThreshold := false
		static behindGainThreshold := false
		static behindLostThreshold := false

		if (lapUpRangeThreshold = kUndefined) {
			lapUpRangeThreshold := getDeprecatedConfigurationValue(this.Settings, "Assistant.Spotter", "Spotter Settings", "LapUp.Range.Threshold", 1.0)
			lapDownRangeThreshold := getDeprecatedConfigurationValue(this.Settings, "Assistant.Spotter", "Spotter Settings", "LapDown.Range.Threshold", 2.0)
			frontAttackThreshold := getDeprecatedConfigurationValue(this.Settings, "Assistant.Spotter", "Spotter Settings", "Front.Attack.Threshold", 0.8)
			frontGainThreshold := getDeprecatedConfigurationValue(this.Settings, "Assistant.Spotter", "Spotter Settings", "Front.Gain.Threshold", 0.3)
			frontLostThreshold := getDeprecatedConfigurationValue(this.Settings, "Assistant.Spotter", "Spotter Settings", "Front.Lost.Threshold", 1.0)
			behindAttackThreshold := getDeprecatedConfigurationValue(this.Settings, "Assistant.Spotter", "Spotter Settings", "Behind.Attack.Threshold", 0.8)
			behindLostThreshold := getDeprecatedConfigurationValue(this.Settings, "Assistant.Spotter", "Spotter Settings", "Behind.Lost.Threshold", 0.3)
			behindGainThreshold := getDeprecatedConfigurationValue(this.Settings, "Assistant.Spotter", "Spotter Settings", "Behind.Gain.Threshold", 1.5)
		}

		standingsAhead := false
		standingsBehind := false
		trackAhead := false
		trackBehind := false
		leader := false

		this.getPositionInfos(standingsAhead, standingsBehind, trackAhead, trackBehind, leader)

		if this.Debug[kDebugPositions] {
			info := ("=================================`n" . regular . (standingsAhead != false) . (standingsBehind != false) . (trackAhead != false) . (trackBehind != false) . "`n=================================`n`n")

			FileAppend %info%, %kTempDirectory%Race Spotter.positions
		}

		speaker := this.getSpeaker(true)

		informed := false

		speaker.beginTalk()

		try {
			opponentType := (trackAhead ? trackAhead.OpponentType[sector] : false)

			if ((sector > 1) && trackAhead && (trackAhead != standingsAhead) && trackAhead.hasGap(sector)
			 && (opponentType != "Position")
			 && trackAhead.inRange(sector, true, (opponentType = "LapDown") ? lapDownRangeThreshold : lapUpRangeThreshold)
			 && !trackAhead.isFaster(sector) && !trackAhead.runningAway(sector, frontGainThreshold)
			 && !trackAhead.Reported) {
				if (opponentType = "LapDown") {
					speaker.speakPhrase("LapDownDriver")

					trackAhead.Reported := true

					spoken := true
				}
				else if (opponentType = "LapUp") {
					speaker.speakPhrase("LapUpDriver")

					trackAhead.Reported := true

					spoken := true
				}
			}
			else if (standingsAhead && standingsAhead.hasGap(sector) && (method >= kDeltaMethodDynamic)) {
				delta := Abs(standingsAhead.Delta[false, true, 1])
				deltaDifference := Abs(standingsAhead.DeltaDifference[sector])
				lapTimeDifference := Abs(standingsAhead.LapTimeDifference)

				if this.Debug[kDebugPositions] {
					info := values2String(", ", values2String("|", this.DriverCar.LapTimes*), this.DriverCar.LapTime[true]
											  , standingsAhead.Car.Nr, standingsAhead.Car.InPit, standingsAhead.Reported
											  , values2String("|", standingsAhead.Car.LapTimes*), standingsAhead.Car.LapTime[true]
											  , values2String("|", standingsAhead.Car.Deltas[sector]*)
											  , standingsAhead.Delta[sector], standingsAhead.Delta[false, true, 1]
											  , standingsAhead.inFront(), standingsAhead.atBehind()
											  , standingsAhead.inFront(false), standingsAhead.atBehind(false), standingsAhead.forPosition()
											  , standingsAhead.DeltaDifference[sector], standingsAhead.LapTimeDifference[true]
											  , standingsAhead.isFaster(sector)
											  , standingsAhead.closingIn(sector, frontGainThreshold)
											  , standingsAhead.runningAway(sector, frontLostThreshold))

					info := ("=================================`n" . info . "`n=================================`n`n")

					FileAppend %info%, %kTempDirectory%Race Spotter.positions
				}

				if ((delta <= frontAttackThreshold) && !standingsAhead.isFaster(sector) && !standingsAhead.Reported) {
					speaker.speakPhrase("GotHim", {delta: printNumber(delta, 1)
												 , gained: printNumber(deltaDifference, 1)
												 , lapTime: printNumber(lapTimeDifference, 1)})

					car := standingsAhead.Car

					if (car.Incidents > 0)
						speaker.speakPhrase("UnsafeDriverFront")
					else if (car.InvalidLaps > 3)
						speaker.speakPhrase("InconsistentDriverFront")

					standingsAhead.Reported := true

					standingsAhead.reset(sector)

					spoken := true
				}
				else if (regular && standingsAhead.closingIn(sector, frontGainThreshold) && !standingsAhead.Reported) {
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

					standingsAhead.reset(sector)

					spoken := true
				}
				else if (regular && standingsAhead.runningAway(sector, frontLostThreshold)) {
					speaker.speakPhrase("LostFront", {delta: (delta > 5) ? Round(delta) : printNumber(delta, 1)
													, lost: printNumber(deltaDifference, 1)
													, lapTime: printNumber(lapTimeDifference, 1)})

					standingsAhead.reset(sector, true)

					spoken := true
				}
			}

			if (standingsBehind && standingsBehind.hasGap(sector) && (method >= kDeltaMethodDynamic)) {
				delta := Abs(standingsBehind.Delta[false, true, 1])
				deltaDifference := Abs(standingsBehind.DeltaDifference[sector])
				lapTimeDifference := Abs(standingsBehind.LapTimeDifference)

				if this.Debug[kDebugPositions] {
					info := values2String(", ", values2String("|", this.DriverCar.LapTimes*), this.DriverCar.LapTime[true]
											  , standingsBehind.Car.Nr, , standingsBehind.Car.InPit, standingsBehind.Reported
											  , values2String("|", standingsBehind.Car.LapTimes*), standingsBehind.Car.LapTime[true]
											  , values2String("|", standingsBehind.Car.Deltas[sector]*)
											  , standingsBehind.Delta[sector], standingsBehind.Delta[false, true, 1]
											  , standingsBehind.inFront(), standingsBehind.atBehind()
											  , standingsBehind.inFront(false), standingsBehind.atBehind(false), standingsBehind.forPosition()
											  , standingsBehind.DeltaDifference[sector], standingsBehind.LapTimeDifference[true]
											  , standingsBehind.isFaster(sector)
											  , standingsBehind.closingIn(sector, behindLostThreshold)
											  , standingsBehind.runningAway(sector, behindGainThreshold))

					info := ("=================================`n" . info . "`n=================================`n`n")

					FileAppend %info%, %kTempDirectory%Race Spotter.positions
				}

				if ((delta <= behindAttackThreshold) && (standingsBehind.isFaster(sector) || standingsBehind.closingIn(sector, behindLostThreshold)) && !standingsBehind.Reported) {
					speaker.speakPhrase("ClosingIn", {delta: printNumber(delta, 1)
													, lost: printNumber(deltaDifference, 1)
													, lapTime: printNumber(lapTimeDifference, 1)})

					car := standingsAhead.Car

					if (car.Incidents > 0)
						speaker.speakPhrase("UnsafeDriveBehind")
					else if (car.InvalidLaps > 3)
						speaker.speakPhrase("InconsistentDriverBehind")

					standingsBehind.Reported := true

					standingsBehind.reset(sector)

					spoken := true
				}
				else if (regular && standingsBehind.closingIn(sector, behindLostThreshold) && !standingsBehind.Reported) {
					speaker.speakPhrase("LostBehind", {delta: (delta > 5) ? Round(delta) : printNumber(delta, 1)
													 , lost: printNumber(deltaDifference, 1)
													 , lapTime: printNumber(lapTimeDifference, 1)})

					if !informed
						speaker.speakPhrase("Focus")

					standingsBehind.reset(sector)

					spoken := true
				}
				else if (regular && standingsBehind.runningAway(sector, behindGainThreshold)) {
					speaker.speakPhrase("GainedBehind", {delta: (delta > 5) ? Round(delta) : printNumber(delta, 1)
													   , gained: printNumber(deltaDifference, 1)
													   , lapTime: printNumber(lapTimeDifference, 1)})

					standingsBehind.reset(sector, true)

					spoken := true
				}
			}
		}
		finally {
			speaker.endTalk()
		}

		if (!spoken && regular && ((method = kDeltaMethodStatic) || (method = kDeltaMethodBoth))) {
			if (regular = "S")
				Random rnd, 1, 7
			else
				Random rnd, 1, 9

			if (rnd > 6) {
				Random rnd, 1, 10

				if (standingsAhead && (rnd > 3))
					spoken := this.standingsGapToAheadRecognized([], false)
				else if (standingsBehind && (rnd <= 3))
					spoken := this.standingsGapToBehindRecognized([], false)
			}
		}

		return spoken
	}

	updateDriver(lastLap, sector, positions) {
		local raceInfo := (this.hasEnoughData(false) && (this.Session = kSessionRace) && (lastLap > 2))
		local hadInfo := false
		local deltaInformation, rnd

		if this.Speaker[false] {
			if (lastLap > 1)
				this.updatePositionInfos(lastLap, sector, positions)

			if (!this.SpotterSpeaking && !this.DriverCar.InPit) {
				this.SpotterSpeaking := true

				try {
					if raceInfo {
						deltaInformation := this.Announcements["DeltaInformation"]

						if ((deltaInformation != "S") && (lastLap >= (this.iLastDeltaInformationLap + deltaInformation)))
							this.iLastDeltaInformationLap := lastLap

						hadInfo := this.deltaInformation(lastLap, sector, positions
													   , (deltaInformation = "S") || (lastLap = this.iLastDeltaInformationLap)
													   , this.Announcements["DeltaInformationMethod"])

						if hadInfo {
							Random rnd, 1, 10

							if (rnd < 5)
								hadInfo := false
						}
					}

					if (!hadInfo && this.Announcements["SessionInformation"])
						hadInfo := this.sessionInformation(lastLap, sector, positions, true)

					if (!hadInfo && raceInfo && this.Announcements["TacticalAdvices"])
						hadInfo := this.tacticalAdvice(lastLap, sector, positions, true)
				}
				finally {
					this.SpotterSpeaking := false
				}
			}
		}
	}

	pendingAlert(alert, match := false) {
		local ignore, candidate

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
		local ignore, alert, candidate

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
		if ((alert = "Hold") && this.pendingAlert("Clear", true))
			return true
		else if ((alert = "Left") && (this.pendingAlerts(["ClearAll", "ClearLeft", "Left", "Three"])))
			return true
		else if ((alert = "Right") && (this.pendingAlerts(["ClearAll", "ClearRight", "Right", "Three"])))
			return true
		else if ((alert = "Three") && this.pendingAlert("Clear", true))
			return true
		else if ((alert = "Side") && this.pendingAlert("Clear", true))
			return true
		else if ((alert = "ClearLeft") && this.pendingAlert("ClearLeft"))
			return true
		else if ((alert = "ClearRight") && this.pendingAlert("ClearRight"))
			return true
		else if (InStr(alert, "Clear") && this.pendingAlerts(["Left", "Right", "Three", "Side", "ClearAll"]))
			return true
		else if (InStr(alert, "Behind") && this.pendingAlerts(["Behind", "Left", "Right", "Three", "Clear"], true))
			return true
		else if (InStr(alert, "Yellow") && this.pendingAlert("YellowClear"))
			return true
		else if ((alert = "YellowClear") && this.pendingAlert("Yellow", true))
			return true

		return false
	}

	superfluousAlert(alert) {
		if (InStr(alert, "Behind") && this.pendingAlerts(["Behind", "Left", "Right", "Three", "Clear"], true))
			return true

		return false
	}

	proximityAlert(alert) {
		local speaker, type, oldPriority, oldAlerting

		static alerting := false

		if (this.Speaker[false] && this.Running) {
			speaker := this.getSpeaker(true)

			if alert {
				if this.superfluousAlert(alert)
					return
				else
					this.iPendingAlerts.Push(alert)

				if (alerting || speaker.isSpeaking()) {
					if (this.iPendingAlerts.Length() == 1)
						Task.startTask(ObjBindMethod(this, "proximityAlert", false), 500, kHighPriority)

					return
				}
			}
			else if (alerting || speaker.isSpeaking())
				if (this.iPendingAlerts.Length() > 0) {
					Task.CurrentTask.Sleep := 200

					return Task.CurrentTask
				}
				else
					return false

			oldPriority := Task.block(kHighPriority)
			oldAlerting := alerting

			alerting := true

			try {
				loop {
					if (this.iPendingAlerts.Length() > 0)
						alert := this.iPendingAlerts.RemoveAt(1)
					else
						break

					if (InStr(alert, "Behind") == 1)
						type := "Behind"
					else
						type := alert

					if (((type != "Behind") && this.Announcements["SideProximity"])
					 || ((type = "Behind") && this.Announcements["RearProximity"])) {
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
				alerting := oldAlerting

				Task.unblock(oldPriority)
			}
		}

		return false
	}

	greenFlag(arguments*) {
		local speaker

		if (this.Speaker[false] && (this.Session = kSessionRace) && this.Running) {
			this.SpotterSpeaking := true

			try {
				speaker := this.getSpeaker(true)

				speaker.speakPhrase("Green", false, false, "Green")
			}
			finally {
				this.SpotterSpeaking := false
			}
		}
	}

	yellowFlag(alert, arguments*) {
		local speaker, sectors

		if (this.Announcements["YellowFlags"] && this.Speaker[false] && this.Running) {
			this.SpotterSpeaking := true

			try {
				speaker := this.getSpeaker(true)
				sectors := string2Values(",", speaker.Fragments["Sectors"])

				switch alert {
					case "All":
						speaker.speakPhrase("YellowAll", false, false, "YellowAll")
					case "Sector":
						if (arguments.Length() > 1)
							speaker.speakPhrase("YellowDistance", {sector: sectors[arguments[1]], distance: arguments[2]})
						else
							speaker.speakPhrase("YellowSector", {sector: sectors[arguments[1]]})
					case "Clear":
						speaker.speakPhrase("YellowClear", false, false, "YellowClear")
					case "Ahead":
						speaker.speakPhrase("YellowAhead", false, false, "YellowAhead")
				}
			}
			finally {
				this.SpotterSpeaking := false
			}
		}
	}

	blueFlag() {
		local positions := this.Positions
		local knowledgeBase := this.KnowledgeBase
		local delta

		if (this.Announcements["BlueFlags"] && this.Speaker[false] && this.Running) {
			this.SpotterSpeaking := true

			try {
				if positions.HasKey("StandingsBehind") {
					delta := Abs(positions[positions["StandingsBehind"]][8])

					if (delta && (delta < 2000))
						this.getSpeaker(true).speakPhrase("BlueForPosition", false, false, "BlueForPosition")
					else
						this.getSpeaker(true).speakPhrase("Blue", false, false, "Blue")
				}
				else
					this.getSpeaker(true).speakPhrase("Blue", false, false, "Blue")
			}
			finally {
				this.SpotterSpeaking := false
			}
		}
	}

	pitWindow(state) {
		if (this.Announcements["PitWindow"] && this.Speaker[false] && (this.Session = kSessionRace) && this.Running) {
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

	startupSpotter(forceShutdown := false) {
		local code, exePath, pid

		if !this.iSpotterPID {
			code := this.SettingsDatabase.getSimulatorCode(this.Simulator)

			exePath := (kBinariesDirectory . code . " SHM Spotter.exe")

			if FileExist(exePath) {
				this.shutdownSpotter(forceShutdown)

				try {
					Run %exePath%, %kBinariesDirectory%, Hide UseErrorLevel, pid
				}
				catch exception {
					logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Spotter (")
															   , {simulator: code, protocol: "SHM"})
										   . exePath . translate(") - please rebuild the applications in the binaries folder (")
										   . kBinariesDirectory . translate(")"))

					showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Spotter (%exePath%) - please check the configuration...")
												  , {exePath: exePath, simulator: code, protocol: "SHM"})
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				}

				if ((ErrorLevel != "Error") && pid)
					this.iSpotterPID := pid
			}
		}

		return false
	}

	shutdownSpotter(force := false) {
		local pid := this.iSpotterPID
		local processName, tries

		if pid {
			Process Close, %pid%

			Sleep 500

			Process Exist, %pid%

			if (force && ErrorLevel) {
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
			}
		}

		this.iSpotterPID := false

		return false
	}

	createSession(settings, data) {
		local facts := base.createSession(settings, data)
		local simulatorName := this.SettingsDatabase.getSimulatorName(facts["Session.Simulator"])
		local configuration := this.Configuration

		facts["Session.Settings.Lap.Learning.Laps"]
			:= getConfigurationValue(configuration, "Race Spotter Analysis", simulatorName . ".LearningLaps", 1)
		facts["Session.Settings.Lap.History.Considered"]
			:= getConfigurationValue(configuration, "Race Spotter Analysis", simulatorName . ".ConsideredHistoryLaps", 5)
		facts["Session.Settings.Lap.History.Damping"]
			:= getConfigurationValue(configuration, "Race Spotter Analysis", simulatorName . ".HistoryLapsDamping", 0.2)

		return facts
	}

	initializeAnnouncements(data) {
		local simulator := getConfigurationValue(data, "Session Data", "Simulator", "Unknown")
		local simulatorName := this.SettingsDatabase.getSimulatorName(simulator)
		local configuration := this.Configuration
		local announcements := {}
		local ignore, key, default

		for ignore, key in ["TacticalAdvices", "SideProximity", "RearProximity", "YellowFlags", "BlueFlags"
						  , "PitWindow", "SessionInformation"]
			announcements[key] := getConfigurationValue(configuration, "Race Spotter Announcements", simulatorName . "." . key, true)

		default := getConfigurationValue(configuration, "Race Spotter Announcements", simulatorName . ".PerformanceUpdates", 2)
		default := getConfigurationValue(configuration, "Race Spotter Announcements", simulatorName . ".DistanceInformation", default)

		announcements["DeltaInformation"] := getConfigurationValue(configuration, "Race Spotter Announcements"
																 , simulatorName . ".DeltaInformation", default)
		announcements["DeltaInformationMethod"] := inList(["Static", "Dynamic", "Both"]
														, getConfigurationValue(configuration, "Race Spotter Announcements"
																			  , simulatorName . ".DeltaInformationMethod", "Both"))

		this.updateConfigurationValues({Announcements: announcements})
	}

	initializeGridPosition(data, force := false) {
		local driver := getConfigurationValue(data, "Position Data", "Driver.Car", false)

		if ((force || !this.GridPosition) && driver && (getConfigurationValue(data, "Stint Data", "Laps", 0) <= 1)) {
			this.iOverallGridPosition := this.getPosition(driver, "Overall", data)
			this.iClassGridPosition := this.getPosition(driver, "Class", data)
		}
	}

	prepareSession(settings, data) {
		local speaker := this.getSpeaker()
		local fragments := speaker.Fragments
		local facts, weather, airTemperature, trackTemperature, weatherNow, weather10Min, weather30Min, driver
		local position, length

		base.prepareSession(settings, data)

		this.iWasStartDriver := true

		this.initializeAnnouncements(data)
		this.initializeGridPosition(data, true)

		facts := this.createSession(settings, data)

		if this.Speaker {
			speaker.beginTalk()

			try {
				speaker.speakPhrase("GreetingIntro")

				airTemperature := Round(getConfigurationValue(data, "Weather Data", "Temperature", 0))
				trackTemperature := Round(getConfigurationValue(data, "Track Data", "Temperature", 0))

				if (airTemperature = 0)
					airTemperature := Round(getConfigurationValue(data, "Car Data", "AirTemperature", 0))

				if (trackTemperature = 0)
					trackTemperature := Round(getConfigurationValue(data, "Car Data", "RoadTemperature", 0))

				weatherNow := getConfigurationValue(data, "Weather Data", "Weather", "Dry")
				weather10Min := getConfigurationValue(data, "Weather Data", "Weather10Min", "Dry")
				weather30Min := getConfigurationValue(data, "Weather Data", "Weather30Min", "Dry")

				if (weatherNow = "Dry") {
					if ((weather10Min = "Dry") || (weather30Min = "Dry"))
						weather := fragments["GreetingDry"]
					else
						weather := fragments["GreetingDry2Wet"]
				}
				else {
					if ((weather10Min = "Dry") || (weather30Min = "Dry"))
						weather := fragments["GreetingWet2Dry"]
					else
						weather := fragments["GreetingWet"]
				}

				speaker.speakPhrase("GreetingWeather", {air: airTemperature, track: trackTemperature, weather: weather})

				if (this.Session = kSessionRace) {
					driver := getConfigurationValue(data, "Position Data", "Driver.Car", false)
					position := this.getPosition(driver, "Overall", data) ; getConfigurationValue(data, "Position Data", "Car." . driver . ".Position")

					if (driver && position)
						speaker.speakPhrase("GreetingPosition"
										  , {position: position, overall: this.MultiClass[data] ? speaker.Fragments["Overall"] : ""})

					if (getConfigurationValue(data, "Session Data", "SessionFormat", "Time") = "Time") {
						length := Round(getConfigurationValue(data, "Session Data", "SessionTimeRemaining", 0) / 60000)

						if (length > 0)
							speaker.speakPhrase("GreetingDuration", {minutes: length})
					}
					else {
						length := this.SessionLaps

						if (length > 0)
							speaker.speakPhrase("GreetingLaps", {laps: length})
					}
				}
			}
			finally {
				speaker.endTalk()
			}

			this.getSpeaker(true)
		}

		Task.startTask(ObjBindMethod(this, "startupSpotter", true), 1000)
		Task.startTask(ObjBindMethod(this, "updateSessionValues", {Running: true}), 25000)
	}

	startSession(settings, data) {
		local facts, joined, simulatorName, configuration, saveSettings

		if this.Debug[kDebugPositions]
			deleteFile(kTempDirectory . "Race Spotter.positions")

		joined := !this.iWasStartDriver

		if !IsObject(settings)
			settings := readConfiguration(settings)

		if !IsObject(data)
			data := readConfiguration(data)

		if joined {
			this.initializeAnnouncements(data)

			if this.Speaker
				this.getSpeaker().speakPhrase("GreetingIntro")
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

		this.iDriverCar := false
		this.OtherCars := {}
		this.PositionInfos := {}
		this.TacticalAdvices := {}
		this.SessionInfos := {}
		this.iLastDeltaInformationLap := 0

		this.initializeGridPosition(data)

		this.startupSpotter()

		if joined
			Task.startTask(ObjBindMethod(this, "updateSessionValues", {Running: true}), 10000)
		else
			this.updateSessionValues({Running: true})

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledgeBase(this.KnowledgeBase)
	}

	finishSession(shutdown := true) {
		local knowledgeBase := this.KnowledgeBase
		local asked

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

					Task.startTask(ObjBindMethod(this, "forceFinishSession"), 120000, kLowPriority)

					return
				}
			}

			this.shutdownSpotter(true)

			this.updateDynamicValues({KnowledgeBase: false})
		}

		this.updateDynamicValues({OverallTime: 0, BestLapTime: 0, LastFuelAmount: 0, InitialFuelAmount: 0, EnoughData: false})
		this.updateSessionValues({Simulator: "", Session: kSessionFinished, SessionTime: false})
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

	prepareData(lapNumber, data) {
		local knowledgeBase, key, value

		data := base.prepareData(lapNumber, data)

		knowledgeBase := this.KnowledgeBase

		for key, value in getConfigurationSectionValues(data, "Position Data", Object())
			knowledgeBase.setFact(key, value)

		return data
	}

	addLap(lapNumber, data) {
		local result := base.addLap(lapNumber, data)
		local knowledgeBase := this.KnowledgeBase
		local gapAhead, gapBehind, validLaps, lap, lastPitstop

		if !this.MultiClass {
			gapAhead := getConfigurationValue(data, "Stint Data", "GapAhead", kUndefined)
			gapBehind := getConfigurationValue(data, "Stint Data", "GapBehind", kUndefined)

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

		loop % knowledgeBase.getValue("Car.Count")
		{
			validLaps := knowledgeBase.getValue("Car." . A_Index . ".Valid.Laps", 0)
			lap := knowledgeBase.getValue("Car." . A_Index . ".Lap", 0)

			if (lap != knowledgeBase.getValue("Car." . A_Index . ".Valid.LastLap", 0)) {
				knowledgeBase.setFact("Car." . A_Index . ".Valid.LastLap", lap)

				if knowledgeBase.getValue("Car." . A_Index . ".Lap.Valid", true)
					knowledgeBase.setFact("Car." . A_Index . ".Valid.Laps", validLaps +  1)
			}
		}

		lastPitstop := knowledgeBase.getValue("Pitstop.Last", false)

		if (lastPitstop && (Abs(lapNumber - lastPitstop) <= 2)) {
			this.PositionInfos := {}
			this.TacticalAdvices := {}
			this.SessionInfos := {}
			this.iLastDeltaInformationLap := 0
		}

		this.initializeGridPosition(data)

		return result
	}

	updateLap(lapNumber, data) {
		local knowledgeBase := this.KnowledgeBase
		local update, sector, gapAhead, gapBehind, result

		static lastSector := 1

		update := false

		if !IsObject(data)
			data := readConfiguration(data)

		sector := getConfigurationValue(data, "Stint Data", "Sector", 0)

		if (sector != lastSector) {
			lastSector := sector

			update := true

			knowledgeBase.addFact("Sector", sector)
		}

		if this.MultiClass {
			gapAhead := kUndefined
			gapBehind := kUndefined
		}
		else {
			gapAhead := getConfigurationValue(data, "Stint Data", "GapAhead", kUndefined)
			gapBehind := getConfigurationValue(data, "Stint Data", "GapBehind", kUndefined)
		}

		if update {
			this.iPositions := this.computePositions(data, (gapAhead != kUndefined) ? gapAhead : false
														 , (gapBehind != kUndefined) ? gapBehind : false)

			this.updateDriver(lapNumber, sector, this.Positions)
		}

		result := base.updateLap(lapNumber, data)

		if (gapAhead != kUndefined) {
			knowledgeBase.setFact("Position.Standings.Class.Ahead.Delta", gapAhead)

			if (knowledgeBase.getValue("Position.Track.Ahead.Car", -1) = knowledgeBase.getValue("Position.Standings.Class.Ahead.Car", 0))
				knowledgeBase.setFact("Position.Track.Ahead.Delta", gapAhead)
		}

		if (gapBehind != kUndefined) {
			knowledgeBase.setFact("Position.Standings.Class.Behind.Delta", gapBehind)

			if (knowledgeBase.getValue("Position.Track.Behind.Car", -1) = knowledgeBase.getValue("Position.Standings.Class.Behind.Car", 0))
				knowledgeBase.setFact("Position.Track.Behind.Delta", gapBehind)
		}

		return result
	}

	computePositions(data, gapAhead, gapBehind) {
		local knowledgeBase := this.KnowledgeBase
		local carPositions := []
		local driver := getConfigurationValue(data, "Position Data", "Driver.Car", 0)
		local count := getConfigurationValue(data, "Position Data", "Car.Count", 0)
		local notAlone := (count > 1)
		local carPositions := []
		local positions := {}
		local trackAhead := false
		local trackBehind := false
		local standingsAhead := false
		local standingsBehind := false
		local leader := false
		local hasDriver := false
		local index, car, prefix, lapTime, driverLaps, driverRunning, carIndex, carLaps, carRunning
		local driverClassPosition, carOverallPosition, carClassPosition, carDelta, carAheadDelta, carBehindDelta
		local classes, class, carClassPositions, ignore

		if (driver && count) {
			classes := {}
			carClassPositions := []

			loop %count%
			{
				class := this.getClass(A_Index, data) ; getConfigurationValue(data, "Position Data", "Car." . A_Index . ".Class", "Unknown")

				if !classes.HasKey(class)
					classes[class] := [Array(A_Index, this.getPosition(A_Index, "Overall", data))]
				else
					classes[class].Push(Array(A_Index, this.getPosition(A_Index, "Overall", data)))

				carClassPositions.Push(false)
			}

			for ignore, class in classes {
				bubbleSort(class, "compareClassPositions")

				for carClassPosition, car in class
					carClassPositions[car[1]] := carClassPosition
			}

			loop %count%
			{
				carLaps := getConfigurationValue(data, "Position Data", "Car." . A_Index . ".Lap")
				carRunning := getConfigurationValue(data, "Position Data", "Car." . A_Index . ".Lap.Running")

				if (A_Index = driver) {
					hasDriver := true

					driverLaps := carLaps
					driverRunning := carRunning
				}

				carPositions.Push(Array(A_Index, carLaps, carRunning))
			}

			if hasDriver {
				bubbleSort(carPositions, "trackOrder")

				positions["Driver"] := driver
				positions["Count"] := count

				driverClassPosition := carClassPositions[driver]
				class := this.getClass(driver, data)
				lapTime := getConfigurationValue(data, "Position Data", "Car." . driver . ".Time")

				for index, car in carPositions {
					carIndex := car[1]
					carLaps := car[2]
					carRunning := car[3]

					prefix := ("Car." . carIndex)

					carOverallPosition := this.getPosition(carIndex, "Overall", data) ; getConfigurationValue(data, "Position Data", prefix . ".Position")
					carClassPosition := carClassPositions[carIndex]
					carDelta := (((carLaps + carRunning) - (driverLaps + driverRunning)) * lapTime)

					if (driverRunning < carRunning) {
						carAheadDelta := ((carRunning - driverRunning) * lapTime)
						carBehindDelta := ((1 - carRunning + driverRunning) * lapTime * -1)
					}
					else {
						carAheadDelta := ((1 - driverRunning + carRunning) * lapTime)
						carBehindDelta := ((driverRunning - carRunning) * lapTime * -1)
					}

					positions[carIndex] := Array(getConfigurationValue(data, "Position Data", prefix . ".Nr")
											   , getConfigurationValue(data, "Position Data", prefix . ".Car", "Unknown")
											   , this.getClass(carIndex, data) ; getConfigurationValue(data, "Position Data", prefix . ".Class", kUnknown)
											   , computeDriverName(getConfigurationValue(data, "Position Data", prefix . ".Driver.Forname", "John")
																 , getConfigurationValue(data, "Position Data", prefix . ".Driver.Surname", "Doe")
																 , getConfigurationValue(data, "Position Data", prefix . ".Driver.Nickname", "JD"))
											   , carOverallPosition, carClassPosition
											   , carLaps, carRunning
											   , getConfigurationValue(data, "Position Data", prefix . ".Time")
											   , carDelta, carAheadDelta, carBehindDelta
											   , getConfigurationValue(data, "Position Data", prefix . ".Lap.Valid", true)
											   , knowledgeBase.getValue(prefix . ".Valid.Laps", carLaps)
											   , getConfigurationValue(data, "Position Data", prefix . ".Incidents", 0)
											   , getConfigurationValue(data, "Position Data", prefix . ".InPitlane", false))

					if (class = this.getClass(carIndex, data)) {
						if (carClassPosition = 1)
							leader := carIndex

						if (carClassPosition = (driverClassPosition - 1))
							standingsAhead := carIndex
						else if (carClassPosition = (driverClassPosition + 1))
							standingsBehind := carIndex
					}

					if (carIndex = driver) {
						if (index = count) {
							trackAhead := (notAlone ? index - 1 : false)
							trackBehind := (notAlone ? 1 : false)
						}
						else if (index = 1) {
							trackAhead := (notAlone ? count : false)
							trackBehind := (notAlone ? 2 : false)
						}
						else {
							trackAhead := (index - 1)
							trackBehind := (index + 1)
						}
					}
				}

				trackAhead := carPositions[trackAhead][1]
				trackBehind := carPositions[trackBehind][1]

				if (gapAhead && standingsAhead) {
					positions[standingsAhead][8] := gapAhead

					if (standingsAhead = trackAhead)
						positions[trackAhead][8] := gapAhead
				}

				if (gapBehind && standingsBehind) {
					positions[standingsBehind][8] := gapBehind

					if (standingsBehind = trackBehind)
						positions[trackBehind][8] := gapBehind
				}

				positions["Position.Overall"] := this.getPosition(driver, "Overall", data) ; getConfigurationValue(data, "Position Data", "Car." . driver . ".Position")
				positions["Position.Class"] := driverClassPosition
				positions["Leader"] := leader
				positions["StandingsAhead"] := standingsAhead
				positions["StandingsBehind"] := standingsBehind
				positions["TrackAhead"] := trackAhead
				positions["TrackBehind"] := trackBehind
			}
		}

		return positions
	}

	executePitstop(lapNumber) {
		this.PositionInfos := {}
		this.TacticalAdvices := {}
		this.SessionInfos := {}
		this.iLastDeltaInformationLap := 0

		return base.executePitstop(lapNumber)
	}

	requestInformation(category, arguments*) {
		switch category {
			case "Time":
				this.timeRecognized([])
			case "Position":
				this.positionRecognized([])
			case "LapTimes":
				this.lapTimesRecognized([])
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


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

getTime() {
	return A_Now
}

trackOrder(a, b) {
	return (a[3] < b[3])
}