#!/bin/bash
# Copies the shared files of the kit into the mods (src/). The mods are the sibling folders of this repository.
set -e
here="$(cd "$(dirname "$0")/.." && pwd)"; root="$(dirname "$here")"
for mod in seapower.alternativegameinterface seapower.alternativeweaponscontrol seapower.alternativedamagemodel seapower.alternativespecialeffects; do
  [ -d "$root/$mod/src" ] || { echo "skip $mod (no src)"; continue; }
  for f in TabScroll.cs SettingsShotKit.cs; do cp "$here/src/$f" "$root/$mod/src/$f"; done
  echo "synced $mod"
done
