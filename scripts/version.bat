@echo off
REM Version Management Script for Food Calorie App (Windows)
REM This script helps manage version numbers and releases

setlocal enabledelayedexpansion

REM Configuration
set PUBSPEC_FILE=frontend\pubspec.yaml
set VERSION_FILE=frontend\lib\utils\app_version.dart
set CHANGELOG_FILE=CHANGELOG.md

REM Get current version from pubspec.yaml
for /f "tokens=2 delims=: " %%a in ('findstr "^version:" %PUBSPEC_FILE%') do (
    set VERSION_LINE=%%a
)
for /f "tokens=1,2 delims=+" %%a in ("%VERSION_LINE%") do (
    set CURRENT_VERSION=%%a
    set CURRENT_BUILD=%%b
)

echo Current Version: %CURRENT_VERSION%+%CURRENT_BUILD%

REM Parse version components
for /f "tokens=1,2,3 delims=." %%a in ("%CURRENT_VERSION%") do (
    set MAJOR=%%a
    set MINOR=%%b
    set PATCH=%%c
)

if "%1"=="show" goto :show_version
if "%1"=="bump" goto :bump_version
if "%1"=="release" goto :create_release
if "%1"=="help" goto :show_help
if "%1"=="" goto :show_help

echo Unknown command: %1%
goto :show_help

:show_version
echo.
echo ========================================
echo   Current Version Information
echo ========================================
echo Version: %CURRENT_VERSION%
echo Build: %CURRENT_BUILD%
echo Full: %CURRENT_VERSION%+%CURRENT_BUILD%
echo ========================================
goto :end

:bump_version
set TYPE=%2
if "%TYPE%"=="" (
    echo Usage: %0 bump [major^|minor^|patch^|build]
    goto :end
)

if "%TYPE%"=="major" (
    set /a MAJOR+=1
    set MINOR=0
    set PATCH=0
    set BUILD=1
) else if "%TYPE%"=="minor" (
    set /a MINOR+=1
    set PATCH=0
    set BUILD=1
) else if "%TYPE%"=="patch" (
    set /a PATCH+=1
    set /a BUILD=%CURRENT_BUILD%+1
) else if "%TYPE%"=="build" (
    set /a BUILD=%CURRENT_BUILD%+1
) else (
    echo Invalid version type: %TYPE%
    echo Usage: %0 bump [major^|minor^|patch^|build]
    goto :end
)

set NEW_VERSION=%MAJOR%.%MINOR%.%PATCH%+%BUILD%

echo Bumping version from %CURRENT_VERSION%+%CURRENT_BUILD% to %NEW_VERSION%

REM Update pubspec.yaml
powershell -Command "(Get-Content %PUBSPEC_FILE%) -replace '^version: .*', 'version: %NEW_VERSION%' | Set-Content %PUBSPEC_FILE%"

REM Update app_version.dart
powershell -Command "(Get-Content %VERSION_FILE%) -replace \"static const String version = '.*';\", \"static const String version = '%MAJOR%.%MINOR%.%PATCH%';\" | Set-Content %VERSION_FILE%"
powershell -Command "(Get-Content %VERSION_FILE%) -replace 'static const int buildNumber = .*', 'static const int buildNumber = %BUILD%;' | Set-Content %VERSION_FILE%"

echo Version updated successfully!
echo New version: %NEW_VERSION%
goto :end

:create_release
echo Creating release for version %CURRENT_VERSION%+%CURRENT_BUILD%

REM Check for uncommitted changes
git status --porcelain >nul 2>&1
if %errorlevel% equ 0 (
    for /f %%i in ('git status --porcelain ^| find /c /v ""') do set CHANGES=%%i
    if !CHANGES! gtr 0 (
        echo Warning: You have uncommitted changes
        set /p CONTINUE="Do you want to continue? (y/n): "
        if /i not "!CONTINUE!"=="y" goto :end
    )
)

REM Update CHANGELOG.md
echo Updating CHANGELOG.md
set /p NOTES="Enter release notes for this version: "

REM Add new version to CHANGELOG (simplified - you may want to edit manually)
echo ## [%CURRENT_VERSION%] - %date% >> %CHANGELOG_FILE%
echo. >> %CHANGELOG_FILE%
echo ### Added >> %CHANGELOG_FILE%
echo - %NOTES% >> %CHANGELOG_FILE%
echo. >> %CHANGELOG_FILE%

REM Commit changes
echo Committing changes
git add %PUBSPEC_FILE% %VERSION_FILE% %CHANGELOG_FILE%
git commit -m "chore: release v%CURRENT_VERSION%"

REM Create tag
echo Creating git tag
git tag -a "v%CURRENT_VERSION%" -m "Release version %CURRENT_VERSION%"

echo Release created successfully!
echo To push the release, run:
echo   git push origin main
echo   git push origin v%CURRENT_VERSION%
goto :end

:show_help
echo Version Management Script for Food Calorie App
echo.
echo Usage: %0 [command] [options]
echo.
echo Commands:
echo   show              Show current version
echo   bump [type]       Bump version (major, minor, patch, or build)
echo   release           Create a new release
echo   help              Show this help message
echo.
echo Examples:
echo   %0 show
echo   %0 bump minor
echo   %0 release
goto :end

:end
endlocal
