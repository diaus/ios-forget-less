# Forget Less

A personal todo list: things the user plans to do, each planned for a day, ticked off when done.

## Language

### Tasks

**Task**:
Something the user plans to do, identified by its name and planned for exactly one Day.
_Avoid_: Todo, item, reminder, entry

**Complete / Incomplete**:
The two states of a Task. A Task is Complete once the user has done it, and can be made Incomplete again.
_Avoid_: Done, finished, checked, closed, open, pending

**Grace Period**:
The short time a Task just made Complete stays listed where Complete Tasks are hidden, struck through, so the tap can be undone. The app has one Grace Period, and each Home Screen widget with controls has its own.
_Avoid_: Kept duration, undo window, delay

**Move**:
To give a Task a new place: a position on its own Day or on another. Moving never makes a Task Complete or Incomplete.
_Avoid_: Drag, reorder, reschedule, postpone

### Days

**Day**:
A calendar day in the user's local calendar. A Task's Day never shifts when the user changes time zone.
_Avoid_: Date (for the concept), due date, deadline

**Today**:
The Day it is now on the device. Rolls over at local midnight.

**Tomorrow**:
The Day after Today.

**Yesterday**:
The Day before Today.

**Overdue**:
Describes an Incomplete Task whose Day is before Today. A Task completed from Overdue stays listed there, Complete, for an hour.
_Avoid_: Late, missed, past due

**History**:
A way of listing Days that shows every Day before Today, each with all its Tasks, Complete or not, in place of Overdue. In History any Day can be chosen for a Task, so a Task can be made Overdue on purpose.
_Avoid_: Archive, past, log, timeline
