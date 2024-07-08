## Preambel

Cato is based entirely on the technology of Jona, the Virtual Race Engineer. Therefore, all concepts from the [associated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer), especially for installation and configuration, also apply here.

## Introduction

As a complement to Jona, your Virtual Race Engineer, this new Assistant will accompany you during your races as a Virtual Strategist. Cato will have complete knowledge over the race session incl. lap times of you and your opponents, the current race positions, pitstop events, weather changes, and so on. You can request updates for all these informations by asking Cato for the position, the gaps to the car in front and behind and also request information about the current lap times of your opponents and wether they are closing in. All this, although very useful, if you are racing using VR, is only a part of Catos capabilties. Cato is furthermore able to develop appropriate pitstop strategies if you are stuck in traffic and he will be able to react to unforeseen events such as sudden weather changes and severe damage - all hand in hand with Jona, the Virtual Race Engineer. Cato currently supports *Assetto Corsa*, *Assetto Corsa Competizione*, *rFactor 2*, *Le Mans Ultimate*, *RaceRoom Racing Experience*, *iRacing*, *Automobilista 2* and *Project CARS 2*.

Before we dig deeper into the inner workings, here is a typical dialog based interaction, to give you an understanding of the current capabilities of Cato.

Important: If you have multiple *dialog partners* active, for example Jona and Cato, it will benecessary to use the [activation phrase](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#voice-commands) the first time you start talking to a specific *dialog partner*.

### A typical dialog

(You are on the track, for example in the third lap. A lot of traffic has developed around you, and you want get more information about the current standings. You can call Cato anytime using one of the key phrases - see the section about [phrase grammars](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#phrase-grammars) for more information.)

**Driver: "What is my position?"**

**Cato: "You are currently on P 12."**

(This information might be a little bit outdated, since many of the simulation games update the position information only once per sector or even only once per lap.)

**Driver: "What is the gap to the car behind me?"**

**Cato: "The gap currently is 1.1 seconds."**

(You have seen in the mirror, that the car behind you closed in quite rapidly. Therefore you want to compare the last lap times.)

**Driver: "Can you give me the lap times?"**

(Cato will now tell you the lap times and the lap deltas for the car in front of you, the car behind and the leading car.)

**Cato: "Your last lap time was 122.2 seconds. The car behind you is running a 121.3 and is therefore 0.8 seconds faster than you. 124.7 seconds is the time of the car in front of you. He is 2.5 seconds slower than you. The leader is running a 120.9 and is therefore 1.3 seconds faster than you."**

(You regain your focus and try to overtake P 11. It will be a nice safety barrier between you and the faster car behind you...)

(Finally, after you've managed to gain P 11 and settled your pace, you want your strategist to run a simulation, how the race might develop in the next few laps.)

**Driver: "What will be my position in 4 laps?"**

**Cato: "Understood. Please give me a few seconds."**

(Cato runs a simulation in the background to calculate the possible race positions for the requested lap. Cato will use the average pace of all drivers and takes into account, how many seconds an overtake might need depending on the settings.)

**Cato: "The simulation shows you on P 8."**

(That is a very good message. You put your foot down on the pedal and push a little bit more to bridge the gap to the car in front of you.)

(After a few laps, you finally managed to gain P 8. Now it is time to plan for the upcoming pitstop. Maybe Cato can give you some recommendation...)

**Driver: "What is the best lap for the next pitstop?"**

**Cato: "Understood. Please give me a few seconds."**

(Cato again runs a complex simulation, taking into account your remaining fuel, the current race positions and the weather outlook. Cato will recommend the lap for the pitstop, where you will have the least traffic after the stop, or the lap where an undercut might be possible, taking into account the best lap for a tyre compound change, if applicable.)

**Cato: "I recommend a pitstop in lap 17. Should I inform your Race Engineer?"**

**Driver: "Yes, please."**

(Cato will hand over the information to your Virtual Race Strategist, which will handle the technical stuff and plan the pitstop.)

To have an error free session like this one, you must have a perfect setup for voice recognition. I strongly recommend using a headset, since alien noises might lead to false positives in Catos voice recognition. Please see the section on [troubleshooting](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#troubleshooting) in the documentation for Jona, if you need some hints.

## Installation

The installation procedure for Cato is the same as the [installation procedure for Jona](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#installation), which means, that you are also well prepared to use Cato, if you have everything setup correctly for Jona.

## Interacting with Cato

The same principles as [described for Jona](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#interacting-with-jona) apply here as well, since Cato is based on the same technology as Jona.

### List of all voice commands

1. [English version](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Strategist-Commands-(EN))

2. [German version](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Strategist-Commands-(DE))

I strongly recommed to memorize the phrases in the language you use to interact with Cato. You will always find the current version of the grammar files as actually used by the software in the *Resources\Grammars* folder of the Simulator Controller distribution. Or you can take a look at the files in the [*Resources\Grammars* directory on GitHub](https://github.com/SeriousOldMan/Simulator-Controller/tree/main/Resources/Grammars), for example the German version [Race Strategist.grammars.de](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Resources/Grammars/Race%20Strategist.grammars.de).

#### Boosting conversation capabilities using an LLM

Beside the builtin pattern-based voice recognition and the speech capabilities based on predefined phrases as described above, it is optionally possible to connect Cato to a GPT service like OpenAI or a locally hosted LLM, to dramatacilly improve the quality in conversation with the Assistant. When the *Conversation* Booster is configured (see [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#boosting-conversation-with-an-llm) for more information about the necessary configuration steps), the full knowledge about the the car state and the drivers performance will be supplied to the LLM. In detail, this includes tyre pressures, tyre temeperatures, tyre wear, fuel level, fuel consumption, and so on. When a pitstop is planned, the plan is available and the pitstop history is also available. The position information includes a history of the last laps and gap and lap time information for the most important opponents are provided.

##### Trigger actions from conversation

An LLM may be able to trigger actions as a result of a conversation. This is achieved by the so-called tool interface of the LLM. Tools are supported at the time of this writing by the following models:

  - GPT 3.5 and above from *OpenAI*
  - Mistral Small, Mistral Large and Mixtral 8x22b from *Mistral AI*
  - Claude3 by *Anthropic* (via *OpenRouter*)
  - Command-R+ by *Cohere* (via *OpenRouter*, but not working properly yet)
  - Some Open Source models, such as Open Hermes, also support tools but with a varying degree of reliability

Please note that calling actions is currently only available when using *OpenAI*, *Mistral AI* or *OpenRouter* are used as GPT service providers.

There are some predefined actions available for the Strategist, which come with the standard installation and you can define your own actions. But this will require a very deep knowledge of the inner workings of Simulator Controller and the Assistants. You have been warned. If you want to try this, check out the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#boosting-conversation-with-an-llm) for the "Conversation" booster.

The following table shows you the predefined actions, that might be triggered by the LLM during a conversation with the Strategist:

| Action                 | Parameter(s)      | Example(s) |
|------------------------|----------------|------------|
| Pitstop Simulation     | [Optional] lap | "What do you think? Can we go for an undercut in lap 7?" or "Can we get some clean air when we pit earlier?" |
| Pitstop Planning       | [Optional] lap | "Can you ask the Engineer to create a pitstop plan for the next lap?" |
| Strategy Recalculation | -              | "Can you check whether we can skip the last pitstop now, if we use a fuel saving map from now on?" |

As you can see, you can define new voice commands by defining a corresponding action, that can be triggered by the LLM. But that is only one part of the story. Please note, that beside reacting to the phrase as shown in the examples above, the LLM might decide to take the action on its own according to the current situation and based on the current data. So always be alerted, if the LLM gets active unexpectedly.

That said, it depends on the available data in the knowledge base, whether the LLM will decide to trigger this action or not. If the LLM refuses to do so, you still have all the traditional voice commands and the controller actions at your disposal.

Beside the predefined actions for the Strategist, which come with the standard installation as listed above, you can also define your own actions. But this will require a very deep knowledge of the inner workings of Simulator Controller and the Assistants. You have been warned. If you want to try this, check out the dedicated [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants) for the "Conversation" booster.

IMPORTANT: When action handling is enabled, it might be necessary to disable the "Recognition" booster or at least set the "Creativity" to a very low value. Otherwise the "Recognition" booster might detect a command pattern, which will match to a pre-defined voice command, thereby preventing the LLM from creating a custom action plan.

##### Trigger events during reasoning

Very similar, you can use an LLM to alter or extend the reasoning process of an Assistant. In the reasoning process, events are raised, which then causes the Assistant to react upon them. Events and actions are normally being implemented in the rule system, but it is also prossible to raise an event, which then is inspected by an LLM, possibly taking action using the supplied actions similar to the actions used the conversation as described above.

For a complete description of events and actions, see the dedicated [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants).

### Enabling and disabling specific warnings and announcements

Cato can give you information about the weather development and might recommend a strategy change. You may disable this warning by using a special voice command:

	[Please] No more *warning* [please]

As you might expect, the word "please" is optional. Only one option for *warning* is available at the moment: "weather warnings". After you have disabled the warning (it is enabled by default), you can reenable it with the following command:

	[Please] Give me *warning* [please]

As an alternative, you can disable unwanted talking completely by saying:

	Be quiet please

To reactivate the Assistant use:

	I can listen now

These commands are also available as "Mute" and "Unmute" plugin actions, which can be configured for a Button Box or a Stream Deck, for example.

## Racing with Cato

Cato will be active during practice and race sessions by default, although the Assistant will be of not much help in a practice session, since it only collects data for future race strategy development purposes. You can configure the sessions, where Cato collects telemetry data using the [settings in the "Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#managing-the-session-database). 

Cato will always be active during a race, even if you have disabled data collection for races. Cato ca support you in a couple of different areas while you are running a race.

1. You can activate the Assitant anytime using the activation phrase and ask then for information about current lap times, current and possible future standings and so on. This is also possible using [controller actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) in most cases.

2. Cato can simulate future race situations based on the knowledge about your driving and all the other participants. This includes the devlopment of the standings as well as a [recommendation for the best possible lap for an upcoming pitstop](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#pitstop-recommendation).

3. And Cato is able to guide you through the race using a strategy that was prepared before the race using the ["Strategy Workbench" tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench). This includes the announcement of an upcoming pitstop, as well as a cooperation with the Race Engineer to prepare and handle the pitstop.

Normally, Cato will not contact you on its own as often as Jona does. Most of the time, you must ask Cato specifically for its support. An exception is, when you have an active race strategy or when a weather change will require you to conduct an unplanned pitstop for tyre change.

Important: In the default configuration, Cato will be activated in the first lap of a session. This is necessary, so that Cato can setup the initial knowledge (starting grid, your position, the initial strategy, etc.). If you join a session later than during the first lap, Cato will refuse to work. This behaviour can be changed with the setting "Strategist: Late Join" in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#managing-the-session-database), but the behaviour of Cato may be somewhat confusing.

### Multi-class support

Cato *understands* multi-class and multi-category races. Position evaluation and gap and lap time information will be always focused on your own class. Where it is necessary to mention, for example, the overall position, Cato will phrase it in a way, so that you understand, that information is related to the whole grid. Support tools like "Race Reports" also *understand* multi-class races and will give you related information with a class-specific focus as well, or you can choose, at which class you want to look, for example in a report. You can configure in the [settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database", in what way Cato uses the information about the car classes and cup categories to partition the grid.

### Race Settings

Cato shares many settings with Jona. Therefore consult the documentation on the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-settings) in the documentation for Jona for the general use of the settings tool and the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#managing-the-session-database).

#### Tab *Strategy*

You will find settings for the race strategy analysis and simulation in the third tab of the settings tool.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Settings%203.JPG)

A very special setting is the *Autonomous Mode*. If you set it to "Yes", it will allow the Assistants (especially the Strategist and the Engineer) to take their own decisions actions to guide you through the race without further confirmations needed from your side. Normally you will be asked to confirm each and every action taken by the Assistants, but this is not the case, when you choose "Yes". The default choice "Custom" let you even further customize the behaviour of the Assistants for every single decision and action. Take a look at the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-settings) in the "Session Database" and search there for "Confirm" to see all the available settings. Last, but not least, choosing *No* here will overwrite everything set in the "Session Database" and will force the Assistants to ask for confirmation each and every time. Further information can be found in the chapter about [strategy handling](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#autonomous-mode).

You can also activate an automatic revision of a the [currently chosen strategy](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#strategy-handling) with respect to the current race situation and current and maybe upcoming weather conditions. If a better strategy can be derived (depending on available data in the session database), Cato will inform you and you might decide to activate the new strategy (no confirmation is needed in autonomous mode, of course). Please note, that you can also ask the Strategist anytime to revise the strategy during a race, if you don't want to enable this automatism. Two different triggers can be defined for the recalculation, either automatic after a number of laps has been driven, or when an unplanned pitstop was neccessary. Please note, that the Strategist will never cancel the current strategy, if he cannot come up with a valid new one. Cancelling the current strategy must always be actively requested.

Using the fields at the end of the first group, you can customize the projection of current race positions into a model of future race standings. Cato will calculate this model each lap and will store the future standings for a given number of laps in the working memory and use them for strategy decisions. You can control the number of laps calculated for future standings by changing the value in the field *Race positions*. Greater numbers will yield better predictions, but take care, it might cost a lot of computing power.
With the second field, *Overtake Delta*, you specify the number of seconds as time discount for each overtake for the passing and for the passed car, whereas you specify the percentage of track length in front of the car, which will be taken into account for traffic density analysis.

The second group of fields specify the time required for several pitstop activities, as well as the pitstop window, in which the best pitstop lap will be derived. With the value of *Pitstop Delta*, you supply the difference time needed for a normal pitstop (time for pit in and pit out but without any service time minus the time to pass the pit area on the track, i.e. Drive through vs. Drive by), The fields below specify the time required for the various pit services, like changing tyres, refueling, and so on, as well as these times are combined into an overall pitstop service time.

### Pitstop Recommendation

You can ask Cato to evaluate a couple of possible laps for an upcoming pitstop, either by using a voice command or the ["RecommendPitstop" controller action](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist). You can either ask to simulate a pitstop around a specific lap or you can simply ask for the best option for the next pitstop. In this case, the target lap is either taken from an active strategy or, when no such strategy has been created, it is determined depending on the amount of fuel left.

The Race Strategist will simulate the laps around the planned or requested pitstop lap (as long there is enough fuel to do it) and will try to optimize for undercut opportunities as well as the traffic density ahead after you re-enter the track. When you are satisfied with the prposed lap, Cato can handover the data to the Engineer, who will then prepare the pitstop.

Please note, that this simulation does not take possible pitstops or driving errors of your opponents into account. The simulation is based on the current positions and the average lap times of all drivers. If you want a more complex simulation, which is based on the Monte Carlo method, a team mate of you must run the "Race Center" and use the [strategy tools](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#strategy-handling), which are available on the Team Server. They can be used even when you are running a solo race.

### How it works

Cato uses the position data gathered from the simulation game to form a complete overview of all drivers, their lap times and the development of their positions on track, even with different pit strategies. Using this knowledge, Cato can give you valuable information, but also can derive adapted race strategies, when your are stuck in traffic or are faced with other challenges.

The following statistical models are currently implemented:

  1. Pre-Race strategy development
  
     Cato can import a prepared strategy model at the start of a race session and will automatically call you to the pit and collaborate with Jona to give you a real life like race crew experience. Please see the dedicated chapter on the [Strategy Workbench](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench) and also on [Strategy Handling](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#strategy-handling) down below for more information.
	 
	 You can configure in the race settings, that this predefined strategy will be revised actively by Cato depending on the current race situation or unplanned pitstops and so on.

  2. Weather trend analysis
  
     Cato will observe the weather development using the same rule set, that Jona uses. Thereby, Cato will notify you, when it is time to change the tyres, to achieve the best results. If you accept the recommendation, Cato will inform Jona to plan a pitstop with the best tyre compound for the upcoming conditions. Additionally, if Cato is currently following a predefined strategy, he will try to revise this strategy to take the new weather conditions into account.

  3. Fuel availabilty and stint time calculation
  
     Cato will observe the average fuel comsumption. Depending on the race situation and strategy requirements, Cato might suggest to save fuel to get one or two more laps from the available full. If you don't follow this recommendations, Cato will try to revise the strategy, to take this into account as well.

  4. Standings and race position development

     Using the position data gathered from the simulation game, Cato builds a knowledge of the pace of the various drivers. As a simple application of this knowledge, Cato can give you information about the current race positions and lap times of your opponents and the gaps between the cars. A more complex application will be a forecast of the race positions in a given time frame (see the next point).
	 
  5. Pitstop simulation
  
     Also using the position data and a complex prediction model, Cato can determine the best lap for the next pitstop in a given pitstop window. The pitstop delta time as well as the service time is taken into account. The best pitstop lap will be selected based on position and the expected traffic after the pitstop.

## Race Reports

Cato allows you to save most of the data that is acquired during a race to an external database as a report for later analysis. You can configure, where and also when these reports are stored, using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-strategist). If a report has been saved for a given race, you use the "Race Reports" application to open this race from the database.

Important: "Race Reports" displays various graphs using the Google chart library in an embedded web browser. This web browser, which is part of Windows, must be configured for a given application using a setting in the Windows Registry. In most cases, this setting can be configured automatically by the given application, but in rare cases, admin privileges are required to insert the corrsponding key in the registry. If you encounter an error, that the Google library can not be loaded, you must run "Race Reports" once using administrator privileges.

After a given race report has been selected, the "Race Reports" tool offers you several different views, which you can use to analyze the data.

  1. Overview Report
  
	 The overview list all drivers / cars with their starting positions, the best and average lap times, as well as the race results.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%203.JPG)
	 
	 For multi-class sessions, two result columns with the overall result and the class-specific result will be available. If available, driver categories are shown here as well for the starting driver, when you have enabled it in the [settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database".

  2. Car Report
  
	 A report with technical data of your own car, especially mounted tyres and electronic settings, as well as the weather conditions and the lap time for each lap.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%204.JPG)

  3. Driver Report
  
     This report allows you to compare the inidividual abilities of the different drivers during the session. You can select the laps, which will be taken into account and you can choose the drivers to be included in the ranking (see the settings dialog below). Five dimensions will be computed in the ranking:

	 - Potential: Based on the starting position and the race result.
	 - Race Craft: Number of positive overtake maneuvers, as well as the number of laps in the top positions are taken into account.
	 - Speed: Simply the best lap time.
	 - Consistency: Calculated using the standard deviation of the lap times.
	 - Car Control: Based on an analysis of all laps slower than (average lap time + standard deviation).
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%205.JPG)
	 
	 Due to technical reasons, the driver names are always the names of the starting driver, even if you are in a team race and have selected a lap range, that had been driven by another driver.

  4. Positions Report
  
     The Positions Report will show you the development of the positions of the different cars during the course of the race. When you hover with the mouse over a given car in the legend at the right side, the corresponding race line will be highlighted.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%201.JPG)

  5. Lap Times Report
  
     This report will give you access to all lap times of all your opponents. These lap times will also be used to create the *Pace* chart (see next report), which supplies a much more intuitive way to judge the performance of a given car / driver, but sometimes looking at the numbers may reveal more detailed information.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%206.JPG)
	 
	 Impotant: The laps will be always the last lap of you and your car. The report does not perform any lap up or lap down correction, take the lap number for your opponents with a grain of salt.

  6. Performance Report
  
     This report provides a different view on the lap times of all drivers / cars. It can show you the lap times for a selected group of drivers / cars and laps graphically which makes it very easy to compare their respective performance.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%209.JPG)

  7. Consistency Report
  
     The Consistency Report will give you a graphical representation of the lap times of a couple of cars and therefore is an addition to the Lap Times Report at the first look.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%207.JPG)
	 
	 But when you select only one car, additional information will be made available. The minimum, maximum and average lap times will be added as marker lines to the graph and the overall consistncy number will be calculated and will be displayed at the top of the graph.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%208.JPG)

  8. Pace Report
  
     If you want to analyze lap times and consistency of the different drivers, this report is for you. The small rectangle marks the range of typical lap times of the different drivers. The smaller and further down the small rectangle, the faster and the more consistent the corresponding driver is. If there are small lines above or below the rectangle, these marks lap times, which are outside of the standard deviation, for example a slow lap time after a crash. Inside the reactangle you may find a horizontal dividing line which represents the median of all lap times and a small grey dot, which shows the average or mean value of all lap times.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%202.JPG)

Some reports allow you to control the amount and type of data, which will be included in the report. Please click on the small button with the cog wheel in the upper right corner of the window to open the settings dialog, with which you can change the settings for the report. The following window will open up:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Report%20Settings.JPG)

Beside restricting the laps which will be included in the report, you can also choose the drivers / cars for which data will be shown, or you can even restrict the report to a given class or category in a multi-class race. When you select "All" for the categories as well as "All" for the car classes, the display data will split the grid into car classes and each car classes according to the different cup categories, if any. This will look like this:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%2010.JPG)

On the other side, you can restrict a report only to a given class or cup category, which then will present the information like this:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%2011.JPG)

Last, but not least, you can choose to display driver categories (i.e. Platinum, Gold, and so on), when they are supplied by the simulator.

## Practice Center

The "Practice Center" is an application, which you can run alongside your practice sessions or even while running a solo race. When the Race Assistants detect that the "Practice Center" is running, they transfer all collected data to this application and do not store the data in the [session databse](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#managing-the-session-database) at the end of the session. Instead you can use the "Practice Center" after your session to investigate the data and select the data that should be stored permanently in the session database, if any at all. You can also use the "Practice Center" to plan your practice session, review the car telemetry data and compare your performance to other drivers participating in the same session.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center.JPG)

The "Practice Center" looks very similar to the ["Race Center"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#race-center), a tool typically used to manage team endurance races. Both tools share common concepts, reports and data views by intention, but there are also some differences, of course.

### Starting a session

Simply start the "Practice Center" **before** starting the session in your simulator. The Race Assistants will automatically connect to the "Practice Center" after the first lap and initiate a session there as well. Once data has been collected in the "Practice Center", it will **not** connect to a new session, before this data has been exported. However, you can use the "Clear..." command from the "Session" menu and you are ready to go for a new session, if you don't want to retain your collected data.

When you start a new session or when you close the window, the "Practice Center" will ask you before any unsaved / unexported data will be overwritten. You can, however, enable "Auto Export" or even "Auto Clear" in the "Session" menu according to your preferences.

Do **not** start the "Practice Center" after you have already started your session in the simulator. Although nothing will explode, you will loose your valuable practice data, since it will be send to the "Practice Center", which most likely will not collect it. Also, do not quit the "Practice Center" **before** quiting the session in your simulator. You will also end up with an inconsistent data constellation. Nothing really harmful, since in the end all data is treated with statistical weights and averages, but if possible, do avoid it.

Note: If you have [enabled a team session](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#connecting-to-a-session), the "Practice Center" cannot be used (it will simply ignore the running session), since all data duties are handled by the Team Server in this case. But you may want to use the "Race Center" to control your race in this case anyway.

Good to know: The "Practice Center" benefits from a high data update frequency of the Race Assistants. Therefore, if your PC is powerful enough, you can lower this value in the [settings of the "Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#managing-the-session-database):

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center%207.JPG)

The default value for the data update frequency is 10 seconds, but you can can try to go as low as 2 seconds, if your PC is powerful enough.

### Data Analysis

"Practice Center" supplies you with a couple of reports, which you can use to analyse your performance and dig deeper into the telemetry data of the car. Choose one of the reports in the reports list and this report will be shown in the report area on the top right of "Practice Center" window.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center%201.JPG)

The reports at the top of the list are the well known reports, which are also available after a session using the ["Race Reports"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#race-reports) tool. They are mostly useful to analyze the standings and the performance of the various drivers and cars. The other reports will give you an insight into the telemetry data. You can select the data to be shown using the selector menus on the right of the report list. You can also choose the type of visualization using the "Plot" menu on top of the report area. Use the "Stint" menu to restrict the visualized data to a specific stint or use the "Driver" menu to restrict the data of the various charts to one the drivers who has already driven some laps in the session (normally only you). Only data of the selected driver will be shown then.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center%202.JPG)

A special case is the "Running" report, which gives you access to many telemetry values for the previous and the currently running lap. The X-Axis stands for the track length here withe the 0 value beeing the start/finish line and the values are updated, when you reach the given point on the track (depending on the general data update frequency - see below). Please be aware that not all values may be provided by a given simulator.

Note: The values for wear (tyres and brake pads) range from 0% up to 100%. For most of the simulators these values are directly available through the API, whereas in *Assetto Corsa Competizione*, the data interface provide the remaining thickness of each pad. Depending on the compound of the pad, the wear level for 100% ranges from 12 mm to 15.5 mm left pad thickness here, with a starting thickness for a fresh pad with 29 mm.

Last but not least, using the small button with the cog wheel icon, you can choose various settings for the currently selected report, for example the range of laps to be considered in the data or the set of drivers in reports which are driver specific.

  1. Details of a selected stint
  
     This will give you an overview for the stint, the driven laps, as well as some performance figures for the driver. Please select a stint in the list of stints to generate this report.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center%203.JPG)
	 
	 While you are in an active session, you can also take notes for a selected stint, for example to remember setup changes, special weather conditions or other stuff worth to mention.

  2. Details for a given lap
  
     When you select a lap in the *Laps* tab, you will get a detailed table of the standings and (depending on the type of the session) the gaps to the cars in front of and behind the drivers car, as well as to the leader.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center%204.JPG)
	 
	 If the current race is a multi-class race, the report will also show the class specific positions of all cars, additionally to their overall position in the race. In a multi-class race, the gaps shown in the gap table at the top of the report will always be specific for the own class. Additionaly, if driver categories are available, the category label of a given driver will be added to his name.
	 
	 Last, but not least, you will find informations about the past pitstops of each car (only in a race session). The overall number of pitstops, as well as the lap (in reference to your own laps) of the last stop are shown. Please keep in mind, that due to restrictions in the data provided by the various simulators, it cannot be differentiated in many cases whether a car has been in the pits for a penalty, a regular pitstop or even an unplanned stop due to repairs. It is also possible, that the number of pitstops are not correct at all, since not all stops may be correctly reported by the simulator.
	 
	 If you are in a practice session, the standings table will list all drivers, which has also been present at the start of your session, and the list will be sorted according to the best lap times of all drivers.
	 
	 Some basic data is shown in the header of the lap details as well. Important are here the ambient temperatures and the tyre pressure information. You can see the current hot pressures, recommend cold pressures and information about tyre pressure losses, if there are any.
	 
  3. Session Summary
  
     This report is useful by the end of a session to create a document to be stored away in the archive. It contains data on all stints. This report can be created using the "Session Summary" command from the "Session" menu.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center%205.JPG)

  4. Data Summary
  
     Data Summary is another useful report, which gives you a complete documentation of all data collected in your session or already stored in your database (depending on your choice in the "Data" menu.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center%209.JPG)
	 
	 You can create this report by chooosing "Data Summary" from the "Data" menu.

  5. Stints Summary
  
     This report combines the output of the stint report (see above) for all stints into one document.
	 
All these report documents are HTML-based and can be saved or printed using the context menu when right-clicking into the output area.

### Managing tyres and planning practice stints

The first tab "Tyres" in the lower left corner allows you to manage your tyre sets during your practice runs. In many cases, you can let the "Practice Center" decide automatically, when to create a new stint and when a tyre change happened (at least for *Assetto Corsa Competizione*, *rFactor 2* and *Le Mans Ultimate*). But not all simulators provide access to the mounted tyres in their data API, so it is also possible to create a new stint with your individual tyre setup manually.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center%206.JPG)

To create a new stint manually while you are standing in the pit, follow these steps:

1. Select "Manual" from the "Mode" drop down menu.
2. Select whether you want to change tyres and possibly a specific tyre compound using the "Compound" drop down menu. You can also use the small button beside the drop down menu to query the simulator for the currently mounted tyre compound and tyre set, if this data is provided.
3. Select the number of the mounted tyre set. This is important, so that the "Practice Center" can manage the number of laps driven with this specific tyre set.
4. Enter the cold pressures, you have chosen for the new tyres. This is particular important, otherwise the cold pressures derived by the Race Engineer will be wrong.
5. Finally click on the button "New Stint" or choose the corresponding command from the "Stints" menu.

It is recommended to use the "Auto" mode in races, since then the pitstops are reliable detected by the Race Assistants (and the additional data like tyre set and tyre pressures will be taken from the pitstop plan), whereas in Practice sessions, it will be much better to create the different practice stints manually. Esspecially the ideal cold tyre pressures derived by the Race Engineer will be mostly wrong, when the tyre change has not been planned and prepared under the control of the Race Engineer, which is uncommon in a practice session.

#### Using the Run Sheet

The "Practice Center" can give you hints for worthy practice runs, which will create data for specific car configurations, for which currently no data is available in the database. This is somewhat the inverse approach as taken by the data explorer described in the next section, since the "Run Sheet" will show you data, that is *missing*

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center%2010.JPG)

You can open the "Run Sheet" by choosing the corresponding command in the "Data" menu and the window can stay open, while you are working in other areas of the "Practice Center". The data shown, will always reflect your current selection of car and track and the chosen data setting in the "Data" menu.

In the upper list, you will see entries for missing data which relate your lap times to the combination of chosen engine map (if available in your simulator) and the amount of fuel currently in the tank (thereby determining the car weight and balance). The lower list show missing data correlations between fuel level (car weight) and the number of laps you have already driven with a given tyre set.

When you now select an entry in one of these lists, instructions will be given how to create the missing data points, thereby defining the conditions for a worthy practice run.

Please note, that not all data points may be of interest. Decide for yourself, if you will ever encounter a situation, where you will run a car with a full tank, but worn tyres, for example. If you are participating mostly in sprint races, this will be very unlikely. If you are running high class endurance races, on the other hand, it can happen that you must double stint a tyre set due to tyre set restrictions imposed by the race rules. You see, it depends...

### Exploring data

The "Data" tab will give you an overview of what data you have collected during your session, or, after you have selected the corrsponding option in the "Data" menu, what data is available in your session database.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center%208.JPG)

Using the "Data" menu, you can choose between the different weather conditions and available tyre compounds, thereby identifying possible gaps in your data collection that need to be filled with a specific practice run.

The choices (except tyre compounds) will be remembered between different runs of "Practice Center".

### Exporting data to the session database

At the end of your session, you can decide which data should be transfered to the session database by clicking the small check marks for each lap in the list of driven laps. "Practice Center" will already have selected by default all valid laps for your convenience. Then choose the command "Export to Database" from the "Session" menu.

Please note, that this export is possible only once, to prevent duplicate data entries in your database, and cannot be undone. Therefore check your selection carefully beforehand.

You can also store your session for later inspection in any location on your PC using the "Save a copy..." command from the "Session" menu. The mentioned data export can also be initiated from a saved copy - very helpful, if you are exhausted after your session and want to defer the data inspection for later.

## Strategy Handling

Cato can use strategies that have been created with the ["Strategy Workbench"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench) during a race. When a race session starts, Cato looks for a currently defined strategy and checks, whether this strategy has been defined for the same car and track in the same conditions and whether the duration of the upcoming session is identical to that defined in the strategy. If all these aspects match, Cato will use the given strategy during the race. If there is a pitstop upcoming, Cato will actively inform you and will, as long as you accept it, hand over all settings for the pitstop to Jona for further handling. The pitstop will be planned and prepared for a specific lap and if you are in this lap, all settings will be entered into the Pitstop MFD of the current simulation without any necessary interaction from your side.

The Engineer, however, may revise parts of the request of the Strategist, especially for the last stint, because he has a much more precise understanding of the car state, fuel consumption, tyre wear, and so on. Those changes are only applied, if they are in accordance with the race rules.

Important: Cato keeps track of your pitstops, if you visit the pit after being called and with a preparation done by Jona. But Cato also checks whether the current lap fits to the strategy, if you visit the pit *on your own*. As long as the current lap is equal to the lap planned in the strategy +/- the number of laps defined as the pitstop window in the settings, it will count as a valid pitstop with regards to the strategy. Since most simulators do not flag a stop in the pits, whether it is a normal one, or whether it is for serving a penalty, this can lead to *problems* in those special cases, when you got a penalty and serve it right before the next planned pitstop. Cato tries to cope with that, but is not always successful. Sometimes, Cato will come up with a strategy revision after you have been in the pit for serving a penalty (depending on the conditions and the initial race rules), if you  have enabled automatic strategy revisions in the settings. Be sure to check the revised strategy before accepting it, since Cato may count the penalty serving as a valid pitstop against the pitstop rules. If in doubt, reject the recommendation.

The currently active strategy might be dropped, if you do not adhere to the pitstop plan defined in the strategy, or it might be automatically revised - depending on the settings. To conform to the strategy, you must execute the pitstops in the laps as defined in the strategy +/- a few laps (default here is the pitstop variation window as defined in the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#tab-strategy)). If you think, that the predefined strategy is not of any use any more, because of a crash or changing weather conditions, you can cancel it actively with a voice command or by using ["StrategyCancel" controller action](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist).

Please note, that in a team race, the starting driver must be the one, which created and activated the strategy for the given event, or you musr use the "Instruct Strategist" command of the "Race Center" during the first laps to activate the strategy.

If you want to see all this in action in session in *Assetto Corsa Competizione*, take your time and watch this video:

[![](https://img.youtube.com/vi/MlbAESpzg7Q/0.jpg)](https://www.youtube.com/watch?v=MlbAESpzg7Q)

The video has jump marks, so you can skip the boring time in between the interesting parts, where the Race Assistants take action.

### Adjusting the Strategy during a race

If there is a need to revise the selected strategy later on, for example due to an accident with an unplanned repair pitstop or also due to severe wether changes, you can instruct the Strategist to recalculate and adjust the currently active strategy using a voice command or the ["StrategyRecommend" controller action](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist). In this case, the currently active strategy will be taken as a template incl. all original settings like pitstop rules, available tyre sets, and so on, but other aspects like starting fuel level or the current weather conditions, will be taken from the actual race situation. Based on this conditions a new strategy will be derived for the remaining race. The Strategist will inform you about the new strategy and will give you as much information as possible about the differences between the currently active and the new strategy. If it is not possible to calculate a new strategy, for example, when too few laps remain or if there is no telemetry data available for the requested weather conditions and tyre compound, the currently active strategy will be canceled upon your decision.

The weather forecast will be taken into account for the new strategy. If the currently mounted tyres are not suitable for the upcoming weather, the new strategy will start with a pitstop to change tyres. For additional information, how tyre compounds are chosen during weather changes, see the [corresponding documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Tyre-Compounds#using-tyre-compounds) about weather specific tyre compounds.

The Race Strategist will also keep track of all already used tyre sets and will consider this, when running a strategy simulation. However, this only covers tyre set usage in the current session. If there are tyre sets that already have been used in a previous session, for example in a qualifying run, this information is not available.

It is possible to enable a dynamic traffic simulation method, which uses a probabilistic method to predict future race development based on data collected during the race. You can enable or disable this method in the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#tab-strategy) or using default settings in ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#managing-the-session-database). Here you will also find a couple of settings to fine tune various aspects of the algorithm. These [settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-settings) are similar to the [options documented for the stratagy handling in the "Race Center](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#monte-carlo-traffic-model), so please take a look there for more information about the Monte Carlo method.

Please note, that if you are running a race with Team Server support, a new strategy can be also created and activated using the [strategy support of "Race Center"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#strategy-handling), which gives you much more control over various aspects of the new strategy.

Good to know: The settings of the *Optimizer* will also be stored in the original strategy and the same settings will be used for all subsequent recalculations based on this particular strategy. This will be in general exactly what you want. But be aware, that the time needed (and therefore also the CPU consumption) to create a new strategy during a race will be the same as for the original strategy.

It is also possible to enable automatic revision of the current strategy in the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#tab-strategy). You can specify that an automatic revision will occur after each couple of laps as well as after an unplanned pitstop. Cato will inform you whenever a better strategy has been identified and will give you as much information as possible about the differences between the currently active and the new strategy. You then can decide, that it should be activated for the rest of the session. Whether you can use this without sacrificing performance or introducing lags, depends on your PC configuration (see next advice). Please note, that with the current release, automatic revision will only bring up strategies which are to be considered better in terms of final number of laps or race time. This means that the strategist **not** automatically suggests a *slower* strategy, which may be necessary, for example, due to the onset of rain. The reason for this is the large number of edge cases in these situations. However, you can manually request a new strategy via voice command or controller action to override the current, probably *better* strategy.

Finally a word of a advice: The calculation of a strategy can be a time consuming and CPU intensive process, especially for long endurance races or if the *Optimizer* was used during the creation of the initially strategy, and, with even more impact, when the Monte Carlo traffic simulation method is used. This can result in framerate drops on weaker PC systems. So please check before an important race, whether you can use this functionality safely in your specific environment. But, even if your system is capable to handle the load, the recalculation may take some time, especially when high *Optimizer* settings were chosen during the creation of the original strategy.

#### Handling Full Course Yellow

Cato is also able to handle a Full Course Yellow condition, as long as a selected strategy is active. If you encounter a Full Course Yellow and if it is allowed to go to the pit during Full Course Yellow, you can ask the Strategist to evaluate whether a pitstop will be of benefit in this situation. There is a voice command and also a controller action available to trigger this evaluation. If the Strategist thinks that it is of benefit to perform an early pitstop, it will ask you and then directly calls you to the pit, while the Engineer is already preparing the pitstop.

Remarks:

1. When Cato has created a new strategy with an immediate pitstop, only the number of pitstops are used to compare it against the currently active strategy, since in most cases, the benefits of performing a pitstop during Full Course Yellow outweighs a possible longer stint afterwards. Therefore, if the new strategy has the same number of remaining pitstops, it is considered valid and the Strategist will call you to the pit.
2. Be careful, when using teh Full Course Yellow handling during the first few laps, since the calculation of average lap time and fuel consumption might not be exact then. Normally, the Asisstants will refuse to help you in the learning phase, but in case of Full Course Yellow this is overriden. As long as you have already collected data about the given car / track / weather condition, this information is used and you will be fine. Otherwise double-check the recommendation.
3. If you have accepted the new strategy with an immediate pitstop, the Engineer will be informed without further notice. He will plan and prepare the pitstop immediately without waiting for the next crossing of the start/finish line, as usual. This is important, so that you can enter the pit at the end of the current lap.

### Autonomous Mode

If you have chosen *Autonomous Mode* in the [*Strategy* tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#tab-strategy) of the "Race Settings" as described above, the Strategist and the Engineer will work together using the selected strategy in such a way, that no further interaction or decisions are needed from the drivers side regarding strategy updates, pitstop handling, and so on. Both Assistants will exhibit the same behaviour as in the non-autonomous mode, but they will not ask for confirmation, if they think that an action is required. Instead of asking for confirmation, the corresponding action is performed immediately and you are notified about that. As a result, the two Assistants now act as Agents, which feels very natural, very much like a real pit crew.

The Strateist will not ask for confirmation for the following actions:

1. Give an introduction for the race strategy at the beginning of a session.
2. Alter the strategy due to fuel requirements or changing conditions.
3. Alter the strategy due to traffic requirements and possible undercut chances.
4. Explain a changed strategy and the result of the corresponding traffic and position simulation.
4. Calling you to the pit, thereby informing the Engineer to plan the pitstop.

Additionally, the Engineer will not ask for confirmation to prepare an already planned pitstop, when it is time to come to the pit.

Both Assistants will still ask for confirmation when actions are necessary due to weather changes, damages caused by accidents, and so on. It is possible to disable those confirmations as well, though. For this, take a look at the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-settings) in the "Session Database" and search there for "Confirm" to see all the available settings.

## Technical information

Cato uses the same AI kernel as Jona. In fact, large parts of the basic rule set is identical for both Assistants. Therefore, you can consult the [technical information](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#technical-information) of Jona, if you want to dig deeper into the inner workings.

### Data Acquisition

The complete position information is requested from the simulation gane every 10 seconds (this is the default, you can lower that in the settings, if your PC is fast enough). For each car, the data contains the current position, the last lap time and the fraction of the track which has been driven since the car last crossed the S/F line. The data acquisition is controlled by the "Race Strategist" plugin. For *Assetto Corsa*, *RaceRoom Racing Experience*, *rFactor 2*, *Le Mans Ultimate*, *iRacing*, *Automobilista 2* and *Project CARS 2* the data is requested from shared memory using the same data providers, which are used by Jona as well, whereas a special UDP client is used for *Assetto Corsa Competizione* (due to the asynchronous nature of the UDP interface for *Assetto Corsa Competizione*, the provided data is not always exact).

After the data has been gathered, it is then transfered to the *Race Strategist* process and loaded into the knowledge base, where the statistical models create several projections for future position development. Beside that, a historical copy is created for each lap. 

	[Position Data]
	Driver.Car=1
	Car.Count=20
	Car.1.Car = Mazda MX-5 Cup
	Car.1.Driver.Forname = The
	Car.1.Driver.Nickname = TB
	Car.1.Driver.Surname = BigO
	Car.1.Laps = 2
	Car.1.Lap.Running = 0
	Car.1.Position = 1
	Car.1.Time = 110650
	Car.2.Car = Mazda MX-5 Cup
	Car.2.Driver.Forname = Jimmy
	Car.2.Driver.Nickname = JV
	Car.2.Driver.Surname = Van Veen
	Car.2.Laps = 1
	Car.2.Lap.Running = 0.9514
	Car.2.Position = 14
	Car.2.Time = 123535
	Car.3.Car = Mazda MX-5 Cup
	Car.3.Driver.Forname = Jennifer
	Car.3.Driver.Nickname = JY
	Car.3.Driver.Surname = Young
	Car.3.Laps = 1
	Car.3.Lap.Running = 0.9827
	Car.3.Position = 4
	Car.3.Time = 117209
	...

## Troubleshooting

For some tips n tricks for the best voice recognition experience, see the [corresponding chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#troubleshooting) in the documentation of Jona.