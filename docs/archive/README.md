# Archive — Goal Isle

This directory contains outdated and historical documentation that has been superseded by the current doc set.

**Do not use these as a reference for the current project.** They are kept only for historical context.

---

## Why an Archive?

The project accumulated many `.md` files during the long debugging saga (June 18–22). They contradicted each other because:

- They were written at different times, before the actual root cause was known.
- Multiple incorrect diagnoses were documented as if they were fixes.
- The HTML mockup was treated as the primary product before the Flutter app was fixed.
- Some docs (like `MASTER_INDEX.md`) were replaced by `README.md` at the project root.

The current doc set (`README.md`, `CURRENT_STATUS.md`, `UI_DEVELOPMENT_PLAN.md`, `docs/ARCHITECTURE.md`, `docs/DEVELOPMENT.md`, `docs/HISTORY.md`, `docs/design/*`) supersedes everything in this archive.

---

## What's in Here

| File | Why archived |
|---|---|
| `DEBUGGING_SUMMARY.md` | Predates the actual root cause discovery. Documents 5 wrong diagnoses. |
| `STRUCTURAL_ANALYSIS.md` | Identified `dart:io` as root cause. It wasn't — `ua_client_hints` (transitive dep of `supabase_flutter`) was. |
| `ROOT_CAUSE_RESOLUTION.md` | Same as above. "Root cause" was incorrect. |
| `ADDITIONAL_FIXES.md` | Lists race condition fixes and null-aware operators. None of these were the actual fix. |
| `HONEST_ASSESSMENT.md` | Predates the Flutter app working. Recommends abandoning Flutter for the HTML mockup. |
| `RESUME_WORK_GUIDE.md` | Refers to the HTML mockup as the primary product. |
| `QUICK_START.md` | Describes the app as broken with a null check error. |
| `WORKING_MOCKUP_SUCCESS.md` | Documents the HTML mockup as the working product. Mockup is now archived. |
| `README_MOCKUP.md` | Same as above. |
| `TEST_RESUME.md` | A test of whether a new AI can read docs and resume. Not needed. |
| `MASTER_INDEX.md` | Replaced by `README.md` at project root. |

---

## What to Read Instead

| If you want to know about… | Read |
|---|---|
| Project state, what's working now | [`../../CURRENT_STATUS.md`](../../CURRENT_STATUS.md) |
| Why the Flutter app finally renders | [`../../FLUTTER_DEBUG_LOG.md`](../../FLUTTER_DEBUG_LOG.md) |
| The plan for designing the UI | [`../../UI_DEVELOPMENT_PLAN.md`](../../UI_DEVELOPMENT_PLAN.md) |
| Project timeline | [`../HISTORY.md`](../HISTORY.md) |
| Code architecture | [`../ARCHITECTURE.md`](../ARCHITECTURE.md) |
| How to develop | [`../DEVELOPMENT.md`](../DEVELOPMENT.md) |
| Design intent | [`../design/VISION.md`](../design/VISION.md) |
| Design tokens | [`../design/TOKENS.md`](../design/TOKENS.md) |

---

*Last updated: June 22, 2026.*