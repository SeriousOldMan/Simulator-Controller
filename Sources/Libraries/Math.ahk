;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Mathematical Functions          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                     Public Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

minimum(numbers) {
	local min := kUndefined
	local ignore, value

	for ignore, value in numbers
		if value is Number
			min := ((min == kUndefined) ? value : Min(min, value))

	return ((min == kUndefined) ? 0 : min)
}

maximum(numbers) {
	local max := kUndefined
	local ignore, value

	for ignore, value in numbers
		if value is Number
			max := ((max == kUndefined) ? value : Max(max, value))

	return ((max == kUndefined) ? 0 : max)
}

average(numbers) {
	local avg := 0
	local ignore, value, count

	for ignore, value in numbers
		if value is Number
			avg += value

	count := count(numbers, false)

	if (count > 0)
		return (avg / count)
	else
		return false
}

stdDeviation(numbers) {
	local avg := average(numbers)
	local squareSum := 0
	local ignore, value

	for ignore, value in numbers
		if value is Number
			squareSum += ((value - avg) * (value - avg))

	squareSum := (squareSum / count(numbers, false))

	return Sqrt(squareSum)
}

count(values, null := true) {
	local result, ignore, value

	if null
		return values.Length()
	else {
		result := 0

		for ignore, value in values
			if (value != kNull)
				result += 1

		return result
	}
}

linRegression(xValues, yValues, ByRef a, ByRef b) {
	local xAverage := average(xValues)
	local yAverage := average(yValues)
	local dividend := 0
	local divisor := 0
	local index, xValue, xDelta, yDelta

	for index, xValue in xValues {
		if xValue is Number
		{
			xDelta := (xValue - xAverage)
			yDelta := (yValues[index] - yAverage)

			dividend += (xDelta * yDelta)
			divisor += (xDelta * xDelta)
		}
	}

	if (divisor != 0) {
		b := (dividend / divisor)
		a := (yAverage - (b * xAverage))
	}
	else {
		a := 0
		b := 0
	}
}