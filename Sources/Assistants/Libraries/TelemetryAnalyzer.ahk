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
#Include "..\..\Database\Libaries\TelemetryCollector.ahk"


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

	Duration {
		Get {
			throw "Virtual property Section.Duration must be implemented in a subclass..."
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
			return {Type: this.Type, Length: this.Length, Duration: this.Duration
				  , MinG: this.MinG, MaxG: this.MaxG, AvgG: this.AvgG
				  , MinSpeed: this.MinSpeed, MaxSpeed: this.MaxSpeed, AvgSpeed: this.AvgSpeed}
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
	iNr := 0							; Number of the corner counting from start/finish

	iDirection := "Left"				; OneOf("Left", "Right")
	iCurvature := 0.0					; Higher values -> sharper corner

	iBrakingDuration := 0				; Duration of the braking phase in meters
	iRollingDuration := 0				; Duration of the rolling phase in meters
	iAcceleratingDuration := 0			; Duration of the acceleration phase in meters

	iBrakingLength := 0					; Length of the braking phase in meters
	iRollingLength := 0					; Length of the rolling phase in meters
	iAcceleratingLength := 0			; Length of the acceleration phase in meters

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

	Nr {
		Get {
			return this.iNr
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

	Duration[part := "Overall"] {
		Get {
			if (part = "Overall")
				return (this.iBrakingDuration + this.iRollingDuration + this.iAcceleratingDuration)
			else if ((part = "Entry") || (part = "Braking"))
				return this.iBrakingDuration
			else if ((part = "Apex") || (part = "Rolling"))
				return this.iRollingDuration
			else if ((part = "Exit") || (part = "Accelerating"))
				return this.iAcceleratingDuration
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

			descriptor.BrakingDuration := this.Duration["Braking"]
			descriptor.BrakingLength := this.Length["Braking"]

			descriptor.RollingDuration := this.Duration["Rolling"]
			descriptor.RollingLength := this.Length["Rolling"]

			descriptor.AcceleratingDuration := this.Duration["Accelerating"]
			descriptor.AcceleratingLength := this.Length["Accelerating"]

			descriptor.TCActivations := this.TCActivations
			descriptor.ABSActivations := this.ABSActivations

			descriptor.SteeringSmoothness := this.SteeringSmoothness
			descriptor.ThrottleSmoothness := this.ThrottleSmoothness
			descriptor.BrakingSmoothness := this.BrakingSmoothness

			return descriptor
	}

	__New(trackSection) {
		super.__New(trackSection)
	}

	static fromSection(telemetry, section, startIndex, endIndex) {
	}
}

class Straight extends Section {
	iDuration := 0

	iMinSpeed := 0
	iMaxSpeed := 0
	iAvgSpeed := 0

	Type {
		Get {
			return "Straight"
		}
	}

	Duration {
		Get {
			return this.iDuration
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

	__New(trackSection, duration, minSpeed, maxSpeed, avgSpeed) {
		super.__New(trackSection)

		this.iDuration := duration

		this.iMinSpeed := minSpeed
		this.iMaxSpeed := maxSpeed
		this.iAvgSpeed := avgSpeed
	}

	static fromSection(telemetry, section, startIndex, endIndex) {
		local index := startIndex
		local speeds, startDistance, startTime, minSpeed, maxSpeed

		startTime := telemetry.getValue(index, "Time")
		speed := telemetry.getValue(index, "Speed")

		minSpeed := speed
		maxSpeed := speed
		speeds.Push(speed)

		while (index <= endIndex) {
			speed := telemetry.getValue(index, "Speed")

			minSpeed := Min(speed, minSpeed)
			maxSpeed := Max(speed, maxSpeed)
			speeds.Push(speed)

			index += 1
		}

		return Straight(section, telemetry.getValue(index - 1, "Time") - startTime
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

	__New(analyzer, data) {
		local maxG := kUndefined
		local maxSpeed := kUndefined
		local ignore, corner

		this.iTelemetryAnalyzer := analyzer
		this.iData := data

		this.createSections(this.Data)

		for ignore, corner this.Sections {
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
			startIndex := TelemetryAnalayzer.getTelemetryCoordinateIndex(data, lastSection.X, lastSection.Y)

			for ignore, section in trackSections {
				index := TelemetryAnalayzer.getTelemetryCoordinateIndex(data, section.X, section.Y)

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

	getValue(index, name) {
		return TelemetryAnalyzer.getValue(this.Data[index], name)
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
				coordX := data[posXIndex]
				coordY := data[posYIndex]
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

		return index
	}

	static getValue(data, name) {
		local channel = TelemetryAnalyzer.Schema[Name]
		local index, value

		if channel.Function
			return channel.Function(data)
		else {
			index := channel.Indices[1]

			return (data.Has(index) ? data[index] : kNull)
		}
	}

	loadTrackSections() {
		local trackMap := this.TrackMap
		local straights := 0
		local corners := 0
		local sections := []
		local index, section

		computeLength(index) {
			local next := ((index = this.TrackSections.Length) ? 1 : (index + 1))
			local distance := 0
			local count := getMultiMapValue(trackMap, "Map", "Points", 0)
			local lastX, lastY, nextX, nextY

			index := TelemetryAnalyzer.getTrackCoordinateIndex(trackMap, this.TrackSections[index].X, this.TrackSections[index].Y)
			next := TelemetryAnalyzer.getTrackCoordinateIndex(trackMap, this.TrackSections[next].X, this.TrackSections[next].Y)

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

		loop getMultiMapValue(trackMap, "Sections", "Count") {
			sections.Push({Nr: getMultiMapValue(trackMap, "Sections", A_Index . ".Nr")
						 , Type: getMultiMapValue(trackMap, "Sections", index . ".Type")
						 , Index: getMultiMapValue(trackMap, "Sections", index . ".Index")
						 , X: getMultiMapValue(trackMap, "Sections", index . ".X")
						 , Y: getMultiMapValue(trackMap, "Sections", index . ".Y")})

		for index, section in sections
			section.Length := computeLength(index)

		this.iTrackSections := sections

		return (sections.Length > 0)
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

	createTelemetrySchema() {
		local schema := CaseInsenceMap()
		local ignore, channel

		for ignore, channel in kTelemetryChannels {
			if (channel.Indices.Length = 1)
				schema[channel.Name] := channel

		return schema
	}

	createTelemetry(fileName) {
		return Telemetry(this, this.loadData(fileName))
	}

	analyze(fileName) {
	}
}