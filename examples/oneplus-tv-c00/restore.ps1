# Put this OnePlus C00 back exactly as it was on 2026-10-19 (see backup/oneplus-c00-2026-10-19/):
# re-enable everything in debloat.txt, FLauncher as home, the OnePlus screensaver, animations at 0.
# The new launcher (com.gathin.tvhome) stays installed but is no longer home; remove it with
#   tools\venv\Scripts\python.exe -I tools\tv.py 'pm uninstall com.gathin.tvhome'
#
# Usage: powershell -ExecutionPolicy Bypass -File examples\oneplus-tv-c00\restore.ps1 [-TvHost 192.168.29.182]
param([string]$TvHost = $(if ($env:TV_HOST) { $env:TV_HOST } else { '192.168.29.182' }))
$ErrorActionPreference = 'Stop'
# Pipe plain UTF-8 to native commands; the default here prepends a BOM that corrupts the first command.
$OutputEncoding = New-Object System.Text.UTF8Encoding $false
$repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$env:TV_HOST = $TvHost

$pkgs = Get-Content (Join-Path $PSScriptRoot 'debloat.txt') | ForEach-Object { ($_ -replace '#.*$', '').Trim() } | Where-Object { $_ }
$cmds = @($pkgs | ForEach-Object { "pm enable $_" }) + @(
    'pm enable me.efesser.flauncher',
    'cmd package set-home-activity --user 0 me.efesser.flauncher/.MainActivity',
    'settings put secure screensaver_components com.oneplus.tv.screensaver/.service.DaydreamService',
    'settings put global window_animation_scale 0.0',
    'settings put global transition_animation_scale 0.0',
    'settings put global animator_duration_scale 0.0',
    'pm list packages -d'
)
$cmds | & (Join-Path $repo 'tools\venv\Scripts\python.exe') -I (Join-Path $repo 'tools\tv.py') --batch
