## Introduction

Cato, the Virtual Race Strategist, allows you to save most of the data that is acquired during a race to an external database as a report for later analysis. You can configure, where and also when these reports are stored, using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-strategist). If a report has been saved for a given race, you use the "Race Reports" application to open this race from the database.

Important: "Race Reports" displays various graphs using the Google chart library in an embedded web browser. This web browser, which is part of Windows, must be configured for a given application using a setting in the Windows Registry. In most cases, this setting can be configured automatically by the given application, but in rare cases, admin privileges are required to insert the corrsponding key in the registry. If you encounter an error, that the Google library can not be loaded, you must run "Race Reports" once using administrator privileges.

## Available Reports

After a given race has been selected, the "Race Reports" tool offers you several different views, which you can use to analyze the data.

### Overview Report
  
The overview list all drivers / cars with their starting positions, the best and average lap times, as well as the race results.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%203.JPG)

For multi-class sessions, two result columns with the overall result and the class-specific result will be available. If available, driver categories are shown here as well for the starting driver, when you have enabled it in the [settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database".

### Car Report
  
A report with technical data of your own car, especially mounted tyres and electronic settings, as well as the weather conditions and the lap time for each lap.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%204.JPG)

### Driver Report
  
This report allows you to compare the inidividual abilities of the different drivers during the session. You can select the laps, which will be taken into account and you can choose the drivers to be included in the ranking (see the settings dialog below). Five dimensions will be computed in the ranking:

  - Potential: Based on the starting position and the race result.
  - Race Craft: Number of positive overtake maneuvers, as well as the number of laps in the top positions are taken into account.
  - Speed: Simply the best lap time.
  - Consistency: Calculated using the standard deviation of the lap times.
  - Car Control: Based on an analysis of all laps slower than (average lap time + standard deviation).

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%205.JPG)

Due to technical reasons, the driver names are always the names of the starting driver, even if you are in a team race and have selected a lap range, that had been driven by another driver.

### Positions Report
  
The Positions Report will show you the development of the positions of the different cars during the course of the race. When you hover with the mouse over a given car in the legend at the right side, the corresponding race line will be highlighted.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%201.JPG)

### Lap Times Report
  
This report will give you access to all lap times of all your opponents. These lap times will also be used to create the *Pace* chart (see next report), which supplies a much more intuitive way to judge the performance of a given car / driver, but sometimes looking at the numbers may reveal more detailed information.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%206.JPG)

Impotant: The laps will be always the last lap of you and your car. The report does not perform any lap up or lap down correction, take the lap number for your opponents with a grain of salt.

### Performance Report
  
This report provides a different view on the lap times of all drivers / cars. It can show you the lap times for a selected group of drivers / cars and laps graphically which makes it very easy to compare their respective performance.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%209.JPG)

### Consistency Report
  
The Consistency Report will give you a graphical representation of the lap times of a couple of cars and therefore is an addition to the Lap Times Report at the first look.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%207.JPG)

But when you select only one car, additional information will be made available. The minimum, maximum and average lap times will be added as marker lines to the graph and the overall consistncy number will be calculated and will be displayed at the top of the graph.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%208.JPG)

### Pace Report
  
If you want to analyze lap times and consistency of the different drivers, this report is for you. The small rectangle marks the range of typical lap times of the different drivers. The smaller and further down the small rectangle, the faster and the more consistent the corresponding driver is. If there are small lines above or below the rectangle, these marks lap times, which are outside of the standard deviation, for example a slow lap time after a crash. Inside the reactangle you may find a horizontal dividing line which represents the median of all lap times and a small grey dot, which shows the average or mean value of all lap times.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%202.JPG)

## Selecting report data

Some reports allow you to control the amount and type of data, which will be included in the report. Please click on the small button with the cog wheel in the upper right corner of the window to open the settings dialog, with which you can change the settings for the report. The following window will open up:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Report%20Settings.JPG)

Beside restricting the laps which will be included in the report, you can also choose the drivers / cars for which data will be shown, or you can even restrict the report to a given class or category in a multi-class race. When you select "All" for the categories as well as "All" for the car classes, the display data will split the grid into car classes and each car classes according to the different cup categories, if any. This will look like this:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%2010.JPG)

On the other side, you can restrict a report only to a given class or cup category, which then will present the information like this:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%2011.JPG)

Last, but not least, you can choose to display driver categories (i.e. Platinum, Gold, and so on), when they are supplied by the simulator.