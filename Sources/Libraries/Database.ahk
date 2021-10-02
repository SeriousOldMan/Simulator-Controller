;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Database                        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Constant Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kNull = "__Null__"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class Database {
	iDirectory := false
	iSchemas := false
	iTables := {}
	
	Directory[] {
		Get {
			return this.iDirectory
		}
	}
	
	Schemas[name := false] {
		Get {
			return (name ? this.iSchemas[name] : this.iSchemas)
		}
	}
	
	Tables[name := false] {
		Get {
			if name {
				if !this.iTables.HasKey(name) {
					schema := this.Schemas[name]
					data := []
					
					Loop Read, % (this.Directory . name . ".CSV")
					{
						row := {}
						values := string2Values(";", A_LoopReadLine)
						
						for ignore, column in schema
							row[column] := values[A_Index]
						
						data.Push(row)
					}
					
					this.iTables[name] := data
				}
					
				return this.iTables[name]
			}
			else
				return this.iTables
		}
	}
	
	__New(directory, schemas) {
		this.iDirectory := directory
		this.iSchemas := schemas
	}
	
	query(name, query) {
		local predicate
		
		schema := this.Schemas[name]
		rows := this.Tables[name]
		needsClone := true
		
		if query.HasKey("Where") {
			predicate := query["Where"]
			selection := []
			
			if !predicate.MinParams
				predicate := Func("constraintColumns").Bind(predicate)
			
			for ignore, row in rows
				if %predicate%(row)
					selection.Push(row)
			
			rows := selection
			needsClone := false
		}
		
		if query.HasKey("Filter") {
			filter := query["Filter"]
			
			rows := %filter%(rows)
		}
		
		if (query.HasKey("Group") || query.HasKey("By")) {
			rows := groupRows(query.HasKey("By") ? query["By"] : [], query.HasKey("Group") ? query["Group"] : [], rows)
			needsClone := false
		}
	
		if query.HasKey("Select") {
			projection := query["Select"]
			projectedRows := []
			
			for ignore, row in rows {
				projectedRow := {}
			
				for ignore, column in projection
					projectedRow[column] := row[column]
				
				projectedRows.Push(projectedRow)
			}
			
			rows := projectedRows
			needsClone := false
		}
		
		return (needsClone ? rows.Clone() : rows)
	}
	
	flush(name := false) {
		if name {
			if this.Table.HasKey(name) {
				directory := this.Directory
				fileName := (directory . name . ".CSV")
				
				FileCreateDir %directory%
				
				try {
					FileDelete %fileName%
				}
				catch exception {
					; ignore
				}
				
				for ignore, row in this.Tables[name] {
					row := (values2String(";", row*) . "`n")
		
					FileAppend %row%, %fileName%
				}
			}
		}
		else
			for name, ignore in this.Tables
				this.flush(name)
	}
	
	reload(flush := true) {
		if flush
			this.flush()
		
		this.iTables := {}
	}
	
	add(name, values, flush := false) {
		row := []
			
		for ignore, column in this.Schemas[name]
			row.Push(values.HasKey(column) ? values[column] : kNull)
		
		if this.Tables.HasKey(name)
			this.Tables[name].Push(row)
		
		if flush {
			directory := this.Directory
			fileName := (directory . name . ".CSV")
			
			FileCreateDir %directory%
					
			row := (values2String(";", row*) . "`n")
			
			FileAppend %row%, %fileName%
		}
	}
	
	remove(name, predicate, flush := false) {
		rows := []
		
		for ignore, row in this.Tables[name]
			if !%predicate%(row)
				rows.Push(row)
		
		this.iTables[name] := rows
		
		if flush
			this.flush(name)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

minimum(numbers) {
	min := 0
	
	for ignore, number in numbers
		min := (!min ? number : Min(min, number))

	return min
}

maximum(numbers) {
	max := 0
	
	for ignore, number in numbers
		max := (!max ? number : Max(max, number))

	return max
}

average(numbers) {
	avg := 0
	
	for ignore, value in numbers
		avg += value
	
	return (avg / numbers.Length())
}

stdDeviation(numbers) {
	avg := average(numbers)
	
	squareSum := 0
	
	for ignore, value in numbers
		squareSum += ((value - avg) * (value - avg))
	
	return Sqrt(squareSum)
}

count(values) {
	return values.Length()
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

constraintColumns(constraints, row) {
	for column, value in constraints
		if (row[column] != value)
			return false
		
	return true
}

groupRows(groupedByColumns, groupedColumns, rows) {
	local function
	
	values := {}
	
	if !IsObject(groupedByColumns)
		groupedByColumns := Array(groupedByColumns)
	
	for ignore, row in rows {
		key := []
		
		for ignore, column in groupedByColumns
			key.Push(row[column])
		
		key := values2String("|", key*)
	
		if values.HasKey(key)
			values[key].Push(row)
		else
			values[key] := Array(row)
	}
	
	result := []
	
	for group, groupedRows in values {
		group := string2Values("|", group)
		
		resultRow := Object()
		
		for ignore, column in groupedByColumns
			resultRow[column] := group[A_Index]
		
		for ignore, columnDescriptor in groupedColumns {
			valueColumn := columnDescriptor[1]
			function := columnDescriptor[2]
			resultColumn := columnDescriptor[3]
			
			columnValues := []
			
			for ignore, row in groupedRows
				columnValues.Push(row[valueColumn])
			
			resultRow[resultColumn] := %function%(columnValues)
		}
		
		result.Push(resultRow)
	}
	
	return result
}