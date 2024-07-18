## Introduction

Welcome to Jona, the world first fully interactive and AI-based Virtual Race Engineer for race car simulations.

Ok, enough marketing bullshit. Jona is a voice chat bot with a special knowledge about racing. It uses the telemetry data provided by a simulation game and a large domain specific rule set to derive its knowledge from there. Using this knowledge, Jona can give you information about the current state of your car (temperatures, pressures, remaining laps, upcoming pitstops, and so on), and can recommend settings for the next pitstop. Currently, Jona supports the *Assetto Corsa*, *Assetto Corsa Competizione*, *RaceRoom Racing Experience*, *rFactor 2*, *Le Mans Ultimate*, *iRacing*, *Automobilista 2* and *Project CARS 2* simulation games through their respective plugins. Using the Pitstop MFD handling for *Assetto Corsa Competizione* introduced with [Release 2.0](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-20), Jona is even capable to setup a pitstop without user interaction completely on its own. Step by step, this will be made available for all simulations, where this is possible (currently all above simulators are supported, although the support for *RaceRoom Racing Experience* and also *iRacing* is somewhat limited).

***

Before we head on, an important note: Depending on the simulation, the Race Assistants can not be used in a team race, since the required data is not availabe, when you are not the currently active driver.  I have concepts for a server based solution in the drawer, which will allow Jona to act as a Race Engineer for a complete team multiplayer endurance race. But this will be quite a huge undertaking and will take a while, depending on my available time to invest in this project.

***

As said above, Jona is a voice chat bot and therefore you can control Jona completely by voice. If you don't want to use voice control, there are other possibilities as well. More on that later in this documentation.

Before we dig deeper into the inner workings, here is a typical dialog based interaction, to give you an understanding of the current capabilities of Jona.

Important: If you have multiple *dialog partners* active, for example Jona and Cato, it will benecessary to use the [activation phrase](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#voice-commands) the first time you start talking to a specific *dialog partner*.

### A typical dialog

**Jona: "Hi, here is Jona, your Race Engineer today. You can call me anytime if you have questions. Good luck."**

(You hear this or a similar phrase, whenever Jona is ready to interact with you. Typically this is at the beginning of the second lap in a session. From now on Jona might call you, when important information is available, or you can call her/him anytime using one of the key phrases - see the section about [phrase grammars](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#phrase-grammars) on that.)

**Driver: "Tell me the tyre temperatures."**

**Jona: "We have a blue screen here. Windows XP is crap. Give me a minute."**

(This answer, or a similar one, means, that Jona does not have enough data at the moment to answer your question. Typically, Jona needs two laps at the beginning of the session or after a pitstop, to be completely up and running)

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

To have an error free session like this one, you must have a perfect setup for voice recognition. I strongly recommend using a headset, since alien noises might lead to false positives in Jonas voice recognition. Please see the section on [troubleshooting](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#troubleshooting), if you need some hints.

## Installation

Not much to do here, since Jona is a fully integrated component of the Simulator Controller package. Of yourse, you have to configure the Simulator Controller software, before you can use the Virtual Race Engineer. Please read the [installation documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration) for a complete overview of the steps required, especially the installation and configuration for [Voice Control](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control). You might want to have a look at the ["Race Engineer" plugin arguments](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer), since this plugin controls Jona during your simulator sessions.

### Installation of Telemetry Providers

Jona acquires telemetry data from the different simulation games using so called telemtry providers, which in most cases read the [required data](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#telemetry-integration) from a shared memory interface. In general these are already included in Simulator Controller and there is nothing to do, but for *Assetto Corsa*, *rFactor 2* and *Le Mans Ultimate*, you need to install a plugin into a special location for the telemetry interface to work and for *Automobilista 2* and *Project CARS 2* a change in the settings is necessary.

Please, note that all of this also applies to all other Virtual Race Assistants, but you have to do it only once, of course.

  1. *Assetto Corsa*
  
     Please copy the complete *SimlatorController* folder, which is located in the *Utilities\Plugins* folder of the Simulator Controller installation, to the Steam installation folder of *Assetto Corsa* and there into the *apps\python* folder. You will have to enable this plugin in the *Asseto Corsa* settings afterwards. This plugin uses code originally developed by *Sparten* which can be found at [GitHub](https://github.com/Sparten/ACInternalMemoryReader).
  
  2. *rFactor 2* and *Le Mans Ultimate*
  
     You can find the plugin *rFactor2SharedMemoryMapPlugin64.dll* in the *Utilities\Plugins* folder of the Simulator Controller installation folder or you can load the [latest version](https://github.com/TheIronWolfModding/rF2SharedMemoryMapPlugin) from GitHub.
	 
	 *rFactor 2*: Copy the DLL file to the *Bin64\Plugins* folder in the Steam installation directory of *rFactor 2*. You will have to enable this plugin in the *rFactor 2* settings afterwards.
	 
	 *Le Mans Ultimate*: Copy the DLL to the *Plugins* folder in the Steam installation directory of *Le Mans Ultimate*. As the time of this writing, there is no way to enable the plugin in the UI of *le Mans Ultimate*. Therefore start the game once, go to the track and drive out the pit. Exit the game and open the file *UserData\player\CustomPluginVariables.JSON* with a text editor and set " Enabled:" to **1**.

  3. *Automobilista 2* and *Project CARS 2*
  
     You have to enable Shared Memory access in the game settings. Please use the PCars 2 mode.

If you have used the quick setup method of "Simulator Setup", the plugins might already have been installed.

### Important preparation for the Pitstop MFD handling in *Assetto Corsa Competizione* and *RaceRoom Racing Experience*

Jona can control the pitstop settings, as you have seen in the dialog transcript above. Generally, this can be handled in the different simulation games using an API integration, with the exception of *Assetto Corsa Competizione* and *RaceRoom Racing Experience*. In the later cases, a special procedure using image recognition has been developed. Please see the documentation for the special preparation steps for [*Assetto Corsa Competizione*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#important-preparation-for-the-pitstop-mfd-handling) and [*RaceRoom Racing Experience*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#important-preparation-for-the-pitstop-mfd-handling-1) that might be necessary.

## Interacting with Jona

Although it is possible, to [use parts of Jona without voice interaction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer), it is not much fun. But to have fun with Jona, you must understand, how the interaction is structured, since in the end, Jona is stupid as bread and only reacts to strong standard patterns. For each language you want to use to interact with Jona, a so called grammar file must exist. As said, grammars for English and German are already there. The grammar files are named "Race Engineer.grammars.XX", where XX is the two letter ISO language code. These files reside in a special folder, either in the *Resources\Grammars* folder of Simulator Controller or in the *Simulator Controller\Grammars* folder in your user *Documents* folder. The later means, that you are able to provide your own grammar files or *overwrite* the existing ones. But be careful with overwriting, since this will introduce a pain in the a..., when updating to new versions.

Tha grammar files define the input patterns which Jona uses to understand you and also all reactions of Jona as predefined phrases. For each reaction, an unlimited number of phrases may exist (typically 2-4 different ones in the predefined grammar files) to provide for an entertaining variety of answers.

### Phrase grammars

Here is a small excerpt from the input setion of the English grammar file:

	[Choices]
	TellMe=Tell me, Give me, What are
	CanWe=Can you, Can we, Please
	[Listener Grammars]
	// Conversation //
	Call=[{Hi, Hey} %name%, {%name% do you hear me, %name% I need you, Hey %name% where are you}]
	Yes={Yes please, Yes go on, Perfect go on, Go on please, Head on please, Okay let's go on}
	No=No {thank you, not now, I will call you later}
	// Information //
	TyrePressures=[(TellMe) {the tyre pressures, the current tyre pressures, the pressures in the tyres}, What are the current pressures]

As you can see, a typical recognition phrase looks like this:

	[(TellMe) {the tyre pressures, the current tyre pressures, the pressures in the tyres}, (TellMe) the current pressures]
	
(TellMe) is a variable for a set of predefined optional filler phrases (in the example above TellMe stands for "Tell me, Give me, What are"). The definition above consists of two different independent phrases, which lead to the same reaction of Jona. This is denoted by the "[..., ...]" bracket construct. For the first phrase the "{..., ..., ...}" defines inner alternatives for this phrase. By using "[" and "{" constructs, you can create a variety of pattern alternatives. But in the end, Jona reacts only to the core words of a phrase, for example "the current pressures" in the above example.

Important: The words of the recognized phrase are reported to the Jona control program and may be analyzed there for further processing. For example, when asking for tyre pressures or temperaturs, the words "front", "left", ... are very important. Therefore be careful, if you change some of the predefined phrases.

Some phrases (input and output) may have additional variables enclosed in "%", as in *%name%* above. These variables are provided by the runtime to customize the questions and answers.

For the reactions of Jona, the format is much more simple. It looks like this:

	[Speaker Phrases]
	// Conversation //
	Greeting.1=Hi, I am %name%, your Race Engineer today. You can call me anytime if you have questions. Good luck.
	Greeting.2=Here is %name%. I am your Race Engineer for this session. Call me anytime.
	Greeting.3=Here is %name%, your Race Engineer. Have a great session.
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

#### List of all voice commands

1. [English version](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Engineer-Commands-(EN))

2. [German version](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Engineer-Commands-(DE))

I strongly recommed to memorize the phrases in the language you use to interact with Jona. You will always find the current version of the grammar files as actually used by the software in the *Resources\Grammars* folder of the Simulator Controller distribution. Or you can take a look at the files in the [Resources\Grammars directory on GitHub](https://github.com/SeriousOldMan/Simulator-Controller/tree/main/Resources/Grammars), for example the German version [Race Engineer.grammars.de](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Resources/Grammars/Race%20Engineer.grammars.de).

#### Extending conversation and reasoning capabilities using an LLM

Beside the builtin pattern-based voice recognition and the speech capabilities based on predefined phrases as described above, it is optionally possible to connect Jona to a GPT service like OpenAI or a locally hosted LLM, to dramatacilly improve the quality in conversation with the Assistant. And you can also extend the knowledge and reasoning capabilities. When the *Conversation* Booster or the *Reasoning* booster are configured (see [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants) for more information about the necessary configuration steps), the full knowledge about the car state will be supllied to the LLM. In detail, this includes tyre pressures, tyre temeperatures, tyre wear, brake temperatures, brake wear, fuel level, fuel consumption, damage, and so on. When a pitstop is planned, the plan is available and the pitstop history is also available.

### Enabling and disabling specific warnings and announcements

Jona will give you a lot of information about fuel level, damages after an accident, and so on. You may disable these warnings individually by using a special voice command:

	[Please] No more *warning* [please]

As you might expect, the word "please" is optional. Available options for *warning* are: "fuel warnings", "damage warnings", "damage analysis", "pressure warnings" and "weather warnings" (when the Assistant Cato is active, it will take the duty for weather warnings). After you have disabled one of the warnings (all are enabled by default), you can reenable it with the following command:

	[Please] Give me *warning* [please]

As an alternative, you can disable unwanted talking completely by saying:

	Be quiet please

To reactivate the Assistant use:

	I can listen now

These commands are also available as "Mute" and "Unmute" plugin actions, which can be configured for a Button Box or a Stream Deck, for example.

## Racing with Jona

Racing with Jona is easy, just begin your session and wait until Jona will contact you. This will be a few seconds after you crossed the start finish line after your first complete lap. Jona will be available in Practice, Qualifying and Race sessions, but the amount of support you can expect from Jona will vary between those session types. Pitstops, for example, will only be handled during race sessions, unless you enable them for other session types in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) tool.

The Virtual Race Engineer is handled by the "Race Engineer" plugin, which may be integrated by the different simulation game plugins, if they want to support Jona. This plugin will start *Race Engineer.exe*, which is located in the *Binaries* folder, as a subprocess, as long as you are out on a track. (Note for developers: The communication between those two processes uses named pipes. For more technical information, see the [technical information](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#technical-information) section below).

Most of the information, that Jona needs, will be collected from the telemetry information of the simulation game. Unfortunately, this data does not contain every required information, and also there are additional data and configuration information, which are required by Jona. For example, data is required to understand the given race situation and the corresponding telemetry information, and to precisely predict tyre pressures, fuel requirements, tyre compound recommendations, and so on. In the end, all that means, that some setup work is required, before you start your session. 

Important: In the default configuration, Jona will be activated in the first lap of a session. This is necessary, so that Jona can setup the initial knowledge (fuel, pressures, etc.). If you join a session later than during the first lap, Jona will refuse to work. This behaviour can be changed with the setting "Engineer: Late Join" in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database), but the behaviour of Jona may be somewhat confusing.

### Race Settings

The additional knowledge Jona needs is stored in a special file, *Race.settings*, that exists in the *Simulator Controller\Config* folder in your user *Documents* folder, which you have to modify for each session. You can do this by editing this file using a text editor or you can use a graphical user interface by using the application *Race Settings.exe* from the *Binaries* folder. As a side note, I am still trying to gather at least the setup part of this information from the simulation game itself.

The *Race.settings* looks like this:

	[Session Settings]
	Lap.AvgTime=106
	Lap.Formation=true
	Lap.PostRace=true
	Lap.PitstopWarning=3
	Fuel.AvgConsumption=2.7
	Fuel.SafetyMargin=3
	Pitstop.Delta=50
	Damage.Bodywork.Repair=Threshold
	Damage.Bodywork.Repair.Threshold=20.0
	Damage.Suspension.Repair=Always
	Damage.Suspension.Repair.Threshold=false
	Tyre.Compound.Change=Never
	Tyre.Compound.Change.Threshold=false
	Tyre.Pressure.Deviation=0.2
	Tyre.Pressure.Correction.Temperature=true
	Tyre.Pressure.Correction.Setup=true
	Tyre.Dry.Pressure.Target.FL=27.7
	Tyre.Dry.Pressure.Target.FR=27.7
	Tyre.Dry.Pressure.Target.RL=27.7
	Tyre.Dry.Pressure.Target.RR=27.7
	Tyre.Wet.Pressure.Target.FL=30.0
	Tyre.Wet.Pressure.Target.FR=30.0
	Tyre.Wet.Pressure.Target.RL=30.0
	Tyre.Wet.Pressure.Target.RR=30.0
	[Session Setup]
	Tyre.Compound=Dry
	Tyre.Compound.Color=Black
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
	[Strategy Settings]
	Extrapolation.Laps=2
	Overtake.Delta=2
	Traffic.Considered=5
	Pitstop.Delta=50
	Service.Tyres=30
	Service.Refuel=1.5

Most options above define general settings which may be applicable to many different race events. But the options from the *[Session Setup]* section need to be adjusted for each individual race event, as long, as you want Jona to come to correct recommendations.

  - The first fresh tyre set (*Tyre.Set.Fresh*), which is available for a pitstop and the tyres and pressures (*Tyre.XXX.Pressure.YY*) used for the first stint. Jona needs this information to calculate the target pressures for the first pitstop.
  - The *Lap.AvgTime* and *Fuel.AvgConsumption* are more informational, but might lead to more accurate estimations for the fuel calulations in the first few laps, where you typically have much slower lap times.

Let's have a look at the settings tool, which provides a graphical user interface for the *Race.settings* file. The dialog provides two distinct areas as tabs.

#### Tab *Race*

The first tab of the settings tool contains information about the actual session, which typically will be a race.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Settings%201.JPG)

You must supply the tyre selection and pressure setup that is used at the beginning of the race in the lower area of the *Race* tab, whereas the static information for the given track and race is located in the upper area. With the "Setups..." button you can open the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) tool to look up the best match for tyre pressures from recent sessions. Beside that, you can use the "Import" button to retrieve the current tyre setup information from your simulation game (this can also be triggered automatically at the beginning of a session depending on the configuration of the Race Engineer). But what data is available for an import depends on the capabilities of the simulator game in use. For example, *Assetto Corsa Competizione* currently only gives access to the tyre pressures that are configured in the Pitstop MFD. But you may use the "Use current pressures" option in the *Assetto Corsa Competizione* "Fuel & Strategy" area to transfer your current tyre setup to the Pitstop MFD and *import* the settings from there. Depending on your currently mounted tyres, the values will be imported as "Dry" or "Intermediate" / "Wet" setup values. Please consult the documentation for the [configuration of the "Race Engineer" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-engineer) for more information on the different methods to initialize the initial pressures at the beginning of a session, and also take a look at the documentation about [handling tyre compounds](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Tyre-Compounds) in general.

The management of tyre sets (mainly used in *Assetto Corsa Competizione*) can be set to "Auto", if you are using automatic import from the simulation. See the discussion about [pitstop handling](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#the-pitstop) below for more information. 

Note: We requested a more versatile access to setup informations from Kunos already. Hopefully, this will be available in a future version of *Assetto Corsa Competizione*, and the whole process will become much less cumbersome. But to be honest, there is even less functionality available at the moment for other simulators.

Additionally worth to be mentioned is the field *Pitstop.Delta*, with which you supply the difference time needed for a normal pitstop (time for pit in and pit out but without any service the time minus the time to pass the pit area on the track). This information is used by Jona to decide, whether an early pitstop for a tyre change or damage repair might be worthwhile.

#### Tab *Pitstop*

The second tab, *Pitstop*, contains information that will be used to derived the settings for a pitstop.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Settings%202.JPG)

The upper area with the three dropdown menus give you you control over several decisions, Jona will take for an upcoming pitstop. For the repair settings you can decide between "Never", "Always", "Threshold" and "Impact".

  - "Threshold" will allow you to enter a value, which defines a level of damage as seconds that will be needed to repair this damage during a pitstop. If the repair duration is above this value, Jona will advise to go for a repair on the next pitstop. The data APIs of the different simulators report damage differently. Typical are values between 0% and 100%, but *Assetto Corsa Competizione*, for example, report a meaningless, although linear rising number. To support a conversion to repair duration, you must set a conversion factor for a given simulator in the [settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database". The conversion factor can be set independently for bodywork, suspension and engine repair, and I will provide a growing number of defaults for the different sims.
  
  - For "Impact" you can also enter a number of seconds. Jona will analyse your lap time and will go for a repair, if your lap time is slower by the number you entered with regards to the reference laps just before the accident. Jona will also consider the time needed for the repair with regards to the remaining session or stint time. Beside that, I advise to go always for a repair for supsension damage, since additional damage in a next accident will most likely be catastrophic.

In many cases it is not a good idea to decide based on the repair duration, whether a repair is useful. Sometimes a damage, for example at the side of the car, has no negative influence on lap time. Therefore I recommend to use the "Impact" rule, at least for bodywork and engine damage, whenever possible. Suspension damage is a different topic, though.

The following table shows, which simulator supports which damage type:

| Simulator                  | Bodywork | Suspension | Engine |
|----------------------------|----------|------------|--------|
| Assetto Corsa              | Yes      | No (1)     | No (1) |
| Assetto Corsa Competizione | Yes      | Yes        | No     |
| Automobilista 2            | Yes      | Yes        | Yes    |
| iRacing                    | No       | No         | No     |
| Project CARS 2             | Yes      | Yes        | Yes    |
| RaceRoom Racing Experience | Yes      | Yes        | Yes    |
| rFactor 2                  | Yes      | No         | No     |
| Le Mans Ultimate           | Yes      | No         | No     |

##### Notes

(1) Supported but not reported in the data API.

For tyre compound changes, you can choose between the triggers "Never", "Tyre Temperature" and "Weather". If you choose "Weather", Jona will advise wet tyres for light rain or worse and dry tyres for a dry track or drizzle. "Tyre Temperature" will allow you to enter a temperature threshold, where Jona will plan a tyre change, if the tyre temeprature falls outside its optimal temperature window by this amount. For dry tyres, the optimal temperature is considered to be above 70 Degrees and for wet tyres below 55 Degrees.

In the lower area you can define the optimal or target tyre pressures. When there is a deviation larger than *Deviation Threshold* from these *Target Pressures* is detected by Jona, corresponding pressure adjustments will be applied for the next pitstop. Beside this very simple approach, there are rules in the AI kernel, which try to predict future influences by falling or rising ambient temperatures and upcoming weather changes, and Jona also might access the session database for a second opinion on target pressures, both depending on the selection of the *Correction* check boxes.

If you open the settings tool, it will load the *Race.settings* file located in the *Simulator Controller\Config* folder in your user *Documents* folder. If you close the tool with the "Ok" button, this file will be overwritten with the new information. Beside that, you can load a settings file from a different location with the "Load..." button and you can save the current settings with the "Save..." button. As an alternative to handle the locations of the settings files yourself, you can use the settings in the session database to organize them. Plesse see the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) for the "Session Database" for further information.

If "Load from Database" has been configured for the settings of all Race Assistants in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-engineer), all settings configured in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) will take precedence over the choices you make in "Race Settings" tool. And both will be superceded by the overarching choices in the [startup profiles](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-profiles).

Good to know: When the *Race.settings* file is changed while Jona or any other Assistant is already active, the updated settings will be imported into the active session. This is useful during Practice, Qualifying or even Race sessions. Please note, that only the driver who has control of the car can do this in a team session.

Beside the session respectively race specific settings described in the previous sections, the general behaviour of the Virtual Race Engineer can be customized using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-engineer).

#### Tab *Strategy*

You will find settings for the race strategy analysis and simulation in the third tab. These settings are mainly used by the Virtual Race Strategist, but some of them, for example the *Pitstop Delta* time or the *Safety Fuel* will also be used by Jona.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Settings%203.JPG)

Please see the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#tab-strategy) in the Virtual Race Strategist chapter for a description of these fields.

#### Tab *Team*

This tab gives you all you need to become a driver in a team session. Whenever you want to participate in a team session, you must connect to the corresponding *Team Server* beforehand using the URI and the access token provided by your team manager and clicking on the "Key" button (if you hold down the Control key, while pressing on the "Key" button, you can use login credentials of the team manager as well). After you have established a valid connection, you can choose the team, your driver name and the sesison you want to join. Please note, that you still might have to activate a team session, before you head out onto the track (see the actions of the ["Team Server" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-team-server), if you want to control this using your Button Box, for example).

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Settings%204.JPG)

The details about the installation, configuration and usage of the *Team Server*, and also about the team administration task in general can be found in the [dedicated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server) for the *Team Server*.

### The Pitstop

The process of the pitstop handling differs between the various supported simulations. Below you will find some simulation specific hints. Please note, that pitstop handling is currently available for *Assetto Corsa*, *Assetto Corsa Competizione*, *rFactor 2*, *Le Mans Ultimate*, *RaceRoom Racing Experience*, *iRacing*, *Automobilista 2* and *Project CARS 2*.

The pitstop is handled by Jona in two phases. In the first phase, the planning phase, Jona creates a list of the necessary activities (refueling, changing tires, repairs) and gives you the chosen service tasks by radio. If you then agree with the selected services, or after you have made any necessary corrections, the settings are transferred to the simulation in the second phase, the preparation phase. After the preparation is finished, you can come to the pit anytime (depending on the simulation, it might be necessary, to activate a "Request pitstop" function as well).

Good to know: If Jona has planned the pitstop based on a request from Cato, the Virtual Race Engineer, the lap in which you should come to the pit is already known. In this case, the preparation phase does not have to be triggered explicitly, since the preparation for the pitstop takes place automatically when you start the selected lap.

Some final notes: If you ever perform a pitstop, which has not been planned and prepared by Jona, Jona will be very confused, say the least. You can do this, but please double check the recommendations of Jona for each subsequent pitstop, especially the chosen tyre set, if you don't want to end up with worn out tyres for your last stint. Also be very careful, when using the "Pitstop" mode on your Button Box to change the pitstop settings. Jona will not know about your changes, and might overwrite them during the pitstop preparation. There is one notable exception, if Jona has planned and prepared a pitstop, but this pitstop has not been carried out yet, every change to the pitstop settings using the "Pitstop" mode will be recognized and taken into account by Jona. If you change pitstop settings using the pitstop menu in the simulation directly, it depends on the data integration support of the given simulator, whether this change is recognized by Jona or not. Please see the following table:

| Simulator                  | Fuel | Tyre Compound | Tyre Set | Tyre Pressures | Repairs |
| -------------------------- | ---- | ------------- | -------- | -------------- | ------- |
| Assetto Corsa              | No   | No            | -        | No             | No      |
| Assetto Corsa Competizione | Yes  | No            | Yes      | Yes            | No      |
| Automobilista 2            | No   | No            | -        | No             | No      |
| iRacing                    | Yes  | No            | -        | Yes            | No      |
| Projects CARS 2            | No   | No            | -        | No             | No      |
| RaceRoom Racing Experience | No   | No            | -        | No             | No      |
| rFactor 2                  | Yes  | Yes           | -        | Yes            | Yes     |
| Le Mans Ultimate           | Yes  | Yes           | -        | Yes            | Yes     |

It is no problem to change the settings marked above with "No" in a case of urgency, but be aware that this might lead to wrong subsequent recommendations by Jona, since the knowledge is not in sync with the reality.

#### *Assetto Corsa Competizione*

Jona can acquire the curent settings directly from *Assetto Corsa Competizione* via API. Jona uses the values already set in the Pitstop MFD and applies the delta to the desired target values. Please note, that this requires the settings in the [*Race Settings*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#tab-race) dialog to be valid. Beside that, I still recommend to setup a reasonable pitstop strategy, since this will reduce the time needed to dial in all those numbers (going from 0 to 120 liters of refueling will take quite some time).

A special case is the management of tyre sets. You can either dial the values of the tyre set mounted at the start of the session and the first fresh tyre set for the first pitstop into the "Race Settings", or you can set both values to "Auto" (or to **0** in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database)). In this case, tyre sets are managed completely by the simulation when it comes to a pitstop.

#### *rFactor 2*

No special setup required for *rFactor 2*, since this simulation has an integrated interface to control the pitstop settings externally.

#### *Le Mans Ultimate*

Same applies to *Le Mans Ultimate*, since this simulation uses the same engine as *rFactor 2*.

#### *iRacing*

No special setup required for *iRacing*, since this simulation has an integrated interface to control the pitstop settings externally.

#### *RaceRoom Racing Experience*

*RaceRoom Racing Experience* does not provide any data interface for initial setup information. So you must take care, that everything is entered correctly into the settings tool, before you head out onto the track. On the other hand, the support for pitstop settings is quite limited in *RaceRoom Racing Experience*, so you might skip tyre pressures and dry vs. wet tyre considerations alltogether.

#### *Automobilista 2* and *Project CARS 2*

Both siimulator do not provide any data interface for initial setup information. Therefore you must take care here as well, that everything is entered correctly into the settings tool, before you head out onto the track.

Furthermore, it is very important, that you do not use the *Automobilista 2* and *Project CARS 2* ICM yourself, while you want Jona to control the pitstop settings or want to use the "Pitstop" mode of the "AMS2" plugin. Additionally, you must leave *all* repairs selected in the default pitstop strategy and select *no tyre change* in the default pitstop strategy as well. Not complying with this requirements will give you funny results at least.

### How it works

Jona uses several statistical models to derive the data, on which the recommendations for the pitstop or other information is based. Therefore it will take some laps, before Jonas conclusion get more and more precise. So be careful, if you let Jona plan a pitstop after you have driven only three or four laps. You might end up with not enough fuel to reach the finish line.

The following statistical models are currently implemented:

  1. Tyre pressure development
  
     The pressure development of the last laps and the deviation from the predefined target pressures are considered to derive pressure corrections for the next pitstop. The number of laps considered and the weighting of past laps can be configured using the settings tool. To get the most precise recommendations, set the *Statistical Window* as large as possible and the *Damping Factor* as small as possible. For example, a statistical window of 10 and a damping factor of 0.1 will consider your last 10 laps, where your most recent lap counts fully and the lap five laps ago only with 50%. Depending on accidents, severe traffic or safety car phases, especially in the most recent laps, the algorithm will come up with unexpected results, so always double check Jonas recommendations here.
	 
	 When planning and preparing a pitstop, Jona will consult the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) for a second opinion on tyre pressures for given temperature and weather conditions. Needless to say, these values are also specific for a given car and track combination. Jona will use the same algorithm as the database tool, therefore extra- or interpolation will be used, when no exact match is available. But in those cases an (un)certainty factor will be applied, so that the dynamically derived target pressures will be considered more relevant.

  2. Tyre pressure loss

     Beside looking at the *normal* tyre pressure development, the artificial intelligence also constantly observes and compares the pressures of all tyres in relation to each other. During the learning laps (see the ["Race Engineer" configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-engineer) for more information), a reference pressure is derived for each tyre. When the actual tyre pressure deviates more than other tyres from this reference pressure (actual the average of all deviations plus the standard deviation of all deviations is used as a threshold), than the artificial intelligence assumes that the tyre is loosing pressure, either by a sudden hit on a curb or slowly as a result of a puncture, and you will be informed about that by the Race Engineer. The pressure loss can alo be taken into account when planing and preparing the next pitstop, but you have to activate this feature in the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-settings). Please always double-check the recommendation in this case, because the reported pressure loss could also have been a result of wrong cold pressures right from the start, which might give you even more underflated tyres at the end.

  3. Refuel amount
  
     Depending on the number of remaining laps and average fuel comsumption, Jona derives the exact amount of fuel required for the next stint. As for the tyre pressures, the lap weight of past laps may be configured for the fuel average calculation, so the remarks above on statistical window and damping factor are valid here as well.
	 
  4. Damage related lap time degration
  
     After Jona detects a new damage, the devlopment of your lap times are observed and Jona might suggest an adopted pitstop strategy, depending on remaining stint time and the delta time necessary for a pitstop. The underlying model is quite complex and recognizes and excludes special lap situations like pitstops, accidents, and so on, from the average laptime calculation. All laps of the current stint (except a couple of laps at the beginning) are considered by the algorithm and the average lap time incl. the standard deviation before the accident will be taken as the reference lap time. This means, that the computation will fail, if you had an accident very early in your stint, since you never had the chance to set a good reference lap.
	 
	 The following damage categories are supported for the different simulators:
	 
	 | Simulator                  | Bodywork & Aerodynamics | Suspension & Chassis | Engine |
     | -------------------------- | ----------------------- | -------------------- | ------ |
     | Assetto Corsa              | Yes (1)                 | No (1)               | No (1) |
     | Assetto Corsa Competizione | Yes                     | Yes                  | No     |
     | Automobilista 2            | Yes                     | Yes                  | Yes    |
     | iRacing                    | No                      | No                   | No     |
     | Projects CARS 2            | Yes                     | Yes                  | Yes    |
     | RaceRoom Racing Experience | Yes                     | Yes                  | Yes    |
     | rFactor 2                  | Yes (1)                 | No (1)               | No (1) |
     | Le Mans Ultimate           | Yes (1)                 | No (1)               | No (1) |
	 
	 (1) It looks like the damage is reported by the corresponding API as an accumulated value for all different damage types. The damage will be reported by the Race Engineer as adamage to the Bodywork and only Bodywork repair will therefore automatically recommended for a pitstop. Select the other repair categories manually as needed.
	 
  5. Repair recommendations
  
     Based on the same model, Jona suggests repairs for the upcoming pitstop. You can configure various strategies (Repair Always, Repair Never, Repair when damage is above a given threshold, ...) using the settings tool.
	 
	 Some remarks regarding simulator specific restrictions for the different damage types:
	 
	 - *Assetto Corsa*
	   
	   Bodywork repair will be recommended, but you have to select suspension or engine repair on your own as needed.
	 
	 - *Assetto Corsa Competizione*
	   
	   Bodywork and suspension repair will be handled automatically, but although there is an engine warning light available in the HUDs, no data is available in the API regarding the current engine state. And it looks like configurable engine repair during pitstops is not supported as well.
	   
	 - *Automobilista 2* and *Project CARS 2*
	   
	   Repair recommendations will be given for all damage types.
	   
	 - *iRacing*
	   
	   No automatic support, you must select the "Quick fix" option for the upcoming pitstop manually.
	   
	 - *RaceRoom Racing Experience*
	   
	   Repair recommendations will be given for all damage types.
	 
	 - *rFactor 2* and *Le Mans Ultimate*
	 
	   Since the damage types are not distinguishable in the API, only bodywork & aerodynamics damage will be recommended. Handle other damage types manually.
	 
  6. Tyre pressure gambling
  
     Linear regression models are used here, depending on the development of ambient, track and tyre temperatures and the resulting tyre pressure development, Jona might suggest higher or lower pressures for the next pitstop than currently might be perfect as a result of a clear past trend, thereby probably giving you a good compromise for the upcoming stint.
	 
  7. Weather trend analysis and tyre compound recommendation
  
     Beginning with Release 2.5, a weather model has been integrated in the working memory. The raw data is acquired from the simulation. For example, *Assetto Corsa Competizione*, *rFactor 2*, *Le Mans Ultimate*, *Automobilista 2* and *Project CARS 2* supply current weather information ranging from "Dry" up to full "Thunderstorm". *Assetto Corsa Competizione* goes even further and can supply a full weather forecast from now on up to 30 minnutes into the future. Based on this information and currently mounted tyres, Jona will recommend a tyre change. This recomendation will be incorporated into the plan for an upcoming pitstop depending on the settings you have chosen in the [settings dialog](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-settings).
	 
	 All applications of Simulator Controller, incl. the Race Engineer, support three different tyre categories (Dry, Intermediate and Wet), as well as a couple of mixtures for each category. The combination of both is a tyre compound, for example "Dry (M)", a dry tyre (aka Slick) with a medium hardness. Please read the chapter [Tyre Compounds](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Tyre-Compounds) carefully for more information and especially for the mapping of simulator specific tyre compounds to the tyre model of Simulator Controller. Jona uses the tyre model to recommend the best possible tyre compound for the given weather conditions.
	 
	 | Weather      | Suitable Category | Optimal Category |
     | ------------ | ----------------- | ---------------- |
     | Dry          | Dry               | Dry              |
     | Drizzle      | Dry, Intermediate | Intermediate (1) |
     | Light Rain   | Intermediate, Wet | Intermediate (1) |
     | Medium Rain  | Wet               | Wet              |
     | Heavy Rain   | Wet               | Wet              |
     | Thunderstorm | Wet               | Wet              |
     
     (1) If no Intermediates are available, Dry Tyres will be used in Drizzle conditions and Wet Tyres in Light Rain conditions.
	 
	 Looking at the above table, you can understand when and why a tyre change will be recommended by the Jona. As long as the currently mounted tyre has a suitable category, no urgent pitstop will be requested. If you come in for a regular pitstop, the tyre compound with the optimal category will always be chosen, as long as it is available (see note (1)). But in the case, that the currently mounted tyre is not suitable for the current or upcoming weather conditions, an urgent pitstop will be requested and the optimal tyre compound will be chosen, if available.
	 
	 Finally some remarks regarding simulator specific restrictions:
	 
	 - *Assetto Corsa*
	   
	   Tyre Compounds are supported as described in the [Tyre Compounds](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Tyre-Compounds#using-tyre-compounds) chapter, but no weather model is available.
	 
	 - *Assetto Corsa Competizione*
	   
	   Everything works as designed, but only Dry and Wet tyre categories without different mixtures are available.
	   
	 - *Automobilista 2* and *Project CARS 2*
	 
	   Both simulator share the same engine, therefore everything applies to both. The API does not provide any information about the currently mounted tyre compound. So make sure, that the initial mounted tyres are specified correctly in the "Race Settings". Additionally, weather information is not available for the future, so weather warnings might come in a *little bit* late.
	   
	 - *iRacing*
	   
	   *iRacing* neither provides a weather model nor a sophisticated tyre model with different compounds. SO nothing to see her and move on.
	   
	 - *RaceRoom Racing Experience*
	   
	   Tyre Compounds are supported as described in the [Tyre Compounds](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Tyre-Compounds#using-tyre-compounds) chapter, but no weather model is available.
	 
	 - *rFactor 2* and *Le Mans Ultimate*
	   
	   Tyre Compounds are supported as described in the [Tyre Compounds](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Tyre-Compounds#using-tyre-compounds) chapter. Weather information is not available for the future, so weather warnings might come in a *little bit* late. There might be a possibility to parse the weather control history, this will be implemented in a future release.
	 
Note: Extrem changes in the conditions, for example an incoming thunderstorm on a previously dry and hot track, will result in extreme variances in the statistical models and thereby will lead to strange recommendations in many cases. This is a drawback for the moment, so always double-check under those circumstances. Jona will use the data collection of recent races, if available, to guess the best possible combination of tyre compound and pressures, but especially in changing conditions tyre pressures may be way off. So double check the recommendations fo the Race Engineer against your own experiences and gut feeling.

Additional notes for *iRacing* users: It looks like that tyre pressures and also to some extent tyre temperatures for most of the cars are not available in the *iRacing* live data. To make it worse, damage information is also not available in the API, although *iRacing* apparently has a sophisticated damage model. Since *iRacing* is a quite mature (not to say old) simulation game, and the API hasn't changed in a while, I am quite pessimistic, that this will be fixed. Therefore, the recommendations of the Virtual Race Engineer will be at best limited and in some cases even false. Nevertheless, Jona will help you with refuel recommendation for an upcoming pitstop and you will have someone to talk to while hunting down your opponent on the long straights.

## Technical information

This section will give you some background information about the inner workings of Jona. To understand the most of it, you need some background knowledge about programming. Therefore, if you never have coded just a tiny bit, you can safely skip this section.

The most important part of Jona, beside the natural language interface, which has been described above, is the [Rule Engine](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine) and the knowledge base, the rules work with. The major part of the knowledge base consists of a history of past events, which is used by the rules to give Jona a kind of memory and allows the bot to interact in a context-sensitive manner. The history is also used by the rules to infere future trends, for example, a projection of target tyre pressures for long stints in an evening session, when the air and track temperatures are falling. Past and future weather trend information will be integrated as well, when they are available. Jona is able to recommend whether a repair of a damage be worth of for the next pitstop by calculating the historic impact of the damage on your lap time, and so on. Not all of this has been implemented completely in the alpha version of Jona, but the genetics are all there.

Below you will find a short intrduction to the rule engine and the knowledge base for a general understanding. For a complete documentation targeted at developers, see [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine).

### The Rule Engine

The rule engine used for Jona and the other Assistants implements support for a hybrid approach, which means, that rules can produce new knowledge from given knowledge, called forward chaining, or rules can be used to prove a hypothesis by reducing it to more and more simple questions until all those question has been answered or no more possibilities are available, which means, that the hypothesis is considered to be false. This is called backward chaining and the most prominent representative for this kind of logical computation is the programming language Prolog.

Forward chaining rules (aka Productions) look like this:

	{All: [?Pitstop.Plan], [?Tyre.Pressure.Target.FL]} =>
		(Set: Pitstop.Planned.Tyre.Pressure.FL, ?Tyre.Pressure.Target.FL),
		(Set: Pitstop.Planned.Tyre.Pressure.FL.Increment, !Tyre.Pressure.Target.FL.Increment)

This rule, for example, is triggered, when a new pitstop plan had been requested (*[?Pitstop.Plan]*) and when at the same time a target pressure for the front left tyre had been derived (typically by another rule). The rule above then *fires* and thereby copies this information to the pitstop plan.

A backward chaining rule (aka Reduction) is typically used for calculations and looks like this:

	updateRemainingLaps(?lap) <=
		remainingStintLaps(?lap, ?stintLaps), remainingRaceLaps(?lap, ?raceLaps),
		?stintLaps < ?raceLaps, Set(Lap.Remaining, ?stintLaps)

	lowFuelWarning(?lap, ?remainingLaps) <= pitstopLap(?lap), !, fail
	lowFuelWarning(?lap, ?remainingLaps) <= Call(lowFuelWarning, ?remainingLaps)
	
In this example, the rule *updateRemainingLaps* calculates the number of laps, which remains with the current amount of fuel. Or, as an alternative route, it might consider the remaining stint time of the current driver. The result is then updated in the memory as the *Lap.Remaining* fact, which might trigger other rules. One of these rules might then invoke *lowFuelWarning*, the second part of the example above. This rule calls the external function *lowFuelWarning*, which in the end let Jona call you and tell you, that you are running out of fuel. As you can see by the first instance of the rule *lowFuelWarning*, this call is only issued, when the current lap (*?lap*) is not a lap, where the driver has pitted.

You can find the rules of Jona in the file *Race Engineer.rules* which resides in the *Resources\Rules* folder in the installation folder of Simulator Controller. As always, you are able to overwrite this file by placing a (modified) copy in the *Simulator Controller\Rules* folder in your user *Documents* folder. This might be or might not be a good idea, depending on your programming skills in logical languages.

### Interaction States

At this time, Jona can handle three important states in its knowledge base.

  - A pitstop has been planned
  - A pitstop has been prepared, which means that all the settings had been transferred to the simulation game, for example to the Pitstop MFD of *Assetto Corsa Competizione*
  - The car is in the pit and the crew is working on the car
  
You can trigger the first two states, as long as logical for the given situation, by setting the facts *Pitstop.Plan* or *Pitstop.Prepare* to *true* in the knowledge base. The rule network will do the rest. An undertaken pitstop must be triggered by setting *Pitstop.Lap* to the lap number, where the driver pitted. All this is handled by the *RaceEngineer* class already, so there is no need to do this at the knowledge base level. But it is important to know, that these states exist, in order to undertstand Jonas reactions to your requests. For example, Jona first wants to plan a pitstop before you enter the pit, which is quite logical, right?

### Jonas Memory

The content of the knowledge base of Jona or the facts, as these are called in the world of rule engines, can be divided into three categories:

  - *Historical information:* Here, all recent laps and pitstops are memorized to build a base of historic data for trend anlysis.
  - *Derived future predictions:* In this category fall the state information described above, for example the projected settings for the next pitstop.
  - *Real working memory:* Jona constantly calculates future trends and events, like low fuel in a few laps. These projected values are stored in the memory as well.
  
For historical information, the format is quite simple. All facts for a past lap start with *Lap.X* where X is the lap number. A similar format is used for pitstops, *Pitstop.X*, where X is the pitstop number here. Normally you will have more laps than pitstops in the memory, except you are me in a reverse grid league race, hey?
The derived future predictions is typically categorized by the first part of the fact name, for example *Tyre* for all knowledge about the current and projected tyre state.

You can take a look at the knowledge base by enabling "Debug" mode in the configuration, as described in the [Troubleshooting](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#troubleshooting) section. By doing this, you will pay a performance penalty, which might or might not be noticeable depending on your hardware.

### Telemetry Integration

A considerable part of the knowledge of Jona comes from the telemetry information of the simulation game. As said, data providers for *Assetto Corsa*, *Assetto Corsa Competizione*, *RaceRoom Racing Experience*, *rFactor 2*, *Le Mans Ultimate*, *iRacing*, *Automobilista 2* and *Project CARS 2* are already builtin. The special plugin "Race Engineer" collects the data from the simulation games and hands it over to Jona. Small applications like "ACC SHM Provider.exe" or "RF2 SHM Provider.exe", which are located in the *Binaries* folder, are used to acquire the data. They run periodically and output the following data:

	[Car Data]
	BodyworkDamage=0, 0, 0, 0, 0
	SuspensionDamage=0, 0, 0, 0
	FuelRemaining=54.6047
	TyreCompound=Dry
	TyreCompoundColor=White
	TyreTemperature=84.268, 74.6507, 85.6955, 77.2675
	TyrePressure=27.6296, 27.6063, 27.6666, 27.5575
	Map=1
	TC=2
	ABS=3
	[Stint Data]
	DriverForname=The
	DriverSurname=BigO
	DriverNickname=TBO
	Sector=2
	Laps=3
	LapLastTime=116697
	LapBestTime=116697
	StintTimeRemaining=1.41874e+06
	DriverTimeRemaining=1.41874e+06
	InPit=false
	[Track Data]
	Temperature=25.5913
	Grip=Optimum
	[Setup Data]
	TyreCompound=Dry
	TyreCompoundColor=White
	TyreSet=2
	FuelAmount=0
	TyrePressureFL=25.3
	TyrePressureFR=26.6
	TyrePressureRL=25
	TyrePressureRR=26.2
	[Weather Data]
	Temperature=22.9353
	Weather=Dry
	Weather10min=Dry
	Weather30min=Dry
	[Session Data]
	Active=true
	Paused=false
	Session=Race
	Car=mclaren_720s_gt3
	Track=Paul_Ricard
	FuelAmount=125
	SessionFormat=Time
	SessionTimeRemaining=1.41874e+06
	SessionLapsRemaining=9

The shared memory of the simulation games typically provide a lot more information, but this is all that is needed for Jona at the moment. Future versions of Jona will incorporate more data, as Jona gets smarter. For example, version 1.7 of *Assetto Corsa Competizione* introduced updated information for weather information and the current settings of the Pitstop MFD, which had been incorporated into the above telemetry file.

The "Race Engineer" plugin writes this information to a temporary file and hands it over to Jona for each new lap. A special case is the flag *InPit*. If this is found to be *true*, the driver is currently in the pit. In this case, the ACC plugin informs Jona about this by raising the corresponding event. Another special case is the flag *Active* which is used to detect, whether you are in a simulation (Practice, Qualifying, Race, whatever) right now. Not every simulation may provide all data as in the example above. In this case, a default value will be assumed.

The *[Setup Data]* section reference the settings at the start of the session and must only be written by the data provider, if the *-Setup* option has been passed to the process. These information are ussed in the pitstop preparation process and also by the *Race Settings* when importing the initial setup data.

Note: If you are a developer and want to take the challenge to adopt Jona to a different simulation game, you are welcome. You can use the "RF2" plugin code and the above file format as a blueprint, but the shared memory interface of each simulation game is different. Please feel free to contact me, if you have questions. I would be happy to integrate plugins for other simulation games into Simulator Controller in the future.

## Troubleshooting

The biggest hurdle to overcome when using Jona, is to find a satisfying setting for voice recognition. Here are some hints:

  - I strongly recommend to use a head set. Although it is possible, and I have tested it myself, to talk to Jona using a desktop or webcam microphone, it is hard to find a satisfying setup. Typically, you will get a couple of false positives in this scenario, while the V12 sound from the Aston Martin is hammering from the speakers. You have been warned...
  - Even when using headset, you might get false positives. The reason for that, normally is a too sensitive microphone level. Reduce the input level of the microphone as low as possible in the Windows audio devices settings, so that Jona still recognizes your spoken words, but does not interpret your sighs and breath noises as valid input.
  - If voice recognition is not working at all, you might need to unblock the DLLs. Follow the instructions in the [installation section](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#installation-of-speech-recognition-libraries) above.
  - Although it is very helpful to be able to talk to Jona anytime, you might consider to use the *Push-To-Talk* functionality introduced with release 2.4. Please consult the corresponding [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control) on how to configure this feature, which will eliminate false positives almost completely.
  - Most important: Learn the phrases, which are defined as input for Jona. Sometimes, only a somewhat different pronounciation is needed, and everything is fine. As a last line of defence, define your own input grammar as described above in the section about [phrase grammars](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#phrase-grammars). But doing this will make your upgrade path for future versions much more complicated.

It has been reported, that the system sound volume gets sometimes significantly reduced, when voice recognition is active. In most cases, it will help to enable [*Push-To-Talk*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control), since the sound volume reduction should then only happen while you are holing down the *Push-To-Talk* button. If this does not help, you can try to uncheck the sound enhacement option in the properties dialog of your select Microphone, but you might encounter reduced recognition quality afterwards.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Microphon%20Properties.JPG)

Beside that, when you encounter false recommendations from Jona, you might take a look into the brain of Jona to see, why Jona arrived at those conclusions. You can do this by enabling "Debug" mode in the configuration. In the next run, Jona will periodically dump its knowledge to the file "Race Engineer.knowledge" in the folder *Simulator Controller\Temp* that resides in your user *Documents* folder. If you think, that you have found a bug in Jonas behaviour, it would be very helpful for me, when you attach this file to any reported issue.

And, last but not least, you might have a problem with the Shared Memory Reader for a simulation game. Please check, if files named "Race Engineer Lap X.Y.data" (where X and Y are consecutive running numbers) exists in the *Simulator Controller\Temp\XXX Data* folder (where XXX is the three letter short code for the simulation), which is located in your user *Documents* folder. Use a text editor to check whether these files have a content as shown a bove in the section about [telemetry integration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#telemetry-integration). If these files do not exist or haven't a meaningful content, you might try a complete reinstall.

If you still have problems with voice recognition, you might try this combination:

  1. Disable voice recognition by supplying *raceAssistantListener: false* as argument for the ["Race Engineer" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer).
  2. Configure all necessary options you want to use for the ["Pitstop" mode](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-pitstop) for example for the ACC plugin, especially for the *pitstopCommands* *PitstopPlan* and *PitstopPrepare*.

With this setup, Jona will be there and inform you about low fuel, damages and so on, but you have to use the Button Box to initiate pitstop planning and preparation. You will miss out all the eloquent conversations with Jona, but functionality wise, you are almost on par.