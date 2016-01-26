@ECHO OFF
setlocal ENABLEDELAYEDEXPANSION

REM Set your application folder relative to root
set APPLICATION_FOLDER=MyApplication

echo ====== Restoring packages... ======

if not exist .paket (
  mkdir .paket
)

if not exist .paket\paket.bootstrapper.exe (
    where /q curl
    if not !ERRORLEVEL! == 0 (
        echo ====== Failed to find paket bootstrapper and curl was not available
        exit 1
    )
        
    curl https://github.com/fsprojects/Paket/releases/download/1.2.0/paket.bootstrapper.exe -L --insecure -o .paket\paket.bootstrapper.exe
)

if not exist .paket\paket.exe (
  .paket\paket.bootstrapper.exe
)

.paket\paket.exe restore

if not %ERRORLEVEL% == 0 (
  echo ====== Failed to restore packages. ======
  exit 1
)

echo ====== Building... ======

REM Azure provides MSBUILD_PATH and DEPLOYMENT_TARGET.
REM If we're not deploying to Azure (eg. building locally),
REM we need to set MSBUILD_PATH.

if "%MSBUILD_PATH%" == "" (
  echo MSBUILD_PATH not found - assuming local build.
  set "MSBUILD_PATH=%ProgramFiles(x86)%\MSBuild\14.0\Bin\MSBuild.exe"

  if not exist "!MSBUILD_PATH!" (
      echo !MSBUILD_PATH! does not exist
      set "MSBUILD_PATH=%ProgramFiles(x86)%\MSBuild\12.0\Bin\MSBuild.exe"
      echo Trying !MSBUILD_PATH!
      if not exist "!MSBUILD_PATH!" (
          echo ====== Failed to find msbuild ======
          exit 1
      )
  )
)

echo using %MSBUILD_PATH%

"%MSBUILD_PATH%" /p:Configuration=Release

if not %ERRORLEVEL% == 0 (
  echo ====== Build failed. ======
  exit 1
)

if not "%DEPLOYMENT_TARGET%" == "" (
  xcopy /y /e %APPLICATION_FOLDER% "%DEPLOYMENT_TARGET%"
)

echo ====== Done. ======
