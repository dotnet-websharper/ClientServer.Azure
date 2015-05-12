@ECHO OFF
setlocal

REM Set your application folder relative to root
set APPLICATION_FOLDER=MyApplication

echo ====== Restoring packages... ======

if not exist .paket (
  mkdir .paket
)

curl https://github.com/fsprojects/Paket/releases/download/1.2.0/paket.bootstrapper.exe -L --insecure -o .paket\paket.bootstrapper.exe

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
  set MSBUILD_PATH="%ProgramFiles(x86)%\MSBuild\12.0\Bin\MSBuild.exe"
)

%MSBUILD_PATH% /p:Configuration=Release

if not %ERRORLEVEL% == 0 (
  echo ====== Build failed. ======
  exit 1
)

if not "%DEPLOYMENT_TARGET%" == "" (
  xcopy /y /e %APPLICATION_FOLDER% "%DEPLOYMENT_TARGET%"
)

echo ====== Done. ======
