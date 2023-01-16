;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AI Race Engineer                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Global Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Framework\Framework.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Task.ahk
#Include ..\Assistants\Libraries\RaceAssistant.ahk
#Include ..\Assistants\Libraries\SessionDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceEngineer extends RaceAssistant {
	iAdjustLapTime := true

	iSaveTyrePressures := kAsk

	iHasPressureData := false
	iSessionDataActive := false

	class RaceEngineerRemoteHandler extends RaceAssistant.RaceAssistantRemoteHandler {
		__New(remotePID) {
			base.__New("Race Engineer", remotePID)
		}

		pitstopPlanned(arguments*) {
			this.callRemote("pitstopPlanned", arguments*)
		}

		pitstopPrepared(arguments*) {
			this.callRemote("pitstopPrepared", arguments*)
		}

		pitstopFinished(arguments*) {
			this.callRemote("pitstopFinished", arguments*)
		}

		startPitstopSetup(arguments*) {
			this.callRemote("startPitstopSetup", arguments*)
		}

		finishPitstopSetup(arguments*) {
			this.callRemote("finishPitstopSetup", arguments*)
		}

		updateTyreSet(arguments*) {
			this.callRemote("updateTyreSet", arguments*)
		}

		setPitstopRefuelAmount(arguments*) {
			this.callRemote("setPitstopRefuelAmount", arguments*)
		}

		setPitstopTyreSet(arguments*) {
			this.callRemote("setPitstopTyreSet", arguments*)
		}

		setPitstopTyrePressures(arguments*) {
			this.callRemote("setPitstopTyrePressures", arguments*)
		}

		requestPitstopRepairs(arguments*) {
			this.callRemote("requestPitstopRepairs", arguments*)
		}

		requestPitstopDriver(arguments*) {
			this.callRemote("requestPitstopDriver", arguments*)
		}

		savePressureData(arguments*) {
			this.callRemote("savePressureData", arguments*)
		}

		updateTyresDatabase(arguments*) {
			this.callRemote("updateTyresDatabase", arguments*)
		}
	}

	AdjustLapTime[] {
		Get {
			return this.iAdjustLapTime
		}
	}

	SaveTyrePressures[] {
		Get {
			return this.iSaveTyrePressures
		}
	}

	HasPressureData[] {
		Get {
			return this.iHasPressureData
		}
	}

	SessionDataActive[] {
		Get {
			return this.iSessionDataActive
		}
	}

	__New(configuration, remoteHandler := false, name := false, language := "__Undefined__"
		, synthesizer := false, speaker := false, vocalics := false, recognizer := false, listener := false, voiceServer := false) {
		base.__New(configuration, "Race Engineer", remoteHandler, name, language, synthesizer, speaker, vocalics, recognizer, listener, voiceServer)

		this.updateConfigurationValues({Announcements: {FuelWarning: true, DamageReporting: true, DamageAnalysis: true, PressureReporting: true, WeatherUpdate: true}})
	}

	updateConfigurationValues(values) {
		base.updateConfigurationValues(values)

		if values.HasKey("AdjustLapTime")
			this.iAdjustLapTime := values["AdjustLapTime"]

		if values.HasKey("SaveTyrePressures") {
			this.iSaveTyrePressures := values["SaveTyrePressures"]

			logMessage(kLogDebug, "SaveTyrePressures is now " . this.iSaveTyrePressures)
		}
	}

	updateSessionValues(values) {
		base.updateSessionValues(values)
	}

	updateDynamicValues(values) {
		base.updateDynamicValues(values)

		if values.HasKey("HasPressureData") {
			this.iHasPressureData := values["HasPressureData"]

			logMessage(kLogDebug, "HasPressureData is now " . this.iHasPressureData)
		}
	}

	handleVoiceCommand(grammar, words) {
		switch grammar {
			case "LapsRemaining":
				this.lapInfoRecognized(words)
			case "FuelRemaining":
				this.fuelInfoRecognized(words)
			case "BrakeWear":
				this.brakeWearRecognized(words)
			case "BrakeTemperatures":
				this.brakeTemperaturesRecognized(words)
			case "TyreWear":
				this.tyreWearRecognized(words)
			case "TyreTemperatures":
				this.tyreInfoRecognized(Array(this.getSpeaker().Fragments["Temperatures"]))
			case "TyrePressures":
				this.tyreInfoRecognized(Array(this.getSpeaker().Fragments["Pressures"]))
			case "Weather":
				this.weatherRecognized(words)
			case "PitstopPlan":
				this.clearContinuation()

				if !this.supportsPitstop()
					this.getSpeaker().speakPhrase("NoPitstop")
				else if this.hasPlannedPitstop() {
					this.getSpeaker().speakPhrase("ConfirmRePlan")

					this.setContinuation(ObjBindMethod(this, "planPitstopRecognized", words))
				}
				else {
					this.getSpeaker().speakPhrase("Confirm")

					Task.yield()

					loop 10
						Sleep 500

					this.planPitstopRecognized(words)
				}
			case "PitstopPrepare":
				this.clearContinuation()

				if !this.supportsPitstop()
					this.getSpeaker().speakPhrase("NoPitstop")
				else
					this.preparePitstopRecognized(words)
			case "PitstopAdjustFuel":
				this.clearContinuation()

				if !this.supportsPitstop()
					this.getSpeaker().speakPhrase("NoPitstop")
				else
					this.pitstopAdjustFuelRecognized(words)
			case "PitstopAdjustCompound":
				this.clearContinuation()

				if !this.supportsPitstop()
					this.getSpeaker().speakPhrase("NoPitstop")
				else
					this.pitstopAdjustCompoundRecognized(words)
			case "PitstopAdjustPressureUp", "PitstopAdjustPressureDown":
				this.clearContinuation()

				if !this.supportsPitstop()
					this.getSpeaker().speakPhrase("NoPitstop")
				else
					this.pitstopAdjustPressureRecognized(words)
			case "PitstopNoPressureChange":
				this.clearContinuation()

				if !this.supportsPitstop()
					this.getSpeaker().speakPhrase("NoPitstop")
				else
					this.pitstopAdjustNoPressureRecognized(words)
			case "PitstopNoTyreChange":
				this.clearContinuation()

				if !this.supportsPitstop()
					this.getSpeaker().speakPhrase("NoPitstop")
				else
					this.pitstopAdjustNoTyreRecognized(words)
			case "PitstopAdjustRepairSuspension":
				this.clearContinuation()

				if !this.supportsPitstop()
					this.getSpeaker().speakPhrase("NoPitstop")
				else
					this.pitstopAdjustRepairRecognized("Suspension", words)
			case "PitstopAdjustRepairBodywork":
				this.clearContinuation()

				if !this.supportsPitstop()
					this.getSpeaker().speakPhrase("NoPitstop")
				else
					this.pitstopAdjustRepairRecognized("Bodywork", words)
			case "PitstopAdjustRepairEngine":
				this.clearContinuation()

				if !this.supportsPitstop()
					this.getSpeaker().speakPhrase("NoPitstop")
				else
					this.pitstopAdjustRepairRecognized("Engine", words)
			default:
				base.handleVoiceCommand(grammar, words)
		}
	}

	lapInfoRecognized(words) {
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

	fuelInfoRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local lap, fuel

		lap := knowledgeBase.getValue("Lap", 0)

		if (lap == 0)
			this.getSpeaker().speakPhrase("Later")
		else {
			fuel := knowledgeBase.getValue("Lap." . lap . ".Fuel.Remaining", 0)

			if (fuel == 0)
				this.getSpeaker().speakPhrase("Later")
			else
				this.getSpeaker().speakPhrase("Fuel", {fuel: Floor(fuel)})
		}
	}

	tyreInfoRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local fragments := speaker.Fragments
		local value, lap

		if !this.hasEnoughData()
			return

		if inList(words, fragments["Temperatures"])
			value := "Temperature"
		else if inList(words, fragments["Pressures"])
			value := "Pressure"
		else {
			speaker.speakPhrase("Repeat")

			return
		}

		speaker.beginTalk()

		try {
			lap := knowledgeBase.getValue("Lap")

			speaker.speakPhrase((value == "Pressure") ? "Pressures" : "Temperatures")

			speaker.speakPhrase("TyreFL", {value: printNumber(knowledgeBase.getValue("Lap." . lap . ".Tyre." . value . ".FL"), 1)
										 , unit: (value == "Pressure") ? fragments["PSI"] : fragments["Degrees"]})

			speaker.speakPhrase("TyreFR", {value: printNumber(knowledgeBase.getValue("Lap." . lap . ".Tyre." . value . ".FR"), 1)
										 , unit: (value == "Pressure") ? fragments["PSI"] : fragments["Degrees"]})

			speaker.speakPhrase("TyreRL", {value: printNumber(knowledgeBase.getValue("Lap." . lap . ".Tyre." . value . ".RL"), 1)
										 , unit: (value == "Pressure") ? fragments["PSI"] : fragments["Degrees"]})

			speaker.speakPhrase("TyreRR", {value: printNumber(knowledgeBase.getValue("Lap." . lap . ".Tyre." . value . ".RR"), 1)
										 , unit: (value == "Pressure") ? fragments["PSI"] : fragments["Degrees"]})
		}
		finally {
			speaker.endTalk()
		}
	}

	tyreWearRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local lap := knowledgeBase.getValue("Lap")
		local flWear := knowledgeBase.getValue("Lap." . lap . ".Tyre.Wear.FL", kUndefined)
		local frWear, rlWear, rrWear

		if !this.hasEnoughData()
			return

		if (flWear == kUndefined)
			speaker.speakPhrase("NoWear")
		else {
			frWear := knowledgeBase.getValue("Lap." . lap . ".Tyre.Wear.FR")
			rlWear := knowledgeBase.getValue("Lap." . lap . ".Tyre.Wear.RL")
			rrWear := knowledgeBase.getValue("Lap." . lap . ".Tyre.Wear.RR")

			speaker.beginTalk()

			try {
				speaker.speakPhrase("Wear")

				speaker.speakPhrase("WearFL", {used: Round(flWear), remaining: Round(100 - flWear)})

				speaker.speakPhrase("WearFR", {used: Round(frWear), remaining: Round(100 - frWear)})

				speaker.speakPhrase("WearRL", {used: Round(rlWear), remaining: Round(100 - rlWear)})

				speaker.speakPhrase("WearRR", {used: Round(rrWear), remaining: Round(100 - rrWear)})
			}
			finally {
				speaker.endTalk()
			}
		}
	}

	brakeTemperaturesRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local fragments := speaker.Fragments
		local lap

		if !this.hasEnoughData()
			return

		speaker.beginTalk()

		try {
			lap := knowledgeBase.getValue("Lap")

			speaker.speakPhrase("Temperatures")

			speaker.speakPhrase("BrakeFL", {value: Round(knowledgeBase.getValue("Lap." . lap . ".Brake.Temperature.FL"))
										 , unit: fragments["Degrees"]})

			speaker.speakPhrase("BrakeFR", {value: Round(knowledgeBase.getValue("Lap." . lap . ".Brake.Temperature.FR"))
										 , unit: fragments["Degrees"]})

			speaker.speakPhrase("BrakeRL", {value: Round(knowledgeBase.getValue("Lap." . lap . ".Brake.Temperature.RL"))
										 , unit: fragments["Degrees"]})

			speaker.speakPhrase("BrakeRR", {value: Round(knowledgeBase.getValue("Lap." . lap . ".Brake.Temperature.RR"))
										 , unit: fragments["Degrees"]})
		}
		finally {
			speaker.endTalk()
		}
	}

	brakeWearRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local lap := knowledgeBase.getValue("Lap")
		local flWear := knowledgeBase.getValue("Lap." . lap . ".Brake.Wear.FL", kUndefined)
		local frWear, rlWear, rrWear

		if !this.hasEnoughData()
			return

		if (flWear == kUndefined)
			speaker.speakPhrase("NoWear")
		else {
			frWear := knowledgeBase.getValue("Lap." . lap . ".Brake.Wear.FR")
			rlWear := knowledgeBase.getValue("Lap." . lap . ".Brake.Wear.RL")
			rrWear := knowledgeBase.getValue("Lap." . lap . ".Brake.Wear.RR")

			speaker.beginTalk()

			try {
				speaker.speakPhrase("Wear")

				speaker.speakPhrase("WearFL", {used: printNumber(flWear, 1), remaining: printNumber(100 - flWear, 1)})

				speaker.speakPhrase("WearFR", {used: printNumber(frWear, 1), remaining: printNumber(100 - frWear, 1)})

				speaker.speakPhrase("WearRL", {used: printNumber(rlWear, 1), remaining: printNumber(100 - rlWear, 1)})

				speaker.speakPhrase("WearRR", {used: printNumber(rrWear, 1), remaining: printNumber(100 - rrWear, 1)})
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

	planPitstopRecognized(words) {
		this.planPitstop()
	}

	preparePitstopRecognized(words) {
		this.getSpeaker().speakPhrase("Confirm")

		Task.yield()

		loop 10
			Sleep 500

		this.preparePitstop()
	}

	pitstopAdjustFuelRecognized(words) {
		local speaker := this.getSpeaker()
		local fragments := speaker.Fragments
		local litresPosition, litres

		if !this.hasPlannedPitstop() {
			speaker.beginTalk()

			try {
				speaker.speakPhrase("NotPossible")

				speaker.speakPhrase("ConfirmPlan", false, true)
			}
			finally {
				speaker.endTalk()
			}

			this.setContinuation(ObjBindMethod(this, "planPitstop"))
		}
		else {
			litresPosition := inList(words, fragments["Litres"])

			if litresPosition {
				litres := words[litresPosition - 1]

				if this.isNumber(litres, litres) {
					speaker.speakPhrase("ConfirmFuelChange", {litres: litres}, true)

					this.setContinuation(ObjBindMethod(this, "updatePitstopFuel", litres))

					return
				}
			}

			speaker.speakPhrase("Repeat")
		}
	}

	pitstopAdjustCompoundRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local fragments := speaker.Fragments
		local compound, compoundColor, ignore, candidate

		if !this.hasPlannedPitstop() {
			speaker.beginTalk()

			try {
				speaker.speakPhrase("NotPossible")
				speaker.speakPhrase("ConfirmPlan", false, true)
			}
			finally {
				speaker.endTalk()
			}

			this.setContinuation(ObjBindMethod(this, "planPitstop"))
		}
		else {
			compound := false

			if inList(words, fragments["WetTyre"])
				compound := "Wet"
			else if inList(words, fragments["IntermediateTyre"])
				compound := "Intermediate"
			else if inList(words, fragments["DryTyre"])
				compound := "Dry"

			if compound {
				for ignore, candidate in new SessionDatabase().getTyreCompounds(knowledgeBase.getValue("Session.Simulator")
																			  , knowledgeBase.getValue("Session.Car")
																			  , knowledgeBase.getValue("Session.Track"))
					if (InStr(candidate, compound) = 1) {
						splitCompound(compound, compound, compoundColor)

						speaker.speakPhrase("ConfirmCompoundChange", {compound: fragments[compound . "Tyre"]}, true)

						this.setContinuation(ObjBindMethod(this, "updatePitstopTyreCompound", compound, compoundColor))
					}
					else
						speaker.speakPhrase("CompoundNotAvailable", {compound: fragments[compound . "Tyre"]})
			}
			else
				speaker.speakPhrase("Repeat")
		}
	}

	pitstopAdjustPressureRecognized(words) {
		local speaker := this.getSpeaker()
		local fragments := speaker.Fragments
		local tyreType, action, pointPosition, found, psiValue, tenthPsiValue, ignore, word, startChar, tyre, delta

		static tyreTypeFragments := false

		if !this.hasPlannedPitstop() {
			speaker.beginTalk()

			try {
				speaker.speakPhrase("NotPossible")
				speaker.speakPhrase("ConfirmPlan", false, true)
			}
			finally {
				speaker.endTalk()
			}

			this.setContinuation(ObjBindMethod(this, "planPitstop"))
		}
		else {
			if !tyreTypeFragments
				tyreTypeFragments := {FL: fragments["FrontLeft"], FR: fragments["FrontRight"], RL: fragments["RearLeft"], RR: fragments["RearRight"]}

			tyreType := false

			if inList(words, fragments["Front"]) {
				if inList(words, fragments["Left"])
					tyreType := "FL"
				else if inList(words, fragments["Right"])
					tyreType := "FR"
			}
			else if inList(words, fragments["Rear"]) {
				if inList(words, fragments["Left"])
					tyreType := "RL"
				else if inList(words, fragments["Right"])
					tyreType := "RR"
			}

			if tyreType {
				action := false

				if (inList(words, fragments["Increase"]) || inList(words, fragments["More"]))
					action := kIncrease
				else if (inList(words, fragments["Decrease"]) || inList(words, fragments["Less"]))
					action := kDecrease

				pointPosition := inList(words, fragments["Point"])
				found := false

				if pointPosition {
					psiValue := words[pointPosition - 1]
					tenthPsiValue := words[pointPosition + 1]

					found := (this.isNumber(psiValue, psiValue) && this.isNumber(tenthPsiValue, tenthPsiValue))
				}
				else
					for ignore, word in words {
						if word is Float
						{
							psiValue := Floor(word)
							tenthPsiValue := Round((word - psiValue) * 10)

							found := true

							break
						}
						else {
							startChar := SubStr(word, 1, 1)

							if startChar is Integer
								if (StrLen(word) = 2) {
									found := (this.isNumber(startChar, psiValue) && this.isNumber(SubStr(word, 2, 1), tenthPsiValue))

									if found
										break
								}
						}
					}

				if found {
					tyre := tyreTypeFragments[tyreType]
					action := fragments[action]

					delta := Round(psiValue + (tenthPsiValue / 10), 1)

					speaker.speakPhrase("ConfirmPsiChange", {action: action, tyre: tyre, unit: fragments["PSI"], delta: printNumber(delta, 1)}, true)

					this.setContinuation(ObjBindMethod(this, "updatePitstopTyrePressure", tyreType, (action == kIncrease) ? delta : (delta * -1)))

					return
				}
			}

			speaker.speakPhrase("Repeat")
		}
	}

	pitstopAdjustNoPressureRecognized(words) {
		local speaker := this.getSpeaker()

		if !this.hasPlannedPitstop() {
			speaker.beginTalk()

			try {
				speaker.speakPhrase("NotPossible")
				speaker.speakPhrase("ConfirmPlan", false, true)
			}
			finally {
				speaker.endTalk()
			}

			this.setContinuation(ObjBindMethod(this, "planPitstop"))
		}
		else {
			speaker.speakPhrase("ConfirmNoPressureChange", false, true)

			this.setContinuation(ObjBindMethod(this, "updatePitstopPressures"))
		}
	}

	pitstopAdjustNoTyreRecognized(words) {
		local speaker := this.getSpeaker()

		if !this.hasPlannedPitstop() {
			speaker.beginTalk()

			try {
				speaker.speakPhrase("NotPossible")
				speaker.speakPhrase("ConfirmPlan", false, true)
			}
			finally {
				speaker.endTalk()
			}

			this.setContinuation(ObjBindMethod(this, "planPitstop"))
		}
		else {
			speaker.speakPhrase("ConfirmNoTyreChange", false, true)

			this.setContinuation(ObjBindMethod(this, "updatePitstopTyreChange"))
		}
	}

	pitstopAdjustRepairRecognized(repairType, words) {
		local speaker := this.getSpeaker()
		local fragments := speaker.Fragments
		local negation

		if !this.hasPlannedPitstop() {
			speaker.beginTalk()

			try {
				speaker.speakPhrase("NotPossible")
				speaker.speakPhrase("ConfirmPlan", false, true)
			}
			finally {
				speaker.endTalk()
			}

			this.setContinuation(ObjBindMethod(this, "planPitstop"))
		}
		else {
			negation := ""

			if inList(words, fragments["Not"])
				negation := fragments["Not"]

			speaker.speakPhrase("ConfirmRepairChange", {damage: fragments[repairType], negation: negation}, true)

			this.setContinuation(ObjBindMethod(this, "updatePitstopRepair", repairType, negation = ""))
		}
	}

	updatePitstopFuel(litres) {
		local speaker := this.getSpeaker()

		speaker.beginTalk()

		try {
			if !this.hasPlannedPitstop() {
				speaker.speakPhrase("NotPossible")
				speaker.speakPhrase("ConfirmPlan", false, true)

				this.setContinuation(ObjBindMethod(this, "planPitstop"))
			}
			else {
				this.KnowledgeBase.setValue("Pitstop.Planned.Fuel", litres)

				if this.Debug[kDebugKnowledgeBase]
					this.dumpKnowledgeBase(this.KnowledgeBase)

				speaker.speakPhrase("ConfirmPlanUpdate")
				speaker.speakPhrase("MoreChanges", false, true)
			}
		}
		finally {
			speaker.endTalk()
		}
	}

	updatePitstopTyreCompound(compound, color) {
		local speaker := this.getSpeaker()
		local knowledgeBase, ignore, tyreType

		speaker.beginTalk()

		try {
			if !this.hasPlannedPitstop() {
				speaker.speakPhrase("NotPossible")
				speaker.speakPhrase("ConfirmPlan", false, true)

				this.setContinuation(ObjBindMethod(this, "planPitstop"))
			}
			else {
				knowledgeBase := this.KnowledgeBase

				if (knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound") != compound) {
					speaker.speakPhrase("ConfirmPlanUpdate")

					knowledgeBase.setValue("Tyre.Compound.Target", compound)
					knowledgeBase.setValue("Tyre.Compound.Color.Target", color)

					knowledgeBase.clearFact("Pitstop.Planned.Tyre.Compound")
					knowledgeBase.clearFact("Pitstop.Planned.Tyre.Compound.Color")

					for ignore, tyreType in ["FL", "FR", "RL", "RR"] {
						knowledgeBase.clearFact("Pitstop.Planned.Tyre.Pressure." . tyreType)
						knowledgeBase.clearFact("Pitstop.Planned.Tyre.Pressure." . tyreType . ".Increment")
					}

					knowledgeBase.clearFact("Pitstop.Planned.Tyre.Pressure.Correction")

					this.planPitstop({Update: true, Pressures: true, Confirm: false})

					speaker.speakPhrase("MoreChanges", false, true)
				}
				else {
					speaker.speakPhrase("ConfirmPlanUpdate")
					speaker.speakPhrase("MoreChanges", false, true)
				}
			}
		}
		finally {
			speaker.endTalk()
		}
	}

	updatePitstopTyrePressure(tyreType, delta) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local targetValue, targetIncrement

		speaker.beginTalk()

		try {
			if !this.hasPlannedPitstop() {
				speaker.speakPhrase("NotPossible")
				speaker.speakPhrase("ConfirmPlan", false, true)

				this.setContinuation(ObjBindMethod(this, "planPitstop"))
			}
			else {
				targetValue := knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure." . tyreType)
				targetIncrement := knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure." . tyreType . ".Increment")

				knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure." . tyreType, targetValue + delta)
				knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure." . tyreType . ".Increment", targetIncrement + delta)

				if this.Debug[kDebugKnowledgeBase]
					this.dumpKnowledgeBase(this.KnowledgeBase)

				speaker.speakPhrase("ConfirmPlanUpdate")
				speaker.speakPhrase("MoreChanges", false, true)
			}
		}
		finally {
			speaker.endTalk()
		}
	}

	updatePitstopPressures() {
		local speaker := this.getSpeaker()
		local knowledgeBase

		speaker.beginTalk()

		try {
			if !this.hasPlannedPitstop() {
				speaker.speakPhrase("NotPossible")
				speaker.speakPhrase("ConfirmPlan", false, true)

				this.setContinuation(ObjBindMethod(this, "planPitstop"))
			}
			else {
				knowledgeBase := this.KnowledgeBase

				if (knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound", "Dry") = "Dry") {
					knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.FL", knowledgeBase.getValue("Session.Setup.Tyre.Dry.Pressure.FL", 26.1))
					knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.FR", knowledgeBase.getValue("Session.Setup.Tyre.Dry.Pressure.FR", 26.1))
					knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.RL", knowledgeBase.getValue("Session.Setup.Tyre.Dry.Pressure.RL", 26.1))
					knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.RR", knowledgeBase.getValue("Session.Setup.Tyre.Dry.Pressure.RR", 26.1))
				}
				else {
					knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.FL", knowledgeBase.getValue("Session.Setup.Tyre.Wet.Pressure.FL", 26.1))
					knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.FR", knowledgeBase.getValue("Session.Setup.Tyre.Wet.Pressure.FR", 26.1))
					knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.RL", knowledgeBase.getValue("Session.Setup.Tyre.Wet.Pressure.RL", 26.1))
					knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.RR", knowledgeBase.getValue("Session.Setup.Tyre.Wet.Pressure.RR", 26.1))
				}

				knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.FL.Increment", 0)
				knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.FR.Increment", 0)
				knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.RL.Increment", 0)
				knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.RR.Increment", 0)

				if this.Debug[kDebugKnowledgeBase]
					this.dumpKnowledgeBase(knowledgeBase)

				speaker.speakPhrase("ConfirmPlanUpdate")
				speaker.speakPhrase("MoreChanges", false, true)
			}
		}
		finally {
			speaker.endTalk()
		}
	}

	updatePitstopTyreChange() {
		local speaker := this.getSpeaker()
		local knowledgeBase

		speaker.beginTalk()

		try {
			if !this.hasPlannedPitstop() {
				speaker.speakPhrase("NotPossible")
				speaker.speakPhrase("ConfirmPlan", false, true)

				this.setContinuation(ObjBindMethod(this, "planPitstop"))
			}
			else {
				knowledgeBase := this.KnowledgeBase

				knowledgeBase.setValue("Pitstop.Planned.Tyre.Compound", false)
				knowledgeBase.setValue("Pitstop.Planned.Tyre.Compound.Color", false)

				if this.Debug[kDebugKnowledgeBase]
					this.dumpKnowledgeBase(knowledgeBase)

				speaker.speakPhrase("ConfirmPlanUpdate")
				speaker.speakPhrase("MoreChanges", false, true)
			}
		}
		finally {
			speaker.endTalk()
		}
	}

	updatePitstopRepair(repairType, repair) {
		local speaker := this.getSpeaker()

		speaker.beginTalk()

		try {
			if !this.hasPlannedPitstop() {
				speaker.speakPhrase("NotPossible")
				speaker.speakPhrase("ConfirmPlan", false, true)

				this.setContinuation(ObjBindMethod(this, "planPitstop"))
			}
			else {
				this.KnowledgeBase.setValue("Pitstop.Planned.Repair." . repairType, repair)

				if this.Debug[kDebugKnowledgeBase]
					this.dumpKnowledgeBase(this.KnowledgeBase)

				speaker.speakPhrase("ConfirmPlanUpdate")
				speaker.speakPhrase("MoreChanges", false, true)
			}
		}
		finally {
			speaker.endTalk()
		}
	}

	collectTyrePressures() {
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

		return getConfigurationValue(this.Settings, "Session Settings", "Pressures." . session, default)
	}

	readSettings(ByRef settings) {
		return combine(base.readSettings(settings)
					 , {"Session.Settings.Pitstop.Delta": getConfigurationValue(settings, "Strategy Settings", "Pitstop.Delta"
																			  , getDeprecatedConfigurationValue(settings
																											  , "Session Settings"
																											  , "Race Settings"
																											  , "Pitstop.Delta", 30))
					  , "Session.Settings.Damage.Suspension.Repair": getDeprecatedConfigurationValue(settings, "Session Settings"
																								   , "Race Settings"
																								   , "Damage.Suspension.Repair", "Always")
					  , "Session.Settings.Damage.Suspension.Repair.Threshold": getDeprecatedConfigurationValue(settings, "Session Settings"
																										     , "Race Settings"
																										     , "Damage.Suspension.Repair.Threshold", 0)
					  , "Session.Settings.Damage.Bodywork.Repair": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings"
																								 , "Damage.Bodywork.Repair", "Impact")
					  , "Session.Settings.Damage.Bodywork.Repair.Threshold": getDeprecatedConfigurationValue(settings, "Session Settings"
																										   , "Race Settings"
																										   , "Damage.Bodywork.Repair.Threshold", 1)
					  , "Session.Settings.Damage.Engine.Repair": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings"
																							   , "Damage.Engine.Repair", "Impact")
					  , "Session.Settings.Damage.Engine.Repair.Threshold": getDeprecatedConfigurationValue(settings, "Session Settings"
																										 , "Race Settings"
																										 , "Damage.Engine.Repair.Threshold", 1)
					  , "Session.Settings.Tyre.Compound.Change": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings"
																										 , "Tyre.Compound.Change", "Never")
					  , "Session.Settings.Tyre.Compound.Change.Threshold": getDeprecatedConfigurationValue(settings, "Session Settings"
																										 , "Race Settings"
																										 , "Tyre.Compound.Change.Threshold", 0)
					  , "Session.Settings.Tyre.Pressure.Correction.Temperature": getConfigurationValue(settings, "Session Settings"
																									 , "Tyre.Pressure.Correction.Temperature", true)
					  , "Session.Settings.Tyre.Pressure.Correction.Setup": getConfigurationValue(settings, "Session Settings"
																							   , "Tyre.Pressure.Correction.Setup", false)
					  , "Session.Settings.Tyre.Pressure.Correction.Pressure": getConfigurationValue(settings, "Session Settings"
																								  , "Tyre.Pressure.Correction.Pressure", false)
					  , "Session.Settings.Tyre.Dry.Pressure.Target.FL": getDeprecatedConfigurationValue(settings, "Session Settings"
																									  , "Race Settings"
																									  , "Tyre.Dry.Pressure.Target.FL", 27.7)
					  , "Session.Settings.Tyre.Dry.Pressure.Target.FR": getDeprecatedConfigurationValue(settings, "Session Settings"
																									  , "Race Settings"
																									  , "Tyre.Dry.Pressure.Target.FR", 27.7)
					  , "Session.Settings.Tyre.Dry.Pressure.Target.RL": getDeprecatedConfigurationValue(settings, "Session Settings"
																									  , "Race Settings"
																									  , "Tyre.Dry.Pressure.Target.RL", 27.7)
					  , "Session.Settings.Tyre.Dry.Pressure.Target.RR": getDeprecatedConfigurationValue(settings, "Session Settings"
																									  , "Race Settings"
																									  , "Tyre.Dry.Pressure.Target.RR", 27.7)
					  , "Session.Settings.Tyre.Wet.Pressure.Target.FL": getDeprecatedConfigurationValue(settings, "Session Settings"
																									  , "Race Settings"
																									  , "Tyre.Wet.Pressure.Target.FL", 30.0)
					  , "Session.Settings.Tyre.Wet.Pressure.Target.FR": getDeprecatedConfigurationValue(settings, "Session Settings"
																									  , "Race Settings"
																									  , "Tyre.Wet.Pressure.Target.FR", 30.0)
					  , "Session.Settings.Tyre.Wet.Pressure.Target.RL": getDeprecatedConfigurationValue(settings, "Session Settings"
																									  , "Race Settings"
																									  , "Tyre.Wet.Pressure.Target.RL", 30.0)
					  , "Session.Settings.Tyre.Wet.Pressure.Target.RR": getDeprecatedConfigurationValue(settings, "Session Settings"
																									  , "Race Settings"
																									  , "Tyre.Wet.Pressure.Target.RR", 30.0)
					  , "Session.Settings.Tyre.Pressure.Deviation": getDeprecatedConfigurationValue(settings, "Session Settings"
																									  , "Race Settings"
																									  , "Tyre.Pressure.Deviation", 0.2)
					  , "Session.Setup.Tyre.Set.Fresh": getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup"
																					  , "Tyre.Set.Fresh", 8)
					  , "Session.Setup.Tyre.Set": getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Set", 7)
					  , "Session.Setup.Tyre.Dry.Pressure.FL": getDeprecatedConfigurationValue(settings, "Session Setup"
																							, "Race Setup", "Tyre.Dry.Pressure.FL", 26.1)
					  , "Session.Setup.Tyre.Dry.Pressure.FR": getDeprecatedConfigurationValue(settings, "Session Setup"
																							, "Race Setup", "Tyre.Dry.Pressure.FR", 26.1)
					  , "Session.Setup.Tyre.Dry.Pressure.RL": getDeprecatedConfigurationValue(settings, "Session Setup"
																							, "Race Setup", "Tyre.Dry.Pressure.RL", 26.1)
					  , "Session.Setup.Tyre.Dry.Pressure.RR": getDeprecatedConfigurationValue(settings, "Session Setup"
																							, "Race Setup", "Tyre.Dry.Pressure.RR", 26.1)
					  , "Session.Setup.Tyre.Wet.Pressure.FL": getDeprecatedConfigurationValue(settings, "Session Setup"
																							, "Race Setup", "Tyre.Wet.Pressure.FL", 28.2)
					  , "Session.Setup.Tyre.Wet.Pressure.FR": getDeprecatedConfigurationValue(settings, "Session Setup"
																							, "Race Setup", "Tyre.Wet.Pressure.FR", 28.2)
					  , "Session.Setup.Tyre.Wet.Pressure.RL": getDeprecatedConfigurationValue(settings, "Session Setup"
																							, "Race Setup", "Tyre.Wet.Pressure.RL", 28.2)
					  , "Session.Setup.Tyre.Wet.Pressure.RR": getDeprecatedConfigurationValue(settings, "Session Setup"
																							, "Race Setup", "Tyre.Wet.Pressure.RR", 28.2)})
	}

	createSession(settings, data) {
		local facts := base.createSession(settings, data)
		local configuration := this.Configuration
		local simulatorName := this.SettingsDatabase.getSimulatorName(facts["Session.Simulator"])

		facts["Session.Settings.Lap.Learning.Laps"]
			:= getConfigurationValue(configuration, "Race Engineer Analysis", simulatorName . ".LearningLaps", 1)
		facts["Session.Settings.Lap.History.Considered"]
			:= getConfigurationValue(configuration, "Race Engineer Analysis", simulatorName . ".ConsideredHistoryLaps", 5)
		facts["Session.Settings.Lap.History.Damping"]
			:= getConfigurationValue(configuration, "Race Engineer Analysis", simulatorName . ".HistoryLapsDamping", 0.2)
		facts["Session.Settings.Damage.Analysis.Laps"]
			:= getConfigurationValue(configuration, "Race Engineer Analysis", simulatorName . ".DamageAnalysisLaps", 1)

		facts["Session.Settings.Tyre.Pressure.Correction.Temperature.Air"]
			:= getConfigurationValue(settings, "Session Settings", "Tyre.Pressure.Correction.Temperature.Air", -0.1)
		facts["Session.Settings.Tyre.Pressure.Correction.Temperature.Track"]
			:= getConfigurationValue(settings, "Session Settings", "Tyre.Pressure.Correction.Temperature.Track", -0.02)

		facts["Session.Setup.Tyre.Compound"]
			:= getConfigurationValue(data, "Car Data", "TyreCompound"
								   , getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Compound", "Dry"))
		facts["Session.Setup.Tyre.Compound.Color"]
			:= getConfigurationValue(data, "Car Data", "TyreCompoundColor"
								   , getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Compound.Color", "Black"))

		return facts
	}

	startSession(settings, data) {
		local facts, simulatorName, configuration, deprecated, saveSettings, speaker, strategistPlugin, strategistName
		local knowledgeBase

		if !IsObject(settings)
			settings := readConfiguration(settings)

		if !IsObject(data)
			data := readConfiguration(data)

		facts := this.createSession(settings, data)

		simulatorName := this.Simulator
		configuration := this.Configuration

		deprecated := getConfigurationValue(configuration, "Race Engineer Shutdown", simulatorName . ".SaveSettings", kNever)
		saveSettings := getConfigurationValue(configuration, "Race Assistant Shutdown", simulatorName . ".SaveSettings", deprecated)

		this.updateConfigurationValues({LearningLaps: getConfigurationValue(configuration, "Race Engineer Analysis", simulatorName . ".LearningLaps", 1)
									  , AdjustLapTime: getConfigurationValue(configuration, "Race Engineer Analysis", simulatorName . ".AdjustLapTime", true)
									  , SaveSettings: saveSettings
									  , SaveTyrePressures: getConfigurationValue(configuration, "Race Engineer Shutdown", simulatorName . ".SaveTyrePressures", kAsk)})

		knowledgeBase := this.createKnowledgeBase(facts)

		this.updateDynamicValues({KnowledgeBase: knowledgeBase, HasPressureData: false
								, BestLapTime: 0, OverallTime: 0, LastFuelAmount: 0, InitialFuelAmount: 0, EnoughData: false})

		if this.Speaker {
			speaker := this.getSpeaker()

			speaker.beginTalk()

			try {
				speaker.speakPhrase("GreetingEngineer")

				Process Exist, Race Strategist.exe

				if ErrorLevel {
					strategistPlugin := new Plugin("Race Strategist", kSimulatorConfiguration)
					strategistName := strategistPlugin.getArgumentValue("raceAssistantName", false)

					if strategistName {
						speaker.speakPhrase("GreetingStrategist", {strategist: strategistName})

						speaker.speakPhrase("CallUs")
					}
					else
						speaker.speakPhrase("CallMe")
				}
				else
					speaker.speakPhrase("CallMe")
			}
			finally {
				speaker.endTalk()
			}
		}

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledgeBase(this.KnowledgeBase)
	}

	finishSession(shutdown := true) {
		local knowledgeBase := this.KnowledgeBase

		if knowledgeBase {
			logMessage(kLogDebug, "Finish: Speaker is " . this.Speaker)
			logMessage(kLogDebug, "Finish: Listener is " . this.Listener)
			logMessage(kLogDebug, "Finish: SaveTyrePressures is " . this.SaveTyrePressures)
			logMessage(kLogDebug, "Finish: HasPressureData is " . this.HasPressureData)
			logMessage(kLogDebug, "Finish: collectTyrePressures() is " . this.collectTyrePressures())

			if (this.Session == kSessionRace) {
				Process Exist, Race Strategist.exe

				if ErrorLevel
					Sleep 5000
			}

			if (shutdown && this.Speaker)
				this.getSpeaker().speakPhrase("Bye")

			if (shutdown && (knowledgeBase.getValue("Lap", 0) > this.LearningLaps)) {
				this.shutdownSession("Before")

				if (((this.SaveTyrePressures = kAsk) && this.collectTyrePressures() && this.HasPressureData) || (this.SaveSettings = kAsk)) {
					this.getSpeaker().speakPhrase("ConfirmDataUpdate", false, true)

					this.setContinuation(ObjBindMethod(this, "shutdownSession", "After"))

					Task.startTask(ObjBindMethod(this, "forceFinishSession"), 120000, kLowPriority)

					return
				}
			}

			this.updateDynamicValues({KnowledgeBase: false})
		}

		this.updateDynamicValues({BestLapTime: 0, OverallTime: 0, LastFuelAmount: 0, InitialFuelAmount: 0, EnoughData: false, HasPressureData: false})
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

	shutdownSession(phase) {
		this.iSessionDataActive := true

		try {
			if (((phase = "After") && (this.SaveSettings = kAsk)) || ((phase = "Before") && (this.SaveSettings = kAlways)))
				if (this.Session == kSessionRace)
					this.saveSessionSettings()

			if (((phase = "After") && (this.SaveTyrePressures = kAsk)) || ((phase = "Before") && (this.SaveTyrePressures = kAlways)))
				if (this.HasPressureData && this.collectTyrePressures())
					this.updateTyresDatabase()
		}
		finally {
			this.iSessionDataActive := false
		}

		if (phase = "After") {
			if this.Speaker
				this.getSpeaker().speakPhrase("DataUpdated")

			this.updateDynamicValues({KnowledgeBase: false, HasPressureData: false})

			this.finishSession()
		}
	}

	prepareData(lapNumber, data) {
		local knowledgeBase, bodyworkDamage, suspensionDamage

		data := base.prepareData(lapNumber, data)

		knowledgeBase := this.KnowledgeBase

		if (knowledgeBase.getValue("Lap", false) != lapNumber) {
			bodyworkDamage := string2Values(",", getConfigurationValue(data, "Car Data", "BodyworkDamage", ""))

			knowledgeBase.setFact("Lap." . lapNumber . ".Damage.Bodywork.Front", Round(bodyworkDamage[1], 2))
			knowledgeBase.setFact("Lap." . lapNumber . ".Damage.Bodywork.Rear", Round(bodyworkDamage[2], 2))
			knowledgeBase.setFact("Lap." . lapNumber . ".Damage.Bodywork.Left", Round(bodyworkDamage[3], 2))
			knowledgeBase.setFact("Lap." . lapNumber . ".Damage.Bodywork.Right", Round(bodyworkDamage[4], 2))
			knowledgeBase.setFact("Lap." . lapNumber . ".Damage.Bodywork.Center", Round(bodyworkDamage[5], 2))

			suspensionDamage := string2Values(",", getConfigurationValue(data, "Car Data", "SuspensionDamage", ""))

			knowledgeBase.setFact("Lap." . lapNumber . ".Damage.Suspension.FL", Round(suspensionDamage[1], 2))
			knowledgeBase.setFact("Lap." . lapNumber . ".Damage.Suspension.FR", Round(suspensionDamage[2], 2))
			knowledgeBase.setFact("Lap." . lapNumber . ".Damage.Suspension.RL", Round(suspensionDamage[3], 2))
			knowledgeBase.setFact("Lap." . lapNumber . ".Damage.Suspension.RR", Round(suspensionDamage[4], 2))

			knowledgeBase.setFact("Lap." . lapNumber . ".Damage.Engine"
								, Round(getConfigurationValue(data, "Car Data", "EngineDamage", 0), 1))
		}

		return data
	}

	addLap(lapNumber, data) {
		local knowledgeBase := this.KnowledgeBase
		local driverForname := ""
		local driverSurname := ""
		local driverNickname := ""
		local result, currentCompound, currentCompoundColor, targetCompound, targetCompoundColor, prefix
		local coldPressures, hotPressures, pressuresLosses, airTemperature, trackTemperature, weatherNow

		static lastLap := 0

		if (lapNumber <= lastLap)
			lastLap := 0
		else if ((lastLap == 0) && (lapNumber > 1))
			lastLap := (lapNumber - 1)

		if (this.Speaker && (lapNumber > 1)) {
			driverForname := knowledgeBase.getValue("Driver.Forname", "John")
			driverSurname := knowledgeBase.getValue("Driver.Surname", "Doe")
			driverNickname := knowledgeBase.getValue("Driver.Nickname", "JDO")
		}

		result := base.addLap(lapNumber, data)

		if !result
			return false

		if (this.Speaker && (lastLap < (lapNumber - 2)) && (computeDriverName(driverForname, driverSurname, driverNickname) != this.DriverFullName))
			this.getSpeaker().speakPhrase("WelcomeBack")

		lastLap := lapNumber

		if (this.SaveTyrePressures != kNever) {
			knowledgeBase := this.KnowledgeBase

			currentCompound := knowledgeBase.getValue("Tyre.Compound", false)
			currentCompoundColor := knowledgeBase.getValue("Tyre.Compound.Color", false)

			if this.hasEnoughData(false) {
				targetCompound := knowledgeBase.getValue("Tyre.Compound.Target", false)
				targetCompoundColor := knowledgeBase.getValue("Tyre.Compound.Color.Target", false)
			}
			else {
				targetCompound := currentCompound
				targetCompoundColor := currentCompoundColor
			}

			if (currentCompound && (currentCompound = targetCompound) && (currentCompoundColor = targetCompoundColor)) {
				if (lapNumber <= knowledgeBase.getValue("Session.Settings.Lap.Learning.Laps", 2)) {
					if (currentCompound = "Dry")
						prefix := "Session.Setup.Tyre.Dry.Pressure."
					else
						prefix := "Session.Setup.Tyre.Wet.Pressure."
				}
				else if this.hasEnoughData(false)
					prefix := "Tyre.Pressure.Target."
				else
					prefix := false

				if prefix {
					coldPressures := values2String(",", Round(knowledgeBase.getValue(prefix . "FL"), 1)
													  , Round(knowledgeBase.getValue(prefix . "FR"), 1)
													  , Round(knowledgeBase.getValue(prefix . "RL"), 1)
													  , Round(knowledgeBase.getValue(prefix . "RR"), 1))

					hotPressures := values2String(",", Round(knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Pressure.FL"), 1)
													 , Round(knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Pressure.FR"), 1)
													 , Round(knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Pressure.RL"), 1)
													 , Round(knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Pressure.RR"), 1))

					prefix := "Tyre.Pressure.Loss."

					pressuresLosses := values2String(",", Round(knowledgeBase.getValue(prefix . "FL", 0), 1)
														, Round(knowledgeBase.getValue(prefix . "FR", 0), 1)
														, Round(knowledgeBase.getValue(prefix . "RL", 0), 1)
														, Round(knowledgeBase.getValue(prefix . "RR", 0), 1))

					airTemperature := Round(getConfigurationValue(data, "Weather Data", "Temperature", 0))
					trackTemperature := Round(getConfigurationValue(data, "Track Data", "Temperature", 0))

					if (airTemperature = 0)
						airTemperature := Round(getConfigurationValue(data, "Car Data", "AirTemperature", 0))

					if (trackTemperature = 0)
						trackTemperature := Round(getConfigurationValue(data, "Car Data", "RoadTemperature", 0))

					weatherNow := getConfigurationValue(data, "Weather Data", "Weather", "Dry")

					logMessage(kLogDebug, "Saving pressures for " . lapNumber)

					this.savePressureData(lapNumber, knowledgeBase.getValue("Session.Simulator")
										, knowledgeBase.getValue("Session.Car"), knowledgeBase.getValue("Session.Track")
										, weatherNow, airTemperature, trackTemperature
										, currentCompound, currentCompoundColor, coldPressures, hotPressures, pressuresLosses)
				}
			}
		}

		return result
	}

	updateLap(lapNumber, data) {
		local knowledgeBase := this.KnowledgeBase
		local result := base.updateLap(lapNumber, data)
		local needProduce := false
		local tyrePressures := string2Values(",", getConfigurationValue(data, "Car Data", "TyrePressure", ""))
		local threshold := knowledgeBase.getValue("Session.Settings.Tyre.Pressure.Deviation")
		local changed := false
		local fact, index, tyreType, oldValue, newValue, tyreTemperatures
		local bodyworkDamage, suspensionDamage, position

		for index, tyreType in ["FL", "FR", "RL", "RR"] {
			newValue := Round(tyrePressures[index], 2)
			fact := ("Lap." . lapNumber . ".Tyre.Pressure." . tyreType)

			if (Abs(knowledgeBase.getValue(fact) - newValue) > threshold) {
				knowledgeBase.setValue(fact, newValue)

				changed := true
			}
		}

		if changed {
			knowledgeBase.addFact("Tyre.Update.Pressure", true)

			needProduce := true
		}

		tyreTemperatures := string2Values(",", getConfigurationValue(data, "Car Data", "TyreTemperature", ""))

		for index, tyreType in ["FL", "FR", "RL", "RR"]
			knowledgeBase.setValue("Lap." . lapNumber . ".Tyre.Temperature." . tyreType, Round(tyreTemperatures[index], 2))

		bodyworkDamage := string2Values(",", getConfigurationValue(data, "Car Data", "BodyworkDamage", ""))
		changed := false

		for index, position in ["Front", "Rear", "Left", "Right", "Center"] {
			newValue := Round(bodyworkDamage[index], 2)
			fact := ("Lap." . lapNumber . ".Damage.Bodywork." . position)
			oldValue := knowledgeBase.getValue(fact, 0)

			if (oldValue < newValue)
				knowledgeBase.setValue(fact, newValue)

			changed := (changed || (Round(oldValue) < Round(newValue)))
		}

		if changed {
			knowledgeBase.addFact("Damage.Update.Bodywork", lapNumber)

			needProduce := true
		}

		suspensionDamage := string2Values(",", getConfigurationValue(data, "Car Data", "SuspensionDamage", ""))
		changed := false

		for index, position in ["FL", "FR", "RL", "RR"] {
			newValue := Round(suspensionDamage[index], 2)
			fact := ("Lap." . lapNumber . ".Damage.Suspension." . position)
			oldValue := knowledgeBase.getValue(fact, 0)

			if (oldValue < newValue)
				knowledgeBase.setValue(fact, newValue)

			changed := (changed || (Round(oldValue) < Round(newValue)))
		}

		if changed {
			knowledgeBase.addFact("Damage.Update.Suspension", lapNumber)

			needProduce := true
		}

		newValue := Round(getConfigurationValue(data, "Car Data", "EngineDamage", 0), 1)
		fact := ("Lap." . lapNumber . ".Damage.Engine")

		if (knowledgeBase.getValue(fact, 0) < newValue) {
			knowledgeBase.setValue(fact, newValue)

			knowledgeBase.addFact("Damage.Update.Suspension", lapNumber)

			needProduce := true
		}

		if needProduce {
			if knowledgeBase.produce()
				result := true

			if this.Debug[kDebugKnowledgeBase]
				this.dumpKnowledgeBase(this.KnowledgeBase)
		}

		return result
	}

	savePressureData(lapNumber, simulator, car, track, weather, airTemperature, trackTemperature
				   , compound, compoundColor, coldPressures, hotPressures, pressuresLosses) {
		this.iSessionDataActive := true

		try {
			if (this.RemoteHandler && this.collectTyrePressures()) {
				this.updateDynamicValues({HasPressureData: true})

				this.RemoteHandler.savePressureData(lapNumber, simulator, car, track, weather, airTemperature, trackTemperature
												  , compound, compoundColor, coldPressures, hotPressures, pressuresLosses)
			}
		}
		finally {
			this.iSessionDataActive := false
		}
	}

	updateTyresDatabase() {
		if (this.RemoteHandler && this.collectTyrePressures())
			this.RemoteHandler.updateTyresDatabase()

		this.updateDynamicValues({HasPressureData: false})
	}

	hasPlannedPitstop() {
		return (this.KnowledgeBase ? this.KnowledgeBase.getValue("Pitstop.Planned", false) : false)
	}

	hasPreparedPitstop() {
		return (this.KnowledgeBase ? this.KnowledgeBase.getValue("Pitstop.Prepared", false) : false)
	}

	supportsPitstop() {
		if this.RemoteHandler
			switch this.Session {
				case kSessionPractice:
					return getConfigurationValue(this.Settings, "Session Settings", "Pitstop.Practice", false)
				case kSessionQualification:
					return getConfigurationValue(this.Settings, "Session Settings", "Pitstop.Qualification", false)
				case kSessionRace:
					return getConfigurationValue(this.Settings, "Session Settings", "Pitstop.Race", true)
				default:
					return false
			}
		else
			return false
	}

	requestInformation(category, arguments*) {
		switch category {
			case "Time":
				this.timeRecognized([])
			case "LapsRemaining":
				this.lapInfoRecognized([])
			case "FuelRemaining":
				this.fuelInfoRecognized([])
			case "Weather":
				this.weatherRecognized([])
			case "TyrePressures":
				this.tyreInfoRecognized(Array(this.getSpeaker().Fragments["Pressures"]))
			case "TyreTemperatures":
				this.tyreInfoRecognized(Array(this.getSpeaker().Fragments["Temperatures"]))
			case "TyreWear":
				this.tyreWearRecognized([])
			case "BrakeTemperatures":
				this.brakeTemperaturesRecognized([])
			case "BrakeWear":
				this.brakeWearRecognized([])
		}
	}

	planPitstop(optionsOrLap := "__Undefined__", refuelAmount := "__Undefined__"
			  , changeTyres := "__Undefined__", tyreSet := "__Undefined__"
			  , tyreCompound := "__Undefined__", tyreCompoundColor := "__Undefined__", tyrePressures := "__Undefined__"
			  , repairBodywork := "__Undefined__", repairSuspension := "__Undefined__", repairEngine := "__Undefined__"
			  , requestDriver := "__Undefined__") {
		local knowledgeBase := this.KnowledgeBase
		local confirm := true
		local options := ((optionsOrLap = kUndefined) ? true : optionsOrLap)
		local plannedLap := false
		local result, pitstopNumber, speaker, fragments, fuel, lap, correctedFuel, targetFuel
		local correctedTyres, compound, color, incrementFL, incrementFR, incrementRL, incrementRR, pressureCorrection
		local temperatureDelta, debug, tyre, tyreType, lostPressure, deviationThreshold

		if (optionsOrLap != kUndefined) {
			if optionsOrLap is Number
			{
				plannedLap := Max(optionsOrLap, knowledgeBase.getValue("Lap") + 1)

				options := true
			}
			else if (IsObject(optionsOrLap) && optionsOrLap.HasKey("Confirm"))
				confirm := optionsOrLap["Confirm"]
		}

		if !plannedLap
			if !this.hasEnoughData()
				return false

		if !this.supportsPitstop() {
			if this.Speaker
				this.getSpeaker().speakPhrase("NoPitstop")

			return false
		}

		knowledgeBase.addFact("Pitstop.Plan", ((options == true) || !options.HasKey("Update") || !options.Update) ? true : false)

		correctedFuel := false

		if (refuelAmount != kUndefined) {
			if (InStr(refuelAmount . "", "!") = 1)
				knowledgeBase.addFact("Pitstop.Plan.Fuel.Amount", SubStr(refuelAmount, 2) + 0)
			else {
				targetFuel := knowledgeBase.getValue("Fuel.Amount.Target", false)

				if (targetFuel && (targetFuel != refuelAmount)) {
					if ((knowledgeBase.getValue("Lap." . knowledgeBase.getValue("Lap") . ".Fuel.Remaining") + targetFuel)
					  < knowledgeBase.getValue("Session.Settings.Fuel.Max"))
						correctedFuel := true
					else
						knowledgeBase.addFact("Pitstop.Plan.Fuel.Amount", refuelAmount)
				}
				else
					knowledgeBase.addFact("Pitstop.Plan.Fuel.Amount", refuelAmount)
			}
		}

		correctedTyres := false

		if (changeTyres != kUndefined) {
			if (InStr(changeTyres . "", "!") = 1) {
				changeTyres := (SubStr(changeTyres, 2) + 0)

				knowledgeBase.addFact("Pitstop.Plan.Tyre.Change", changeTyres)
			}
			else {
				if (changeTyres != (knowledgeBase.getValue("Tyre.Compound.Target", false) != false)) {
					changeTyres := !changeTyres

					correctedTyres := true
				}
			}

			if changeTyres {
				if (tyreSet != kUndefined)
					knowledgeBase.addFact("Pitstop.Plan.Tyre.Set", tyreSet)

				if (tyreCompound != kUndefined)
					knowledgeBase.addFact("Pitstop.Plan.Tyre.Compound", tyreCompound)

				if (tyreCompoundColor != kUndefined)
					knowledgeBase.addFact("Pitstop.Plan.Tyre.Compound.Color", tyreCompoundColor)

				if (tyrePressures != kUndefined) {
					tyrePressures := string2Values(",", tyrePressures)

					knowledgeBase.addFact("Pitstop.Plan.Tyre.Pressure.FL", tyrePressures[1])
					knowledgeBase.addFact("Pitstop.Plan.Tyre.Pressure.FR", tyrePressures[2])
					knowledgeBase.addFact("Pitstop.Plan.Tyre.Pressure.RL", tyrePressures[3])
					knowledgeBase.addFact("Pitstop.Plan.Tyre.Pressure.RR", tyrePressures[4])
				}
			}
		}

		if (repairBodywork != kUndefined)
			knowledgeBase.addFact("Pitstop.Plan.Repair.Bodywork", repairBodywork)

		if (repairSuspension != kUndefined)
			knowledgeBase.addFact("Pitstop.Plan.Repair.Suspension", repairSuspension)

		if (repairEngine != kUndefined)
			knowledgeBase.addFact("Pitstop.Plan.Repair.Engine", repairEngine)

		if (requestDriver != kUndefined)
			knowledgeBase.addFact("Pitstop.Plan.Driver.Request", requestDriver)

		result := knowledgeBase.produce()

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledgeBase(knowledgeBase)

		pitstopNumber := knowledgeBase.getValue("Pitstop.Planned.Nr")

		knowledgeBase.setFact("Pitstop.Planned.Lap", plannedLap ? (plannedLap - 1) : false)

		if this.Speaker {
			speaker := this.getSpeaker()
			fragments := speaker.Fragments

			speaker.beginTalk()

			try {
				if ((options == true) || options.Intro)
					speaker.speakPhrase("Pitstop", {number: pitstopNumber})

				if ((options == true) || options.Fuel) {
					fuel := Round(knowledgeBase.getValue("Pitstop.Planned.Fuel", 0))

					if (fuel == 0)
						speaker.speakPhrase("NoRefuel")
					else
						speaker.speakPhrase("Refuel", {litres: fuel})

					if correctedFuel
						speaker.speakPhrase("RefuelAdjusted")
				}

				compound := knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound", false)

				if ((options == true) || options.Compound) {
					if compound {
						color := knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound.Color")
						tyreSet := knowledgeBase.getValue("Pitstop.Planned.Tyre.Set", 0)

						if (compound = "Dry")
							speaker.speakPhrase(!tyreSet ? "DryTyresNoSet" : "DryTyres", {compound: fragments[compound . "Tyre"], color: color, set: tyreSet})
						else
							speaker.speakPhrase(!tyreSet ? "WetTyresNoSet" : "WetTyres", {compound: fragments[compound . "Tyre"], color: color, set: tyreSet})
					}
					else {
						if (knowledgeBase.getValue("Lap.Remaining.Stint") > 5)
							speaker.speakPhrase("NoTyreChange")
						else
							speaker.speakPhrase("NoTyreChangeLap")
					}
				}

				debug := this.VoiceManager.Debug[kDebugPhrases]

				if (compound && ((options == true) || options.Pressures)) {
					incrementFL := Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FL.Increment", 0), 1)
					incrementFR := Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FR.Increment", 0), 1)
					incrementRL := Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RL.Increment", 0), 1)
					incrementRR := Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RR.Increment", 0), 1)

					if (debug || (incrementFL != 0) || (incrementFR != 0) || (incrementRL != 0) || (incrementRR != 0) || (tyrePressures != kUndefined))
						speaker.speakPhrase("NewPressures")

					if (debug || (incrementFL != 0) || (tyrePressures != kUndefined))
						speaker.speakPhrase("TyreFL", {value: printNumber(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FL"), 1)
													 , unit: fragments["PSI"]})

					if (debug || (incrementFR != 0) || (tyrePressures != kUndefined))
						speaker.speakPhrase("TyreFR", {value: printNumber(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FR"), 1)
													 , unit: fragments["PSI"]})

					if (debug || (incrementRL != 0) || (tyrePressures != kUndefined))
						speaker.speakPhrase("TyreRL", {value: printNumber(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RL"), 1)
													 , unit: fragments["PSI"]})

					if (debug || (incrementRR != 0) || (tyrePressures != kUndefined))
						speaker.speakPhrase("TyreRR", {value: printNumber(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RR"), 1)
													 , unit: fragments["PSI"]})

					pressureCorrection := Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.Correction", 0), 1)

					if (Abs(pressureCorrection) > 0.05) {
						temperatureDelta := knowledgeBase.getValue("Weather.Temperature.Air.Delta", 0)

						if (temperatureDelta = 0)
							temperatureDelta := ((pressureCorrection > 0) ? -1 : 1)

						speaker.speakPhrase((pressureCorrection > 0) ? "PressureCorrectionUp" : "PressureCorrectionDown"
										  , {value: printNumber(Abs(pressureCorrection), 1), unit: fragments["PSI"]
										   , pressureDirection: (pressureCorrection > 0) ? fragments["Increase"] : fragments["Decrease"]
										   , temperatureDirection: (temperatureDelta > 0) ? fragments["Rising"] : fragments["Falling"]})
					}

					deviationThreshold := knowledgeBase.getValue("Session.Settings.Tyre.Pressure.Deviation")

					for tyre, tyreType in {FrontLeft: "FL", FrontRight: "FR", RearLeft: "RL", RearRight: "RR"} {
						lostPressure := knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.Lost." . tyreType, false)

						if (lostPressure && (lostPressure >= deviationThreshold))
							speaker.speakPhrase("PressureAdjustment", {tyre: fragments[tyre], lost: Round(lostPressure, 1), unit: fragments["PSI"]})
					}
				}

				if ((options == true) || options.Repairs
				 || (repairBodywork != kUndefined) || (repairSuspension != kUndefined) || (repairEngine != kUndefined)) {
					if knowledgeBase.getValue("Pitstop.Planned.Repair.Suspension", false)
						speaker.speakPhrase("RepairSuspension")
					else if debug
						speaker.speakPhrase("NoRepairSuspension")

					if knowledgeBase.getValue("Pitstop.Planned.Repair.Bodywork", false)
						speaker.speakPhrase("RepairBodywork")
					else if debug
						speaker.speakPhrase("NoRepairBodywork")

					if knowledgeBase.getValue("Pitstop.Planned.Repair.Engine", false)
						speaker.speakPhrase("RepairEngine")
					else if debug
						speaker.speakPhrase("NoRepairEngine")
				}

				if confirm
					if plannedLap
						speaker.speakPhrase("PitstopLap", {lap: plannedLap})
					else {
						speaker.speakPhrase("ConfirmPrepare", false, true)

						this.setContinuation(new VoiceManager.ReplyContinuation(this, ObjBindMethod(this, "preparePitstop"), false, "Okay"))
					}
			}
			finally {
				speaker.endTalk()
			}
		}

		if (result && this.RemoteHandler)
			this.RemoteHandler.pitstopPlanned(pitstopNumber, plannedLap)

		return result
	}

	preparePitstop(lap := false) {
		local speaker, result

		if !this.supportsPitstop() {
			if this.Speaker
				this.getSpeaker().speakPhrase("NoPitstop")

			return false
		}

		if !this.hasPlannedPitstop() {
			if this.Speaker {
				speaker := this.getSpeaker()

				speaker.speakPhrase("MissingPlan")

				if this.supportsPitstop() {
					speaker.speakPhrase("ConfirmPlan", false, true)

					this.setContinuation(ObjBindMethod(this, "planPitstop"))
				}
			}

			return false
		}
		else {
			if this.Speaker {
				speaker := this.getSpeaker()

				if lap
					speaker.speakPhrase("PrepareLap", {lap: lap})
				else
					speaker.speakPhrase("PrepareNow")
			}

			if !lap
				this.KnowledgeBase.addFact("Pitstop.Prepare", true)
			else
				this.KnowledgeBase.setFact("Pitstop.Planned.Lap", lap - 1)

			result := this.KnowledgeBase.produce()

			if this.Debug[kDebugKnowledgeBase]
				this.dumpKnowledgeBase(this.KnowledgeBase)

			return result
		}
	}

	pitstopOptionChanged(option, values*) {
		local knowledgeBase := this.KnowledgeBase
		local prssKey, incrKey, targetPressure, index, suffix

		if this.hasPreparedPitstop() {
			switch option {
				case "Refuel":
					knowledgeBase.setFact("Pitstop.Planned.Fuel", values[1])
				case "Tyre Compound":
					knowledgeBase.setFact("Pitstop.Planned.Tyre.Compound", values[1])
					knowledgeBase.setFact("Pitstop.Planned.Tyre.Compound.Color", values[2])
				case "Tyre Set":
					knowledgeBase.setFact("Pitstop.Planned.Tyre.Set", values[1])
				case "Tyre Pressures":
					for index, suffix in ["FL", "FR", "RL", "RR"] {
						prssKey := ("Pitstop.Planned.Tyre.Pressure." . suffix)
						incrKey := ("Pitstop.Planned.Tyre.Pressure." . suffix . ".Increment")

						targetPressure := values[index]

						knowledgeBase.setFact(prssKey, targetPressure)
						knowledgeBase.setFact(incrKey, knowledgeBase.getValue(incrKey) + (targetPressure - knowledgeBase.getValue(prssKey)))
					}
				case "Repair Suspension":
					knowledgeBase.setFact("Pitstop.Planned.Repair.Suspension", values[1])
				case "Repair Bodywork":
					knowledgeBase.setFact("Pitstop.Planned.Repair.Bodywork", values[1])
				case "Repair Engine":
					knowledgeBase.setFact("Pitstop.Planned.Repair.Engine", values[1])
			}

			if this.Speaker[false]
				this.getSpeaker().speakPhrase("ConfirmPlanUpdate")
		}
	}

	executePitstop(lapNumber) {
		local knowledgeBase := this.KnowledgeBase
		local lastLap, flWear, frWear, rlWear, rrWear, driver, tyreCompound, tyreCompoundColor, tyreSet, result
		local lastPitstop, pitstop

		if this.Speaker[false]
			this.getSpeaker().speakPhrase("Perform")

		lastPitstop := knowledgeBase.getValue("Pitstop.Last", 0)

		if this.RemoteHandler {
			lastLap := (lapNumber - 1)

			flWear := knowledgeBase.getValue("Lap." . lastLap . ".Tyre.Wear.FL", kUndefined)

			if (flWear != kUndefined) {
				frWear := knowledgeBase.getValue("Lap." . lastLap . ".Tyre.Wear.FR")
				rlWear := knowledgeBase.getValue("Lap." . lastLap . ".Tyre.Wear.RL")
				rrWear := knowledgeBase.getValue("Lap." . lastLap . ".Tyre.Wear.RR")

				driver := computeDriverName(knowledgeBase.getValue("Lap." . lastLap . ".Driver.Forname")
										  , knowledgeBase.getValue("Lap." . lastLap . ".Driver.Surname")
										  , knowledgeBase.getValue("Lap." . lastLap . ".Driver.Nickname"))

				tyreCompound := knowledgeBase.getValue("Lap." . lastLap . ".Tyre.Compound")
				tyreCompoundColor := knowledgeBase.getValue("Lap." . lastLap . ".Tyre.Compound.Color")
				tyreSet := knowledgeBase.getValue("Lap." . lastLap . ".Tyre.Set", false)
			}
		}

		result := base.executePitstop(lapNumber)

		pitstop := knowledgeBase.getValue("Pitstop.Last", 0)

		if (this.RemoteHandler && (flWear != kUndefined) && (pitstop != lastPitstop))
			this.RemoteHandler.updateTyreSet(pitstop, driver, false
										   , tyreCompound, tyreCompoundColor, tyreSet
										   , flWear, frWear, rlWear, rrWear)

		return result
	}

	finishPitstop(lapNumber) {
		local result := base.finishPitstop(lapNumber)

		if this.RemoteHandler
			this.RemoteHandler.pitstopFinished(this.KnowledgeBase.getValue("Pitstop.Last", 0))

		return result
	}

	callPlanPitstop(lap := "__Undefined__", arguments*) {
		this.clearContinuation()

		if !this.supportsPitstop()
			this.getSpeaker().speakPhrase("NoPitstop")
		else if ((lap = kUndefined) && this.hasPlannedPitstop()) {
			this.getSpeaker().speakPhrase("ConfirmRePlan")

			this.setContinuation(ObjBindMethod(this, "invokePlanPitstop", false, lap, arguments*))
		}
		else
			this.invokePlanPitstop(true, lap, arguments*)
	}

	invokePlanPitstop(confirm, lap := "__Undefined__", arguments*) {
		this.clearContinuation()

		if (lap == kUndefined) {
			if confirm {
				this.getSpeaker().speakPhrase("Confirm")

				Task.yield()

				loop 10
					Sleep 500
			}

			this.planPitstop()
		}
		else
			this.planPitstop(lap, arguments*)
	}

	callPreparePitstop(lap := false) {
		this.clearContinuation()

		if !this.supportsPitstop()
			this.getSpeaker().speakPhrase("NoPitstop")
		else {
			this.getSpeaker().speakPhrase("Confirm")

			Task.yield()

			loop 10
				Sleep 500

			if lap
				this.preparePitstop(lap)
			else
				this.preparePitstop()
		}
	}

	requestPitstopHistory(callbackCategory, callbackMessage, callbackPID) {
		local knowledgeBase := this.KnowledgeBase
		local pitstopHistory := newConfiguration()
		local numPitstops := 0
		local numTyreSets := 1
		local lastLap := 0
		local fileName, pitstopLap, tyreCompound, tyreCompoundColor, tyreSet

		setConfigurationValue(pitstopHistory, "TyreSets", "1.Compound"
											, knowledgeBase.getValue("Session.Setup.Tyre.Compound"))
		setConfigurationValue(pitstopHistory, "TyreSets", "1.CompoundColor"
											, knowledgeBase.getValue("Session.Setup.Tyre.Compound.Color"))
		setConfigurationValue(pitstopHistory, "TyreSets", "1.Set"
											, knowledgeBase.getValue("Session.Setup.Tyre.Set"))

		loop % knowledgeBase.getValue("Pitstop.Last")
		{
			numPitstops += 1

			pitstopLap := knowledgeBase.getValue("Pitstop." . A_Index . ".Lap")

			setConfigurationValue(pitstopHistory, "Pitstops", A_Index . ".Lap", pitstopLap)
			setConfigurationValue(pitstopHistory, "Pitstops", A_Index . ".Refuel"
												, knowledgeBase.getValue("Pitstop." . A_Index . ".Fuel"))

			tyreCompound := knowledgeBase.getValue("Pitstop." . A_Index . ".Tyre.Compound")
			tyreCompoundColor := knowledgeBase.getValue("Pitstop." . A_Index . ".Tyre.Compound.Color")
			tyreSet := knowledgeBase.getValue("Pitstop." . A_Index . ".Tyre.Set")

			if tyreCompound {
				setConfigurationValue(pitstopHistory, "TyreSets", numTyreSets . ".Laps", pitstopLap - lastLap)

				numTyreSets += 1
				lastLap := pitstopLap

				setConfigurationValue(pitstopHistory, "TyreSets", numTyreSets . ".Compound", tyreCompound)
				setConfigurationValue(pitstopHistory, "TyreSets", numTyreSets . ".CompoundColor", tyreCompoundColor)
				setConfigurationValue(pitstopHistory, "TyreSets", numTyreSets . ".Set", tyreSet)

				setConfigurationValue(pitstopHistory, "Pitstops", A_Index . ".TyreCompound", tyreCompound)
				setConfigurationValue(pitstopHistory, "Pitstops", A_Index . ".TyreCompoundColor", tyreCompoundColor)
				setConfigurationValue(pitstopHistory, "Pitstops", A_Index . ".TyreSet", tyreSet)
				setConfigurationValue(pitstopHistory, "Pitstops", A_Index . ".TyreChange", true)
			}
			else
				setConfigurationValue(pitstopHistory, "Pitstops", A_Index . ".TyreChange", false)

			setConfigurationValue(pitstopHistory, "Pitstops", A_Index . ".RepairBodywork"
												, knowledgeBase.getValue("Pitstop." . A_Index . ".Repair.Bodywork"))
			setConfigurationValue(pitstopHistory, "Pitstops", A_Index . ".RepairSuspension"
												, knowledgeBase.getValue("Pitstop." . A_Index . ".Repair.Suspension"))
			setConfigurationValue(pitstopHistory, "Pitstops", A_Index . ".RepairEngine"
												, knowledgeBase.getValue("Pitstop." . A_Index . ".Repair.Engine", false))
		}

		setConfigurationValue(pitstopHistory, "TyreSets", numTyreSets . ".Laps", knowledgeBase.getValue("Lap") - lastLap)

		setConfigurationValue(pitstopHistory, "Pitstops", "Count", numPitstops)
		setConfigurationValue(pitstopHistory, "TyreSets", "Count", numTyreSets)

		fileName := temporaryFileName("Pitstop", "history")

		writeConfiguration(filename, pitstopHistory)

		sendMessage(kFileMessage, callbackCategory, callbackMessage . ":" . fileName, callbackPID)
	}

	lowFuelWarning(remainingLaps) {
		local speaker

		if (this.Speaker[false] && this.Announcements["FuelWarning"]) {
			speaker := this.getSpeaker()

			speaker.beginTalk()

			try {
				speaker.speakPhrase((remainingLaps <= 2) ? "VeryLowFuel" : "LowFuel", {laps: remainingLaps})

				if this.supportsPitstop() {
					if this.hasPreparedPitstop()
						speaker.speakPhrase((remainingLaps <= 2) ? "LowComeIn" : "ComeIn")
					else if !this.hasPlannedPitstop() {
						speaker.speakPhrase("ConfirmPlan", false, true)

						this.setContinuation(ObjBindMethod(this, "planPitstop"))
					}
					else {
						speaker.speakPhrase("ConfirmPrepare", false, true)

						this.setContinuation(new VoiceManager.ReplyContinuation(this, ObjBindMethod(this, "preparePitstop"), false, "Okay"))
					}
				}
			}
			finally {
				speaker.endTalk()
			}
		}
	}

	damageWarning(newSuspensionDamage, newBodyworkDamage, newEngineDamage) {
		local knowledgeBase := this.KnowledgeBase
		local speaker, phrase

		if (this.Speaker[false] && this.Announcements["DamageReporting"]) {
			speaker := this.getSpeaker()
			phrase := false

			if newEngineDamage {
				if (newSuspensionDamage || newBodyworkDamage)
					phrase := "AllDamage"
				else
					phrase := "EngineDamage"
			}
			else if (newSuspensionDamage && newBodyworkDamage)
				phrase := "BothDamage"
			else if newSuspensionDamage
				phrase := "SuspensionDamage"
			else if newBodyworkDamage
				phrase := "BodyworkDamage"

			speaker.beginTalk()

			try {
				speaker.speakPhrase(phrase)

				if (knowledgeBase.getValue("Lap.Remaining") > 4)
					speaker.speakPhrase("DamageAnalysis")
				else
					speaker.speakPhrase("NoDamageAnalysis")
			}
			finally {
				speaker.endTalk()
			}
		}
	}

	reportDamageAnalysis(repair, stintLaps, delta) {
		local knowledgeBase := this.KnowledgeBase
		local speaker

		if (knowledgeBase.getValue("Lap.Remaining") > 3)
			if (this.Speaker[false] && this.Announcements["DamageAnalysis"]) {
				speaker := this.getSpeaker()

				stintLaps := Round(stintLaps)

				if repair {
					speaker.beginTalk()

					try {
						speaker.speakPhrase("RepairPitstop", {laps: stintLaps, delta: printNumber(delta, 1)})

						if this.supportsPitstop() {
							speaker.speakPhrase("ConfirmPlan", false, true)

							this.setContinuation(ObjBindMethod(this, "planPitstop"))
						}
					}
					finally {
						speaker.endTalk()
					}
				}
				else if (repair == false)
					speaker.speakPhrase((Abs(delta) < 0.2) ? "NoTimeLost" : "NoRepairPitstop", {laps: stintLaps, delta: printNumber(delta, 1)})
			}
	}

	pressureLossWarning(tyre, lostPressure) {
		local knowledgeBase := this.KnowledgeBase
		local speaker, fragments

		if (this.Session == kSessionRace)
			if (this.Speaker[false] && this.Announcements["PressureReporting"]) {
				speaker := this.getSpeaker()
				fragments := speaker.Fragments

				speaker.speakPhrase("PressureLoss", {tyre: fragments[{FL: "FrontLeft", FR: "FrontRight", RL: "RearLeft", RR: "RearRight"}[tyre]]
												   , lost: Round(lostPressure, 1), unit: fragments["PSI"]})
			}
	}

	weatherChangeNotification(change, minutes) {
		local knowledgeBase := this.KnowledgeBase
		local speaker

		Process Exist, Race Strategist.exe

		if !ErrorLevel
			if (this.Speaker[false] && (this.Session == kSessionRace) && this.Announcements["WeatherUpdate"]) {
				speaker := this.getSpeaker()

				speaker.speakPhrase(change ? "WeatherChange" : "WeatherNoChange", {minutes: minutes})
			}
	}

	weatherTyreChangeRecommendation(minutes, recommendedCompound) {
		local knowledgeBase := this.KnowledgeBase
		local speaker, fragments

		Process Exist, Race Strategist.exe

		if (!ErrorLevel && (knowledgeBase.getValue("Lap.Remaining") > 3))
			if (this.Speaker[false] && (this.Session == kSessionRace)) {
				speaker := this.getSpeaker()
				fragments := speaker.Fragments

				speaker.beginTalk()

				try {
					speaker.speakPhrase(((recommendedCompound = "Wet") || (recommendedCompound = "Intermediate")) ? "WeatherRainChange"
																												  : "WeatherDryChange"
									  , {minutes: minutes, compound: fragments[recommendedCompound . "Tyre"]})

					if this.supportsPitstop() {
						speaker.speakPhrase("ConfirmPlan", false, true)

						this.setContinuation(ObjBindMethod(this, "planPitstop"))
					}
				}
				finally {
					speaker.endTalk()
				}
			}
	}

	startPitstopSetup(pitstopNumber) {
		if this.RemoteHandler
			this.RemoteHandler.startPitstopSetup(pitstopNumber)
	}

	finishPitstopSetup(pitstopNumber) {
		if this.RemoteHandler {
			this.RemoteHandler.finishPitstopSetup(pitstopNumber)

			this.RemoteHandler.pitstopPrepared(pitstopNumber)

			if this.Speaker
				this.getSpeaker().speakPhrase("CallToPit")
		}
	}

	setPitstopRefuelAmount(pitstopNumber, litres) {
		if this.RemoteHandler
			this.RemoteHandler.setPitstopRefuelAmount(pitstopNumber, litres)
	}

	setPitstopTyreSet(pitstopNumber, compound, compoundColor, set) {
		if this.RemoteHandler
			this.RemoteHandler.setPitstopTyreSet(pitstopNumber, compound, compoundColor, set)
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		if this.RemoteHandler
			this.RemoteHandler.setPitstopTyrePressures(pitstopNumber, Round(pressureFL, 1), Round(pressureFR, 1), Round(pressureRL, 1), Round(pressureRR, 1))
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine) {
		if this.RemoteHandler
			this.RemoteHandler.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine)
	}

	requestPitstopDriver(pitstopNumber, driver) {
		if (this.RemoteHandler && driver)
			this.RemoteHandler.requestPitstopDriver(pitstopNumber, driver)
	}

	getTyrePressures(weather, airTemperature, trackTemperature, ByRef compound, ByRef compoundColor, ByRef pressures, ByRef certainty) {
		local knowledgeBase := this.KnowledgeBase

		return this.TyresDatabase.getTyreSetup(knowledgeBase.getValue("Session.Simulator")
											 , knowledgeBase.getValue("Session.Car"), knowledgeBase.getValue("Session.Track")
											 , weather, airTemperature, trackTemperature, compound, compoundColor, pressures, certainty, true)
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

lowFuelWarning(context, remainingLaps) {
	context.KnowledgeBase.RaceAssistant.lowFuelWarning(Round(remainingLaps))

	return true
}

damageWarning(context, newSuspensionDamage, newBodyworkDamage, newEngineDamage) {
	context.KnowledgeBase.RaceAssistant.damageWarning(newSuspensionDamage, newBodyworkDamage, newEngineDamage)

	return true
}

reportDamageAnalysis(context, repair, stintLaps, delta) {
	context.KnowledgeBase.RaceAssistant.reportDamageAnalysis(repair, stintLaps, delta)

	return true
}

pressureLossWarning(context, tyre, lostPressure) {
	context.KnowledgeBase.RaceAssistant.pressureLossWarning(tyre, lostPressure)

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

startPitstopSetup(context, pitstopNumber) {
	context.KnowledgeBase.RaceAssistant.startPitstopSetup(pitstopNumber)

	return true
}

finishPitstopSetup(context, pitstopNumber) {
	context.KnowledgeBase.RaceAssistant.finishPitstopSetup(pitstopNumber)

	return true
}

setPitstopRefuelAmount(context, pitstopNumber, litres) {
	context.KnowledgeBase.RaceAssistant.setPitstopRefuelAmount(pitstopNumber, litres)

	return true
}

setPitstopTyreSet(context, pitstopNumber, compound, compoundColor, set) {
	context.KnowledgeBase.RaceAssistant.setPitstopTyreSet(pitstopNumber, compound, compoundColor, set)

	return true
}

setPitstopTyrePressures(context, pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
	context.KnowledgeBase.RaceAssistant.setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)

	return true
}

requestPitstopRepairs(context, pitstopNumber, repairSuspension, repairBodywork, repairEngine) {
	context.KnowledgeBase.RaceAssistant.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine)

	return true
}

requestPitstopDriver(context, pitstopNumber, driver) {
	context.KnowledgeBase.RaceAssistant.requestPitstopDriver(pitstopNumber, driver)

	return true
}

setupTyrePressures(context, weather, airTemperature, trackTemperature, compound, compoundColor) {
	local knowledgeBase := context.KnowledgeBase
	local pressures := false
	local certainty := 1.0

	if !inList(kTyreCompounds, compound(compound, compoundColor)) {
		compound := false
		compoundColor := false
	}

	airTemperature := Round(airTemperature)
	trackTemperature := Round(trackTemperature)

	if context.KnowledgeBase.RaceAssistant.getTyrePressures(weather, airTemperature, trackTemperature, compound, compoundColor, pressures, certainty) {
		knowledgeBase.setFact("Tyre.Setup.Certainty", certainty)
		knowledgeBase.setFact("Tyre.Setup.Compound", compound)
		knowledgeBase.setFact("Tyre.Setup.Compound.Color", compoundColor)
		knowledgeBase.setFact("Tyre.Setup.Weather", weather)
		knowledgeBase.setFact("Tyre.Setup.Temperature.Air", airTemperature)
		knowledgeBase.setFact("Tyre.Setup.Temperature.Track", trackTemperature)
		knowledgeBase.setFact("Tyre.Setup.Pressure.FL", pressures[1])
		knowledgeBase.setFact("Tyre.Setup.Pressure.FR", pressures[2])
		knowledgeBase.setFact("Tyre.Setup.Pressure.RL", pressures[3])
		knowledgeBase.setFact("Tyre.Setup.Pressure.RR", pressures[4])

		return true
	}
	else
		return false
}