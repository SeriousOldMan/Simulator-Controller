;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Telemetry Analyzer              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\JSON.ahk"
#Include "..\..\Libraries\Math.ahk"
#Include "TelemetryCollector.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class Section {
	iTrackSection := false

	Type {
		Get {
			throw "Virtual property Section.Type must be implemented in a subclass..."
		}
	}

	TrackSection {
		Get {
			return this.iTrackSection
		}
	}

	Nr {
		Get {
			return this.TrackSection.Nr
		}
	}

	Length {
		Get {
			return this.TrackSection.Length
		}
	}

	Time {
		Get {
			throw "Virtual property Section.Time must be implemented in a subclass..."
		}
	}

	MinG {
		Get {
			throw "Virtual property Section.MinG must be implemented in a subclass..."
		}
	}

	MaxG {
		Get {
			throw "Virtual property Section.MaxG must be implemented in a subclass..."
		}
	}

	AvgG {
		Get {
			throw "Virtual property Section.AvgG must be implemented in a subclass..."
		}
	}

	MinSpeed {
		Get {
			throw "Virtual property Section.MinSpeed must be implemented in a subclass..."
		}
	}

	MaxSpeed {
		Get {
			throw "Virtual property Section.MaxSpeed must be implemented in a subclass..."
		}
	}

	AvgSpeed {
		Get {
			throw "Virtual property Section.AvgSpeed must be implemented in a subclass..."
		}
	}

	Descriptor {
		Get {
			return {Type: this.Type, Length: (nullRound(this.Length, 1) . " Meter")
				  , Time: (nullRound(this.Time / 1000, 2) . " Seconds")}
		}
	}

	JSON {
		Get {
			return JSON.print(this.Descriptor, "  ")
		}
	}

	__New(trackSection) {
		this.iTrackSection := trackSection
	}
}

class Corner extends Section {
	iDirection := "Left"				; OneOf("Left", "Right")
	iCurvature := 0.0					; Higher values -> sharper corner

	iBrakingStart := 0					; Distance into the track, where braking starts
	iRollingStart := 0					; Distance into the track, where accelerating starts
	iAcceleratingStart := 0				; Distance into the track, where accelerating starts

	iBrakingTime := 0					; Time of the braking phase in meters
	iRollingTime := 0					; Time of the rolling phase in meters
	iAcceleratingTime := 0				; Time of the acceleration phase in meters

	iBrakingLength := 0					; Length of the braking phase in meters
	iRollingLength := 0					; Length of the rolling phase in meters
	iAcceleratingLength := 0			; Length of the acceleration phase in meters

	iRollingGear := 0					; Min gear during rolling phase
	iRollingRPM := 0					; Min RPM during rolling phase

	iAcceleratingGear := 0				; Gear at start of the accelerating phase
	iAcceleratingRPM := 0				; RPM at start of the accelarating phase
	iAcceleratingSpeed := 0				; Speed at the end of the accelerating phase

	iMinG := 0							; Min G Force around apex (rolling phase)
	iMaxG := 0							; Max G Force around apex (rolling phase)
	iAvgG := 0							; Avg G Force around apex (rolling phase)
	iMinSpeed := 0						; Min Speed around apex (rolling phase)
	iMaxSpeed := 0						; Max Speed around apex (rolling phase)
	iAvgSpeed := 0						; Avg Speed around apex (rolling phase)

	iTCActivations := 0					; # of TC activations (each meter is one tick)
	iABSActivations := 0				; # of ABS activations (each meter is one tick)

	iMaxBrakePressure := 0				; Percentage
	iBrakePressureRampUp := 0			; Meters

	iSteeringCorrections:= 0			; Count
	iThrottleCorrections:= 0			; Count
	iBrakeCorrections:= 0				; Count

	iSteeringSmoothness := 0			; Percentage
	iThrottleSmoothness := 0			; Percentage
	iBrakeSmoothness := 0				; Percentage

	Type {
		Get {
			return "Corner"
		}
	}

	Direction {
		Get {
			return this.iDirection
		}
	}

	Curvature {
		Get {
			return this.iCurvature
		}
	}

	Time[part := "Overall"] {
		Get {
			if (part = "Overall")
				return (this.iBrakingTime + this.iRollingTime + this.iAcceleratingTime)
			else if ((part = "Entry") || (part = "Braking"))
				return this.iBrakingTime
			else if ((part = "Apex") || (part = "Rolling"))
				return this.iRollingTime
			else if ((part = "Exit") || (part = "Accelerating"))
				return this.iAcceleratingTime
			else
				return 0
		}
	}

	Start[part := "Overall"] {
		Get {
			if (part = "Overall")
				return Min(nullZero(this.iBrakingStart), nullZero(this.iRollingStart), nullZero(this.iAcceleratingStart))
			else if ((part = "Entry") || (part = "Braking"))
				return nullZero(this.iBrakingStart)
			else if ((part = "Apex") || (part = "Rolling"))
				return nullZero(this.iRollingStart)
			else if ((part = "Exit") || (part = "Accelerating"))
				return nullZero(this.iAcceleratingStart)
			else
				return 0
		}
	}

	Length[part := "Overall"] {
		Get {
			if (part = "Overall")
				return (this.iBrakingLength + this.iRollingLength + this.iAcceleratingLength)
			else if ((part = "Entry") || (part = "Braking"))
				return this.iBrakingLength
			else if ((part = "Apex") || (part = "Rolling"))
				return this.iRollingLength
			else if ((part = "Exit") || (part = "Accelerating"))
				return this.iAcceleratingLength
			else
				return 0
		}
	}

	RollingGear {
		Get {
			return this.iRollingGear
		}
	}

	RollingRPM {
		Get {
			return this.iRollingRPM
		}
	}

	AcceleratingGear {
		Get {
			return this.iAcceleratingGear
		}
	}

	AcceleratingRPM {
		Get {
			return this.iAcceleratingRPM
		}
	}

	AcceleratingSpeed {
		Get {
			return this.iAcceleratingSpeed
		}
	}

	MinG {
		Get {
			return this.iMinG
		}
	}

	MaxG {
		Get {
			return this.iMaxG
		}
	}

	AvgG {
		Get {
			return this.iAvgG
		}
	}

	MinSpeed {
		Get {
			return this.iMinSpeed
		}
	}

	MaxSpeed {
		Get {
			return this.iMaxSpeed
		}
	}

	AvgSpeed {
		Get {
			return this.iAvgSpeed
		}
	}

	BrakingStart {
		Get {
			return this.iBrakingStart
		}
	}

	AcceleratingStart {
		Get {
			return this.iAcceleratingStart
		}
	}

	MaxBrakePressure {
		Get {
			return this.iMaxBrakePressure
		}
	}

	BrakePressureRampUp {
		Get {
			return this.iBrakePressureRampUp
		}
	}

	TCActivations {
		Get {
			return this.iTCActivations
		}
	}

	ABSActivations {
		Get {
			return this.iABSActivations
		}
	}

	SteeringSmoothness {
		Get {
			return this.iSteeringSmoothness
		}
	}

	SteeringCorrections {
		Get {
			return this.iSteeringCorrections
		}
	}

	ThrottleSmoothness {
		Get {
			return this.iThrottleSmoothness
		}
	}

	ThrottleCorrections {
		Get {
			return this.iThrottleCorrections
		}
	}

	BrakeSmoothness {
		Get {
			return this.iBrakeSmoothness
		}
	}

	BrakeCorrections {
		Get {
			return this.iBrakeCorrections
		}
	}

	Descriptor {
		Get {
			local descriptor := super.Descriptor

			descriptor.Nr := this.Nr
			descriptor.Direction := this.Direction
			descriptor.Curvature := Round(this.Curvature, 2)

			if this.Start["Entry"]
				descriptor.Entry := {Phase: "Braking"
								   , Start: (Round(this.Start["Entry"], 1) . " Meter")
								   , Length: (nullRound(this.Length["Entry"], 1) . " Meter")
								   , Duration: (nullRound(this.Time["Entry"] / 1000, 2) . " Seconds")
								   , MaxBrakePressure: (Round(this.MaxBrakePressure) . " Percent")
								   , BrakePressureRampUp: (Round(this.BrakePressureRampUp, 1) . " Meter")
								   , ABSActivations: this.ABSActivations
								   , BrakeCorrections: this.BrakeCorrections
								   , BrakeSmoothness: (nullRound(this.BrakeSmoothness) . " Percent")}

			if (this.Start["Apex"] != kNull)
				descriptor.Apex := {Phase: "Rolling"
								  , Start: (Round(this.Start["Apex"], 1) . " Meter")
								  , Length: (nullRound(this.Length["Apex"], 1) . " Meter")
								  , Duration: (nullRound(this.Time["Apex"] / 1000, 2) . " Seconds")
								  , Gear: this.RollingGear
								  , RPM: this.RollingRPM
								  , G: nullRound(this.AvgG, 2)
								  , Speed: (nullRound(this.MinSpeed) . " km/h")}
			else
				descriptor.Apex := {Phase: "Rolling"
								  , G: nullRound(this.AvgG, 2)
								  , Speed: (nullRound(this.MinSpeed) . " km/h")}

			if (this.Start["Exit"] != kNull) {
				descriptor.Exit := {Phase: "Accelerating"
								  , Start: (Round(this.Start["Entry"], 1) . " Meter")
								  , Length: (nullRound(this.Length["Exit"], 1) . " Meter")
								  , Duration: (nullRound(this.Time["Exit"] / 1000, 2) . " Seconds")
								  , Gear: this.AcceleratingGear
								  , RPM: this.AcceleratingRPM
								  , Speed: this.AcceleratingSpeed
								  , TCActivations: this.TCActivations
								  , ThrottleCorrections: this.ThrottleCorrections
								  , ThrottleSmoothness: (nullRound(this.ThrottleSmoothness) . " Percent")}
			}

			descriptor.SteeringCorrections := this.SteeringCorrections
			descriptor.SteeringSmoothness := (nullRound(this.SteeringSmoothness) . " Percent")

			return descriptor
		}
	}

	__New(trackSection, direction, curvature
					  , brakingStart, brakingTime, brakingLength, maxBrakePressure, brakePressureRampUp
					  , rollingStart, rollingTime, rollingLength
					  , accelerationStart, acceleratingTime, acceleratingLength
					  , rollingGear, rollingRPM, acceleratingGear, acceleratingRPM, acceleratingSpeed
					  , minG, maxG, avgG, minSpeed, maxSpeed, avgSpeed, tcActivations, absActivations
					  , steeringCorrections, steeringSmoothness
					  , throttleCorrections, throttleSmoothness
					  , brakeCorrections, brakeSmoothness) {
		super.__New(trackSection)

		this.iDirection := direction
		this.iCurvature := curvature

		this.iBrakingStart := brakingStart
		this.iRollingStart := rollingStart
		this.iAccelerationStart := accelerationStart

		this.iBrakingTime := brakingTime
		this.iRollingTime := rollingTime
		this.iAcceleratingTime := acceleratingTime

		this.iBrakingLength := brakingLength
		this.iRollingLength := rollingLength
		this.iAcceleratingLength := acceleratingLength

		this.iRollingGear := rollingGear
		this.iRollingRPM := rollingRPM
		this.iAcceleratingGear := acceleratingGear
		this.iAcceleratingRPM := acceleratingRPM
		this.iAcceleratingSpeed := acceleratingSpeed

		this.iMinG := minG
		this.iMaxG := maxG
		this.iAvgG := avgG
		this.iMinSpeed := minSpeed
		this.iMaxSpeed := maxSpeed
		this.iAvgSpeed := avgSpeed

		this.iMaxBrakePressure := maxBrakePressure
		this.iBrakePressureRampUp := brakePressureRampUp

		this.iTCActivations := tcActivations
		this.iABSActivations := absActivations

		this.iSteeringSmoothness := steeringSmoothness
		this.iSteeringCorrections := steeringCorrections
		this.iThrottleSmoothness := throttleSmoothness
		this.iThrottleCorrections := throttleCorrections
		this.iBrakeSmoothness := brakeSmoothness
		this.iBrakeCorrections := brakeCorrections
	}

	static fromSection(telemetry, section, startIndex, endIndex) {
		local index := startIndex
		local phase := "Approaching"
		local lastPhase := phase
		local brakingLength := 0
		local rollingLength := 0
		local acceleratingLength := 0
		local brakingTime := 0
		local rollingTime := 0
		local acceleratingTime := 0
		local rollingGear := kNull
		local rollingRPM := 0
		local acceleratingGear := 0
		local acceleratingRPM := 0
		local acceleratingSpeed := 0
		local curvature := telemetry.getValue(index, "Curvature", 0)
		local speed := kUndefined
		local latG := kUndefined
		local absActivations := 0
		local tcActivations := 0
		local lastBrake := 0
		local lastBrakeDelta := 0
		local brakeCount := 0
		local brakeChanges := 0
		local lastThrottle := 0
		local lastThrottleDelta := 0
		local throttleCount := 0
		local throttleChanges := 0
		local lastSteering := 0
		local lastSteeringDelta := 0
		local steeringCount := 0
		local steeringChanges := 0
		local sumSteering := 0
		local speed := telemetry.getValue(index, "Speed")
		local minSpeed := speed
		local maxSpeed := speed
		local speeds := []
		local latG := Abs(telemetry.getValue(index, "Lat G"))
		local minLatG := latG
		local maxLatG := latG
		local latGs := []
		local brakingStart := kNull
		local rollingStart := kNull
		local acceleratingStart := kNull
		local maxBrake := 0
		local brakeRampUp := 0
		local brake, throttle, steering, gear, rpm
		local startDistance, startTime, distance

		updatePhase(phase, index) {
			if (phase = "Braking") {
				brakingLength += (telemetry.getValue(index, "Distance") - startDistance)
				brakingTime += (telemetry.getValue(index, "Time", 0) - startTime)
			}
			else if (phase = "Rolling") {
				rollingLength += (telemetry.getValue(index, "Distance") - startDistance)
				rollingTime += (telemetry.getValue(index, "Time", 0) - startTime)
			}
			else if (phase = "Accelerating") {
				acceleratingLength += (telemetry.getValue(index, "Distance") - startDistance)
				acceleratingTime += (telemetry.getValue(index, "Time", 0) - startTime)
				acceleratingSpeed := Max(speed, acceleratingSpeed)
			}
		}

		while (index <= endIndex) {
			if (curvature = kNull)
				curvature := telemetry.getValue(index, "Curvature")
			else {
				newCurvature := telemetry.getValue(index, "Curvature")

				if (newCurvature != kNull)
					curvature := Max(curvature, newCurvature)
			}

			distance := telemetry.getValue(index, "Distance")
			steering := telemetry.getValue(index, "Steering")
			brake := telemetry.getValue(index, "Brake")
			throttle := telemetry.getValue(index, "Throttle")
			speed := telemetry.getValue(index, "Speed")
			latG := Abs(telemetry.getValue(index, "Lat G"))

			minSpeed := Min(speed, minSpeed)
			maxSpeed := Max(speed, maxSpeed)
			speeds.Push(speed)

			minLatG := Min(minLatG, latG)
			maxLatG := Max(maxLatG, latG)
			latGs.Push(latG)

			sumSteering += steering

			steeringCount += 1

			if ((lastSteeringDelta > 0) && (steering < lastSteering))
				steeringChanges += 1
			else if ((lastSteeringDelta < 0) && (steering > lastSteering))
				steeringChanges += 1

			lastSteeringDelta := (steering - lastSteering)
			lastSteering := steering

			if (brake > 0.2)
				phase := "Braking"
			else if (throttle <= 0.2)
				phase := "Rolling"
			else
				phase := "Accelerating"

			if (phase != lastPhase) {
				updatePhase(lastPhase, index)

				startDistance := telemetry.getValue(index, "Distance")
				startTime := telemetry.getValue(index, "Time", 0)

				lastPhase := phase
			}

			if (phase = "Braking") {
				if (brakingStart == kNull)
					brakingStart := startDistance

				if telemetry.getValue(index, "ABS", false)
					absActivations += 1

				if (brake > maxBrake) {
					brakeRampUp := (distance - startDistance)

					maxBrake := brake
				}

				brakeCount += 1

				if ((lastBrakeDelta > 0) && (brake < lastBrake))
					brakeChanges += 1
				else if ((lastBrakeDelta < 0) && (brake > lastBrake))
					brakeChanges += 1

				lastBrakeDelta := (brake - lastBrake)
				lastBrake := brake
			}
			else if (phase = "Rolling") {
				if (rollingStart == kNull)
					rollingStart := startDistance

				if (rollingGear == kNull) {
					rollingGear := telemetry.getValue(index, "Gear")
					rollingRPM := telemetry.getValue(index, "RPM")
				}
				else {
					gear := telemetry.getValue(index, "Gear")
					rpm := telemetry.getValue(index, "RPM")

					if (gear < rollingGear) {
						rollingGear := gear
						rollingRPM := rpm
					}
					else
						rollingRPM := Min(rpm, rollingRPM)
				}
			}
			else if (phase = "Accelerating") {
				if (acceleratingStart == kNull) {
					acceleratingStart := startDistance

					acceleratingGear := telemetry.getValue(index, "Gear")
					acceleratingRPM := telemetry.getValue(index, "RPM")
				}

				if telemetry.getValue(index, "TC", false)
					tcActivations += 1

				throttleCount += 1

				if ((lastThrottleDelta > 0) && (throttle < lastThrottle))
					throttleChanges += 1
				else if ((lastThrottleDelta < 0) && (throttle > lastThrottle))
					throttleChanges += 1

				lastThrottleDelta := (throttle - lastThrottle)
				lastThrottle := throttle
			}

			index += 1
		}

		updatePhase(phase, index - 1)

		return Corner(section, (sumSteering > 0) ? "Right" : "Left", (curvature != kNull) ? curvature : 0
							 , brakingStart, brakingTime, brakingLength, Round(maxBrake * 100), brakeRampUp
							 , rollingStart, rollingTime, rollingLength
							 , acceleratingStart, acceleratingTime, acceleratingLength
							 , rollingGear, rollingRPM, acceleratingGear, acceleratingRPM, acceleratingSpeed
							 , minLatG, maxLatG, average(latGs), minSpeed, maxSpeed, average(speeds), tcActivations, absActivations
							 , Max(0, steeringChanges - 1), 100 - (steeringCount ? ((steeringChanges / steeringCount) * 100) : 0)
							 , Max(0, throttleChanges - 1), 100 - (throttleCount ? ((throttleChanges / throttleCount) * 100): 0)
							 , Max(0, brakeChanges - 1), 100 - (brakeCount ? ((brakeChanges / brakeCount) * 100) : 0))
	}
}

class Straight extends Section {
	iTime := 0

	iMinSpeed := 0
	iMaxSpeed := 0
	iAvgSpeed := 0

	Type {
		Get {
			return "Straight"
		}
	}

	Time {
		Get {
			return this.iTime
		}
	}

	MinG {
		Get {
			return 0
		}
	}

	MaxG {
		Get {
			return 0
		}
	}

	AvgG {
		Get {
			return 0
		}
	}

	MinSpeed {
		Get {
			return this.iMinSpeed
		}
	}

	MaxSpeed {
		Get {
			return this.iMaxSpeed
		}
	}

	AvgSpeed {
		Get {
			return this.iAvgSpeed
		}
	}

	Descriptor {
		Get {
			local descriptor := super.Descriptor

			descriptor.MinSpeed := (nullRound(this.MinSpeed) . " km/h")
			descriptor.MaxSpeed := (nullRound(this.MaxSpeed) . " km/h")
			descriptor.AvgSpeed := (nullRound(this.AvgSpeed) . " km/h")

			return descriptor
		}
	}

	__New(trackSection, time, minSpeed, maxSpeed, avgSpeed) {
		super.__New(trackSection)

		this.iTime := time

		this.iMinSpeed := minSpeed
		this.iMaxSpeed := maxSpeed
		this.iAvgSpeed := avgSpeed
	}

	static fromSection(telemetry, section, startIndex, endIndex) {
		local index := startIndex
		local speed := telemetry.getValue(index, "Speed")
		local minSpeed := speed
		local maxSpeed := speed
		local speeds := []

		while (index <= endIndex) {
			speed := telemetry.getValue(index, "Speed")

			minSpeed := Min(speed, minSpeed)
			maxSpeed := Max(speed, maxSpeed)
			speeds.Push(speed)

			index += 1
		}

		return Straight(section, telemetry.getValue(endIndex - 1, "Time", 0) - telemetry.getValue(startIndex, "Time", 0)
							   , minSpeed, maxSpeed, average(speeds))
	}
}

class Telemetry {
	iTelemetryAnalyzer := false

	iLap := false
	iData := []

	iSections := []

	iMaxG := 0
	iMaxSpeed := 0

	iMaxGear := 0
	iMaxRPM := 0

	TelemetryAnalyzer {
		Get {
			return this.iTelemetryAnalyzer
		}
	}

	Lap {
		Get {
			return this.iLap
		}
	}

	Data {
		Get {
			return this.iData
		}
	}

	Sections {
		Get {
			return this.iSections
		}

		Set {
			return (this.iSections := value)
		}
	}

	MaxG {
		Get {
			return this.iMaxG
		}
	}

	MaxSpeed {
		Get {
			return this.iMaxSpeed
		}
	}

	MaxGear {
		Get {
			return this.iMaxGear
		}
	}

	MaxRPM {
		Get {
			return this.iMaxRPM
		}
	}

	Descriptor {
		Get {
			return {Lap: this.Lap, MaxG: nullRound(this.MaxG, 2), MaxSpeed: (nullRound(this.MaxSpeed) . " km/h")
								 , MaxGear: this.MaxGear, MaxRPM: this.MaxRPM
								 , Sections: collect(this.Sections, (s) => s.Descriptor)}
		}
	}

	JSON {
		Get {
			return JSON.print(this.Descriptor, "  ")
		}
	}

	__New(analyzer, lap, data) {
		local maxG := kUndefined
		local maxSpeed := kUndefined
		local ignore, section

		this.iTelemetryAnalyzer := analyzer

		this.iLap := lap
		this.iData := data

		this.iSections := this.createSections(data)

		for ignore, section in this.Sections {
			if (maxG == kUndefined)
				maxG := section.MaxG
			else
				maxG := Max(section.MaxG, maxG)

			if (maxSpeed == kUndefined)
				maxSpeed := section.MaxSpeed
			else
				maxSpeed := Max(section.MaxSpeed, maxSpeed)
		}

		loop data.Length {
			this.iMaxGear := Max(this.getValue(A_Index, "Gear", 0), this.iMaxGear)
			this.iMaxRPM := Max(this.getValue(A_Index, "RPM", 0), this.iMaxRPM)
		}

		if (maxG != kUndefined) {
			this.iMaxG := maxG
			this.iMaxSpeed := maxSpeed
		}
	}

	createSections(data) {
		local trackSections := this.TelemetryAnalyzer.TrackSections
		local sections := []
		local lastSection, startIndex, ignore, section

		if (trackSections.Length > 0) {
			lastSection := trackSections[1]
			startIndex := TelemetryAnalyzer.getTelemetryCoordinateIndex(data, lastSection.X, lastSection.Y)

			for ignore, section in trackSections {
				if (A_Index = 1)
					continue

				index := TelemetryAnalyzer.getTelemetryCoordinateIndex(data, section.X, section.Y)

				if index {
					if lastSection
						try {
							if (lastSection.Type = "Corner")
								sections.Push(Corner.fromSection(this, section, startIndex, Max(1, index - 1)))
							else
								sections.Push(Straight.fromSection(this, section, startIndex, Max(1, index - 1)))
						}
						catch Any as exception {
							logError(exception)
						}

					lastSection := section
					startIndex := index
				}
			}
		}

		this.iSections := sections

		return sections
	}

	getValue(index, name, default := kUndefined) {
		return TelemetryAnalyzer.getValue(this.Data[index], name, default)
	}
}

class TelemetryAnalyzer {
	static sSchema := false

	iSimulator := false
	iTrack := false

	iTrackMap := false
	iTrackSections := []

	static Schema {
		Get {
			return TelemetryAnalyzer.sSchema
		}
	}

	Schema {
		Get {
			return TelemetryAnalyzer.Schema
		}
	}

	Simulator {
		Get {
			return this.iSimulator
		}
	}

	Track {
		Get {
			return this.iTrack
		}
	}

	TrackMap {
		Get {
			return this.iTrackMap
		}
	}

	TrackSections {
		Get {
			return this.iTrackSections
		}
	}

	__New(simulator, track) {
		local sessionDB := SessionDatabase()

		if !TelemetryAnalyzer.Schema
			TelemetryAnalyzer.sSchema := this.createTelemetrySchema()

		this.iSimulator := simulator
		this.iTrack := track
		this.iTrackMap := sessionDB.getTrackMap(simulator, track)

		if this.TrackMap
			this.iTrackSections := this.createTrackSections()
	}

	static getTrackCoordinateIndex(trackMap, x, y, threshold := 5) {
		local index := false
		local candidateX, candidateY, deltaX, deltaY, coordX, coordY, dX, dY

		if trackMap {
			candidateX := kUndefined
			candidateY := false
			deltaX := false
			deltaY := false

			loop getMultiMapValue(trackMap, "Map", "Points") {
				coordX := getMultiMapValue(trackMap, "Points", A_Index . ".X")
				coordY := getMultiMapValue(trackMap, "Points", A_Index . ".Y")

				dX := Abs(coordX - x)
				dY := Abs(coordY - y)

				if ((dX <= threshold) && (dY <= threshold) && ((candidateX == kUndefined) || ((dx + dy) < (deltaX + deltaY)))) {
					candidateX := coordX
					candidateY := coordY
					deltaX := dX
					deltaY := dY

					index := A_Index
				}
			}

			return index
		}
		else
			return false
	}

	static getTelemetryCoordinateIndex(data, x, y, threshold := 25) {
		local index := false
		local candidateX := kUndefined
		local candidateY := false
		local deltaX := false
		local deltaY := false
		local coordX, coordY, dX, dY, ignore, entry

		static posXIndex := TelemetryAnalyzer.Schema["PosX"].Indices[1]
		static posYIndex := TelemetryAnalyzer.Schema["PosY"].Indices[1]

		if isInstance(data, Telemetry)
			data := data.Data

		for ignore, entry in data
			if entry.Has(posXIndex) {
				coordX := entry[posXIndex]
				coordY := entry[posYIndex]

				if isNumber(coordX) {
					dX := Abs(coordX - x)
					dY := Abs(coordY - y)

					if ((dX <= threshold) && (dY <= threshold) && ((candidateX == kUndefined) || ((dx + dy) < (deltaX + deltaY)))) {
						candidateX := coordX
						candidateY := coordY
						deltaX := dX
						deltaY := dY

						index := A_Index
					}
				}
				else
					return false
			}
			else
				return false

		return index
	}

	getSectionCoordinateIndex(section, &x, &y, &index, offset := 0, threshold := 25) {
		local trackMap := this.TrackMap
		local distance := 0
		local absOffset := Abs(offset)
		local points, nextX, nextY

		if trackMap {
			points := getMultiMapValue(trackMap, "Map", "Points")

			x := section.X
			y := section.Y
			index := section.Index

			loop {
				nextX := getMultiMapValue(trackMap, "Points", index . ".X")
				nextY := getMultiMapValue(trackMap, "Points", index . ".Y")

				distance += Sqrt(((nextX - x) ** 2) + ((nextY - y) ** 2))

				x := nextX
				y := nextY

				if ((absOffset - distance) <= threshold)
					break

				if (offset < 0) {
					if (index = 1)
						index := points
					else
						index -= 1
				}
				else {
					if (index = points)
						index := 1
					else
						index += 1
				}
			}

			return true
		}
		else
			return false
	}

	static getValue(data, name, default := kUndefined) {
		local channel := TelemetryAnalyzer.Schema[name]
		local index, value

		if channel.HasProp("Function") {
			value := channel.Function.Call(data)

			if ((value = kNull) && (default != kUndefined))
				return default
			else
				return value
		}
		else {
			index := channel.Indices[1]

			return (data.Has(index) ? data[index] : ((default != kUndefined) ? default : kNull))
		}
	}

	loadData(fileName) {
		local data := []
		local entry

		loop Read, fileName {
			entry := string2Values(";", A_LoopReadLine)

			for index, value in entry
				if !isNumber(value)
					entry[index] := kNull

			data.Push(entry)
		}

		return data
	}

	createTrackSections() {
		local trackMap := this.TrackMap
		local straights := 0
		local corners := 0
		local sections := []
		local index, section

		computeLength(index) {
			local next := ((index = sections.Length) ? 1 : (index + 1))
			local distance := 0
			local count := getMultiMapValue(trackMap, "Map", "Points", 0)
			local lastX, lastY, nextX, nextY

			index := TelemetryAnalyzer.getTrackCoordinateIndex(trackMap, sections[index].X, sections[index].Y)
			next := TelemetryAnalyzer.getTrackCoordinateIndex(trackMap, sections[next].X, sections[next].Y)

			if (index && next) {
				lastX := getMultiMapValue(trackMap, "Points", index . ".X", 0)
				lastY := getMultiMapValue(trackMap, "Points", index . ".Y", 0)

				index += 1

				loop
					if (index = next)
						break
					else if (index > count)
						index := 1
					else {
						nextX := getMultiMapValue(trackMap, "Points", index . ".X", 0)
						nextY := getMultiMapValue(trackMap, "Points", index . ".Y", 0)

						distance += Sqrt(((nextX - lastX) ** 2) + ((nextY - lastY) ** 2))

						lastX := nextX
						lastY := nextY

						index += 1
					}
				}

			return Round(convertUnit("Length", distance))
		}

		loop getMultiMapValue(trackMap, "Sections", "Count")
			sections.Push({Nr: getMultiMapValue(trackMap, "Sections", A_Index . ".Nr")
						 , Type: getMultiMapValue(trackMap, "Sections", A_Index . ".Type")
						 , Index: getMultiMapValue(trackMap, "Sections", A_Index . ".Index")
						 , X: getMultiMapValue(trackMap, "Sections", A_Index . ".X")
						 , Y: getMultiMapValue(trackMap, "Sections", A_Index . ".Y")})

		for index, section in sections
			section.Length := computeLength(index)

		return sections
	}

	createTelemetrySchema() {
		local schema := CaseInsenseMap()
		local ignore, channel

		for ignore, channel in kTelemetryChannels
			if (channel.Indices.Length = 1)
				schema[channel.Name] := channel

		return schema
	}

	createTelemetry(lap, fileName) {
		return Telemetry(this, lap, this.loadData(fileName))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Public Function Section                         ;;;
;;;-------------------------------------------------------------------------;;;

nullZero(value) {
	return (isNull(value) ? 0 : value)
}

nullRound(value, precision := 0) {
	if isNumber(value)
		return Round(value, precision)
	else
		return value
}