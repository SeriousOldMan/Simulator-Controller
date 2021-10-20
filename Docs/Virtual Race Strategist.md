## Preambel

Cato is based entirely on the technology of Jona, the Virtual Race Engineer. Therefore, all concepts from the [associated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer), especially for installation and configuration, also apply here.

## Introduction

As a complement to Jona, your Virtual Race Engineer, this new assistant will accompany you during your races as a Virtual Strategist. Cato will have complete knowledge over the race session incl. lap times of you and your opponents, the current race positions, pitstop events, weather changes, and so on. You can request updates for all these informations by asking Cato for the position, the gaps to the car in front and behind and also request information about the current lap times of your opponents and wether they are closing in. All this, although very useful, if you are racing using VR, is only a part of Catos capabilties. Cato will furthermore be able to develop appropriate pitstop strategies if you are stuck in traffic and he will be able to react to unforeseen events such as sudden weather changes and severe damage - all hand in hand with Jona, the Virtual Race Engineer. This functionality will come step by step over the course of the next releases. Also step by step will the support for the various simulation games develop. Support for *Assetto Corsa Competizione*, *rFactor 2*, *RaceRoom Racing Experience*, *iRacing* and *Automobilista 2*is already there.

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

**Cato: "I recommend a pitstop in lap 17. Should I inform your race engineer?"**

**Driver: "Yes, please."**

(Cato will hand over the information to your virtual race engineer, which will handle the technical stuff and plan the pitstop.)

To have an error free session like this one, you must have a perfect setup for voice recognition. I strongly recommend using a headset, since alien noises might lead to false positives in Catos voice recognition. Please see the section on [troubleshooting](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#troubleshooting) in the documentation for Jona, if you need some hints.

## Installation

The installation procedure for Cato is the same as the [installation procedure for Jona](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#installation), which means, that you are also well prepared to use Cato, if you have everything setup correctly for Jona.

## Interacting with Cato

The same principles as [described for Jona](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#interacting-with-jona) apply here as well, since Cato is based on the same technology as Jona.

I strongly recommed to memorize the phrases in the language you use to interact with Cato. You will always find the current version of the grammar files in the *Resources\Grammars* folder of the Simulator Controller distribution. Or you can take a look at the files in the [*Resources\Grammars* directory on GitHub](https://github.com/SeriousOldMan/Simulator-Controller/tree/main/Resources/Grammars), for example the German version [Race Strategist.grammars.de](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Resources/Grammars/Race%20Strategist.grammars.de).

## Racing with Cato

Cato will be active during practice and race sessions, although the assistant will be of not much help in a practice session, since it only collects data for future race strategy development purposes. Using Cato during a race is easy. You can activate the assitant anytime using the activation phrase and ask then for information about current lap times, current and possible future standings and so on. Normally, Cato will not contact you on its own like Jona does, but Cato will also collaberate with Jona, when it is time for a pitstop. In this situation, Cato might suggest a specific lap for the next pitstop to optimize your race position after the stop.

### Race Settings

Cato shares a lot of settings with Jona. Therefore consult the documentation on the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-settings) in the documentation for Jona for the general use of the settings tool.

#### Tab *Strategy*

You will find settings for the race strategy analysis and simulation in the third tab of the settings tool.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Settings%203.JPG)

Using the fields in the first group, you can customize the projection of current race positions into a model of future race standings. Cato will calculate this model each lap and will store the future standings for a given number of laps in the working memory and use them for strategy decisions. You can control the number of laps calculated for future standings by changing the value in the field *Race positions*. Greater numbers will yield better predictions, but take care, it might cost a lot of computing power.
With the second field, *Overtake Delta*, you specify the number of seconds as time discount for each overtake for the passing and for the passed car, whereas you specify the percentage of track length in front of the car, which will be taken into account for traffic density analysis.

The second group of fields specify the time required for several pitstop activities, as well as the pitstop window, in which the best pitstop lap will be derived. With the value of *Pitstop Delta*, you supply the difference time needed for a normal pitstop (time for pit in and pit out but without any service time minus the time to pass the pit area on the track, i.e. Drive through vs. Drive by), The fields below specify the time required for the various pit services, like changing tyres, refueling, and so on.

### How it works

Cato uses the position data gathered from the simulation game to form a complete overview of all drivers, their lap times and the development of their positions on track, even with different pit strategies. Using this knowledge, Cato can give you valuable information, but also can derive adapted race strategies, when your are stuck in traffic or are faced with other challenges.

The following statistical models are currently implemented:

  1. Weather trend analysis
  
     Cato will observe the weather development using the same rule set, that Jona uses. Thereby, Cato will notify you, when it is time to change the tyres, to achieve the best results. If you accept the recommendation, Cato will inform Jona to plan a pitstop with the best tyre compound for the upcoming conditions.

  2. Fuel availabilty and stint time calculation
  
     Cato will observe the average fuel comsumption. Depending on the race situation and strategy requirements, Cato might suggest to save fuel to get one or two more laps from the available full. 

  3. Standings and race position development

     Using the position data gathered from the simulation game, Cato builds a knowledge of the pace of the various drivers. As a simple application of this knowledge, Cato can give you information about the current race positions and lap times of your opponents and the gaps between the cars. A more complex application will be a forecast of the race positions in a given time frame (see the next point).
	 
  4. Pitstop simulation
  
     Also using the position data and a complex prediction model, Cato can determine the best lap for the next pitstop in a given pitstop window. The pitstop delta time as well as the service time is taken into account. The best pitstop lap will be selected based on position and the expected traffic after the pitstop.

### Race Reports

Cato allows you to save most of the data that is acquired during a race to an external database as a report for later analysis. You can configure, where and also when these reports are stored, using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-strategist). If a report has been saved for a given race, you use the "Race Reports" application to open this race from the database. After the race report has been opened, the "Race Reports" tool gives you several different views, which you can use to analyze the data.

  1. Overview Report
  
	 The overview list all drivers / cars with their starting positions, the best and average lap times, as well as the race results.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%203.JPG)

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

  4. Positions Report
  
     The Positions Report will show you the development of the positions of the different cars during the course of the race. When you hover with the mouse over a given car in the legend at the right side, the corresponding race line will be highlighted.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%201.JPG)

  5. Pace Report
  
     If you want to analyze lap times and consistency of the different drivers, this report is for you. The small rectangle marks the range of typical lap times of the different drivers. The smaller and further down the small rectangle, the faster and the more consistent the corresponding driver is. If there are small blue lines above or below the rectangle, these marks lap times, which are outside of the standard deviation, for example a slow lap time after a crash.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%202.JPG)

Some reports allow you to control the amount and type of data, which will be included in the report. Please click on the small gear button in the upper right corner of the window to open the settings dialog, with which you can change the settings for the report. The following window will open up:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Report%20Settings.JPG)

### Strategy Development

Another valuable tool, which is supported by Cato is the "Strategy Workbench". With the help of this tool, you can develop a pitstop and tyre strategy for an upcoming race. Simple sprint races with a single required pitstop are supported as well as endurance races with multiple stints and complex tyre and fuel saving strategies. An important feature of this tool is the ability to analyze telemetry data of past stints, that have been collected by Cato. This telemetry information is stored in the local database at the end of a session, as long as thiis has been activated in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-strategist) for the given simulator.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Strategy%20Workbench.JPG)

The "Strategy Workbench" is divided into two main areas. The upper area allows you to analyze the available telemetry information for a given car / track / conditions combination using several available graphical charts. Telemetry information are divided into an *Electronics* and *Tyres* group. In each group you can select up to four different series of values ​​that are to be plotted against each other in the chart.

The lower area allows you to create a race strategy. You have to enter the race rules and various settings before you can use the simulation tool to create the required pitstops based partly on your entered settings and also on the telemetry information. In the lower left part of the window, you find a tabbed pane with several input sections.

#### Rules & Settings

In the first tab you enter the rules and settings for the upcoming event. Using the *Settings* drop down menu directly above the tabbed area, you can load settings values from different sources, for example from the setup Database or the from the currently active simulation.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Strategy%20Settings%201.JPG)

Loading of settings is supported for:

  1. *Race.settings* file (from the setup database)
  
     The file chooser dialog is opened in the directory of the settings for the current simulator / car / track combination, but you may navigate to a totally different location if desired. The following fields are loaded from the settings file:
	 
	 - Rules & Settings
	   - Race Duration
	   - Formation Lap
	   - Post Race Lap
	   - Pitstop Delta
	 - Pitstop & Service
	   - Tyre Service Time
	   - Refuel Service Time
	 - Simulation
	   - Tyre Compound
	   - Tyre Compound Color
	   - Average Lap Time
	   - Average Fuel Consumption

  2. Telemetry Data
  
     The best lap time and the best hot tyre pressures are extracted for for the current simulator / car / track combination and the following fields are initialized from this data:
	 
	 - Simulation
	   - Map
	   - Average Lap Time
	   - Average Fuel Consumption

  3. Simulation
  
     If a simulator session exists and is identical to the currently selected simulator / car / track combination, the following fields are initialized from data acquired from the simulator:
	 
	 - Rules & Settings
	   - Fuel Capacity
	 - Simulation
	   - Initial Fuel Amount
	   - Map
	   - Tyre Compound
	   - Tyre Compound Color

Notes: If you specify a required pitstop window, this will be applied for the first pitstop. When a mandatory pitstop with a required tyre change and/or a required refueling has been defined, but actually there is no need for refueling or tyre change, the pitstop is planned as late as possible and only 1 liter will be refueled. All these are common scenarios for a GT3 solo or team sprint races. 

#### Pitstop & Service

In this tab you have to enter the time required for several pitstop activities, as well as the pitstop window, in which the best pitstop lap will be derived. With the value of Pitstop Delta, you supply the difference time needed for a normal pitstop (time for pit in and pit out but without any service time minus the time to pass the pit area on the track, i.e. Drive through vs. Drive by), The fields below specify the time required for the various pit services, like changing tyres, refueling, and so on. As you can see, this is very similar to the settings in the [*Strategy* tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#tab-strategy) in the Race Settings described above. In fact, the values you enter here will be used later on, if you export the strategy to be used for the upcoming race.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Strategy%20Settings%202.JPG)

#### Simulation

This is the central functionality for strategy development. Using the fields in this tab, you can define the starting conditions and settings for your first stint and run a strategy simulation. You can choose, whether to use only the values you entered here for engine map, lap time and average fuel consumption, or you can include the full knowledge from the telemetry data from previous sessions on the same track in similar conditions. For each different engine map and therefore fuel consumption and resulting average lap time, a strategy scenario will be created. These scenarios together with all additional scenarios created by the optimization algorithm (see below), will be compared at the end of the simulation and the best one regarding the overall race result will be selected as the best strategy. 

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Strategy%20Settings%203.JPG)

Enter the required values in the *Initial Conditions* group, choose the data to use and click on the "Simulate!" button. A summary of the strategy will be shown in fields in the *Summary* group. Use the sliders in the *Optimizer* group to define weights for diffferent variations of the simulation algorithm. These has the following meanings:

  - Fuel Consumption
  
	The slider defines a range between 0 and 10%, in which the simulation will decrease the fuel consumption, which has been derived from past telemetry data or from the values entered into the *Initial Conditions* group. This can be beneficial in endirance races for example, if you think, that you are able to save additional fuel by applying some lift n cost techniques or if you want to use a fuel saving engine map, for which no telemetry data is available yet.
  - Initial fuel
  
	Perhaps the most tricky one and it needs a lot of historical telemetry data to create sensible results. Using the slider, you can optimize the amount of fuel to be used for the first stint, thereby influencing the car weight and in the end the resulting lap times in the critical first phase of a race. For some cars, for example, lap times degrade heavily, if the amount of fuel and therefore the car weight is above a specific threshold. This can be derived from the telemtry data. If you set the slider completely to the left, the initial fuel amount entered in the *Initial Conditions* field group will be used only, whereas, if you set the slider to the right, you specify, how much of the fuel capacity of the car might be used as additional fuel for the simulation variations.
	
	Hint: If you want to simulate the whole range of initial fuel levels, enter **0** for the initial fuel level in the *Initial Conditions* field group and set the slider completely to the right.
  - Tyre Usage
  
	Here you have a range from 0 to 100% to enable some kind of *overuse* of tires. If you set the "Tyre Usage" slider to 30%, for example, this means that the tires can be used for 54 laps, even if the optimum tire life is at the beginning 40 laps was set. This might be useful to skip the tyre change in the last shorter stint of an endurance race.

For every slider not at the zero position, four different variations of the underlying value will be created as strategy sceanrios, which will be compared at the end for better results. 

You can use the commands in the *Simulation* drop down menu to start a simulation (similar to use the "Simulate!" button), and to copy the current results over to the *Strategy* tab. If you hold the Control key while pressing the "Simulate!" button or choosing the corresponding menu item, the selected scenario will be copied to the *Strategy* tab after the simulation.

#### Strategy

The values in this tab and also the document display on the right side of the tabbed pane describe the currently selected strategy. Normally this will be based on the last chosen simulation result, but you may adjust some of the settings and values using the fields in this tab. The *Strategy* allows you to save the current strategy, you can load a strategy from the database and you can compare different strategies. Finally, you can export the current stragey to Cato to be used for the next race or you can clear a previously exported strategy, so that you are on your own on the track.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Strategy%20Settings%204.JPG)

Good to know: The document shown on the right side can be printed using the right mouse button context menu.

Note: Exported strategies will be saved in the file "Race.strategy", which is located in the *Simulator Controller\Config* folder in your user *Documents* folder. There can only be one currently active strategey. Please see the next chapter for information, how Cato uses such a predefined strategy during a race.

### Strategy Handling

When a race session starts, Cato looks for a currently defined strategy and checks, whether this strategy has been defined for the same car and track in the same conditions and whether the duration of the ucoming session is identical to that defined in the strategy. If all these aspects match, Cato will use the strategy during the race. If there is a pitstop upcoming, Cato will actively inform you and will, as long as you accept it, hand over all settings for the pitstop to Jona for further handling. The pitstop will be planned and prepared for a specific lap and if you are in this lap, all settings will be entered into the Pitstop MFD of the current simulation, without any necessary interaction from your side.

The currently active strategy might be dropped, if you do not adhere to the pitstop plan defined in the strategy. To conform to the strategy, you must execute the pitstops in the laps as defined in the strategy +/- a few laps (10% deviation is allowed). If you think, that the predefined strategy is not of any use any more, because of a crash or changing weather conditions, you can cancel it actively with a voice command or by using ["StrategyCancel" controller action](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist).

## Technical information

Cato uses the same AI kernel as Jona. In fact, large parts of the basic rule set is identical for both assistants. Therefore, you can consult the [technical information](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#technical-information) of Jona, if you want to dig deeper into the inner workings.

### Data Acquisition

The complete position information is requested from the simulation gane every 10 seconds. For each car, the data contains the current position, the last lap time and the fraction of the track which has been driven since the car last crossed the S/F line. The data acquisition is controlled by the "Race Strategist" plugin. For *RaceRoom Racing Experience*, *rFactor 2*, *iRacing* and *Automobilista 2* the data is requested from shared memory using the same data providers, which are used by Jona as well, whereas a special UDP client is used for *Assetto Corsa Competizione*.

After the data has been gathered, it is then transfered to the *Race Strategist* process and loaded into the knowledge base, where the statistical models create several projections for future position development. Beside that, a historical copy is created for each lap. 

	[Position Data]
	Car.Driver=1
	Car.Count=20
	Car.1.Car = Mazda MX-5 Cup
	Car.1.Driver.Forname = The
	Car.1.Driver.Nickname = TB
	Car.1.Driver.Surname = BigO
	Car.1.Lap = 2
	Car.1.Lap.Running = 0
	Car.1.Position = 1
	Car.1.Time = 110650
	Car.2.Car = Mazda MX-5 Cup
	Car.2.Driver.Forname = Jimmy
	Car.2.Driver.Nickname = JV
	Car.2.Driver.Surname = Van Veen
	Car.2.Lap = 1
	Car.2.Lap.Running = 0.9514
	Car.2.Position = 14
	Car.2.Time = 123535
	Car.3.Car = Mazda MX-5 Cup
	Car.3.Driver.Forname = Jennifer
	Car.3.Driver.Nickname = JY
	Car.3.Driver.Surname = Young
	Car.3.Lap = 1
	Car.3.Lap.Running = 0.9827
	Car.3.Position = 4
	Car.3.Time = 117209
	...

## Troubleshooting

For some tips n tricks for the best voice recognition experience, see the [corresponding chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#troubleshooting) in the documentation of Jona.