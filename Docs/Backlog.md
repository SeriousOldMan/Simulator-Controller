#### Core System
  1. Integration of local TTS engines for voice generation
  2. Support automatic language translation when using Whisper voice recognition
  3. New GPT booster that supports automatic translation to a different language for voice generation
  4. HTTP Server to run Whisper on a remote machine

#### Simulation Support
  1. Better integration with the weather forecast data of *rFactor 2*
  2. Full support for hybrid and fully electric cars
  3. Support for new and also historic simulators
  4. Work around the jumping lap counter in *rFactor 2* and *Le Mans Ultimate* after an RTG in practice

#### Plugins
  1. Cleanup of "Session State.json" file, i.e. not using *null* anymore for unavailable data

#### Assistants
  1. Controller action and voice command to enable/disable data collection
  2. Better answers by the Strategist, when a pitstop cannot be recommended
  3. Support for partial tyre changes
  4. Integrate support for LAMs
  5. Support for Time+1 session format
  6. Approaching corner braking point countdown
  7. Configurable priority for voice output between Spotter and other Assistants

#### Session Database
  1. Active validation of value ranges in settings definitions
  2. Editor for fuel consumption values
  3. Editor for tyre wear values
  
#### Setup Workbench
  1. Collect telemetry data from multiple drivers and generate combined setup recommendations
  2. Gear ratio optimizer for the Issue Analyzer

#### Strategy Workbench
  1. Multi session tyre management - manage tyre sets and driven laps for a whole weekend (Practice, Qualifying, Race 1, Race 2, ...)
  2. Introduce data groups (for example all data belonging to a complete weekend w. practice, qualiy and race) and make this group usable for future strategy calculation
  3. Handle DT as an alternative to reset the stint timer at the end of a race

#### Team Center
  1. Change hot target pressures for the next pitstop
  
#### New Apps
  1. Pitwall timing application with full information about all cars on the track
     - Timings
	 - Incidents
	 - Drivers
	 - Number of pitstops
	 - Relative performance