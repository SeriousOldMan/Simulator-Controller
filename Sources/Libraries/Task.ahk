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

	iStopped := false
	iRunnable := true
	iSleep := false

	iPriority := kNormalPriority
	iNextExecution := false

	iCallable := false

	CurrentTask[] {
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

	Stopped[] {
		Get {
			return this.iStopped
		}

		Set {
			return (this.iStopped := value)
		}
	}

	Runnable[] {
		Get {
			return ((A_TickCount > this.NextExecution) && this.iRunnable && !this.Stopped)
		}

		Set {
			return (this.iRunnable := value)
		}
	}

	Sleep[] {
		Get {
			return this.iSleep
		}

		Set {
			return (this.iSleep := value)
		}
	}

	Callable[] {
		Get {
			return this.iCallable
		}
	}

	__New(callable := false, sleep := 0, priority := 1) {
		this.iSleep := Sleep
		this.iNextExecution := (A_TickCount + sleep)

		this.iCallable := callable
		this.iPriority := priority
	}

	run() {
		callable := this.Callable

		result := (isInstance(callable, Task) ? callable.run() : %callable%())

		return (isInstance(result, Task) ? result : false)
	}

	resume() {
		this.Runnable := true
	}

	pause() {
		this.Runnable := false
	}

	getNextTask(remove := true) {
		for index, candidate in Task.sHighTasks
			if candidate.Runnable {
				if remove
					Task.sHighTasks.RemoveAt(index)

				return candidate
			}

		for index, candidate in Task.sNormalTasks
			if candidate.Runnable {
				if remove
					Task.sNormalTasks.RemoveAt(index)

				return candidate
			}

		for index, candidate in Task.sLowTasks
			if candidate.Runnable {
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

	startTask(theTask, sleep := "__Undefined__", priority := "__Undefined__") {
		if isInstance(theTask, Task) {
			if (sleep != kUndefined)
				theTask.iNextExecution := (A_TickCount + sleep)

			if (priority != kUndefined)
				theTask.iPriority := priority
		}
		else
			theTask := new Task(theTask, sleep, (priority != kUndefined) ? priority : kNormalPriority)

		Task.addTask(theTask)

		theTask.Runnable := true

	}

	stopTask(theTask) {
		theTask.Runnable := false
		theTask.Stopped := true

		Task.removeTask(theTask)
	}

	yield() {
		Task.schedule()
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

		if (next && !next.Stopped)
			Task.addTask(next)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                       PeriodicTask                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class PeriodicTask extends Task {
	run() {
		base.run()

		this.NextExecution := (A_TickCount + this.Sleep)

		return this
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                        WindowTask                                 ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class WindowTask extends Task {
	iWindow := false

	Window[] {
		Get {
			return this.iWindow
		}
	}

	__New(window, callable := false, sleep := 0, priority := 1) {
		this.iWindow := window

		base.__New(callable, sleep, priority)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    WindowPeriodicTask                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class WindowPeriodicTask extends WindowTask {
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

	__New(task := false, continuation := false, sleep := "__Undefined__", priority := "__Undefined__") {
		if !task
			task := Task.CurrentTask

		this.iTask := task

		if (sleep = kUndefined)
			sleep := task.Sleep

		if (priority = kUndefined)
			priority := task.Priority

		base.__New(continuation, sleep, priority)
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
