;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AI Race Engineer                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Global Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\RuleEngine.ahk
#Include ..\Libraries\SpeechGenerator.ahk
#Include ..\Libraries\SpeechRecognizer.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kAlways = "Always"

global kFront = 0
global kRear = 1
global kLeft = 2
global kRight = 3
global kCenter = 4


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceEngineer extends ConfigurationItem {
	iPitstopHandler := false
	iRaceSettings := false
	
	iName := false	
	iSpeaker := false
	iListener := false
	
	iSpeechGenerator := false
	iSpeechRecognizer := false
	
	iContinuation := false
	
	iEnoughData := false
	
	iKnowledgeBase := false
	iOverallTime := 0
	iLastLap := 0
	iLastFuelAmount := 0
	iInitialFuelAmount := 0
	
	class RaceEngineerSpeaker extends SpeechGenerator {
		iEngineer := false
		
		__New(engineer, speaker) {
			this.iEngineer := engineer
			
			if (speaker == true)
				base.__New()
			else
				base.__New(speaker)
		}
		
		speak(text) {
			listener := false ; this.iEngineer.getListener()
			
			if listener
				listener.stopRecognizer()
			
			base.speak(text)
			
			if listener
				listener.startRecognizer()
		}
	}
	
	class RaceKnowledgeBase extends KnowledgeBase {
		iEngineer := false
		
		RaceEngineer[] {
			Get {
				return this.iRaceEngineer
			}
		}
		
		__New(raceEngineer, ruleEngine, facts, rules) {
			this.iRaceEngineer := raceEngineer
			
			base.__New(ruleEngine, facts, rules)
		}
	}
	
	KnowledgeBase[] {
		Get {
			return this.iKnowledgeBase
		}
	}
	
	RaceSettings[] {
		Get {
			return this.iRaceSettings
		}
	}
	
	PitstopHandler[] {
		Get {
			return this.iPitstopHandler
		}
	}
	
	Name[] {
		Get {
			return this.iName
		}
	}
	
	Speaker[] {
		Get {
			return this.iSpeaker
		}
	}
	
	Listener[] {
		Get {
			return this.iListener
		}
	}
	
	Continuation[] {
		Get {
			return this.iContinuation
		}
	}
	
	EnoughData[] {
		Get {
			return this.iEnoughData
		}
	}
	
	OverallTime[] {
		Get {
			return this.iOverallTime
		}
	}
	
	LastLap[] {
		Get {
			return this.iLastLap
		}
	}
	
	InitialFuelAmount[] {
		Get {
			return this.iInitialFuelAmount
		}
	}
	
	LastFuelAmount[] {
		Get {
			return this.iLastFuelAmount
		}
	}
	
	__New(configuration, raceSettings, pitstopHandler := false, name := false, speaker := false, listener := false) {
		this.iRaceSettings := raceSettings
		this.iPitstopHandler := pitstopHandler
		this.iName := name
		this.iSpeaker := speaker
		this.iListener := ((speaker != false) ? listener : false)
		
		base.__New(configuration)
	}
	
	createRace(data) {
		local facts
		
		settings := this.RaceSettings
		
		duration := Round((getConfigurationValue(data, "Stint Data", "TimeRemaining", 0) + getConfigurationValue(data, "Stint Data", "LapLastTime", 0)) / 1000)
		
		facts := {"Race.Car": getConfigurationValue(data, "Race Data", "Car", "")
				, "Race.Track": getConfigurationValue(data, "Race Data", "Track", "")
				, "Race.Duration": duration
				, "Race.Settings.OutLap": getConfigurationValue(settings, "Race Settings", "OutLap", true)
				, "Race.Settings.InLap": getConfigurationValue(settings, "Race Settings", "InLap", true)
				, "Race.Settings.Fuel.AvgConsumption": getConfigurationValue(settings, "Race Settings", "Fuel.AvgConsumption", 0)
				, "Race.Settings.Fuel.SafetyMargin": getConfigurationValue(settings, "Race Settings", "Fuel.SafetyMargin", 5)
				, "Race.Settings.Lap.PitstopWarning": getConfigurationValue(settings, "Race Settings", "Lap.PitstopWarning", 5)
				, "Race.Settings.Lap.AvgTime": getConfigurationValue(settings, "Race Settings", "Lap.AvgTime", 0)
				, "Race.Settings.Lap.Considered": getConfigurationValue(settings, "Race Settings", "Lap.Considered", 5)
				, "Race.Settings.Damage.Suspension.Repair": getConfigurationValue(settings, "Race Settings", "Damage.Suspension.Repair", "Always")
				, "Race.Settings.Damage.Suspension.Repair.Threshold": getConfigurationValue(settings, "Race Settings", "Damage.Suspension.Repair.Threshold", 0)
				, "Race.Settings.Damage.Bodywork.Repair": getConfigurationValue(settings, "Race Settings", "Damage.Bodywork.Repair", "Threshold")
				, "Race.Settings.Damage.Bodywork.Repair.Threshold": getConfigurationValue(settings, "Race Settings", "Damage.Bodywork.Repair.Threshold", 20)
				, "Race.Settings.Tyre.Dry.Pressure.Target.FL": getConfigurationValue(settings, "Race Settings", "Tyre.Dry.Pressure.Target.FL", 27.7)
				, "Race.Settings.Tyre.Dry.Pressure.Target.FR": getConfigurationValue(settings, "Race Settings", "Tyre.Dry.Pressure.Target.FR", 27.7)
				, "Race.Settings.Tyre.Dry.Pressure.Target.RL": getConfigurationValue(settings, "Race Settings", "Tyre.Dry.Pressure.Target.RL", 27.7)
				, "Race.Settings.Tyre.Dry.Pressure.Target.RR": getConfigurationValue(settings, "Race Settings", "Tyre.Dry.Pressure.Target.RR", 27.7)
				, "Race.Settings.Tyre.Wet.Pressure.Target.FL": getConfigurationValue(settings, "Race Settings", "Tyre.Wet.Pressure.Target.FL", 30.0)
				, "Race.Settings.Tyre.Wet.Pressure.Target.FR": getConfigurationValue(settings, "Race Settings", "Tyre.Wet.Pressure.Target.FR", 30.0)
				, "Race.Settings.Tyre.Wet.Pressure.Target.RL": getConfigurationValue(settings, "Race Settings", "Tyre.Wet.Pressure.Target.RL", 30.0)
				, "Race.Settings.Tyre.Wet.Pressure.Target.RR": getConfigurationValue(settings, "Race Settings", "Tyre.Wet.Pressure.Target.RR", 30.0)
				, "Race.Settings.Tyre.Pressure.Deviation": getConfigurationValue(settings, "Race Settings", "Tyre.Pressure.Deviation", 0.2)
				, "Race.Settings.Tyre.Set.Fresh": getConfigurationValue(settings, "Race Settings", "Tyre.Set.Fresh", 8)
				, "Race.Setup.Tyre.Compound": getConfigurationValue(settings, "Race Setup", "Tyre.Compound", "Dry")
				, "Race.Setup.Tyre.Set": getConfigurationValue(settings, "Race Setup", "Tyre.Set", 7)
				, "Race.Setup.Tyre.Pressure.FL": getConfigurationValue(settings, "Race Setup", "Tyre.Pressure.FL", 26.1)
				, "Race.Setup.Tyre.Pressure.FR": getConfigurationValue(settings, "Race Setup", "Tyre.Pressure.FR", 26.1)
				, "Race.Setup.Tyre.Pressure.RL": getConfigurationValue(settings, "Race Setup", "Tyre.Pressure.RL", 26.1)
				, "Race.Setup.Tyre.Pressure.RR": getConfigurationValue(settings, "Race Setup", "Tyre.Pressure.RR", 26.1)}
				
		return facts
	}
	
	getSpeaker() {
		if (this.Speaker && !this.iSpeechGenerator) {
			this.iSpeechGenerator := new this.RaceEngineerSpeaker(this, this.Speaker)
			
			this.getListener()
		}
		
		return this.iSpeechGenerator
	}
	
	getListener() {
		if (this.Listener && !this.iSpeechRecognizer) {
			if (this.Listener != true)
				recognizer := new SpeechRecognizer(this.Listener)
			else
				recognizer := new SpeechRecognizer()
			msgbox after create
			this.buildGrammars(recognizer)
			
			recognizer.startRecognizer()
			msgbox after start
			this.iSpeechRecognizer := recognizer
		}
		
		return this.iSpeechRecognizer
	}
	
	buildGrammars(speechRecognizer) {
		canYouGrammar := speechRecognizer.NewGrammar()
		canYouGrammar.AppendString(translate("Can you"))

		tellMeGrammar := speechRecognizer.NewGrammar()
		tellMeGrammar.AppendString(translate("Tell me"))

		giveMeGrammar := speechRecognizer.NewGrammar()
		giveMeGrammar.AppendString(translate("Give me"))

		whatAreGrammar := speechRecognizer.NewGrammar()
		whatAreGrammar.AppendString(translate("What are"))

		grammar := speechRecognizer.NewGrammar()
		grammar.AppendChoices(speechRecognizer.newChoices(translate("Hi"), translate("Hey")))
		grammar.AppendString("Jona")
		speechRecognizer.LoadGrammar(grammar, "Jona", ObjBindMethod(this, "phraseRecognized"))

		grammar := speechRecognizer.NewGrammar()
		grammar.AppendChoices(speechRecognizer.newChoices(translate("Yes go on"), translate("Perfect go on"), translate("Go on please"), translate("Head on please")))
		speechRecognizer.LoadGrammar(grammar, "Yes", ObjBindMethod(this, "phraseRecognized"))

		grammar := speechRecognizer.NewGrammar()
		grammar.AppendString(translate("No thank you"))
		speechRecognizer.LoadGrammar(grammar, "No", ObjBindMethod(this, "phraseRecognized"))

		grammar := speechRecognizer.NewGrammar()
		grammar.AppendGrammars(tellMeGrammar, giveMeGrammar, whatAreGrammar)
		grammar.AppendChoices(speechRecognizer.newChoices(translate("the tyre temperatures"), translate("the tyre pressures")))
		speechRecognizer.LoadGrammar(grammar, "Tyre", ObjBindMethod(this, "phraseRecognized"))

		grammar1 := speechRecognizer.NewGrammar()
		grammar1.AppendGrammars(tellMeGrammar, giveMeGrammar)
		grammar1.AppendString(translate("the remaining laps"))
		grammar2 := speechRecognizer.NewGrammar()
		grammar2.AppendString(translate("how many laps are remaining"))
		grammar3 := speechRecognizer.NewGrammar()
		grammar3.AppendString(translate("how many laps are left"))
		grammar := speechRecognizer.NewGrammar()
		grammar.AppendGrammars(grammar1, grammar2, grammar3)
		speechRecognizer.LoadGrammar(grammar, "Laps", ObjBindMethod(this, "phraseRecognized"))
	}
	
	phraseRecognized(grammar, words) {
		msgbox % grammar . ": " . values2String(", ", words*)
		switch grammar {
			case "Yes":
				continuation := this.iContinuation
				
				this.iContinuation := false
				
				if continuation {
					this.getSpeaker().speak(translate("Roger, I come back to you as soon as possible."), true)
								
					Sleep 5000

					%continuation%()
				}
			case "No":
				this.iContinuation := false
			case this.Name:
				this.nameRecognized(words)
			case "Laps":
				this.lapInfoRecognized(words)
			case "Tyre":
				this.tyreInfoRecognized(words)
			default:
				Throw "Unknown grammar """ . grammar . """ detected in RaceEngineer.phraseRecognized...."
		}
	}
	
	nameRecognized(words) {
		this.getSpeaker().speak(translate("I am here. What can I do for you?"), true)
	}
	
	lapInfoRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		
		if !this.hasEnoughData()
			return
		
		this.getSpeaker().speak(translate("You still have " . Round(knowledgeBase.getValue("Lap.Remaining")) . " laps to go."), true)
	}
	
	tyreInfoRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		
		if !this.hasEnoughData()
			return
		
		speaker := this.getSpeaker()
		
		temperatures := translate("temperatures")
		pressures := translate("pressures")
		
		if inList(words, temperatures)
			value := "Temperature"
		else if inList(words, pressures)
			value := "Pressure"
		else {
			speaker.speak(translate("Sorry, I did not understand. Can you repeat?"), true)
		
			return
		}
		
		lap := knowledgeBase.getValue("Lap")
		
		speaker.speak(translate("Ok, the " ((value == "Pressure") ? pressures : temperatures) . " are:"), true)
		
		speaker.speak(translate("Front Left " . Round(knowledgeBase.getValue("Lap." . lap . ".Tyre." . value . ".FL"), 1)), true)
		speaker.speak(translate("Front Right " . Round(knowledgeBase.getValue("Lap." . lap . ".Tyre." . value . ".FR"), 1)), true)
		speaker.speak(translate("Rear Left " . Round(knowledgeBase.getValue("Lap." . lap . ".Tyre." . value . ".RL"), 1)), true)
		speaker.speak(translate("Rear Right " . Round(knowledgeBase.getValue("Lap." . lap . ".Tyre." . value . ".RR"), 1)), true)
	}
	
	setContinuation(continuation) {
		this.iContinuation := continuation
	}
	
	startRace(data) {
		local facts := this.createRace(data)
		
		FileRead engineerRules, % getFileName("Race Engineer.rules", kConfigDirectory, kUserConfigDirectory)
		
		productions := false
		reductions := false

		new RuleCompiler().compileRules(engineerRules, productions, reductions)

		engine := new RuleEngine(productions, reductions, facts)
		
		this.iKnowledgeBase := new this.RaceKnowledgeBase(this, engine, engine.createFacts(), engine.createRules())
		this.iLastLap := 0
		this.iOverallTime := 0
		this.iLastFuelAmount := 0
		this.iInitialFuelAmount := 0
		this.iEnoughData := false
		
		result := this.KnowledgeBase.produce()
			
		if this.Speaker
			this.getSpeaker().speak(translate("Hi, I am " . this.Name . ", your race engineer today. You can call me anytime if you have questions. Good luck."), true)
		msgbox after speech
		if isDebug()
			dumpFacts(this.KnowledgeBase)
		msgbox after dumpfacts
		return result
	}
	
	finishRace() {
		this.iKnowledgeBase := false
		this.iLastLap := 0
		this.iOverallTime := 0
		this.iLastFuelAmount := 0
		this.iInitialFuelAmount := 0
		this.iEnoughData := false
			
		if this.Speaker
			this.getSpeaker().speak(translate("Yeah, what a race. Thanks for the excellent job."), true)
	}
	
	addLap(lapNumber, data) {
		local knowledgeBase
		local facts
		
		if !this.KnowledgeBase
			this.startRace(data)
		
		knowledgeBase := this.KnowledgeBase
		
		if (lapNumber == 1)
			knowledgeBase.addFact("Lap", 1)
		else {
			knowledgeBase.setValue("Lap", lapNumber)
			
			this.iEnoughData := true
		}
			
		knowledgeBase.addFact("Lap." . lapNumber . ".Driver", getConfigurationValue(data, "Race Data", "DriverName", ""))
		
		lapTime := getConfigurationValue(data, "Stint Data", "LapLastTime", 0)
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Time", lapTime)
		knowledgeBase.addFact("Lap." . lapNumber . ".Time.Start", this.OverallTime)
		
		this.iOverallTime := this.OverallTime + lapTime
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Time.End", this.OverallTime)
		
		fuelRemaining := getConfigurationValue(data, "Car Data", "FuelRemaining", 0)
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.Remaining", Round(fuelRemaining, 2))
		
		if (lapNumber == 1) {
			this.iInitialFuelAmount := fuelRemaining
			this.iLastFuelAmount := fuelRemaining
			
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.AvgConsumption", 0)
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.Consumption", 0)
		}
		else {
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.AvgConsumption", Round((this.InitialFuelAmount - fuelRemaining) / (lapNumber - 1), 2))
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.Consumption", Round(this.iLastFuelAmount - fuelRemaining, 2))
			
			this.iLastFuelAmount := fuelRemaining
		}
		
		tyrePressures := string2Values(",", getConfigurationValue(data, "Car Data", "TyrePressure", ""))
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Pressure.FL", Round(tyrePressures[1], 2))
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Pressure.FR", Round(tyrePressures[2], 2))		
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Pressure.RL", Round(tyrePressures[3], 2))
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Pressure.RR", Round(tyrePressures[4], 2))
		
		tyreTemperatures := string2Values(",", getConfigurationValue(data, "Car Data", "TyreTemperature", ""))
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Temperature.FL", Round(tyreTemperatures[1], 1))
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Temperature.FR", Round(tyreTemperatures[2], 1))		
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Temperature.RL", Round(tyreTemperatures[3], 1))
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Temperature.RR", Round(tyreTemperatures[4], 1))
			
		knowledgeBase.addFact("Lap." . lapNumber . ".Weather", 0)
		knowledgeBase.addFact("Lap." . lapNumber . ".Temperature.Air", Round(getConfigurationValue(data, "Car Data", "AirTemperature", 0)))
		knowledgeBase.addFact("Lap." . lapNumber . ".Temperature.Track", Round(getConfigurationValue(data, "Car Data", "RoadTemperature", 0)))
		
		bodyworkDamage := string2Values(",", getConfigurationValue(data, "Car Data", "BodyworkDamage", ""))
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Damage.Bodywork.Front", Round(bodyworkDamage[1], 2))
		knowledgeBase.addFact("Lap." . lapNumber . ".Damage.Bodywork.Rear", Round(bodyworkDamage[2], 2))
		knowledgeBase.addFact("Lap." . lapNumber . ".Damage.Bodywork.Left", Round(bodyworkDamage[3], 2))
		knowledgeBase.addFact("Lap." . lapNumber . ".Damage.Bodywork.Right", Round(bodyworkDamage[4], 2))
		knowledgeBase.addFact("Lap." . lapNumber . ".Damage.Bodywork.Center", Round(bodyworkDamage[5], 2))
		
		suspensionDamage := string2Values(",", getConfigurationValue(data, "Car Data", "SuspensionDamage", ""))
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Damage.Suspension.FL", Round(suspensionDamage[1], 2))
		knowledgeBase.addFact("Lap." . lapNumber . ".Damage.Suspension.FR", Round(suspensionDamage[2], 2))
		knowledgeBase.addFact("Lap." . lapNumber . ".Damage.Suspension.RL", Round(suspensionDamage[3], 2))
		knowledgeBase.addFact("Lap." . lapNumber . ".Damage.Suspension.RR", Round(suspensionDamage[4], 2))
		msgbox before produce
		result := knowledgeBase.produce()
		msgbox before dumpfacts
		if isDebug()
			dumpFacts(this.KnowledgeBase)
		msgbox ready
		return result
	}
	
	hasEnoughData() {
		if this.EnoughData
			return true
		else if this.Speaker {
			this.getSpeaker().speak(translate("Sorry, I do not have enough data yet. Please come back in one or two laps."), true)
			
			return false
		}
	}
	
	hasPlannedPitstop() {
		return this.KnowledgeBase.getValue("Pitstop.Planned", false)
	}
	
	hasPreparedPitstop() {
		return this.KnowledgeBase.getValue("Pitstop.Prepared", false)
	}
	
	planPitstop() {
		local knowledgeBase := this.KnowledgeBase
		
		if !this.hasEnoughData()
			return
				
		knowledgeBase.addFact("Pitstop.Plan", true)
		
		result := knowledgeBase.produce()
		
		if isDebug()
			dumpFacts(this.KnowledgeBase)
		
		if this.Speaker {
			pitstopPlan := translate("Ok, we have the following for Pitstop number ") . knowledgeBase.getValue("Pitstop.Planned.Nr") . translate(".")
				
			fuel := knowledgeBase.getValue("Pitstop.Planned.Fuel", 0)
			if (fuel == 0)
				pitstopPlan .= "`n" . translate("Refueling is not necessary.")
			else
				pitstopPlan .= "`n" . translate("We have to refuel ") . Round(fuel) . translate(" litres.")
			
			pitstopPlan .= "`n" . translate("We will use ") . knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound")
			pitstopPlan .= translate(" tyre compound and tyre set number ") . knowledgeBase.getValue("Pitstop.Planned.Tyre.Set") . translate(".")
			
			pitstopPlan .= "`n" . translate("Pressure front left ") . Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FL"), 1) . translate(".")
			pitstopPlan .= "`n" . translate("Pressure front right ") . Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FR"), 1) . translate(".")
			pitstopPlan .= "`n" . translate("Pressure rear left ") . Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RL"), 1) . translate(".")
			pitstopPlan .= "`n" . translate("Pressure rear right ") . Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RR"), 1) . translate(".")

			if knowledgeBase.getValue("Pitstop.Planned.Repair.Suspension", false)
				pitstopPlan .= "`n" . translate("We will repair the suspension.")
			else
				pitstopPlan .= "`n" . translate("The suspension looks fine.")

			if knowledgeBase.getValue("Pitstop.Planned.Repair.Bodywork", false)
				pitstopPlan .= "`n" . translate("Bodywork and aerodynamic elements should be repaired.")
			else
				pitstopPlan .= "`n" . translate("Bodywork and aerodynamic elements should be good.")
			
			speaker := this.getSpeaker()
			
			speaker.speak(pitstopPlan, true)
				
			if this.Listener {
				speaker.speak(translate("Should I instruct the pit crew?"), true)
				
				this.setContinuation(ObjBindMethod(this, "preparePitstop"))
			}
		}
		
		if (result && this.PitstopHandler) {
			this.PitstopHandler.pitstopPlanned()
		}
		
		return result
	}
	
	preparePitstop(lap := false) {
		if !this.hasPlannedPitstop() {
			if this.Speaker {
				speaker := this.getSpeaker()

				if this.Listener {
					speaker.speak(translate("I have not planned a pitstop yet. Should I update the pitstop strategy now?"), true)
				
					this.setContinuation(ObjBindMethod(this, "planPitstop"))
				}
				else
					speaker.speak(translate("Sorry, I have not planned a pitstop yet."), true)
			}
			
			return false
		}
		else {
			if this.Speaker {
				speaker := this.getSpeaker()

				if lap
					speaker.speak(translate("Ok, I will let the crew prepare the pitstop for lap ") . lap . translate("."), true)
				else
					speaker.speak(translate("Ok, I will let the crew prepare the pitstop immediately. Come in whenever you want."), true)
			}
				
			if !lap
				this.KnowledgeBase.addFact("Pitstop.Prepare", true)
			else
				this.KnowledgeBase.addFact("Pitstop.Planned.Lap", lap - 1)
		
			result := this.KnowledgeBase.produce()
			
			if isDebug()
				dumpFacts(this.KnowledgeBase)
		
			if (result && this.PitstopHandler) {
				this.PitstopHandler.pitstopPrepared()
			}
					
			return result
		}
	}
	
	performPitstop() {
		if this.Speaker
			this.getSpeaker().speak(translate("Ok, let the crew do their job. Check ignition, relax and prepare for engine restart."), true)
				
		this.KnowledgeBase.addFact("Pitstop.Lap", this.KnowledgeBase.getValue("Lap"))
		
		result := this.KnowledgeBase.produce()
		
		if isDebug()
			dumpFacts(this.KnowledgeBase)
		
		if (result && this.PitstopHandler)
			this.PitstopHandler.pitstopFinished()
		
		return result
	}
	
	upcomingPitstopWarning(remainingLaps) {
		if this.Speaker {
			speaker := this.getSpeaker()
			
			speaker.speak(translate("Hi, here is " . this.Name . ". You have fuel left for ") . Round(remainingLaps) . translate(" laps."), true)
		
			if this.Listener {
				speaker.speak(translate("Should I update the pitstop strategy now?"), true)
				
				this.setContinuation(ObjBindMethod(this, "planPitstop"))
			}
		}
	}
	
	startPitstopSetup() {
		if this.PitstopHandler
			this.PitstopHandler.startPitstopSetup()
	}

	finishPitstopSetup() {
		if this.PitstopHandler {
			this.PitstopHandler.finishPitstopSetup()
			
			this.PitstopHandler.pitstopPrepared()
		}
	}

	setPitstopRefuelAmount(litres) {
		if this.PitstopHandler
			this.PitstopHandler.setPitstopRefuelAmount(litres)
	}

	setPitstopTyreSet(compound, set) {
		if this.PitstopHandler
			this.PitstopHandler.setPitstopTyreSet(compound, set)
	}

	setPitstopTyrePressures(pressureFL, pressureFR, pressureRL, pressureRR) {
		if this.PitstopHandler
			this.PitstopHandler.setPitstopTyrePressures(pressureFL, pressureFR, pressureRL, pressureRR)
	}

	requestPitstopRepairs(repairSuspension, repairBodywork) {
		if this.PitstopHandler
			this.PitstopHandler.requestPitstopRepairs(repairSuspension, repairBodywork)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

upcomingPitstopWarning(context, remainingLaps) {
	context.KnowledgeBase.RaceEngineer.upcomingPitstopWarning(Round(remainingLaps))
}

startPitstopSetup(context) {
	context.KnowledgeBase.RaceEngineer.startPitstopSetup()
}

finishPitstopSetup(context) {
	context.KnowledgeBase.RaceEngineer.finishPitstopSetup()
}

setPitstopRefuelAmount(context, litres) {
	context.KnowledgeBase.RaceEngineer.setPitstopRefuelAmount(litres)
}

setPitstopTyreSet(context, compound, set) {
	context.KnowledgeBase.RaceEngineer.setPitstopTyreSet(compound, set)
}

setPitstopTyrePressures(context, pressureFL, pressureFR, pressureRL, pressureRR) {
	context.KnowledgeBase.RaceEngineer.setPitstopTyrePressures(pressureFL, pressureFR, pressureRL, pressureRR)
}

requestPitstopRepairs(context, repairSuspension, repairBodywork) {
	context.KnowledgeBase.RaceEngineer.requestPitstopRepairs(repairSuspension, repairBodywork)
}

dumpFacts(knowledgeBase) {
	try {
		FileDelete %kUserHomeDirectory%Temp\Race.facts
	}
	catch exception {
		; ignore
	}

	for key, value in knowledgeBase.Facts.Facts {
		text := key . " = " . value . "`n"
		FileAppend %text%, %kUserHomeDirectory%Temp\Race.facts
	}
}