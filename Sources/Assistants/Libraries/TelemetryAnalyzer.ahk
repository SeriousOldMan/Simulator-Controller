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
#Include "..\..\Database\Libraries\TelemetryCollector.ahk"


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

	Distance {
		Get {
			return (this.TrackSection.Distance . " Meter")
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
			return {Type: this.Type, Distance: (this.Distance . " Meter"), Time: (this.Time . " Seconds")
				  , MinG: this.MinG, MaxG: this.MaxG, AvgG: this.AvgG
				  , MinSpeed: (this.MinSpeed . " km/h"), MaxSpeed: (this.MaxSpeed . " km/h"), AvgSpeed: (this.AvgSpeed . " km/h")}
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

	iBrakingTime := 0					; Time of the braking phase in meters
	iRollingTime := 0					; Time of the rolling phase in meters
	iAcceleratingTime := 0				; Time of the acceleration phase in meters

	iBrakingDistance := 0				; Distance of the braking phase in meters
	iRollingDistance := 0				; Distance of the rolling phase in meters
	iAcceleratingDistance := 0			; Distance of the acceleration phase in meters

	iMinG := 0							; Min G Force around apex (rolling phase)
	iMaxG := 0							; Max G Force around apex (rolling phase)
	iAvgG := 0							; Avg G Force around apex (rolling phase)
	iMinSpeed := 0						; Min Speed around apex (rolling phase)
	iMaxSpeed := 0						; Max Speed around apex (rolling phase)
	iAvgSpeed := 0						; Avg Speed around apex (rolling phase)

	iTCActivations := 0					; # of TC activations (each meter is one tick)
	iABSActivations := 0				; # of ABS activations (each meter is one tick)

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

	Distance[part := "Overall"] {
		Get {
			if (part = "Overall")
				return (this.iBrakingDistance + this.iRollingDistance + this.iAcceleratingDistance)
			else if ((part = "Entry") || (part = "Braking"))
				return this.iBrakingDistance
			else if ((part = "Apex") || (part = "Rolling"))
				return this.iRollingDistance
			else if ((part = "Exit") || (part = "Accelerating"))
				return this.iAcceleratingDistance
			else
				return 0
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

	ThrottleSmoothness {
		Get {
			return this.iThrottleSmoothness
		}
	}

	BrakeSmoothness {
		Get {
			return this.iBrakeSmoothness
		}
	}

	Descriptor {
		Get {
			local descriptor := super.Descriptor

			descriptor.Nr := this.Nr
			descriptor.Direction := this.Direction
			descriptor.Curvature := this.Curvature

			descriptor.BrakingTime := (this.Time["Entry"] . " Seconds")
			descriptor.BrakingDistance := (this.Distance["Entry"] . " Meter")

			descriptor.RollingTime := (this.Time["Apex"] . " Seconds")
			descriptor.RollingDistance := (this.Distance["Apex"] . " Meter")

			descriptor.AcceleratingTime := (this.Time["Exit"] . " Seconds")
			descriptor.AcceleratingDistance := (this.Distance["Exit"] . " Meter")

			descriptor.TCActivations := this.TCActivations
			descriptor.ABSActivations := this.ABSActivations

			descriptor.SteeringSmoothness := (this.SteeringSmoothness . " Percent")
			descriptor.ThrottleSmoothness := (this.ThrottleSmoothness . " Percent")
			descriptor.BrakeSmoothness := (this.BrakeSmoothness . " Percent")

			return descriptor
		}
	}

	__New(trackSection, direction, curvature
					  , brakingTime, brakingDistance, rollingTime, rollingDistance, acceleratingTime, acceleratingDistance
					  , minG, maxG, avgG, minSpeed, maxSpeed, avgSpeed, tcActivations, absActivations
					  , steeringSmoothness, throttleSmoothness, brakeSmoothness) {
		super.__New(trackSection)

		this.iBrakingTime := brakingTime
		this.iRollingTime := rollingTime
		this.iAcceleratingTime := acceleratingTime

		this.iBrakingDistance := brakingDistance
		this.iRollingDistance := rollingDistance
		this.iAcceleratingDistance := acceleratingDistance

		this.iMinG := minG
		this.iMaxG := maxG
		this.iAvgG := avgG
		this.iMinSpeed := minSpeed
		this.iMaxSpeed := maxSpeed
		this.iAvgSpeed := avgSpeed

		this.iTCActivations := tcActivations
		this.iABSActivations := absActivations

		this.SteeringSmoothness := steeringSmoothness
		this.ThrottleSmoothness := throttleSmoothness
		this.BrakeSmoothness := brakeSmoothness
	}

	static fromSection(telemetry, section, startIndex, endIndex) {
		local index := startIndex
		local phase := "Approaching"
		local lastPhase := phase
		local brakingDistance := 0
		local rollingDistance := 0
		local acceleratingDistance := 0
		local brakingTime := 0
		local rollingTime := 0
		local acceleratingTime := 0
		local brakingG := kUndefined
		local brakingSpeed := kUndefined
		local acceleratingG := kUndefined
		local acceleratingSpeed := kUndefined
		local curvature := telemetry.getValue(index, "Curvature")
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
		local minSpeed, maxSpeed, speeds, minLatG, maxLatG, latGs
		local brake, throttle, steering
		local startDistance, startTime

		while (index <= endIndex) {
			curvature := Max(curvature, telemetry.getValue(index, "Curvature"))
			steering := telemetry.getValue(index, "Steering")
			brake := telemetry.getValue(index, "Brake")
			throttle := telemetry.getValue(index, "Trottle")

			sumSteering += steering

			steeringCount += 1

			if ((lastSteeringDelta > 0) && (steering < lastSteering))
				steeringChanges += 1
			else if ((lastSteeringDelta < 0) && (steering > lastSteering))
				steeringChanges += 1

			lastSteeringDelta := (steering - lastSteering)
			lastSteering := steering

			if ((brake > 0) && (lastPhase = "Approaching")) {
				phase := "Braking"
			}
			else if ((brake <= 0.2) && (throttle <= 0.2) && (lastPhase = "Braking")) {
				phase := "Rolling"
			}
			else if ((brake <= 0.2) && (throttle > 0.5) && ((lastPhase = "Braking") || (lastPhase = "Rolling"))) {
				phase := "Accelerating"
			}

			if (phase != lastPhase) {
				if (phase = "Rolling") {
					latG := Abs(telemetry.getValue(index, "Lat G"))
					minLatG := latG
					maxLatG := latG
					latGs := []

					speed := telemetry.getValue(index, "Speed")
					minSpeed := speed
					maxSpeed := speed
					speeds := []
				}
				else if (phase = "Accelerating") {
					acceleratingG := Abs(telemetry.getValue(index, "Lat G"))
					acceleratingSpeed := telemetry.getValue(index, "Speed")
				}

				if (lastPhase = "Braking") {
					brakingDistance := (telemetry.getValue(index, "Distance") - startDistance)
					brakingTime := (telemetry.getValue(index, "Time", 0) - startTime)
					brakingG := Abs(telemetry.getValue(index, "Lat G"))
					brakingSpeed := telemetry.getValue(index, "Speed")
				}
				else if (lastPhase = "Rolling") {
					rollingDistance := (telemetry.getValue(index, "Distance") - startDistance)
					rollingTime := (telemetry.getValue(index, "Time", 0) - startTime)
				}
				else if (lastPhase = "Accelerating") {
					acceleratingDistance := (telemetry.getValue(index, "Distance") - startDistance)
					acceleratingTime := (telemetry.getValue(index, "Time", 0) - startTime)
				}

				startDistance := telemetry.getValue(index, "Distance")
				startTime := telemetry.getValue(index, "Distance", 0)

				lastPhase := phase
			}


			if (phase = "Braking") {
				if telemetry.getValue(index, "ABS", false)
					absActivations += 1

				brakeCount += 1

				if ((lastBrakeDelta > 0) && (brake < lastBrake))
					brakeChanges += 1
				else if ((lastBrakeDelta < 0) && (brake > lastBrake))
					brakeChanges += 1

				lastBrakeDelta := (brake - lastBrake)
				lastBrake := brake
			}
			else if (phase = "Rolling") {
				minLatG := Min(minLatG, latG)
				maxLatG := Max(maxLatG, latG)
				latGs.Push(latG)

				minSpeed := Min(minSpeed, latG)
				maxSpeed := Max(maxSpeed, latG)
				speeds.Push(speed)
			}
			else if (phase = "Accelerating") {
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

		if (speed = kUndefined) {
			if (brakingG != kUndefined) {
				latG := brakingG
				speed := brakingSpeed
			}
			else if (acceleratingG != kUndefined) {
				latG := brakingG
				speed := brakingSpeed
			}
			else {
				latG := 0
				speed := 0
			}

			return Corner(section, (sumSteering > 0) ? "Right" : "Left", curvature
								 , brakingTime, brakingDistance, rollingTime, rollingDistance, acceleratingTime, acceleratingDistance
								 , latG, latG, latG, speed, speed, speed, tcActivations, absActivations
								 , 100 - ((steeringChanges / steeringCount) * 100)
								 , 100 - ((throttleChanges / throttleCount) * 100)
								 , 100 - ((brakeChanges / brakeCount) * 100))
		}
		else
			return Corner(section, (sumSteering > 0) ? "Right" : "Left", curvature
								 , brakingTime, brakingDistance, rollingTime, rollingDistance, acceleratingTime, acceleratingDistance
								 , minLatG, maxLatG, average(latGs), minSpeed, maxSpeed, average(speeds), tcActivations, absActivations
								 , 100 - ((steeringChanges / steeringCount) * 100)
								 , 100 - ((throttleChanges / throttleCount) * 100)
								 , 100 - ((brakeChanges / brakeCount) * 100))
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
	iData := []

	iSections := []

	iMaxG := 0
	iMaxSpeed := 0

	TelemetryAnalyzer {
		Get {
			return this.iTelemetryAnalyzer
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

	Descriptor {
		Get {
			return {MaxG: this.MaxG, MaxSpeed: this.MaxSpeed, Sections: collect(this.Sections, (s) => s.Descriptor)}
		}
	}

	JSON {
		Get {
			return JSON.print(this.Descriptor, "  ")
		}
	}

	__New(analyzer, data) {
		local maxG := kUndefined
		local maxSpeed := kUndefined
		local ignore, corner

		this.iTelemetryAnalyzer := analyzer
		this.iData := data

		this.iSections := this.createSections(this.Data)

		for ignore, corner in this.Sections {
			if (maxG == kUndefined)
				maxG := section.MaxG
			else
				maxG := Max(section.MaxG, maxG)

			if (maxSpeed == kUndefined)
				maxSpeed := section.MaxSpeed
			else
				maxSpeed := Max(section.MaxSpeed, maxSpeed)
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
				index := TelemetryAnalyzer.getTelemetryCoordinateIndex(data, section.X, section.Y)

				if index {
					if lastSection
						if (lastSection.Type = "Corner")
							sections.Push(Corner.fromSection(this, section, startIndex, index - 1))
						else
							sections.Push(Straight.fromSection(this, section, startIndex, index - 1))

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

	static getValue(data, name, default := kUndefined) {
		local channel := TelemetryAnalyzer.Schema[Name]
		local index, value

		if channel.HasProp("Function") {
			value := channel.Function(data)

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

	createTelemetry(fileName) {
		return Telemetry(this, this.loadData(fileName))
	}
}

analyzer := TelemetryAnalyzer("Assetto Corsa Competizione", "Imola")

telm := analyzer.createTelemetry("C:\Users\juwig\Desktop\Lap 2 (Oliver Juwig - 105.917).telemetry")

js := telm.JSON
MsgBox js