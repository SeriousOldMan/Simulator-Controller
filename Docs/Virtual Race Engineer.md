## Introduction

Welcome to Jona, the world first fully interactive virtual race engineer for race car simulations.

Ok, enough marketing bullshit. Jona is a voice chat bot with a special knowledge about racing. It uses the telemetry data provided by a simulation game and a large domain specific rule set to derive its knowledge from there. Using this knowledge, Jona can give you information about the current state of your car (temperatures, pressures, remaining laps, upcoming pitstops, and so on), and can recommend settings for the next pitstop. Using the Pitstop MFD handling for *Assetto Corsa Competizione* introduced with Release 2.0, Jona is capable to setup a pitstop without user interaction completely on its own.

***

Before we head on, an important note: The first version of Jona as part of Release 2.1 is still quite restricted. Please consider this version more as an alpha version or a technology showcase. Over the course of the next releases, Jona will get smarter and smarter, as the AI kernel grows and I have found ways to incorporate further data, like weather information, into the knowledge base. Also, there will be the option to use a cloud based voice recognition integration insteaad of the Windows local offline speech recognition runtime, which is not state of the art anymore. Although a cloud based solution might impose a pay wall depending on your usage, this will be quite negliable. And, last but not least, I have concepts for a server based solution in the drawer, which will allow Jona to act as a race engineer for a complete team multiplayer endurance race. But this will be quite a huge undertaking and will take a while, depending on my available time to invest in this project.

***

As said above, Jona is a voice chat bot and therefore you can control Jona completely by voice. If you don't want to use voice control, there are other possibilities as well. More on that later in this documentation.

Before we dig deeper into the inner workings, here is a typical dialog based interaction, to give you an understanding of the current capabilities of Jona.

### A typical dialog

**Jona: "Hi, here is Jona, your race engineer today. You can call me anytime if you have questions. Good luck."**

(You hear this or a similar phrase, whenever Jona is ready to interact with you. Typically this is at the beginning of the second lap in a race. From now on Jona might call you, when important information is available, or you can call her/him anytime using one of the key phrases - see the section about [phrase grammars](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#phrase-grammars) on that.)

**Driver: "Tell me the tyre temperatures."**

**Jona: "We have a blue screen here. Windows XP is crap. Give me a minute."**

(This answer, or a similar one, means, that Jona does not have enough data at the moment to answer your question. Typically, Jona needs two laps at the beginning of the race or after a pitstop, to be completely up and running)

(A lap later...)

**Driver: "Tell me the tyre temperatures."**

**Jona: "We have the following temperatures: Front left 87. 85 Degrees in the front right tyre. Rear left 93. 91 rear right."**

(You can ask for other information as well. See the section about [phrase grammars](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#phrase-grammars) for more information.)

(A few laps later...)

**Jona: "Warning. Only 3 laps before you will run out of fuel. Should I update the pitstop strategy now?"**

(With this question Jona asks, if you want to start the preparation process for the upcoming pitstop.)

**Driver: "No thank you."**

(We are brave and go on to another lap.)

**Jona: "Okay. Call me when you are ready."**

(As you can see, Jona always acknowledges what you have said. This helps you to check, whether Jona understood you correctly.)

(A lap later...)

**Jona: "What are you doing? You are running out of fuel. We should prepare for a pitstop, Okay?"**

**Driver: "Yes go on."**

**Jona: "Okay, give me a second."**

(A few moments later...)

**Jona: "Jona here. I recommend this for pitstop number one: ..."**

(Jona gives you a complete overview of all the settings, that were derived for the upcoming pitstop (refueling, tyre compound, pressures, repairs, and so on.)

(Maybe you have some corrections...)

**Driver: "Can we decrease front right by zero point two?"**

**Jona: "The pressure of the front right tyre shall be decreased by 0.2 PSI, is that correct?"**

**Driver: "Yes please"**

(A moment later...)

**Jona: "I updated the pitstop plan like you said. Anything else?"**

**Driver: "No thank you"**

**Jona: "Understood. I am here."**

(The pitstop is now planned, but still not locked in. We are very brave and stay out for the last lap...)

**Jona: "Warning. You will run out of fuel in one lap. You should come in immediately. Shall I instruct the pit crew?"**

(With the last question, Jona asks, whether the pitstop plan shall be locked in.)

**Driver: "Ok, let's go on."**

**Jona: "Okay, I will let the crew prepare everything immediately."**

(A few moments later...)

**Jona: "We are ready for the pitstop. You can come in."**

(The Pitstop MFD window of *Assetto Corsa Competizione* comes to life and all the data is input automatically. See the section about the [pitstop handling](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#the-pitstop) for more information.)

(You enter the pit and bring the car to a stop.)

**Jona: "Okay, let the crew do their job. Check ignition, relax and prepare for engine restart."**

(And now you are ready for your next stint...)

To have an error free session like this one, you must have a perfect setup for voice recognition. I strngly recommend using a headset, since alien noises might lead to false positives in Jonas voice recognition. Please see the section on [troubleshooting](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#troubleshooting), if you need some hints.

## Installation

Not much to do here, since Jona is a fully integrated component of the Simulator Controller package. You might want to have a look on the ACC [plugin arguments](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-acc), since this plugin controls Jona during your *Assetto Corsa Competizione* sessions. And you might have to install (additional) voice support in your Windows operating system depending on the Windows isntallation you have.

### Installation of additional Voices

Almost every Windows installation already has builtin support for voice generation (called TTS, aka text-to-speech). If you want to install more voices (and Jona will use all of them according to the configured language), you might want to install some additional packages. Depending on your Windows license you can do this on the windows settings dialog as described in the [Microsoft documentation](https://support.microsoft.com/en-us/office/how-to-download-text-to-speech-languages-for-windows-10-d5a6b612-b3ae-423f-afa5-4f6caf1ec5d3) ([German version](https://support.microsoft.com/de-de/office/herunterladen-von-text-zu-sprache-sprachen-f%C3%BCr-windows-10-d5a6b612-b3ae-423f-afa5-4f6caf1ec5d3)). The current version of Jona comes with translations for English and German, as these are the languages supported by Simulator Controller out of the box. Therefore I recommend to install voices for these languages at least.

### Installation of Speech Recognition Libraries

The installation of the voice recognition engine sometimes needs a little bit more effort. Jona relies on the speech recognition runtime from Microsoft, which is not necessarily part of a Windows standard distribution. You can check this in your Settings dialog as well. If you do not have any voice recognition capabilities available, you can use the installer provided for your convinience in the *Utilities\3rd party* folder, as long you have a 64-bit Windows installation. Please install the runtime first and the two provided language packs for English and German afterwards. Otherwise search the web for "Windows Speech Recognition Runtime".

After installing the language packs, it might be necessary to unblock the recognizer DLLs of Jona, which are provided in the *Binaries* folder. Windows might have blocked these DLLs for security reasons, because you downloaded it from a non-trusted location. You will find a little Powershell script in the *Utilities* folder, which you can copy to the *Binaries* folder and execute it there with Administrator privileges.

Note: Since the time for offline voice recognition is almost over, a future version of Jona will use Google, Amazon or Azure services for voice recognition. But this might be a pay per use kind of service.

## Interacting with Jona

Although it is possible, to [use Jona without voice interaction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#vitual-race-engineer-integration), it is not much fun. But to have fun with Jona, you must understand, how the interaction is structured, since in the end, Jona is stupid as bread and only reacts to strong standard patterns. For each language you want to use to interact with Jona, a so called grammar file must exist. As said, grammars for English and German are already there. The grammar files are named "Race Engineer.grammars.XX", where XX is the two letter ISO language code. These files reside in the *Config* directory, either in the installation folder of Simulator Controller or in the *Simulator Controller\Config* folder in your user *Documents* folder. The later means, that you are able to provide your own grammar files or *overwrite* the existing ones. But be careful with overwriting, since this will introduce a pain in the a..., when updating to new versions.

Tha grammar files define the input patterns which Jona uses to understand you and also all reactions of Jona as predefined phrases. For each reaction, an unlimited number of phrases may exist (typically 2-4 different ones in the predefined grammar files) to provide for an entertaining variety of answers.

### Phrase grammars

Here is a small excerpt from the input setion of the English grammar file:

	[Choices]
	TellMe=Tell me, Give me, What are
	CanWe=Can you, Can we, Please
	[Listener Grammars]
	// Conversation //
	Call={Hi, Hey} %name%
	Harsh={%name% do you hear me, %name% I need you, Hey %name% where are you}
	Yes={Yes please, Yes go on, Perfect go on, Go on please, Head on please, Okay let's go on}
	No=No {thank you, not now, I will call you later}
	// Information //
	TyrePressures=[(TellMe) {the tyre pressures, the current tyre pressures, the pressures in the tyres}, What are the current pressures]

As you can see, a typical recognition phrase looks like this:

	[(TellMe) {the tyre pressures, the current tyre pressures, the pressures in the tyres}, (TellMe) the current pressures]
	
(TellMe) is a variable for a set of predfined optional filler phrases (in the example above TellMe stands for "Tell me, Give me, What are"). The definition above consists of two different independent phrases, which lead to the same reaction of Jona. This is denoted by the "[..., ...]" bracket construct. For the first phrase the "{..., ..., ...}" defines inner alternatives for this phrase. By using "[" and "{" constructs, you can create a variety of pattern alternatives. But in the end, Jona reacts only to the core words of a phrase, for example "the current pressures" in the above example.

Important: The words of the recognized phrase are reported to the Jona control program and may be analyzed there for further processing. For example, when asking for tyre pressures or temperaturs, the words "front", "left", ... are very important. Therefore be careful, if you change some of the predefined phrases.

Some phrases (input and output) may have additional variables enclosed in "%", as in *%name%* above. These variables are provided by the runtime to customize the questions and answers.

For the reactions of Jona, the format is much more simple. It looks like this:

	[Speaker Phrases]
	// Conversation //
	Greeting.1=Hi, I am %name%, your race engineer today. You can call me anytime if you have questions. Good luck.
	Greeting.2=Here is %name%. I am your race engineer for this race. Call me anytime.
	Greeting.3=Here is %name%, your race engineer. Have a great race.
	IHearYou.1=I am here. What can I do for you?
	IHearYou.2=Yeah? Have you called me?
	IHearYou.3=I hear you. Go on.
	IHearYou.4=Yes, I hear you. What do you need?
	Confirm.1=Roger, I come back to you as soon as possible.
	Confirm.2=Okay, give me a second.
	Comfirm.3=Wait a minute.
	Okay.1=Okay. Call me when you are ready.
	Okay.2=Understood. I am here.

As you can see here, each phrase provides different alternative sentences. Variables may be used here as well.

## Racing with Jona

Racing with Jona is easy, just begin your race and wait until Jona will contact you. This will be a few seconds after you crossed the start finish line after your first complete lap. To achieve this, the ACC plugin will start *Race Engineer.exe*, which is located in the *Binaries* folder, as a subprocess, as long as you are out on a track. (Note for developers: The communication between those two processes uses named pipes. For more technical information, see the [technical information](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#technical-information) section below).

Most of the information, that Jona needs, will be collected from the telemetry information of the simulation game. Unfortunately, this data does not contain every required information, and also there are additional data and configuration information, which are required by Jona. For example, data is required to understand the given race situation and the corresponding telemetry information, and to precisely predict tyre pressures, fuel requirements, tyre compound recommendations, and so on. In the end, all that means, that some setup work is required, before you start your race. 

### Race Engineer Settings

That said, we now come to an unpleasant part of the game, at least for the moment. The additional knowledge Jona needs is stored in a special file, *Race Engineer.settings*, that exists in the *Simulator Controller\Config* folder in your user *Documents* folder, which you have to modify for each race. You can do this by editing this file using a text editor or you can use a graphical user interface by using the application *Race Engineer Settings.exe* from the *Binaries* folder. As a side note, I am still trying to gather at least the setup part of this information from the simulation game itself.

The *Race Engineer.settings* looks like this:

	[Race Settings]
	Duration=60
	Lap.AvgTime=106
	Lap.Formation=true
	Lap.PostRace=true
	Lap.History.Considered=5
	Lap.History.Damping=0.20
	Lap.PitstopWarning=3
	Fuel.AvgConsumption=2.7
	Fuel.SafetyMargin=3
	Pitstop.Duration=50
	Damage.Bodywork.Repair=Threshold
	Damage.Bodywork.Repair.Threshold=20.0
	Damage.Suspension.Repair=Always
	Damage.Suspension.Repair.Threshold=false
	Tyre.Compound.Change=Never
	Tyre.Compound.Change.Threshold=false
	Tyre.Pressure.Deviation=0.2
	Tyre.Dry.Pressure.Target.FL=27.7
	Tyre.Dry.Pressure.Target.FR=27.7
	Tyre.Dry.Pressure.Target.RL=27.7
	Tyre.Dry.Pressure.Target.RR=27.7
	Tyre.Wet.Pressure.Target.FL=30.0
	Tyre.Wet.Pressure.Target.FR=30.0
	Tyre.Wet.Pressure.Target.RL=30.0
	Tyre.Wet.Pressure.Target.RR=30.0
	[Race Setup]
	Tyre.Compound=Dry
	Tyre.Set=7
	Tyre.Set.Fresh=8
	Tyre.Dry.Pressure.FL=26.1
	Tyre.Dry.Pressure.FR=26.1
	Tyre.Dry.Pressure.RL=26.1
	Tyre.Dry.Pressure.RR=26.1
	Tyre.Wet.Pressure.FL=28.2
	Tyre.Wet.Pressure.FR=28.2
	Tyre.Wet.Pressure.RL=28.2
	Tyre.Wet.Pressure.RR=28.2


Most options above define general settings which will be applicable to any race event. But the options from the *[Race Setup]* section need to be adjusted for each individual race event, as long, as you want Jona to come to correct recommendations.

  - The first fresh tyre set (*Tyre.Set.Fresh*), which is available for a pitstop and the tyres and pressures (*Tyre.XXX.Pressure.YY*) used in for the first stint. Jona needs this information to calculate the target pressures for the first pitstop.
  - The *Lap.AvgTime* and *Fuel.AvgConsumption* are more informational, but might lead to more accurate estimations for the fuel calulations in the first few laps, where you typically have much slower lap times.

Let's have a look at the settings tool, which provides two sections. The first section, *Settings*, contains information that are independent of the current race situation.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Engineer%20Settings%201.JPG)

In the upper area you find configuration information, that are used by Jona while *computing* the recommendations for the upcoming pitstop. Especially the first field, *Statistical Window*, is quite important. It defines the number of recent laps, which are used for each and every statistical calculation, for example the standard deviation of tyre pressures. The next field, *Damping Factor*, can be used to influence the calculation weight for each of thos laps. If you want all laps to be considered with equal weight, set this to *0*.

In the lower area you can define the optimal tyre pressures. When there is a deviation larger than *Deviation Threshold* form these target pressures is detected by Jona, corresponding pressure adjustments will be applied for the next pitstop. Beside this very simple approach, there are rules in the AI kernel, which try to predict future incluences by falling ambient temperatures and upcoming weather changes. You can modify the bahaviour of these rules by using the controls in the upper area.

The second section of the settings tool contains information about the actual race.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Engineer%20Settings%202.JPG)

You must supply the tyre selection and pressure setup, that is used at the beginning of the race, in the lower area of the *Race* section, wherease the static information for the given track and race is located in the upper area. Worth mentioning is the field *Pitstop Duration*, with which you supply the difference time needed for a normal pitstop (time for pit in and pit out plus the time needed for a tyre change minus the time to pass the pit area on the track). This information is used by Jona to decide, whether an early pitstop for a tyre change or damage repair might be worthwhile.

If you open the settings tool, it will load the *Race Engineer.settings* file located in the *Simulator Controller\Config* folder in your user *Documents* folder. If you close the tool with the "Ok" button, this file will be overwritten with the new information. Beside that, you can load a settings file from a different location with the "Load..." button and you can save the current settings with the "Save..." button. This may be used to create a settings database for all your cars and tracks in the various environmental conditions. By the way - a future version of Simulator Controller will create this database automatically.

### The pitstop

To enable Jona to handle the pitstop settings in *Assetto Corsa Competizione* fully on izs own, you need to prepare two things beforehand. First you have to follow the instructions in the [update information for Release 2.0](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-20), so that the ACC plugin is able to control the Pitstop MFD of *Assetto Corsa Competizione*. Second, you need to setup your ACC pitstop strategy in a special way for as many pitstops you expect in the given race (plus some more for a safety margin):

  - Refueling must be set to zero litres for each strategy
  - Each strategy has to use the Dry tyre compound
  - Each strategy has to use the next fresh tyre set after the previous strategy
  - For each strategy, the tyre pressures must be those as used for the first stint and documented in the *Race Engineer.settings* file as described above

Beside that, the check boxes for repair of Suspension and Bodywork must be both selected by the start of the race in the Pitstop MFD. After you have done all that, you can let Jona handle the pitstop setttings. Only be sure to not interfere with the artificial click and keyboard events, while Jona is managing the pitstop settings.

### How it works

Jona uses several statistical models to derive the data, on which the recommendations for the pitstop or other information is based. Therefore it will take some laps, before Jonas conclusion get more and more precise. So be careful, if you let Jona plan a pitstop after you have driven only three or four laps. You might end up with not enough fuel to reach the finish line.

The following statsitical models are used at the moment:

  1. Tyre pressure development
  
     The pressure development of the last laps and the deviation from the predefined target pressures are considered to derive pressure corrections for the next pitstop. The number of laps considered and the weighting of past laps can be configured using the settings tool.

  2. Refuel amount
  
     Depending on the number of remaining laps and average fuel comsumption, Jona derives the exact amount of fuel required for the next stint. As for the tyre pressures, the lap weight of past laps may be configured for the fuel average calculation.
	 
  3. Damage induced lap time degration
  
     After Jona detects a new damage, Jona observes the devlopment of your lap times and suggests an adopted pitstop strategy, depending on remaining stint time and the time used for a pitstop. The underlying model is quite complex and recognizes and excludes special lap situations like pitstops, accidents, and so on, from the average laptime calculation.
	 
  4. Repair recommendations
  
     Based on the same model, Jona suggests repairs for the upcoming pitstop. You can configure various strategies using the settings tool.
	 
  5. Tyre compound selection and tyre pressure gambling
  
     Linear regression models are used here. Depending on the development of ambient and tyre temperatures, as well as weather changes (not yet implemented), Jona might suggest higher or lower pressures than currently perfect as a result of clear past trend, thereby giving you a good compromise for the upcoming sprint

## Technical information

This section will give you some background information about the inner workings of Jona. To understand the most of it, you need some background knowledge about programming. Therefore, if you never have coded just a tiny bit, you can safely skip this section.

The most important part of Jona, beside the natural language interface, which has been described above, is the rule engine and the knowledgebase, the rules work with. The major part of the knowledgebase consists of a history of past events, which is used by the rules to give Jona a kind of memory and allows the bot to interact in a context-sensitive manner. The history is also used by the rules to infere future trends, for example, a projection of target tyre pressures for long stints in an evening session, when the air and track temperatures are falling. Past and future weather trend information will be integrated as well, when they are available. Jona is able to recommend whether a repair of a damage be worth of for the next pitstop by calculating the historic impact of the damage on your lap time, and so on. Not all of this has been implemented completely in the alpha version of Jona, but the genetics are all there.

Below you will find some information about the rule engine and the knowledge base, although this is not a complete documentation at all for the moment.

### The Rule Engine

The rule engine used for Jona is a so called hybrid rule engine, which means, that rules can derive new knowledge from given knowledge, called forward chaining, or rules can be used to prove a hypothesis by reducing it to more and more simple questions until all those question has been answered or no more possibilities are available, which means, that the hypothesis is considered to be false. This is called backward chaining and the most prominent representative for this kind of logical computation is the programming language Prolog.

Jonas forward chaining rules look like this:

	{All: [?Pitstop.Plan], [?Tyre.Pressure.Target.FL]} =>
		(Set: Pitstop.Planned.Tyre.Pressure.FL, ?Tyre.Pressure.Target.FL),
		(Set: Pitstop.Planned.Tyre.Pressure.FL.Increment, !Tyre.Pressure.Target.FL.Increment)

This rule, for example, is triggered, when a new pitstop plan had been requested (*[?Pitstop.Plan]*) and when at the same time a target pressure for the front left tyre had been derived (typically by another rule). The rule above then *fires* and thereby copies this information to the pitstop plan.

A backword chaining rule is typically used for calculations and looks like this:

	updateRemainingLaps(?lap) <=
		remainingStintLaps(?lap, ?stintLaps), remainingRaceLaps(?lap, ?raceLaps),
		?stintLaps < ?raceLaps, Set(Lap.Remaining, ?stintLaps)

	lowFuelWarning(?lap, ?remainingLaps) <= pitstopLap(?lap), !, fail
	lowFuelWarning(?lap, ?remainingLaps) <= Call(lowFuelWarning, ?remainingLaps)
	
In this example, the rule *updateRemainingLaps* calculates the number of laps, which remains with the current amount of fuel. Or, as an alternative route, it might consider the remaining stint time of the current driver. The result is then updated in the memory as the *Lap.Remaining* fact, which might trigger other rules. One of these rules might then call *lowFuelWarning*, the second part of the example above. This rule calls the external function *lowFuelWarning*, which in the end let Jona call you and tell you, that you are running out of fuel. As you can see by the first instance of the rule *lowFuelWarning*, this call is only issued, when the current lap (*?lap*) is not a lap, where the driver has pitted.

You can find the rules of Jona in the file *Race Engineer.rules* which resides in the *Config* folder in the installation folder of Simulator Controller. As always, you are able to overwrite this file by placing a (modified) copy in the *Simulator Controller\Config* folder in your user *Documents* folder. This might be or might not be a good idea, depending on your programming skills in logical languages.

### Interaction States

At this time, Jona can handle three important states in its knowledge base.

  - A pitstop has been planned
  - A pitstop has been prepared, which means that all the settings had been transferred to the Pitstop MFD of *Assetto Corsa Competizione*
  - The car is in the pit and the crew is working on the car
  
You can trigger the first two states, as long as logical for the given situation, by setting the facts *Pitstop.Plan* or *Pitstop.Prepare* to *true* in the knowledge base. The rule network will do the rest. An undertaken pitstop must be triggered by setting *Pitstop.Lap* to the lap number, where the driver pitted. All this is handled by the *RaceEngineer* class already, so there is no need to do this at the knowledge base level. But it is important to know, that these states exist, in order to undertstand Jonas reactions to your requests. For example, Jona first wants to plan a pitstop before you enter the pit, which is quite logical, right?

### Jonas Memory

The content of the knowledgbase of Jona or the facts, as these are called in the world of rule engines, can be divided into three categories:

  - *Historical information:* Here, all recent laps and pitstops are memorized to build a base of historic data for trend anlysis.
  - *Derived future information:* In this category fall the state information described above, for example the projected settings for the next pitstop.
  - *Real working memory:* Jona constantly calculates future trends and events, like low fuel in a few laps. These projected values are stored in the memory as well.
  
For historical information, the format is quite simple. All facts for a past lap start with *Lap.X* where X is the lap number. A similar format is used for pitstops, *Pitstop.X*, where X is the pitstop number here. Normally you will have more laps than pitstops in the memory, except you are me in a reverse grid league race, hey?
The derived future information is typically categorized by the first part of the fact name, for example *Tyre* for all knowledge about the current and projected tyre state.

You can take a look at the knowledge base by enabling "Debug" mode in the configuration, as described in the [Troubleshooting](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#troubleshooting) section. By doing this, you will pay a performance penalty, which might or might not be noticeable depending on your hardware.

### Telemetry Integration

A considerable part of the knowledge of Jona comes from the telemetry information of the simulation game. As said, a data provider for *Assetto Corsa Competizione* is already builtin and is used by the ACC plugin to load the data and hand it over to Jona. A small spplication "ACC SHM Reader.exe", which is located in the *Binaries* folder, is used to acquire the data. This reader ist run periodically and outputs the following data:

	[Car Data]
	AirTemperature=24.9965
	BodyworkDamage=0, 0, 0, 0, 0
	FuelRemaining=9.39671
	RoadTemperature=31.8178
	SuspensionDamage=0, 0, 0, 0
	TyreCompound=Wet
	TyrePressure=27.1306, 27.3363, 27.166, 27.5029
	TyreTemperature=82.8184, 71.4197, 86.3127, 77.3212
	[Race Data]
	Car=mclaren_720s_gt3
	FuelAmount=125
	Track=Barcelona
	[Stint Data]
	DriverForname=The
	DriverSurname=BigO
	DriverNickname=TBO
	Active=true
	Paused=false
	Session=RACE
	InPit=false
	LapBestTime=110091
	LapLastTime=110091
	Laps=2
	TimeRemaining=2.47009e+06
		
The shared memory of *Assetto Corsa Competizione* provides a lot more information, but this is all that is needed for Jona at the momemnt. Future versions of Jona will incorporate more data, as Jona gets smarter. Unfortunately, the shared memory interface of *Assetto Corsa Competizione* does not provide any weather or car setup information at the moment, but time will tell.

The ACC plugin writes this information to a temporary file and hands it over to Jona for each new lap. A special case is the flag *InPit*. If this is found to be *true*, the driver is currently in the pit. In this case, the ACC plugin informs Jona about this by raising the corresponding event. Another special case is the flag *Active* which is used to detect, whether you are in a simulation (race, training, whatever) right now.

Note: If you are a developer and want to take the challenge to adopt Jona to a different simulation game, you are welcome. You can use the ACC plugin code and the above file format as a blueprint. Please feel free to contact me, if you have questions. I would be happy to integrate plugins for other simulation games into Simulator Controller in the future.

## Troubleshooting

The biggest hurdle to overcome when using Jona, is to find a satisfying setting for voice recognition. Here are some hints:

  - I strongly recommend to use a head set. Although it is possible, and I have tested it myself, to talk to Jona using a desktop or webcam microphone, it is hard to find a satisfying setup. Typically, you will get a couple of false positives in this scenario, while the V12 sound from the Aston Martin is hammering from the speakers. You have been warned...
  - Even when using headset, you might get false positives. The reason for that, normally is a too sensitive microphone level. Reduce the input level of the microphone as low as possible in the Windows audio devices settings, so that Jona still recognizes your spoken words, but does not interpret your sighs and breath noises as valid input.
  - If voice recognition is not working at all, you might need to unblock the DLLs. Follow the instructions in the [installation section](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#installation-of-speech-recognition-libraries) above.
  - Most import: Learn the phrases, which are defined as input for Jona. Sometimes, only a somewhat different pronounciation is needed, and everything is fine. As a last line of defence, define your own input grammar as described above in the section about [phrase grammars](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#phrase-grammars). But doing this will make your upgrade path for future versions much more complicated. 

Beside that, when you encounter false recommendations from Jona, you might take a look into the brain of Jona to see, why Jona arrived at those conclusions. You can do this by enabling "Debug" mode in the configuration. In the next run, Jona will periodically dump its knowledge to the file "Race Engineer.knowledge" in the folder *Simulator Controller\Temp* that resides in your user *Documents* folder. If you think, that you found a bug, it  would be very helpful for me, when you attach this file to any reported issue.

And, last but not least, you might have a problem with the Shared Memory Reader for *Assetto Corsa Competizione*. Please check, if a file "SHM.data" exists in the *Simulator Controller\Temp\ACC Data* folder, which is located in your user *Documents* folder. If this file does not exist, you might try a complete reinstall.

If you still have problems with voice recognition, you might try this combination:

  1. Disable voice recognition by supplying *raceEngineerListener: false* as argument for the [ACC plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#vitual-race-engineer-integration).
  2. Also, define a toggle function to switch Jona On or Off using the *raceEngineer* parameter of the ACC plugin.
  3. Configure all necessary options you want to use for the ["Pitstop" mode](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-pitstop) of the ACC plugin, especially the *raceEngineerCommands* *PitstopPlan* and *PitstopPrepare*.

With this setup, Jona will be there and inform you about low fuel, damages and so on, but you have to use the Button Box to initiate pitstop planning and preparation. You will miss out all the eloquent conversations with Jona, but functionality wise, you are almost on par.
  