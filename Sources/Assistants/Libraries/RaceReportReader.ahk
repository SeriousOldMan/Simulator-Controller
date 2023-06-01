;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Report Reader              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\Math.ahk"
#Include "..\..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kNotInitialized := "__NotInitialized__"
global kUnknown := false


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceReportReader {
	iReport := false

	Report {
		Get {
			return this.iReport
		}
	}

	__New(report := false) {
		global kUnknown

		this.iReport := report

		if !kUnknown
			kUnknown := translate("Unknown")
	}

	setReport(report) {
		this.iReport := report
	}

	getLaps(raceData) {
		local laps := []

		loop getMultiMapValue(raceData, "Laps", "Count")
			laps.Push(A_Index)

		return laps
	}

	getClass(raceData, car, categories := ["Class"]) {
		local carClass, carCategory

		if inList(categories, "Class") {
			carClass := getMultiMapValue(raceData, "Cars", "Car." . car . ".Class", kUnknown)

			if inList(categories, "Cup") {
				carCategory := getMultiMapValue(raceData, "Cars", "Car." . car . ".Category", kUndefined)

				return ((carCategory != kUndefined) ? (carClass . translate(" (") . carCategory . translate(")")) : carClass)
			}
			else
				return carClass
		}
		else
			return getMultiMapValue(raceData, "Cars", "Car." . car . ".Category", kUnknown)
	}

	getClasses(raceData, categories?) {
		local classes := []
		local carClass

		loop getMultiMapValue(raceData, "Cars", "Count")
			if (getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Car", kNotInitialized) != kNotInitialized) {
				carClass := this.getClass(raceData, A_Index, categories?)

				if !inList(classes, carClass)
					classes.Push(carClass)
			}

		bubbleSort(&classes)

		return classes
	}

	getDrivers(raceData) {
		local cars := []

		loop getMultiMapValue(raceData, "Cars", "Count")
			if (getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Car", kNotInitialized) != kNotInitialized)
				cars.Push(A_Index)

		return cars
	}

	getCars(raceData) {
		return this.getDrivers(raceData)
	}

	getCar(lap, &carID, &car, &carNumber, &carName, &driverForname, &driverSurname, &driverNickname) {
		local raceData := true
		local drivers := true
		local positions := false
		local times := false

		this.loadData(Array(lap), &raceData, &drivers, &positions, &times)

		if carID {
			loop getMultiMapValue(raceData, "Cars", "Count", 0)
				if ((getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Car", kNotInitialized) != kNotInitialized)
				 && (getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".ID") = carID)) {
					car := A_Index
					carNumber := getMultiMapValue(raceData, "Cars", "Car." . car . ".Nr", "-")
					carName := getMultiMapValue(raceData, "Cars", "Car." . car . ".Car", translate("Unknown"))

					if ((drivers.Length > 0) && drivers[1].Has(car))
						parseDriverName(drivers[1][car], &driverForname, &driverSurname, &driverNickname)
					else {
						driverForname := "John"
						driverSurname := "Doe"
						driverNickname := "JDO"
					}

					return true
				}
		}
		else {
			if (getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Car", kNotInitialized) != kNotInitialized) {
				carID := getMultiMapValue(raceData, "Cars", "Car." . car . ".ID", false)
				carNumber := getMultiMapValue(raceData, "Cars", "Car." . car . ".Nr", "-")
				carName := getMultiMapValue(raceData, "Cars", "Car." . car . ".Car", translate("Unknown"))

				if (drivers.Length > 0) {
					parseDriverName(drivers[1][car], &driverForname, &driverSurname, &driverNickname)
				}
				else {
					driverForname := "John"
					driverSurname := "Doe"
					driverNickname := "JDO"
				}

				return true
			}
		}

		return false
	}

	getStandings(lap, &cars, &ids, &overallPositions, &classPositions, &carNumbers, &carNames
					, &driverFornames, &driverSurnames, &driverNicknames, &driverCategories) {
		local raceData := true
		local drivers := true
		local tPositions := true
		local tCategories := driverCategories
		local tTimes := true
		local classes := CaseInsenseMap()
		local driver, category, forName, surName, nickName, position, carClass

		comparePositions(c1, c2) {
			local pos1 := c1[2]
			local pos2 := c2[2]

			if !isNumber(pos1)
				pos1 := 999

			if !isNumber(pos2)
				pos2 := 999

			return (pos1 > pos2)
		}

		this.loadData(Array(lap), &raceData, &drivers, &tPositions, &tTimes, &tCategories)

		if cars
			cars := []

		if ids
			ids := []

		if overallPositions
			overallPositions := []

		if classPositions
			classPositions := []

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

		if driverCategories
			driverCategories := []

		if (cars && (tPositions.Length > 0) && (drivers.Length > 0)) {
			loop getMultiMapValue(raceData, "Cars", "Count", 0)
				if (tPositions[tPositions.Length].Has(A_Index) && tTimes[tTimes.Length].Has(A_Index))
					if (!extendedIsNull(tPositions[tPositions.Length][A_Index]) && !extendedIsNull(tTimes[tTimes.Length][A_Index])) {
						if cars
							cars.Push(A_Index)

						if ids
							ids.Push(getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".ID"))

						position := tPositions[1][A_Index]

						if overallPositions
							overallPositions.Push(position)

						carClass := this.getClass(raceData, A_Index)

						if !classes.Has(carClass)
							classes[carClass] := [Array(A_Index, position)]
						else
							classes[carClass].Push(Array(A_Index, position))

						if carNumbers
							carNumbers.Push(getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Nr"))

						if carNames
							carNames.Push(getMultiMapValue(raceData, "Cars", "Car." . A_Index . ".Car"))

						forName := false
						surName := false
						nickName := false

						parseDriverName(drivers[1][A_Index], &forName, &surName, &nickName)

						if driverFornames
							driverFornames.Push(forName)

						if driverSurnames
							driverSurnames.Push(surName)

						if driverNicknames
							driverNicknames.Push(nickName)

						if driverCategories
							driverCategories.Push(tCategories[1][A_Index])
					}

			if (classes.Count > 1) {
				classPositions := overallPositions.Clone()

				for ignore, carClass in classes {
					bubbleSort(&carClass, comparePositions)

					for position, car in carClass
						if classPositions.Has(car[1])
							classPositions[car[1]] := position
				}

				return true
			}
			else {
				classPositions := overallPositions

				return false
			}
		}
		else
			return false
	}

	getDriverPositions(raceData, positions, car) {
		local result := []
		local gridPosition := getMultiMapValue(raceData, "Cars", "Car." . car . ".Position", kUndefined)
		local ignore, lap

		if (gridPosition != kUndefined)
			if (StrLen(Trim(gridPosition)) == 0)
				result.Push(car)
			else
				result.Push(gridPosition)

		for ignore, lap in this.getLaps(raceData)
			if positions.Has(lap)
				result.Push(positions[lap].Has(car) ? positions[lap][car] : kNull)

		return result
	}

	getDriverTimes(raceData, times, car) {
		local min := false
		local max := false
		local avg := false
		local stdDev := false
		local result := []
		local ignore, lap, time

		if this.getDriverPace(raceData, times, car, &min, &max, &avg, &stdDev)
			for ignore, lap in this.getLaps(raceData)
				if times.Has(lap) {
					time := (times[lap].Has(car) ? times[lap][car] : 0)
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

	getDriverPace(raceData, times, car, &min, &max, &avg, &stdDev) {
		local validTimes := []
		local ignore, lap, time, invalidTimes

		for ignore, lap in this.getLaps(raceData)
			if times.Has(lap) {
				time := (times[lap].Has(car) ? times[lap][car] : 0)
				time := (isNull(time) ? 0 : Round(time, 1))

				if (time > 0)
					validTimes.Push(time)
			}

		if (validTimes.Length = 0)
			return false
		else {
			min := Round(minimum(validTimes) / 1000, 1)

			stdDev := stdDeviation(validTimes)
			avg := average(validTimes)

			invalidTimes := []

			for ignore, time in validTimes
				if ((time > avg) && (Abs(time - avg) > stdDev))
					invalidTimes.Push(time)

			for ignore, time in invalidTimes
				validTimes.RemoveAt(inList(validTimes, time))

			if (validTimes.Length > 0) {
				max := Round(maximum(validTimes) / 1000, 1)
				avg := Round(average(validTimes) / 1000, 1)
				stdDev := (stdDeviation(validTimes) / 1000)

				return true
			}
			else
				return false
		}
	}

	getDriverPotential(raceData, positions, car) {
		local cars := getMultiMapValue(raceData, "Cars", "Count")

		positions := this.getDriverPositions(raceData, positions, car)

		return Max(0, cars - numberValue(positions[1])) + Max(0, cars - numberValue(positions[positions.Length]))
	}

	getDriverRaceCraft(raceData, positions, car) {
		local cars := getMultiMapValue(raceData, "Cars", "Count")
		local result := 0
		local lastPosition := false
		local position

		positions := this.getDriverPositions(raceData, positions, car)

		loop positions.Length {
			position := positions[A_Index]

			if (extendedIsNull(position) && (A_Index = positions.Length))
				return 0
			else if !extendedIsNull(position) {
				result += (Max(0, 11 - position) / 10)

				if lastPosition
					result += (lastPosition - position)

				lastPosition := position

				result := Max(0, result)
			}
		}

		return result
	}

	getDriverSpeed(raceData, times, car) {
		local min := false
		local max := false
		local avg := false
		local stdDev := false

		if this.getDriverPace(raceData, times, car, &min, &max, &avg, &stdDev)
			return min
		else
			return false
	}

	getDriverConsistency(raceData, times, car) {
		local min := false
		local max := false
		local avg := false
		local stdDev := false

		if this.getDriverPace(raceData, times, car, &min, &max, &avg, &stdDev)
			return ((stdDev == 0) ? 0.1 : (1 / stdDev))
		else
			return false
	}

	getDriverCarControl(raceData, times, car) {
		local min := false
		local max := false
		local avg := false
		local stdDev := false
		local carControl, threshold, ignore, lap, time

		if this.getDriverPace(raceData, times, car, &min, &max, &avg, &stdDev) {
			carControl := 1
			threshold := (avg + ((max - avg) / 4))

			for ignore, lap in this.getLaps(raceData)
				if times.Has(lap) {
					time := (times[lap].Has(car) ? times[lap][car] : 0)
					time := (extendedIsNull(time) ? 0 : Round(times[lap][car] / 1000, 1))

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
		local max := maximum(values)
		local factor := ((max != 0) ? (target / max) : 1)
		local index, value

		for index, value in values
			values[index] *= factor

		return values
	}

	normalizeSpeedValues(values, target) {
		local index, value, halfTarget, min, max, factor

		for index, value in values
			values[index] := - value

		halfTarget := (target / 2)
		min := minimum(values)

		for index, value in values
			if (value != 0)
				values[index] := halfTarget + (value - min)

		max := maximum(values)

		if (max = 0)
			factor := 0
		else
			factor := (target / max)

		for index, value in values
			values[index] *= factor

		return values
	}

	getDriverStatistics(raceData, cars, positions, times
					  , &potentials, &raceCrafts, &speeds, &consistencies, &carControls) {
		consistencies := this.normalizeValues(collect(cars, ObjBindMethod(this, "getDriverConsistency", raceData, times)), 5)
		carControls := this.normalizeValues(collect(cars, ObjBindMethod(this, "getDriverCarControl", raceData, times)), 5)
		speeds := this.normalizeSpeedValues(collect(cars, ObjBindMethod(this, "getDriverSpeed", raceData, times)), 5)
		raceCrafts := this.normalizeValues(collect(cars, ObjBindMethod(this, "getDriverRaceCraft", raceData, positions)), 5)
		potentials := this.normalizeValues(collect(cars, ObjBindMethod(this, "getDriverPotential", raceData, positions)), 5)

		return true
	}

	loadData(laps, &raceData, &drivers, &positions, &times, &categories := false) {
		local report, oldEncoding, driverLine, categoryLine

		if drivers
			drivers := []

		if positions
			positions := []

		if times
			times := []

		if categories
			categories := []

		report := this.Report

		if report {
			if raceData
				raceData := readMultiMap(report . "\Race.data")

			oldEncoding := A_FileEncoding

			FileEncoding("UTF-8")

			try {
				if drivers {
					try {
						loop Read, report . "\Drivers.CSV"
							if (!laps || inList(laps, A_Index)) {
								driverLine := string2Values(";", A_LoopReadLine)

								if categories
									categoryLine := []

								loop driverLine.Length
									if InStr(driverLine[A_Index], "|||") {
										driver := string2Values("|||", driverLine[A_Index])

										driverLine[A_Index] := driver[1]

										if categories
											categoryLine.Push(driver[2])
									}
									else if categories
										categoryLine.Push("Unknown")

								drivers.Push(driverLine)

								if categories
									categories.Push(categoryLine)
							}
					}
					catch Any as exception {
						logError(exception)
					}

					drivers := correctEmptyValues(drivers, "")

					if categories
						categories := correctEmptyValues(categories, "Unknown")
				}

				if positions {
					try {
						loop Read, report . "\Positions.CSV"
							if (!laps || inList(laps, A_Index))
								positions.Push(string2Values(";", A_LoopReadLine))
					}
					catch Any as exception {
						logError(exception)
					}

					positions := correctEmptyValues(positions, kNull)
				}

				if times {
					try {
						loop Read, report . "\Times.CSV"
							if (!laps || inList(laps, A_Index))
								times.Push(string2Values(";", A_LoopReadLine))
					}
					catch Any as exception {
						logError(exception)
					}

					times := correctEmptyValues(times, kNull)
					times := correctLapTimes(times)
				}
			}
			finally {
				FileEncoding(oldEncoding)
			}
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

extendedIsNull(value, allowZero := true) {
	return (isNull(value) || (!allowZero && !value) || (value = "-") || (value = ""))
}

numberValue(value) {
	return (isNumber(value) ? value : (extendedIsNull(value) ? 0 : value))
}

correctEmptyValues(table, default := kUndefined) {
	local line

	loop table.Length {
		line := A_Index

		loop table[line].Length
			if (table[line][A_Index] = "-")
				table[line][A_Index] := ((default == kUndefined) ? ((line > 1) ? table[line - 1][A_Index] : "-") : default)
	}

	return table
}

correctLapTimes(times) {
	local lastLapTimes := CaseInsenseMap()
	local line, lapTime

	loop times.Length {
		line := A_Index

		loop times[line].Length {
			lapTime := times[line][A_Index]

			if (lastLapTimes.Has(A_Index) && (times[line][A_Index] = lastLapTimes[A_Index][1])) {
				if lastLapTimes[A_Index][2]
					times[line][A_Index] := 0
				else
					lastLapTimes[A_Index][2] := true
			}
			else
				lastLapTimes[A_Index] := [lapTime, false]
		}
	}

	return times
}