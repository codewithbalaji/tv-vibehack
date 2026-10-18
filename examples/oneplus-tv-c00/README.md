# OnePlus TV C00 (Cebu), Android TV 11 — what was done on 2026-10-19

TV at `192.168.29.182`, ADB on port 5555. Commands below run from the repo root in PowerShell.
Set the TV address once per terminal:

```powershell
$env:TV_HOST = '192.168.29.182'
```

## What changed

- **Backup** of every package, the disabled list, `getprop` and all settings:
  `backup/oneplus-c00-2026-10-19/`.
- **Disabled** (never uninstalled) the 12 packages in [`debloat.txt`](debloat.txt): Google RLZ
  pings, the remote-diagnostics app, print spooler, file browser, camera, BT speaker mode, the
  OnePlus screensaver, Spotify, Lionsgate Play, JioGames, JioSphere and TV Bro.
  The 26 packages that were already disabled before (Netflix, Prime Video, Assistant, Miracast,
  stock launcher...) were left as they were.
- **Kept**: Live TV and HDMI inputs, the Source menu, remote and Bluetooth, keyboard, Play Store,
  Play Services, Chromecast and firmware updates.
- **Launcher**: `com.gathin.tvhome` is home, FLauncher is disabled. Dock: YouTube, JioHotstar,
  Plex, Yet+. Its Clock screensaver replaces the OnePlus one.

## Undo everything

```powershell
powershell -ExecutionPolicy Bypass -File examples\oneplus-tv-c00\restore.ps1
```

Re-enables all 12 packages, makes FLauncher home again, restores the OnePlus screensaver and the
animation settings (they were 0 on this TV). Tested: afterwards the disabled list matched the backup exactly.

## Re-enable a single app

```powershell
tools\venv\Scripts\python.exe -I tools\tv.py 'pm enable com.spotify.tv.android'
```

Package names are in `debloat.txt` (and `backup/.../packages-disabled.txt` for the ones that
were already off, e.g. `com.netflix.ninja`). No computer? TV Settings → Apps → See all apps →
show system apps → pick the app → Enable. It appears in the launcher grid straight away.

## Change the dock order

Edit `launcher/app/src/main/res/values/config.xml`, the `dock_apps` list (top to bottom = left
to right; four slots; apps that aren't installed are skipped), then rebuild and install:

```powershell
powershell -ExecutionPolicy Bypass -File launcher\build-and-install.ps1 -TvHost 192.168.29.182 -StockLauncher me.efesser.flauncher
```

The same file holds `hidden_apps` (apps never shown as tiles) and `columns`.

## Change the wallpaper

The background is plain black. To use a picture:

1. Save a 1920×1080 JPEG as `launcher/app/src/main/res/drawable-nodpi/wallpaper.jpg`
   (lowercase name, keep it under ~500 KB: the TV is short on memory).
2. In `launcher/app/src/main/res/layout/activity_main.xml`, line 6, change
   `android:background="#FF000000"` to `android:background="@drawable/wallpaper"`.
3. Rebuild and install with the command above.

## Notes for this TV

- **ADB installs are blocked by Play Protect** (`INSTALL_FAILED_VERIFICATION_FAILURE`). The install
  scripts now switch `verifier_verify_adb_installs` off for the install and back to default after.
- **`screencap` prints debug text** before the PNG on stdout, and sometimes writes an empty file.
  Save on the TV (`screencap -p /data/local/tmp/s.png`), check it's non-empty, then `adb pull`.
- **The Wi-Fi pill shows "Wi-Fi"** rather than the network name because Location is off
  (Android 11 hides the SSID without it). Turning on Location in TV Settings shows the name.
- **Animations are off** system-wide (set before this work), so the tile lift, name and glow
  fades happen instantly. For the full effect: Settings → Device Preferences → Developer options → set the
  three animation scales to 1x.
- The Home key sometimes lands on Live TV right after the screen wakes; press Home again.
