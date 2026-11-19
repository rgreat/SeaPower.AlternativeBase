# SeaPower.AlternativeBase

Code that is the same in the rgreat Sea Power mods (Alternative Game Interface, Alternative Weapons Control, Alternative Damage Model,
Alternative Special Effects). The mods stay independent: they do not need each other or this repository at run time. The files here are shared
source, copied into each mod (as SettingsHub.cs always was) and compiled into its own dll. No shared dll on purpose: the mods are installed
in any combination.

| File | What it is |
| --- | --- |
| src/SettingsKit.cs | `WinStyle` (the colours of the settings windows, small helpers) and `WinFrame`: the window itself - putting it into the panel of the screen (or a Popup), the size in screen pixels cut to the screen and centred, dragging, resizing by edges and corners, title bar, help pane, footer, the game's hot keys off while typing, and the editors of a row (number - / box / +, check box, drop-down, reset arrow, help of the row under the mouse) |
| src/TabScroll.cs | the strip of tabs of a settings window as one line: scrolled by the arrow buttons (visible only while the tabs do not fit) and the wheel; the chosen tab is kept in view |
| src/SettingsShotKit.cs | screenshots of every tab of a settings window, the window fitted to each tab; IShotWindow is what a mod implements for its window |
| src/SettingsHub.cs | one menu entry (main menu / pause menu) for the settings of all installed rgreat mods (protocol v1) |

tools/sync.sh copies the files into the sibling folders seapower.alternativegameinterface, seapower.alternativeweaponscontrol,
seapower.alternativedamagemodel, seapower.alternativespecialeffects (src/). Change a file here, run the script, build the mods.
Never edit a copy inside a mod.

## Switch between the mods' windows

The mods keep separate settings windows. `WinFrame.ModRow` puts a row with the names of the installed mods at the top of each; a click hides the
current window with its edits and opens the other mod's window at the same place and size. Apply / OK apply the edits of all mods, Cancel / ✕ drop
them; a yellow dot on a mod's name marks edits not applied. The hub registry (`SettingsHub.Register`, extended fields) carries the delegates.

## What a mod keeps

The list of its options and where a value is read from / written to, the tabs and their pages, the texts (Loc.cs), what Apply / OK do,
the rows that are special (lists, tables, pads, ship pickers, profiles). A mod's SettingsWindow makes one `WinFrame` (`_f`) with its size
in screen pixels, its Trace, and - when its English text is the key of the translation (ADM) - `Tr`; the thin forwarders `Text`, `Btn`,
`Edit`, `Typing` in it call the frame.

## Not moved yet

Loc.cs (ADM uses the English text as the key, the others use `lbl.` / `help.` keys: one scheme first), the row layout of each window
(the columns differ), Apply / OK logic (what a value is stored in differs).

## Help pane

`WinFrame.HelpPane` is a fixed-height pane with a ScrollViewer: a long hint scrolls with the wheel over the pane (the text stays when the mouse leaves the row). Every mod shows a hint only through `WinFrame.ShowHelp(label, text, extra)` (or `Hover`, which calls it); it scrolls the pane back to the top. Tooltips (e.g. AGI's link hints) are not part of it: a tooltip cannot be scrolled.

## Tabs, search, revert (WinFrame)

- `TabButton` / `PageButton`: the tab strip and the second row of pages (yellow dot first, so a mod can add / remove it in place).
- `ToolRow(strip, hint, changed, tabChanged, revertTab, tip)`: returns the strip of tabs; the search box goes to the footer, leftmost; the revert button of the tab sits next to Cancel and is hidden while the tab has no edits (Footer, built after ToolRow). `Query` is the text; `Match(texts...)` tells whether a row fits (every word in some text). The search filters the current tab (its pages one under the other); tabs with nothing found are hidden, and the current one moves to the first tab with a hit.
- `GroupHeader(title, changed, revert, tip)`: a group title with ↺ that takes back the group's edits. The revert is to the values SAVED before editing (ADM: the profile's), like Cancel without closing - never to the defaults. `UpdateTools()` refreshes the buttons (call it where the dots are updated).
- `KeepScroll(scroll, rebuild)`: a page built again in place (a switch clicked, search) keeps its scroll position.

## Ctrl+C copies the text under the mouse (kit)
While the settings window is on a screen, Ctrl+C copies the help text (name - text, and the yellow extra line) of the row under the mouse, or what is written in the help pane while the mouse is over it (`GUIUtility.systemCopyBuffer`); a small "✓" shows in the pane after the copy. It does nothing while the text box that has the keyboard has text selected (its own Ctrl+C copies that; note a box selects all of its text when it gets focus). Done by `CopyPoll`, a MonoBehaviour created in `Mount` and destroyed in `Unmount` (polls `Input.GetKeyDown(C)`), no per-mod hook. The kit now needs the references `UnityEngine.InputLegacyModule` and `UnityEngine.IMGUIModule` in the csproj of every mod. Not verified in game.

## One shared Language (hub + kit)
The Language setting is no longer a row of each mod: it is a drop-down at the right of the mods' row (kit `ModRow`; the row is shown also with one mod), "Default" = the game's own language. The hub holds the value (`SettingsHub.SharedLanguage` / `SetLanguage` / `JoinLanguage`, AppDomain data `rgreat.settings.v1.lang` and `.langsinks`): every mod joins at start with a sink that stores the code in its own `[General] Language` and refreshes `Loc`; the first mod to start brings its stored value, the others take the shared one. A change is applied at once (not with Apply) and the window rebuilds itself (`WinFrame.LanguageChanged`, supplied by each mod: AGI `RebuildAfterLayout`, AWC / ASE `_redraw`, ADM `RebuildAfterLanguage`, which puts the window back in the middle). The mods give the list (`WinFrame.Languages`) and the caption (`LanguageLabel`). The window is at least as wide as the row needs for up to 4 mod names plus the language (`_rowW`; wider windows wrap when there are more mods). Not verified in game.

## Search box: clear button and carry-over (kit)
- The box has a ✕ at its right (shown while there is text): clears it.
- Switching to another mod's window carries the typed text: `SettingsKit.SwitchTo` -> `SettingsHub.CarryQuery(Query)`, the next `ToolRow` takes it once (`TakeQuery`). A plain reopen starts empty; an in-place rebuild (language change) keeps `Query`.
- Search matches the names of the options only (not the descriptions, tabs, groups).

## Last active mod (kit + hub)
`ModRow()` calls `SettingsHub.MarkLast(Id)` every time a mod's settings window is built, so the hub's `last` (AppDomain data `rgreat.settings.v1.last`) is always the mod whose window was on the screen last, however it was opened (menu button, a gear, the row of the mods). The menu button opens that mod's window; the gear of the World View window uses `SettingsHub.OpenLastOther(anchor, ownId)` (another active mod used last -> its window, else the caller opens its own). Not verified in game.
