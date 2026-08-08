@echo off
REM update.bat - one-click portfolio update.
REM Put a fresh Montrose CSV export in imports\, then double-click this file (or run it).
REM It merges new trades, then commits and pushes to GitHub.

cd /d "%~dp0"

echo == Merging transactions ==
powershell -NoProfile -ExecutionPolicy Bypass -File ".\merge.ps1"
if errorlevel 1 (
  echo.
  echo merge.ps1 failed - nothing was pushed.
  pause
  exit /b 1
)

echo.
echo == Committing and pushing ==
git add -A
git commit -m "Update portfolio %date%"
git push

echo.
echo Done.
pause
