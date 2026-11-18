# SeaPower.AlternativeBase

Code that is the same in the rgreat Sea Power mods (Alternative Game Interface, Alternative Weapons Control, Alternative Damage Model,
Alternative Special Effects). The mods stay independent: they do not need each other or this repository at run time. The files here are shared
source, copied into each mod (like SettingsHub.cs always was) and compiled into its own dll.

| File | What it is |
| --- | --- |
| src/TabScroll.cs | the strip of tabs of a settings window as one line: scrolled by the arrow buttons (visible only while the tabs do not fit) and the wheel; the chosen tab is kept in view |
| src/SettingsShotKit.cs | screenshots of every tab of a settings window, the window fitted to each tab; IShotWindow is what a mod implements for its window |

tools/sync.sh copies the files into the sibling folders seapower.alternativegameinterface, seapower.alternativeweaponscontrol,
seapower.alternativedamagemodel, seapower.alternativespecialeffects (src/). Change a file here, run the script, build the mods.
Never edit a copy inside a mod.

Not moved yet: SettingsHub.cs (the canonical copy is still in Alternative Special Effects), the window chrome (title bar, drag, resize edges,
help pane, footer), the editors of the rows (number, check box, choice, colour), Loc.cs.
