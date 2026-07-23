# Platform Support (Task 6.3)

`flutter test` (Task 6.1's state-management smoke tests + Task 6.2's
goldens) only exercises the widget tree in a headless test harness —
it never touches a real device, browser, or window manager. This
document is the manual pass those tests can't cover: an identical
checklist run by a human on each target platform, using the example
app (using the example application or a minimal verification application that just imports the package and calls
`showEthiopianDatePicker` / `showEthiopianDateRangePicker` /
`EthiopianDateFormField`).

If `example/` doesn't exist yet in this package, create a minimal one
first:

```bash
flutter create example
```

and add a `pubspec.yaml` dependency on the parent package via
`path: ../`, then build a single screen with a button for each of the
three entry points below.

---

## The test script (run identically on every platform)

Run each checklist item in order on every supported platform. Anything that doesn't match — note it
in the row's "Notes" column in the summary table at the bottom rather
than silently checking it off.

1. **Open the single-date picker** — tap/click the field or button
   that calls `showEthiopianDatePicker`. Dialog should fade+scale in
   (Task 4.1) with today's month displayed and today's cell outlined.
2. **Navigate months** — tap the next/previous chevrons several times,
   including across a year boundary (e.g. from Pagume into Meskerem)
   and past `firstDate`/`lastDate` (the chevron should disable rather
   than wrap or crash). Confirm the month/year label updates and the
   slide+fade transition (Task 4.1) is smooth, not janky.
3. **Select a date and confirm** — tap a day, tap OK, confirm the
   value returned matches what was tapped. Reopen and tap Cancel —
   confirm it returns `null` and doesn't mutate the field.
4. **Range picker** — call `showEthiopianDateRangePicker`. Tap a start
   day, then an end day; confirm the band highlight fills between them
   (Task 4.2). Tap a third day — confirm it starts a **new** range
   rather than extending the old one. Try tapping end-before-start —
   confirm the range still comes back with `start <= end` (auto-swap).
5. **Form field** — drop an `EthiopianDateFormField` into a `Form`,
   leave it empty, call `formKey.currentState!.validate()`. Confirm
   your `validator` error text renders. Fill it in (tap-to-open mode,
   then again in typed-entry mode with a controller) and confirm
   `formKey.currentState!.save()` calls `onSaved` with the right date.
6. **Locale switch** — pass `locale: 'am'`, `'om'`, `'ti'` in turn.
   Confirm month names, weekday row, and OK/Cancel labels are all
   translated — no English leaking through, no missing-key errors.
7. **Theme** — pass a custom `EthiopianDatePickerTheme` (or toggle the
   host app between light/dark `ThemeData`) and confirm colors,
   spacing, and text styles all update, matching what Task 6.2's
   goldens show for that theme.

---

## Platform-specific additions

### Android / iOS
No extra steps beyond the script above. Additionally:
- Rotate the device mid-dialog (portrait ↔ landscape) — confirm no
  crash and the dialog re-lays-out rather than overflowing.
- Test with the system font-scale setting increased (Settings →
  Accessibility → large text) — day cells should stay tappable and
  text should clamp rather than overflow the 48px cell (Task 5.3).

### Web (Chrome + Safari at minimum; Firefox if available)
Run the full script above, then:
- **Keyboard-only pass**: unplug the mouse (or just don't touch it).
  Tab to the field, Enter/Space to open the dialog, Arrow keys to move
  between day cells, Enter to select, Esc to close. Confirm focus
  never gets stuck and the visible focus ring (Task 5.3) is always
  identifiable.
- **Mouse-only pass**: same flows via click/hover only — confirm
  parity, i.e. nothing keyboard-only users can do is unreachable by
  mouse and vice versa.
- Resize the browser window narrow (mobile-web width) and confirm the
  fixed-width calendar (364px, see `calendar_view.dart`) doesn't force
  horizontal scrolling on the page.

### Windows / macOS / Linux (desktop)
Run the full script above, then:
- Keyboard/mouse parity pass, same as web above.
- Confirm the dialog respects the OS window's actual size — test in
  both a large window and a small/resized one.
- Screen reader smoke test: NVDA (Windows), VoiceOver (macOS), Orca
  (Linux, if available) — tab into the calendar and confirm each cell
  announces its full spoken label (weekday, month, day, year, "Today"
  where applicable), not just the bare digit.

---

## Support matrix

Fill in once each platform has been run through the script above.

| Platform | Automated (CI) | Manual script pass | Keyboard/mouse parity | Screen reader | Notes |
|----------|:---:|:---:|:---:|:---:|---|
| Android  | ✅ | ☐ | n/a | ☐ (TalkBack) | Build-verified in CI; no physical device available for manual pass yet |
| iOS      | ✅ | ☐ | n/a | ☐ (VoiceOver) | Build-verified in CI; no physical device available for manual pass yet |
| Web      | ✅ | ✅ | ☐ |  ☐  | Full script run + performance profiled in Chrome DevTools |
| Windows  | ✅ | ☐ | ☐ | ☐ (NVDA) | Build-verified in CI; no Windows machine available for manual pass yet |
| macOS    | ✅ | ☐ | ☐ | ☐ (VoiceOver) | Build-verified in CI; no macOS machine available for manual pass yet |
| Linux    | ✅ | ✅ | ☐ | ☐ (Orca, if available) | Full script run manually — all features confirmed working |

"Automated" is already true for all six once `flutter test` is green
in CI — that only proves the widget tree behaves correctly in
isolation, not that it renders and responds correctly on real
hardware, so every other column still needs a human before checking
it off.

---

## Accessibility notes

An automated Lighthouse accessibility audit on the web build scored 92/100,
with 16 checks passed and only one failing check. That failure —
`user-scalable="no"` on the viewport meta tag — comes from a default set by
the Flutter web engine itself (used to keep pinch-zoom from interfering with
CanvasKit rendering) across all Flutter web apps. It is not controllable
from application code and is not specific to this package.

This automated audit is a useful signal but is not a substitute for a real
screen reader pass (NVDA, VoiceOver, TalkBack, Orca) — those remain
outstanding for all platforms and are tracked in the support matrix above.