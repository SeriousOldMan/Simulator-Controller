;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Mathematical Functions          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                     Public Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

signum(number) {
	return ((number < 0) ? -1 : 1)
}

minimum(numbers) {
	local theMin := kUndefined
	local ignore, value

	for ignore, value in numbers
		if isNumber(value)
			theMin := ((theMin == kUndefined) ? value : Min(theMin, value))

	return ((theMin == kUndefined) ? 0 : theMin)
}

maximum(numbers) {
	local theMax := kUndefined
	local ignore, value

	for ignore, value in numbers
		if isNumber(value)
			theMax := ((theMax == kUndefined) ? value : Max(theMax, value))

	return ((theMax == kUndefined) ? 0 : theMax)
}

average(numbers) {
	local avg := 0
	local ignore, value, cnt

	for ignore, value in numbers
		if isNumber(value) {
			avg += value
			cnt += 1
		}

	if (cnt > 0)
		return (avg / cnt)
	else
		return false
}

sum(numbers) {
	local sum := 0
	local ignore, value

	for ignore, value in numbers
		if isNumber(value)
			sum += value

	return sum
}

stdDeviation(numbers) {
	local avg := average(numbers)
	local squareSum := 0
	local ignore, value, cnt

	for ignore, value in numbers
		if isNumber(value) {
			squareSum += ((value - avg) * (value - avg))
			cnt += 1
		}

	if (cnt > 0)
		squareSum := (squareSum / cnt)

	return Sqrt(squareSum)
}

count(values, null := true) {
	local result, ignore, value

	if null
		return values.Length
	else {
		result := 0

		for ignore, value in values
			if isNumber(value)
				result += 1

		return result
	}
}

linRegression(xValues, yValues, &a, &b) {
	local xAverage := average(xValues)
	local yAverage := average(yValues)
	local dividend := 0
	local divisor := 0
	local index, xValue, xDelta, yDelta

	for index, xValue in xValues {
		if isNumber(xValue) {
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