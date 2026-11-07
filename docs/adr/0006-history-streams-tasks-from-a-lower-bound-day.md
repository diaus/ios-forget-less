---
status: accepted
---

# History streams every Task from a lower-bound Day, moved back in pages

History lists every Day before Today with all its Tasks, Complete ones included, and scrolls back without limit. ADR 0002's stream fetches only the past Tasks that are Incomplete or were completed on Today, so in History the repository streams every Task whose Day is on or after a lower-bound Day instead. The bound starts about 60 Days before Today and moves back another 60 each time the list nears its top, which resubscribes. The Schedule makes the empty Days between the bound and Today itself, so the list never runs out. Outside History the stream and its query are unchanged.

## Considered Options

- **A stream of every Task**, which ADR 0002 rejected because past Complete Tasks only grow in number. It's still rejected: History is off by default and usually shows only the last few weeks.
- **A separate one-off fetch of past Tasks next to the unchanged stream.** Rejected: a write on a past Day, which History allows, would need a manual reload, which is what ADR 0002 moved away from.

## Consequences

- In History the move rule and every Day picker accept Days before Today. `canBePlanned(today:)` and ADR 0004's "nothing lands in Overdue" still hold outside History.
- A Task Moved to a past Day in History becomes Overdue, and it shows in Overdue once History is off. A Task completed on Today and Moved to a past Day shows there struck through until Today rolls over, under ADR 0002's rule.
