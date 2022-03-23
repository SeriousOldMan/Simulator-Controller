## Introduction

Elisa, the Virtual Race Spotter is a part of the Race Assistant family of Simulator Controller. As a spotter, Elisa watches over your car and all the cars around you. Elisa will warn you about critical situations, for example, when a car appears in your blind spot, or when a car is chasing you from behind. Furthermore, Elisa will inform you periodically about other aspects of the traffic around you, for example, when one of the leading cars is closing in from behind and you are getting a blue flag.

## Alerts & Information

The Spotter will give you critical and in most cases real time information about the current race situation. This helps you to keep track and stay out of trouble. In detail:

1. Proximity Alerts

   This real time information will highlight other cars on your side and directly behind you. Elisa will warn you about cars on your left and on your right (as well as three wide situations) and will also inform you, when the situation has cleared up. A warning will also be issued, when a car is very near to your back of your car, typically closing in for a pass maneuver. This may give you the opportunity to respond with countermeasures.

2. Yellow Flag Warnings

   When a yellow flag has been raised, you will get a warning from Elisa. Typically, you will get information about the sector, which is under yellow and sometimes also the distance into the track, where the incident happend. You will get a special warning for full course yellow and Elisa will also information you, when the yellow phase hase ended and the track is green again.

3. Blue Flag Warnings

   Once a lapping car appears behind, you will get a blue flag warning. This typically appears, when the faster car is less than 2 seconds behind. If there is also a direct opponent currently behind you, you will be informed about that as well, so that you can be cautios to not let this car pass together with the lapping car.

4. Pit Window Information

   Elisa will inform you when the timed window or the designated lap for a required pitstop arrived. Elisa will inform you also, when the pit closes again.

5. Start Performance Summary

   You will get an update whether you gained or lost places during the start phase a few laps into the race.

6. Distance Information

   Elisa observes your direct opponents behind and in front of you and informs you, whether you can catch up the car in front or whether you need to pay attention to the car behind you.

7. Last Laps Announcement

   You will get an announcement a few laps before the end of the race.

All these alerts and announcements can be individually configured or disabled with the configuration tool for each simulator. Please consult the [corresponding documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-spotter) for more information. 

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%2011.JPG)

Please note, that not every simulation will support all these capabilities and that the behaviour will be very different in each simulation. This is due to the fact, that the provided data differs heavily between the different simulations. Please see the section below for detailed information.

### Enabling and disabling specific warnings and announcements

As you have seen above, Elisa will give you a lot of warnings and announcements about traffic and the overall race situation. You may disable these announcements by using a special voice command:

	[Please] No more *announcement* [please]

As you might expect, the word "please" is optional. Available options for *announcement* are: "distance information", "side alerts", "rear alerts", "blue flag warnings", "yellow flag warnings". After you have disabled one of the warnings (all are enabled or disabled according to the settings described above), you can reenable it with the following command:

	[Please] Give me *announcement* [please]

## Simulator Integration

As mentioned, each simulator is different. The Spotter will make as much out of the data supplied by the simulation as possible, as long as a specific information is available, even if it is somewhat restricted. The following table shows you which capability of the Spotter is available in the different simulators.

| Capability                | Assetto Corsa Competizione | Automobilista 2 | iRacing | RaceRoom Racing Experience | rFactor 2 |
| --------------------------| -------------------------- | --------------- | ------- | -------------------------- | --------- |
| Side Alert                | Yes                        | Yes             | Yes     | Yes                        | Yes       |
| Behind Alert              | Yes                        | Yes             | No (1)  | Yes                        | Yes       |
| Yellow Flag               | Yes                        | Yes             | Yes     | Yes                        | Yes       |
| Full Course Yellow        | Yes                        | No              | No      | Yes                        | Yes       |
| Sector Yellow             | Yes                        | No              | No      | Yes                        | Yes       |
| Yellow Distance           | No                         | No              | No      | Yes                        | No        |
| Blue Flag                 | Yes                        | Yes             | Yes     | Yes                        | Yes       |
| Pit Window                | Yes (by time)              | Yes (by lap)    | No      | Yes (by time and lap)      | No        |
| Start Performance Summary | Yes                        | Yes             | Yes     | Yes                        | Yes       |
| Distance Information      | Yes                        | Yes             | Yes     | Yes                        | Yes       |
| Final Laps Announcement   | Yes                        | Yes             | Yes     | Yes                        | Yes       |

(1) The iRacing data interface does not provide any real time position information, only a flag whether there are cars on your side. So there is actually no way to safely decide, whether a car is behind you.