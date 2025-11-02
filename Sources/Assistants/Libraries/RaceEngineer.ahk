;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AI Race Engineer                ;;;
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

#Include "..\..\Framework\Extensions\JSON.ahk"
#Include "..\..\Framework\Extensions\Task.ahk"
#Include "..\..\Framework\Extensions\RuleEngine.ahk"
#Include "..\..\Framework\Extensions\LLMConnector.ahk"
#Include "..\..\Plugins\Libraries\SimulatorProvider.ahk"
#Include "..\..\Database\Libraries\SessionDatabase.ahk"
#Include "RaceAssistant.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class EngineerEvent extends AssistantEvent {
	Asynchronous {
		Get {
			return true
		}
	}
}

class FuelLowEvent extends EngineerEvent {
	createTrigger(event, phrase, arguments) {
		return ("Fuel is running low. " . Round(arguments[1], 1) . " Liters remaining which are good for " . Floor(arguments[2]) . " more laps.")
	}

	handleEvent(event, arguments*) {
		if !super.handleEvent(event, arguments*)
			this.Assistant.lowFuelWarning(Round(arguments[1], 1), Floor(arguments[2]))

		return true
	}
}

class EnergyLowEvent extends EngineerEvent {
	createTrigger(event, phrase, arguments) {
		return ("Running out of virtual energy. " . Round(arguments[1], 1) . " percent remaining which are good for " . Floor(arguments[2]) . " more laps.")
	}

	handleEvent(event, arguments*) {
		if !super.handleEvent(event, arguments*)
			this.Assistant.lowEnergyWarning(Round(arguments[1], 1), Floor(arguments[2]))

		return true
	}
}

class TyreWearEvent extends EngineerEvent {
	createTrigger(event, phrase, arguments) {
		static wheels := false

		if !wheels {
			wheels := CaseInsenseMap("FL", "front left", "FR", "front right"
								   , "RL", "rear left", "RR", "rear right")

			wheels.Default := "worst"
		}

		return ("Tyres are worn out. Only " . (100 - Round(arguments[2])) . " percentage of tread left on the " . wheels[arguments[1]] . " tyre.")
	}

	handleEvent(event, arguments*) {
		if !super.handleEvent(event, arguments*)
			this.Assistant.tyreWearWarning(arguments[1], Round(arguments[2]))

		return true
	}
}

class BrakeWearEvent extends EngineerEvent {
	createTrigger(event, phrase, arguments) {
		static wheels := false

		if !wheels {
			wheels := CaseInsenseMap("FL", "front left", "FR", "front right"
								   , "RL", "rear left", "RR", "rear right")

			wheels.Default := "worst"
		}

		return ("Brake pads are worn out. Only " . (100 - Round(arguments[2])) . " percentage left on the " . wheels[arguments[1]] . " pad.")
	}

	handleEvent(event, arguments*) {
		if !super.handleEvent(event, arguments*)
			this.Assistant.brakeWearWarning(arguments[1], Round(arguments[2]))

		return true
	}
}

class DamageEvent extends EngineerEvent {
	createArguments(event, arguments) {
		local result := []

		loop arguments.Length
			result.Push(arguments.Has(A_Index) ? arguments[A_Index] : false)

		return result
	}

	createTrigger(event, phrase, arguments) {
		local damage := []
		local index, type

		for index, type in ["Suspension", "Bodywork", "Engine"]
			if arguments[index]
				damage.Push(type)

		return ("Damage has just been collected for " . values2String(", ", damage*) . ".")
	}

	handleEvent(event, arguments*) {
		if !super.handleEvent(event, arguments*)
			this.Assistant.damageWarning(arguments*)

		return true
	}
}

class TimeLossEvent extends EngineerEvent {
	createArguments(event, arguments) {
		local result := []

		loop arguments.Length
			result.Push(arguments.Has(A_Index) ? arguments[A_Index] : 0)

		return result
	}

	createTrigger(event, phrase, arguments) {
		return ("The car is loosing " . arguments[2] . " seconds for the remaining " . arguments[1] . " laps due to damage.")
	}

	handleEvent(event, arguments*) {
		if !super.handleEvent(event, arguments*)
			this.Assistant.reportDamageAnalysis(true, arguments*)

		return true
	}
}

class NoTimeLossEvent extends EngineerEvent {
	createArguments(event, arguments) {
		local result := []

		loop arguments.Length
			result.Push(arguments.Has(A_Index) ? arguments[A_Index] : 0)

		return result
	}

	createTrigger(event, phrase, arguments) {
		return ("The driver has recovered his pace and repairs are no longer needed.")
	}

	handleEvent(event, stintLaps, delta, *) {
		if !super.handleEvent(event, stintLaps, delta)
			this.Assistant.reportDamageAnalysis(false, stintLaps, delta, true)

		return true
	}
}

class PressureLossEvent extends EngineerEvent {
	createTrigger(event, phrase, arguments) {
		static tyres := CaseInsenseMap("FL", "front left", "FR", "front right", "RL", "rear left", "RR", "rear right")

		return ("The " . tyres[arguments[1]] . " (" . arguments[1] . ") tyre has lost pressure by " . Round(arguments[2], 1) . " PSI.")
	}

	handleEvent(event, arguments*) {
		if !super.handleEvent(event, arguments*)
			this.Assistant.pressureLossWarning(arguments[1], Round(arguments[2], 1))

		return true
	}
}

class WeatherForecastEvent extends EngineerEvent {
	createTrigger(event, phrase, arguments) {
		local trigger := ("The weather will change to " . arguments[1] . " in " . arguments[2] . ".")

		if (arguments.Has(4) && arguments[3])
			return (trigger . A_Space . " A pitstop must be planned and " . arguments[4] . " tyres must be mounted.")
		else
			return (trigger . " A tyre change will not be necessary.")
	}

	handleEvent(event, arguments*) {
		if !ProcessExist("Race Strategist.exe") {
			if !super.handleEvent(event, arguments*)
				if (arguments.Has(4) && arguments[3])
					this.Assistant.requestTyreChange(arguments[1], arguments[2], arguments[4])
				else
					this.Assistant.weatherForecast(arguments[1], arguments[2], arguments[3])

			return true
		}
		else
			return false
	}
}

class PlanPitstopEvent extends EngineerEvent {
	Asynchronous {
		Get {
			return false
		}
	}

	handledEvent(event) {
		return (super.handledEvent(event) && this.Assistant.hasEnoughData(false))
	}

	createTrigger(event, phrase, arguments) {
		local knowledgeBase := this.Assistant.KnowledgeBase
		local targetLap, refuelAmount, tyreChange, repairs
		local targetLapRule, refuelRule, tyreRule, repairRule, mixedCompounds

		static instructions := false

		if !instructions {
			instructions := readMultiMap(kResourcesDirectory . "Translations\Race Engineer.instructions.en")

			addMultiMapValues(instructions, readMultiMap(kUserHomeDirectory . "Translations\Race Engineer.instructions.en"))
		}

		targetLap := (arguments.Has(1) ? arguments[1] : kUndefined)
		refuelAmount := (arguments.Has(2) ? arguments[2] : kUndefined)
		tyreChange := (arguments.Has(3) ? arguments[3] : kUndefined)
		repairs := (arguments.Has(4) ? arguments[4] : kUndefined)

		if (targetLap = "Now")
			targetLap := (this.Assistant.KnowledgeBase.getValue("Lap", 0) + 1)

		this.Assistant.Provider.supportsTyreManagement(&mixedCompounds)

		if (targetLap != kUndefined)
			targetLapRule := substituteVariables(getMultiMapValue(instructions, "Rules", "TargetLapRuleFixed")
											   , {targetLap: targetLap})
		else
			targetLapRule := getMultiMapValue(instructions, "Rules", "TargetLapRuleVariable")

		if (refuelAmount != kUndefined)
			refuelRule := substituteVariables(getMultiMapValue(instructions, "Rules", "RefuelRuleRequired"), {liter: refuelAmount})
		else
			refuelRule := getMultiMapValue(instructions, "Rules", "RefuelRuleTime")

		if ((tyreChange = kUndefined) || tyreChange) {
			if (knowledgeBase.getValue("Session.Settings.Tyre.Change", "Wear") = "Always")
				tyreRule := getMultiMapValue(instructions, "Rules", "TyreRuleAlways")
			else if (mixedCompounds = "Wheel")
				tyreRule := getMultiMapValue(instructions, "Rules", "TyreRuleWheel")
			else if (mixedCompounds = "Axle")
				tyreRule := getMultiMapValue(instructions, "Rules", "TyreRuleAxle")
			else
				tyreRule := getMultiMapValue(instructions, "Rules", "TyreRuleAll")

			if inList(SessionDatabase.getTyreCompounds(this.Assistant.Simulator, this.Assistant.Car, this.Assistant.Track)
					, tyreChange)
				tyreRule .= (A_Space . substituteVariables(getMultiMapValue(instructions, "Rules", "TyreRuleRestrict")
														 , {tyreCompound: tyreChange}))
		}
		else
			tyreRule := getMultiMapValue(instructions, "Rules", "TyreRuleNoChange")

		if (repairs = kUndefined)
			repairRule := getMultiMapValue(instructions, "Rules", "RepairRuleImpact")
		else if repairs
			repairRule := getMultiMapValue(instructions, "Rules", "RepairRuleRequired")
		else
			repairRule := getMultiMapValue(instructions, "Rules", "RepairRuleNoRepairs")

		return substituteVariables(getMultiMapValue(instructions, "Instructions", "PitstopPlan")
								 , {targetLapRule: targetLapRule, refuelRule: refuelRule, tyreRule: tyreRule, repairRule: repairRule
								  , maxTyreWear: (100 - knowledgeBase.getValue("Session.Settings.Tyre.Wear.Warning", 25))
								  , lastService: knowledgeBase.getValue("Session.Settings.Pitstop.Service.Last", 5)})
	}

	handleEvent(event, arguments*) {
		local targetLap, refuelAmount, tyreChange, repairs

		if !super.handleEvent(event, arguments*) {
			targetLap := (arguments.Has(1) ? arguments[1] : kUndefined)
			refuelAmount := (arguments.Has(2) ? arguments[2] : kUndefined)
			tyreChange := (arguments.Has(3) ? arguments[3] : kUndefined)
			repairs := (arguments.Has(4) ? arguments[4] : kUndefined)

			this.Assistant.planPitstop(targetLap, refuelAmount, tyreChange, kUndefined, kUndefined, kUndefined, kUndefined
												, repairs, repairs, repairs)
		}

		return true
	}
}

class RaceEngineer extends RaceAssistant {
	iAdjustLapTime := true

	iCollectTyrePressures := true

	iSaveTyrePressures := kAsk

	iHasPressureData := false
	iSessionDataActive := false

	iRaceRules := false

	iPitstopOptionsFile := false
	iPitstopAdjustments := false
	iPitstopFillUp := false

	iCurrentTyreTemperatures := false
	iCurrentTyrePressures := false
	iCurrentBrakeTemperatures := false
	iCurrentRemainingFuel := false

	class RaceEngineerRemoteHandler extends RaceAssistant.RaceAssistantRemoteHandler {
		__New(remotePID) {
			super.__New("Race Engineer", remotePID)
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

		setPitstopTyreCompound(arguments*) {
			this.callRemote("setPitstopTyreCompound", arguments*)
		}

		setPitstopTyrePressures(arguments*) {
			this.callRemote("setPitstopTyrePressures", arguments*)
		}

		setPitstopBrakeChange(arguments*) {
			this.callRemote("setPitstopBrakeChange", arguments*)
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

		planDriverSwap(arguments*) {
			this.callRemote("planDriverSwap", arguments*)
		}

		optimizeFuelRatio(arguments*) {
			this.callRemote("optimizeFuelRatio", arguments*)
		}
	}

	Knowledge {
		Get {
			static knowledge := concatenate(super.Knowledge, ["Brakes", "Damage", "Pitstop", "Pitstops"])

			return knowledge
		}
	}

	AdjustLapTime {
		Get {
			return this.iAdjustLapTime
		}
	}

	CollectTyrePressures {
		Get {
			return this.iCollectTyrePressures
		}
	}

	SaveTyrePressures {
		Get {
			return this.iSaveTyrePressures
		}
	}

	HasPressureData {
		Get {
			return this.iHasPressureData
		}
	}

	SessionDataActive {
		Get {
			return this.iSessionDataActive
		}
	}

	CurrentTyreTemperatures {
		Get {
			return this.iCurrentTyreTemperatures
		}
	}

	CurrentTyrePressures {
		Get {
			return this.iCurrentTyrePressures
		}
	}

	CurrentBrakeTemperatures {
		Get {
			return this.iCurrentBrakeTemperatures
		}
	}

	CurrentRemainingFuel {
		Get {
			return this.iCurrentRemainingFuel
		}
	}

	__New(configuration, remoteHandler := false, name := false, language := kUndefined
		, synthesizer := false, speaker := false, vocalics := false, speakerBooster := false
		, recognizer := false, listener := false, listenerBooster := false, conversationBooster := false, agentBooster := false
		, muted := false, voiceServer := false) {
		super.__New(configuration, "Race Engineer", remoteHandler, name, language, synthesizer, speaker, vocalics, speakerBooster
												  , recognizer, listener, listenerBooster, conversationBooster, agentBooster
												  , muted, voiceServer)

		this.updateConfigurationValues({Announcements: {FuelWarning: true
													  , TyreWearWarning: true, BrakeWearWarning: true
													  , DamageReporting: true, DamageAnalysis: true
													  , PressureReporting: true, WeatherUpdate: true}})

		deleteDirectory(kTempDirectory . "Race Engineer")

		DirCreate(kTempDirectory . "Race Engineer")
	}

	updateConfigurationValues(values) {
		super.updateConfigurationValues(values)

		if values.HasProp("AdjustLapTime")
			this.iAdjustLapTime := values.AdjustLapTime

		if values.HasProp("CollectTyrePressures") {
			this.iCollectTyrePressures := values.CollectTyrePressures

			logMessage(kLogDebug, "CollectTyrePressures is now " . this.iCollectTyrePressures)
		}

		if values.HasProp("SaveTyrePressures") {
			this.iSaveTyrePressures := values.SaveTyrePressures

			logMessage(kLogDebug, "SaveTyrePressures is now " . this.iSaveTyrePressures)
		}
	}

	updateSessionValues(values) {
		super.updateSessionValues(values)

		if (values.HasProp("Session") && (values.Session == kSessionFinished)) {
			this.iRaceRules := false
			this.iPitstopAdjustments := false
			this.iPitstopFillUp := false

			this.iCurrentTyreTemperatures := false
			this.iCurrentTyrePressures := false
			this.iCurrentBrakeTemperatures := false
			this.iCurrentRemainingFuel := false
		}
	}

	updateDynamicValues(values) {
		super.updateDynamicValues(values)

		if values.HasProp("HasPressureData") {
			this.iHasPressureData := values.HasPressureData

			logMessage(kLogDebug, "HasPressureData is now " . this.iHasPressureData)
		}
	}

	confirmAction(action) {
		local confirmation := getMultiMapValue(this.Settings, "Assistant.Engineer", "Confirm." . action, "Always")

		switch confirmation, false {
			case "Always":
				confirmation := true
			case "Never":
				confirmation := false
			case "Listening":
				confirmation := (this.Listener != false)
			default:
				throw "Unsupported action confirmation detected in RaceStrategist.confirmAction..."
		}

		switch action, false {
			case "Pitstop.Prepare":
				if inList(["Yes", true], this.Autonomy)
					return false
				else if inList(["No", false], this.Autonomy)
					return true
				else
					return confirmation
			case "Pitstop.Fuel", "Pitstop.Tyre", "Pitstop.Brake", "Pitstop.Repair", "Pitstop.Weather":
				return confirmation
			default:
				return super.confirmAction(action)
		}
	}

	handleVoiceCommand(grammar, words) {
		switch grammar, false {
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
				this.tyreInfoRecognized(concatenate(Array(this.getSpeaker().Fragments["Pressures"]), words))
			case "EngineTemperatures":
				this.engineInfoRecognized(Array(this.getSpeaker().Fragments["Temperatures"]))
			case "Weather":
				this.weatherRecognized(words)
			case "FuelRatioOptimize":
				this.fuelRatioOptimizeRecognized(words)
			case "PitstopPlan":
				this.clearContinuation()

				if !this.supportsPitstop()
					this.getSpeaker().speakPhrase("NoPitstop")
				else if (this.hasPlannedPitstop() && this.Listener) {
					this.getSpeaker().speakPhrase("ConfirmRePlan", false, true)

					this.setContinuation(ObjBindMethod(this, "planPitstopRecognized", words))
				}
				else {
					if !this.confirmCommand(false)
						return

					this.planPitstopRecognized(words)
				}
			case "DriverSwapPlan":
				this.clearContinuation()

				if !this.supportsPitstop()
					this.getSpeaker().speakPhrase("NoPitstop")
				else if !this.TeamSession {
					this.getSpeaker().speakPhrase("NoDriverSwap")

					if this.supportsPitstop()
						if this.Listener {
							this.getSpeaker().speakPhrase("ConfirmPlan", {forYou: this.getSpeaker().Fragments["ForYou"]}, true)

							this.setContinuation(ObjBindMethod(this, "proposePitstop"))
						}
						else if this.supportsPitstop()
							this.proposePitstop()
				}
				else if this.hasPlannedPitstop() {
					if this.Listener {
						this.getSpeaker().speakPhrase("ConfirmRePlan", false, true)

						this.setContinuation(ObjBindMethod(this, "driverSwapRecognized", words))
					}
					else
						this.driverSwapRecognized(words)
				}
				else {
					if !this.confirmCommand(false)
						return

					this.driverSwapRecognized(words)
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
				reset := false

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
			case "PitstopCompensatePressureLoss":
				this.clearContinuation()

				if !this.supportsPitstop()
					this.getSpeaker().speakPhrase("NoPitstop")
				else
					this.pitstopCompensatePressureLossRecognized(words, true)
			case "PitstopNoCompensatePressureLoss":
				this.clearContinuation()

				if !this.supportsPitstop()
					this.getSpeaker().speakPhrase("NoPitstop")
				else
					this.pitstopCompensatePressureLossRecognized(words, false)
			default:
				super.handleVoiceCommand(grammar, words)
		}
	}

	planPitstopAction(targetLap?, refuelAmount?, tyreCompounds?, repairs?, driverSwap?) {
		local knowledgeBase := this.Knowledgebase
		local changeTyres, ignore, compound, compounds, compoundColors, availableCompounds
		local tyreCompound, tyreCompoundColor

		repairs := (isSet(repairs) ? repairs : kUndefined)

		if (knowledgeBase && isSet(tyreCompounds)) {
			availableCompounds := SessionDatabase.getTyreCompounds(this.Simulator, this.Car, this.Track)
			compounds := []
			compoundColors := []

			for ignore, compound in string2Values(",", tyreCompounds) {
				compound := Trim(compound)

				if (!compound || (compound = kFalse) || (compound = "-") || !inList(availableCompounds, compound)) {
					compounds.Push(false)
					compoundColors.Push(false)
				}
				else {
					splitCompound(compound, &tyreCompound, &tyreCompoundColor)

					compounds.Push(tyreCompound)
					compoundColors.Push(tyreCompoundColor)
				}
			}

			if exist(compounds, (c) => (c != false))
				changeTyres := true
			else {
				compounds := kUndefined
				compoundColors := kUndefined
			}
		}
		else {
			compounds := kUndefined
			compoundColors := kUndefined
		}

		if (isSet(driverSwap) && driverSwap) {
			if (compounds != kUndefined) {
				compounds := values2String(",", compounds)
				compoundColors := values2String(",", compoundColors)
			}

			this.planDriverSwap("?" . (isSet(targetLap) ? targetLap : "Now")
							  , isSet(refuelAmount) ? refuelAmount : "!0"
							  , isSet(changeTyres) ? changeTyres : "!0"
							  , repairs, repairs, repairs
							  , compounds, compoundColors)
		}
		else
			this.planPitstop(isSet(targetLap) ? targetLap : "Now"
						   , isSet(refuelAmount) ? ("!" . refuelAmount) : "!0"
						   , isSet(changeTyres) ? ("!" . changeTyres) : "!0"
						   , kUndefined, compounds, compoundColors, kUndefined
						   , repairs, repairs, repairs)
	}

	reportTimeLossAction(lapsToDrive, delta) {
		this.reportDamageAnalysis(true, lapsToDrive, delta)
	}

	reportNoTimeLossAction(lapsToDrive, delta) {
		this.reportDamageAnalysis(false, lapsToDrive, delta, true)
	}

	getData(type, topic, item) {
		local knowledgeBase := this.KnowledgeBase
		local lapNr, ignore, wheel, tyre
		local compounds, tyrePressures, tyreTemperatures, tyreWears, brakeTemperatures, brakeWears
		local fuelConsumption, remainingFuel, bodyworkDamage, suspensionDamage, engineDamage
		local mixedCompounds, tyreSet

		if (knowledgeBase && (topic = "Stint") && (item = "Car")) {
			lapNr := knowledgeBase.getValue("Lap", 0)

			this.Provider.supportsTyreManagement(&mixedCompounds, &tyreSet)

			compounds := []
			tyreTemperatures := []
			tyrePressures := []
			tyreWears := []
			brakeTemperatures := []
			brakeWears := []

			for wheel, tyre in ["FL", "FrontLeft", "FR", "FrontRight", "RL", "RearLeft", "RR", "RearRight"] {
				if (mixedCompounds = "Wheel")
					compounds.Push(compound(knowledgeBase.getValue("Lap." . lapNr . ".Tyre.Compound." . tyre, "Dry")
										  , knowledgeBase.getValue("Lap." . lapNr . ".Tyre.Compound.Color." . tyre, "Black")))
				else if (mixedCompounds = "Axle") {
					if ((wheel = "FL") || (wheel = "FR"))
						compounds.Push(compound(knowledgeBase.getValue("Lap." . lapNr . ".Tyre.Compound.Front", "Dry")
											  , knowledgeBase.getValue("Lap." . lapNr . ".Tyre.Compound.Color.Front", "Black")))
					else
						compounds.Push(compound(knowledgeBase.getValue("Lap." . lapNr . ".Tyre.Compound.Rear", "Dry")
											  , knowledgeBase.getValue("Lap." . lapNr . ".Tyre.Compound.Color.Rear", "Black")))
				}
				else
					compounds.Push(compound(knowledgeBase.getValue("Lap." . lapNr . ".Tyre.Compound", "Dry")
										  , knowledgeBase.getValue("Lap." . lapNr . ".Tyre.Compound.Color", "Black")))

				tyreTemperatures.Push(knowledgeBase.getValue("Lap." . lapNr . ".Tyre.Temperature." . wheel, kNull))
				tyrePressures.Push(knowledgeBase.getValue("Lap." . lapNr . ".Tyre.Pressure." . wheel, kNull))
				tyreWears.Push(knowledgeBase.getValue("Lap." . lapNr . ".Tyre.Wear." . wheel, kNull))
				brakeTemperatures.Push(knowledgeBase.getValue("Lap." . lapNr . ".Brake.Temperature." . wheel, kNull))
				brakeWears.Push(knowledgeBase.getValue("Lap." . lapNr . ".Brake.Wear." . wheel, kNull))
			}

			fuelConsumption := this.AvgFuelConsumption
			remainingFuel := Round(this.CurrentRemainingFuel, 1)

			bodyworkDamage := knowledgeBase.getValue("Lap." . lapNr . ".Damage.Bodywork", 0)
			suspensionDamage := knowledgeBase.getValue("Lap." . lapNr . ".Damage.Suspension", 0)
			engineDamage := knowledgeBase.getValue("Lap." . lapNr . ".Damage.Engine", 0)

			return Values(compounds, tyrePressures, tyreTemperatures, tyreWears, brakeTemperatures, brakeWears
						, fuelConsumption, remainingFuel, bodyworkDamage, suspensionDamage, engineDamage)
		}
		else
			return super.getData(type, topic, item)
	}

	getKnowledge(type, options := false) {
		local knowledgeBase := this.KnowledgeBase
		local knowledge := super.getKnowledge(type, options)
		local volumeUnit := ((type != "Agent") ? (A_Space . getUnit("Volume")) : " Liters")
		local pressureUnit := ((type != "Agent") ? (A_Space . getUnit("Pressure")) : " PSI")
		local temperatureUnit := ((type != "Agent") ? (A_Space . getUnit("Temperature")) : " Celsius")
		local percent := " %"
		local seconds := " Seconds"
		local lapNumber, tyres, brakes, tyreCompound, tyreType, setupPressures, idealPressures, ignore, tyreType, goal, resultSet
		local bodyworkDamage, suspensionDamage, engineDamage, bodyworkDamageSum, suspensionDamageSum, pitstop, pitstops, lap, lapNr
		local tyres, brakes, postfix, tyre, brake, tyreTemperatures, tyrePressures, tyreWear, brakeTemperatures, brakeWear
		local fuelService, tyreService, brakeService, repairService, tyreSet, pitstopHistory, stintLaps, lastPitstop
		local tyreCompound, tyreCompoundColor, tcCandidate, tyreSets, tyreSet, ignore, tyreLife

		static wheels := ["FL", "FR", "RL", "RR"]

		convert(unit, value, arguments*) {
			if (type != "Agent")
				return convertUnit(unit, value, arguments*)
			else if isNumber(value)
				return Round(value, 2)
			else
				return value
		}

		getPitstopForecast() {
			local pitstop := Map("Status", "Forecast")
			local tyreChange := false
			local index, tyre, axle

			try {
				if fuelService
					pitstop["Refuel"] := (convert("Volume", knowledgeBase.getValue("Fuel.Amount.Target", 0)) . volumeUnit)

				if (repairService.Length > 0)
					pitstop["Repairs"] := (knowledgeBase.getValue("Target.Time.Repairs", 0) ? kTrue : kFalse)

				if tyreService {
					if (tyreService = "Wheel") {
						for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
							pitstop["TyreChange" . tyre]
								:= (knowledgeBase.getValue("Tyre.Compound.Target." . tyre, false) ? kTrue : kFalse)

							if (pitstop["TyreChange" . tyre] = kTrue) {
								tyreChange := true

								pitstop["TyreCompound" . tyre]
									:= compound(knowledgeBase.getValue("Tyre.Compound.Target." . tyre, "Dry")
											  , knowledgeBase.getValue("Tyre.Compound.Color.Target." . tyre, "Black"))
							}
						}
					}
					else if (tyreService = "Axle") {
						for index, axle in ["Front", "Rear"] {
							pitstop["TyreChange" . axle]
								:= (knowledgeBase.getValue("Tyre.Compound.Target." . axle, false) ? kTrue : kFalse)

							if (pitstop["TyreChange" . axle] = kTrue) {
								tyreChange := true

								pitstop["TyreCompound" . axle]
									:= compound(knowledgeBase.getValue("Tyre.Compound.Target." . axle, "Dry")
											  , knowledgeBase.getValue("Tyre.Compound.Color.Target." . axle, "Black"))
							}
						}
					}
					else {
						pitstop["TyreChange"] := (knowledgeBase.getValue("Tyre.Compound.Target", false) ? kTrue : kFalse)

						if (pitstop["TyreChange"] = kTrue) {
							tyreChange := true

							pitstop["TyreCompound"] := compound(knowledgeBase.getValue("Tyre.Compound.Target", "Dry")
															  , knowledgeBase.getValue("Tyre.Compound.Color.Target", "Black"))
						}
					}

					if tyreChange {
						if (tyreSet && (knowledgeBase.getValue("Tyre.Set.Target", 0) != 0))
							pitstop["TyreSet"] := knowledgeBase.getValue("Tyre.Set.Target")

						pitstop["TyrePressures"]
							:= Map("FrontLeft", (convert("Pressure", knowledgeBase.getValue("Tyre.Pressure.Target.FL", 0)) . pressureUnit)
								 , "FrontRight", (convert("Pressure", knowledgeBase.getValue("Tyre.Pressure.Target.FR", 0)) . pressureUnit)
								 , "RearLeft", (convert("Pressure", knowledgeBase.getValue("Tyre.Pressure.Target.RL", 0)) . pressureUnit)
								 , "RearRight", (convert("Pressure", knowledgeBase.getValue("Tyre.Pressure.Target.RR", 0)) . pressureUnit))
					}

					if brakeService
						pitstop["BrakeChange"] := (knowledgeBase.getValue("Brake.Change.Target", false) ? kTrue : kFalse)
				}

				return pitstop
			}
			catch Any as exception {
				logError(exception)

				return false
			}
		}

		getPitstopPlanned() {
			local lap := knowledgeBase.getValue("Pitstop.Planned.Lap", false)
			local pitstop := Map("Nr", knowledgeBase.getValue("Pitstop.Planned.Nr")
							   , "Status", (this.hasPreparedPitstop() ? "Prepared" : "Planned"))
			local tyreChange := false
			local repairs, index, tyre, axle

			try {
				if lap
					pitstop["Lap"] := lap + 1

				if fuelService
					pitstop["Refuel"] := (convert("Volume", knowledgeBase.getValue("Pitstop.Planned.Fuel", 0)) . volumeUnit)

				if (repairService.Length > 0) {
					repairs := (knowledgeBase.getValue("Pitstop.Planned.Repair.Bodywork", false)
							 || knowledgeBase.getValue("Pitstop.Planned.Repair.Suspension", false)
							 || knowledgeBase.getValue("Pitstop.Planned.Repair.Engine", false))

					pitstop["Repairs"] := (repairs ? kTrue : kFalse)
				}

				if tyreService {
					if (tyreService = "Wheel") {
						for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
							pitstop["TyreChange" . tyre]
								:= (knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound." . tyre, false) ? kTrue : kFalse)

							if (pitstop["TyreChange" . tyre] = kTrue) {
								tyreChange := true

								pitstop["TyreCompound" . tyre]
									:= compound(knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound." . tyre, "Dry")
											  , knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound.Color." . tyre, "Black"))
							}
						}
					}
					else if (tyreService = "Axle") {
						for index, axle in ["Front", "Rear"] {
							pitstop["TyreChange" . axle]
								:= (knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound." . axle, false) ? kTrue : kFalse)

							if (pitstop["TyreChange" . axle] = kTrue) {
								tyreChange := true

								pitstop["TyreCompound" . axle]
									:= compound(knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound." . axle, "Dry")
											  , knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound.Color." . axle, "Black"))
							}
						}
					}
					else {
						tyreChange := knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound", false)

						if tyreChange
							pitstop["TyreCompound"] := compound(tyreChange
															  , knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound.Color", "Black"))
					}

					pitstop["TyreChange"] := (tyreChange ? kTrue : kFalse)

					if tyreChange {
						if (tyreSet && (knowledgeBase.getValue("Pitstop.Planned.Tyre.Set", 0) != 0))
							pitstop["TyreSet"] := knowledgeBase.getValue("Pitstop.Planned.Tyre.Set")

						if knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FL", false)
							pitstop["TyrePressures"]
								:= Map("FrontLeft", (convert("Pressure", knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FL", 0)) . pressureUnit)
									 , "FrontRight", (convert("Pressure", knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FR", 0)) . pressureUnit)
									 , "RearLeft", (convert("Pressure", knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RL", 0)) . pressureUnit)
									 , "RearRight", (convert("Pressure", knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RR", 0)) . pressureUnit))
					}

					if brakeService
						pitstop["BrakeChange"] := (knowledgeBase.getValue("Pitstop.Planned.Brake.Change", false) ? kTrue : kFalse)
				}

				return pitstop
			}
			catch Any as exception {
				logError(exception)

				return false
			}
		}

		getPastPitstop(nr) {
			local tyreChange := false
			local pitstop, repairs
			local index, tyre, axle

			try {
				pitstop := Map("Nr", nr
							 , "AirTemperature", (convert("Temperature", knowledgeBase.getValue("Pitstop." . nr . ".Temperature.Air", 0)) . temperatureUnit)
							 , "TrackTemperature", (convert("Temperature", knowledgeBase.getValue("Pitstop." . nr . ".Temperature.Track", 0)) . temperatureUnit)
							 , "Lap", knowledgeBase.getValue("Pitstop." . nr . ".Lap", 0))

				if fuelService
					pitstop["Refuel"] := (convert("Volume", knowledgeBase.getValue("Pitstop." . nr . ".Fuel", 0)) . volumeUnit)

				if (repairService.Length > 0) {
					repairs := (knowledgeBase.getValue("Pitstop." . nr . ".Repair.Bodywork", false)
							 || knowledgeBase.getValue("Pitstop." . nr . ".Repair.Suspension", false)
							 || knowledgeBase.getValue("Pitstop." . nr . ".Repair.Engine", false))

					pitstop["Repairs"] := (repairs ? kTrue : kFalse)
				}

				if tyreService {
					if (tyreService = "Wheel") {
						for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
							pitstop["TyreChange" . tyre]
								:= (knowledgeBase.getValue("Pitstop." . nr . ".Tyre.Compound." . tyre, false) ? kTrue : kFalse)

							if (pitstop["TyreChange" . tyre] = kTrue) {
								tyreChange := true

								pitstop["TyreCompound" . tyre]
									:= compound(knowledgeBase.getValue("Pitstop." . nr . ".Tyre.Compound." . tyre, "Dry")
											  , knowledgeBase.getValue("Pitstop." . nr . ".Tyre.Compound.Color." . tyre, "Black"))
							}
						}
					}
					else if (tyreService = "Axle") {
						for index, axle in ["Front", "Rear"] {
							pitstop["TyreChange" . axle]
								:= (knowledgeBase.getValue("Pitstop." . nr . ".Tyre.Compound." . axle, false) ? kTrue : kFalse)

							if (pitstop["TyreChange" . axle] = kTrue) {
								tyreChange := true

								pitstop["TyreCompound" . axle]
									:= compound(knowledgeBase.getValue("Pitstop." . nr . ".Tyre.Compound." . axle, "Dry")
											  , knowledgeBase.getValue("Pitstop." . nr . ".Tyre.Compound.Color." . axle, "Black"))
							}
						}
					}
					else {
						tyreChange := knowledgeBase.getValue("Pitstop." . nr . ".Tyre.Compound", false)

						if tyreChange
							pitstop["TyreCompound"] := compound(knowledgeBase.getValue("Pitstop." . nr . ".Tyre.Compound")
															  , knowledgeBase.getValue("Pitstop." . nr . ".Tyre.Compound.Color", "Black"))
					}

					pitstop["TyreChange"] := (tyreChange ? kTrue : kFalse)

					if tyreChange {
						if (tyreSet && (knowledgeBase.getValue("Pitstop." . nr . ".Tyre.Set", 0) != 0))
							pitstop["TyreSet"] := knowledgeBase.getValue("Pitstop." . nr . ".Tyre.Set")

						pitstop["TyrePressures"]
							:= Map("FrontLeft", (convert("Pressure", knowledgeBase.getValue("Pitstop." . nr . ".Tyre.Pressure.FL", 0)) . pressureUnit)
								 , "FrontRight", (convert("Pressure", knowledgeBase.getValue("Pitstop." . nr . ".Tyre.Pressure.FR", 0)) . pressureUnit)
								 , "RearLeft", (convert("Pressure", knowledgeBase.getValue("Pitstop." . nr . ".Tyre.Pressure.RL", 0)) . pressureUnit)
								 , "RearRight", (convert("Pressure", knowledgeBase.getValue("Pitstop." . nr . ".Tyre.Pressure.RR", 0)) . pressureUnit))
					}

					if brakeService
						pitstop["BrakeChange"] := (knowledgeBase.getValue("Pitstop." . nr . ".Brake.Change", false) ? kTrue : kFalse)
				}

				return pitstop
			}
			catch Any as exception {
				logError(exception)

				return false
			}
		}

		if knowledgeBase {
			this.Provider.supportsPitstop(&fuelService, &tyreService, &brakeService, &repairService)
			this.Provider.supportsTyreManagement( , &tyreSet)

			lapNumber := knowledgeBase.getValue("Lap", 0)

			if this.activeTopic(options, "Session")
				try {
					if this.iRaceRules
						knowledge["Session"]["Rules"] := this.iRaceRules

					tyreSets := knowledge["Session"]["AvailableTyres"]

					for ignore, tyreCompound in SessionDatabase.getTyreCompounds(this.Simulator, this.Car, this.Track) {
						tcCandidate := tyreCompound

						splitCompound(tyreCompound, &tyreCompound, &tyreCompoundColor)

						tyreLife := knowledgeBase.getValue("Session.Settings.Tyre." . tyreCompound . "." . tyreCompoundColor . ".Laps.Max"
														 , kUndefined)

						if (tyreLife != kUndefined) {
							tyreSet := first(tyreSets, (ts) => (ts["Compound"] = tcCandidate))

							if tyreSet
								tyreSet["UsableLaps"] := tyreLife
						}
					}
				}
				catch Any as exception {
					logError(exception, true)
				}

			if (this.activeTopic(options, "Laps") && knowledge.Has("Laps"))
				try {
					for ignore, lap in knowledge["Laps"] {
						lapNr := lap["Nr"]

						lap["BodyworkDamage"] := knowledgeBase.getValue("Lap." . lapNr . ".Damage.Bodywork", 0)
						lap["SuspensionDamage"] := knowledgeBase.getValue("Lap." . lapNr . ".Damage.Suspension", 0)
						lap["EngineDamage"] := knowledgeBase.getValue("Lap." . lapNr . ".Damage.Engine", 0)

						tyres := Map()
						tyreTemperatures := Map()
						tyrePressures := Map()

						for postfix, tyre in Map("FL", "FrontLeft", "FR", "FrontRight"
											   , "RL", "RearLeft", "RR", "RearRight") {
							tyreTemperatures[tyre] := (convert("Temperature", knowledgeBase.getValue("Lap." . lapNr . ".Tyre.Temperature." . postfix, 0)) . temperatureUnit)
							tyrePressures[tyre] := (convert("Pressure", knowledgeBase.getValue("Lap." . lapNr . ".Tyre.Pressure." . postfix, 0)) . pressureUnit)
						}

						tyres["Temperatures"] := tyreTemperatures
						tyres["Pressures"] := tyrePressures

						if (knowledgeBase.getValue("Lap." . lapNr . ".Tyre.Wear.FL", kUndefined) != kUndefined) {
							tyreWear := Map()

							for postfix, tyre in Map("FL", "FrontLeft", "FR", "FrontRight"
												   , "RL", "RearLeft", "RR", "RearRight")
								tyreWear[tyre] := (knowledgeBase.getValue("Lap." . lapNr . ".Tyre.Wear." . postfix, 0) . percent)

							tyres["Wear"] := tyreWear
						}

						lap["Tyres"] := tyres

						brakes := Map()

						if (knowledgeBase.getValue("Lap." . lapNr . ".Brake.Wear.FL", kUndefined) != kUndefined) {
							brakeWear := Map()

							for postfix, brake in Map("FL", "FrontLeft", "FR", "FrontRight"
												    , "RL", "RearLeft", "RR", "RearRight")
								brakeWear[brake] := (knowledgeBase.getValue("Lap." . lapNr . ".Brake.Wear." . postfix, 0) . percent)

							brakes["Wear"] := brakeWear
						}

						if (knowledgeBase.getValue("Lap." . lapNr . ".Brake.Temperature.FL", kUndefined) != kUndefined) {
							brakeTemperatures := Map()

							for postfix, brake in Map("FL", "FrontLeft", "FR", "FrontRight"
												   , "RL", "RearLeft", "RR", "RearRight")
								brakeTemperatures[brake] := (convert("Temperature", knowledgeBase.getValue("Lap." . lapNr . ".Brake.Temperature." . postfix, 0)) . temperatureUnit)

							brakes["Temperatures"] := brakeTemperatures
						}

						if (brakes.Count > 0)
							lap["Brakes"] := brakes
					}
				}
				catch Any as exception {
					logError(exception, true)
				}

			if (this.activeTopic(options, "Fuel") && knowledge.Has("Fuel") && this.CurrentRemainingFuel)
				try {
					knowledge["Fuel"]["Remaining"] := (convert("Volume", this.CurrentRemainingFuel) . volumeUnit)
				}
				catch Any as exception {
					logError(exception, true)
				}

			if this.activeTopic(options, "Tyres")
				try {
					tyres := knowledge["Tyres"]

					if tyres.Has("Compound") {
						tyreCompound := compound(tyres["Compound"])

						setupPressures := []

						for ignore, tyreType in ["FL", "FR", "RL", "RR"] {
							goal := RuleCompiler().compileGoal("lastPressure(" . tyreCompound . ", " . tyreType . ", ?pressure)")
							resultSet := knowledgeBase.prove(goal)

							setupPressures.Push(resultSet ? Round(resultSet.getValue(goal.Arguments[3]).toString(), 1) : 0)
						}

						if (tyreCompound = "Intermediate")
							tyreCompound := "Wet"

						tyres["Pressures"]
							:= Map("Current", Map("FrontLeft", (convert("Pressure", this.CurrentTyrePressures[1]) . pressureUnit)
												, "FrontRight", (convert("Pressure", this.CurrentTyrePressures[2]) . pressureUnit)
												, "RearLeft", (convert("Pressure", this.CurrentTyrePressures[3]) . pressureUnit)
												, "RearRight", (convert("Pressure", this.CurrentTyrePressures[4]) . pressureUnit))
								 , "Ideal", Map("FrontLeft", (convert("Pressure", knowledgeBase.getValue("Session.Settings.Tyre." . tyreCompound . ".Pressure.Target.FL", 0)) . pressureUnit)
											  , "FrontRight", (convert("Pressure", knowledgeBase.getValue("Session.Settings.Tyre." . tyreCompound . ".Pressure.Target.FR", 0)) . pressureUnit)
											  , "RearLeft", (convert("Pressure", knowledgeBase.getValue("Session.Settings.Tyre." . tyreCompound . ".Pressure.Target.RL", 0)) . pressureUnit)
											  , "RearRight", (convert("Pressure", knowledgeBase.getValue("Session.Settings.Tyre." . tyreCompound . ".Pressure.Target.RR", 0)) . pressureUnit))
								 , "Setup", Map("FrontLeft", (convert("Pressure", setupPressures[1]) . pressureUnit)
											  , "FrontRight", (convert("Pressure", setupPressures[2]) . pressureUnit)
											  , "RearLeft", (convert("Pressure", setupPressures[3]) . pressureUnit)
											  , "RearRight", (convert("Pressure", setupPressures[4]) . pressureUnit)))
					}
					else if tyres.Has("CompoundFrontLeft") {
						setupPressures := Map()
						idealPressures := Map()

						for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
							tyreCompound := compound(tyres["Compound" . tyre])

							goal := RuleCompiler().compileGoal("lastPressure(" . tyreCompound . ", " . wheels[index] . ", ?pressure)")
							resultSet := knowledgeBase.prove(goal)

							setupPressures[tyre] := ((resultSet ? convert("Pressure", resultSet.getValue(goal.Arguments[3]).toString()) : 0) . pressureUnit)

							if (tyreCompound = "Intermediate")
								tyreCompound := "Wet"

							idealPressures[tyre] := (convert("Pressure", knowledgeBase.getValue("Session.Settings.Tyre." . tyreCompound . ".Pressure.Target." . wheels[index], 0)) . pressureUnit)
						}

						tyres["Pressures"] := Map("Current", Map("FrontLeft", (convert("Pressure", this.CurrentTyrePressures[1]) . pressureUnit)
															   , "FrontRight", (convert("Pressure", this.CurrentTyrePressures[2]) . pressureUnit)
															   , "RearLeft", (convert("Pressure", this.CurrentTyrePressures[3]) . pressureUnit)
															   , "RearRight", (convert("Pressure", this.CurrentTyrePressures[4]) . pressureUnit))
												, "Ideal", idealPressures
												, "Setup", setupPressures)
					}
					else if tyres.Has("CompoundFront") {
						setupPressures := Map()
						idealPressures := Map()

						for index, axle in ["Front", "Rear"] {
							tyreCompound := compound(tyres["Compound" . axle])

							goal := RuleCompiler().compileGoal("lastPressure(" . tyreCompound . ", " . wheels[index + (index - 1)] . ", ?pressure)")
							resultSet := knowledgeBase.prove(goal)

							setupPressures[axle . "Left"] := (convert("Pressure", (resultSet ? Round(resultSet.getValue(goal.Arguments[3]).toString(), 1) : 0)) . pressureUnit)

							goal := RuleCompiler().compileGoal("lastPressure(" . tyreCompound . ", " . wheels[index + (index - 1) + 1] . ", ?pressure)")
							resultSet := knowledgeBase.prove(goal)

							setupPressures[axle . "Right"] := ((resultSet ? convert("Pressure", resultSet.getValue(goal.Arguments[3]).toString()) : 0) . pressureUnit)

							if (tyreCompound = "Intermediate")
								tyreCompound := "Wet"

							idealPressures[axle . "Left"] := (convert("Pressure", knowledgeBase.getValue("Session.Settings.Tyre." . tyreCompound . ".Pressure.Target." . wheels[index + (index - 1)], 0)) . pressureUnit)
							idealPressures[axle . "Right"] := (convert("Pressure", knowledgeBase.getValue("Session.Settings.Tyre." . tyreCompound . ".Pressure.Target." . wheels[index + (index - 1) + 1], 0)) . pressureUnit)
						}

						tyres["Pressures"] := Map("Current", Map("FrontLeft", (convert("Pressure", this.CurrentTyrePressures[1]) . pressureUnit)
															   , "FrontRight", (convert("Pressure", this.CurrentTyrePressures[2]) . pressureUnit)
															   , "RearLeft", (convert("Pressure", this.CurrentTyrePressures[3]) . pressureUnit)
															   , "RearRight", (convert("Pressure", this.CurrentTyrePressures[4]) . pressureUnit))
												, "Ideal", idealPressures
												, "Setup", setupPressures)
					}

					if (knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Wear.FL", kUndefined) != kUndefined)
						tyres["Wear"] := Map("FrontLeft", (knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Wear.FL", 0) . percent)
										   , "FrontRight", (knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Wear.FR", 0) . percent)
										   , "RearLeft", (knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Wear.RL", 0) . percent)
										   , "RearRight", (knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Wear.RR", 0) . percent))

					tyres["Temperatures"]
						:= Map("Current", Map("FrontLeft", (convert("Temperature", this.CurrentTyreTemperatures[1]) . temperatureUnit)
											, "FrontRight", (convert("Temperature", this.CurrentTyreTemperatures[2]) . temperatureUnit)
											, "RearLeft", (convert("Temperature", this.CurrentTyreTemperatures[3]) . temperatureUnit)
											, "RearRight", (convert("Temperature", this.CurrentTyreTemperatures[4]) . temperatureUnit)))

					lastPitstop := knowledgeBase.getValue("Pitstop.Last", false)

					if lastPitstop {
						pitstopHistory := this.createPitstopHistory()

						if (getMultiMapValue(pitstopHistory, "Pitstops", lastPitstop . ".Lap", kUndefined) != kUndefined) {
							stintLaps := (lapNumber - (knowledgeBase.getValue("Pitstop." . lastPitstop . ".Lap")))

							tyres["Laps"] := Map("FrontLeft", getMultiMapValue(pitstopHistory, "Pitstops", lastPitstop . ".TyreLapsFrontLeft") + stintLaps
											   , "FrontRight", getMultiMapValue(pitstopHistory, "Pitstops", lastPitstop . ".TyreLapsFrontRight") + stintLaps
											   , "RearLeft", getMultiMapValue(pitstopHistory, "Pitstops", lastPitstop . ".TyreLapsRearLeft") + stintLaps
											   , "RearRight", getMultiMapValue(pitstopHistory, "Pitstops", lastPitstop . ".TyreLapsRearRight") + stintLaps)
						}
						else
							tyres["Laps"] := Map("FrontLeft", lapNumber, "FrontRight", lapNumber, "RearLeft", lapNumber, "RearRight", lapNumber)
					}
					else
						tyres["Laps"] := Map("FrontLeft", lapNumber, "FrontRight", lapNumber, "RearLeft", lapNumber, "RearRight", lapNumber)
				}
				catch Any as exception {
					logError(exception, true)
				}

			if this.activeTopic(options, "Brakes")
				try {
					if this.CurrentBrakeTemperatures
						knowledge["Brakes"]
							:= Map("Temperatures", Map("FrontLeft", (convert("Temperature", this.CurrentBrakeTemperatures[1]) . temperatureUnit)
													 , "FrontRight", (convert("Temperature", this.CurrentBrakeTemperatures[2]) . temperatureUnit)
													 , "RearLeft", (convert("Temperature", this.CurrentBrakeTemperatures[3]) . temperatureUnit)
													 , "RearRight", (convert("Temperature", this.CurrentBrakeTemperatures[4]) . temperatureUnit)))

					if (knowledgeBase.getValue("Lap." . lapNumber . ".Brake.Wear.FL", kUndefined) != kUndefined) {
						if !knowledge.Has("Brakes")
							knowledge["Brakes"] := Map()

						knowledge["Brakes"]["Wear"]
							:= Map("FrontLeft", (knowledgeBase.getValue("Lap." . lapNumber . ".Brake.Wear.FL", 0) . percent)
								 , "FrontRight", (knowledgeBase.getValue("Lap." . lapNumber . ".Brake.Wear.FR", 0) . percent)
								 , "RearLeft", (knowledgeBase.getValue("Lap." . lapNumber . ".Brake.Wear.RL", 0) . percent)
								 , "RearRight", (knowledgeBase.getValue("Lap." . lapNumber . ".Brake.Wear.RR", 0) . percent))
					}
				}
				catch Any as exception {
					logError(exception, true)
				}

			if this.activeTopic(options, "Damage")
				try {
					if (knowledgeBase.getValue("Lap." . lapNumber . ".Damage.Bodywork.Front", kUndefined) != kUndefined)
						bodyworkDamage := [knowledgeBase.getValue("Lap." . lapNumber . ".Damage.Bodywork.Front", 0)
										 , knowledgeBase.getValue("Lap." . lapNumber . ".Damage.Bodywork.Rear", 0)
										 , knowledgeBase.getValue("Lap." . lapNumber . ".Damage.Bodywork.Left", 0)
										 , knowledgeBase.getValue("Lap." . lapNumber . ".Damage.Bodywork.Right", 0)]
					else
						bodyworkDamage := []

					bodyworkDamageSum := sum(bodyworkDamage)

					if (bodyworkDamageSum > 0)
						knowledge["Damage"]
							:= Map("Bodywork", Map("Front", (Round(bodyworkDamage[1] / bodyWorkDamageSum * 100, 1) . percent)
												 , "Rear", (Round(bodyworkDamage[2] / bodyWorkDamageSum * 100, 1) . percent)
												 , "Left", (Round(bodyworkDamage[3] / bodyWorkDamageSum * 100, 1) . percent)
												 , "Right", (Round(bodyworkDamage[4] / bodyWorkDamageSum * 100, 1) . percent)))

					if (knowledgeBase.getValue("Lap." . lapNumber . ".Damage.Suspension.FL", kUndefined) != kUndefined)
						suspensionDamage := [knowledgeBase.getValue("Lap." . lapNumber . ".Damage.Suspension.FL", 0)
										   , knowledgeBase.getValue("Lap." . lapNumber . ".Damage.Suspension.FR", 0)
										   , knowledgeBase.getValue("Lap." . lapNumber . ".Damage.Suspension.RL", 0)
										   , knowledgeBase.getValue("Lap." . lapNumber . ".Damage.Suspension.RR", 0)]
					else
						suspensionDamage := []

					suspensionDamageSum := sum(suspensionDamage)

					if (suspensionDamageSum > 0) {
						if !knowledge.Has("Damage")
							knowledge["Damage"] := Map()

						knowledge["Damage"]["Suspension"]
							:= Map("Suspension", Map("FrontLeft", (Round(suspensionDamage[1] / suspensionDamageSum * 100, 1) . percent)
												   , "FrontRight", (Round(suspensionDamage[2] / suspensionDamageSum * 100, 1) . percent)
												   , "RearLeft", (Round(suspensionDamage[3] / suspensionDamageSum * 100, 1) . percent)
												   , "RearRight", (Round(suspensionDamage[4] / suspensionDamageSum * 100, 1) . percent)))
					}

					if ((knowledgeBase.getValue("Lap." . lapNumber . ".Damage.Engine", kUndefined) != kUndefined)
					 && (knowledgeBase.getValue("Lap." . lapNumber . ".Damage.Engine") > 0)) {
						if !knowledge.Has("Damage")
							knowledge["Damage"] := Map()

						knowledge["Damage"]["Engine"] := (knowledgeBase.getValue("Lap." . lapNumber . ".Damage.Engine") . percent)
					}

					if ((!knowledge.Has("Damage") || !knowledge["Damage"].Has("Bodywork")) && (knowledgeBase.getValue("Damage.Bodywork", 0) != 0)) {
						if !knowledge.Has("Damage")
							knowledge["Damage"] := Map()

						knowledge["Damage"]["Bodywork"] := knowledgeBase.getValue("Damage.Bodywork")
					}

					if ((!knowledge.Has("Damage") || !knowledge["Damage"].Has("Suspension")) && (knowledgeBase.getValue("Damage.Suspension", 0) != 0)) {
						if !knowledge.Has("Damage")
							knowledge["Damage"] := Map()

						knowledge["Damage"]["Suspension"] := knowledgeBase.getValue("Damage.Suspension")
					}

					if ((!knowledge.Has("Damage") || !knowledge["Damage"].Has("Engine")) && (knowledgeBase.getValue("Damage.Engine", 0) != 0)) {
						if !knowledge.Has("Damage")
							knowledge["Damage"] := Map()

						knowledge["Damage"]["Engine"] := knowledgeBase.getValue("Damage.Engine")
					}

					if knowledge.Has("Damage") {
						knowledge["Damage"]["LapTimeLoss"] := (Round(Max(knowledgeBase.getValue("Damage.Bodywork.Lap.Delta", 0)
																	   , knowledgeBase.getValue("Damage.Suspension.Lap.Delta", 0)
																	   , knowledgeBase.getValue("Damage.Engine.Lap.Delta", 0)), 1) . seconds)

						knowledge["Damage"]["RepairTime"] := (Round(knowledgeBase.getValue("Target.Time.Repairs", 0) / 1000) . seconds)
					}
				}
				catch Any as exception {
					logError(exception, true)
				}

			if this.activeTopic(options, "Pitstop")
				try {
					if (this.hasPlannedPitstop() || this.hasPreparedPitstop())
						knowledge["Pitstop"] := getPitstopPlanned()
					else
						knowledge["Pitstop"] := getPitstopForecast()
				}
				catch Any as exception {
					logError(exception, true)
				}

			if this.activeTopic(options, "Pitstops")
				try {
					pitstops := []

					loop knowledgeBase.getValue("Pitstop.Last", 0)
						if (knowledgeBase.getValue("Pitstop." . A_Index . ".Lap", kUndefined) != kUndefined) {
							pitstop := getPastPitstop(A_Index)

							if pitstop
								pitstops.Push(pitstop)
						}

					knowledge["Pitstops"] := pitstops
				}
				catch Any as exception {
					logError(exception, true)
				}
		}

		return knowledge
	}

	requestInformation(category, arguments*) {
		switch category, false {
			case "LapsRemaining":
				this.lapInfoRecognized([])
			case "FuelRemaining":
				this.fuelInfoRecognized([])
			case "Weather":
				this.weatherRecognized([])
			case "TyrePressures":
				this.tyreInfoRecognized(Array(this.getSpeaker().Fragments["Pressures"]))
			case "TyrePressuresCold":
				this.tyreInfoRecognized(Array(this.getSpeaker().Fragments["Pressures"], this.getSpeaker().Fragments["Cold"]))
			case "TyrePressuresSetup":
				this.tyreInfoRecognized(Array(this.getSpeaker().Fragments["Pressures"], this.getSpeaker().Fragments["Setup"]))
			case "TyreTemperatures":
				this.tyreInfoRecognized(Array(this.getSpeaker().Fragments["Temperatures"]))
			case "TyreWear":
				this.tyreWearRecognized([])
			case "BrakeTemperatures":
				this.brakeTemperaturesRecognized([])
			case "BrakeWear":
				this.brakeWearRecognized([])
			case "EngineTemperatures":
				this.engineInfoRecognized(Array(this.getSpeaker().Fragments["Temperatures"]))
			default:
				super.requestInformation(category, arguments*)
		}
	}

	fuelRatioOptimizeRecognized(words) {
		this.optimizeFuelRatio()
	}

	lapInfoRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local lap, speaker, remainingFuelLaps, remainingSessionLaps, remainingStintLaps

		if !this.hasEnoughData()
			return

		speaker := this.getSpeaker()
		remainingFuelLaps := Floor(knowledgeBase.getValue("Lap.Remaining.Fuel", 0))

		if (remainingFuelLaps == 0)
			speaker.speakPhrase("Later")
		else {
			speaker.beginTalk()

			try {
				speaker.speakPhrase("LapsAlready", {laps: (knowledgeBase.getValue("Lap", 0) - this.BaseLap + 1)})

				speaker.speakPhrase("LapsFuel", {laps: remainingFuelLaps})

				remainingSessionLaps := Ceil(knowledgeBase.getValue("Lap.Remaining.Session", 0))
				remainingStintLaps := Floor(knowledgeBase.getValue("Lap.Remaining.Stint", 0))

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
		local speaker := this.getSpeaker()
		local lap, fuel

		lap := knowledgeBase.getValue("Lap", 0)

		if (lap == 0)
			speaker.speakPhrase("Later")
		else {
			fuel := knowledgeBase.getValue("Lap." . lap . ".Fuel.Remaining", 0)

			if (fuel == 0)
				speaker.speakPhrase("Later")
			else if this.CurrentRemainingFuel
				speaker.speakPhrase("Fuel", {fuel: speaker.number2Speech(Floor(convertUnit("Volume", this.CurrentRemainingFuel)), 0)
										   , unit: speaker.Fragments[getUnit("Volume")]})
			else
				speaker.speakPhrase("Fuel", {fuel: speaker.number2Speech(Floor(convertUnit("Volume", fuel)), 0)
										   , unit: speaker.Fragments[getUnit("Volume")]})
		}
	}

	tyreInfoRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local fragments := speaker.Fragments
		local forCold := false
		local forSetup := false
		local unit, lap, index, suffix, value, setupPressures, ignore, tyreType, goal, resultSet, compound

		if !this.hasEnoughData()
			return

		words := string2values(";", StrReplace(values2String(";", words*), "set;up", "setup"))

		if inList(words, fragments["Temperatures"])
			unit := "Temperature"
		else if inList(words, fragments["Pressures"]) {
			unit := "Pressure"

			forSetup := inList(words, fragments["Setup"])
			forCold := inList(words, fragments["Cold"])
		}
		else {
			speaker.speakPhrase("Repeat")

			return
		}

		speaker.beginTalk()

		try {
			lap := knowledgeBase.getValue("Lap")

			if forSetup {
				compound := knowledgeBase.getValue("Tyre.Compound", "Dry")
				setupPressures := []

				for ignore, tyreType in ["FL", "FR", "RL", "RR"] {
					goal := RuleCompiler().compileGoal("lastPressure(" . compound . ", " . tyreType . ", ?pressure)")
					resultSet := knowledgeBase.prove(goal)

					setupPressures.Push(resultSet ? resultSet.getValue(goal.Arguments[3]).toString() : 0)
				}
			}

			if (unit = "Pressure") {
				if ((forSetup && (setupPressures[1] = 0))
				 || (forCold && (knowledgeBase.getValue("Tyre.Pressure.Target.FL", kUndefined) = kUndefined))
				 || (knowledgeBase.getValue("Lap." . lap . ".Tyre.Pressure.FL", kUndefined) = kUndefined)) {
					 speaker.speakPhrase("NoData")

					 return
				}
			}
			else if (knowledgeBase.getValue("Lap." . lap . ".Tyre.Temperature.FL", kUndefined) = kUndefined) {
				speaker.speakPhrase("NoData")

				return
			}

			if (unit == "Pressure")
				speaker.speakPhrase("Pressures", {type: forSetup ? fragments["Setup"] : (forCold ? fragments["Cold"] : "")})
			else
				speaker.speakPhrase("Temperatures")

			for index, suffix in ["FL", "FR", "RL", "RR"] {
				if (unit = "Pressure") {
					if forSetup
						value := speaker.number2Speech(convertUnit("Pressure", setupPressures[index]))
					else if forCold
						value := speaker.number2Speech(convertUnit("Pressure", knowledgeBase.getValue("Tyre.Pressure.Target." . suffix)))
					else if this.CurrentTyrePressures
						value := speaker.number2Speech(convertUnit("Pressure", this.CurrentTyrePressures[index]))
					else
						value := speaker.number2Speech(convertUnit("Pressure", knowledgeBase.getValue("Lap." . lap . ".Tyre.Pressure." . suffix)))
				}
				else if this.CurrentTyreTemperatures
					value := speaker.number2Speech(convertUnit("Temperature",  this.CurrentTyreTemperatures[index]))
				else
					value := speaker.number2Speech(convertUnit("Temperature", knowledgeBase.getValue("Lap." . lap . ".Tyre.Temperature." . suffix)), 0)

				speaker.speakPhrase("Tyre" . suffix, {value: value
													, unit: (unit = "Pressure") ? fragments[getUnit("Pressure")]
																				: (fragments["Degrees"] . A_Space . fragments[getUnit("Temperature")])
													, delta: "", by: ""})
			}
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
			speaker.speakPhrase("NoData")
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

		lap := knowledgeBase.getValue("Lap")

		if isNumber(knowledgeBase.getValue("Lap." . lap . ".Brake.Temperature.FL", kUndefined)) {
			speaker.beginTalk()

			try {
				speaker.speakPhrase("Temperatures")

				if this.CurrentBrakeTemperatures {
					speaker.speakPhrase("BrakeFL", {value: speaker.number2Speech(convertUnit("Temperature", this.CurrentBrakeTemperatures[1]), 0)
												  , unit: (fragments["Degrees"] . A_Space . fragments[getUnit("Temperature")])})

					speaker.speakPhrase("BrakeFR", {value: speaker.number2Speech(convertUnit("Temperature", this.CurrentBrakeTemperatures[2]), 0)
												  , unit: (fragments["Degrees"] . A_Space . fragments[getUnit("Temperature")])})

					speaker.speakPhrase("BrakeRL", {value: speaker.number2Speech(convertUnit("Temperature",  this.CurrentBrakeTemperatures[3]), 0)
												  , unit: (fragments["Degrees"] . A_Space . fragments[getUnit("Temperature")])})

					speaker.speakPhrase("BrakeRR", {value: speaker.number2Speech(convertUnit("Temperature",  this.CurrentBrakeTemperatures[4]), 0)
												  , unit: (fragments["Degrees"] . A_Space . fragments[getUnit("Temperature")])})
				}
				else {
					speaker.speakPhrase("BrakeFL", {value: speaker.number2Speech(convertUnit("Temperature", knowledgeBase.getValue("Lap." . lap . ".Brake.Temperature.FL")), 0)
												  , unit: (fragments["Degrees"] . A_Space . fragments[getUnit("Temperature")])})

					speaker.speakPhrase("BrakeFR", {value: speaker.number2Speech(convertUnit("Temperature", knowledgeBase.getValue("Lap." . lap . ".Brake.Temperature.FR")), 0)
												  , unit: (fragments["Degrees"] . A_Space . fragments[getUnit("Temperature")])})

					speaker.speakPhrase("BrakeRL", {value: speaker.number2Speech(convertUnit("Temperature", knowledgeBase.getValue("Lap." . lap . ".Brake.Temperature.RL")), 0)
												  , unit: (fragments["Degrees"] . A_Space . fragments[getUnit("Temperature")])})

					speaker.speakPhrase("BrakeRR", {value: speaker.number2Speech(convertUnit("Temperature", knowledgeBase.getValue("Lap." . lap . ".Brake.Temperature.RR")), 0)
												  , unit: (fragments["Degrees"] . A_Space . fragments[getUnit("Temperature")])})
				}
			}
			finally {
				speaker.endTalk()
			}
		}
		else
			speaker.speakPhrase("NoData")
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
			speaker.speakPhrase("NoData")
		else {
			frWear := knowledgeBase.getValue("Lap." . lap . ".Brake.Wear.FR")
			rlWear := knowledgeBase.getValue("Lap." . lap . ".Brake.Wear.RL")
			rrWear := knowledgeBase.getValue("Lap." . lap . ".Brake.Wear.RR")

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

	engineInfoRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local fragments := speaker.Fragments
		local waterTemperature := false
		local oilTemperature := false

		if !this.hasEnoughData()
			return

		speaker.beginTalk()

		try {
			lap := knowledgeBase.getValue("Lap")

			waterTemperature := knowledgeBase.getValue("Lap." . lap . ".Engine.Temperature.Water", false)
			oilTemperature := knowledgeBase.getValue("Lap." . lap . ".Engine.Temperature.Oil", false)

			if (waterTemperature || oilTemperature) {
				speaker.speakPhrase("Temperatures")

				if waterTemperature
					speaker.speakPhrase("WaterTemperature", {value: speaker.number2Speech(convertUnit("Temperature",  waterTemperature))
														   , unit: (fragments["Degrees"] . A_Space . fragments[getUnit("Temperature")])})

				if oilTemperature
					speaker.speakPhrase("OilTemperature", {value: speaker.number2Speech(convertUnit("Temperature",  oilTemperature))
														 , unit: (fragments["Degrees"] . A_Space . fragments[getUnit("Temperature")])})
			}
			else
				speaker.speakPhrase("NoData")
		}
		finally {
			speaker.endTalk()
		}
	}

	planPitstopRecognized(words) {
		this.proposePitstop()
	}

	driverSwapRecognized(words) {
		this.planDriverSwap()
	}

	preparePitstopRecognized(words) {
		if !this.confirmCommand(false)
			return

		this.preparePitstop()
	}

	pitstopAdjustFuelRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local fragments := speaker.Fragments
		local convert := false
		local volumePosition := false
		local fuel, ignore, word, lap, remainingFuel

		if !this.hasPlannedPitstop() {
			if this.Listener {
				speaker.beginTalk()

				try {
					speaker.speakPhrase("NotPossible")

					speaker.speakPhrase("ConfirmPlan", {forYou: ""}, true)
				}
				finally {
					speaker.endTalk()
				}

				this.setContinuation(ObjBindMethod(this, "planPitstop"))
			}
			else
				speaker.speakPhrase("NotPossible")
		}
		else {
			for ignore, word in words
				if (InStr(word, fragments["Liter"]) || InStr(word, "litre")) {
					volumePosition := A_Index

					break
				}
				else if InStr(word, fragments["Gallon"]) {
					volumePosition := A_Index
					convert := true

					break
				}

			if volumePosition {
				fuel := words[volumePosition - 1]

				if InStr(values2String(A_Space, words*), A_Space . fragments["UpTo"] . A_Space) {
					lap := knowledgeBase.getValue("Lap")
					remainingFuel := (knowledgeBase.getValue("Lap." . lap . ".Fuel.Remaining", 0) - knowledgeBase.getValue("Lap." . lap . ".Fuel.AvgConsumption", 0))

					if convert
						if (getUnit("Volume") = "Gallon (US)")
							remainingFuel := Floor(remainingFuel / 3.785411)
						else
							remainingFuel := Floor(remainingFuel / 4.546092)

					fuel := Round(Max(0, fuel - remainingFuel))
				}

				if this.isNumber(fuel, &fuel) {
					if this.Listener {
						speaker.speakPhrase("ConfirmFuelChange", {fuel: fuel, unit: fragments[convert ? "Gallon" : "Liter"]}, true)

						if convert
							if (getUnit("Volume") = "Gallon (US)")
								fuel := Ceil(fuel * 3.785411)
							else
								fuel := Ceil(fuel * 4.546092)

						this.setContinuation(ObjBindMethod(this, "updatePitstopFuel", fuel))
					}
					else {
						if convert
							if (getUnit("Volume") = "Gallon (US)")
								fuel := Ceil(fuel * 3.785411)
							else
								fuel := Ceil(fuel * 4.546092)

						this.updatePitstopFuel(fuel)
					}

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
		local compound, compoundColor, ignore, candidate, found

		if !this.hasPlannedPitstop() {
			if this.Listener {
				speaker.beginTalk()

				try {
					speaker.speakPhrase("NotPossible")
					speaker.speakPhrase("ConfirmPlan", {forYou: ""}, true)
				}
				finally {
					speaker.endTalk()
				}

				this.setContinuation(ObjBindMethod(this, "planPitstop"))
			}
			else
				speaker.speakPhrase("NotPossible")
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
				found := false

				for ignore, candidate in SessionDatabase.getTyreCompounds(knowledgeBase.getValue("Session.Simulator")
																		, knowledgeBase.getValue("Session.Car")
																		, knowledgeBase.getValue("Session.Track"))
					if (InStr(candidate, compound) = 1) {
						splitCompound(compound, &compound, &compoundColor)

						if this.Listener {
							speaker.speakPhrase("ConfirmCompoundChange", {compound: fragments[compound . "Tyre"]}, true)

							this.setContinuation(ObjBindMethod(this, "updatePitstopTyreCompound", compound, compoundColor))
						}
						else
							this.updatePitstopTyreCompound(compound, compoundColor)

						found := true

						break
					}

				if !found
					speaker.speakPhrase("CompoundNotAvailable", {compound: fragments[compound . "Tyre"]})
			}
			else
				speaker.speakPhrase("Repeat")
		}
	}

	pitstopAdjustPressureRecognized(words) {
		local speaker := this.getSpeaker()
		local fragments := speaker.Fragments
		local tyreType, action, pointPosition, found, pressureValue, tenthPressureValue, ignore, word, startChar, delta

		static tyreTypeFragments := false

		if !this.hasPlannedPitstop() {
			if this.Listener {
				speaker.beginTalk()

				try {
					speaker.speakPhrase("NotPossible")
					speaker.speakPhrase("ConfirmPlan", {forYou: ""}, true)
				}
				finally {
					speaker.endTalk()
				}

				this.setContinuation(ObjBindMethod(this, "planPitstop"))
			}
			else
				speaker.speakPhrase("NotPossible")
		}
		else {
			if !tyreTypeFragments
				tyreTypeFragments := CaseInsenseMap("FL", fragments["FrontLeft"], "FR", fragments["FrontRight"]
												  , "RL", fragments["RearLeft"], "RR", fragments["RearRight"])

			tyreType := false

			if inList(words, fragments["All"])
				tyreType := "All"
			else if inList(words, fragments["Front"]) {
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

				pointPosition := inList(words, fragments[(getFloatSeparator() = ".") ? "Point" : "Coma"])
				found := false

				if pointPosition {
					pressureValue := words[pointPosition - 1]
					tenthPressureValue := words[pointPosition + 1]

					found := (this.isNumber(pressureValue, &pressureValue) && this.isNumber(tenthPressureValue, &tenthPressureValue))
				}
				else
					for ignore, word in words {
						if isFloat(word) {
							pressureValue := Floor(word)
							tenthPressureValue := Round((word - pressureValue) * 10)

							found := true

							break
						}
						else {
							startChar := SubStr(word, 1, 1)

							if isInteger(startChar)
								if (StrLen(word) = 2) {
									found := (this.isNumber(startChar, &pressureValue) && this.isNumber(SubStr(word, 2, 1), &tenthPressureValue))

									if found
										break
								}
						}
					}

				if found {
					action := fragments[action]

					delta := Round(pressureValue + (tenthPressureValue / 10), 1)

					if knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FL", false) {
						if this.Listener {
							if (tyreType = "All")
								speaker.speakPhrase("ConfirmAllPressureChange", {action: action, unit: fragments[getUnit("Pressure")]
																			   , delta: speaker.number2Speech(delta, 1)}, true)
							else
								speaker.speakPhrase("ConfirmPressureChange", {action: action, tyre: tyreTypeFragments[tyreType]
																			, unit: fragments[getUnit("Pressure")]
																			, delta: speaker.number2Speech(delta, 1)}, true)

							this.setContinuation(ObjBindMethod(this, "updatePitstopTyrePressure", tyreType, (action == kIncrease) ? delta : (delta * -1)))
						}
						else
							this.updatePitstopTyrePressure(tyreType, (action == kIncrease) ? delta : (delta * -1))
					}
					else
						speaker.speakPhrase("NotPossible")

					return
				}
			}

			speaker.speakPhrase("Repeat")
		}
	}

	pitstopAdjustNoPressureRecognized(words) {
		local speaker := this.getSpeaker()

		if !this.hasPlannedPitstop() {
			if this.Listener {
				speaker.beginTalk()

				try {
					speaker.speakPhrase("NotPossible")
					speaker.speakPhrase("ConfirmPlan", {forYou: ""}, true)
				}
				finally {
					speaker.endTalk()
				}

				this.setContinuation(ObjBindMethod(this, "planPitstop"))
			}
			else
				speaker.speakPhrase("NotPossible")
		}
		else if this.Listener {
			speaker.speakPhrase("ConfirmNoPressureChange", false, true)

			this.setContinuation(ObjBindMethod(this, "updatePitstopPressures"))
		}
		else
			this.updatePitstopPressures()
	}

	pitstopAdjustNoTyreRecognized(words) {
		local speaker := this.getSpeaker()

		if !this.hasPlannedPitstop() {
			if this.Listener {
				speaker.beginTalk()

				try {
					speaker.speakPhrase("NotPossible")
					speaker.speakPhrase("ConfirmPlan", {forYou: ""}, true)
				}
				finally {
					speaker.endTalk()
				}

				this.setContinuation(ObjBindMethod(this, "planPitstop"))
			}
			else
				speaker.speakPhrase("NotPossible")
		}
		else if this.Listener {
			speaker.speakPhrase("ConfirmNoTyreChange", false, true)

			this.setContinuation(ObjBindMethod(this, "updatePitstopTyreChange"))
		}
		else
			this.updatePitstopTyreChange()
	}

	pitstopAdjustRepairRecognized(repairType, words) {
		local speaker := this.getSpeaker()
		local fragments := speaker.Fragments
		local negation

		if !this.hasPlannedPitstop() {
			if this.Listener {
				speaker.beginTalk()

				try {
					speaker.speakPhrase("NotPossible")
					speaker.speakPhrase("ConfirmPlan", {forYou: ""}, true)
				}
				finally {
					speaker.endTalk()
				}

				this.setContinuation(ObjBindMethod(this, "planPitstop"))
			}
			else
				speaker.speakPhrase("NotPossible")
		}
		else {
			negation := ""

			if inList(words, fragments["Not"])
				negation := fragments["Not"]

			if this.Listener {
				speaker.speakPhrase("ConfirmRepairChange", {damage: fragments[repairType], negation: negation}, true)

				this.setContinuation(ObjBindMethod(this, "updatePitstopRepair", repairType, negation = ""))
			}
			else
				this.updatePitstopRepair(repairType, negation = "")
		}
	}

	pitstopCompensatePressureLossRecognized(words, enabled) {
		local knowledgeBase := this.KnowledgeBase

		if !this.hasEnoughData()
			return

		if knowledgeBase {
			this.getSpeaker().speakPhrase("Roger")

			knowledgeBase.setFact("Session.Settings.Tyre.Pressure.Correction.Pressure", enabled)
		}
		else
			this.getSpeaker().speakPhrase("Later")
	}

	updateDriver(name, verbose := true) {
		local knowledgeBase := this.KnowledgeBase
		local driverRequest := knowledgeBase.getValue("Pitstop.Planned.Driver.Request", false)
		local driver, index, candidate, forName, surName

		if driverRequest {
			driverRequest := string2Values("|", driverRequest)

			parseDriverName(name, &forName, &surName)

			forName := SubStr(forName, 1, 1)

			name := driverName(forName, surName, "")

			parseDriverName(string2Values(":", driverRequest[2])[1], &forName, &surName)

			forName := SubStr(forName, 1, 1)

			if (name != driverName(forName, surName, ""))
				for index, driver in string2Values(",", driverRequest[3]) {
					parseDriverName(driver, &forName, &surName)

					forName := SubStr(forName, 1, 1)

					if (driverName(forName, surName, "") = name) {
						this.pitstopOptionChanged("Driver Request", verbose
												, values2String("|", driverRequest[1], values2String(":", driver, index), driverRequest[3]))

						return true
					}
				}
		}

		return false
	}

	updatePitstop(data) {
		local knowledgeBase := this.KnowledgeBase
		local result := false
		local verbose := knowledgeBase.getValue("Pitstop.Planned.Adjusted", false)
		local index, suffix, prssKey, changed, values, value, tyreCompound, tyreCompoundColor
		local mixedCompounds, tyreSet, tyreService, brakeService, index, tyre, axle, tc, tcc
		local tyreCompounds, tyreCompoundColors

		if (this.iPitstopAdjustments && this.hasPreparedPitstop()) {
			this.Provider.supportsTyreManagement(&mixedCompounds, &tyreSet)
			this.Provider.supportsPitstop( , &tyreService, &brakeService)

			value := getMultiMapValue(data, "Setup Data", "FuelAmount", kUndefined)

			if ((value != kUndefined) && (Abs(Floor(knowledgeBase.getValue("Pitstop.Planned.Fuel")) - Floor(value)) > 2)) {
				this.pitstopOptionChanged("Refuel", verbose, Round(value, 1))

				result := true
			}

			tc := getMultiMapValue(data, "Setup Data", "TyreCompound", kUndefined)
			tcc := getMultiMapValue(data, "Setup Data", "TyreCompoundColor")

			if (tyreService = "Axle") {
				changed := false
				tyreCompounds := []
				tyreCompoundColors := []

				for index, axle in ["Front", "Rear"] {
					tyreCompound := getMultiMapValue(data, "Setup Data", "TyreCompound" . axle, tc)
					tyreCompoundColor := getMultiMapValue(data, "Setup Data", "TyreCompoundColor" . axle, tcc)

					tyreCompounds.Push(tyreCompound)
					tyreCompoundColors.Push(tyreCompoundColor)

					if ((tyreCompound != kUndefined) && ((knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound." . axle) != tyreCompound)
													  || (knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound.Color." . axle) != tyreCompoundColor)))
						changed := true
				}

				if changed {
					this.pitstopOptionChanged("Tyre Compound Axle", verbose, tyreCompounds, tyreCompoundColors)

					result := true
				}
			}
			else if (tyreService = "Wheel") {
				changed := false
				tyreCompounds := []
				tyreCompoundColors := []

				for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
					tyreCompound := getMultiMapValue(data, "Setup Data", "TyreCompound" . tyre, tc)
					tyreCompoundColor := getMultiMapValue(data, "Setup Data", "TyreCompoundColor" . tyre, tcc)

					tyreCompounds.Push(tyreCompound)
					tyreCompoundColors.Push(tyreCompoundColor)

					if ((tyreCompound != kUndefined) && ((knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound." . tyre) != tyreCompound)
													  || (knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound.Color." . tyre) != tyreCompoundColor)))
						changed := true
				}

				if changed {
					this.pitstopOptionChanged("Tyre Compound Wheel", verbose, tyreCompounds, tyreCompoundColors)

					result := true
				}
			}
			else {
				if ((tc != kUndefined) && ((knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound") != tc)
										|| (knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound.Color") != tcc))) {
					this.pitstopOptionChanged("Tyre Compound", verbose, tc, tcc)

					result := true
				}
			}

			if tyreSet {
				value := getMultiMapValue(data, "Setup Data", "TyreSet", kUndefined)

				if ((value != kUndefined) && (knowledgeBase.getValue("Pitstop.Planned.Tyre.Set") != value)) {
					this.pitstopOptionChanged("Tyre Set", verbose, value)

					result := true
				}
			}

			changed := false
			values := []

			if (knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound", false) || first(["Front", "Rear", "FrontLeft", "FrontRight", "RearLeft", "RearRight"]
																					  , (p) => knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound." . p, false))){
				for index, suffix in ["FL", "FR", "RL", "RR"] {
					prssKey := ("Pitstop.Planned.Tyre.Pressure." . suffix)
					value := getMultiMapValue(data, "Setup Data", "TyrePressure" . suffix, false)

					values.Push(value)

					if knowledgeBase.getValue(prssKey, false)
						if (value && (Abs(Round(knowledgeBase.getValue(prssKey, false), 1) - Round(value, 1)) > 0.2))
							changed := true
				}

				if changed {
					this.pitstopOptionChanged("Tyre Pressures", verbose, values*)

					result := true
				}
			}

			if brakeService {
				value := getMultiMapValue(data, "Setup Data", "ChangeBrakes", kUndefined)

				if ((value != kUndefined) && (knowledgeBase.getValue("Pitstop.Planned.Brake.Change") != value)) {
					this.pitstopOptionChanged("Change Brakes", verbose, value)

					result := true
				}
			}

			value := getMultiMapValue(data, "Setup Data", "RepairSuspension", kUndefined)

			if ((value != kUndefined) && (knowledgeBase.getValue("Pitstop.Planned.Repair.Suspension") != value)) {
				this.pitstopOptionChanged("Repair Suspension", verbose, value)

				result := true
			}

			value := getMultiMapValue(data, "Setup Data", "RepairBodywork", kUndefined)

			if ((value != kUndefined) && (knowledgeBase.getValue("Pitstop.Planned.Repair.Bodywork") != value)) {
				this.pitstopOptionChanged("Repair Bodywork", verbose, value)

				result := true
			}

			value := getMultiMapValue(data, "Setup Data", "RepairEngine", kUndefined)

			if ((value != kUndefined) && (knowledgeBase.getValue("Pitstop.Planned.Repair.Engine") != value)) {
				this.pitstopOptionChanged("Repair Engine", verbose, value)

				result := true
			}

			value := getMultiMapValue(data, "Setup Data", "Driver", kUndefined)

			if (value != kUndefined)
				if this.updateDriver(value, verbose)
					result := true

			if result
				knowledgeBase.setFact("Pitstop.Planned.Adjusted", true)
		}

		return result
	}

	updatePitstopFuel(fuel) {
		local speaker := this.getSpeaker()

		speaker.beginTalk()

		try {
			if !this.hasPlannedPitstop() {
				if this.Listener {
					speaker.speakPhrase("NotPossible")
					speaker.speakPhrase("ConfirmPlan", {forYou: ""}, true)

					this.setContinuation(ObjBindMethod(this, "planPitstop"))
				}
				else
					speaker.speakPhrase("NotPossible")
			}
			else {
				this.KnowledgeBase.setValue("Pitstop.Planned.Fuel", fuel)

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
				if this.Listener {
					speaker.speakPhrase("NotPossible")
					speaker.speakPhrase("ConfirmPlan", {forYou: ""}, true)

					this.setContinuation(ObjBindMethod(this, "planPitstop"))
				}
				else
					speaker.speakPhrase("NotPossible")
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
		local targetValue, targetIncrement, ignore, tyre

		speaker.beginTalk()

		try {
			if !this.hasPlannedPitstop() {
				if this.Listener {
					speaker.speakPhrase("NotPossible")
					speaker.speakPhrase("ConfirmPlan", {forYou: ""}, true)

					this.setContinuation(ObjBindMethod(this, "planPitstop"))
				}
				else
					speaker.speakPhrase("NotPossible")
			}
			else {
				delta := convertUnit("Pressure", internalValue("Float", delta))

				if (tyreType = "All")
					tyreType := ["FL", "FR", "RL", "RR"]
				else
					tyreType := Array(tyreType)

				if knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FL", false) {
					for ignore, tyre in tyreType {
						targetValue := knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure." . tyre)
						targetIncrement := knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure." . tyre . ".Increment")

						knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure." . tyre, targetValue + delta)
						knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure." . tyre . ".Increment", targetIncrement + delta)
					}

					if this.Debug[kDebugKnowledgeBase]
						this.dumpKnowledgeBase(this.KnowledgeBase)

					speaker.speakPhrase("ConfirmPlanUpdate")
					speaker.speakPhrase("MoreChanges", false, true)
				}
				else
					speaker.speakPhrase("NotPossible")
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
				if this.Listener {
					speaker.speakPhrase("NotPossible")
					speaker.speakPhrase("ConfirmPlan", {forYou: ""}, true)

					this.setContinuation(ObjBindMethod(this, "planPitstop"))
				}
				else
					speaker.speakPhrase("NotPossible")
			}
			else {
				knowledgeBase := this.KnowledgeBase

				knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.FL", false)
				knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.FR", false)
				knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.RL", false)
				knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.RR", false)
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
				if this.Listener {
					speaker.speakPhrase("NotPossible")
					speaker.speakPhrase("ConfirmPlan", {forYou: ""}, true)

					this.setContinuation(ObjBindMethod(this, "planPitstop"))
				}
				else
					speaker.speakPhrase("NotPossible")
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
				if this.Listener {
					speaker.speakPhrase("NotPossible")
					speaker.speakPhrase("ConfirmPlan", {forYou: ""}, true)

					this.setContinuation(ObjBindMethod(this, "planPitstop"))
				}
				else
					speaker.speakPhrase("NotPossible")
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
			case kSessionTimeTrial:
				session := "Time Trial"
			case kSessionRace:
				session := "Race"
				default := true
		}

		return getMultiMapValue(this.Settings, "Session Settings", "Pressures." . session, default)
	}

	readSettings(simulator, car, track, &settings) {
		local simulatorName := this.SettingsDatabase.getSimulatorName(simulator)
		local section := ("Simulator." . simulatorName)
		local defaults := CaseInsenseMap()
		local bodyworkDuration, suspensionDuration, engineDuration
		local bodyworkRepair, suspensionRepair, engineRepair
		local bodyworkThreshold, suspensionThreshold, engineThreshold
		local facts, compound, tyreLife, tyreCompound, tyreCompoundColor

		defaults.Default := {Bodywork: 0.0, Suspension: 0.0, Engine: 0.0}

		defaults["Assetto Corsa Competizione"] := {Bodywork: 0.282351878, Suspension: 31.0, Engine: 0.0}

		bodyworkDuration := getMultiMapValue(settings, section, "Pitstop.Repair.Bodywork.Duration", defaults[simulatorName].Bodywork)
		suspensionDuration := getMultiMapValue(settings, section, "Pitstop.Repair.Suspension.Duration", defaults[simulatorName].Suspension)
		engineDuration := getMultiMapValue(settings, section, "Pitstop.Repair.Engine.Duration", defaults[simulatorName].Engine)

		bodyworkRepair := getDeprecatedValue(settings, "Session Settings", "Race Settings", "Damage.Bodywork.Repair", "Impact")
		suspensionRepair := getDeprecatedValue(settings, "Session Settings", "Race Settings", "Damage.Suspension.Repair", "Always")
		engineRepair := getDeprecatedValue(settings, "Session Settings", "Race Settings", "Damage.Engine.Repair", "Impact")

		bodyworkThreshold := getDeprecatedValue(settings, "Session Settings", "Race Settings", "Damage.Bodywork.Repair.Threshold", 1)
		suspensionThreshold := getDeprecatedValue(settings, "Session Settings", "Race Settings", "Damage.Suspension.Repair.Threshold", 0)
		engineThreshold := getDeprecatedValue(settings, "Session Settings", "Race Settings", "Damage.Engine.Repair.Threshold", 1)

		if ((bodyworkRepair = "Threshold") && (bodyworkDuration != 0))
			bodyworkThreshold /= bodyworkDuration

		if ((suspensionRepair = "Threshold") && (suspensionDuration != 0))
			suspensionThreshold /= suspensionDuration

		if ((engineRepair = "Threshold") && (engineDuration != 0))
			engineThreshold /= engineDuration

		tyreService := getMultiMapValue(settings, section, "Pitstop.Service.Tyres", "Full")

		if (tyreService == false)
			tyreService := "Off"
		else if (tyreService == true)
			tyreService := "Full"
		else if (tyreService && !inList(["Off", "Change", "Full"], tyreService))
			tyreService := "Full"

		facts := combine(super.readSettings(simulator, car, track, &settings)
					   , CaseInsenseMap("Session.Settings.Pitstop.Service.Refuel", getMultiMapValue(settings, section, "Pitstop.Service.Refuel", true)
									  , "Session.Settings.Pitstop.Service.Tyres", tyreService
									  , "Session.Settings.Pitstop.Service.Brakes", getMultiMapValue(settings, section, "Pitstop.Service.Brakes", true)
									  , "Session.Settings.Pitstop.Service.Repairs", getMultiMapValue(settings, section, "Pitstop.Service.Repairs", true)
									  , "Session.Settings.Pitstop.Repair.Bodywork.Duration", bodyworkDuration
									  , "Session.Settings.Pitstop.Repair.Suspension.Duration", suspensionDuration
									  , "Session.Settings.Pitstop.Repair.Engine.Duration", engineDuration
									  , "Session.Settings.Pitstop.Delta", getMultiMapValue(settings, "Strategy Settings", "Pitstop.Delta"
																						 , getDeprecatedValue(settings, "Session Settings", "Race Settings", "Pitstop.Delta", 60))
									  , "Session.Settings.Pitstop.Service.Refuel.Rule", getMultiMapValue(settings, "Strategy Settings"
																												 , "Service.Refuel.Rule", "Dynamic")
									  , "Session.Settings.Pitstop.Service.Refuel.Duration", getMultiMapValue(settings, "Strategy Settings"
																													 , "Service.Refuel", 1.8)
									  , "Session.Settings.Pitstop.Service.Tyres.Duration", getMultiMapValue(settings, "Strategy Settings"
																													, "Service.Tyres", 30)
									  , "Session.Settings.Pitstop.Service.Brakes.Duration", getMultiMapValue(settings, "Strategy Settings"
																													 , "Service.Brakes", 50)
									  , "Session.Settings.Pitstop.Service.Order", getMultiMapValue(settings, "Strategy Settings"
																										   , "Service.Order", "Simultaneous")
									  , "Session.Settings.Pitstop.Service.Last", getMultiMapValue(settings, "Session Settings", "Pitstop.Service.Last", 5)
									  , "Session.Settings.Damage.Suspension.Repair", suspensionRepair
									  , "Session.Settings.Damage.Suspension.Repair.Threshold", suspensionThreshold
									  , "Session.Settings.Damage.Bodywork.Repair", bodyworkRepair
									  , "Session.Settings.Damage.Bodywork.Repair.Threshold", bodyworkThreshold
									  , "Session.Settings.Damage.Engine.Repair", engineRepair
									  , "Session.Settings.Damage.Engine.Repair.Threshold", engineThreshold
									  , "Session.Settings.Tyre.Change", getMultiMapValue(settings, "Session Settings", "Tyre.Change", "Wear")
									  , "Session.Settings.Tyre.Compound.Change", getDeprecatedValue(settings, "Session Settings", "Race Settings"
																											, "Tyre.Compound.Change", "Never")
									  , "Session.Settings.Tyre.Compound.Change.Threshold", getDeprecatedValue(settings, "Session Settings", "Race Settings"
																													  , "Tyre.Compound.Change.Threshold", 0)
									  , "Session.Settings.Tyre.Dry.Temperature.Ideal", getMultiMapValue(settings, "Session Settings"
																												, "Tyre.Dry.Temperature.Ideal", 90)
									  , "Session.Settings.Tyre.Wet.Temperature.Ideal", getMultiMapValue(settings, "Session Settings"
																												, "Tyre.Wet.Temperature.Ideal", 55)
									  , "Session.Settings.Tyre.Pressure.Correction.Temperature", getMultiMapValue(settings, "Session Settings"
																														  , "Tyre.Pressure.Correction.Temperature", true)
									  , "Session.Settings.Tyre.Pressure.Correction.Setup", getMultiMapValue(settings, "Session Settings"
																													, "Tyre.Pressure.Correction.Setup", false)
									  , "Session.Settings.Tyre.Pressure.Correction.Pressure", getMultiMapValue(settings, "Session Settings"
																													   , "Tyre.Pressure.Correction.Pressure", false)
									  , "Session.Settings.Tyre.Pressure.Loss.Threshold", getMultiMapValue(settings, "Session Settings"
																												  , "Tyre.Pressure.Loss.Threshold", 0.2)
									  , "Session.Settings.Tyre.Dry.Pressure.Target.FL", getDeprecatedValue(settings, "Session Settings", "Race Settings"
																												   , "Tyre.Dry.Pressure.Target.FL", 26.5)
									  , "Session.Settings.Tyre.Dry.Pressure.Target.FR", getDeprecatedValue(settings, "Session Settings", "Race Settings"
																												   , "Tyre.Dry.Pressure.Target.FR", 26.5)
									  , "Session.Settings.Tyre.Dry.Pressure.Target.RL", getDeprecatedValue(settings, "Session Settings", "Race Settings"
																												   , "Tyre.Dry.Pressure.Target.RL", 26.5)
									  , "Session.Settings.Tyre.Dry.Pressure.Target.RR", getDeprecatedValue(settings, "Session Settings", "Race Settings"
																												   , "Tyre.Dry.Pressure.Target.RR", 26.5)
									  , "Session.Settings.Tyre.Wet.Pressure.Target.FL", getDeprecatedValue(settings, "Session Settings", "Race Settings"
																												   , "Tyre.Wet.Pressure.Target.FL", 30.0)
									  , "Session.Settings.Tyre.Wet.Pressure.Target.FR", getDeprecatedValue(settings, "Session Settings", "Race Settings"
																												   , "Tyre.Wet.Pressure.Target.FR", 30.0)
									  , "Session.Settings.Tyre.Wet.Pressure.Target.RL", getDeprecatedValue(settings, "Session Settings", "Race Settings"
																												   , "Tyre.Wet.Pressure.Target.RL", 30.0)
									  , "Session.Settings.Tyre.Wet.Pressure.Target.RR", getDeprecatedValue(settings, "Session Settings", "Race Settings"
																												   , "Tyre.Wet.Pressure.Target.RR", 30.0)
									  , "Session.Settings.Tyre.Pressure.Deviation", getDeprecatedValue(settings, "Session Settings", "Race Settings"
																											   , "Tyre.Pressure.Deviation", 0.2)
									  , "Session.Settings.Tyre.Wear.Warning", getMultiMapValue(settings, "Session Settings", "Tyre.Wear.Warning", 25)
									  , "Session.Settings.Brake.Wear.Warning", getMultiMapValue(settings, "Session Settings", "Brake.Wear.Warning", 10)
									  , "Session.Setup.Tyre.Set.Fresh", getDeprecatedValue(settings, "Session Setup", "Race Setup"
																								   , "Tyre.Set.Fresh", 8)
									  , "Session.Setup.Tyre.Set", getDeprecatedValue(settings, "Session Setup", "Race Setup", "Tyre.Set", 7)
									  , "Session.Setup.Tyre.Dry.Pressure.FL", getDeprecatedValue(settings, "Session Setup", "Race Setup"
																										 , "Tyre.Dry.Pressure.FL", 26.1)
									  , "Session.Setup.Tyre.Dry.Pressure.FR", getDeprecatedValue(settings, "Session Setup", "Race Setup"
																										 , "Tyre.Dry.Pressure.FR", 26.1)
									  , "Session.Setup.Tyre.Dry.Pressure.RL", getDeprecatedValue(settings, "Session Setup", "Race Setup"
																										 , "Tyre.Dry.Pressure.RL", 26.1)
									  , "Session.Setup.Tyre.Dry.Pressure.RR", getDeprecatedValue(settings, "Session Setup", "Race Setup"
																										 , "Tyre.Dry.Pressure.RR", 26.1)
									  , "Session.Setup.Tyre.Wet.Pressure.FL", getDeprecatedValue(settings, "Session Setup", "Race Setup"
																										 , "Tyre.Wet.Pressure.FL", 28.2)
									  , "Session.Setup.Tyre.Wet.Pressure.FR", getDeprecatedValue(settings, "Session Setup", "Race Setup"
																										 , "Tyre.Wet.Pressure.FR", 28.2)
									  , "Session.Setup.Tyre.Wet.Pressure.RL", getDeprecatedValue(settings, "Session Setup", "Race Setup"
																										 , "Tyre.Wet.Pressure.RL", 28.2)
									  , "Session.Setup.Tyre.Wet.Pressure.RR", getDeprecatedValue(settings, "Session Setup", "Race Setup"
																										 , "Tyre.Wet.Pressure.RR", 28.2)))

		if (getMultiMapValue(settings, "Session Settings", "Tyre.Compound.Usage", kUndefined) != kUndefined)
			for compound, tyreLife in string2Map(";", "->", getMultiMapValue(settings, "Session Settings", "Tyre.Compound.Usage")) {
				splitCompound(compound, &tyreCompound, &tyreCompoundColor)

				facts["Session.Settings.Tyre." . tyreCompound . "." . tyreCompoundColor . ".Laps.Max"] := tyreLife
			}

		return facts
	}

	prepareSession(&settings, &data, formationLap?) {
		local prepared := this.Prepared
		local announcements := false
		local facts := super.prepareSession(&settings, &data, formationLap?)

		if (!prepared && settings) {
			this.updateConfigurationValues({UseTalking: getMultiMapValue(settings, "Assistant.Engineer", "Voice.UseTalking", false)})

			if (this.Session = kSessionPractice)
				announcements := {FuelWarning: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Practice.LowFuel", true)
								, TyreWearWarning: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Practice.TyreWear", true)
								, BrakeWearWarning: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Practice.BrakeWear", false)
								, DamageReporting: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Practice.Damage", false)
								, DamageAnalysis: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Practice.Damage", false)
								, PressureReporting: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Practice.Pressure", true)}
			else if (this.Session = kSessionQualification)
				announcements := {FuelWarning: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Qualification.LowFuel", false)
								, TyreWearWarning: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Qualification.TyreWear", false)
								, BrakeWearWarning: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Qualification.BrakeWear", false)
								, DamageReporting: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Qualification.Damage", false)
								, DamageAnalysis: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Qualification.Damage", false)
								, PressureReporting: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Qualification.Pressure", true)}
			else if (this.Session = kSessionRace)
				announcements := {FuelWarning: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Race.LowFuel", true)
								, TyreWearWarning: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Race.TyreWear", true)
								, BrakeWearWarning: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Race.BrakeWear", true)
								, DamageReporting: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Race.Damage", true)
								, DamageAnalysis: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Race.Damage", true)
								, PressureReporting: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Race.Pressure", true)}
			else if (this.Session = kSessionTimeTrial)
				announcements := {FuelWarning: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Time Trial.LowFuel", false)
								, TyreWearWarning: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Time Trial.TyreWear", false)
								, BrakeWearWarning: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Time Trial.BrakeWear", false)
								, DamageReporting: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Time Trial.Damage", false)
								, DamageAnalysis: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Time Trial.Damage", false)
								, PressureReporting: getMultiMapValue(settings, "Assistant.Engineer", "Announcement.Time Trial.Pressure", true)}

			if announcements
				this.updateConfigurationValues({Announcements: announcements})
		}

		return facts
	}

	createFacts(settings, data) {
		local configuration := this.Configuration
		local facts := super.createFacts(settings, data)
		local simulatorName := this.SettingsDatabase.getSimulatorName(facts["Session.Simulator"])
		local mixedCompounds, index, tyre, axle

		SimulatorProvider.createSimulatorProvider(simulatorName, getMultiMapValue(data, "Session Data", "Car")
															   , getMultiMapValue(data, "Session Data", "Track")).supportsTyreManagement(&mixedCompounds)

		facts["Session.Settings.Damage.Analysis.Laps"]
			:= getMultiMapValue(configuration, "Race Engineer Analysis", simulatorName . ".DamageAnalysisLaps", 1)

		facts["Session.Settings.Tyre.Pressure.Correction.Temperature.Air"]
			:= getMultiMapValue(settings, "Session Settings", "Tyre.Pressure.Correction.Temperature.Air", -0.1)
		facts["Session.Settings.Tyre.Pressure.Correction.Temperature.Track"]
			:= getMultiMapValue(settings, "Session Settings", "Tyre.Pressure.Correction.Temperature.Track", -0.02)

		facts["Session.Setup.Tyre.Compound"]
			:= getMultiMapValue(data, "Car Data", "TyreCompound"
									, getDeprecatedValue(settings, "Session Setup", "Race Setup", "Tyre.Compound", "Dry"))
		facts["Session.Setup.Tyre.Compound.Color"]
			:= getMultiMapValue(data, "Car Data", "TyreCompoundColor"
									, getDeprecatedValue(settings, "Session Setup", "Race Setup", "Tyre.Compound.Color", "Black"))

		if (mixedCompounds = "Wheel") {
			for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
				facts["Session.Setup.Tyre.Compound." . tyre]
					:= getMultiMapValue(data, "Car Data", "TyreCompound" . tyre
											, getMultiMapValue(settings, "Session Setup", "Tyre.Compound." . tyre, facts["Session.Setup.Tyre.Compound"]))
				facts["Session.Setup.Tyre.Compound.Color." . tyre]
					:= getMultiMapValue(data, "Car Data", "TyreCompoundColor" . tyre
											, getMultiMapValue(settings, "Session Setup", "Tyre.Compound." . tyre, facts["Session.Setup.Tyre.Compound.Color"]))
			}
		}
		else if (mixedCompounds = "Axle")
			for index, axle in ["Front", "Rear"] {
				facts["Session.Setup.Tyre.Compound." . axle]
					:= getMultiMapValue(data, "Car Data", "TyreCompound" . axle
											, getMultiMapValue(settings, "Session Setup", "Tyre.Compound." . axle, facts["Session.Setup.Tyre.Compound"]))
				facts["Session.Setup.Tyre.Compound.Color." . axle]
					:= getMultiMapValue(data, "Car Data", "TyreCompoundColor" . axle
											, getMultiMapValue(settings, "Session Setup", "Tyre.Compound." . axle, facts["Session.Setup.Tyre.Compound.Color"]))
			}

		return facts
	}

	startSession(settings, data) {
		local configuration := this.Configuration
		local facts := this.prepareSession(&settings, &data, false)
		local simulatorName := this.Simulator
		local deprecated, saveSettings, speaker, strategistPlugin, strategistName, session

		deprecated := getMultiMapValue(configuration, "Race Engineer Shutdown", simulatorName . ".SaveSettings", kNever)
		saveSettings := getMultiMapValue(configuration, "Race Assistant Shutdown", simulatorName . ".SaveSettings", deprecated)

		this.updateConfigurationValues({LearningLaps: getMultiMapValue(configuration, "Race Engineer Analysis", simulatorName . ".LearningLaps", 2)
									  , AdjustLapTime: getMultiMapValue(configuration, "Race Engineer Analysis", simulatorName . ".AdjustLapTime", true)
									  , SaveSettings: saveSettings
									  , CollectTyrePressures: this.collectTyrePressures()
									  , SaveTyrePressures: getMultiMapValue(configuration, "Race Engineer Shutdown", simulatorName . ".SaveTyrePressures", kAsk)})

		this.updateDynamicValues({KnowledgeBase: this.createKnowledgeBase(facts), HasPressureData: false
								, BestLapTime: 0, OverallTime: 0
								, LastFuelAmount: 0, InitialFuelAmount: 0, LastEnergyAmount: 0, InitialEnergyAmount: 0
								, EnoughData: false})

		if this.Speaker[false] {
			speaker := this.getSpeaker()

			speaker.beginTalk()

			try {
				switch this.Session {
					case kSessionPractice:
						session := "Practice"
					case kSessionQualification:
						session := "Qualifying"
					case kSessionRace:
						session := "Race"
					case kSessionTimeTrial:
						session := "Time Trial"
					default:
						session := "Session"
				}

				speaker.speakPhrase("GreetingEngineer", {session: speaker.Fragments[session]})

				if ((this.Session = kSessionRace) && ProcessExist("Race Strategist.exe")) {
					strategistPlugin := Plugin("Race Strategist", kSimulatorConfiguration)
					strategistName := strategistPlugin.getArgumentValue("name", strategistPlugin.getArgumentValue("raceAssistantName", false))

					if strategistName {
						speaker.speakPhrase("GreetingStrategist", {strategist: strategistName, session: speaker.Fragments[session]})

						speaker.speakPhrase("CallUs", {session: speaker.Fragments[session]})
					}
					else
						speaker.speakPhrase("CallMe", {session: speaker.Fragments[session]})
				}
				else
					speaker.speakPhrase("CallMe", {session: speaker.Fragments[session]})
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
			logMessage(kLogDebug, "Finish: CollectTyrePressures is " . this.CollectTyrePressures)

			if (this.Session == kSessionRace)
				if ProcessExist("Race Strategist.exe")
					Sleep(5000)

			if (shutdown && this.Speaker[false])
				this.getSpeaker().speakPhrase("Bye")

			if (shutdown && (knowledgeBase.getValue("Lap", 0) > this.LearningLaps)) {
				this.shutdownSession("Before")

				if ProcessExist("Solo Center.exe") {
					if (this.SaveSettings = kAsk) {
						if this.Speaker[false] {
							this.getSpeaker().speakPhrase("ConfirmDataUpdate", false, true)

							this.setContinuation(ObjBindMethod(this, "shutdownSession", "After", true))

							Task.startTask(ObjBindMethod(this, "forceFinishSession"), 120000, kLowPriority)

							return
						}
					}
				}
				else {
					if (((this.SaveTyrePressures = kAsk) && this.CollectTyrePressures && this.HasPressureData) || (this.SaveSettings = kAsk)) {
						if this.Speaker[false] {
							this.getSpeaker().speakPhrase("ConfirmDataUpdate", false, true)

							this.setContinuation(ObjBindMethod(this, "shutdownSession", "After", true))

							Task.startTask(ObjBindMethod(this, "forceFinishSession"), 120000, kLowPriority)

							return
						}
					}
				}

				this.shutdownSession("After")
			}

			this.updateDynamicValues({KnowledgeBase: false, Prepared: false})
		}

		this.updateDynamicValues({BestLapTime: 0, OverallTime: 0
								, LastFuelAmount: 0, InitialFuelAmount: 0, LastEnergyAmount: 0, InitialEnergyAmount: 0
								, EnoughData: false, HasPressureData: false})
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

	shutdownSession(phase, confirmed := false) {
		local pressuresSaved := false

		this.iSessionDataActive := true

		try {
			if ((phase = "Before") && this.CollectSessionKnowledge)
				this.saveSessionKnowledge("Finish")

			if (((phase = "After") && (this.SaveSettings = kAsk) && confirmed) || ((phase = "Before") && (this.SaveSettings = kAlways)))
				if (this.Session == kSessionRace)
					this.saveSessionSettings()

			if (((phase = "After") && (this.SaveTyrePressures = kAsk) && confirmed) || ((phase = "Before") && (this.SaveTyrePressures = kAlways)))
				if (this.HasPressureData && this.CollectTyrePressures && !ProcessExist("Solo Center.exe")) {
					this.updateTyresDatabase()

					pressuresSaved := true
				}
		}
		finally {
			this.iSessionDataActive := false
		}

		if (phase = "After") {
			if (this.Speaker[false] && pressuresSaved)
				this.getSpeaker().speakPhrase("DataUpdated")

			this.updateDynamicValues({KnowledgeBase: false})

			this.finishSession()
		}
	}

	prepareData(lapNumber, data) {
		local knowledgeBase, bodyworkDamage, suspensionDamage

		data := super.prepareData(lapNumber, data)

		knowledgeBase := this.KnowledgeBase

		if (knowledgeBase.getValue("Lap", false) != lapNumber) {
			bodyworkDamage := string2Values(",", getMultiMapValue(data, "Car Data", "BodyworkDamage", ""))

			knowledgeBase.setFact("Lap." . lapNumber . ".Damage.Bodywork.Front", Round(bodyworkDamage[1], 2))
			knowledgeBase.setFact("Lap." . lapNumber . ".Damage.Bodywork.Rear", Round(bodyworkDamage[2], 2))
			knowledgeBase.setFact("Lap." . lapNumber . ".Damage.Bodywork.Left", Round(bodyworkDamage[3], 2))
			knowledgeBase.setFact("Lap." . lapNumber . ".Damage.Bodywork.Right", Round(bodyworkDamage[4], 2))
			knowledgeBase.setFact("Lap." . lapNumber . ".Damage.Bodywork.Center", Round(bodyworkDamage[5], 2))

			suspensionDamage := string2Values(",", getMultiMapValue(data, "Car Data", "SuspensionDamage", ""))

			knowledgeBase.setFact("Lap." . lapNumber . ".Damage.Suspension.FL", Round(suspensionDamage[1], 2))
			knowledgeBase.setFact("Lap." . lapNumber . ".Damage.Suspension.FR", Round(suspensionDamage[2], 2))
			knowledgeBase.setFact("Lap." . lapNumber . ".Damage.Suspension.RL", Round(suspensionDamage[3], 2))
			knowledgeBase.setFact("Lap." . lapNumber . ".Damage.Suspension.RR", Round(suspensionDamage[4], 2))

			knowledgeBase.setFact("Lap." . lapNumber . ".Damage.Engine"
								, Round(getMultiMapValue(data, "Car Data", "EngineDamage", 0), 1))
		}

		return data
	}

	createSessionInfo(simulator, car, track, lapNumber, valid, data, pitstopHistory) {
		local knowledgeBase := this.KnowledgeBase
		local sessionInfo := super.createSessionInfo(simulator, car, track, lapNumber, valid, data)
		local lastPitstop := knowledgeBase.getValue("Pitstop.Last", false)
		local tyreChange := false
		local tyreLaps := false
		local planned, prepared, tyreCompound, lap
		local bodyworkDamage, suspensionDamage, index, position, defaultTyreCompound, defaultTyreCompoundColor
		local fuelService, tyreService, brakeService, repairService, index, tyre, axle
		local ignore, pitstop, stintLaps

		if knowledgeBase {
			this.Provider.supportsPitstop(&fuelService, &tyreService, &brakeService, &repairService)
			this.Provider.supportsTyreManagement( , &tyreSet)

			if fuelService
				setMultiMapValue(sessionInfo, "Pitstop", "Target.Fuel.Amount", knowledgeBase.getValue("Fuel.Amount.Target", 0))

			if knowledgeBase.getValue("Tyre.Compound.Target", false) {
				defaultTyreCompound := knowledgeBase.getValue("Tyre.Compound.Target")
				defaultTyreCompoundColor := knowledgeBase.getValue("Tyre.Compound.Color.Target", "Black")
			}
			else {
				defaultTyreCompound := "-"
				defaultTyreCompoundColor := "-"
			}

			setMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Compound", defaultTyreCompound)
			setMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Compound.Color", defaultTyreCompoundColor)

			if (tyreService = "Wheel") {
				for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
					tyreCompound := knowledgeBase.getValue("Tyre.Compound.Target." . tyre, defaultTyreCompound)

					if (tyreCompound && (tyreCompound != "-")) {
						setMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Compound." . tyre, tyreCompound)
						setMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Compound.Color." . tyre
													, knowledgeBase.getValue("Tyre.Compound.Color.Target." . tyre, defaultTyreCompoundColor))

						tyreChange := true
					}
					else {
						setMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Compound." . tyre, "-")
						setMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Compound.Color." . tyre
													, knowledgeBase.getValue("Tyre.Compound.Color.Target." . tyre, "-"))
					}
				}
			}
			else if (tyreService = "Axle") {
				for index, axle in ["Front", "Rear"] {
					tyreCompound := knowledgeBase.getValue("Tyre.Compound.Target." . axle, defaultTyreCompound)

					if (tyreCompound && (tyreCompound != "-")) {
						setMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Compound." . axle, tyreCompound)
						setMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Compound.Color." . axle
													, knowledgeBase.getValue("Tyre.Compound.Color.Target." . axle, defaultTyreCompoundColor))

						tyreChange := true
					}
					else {
						setMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Compound." . axle, "-")
						setMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Compound.Color." . axle
													, knowledgeBase.getValue("Tyre.Compound.Color.Target." . axle, "-"))
					}
				}
			}
			else
				tyreChange := (defaultTyreCompound != "-")

			if tyreChange {
				setMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Pressure.FL", Round(knowledgeBase.getValue("Tyre.Pressure.Target.FL", 0), 1))
				setMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Pressure.FR", Round(knowledgeBase.getValue("Tyre.Pressure.Target.FR", 0), 1))
				setMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Pressure.RL", Round(knowledgeBase.getValue("Tyre.Pressure.Target.RL", 0), 1))
				setMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Pressure.RR", Round(knowledgeBase.getValue("Tyre.Pressure.Target.RR", 0), 1))
				setMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Pressure.FL.Increment", Round(knowledgeBase.getValue("Tyre.Pressure.Target.FL.Increment", 0), 1))
				setMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Pressure.FR.Increment", Round(knowledgeBase.getValue("Tyre.Pressure.Target.FR.Increment", 0), 1))
				setMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Pressure.RL.Increment", Round(knowledgeBase.getValue("Tyre.Pressure.Target.RL.Increment", 0), 1))
				setMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Pressure.RR.Increment", Round(knowledgeBase.getValue("Tyre.Pressure.Target.RR.Increment", 0), 1))

				if tyreSet
					setMultiMapValue(sessionInfo, "Pitstop", "Target.Tyre.Set", knowledgeBase.getValue("Tyre.Set.Target", 0))
			}

			if brakeService
				setMultiMapValue(sessionInfo, "Pitstop", "Target.Brake.Change", knowledgeBase.getValue("Brake.Change.Target", false))

			setMultiMapValue(sessionInfo, "Pitstop", "Target.Time.Box", Round(knowledgeBase.getValue("Target.Time.Box", 0) / 1000))
			setMultiMapValue(sessionInfo, "Pitstop", "Target.Time.Pitlane", Round(knowledgeBase.getValue("Target.Time.Pitlane", 0) / 1000))
			setMultiMapValue(sessionInfo, "Pitstop", "Target.Time.Service", Round(knowledgeBase.getValue("Target.Time.Service", 0) / 1000))

			if (repairService.Length > 0)
				setMultiMapValue(sessionInfo, "Pitstop", "Target.Time.Repairs", Round(knowledgeBase.getValue("Target.Time.Repairs", 0) / 1000))

			planned := this.hasPlannedPitstop()
			prepared := this.hasPreparedPitstop()

			if (planned || prepared) {
				lap := knowledgeBase.getValue("Pitstop.Planned.Lap", false)

				if lap
					lap += 1

				setMultiMapValue(sessionInfo, "Pitstop", "Planned.Nr", knowledgeBase.getValue("Pitstop.Planned.Nr"))
				setMultiMapValue(sessionInfo, "Pitstop", "Planned.Lap", lap)

				setMultiMapValue(sessionInfo, "Pitstop", "Planned.Time.Box", Round(knowledgeBase.getValue("Pitstop.Planned.Time.Box", 0) / 1000))
				setMultiMapValue(sessionInfo, "Pitstop", "Planned.Time.Pitlane", Round(knowledgeBase.getValue("Pitstop.Planned.Time.Pitlane", 0) / 1000))
				setMultiMapValue(sessionInfo, "Pitstop", "Planned.Time.Service", Round(knowledgeBase.getValue("Pitstop.Planned.Time.Service", 0) / 1000))

				if (repairService.Length > 0)
					setMultiMapValue(sessionInfo, "Pitstop", "Planned.Time.Repairs", Round(knowledgeBase.getValue("Pitstop.Planned.Time.Repairs", 0) / 1000))

				if knowledgeBase.getValue("Pitstop.Planned.Driver.Request", false)
					setMultiMapValue(sessionInfo, "Pitstop", "Planned.Driver.Request", knowledgeBase.getValue("Pitstop.Planned.Driver.Request", false))

				if fuelService
					setMultiMapValue(sessionInfo, "Pitstop", "Planned.Refuel", knowledgeBase.getValue("Pitstop.Planned.Fuel", 0))

				if knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound", false) {
					defaultTyreCompound := knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound")
					defaultTyreCompoundColor := knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound.Color", "Black")
				}
				else {
					defaultTyreCompound := "-"
					defaultTyreCompoundColor := "-"
				}

				setMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Compound", defaultTyreCompound)
				setMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Compound.Color", defaultTyreCompoundColor)

				tyreChange := false

				if (tyreService = "Wheel") {
					for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
						tyreCompound := knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound." . tyre, defaultTyreCompound)

						if (tyreCompound && (tyreCompound != "-")) {
							setMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Compound." . tyre, tyreCompound)
							setMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Compound.Color." . tyre
														, knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound.Color." . tyre, defaultTyreCompoundColor))

							tyreChange := true
						}
						else {
							setMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Compound." . tyre, "-")
							setMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Compound.Color." . tyre
														, knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound.Color." . tyre, "-"))
						}
					}
				}
				else if (tyreService = "Axle") {
					for index, axle in ["Front", "Rear"] {
						tyreCompound := knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound." . axle, defaultTyreCompound)

						if (tyreCompound && (tyreCompound != "-")) {
							setMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Compound." . axle, tyreCompound)
							setMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Compound.Color." . axle
														, knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound.Color." . axle, defaultTyreCompoundColor))

							tyreChange := true
						}
						else {
							setMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Compound." . axle, "-")
							setMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Compound.Color." . axle
														, knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound.Color." . axle, "-"))
						}
					}
				}
				else
					tyreChange := (defaultTyreCompound != "-")

				if tyreChange {
					if tyreSet
						setMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Set", knowledgeBase.getValue("Pitstop.Planned.Tyre.Set", 0))

					setMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.FL", Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FL", 0), 1))
					setMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.FR", Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FR", 0), 1))
					setMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.RL", Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RL", 0), 1))
					setMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.RR", Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RR", 0), 1))

					setMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.FL.Increment", Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FL.Increment", 0), 1))
					setMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.FR.Increment", Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FR.Increment", 0), 1))
					setMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.RL.Increment", Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RL.Increment", 0), 1))
					setMultiMapValue(sessionInfo, "Pitstop", "Planned.Tyre.Pressure.RR.Increment", Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RR.Increment", 0), 1))
				}

				if brakeService
					setMultiMapValue(sessionInfo, "Pitstop", "Planned.Brake.Change", knowledgeBase.getValue("Pitstop.Planned.Brake.Change", false))

				if inList(repairService, "Bodywork")
					setMultiMapValue(sessionInfo, "Pitstop", "Planned.Repair.Bodywork", knowledgeBase.getValue("Pitstop.Planned.Repair.Bodywork", false))

				if inList(repairService, "Suspension")
					setMultiMapValue(sessionInfo, "Pitstop", "Planned.Repair.Suspension", knowledgeBase.getValue("Pitstop.Planned.Repair.Suspension", false))

				if inList(repairService, "Engine")
					setMultiMapValue(sessionInfo, "Pitstop", "Planned.Repair.Engine", knowledgeBase.getValue("Pitstop.Planned.Repair.Engine", false))

				setMultiMapValue(sessionInfo, "Pitstop", "Prepared", prepared && !planned)
			}

			setMultiMapValue(sessionInfo, "Tyres", "Pressures.Cold", values2String(", ", knowledgeBase.getValue("Tyre.Pressure.Target.FL", 0)
																					   , knowledgeBase.getValue("Tyre.Pressure.Target.FR", 0)
																					   , knowledgeBase.getValue("Tyre.Pressure.Target.RL", 0)
																					   , knowledgeBase.getValue("Tyre.Pressure.Target.RR", 0)))

			setMultiMapValue(sessionInfo, "Tyres", "Pressures.Loss", values2String(", ", knowledgeBase.getValue("Tyre.Pressure.Loss.FL", 0)
																					   , knowledgeBase.getValue("Tyre.Pressure.Loss.FR", 0)
																					   , knowledgeBase.getValue("Tyre.Pressure.Loss.RL", 0)
																					   , knowledgeBase.getValue("Tyre.Pressure.Loss.RR", 0)))

			if lastPitstop {
				if (getMultiMapValue(pitstopHistory, "Pitstops", lastPitstop . ".Lap", kUndefined) != kUndefined) {
					stintLaps := (lapNumber - (knowledgeBase.getValue("Pitstop." . lastPitstop . ".Lap")))

					setMultiMapValue(sessionInfo, "Tyres", "Laps"
												, values2String(",", getMultiMapValue(pitstopHistory, "Pitstops", lastPitstop . ".TyreLapsFrontLeft") + stintLaps
																   , getMultiMapValue(pitstopHistory, "Pitstops", lastPitstop . ".TyreLapsFrontRight") + stintLaps
																   , getMultiMapValue(pitstopHistory, "Pitstops", lastPitstop . ".TyreLapsRearLeft") + stintLaps
																   , getMultiMapValue(pitstopHistory, "Pitstops", lastPitstop . ".TyreLapsRearRight") + stintLaps))
				}
				else
					setMultiMapValue(sessionInfo, "Tyres", "Laps", values2String(",", lapNumber, lapNumber, lapNumber, lapNumber))
			}
			else
				setMultiMapValue(sessionInfo, "Tyres", "Laps", values2String(",", lapNumber, lapNumber, lapNumber, lapNumber))

			if data {
				bodyworkDamage := string2Values(",", getMultiMapValue(data, "Car Data", "BodyworkDamage", ""))
				suspensionDamage := string2Values(",", getMultiMapValue(data, "Car Data", "SuspensionDamage", ""))

				if (bodyWorkDamage.Length >= 5)
					for index, position in ["Front", "Rear", "Left", "Right", "Center"] {
						if (position = "Center")
							position := "All"

						setMultiMapValue(sessionInfo, "Damage", "Bodywork." . position, Round(bodyworkDamage[index], 2))
					}

				if (suspensionDamage.Length >= 4)
					for index, position in ["FL", "FR", "RL", "RR"]
						setMultiMapValue(sessionInfo, "Damage", "Suspension." . position, Round(suspensionDamage[index], 2))

				if (getMultiMapValue(data, "Car Data", "EngineDamage", kUndefined) != kUndefined)
					setMultiMapValue(sessionInfo, "Damage", "Engine", Round(getMultiMapValue(data, "Car Data", "EngineDamage"), 2))

				setMultiMapValue(sessionInfo, "Damage", "Lap.Delta", Round(Max(knowledgeBase.getValue("Damage.Bodywork.Lap.Delta", 0)
																			 , knowledgeBase.getValue("Damage.Suspension.Lap.Delta", 0)
																			 , knowledgeBase.getValue("Damage.Engine.Lap.Delta", 0)), 1))

				setMultiMapValue(sessionInfo, "Damage", "Time.Repairs", Round(knowledgeBase.getValue("Target.Time.Repairs", 0) / 1000))
			}
		}

		return sessionInfo
	}

	updateTyreUsage(tyreSets) {
		local knowledgeBase := this.KnowledgeBase
		local ignore, tyreSet

		for ignore, tyreSet in string2Values("|", tyreSets) {
			tyreSet := string2Values("#", tyreSet)

			knowledgeBase.setFact("Session.Settings.Tyre." . tyreSet[1] . "." . tyreSet[2] . ".Laps.Max", tyreSet[4])
		}
	}

	updateRaceRules(raceRules) {
		local knowledgeBase := this.KnowledgeBase

		if !isObject(raceRules)
			try {
				raceRules := JSON.parse(FileRead(raceRules))

				deleteFile(raceRules)
			}
			catch Any {
				raceRules := false
			}

		this.iRaceRules := raceRules
	}

	updateSession(simulator, car, track, lapNumber, data) {
		local knowledgeBase := this.KnowledgeBase
		local lastPitstop

		static lastLap := 0
		static pitstopHistory := false

		if knowledgeBase {
			if (lapNumber != lastLap) {
				pitstopHistory := this.createPitstopHistory()

				lastLap := lapNumber

				lastPitstop := getMultiMapValue(pitstopHistory, "Pitstops", "Count", false)

				if lastPitstop {
					knowledgeBase.setFact("Tyre.FL.Laps", getMultiMapValue(pitstopHistory, "Pitstops", lastPitstop . ".TyreLapsFrontLeft"))
					knowledgeBase.setFact("Tyre.FR.Laps", getMultiMapValue(pitstopHistory, "Pitstops", lastPitstop . ".TyreLapsFrontRight"))
					knowledgeBase.setFact("Tyre.RL.Laps", getMultiMapValue(pitstopHistory, "Pitstops", lastPitstop . ".TyreLapsRearLeft"))
					knowledgeBase.setFact("Tyre.RR.Laps", getMultiMapValue(pitstopHistory, "Pitstops", lastPitstop . ".TyreLapsRearRight"))
				}
				else {
					knowledgeBase.setFact("Tyre.FL.Laps", lapNumber)
					knowledgeBase.setFact("Tyre.FR.Laps", lapNumber)
					knowledgeBase.setFact("Tyre.RL.Laps", lapNumber)
					knowledgeBase.setFact("Tyre.RR.Laps", lapNumber)
				}
			}
			else {
				setMultiMapValue(pitstopHistory, "Pitstops", "Count", 0)
			}

			this.saveSessionInfo(simulator, car, track, lapNumber
							   , this.createSessionInfo(simulator, car, track
													  , lapNumber, knowledgeBase.getValue("Lap." . lapNumber . ".Valid", true)
													  , data, pitstopHistory))
		}
	}

	addLap(lapNumber, &data) {
		local knowledgeBase := this.KnowledgeBase
		local driverForname := ""
		local driverSurname := ""
		local driverNickname := ""
		local result, currentCompound, currentCompoundColor, targetCompound, targetCompoundColor, prefix
		local coldPressures, hotPressures, pressuresLosses, airTemperature, trackTemperature, weatherNow
		local pitstopState, stateFile, key, value, learningLaps
		local simulator, car, track

		static lastLap := 0

		if (lapNumber <= lastLap)
			lastLap := 0
		else if ((lastLap == 0) && (lapNumber > 1))
			lastLap := (lapNumber - 1)

		if (knowledgeBase && (lapNumber > 1)) {
			driverForname := knowledgeBase.getValue("Driver.Forname", "John")
			driverSurname := knowledgeBase.getValue("Driver.Surname", "Doe")
			driverNickname := knowledgeBase.getValue("Driver.Nickname", "JD")
		}

		if (knowledgeBase && data.Has("Setup Data"))
			if getMultiMapValue(data, "Setup Data", "ServiceTime", false)
				knowledgeBase.setFact("Target.Time.Box.Fixed", Round(getMultiMapValue(data, "Setup Data", "ServiceTime") * 1000))
			else
				knowledgeBase.clearFact("Target.Time.Box.Fixed")

		result := super.addLap(lapNumber, &data)

		knowledgeBase := this.KnowledgeBase
		learningLaps := knowledgeBase.getValue("Session.Settings.Lap.Learning.Laps", 2)

		if (result && ((lapNumber <= learningLaps) || !this.TeamSession || (lapNumber >= (this.BaseLap + learningLaps)))) {
			if (this.hasPreparedPitstop() && getMultiMapValues(data, "Setup Data", false))
				this.updatePitstop(data)

			if (this.RemoteHandler && knowledgeBase.getValue("Pitstop.Planned.Nr", false)) {
				pitstopState := newMultiMap()

				for key, value in this.KnowledgeBase.Facts.Facts
					if (InStr(key, "Pitstop") = 1)
						setMultiMapValue(pitstopState, "Pitstop Pending", key, value)

				setMultiMapValue(pitstopState, "Pitstop Pending", "Target.Time.Repairs", Round(knowledgeBase.getValue("Target.Time.Repairs", 0) / 1000))

				setMultiMapValues(pitstopState, "Pitstop Pending", getMultiMapValues(data, "Setup Data"), false)

				stateFile := temporaryFileName(this.AssistantType . " Pitstop Pending", "state")

				writeMultiMap(stateFile, pitstopState)

				this.RemoteHandler.saveLapState(lapNumber, stateFile)
			}
		}

		if ((lastLap < (lapNumber - 2)) && (driverName(driverForname, driverSurname, driverNickname) != this.DriverFullName)) {
			this.iPitstopAdjustments := false
			this.iPitstopFillUp := false

			if this.Speaker[false]
				this.getSpeaker().speakPhrase("WelcomeBack")
		}

		lastLap := lapNumber

		simulator := knowledgeBase.getValue("Session.Simulator")
		car := knowledgeBase.getValue("Session.Car")
		track := knowledgeBase.getValue("Session.Track")

		this.iCurrentTyrePressures := [knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Pressure.FL")
									 , knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Pressure.FR")
									 , knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Pressure.RL")
									 , knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Pressure.RR")]
		this.iCurrentTyreTemperatures := [knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Temperature.FL")
										, knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Temperature.FR")
										, knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Temperature.RL")
										, knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Temperature.RR")]

		if (knowledgeBase.getValue("Lap." . lapNumber . ".Brake.Temperature.FL", kUndefined) != kUndefined)
			this.iCurrentBrakeTemperatures := [knowledgeBase.getValue("Lap." . lapNumber . ".Brake.Temperature.FL")
											 , knowledgeBase.getValue("Lap." . lapNumber . ".Brake.Temperature.FR")
											 , knowledgeBase.getValue("Lap." . lapNumber . ".Brake.Temperature.RL")
											 , knowledgeBase.getValue("Lap." . lapNumber . ".Brake.Temperature.RR")]
		else
			this.iCurrentBrakeTemperatures := false

		this.iCurrentRemainingFuel := knowledgeBase.getValue("Lap." . lapNumber . ".Fuel.Remaining")

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

			if currentCompound {
				if (lapNumber <= (((this.Session = kSessionRace) ? 0 : this.BaseLap) + learningLaps)) {
					if (currentCompound = "Dry")
						prefix := "Session.Setup.Tyre.Dry.Pressure."
					else
						prefix := "Session.Setup.Tyre.Wet.Pressure."
				}
				else if this.hasEnoughData(false)
					prefix := "Tyre.Pressure.Target."
				else
					prefix := false

				if prefix
					try {
						if ((currentCompound = targetCompound) && (currentCompoundColor = targetCompoundColor))
							coldPressures := values2String(",", Round(knowledgeBase.getValue(prefix . "FL"), 1)
															  , Round(knowledgeBase.getValue(prefix . "FR"), 1)
															  , Round(knowledgeBase.getValue(prefix . "RL"), 1)
															  , Round(knowledgeBase.getValue(prefix . "RR"), 1))
						else
							coldPressures := values2String(",", kNull, kNull, kNull, kNull)

						hotPressures := values2String(",", Round(knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Pressure.FL"), 1)
														 , Round(knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Pressure.FR"), 1)
														 , Round(knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Pressure.RL"), 1)
														 , Round(knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Pressure.RR"), 1))

						prefix := "Tyre.Pressure.Loss."

						if ((currentCompound = targetCompound) && (currentCompoundColor = targetCompoundColor))
							pressuresLosses := values2String(",", Round(knowledgeBase.getValue(prefix . "FL", 0), 1)
																, Round(knowledgeBase.getValue(prefix . "FR", 0), 1)
																, Round(knowledgeBase.getValue(prefix . "RL", 0), 1)
																, Round(knowledgeBase.getValue(prefix . "RR", 0), 1))
						else
							pressuresLosses := values2String(",", kNull, kNull, kNull, kNull)

						airTemperature := Round(getMultiMapValue(data, "Weather Data", "Temperature", 0))
						trackTemperature := Round(getMultiMapValue(data, "Track Data", "Temperature", 0))

						if (airTemperature = 0)
							airTemperature := Round(getMultiMapValue(data, "Car Data", "AirTemperature", 0))

						if (trackTemperature = 0)
							trackTemperature := Round(getMultiMapValue(data, "Car Data", "RoadTemperature", 0))

						weatherNow := getMultiMapValue(data, "Weather Data", "Weather", "Dry")

						logMessage(kLogDebug, "Saving pressures for " . lapNumber)

						this.savePressureData(lapNumber, simulator, car, track, weatherNow, airTemperature, trackTemperature
													   , currentCompound, currentCompoundColor, coldPressures, hotPressures, pressuresLosses)
					}
					catch Any as exception {
						logError(exception)
					}
			}
		}

		Task.startTask((*) => this.updateSession(simulator, car, track, lapNumber, data), 1000, kLowPriority)

		return result
	}

	updateLap(lapNumber, &data) {
		local knowledgeBase := this.KnowledgeBase
		local result := super.updateLap(lapNumber, &data)
		local needProduce := false
		local tyrePressures := string2Values(",", getMultiMapValue(data, "Car Data", "TyrePressure", ""))
		local tyreTemperatures := string2Values(",", getMultiMapValue(data, "Car Data", "TyreTemperature", ""))
		local bodyworkDamage := string2Values(",", getMultiMapValue(data, "Car Data", "BodyworkDamage", ""))
		local suspensionDamage := string2Values(",", getMultiMapValue(data, "Car Data", "SuspensionDamage", ""))
		local threshold := knowledgeBase.getValue("Session.Settings.Tyre.Pressure.Deviation")
		local changed := false
		local fact, index, tyreType, oldValue, newValue, position, learningLaps
		local simulator, car, track
		local pitstopState, key, value, stateFile

		this.iCurrentTyrePressures := tyrePressures
		this.iCurrentTyreTemperatures := tyreTemperatures

		if (getMultiMapValue(data, "Car Data", "BrakeTemperatures", kUndefined) != kUndefined)
			this.iCurrentBrakeTemperatures := string2Values(",", getMultiMapValue(data, "Car Data", "BrakeTemperatures"))
		else
			this.iCurrentBrakeTemperatures := false

		this.iCurrentRemainingFuel := getMultiMapValue(data, "Car Data", "FuelRemaining", 0)

		if data.Has("Setup Data")
			if getMultiMapValue(data, "Setup Data", "ServiceTime", false)
				knowledgeBase.setFact("Target.Time.Box.Fixed", Round(getMultiMapValue(data, "Setup Data", "ServiceTime") * 1000))
			else
				knowledgeBase.clearFact("Target.Time.Box.Fixed")

		if (tyrePressures.Length >= 4) {
			for index, tyreType in ["FL", "FR", "RL", "RR"] {
				newValue := Round(tyrePressures[index], 2)
				fact := ("Lap." . lapNumber . ".Tyre.Pressure." . tyreType)
				oldValue := knowledgeBase.getValue(fact, false)

				if (isNumber(oldValue) && oldValue && (Abs(oldValue - newValue) > threshold)) {
					knowledgeBase.setValue(fact, newValue)

					changed := true
				}
			}

			if changed {
				knowledgeBase.addFact("Tyre.Update.Pressure", true)

				needProduce := true
			}
		}

		if (tyreTemperatures.Length >= 4)
			for index, tyreType in ["FL", "FR", "RL", "RR"]
				knowledgeBase.setFact("Lap." . lapNumber . ".Tyre.Temperature." . tyreType, Round(tyreTemperatures[index], 2))

		if (bodyWorkDamage.Length >= 5) {
			changed := false

			for index, position in ["Front", "Rear", "Left", "Right", "Center"] {
				newValue := Round(bodyworkDamage[index], 2)
				fact := ("Lap." . lapNumber . ".Damage.Bodywork." . position)
				oldValue := knowledgeBase.getValue(fact, 0)

				if (isNumber(oldValue) && (oldValue < newValue)) {
					knowledgeBase.setFact(fact, newValue)

					changed := true
				}
			}

			if changed {
				knowledgeBase.addFact("Damage.Update.Bodywork", lapNumber)

				needProduce := true
			}
		}

		if (suspensionDamage.Length >= 4) {
			changed := false

			for index, position in ["FL", "FR", "RL", "RR"] {
				newValue := Round(suspensionDamage[index], 2)
				fact := ("Lap." . lapNumber . ".Damage.Suspension." . position)
				oldValue := knowledgeBase.getValue(fact, 0)

				if (isNumber(oldValue) && (oldValue < newValue)) {
					knowledgeBase.setFact(fact, newValue)

					changed := true
				}
			}

			if changed {
				knowledgeBase.addFact("Damage.Update.Suspension", lapNumber)

				needProduce := true
			}
		}

		newValue := Round(getMultiMapValue(data, "Car Data", "EngineDamage", 0), 1)
		fact := ("Lap." . lapNumber . ".Damage.Engine")
		oldValue := knowledgeBase.getValue(fact, 0)

		if (isNumber(oldValue) && (oldValue < newValue)) {
			knowledgeBase.setFact(fact, newValue)

			knowledgeBase.addFact("Damage.Update.Engine", lapNumber)

			needProduce := true
		}

		learningLaps := knowledgeBase.getValue("Session.Settings.Lap.Learning.Laps", 2)

		if (this.hasPreparedPitstop() && getMultiMapValues(data, "Setup Data", false)) {
			if ((lapNumber <= learningLaps) || !this.TeamSession || (lapNumber >= (this.BaseLap + learningLaps)))
				this.updatePitstop(data)

			if (this.RemoteHandler && knowledgeBase.getValue("Pitstop.Planned.Nr", false)) {
				pitstopState := newMultiMap()

				for key, value in this.KnowledgeBase.Facts.Facts
					if (InStr(key, "Pitstop") = 1)
						setMultiMapValue(pitstopState, "Pitstop Pending", key, value)

				setMultiMapValues(pitstopState, "Pitstop Pending", getMultiMapValues(data, "Setup Data"), false)

				stateFile := temporaryFileName(this.AssistantType . " Pitstop Pending", "state")

				writeMultiMap(stateFile, pitstopState)

				this.RemoteHandler.saveLapState(lapNumber, stateFile)
			}
		}

		if needProduce {
			if knowledgeBase.produce()
				result := true

			if this.Debug[kDebugKnowledgeBase]
				this.dumpKnowledgeBase(this.KnowledgeBase)
		}

		simulator := knowledgeBase.getValue("Session.Simulator")
		car := knowledgeBase.getValue("Session.Car")
		track := knowledgeBase.getValue("Session.Track")

		Task.startTask((*) => this.updateSession(simulator, car, track, lapNumber, data), 1000, kLowPriority)

		return result
	}

	savePressureData(lapNumber, simulator, car, track, weather, airTemperature, trackTemperature
				   , compound, compoundColor, coldPressures, hotPressures, pressuresLosses) {
		this.iSessionDataActive := true

		try {
			if (this.RemoteHandler && this.CollectTyrePressures) {
				this.updateDynamicValues({HasPressureData: true})

				this.RemoteHandler.savePressureData(lapNumber, simulator, car, track, weather, airTemperature, trackTemperature
												  , compound, compoundColor, coldPressures, hotPressures, pressuresLosses)
			}
		}
		finally {
			this.iSessionDataActive := false
		}
	}

	createSessionKnowledge(lapNumber) {
		return this.getKnowledge("Agent")
	}

	updateTyresDatabase() {
		if (this.RemoteHandler && this.CollectTyrePressures)
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
		local provider := this.Provider

		if (provider && !this.Provider.supportsPitstop())
			return false

		if this.RemoteHandler {
			switch this.Session {
				case kSessionPractice:
					return getMultiMapValue(this.Settings, "Session Settings", "Pitstop.Practice", false)
				case kSessionQualification:
					return getMultiMapValue(this.Settings, "Session Settings", "Pitstop.Qualification", false)
				case kSessionRace:
					return getMultiMapValue(this.Settings, "Session Settings", "Pitstop.Race", true)
				case kSessionTimeTrial:
					return getMultiMapValue(this.Settings, "Session Settings", "Pitstop.Time Trial", false)
				default:
					return false
			}
		}
		else
			return false
	}

	optimizeFuelRatio(safetyFuel?) {
		local knowledgeBase := this.KnowledgeBase

		if this.hasEnoughData()
			if (this.Simulator = "Le Mans Ultimate") {
				if this.Speaker
					this.getSpeaker().speakPhrase("Roger")

				if this.RemoteHandler {
					if !isSet(safetyFuel)
						safetyFuel := knowledgeBase.getValue("Session.Settings.Fuel.SafetyMargin", 4)

					this.RemoteHandler.optimizeFuelRatio(safetyFuel)
				}
			}
			else if this.Speaker
				this.getSpeaker().speakPhrase("Repeat")
	}

	proposePitstop(lap := kUndefined, refuelAmount := kUndefined, tyreChange := kUndefined, repairs := kUndefined) {
		if (this.AgentBooster && this.handledEvent("PlanPitstop") && this.findAction("plan_pitstop"))
			this.handleEvent("PlanPitstop", lap, refuelAmount, tyreChange, repairs)
		else
			this.planPitstop(lap, refuelAmount, tyreChange, kUndefined, kUndefined, kUndefined, kUndefined
								, repairs, repairs, repairs)
	}

	planPitstop(optionsOrLap := kUndefined, refuelAmount := kUndefined
			  , changeTyres := kUndefined, tyreSet := kUndefined
			  , tyreCompound := kUndefined, tyreCompoundColor := kUndefined, tyrePressures := kUndefined
			  , repairBodywork := kUndefined, repairSuspension := kUndefined, repairEngine := kUndefined
			  , requestDriver := kUndefined, changeBrakes := kUndefined) {
		local knowledgeBase := this.KnowledgeBase
		local lapNr := knowledgeBase.getValue("Lap")
		local confirm := true
		local options := ((optionsOrLap = kUndefined) ? true : optionsOrLap)
		local plannedLap := false
		local force := false
		local forceRefuel := false
		local forceTyreChange := false
		local processedTyres := false
		local result, pitstopNumber, speaker, fragments, fuel, lap, correctedFuel, targetFuel, pressure
		local pressureFL, pressureFR, pressureRL, pressureRR
		local correctedTyres, theCompound, theCompoundColor, compoundName
		local incrementFL, incrementFR, incrementRL, incrementRR, pressureCorrection
		local temperatureDelta, debug, tyre, tyreType, lostPressure, deviationThreshold, ignore, suffix
		local tyreService, tyreSets, index, tyre, axle, processed

		this.clearContinuation()

		if (optionsOrLap = "Now") {
			optionsOrLap := kUndefined
			options := true

			force := true
		}
		else if (optionsOrLap != kUndefined) {
			if (!isObject(optionsOrLap) && (InStr(optionsOrLap, "!") = 1))
				optionsOrLap := SubStr(optionsOrLap, 2)

			if isNumber(optionsOrLap) {
				options := true

				if (optionsOrLap != false)
					plannedLap := Max(optionsOrLap, knowledgeBase.getValue("Lap") + 1)
			}
			else if (isObject(optionsOrLap) && optionsOrLap.HasProp("Confirm"))
				confirm := optionsOrLap.Confirm
		}

		if (!force && !plannedLap)
			if !this.hasEnoughData()
				return false

		this.Provider.supportsTyreManagement( , &tyreSets)

		if !this.Provider.supportsPitstop( , &tyreService) {
			if this.Speaker
				this.getSpeaker().speakPhrase("NoPitstop")

			return false
		}

		knowledgeBase.addFact("Pitstop.Plan", ((options == true) || !options.HasProp("Update") || !options.Update) ? true : false)

		correctedFuel := false

		if (refuelAmount != kUndefined) {
			if (InStr(refuelAmount, "!") = 1) {
				knowledgeBase.addFact("Pitstop.Plan.Fuel.Amount", SubStr(refuelAmount, 2) + 0)

				forceRefuel := true
			}
			else {
				targetFuel := knowledgeBase.getValue("Fuel.Amount.Target", false)

				if (targetFuel && (targetFuel != refuelAmount)) {
					if ((knowledgeBase.getValue("Lap." . lapNr . ".Fuel.Remaining") + targetFuel)
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

				forceTyreChange := true
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

				if ((tyreCompound != kUndefined) && !isObject(tyreCompound)) {
					tyreCompound := collect(string2Values(",", tyreCompound), (c) => ((c = "-") ? false : c))
					tyreCompoundColor := collect(string2Values(",", tyreCompoundColor), (c) => ((c = "-") ? false : c))
				}

				if (tyreCompound != kUndefined) {
					processed := false

					if ((tyreService = "Wheel") && (tyreCompound.Length = 4)) {
						processedTyres := true

						for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
							knowledgeBase.addFact("Pitstop.Plan.Tyre.Compound." . tyre, tyreCompound[index])

							if (!processed && tyreCompound[index]) {
								knowledgeBase.addFact("Pitstop.Plan.Tyre.Compound", tyreCompound[index])

								processed := true
							}
						}
					}
					else if ((tyreService = "Axle") && (tyreCompound.Length = 2)) {
						processedTyres := true

						for index, axle in ["Front", "Rear"] {
							knowledgeBase.addFact("Pitstop.Plan.Tyre.Compound." . axle, tyreCompound[index])

							if (!processed && tyreCompound[index]) {
								knowledgeBase.addFact("Pitstop.Plan.Tyre.Compound", tyreCompound[index])

								processed := true
							}
						}
					}

					if !processedTyres {
						tyreCompound := first(tyreCompound, (c) => (c && (c != "-")))

						knowledgeBase.addFact("Pitstop.Plan.Tyre.Compound", tyreCompound)

						if (tyreService = "Wheel") {
							for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"]
								knowledgeBase.addFact("Pitstop.Plan.Tyre.Compound." . tyre, tyreCompound)
						}
						else if (tyreService = "Axle")
							for index, axle in ["Front", "Rear"]
								knowledgeBase.addFact("Pitstop.Plan.Tyre.Compound." . axle, tyreCompound)
					}
					else
						processedTyres := false
				}

				if (tyreCompoundColor != kUndefined) {
					processed := false

					if ((tyreService = "Wheel") && (tyreCompoundColor.Length = 4)) {
						processedTyres := true

						for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
							knowledgeBase.addFact("Pitstop.Plan.Tyre.Compound.Color." . tyre, tyreCompoundColor[index])

							if (!processed && tyreCompoundColor[index]) {
								knowledgeBase.addFact("Pitstop.Plan.Tyre.Compound.Color", tyreCompoundColor[index])

								processed := true
							}
						}
					}
					else if ((tyreService = "Axle") && (tyreCompoundColor.Length = 2)) {
						processedTyres := true

						for index, axle in ["Front", "Rear"] {
							knowledgeBase.addFact("Pitstop.Plan.Tyre.Compound.Color." . axle, tyreCompoundColor[index])

							if (!processed && tyreCompoundColor[index]) {
								knowledgeBase.addFact("Pitstop.Plan.Tyre.Compound.Color", tyreCompoundColor[index])

								processed := true
							}
						}
					}

					if !processedTyres {
						tyreCompoundColor := first(tyreCompoundColor, (c) => (c && (c != "-")))

						knowledgeBase.addFact("Pitstop.Plan.Tyre.Compound.Color", tyreCompoundColor)

						if (tyreService = "Wheel") {
							for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"]
								knowledgeBase.addFact("Pitstop.Plan.Tyre.Compound.Color." . tyre, tyreCompoundColor)
						}
						else if (tyreService = "Axle")
							for index, axle in ["Front", "Rear"]
								knowledgeBase.addFact("Pitstop.Plan.Tyre.Compound.Color." . axle, tyreCompoundColor)
					}
				}

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

		if (changeBrakes != kUndefined)
			knowledgeBase.addFact("Pitstop.Plan.Brake.Change", changeBrakes)

		knowledgeBase.setFact("Pitstop.Plan.Lap", plannedLap ? (plannedLap - 1) : false)

		result := knowledgeBase.produce()

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledgeBase(knowledgeBase)

		pitstopNumber := knowledgeBase.getValue("Pitstop.Planned.Nr")

		if this.Speaker {
			speaker := this.getSpeaker()
			fragments := speaker.Fragments

			speaker.beginTalk()

			try {
				if ((options == true) || (options.HasProp("Intro") && options.Intro))
					speaker.speakPhrase("Pitstop", {number: pitstopNumber})

				if ((options == true) || (options.HasProp("Fuel") && options.Fuel)) {
					fuel := knowledgeBase.getValue("Pitstop.Planned.Fuel", 0)

					if (fuel == 0)
						speaker.speakPhrase(forceRefuel ? "NoRefuel" : "NoRefuelLap")
					else
						speaker.speakPhrase("Refuel", {fuel: speaker.number2Speech(convertUnit("Volume", fuel), 1), unit: fragments[getUnit("Volume")]})

					if correctedFuel
						speaker.speakPhrase("RefuelAdjustedLast")
				}

				if (tyreService = "Wheel") {
					theCompound := false
					theCompoundColor := false

					for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
						theCompound := knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound." . tyre, false)

						if theCompound {
							theCompoundColor := knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound.Color." . tyre, false)

							break
						}
					}
				}
				else if (tyreService = "Axle") {
					theCompound := false
					theCompoundColor := false

					for index, axle in ["Front", "Rear"] {
						theCompound := knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound." . axle, false)

						if theCompound {
							theCompoundColor := knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound.Color." . axle, false)

							break
						}
					}
				}
				else {
					theCompound := knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound", false)
					theCompoundColor := knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound.Color", false)
				}

				if ((options == true) || (options.HasProp("Compound") && options.Compound)) {
					if theCompound {
						if tyreSets
							tyreSet := knowledgeBase.getValue("Pitstop.Planned.Tyre.Set", false)
						else
							tyreSet := false

						/*
						if (theCompound = "Dry")
							speaker.speakPhrase(!tyreSet ? "DryTyresNoSet" : "DryTyres", {compound: fragments[theCompound . "Tyre"], color: theCompoundColor, set: tyreSet})
						else
							speaker.speakPhrase(!tyreSet ? "WetTyresNoSet" : "WetTyres", {compound: fragments[theCompound . "Tyre"], color: theCompoundColor, set: tyreSet})
						*/

						if (theCompoundColor = "Black")
							compoundName := translate(theCompound, this.VoiceManager.Language)
						else
							compoundName := translate(compound(theCompound, theCompoundColor), this.VoiceManager.Language)

						speaker.speakPhrase(!tyreSet ? "TyreChangeNoSet" : "TyreChange", {compound: compoundName, set: tyreSet})
					}
					else {
						if (forceTyreChange || (knowledgeBase.getValue("Lap.Remaining.Stint", 0)
											  > knowledgeBase.getValue("Session.Settings.Pitstop.Service.Last", 5)))
							speaker.speakPhrase("NoTyreChange")
						else
							speaker.speakPhrase("NoTyreChangeLap")
					}
				}

				debug := this.VoiceManager.Debug[kDebugPhrases]

				if (theCompound && ((options == true) || (options.HasProp("Pressures") && options.Pressures))) {
					pressureFL := Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FL", 0), 1)
					pressureFR := Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FR", 0), 1)
					pressureRL := Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RL", 0), 1)
					pressureRR := Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RR", 0), 1)
					incrementFL := Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FL.Increment", 0), 1)
					incrementFR := Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FR.Increment", 0), 1)
					incrementRL := Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RL.Increment", 0), 1)
					incrementRR := Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RR.Increment", 0), 1)

					pressure := false

					for ignore, suffix in ["FL", "FR", "RL", "RR"]
						if (((tyrePressures != kUndefined) && (pressure%suffix% != 0.0)) || (increment%suffix% != 0.0)) {
							pressure := true

							break
						}

					if (debug || pressure) {
						speaker.speakPhrase("NewPressures")

						if ((knowledgeBase.getValue("Tyre.Compound") != theCompound) || (knowledgeBase.getValue("Tyre.Compound.Color") != theCompoundColor)
																					 || (tyrePressures != kUndefined)) {
							for ignore, suffix in ["FL", "FR", "RL", "RR"]
								if (debug || (pressure%suffix% != 0.0))
									speaker.speakPhrase("Tyre" . suffix
													  , {value: speaker.number2Speech(convertUnit("Pressure", pressure%suffix%))
													   , unit: fragments[getUnit("Pressure")], delta: "", by: ""})
						}
						else
							for ignore, suffix in ["FL", "FR", "RL", "RR"]
								if (debug || (increment%suffix% != 0.0))
									speaker.speakPhrase("Tyre" . suffix
													  , {value: speaker.number2Speech(convertUnit("Pressure", Round(Abs(increment%suffix%), 1)))
													   , unit: fragments[getUnit("Pressure")]
													   , delta: fragments[(increment%suffix% > 0) ? "Increased" : "Decreased"]
													   , by: fragments["By"]})

						if (tyrePressures = kUndefined) {
							pressureCorrection := Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.Correction", 0), 1)

							if (Abs(pressureCorrection) > 0.05) {
								temperatureDelta := knowledgeBase.getValue("Weather.Temperature.Air.Delta", 0)

								if (temperatureDelta = 0)
									temperatureDelta := ((pressureCorrection > 0) ? -1 : 1)

								speaker.speakPhrase((pressureCorrection > 0) ? "PressureCorrectionUp" : "PressureCorrectionDown"
												  , {value: speaker.number2Speech(convertUnit("Pressure", Abs(pressureCorrection)))
												   , unit: fragments[getUnit("Pressure")]
												   , pressureDirection: (pressureCorrection > 0) ? fragments["Increase"] : fragments["Decrease"]
												   , temperatureDirection: (temperatureDelta > 0) ? fragments["Rising"] : fragments["Falling"]})
							}
						}

						deviationThreshold := knowledgeBase.getValue("Session.Settings.Tyre.Pressure.Deviation")

						for tyre, tyreType in Map("FrontLeft", "FL", "FrontRight", "FR", "RearLeft", "RL", "RearRight", "RR") {
							lostPressure := knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.Lost." . tyreType, false)

							if (lostPressure && (lostPressure >= deviationThreshold) && (increment%tyreType% != 0))
								speaker.speakPhrase("PressureAdjustment", {tyre: fragments[tyre]
																		 , lost: speaker.number2Speech(convertUnit("Pressure", lostPressure))
																		 , unit: fragments[getUnit("Pressure")]})
						}
					}
				}

				if ((options == true) || (options.HasProp("Brakes") && options.Brakes) || (changeBrakes != kUndefined))
					if knowledgeBase.getValue("Pitstop.Planned.Brake.Change", false)
						speaker.speakPhrase("ChangeBrakes")

				if ((options == true) || (options.HasProp("Repairs") && options.Repairs)
				 || (repairBodywork != kUndefined) || (repairSuspension != kUndefined) || (repairEngine != kUndefined)) {
					if ((knowledgeBase.getValue("Lap." . lapNr . ".Damage.Suspension", 0) > 0)
					 && knowledgeBase.getValue("Pitstop.Planned.Repair.Suspension", false))
						speaker.speakPhrase("RepairSuspension")
					else if debug
						speaker.speakPhrase("NoRepairSuspension")

					if ((knowledgeBase.getValue("Lap." . lapNr . ".Damage.Bodywork", 0) > 0)
					 && knowledgeBase.getValue("Pitstop.Planned.Repair.Bodywork", false))
						speaker.speakPhrase("RepairBodywork")
					else if debug
						speaker.speakPhrase("NoRepairBodywork")

					if ((knowledgeBase.getValue("Lap." . lapNr . ".Damage.Engine", 0) > 0)
					 && knowledgeBase.getValue("Pitstop.Planned.Repair.Engine", false))
						speaker.speakPhrase("RepairEngine")
					else if debug
						speaker.speakPhrase("NoRepairEngine")
				}

				if confirm
					if plannedLap
						speaker.speakPhrase("PitstopLap", {lap: plannedLap})
					else if this.confirmAction("Pitstop.Prepare") {
						speaker.speakPhrase("ConfirmPrepare", false, true)

						this.setContinuation(VoiceManager.ReplyContinuation(this, ObjBindMethod(this, "preparePitstop"), false, "Okay"))
					}
					else
						this.preparePitstop()
			}
			finally {
				speaker.endTalk()
			}
		}

		if (result && this.RemoteHandler)
			this.RemoteHandler.pitstopPlanned(pitstopNumber, plannedLap)

		return result
	}

	planDriverSwap(lap := kUndefined, arguments*) {
		local knowledgeBase := this.KnowledgeBase
		local tyreCompound := kUndefined
		local tyreCompoundColor := kUndefined
		local repairBodywork, repairSuspension, repairEngine, speaker

		static lastRequest := []
		static forcedLap := false

		this.clearContinuation()

		if (arguments.Length == 0) {
			forcedLap := false

			if this.RemoteHandler {
				repairBodywork := knowledgeBase.getValue("Damage.Repair.Bodywork.Target", false)
				repairSuspension := knowledgeBase.getValue("Damage.Repair.Suspension.Target", false)
				repairEngine := knowledgeBase.getValue("Damage.Repair.Engine.Target", false)

				if (lap = kUndefined) {
					lastRequest := []

					this.RemoteHandler.planDriverSwap(false, kUndefined, kUndefined, repairBodywork, repairSuspension, repairEngine)
				}
				else {
					if (InStr(lap, "!") = 1) {
						lap := SubStr(lap, 2)

						forcedLap := lap
					}

					lastRequest := Array(lap)

					this.RemoteHandler.planDriverSwap(lap, kUndefined, kUndefined, repairBodywork, repairSuspension, repairEngine)
				}
			}
		}
		else if (lap == false) {
			forcedLap := false

			if this.Speaker {
				speaker := this.getSpeaker()

				speaker.speakPhrase("NoDriverSwap")

				if this.supportsPitstop()
					if this.Listener {
						speaker.speakPhrase("ConfirmPlan", {forYou: speaker.Fragments["ForYou"]}, true)

						this.setContinuation(ObjBindMethod(this, "planPitstop", lastRequest*))
					}
					else
						this.planPitstop(lastRequest*)
			}
			else if this.supportsPitstop()
				this.planPitstop(lastRequest*)

			forcedLap := false
			lastRequest := []
		}
		else if (InStr(lap, "!") = 1) {
			lap := SubStr(lap, 2)

			forcedLap := lap
			lastRequest := concatenate(Array(lap), arguments)

			if this.RemoteHandler {
				repairBodywork := knowledgeBase.getValue("Damage.Repair.Bodywork.Target", false)
				repairSuspension := knowledgeBase.getValue("Damage.Repair.Suspension.Target", false)
				repairEngine := knowledgeBase.getValue("Damage.Repair.Engine.Target", false)

				this.RemoteHandler.planDriverSwap(lap, kUndefined, kUndefined, repairBodywork, repairSuspension, repairEngine)
			}
		}
		else if (InStr(lap, "?") = 1) {
			lap := SubStr(lap, 2)

			if arguments.Has(6)
				tyreCompound := arguments[6]

			if arguments.Has(7)
				tyreCompoundColor := arguments[7]

			forcedLap := lap
			lastRequest := Array(lap, arguments[1], arguments[2]
							   , kUndefined, tyreCompound, tyreCompoundColor, kUndefined
							   , arguments[3], arguments[4], arguments[5])

			if this.RemoteHandler
				this.RemoteHandler.planDriverSwap(lap, arguments*)
		}
		else {
			this.planPitstop(forcedLap ? forcedLap : lap, arguments*)

			forcedLap := false
			lastRequest := []
		}
	}

	preparePitstop(lap := false) {
		local speaker, result

		this.clearContinuation()

		if !this.supportsPitstop() {
			if this.Speaker
				this.getSpeaker().speakPhrase("NoPitstop")

			return false
		}

		if !this.hasPlannedPitstop() {
			if this.Speaker {
				speaker := this.getSpeaker()

				speaker.speakPhrase("MissingPlan")

				if this.supportsPitstop()
					if this.Listener {
						speaker.speakPhrase("ConfirmPlan", {forYou: ""}, true)

						this.setContinuation(ObjBindMethod(this, "planPitstop"))
					}
					else
						this.proposePitstop()
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

	pitstopPrepared() {
		this.iPitstopAdjustments := true
	}

	pitstopOptionChanged(option, verbose, values*) {
		local knowledgeBase := this.KnowledgeBase
		local prssKey, incrKey, targetPressure, index, suffix, axle, tyre

		if this.hasPreparedPitstop() {
			if isDebug()
				logMessage(kLogDebug, "Changing `"" . option . "`" to: " . values2String(", ", values*))

			switch option, false {
				case "Refuel":
					knowledgeBase.setFact("Pitstop.Planned.Fuel", values[1])
				case "Tyre Compound":
					knowledgeBase.setFact("Pitstop.Planned.Tyre.Compound", values[1])
					knowledgeBase.setFact("Pitstop.Planned.Tyre.Compound.Color", values[2])
				case "Tyre Compound Axle":
					for index, axle in ["Front", "Rear"] {
						knowledgeBase.setFact("Pitstop.Planned.Tyre.Compound." . axle, values[1][index])
						knowledgeBase.setFact("Pitstop.Planned.Tyre.Compound.Color." . axle, values[2][index])
					}
				case "Tyre Compound Wheel":
					for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
						knowledgeBase.setFact("Pitstop.Planned.Tyre.Compound." . tyre, values[1][index])
						knowledgeBase.setFact("Pitstop.Planned.Tyre.Compound.Color." . tyre, values[2][index])
					}
				case "Tyre Set":
					knowledgeBase.setFact("Pitstop.Planned.Tyre.Set", values[1])
				case "Tyre Pressures":
					for index, suffix in ["FL", "FR", "RL", "RR"] {
						prssKey := ("Pitstop.Planned.Tyre.Pressure." . suffix)
						incrKey := ("Pitstop.Planned.Tyre.Pressure." . suffix . ".Increment")

						if knowledgeBase.getValue(prssKey, false) {
							targetPressure := values[index]

							if knowledgeBase.getValue(incrKey, false)
								knowledgeBase.setFact(incrKey, knowledgeBase.getValue(incrKey) + (targetPressure - knowledgeBase.getValue(prssKey)))
							else
								knowledgeBase.setFact(incrKey, 0)

							knowledgeBase.setFact(prssKey, targetPressure)
						}
					}
				case "Change Brakes":
					knowledgeBase.setFact("Pitstop.Planned.Brake.Change", values[1])
				case "Repair Suspension":
					knowledgeBase.setFact("Pitstop.Planned.Repair.Suspension", values[1])
				case "Repair Bodywork":
					knowledgeBase.setFact("Pitstop.Planned.Repair.Bodywork", values[1])
				case "Repair Engine":
					knowledgeBase.setFact("Pitstop.Planned.Repair.Engine", values[1])
				case "Driver Request":
					knowledgeBase.setFact("Pitstop.Planned.Driver.Request", values[1])
				case "Driver":
					this.updateDriver(values[1], verbose)

					return
			}

			knowledgeBase.setFact("Pitstop.Update", true)

			knowledgeBase.produce()

			if this.Debug[kDebugKnowledgeBase]
				this.dumpKnowledgeBase(knowledgeBase)

			if (verbose && this.Speaker[false])
				if (this.iPitstopAdjustments && (option = "Refuel") && !this.iPitstopFillUp)
					this.getSpeaker().speakPhrase("RefuelAdjustedNext")
				else
					this.getSpeaker().speakPhrase("ConfirmPlanUpdate")
		}
	}

	performPitstop(lapNumber := false, optionsFile := false) {
		this.iPitstopAdjustments := false
		this.iPitstopFillUp := false
		this.iPitstopOptionsFile := optionsFile

		super.performPitstop(lapNumber, optionsFile)
	}

	executePitstop(lapNumber) {
		local knowledgeBase := this.KnowledgeBase
		local tyreChange := false
		local lastLap, flWear, frWear, rlWear, rrWear, driver, tyreCompound, tyreCompoundColor, tyreSet, result
		local lastPitstop, pitstop, options, compound, pressures, tyre, mixedCompounds, brakeService

		this.Provider.supportsTyreManagement(&mixedCompounds, &tyreSet)
		this.Provider.supportsPitstop( , , &brakeService)

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

				driver := driverName(knowledgeBase.getValue("Lap." . lastLap . ".Driver.Forname")
								   , knowledgeBase.getValue("Lap." . lastLap . ".Driver.Surname")
								   , knowledgeBase.getValue("Lap." . lastLap . ".Driver.Nickname"))

				tyreCompound := knowledgeBase.getValue("Lap." . lastLap . ".Tyre.Compound")
				tyreCompoundColor := knowledgeBase.getValue("Lap." . lastLap . ".Tyre.Compound.Color")

				if (mixedCompounds = "Wheel") {
					tyreCompound := collect(["FrontLeft", "FrontRight", "RearLeft", "RearRight"], (tyre) {
										return knowledgeBase.getValue("Lap." . lastLap . ".Tyre.Compound." . tyre, tyreCompound)
									})
					tyreCompoundColor := collect(["FrontLeft", "FrontRight", "RearLeft", "RearRight"], (tyre) {
											 return knowledgeBase.getValue("Lap." . lastLap . ".Tyre.Compound.Color." . tyre, tyreCompoundColor)
										 })
				}
				else if (mixedCompounds = "Axle") {
					tyreCompound := collect(["Front", "Rear"], (axle) {
										return knowledgeBase.getValue("Lap." . lastLap . ".Tyre.Compound." . axle, tyreCompound)
									})
					tyreCompoundColor := collect(["Front", "Rear"], (axle) {
											 return knowledgeBase.getValue("Lap." . lastLap . ".Tyre.Compound.Color." . axle, tyreCompoundColor)
										 })
				}
				else {
					tyreCompound := [tyreCompound]
					tyreCompoundColor := [tyreCompoundColor]
				}

				if tyreSet
					tyreSet := knowledgeBase.getValue("Lap." . lastLap . ".Tyre.Set", false)
			}
		}

		result := super.executePitstop(lapNumber)

		pitstop := knowledgeBase.getValue("Pitstop.Last", 0)

		if this.iPitstopOptionsFile {
			if (knowledgeBase.getValue("Pitstop." . pitstop . ".Fuel", kUndefined) = kUndefined) {
				options := readMultiMap(this.iPitstopOptionsFile)

				knowledgeBase.setFact("Pitstop." . pitstop . ".Fuel", getMultiMapValue(options, "Pitstop", "Refuel", 0))

				compound := getMultiMapValue(options, "Pitstop", "Tyre.Compound", false)

				knowledgeBase.setFact("Pitstop." . pitstop . ".Tyre.Compound", compound)

				if compound {
					knowledgeBase.setFact("Pitstop." . pitstop . ".Tyre.Compound.Color"
										, getMultiMapValue(options, "Pitstop", "Tyre.Compound.Color", false))

					tyreChange := true
				}
				else
					knowledgeBase.setFact("Pitstop." . pitstop . ".Tyre.Compound.Color", false)

				if (mixedCompounds = "Wheel") {
					do(["FrontLeft", "FrontRight", "RearLeft", "RearRight"], (tyre) {
						compound := getMultiMapValue(options, "Pitstop", "Tyre.Compound." . tyre, false)

						knowledgeBase.setFact("Pitstop." . pitstop . ".Tyre.Compound." . tyre, compound)

						if compound {
							knowledgeBase.setFact("Pitstop." . pitstop . ".Tyre.Compound.Color." . tyre
												, getMultiMapValue(options, "Pitstop", "Tyre.Compound.Color." . tyre, false))

							tyreChange := true
						}
						else
							knowledgeBase.setFact("Pitstop." . pitstop . ".Tyre.Compound.Color." . tyre, false)
					})
				}
				else if (mixedCompounds = "Axle") {
					do(["Front", "Rear"], (axle) {
						compound := getMultiMapValue(options, "Pitstop", "Tyre.Compound." . axle, false)

						knowledgeBase.setFact("Pitstop." . pitstop . ".Tyre.Compound." . axle, compound)

						if compound {
							knowledgeBase.setFact("Pitstop." . pitstop . ".Tyre.Compound.Color." . axle
												, getMultiMapValue(options, "Pitstop", "Tyre.Compound.Color." . axle, false))

							tyreChange := true
						}
						else
							knowledgeBase.setFact("Pitstop." . pitstop . ".Tyre.Compound.Color." . axle, false)
					})
				}

				if tyreChange {
					if tyreSet
						knowledgeBase.setFact("Pitstop." . pitstop . ".Tyre.Set", getMultiMapValue(options, "Pitstop", "Tyre.Set", false))

					pressures := string2Values(";", getMultiMapValue(options, "Pitstop", "Tyre.Pressures", ""))

					for index, tyre in ["FL", "FR", "RL", "RR"]
						knowledgeBase.setFact("Pitstop." . pitstop . ".Tyre.Pressure." . tyre, pressures[index])
				}

				if brakeService
					knowledgeBase.setFact("Pitstop." . pitstop . ".Brake.Change", getMultiMapValue(options, "Pitstop", "Change.Brakes", false))

				knowledgeBase.setFact("Pitstop." . pitstop . ".Repair.Suspension", getMultiMapValue(options, "Pitstop", "Repair.Suspension", false))
				knowledgeBase.setFact("Pitstop." . pitstop . ".Repair.Bodywork", getMultiMapValue(options, "Pitstop", "Repair.Bodywork", false))
				knowledgeBase.setFact("Pitstop." . pitstop . ".Repair.Engine", getMultiMapValue(options, "Pitstop", "Repair.Engine", false))

				if this.Debug[kDebugKnowledgeBase]
					this.dumpKnowledgeBase(knowledgeBase)
			}

			deleteFile(this.iPitstopOptionsFile)

			this.iPitstopOptionsFile := false
		}

		if (this.RemoteHandler && (flWear != kUndefined) && (pitstop != lastPitstop))
			this.RemoteHandler.updateTyreSet(pitstop, driver, false
										   , values2String(",", tyreCompound*), values2String(",", tyreCompoundColor*), tyreSet
										   , flWear, frWear, rlWear, rrWear)

		return result
	}

	finishPitstop(lapNumber) {
		local result := super.finishPitstop(lapNumber)

		if this.RemoteHandler
			this.RemoteHandler.pitstopFinished(this.KnowledgeBase.getValue("Pitstop.Last", 0))

		return result
	}

	performService(lapNumber, fuel, tyreCompound, tyreCompoundColor, tyreSet
						    , tyrePressureFL, tyrePressureFR, tyrePressureRL, tyrePressureRR) {
		local knowledgeBase := this.KnowledgeBase
		local pitstop := (knowledgeBase.getValue("Pitstop.Last", 0) + 1)
		local ignore, fact, mixedCompounds, index, tyre, axle

		this.Provider.supportsTyreManagement(&mixedCompounds)

		setValue(fact, value) {
			knowledgeBase.setFact("Pitstop." . pitstop . "." . fact, value)
		}

		tyreCompound := string2Values(",", tyreCompound)
		tyreCompoundColor := string2Values(",", tyreCompoundColor)

		knowledgeBase.setFact("Tyre.Compound", first(tyreCompound, (c) => (c && (c != "-"))))
		knowledgeBase.setFact("Tyre.Compound.Color", first(tyreCompoundColor, (cc) => (cc && (cc != "-"))))

		if (mixedCompounds = "Wheel") {
			for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
				if (tyreCompound.Length != 4)
					index := 1

				knowledgeBase.setFact("Tyre.Compound." . tyre, tyreCompound[index])
				knowledgeBase.setFact("Tyre.Compound.Color." . tyre, tyreCompoundColor[index])
				setValue("Tyre.Compound." . tyre, tyreCompound[index])
				setValue("Tyre.Compound.Color. " . tyre, tyreCompoundColor[index])
			}
		}
		else if (mixedCompounds = "Axle")
			for index, axle in ["Front", "Rear"] {
				if (tyreCompound.Length != 2)
					index := 1

				knowledgeBase.setFact("Tyre.Compound." . axle, tyreCompound[index])
				knowledgeBase.setFact("Tyre.Compound.Color." . axle, tyreCompoundColor[index])
				setValue("Tyre.Compound." . axle, tyreCompound[index])
				setValue("Tyre.Compound.Color. " . axle, tyreCompoundColor[index])
			}

		setValue("Lap", lapNumber)
		setValue("Time", A_Now)
		setValue("Temperature.Air", knowledgeBase.getValue("Lap." . lapNumber . "Temperature.Air"))
		setValue("Temperature.Track", knowledgeBase.getValue("Lap." . lapNumber . "Temperature.Track"))
		setValue("Fuel", fuel)
		setValue("Tyre.Compound", tyreCompound)
		setValue("Tyre.Compound.Color", tyreCompoundColor)
		setValue("Tyre.Set", tyreSet)
		setValue("Tyre.Pressure.FL", tyrePressureFL)
		setValue("Tyre.Pressure.FR", tyrePressureFR)
		setValue("Tyre.Pressure.RL", tyrePressureRL)
		setValue("Tyre.Pressure.RR", tyrePressureRR)

		for ignore, fact in ["Tyre.Pressure.Correction", "Driver.Request", "Repair.Bodywork", "Repair.Suspension", "Repair.Engine"]
			setValue(fact, false)

		knowledgeBase.setFact("Pitstop.Last", pitstop)
		knowledgeBase.setFact("Pitstop.Clear", lapNumber)

		knowledgeBase.produce()

		if this.Debug[kDebugKnowledgeBase]
 			this.dumpKnowledgeBase(this.KnowledgeBase)
	}

	callPlanPitstop(lap := kUndefined, arguments*) {
		this.clearContinuation()

		if !this.supportsPitstop() {
			if this.Speaker
				this.getSpeaker().speakPhrase("NoPitstop")
		}
		else if ((lap = kUndefined) && this.hasPlannedPitstop()) {
			if this.Listener {
				this.getSpeaker().speakPhrase("ConfirmRePlan")

				this.setContinuation(ObjBindMethod(this, "invokePlanPitstop", false, lap, arguments*))
			}
			else
				this.invokePlanPitstop(false, lap, arguments*)
		}
		else
			this.invokePlanPitstop(true, lap, arguments*)
	}

	invokePlanPitstop(confirm, lap := kUndefined, arguments*) {
		this.clearContinuation()

		if (lap == kUndefined) {
			if confirm
				if !this.confirmCommand(false)
					return

			this.proposePitstop()
		}
		else if (arguments.Length = 0)
			this.proposePitstop(lap)
		else
			this.planPitstop(lap, arguments*)
	}

	callPlanDriverSwap(lap := kUndefined, arguments*) {
		local speaker := this.getSpeaker()

		this.clearContinuation()

		if !this.supportsPitstop() {
			if this.Speaker
				speaker.speakPhrase("NoPitstop")
		}
		else if (!this.TeamSession || (lap == false)) {
			speaker.speakPhrase("NoDriverSwap")

			if this.supportsPitstop()
				if this.Listener {
					speaker.speakPhrase("ConfirmPlan", {forYou: speaker.Fragments["ForYou"]}, true)

					this.setContinuation(ObjBindMethod(this, "planPitstop", lap, arguments*))
				}
				else if (arguments.Length = 0)
					this.proposePitstop(lap)
				else
					this.planPitstop(lap, arguments*)
		}
		else if ((lap = kUndefined) && this.hasPlannedPitstop()) {
			if this.Listener {
				speaker.speakPhrase("ConfirmRePlan")

				this.setContinuation(ObjBindMethod(this, "invokePlanDriverSwap", false, lap, arguments*))
			}
			else
				this.invokePlanDriverSwap(false, lap, arguments*)
		}
		else
			this.invokePlanDriverSwap(true, lap, arguments*)
	}

	invokePlanDriverSwap(confirm, lap := kUndefined, arguments*) {
		this.clearContinuation()

		if (lap == kUndefined) {
			if confirm
				if !this.confirmCommand(false)
					return

			this.planDriverSwap()
		}
		else
			this.planDriverSwap(lap, arguments*)
	}

	callPreparePitstop(lap := false) {
		this.clearContinuation()

		if !this.supportsPitstop() {
			if this.Speaker
				this.getSpeaker().speakPhrase("NoPitstop")
		}
		else {
			if !this.confirmCommand(false)
				return

			if lap
				this.preparePitstop(lap)
			else
				this.preparePitstop()
		}
	}

	createPitstopHistory() {
		local knowledgeBase := this.KnowledgeBase
		local pitstopHistory := newMultiMap()
		local numPitstops := 0
		local numTyreSets := 1
		local lastLap := 0
		local tyreLapsFL := 0
		local tyreLapsFR := 0
		local tyreLapsRL := 0
		local tyreLapsRR := 0
		local pitstopLap, pitstopLaps, tyreCompound, tyreCompoundColor, tyreSet
		local tyreService, brakeService, tyreSets, pitstop, tyreChange, index, axle, tyre
		local tc, tcc, first

		static postfixes := ["FL", "FR", "RL", "RR"]

		if knowledgeBase {
			this.Provider.supportsPitstop( , &tyreService, &brakeService)
			this.Provider.supportsTyreManagement( , &tyreSets)

			setMultiMapValue(pitstopHistory, "TyreSets", "1.Compound"
						   , knowledgeBase.getValue("Session.Setup.Tyre.Compound"))
			setMultiMapValue(pitstopHistory, "TyreSets", "1.CompoundColor"
						   , knowledgeBase.getValue("Session.Setup.Tyre.Compound.Color"))

			if tyreSets
				setMultiMapValue(pitstopHistory, "TyreSets", "1.Set"
							   , knowledgeBase.getValue("Session.Setup.Tyre.Set"))

			loop knowledgeBase.getValue("Pitstop.Last") {
				numPitstops += 1

				if (knowledgeBase.getValue("Pitstop." . A_Index . ".Lap", kUndefined) != kUndefined) {
					pitstopLap := knowledgeBase.getValue("Pitstop." . A_Index . ".Lap")
					pitstopLaps := (pitstopLap - lastLap)

					setMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".Lap", pitstopLap)
					setMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".Time"
								   , Round(knowledgeBase.getValue("Pitstop." . A_Index . ".Time", 0) / 1000))
					setMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".Refuel"
								   , knowledgeBase.getValue("Pitstop." . A_Index . ".Fuel", 0))

					tyreCompound := knowledgeBase.getValue("Pitstop." . A_Index . ".Tyre.Compound", false)
					tyreCompoundColor := knowledgeBase.getValue("Pitstop." . A_Index . ".Tyre.Compound.Color", false)

					tyreSet := knowledgeBase.getValue("Pitstop." . A_Index . ".Tyre.Set", false)

					if tyreCompound {
						setMultiMapValue(pitstopHistory, "TyreSets", numTyreSets . ".Laps", pitstopLaps)

						numTyreSets += 1
						lastLap := pitstopLap

						setMultiMapValue(pitstopHistory, "TyreSets", numTyreSets . ".Compound", tyreCompound)
						setMultiMapValue(pitstopHistory, "TyreSets", numTyreSets . ".CompoundColor", tyreCompoundColor)

						if tyreSets
							setMultiMapValue(pitstopHistory, "TyreSets", numTyreSets . ".Set", tyreSet)

						setMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".TyreCompound", tyreCompound)
						setMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".TyreCompoundColor", tyreCompoundColor)
						setMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".TyreChange", true)

						if tyreSets
							setMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".TyreSet", tyreSet)
					}
					else
						setMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".TyreChange", false)

					tyreChange := false
					pitstop := A_Index

					if (tyreService = "Axle") {
						first := true

						for index, axle in ["Front", "Rear"] {
							tc := knowledgeBase.getValue("Pitstop." . pitstop . ".Tyre.Compound." . axle, false)
							tcc := knowledgeBase.getValue("Pitstop." . pitstop . ".Tyre.Compound.Color." . axle, false)

							if (tc && (tc != "-")) {
								setMultiMapValue(pitstopHistory, "Pitstops", pitstop . ".TyreCompound" . axle, tc)
								setMultiMapValue(pitstopHistory, "Pitstops", pitstop . ".TyreCompoundColor" . axle, tcc)

								if first {
									first := false

									setMultiMapValue(pitstopHistory, "Pitstops", pitstop . ".TyreCompound", tc)
									setMultiMapValue(pitstopHistory, "Pitstops", pitstop . ".TyreCompoundColor", tc)
								}

								tyreChange := true

								if (axle = "Front") {
									tyreLapsFL := 0
									tyreLapsFR := 0
								}
								else {
									tyreLapsRL := 0
									tyreLapsRR := 0
								}
							}
							else  {
								if (axle = "Front") {
									tyreLapsFL += pitstopLaps
									tyreLapsFR += pitstopLaps
								}
								else {
									tyreLapsRL += pitstopLaps
									tyreLapsRR += pitstopLaps
								}
							}
						}

						if !tyreChange {
							setMultiMapValue(pitstopHistory, "Pitstops", pitstop . ".TyreCompound", false)
							setMultiMapValue(pitstopHistory, "Pitstops", pitstop . ".TyreCompoundColor", false)
						}
					}
					else if (tyreService = "Wheel") {
						first := true

						for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
							tc := knowledgeBase.getValue("Pitstop." . pitstop . ".Tyre.Compound." . tyre, false)
							tcc := knowledgeBase.getValue("Pitstop." . pitstop . ".Tyre.Compound.Color." . tyre, false)

							if (tc && (tc != "-")) {
								setMultiMapValue(pitstopHistory, "Pitstops", pitstop . ".TyreCompound" . tyre, tc)
								setMultiMapValue(pitstopHistory, "Pitstops", pitstop . ".TyreCompoundColor" . tyre, tcc)

								if first {
									first := false

									setMultiMapValue(pitstopHistory, "Pitstops", pitstop . ".TyreCompound", tc)
									setMultiMapValue(pitstopHistory, "Pitstops", pitstop . ".TyreCompoundColor", tc)
								}

								tyreChange := true

								%"tyreLaps" . postfixes[index]% := 0
							}
							else  {
								setMultiMapValue(pitstopHistory, "Pitstops", pitstop . ".TyreCompound" . tyre, false)
								setMultiMapValue(pitstopHistory, "Pitstops", pitstop . ".TyreCompoundColor" . tyre, false)

								%"tyreLaps" . postfixes[index]% += pitstopLaps
							}
						}

						if !tyreChange {
							setMultiMapValue(pitstopHistory, "Pitstops", pitstop . ".TyreCompound", false)
							setMultiMapValue(pitstopHistory, "Pitstops", pitstop . ".TyreCompoundColor", false)
						}
					}
					else if tyreCompound {
						tyreLapsFL := 0
						tyreLapsFR := 0
						tyreLapsRL := 0
						tyreLapsRR := 0

						tyreChange := true
					}
					else {
						tyreLapsFL += pitstopLaps
						tyreLapsFR += pitstopLaps
						tyreLapsRL += pitstopLaps
						tyreLapsRR += pitstopLaps
					}

					setMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".TyreLapsFrontLeft", tyreLapsFL)
					setMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".TyreLapsFrontRight", tyreLapsFR)
					setMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".TyreLapsRearLeft", tyreLapsRL)
					setMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".TyreLapsRearRight", tyreLapsRR)

					if tyreChange
						setMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".TyreChange", true)

					if brakeService
						setMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".BrakeChange"
													   , knowledgeBase.getValue("Pitstop." . A_Index . ".Brake.Change", false))

					setMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".RepairBodywork"
								   , knowledgeBase.getValue("Pitstop." . A_Index . ".Repair.Bodywork", false))
					setMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".RepairSuspension"
								   , knowledgeBase.getValue("Pitstop." . A_Index . ".Repair.Suspension", false))
					setMultiMapValue(pitstopHistory, "Pitstops", A_Index . ".RepairEngine"
								   , knowledgeBase.getValue("Pitstop." . A_Index . ".Repair.Engine", false))
				}
			}

			setMultiMapValue(pitstopHistory, "TyreSets", numTyreSets . ".Laps", knowledgeBase.getValue("Lap") - lastLap)

			setMultiMapValue(pitstopHistory, "Pitstops", "Count", numPitstops)
			setMultiMapValue(pitstopHistory, "TyreSets", "Count", numTyreSets)
		}
		else {
			setMultiMapValue(pitstopHistory, "Pitstops", "Count", 0)
			setMultiMapValue(pitstopHistory, "TyreSets", "Count", 0)
		}

		return pitstopHistory
	}

	requestPitstopHistory(callbackCategory, callbackMessage, callbackPID, arguments*) {
		local fileName := temporaryFileName("Pitstop", "history")

		writeMultiMap(filename, this.createPitstopHistory())

		messageSend(kFileMessage, callbackCategory, callbackMessage . ":" . values2String(";", fileName, arguments*), callbackPID)
	}

	lowFuelWarning(remainingFuel, remainingLaps, planPitstop := true) {
		local knowledgeBase := this.KnowledgeBase
		local speaker

		if (this.hasEnoughData(false) && this.Speaker[false] && this.Announcements["FuelWarning"])
			if (!knowledgeBase.getValue("InPitLane", false) && !knowledgeBase.getValue("InPit", false)) {
				remainingFuel := Round(remainingFuel, 1)
				remainingLaps := Floor(remainingLaps)

				speaker := this.getSpeaker()

				speaker.beginTalk()

				try {
					speaker.speakPhrase((remainingLaps <= 2) ? "VeryLowFuel" : "LowFuel", {laps: remainingLaps})

					if this.supportsPitstop()
						if this.hasPreparedPitstop()
							speaker.speakPhrase((remainingLaps <= 2) ? "LowComeIn" : "ComeIn")
						else if (!this.hasPlannedPitstop() && planPitstop) {
							if this.confirmAction("Pitstop.Fuel") {
								speaker.speakPhrase("ConfirmPlan", {forYou: ""}, true)

								this.setContinuation(ObjBindMethod(this, "proposePitstop", "Now"))
							}
							else
								this.proposePitstop("Now")
						}
						else if planPitstop {
							if this.confirmAction("Pitstop.Fuel") {
								speaker.speakPhrase("ConfirmPrepare", false, true)

								this.setContinuation(VoiceManager.ReplyContinuation(this, ObjBindMethod(this, "preparePitstop"), false, "Okay"))
							}
							else
								this.preparePitstop()
						}
				}
				finally {
					speaker.endTalk()
				}
			}
	}

	lowEnergyWarning(remainingEnergy, remainingLaps, planPitstop := true) {
		local knowledgeBase := this.KnowledgeBase
		local speaker

		if (this.hasEnoughData(false) && this.Speaker[false] && this.Announcements["FuelWarning"])
			if (!knowledgeBase.getValue("InPitLane", false) && !knowledgeBase.getValue("InPit", false)) {
				remainingEnergy := Round(remainingEnergy, 1)
				remainingLaps := Floor(remainingLaps)

				speaker := this.getSpeaker()

				speaker.beginTalk()

				try {
					speaker.speakPhrase((remainingLaps <= 2) ? "VeryLowEnergy" : "LowEnergy", {laps: remainingLaps})

					if this.supportsPitstop()
						if this.hasPreparedPitstop()
							speaker.speakPhrase((remainingLaps <= 2) ? "LowComeIn" : "ComeIn")
						else if (!this.hasPlannedPitstop() && planPitstop) {
							if this.confirmAction("Pitstop.Fuel") {
								speaker.speakPhrase("ConfirmPlan", {forYou: ""}, true)

								this.setContinuation(ObjBindMethod(this, "proposePitstop", "Now"))
							}
							else
								this.proposePitstop("Now")
						}
						else if planPitstop {
							if this.confirmAction("Pitstop.Fuel") {
								speaker.speakPhrase("ConfirmPrepare", false, true)

								this.setContinuation(VoiceManager.ReplyContinuation(this, ObjBindMethod(this, "preparePitstop"), false, "Okay"))
							}
							else
								this.preparePitstop()
						}
				}
				finally {
					speaker.endTalk()
				}
			}
	}

	tyreWearWarning(tyre, wear, planPitstop := true) {
		local knowledgeBase := this.KnowledgeBase
		local speaker

		static wheels := CaseInsenseMap("FL", "FrontLeft", "FR", "FrontRight"
								      , "RL", "RearLeft", "RR", "RearRight")

		if !inList(["FL", "FR", "RL", "RR"], tyre)
			throw "Unknown tyre descriptor (" . tyre . ") detected in RaceEngineer.tyreWearWarning..."

		if (this.hasEnoughData(false) && this.Speaker[false] && this.Announcements["TyreWearWarning"])
			if (!knowledgeBase.getValue("InPitLane", false) && !knowledgeBase.getValue("InPit", false)) {
				speaker := this.getSpeaker()

				speaker.beginTalk()

				try {
					speaker.speakPhrase("TyreWearWarning", {tyre: speaker.Fragments[wheels[tyre]]})

					speaker.speakPhrase("Wear" . tyre, {used: Round(wear), remaining: Round(100 - wear)})

					if this.supportsPitstop()
						if this.hasPreparedPitstop()
							speaker.speakPhrase("ComeIn")
						else if (!this.hasPlannedPitstop() && planPitstop) {
							if this.confirmAction("Pitstop.Tyre") {
								speaker.speakPhrase("ConfirmPlan", {forYou: ""}, true)

								this.setContinuation(ObjBindMethod(this, "proposePitstop", "Now"))
							}
							else
								this.proposePitstop("Now")
						}
						else if planPitstop {
							if this.confirmAction("Pitstop.Tyre") {
								speaker.speakPhrase("ConfirmPrepare", false, true)

								this.setContinuation(VoiceManager.ReplyContinuation(this, ObjBindMethod(this, "preparePitstop"), false, "Okay"))
							}
							else
								this.preparePitstop()
						}
				}
				finally {
					speaker.endTalk()
				}
			}
	}

	brakeWearWarning(brake, wear, planPitstop := true) {
		local knowledgeBase := this.KnowledgeBase
		local speaker

		static wheels := CaseInsenseMap("FL", "FrontLeft", "FR", "FrontRight"
								      , "RL", "RearLeft", "RR", "RearRight")

		if !inList(["FL", "FR", "RL", "RR"], brake)
			throw "Unknown tyre descriptor (" . brake . ") detected in RaceEngineer.brakeWearWarning..."

		if (this.hasEnoughData(false) && this.Speaker[false] && this.Announcements["BrakeWearWarning"])
			if (!knowledgeBase.getValue("InPitLane", false) && !knowledgeBase.getValue("InPit", false)) {
				speaker := this.getSpeaker()

				speaker.beginTalk()

				try {
					speaker.speakPhrase("BrakeWearWarning", {brake: speaker.Fragments[wheels[brake]]})

					speaker.speakPhrase("Wear" . brake, {used: Round(wear), remaining: Round(100 - wear)})

					if this.supportsPitstop()
						if this.hasPreparedPitstop()
							speaker.speakPhrase("ComeIn")
						else if (!this.hasPlannedPitstop() && planPitstop) {
							if this.confirmAction("Pitstop.Brake") {
								speaker.speakPhrase("ConfirmPlan", {forYou: ""}, true)

								this.setContinuation(ObjBindMethod(this, "proposePitstop", "Now"))
							}
							else
								this.proposePitstop("Now")
						}
						else if planPitstop {
							if this.confirmAction("Pitstop.Brake") {
								speaker.speakPhrase("ConfirmPrepare", false, true)

								this.setContinuation(VoiceManager.ReplyContinuation(this, ObjBindMethod(this, "preparePitstop"), false, "Okay"))
							}
							else
								this.preparePitstop()
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

		if ((this.hasEnoughData(false) || (knowledgeBase.getValue("Lap", 0) <= this.LearningLaps)) && this.Speaker[false] && this.Announcements["DamageReporting"])
			if (!knowledgeBase.getValue("InPitLane", false) && !knowledgeBase.getValue("InPit", false)) {
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

					if (knowledgeBase.getValue("Lap.Remaining.Session", knowledgeBase.getValue("Lap.Remaining", 0)) > 4)
						speaker.speakPhrase("DamageAnalysis")
					else
						speaker.speakPhrase("NoDamageAnalysis")
				}
				finally {
					speaker.endTalk()
				}
			}
	}

	reportDamageAnalysis(repair, stintLaps, delta, clear := false) {
		local knowledgeBase := this.KnowledgeBase
		local speaker

		repairPitstop() {
			knowledgeBase.setFact("Damage.Repair.Suspension.Target", true)
			knowledgeBase.setFact("Damage.Repair.Bodywork.Target", true)
			knowledgeBase.setFact("Damage.Repair.Engine.Target", true)

			this.proposePitstop("Now", kUndefined, kUndefined, true)
		}

		if (this.hasEnoughData(false) && knowledgeBase.getValue("Lap.Remaining.Session", knowledgeBase.getValue("Lap.Remaining", 0)) > 3)
			if (this.Speaker[false] && this.Announcements["DamageAnalysis"])
				if (!knowledgeBase.getValue("InPitLane", false) && !knowledgeBase.getValue("InPit", false)) {
					speaker := this.getSpeaker()

					if clear
						speaker.speakPhrase("RepairPitstopNotNeeded", {laps: Round(stintLaps), delta: speaker.number2Speech(delta, 1)})
					else if repair {
						speaker.beginTalk()

						try {
							speaker.speakPhrase("RepairPitstop", {laps: Round(stintLaps), delta: speaker.number2Speech(delta, 1)})

							if this.supportsPitstop()
								if this.confirmAction("Pitstop.Repair") {
									speaker.speakPhrase("ConfirmPlan", {forYou: ""}, true)

									this.setContinuation(repairPitstop)
								}
								else
									this.proposePitstop("Now", kUndefined, kUndefined, true)
						}
						finally {
							speaker.endTalk()
						}
					}
					else if (repair == false)
						speaker.speakPhrase((Abs(delta) < 0.2) ? "NoTimeLost" : "NoRepairPitstop", {laps: stintLaps, delta: speaker.number2Speech(delta, 1)})
				}
	}

	pressureLossWarning(tyre, lostPressure) {
		local knowledgeBase := this.KnowledgeBase
		local speaker, fragments

		static tyreLookup := CaseInsenseMap("FL", "FrontLeft", "FR", "FrontRight", "RL", "RearLeft", "RR", "RearRight")

		if !inList(["FL", "FR", "RL", "RR"], tyre)
			throw "Unknown tyre descriptor (" . tyre . ") detected in RaceEngineer.pressureLossWarning..."

		if (this.hasEnoughData(false) && (this.Session == kSessionRace))
			if (!knowledgeBase.getValue("InPitLane", false) && !knowledgeBase.getValue("InPit", false))
				if (this.Speaker[false] && this.Announcements["PressureReporting"]) {
					speaker := this.getSpeaker()
					fragments := speaker.Fragments

					speaker.speakPhrase("PressureLoss", {tyre: fragments[tyreLookup[tyre]]
													   , lost: speaker.number2Speech(convertUnit("Pressure", lostPressure))
													   , unit: fragments[getUnit("Pressure")]})
				}
	}

	weatherForecast(weather, minutes, changeTyres) {
		if (!ProcessExist("Race Strategist.exe") && this.Speaker[false]
												 && (this.Session == kSessionRace) && this.Announcements["WeatherUpdate"])
			this.getSpeaker().speakPhrase(changeTyres ? "WeatherChange" : "WeatherNoChange", {minutes: minutes})
	}

	requestTyreChange(weather, minutes, recommendedCompound) {
		local knowledgeBase := this.KnowledgeBase
		local speaker, fragments

		if (!ProcessExist("Race Strategist.exe")
		 && (knowledgeBase.getValue("Lap.Remaining.Session", knowledgeBase.getValue("Lap.Remaining", 0))
		   > knowledgeBase.getValue("Session.Settings.Pitstop.Service.Last", 5))
		 && this.Speaker[false] && (this.Session == kSessionRace)) {
			speaker := this.getSpeaker()
			fragments := speaker.Fragments

			speaker.beginTalk()

			try {
				speaker.speakPhrase(((recommendedCompound = "Wet") || (recommendedCompound = "Intermediate")) ? "WeatherRainChange"
																											  : "WeatherDryChange"
								  , {minutes: minutes, compound: fragments[recommendedCompound . "Tyre"]})

				if (this.hasEnoughData(false) && this.supportsPitstop())
					if this.confirmAction("Pitstop.Weather") {
						speaker.speakPhrase("ConfirmPlan", {forYou: ""}, true)

						this.setContinuation(ObjBindMethod(this, "proposePitstop", "Now", kUndefined, true))
					}
					else
						this.proposePitstop("Now", kUndefined, true)
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
				Task.startTask(() => this.getSpeaker().speakPhrase("CallToPit"), 10000)
		}
	}

	setPitstopRefuelAmount(pitstopNumber, fuel) {
		local knowledgeBase := this.KnowledgeBase
		local fillUp

		if this.RemoteHandler {
			fillUp := ((knowledgeBase.getValue("Lap." . knowledgeBase.getValue("Lap") . ".Fuel.Remaining", 0)
					  + knowledgeBase.getValue("Pitstop.Planned.Fuel", 0))
					>= (knowledgeBase.getValue("Session.Settings.Fuel.Max", 0) - this.AvgFuelConsumption))

			this.iPitstopFillUp := fillUp

			this.RemoteHandler.setPitstopRefuelAmount(pitstopNumber, fuel, fillUp)
		}
	}

	setPitstopTyreCompound(pitstopNumber, compound, compoundColor, set) {
		if this.RemoteHandler
			this.RemoteHandler.setPitstopTyreCompound(pitstopNumber, compound, compoundColor, set)
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		if this.RemoteHandler
			if (pressureFL && isNumber(pressureFL)
			 && pressureFR && isNumber(pressureFR)
			 && pressureRL && isNumber(pressureRL)
			 && pressureRR && isNumber(pressureRR))
				this.RemoteHandler.setPitstopTyrePressures(pitstopNumber, Round(pressureFL, 1), Round(pressureFR, 1), Round(pressureRL, 1), Round(pressureRR, 1))
	}

	setPitstopBrakeChange(pitstopNumber,change) {
		if this.RemoteHandler
			this.RemoteHandler.setPitstopBrakeChange(pitstopNumber, change)
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine) {
		if this.RemoteHandler
			this.RemoteHandler.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine)
	}

	requestPitstopDriver(pitstopNumber, driver) {
		if (this.RemoteHandler && driver)
			this.RemoteHandler.requestPitstopDriver(pitstopNumber, driver)
	}

	getTyrePressures(weather, airTemperature, trackTemperature, &compound, &compoundColor, &pressures, &certainty) {
		local knowledgeBase := this.KnowledgeBase

		return this.TyresDatabase.getTyreSetup(knowledgeBase.getValue("Session.Simulator")
											 , knowledgeBase.getValue("Session.Car"), knowledgeBase.getValue("Session.Track")
											 , weather, airTemperature, trackTemperature, &compound, &compoundColor, &pressures, &certainty, true)
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                  Internal Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

lowFuelWarning(context, remainingFuel, remainingLaps) {
	context.KnowledgeBase.RaceAssistant.lowFuelWarning(Round(remainingFuel, 1), Floor(remainingLaps))

	return true
}

lowEnergyWarning(context, remainingEnergy, remainingLaps) {
	context.KnowledgeBase.RaceAssistant.lowEnergyWarning(Round(remainingEnergy, 1), Floor(remainingLaps))

	return true
}

tyreWearWarning(context, tyre, wear) {
	context.KnowledgeBase.RaceAssistant.tyreWearWarning(tyre, Round(wear))

	return true
}

brakeWearWarning(context, brake, wear) {
	context.KnowledgeBase.RaceAssistant.brakeWearWarning(brake, Round(wear))

	return true
}

damageWarning(context, newSuspensionDamage, newBodyworkDamage, newEngineDamage) {
	context.KnowledgeBase.RaceAssistant.damageWarning(newSuspensionDamage, newBodyworkDamage, newEngineDamage)

	return true
}

reportDamageAnalysis(context, repair, stintLaps, delta, clear := false) {
	context.KnowledgeBase.RaceAssistant.clearContinuation()

	context.KnowledgeBase.RaceAssistant.reportDamageAnalysis(repair, stintLaps, delta, clear)

	return true
}

pressureLossWarning(context, tyre, lostPressure) {
	context.KnowledgeBase.RaceAssistant.pressureLossWarning(tyre, lostPressure)

	return true
}

notifyWeatherForecast(context, weather, minutes, change) {
	context.KnowledgeBase.RaceAssistant.weatherForecast(weather, minutes, change)

	return true
}

requestTyreChange(context, weather, minutes, recommendedCompound) {
	context.KnowledgeBase.RaceAssistant.clearContinuation()

	context.KnowledgeBase.RaceAssistant.requestTyreChange(weather, minutes, recommendedCompound)

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

setPitstopRefuelAmount(context, pitstopNumber, fuel) {
	context.KnowledgeBase.RaceAssistant.setPitstopRefuelAmount(pitstopNumber, fuel)

	return true
}

setPitstopTyreCompound(context, pitstopNumber, compound, compoundColor, set) {
	context.KnowledgeBase.RaceAssistant.setPitstopTyreCompound(pitstopNumber, compound, compoundColor, set)

	return true
}

setPitstopTyrePressures(context, pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
	context.KnowledgeBase.RaceAssistant.setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)

	return true
}

setPitstopBrakeChange(context, pitstopNumber, change) {
	context.KnowledgeBase.RaceAssistant.setPitstopBrakeChange(pitstopNumber, change)

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

setupTyrePressures(context, weather, airTemperature, trackTemperature, tyreCompound, tyreCompoundColor) {
	local knowledgeBase := context.KnowledgeBase
	local pressures := false
	local certainty := 1.0

	if !inList(kTyreCompounds, compound(tyreCompound, tyreCompoundColor)) {
		tyreCompound := false
		tyreCompoundColor := false
	}

	airTemperature := Round(airTemperature)
	trackTemperature := Round(trackTemperature)

	if context.KnowledgeBase.RaceAssistant.getTyrePressures(weather, airTemperature, trackTemperature
														  , &tyreCompound, &tyreCompoundColor, &pressures, &certainty) {
		knowledgeBase.setFact("Tyre.Setup.Certainty", certainty)
		knowledgeBase.setFact("Tyre.Setup.Compound", tyreCompound)
		knowledgeBase.setFact("Tyre.Setup.Compound.Color", tyreCompoundColor)
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