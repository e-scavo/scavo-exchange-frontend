@echo off
setlocal

if "%~1"=="" (
    echo Uso: zip_etapa_limpio.bat 6.3
    exit /b 1
)

set "ETAPA=%~1"
set "CURRENT_DIR=%cd%"
set "PARENT_DIR=%CURRENT_DIR%\.."

set "BACKEND_DIR=%PARENT_DIR%\scavo.exchange-backend"
set "FRONTEND_DIR=%PARENT_DIR%\scavo.exchange-frontend"

set "OUTPUT_FILE=%PARENT_DIR%\scavo-exchange-frontend-%ETAPA%.zip"
set "TEMP_DIR=%temp%\scavo_exchange_bundle_%random%%random%"
set "TEMP_ROOT=%TEMP_DIR%\bundle"

echo.
echo Verificando carpetas origen...

if not exist "%BACKEND_DIR%" (
    echo ERROR: no existe la carpeta backend:
    echo %BACKEND_DIR%
    exit /b 1
)

if not exist "%FRONTEND_DIR%" (
    echo ERROR: no existe la carpeta frontend:
    echo %FRONTEND_DIR%
    exit /b 1
)

echo.
echo Preparando carpeta temporal...
mkdir "%TEMP_ROOT%"
mkdir "%TEMP_ROOT%\scavo.exchange-backend"
mkdir "%TEMP_ROOT%\scavo.exchange-frontend"

echo.
echo Copiando backend...
robocopy "%BACKEND_DIR%" "%TEMP_ROOT%\scavo.exchange-backend" /E /XD .git .idea .vscode dist build .dart_tool distribution\submissions >nul

if errorlevel 8 (
    echo ERROR: fallo robocopy al copiar backend.
    rmdir /s /q "%TEMP_DIR%"
    exit /b 1
)

echo Copiando frontend...
robocopy "%FRONTEND_DIR%" "%TEMP_ROOT%\scavo.exchange-frontend" /E /XD .git .idea .vscode dist build .dart_tool distribution\submissions >nul

if errorlevel 8 (
    echo ERROR: fallo robocopy al copiar frontend.
    rmdir /s /q "%TEMP_DIR%"
    exit /b 1
)

if exist "%OUTPUT_FILE%" del /f /q "%OUTPUT_FILE%"

echo.
echo Generando ZIP...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Compress-Archive -Path '%TEMP_ROOT%\*' -DestinationPath '%OUTPUT_FILE%' -Force"

if errorlevel 1 (
    echo ERROR: no se pudo generar el zip.
    rmdir /s /q "%TEMP_DIR%"
    exit /b 1
)

rmdir /s /q "%TEMP_DIR%"

echo.
echo ZIP generado correctamente:
echo %OUTPUT_FILE%
echo.
echo Contenido esperado dentro del ZIP:
echo - scavo.exchange-backend
echo - scavo.exchange-frontend
echo.

endlocal