﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AI Race Spotter                 ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Global Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Extensions\Task.ahk"
#Include "..\..\Framework\Extensions\Math.ahk"
#Include "..\..\Framework\Extensions\RuleEngine.ahk"
#Include "..\..\Framework\Extensions\LLMConnector.ahk"
#Include "RaceAssistant.ahk"


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

class SpotterEvent extends AssistantEvent {
	Asynchronous {
		Get {
			return true
		}
	}
}

class AheadGapUpdateEvent extends SpotterEvent {
	createTrigger(event, phrase, arguments) {
		return ("The gap to the car number " . Round(arguments[1]) . " ahead got " . (arguments[3] ? "smaller" : "larger") . " It is now " . Round(arguments[2], 1) . " seconds.")
	}
}

class BehindGapUpdateEvent extends SpotterEvent {
	createTrigger(event, phrase, arguments) {
		return ("The gap to the car number " . Round(arguments[1]) . " behind got " . (arguments[3] ? "smaller" : "larger") . " It is now " . Round(arguments[2], 1) . " seconds.")
	}
}

class AttackImminentEvent extends SpotterEvent {
	createTrigger(event, phrase, arguments) {
		return ("An opponent has closed in and an attack might happen soon. The gap to car number " . Round(arguments[1]) . " is only " . Round(arguments[2], 1) . " seconds.")
	}
}

class BlueFlagAlertEvent extends SpotterEvent {
	createTrigger(event, phrase, arguments) {
		return "The blue flag is shown, because an opponent is closing in who is at least one lap ahead."
	}
}

class StintEndingEvent extends SpotterEvent {
	createTrigger(event, phrase, arguments) {
		if (arguments.Length > 0)
			return ("The current stint is ending in " . arguments[1] . " laps.")
		else
			return "The current stint is ending in a few laps."
	}
}

class LastLapEvent extends SpotterEvent {
	createTrigger(event, phrase, arguments) {
		return "The car is on the last lap of the session."
	}
}

class SessionOverEvent extends SpotterEvent {
	createTrigger(event, phrase, arguments) {
		return "The car has seen the checkered flag and the session is over."
	}
}

class OpponentPittingEvent extends SpotterEvent {
	createTrigger(event, phrase, arguments) {
		if (arguments.Length > 0)
			if (arguments[1] = "Ahead")
				return "The opponent ahead is pitting."
			else if (arguments[1] = "Behind")
				return "The opponent behind is pitting."

		return "An opponent is pitting."
	}
}

class CarInfo {
	iSpotter := false

	iID := false
	iNr := false
	iCar := false
	iDriver := false
	iClass := false

	iLastLap := false
	iLastSector := false

	iOverallPosition := false
	iClassPosition := false

	iInPit := false

	iLapTimes := []
	iSectorTimes := [[], [], []]
	iBestLapTime := false

	iDeltas := CaseInsenseMap()
	iLastDeltas := CaseInsenseMap()

	iTrackAheadDelta := false
	iTrackBehindDelta := false

	iValid := true
	iInvalidLaps := 0
	iIncidents := 0

	iProblem := false

	Spotter {
		Get {
			return this.iSpotter
		}
	}

	ID {
		Get {
			return this.iID
		}
	}

	Nr {
		Get {
			return this.iNr
		}
	}

	Car {
		Get {
			return this.iCar
		}
	}

	Driver {
		Get {
			return this.iDriver
		}
	}

	Class {
		Get {
			return this.iClass
		}
	}

	BestLapTime {
		Get {
			return this.iBestLapTime
		}
	}

	LastLap {
		Get {
			return this.iLastLap
		}
	}

	Position[type := "Overall"] {
		Get {
			return ((type = "Overall") ? this.iOverallPosition : this.iClassPosition)
		}
	}

	Pitstops[key?] {
		Get {
			local pitstops := this.Spotter.Pitstops[this.ID]

			return (isSet(key) ? pitstops[key] : pitstops)
		}
	}

	InPit {
		Get {
			return this.iInPit
		}
	}

	LapTimes[key?] {
		Get {
			return (isSet(key) ? this.iLapTimes[key] : this.iLapTimes)
		}

		Set {
			return (isSet(key) ? (this.iLapTimes[key] := value) : (this.iLapTimes := value))
		}
	}

	SectorTimes[sector?] {
		Get {
			return (isSet(sector) ? this.iSectorTimes[sector] : this.iSectorTimes)
		}

		Set {
			return (isSet(sector) ? (this.iSectorTimes[sector] := value) : (this.iSectorTimes := value))
		}
	}

	LastLapTime {
		Get {
			local numLapTimes := this.LapTimes.Length

			if (numLapTimes > 0)
				return this.LapTimes[numLapTimes]
			else
				return false
		}
	}

	LastSectorTime[sector] {
		Get {
			local numSectorTimes := this.SectorTimes[sector].Length

			if (numSectorTimes > 0)
				return this.SectorTimes[numSectorTimes]
			else
				return false
		}
	}

	AvgLapTime[weighted := false, count := 3] {
		Get {
			local lapTimes := []
			local numLapTimes := this.LapTimes.Length
			local lapTime

			if weighted {
				loop Min(count, numLapTimes) {
					lapTime := this.LapTimes[numLapTimes - A_Index + 1]

					if (A_Index = numLapTimes)
						lapTimes.Push(lapTime)

					lapTimes.Push(lapTime)
				}
			}
			else
				loop Min(count, numLapTimes)
					lapTimes.Push(this.LapTimes[numLapTimes - A_Index + 1])

			return Round(average(lapTimes), 1)
		}
	}

	AvgSectorTime[sector, weighted := false, count := 3] {
		Get {
			local sectorTimes := []
			local numSectorTimes := this.SectorTimes[sector].Length
			local sectorTime

			if weighted {
				loop Min(count, numSectorTimes) {
					sectorTime := this.SectorTimes[sector][numSectorTimes - A_Index + 1]

					if (A_Index = numSectorTimes)
						sectorTimes.Push(sectorTime)

					sectorTimes.Push(sectorTime)
				}
			}
			else
				loop Min(count, numSectorTimes)
					sectorTimes.Push(this.SectorTimes[sector][numSectorTimes - A_Index + 1])

			return Round(average(sectorTimes), 1)
		}
	}

	LapTime[average := false, weighted := false] {
		Get {
			return (average ? this.AvgLapTime[weighted] : this.LastLapTime)
		}
	}

	SectorTime[sector, average := false, weighted := false] {
		Get {
			return (average ? this.AvgSectorTime[sector, weighted] : this.LastSectorTime)
		}
	}

	Deltas[sector := false, key?] {
		Get {
			if sector {
				if this.iDeltas.Has(sector)
					return (isSet(key) ? this.iDeltas[sector][key] : this.iDeltas[sector])
				else
					return []
			}
			else
				return this.iDeltas
		}
	}

	LastDelta[sector := false] {
		Get {
			local lastSector := 0
			local lastDelta := false
			local delta

			if this.iLastDeltas.Has(sector)
				return this.iLastDeltas[sector]
			else {
				for sector, delta in this.iLastDeltas
					if (sector > lastSector) {
						lastSector := sector
						lastDelta := delta
					}

				return lastDelta
			}
		}
	}

	TrackAheadDelta {
		Get {
			return this.iTrackAheadDelta
		}
	}

	TrackBehindDelta {
		Get {
			return this.iTrackBehindDelta
		}
	}

	AvgDelta[sector, count := 3] {
		Get {
			local deltas := []
			local numDeltas, ignore, sDeltas

			if sector {
				numDeltas := this.Deltas[sector].Length

				loop Min(count, numDeltas)
					deltas.Push(this.Deltas[sector][numDeltas - A_Index + 1])
			}
			else
				for ignore, sDeltas in this.Deltas {
					numDeltas := sDeltas.Length

					loop Min(count, numDeltas)
						deltas.Push(sDeltas[numDeltas - A_Index + 1])
				}

			return Round(average(deltas), 1)
		}
	}

	Delta[sector, average := false, count := 3] {
		Get {
			return (average ? this.AvgDelta[sector, count] : this.LastDelta[sector])
		}
	}

	Valid {
		Get {
			return this.iValid
		}
	}

	InvalidLaps {
		Get {
			return this.iInvalidLaps
		}
	}

	Incidents {
		Get {
			return this.iIncidents
		}
	}

	Problem {
		Get {
			return this.iProblem
		}
	}

	__New(spotter, id, nr, car, class) {
		this.iSpotter := spotter
		this.iID := id
		this.iNr := nr
		this.iCar := car
		this.iClass := class
	}

	reset(full := false) {
		this.iDeltas := CaseInsenseMap()
		this.iLastDeltas := CaseInsenseMap()

		if full {
			iLapTimes := []
			iSectorTimes := [[], [], []]
			iBestLapTime := false
		}
	}

	hasPitted(lap) {
		local ignore, pitstop, pitstopLap

		for ignore, pitstop in this.Pitstops {
			pitstopLap := pitstop.Lap

			if ((lap = pitstopLap) || ((lap - 1) = pitstopLap) || ((lap - 2) = pitstopLap))
				return true
		}

		return false
	}

	update(driver, overallPosition, classPosition, lastLap, sector, lapTime, sectorTimes
		 , delta, trackAheadDelta, trackBehindDelta
		 , validLap, invalid, invalidLaps, incidents, inPit) {
		local avgLapTime := this.AvgLapTime
		local pitted := (inPit || this.hasPitted(lastLap))
		local valid := true
		local deltas, index, sectorTime

		this.iProblem := false

		if ((lapTime && avgLapTime && (Abs((lapTime - avgLapTime) / avgLapTime) > 0.03)) || pitted) {
			this.reset()

			if (!pitted && (lapTime > avgLapTime))
				this.iProblem := true

			valid := false
		}

		if ((lastLap != this.LastLap) && (lapTime > 0) && !pitted) {
			this.LapTimes.Push(lapTime)

			if (this.LapTimes.Length > 5)
				this.LapTimes.RemoveAt(1)

			if (validLap && (!this.BestLapTime || (lapTime < this.BestLapTime)))
				this.iBestLapTime := lapTime

			if sectorTimes
				for index, sectorTime in sectorTimes
					if ((index <= 3) && isNumber(sectorTime) && (sectorTime > 0)) {
						this.SectorTimes[index].Push(sectorTime)

						if (this.SectorTimes[index].Length > 5)
							this.SectorTimes[index].RemoveAt(1)
					}
					else
						break
		}

		this.iDriver := driver
		this.iOverallPosition := overallPosition
		this.iClassPosition := classPosition
		this.iLastLap := lastLap
		this.iValid := !invalid
		this.iInvalidLaps := invalidLaps
		this.iIncidents := incidents

		if (sector != this.iLastSector) {
			this.iLastSector := sector

			if this.iDeltas.Has(sector)
				deltas := this.iDeltas[sector]
			else {
				deltas := []

				this.iDeltas[sector] := deltas
			}

			deltas.Push(delta)

			if (deltas.Length > 5)
				deltas.RemoveAt(1)

			this.iLastDeltas[sector] := delta
			this.iLastDeltas[false] := delta

			this.iTrackAheadDelta := trackAheadDelta
			this.iTrackBehindDelta := trackBehindDelta
		}

		this.iInPit := inPit

		return valid
	}

	hasLapTime() {
		return (this.LapTimes.Length > 0)
	}

	hasDelta(sector := false) {
		if sector
			return (this.Deltas[sector].Length > 0)
		else
			return (this.Deltas.Count > 0)
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

		linRegression(xValues, yValues, &a, &b)

		return (b > 0)
	}
}

class PositionInfo {
	iSpotter := false
	iCar := false

	iBaseLap := false
	iObserved := ""

	iInitialLaps := CaseInsenseMap()
	iInitialDeltas := CaseInsenseMap()

	iReported := false

	iBestLapTime := false

	Type {
		Get {
			throw "Virtual property PositionInfo.Type must be implemented in a subclass..."
		}
	}

	Spotter {
		Get {
			return this.iSpotter
		}
	}

	Car {
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

	Observed {
		Get {
			return this.iObserved
		}
	}

	InitialLap[sector] {
		Get {
			return (this.iInitialLaps.Has(sector) ? this.iInitialLaps[sector] : false)
		}
	}

	InitialDelta[sector] {
		Get {
			local delta

			if this.iInitialDeltas.Has(sector)
				return this.iInitialDeltas[sector]
			else {
				delta := this.Delta[sector]

				this.iInitialLaps[sector] := this.Car.LastLap
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

	LapDifference[sector] {
		Get {
			local initialLap := this.InitialLap[sector]

			return (initialLap ? (this.Car.LastLap - initialLap) : false)
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

	LastLapTime {
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

	Reported {
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
		return (Round(this.BestLapTime, 2) != Round(this.Car.BestLapTime, 2))
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

	isFaster(sector, percentage := false) {
		local difference := this.LapTimeDifference[true]

		if (difference > 0)
			return (percentage ? (difference > (this.Spotter.DriverCar.AvgLapTime / 100 * percentage)) : true)
		else
			return false
	}

	isSlower(sector, percentage := false) {
		return !this.isFaster(sector, percentage)
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

			return (frontCar ? (this.Car.ID = positions[frontCar][17]) : false)
		}
	}

	atBehind(standings := true) {
		local positions := this.Spotter.Positions
		local behindCar

		if standings
			return (this.Car.Position["Overall"] > positions["Position.Overall"])
		else {
			behindCar := positions["TrackBehind"]

			return (behindCar ? (this.Car.ID = positions[behindCar][17]) : false)
		}
	}

	forPosition() {
		local spotter := this.Spotter
		local car := this.Car
		local positions := spotter.Positions
		local position := positions["Position.Class"]
		local carPosition := car.Position["Class"]

		if ((car.Class = spotter.DriverCar.Class) && isNumber(position) && isNumber(carPosition)) {
			if ((position - carPosition) == 1)
				return "Ahead"
			else if ((position - carPosition) == -1)
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

		this.iInitialLaps := CaseInsenseMap()
		this.iInitialDeltas := CaseInsenseMap()

		if !full {
			this.iInitialLaps[sector] := this.Car.LastLap
			this.iInitialDeltas[sector] := this.Delta[sector]
		}
	}

	rebase(sector) {
		local lastLap := this.Car.LastLap

		if (lastLap >= (this.iBaseLap + 3))
			this.reset(sector, true)
		else {
			this.iInitialLaps[sector] := lastLap
			this.iInitialDeltas[sector] := this.Delta[sector]
		}
	}

	checkpoint(sector) {
		local position := this.forPosition()
		local standingsAhead := (position = "Ahead")
		local standingsBehind := (position = "Behind")
		local trackAhead := this.inFront(false)
		local trackBehind := this.atBehind(false)
		local oldObserved := this.Observed
		local newObserved := ((this.isLeader() ? "L" : "") . (trackAhead ? "TA" : "") . (trackBehind ? "TB" : "")
							. (standingsAhead ? "SA" : "") . (standingsBehind ? "SB" : "")
							. ((this == this.Spotter.FocusedCar[true]) ? "F" : ""))

		if this.Car.InPit {
			if !InStr(this.iObserved, "P")
				this.iObserved .= "P"

			this.reset(sector, true, true)
		}
		else {
			this.iObserved := newObserved

			if this.Spotter.DriverCar.InPit
				this.reset(sector, true, true)
			else if (!(InStr(newObserved, "SA") && InStr(oldObserved, "SA"))
				 && !(InStr(newObserved, "SB") && InStr(oldObserved, "SB"))
				 && !(InStr(newObserved, "F") && InStr(oldObserved, "F")))
				if (newObserved != oldObserved)
					this.reset(sector, true, true)
				else if ((newObserved = "") || (newObserved = "L"))
					this.rebase(sector)
		}
	}
}

class RaceSpotter extends GridRaceAssistant {
	iSpotterPID := false
	iRunning := false
	iEnabled := true

	iSessionDataActive := false

	iDriverUpdateTime := 0
	iNextDriverUpdate := 0

	iLastDeltaInformationLap := 0
	iPositionInfos := CaseInsenseMap()
	iTacticalAdvices := CaseInsenseMap()
	iSessionInfos := CaseInsenseMap()

	iDriverCar := false
	iOtherCars := CaseInsenseMap()
	iPositions := CaseInsenseWeakMap()

	iFocusedCar := kUndefined

	iFinalLap := false

	iPendingAlerts := []
	iAlertProcessing := false

	iLastPenalty := false

	iBestTopSpeed := false
	iLastTopSpeed := false

	iPrivateSession := false

	class SpotterVoiceManager extends RaceAssistant.RaceVoiceManager {
		iFastSpeechSynthesizer := false

		class FastSpeaker extends VoiceManager.LocalSpeaker {
			iIsBoostable := false
			iIsSpeaking := false
			iSpotter := false

			Spotter {
				Get {
					return this.iSpotter
				}
			}

			Booster {
				Get {
					return (this.iIsBoostable ? super.Booster : false)
				}
			}

			Speaking {
				Get {
					return (this.iIsSpeaking || super.Speaking)
				}

				Set {
					return (this.iIsSpeaking := value)
				}
			}

			speak(text, focus := false, cache := false, options := false) {
				local oldBoostable := this.iIsBoostable
				local oldSpeaking := this.iIsSpeaking

				if (this.VoiceManager.RaceAssistant.Session >= kSessionPractice) {
					this.iIsBoostable := !cache
					this.iIsSpeaking := true

					try {
						super.speak(text, focus, cache, options)
					}
					finally {
						this.iIsSpeaking := oldSpeaking
						this.iIsBoostable := oldBoostable
					}
				}
			}

			speakPhrase(phrase, arguments*) {
				local assistant := this.VoiceManager.RaceAssistant

				if assistant.skipAlert(phrase) {
					assistant.cleanupAlerts(phrase)

					return
				}

				if this.Awaitable {
					this.wait()

					if assistant.skipAlert(phrase) {
						assistant.cleanupAlerts(phrase)

						return
					}
				}

				super.speakPhrase(phrase, arguments*)
			}

			__New(voiceManager, synthesizer, speaker, language, fragments, phrases) {
				this.iSpotter := voiceManager.RaceAssistant

				super.__New(voiceManager, synthesizer, speaker, language, fragments, phrases)
			}
		}

		getSpeaker(fast := false) {
			local synthesizer

			if fast {
				if !this.iFastSpeechSynthesizer {
					synthesizer := RaceSpotter.SpotterVoiceManager.FastSpeaker(this, this.Synthesizer, this.Speaker, this.Language
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
				return super.getSpeaker()
		}

		updateSpeechStatus(status) {
			if (status = "Start")
				this.mute()
			else if (status = "Stop")
				this.unmute()
		}

		buildPhrases(language, fast := false) {
			if fast
				return super.buildPhrases(language, "Spotter Phrases")
			else
				return super.buildPhrases(language)
		}
	}

	class RaceSpotterRemoteHandler extends RaceAssistant.RaceAssistantRemoteHandler {
		__New(remotePID) {
			super.__New("Race Spotter", remotePID)
		}
	}

	Running {
		Get {
			return this.iRunning
		}
	}

	Enabled {
		Get {
			return this.iEnabled
		}
	}

	SessionDataActive {
		Get {
			return this.iSessionDataActive
		}
	}

	DriverCar {
		Get {
			return this.iDriverCar
		}
	}

	OtherCars[key?] {
		Get {
			return (isSet(key) ? this.iOtherCars[key] : this.iOtherCars)
		}

		Set {
			return (isSet(key) ? (this.iOtherCars[key] := value) : (this.iOtherCars := value))
		}
	}

	FocusedCar[position := false] {
		Get {
			local ignore, candidate

			if isInstance(this.iFocusedCar, PositionInfo)
				return (position ? this.iFocusedCar : this.iFocusedCar.Car.Nr)
			else {
				for ignore, candidate in this.PositionInfos
					if (candidate.Car.Nr = this.iFocusedCar) {
						this.FocusedCar := candidate

						return (position ? candidate : candidate.Car.Nr)
					}

				return false
			}
		}

		Set {
			return (this.iFocusedCar := value)
		}
	}

	Positions[key?] {
		Get {
			return (isSet(key) ? this.iPositions[key] : this.iPositions)
		}
	}

	PositionInfos[key?] {
		Get {
			return (isSet(key) ? this.iPositionInfos[key] : this.iPositionInfos)
		}

		Set {
			return (isSet(key) ? (this.iPositionInfos[key] := value) : (this.iPositionInfos := value))
		}
	}

	DriverUpdateTime {
		Get {
			return this.iDriverUpdateTime
		}
	}

	TacticalAdvices[key?] {
		Get {
			return (isSet(key) ? this.iTacticalAdvices[key] : this.iTacticalAdvices)
		}

		Set {
			return (isSet(key) ? (this.iTacticalAdvices[key] := value) : (this.iTacticalAdvices := value))
		}
	}

	SessionInfos[key?] {
		Get {
			return (isSet(key) ? this.iSessionInfos[key] : this.iSessionInfos)
		}

		Set {
			return (isSet(key) ? (this.iSessionInfos[key] := value) : (this.iSessionInfos := value))
		}
	}

	BestTopSpeed {
		Get {
			return this.iBestTopSpeed
		}
	}

	LastTopSpeed {
		Get {
			return this.iLastTopSpeed
		}
	}

	FinalLap {
		Get {
			return this.iFinalLap
		}
	}

	PrivateSession {
		Get {
			return this.iPrivateSession
		}
	}

	__New(configuration, remoteHandler, name := false, language := kUndefined
		, synthesizer := false, speaker := false, vocalics := false, speakerBooster := false
		, recognizer := false, listener := false, listenerBooster := false, conversationBooster := false, agentBooster := false
		, muted := false, voiceServer := false) {
		super.__New(configuration, "Race Spotter", remoteHandler, name, language, synthesizer, speaker, vocalics, speakerBooster
												 , recognizer, listener, listenerBooster, conversationBooster, agentBooster
												 , muted, voiceServer)

		this.updateConfigurationValues({Announcements: {DeltaInformation: 2, TacticalAdvices: true
													  , SideProximity: true, RearProximity: true
													  , YellowFlags: true, BlueFlags: true, PitWindow: true
													  , SlowCars: true, AccidentsAhead: true, AccidentsBehind: true
													  , SessionInformation: true, CutWarnings: true, PenaltyInformation: true}})

		OnExit(ObjBindMethod(this, "shutdownSpotter", true))
	}

	setDebug(option, enabled, *) {
		local label := false

		super.setDebug(option, enabled)

		switch option {
			case kDebugPositions:
				label := translate("Debug Positions")
		}

		try {
			if label
				if enabled
					SupportMenu.Check(label)
				else
					SupportMenu.Uncheck(label)
		}
		catch Any as exception {
			logError(exception, false, false)
		}
	}

	createVoiceManager(name, options) {
		return RaceSpotter.SpotterVoiceManager(this, name, options)
	}

	updateConfigurationValues(values) {
		super.updateConfigurationValues(values)

		if values.HasProp("DriverUpdateTime")
			this.iDriverUpdateTime := values.DriverUpdateTime

		if values.HasProp("PrivateSession")
			this.iPrivateSession := values.PrivateSession
	}

	updateSessionValues(values) {
		super.updateSessionValues(values)

		if values.HasProp("Running")
			this.iRunning := values.Running

		if (values.HasProp("Session") && (values.Session == kSessionFinished)) {
			this.iRunning := false
			this.iFinalLap := false
			this.iEnabled := true

			this.initializeHistory()
		}
	}

	updateDynamicValues(values) {
		if (values.HasProp("BaseLap") && (values.BaseLap != this.BaseLap))
			if this.SessionInfos.Has("AirTemperature")
				this.SessionInfos.Delete("AirTemperature")

		if values.HasProp("Enabled")
			this.iEnabled := values.Enabled

		super.updateDynamicValues(values)
	}

	getClass(car := false, data := false, categories?) {
		static spotterCategories := false

		if isSet(categories)
			return super.getClass(car, data, categories)
		else {
			if !spotterCategories
				switch getMultiMapValue(this.Settings, "Assistant.Spotter", "CarCategories", "Classes"), false {
					case "All":
						spotterCategories := ["Class", "Cup"]
					case "Classes":
						spotterCategories := ["Class"]
					case "Cups":
						spotterCategories := ["Cup"]
					default:
						strategistCategories := ["Class"]
				}

			return super.getClass(car, data, spotterCategories)
		}
	}

	getCarIndicatorFragment(speaker, number, position) {
		local indicator := getMultiMapValue(this.Settings, "Assistant.Spotter", "CarIndicator", "Position")

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
			case "FocusCar":
				this.focusCarRecognized(words)
			case "NoFocusCar":
				this.noFocusCarRecognized(words)
			default:
				super.handleVoiceCommand(grammar, words)
		}
	}

	resetDeltasAction() {
		local ignore, positionInfo

		for ignore, positionInfo in this.PositionInfos {
			positionInfo.reset(true, true, true)
			positionInfo.Car.reset(true)
		}

		this.DriverCar.reset(true)

		if this.Speaker
			this.getSpeaker().speakPhrase("Okay")
	}

	focusCarRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local validCar := false
		local number, numbers, ignore, carInfo, candidate, fragment

		if !this.hasEnoughData()
			return

		numbers := []

		for ignore, candidate in words {
			if (InStr(candidate, "#") == 1)
				candidate := SubStr(candidate, 2)

			if this.isInteger(candidate, &candidate)
				numbers.Push(candidate)
			else if (numbers.Length > 0)
				break
		}

		if (numbers.Length > 0) {
			number := ""

			for ignore, fragment in numbers
				number .= fragment

			number := Integer(number)
		}
		else
			number := false

		if number
			for ignore, carInfo in this.OtherCars
				if (carInfo.Nr = number) {
					validCar := true

					break
				}

		if (number && validCar) {
			if this.Listener {
				speaker.speakPhrase("ConfirmFocusCar", {number: number}, true)

				this.setContinuation(VoiceManager.ReplyContinuation(this, ObjBindMethod(this, "updateFocusCar", number), "Roger", "Okay"))
			}
			else
				this.updateFocusCar(number)

			return
		}
		else if number
			speaker.speakPhrase("NoFocusCar", {number: number})
		else
			speaker.speakPhrase("Repeat")
	}

	noFocusCarRecognized(words) {
		this.getSpeaker().speakPhrase("Roger")

		this.FocusedCar := kUndefined
	}

	updateFocusCar(number) {
		this.FocusedCar := number
	}

	updateAnnouncement(announcement, value) {
		if (value && (announcement = "DeltaInformation")) {
			value := getMultiMapValue(this.Configuration, "Race Spotter Announcements", this.Simulator . ".PerformanceUpdates", 2)
			value := getMultiMapValue(this.Configuration, "Race Spotter Announcements", this.Simulator . ".DistanceInformation", value)
			value := getMultiMapValue(this.Configuration, "Race Spotter Announcements", this.Simulator . ".DeltaInformation", value)

			if !value
				value := 2
		}

		super.updateAnnouncement(announcement, value)
	}

	getSpeaker(fast := false) {
		return this.VoiceManager.getSpeaker(fast)
	}

	updateCarInfos(lastLap, sector, positions) {
		local knowledgeBase := this.KnowledgeBase
		local activeCars := CaseInsenseMap()
		local driver, otherCars, car, carNr, cInfo, carLaps

		cleanup(otherCars, activeCars) {
			local ignore, carID

			for ignore, carID in getKeys(otherCars)
				if !activeCars.Has(carID)
					otherCars.Delete(carID)
		}

		if (lastLap > 0) {
			driver := positions["Driver"]

			otherCars := this.OtherCars

			loop positions["Count"] {
				car := positions[A_Index]
				carID := car[17]
				carNr := car[1]

				activeCars[carID] := true

				if (A_Index != driver) {
					if otherCars.Has(carID)
						cInfo := otherCars[carID]
					else {
						cInfo := CarInfo(this, carID, carNr, car[2], car[3])

						otherCars[carID] := cInfo
					}
				}
				else {
					cInfo := this.DriverCar

					if !cInfo {
						cInfo := CarInfo(this, carID, carNr, car[2], car[3])

						this.iDriverCar := cInfo
					}
				}

				carLaps := car[7]

				if !cInfo.update(car[4], car[5], car[6], carLaps, sector
							   , Round(car[9] / 1000, 1), car[18]
							   , Round(car[10] / 1000, 1), Round(car[11] / 1000, 1), Round(car[12] / 1000, 1)
							   , car[13], car[19], (carLaps - car[14]), car[15], car[16])
					if ((A_Index != driver) && this.PositionInfos.Has(cInfo.ID))
						this.PositionInfos[cInfo.ID].reset(sector, true, true)
			}

			Task.startTask(cleanup.Bind(otherCars, activeCars), 1000, kLowPriority)
		}
	}

	updatePositionInfos(lastLap, sector, positions) {
		local debug := this.Debug[kDebugPositions]
		local positionInfos, position, info
		local id, car

		this.updateCarInfos(lastLap, sector, positions)

		positionInfos := this.PositionInfos

		if debug
			FileAppend("---------------------------------`n`n", kTempDirectory . "Race Spotter.positions")

		for id, car in this.OtherCars {
			if positionInfos.Has(id)
				position := positionInfos[id]
			else {
				position := PositionInfo(this, car)

				positionInfos[id] := position
			}

			if debug {
				info := values2String(", ", position.Car.Nr, position.Car.Car, position.Car.Driver, position.Car.Position["Class"], position.Observed
										  , values2String("|", position.Car.LapTimes*), position.Car.LapTime[true]
										  , values2String("|", position.Car.Deltas[sector]*), position.Delta[sector]
										  , position.inFront(), position.atBehind(), position.inFront(false), position.atBehind(false), position.forPosition()
										  , position.DeltaDifference[sector], position.LapTimeDifference[true]
										  , position.isFaster(sector), position.closingIn(sector, 0.2), position.runningAway(sector, 0.3))

				FileAppend(info . "`n", kTempDirectory . "Race Spotter.positions")
			}

			position.checkpoint(sector)
		}

		if debug
			FileAppend("`n---------------------------------`n`n", kTempDirectory . "Race Spotter.positions")
	}

	getPositionInfos(&standingsAhead, &standingsBehind, &trackAhead, &trackBehind, &leader, &focused, inpit := false) {
		local ignore, observed, candidate, cInpit

		standingsAhead := false
		standingsBehind := false
		trackAhead := false
		trackBehind := false
		leader := false
		focused := false

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

			if (InStr(observed, "F") && (candidate == this.FocusedCar[true]))
				focused := candidate
		}
	}

	finalLap() {
		local knowledgeBase := this.KnowledgeBase
		local additionalLaps := knowledgeBase.getValue("Session.AdditionalLaps")
		local sessionLapsRemaining := knowledgeBase.getValue("Session.Lap.Remaining")
		local driverCar := knowledgeBase.getValue("Driver.Car")
		local finalLap := this.FinalLap
		local sessionTimeRemaining, driverCar, running, time

		if finalLap
			return (knowledgeBase.getValue("Car." . finalLap[1] . ".Laps") >= finalLap[2])
		else {
			if (knowledgeBase.getValue("Session.Format") = "Time") {
				sessionTimeRemaining := knowledgeBase.getValue("Session.Time.Remaining")

				if (sessionTimeRemaining < (knowledgeBase.getValue("Car." . driverCar . ".Time", 0) * 2)) {
					loop knowledgeBase.getValue("Car.Count", 0)
						if (knowledgeBase.getValue("Car." . A_Index . ".Position") = 1) {
							time := knowledgeBase.getValue("Car." . A_Index . ".Time")
							running := knowledgeBase.getValue("Car." . A_Index . ".Lap.Running")

							if ((sessionTimeRemaining - ((1 - running) * time)) <= 0)
								if (additionalLaps > 0) {
									this.iFinalLap := [A_Index, knowledgeBase.getValue("Car." . A_Index . ".Laps") + additionalLaps]

									return false
								}
								else
									return true

							break
						}

					return (sessionTimeRemaining <= 0)
				}
				else
					return false
			}
			else if ((additionalLaps > 0) && driverCar && (sessionLapsRemaining = 1)) {
				this.iFinalLap := [driverCar, knowledgeBase.getValue("Car." . driverCar . ".Laps") + 1 + additionalLaps]

				return false
			}
			else
				return (sessionLapsRemaining <= 0)
		}
	}

	reviewRaceStart(lastLap, sector, positions) {
		local startPosition := this.GridPosition["Class"]
		local speaker, driver, currentPosition, startPosition

		if ((this.Session == kSessionRace) && startPosition) {
			speaker := this.getSpeaker()
			driver := positions["Driver"]

			if driver {
				currentPosition := positions["Position.Class"]

				if ((currentPosition != startPosition) || (startPosition != this.getCars("Class").Length)) {
					speaker.beginTalk()

					try {
						if (currentPosition = startPosition) {
							speaker.speakPhrase("GoodStart")

							if (currentPosition = 1)
								speaker.speakPhrase("Leader")
							else if (currentPosition <= 5)
								speaker.speakPhrase("Position", {position: currentPosition})
						}
						else if (currentPosition < startPosition) {
							speaker.speakPhrase("GreatStart")

							if (currentPosition = 1)
								speaker.speakPhrase("Leader")
							else if (currentPosition <= 5)
								speaker.speakPhrase("Position", {position: currentPosition})
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
		else
			return false
	}

	reviewHalfTime(lastLap, sector, positions) {
		local knowledgeBase, remainingSessionLaps, remainingStintLaps, remainingSessionTime
		local remainingStintTime, remainingFuelLaps, enoughFuel, speaker

		if (this.Session == kSessionRace) {
			speaker := this.getSpeaker()

			knowledgeBase := this.KnowledgeBase
			remainingSessionLaps := knowledgeBase.getValue("Lap.Remaining.Session", 0)
			remainingStintLaps := knowledgeBase.getValue("Lap.Remaining.Stint", 0)
			remainingSessionTime := Round(knowledgeBase.getValue("Session.Time.Remaining", 0) / 60000)
			remainingStintTime := Round(knowledgeBase.getValue("Driver.Time.Stint.Remaining", 0) / 60000)

			if (remainingSessionLaps > 0) {
				speaker.beginTalk()

				try {
					speaker.speakPhrase("HalfTimeIntro", {minutes: remainingSessionTime
														, laps: remainingSessionLaps
														, position: Round(positions["Position.Class"])})

					remainingFuelLaps := Floor(knowledgeBase.getValue("Lap.Remaining.Fuel", 0))

					if (remainingStintTime < remainingSessionTime) {
						speaker.speakPhrase("HalfTimeStint", {minutes: remainingStintTime, laps: Floor(remainingStintLaps)})

						enoughFuel := (remainingStintLaps < remainingFuelLaps)
					}
					else {
						speaker.speakPhrase("HalfTimeSession", {minutes: remainingSessionTime
															  , laps: Floor(remainingSessionLaps)})

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
		else
			return false
	}

	announceFinalLaps(lastLap, sector, positions) {
		local speaker := this.getSpeaker()
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
		local enoughData := this.hasEnoughData(false)
		local speaker := this.getSpeaker()
		local fragments := speaker.Fragments
		local airTemperature := Round(knowledgebase.getValue("Weather.Temperature.Air"))
		local trackTemperature := Round(knowledgebase.getValue("Weather.Temperature.Track"))
		local remainingSessionLaps := knowledgeBase.getValue("Lap.Remaining.Session", kUndefined)
		local remainingStintLaps := knowledgeBase.getValue("Lap.Remaining.Stint", kUndefined)
		local remainingSessionTime := Round(knowledgeBase.getValue("Session.Time.Remaining") / 60000)
		local standingsAhead := false
		local standingsBehind := false
		local trackAhead := false
		local trackBehind := false
		local leader := false
		local focused := false
		local position := false
		local number := false
		local situation, sessionDuration, lapTime, sessionEnding, minute, lastTemperature, stintLaps
		local minute, rnd, phrase, bestLapTime, lastTopSpeed, ignore, delta

		if isDebug()
			logMessage(kLogDebug, "SessionInformation: " . lastLap . ", " . regular . " Positions: " . (positions != false) . " Remaining: " . remainingSessionLaps . ", " . remainingStintLaps)

		if ((remainingSessionLaps = kUndefined) || (remainingStintLaps = kUndefined))
			return false

		if (this.Session == kSessionRace)
			if (lastLap == 2) {
				situation := "StartSummary"

				if !this.SessionInfos.Has(situation) {
					this.SessionInfos[situation] := true

					if this.reviewRaceStart(lastLap, sector, positions)
						return true
				}
			}
			else if (enoughData && (remainingSessionLaps > 5)) {
				situation := "HalfTime"

				if ((Abs((this.SessionDuration / 2) - this.OverallTime) < 120000) && !this.SessionInfos.Has(situation)) {
					this.SessionInfos[situation] := true

					if this.reviewHalfTime(lastLap, sector, positions)
						return true
				}
			}
			else if this.finalLap() {
				situation := "LastLap"

				if !this.SessionInfos.Has(situation) {
					this.SessionInfos[situation] := true

					this.handleEvent("LastLap")

					if (knowledgeBase.getValue("Session.Format") = "Time") {
						if (this.getPosition() = 1) {
							speaker.beginTalk()

							try {
								speaker.speakPhrase("LastLapDriver")
								speaker.speakPhrase("Leader")
								speaker.speakPhrase("BringItHome")
							}
							finally {
								speaker.endTalk()
							}
						}
						else {
							speaker.beginTalk()

							try {
								speaker.speakPhrase("LastLapLeader")

								if (this.getPosition(false, "Class") < 3) {
									speaker.speakPhrase("Position", {position: this.getPosition(false, "Class")})
									speaker.speakPhrase("BringItHome")
								}
							}
							finally {
								speaker.endTalk()
							}
						}
					}
					else {
						speaker.beginTalk()

						try {
							speaker.speakPhrase("LastLapDriver")

							if (this.getPosition(false, "Class") < 3) {
								speaker.speakPhrase("Position", {position: this.getPosition(false, "Class")})
								speaker.speakPhrase("BringItHome")
							}
						}
						finally {
							speaker.endTalk()
						}
					}
				}
			}

		if (this.BestLapTime > 0) {
			bestLapTime := Round(this.BestLapTime, 1)

			if ((enoughData && (lastLap > (this.BaseLap + 2))) && (!this.SessionInfos.Has("BestLap") || (bestLapTime < this.SessionInfos["BestLap"]))) {
				lapTime := (bestLapTime / 1000)

				minute := Floor(lapTime / 60)

				speaker.speakPhrase("BestLap", {time: speaker.number2Speech(lapTime, 1)
											  , minute: minute, seconds: speaker.number2Speech((lapTime - (minute * 60)), 1)})

				this.SessionInfos["BestLap"] := bestLapTime

				return true
			}
			else
				this.SessionInfos["BestLap"] := bestLapTime
		}

		if (this.LastTopSpeed > 0) {
			lastTopSpeed := Round(convertUnit("Speed", this.LastTopSpeed))

			if (!this.SessionInfos.Has("BestSpeed") || (lastTopSpeed > this.SessionInfos["BestSpeed"])) {
				if (enoughData && (lastLap > (this.BaseLap + 2))) {
					speaker.speakPhrase("BestSpeed", {speed: speaker.number2Speech(lastTopSpeed), unit: getUnit("Speed")})

					this.SessionInfos["BestSpeed"] := lastTopSpeed

					return true
				}
				else
					this.SessionInfos["BestSpeed"] := lastTopSpeed
			}
		}

		if (enoughData && (lastLap > (this.BaseLap + 2)) && !this.SessionInfos.Has("LastLap")) {
			if ((remainingSessionLaps <= 4) && (Floor(remainingSessionLaps) > 2) && (this.Session = kSessionRace)
											&& (remainingSessionTime < 10)) {
				situation := "FinalLaps"

				if !this.SessionInfos.Has(situation) {
					this.SessionInfos[situation] := true

					this.announceFinalLaps(lastLap, sector, positions)

					return true
				}
			}

			stintLaps := Floor(remainingStintLaps)

			if ((this.Session = kSessionRace) && (stintLaps < 5) && (Abs(remainingStintLaps - remainingSessionLaps) > 2)) {
				if (stintLaps > 0) {
					situation := ("StintEnding " . Ceil(lastLap + stintLaps))

					if !this.SessionInfos.Has(situation) {
						this.SessionInfos[situation] := true

						speaker.speakPhrase("StintEnding", {laps: stintLaps})

						this.handleEvent("StintEnding", stintLaps)

						return true
					}
				}
			}

			if !this.SessionInfos.Has("AirTemperature") {
				if (lastLap > (this.BaseLap + 1)) {
					this.SessionInfos["AirTemperature"] := airTemperature

					if (this.BaseLap > 1) {
						speaker.speakPhrase("Temperature", {air: displayValue("Float", convertUnit("Temperature", airTemperature), 0)
														  , track: displayValue("Float", convertUnit("Temperature", trackTemperature), 0)
														  , unit: fragments[getUnit("Temperature")]})

						return true
					}
				}
			}
			else {
				lastTemperature := this.SessionInfos["AirTemperature"]

				this.SessionInfos["AirTemperature"] := airTemperature

				if (lastTemperature < airTemperature) {
					speaker.speakPhrase("TemperatureRising", {air: displayValue("Float", convertUnit("Temperature", airTemperature), 0)
															, track: displayValue("Float", convertUnit("Temperature", trackTemperature), 0)
															, unit: fragments[getUnit("Temperature")]})

					return true
				}

				if (lastTemperature > airTemperature) {
					speaker.speakPhrase("TemperatureFalling", {air: displayValue("Float", convertUnit("Temperature", airTemperature), 0)
															 , track: displayValue("Float", convertUnit("Temperature", trackTemperature), 0)
															 , unit: fragments[getUnit("Temperature")]})

					return true
				}
			}

			if (this.Session != kSessionRace) {
				sessionEnding := false

				if ((remainingSessionTime < 5) && !this.SessionInfos.Has("5MinAlert")) {
					this.SessionInfos["5MinAlert"] := true
					this.SessionInfos["15MinAlert"] := true
					this.SessionInfos["30MinAlert"] := true

					sessionEnding := true
				}

				if ((remainingSessionTime < 15) && !this.SessionInfos.Has("15MinAlert")) {
					this.SessionInfos["15MinAlert"] := true
					this.SessionInfos["30MinAlert"] := true

					sessionEnding := true
				}

				if ((remainingSessionTime < 30) && !this.SessionInfos.Has("30MinAlert")) {
					this.SessionInfos["30MinAlert"] := true

					sessionEnding := true
				}

				if sessionEnding {
					speaker.speakPhrase("SessionEnding", {minutes: remainingSessionTime})

					return true
				}
			}

			if (regular && (lastLap > 2)) {
				this.getPositionInfos(&standingsAhead, &standingsBehind, &trackAhead, &trackBehind, &leader, &focused)

				lapTime := false

				if (standingsAhead && standingsAhead.hasBestLapTime()) {
					lapTime := standingsAhead.BestLapTime[true]

					if (lapTime = standingsAhead.LastLapTime)
						phrase := "AheadBestLap"
					else
						lapTime := false
				}

				if (focused && !lapTime && focused.hasBestLapTime()) {
					lapTime := focused.BestLapTime[true]

					if (lapTime = focused.LastLapTime) {
						phrase := "FocusBestLap"
						position := focused.Car.Position["Class"]
						number := focused.Car.Nr
					}
					else
						lapTime := false
				}

				if (!lapTime && standingsBehind && standingsBehind.hasBestLapTime()) {
					lapTime := standingsBehind.BestLapTime[true]

					if (lapTime = standingsBehind.LastLapTime)
						phrase := "BehindBestLap"
					else
						lapTime := false
				}

				if (!lapTime && leader && leader.hasBestLapTime()) {
					lapTime := leader.BestLapTime[true]

					if (lapTime = leader.LastLapTime)
						phrase := "LeaderBestLap"
					else
						lapTime := false
				}

				if lapTime {
					minute := Floor(lapTime / 60)
					delta := (lapTime - this.DriverCar.BestLapTime)

					speaker.beginTalk()

					try {
						speaker.speakPhrase(phrase, {time: speaker.number2Speech(lapTime, 1), minute: minute
												   , seconds: speaker.number2Speech(lapTime - (minute * 60), 1)
												   , indicator: this.getCarIndicatorFragment(speaker, number, position)})

						if ((Round(Abs(delta), 1) != 0) && (Abs(delta) < 5))
							speaker.speakPhrase("DeltaLapTime", {delta: speaker.number2Speech(Round(Abs(delta), 1))
															   , relativeYou: fragments[(delta > 0) ? "Faster" : "Slower"]
															   , relativeOther: fragments[(delta < 0) ? "Faster" : "Slower"]})
					}
					finally {
						speaker.endTalk()
					}

					return true
				}
			}
		}

		return false
	}

	penaltyInformation(lastLap, sector, lastPenalty) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local penalty := knowledgeBase.getValue("Lap.Penalty", false)

		if ((penalty != this.iLastPenalty) || (penalty != lastPenalty)) {
			this.iLastPenalty := penalty

			if penalty {
				if (penalty = "DSQ")
					speaker.speakPhrase("Disqualified")
				else {
					if (InStr(penalty, "SG") = 1) {
						penalty := ((StrLen(penalty) > 2) ? (A_Space . SubStr(penalty, 3)) : "")

						penalty := (speaker.Fragments["SG"] . penalty)
					}
					else if (penalty = "Time")
						penalty := speaker.Fragments["Time"]
					else if (penalty = "DT")
						penalty := speaker.Fragments["DT"]
					else if (penalty == true)
						penalty := ""

					speaker.speakPhrase("Penalty", {penalty: penalty})
				}

				return true
			}
			else
				return false
		}
		else
			return false
	}

	cutWarning(lastLap, sector, wasValid, lastWarnings) {
		local knowledgeBase := this.KnowledgeBase
		local driverCar := this.DriverCar

		if ((this.Session = kSessionRace) && ((wasValid && !knowledgeBase.getValue("Lap.Valid", true)) || (lastWarnings < knowledgeBase.getValue("Lap.Warnings", 0)))) {
			if (knowledgeBase.getValue("Lap.Warnings", 0) > 2)
				this.getSpeaker().speakPhrase("RepeatedCut")
			else if driverCar
				this.getSpeaker().speakPhrase((this.DriverCar.InvalidLaps > 3) ? "RepeatedCut" : "Cut")
			else
				this.getSpeaker().speakPhrase("Cut")

			return true
		}
		else
			return false
	}

	tacticalAdvice(lastLap, sector, positions, regular) {
		local speaker := this.getSpeaker()
		local standingsAhead := false
		local standingsBehind := false
		local trackAhead := false
		local trackBehind := false
		local leader := false
		local focused := false
		local situation, opponentType, driverPitstops, carPitstops, carInfo, indicator
		local driverPosition, driverLapTime, slowerCar, carNr, carPosition, delta, lapTimeDifference, key

		if ((this.Session = kSessionQualification) && !this.PrivateSession) {
			this.getPositionInfos(&standingsAhead, &standingsBehind, &trackAhead, &trackBehind, &leader, &focused)

			if (trackAhead && trackAhead.inRange(sector, true)) {
				if (trackAhead.Car.Valid && this.DriverCar.Valid) {
					situation := ("AheadValid " . trackAhead.Car.ID . A_Space . lastLap)

					if !this.TacticalAdvices.Has(situation) {
						this.TacticalAdvices[situation] := true

						speaker.speakPhrase("AheadValid")

						return true
					}
				}

				if (!trackAhead.Car.Valid && this.DriverCar.Valid) {
					situation := ("AheadInvalid " . trackAhead.Car.ID . A_Space . lastLap)

					if !this.TacticalAdvices.Has(situation) {
						this.TacticalAdvices[situation] := true

						speaker.speakPhrase("AheadInvalid")

						return true
					}
				}
			}

			if (trackBehind && trackBehind.inRange(sector, true)) {
				if (trackBehind.Car.Valid && !this.DriverCar.Valid) {
					situation := ("BehindValid " . trackBehind.Car.ID . A_Space . lastLap)

					if !this.TacticalAdvices.Has(situation) {
						this.TacticalAdvices[situation] := true

						speaker.speakPhrase("BehindValid")

						return true
					}
				}

				if (!trackBehind.Car.Valid && !this.DriverCar.Valid) {
					situation := ("BehindInvalid " . trackBehind.Car.ID . A_Space . lastLap)

					if !this.TacticalAdvices.Has(situation) {
						this.TacticalAdvices[situation] := true

						speaker.speakPhrase("BehindInvalid")

						return true
					}
				}
			}
		}

		if (this.hasEnoughData(false) && (this.Session = kSessionRace) && (lastLap > (this.BaseLap + 2))) {
			this.getPositionInfos(&standingsAhead, &standingsBehind, &trackAhead, &trackBehind, &leader, &focused, true)

			if (standingsAhead && (standingsAhead != leader)) {
				situation := ("AheadPitting " . standingsAhead.Car.ID . A_Space)

				if (!this.TacticalAdvices.Has(situation . standingsAhead.Car.LastLap) && !this.TacticalAdvices.Has(situation . (standingsAhead.Car.LastLap - 1))) {
					this.TacticalAdvices[situation . standingsAhead.Car.LastLap] := true

					speaker.speakPhrase("AheadPitting")

					this.handleEvent("OpponentPitting", "Ahead")

					return true
				}
			}

			if focused {
				situation := ("FocusPitting " . focused.Car.ID . A_Space)

				if (!this.TacticalAdvices.Has(situation . focused.Car.LastLap) && !this.TacticalAdvices.Has(situation . (focused.Car.LastLap - 1))) {
					this.TacticalAdvices[situation . focused.Car.LastLap] := true

					speaker.speakPhrase("FocusPitting", {indicator: this.getCarIndicatorFragment(speaker, focused.Car.Nr, focused.Car.Position["Class"])})

					return true
				}
			}

			if standingsBehind {
				situation := ("BehindPitting " . standingsBehind.Car.ID . A_Space)

				if (!this.TacticalAdvices.Has(situation . standingsBehind.Car.LastLap) && !this.TacticalAdvices.Has(situation . (standingsBehind.Car.LastLap - 1))) {
					this.TacticalAdvices[situation . standingsBehind.Car.LastLap] := true

					speaker.speakPhrase("BehindPitting")

					this.handleEvent("OpponentPitting", "Behind")

					return true
				}
			}

			if (leader && (leader.Car.ID != this.DriverCar.ID)) {
				situation := ("LeaderPitting " . leader.Car.ID . A_Space)

				if (!this.TacticalAdvices.Has(situation . leader.Car.LastLap) && !this.TacticalAdvices.Has(situation . (leader.Car.LastLap - 1))) {
					this.TacticalAdvices[situation . leader.Car.LastLap] := true

					speaker.speakPhrase("LeaderPitting")

					return true
				}
			}

			this.getPositionInfos(&standingsAhead, &standingsBehind, &trackAhead, &trackBehind, &leader, &focused)

			if (standingsAhead && standingsAhead.hasProblem()) {
				situation := ("AheadProblem " . lastLap)

				if (!this.TacticalAdvices.Has(situation) && !this.TacticalAdvices.Has("AheadProblem " . (lastLap - 1))) {
					this.TacticalAdvices[situation] := true

					speaker.speakPhrase("AheadProblem")

					return true
				}
			}

			if (focused && focused.hasProblem()) {
				situation := ("FocusProblem " . lastLap)

				if (!this.TacticalAdvices.Has(situation) && !this.TacticalAdvices.Has("FocusProblem " . (lastLap - 1))) {
					this.TacticalAdvices[situation] := true

					speaker.speakPhrase("FocusProblem", {indicator: this.getCarIndicatorFragment(speaker, focused.Car.Nr, focused.Car.Position["Class"])})

					return true
				}
			}

			if (regular && trackAhead && trackAhead.inRange(sector, true) && !trackAhead.isFaster(sector)
			 && standingsBehind && (standingsBehind == trackBehind) && !trackAhead.Car.InPit
			 && standingsBehind.hasGap(sector) && trackAhead.hasGap(sector)
			 && standingsBehind.inDelta(sector) && standingsBehind.isFaster(sector)) {
				situation := ("ProtectSlower " . trackAhead.Car.ID . A_Space . trackBehind.Car.ID)

				if !this.TacticalAdvices.Has(situation) {
					this.TacticalAdvices[situation] := true

					speaker.speakPhrase("ProtectSlower")

					return true
				}
			}

			opponentType := (trackBehind ? trackBehind.OpponentType[sector] : false)

			if (regular && trackBehind && trackBehind.hasGap(sector) && !trackBehind.Car.InPit
			 && trackBehind.isFaster(sector) && trackBehind.inRange(sector, true)) {
				if (standingsBehind && (trackBehind != standingsBehind)
				 && standingsBehind.hasGap(sector) && standingsBehind.inDelta(sector, 4.0)
				 && standingsBehind.isFaster(sector) && (opponentType = "LapDown")) {
					situation := ("ProtectFaster " . trackBehind.Car.ID . A_Space . standingsBehind.Car.ID)

					if !this.TacticalAdvices.Has(situation) {
						this.TacticalAdvices[situation] := true

						speaker.speakPhrase("ProtectFaster")

						return true
					}
				}
				else if (((opponentType = "LapDown") || (opponentType = "LapUp")) && trackBehind.isFaster(sector, 0.25)) {
					situation := (opponentType . "Faster " . trackBehind.Car.ID)

					if !this.TacticalAdvices.Has(situation) {
						this.TacticalAdvices[situation] := true

						speaker.beginTalk()

						try {
							speaker.speakPhrase(opponentType . "Faster")

							driverPitstops := this.DriverCar.Pitstops.Length
							carPitstops := trackBehind.Car.Pitstops.Length

							if ((driverPitstops < carPitstops) && (opponentType = "LapDown"))
								speaker.speakPhrase("MorePitstops", {conjunction: speaker.Fragments["But"]
																   , pitstops: carPitstops - driverPitstops})
							else if ((driverPitstops > carPitstops) && (opponentType = "LapUp"))
								speaker.speakPhrase("LessPitstops", {conjunction: speaker.Fragments["But"]
																   , pitstops: driverPitstops - carPitstops})
							else if !trackBehind.isFaster(sector, 0.75)
								speaker.speakPhrase("Slipstream")
						}
						finally {
							speaker.endTalk()
						}

						return true
					}
				}
			}

			if (standingsBehind && standingsBehind.hasProblem()) {
				situation := ("BehindProblem " . lastLap)

				if (!this.TacticalAdvices.Has(situation) && !this.TacticalAdvices.Has("BehindProblem " . (lastLap - 1))) {
					this.TacticalAdvices[situation] := true

					speaker.speakPhrase("BehindProblem")

					return true
				}
			}

			if (regular && (Random(1, 10) < 5)) {
				driverPosition := this.DriverCar.Position["Class"]
				driverClass := this.DriverCar.Class
				driverLapTime := this.DriverCar.AvgLapTime
				slowerCar := false

				for ignore, carInfo in this.OtherCars {
					if (carInfo.Class = driverClass) {
						carPosition := carInfo.Position["Class"]

						if ((carPosition < driverPosition) && (carInfo.AvgLapTime > driverLapTime))
							if (!slowerCar || (carPosition < slowerCar.Position["Class"]))
								if ((carInfo.AvgLapTime - driverLapTime) < 0.5)
									slowerCar := carInfo
							}
				}

				if slowerCar
					if (standingsAhead && (standingsAhead.Car = slowerCar))
						slowerCar := false
					else if (standingsBehind && (standingsBehind.Car = slowerCar))
						slowerCar := false
					else if (focused && (focused.Car = slowerCar))
						slowerCar := false

				if slowerCar {
					delta := Abs(slowerCar.AvgDelta[false])
					lapTimeDifference := Abs(driverLapTime - slowerCar.AvgLapTime)

					if ((delta != 0) && (lapTimeDifference != 0)) {
						key := (slowerCar.Nr . "|" . slowerCar.ID)
						situation := (this.TacticalAdvices.Has("FasterThan") ? this.TacticalAdvices["FasterThan"] : false)
						carNr := slowerCar.Nr
						carPosition := slowerCar.Position["Class"]

						if situation
							if (situation.Key != key)
								situation := false
							else if ((situation.Lap + 5) <= lastLap)
								situation := false

						if !situation {
							speaker.speakPhrase("FasterThan", {indicator: this.getCarIndicatorFragment(speaker, carNr, carPosition)
															 , delta: speaker.number2Speech(delta, 1)
															 , lapTime: speaker.number2Speech(lapTimeDifference, 1)})

							this.TacticalAdvices["FasterThan"] := {Key: key, Lap: lastLap}

							return true
						}
					}
				}
			}
		}

		return false
	}

	standingsGapToAhead() {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local talking := false
		local delta, lap, car, inPit

		if (this.getPosition(false, "Class") = 1)
			return false
		else
			try {
				lap := knowledgeBase.getValue("Lap", 0)
				car := knowledgeBase.getValue("Position.Standings.Class.Ahead.Car", false)

				if (car && (lap > 0)) {
					delta := Abs(knowledgeBase.getValue("Position.Standings.Class.Ahead.Delta", 0) / 1000)
					inPit := (knowledgeBase.getValue("Car." . car . ".InPitLane", false) || knowledgeBase.getValue("Car." . car . ".InPit", false))

					if ((delta = 0) || (inPit && (Abs(delta) < 30)))
						return false
					else if ((knowledgeBase.getValue("Car." . car . ".Laps", knowledgeBase.getValue("Car." . car . ".Lap", 0)) > lap)
						  && (Abs(delta) > (knowledgeBase.getValue("Lap." . lap . ".Time", 0) / 1000)))
						return false
					else {
						speaker.beginTalk()

						speaker.speakPhrase("StandingsGapToAhead", {delta: speaker.number2Speech(delta, 1)})

						talking := true

						if inPit
							speaker.speakPhrase("GapCarInPit")
					}

					return talking
				}
				else
					return false
			}
			finally {
				if talking
					speaker.endTalk()
			}
	}

	standingsGapToBehind() {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local talking := false
		local delta, car, driver, inPit, lap

		if (this.getPosition(false, "Class") = this.getCars("Class").Length)
			return false
		else
			try {
				lap := knowledgeBase.getValue("Lap", 0)
				car := knowledgeBase.getValue("Position.Standings.Class.Behind.Car", false)

				if (car && (lap > 0)) {
					delta := Abs(knowledgeBase.getValue("Position.Standings.Class.Behind.Delta", 0) / 1000)
					inPit := (knowledgeBase.getValue("Car." . car . ".InPitLane", false) || knowledgeBase.getValue("Car." . car . ".InPit", false))

					if ((delta = 0) || (inPit && (Abs(delta) < 30)))
						return false
					else if ((knowledgeBase.getValue("Car." . car . ".Laps", knowledgeBase.getValue("Car." . car . ".Lap", 0)) < lap)
						  && (Abs(delta) > (knowledgeBase.getValue("Lap." . lap . ".Time", 0) / 1000)))
						return false
					else {
						speaker.beginTalk()

						speaker.speakPhrase("StandingsGapToBehind", {delta: speaker.number2Speech(delta, 1)})

						talking := true

						if inPit
							speaker.speakPhrase("GapCarInPit")
					}

					return talking
				}
				else
					return false
			}
			finally {
				if talking
					speaker.endTalk()
			}
	}

	focusGap() {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local talking := false
		local number, focusedCar, delta, car, driver, inPit, lap, ignore, candidate

		if (this.getPosition(false, "Class") = this.getCars("Class").Length)
			return false
		else
			try {
				lap := knowledgeBase.getValue("Lap", 0)

				if (lap > 0) {
					number := this.FocusedCar
					car := false

					for ignore, candidate in this.getCars()
						if (knowledgeBase.getValue("Car." . candidate . ".Nr", "-") = number) {
							car := candidate

							break
						}

					if car {
						delta := (this.getDelta(car) / 1000)
						inPit := (knowledgeBase.getValue("Car." . car . ".InPitLane", false) || knowledgeBase.getValue("Car." . car . ".InPit", false))

						if ((delta = 0) || (inPit && (Abs(delta) < 30)))
							return false
						else if ((knowledgeBase.getValue("Car." . car . ".Laps", knowledgeBase.getValue("Car." . car . ".Lap", 0)) < lap)
							  && (Abs(delta) > (knowledgeBase.getValue("Lap." . lap . ".Time", 0) / 1000)))
							return false
						else {
							speaker.beginTalk()

							speaker.speakPhrase((delta < 0) ? "FocusGapToBehind" : "FocusGapToAhead"
											  , {indicator: this.getCarIndicatorFragment(speaker, number, this.FocusedCar[true].Car.Position["Class"])
											   , delta: speaker.number2Speech(Abs(delta), 1)})

							talking := true

							if inPit
								speaker.speakPhrase("GapCarInPit")
						}
					}

					return talking
				}
				else
					return false
			}
			finally {
				if talking
					speaker.endTalk()
			}
	}

	informSectorDifference(otherCar, mode) {
		local speaker := this.getSpeaker(true)
		local sectors := string2Values(",", speaker.Fragments["Sectors"])
		local driverCar := this.DriverCar
		local betterSectors := []
		local driverSectorTime, otherSectorTime, sector1, sector2

		loop 3 {
			driverSectorTime := driverCar.AvgSectorTime[A_Index]
			otherSectorTime := otherCar.AvgSectorTime[A_Index]

			if (driverSectorTime && otherSectorTime)
				if (((mode = "Ahead") && (driverSectorTime < otherSectorTime))
				 || ((mode = "Behind") && (driverSectorTime > otherSectorTime)))
					betterSectors.Push(Array(A_Index, driverSectorTime, otherSectorTime, Abs(driverSectorTime - otherSectorTime)))
		}

		if (betterSectors.Length = 1) {
			sector1 := betterSectors[1]

			speaker.speakPhrase((mode = "Ahead") ? "SectorFasterAhead" : "SectorSlowerBehind"
							  , {sector: sectors[sector1[1]], sectorTime: speaker.number2Speech(sector1[4], 1)})
		}
		else if (betterSectors.Length = 2) {
			sector1 := betterSectors[1]
			sector2 := betterSectors[2]

			speaker.speakPhrase((mode = "Ahead") ? "SectorsFasterAhead" : "SectorsSlowerBehind"
							  , {sector1: sectors[sector1[1]], sector1Time: speaker.number2Speech(sector1[4], 1)
							   , sector2: sectors[sector2[1]], sector2Time: speaker.number2Speech(sector2[4], 1)})
		}
	}

	deltaInformation(lastLap, sector, positions, regular, method) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker(true)
		local spoken := false
		local informed := false
		local standingsAhead := false
		local standingsBehind := false
		local trackAhead := false
		local trackBehind := false
		local leader := false
		local focused := false
		local lapTime := false
		local position := false
		local number := false
		local info, settings, rnd, phrase, minute
		local opponentType, delta, deltaDifference, lapDifference, lapTimeDifference, car, remaining, rnd
		local unsafe, driverPitstops, carPitstops, indicator

		static lapUpRangeThreshold := kUndefined
		static lapDownRangeThreshold := false
		static frontAttackThreshold := false
		static frontGainThreshold := false
		static frontLostThreshold := false
		static behindAttackThreshold := false
		static behindGainThreshold := false
		static behindLostThreshold := false
		static overtakeThreshold := false
		static frontGapMin := false
		static frontGapMax := false
		static behindGapMin := false
		static behindGapMax := false

		if (lapUpRangeThreshold = kUndefined) {
			settings := this.Settings

			lapUpRangeThreshold := getDeprecatedValue(settings, "Assistant.Spotter", "Spotter Settings", "LapUp.Range.Threshold", 1.0)
			lapDownRangeThreshold := getDeprecatedValue(settings, "Assistant.Spotter", "Spotter Settings", "LapDown.Range.Threshold", 2.0)
			frontAttackThreshold := getDeprecatedValue(settings, "Assistant.Spotter", "Spotter Settings", "Front.Attack.Threshold", 0.8)
			frontGainThreshold := getDeprecatedValue(settings, "Assistant.Spotter", "Spotter Settings", "Front.Gain.Threshold", 0.3)
			frontLostThreshold := getDeprecatedValue(settings, "Assistant.Spotter", "Spotter Settings", "Front.Lost.Threshold", 1.0)
			behindAttackThreshold := getDeprecatedValue(settings, "Assistant.Spotter", "Spotter Settings", "Behind.Attack.Threshold", 0.8)
			behindLostThreshold := getDeprecatedValue(settings, "Assistant.Spotter", "Spotter Settings", "Behind.Lost.Threshold", 0.3)
			behindGainThreshold := getDeprecatedValue(settings, "Assistant.Spotter", "Spotter Settings", "Behind.Gain.Threshold", 1.5)
			overtakeThreshold := getDeprecatedValue(settings, "Assistant.Spotter", "Spotter Settings", "Overtake.Threshold", 0.3)
			frontGapMin := getMultiMapValue(settings, "Assistant.Spotter", "Front.Observe.Range.Min", 2)
			frontGapMax := getMultiMapValue(settings, "Assistant.Spotter", "Front.Observe.Range.Max", 3600)
			behindGapMin := getMultiMapValue(settings, "Assistant.Spotter", "Behind.Observe.Range.Min", 2)
			behindGapMax := getMultiMapValue(settings, "Assistant.Spotter", "Behind.Observe.Range.Max", 3600)
		}

		this.getPositionInfos(&standingsAhead, &standingsBehind, &trackAhead, &trackBehind, &leader, &focused)

		if this.Debug[kDebugPositions] {
			info := ("=================================`n" . regular . (standingsAhead != false) . (standingsBehind != false) . (trackAhead != false) . (trackBehind != false) . "`n=================================`n`n")

			FileAppend(info, kTempDirectory . "Race Spotter.positions")
		}

		speaker.beginTalk()

		try {
			driverPitstops := this.DriverCar.Pitstops.Length
			opponentType := (trackAhead ? trackAhead.OpponentType[sector] : false)

			if (trackAhead && (trackAhead != standingsAhead) && trackAhead.hasGap(sector)
			 && (opponentType != "Position") && !trackAhead.Car.InPit
			 && trackAhead.inRange(sector, true, (opponentType = "LapDown") ? lapDownRangeThreshold : lapUpRangeThreshold)
			 && !trackAhead.inRange(sector, true, overtakeThreshold)
			 && !trackAhead.isFaster(sector) && !trackAhead.runningAway(sector, frontGainThreshold)
			 && !trackAhead.Reported) {
				carPitstops := trackAhead.Car.Pitstops.Length

				if (opponentType = "LapDown") {
					speaker.speakPhrase("LapDownDriver")

					if (driverPitstops < carPitstops)
						speaker.speakPhrase("MorePitstops", {conjunction: "", pitstops: carPitstops - driverPitstops})

					trackAhead.Reported := true

					spoken := true
				}
				else if (opponentType = "LapUp") {
					speaker.speakPhrase("LapUpDriver")

					if (driverPitstops < carPitstops)
						speaker.speakPhrase("MorePitstops", {conjunction: "", pitstops: carPitstops - driverPitstops})
					else if (driverPitstops > carPitstops)
						speaker.speakPhrase("LessPitstops", {conjunction: "", pitstops: driverPitstops - carPitstops})

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

					FileAppend(info, kTempDirectory . "Race Spotter.positions")
				}

				if ((delta <= frontAttackThreshold) && !standingsAhead.isFaster(sector) && !standingsAhead.Reported
													&& !standingsAhead.inRange(sector, true, overtakeThreshold)) {
					speaker.speakPhrase("GotHim", {delta: speaker.number2Speech(delta, 1)
												 , gained: speaker.number2Speech(deltaDifference, 1)
												 , lapTime: speaker.number2Speech(lapTimeDifference, 1)})

					car := standingsAhead.Car

					this.informSectorDifference(car, "Ahead")

					unsafe := true

					if (car.Incidents > 0)
						speaker.speakPhrase("UnsafeDriverFront")
					else if ((car.InvalidLaps >= this.DriverCar.InvalidLaps) && (car.InvalidLaps > (car.LastLap / 10)))
						speaker.speakPhrase("InconsistentDriverFront")
					else
						unsafe := false

					carPitstops := standingsAhead.Car.Pitstops.Length

					if (driverPitstops < carPitstops)
						speaker.speakPhrase("MorePitstops", {conjunction: speaker.Fragments[unsafe ? "And" : "But"], pitstops: carPitstops - driverPitstops})
					else if (driverPitstops > carPitstops)
						speaker.speakPhrase("LessPitstops", {conjunction: speaker.Fragments[unsafe ? "But" : "And"], pitstops: driverPitstops - carPitstops})

					standingsAhead.Reported := true

					standingsAhead.reset(sector, false, true)

					spoken := true
				}
				else if regular {
					lapDifference := standingsAhead.LapDifference[sector]

					if ((lapDifference > 0) && (delta >= frontGapMin) && (delta <= frontGapMax)) {
						if (standingsAhead.closingIn(sector, frontGainThreshold) && !standingsAhead.Reported) {
							speaker.speakPhrase("GainedFront", {delta: (delta > 5) ? Round(delta) : speaker.number2Speech(delta, 1)
															  , gained: speaker.number2Speech(deltaDifference, 1)
															  , lapTime: speaker.number2Speech(lapTimeDifference, 1)
															  , deltaLaps: lapDifference
															  , laps: speaker.Fragments[(lapDifference > 1) ? "Laps" : "Lap"]})

							remaining := Min(knowledgeBase.getValue("Session.Time.Remaining"), knowledgeBase.getValue("Driver.Time.Stint.Remaining"))

							if ((remaining > 0) && (lapTimeDifference > 0))
								if (((remaining / 1000) / this.DriverCar.LapTime[true]) > (delta / lapTimeDifference))
									speaker.speakPhrase("CanDoIt")
								else
									speaker.speakPhrase("CantDoIt")

							this.handleEvent("AheadGapUpdate", standingsAhead.Car.Nr, Round(delta, 1), true)

							informed := true

							standingsAhead.reset(sector, false, true)

							spoken := true
						}
						else if (standingsAhead.runningAway(sector, frontLostThreshold)) {
							speaker.speakPhrase("LostFront", {delta: (delta > 5) ? Round(delta) : speaker.number2Speech(delta, 1)
															, lost: speaker.number2Speech(deltaDifference, 1)
															, lapTime: speaker.number2Speech(lapTimeDifference, 1)
															, deltaLaps: lapDifference
															, laps: speaker.Fragments[(lapDifference > 1) ? "Laps" : "Lap"]})

							this.handleEvent("AheadGapUpdate", standingsAhead.Car.Nr, Round(delta, 1), false)

							standingsAhead.reset(sector, true, true)

							spoken := true
						}
					}
				}
			}

			if (standingsBehind && standingsBehind.hasGap(sector) && (method >= kDeltaMethodDynamic)) {
				delta := Abs(standingsBehind.Delta[false, true, 1])
				deltaDifference := Abs(standingsBehind.DeltaDifference[sector])
				lapTimeDifference := Abs(standingsBehind.LapTimeDifference)

				if this.Debug[kDebugPositions] {
					info := values2String(", ", values2String("|", this.DriverCar.LapTimes*), this.DriverCar.LapTime[true]
																 , standingsBehind.Car.Nr, standingsBehind.Car.InPit, standingsBehind.Reported
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

					FileAppend(info, kTempDirectory . "Race Spotter.positions")
				}

				if ((delta <= behindAttackThreshold) && (standingsBehind.isFaster(sector) || standingsBehind.closingIn(sector, behindLostThreshold))
													 && !standingsBehind.Reported) {
					speaker.speakPhrase("ClosingIn", {delta: speaker.number2Speech(delta, 1)
													, lost: speaker.number2Speech(deltaDifference, 1)
													, lapTime: speaker.number2Speech(lapTimeDifference, 1)})

					car := standingsBehind.Car

					this.informSectorDifference(car, "Behind")

					this.handleEvent("AttackImminent", standingsBehind.Car.Nr, Round(delta, 1))

					unsafe := true

					if (car.Incidents > 0)
						speaker.speakPhrase("UnsafeDriveBehind")
					else if ((car.InvalidLaps >= this.DriverCar.InvalidLaps) && (car.InvalidLaps > (car.LastLap / 10)))
						speaker.speakPhrase("InconsistentDriverBehind")
					else
						unsafe := false

					carPitstops := standingsBehind.Car.Pitstops.Length

					if (driverPitstops < carPitstops)
						speaker.speakPhrase("MorePitstops", {conjunction: speaker.Fragments[unsafe ? "But" : "And"], pitstops: carPitstops - driverPitstops})
					else if (driverPitstops > carPitstops)
						speaker.speakPhrase("LessPitstops", {conjunction: speaker.Fragments[unsafe ? "And" : "But"], pitstops: driverPitstops - carPitstops})

					standingsBehind.Reported := true

					standingsBehind.reset(sector, false, true)

					spoken := true
				}
				else if regular {
					lapDifference := standingsBehind.LapDifference[sector]

					if ((lapDifference > 0) && (delta >= behindGapMin) && (delta <= behindGapMax)) {
						if (standingsBehind.closingIn(sector, behindLostThreshold) && !standingsBehind.Reported) {
							speaker.speakPhrase("LostBehind", {delta: (delta > 5) ? Round(delta) : speaker.number2Speech(delta, 1)
															 , lost: speaker.number2Speech(deltaDifference, 1)
															 , lapTime: speaker.number2Speech(lapTimeDifference, 1)
															 , deltaLaps: lapDifference
															 , laps: speaker.Fragments[(lapDifference > 1) ? "Laps" : "Lap"]})

							if !informed
								speaker.speakPhrase("Focus")

							this.handleEvent("BehindGapUpdate", standingsBehind.Car.Nr, Round(delta, 1), true)

							standingsBehind.reset(sector, false, true)

							spoken := true
						}
						else if (standingsBehind.runningAway(sector, behindGainThreshold)) {
							speaker.speakPhrase("GainedBehind", {delta: (delta > 5) ? Round(delta) : speaker.number2Speech(delta, 1)
															   , gained: speaker.number2Speech(deltaDifference, 1)
															   , lapTime: speaker.number2Speech(lapTimeDifference, 1)
															   , deltaLaps: lapDifference
															   , laps: speaker.Fragments[(lapDifference > 1) ? "Laps" : "Lap"]})

							this.handleEvent("BehindGapUpdate", standingsBehind.Car.Nr, Round(delta, 1), false)

							standingsBehind.reset(sector, true, true)

							spoken := true
						}
					}
				}
			}

			if ((focused = standingsAhead) || (focused = standingsBehind))
				focused := false

			if (focused && (method >= kDeltaMethodDynamic)) {
				position := focused.Car.Position["Class"]
				number := focused.Car.Nr
				delta := focused.Delta[false, true, 1]
				deltaDifference := Abs(focused.DeltaDifference[sector])
				lapTimeDifference := Abs(focused.LapTimeDifference)

				if this.Debug[kDebugPositions] {
					info := values2String(", ", values2String("|", this.DriverCar.LapTimes*), this.DriverCar.LapTime[true]
																 , number, focused.Car.InPit, focused.Reported
																 , values2String("|", focused.Car.LapTimes*), focused.Car.LapTime[true]
																 , values2String("|", focused.Car.Deltas[sector]*)
																 , focused.Delta[sector], focused.Delta[false, true, 1]
																 , focused.inFront(), focused.atBehind()
																 , focused.inFront(false), focused.atBehind(false), focused.forPosition()
																 , focused.DeltaDifference[sector], focused.LapTimeDifference[true]
																 , focused.isFaster(sector)
																 , focused.closingIn(sector, behindLostThreshold)
																 , focused.runningAway(sector, behindGainThreshold))

					info := ("=================================`n" . info . "`n=================================`n`n")

					FileAppend(info, kTempDirectory . "Race Spotter.positions")
				}

				lapDifference := focused.LapDifference[sector]

				if (lapDifference > 0)
					if (delta < 0) {
						delta := Abs(delta)

						if (focused.closingIn(sector, behindLostThreshold) && !focused.Reported) {
							speaker.speakPhrase("LostFocusBehind", {delta: (delta > 5) ? Round(delta) : speaker.number2Speech(delta, 1)
																  , lost: speaker.number2Speech(deltaDifference, 1)
																  , lapTime: speaker.number2Speech(lapTimeDifference, 1)
																  , deltaLaps: lapDifference
																  , laps: speaker.Fragments[(lapDifference > 1) ? "Laps" : "Lap"]
																  , indicator: this.getCarIndicatorFragment(speaker, number, position)})

							if !informed
								speaker.speakPhrase("Focus")

							focused.reset(sector, false, true)

							spoken := true
						}
						else if focused.runningAway(sector, behindGainThreshold) {
							speaker.speakPhrase("GainedFocusBehind", {delta: (delta > 5) ? Round(delta) : speaker.number2Speech(delta, 1)
																	, gained: speaker.number2Speech(deltaDifference, 1)
																	, lapTime: speaker.number2Speech(lapTimeDifference, 1)
																	, deltaLaps: lapDifference
																	, laps: speaker.Fragments[(lapDifference > 1) ? "Laps" : "Lap"]
																	, indicator: this.getCarIndicatorFragment(speaker, number, position)})

							focused.reset(sector, true, true)

							spoken := true
						}
					}
					else {
						if (focused.closingIn(sector, frontGainThreshold) && !focused.Reported) {
							speaker.speakPhrase("GainedFocusFront", {delta: (delta > 5) ? Round(delta) : speaker.number2Speech(delta, 1)
																   , gained: speaker.number2Speech(deltaDifference, 1)
																   , lapTime: speaker.number2Speech(lapTimeDifference, 1)
																   , deltaLaps: lapDifference
																   , laps: speaker.Fragments[(lapDifference > 1) ? "Laps" : "Lap"]
																   , indicator: this.getCarIndicatorFragment(speaker, number, position)})

							remaining := Min(knowledgeBase.getValue("Session.Time.Remaining"), knowledgeBase.getValue("Driver.Time.Stint.Remaining"))

							if ((remaining > 0) && (lapTimeDifference > 0))
								if (((remaining / 1000) / this.DriverCar.LapTime[true]) > (delta / lapTimeDifference))
									speaker.speakPhrase("CanDoIt")
								else
									speaker.speakPhrase("CantDoIt")

							focused.reset(sector, false, true)

							spoken := true
						}
						else if (focused.runningAway(sector, frontLostThreshold)) {
							speaker.speakPhrase("LostFocusFront", {delta: (delta > 5) ? Round(delta) : speaker.number2Speech(delta, 1)
																 , lost: speaker.number2Speech(deltaDifference, 1)
																 , lapTime: speaker.number2Speech(lapTimeDifference, 1)
																 , deltaLaps: lapDifference
																 , laps: speaker.Fragments[(lapDifference > 1) ? "Laps" : "Lap"]
																 , indicator: this.getCarIndicatorFragment(speaker, number, position)})

							focused.reset(sector, true, true)

							spoken := true
						}
					}
			}
		}
		finally {
			speaker.endTalk()
		}

		if (!spoken && regular && ((method = kDeltaMethodStatic) || (method = kDeltaMethodBoth))) {
			if ((regular = "S") || (regular = "A"))
				rnd := Random(1, 7)
			else
				rnd := Random(1, 9)

			if (rnd > 6) {
				rnd := Random(1, focused ? 14 : 10)

				if (standingsAhead && (rnd > 3) && (rnd < 11))
					spoken := this.standingsGapToAhead()
				else if (standingsBehind && (rnd <= 3))
					spoken := this.standingsGapToBehind()
				else if (focused && (rnd > 10))
					spoken := this.focusGap()
			}
		}

		if (!spoken && (this.Session == kSessionRace) && ((method = kDeltaMethodStatic) || (method = kDeltaMethodBoth)))
			if (Random(1, 10) > 8) {
				rnd := Random(1, focused ? 133 : 100)

				if ((rnd <= 33) && standingsAhead) {
					lapTime := standingsAhead.LastLapTime
					phrase := "AheadLapTime"
				}
				else if ((rnd > 33) && (rnd <= 66) && standingsBehind) {
					lapTime := standingsBehind.LastLapTime
					phrase := "BehindLapTime"
				}
				else {
					if focused {
						if ((rnd > 66) && (rnd <= 100)) {
							lapTime := focused.LastLapTime
							phrase := "FocusLapTime"
							position := focused.Car.Position["Class"]
							number := focused.Car.Nr
						}
						else if ((rnd > 100) && leader) {
							lapTime := leader.LastLapTime
							phrase := "LeaderLapTime"
						}
					}
					else if ((rnd > 66) && leader) {
						lapTime := leader.LastLapTime
						phrase := "LeaderLapTime"
					}
				}
			}

		if lapTime {
			minute := Floor(lapTime / 60)
			delta := (lapTime - this.DriverCar.LastLapTime)

			speaker := this.getSpeaker()

			speaker.beginTalk()

			try {
				speaker.speakPhrase(phrase, {time: speaker.number2Speech(lapTime, 1), minute: minute
										   , seconds: speaker.number2Speech(lapTime - (minute * 60), 1)
										   , indicator: this.getCarIndicatorFragment(speaker, number, position)})

				if ((Round(Abs(delta), 1) != 0) && (Abs(delta) < 5))
					speaker.speakPhrase("DeltaLapTime", {delta: speaker.number2Speech(Round(Abs(delta), 1))
													   , relativeYou: speaker.Fragments[(delta > 0) ? "Faster" : "Slower"]
													   , relativeOther: speaker.Fragments[(delta < 0) ? "Faster" : "Slower"]})
			}
			finally {
				speaker.endTalk()
			}

			spoken := true
		}

		return spoken
	}

	updateDriver(lastLap, sector, update, newSector, positions) {
		local raceInfo := (this.hasEnoughData(false) && (this.Session = kSessionRace) && (lastLap > 2))
		local hadInfo := false
		local deltaInformation

		static sessionInfo := true

		if this.Speaker[false] {
			if ((lastLap > 1) || (this.Session = kSessionQualification))
				this.updatePositionInfos(lastLap, sector, positions)

			if (this.DriverCar && !this.DriverCar.InPit && update && this.Enabled) {
				if isDebug()
					logMessage(kLogDebug, "UpdateDriver: " . lastLap . ", " . sector . " Driver: " . (this.DriverCar != false) . ", " . (this.DriverCar && this.DriverCar.InPit) . " Race: " . raceInfo)

				deltaInformation := this.Announcements["DeltaInformation"]

				if (raceInfo && (newSector || (deltaInformation = "A"))) {
					if (isNumber(deltaInformation) && (lastLap >= (this.iLastDeltaInformationLap + deltaInformation)))
						this.iLastDeltaInformationLap := lastLap

					hadInfo := this.deltaInformation(lastLap, sector, positions
												   , (deltaInformation = "A") ? "A" : ((deltaInformation = "S") ? "S" : (lastLap = this.iLastDeltaInformationLap))
												   , this.Announcements["DeltaInformationMethod"])
				}

				if (sessionInfo && this.Announcements["SessionInformation"]) {
					hadInfo := this.sessionInformation(lastLap, sector, positions, !hadInfo)

					if hadInfo
						sessionInfo := false
				}
				else
					sessionInfo := true

				if this.Announcements["TacticalAdvices"]
					this.tacticalAdvice(lastLap, sector, positions, !hadInfo)
			}
		}
	}

	pendingAlert(alert, match := false) {
		local ignore, candidate

		if match {
			for ignore, candidate in this.iPendingAlerts
				if InStr(candidate[1], alert)
					return true

			return false
		}
		else
			for ignore, candidate in this.iPendingAlerts
				if (candidate[1] = alert)
					return true
	}

	pendingAlerts(alerts, match := false) {
		local ignore, alert, candidate

		for ignore, alert in alerts
			if match {
				for ignore, candidate in this.iPendingAlerts
					if InStr(candidate[1], alert)
						return true
			}
			else
				for ignore, candidate in this.iPendingAlerts
					if (candidate[1] = alert)
						return true

		return false
	}

	skipAlert(alert) {
		if this.pendingAlerts(["AccidentAhead", "AccidentAheadDistance"
							 , "SlowCarAhead", "SlowCarAheadDistance", "SlowCarAheadSide"], true)
			return true
		else {
			switch alert, false {
				case "Hold":
					return this.pendingAlert("Clear", true)
				case "Left", "ClearLeft":
					return this.pendingAlerts(["ClearAll", "ClearLeft", "Left", "Three"])
				case "Right", "ClearRight":
					return this.pendingAlerts(["ClearAll", "ClearRight", "Right", "Three"])
				case "Three", "Side":
					return this.pendingAlert("Clear", true)
			}

			if (InStr(alert, "Clear") && this.pendingAlerts(["Left", "Right", "Three", "Side", "ClearAll"]))
				return true
			else if (InStr(alert, "Behind") && this.pendingAlerts(["Behind", "Left", "Right", "Three", "Clear"], true))
				return true
			else if (InStr(alert, "Yellow") && this.pendingAlert("Yellow", true))
				return true

			return false
		}
	}

	cleanupAlerts(alert) {
		local nextAlert := this.nextAlert()

		switch alert, false {
			case "Left":
				if ((nextAlert = "ClearLeft") || (nextAlert = "ClearAll"))
					this.popAlert()
			case "ClearLeft":
				if (nextAlert = "Left")
					this.popAlert()
			case "Right":
				if ((nextAlert = "ClearRight") || (nextAlert = "ClearAll"))
					this.popAlert()
			case "ClearRight":
				if (nextAlert = "Right")
					this.popAlert()
		}
	}

	superfluousAlert(alert) {
		return (InStr(alert, "AccidentBehind") && this.pendingAlerts(["Behind", "Left", "Right", "Three", "Clear"], true))
	}

	nextAlert() {
		return ((this.iPendingAlerts.Length > 0) ? this.iPendingAlerts[1] : false)
	}

	pushAlert(alert, arguments*) {
		if !this.superfluousAlert(alert) {
			this.iPendingAlerts.Push(Array(alert, arguments*))

			this.processAlerts(false)
		}
	}

	popAlert() {
		return ((this.iPendingAlerts.Length > 0) ? this.iPendingAlerts.RemoveAt(1) : false)
	}

	processAlerts(async := true) {
		local speaker := this.getSpeaker(true)
		local type, oldPriority, oldAlertProcessing, alert

		if (this.iAlertProcessing || speaker.Speaking)
			if (this.iPendingAlerts.Length > 0) {
				if async {
					Task.CurrentTask.Sleep := 200

					return Task.CurrentTask
				}
				else {
					Task.startTask(ObjBindMethod(this, "processAlerts"), 500, kHighPriority)

					return false
				}
			}
			else
				return false

		oldPriority := Task.block(kHighPriority)
		oldAlertProcessing := this.iAlertProcessing

		this.iAlertProcessing := true

		speaker.Speaking := true

		try {
			while (alert := this.popAlert())
				speaker.speakPhrase(alert*)
		}
		finally {
			speaker.Speaking := false

			this.iAlertProcessing := oldAlertProcessing

			Task.unblock(oldPriority)
		}

		return false
	}

	proximityAlert(alert) {
		if (this.Speaker[false] && this.Running && !this.PrivateSession
		 && ((!InStr(alert, "Behind") && this.Announcements["SideProximity"]) || (InStr(alert, "Behind") && this.Announcements["RearProximity"])))
			this.pushAlert(alert, false, false, alert)
	}

	slowCarAlert(arguments*) {
		local distance, side, speaker

		if (this.Announcements["SlowCars"] && this.Speaker[false] && this.Running && !this.PrivateSession && this.hasEnoughData(false)) {
			if (arguments.Length = 0)
				this.pushAlert("SlowCarAhead", false, false, "SlowCarAhead")
			else {
				distance := (Round(arguments[1] / 50) * 50)

				if (distance > 0) {
					speaker := this.getSpeaker(true)

					if (arguments.Length > 1) {
						side := arguments[2]

						switch side, false {
							case "Left":
								side := string2Values(",", speaker.Fragments["Sides"])[1]
							case "Right":
								side := string2Values(",", speaker.Fragments["Sides"])[2]
							default:
								side := false
						}
					}
					else
						side := false

					this.pushAlert(side ? "SlowCarAheadSide" : "SlowCarAheadDistance", {distance: Round(convertUnit("Length", distance))
																					  , unit: speaker.Fragments[getUnit("Length")], side: side})
				}
			}
		}
	}

	accidentAlert(type, arguments*) {
		local distance := false
		local speaker

		if (((type = "Ahead") || (this.Session = kSessionRace)) && !this.PrivateSession)
			if (this.Announcements["Accidents" . type] && this.Speaker[false] && this.Running && this.hasEnoughData(false)) {
				speaker := this.getSpeaker(true)

				if ((arguments.Length > 0) && (type = "Ahead")) {
					distance := (Round(arguments[1] / 50) * 50)

					if (distance > 0)
						this.pushAlert("Accident" . type . "Distance", {distance: Round(convertUnit("Length", distance))
																	  , unit: speaker.Fragments[getUnit("Length")]})
				}
				else
					this.pushAlert("Accident" . type, false, false, "Accident" . type)
			}
	}

	greenFlag(arguments*) {
		local speaker

		if (this.Speaker[false] && (this.Session = kSessionRace) && this.Running
		 && !this.PrivateSession && (!this.KnowledgeBase || this.KnowledgeBase.getValue("Lap", 0) <= 1))
			this.pushAlert("Green", false, false, "Green")
	}

	yellowFlag(alert, arguments*) {
		local sectors

		if (this.Announcements["YellowFlags"] && this.Speaker[false] && this.Running && !this.PrivateSession) {
			sectors := string2Values(",", this.getSpeaker(true).Fragments["Sectors"])

			switch alert, false {
				case "All":
					this.pushAlert("YellowAll", false, false, "YellowAll")
				case "Sector":
					if (arguments.Length > 1)
						this.pushAlert("YellowDistance", {sector: sectors[arguments[1]], distance: arguments[2]})
					else
						this.pushAlert("YellowSector", {sector: sectors[arguments[1]]})
				case "Clear":
					this.pushAlert("YellowClear", false, false, "YellowClear")
				case "Ahead":
					this.pushAlert("YellowAhead", false, false, "YellowAhead")
			}
		}
	}

	blueFlag() {
		local positions := this.Positions
		local knowledgeBase := this.KnowledgeBase
		local delta

		if (this.Announcements["BlueFlags"] && this.Speaker[false] && this.Running && !this.PrivateSession) {
			if ((this.Session = kSessionRace) && positions.Has("StandingsBehind") && positions.Has(positions["StandingsBehind"])) {
				delta := Abs(positions[positions["StandingsBehind"]][10])

				if (delta && (delta < 2000))
					this.pushAlert("BlueForPosition", false, false, "BlueForPosition")
				else
					this.pushAlert("Blue", false, false, "Blue")
			}
			else
				this.pushAlert("Blue", false, false, "Blue")

			this.handleEvent("BlueFlagAlert")
		}
	}

	pitWindow(state) {
		if (this.Announcements["PitWindow"] && this.Speaker[false] && (this.Session = kSessionRace) && this.Running)
			if (state = "Open")
				this.pushAlert("PitWindowOpen", false, false, "PitWindowOpen")
			else if (state = "Closed")
				this.pushAlert("PitWindowClosed", false, false, "PitWindowClosed")
	}

	speedUpdate(lastSpeed) {
		if lastSpeed {
			this.iLastTopSpeed := Round(lastSpeed, 1)
			this.iBestTopSpeed := Max(this.LastTopSpeed, this.BestTopSpeed)
		}
	}

	disableSpotter() {
		this.updateDynamicValues({Enabled: false})
	}

	enableSpotter() {
		this.updateDynamicValues({Enabled: true})
	}

	internalError(arguments*) {
		if isDebug()
			showMessage("Internal error: " . values2String(A_Space, arguments*))
	}

	debugMessage(arguments*) {
		MsgBox("Debug: " . values2String(A_Space, arguments*))
	}

	startupSpotter(forceShutdown := false) {
		local pid := false
		local code, exePath, trackData, traceFile

		if !this.iSpotterPID {
			code := this.SettingsDatabase.getSimulatorCode(this.Simulator)

			exePath := (kBinariesDirectory . "Providers\" . code . " SHM Spotter.exe")

			if FileExist(exePath) {
				this.shutdownSpotter(forceShutdown)

				trackData := this.SettingsDatabase.getTrackData(this.Simulator, this.Track)

				if isDebug()
					deleteFile(kTempDirectory . "Race Spotter.trace")

				deleteFile(kTempDirectory . "Race Spotter.semaphore")

				try {
					Run("`"" . exePath . "`" " . this.TrackLength . A_Space
											   . getMultiMapValue(this.Settings, "Assistant.Spotter", "Accident.Distance.Ahead.Threshold", 800) . A_Space
											   . getMultiMapValue(this.Settings, "Assistant.Spotter", "Accident.Distance.Behind.Threshold", 500) . A_Space
											   . getMultiMapValue(this.Settings, "Assistant.Spotter", "SlowCar.Distance.Ahead.Threshold", 500) . A_Space
											   . ("`"" . kTempDirectory . "Race Spotter.semaphore`"") . A_Space
											   . getMultiMapValue(this.Settings, "Assistant.Spotter", "Activation.Speed", 60) . A_Space
											   . (isDebug() ? ("`"" . kTempDirectory . "Race Spotter.trace`"") : "-")
											   . (trackData ? (" `"" . trackData . "`"") : "")
					  , kBinariesDirectory, "Hide", &pid)
				}
				catch Any as exception {
					logError(exception, true)

					logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Spotter (")
															   , {simulator: code, protocol: "SHM"})
										   . exePath . translate(") - please rebuild the applications in the binaries folder (")
										   . kBinariesDirectory . translate(")"))

					if !kSilentMode
						showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Spotter (%exePath%) - please check the configuration...")
													  , {exePath: exePath, simulator: code, protocol: "SHM"})
								  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				}

				if pid
					this.iSpotterPID := pid
			}
		}

		return false
	}

	shutdownSpotter(force := false, arguments*) {
		local pid := this.iSpotterPID
		local tries

		if ((arguments.Length > 0) && inList(["Logoff", "Shutdown"], arguments[1]))
			return false

		if pid {
			ProcessClose(pid)

			if (force && ProcessExist(pid)) {
				Sleep(500)

				tries := 5

				while (tries-- > 0) {
					pid := ProcessExist(pid)

					if pid {
						ProcessClose(pid)

						Sleep(500)
					}
					else
						break
				}
			}
		}

		this.iSpotterPID := false

		return false
	}

	initializeAnnouncements() {
		local configuration := this.Configuration
		local announcements := CaseInsenseMap()
		local ignore, key, default

		for ignore, key in ["TacticalAdvices", "SideProximity", "RearProximity", "YellowFlags", "BlueFlags"
						  , "PitWindow", "SessionInformation", "CutWarnings", "PenaltyInformation"
						  , "SlowCars", "AccidentsAhead", "AccidentsBehind"]
			announcements[key] := getMultiMapValue(configuration, "Race Spotter Announcements", this.Simulator . "." . key, true)

		default := getMultiMapValue(configuration, "Race Spotter Announcements", this.Simulator . ".PerformanceUpdates", 2)
		default := getMultiMapValue(configuration, "Race Spotter Announcements", this.Simulator . ".DistanceInformation", default)

		announcements["DeltaInformation"] := getMultiMapValue(configuration, "Race Spotter Announcements"
																		   , this.Simulator . ".DeltaInformation", default)
		announcements["DeltaInformationMethod"] := inList(["Static", "Dynamic", "Both"]
														, getMultiMapValue(configuration, "Race Spotter Announcements"
																						, this.Simulator . ".DeltaInformationMethod", "Both"))

		this.updateConfigurationValues({Announcements: announcements})
	}

	initializeTacticalAdvices(full := true) {
		this.TacticalAdvices := CaseInsenseMap()
	}

	initializeSessionInfos(full := true) {
		local sessionInfos := CaseInsenseMap()
		local key, value, ignore, candidate

		static retainedInfos := ["StartSummary", "HalfTime", "BestLap", "BestSpeed"]

		if !full {
			for key, value in this.SessionInfos
				for ignore, candidate in retainedInfos
					if InStr(key, candidate)
						sessionInfos[key] := value
		}

		this.SessionInfos := sessionInfos
	}

	initializeHistory(full := true) {
		this.iDriverCar := false
		this.OtherCars := CaseInsenseMap()
		this.PositionInfos := CaseInsenseMap()
		this.iLastDeltaInformationLap := 0
		this.iLastPenalty := false

		this.initializeTacticalAdvices(full)
		this.initializeSessionInfos(full)

		this.iNextDriverUpdate := (A_TickCount + this.DriverUpdateTime)

		this.iBestTopSpeed := false
		this.iLastTopSpeed := false
	}

	prepareSession(&settings, &data, formationLap := true) {
		local prepared := this.Prepared
		local speaker, fragments
		local facts, weather, airTemperature, trackTemperature, weatherNow, weather10Min, weather30Min, driver
		local position, length, facts, private

		facts := super.prepareSession(&settings, &data, formationLap)

		if !prepared {
			if settings {
				if (this.Session = kSessionQualification)
					private := getMultiMapValue(settings, "Assistant.Spotter", "Qualification.Private", false)
				else if (this.Session = kSessionPractice)
					private := getMultiMapValue(settings, "Assistant.Spotter", "Practice.Private", false)
				else
					private := false

				this.updateConfigurationValues({UseTalking: getMultiMapValue(settings, "Assistant.Spotter", "Voice.UseTalking", false)
											  , PrivateSession: private})
			}

			this.initializeAnnouncements()

			if (formationLap && this.Speaker[false] && (this.TrackType = "Circuit")) {
				speaker := this.getSpeaker()
				fragments := speaker.Fragments

				speaker.beginTalk()

				try {
					speaker.speakPhrase("GreetingIntro")

					airTemperature := Round(getMultiMapValue(data, "Weather Data", "Temperature", 0))
					trackTemperature := Round(getMultiMapValue(data, "Track Data", "Temperature", 0))

					if (airTemperature = 0)
						airTemperature := Round(getMultiMapValue(data, "Car Data", "AirTemperature", 0))

					if (trackTemperature = 0)
						trackTemperature := Round(getMultiMapValue(data, "Car Data", "RoadTemperature", 0))

					weatherNow := getMultiMapValue(data, "Weather Data", "Weather", "Dry")
					weather10Min := getMultiMapValue(data, "Weather Data", "Weather10Min", "Dry")
					weather30Min := getMultiMapValue(data, "Weather Data", "Weather30Min", "Dry")

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

					speaker.speakPhrase("GreetingWeather", {weather: weather
														  , air: displayValue("Float", convertUnit("Temperature", airTemperature), 0)
														  , track: displayValue("Float", convertUnit("Temperature", trackTemperature), 0)
														  , unit: fragments[getUnit("Temperature")]})

					if ((this.Session = kSessionRace) && (getMultiMapValue(data, "Position Data", "Car.Count", 0) > 0)) {
						driver := getMultiMapValue(data, "Position Data", "Driver.Car", false)
						position := this.getPosition(driver, "Overall", data)

						if (driver && position && this.GridPosition)
							speaker.speakPhrase("GreetingPosition", {position: position
																   , overall: this.MultiClass[data] ? speaker.Fragments["Overall"] : ""})

						if (getMultiMapValue(data, "Session Data", "SessionFormat", "Time") = "Time") {
							length := Round(getMultiMapValue(data, "Session Data", "SessionTimeRemaining", 0) / 60000)

							if (length > 0)
								speaker.speakPhrase("GreetingDuration", {minutes: length})
						}
						else {
							length := this.SessionLaps

							if (length = 0)
								length := getMultiMapValue(data, "Session Data", "SessionLapsRemaining", 0)

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
			Task.startTask(ObjBindMethod(this, "updateSessionValues", {Running: true}), 10000)
		}

		return facts
	}

	startSession(settings, data) {
		local configuration := this.Configuration
		local joined := false
		local simulatorName, configuration, saveSettings, facts

		if !this.Prepared
			joined := true

		facts := this.prepareSession(&settings, &data, false)

		if this.Debug[kDebugPositions]
			deleteFile(kTempDirectory . "Race Spotter.positions")

		if (joined && this.Speaker[false])
			this.getSpeaker().speakPhrase("GreetingIntro")

		simulatorName := this.Simulator

		if (ProcessExist("Race Engineer.exe") > 0)
			saveSettings := kNever
		else {
			if (ProcessExist("Race Strategist.exe") > 0)
				saveSettings := kNever
			else
				saveSettings := getMultiMapValue(configuration, "Race Assistant Shutdown", simulatorName . ".SaveSettings")
		}

		this.updateConfigurationValues({LearningLaps: getMultiMapValue(configuration, "Race Spotter Analysis", simulatorName . ".LearningLaps", 1)
									  , DriverUpdateTime: (getMultiMapValue(configuration, "Race Spotter Announcements", simulatorName . ".DriverUpdateTime", 0) * 1000)
									  , SaveSettings: saveSettings})

		this.updateDynamicValues({KnowledgeBase: this.createKnowledgeBase(facts)
								, BestLapTime: 0, OverallTime: 0
								, LastFuelAmount: 0, InitialFuelAmount: 0, LastEnergyAmount: 0, InitialEnergyAmount: 0
								, EnoughData: false})

		this.initializeHistory()
		; this.initializeGridPosition(data)

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

		if knowledgeBase {
			if (shutdown && (knowledgeBase.getValue("Lap", 0) > this.LearningLaps)) {
				this.shutdownSession("Before")

				if ((this.SaveSettings == kAsk) && (this.Session == kSessionRace)) {
					if this.Speaker[false] {
						this.getSpeaker().speakPhrase("ConfirmSaveSettings", false, true)

						this.setContinuation(ObjBindMethod(this, "shutdownSession", "After", true))

						Task.startTask(ObjBindMethod(this, "forceFinishSession"), 120000, kLowPriority)

						return
					}
				}

				this.shutdownSession("After")
			}

			this.shutdownSpotter(true)

			this.updateDynamicValues({KnowledgeBase: false, Prepared: false})
		}

		this.updateDynamicValues({OverallTime: 0, BestLapTime: 0
								, LastFuelAmount: 0, InitialFuelAmount: 0, LastEnergyAmount: 0, InitialEnergyAmount: 0
								, EnoughData: false})
		this.updateSessionValues({Simulator: "", Car: "", Track: "", Session: kSessionFinished, SessionTime: false})
	}

	forceFinishSession() {
		if !this.SessionDataActive {
			this.updateDynamicValues({KnowledgeBase: false, Prepared: false})

			this.finishSession()

			return false
		}
		else {
			Task.CurrentTask.Sleep := 5000

			return Task.CurrentTask
		}
	}

	createSessionInfo(lapNumber, valid, data, simulator, car, track) {
		local knowledgeBase := this.KnowledgeBase
		local sessionInfo := super.createSessionInfo(lapNumber, valid, data, simulator, car, track)
		local position, classPosition

		if knowledgeBase {
			car := this.FocusedCar[true]

			if car {
				car := car.Car

				setMultiMapValue(sessionInfo, "Standings", "Focus.Nr", car.Nr)
				setMultiMapValue(sessionInfo, "Standings", "Focus.Lap.Time", car.LastLapTime)
				setMultiMapValue(sessionInfo, "Standings", "Focus.Laps", car.LastLap)
				setMultiMapValue(sessionInfo, "Standings", "Focus.Delta", car.LastDelta)
				setMultiMapValue(sessionInfo, "Standings", "Focus.InPit", car.InPit)
			}

			if this.LastTopSpeed
				setMultiMapValue(sessionInfo, "Stint", "Speed.Last", Round(this.LastTopSpeed, 1))

			if this.BestTopSpeed
				setMultiMapValue(sessionInfo, "Stint", "Speed.Best", Round(this.BestTopSpeed, 1))
		}

		return sessionInfo
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

	addLap(lapNumber, &data) {
		local knowledgeBase := this.KnowledgeBase
		local lastPenalty := false
		local wasValid := true
		local lastWarnings := 0
		local laps, lastPitstop, result
		local simulator, car, track

		if knowledgeBase {
			lastPenalty := knowledgeBase.getValue("Lap.Penalty", false)
			wasValid := knowledgeBase.getValue("Lap.Valid", true)
			lastWarnings := knowledgeBase.getValue("Lap.Warnings", 0)
		}

		result := super.addLap(lapNumber, &data)

		if !this.MultiClass
			this.adjustGaps(data)

		loop knowledgeBase.getValue("Car.Count") {
			laps := knowledgeBase.getValue("Car." . A_Index . ".Laps", knowledgeBase.getValue("Car." . A_Index . ".Lap", 0))

			if (laps != knowledgeBase.getValue("Car." . A_Index . ".Valid.LastLap", 0)) {
				knowledgeBase.setFact("Car." . A_Index . ".Valid.LastLap", laps)

				if (knowledgeBase.getValue("Car." . A_Index . ".Lap.Valid", kUndefined) == kUndefined)
					knowledgeBase.setFact("Car." . A_Index . ".Lap.Valid", knowledgeBase.getValue("Car." . A_Index . ".Valid.Running", true))

				if knowledgeBase.getValue("Car." . A_Index . ".Lap.Valid", true)
					knowledgeBase.setFact("Car." . A_Index . ".Valid.Laps", knowledgeBase.getValue("Car." . A_Index . ".Valid.Laps", 0) + 1)
			}
		}

		lastPitstop := knowledgeBase.getValue("Pitstop.Last", false)

		if (lastPitstop && (Abs(lapNumber - lastPitstop) <= 2))
			this.initializeHistory(false)

		if this.SessionInfos.Has("LastLap")
			this.handleEvent("SessionOver")

		if this.Speaker[false]
			if (!this.Announcements["PenaltyInformation"] || !this.penaltyInformation(lapNumber, getMultiMapValue(data, "Stint Data", "Sector", 0), lastPenalty))
				if (this.Announcements["CutWarnings"] && this.hasEnoughData(false))
					this.cutWarning(lapNumber, getMultiMapValue(data, "Stint Data", "Sector", 0), wasValid, lastWarnings)

		simulator := knowledgeBase.getValue("Session.Simulator")
		car := knowledgeBase.getValue("Session.Car")
		track := knowledgeBase.getValue("Session.Track")

		Task.startTask((*) => this.saveSessionInfo(lapNumber, simulator, car, track
												 , this.createSessionInfo(lapNumber, knowledgeBase.getValue("Lap." . lapNumber . ".Valid", true)
																		, data, simulator, car, track))
					 , 1000, kLowPriority)

		return result
	}

	updateLap(lapNumber, &data) {
		local knowledgeBase := this.KnowledgeBase
		local lastPenalty := knowledgeBase.getValue("Lap.Penalty", false)
		local wasValid := knowledgeBase.getValue("Lap.Valid", true)
		local lastWarnings := knowledgeBase.getValue("Lap.Warnings", 0)
		local hasGaps := false
		local sector, result, valid, gapAhead, gapBehind
		local simulator, car, track

		static lastLap := 0
		static lastSector := -1
		static sectorIndex := 1
		static newSector := false

		if (lapNumber > this.LastLap) {
			this.updateDynamicValues({EnoughData: false})

			lastLap := 0
			lastSector := -1
			sectorIndex := 1
		}
		else if (lapNumber < lastLap) {
			lastLap := 0
			lastSector := -1
			sectorIndex := 1
		}

		if !isObject(data)
			data := readMultiMap(data)

		sector := getMultiMapValue(data, "Stint Data", "Sector", 0)

		if (sector != lastSector) {
			lastSector := sector
			sectorIndex := 1

			newSector := true
		}

		knowledgeBase.setFact("Sector", sector)

		sector := (sector . "." . sectorIndex++)

		if !this.MultiClass
			hasGaps := this.adjustGaps(data, &gapAhead, &gapBehind)

		if isDebug()
			logMessage(kLogDebug, "UpdateLap: " . lapNumber . ", " . this.LastLap . " Sector: " . sector ", " . newSector)

		if (lapNumber = this.LastLap) {
			this.iPositions := this.computePositions(data, hasGaps ? gapAhead : false, hasGaps ? gapBehind : false)

			if this.DriverUpdateTime {
				if (A_TickCount >= this.iNextDriverUpdate) {
					this.updateDriver(lapNumber, sector, true, newSector, this.Positions)

					this.iNextDriverUpdate := (A_TickCount + this.DriverUpdateTime)

					newSector := false
				}
				else
					this.updateDriver(lapNumber, sector, false, false, this.Positions)
			}
			else {
				this.updateDriver(lapNumber, sector, true, newSector, this.Positions)

				newSector := false
			}
		}

		result := super.updateLap(lapNumber, &data)

		loop knowledgeBase.getValue("Car.Count") {
			valid := knowledgeBase.getValue("Car." . A_Index . ".Lap.Running.Valid", kUndefined)

			if (valid == false)
				knowledgeBase.setFact("Car." . A_Index . ".Valid.Running", valid)
		}

		if this.Speaker[false]
			if (!this.Announcements["PenaltyInformation"] || !this.penaltyInformation(lapNumber, getMultiMapValue(data, "Stint Data", "Sector", 0), lastPenalty))
				if (this.Announcements["CutWarnings"] && this.hasEnoughData(false))
					this.cutWarning(lapNumber, getMultiMapValue(data, "Stint Data", "Sector", 0), wasValid, lastWarnings)

		simulator := knowledgeBase.getValue("Session.Simulator")
		car := knowledgeBase.getValue("Session.Car")
		track := knowledgeBase.getValue("Session.Track")

		Task.startTask((*) => this.saveSessionInfo(lapNumber, simulator, car, track
												 , this.createSessionInfo(lapNumber, knowledgeBase.getValue("Lap." . lapNumber . ".Valid", true)
																		, data, simulator, car, track))
					 , 1000, kLowPriority)

		return result
	}

	computePositions(data, gapAhead, gapBehind) {
		local knowledgeBase := this.KnowledgeBase
		local carPositions := []
		local driver := getMultiMapValue(data, "Position Data", "Driver.Car", 0)
		local count := getMultiMapValue(data, "Position Data", "Car.Count", 0)
		local notAlone := (count > 1)
		local carPositions := []
		local positions := CaseInsenseWeakMap()
		local trackAhead := false
		local trackBehind := false
		local standingsAhead := false
		local standingsBehind := false
		local leader := false
		local hasDriver := false
		local index, car, prefix, inPit, lapTime, driverLaps, driverRunning, carIndex, carLaps, carRunning
		local driverClassPosition, carOverallPosition, carClassPosition, carDelta, carAheadDelta, carBehindDelta
		local classes, class, carClassPositions, ignore, sectorTimes

		if (driver && count) {
			classes := CaseInsenseMap()
			carClassPositions := []

			loop count {
				class := this.getClass(A_Index, data)

				if !classes.Has(class)
					classes[class] := [Array(A_Index, this.getPosition(A_Index, "Overall", data))]
				else
					classes[class].Push(Array(A_Index, this.getPosition(A_Index, "Overall", data)))

				carClassPositions.Push(false)
			}

			for ignore, class in classes {
				bubbleSort(&class, compareClassPositions)

				for carClassPosition, car in class
					carClassPositions[car[1]] := carClassPosition
			}

			loop count {
				carLaps := getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Laps", getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Lap"))
				carRunning := getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Lap.Running")

				if (A_Index = driver) {
					hasDriver := true

					driverLaps := carLaps
					driverRunning := carRunning
				}

				carPositions.Push(Array(A_Index, carLaps, carRunning))
			}

			if hasDriver {
				bubbleSort(&carPositions, (a, b) => a[3] < b[3])

				positions["Driver"] := driver
				positions["Count"] := count

				driverClassPosition := carClassPositions[driver]
				class := this.getClass(driver, data)
				lapTime := getMultiMapValue(data, "Position Data", "Car." . driver . ".Time")

				for index, car in carPositions {
					carIndex := car[1]
					carLaps := car[2]
					carRunning := car[3]

					prefix := ("Car." . carIndex)

					try {
						carOverallPosition := this.getPosition(carIndex, "Overall", data)
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
					}
					catch Any as exception {
						logError(exception)

						carDelta := false
						carAheadDelta := false
						carBehindDelta := false
					}

					inPit := (getMultiMapValue(data, "Position Data", prefix . ".InPitLane", false)
						   || getMultiMapValue(data, "Position Data", prefix . ".InPit", false))

					sectorTimes := getMultiMapValue(data, "Position Data", prefix . ".Time.Sectors", false)

					if (sectorTimes && (sectorTimes != "")) {
						sectorTimes := string2Values(",", sectorTimes)

						loop sectorTimes.Length
							if isNumber(sectorTimes[A_Index])
								sectorTimes[A_Index] := Round(sectorTimes[A_Index] / 1000, 1)
							else {
								sectorTimes := false

								break
							}
					}
					else
						sectorTimes := false

					positions[carIndex] := Array(getMultiMapValue(data, "Position Data", prefix . ".Nr", "-")
											   , getMultiMapValue(data, "Position Data", prefix . ".Car", "Unknown")
											   , this.getClass(carIndex, data)
											   , driverName(getMultiMapValue(data, "Position Data", prefix . ".Driver.Forname", "John")
														  , getMultiMapValue(data, "Position Data", prefix . ".Driver.Surname", "Doe")
														  , getMultiMapValue(data, "Position Data", prefix . ".Driver.Nickname", "JD"))
											   , carOverallPosition, carClassPosition
											   , carLaps, carRunning
											   , getMultiMapValue(data, "Position Data", prefix . ".Time")
											   , carDelta, carAheadDelta, carBehindDelta
											   , getMultiMapValue(data, "Position Data", prefix . ".Lap.Valid"
																	  , getMultiMapValue(data, "Position Data", prefix . ".Lap.Running.Valid", true))
											   , knowledgeBase.getValue(prefix . ".Valid.Laps", carLaps)
											   , getMultiMapValue(data, "Position Data", prefix . ".Incidents", 0)
											   , inPit
											   , getMultiMapValue(data, "Position Data", prefix . ".ID", carIndex)
											   , sectorTimes
											   , !getMultiMapValue(data, "Position Data", prefix . ".Lap.Running.Valid", true))

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

				if trackAhead
					trackAhead := carPositions[trackAhead][1]

				if trackBehind
					trackBehind := carPositions[trackBehind][1]

				if (gapAhead && standingsAhead) {
					positions[standingsAhead][10] := gapAhead

					if (standingsAhead = trackAhead)
						positions[trackAhead][10] := gapAhead
				}

				if (gapBehind && standingsBehind) {
					positions[standingsBehind][10] := gapBehind

					if (standingsBehind = trackBehind)
						positions[trackBehind][10] := gapBehind
				}

				positions["Position.Overall"] := this.getPosition(driver, "Overall", data)
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
		this.initializeHistory(false)

		return super.executePitstop(lapNumber)
	}

	shutdownSession(phase, confirmed := false) {
		this.iSessionDataActive := true

		try {
			if (((phase = "After") && (this.SaveSettings = kAsk) && confirmed) || ((phase = "Before") && (this.SaveSettings = kAlways)))
				if (this.Session == kSessionRace)
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
;;;                  Internal Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

resetReferenceTrack(context) {
	loop 5
		try {
			FileAppend("Reset", kTempDirectory . "Race Spotter.semaphore")

			break
		}
		catch Any as exception {
			logError(exception)

			Sleep(Random(1, 10) * 10)
		}

	return true
}