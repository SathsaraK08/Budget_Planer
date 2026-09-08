@echo off
:: ============================================================
:: HomeBudget - Flutter Portable Setup (No Admin Required)
:: Run this once to install Flutter to your user folder
:: ============================================================

set FLUTTER_DIR=%USERPROFILE%\flutter
set FLUTTER_BIN=%FLUTTER_DIR%\bin

echo.
echo [1/3] Checking if Flutter is already installed...
if exist "%FLUTTER_BIN%\flutter.bat" (
    echo Flutter already found at %FLUTTER_BIN%
    goto :run
)

echo.
echo [2/3] Downloading Flutter stable (portable, no admin needed)...
echo This will download ~700MB to %FLUTTER_DIR%
echo.

:: Use PowerShell to download the Flutter zip
powershell -Command "& { $url = 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.3-stable.zip'; $out = '%TEMP%\flutter.zip'; Write-Host 'Downloading...'; Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing; Write-Host 'Extracting...'; Expand-Archive -Path $out -DestinationPath '%USERPROFILE%' -Force; Write-Host 'Done.' }"

if errorlevel 1 (
    echo Download failed. Please download manually from https://flutter.dev/docs/get-started/install/windows
    exit /b 1
)

:run
echo.
echo [3/3] Running HomeBudget in Chrome...

:: Add Flutter bin to PATH for this session
set PATH=%FLUTTER_BIN%;%PATH%

cd /d "%~dp0"
echo Getting dependencies...
call flutter pub get

echo.
echo Launching in Chrome (web mode)...
call flutter run -d chrome --web-port 8080

pause
