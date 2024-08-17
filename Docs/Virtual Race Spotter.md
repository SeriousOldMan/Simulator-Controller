## Introduction

Elisa, the Virtual Race Spotter is a part of the Race Assistant family of Simulator Controller. As a spotter, Elisa watches over your car and all the cars around you. Elisa will warn you about critical situations, for example, when a car appears in your blind spot, or when a car is chasing you from behind. Furthermore, Elisa will inform you periodically about other aspects of the traffic around you, for example, when one of the leading cars is closing in from behind and you are getting a blue flag.

## Installation

The installation procedure for Elisa is the same as the [installation procedure for Jona](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#installation), which means, that you are also well prepared to use the Spotter, if you have everything setup correctly for the Engineer.

## Interacting with Elisa

The same principles as [described for Jona](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#interacting-with-jona) apply here as well, since Elisa is based on the same technology as Jona.

### List of all voice commands

1. [English version](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Spotter-Commands-(EN))

2. [German version](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Spotter-Commands-(DE))

I strongly recommed to memorize the phrases in the language you use to interact with Elisa. You will always find the current version of the grammar files as actually used by the software in the *Resources\Grammars* folder of the Simulator Controller distribution. Or you can take a look at the files in the [*Resources\Grammars* directory on GitHub](https://github.com/SeriousOldMan/Simulator-Controller/tree/main/Resources/Grammars), for example the German version [Race Spotter.grammars.de](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Resources/Grammars/Race%20Spotter.grammars.de).

#### Extending conversation and reasoning capabilities using an LLM

Beside the builtin pattern-based voice recognition and the speech capabilities based on predefined phrases as described above, it is optionally possible to connect Elisa to a GPT service like OpenAI or a locally hosted LLM, to dramatacilly improve the quality in conversation with the Assistant. And you can also extend the knowledge and reasoning capabilities. When the *Conversation* Booster or the *Reasoning* booster are configured (see [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants) for more information about the necessary configuration steps), the full knowledge about the car state will be supllied to the LLM. In detail, this includes tyre pressures, tyre temeperatures, tyre wear, brake temperatures, brake wear, fuel level, fuel consumption, damage, and so on. When a pitstop is planned, the plan is available and the pitstop history is also available.

### Enabling and disabling specific warnings and announcements

As described in the next section, Elisa will give you a lot of warnings and announcements about traffic and the overall race situation. You may disable these announcements by using a special voice command:

	[Please] No more *announcement* [please]

As you might expect, the word "please" is optional. Available options for *announcement* are: "delta information", "tactical advice", "side alerts", "rear alerts", "blue flag warnings", "yellow flag warnings", "cut warnings", "penalty information", "slow car warnings", "ahead accidents warnings"  and "behind accidents information". After you have disabled one of the warnings (all are enabled or disabled by default according to your choices in the configuration, see below), you can reenable it with the following command:

	[Please] Give me *announcement* [please]

As an alternative, you can disable unwanted talking completely by saying:

	Be quiet please

To reactivate the Assistant use:

	I can listen now

These commands are also available as "Mute" and "Unmute" plugin actions, which can be configured for a Button Box or a Stream Deck, for example.

### Multi-class support

Elisa *understands* multi-class and multi-category races. Position evaluation and gap and lap time information will be always focused on your own class. Where it is necessary to mention, for example, the overall position, Elisa will phrase it in a way, so that you understand, that information is related to the whole grid. You can configure in the [settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database", in what way Elisa uses the information about the car classes and cup categories to partition the grid.

## Alerts & Information

The Spotter will give you critical and in most cases real time information about the current race situation. This helps you to keep track and stay out of trouble. In detail:

1. Proximity Alerts

   This real time information will highlight other cars on your side and directly behind you. Elisa will warn you about cars on your left and on your right (as well as three wide situations) and will also inform you, when the situation has cleared up. A warning will also be issued, when a car is very near to your back of your car, typically closing in for a pass maneuver. Elisa will use a path prediction algorithm, therefore sometimes you will get not only a warning that a car is at your rear, but also a hint, on which side the passing maneuver might take place. This may give you the opportunity to respond with countermeasures.

2. Yellow Flag Warnings

   When a yellow flag has been raised, you will get a warning from Elisa. Typically, you will get information about the sector, which is under yellow and sometimes also the distance into the track, where the incident happend. You will get a special warning for full course yellow and Elisa will also information you, when the yellow phase hase ended and the track is green again.

3. Accident and Slow Car Warnings

   The Spotter learns the track layout and the typical speeds during the first laps of a session. This information is relearned after a pitstop or whenever you set a new best lap. When one or more cars are way off the typical speed, this will be handled as a danger on the track. Depending on the speed difference and the heading of the car, it may count as an accident or a slow car. The Spotter will inform you about the fact and the approximate distance to the car(s). The Spotter can also inform you about accidents behind you, since this may give you advantage.

4. Blue Flag Warnings

   Once a lapping car appears behind, you will get a blue flag warning. This typically appears, when the faster car is less than 2 seconds behind. If there is also a direct opponent currently behind you, you will be informed about that as well, so that you can be cautios to not let this car pass together with the lapping car.

5. Green Flag (Race Start) Alert

   The Spotter gives you a *push*, when the race has been started.

6. Pit Window Information

   Elisa will inform you when the timed window or the designated lap for a required pitstop arrived. Elisa will inform you also, when the pit closes again.

7. Start Performance Summary

   You will get an update whether you gained or lost places during the start phase a few laps into the race.

8. Best Lap Update

   When ypu have scored a new personal best lap, you will get a notification.

9. Delta Information

   Elisa observes your direct opponents behind and in front of you and informs you, whether you can catch up the car in front or whether you need to pay attention to the car behind you. Please take a look at the dedicated section about [Opponent and Delta Information](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#opponent-and-delta-information) down below for more detailed information.
   
   There are two methods available for this information:
   
   - Static
   
     This calculation method is quite simple and uses only the direct delta information provided by the simulation. It will simply you provide you with the current gap to your opponent in front and the one behind. This method is precise but you must calculate on your own whether you have catched up or lost upon your opponent.

   - Dynamic
   
     This method uses a complex traffic model and keeps track off all cars regarding their current position and specific deltas to your car. You will get much more information, for example, how much time you have lost on the car ahead during the last laps. But this model will fail in turbulent traffic situations especially in the beginning of the race or in sprint races with lots of fights and overtakes and you might get wrong deltas in those situations.

10. Tactical Advices

    The Virtual Race Spotter has been trained to detect several typical race situations and therefore can advise you how to best handle the corresponding situation. For example will Elisa analyze the laptime difference, when you will be shortly overtaken by another car and will tell you whether it will be possible for you to stay in the slipstream of this faster car. Other adivises will help you to handle faster lapped cars, protect your position by bringing a slower car between you and direct opponent which tries to attack you, and so on. The Race Spotter will learn to detect and handle more situations in the future.

11. Cut warnings & penalty information

    Depending on the available data from the simulator, you will be informed about track cuts and issued penalties by the Spotter.

12. Weather Updates

    The Spotter will inform you when temperatures (both air and track) are rising or falling and will give you the new temperatures in degrees Celcius.

13. Last Laps Announcement

    You will get an announcement a few laps before the end of the race.
   
14. Stint Timer Alert

    During an endurance race, the Spotter will alert you, that the stint time is ending soon and will tell you the number of laps, which you can still go.

15. Session Timer Information

    When you are in a practice or qualifying session, the Spotter will issue a warning 30, 15 and 5 minutes before the end of the session.

16. Half Time Notification

    Exactly in the middle of the race, the Spotter will give you a couple of informations about the second half of the race, like your current position, the number of remaining minutes and laps, the number of laps which are possible using the remaining fuel, and so on.

All these alerts and announcements can be individually configured or disabled with the configuration tool for each simulator. Please consult the [corresponding documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-spotter) for more information. 

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%2011.JPG)

Please note, that not every simulation will support all these capabilities and that the behaviour will be very different in each simulation. This is due to the fact, that the provided data differs heavily between the different simulations. Please see the section below for detailed information.

### Opponent and Delta Information

Elisa tracks the positions, lap times and the deltas to your own car for four different other cars, the cars directly in front and behind you as well as the car one race position before and one race position behind you:

  - Relevant changes in the deltas to these cars will be updated each sector and the Spotter might inform you about any changes each sector, each lap, each second lap, and so on, according to your choices in the ["Race Spotter" tab in configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-spotter). It will take one lap for Elisa to collect all sector timings for each of these four cars, before Elisa will inform you, whether you have gained or lost to the given car. This will be reset, once you have been overtaken or when you overtook the car in front of you.

  - A special case is a situation where you are in attack position to the car in front of you or when the car behind is in attack range. This information will be issued as soon as possible, as long you are faster than the car in front of you or the car behind is faster than you.
  
  - Another special case occurs, when you are approaching a car in front of you which is a lap up or a lap down. Elisa will give you the corresponding information annd additional tactical information about these cars (see above).

When you approach a car in front of you, Elisa will gather all available information for the given car, whether the driver is quite inconsistent or is doing a lot of mistakes, and so on. Depending on the situation, Elisa might give you this information and will ask you to be careful, if necessary.

Elise uses different delta thresholds to decide, whether the situation changed to an extent that an update will be of any value for you. You can define your own thresholds in the "Race Settings" in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database). See the table below for the thresholds and their default values.

| Threshold                | Default Value (Seconds) |
| ------------------------ | ----------------------- |
| Lap up car in range      | 1.0                     |
| Lap down car in range    | 2.0                     |
| Attack car in front      | 0.8                     |
| Gained on car in front   | 0.3                     |
| Lost on car in front     | 1.0                     |
| Attack car behind        | 0.8                     |
| Lost on car behind       | 0.3                     |
| Gained on car behind     | 1.5                     |

Please note, that the corresponding settings in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) will follow the naming conventions for Session settings, for example: "Spotter: Threshold for Lap Up car in range".

## Simulator Integration

As mentioned, each simulator is different. The Spotter will make as much out of the data supplied by the simulation as possible, as long as a specific information is available, even if it is somewhat restricted. The following table shows you which capability of the Spotter is available in the different simulators.

| Capability                      | Assetto Corsa | Assetto Corsa Competizione | Automobilista 2 | iRacing | RaceRoom Racing Experience | rFactor 2 | Project CARS 2 | Le Mans Ultimate |
| ------------------------------- | --------------| -------------------------- | --------------- | ------- | -------------------------- | --------- | -------------- | ---------------- |
| Side Alert                      | Yes (1)       | Yes                        | Yes             | Yes     | Yes                        | Yes       | Yes            | Yes              |
| Behind Alert                    | Yes           | Yes                        | Yes             | Yes (2) | Yes                        | Yes       | Yes            | Yes              |
| Accidents Ahead (7)             | Yes           | Yes                        | Yes             | Yes (8) | Yes                        | Yes       | Yes            | Yes              |
| Accidents Behind (7) (10)       | Yes           | Yes                        | Yes             | Yes (8) | Yes                        | Yes       | Yes            | Yes              |
| Slow Cars (7)                   | Yes           | Yes                        | Yes             | Yes     | Yes                        | Yes       | Yes            | Yes              |
| Yellow Flag                     | Yes           | Yes                        | Yes             | Yes     | Yes                        | Yes       | Yes            | Yes              |
| Full Course Yellow              | No            | No                         | No              | No      | No                         | No        | No             | No               |
| Sector Yellow                   | No            | Yes                        | No              | No      | Yes                        | Yes       | No             | Yes              |
| Yellow Distance                 | No            | No                         | No              | No      | Yes                        | No        | No             | No               |
| Blue Flag                       | Yes           | Yes                        | Yes             | Yes     | Yes                        | Yes       | Yes            | Yes              |
| Track Cuts (Invalid Laps)       | Yes           | Yes                        | Yes             | Yes (9) | Yes                        | Yes       | Yes            | Yes              |
| Penalty Information             | No            | Yes                        | No              | No      | Yes                        | Yes (6)   | No             | Yes (6)          |
| Pit Window                      | No            | Yes (by time)              | Yes (by lap)    | No      | Yes (by time and lap)      | No        | Yes (by lap)   | No               |
| Race Start (Green Flag)         | No            | Yes                        | Yes             | Yes     | Yes                        | Yes       | Yes            | Yes              |
| Delta Information               | Yes           | Yes (3)                    | Yes             | Yes     | Yes                        | Yes       | Yes            | Yes              |
| Tactical Advices (4)            | Yes           | Yes                        | Yes             | Yes     | Yes                        | Yes       | Yes            | Yes              |
| General Session Information (5) | Yes           | Yes                        | Yes             | Yes     | Yes                        | Yes       | Yes            | Yes              |

##### Notes

(1) Due to the way the data acquisition for *Assetto Corsa* works, it is possible that alerts for cars on your side will be given for the wrong side from time to time. I am working on a heuristic to prevent that.

(2) The iRacing data interface does not provide any real time position information, only a flag whether there are cars on your side. Therefore the decision, whether a car is behind you, is based on the track percentage value of the data interface and is therefore not as precise as in the other simulators.

(3) The position and timing data provided by the UDP interface of Assetto Corsa Competizione is asynchronous by design. Therefore it might be possible, that the information provided by the Spotter does not reflect the current race situation exactly. It might be possible. for example, that you get a notification, that you now can overtake your opponent although you overtook him just a second ago.

(4) This includes information when your opponents are going to the pit, when and where it will be best to overtake another car, whether your opponents have a risky driving style, and so on.

(5) This includes a summary of the start performance, final laps announcement, weather updates, best lap acknowledgement and general information about stint, session and fuel limits.

(6) No detailed information for the concrete penalty available.

(7) The distance ahead or behind, for which this is checked and reported can be defined in the [race settings] (https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database". Default is 800 meter for accidents ahead and 500 meter for slow cars and accidents behind. The track spline will be learned during the initial laps, depending on the simulator. Therefore accident detection might not be available in this time. See also the special notes for *Assetto Corsa Competizione* below.

(8) The *iRacing* API does not provide any information about the current speed of all cars on the track, only for the drivers car. Since the crash detection is implemented using an integral over track distance and speed, the algorithm tries to learn the typical speed for each car over time. The detection is therefore not reliable during the first laps.

(9) iRacing has no information of number of cuts per lap in the available data. It is only detectable in a given point in time, whether the car is off track. It therefore depends on the data sampling frequency, how reliable the detection of track cuts is.

(10) Only in a race session.

##### Accident detection for *Assetto Corsa Competizione*

The algorithms used for accident and slow car detection are based on learning the track layout, the ideal line and the typical speeds during the initial laps. Unfortunately, the initial laps also see many accidents in some races, which can lead to false positives further down the road. Additional code is included which tries to detect and correct this, but in some cases it cannot handle the situation. If you encounter many false warnings like "Slow car ahead in 200 meters." by the Spotter during a race, although there is no such slow car, you can disable the warnings by using the voice command:

	No more *warning*, please.
	
Use one of "slow car warnings", "ahead accidents warnings", "behind accidents information" for *warning* as required. If this is not usable for you, for example, because you re not using voice control at all, you can also disable the accident warnings completely in the configuration.

## Track Mapping

Using the positions of the cars on the track, Elisa is able to create a map of any track in any simulator (except for *iRacing*, where a [different method](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#special-notes-about-track-mapping-in-iracing) is applied, since no coordinates are available in the API). A track map consists of two files which are stored in your local database. The first file with the ".map" extension contains the meta data of the track map and all way points (between 1000 and 1500 points for a typical race course).

	[General]
	Simulator=Assetto Corsa Competizione
	Track=Circuit Zandvoort
	TrackType=Circuit
	[Map]
	Height=828
	Offset.X=394.799000
	Offset.Y=426.871000
	Margin.X=50.0
	Margin.Y=50.0
	Points=1569
	Scale=0.900000
	Width=945
	X.Max=596.604
	X.Min=-347.549
	Y.Max=441.796
	Y.Min=-385.471
	[Points]
	1.X=-145.027
	1.Y=-57.783
	...

The second file, which is generated using the way points from the meta data file, is a simple image file representing the outline of the track (typical a PNG file).

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Track%20Map.png)

The track maps are recorded using a 20 Hz resolution, which is comparable to the resolution of high end GPS-based track mapping devices. Therefore the resolution of the generated maps is very good. But since the maps are created, while you are driving on a track, it may be possible that the generated map is not perfect, because you had an offtrack or even an accident. If you face such a situation, simply delete the track in question using the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) tool and the track map will be regenerated during your next visit on this track.

Track maps are used by the "Race Center" which provide a [live view](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Center#data-analysis) of the current race situation. And using the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database), you can associate actions with specific locations on the track map. This actions can change settings in the current simulator by issuing keyboard commands or they can even lauch a Windows script or application, when you arrive at this location. See the section below for a detailed discussion of Track Automation.

### Track Formats

The track mapper can handle closed tracks, like a typical race circuit, but it can also handle open tracks, for example a Rallye stage. You must specify the the track format ("Rally", "Hill", "Street") in the "Session Database" for each track that is not closed ("Circuit" is the default).

Please note, that this is only supported for simulators which can handle non-closed tracks.

### Special notes about Track Mapping in *iRacing*

A special case when recording the track coordinates is *iRacing*. This simulator does not provide real track coordinates. A special algorithm is used here using the *yaw* angle of the car combined with the current velocity, while scanning this data with a 60 Hz resolution. Therefore it is absolutely necessary that you drive as clean as possible during the time where the track is recorded - typically during the first 4 laps. Drifting and sliding, although a lot of fun, will give you very bad results. The coordinates are derived as follows:

1. Initialize the starting position as *x = 0.0* and *y = 0.0*.
1. Apply a fixed sampling rate, in this case 60 Hz.
2. Get a cars *yaw* value from the *iRacing* API.
4. Get the cars *velocity* for the x-direction from the *iRacing* API.
5. Calculate *dx* as *velocity(x)* * *sin(yaw)*.
6. Calculate *dy* as *velocity(x)* * *cos(yaw)*.
7. Set *x* as *x* + *dx*.
8. Set *y* as *y* + *dy*.
9. Wait one sample and go to 2. unless the starting position (plus / minus a threshold) has been reached.

As you can see, the yaw angle is the most important value in this calculation, therefore drive smoothly.

## Track Automations

When a track map is available, the Race Spotter is able to trigger special actions at any location of the track. Using this actions, you can send commands to the running simulator to switch between car settings, for example the traction control.

Track Automations are configured in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database). Once a track map is available for a given track, you can choose the "Automation" section there:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Track%20Automation%202.JPG)

You can create different sets of Track Automations for different purposes. Here we have a "Hotlap" automation for Zandvoort, where the traction control is reduced by 2 before T1 and is returned to its original setting after T4. The "Race" automation is similar, but reduces the traction control only by 1.

First you have to create an automation by pressing the "+" button. Then give it a name and enter as many actions as necessary, by clicking at the corresponding track location. The following dialog opens:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Track%20Automation%203.JPG)

Here you define, what should happen, when you arrive at this specific location on the track. You have two options:

1. Hotkey(s)

   You can enter a list of keyboard commands that should be send to the simulator. Each keyboard command is a [keyboard command hotkey](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#hotkeys). Use the vertical bar to separate between the individual commands. In the example above, the following definition is used: "^!+t | ^!+t". Theis stands for "Control-Alt-T" (uppercase "T", because the "Shift" key is selected as well with the "+") pressed twice in a row.
   
   Note: You can use the [Trigger Detector Tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#trigger-detector-tool) to find out, which hotkey string corresponds to a given keyboard command. This hotkey string will be placed in the Clipboard and can be pasted to the input field after closing the trigger detector tool.

2. Command

   In this case, you can selected every script or application, which is executable by Windows. Use the "..." button to locate the executable.
   
You can reopen the action dialog anytime, by clicking again at the automation location. And you can move actions around whith the left mouse button pressed and you can delete an action by holding down the "Control" key, while clicking on it.

Don't forget to save the Track Automation finally. After you have create all required Track Automations, choose one of them as the default to load when you enable Track Automations, by checking it in the list of automations.

Some words of advice: The action points are identified by the current location of your car. Since there is a sampling rate of about 200 Hz, the location on the track is never exact. Therefore a distance threshold is used, which is about 20 meters. Additionally a cool down period of 2 seconds is used to suppress multiple activations of the same action. This works pretty well. But make sure to use enough distance between your action locations, at least larger than the above mentioned threshold. This is especially important, where two parts of the track are quite near (only separated by a wall, for example). If you ever crash exactly at the location of an action point, this action might be triggered mutiple times, but you will already have a different problem, right?

And a final warning: This kind of automation might be considered illegal according to the rules of some leagues. Therefore please check the rulebooks, when participating in league races. Please obey the rules and follow the spirit of sportsmanship.

### Enabling and disabling Track Automations

For Track Automations to be active, you must enable them, when you are on the track. Once Track Automation is enabled, the default automation (see above) is loaded and activated at the beginning of the next lap. The ["Race Spotter" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-spotter) provides an action, which you can bind to your controller to enable or disable Track Automations.

### Choosing between different Track Automations

As you have seen above, you can select one of the available Track Automations as the default, which will be loaded and activated, when you enable Track Automations. But there might be occasions, for example, when the weather changes, where you want a different set of track actions to be active. In this situation you can load a different Track Automation by name using the ["seleectTrackAutomation"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) action function. To use this, you must create an entry in your configuration like:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Track%20Automation%201.JPG)

If you are using "Simulator Setup" for your configuration tasks, you can achieve the same by adding the following lines to the ["Configuration Patch.ini"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#patching-the-configuration) file:

	[Controller Functions]
	Custom.42.Call=<^<!W
	Custom.42.Call Action=selectTrackAutomation(Wet)

In this example, the "<^<!W" stands for the [keyboard command hotkey](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#hotkeys) *W* pressed together with left *Control* and the left *Alt* key. But you can also use a button on your steering wheel, for example: "3Joy15". However. when the trigger is detected, the action function "selectTrackAutomation" Track Automation is called and loads the Track Automation named "Wet" for the current simulator / car / track combination.

### Ex- and importing Track Automations

Track Automations can be exported and imported using the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) administration tool, so you can share them with your team mates. Please note, that for *iRacing* it might be necessary to share the track map as well, since the track coordinates might differ with each recording of the track.