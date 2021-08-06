## Introduction

Welcome to Jona, the world first fully interactive and AI-based Virtual Race Engineer for race car simulations.

Ok, enough marketing bullshit. Jona is a voice chat bot with a special knowledge about racing. It uses the telemetry data provided by a simulation game and a large domain specific rule set to derive its knowledge from there. Using this knowledge, Jona can give you information about the current state of your car (temperatures, pressures, remaining laps, upcoming pitstops, and so on), and can recommend settings for the next pitstop. Currently, Jona supports the *Assetto Corsa Competizione*, *RaceRoom Racing Experience*, *rFactor 2*, *iRacing* and *Automobilista 2* simulation games through their respective plugins. Using the Pitstop MFD handling for *Assetto Corsa Competizione* introduced with [Release 2.0](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-20), Jona is even capable to setup a pitstop without user interaction completely on its own. Step by step, this will be made available for all simulations, where this is possible (currently *Assetto Corsa Competizione*, *rFactor 2*, *RaceRoom Racing Experience* and *iRacing* are supported, although the support for *RaceRoom Racing Experience* and also *iRacing* is somewhat limited).

***

Before we head on, an important note: Depending on the simulation, the race assistants can not be used in a team race, since the required data is not availabe, when you are not the currently active driver.  I have concepts for a server based solution in the drawer, which will allow Jona to act as a race engineer for a complete team multiplayer endurance race. But this will be quite a huge undertaking and will take a while, depending on my available time to invest in this project.

***

As said above, Jona is a voice chat bot and therefore you can control Jona completely by voice. If you don't want to use voice control, there are other possibilities as well. More on that later in this documentation.

Before we dig deeper into the inner workings, here is a typical dialog based interaction, to give you an understanding of the current capabilities of Jona.

Important: If you have multiple *dialog partners* active, for example Jona and Cato, it will benecessary to use the [activation phrase](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#voice-commands) the first time you start talking to a specific *dialog partner*.

### A typical dialog

**Jona: "Hi, here is Jona, your race engineer today. You can call me anytime if you have questions. Good luck."**

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

Not much to do here, since Jona is a fully integrated component of the Simulator Controller package. Of yourse, you have to configure the Simulator Controller software, before you can use the Virtual Race Engineer. Please read the [installation documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration) for a complete overview of the steps required. You might want to have a look at the ["Race Engineer" plugin arguments](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer), since this plugin controls Jona during your simulator sessions. And you might have to install (additional) voice support in your Windows operating system depending on the Windows isntallation you have.

### Installation of additional Voices

Almost every Windows installation already has builtin support for voice generation (called TTS, aka text-to-speech). If you want to install more voices (and Jona will use all of them according to the configured language), you might want to install some additional packages. Depending on your Windows license you can do this on the windows settings dialog as described in the [Microsoft documentation](https://support.microsoft.com/en-us/office/how-to-download-text-to-speech-languages-for-windows-10-d5a6b612-b3ae-423f-afa5-4f6caf1ec5d3) ([German version](https://support.microsoft.com/de-de/office/herunterladen-von-text-zu-sprache-sprachen-f%C3%BCr-windows-10-d5a6b612-b3ae-423f-afa5-4f6caf1ec5d3)). The current version of Jona comes with translations for English and German, as these are the languages supported by Simulator Controller out of the box. Therefore I recommend to install voices for these languages at least.

### Installation of Speech Recognition Libraries

The installation of the voice recognition engine sometimes needs a little bit more effort. Jona relies on the speech recognition runtime from Microsoft, which is not necessarily part of a Windows standard distribution. You can check this in your settings dialog as well. If you do not have any voice recognition capabilities available, you can use the installer provided for your convenience in the *Utilities\3rd party* folder, as long you have a 64-bit Windows installation. Please install the runtime first and the two provided language packs for English and German afterwards. Alternatively you can download the necessary installation files from [this site at Microsoft](https://www.microsoft.com/en-us/download/details.aspx?id=16789).

After installing the language packs, it might be necessary to unblock the recognizer DLLs of Jona, which are provided in the *Binaries* folder. Windows might have blocked these DLLs for security reasons, because you downloaded it from a non-trusted location. You will find a little Powershell script in the *Utilities* folder, which you can copy to the *Binaries* folder and execute it there with Administrator privileges. These are the commands, which need be executed:

	takeown.exe /F . /R /D N
	Get-ChildItem -Path '.' -Recurse | Unblock-File

Note: Since the time for offline voice recognition is almost over, a future version of Jona will use Google, Amazon or Azure services for voice recognition. But this might be a pay per use kind of service.

### Installation of Telemetry Providers

Jona acquires telemetry data from the different simulation games using so called telemtry providers, which in most cases read the [required data](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#telemetry-integration) from a shared memory interface. In most cases these are already included in Simulator Controller and there is nothing to do, but for *rFactor 2*, you need to install a plugin into a special location for the telemetry interface to work. You can find the plugin in the *Utilities\3rd Part\rf2_sm_tools_3.7.14.2.zip* or you can load the [latest version](https://github.com/TheIronWolfModding/rF2SharedMemoryMapPlugin) from GitHub. A Readme file is included. For *Automobilista 2*, you have to enable Shared Memory access in the game settings. Please use the PCars 2 mode.

## Interacting with Jona

Although it is possible, to [use parts of Jona without voice interaction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer), it is not much fun. But to have fun with Jona, you must understand, how the interaction is structured, since in the end, Jona is stupid as bread and only reacts to strong standard patterns. For each language you want to use to interact with Jona, a so called grammar file must exist. As said, grammars for English and German are already there. The grammar files are named "Race Engineer.grammars.XX", where XX is the two letter ISO language code. These files reside in a special folder directory, either in the *Resources\Grammars* folder of Simulator Controller or in the *Simulator Controller\Grammars* folder in your user *Documents* folder. The later means, that you are able to provide your own grammar files or *overwrite* the existing ones. But be careful with overwriting, since this will introduce a pain in the a..., when updating to new versions.

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
	
(TellMe) is a variable for a set of predfined optional filler phrases (in the example above TellMe stands for "Tell me, Give me, What are"). The definition above consists of two different independent phrases, which lead to the same reaction of Jona. This is denoted by the "[..., ...]" bracket construct. For the first phrase the "{..., ..., ...}" defines inner alternatives for this phrase. By using "[" and "{" constructs, you can create a variety of pattern alternatives. But in the end, Jona reacts only to the core words of a phrase, for example "the current pressures" in the above example.

Important: The words of the recognized phrase are reported to the Jona control program and may be analyzed there for further processing. For example, when asking for tyre pressures or temperaturs, the words "front", "left", ... are very important. Therefore be careful, if you change some of the predefined phrases.

Some phrases (input and output) may have additional variables enclosed in "%", as in *%name%* above. These variables are provided by the runtime to customize the questions and answers.

For the reactions of Jona, the format is much more simple. It looks like this:

	[Speaker Phrases]
	// Conversation //
	Greeting.1=Hi, I am %name%, your race engineer today. You can call me anytime if you have questions. Good luck.
	Greeting.2=Here is %name%. I am your race engineer for this session. Call me anytime.
	Greeting.3=Here is %name%, your race engineer. Have a great session.
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

I strongly recommed to memorize the phrases in the language you use to interact with Jona. You will always find the current version of the grammar files in the *Resources\Grammars* folder of the Simulator Controller distribution. Or you can take a look at the files in the [Resources\Grammars directory on GitHub](https://github.com/SeriousOldMan/Simulator-Controller/tree/main/Resources/Grammars), for example the German version [Race Engineer.grammars.de](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Resources/Grammars/Race%20Engineer.grammars.de).

## Racing with Jona

Racing with Jona is easy, just begin your session and wait until Jona will contact you. This will be a few seconds after you crossed the start finish line after your first complete lap. Jona will be available in Practice, Qualification and Race sessions, but the amount of support you can expect from Jona will vary between those session types. Pitstops, for example, will only be handled during race sessions.

The Virtual Race Engineer is handled by the "Race Engineer" plugin, which may be integrated by the different simulation game plugins, if they want to support Jona. This plugin will start *Race Engineer.exe*, which is located in the *Binaries* folder, as a subprocess, as long as you are out on a track. (Note for developers: The communication between those two processes uses named pipes. For more technical information, see the [technical information](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#technical-information) section below).

Most of the information, that Jona needs, will be collected from the telemetry information of the simulation game. Unfortunately, this data does not contain every required information, and also there are additional data and configuration information, which are required by Jona. For example, data is required to understand the given race situation and the corresponding telemetry information, and to precisely predict tyre pressures, fuel requirements, tyre compound recommendations, and so on. In the end, all that means, that some setup work is required, before you start your session. 

### Race Settings

That said, we now come to an unpleasant part of the game, at least for the moment. The additional knowledge Jona needs is stored in a special file, *Race.settings*, that exists in the *Simulator Controller\Config* folder in your user *Documents* folder, which you have to modify for each session. You can do this by editing this file using a text editor or you can use a graphical user interface by using the application *Race Settings.exe* from the *Binaries* folder. As a side note, I am still trying to gather at least the setup part of this information from the simulation game itself.

The *Race.settings* looks like this:

	[Session Settings]
	Duration=3600
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

You must supply the tyre selection and pressure setup, that is used at the beginning of the race, in the lower area of the *Race* tab, wherease the static information for the given track and race is located in the upper area. With the "Setups..." button you can open the [setup database query tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#querying-the-setup-database) to look up the best match for tyre pressures from recent sessions. Beside that, you can use the "Import" button to retrieve the current tyre setup information from your simulation game. But which data are available for an import depends on the capabilities of the simulator game in use. For example, *Assetto Corsa Competizione* currently only gives access to the tyre pressures that are configured in the Pitstop MFD. But you may use the "Use current pressures" option in the *Assetto Corsa Competizione* "Fuel & Strategy" area to transfer your current tyre setup to the Pitstop MFD and *import+ the settings from there. Depending on your currently mounted tyres, the values will be imported as "Dry" or "Wet" setup values. As a convenience shortcut, the *Import* operation can also be triggered by your hardware controller without opening the settings dialog, which might be all you need during a race preparation. Please consult the documentation for the ["Race Engineer" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) on how to do this.

Note: We requested a more versatile access to setup informations from Kunos already. Hopefully, this will be available in a future version of *Assetto Corsa Competizione*, and the whole process will become much less cumbersome. But to be honest, there is even less functionality available at the moment for other simulators.

Additionally worth to be mentioned is the field *Pitstop.Delta*, with which you supply the difference time needed for a normal pitstop (time for pit in and pit out but without any service the time minus the time to pass the pit area on the track). This information is used by Jona to decide, whether an early pitstop for a tyre change or damage repair might be worthwhile.

#### Tab *Pitstop*

The second tab, *Pitstop*, contains information that will be used to derived the settings for a pitstop.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Settings%202.JPG)

The upper area with the three dropdown menus give you you control over several decisions, Jona will take for an upcoming pitstop. For the repair settings you can decide between "Never", "Always", "Threshold" and "Impact", where "Threshold" will allow you to enter a value. If the current damage is above this value, Jona will advise to go for a repair on the next pitstop. Please note, that these values are NOT to be confused with the number of seconds for example shown on the *Assetto Corsa Competizione* Pitstop MFD, which references the number of seconds it will take to repair the damage. Typically a good threshold for bodywork damage will be between 30 and 40, but it strongly depends on the type of damage (front/rear or on the sides). For supsension damage, I advise to go always for a repair, but you might also use a threshold range around 5. For "Impact" you can enter a number of seconds. Jona will analyse your lap time and will go for a repair, if your lap time is slower by the number you entered with regards to a reference lap before the accident.

For tyre compound changes, you can choose between the triggers "Never", "Tyre Temperature" and "Weather". If you choose "Weather", Jona will advise wet tyres for light rain or worse and dry tyres for a dry track or drizzle. "Tyre Temperature" will allow you to enter a temperature threshold, where Jona will plan a tyre change, if the tyre temeprature falls outside its optimal temperature window by this amount. For dry tyres, the optimal temperature is considered to be above 70 Degrees and for wet tyres below 55 Degrees.

In the lower area you can define the optimal or target tyre pressures. When there is a deviation larger than *Deviation Threshold* from these *Target Pressures* is detected by Jona, corresponding pressure adjustments will be applied for the next pitstop. Beside this very simple approach, there are rules in the AI kernel, which try to predict future influences by falling or rising ambient temperatures and upcoming weather changes, and Jona also might access the setup database for a second opinion on target pressures, both depending on the selection of the *Correction* check boxes.

If you open the settings tool, it will load the *Race.settings* file located in the *Simulator Controller\Config* folder in your user *Documents* folder. If you close the tool with the "Ok" button, this file will be overwritten with the new information. Beside that, you can load a settings file from a different location with the "Load..." button and you can save the current settings with the "Save..." button. As an alternative to handle the locations of the settings files yourself, you can use the setup database to organize them. Plesse see the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race--setup-database) for the setup database for further information.

Good to know: When the *Race.settings* file is changed while Jona is already active, the updated settings will be imported into the active session. This is useful during Practice, Qualification or even Endurance Race sessions. And, if you click on the blue label of the dialog title, this documentation will be opened in your browser.

Beside the session respectively race specific settings described in the previous sections, the general behaviour of the Virtual Race Engineer can be customized using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-engineer).

#### Tab *Strategy*

You will find settings for the race strategy analysis and simulation in the third tab. These settings are mainly used by the Virtual Race Strategist, but some of them, for example the *Pitstop Delta* time will also be used by Jona.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Settings%203.JPG)

Please see the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#tab-strategy) in the Virtual Race Strategist chapter for a description of these fields.

### The pitstop

The process of the pitstop handling differs between the various supported simulations. Below you will find some simulation specific hints. Please note, that pitstop handling is currently available for *Assetto Corsa Competizione*, *rFactor 2*, *RaceRoom Racing Experience*, *iRacing* and *Automobilista 2*.

The pitstop is handled by Jona in two phases. In the first phase, the planning phase, Jona creates a list of the necessary activities (refueling, changing tires, repairs) and gives you the chosen service tasks by radio. If you then agree with the selected services, or after you have made any necessary corrections, the settings are transferred to the simulation in the second phase, the preparation phase. After the preparation is finished, you can come to the pit anytime (depending on the simulation, it might be necessary, to activate a "Request pitstop" function as well).

Good to know: If Jona has planned the pitstop based on a request from Cato, the Virtual Race Engineer, the lap in which you should come to the pit is already known. In this case, the preparation phase does not have to be triggered explicitly, since the preparation for the pitstop takes place automatically when you start the selected lap.

A final warning: If you ever perform a pitstop, which has not been planned and prepared by Jona, Jona will be very confused, say the least. You can do this, but please double check the recommendations of Jona for each subsequent pitstop, especially the chosen tyre set, if you don't want to end up with worn out tyres for your last stint.

#### *Assetto Corsa Competizione*

To enable Jona to handle the pitstop settings in *Assetto Corsa Competizione* completely on its own, you have to prepare some things beforehand. First you have to follow the instructions in the [update information for Release 2.0](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-20), so that the ACC plugin is able to control the Pitstop MFD of *Assetto Corsa Competizione*.

Before Release 2.6, you had to setup your ACC pitstop strategy in a special way for as many pitstops you expect in the given race (plus some more for a safety margin):

  - Refueling must be set to zero litres for each strategy
  - Each strategy has to use the Dry tyre compound
  - Each strategy has to use the next fresh tyre set after the previous strategy
  - For each strategy, the tyre pressures must be those as used for the first stint and documented in the *Race.settings* file as described above

Beginning with Release 2.6 this is not necessary anymore, since Jona can acquire the curent settings directly from *Assetto Corsa Competizione* via APIs. Jona now uses the values already set in the Pitstop MFD and calculates the delta to the desired target values. Please note, that this requires the settings in the [*Race Settings*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#tab-race) dialog to be valid, especially the value for the first fresh dry tyre set. Beside that, I still recommend to setup a reasonable pitstop strategy, since this will reduce the time needed to dial in all those numbers (going from 0 to 120 litres of refueling will take quite some time).

Last but not least, the check boxes for repair of Suspension and Bodywork must be both selected at the start of the race in the Pitstop MFD. After you have done all that, you can let Jona handle the pitstop setttings. Only be sure to not interfere with the artificial click and keyboard events, while Jona is managing the pitstop settings.

#### *rFactor 2*

No special setup required for *rFactor 2*, since this simulation has an integrated interface to control the pitstop settings externally.

#### *iRacing*

No special setup required for *iRacing*, since this simulation has an integrated interface to control the pitstop settings externally.

#### *RaceRoom Racing Experience*

*RaceRoom Racing Experience* does not provide any data interface for initial setup information. So you must take care, that everything is entered correctly into the settings tool, before you head out onto the track. On the other hand, the support for pitstop settings is quite limited in *RaceRoom Racing Experience*, so you might skip tyre pressures and dry vs. wet tyre considerations alltogether.

#### *Automobilista 2*

*Automobilista 2* also does not provide any data interface for initial setup information. Therefore you must take care here as well, that everything is entered correctly into the settings tool, before you head out onto the track.

Furthermore, it is very important, that you do not use the *Automobilista 2* ICM yourself, while you want Jona to control the pitstop settings or want to use the "Pitstop" mode of the "AMS2" plugin. Additionally, you must leave *all* repairs selected in the default pitstop strategy and select *no tyre change* in the default pitstop strategy as well. Not complying with this requirements will give you funny results at least.

### Race & Setup database

With the introduction of Release 2.6, Jona, the Virtual Race Engineer, collects several data points from your practice and race sessions (qualification sessions are not supported, since they often use special setups which will only be in the perfect window during the first few laps) and saves them together with the associated tyre choice and start pressures, air and asphalt temperature and other environmental conditions in a local database. Beside that, you can upload your car setups for a given track and different conditions to the setup databse. This informations may then be used as a starting point for a setup in an upcoming race under the same or similar conditions. In order to build up a comprehensive collection of data on vehicles, tracks and environmental conditions as quickly as possible, Jona can integrate your data with the data of all other drivers, and in return will make the consolidated database available to all contributors.

When your data is transferred, no direct or indirect personal data is involved. It is not possible to draw any conclusions about the individual user or the computers from which the data originated. A randomly generated key is used to identify the local database and the data supplied for further processing. Nevertheless and according to good data privacy standards, you must give your consent to share your data with other users of Simulator Controller by answering "Yes" for the different options in the dialog below. This consents are saved in the "CONSENT" file in the "Simulator Controller\Config" directory which is located in your user *Documents* folder. If you want to change your consents in the future, delete this file and this dialog will appear again.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Consent.JPG)

Note: You can give separate consents for sharing your tyre pressure setups and your mechanical and aerodynamic car setups, since the later might be considered to be some sort of private secret, for example. Furthermore, you must explicitly upload car setup data to include it to the setup database, so you can decide which data you want to share. On the other hand, tyre pressures will be collected automatically by Jona, but you will be asked whether to include them in the setup database (see below).

If you have given your consents, all data of your local races will be transferred to a cloud database once a week. For the moment, nothing more will happen. The functionality will come to live with a later Release of the Version 3 cycle. You will get a payback in terms of a consilidated database of all contributors and Jona will use the data to help you in your setup task in the pit, but also during a race, when radical weather changes are upcoming. This database will then be updated for you once a week too, so you will always get the latest and greatest setup data.

For the moment, the data collection consist of tyre and car setup information for the different track and weather conditions, as long, as they are available in the different simulation telemetry interfaces. But there will be more in the future. For example, there are ideas in the backlog to use race position data and pitstop events from the races to optimize the pitstop strategy with regards to the most positive effect on race position. Neural networks and reenforcment learning algorithms will be used for that, but to be able to do this, our joint database needs to have enough data points, so this will take some time.

Note: The database is stored in the *Simulator Controller\Setup Database* folder, which is located in your users *Documents* folder. Your own data files will be located in the *Local* subfolder, whereas the consolidated data will end up in the *Global* subfolder.

*Very Important*: As long as we can't get the actual car setup information from the different simulation games via APIs, you **really** have to follow the guidelines from [above sections](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-settings), so that Jona has a correct understanding of your car and tyre setup. This has been important in the past to get a correct setup for an upcoming pitstop, but it is even more important when building the setup databse, so that we do not end up with compromised data. Jona will ask you at the end of the session, if you were happy with your setup and if you want to include the setup information in the database. Please only answer "Yes" here, if you are sure, that the setup information has been transferred correctly to Jona, as described above. Please note, that you still may have had a too low or too high hot tyre pressure during your session, because your initial setup was wrong in the first place. This is no problem, since Jona will store the corrected values in the database, as long as your initial setup values are known.

#### Querying the setup database

Whenever you have to setup your car for a given track and specific environmental conditions you can query the setup database to get a recommendation on how to setup your car. When you start the application *Setup Database.exe* from the *Binaries* folder, the following dialog will open up.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Setup%20Database%201.JPG)

You have to enter all the fields in the upper area to specify the simulation, car, track, current weather and so on. Then you will get a recommendation for initial cold tyre pressures in the first tab in the lower area, if a matching setup is available in the setup database. Depending on the temperature settings the recommended tyre pressures will be marked in dark green for a perfect match, or light green or even yellow, if the values have been extra- or interpolated from different air and/or track temperatures.

Note: If the *Setup Database* query tool has been [started by the *Race Settings* tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#tab-race), you can transfer the current tyre pressure and compound information to the *Race Settings* by pressing the "Load" button.

The second tab allows you to store your preferred car setup files for different conditions (Wet vs. Dry) and different Sessions (Qualification vs. Race) in the setup database.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Setup%20Database%202.JPG)

The dropdown menus let you access all setup files, which had been associated with the given car and track, either by you or by another person from the community. The buttons on the right side of the dropdown menu let you 1. upload a setup to the database, 2. download a setup and store it in the specific folder for a simulation and 3. delete one of your setups from the database.

Session settings created by the [*Race Settings*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-settings) tool can be stored in the setup database as well. You can configure Jona with the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-engineer) to load the best matching settings according to the session duration at the beginning of a new session.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Setup%20Database%204.JPG)

The buttons below the list of settings will allow you to create new settings, edit the selected settings, clone the selected settings or delete the selected settings. Settings may alos be renamed by double clicking on the corresponding line or pressing *F2* while a line is selected.

In the last tab you can take some notes on the track, or open issues with your setups and so on.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Setup%20Database%203.JPG)

With the dropdown menu in the lower left corner you can choose, whether only your own setups (=> "Local") will be included in the database search or that also the setups of othe users of Simulator Controller might be considered (=> "Local & Global"). Since the community setups have not been consolidated yet, these two settings are identical for the moment.

Note: You can use the local database, even if you do not have given consent to share your tyre pressure setups with the community.

### How it works

Jona uses several statistical models to derive the data, on which the recommendations for the pitstop or other information is based. Therefore it will take some laps, before Jonas conclusion get more and more precise. So be careful, if you let Jona plan a pitstop after you have driven only three or four laps. You might end up with not enough fuel to reach the finish line.

The following statistical models are currently implemented:

  1. Tyre pressure development
  
     The pressure development of the last laps and the deviation from the predefined target pressures are considered to derive pressure corrections for the next pitstop. The number of laps considered and the weighting of past laps can be configured using the settings tool. To get the most precise recommendations, set the *Statistical Window* as large as possible and the *Damping Factor* as small as possible. For example, a statistical window of 10 and a damping factor of 0.1 will consider your last 10 laps, where your most recent lap counts fully and the lap five laps ago only with 50%. Depending on accidents, severe traffic or safety car phases, especially in the most recent laps, the algorithm will come up with unexpected results, so always double check Jonas recommendations here.
	 
	 When planning and preparing a pitstop, Jona will consult the [setup database](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#querying-the-setup-database) for a second opinion on tyre pressures for given temperature and weather conditions. Needless to say, these values are also specific for a given car and track combination. Jona will use the same algorithm as the database query tool, therefore extra- or interpolation will be used, when no exact match is available. But in those cases an (un)certainty factor will be applied, so that the dynamically derived target pressures will be considered more relevant.

  2. Refuel amount
  
     Depending on the number of remaining laps and average fuel comsumption, Jona derives the exact amount of fuel required for the next stint. As for the tyre pressures, the lap weight of past laps may be configured for the fuel average calculation, so the remarks above on statistical window and damping factor are valid here as well.
	 
  3. Damage related lap time degration
  
     After Jona detects a new damage, the devlopment of your lap times are observed and Jona might suggest an adopted pitstop strategy, depending on remaining stint time and the delta time necessary for a pitstop. The underlying model is quite complex and recognizes and excludes special lap situations like pitstops, accidents, and so on, from the average laptime calculation. All laps of the current stint (except a couple of laps at the beginning) are considered by the algorithm and the average lap time incl. the standard deviation before the accident will be taken as the reference lap time. This means, that the computation will fail, if you had an accident very early in your stint, since you never had the chance to set a good reference lap. 
	 
  4. Repair recommendations
  
     Based on the same model, Jona suggests repairs for the upcoming pitstop. You can configure various strategies (Repair Always, Repair Never, Repair when damage is above a given threshold, ...) using the settings tool.
	 
  5. Tyre pressure gambling
  
     Linear regression models are used here. Depending on the development of ambient, track and tyre temperatures and the resulting tyre pressure development, Jona might suggest higher or lower pressures for the next pitstop than currently might be perfect as a result of a clear past trend, thereby propably giving you a good compromise for the upcoming stint.
	 
  6. Weather trend analysis and tyre compound recommendation
  
     Beginning with Release 2.5, a weather model has been integrated in the working memory. The raw data is acquired from the simulation. For example, *Assetto Corsa Competizione* and *rFactor 2* supply current weather information ranging from "Dry" up to full "Thunderstorm". *Assetto Corsa Competizione* goes even further and can supply a full weather forecast from now on up to 30 minnutes into the future. Based on this information and currently mounted tyres, Jona will recommend a tyre change. This recomendation will be incorporated into the plan for an upcoming pitstop depending on the settings you have chosen in the [settings dialog](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-settings).
	 
Note: Extrem changes in the conditions, for example an incoming thunderstorm on a previously dry and hot track, will result in extreme variances in the statistical models and thereby will lead to strange recommendations in many cases. This is a drawback for the moment, so always doublecheck under those circumstances. This will get much better with one of the next major releases	, which will introduce a big data collection of recent races, which in the end will allow Jona to base or at least to secure the decisions on past experiences using neural networks.

Additional notes for *iRacing* users: It looks like that tyre pressures and also to some extent tyre temperatures for most of the cars are not available in the *iRacing* live data. To make it worse, damage information is also not available in the API, although *iRacing* apparently has a sophisticated damage model. Since *iRacing* is a quite mature (not to say old) simulation game, and the API hasn't changed in a while, I am quite pessimistic, that this will be fixed. Therefore, the recommendations of the Virtual Race Engineer will be at best limited and in some cases even false. Nevertheless, Jona will help you with refuel recommendation for an upcoming pitstop and you will have someone to talk to while hunting down your opponent on the long straight.

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

You can find the rules of Jona in the file *Race Engineer.rules* which resides in the *Resources\Rules* folder in the installation folder of Simulator Controller. As always, you are able to overwrite this file by placing a (modified) copy in the *Simulator Controller\Rules* folder in your user *Documents* folder. This might be or might not be a good idea, depending on your programming skills in logical languages.

### Interaction States

At this time, Jona can handle three important states in its knowledge base.

  - A pitstop has been planned
  - A pitstop has been prepared, which means that all the settings had been transferred to the simulation game, for example to the Pitstop MFD of *Assetto Corsa Competizione*
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

A considerable part of the knowledge of Jona comes from the telemetry information of the simulation game. As said, data providers for *Assetto Corsa Competizione*, *RaceRoom Racing Experience*, *rFactor 2*, *iRacing* and *Automobilista 2* are already builtin. The special plugin "Race Engineer" collects the data from the simulation games and hand it over to Jona. Small applications "ACC SHM Provider.exe" or "RF2 SHM Provider.exe", which are located in the *Binaries* folder, are used to acquire the data. These readers run periodically and output the following data:

	[Car Data]
	BodyworkDamage=0, 0, 0, 0, 0
	SuspensionDamage=0, 0, 0, 0
	FuelRemaining=54.6047
	TyreCompound=Dry
	TyreCompoundColor=White
	TyreTemperature=84.268, 74.6507, 85.6955, 77.2675
	TyrePressure=27.6296, 27.6063, 27.6666, 27.5575
	[Stint Data]
	DriverForname=The
	DriverSurname=BigO
	DriverNickname=TBO
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

The "Race Engineer" plugin writes this information to a temporary file and hands it over to Jona for each new lap. A special case is the flag *InPit*. If this is found to be *true*, the driver is currently in the pit. In this case, the ACC plugin informs Jona about this by raising the corresponding event. Another special case is the flag *Active* which is used to detect, whether you are in a simulation (Practice, Qualification, Race, whatever) right now. Not every simulation may provide all data as in the example above. In this case, a default value will be assumed.

The *[Setup Data]* section reference the settings at the start of the session and must only be written by the data provider, if the *-Setup* option has been passed to the process. These information are ussed in the pitstop preparation process and also by the *Race Settings* when importing the initial setup data.

Note: If you are a developer and want to take the challenge to adopt Jona to a different simulation game, you are welcome. You can use the "RF2" plugin code and the above file format as a blueprint, but the shared memory interface of each simulation game is different. Please feel free to contact me, if you have questions. I would be happy to integrate plugins for other simulation games into Simulator Controller in the future.

## Troubleshooting

The biggest hurdle to overcome when using Jona, is to find a satisfying setting for voice recognition. Here are some hints:

  - I strongly recommend to use a head set. Although it is possible, and I have tested it myself, to talk to Jona using a desktop or webcam microphone, it is hard to find a satisfying setup. Typically, you will get a couple of false positives in this scenario, while the V12 sound from the Aston Martin is hammering from the speakers. You have been warned...
  - Even when using headset, you might get false positives. The reason for that, normally is a too sensitive microphone level. Reduce the input level of the microphone as low as possible in the Windows audio devices settings, so that Jona still recognizes your spoken words, but does not interpret your sighs and breath noises as valid input.
  - If voice recognition is not working at all, you might need to unblock the DLLs. Follow the instructions in the [installation section](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#installation-of-speech-recognition-libraries) above.
  - Although it is very helpful to be able to talk to Jona anytime, you might consider to use the *Push To Talk* functionality introduced with release 2.4. Please consult the corresponding [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control) on how to configure this feature, which will eliminate false positives almost completely.
  - Most important: Learn the phrases, which are defined as input for Jona. Sometimes, only a somewhat different pronounciation is needed, and everything is fine. As a last line of defence, define your own input grammar as described above in the section about [phrase grammars](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#phrase-grammars). But doing this will make your upgrade path for future versions much more complicated.

It has been reported, that the system sound volume gets sometimes significantly reduced, when voice recognition is active. In most cases, it will help to enable [*Push To Talk*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control), since the sound volume reduction should then only happen while you are holing down the *Push To Talk* button. If this does not help, you can try to uncheck the sound enhacement option in the properties dialog of your select Microphone, but you might encounter reduced recognition quality afterwards.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Microphon%20Properties.JPG)

Beside that, when you encounter false recommendations from Jona, you might take a look into the brain of Jona to see, why Jona arrived at those conclusions. You can do this by enabling "Debug" mode in the configuration. In the next run, Jona will periodically dump its knowledge to the file "Race Engineer.knowledge" in the folder *Simulator Controller\Temp* that resides in your user *Documents* folder. If you think, that you found a bug, it  would be very helpful for me, when you attach this file to any reported issue.

And, last but not least, you might have a problem with the Shared Memory Reader for a simulation game. Please check, if a file "SHM.data" exists in the *Simulator Controller\Temp\XXX Data* folder (where XXX is the three letter short code for the simulation), which is located in your user *Documents* folder. If this file does not exist, you might try a complete reinstall.

If you still have problems with voice recognition, you might try this combination:

  1. Disable voice recognition by supplying *raceEngineerListener: false* as argument for the ["Race Engineer" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer).
  2. Also, define a toggle function to switch Jona On or Off using the *raceEngineer* parameter of the "Race Engineer" plugin.
  3. Configure all necessary options you want to use for the ["Pitstop" mode](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-pitstop) for example for the ACC plugin, especially for the *pitstopCommands* *PitstopPlan* and *PitstopPrepare*.

With this setup, Jona will be there and inform you about low fuel, damages and so on, but you have to use the Button Box to initiate pitstop planning and preparation. You will miss out all the eloquent conversations with Jona, but functionality wise, you are almost on par.
  