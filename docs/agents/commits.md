# Commits

Start each commit subject with a tag in brackets, as in `[task] Add the small Home Screen size to the Upcoming widget`:
- `task`: implements a feature.
- `refactor`: restructures code without changing behaviour.
- `fix`: fixes a bug.
- `amdt`: a small request that changes or adds functionality (amendment).
- `cr`: applies code review changes.
- `spec`: adds or changes a spec (`.scratch/<feature>/`).
- `agents`: changes agent instructions (`CLAUDE.md`, `docs/agents/`, skills).

When no tag fits, commit untagged and propose a new tag for this list.

An amend to a `[task]` commit keeps its subject's `[task]` tag, even when the amended change alone would earn `amdt`, `fix` or `cr`.
