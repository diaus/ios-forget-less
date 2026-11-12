# 01: Pin every SPM dependency to an exact version

Status: ready-for-agent

**What to build:** the spec's "Pinning" decision and its `CODING_STANDARDS.md` rule. Factory moves from "up to next major" from 3.5.0 to exactly 3.5.3, its latest release, in the app project and in the Data package. SwiftLintPlugins is already exact at 0.65.1, its latest, so it stays as is. The app behaves exactly as before.

**Blocked by:** nothing.

- [x] `project.pbxproj`: Factory's requirement is `kind = exactVersion; version = 3.5.3;`.
- [x] `Packages/Data/Package.swift`: Factory is `.package(url: "https://github.com/hmlongco/Factory.git", exact: "3.5.3")`.
- [x] Both `Package.resolved` files (the app's and `Packages/Data/`) pin Factory 3.5.3.
- [x] Before pinning, the latest tags of Factory and SwiftLintPlugins are checked again (`git ls-remote --tags`). If either is newer than this issue says, the newer version is used, and the spec and issue 02 are updated to match.
- [x] `CODING_STANDARDS.md` has the rule: every SPM dependency, in the app project and in each local package, is pinned to an exact version, the latest one when it's added or upgraded.
- [x] `build_sim`, `test_sim` and `scripts/check.sh` pass.

## Comments
