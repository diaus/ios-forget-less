# Domain Docs

Before exploring the codebase, read `GLOSSARY.md` at the repo root and the ADRs in `docs/adr/` that touch the area you're about to work in. The repo is single-context: one glossary, one ADR folder. The `/domain-modeling` skill owns their format and adds entries as terms and decisions get resolved.

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis, a test name), use the term as defined in `GLOSSARY.md`, not a synonym the glossary lists under _Avoid_.

If the concept you need isn't in the glossary yet, that's a signal: either you're inventing language the project doesn't use (reconsider) or there's a real gap (note it for `/domain-modeling`).

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly rather than silently overriding:

> _Contradicts ADR-0007 (event-sourced orders), but worth reopening because…_
