;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Report Reader              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Math.ahk
#Include ..\Assistants\Libraries\SessionDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kRaceReports = ["Overview", "Car", "Drivers", "Positions", "Lap Times", "Pace"]


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceReportReader {
	iReport := false

	Report[] {
		Get {
			return this.iReport
		}
	}

	__New(report := false) {
		this.iReport := report
	}

	setReport(report) {
		this.iReport := report
	}

	getLaps(raceData) {
		laps := []

		Loop % getConfigurationValue(raceData, "Laps", "Count")
			laps.Push(A_Index)

		return laps
	}

	getDrivers(raceData) {
		cars := []

		Loop % getConfigurationValue(raceData, "Cars", "Count")
			cars.Push(A_Index)

		return cars
	}

	getCars(raceData) {
		return this.getDrivers(raceData)
	}

	getCar(lap, car, ByRef carNumber, ByRef carName, ByRef driverForname, ByRef driverSurname, ByRef driverNickname) {
		local raceData := true
		local drivers := true
		local positions := false
		local times := false

		this.loadData(Array(lap), raceData, drivers, positions, times)

		carNumber := getConfigurationValue(raceData, "Cars", "Car." . car . ".Nr", "-")
		carName := getConfigurationValue(raceData, "Cars", "Car." . car . ".Car", translate("Unknown"))

		if (drivers.Length() > 0) {
			parts := string2Values(A_Space, drivers[1][car])

			driverForname := parts[1]
			driverSurname := parts[2]
			driverNickname := StrReplace(StrReplace(parts[3], "(", ""), ")", "")
		}
		else {
			driverForname := "John"
			driverSurname := "Doe"
			driverNickname := "JDO"
		}
	}

	getStandings(lap, ByRef cars, ByRef positions, ByRef carNumbers, ByRef carNames
			   , ByRef driverFornames, ByRef driverSurnames, ByRef driverNicknames) {
		local raceData := true
		local drivers := true
		local tPositions := true
		local times := false

		this.loadData(Array(lap), raceData, drivers, tPositions, times)

		if cars
			cars := []

		if positions
			positions := []

		if carNumbers
			carNumbers := []

		if carNames
			carNames := []

		if driverFornames
			driverFornames := []

		if driverSurnames
			driverSurnames := []

		if driverNicknames
			driverNicknames := []

		if cars
			Loop % getConfigurationValue(raceData, "Cars", "Count", 0) {
				cars.Push(A_Index)

				if positions
					positions.Push(tPositions[1][A_Index])

				if carNumbers
					carNumbers.Push(getConfigurationValue(raceData, "Cars", "Car." . A_Index . ".Nr"))

				if carNames
					carNames.Push(getConfigurationValue(raceData, "Cars", "Car." . A_Index . ".Car"))

				parts := string2Values(A_Space, drivers[1][A_Index])

				if driverFornames
					driverFornames.Push(parts[1])

				if driverSurnames
					driverSurnames.Push(parts[2])

				if driverNicknames
					driverNicknames.Push(StrReplace(StrReplace(parts[3], "(", ""), ")", ""))
			}
	}

	getDriverPositions(raceData, positions, car) {
		result := []

		gridPosition := getConfigurationValue(raceData, "Cars", "Car." . car . ".Position", kUndefined)

		if (gridPosition != kUndefined)
			if (StrLen(Trim(gridPosition)) == 0)
				result.Push(car)
			else
				result.Push(gridPosition)

		for ignore, lap in this.getLaps(raceData)
			if positions.HasKey(lap)
				result.Push(positions[lap].HasKey(car) ? positions[lap][car] : kNull)

		return result
	}

	getDriverTimes(raceData, times, car) {
		min := false
		max := false
		avg := false
		stdDev := false

		result := []

		if this.getDriverPace(raceData, times, car, min, max, avg, stdDev)
			for ignore, lap in this.getLaps(raceData)
				if times.hasKey(lap) {
					time := (times[lap].HasKey(car) ? times[lap][car] : 0)
					time := (isNull(time) ? 0 : Round(times[lap][car] / 1000, 1))

					if (time > 0) {
						if ((time > avg) && (Abs(time - avg) > (stdDev / 2)))
							result.Push(avg)
						else
							result.Push(time)
					}
					else
						result.Push(avg)
				}

		return result
	}

	getDriverPace(raceData, times, car, ByRef min, ByRef max, ByRef avg, ByRef stdDev) {
		validTimes := []

		for ignore, lap in this.getLaps(raceData)
			if times.HasKey(lap) {
				time := (times[lap].HasKey(car) ? times[lap][car] : 0)
				time := (isNull(time) ? 0 : Round(time, 1))

				if (time > 0)
					validTimes.Push(time)
			}

		min := Round(minimum(validTimes) / 1000, 1)

		stdDev := stdDeviation(validTimes)
		avg := average(validTimes)

		invalidTimes := []

		for ignore, time in validTimes
			if ((time > avg) && (Abs(time - avg) > stdDev))
				invalidTimes.Push(time)

		for ignore, time in invalidTimes
			validTimes.RemoveAt(inList(validTimes, time))

		if (validTimes.Length() > 1) {
			max := Round(maximum(validTimes) / 1000, 1)
			avg := Round(average(validTimes) / 1000, 1)
			stdDev := (stdDeviation(validTimes) / 1000)

			return true
		}
		else
			return false
	}

	getDriverPotential(raceData, positions, car) {
		cars := getConfigurationValue(raceData, "Cars", "Count")
		positions := this.getDriverPositions(raceData, positions, car)

		return Max(0, cars - positions[1]) + Max(0, cars - positions[positions.Length()])
	}

	getDriverRaceCraft(raceData, positions, car) {
		cars := getConfigurationValue(raceData, "Cars", "Count")
		result := 0

		positions := this.getDriverPositions(raceData, positions, car)

		lastPosition := false

		Loop % positions.Length()
		{
			position := positions[A_Index]

			result += (Max(0, 11 - position) / 10)

			if lastPosition
				result += (lastPosition - position)

			lastPosition := position

			result := Max(0, result)
		}

		return result
	}

	getDriverSpeed(raceData, times, car) {
		min := false
		max := false
		avg := false
		stdDev := false

		if this.getDriverPace(raceData, times, car, min, max, avg, stdDev)
			return min
		else
			return false
	}

	getDriverConsistency(raceData, times, car) {
		min := false
		max := false
		avg := false
		stdDev := false

		if this.getDriverPace(raceData, times, car, min, max, avg, stdDev)
			return ((stdDev == 0) ? 0.1 : (1 / stdDev))
		else
			return false
	}

	getDriverCarControl(raceData, times, car) {
		min := false
		max := false
		avg := false
		stdDev := false

		if this.getDriverPace(raceData, times, car, min, max, avg, stdDev) {
			carControl := 1
			threshold := (avg + ((max - avg) / 4))

			for ignore, lap in this.getLaps(raceData)
				if times.hasKey(lap) {
					time := (times[lap].HasKey(car) ? times[lap][car] : 0)
					time := (isNull(time) ? 0 : Round(times[lap][car] / 1000, 1))

					if (time > 0)
						if (time > threshold)
							carControl *= 0.90
				}

			return carControl
		}
		else
			return false
	}

	normalizeValues(values, target) {
		factor := (target / maximum(values))

		for index, value in values
			values[index] *= factor

		return values
	}

	normalizeSpeedValues(values, target) {
		for index, value in values
			values[index] := - value

		halfTarget := (target / 2)
		min := minimum(values)

		for index, value in values
			values[index] := halfTarget + (value - min)

		factor := (target / maximum(values))

		for index, value in values
			values[index] *= factor

		return values
	}

	getDriverStatistics(raceData, cars, positions, times
					  , ByRef potentials, ByRef raceCrafts, ByRef speeds, ByRef consistencies, ByRef carControls) {
		consistencies := this.normalizeValues(map(cars, ObjBindMethod(this, "getDriverConsistency", raceData, times)), 5)
		carControls := this.normalizeValues(map(cars, ObjBindMethod(this, "getDriverCarControl", raceData, times)), 5)
		speeds := this.normalizeSpeedValues(map(cars, ObjBindMethod(this, "getDriverSpeed", raceData, times)), 5)
		raceCrafts := this.normalizeValues(map(cars, ObjBindMethod(this, "getDriverRaceCraft", raceData, positions)), 5)
		potentials := this.normalizeValues(map(cars, ObjBindMethod(this, "getDriverPotential", raceData, positions)), 5)

		return true
	}

	loadData(laps, ByRef raceData, ByRef drivers, ByRef positions, ByRef times) {
		if drivers
			drivers := []

		if positions
			positions := []

		if times
			times := []

		report := this.Report

		if report {
			if raceData
				raceData := readConfiguration(report . "\Race.data")

			oldEncoding := A_FileEncoding

			FileEncoding UTF-8

			try {
				if drivers {
					Loop Read, % report . "\Drivers.CSV"
						if (!laps || inList(laps, A_Index))
							drivers.Push(string2Values(";", A_LoopReadLine))

					drivers := correctEmptyValues(drivers)
				}

				if positions {
					Loop Read, % report . "\Positions.CSV"
						if (!laps || inList(laps, A_Index))
							positions.Push(string2Values(";", A_LoopReadLine))

					positions := correctEmptyValues(positions, kNull)
				}

				if times {
					Loop Read, % report . "\Times.CSV"
						if (!laps || inList(laps, A_Index))
							times.Push(string2Values(";", A_LoopReadLine))

					times := correctEmptyValues(times, kNull)
				}
			}
			finally {
				FileEncoding %oldEncoding%
			}
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

correctEmptyValues(table, default := "__Undefined__") {
	Loop % table.Length()
	{
		line := A_Index

		if (line > 1)
			Loop % table[line].Length()
				if (table[line][A_Index] = "-")
					table[line][A_Index] := ((default == kUndefined) ? table[line][A_Index - 1] : default)
	}

	return table
}

compound(compound, color := false) {
	if color {
		if (color = "Black")
			return compound
		else
			return (compound . " (" . color . ")")
	}
	else
		return string2Values(A_Space, compound)[1]
}

compoundColor(compound) {
	compound := string2Values(A_Space, compound)

	if (compound.Length() == 1)
		return "Black"
	else
		return SubStr(compound[2], 2, StrLen(compound[2]) - 2)
}