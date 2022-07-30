;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Mathematical Functions          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                     Public Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

minimum(numbers) {
	min := kUndefined

	for ignore, value in numbers
		if value is number
			min := ((min == kUndefined) ? value : Min(min, value))

	return ((min == kUndefined) ? 0 : min)
}

maximum(numbers) {
	max := kUndefined

	for ignore, value in numbers
		if value is number
			max := ((max == kUndefined) ? value : Max(max, value))

	return ((max == kUndefined) ? 0 : max)
}

average(numbers) {
	avg := 0

	for ignore, value in numbers
		if value is number
			avg += value

	count := count(numbers, false)

	if (count > 0)
		return (avg / count)
	else
		return false
}

stdDeviation(numbers) {
	avg := average(numbers)

	squareSum := 0

	for ignore, value in numbers
		if value is number
			squareSum += ((value - avg) * (value - avg))

	squareSum := (squareSum / count(numbers, false))

	return Sqrt(squareSum)
}

count(values, null := true) {
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
	xAverage := average(xValues)
	yAverage := average(yValues)

	dividend := 0
	divisor := 0

	for index, xValue in xValues {
		if xValue is number
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