;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Telemetry Analysis              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\JSON.ahk"
#Include "..\..\Libraries\Math.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class Section {
	Type {
		Get {
			throw "Virtual property Section.Type must be implemented in a subclass..."
		}
	}

	Length {
		Get {
			throw "Virtual property Section.Length must be implemented in a subclass..."
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

	JSON {Get {
			return JSON.print(this.Descriptor, "  ")
		}
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

	static fromTelemetry(telemetry, start) {
	}
}

class Straight extends Section {
	iLength := 0
	iDuration := 0

	iMinSpeed := 0
	iMaxSpeed := 0
	iAvgSpeed := 0

	Type {
		Get {
			return "Straight"
		}
	}

	Length {
		Get {
			return this.iLength
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

	__New(length, duration, minSpeed, maxSpeed, avgSpeed) {
		this.iLength := length
		this.iDuration := duration

		this.iMinSpeed := minSpeed
		this.iMaxSpeed := maxSpeed
		this.iAvgSpeed := avgSpeed
	}

	static fromTelemetry(telemetry, &index) {
		local speeds
		local startDistance, startTime, endDistance, endTime, brake, throttle
		local minSpeed, maxSpeed

		telemetry.getData(index, "Distance", &startDistance)
		telemetry.getData(index, "Time", &startTime)
		telemetry.getData(index, "Speed", &speed)

		minSpeed := speed
		maxSpeed := speed
		speeds.Push(speed)

		while telemetry.getData(index, "Brake", &brake) {
			telemetry.getData(index, "Throttle", &brake)

			if ((brake = 0) && (throttle = 100)) {
				telemetry.getData(index, "Speed", &speed)

				minSpeed := Min(speed, minSpeed)
				maxSpeed := Max(speed, maxSpeed)
				speeds.Push(speed)

				index += 1
			}
			else
				break
		}

		telemetry.getData(index - 1, "Distance", &endDistance)
		telemetry.getData(index - 1, "Time", &endTime)

		return Straight(endDistance - startDistance, endTime - startTime, minSpeed, maxSpeed, average(speeds))
	}
}

class Telemetry {
	iData := []

	iSections := []

	iMaxG := 0
	iMaxSpeed := 0

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

	__New(fileName) {
		local maxG := kUndefined
		local maxSpeed := kUndefined
		local ignore, corner

		this.iData := this.read(fileName)

		this.iSections := this.createSections(this.Data)

		for ignore, corner this.Sections {
			if (maxG == kUndefined)
				section.iMaxG := section.MaxG
			else
				section.iMaxG := Max(section.MaxG, maxG)

			if (maxSpeed == kUndefined)
				section.iMaxSpeed := section.MaxSpeed
			else
				section.iMaxSpeed := Max(section.MaxSpeed, maxSpeed)
		}
	}

	readData(fileName) {
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

	createSections(data) {
	}

	betterCorner(corner, reference) {
	}

	areasOfImprovement(corner, reference := false) {
	}
}