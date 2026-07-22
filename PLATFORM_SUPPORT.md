# Platform Support Matrix (Task 6.3)

Paste this table into the README once each row has been manually
verified. "Automated" = covered by `flutter test` (unit/widget/golden);
"Manual" = run the example app on a real device/browser and click
through: open picker, pick a date, navigate months, keyboard nav
(desktop/web), range selection, form field validation.

| Platform | Automated (CI) | Manual pass | Keyboard/mouse parity | Notes |
|----------|:---:|:---:|:---:|---|
| Android  | ✅ | ☐ | n/a | |
| iOS      | ✅ | ☐ | n/a | |
| Web      | ✅ | ☐ | ☐ | Check tab order + Enter/Esc in Chrome & Safari |
| Windows  | ✅ | ☐ | ☐ | |
| macOS    | ✅ | ☐ | ☐ | |
| Linux    | ✅ | ☐ | ☐ | |

"Automated" is already true for all six once `flutter test` (Task 6.1's
smoke tests + Task 6.2's goldens) is green in CI — those don't exercise
a real device/browser, so the "Manual pass" column still needs a human
for each platform before checking it off.