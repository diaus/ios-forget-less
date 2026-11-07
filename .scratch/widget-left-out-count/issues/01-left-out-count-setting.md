# 01: The "Show Left Out Count" setting and the "+N"

Status: ready-for-agent

**What to build:** everything in `../spec.md`, in one change: the content's `leftOutTaskCount`, the setting, the "+N" on every size, and the two String Catalog keys.

**Blocked by:** `.scratch/home-screen-large-widget/issues/02-medium-size-and-full-size-rows.md`, since the medium size and the full-size rows decide which rows are left out on the sizes with controls.

- [ ] Domain tests for the count pass: Overdue and Today past the cap counted, Tomorrow's not, only Tomorrow's left out gives 0, Overdue not listed isn't counted.
- [ ] Previews (`RenderPreview`) show the "+N" on the Lock Screen (one and two columns), small, medium and large, and none with the setting off or with only Tomorrow's Tasks left out.
- [ ] `build_sim`, `test_sim` and `scripts/check.sh` pass.
- [ ] On the iOS 27 simulator, the Lock Screen and Home Screen widgets show the "+N", and turning "Show Left Out Count" off hides it.
