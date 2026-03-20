@echo off
REM BSLND Backend - Multi-Mode Startup Script (Windows)
REM ====================================================

setlocal enabledelayedexpansion

REM Get the mode from command line argument, default to development
if "%1%"=="" (
  set MODE=development
) else (
  set MODE=%1%
)

REM Validate mode
if /i "%MODE%"=="development" (
  set MODE=development
  set EMOJI=🚀
) else if /i "%MODE%"=="dev" (
  set MODE=development
  set EMOJI=🚀
) else if /i "%MODE%"=="test" (
  set MODE=test
  set EMOJI=🧪
) else if /i "%MODE%"=="production" (
  set MODE=production
  set EMOJI=⚡
) else if /i "%MODE%"=="prod" (
  set MODE=production
  set EMOJI=⚡
) else (
  echo [ERROR] Invalid mode: %MODE%
  echo Usage: start.bat [development^|test^|production]
  exit /b 1
)

REM Check if node_modules exists
if not exist "node_modules" (
  echo [WARNING] node_modules not found. Running npm install...
  call npm install
  if errorlevel 1 (
    echo [ERROR] npm install failed
    exit /b 1
  )
)

REM Set environment variable
set NODE_ENV=%MODE%

echo.
echo %EMOJI% Starting BSLND Backend in %MODE% mode...
echo ══════════════════════════════════════════════════

REM Run appropriate command
if /i "%MODE%"=="production" (
  echo Running: npm start
  call npm start
) else if /i "%MODE%"=="test" (
  if /i "%2%"=="watch" (
    echo Running: npm run test:watch
    call npm run test:watch
  ) else (
    echo Running: npm run test
    call npm run test
  )
) else (
  echo Running: npm run dev
  call npm run dev
)

if errorlevel 1 (
  echo [ERROR] Failed to start backend
  exit /b 1
)

endlocal

