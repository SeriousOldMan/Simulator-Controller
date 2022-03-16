;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Event Buffer Test Program       ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#SingleInstance Force			; Ony one instance allowed
#NoEnv							; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn							; Enable warnings to assist with detecting common errors.
#Warn LocalSameAsGlobal, Off

SendMode Input					; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.

SetBatchLines -1				; Maximize CPU utilization
ListLines Off					; Disable execution history

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Tools.ico
;@Ahk2Exe-ExeName Event Buffer Tester.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Assistants\Libraries\TyresDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Private Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class DatabaseCreator {
	iRootFolder := false
	iIncludePressures := false
	iIncludeSetups := false
	
	RootFolder[] {
		Get {
			return this.iRootFolder
		}
	}
	
	IncludePressures[] {
		Get {
			return this.iIncludePressures
		}
	}
	
	IncludeSetups[] {
		Get {
			return this.iIncludeSetups
		}
	}

	__New(rootFolder, includePressures, includeSetups) [
		this.iRootFolder := rootFolder
		this.iIncludePressures := includePressures
		this.iIncludeSetups := includeSetups
	}
	
	loadDatabase(databaseDirectory) {
		Loop Files, %databaseDirectory%User\*.*, D									; Simulator
		{
			simulator := A_LoopFileName
			
			Loop Files, %databaseDirectory%User\%simulator%\*.*, D					; Car
			{
				car := A_LoopFileName
				
				Loop Files, %databaseDirectory%User\%simulator%\%car%\*.*, D		; Track
				{
					track := A_LoopFileName
					
					fileName = %databaseDirectory%User\%simulator%\%car%\%track%\
					
					if FileExist(fileName . "Setup.Pressures.Distribution.CSV")
						this.loadPressures(simulator, car, track, new Database(fileName, kTyresDataSchemas))
					
					Loop Files, %databaseDirectory%User\%simulator%\%car%\Car Setups\*.*, D
					{
						type := A_LoopFileName
						
						Loop Files, %databaseDirectory%User\%simulator%\%car%\Car Setups\%type%\*.*
							this.loadCarSetup(simulator, car, track, type, A_LoopFilePath)
					}
				}
			}
		}
	}
	
	loadPressures(simulator, car, track, database) {
		if this.IncludePressures
			for ignore, row in database.Tables["Tyres.Pressures.Distribution"]
				this.TyresDatabase.updatePressure(simulator, car, track, row.Weather
												, row["Temperature.Air"], row["Temperature.Track"]
												, row.Compound, row["Compound.Color"], row.Type, row.Tyre,
												, row.Pressure, row.Count, false, true, "Community")
	}
	
	loadCarSetup(simulator, car, track, type, setupFile) {
		if this.IncludeSetups
			FileCopy %setupFile%, %kDatabaseDirectory%Community\%simulator%\%car%\Car Setups\%type%, 1
	}
}