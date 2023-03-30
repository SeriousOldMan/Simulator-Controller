;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Collection Functions            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                    Public Classes Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

class CaseSenseMap extends Map {
}

class CaseInsenseMap extends Map {
	__New(arguments*) {
		this.CaseSense := false

		super.__New(arguments*)
	}
}

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

	if (list1.Length != list2.Length)
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
	local length := list.Length

	loop length
		result.Push(list[length - (A_Index - 1)])

	return result
}

collect(list, function) {
	local result := []
	local ignore, value

	for ignore, value in list
		result.Push(function.Call(value))

	return result
}

do(list, function) {
	local ignore, value

	for ignore, value in list
		function.Call(value)
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

combine(initialMap, collections*) {
	local result := initialMap.Clone()
	local ignore, collection, key, value

	for ignore, collection in collections
		if isInstance(collection, Map) {
			for key, value in collection
				result[key] := value
		}
		else
			for key, value in collection.OwnProps()
				result[key] := value

	return result
}

getKeys(collection) {
	local result := []
	local ignore, key

	if isInstance(collection, Map) {
		for key, ignore in collection
			result.Push(key)
	}
	else
		for key, ignore in collection.OwnProps()
			result.Push(key)

	return result
}

getValues(collection) {
	local result := []
	local ignore, value

	if isInstance(collection, Map) {
		for ignore, value in collection
			result.Push(value)
	}
	else
		for ignore, value in collection.OwnProps()
			result.Push(value)

	return result
}

strGreater(s1, s2) {
	return ((StrCompare(s1, s2, false) <= 0) ? false : true)
}

bubbleSort(&array, comparator := (a, b) => (isNumber(a) && isNumber(b)) ? (a > b) : strGreater(a, b)) {
	local n := array.Length
	local newN, i, j, lineI, lineJ

	while (n > 1) {
		newN := 1
		i := 0

		while (++i < n) {
			j := i + 1

			if comparator.Call(lineI := array[i], lineJ := array[j]) {
				array[i] := lineJ
				array[j] := lineI

				newN := j
			}
		}

		n := newN
	}
}