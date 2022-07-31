;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Task Management                 ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Public Constants Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kLowPriority = 0
global kNormalPriority = 1
global kHighPriority = 2


;;;-------------------------------------------------------------------------;;;
;;;                         Public Classes Section                          ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                           Task                                    ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Task {
	static sLowTasks := []
	static sNormalTasks := []
	static sHighTasks := []

	static sCurrentTask := false

	iPriority := kNormalPriority
	iNextExecution := false

	iCallable := false

	Task[] {
		Get {
			return Task.sCurrentTask
		}
	}

	Window[] {
		Get {
			return false
		}
	}

	Priority[] {
		Get {
			return this.iPriority
		}
	}

	NextExecution[] {
		Get {
			return this.iNextExecution
		}

		Set {
			return (this.iNextExecution := value)
		}
	}

	Active[] {
		Get {
			return (A_TickCount > this.NextExecution)
		}
	}

	Callable[] {
		Get {
			return this.iCallable
		}
	}

	__New(callable := false, sleep := 0, priority := 1) {
		this.iNextExecution := (A_TickCount + sleep)
		this.iCallable := callable
		this.iPriority := priority
	}

	run() {
		callable := this.Callable

		if isInstance(callable, Task)
			return callable.run()
		else {
			result := %callable%()

			return (isInstance(result, Task) ? result : false)
		}
	}

	getNextTask(remove := true) {
		for index, candidate in Task.sHighTasks
			if candidate.Active {
				if remove
					Task.sHighTasks.RemoveAt(index)

				return candidate
			}

		for index, candidate in Task.sNormalTasks
			if candidate.Active {
				if remove
					Task.sNormalTasks.RemoveAt(index)

				return candidate
			}

		for index, candidate in Task.sLowTasks
			if candidate.Active {
				if remove
					Task.sLowTasks.RemoveAt(index)

				return candidate
			}

		return false
	}

	addTask(theTask) {
		priority := theTask.Priority

		switch priority {
			case kNormalPriority:
				Task.sNormalTasks.Push(theTask)
			case kHighPriority:
				Task.sHighTasks.Push(theTask)
			case kLowPriority:
				Task.sLowTasks.Push(theTask)
			default:
				Throw "Unexpected priority detected in Task.addTask..."
		}

		if (Task.CurrentTask && (priority > Task.CurrentTask.Priority))
			Task.interrupt()
	}

	removeTask(theTask) {
		switch theTask.Priority {
			case kNormalPriority:
				Task.sNormalTasks := remove(Task.sNormalTasks, theTask)
			case kHighPriority:
				Task.sHighTasks := remove(Task.sHighTasks, theTask)
			case kLowPriority:
				Task.sLowTasks := remove(Task.sLowTasks, theTask)
			default:
				Throw "Unexpected priority detected in Task.removeTask..."
		}
	}

	runTask(theTask, sleep := "__Undefined__", priority := "__Undefined__") {
		if isInstance(theTask, Task) {
			if (sleep != kUndefined)
				theTask.iNextExecution := (A_TickCount + sleep)

			if (priority != kUndefined)
				theTask.iPriority := priority
		}
		else
			theTask := new Task(theTask, sleep, (priority != kUndefined) ? priority : kNormalPriority)

		Task.addTask(theTask)
	}

	yield() {
		this.schedule()
	}

	interrupt() {
		Task.schedule(true)
	}

	schedule(interrupt := false) {
		protectionOn(true)

		static scheduling := false

		if (scheduling && !interrupt) {
			protectionOff(true)

			return
		}
		else {
			oldScheduling := scheduling

			scheduling := true

			try {
				protectionOff(true)

				Loop {
					worked := false

					next := Task.getNextTask(false)

					if next
						if (!Task.CurrentTask || (Task.CurrentTask.Priority < next.Priority)) {
							Task.removeTask(next)

							worked := true

							Task.execute(next)
						}
				} until !worked
			}
			finally {
				scheduling := oldScheduling
			}
		}
	}

	execute(theTask) {
		oldCurrentTask := Task.CurrentTask
		Task.sCurrentTask := theTask

		oldDefault := A_DefaultGui
		window := theTask.Window

		if window {
			Gui %window%:Default

			Gui %window%:+Disabled
		}

		try {
			next := theTask.run()
		}
		finally {
			if window {
				Gui %oldDefault%:Default

				Gui %window%:-Disabled
			}

			Task.sCurrentTask := oldCurrentTask
		}

		if next
			Task.addTask(next)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                       PeriodicTask                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class PeriodicTask extends Task {
	iSleep := false

	Sleep[] {
		Get {
			return this.iSleep
		}

		Set {
			return (this.iSleep := value)
		}
	}

	__New(callable, sleep, priority := 1) {
		this.iSleep := sleep

		base.__New(callable, sleep, priority)
	}

	run() {
		base.run()

		this.NextExecution := (A_TickCount + this.Sleep)

		return this
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                       Continuation                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Continuation extends Task {
	iTask := false

	Task[] {
		Get {
			return this.iTask
		}
	}

	Window[] {
		Get {
			return this.Task.Window
		}
	}

	__New(task := false, continuation := false) {
		this.iTask := (task ? task : Task.CurrentTask)

		base.__New(continuation)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeTasks() {
	schedule := ObjBindMethod(Task, "schedule")

	SetTimer %schedule%, 50
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeTasks()
