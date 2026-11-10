---
status: accepted
---

# A Task stores the moment it was made Complete, and Overdue keeps it for an hour

The widget's Grace Period needs to know when a Task was made Complete, and a Task stored only the Day it was. So the stored `completeDay` became `completeTime`: the moment the Task was made Complete. Unlike a Task's Day (ADR 0001), it's a plain moment, not a GMT-midnight Day.

Overdue used to keep a Task completed from it until Today rolled over, by comparing `completeDay` with Today. A moment compared with a GMT-midnight Today is off by the UTC offset: completed at 01:00 in Kyiv, it reads as the Day before. So Overdue now keeps a Task completed from it for an hour after `completeTime`, measured against now, which no time zone touches. The hour may run past midnight.

## Considered Options

- **A record of the widget's completions in the App Group's `UserDefaults`**, with the store left as it was. Rejected: a second place that says when a Task was made Complete, kept in step by the widget's intents alone.
- **A second field beside `completeDay`.** Rejected: two stored answers to when a Task was made Complete.
- **The moment in `completeDay`, still compared with Today.** Rejected: wrong by the UTC offset near midnight, as above.

## Consequences

- V1 is edited in place, since nothing is released yet. The rename carries `@Attribute(originalName: "completeDay")`, so the one device holding real data migrates its store on its first launch. A later commit drops `originalName` once that device has run it.
- Values stored before the change are GMT midnights. Read as moments they're hours old, so a Task completed from Overdue before the update leaves Overdue on the first launch.
- The Schedule takes now as well as Today, and the app rebuilds it when the hour of a Task kept in Overdue ends. The stream's lower bound for Complete Tasks is an hour before the moment it fetches.
- Each widget's Grace Period counts from `completeTime`, so a Task made Complete in the app is kept on the widget too, for what's left of that widget's Grace Period (ADR 0005).
