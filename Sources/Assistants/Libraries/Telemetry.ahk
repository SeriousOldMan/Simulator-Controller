;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Telemetry                       ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class Section {
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
}

class Corner extends Section {
	iNr := 0							; Number of the corner counting from start/finish
	iDuration := 0						; Seconds used from Start to Start + Length
	iStart := 0							; Distance into the track where corner starts

	iDirection := "Left"				; OneOf("Left", "Right")
	iCurvature := 0.0					; Higher values -> sharper corner

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

	iCounterSteerings := 0				; # of counter steering events during the corner
	iThrottleSmoothness := 0			; Percentage
	iBrakeSmoothness := 0				; Percentage

	Nr {
		Get {
			return this.iNr
		}
	}

	Duration {
		Get {
			return this.iDuration
		}
	}

	Start {
		Get {
			return this.iStart
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

	CounterSteerings {
		Get {
			return this.iCounterSteerings
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
}

class Straight extends Section {
	iLength := 0
	iMinSpeed := 0
	iMaxSpeed := 0
	iAvgSpeed := 0

	Length {
		Get {
			return this.iLength
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