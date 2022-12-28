;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Collection Functions            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

inList(list, value) {
	local index, candidate

	for index, candidate in list
		if (candidate = value)
			return index

	return false
}

listEqual(list1, list2) {
	local index, value

	if (list1.Length() != list2.Length())
		return false
	else
		for index, value in list1
			if (list2[index] != value)
				return false

	return true
}

concatenate(lists*) {
	local result := []
	local ignore, list, value

	for ignore, list in lists
		for ignore, value in list
			result.Push(value)

	return result
}

reverse(list) {
	local result := []
	local length := list.Length()

	loop %length%
		result.Push(list[length - (A_Index - 1)])

	return result
}

map(list, function) {
	local result := []
	local ignore, value

	for ignore, value in list
		result.Push(%function%(value))

	return result
}

remove(list, object) {
	local result := []
	local ignore, value

	for ignore, value in list
		if (value != object)
			result.Push(value)

	return result
}

removeDuplicates(list) {
	local result := []
	local ignore, value

	for ignore, value in list
		if !inList(result, value)
			result.Push(value)

	return result
}

do(list, function) {
	local ignore, value

	for ignore, value in list
		%function%(value)
}

combine(maps*) {
	local result := {}
	local ignore, map, key, value

	for ignore, map in maps
		for key, value in map
			result[key] := value

	return result
}

getKeys(map) {
	local result := []
	local ignore, key

	for key, ignore in map
		result.Push(key)

	return result
}

getValues(map) {
	local result := []
	local ignore, value

	for ignore, value in map
		result.Push(value)

	return result
}

greaterComparator(a, b) {
	return (a > b)
}

bubbleSort(ByRef array, comparator := "greaterComparator") {
	local n := array.Length()
	local newN, i, j, lineI, lineJ

	while (n > 1) {
		newN := 1
		i := 0

		while (++i < n) {
			j := i + 1

			if %comparator%(lineI := array[i], lineJ := array[j]) {
				array[i] := lineJ
				array[j] := lineI

				newN := j
			}
		}

		n := newN
	}
}