@echo off
setlocal

REM ============================================================
REM STM32N657 FSBL Post-Build Script
REM
REM %1 = AXF file path (#L)
REM %2 = Project path ($P)
REM ============================================================

set "AXF=%~1"
set "PROJECT=%~2"

if not defined AXF (
    echo ERROR: AXF path is empty.
    exit /b 1
)

if not defined PROJECT (
    echo ERROR: Project path is empty.
    exit /b 1
)

if not exist "%AXF%" (
    echo ERROR: AXF file not found:
    echo %AXF%
    exit /b 1
)

REM Resolve AXF directory and filename
for %%F in ("%AXF%") do (
    set "AXF_DIR=%%~dpF"
    set "AXF_NAME=%%~nxF"
    set "BIN_NAME=%%~nF.bin"
)

REM Resolve binary file path
set "BIN=%AXF_DIR%%BIN_NAME%"

REM Use a path relative to this script, independent of Keil's working directory
for %%D in ("%~dp0..\..\..\..\fsbl") do set "FSBL_DIR=%%~fD"

echo.
echo ============================================================
echo STM32N657 FSBL Post-Build
echo ============================================================
echo AXF      : %AXF%
echo BIN      : %BIN%
echo FSBL DIR : %FSBL_DIR%
echo ============================================================
echo.

REM ------------------------------------------------------------
REM 1. Check binary file
REM ------------------------------------------------------------
if not exist "%BIN%" (
    echo ERROR: BIN file not found:
    echo %BIN%
    exit /b 1
)

REM ------------------------------------------------------------
REM 2. Create FSBL output directory if needed
REM ------------------------------------------------------------
if not exist "%FSBL_DIR%" (
    echo Creating FSBL directory:
    echo %FSBL_DIR%
    mkdir "%FSBL_DIR%"
    if errorlevel 1 (
        echo ERROR: Failed to create FSBL directory.
        exit /b 1
    )
)

REM ------------------------------------------------------------
REM 3. Copy binary to FSBL output directory
REM ------------------------------------------------------------
echo Copying BIN...
copy /Y "%BIN%" "%FSBL_DIR%\"
if errorlevel 1 (
    echo ERROR: Failed to copy BIN.
    exit /b 1
)

REM ------------------------------------------------------------
REM 4. Copy AXF to FSBL output directory
REM ------------------------------------------------------------
echo Copying AXF...
copy /Y "%AXF%" "%FSBL_DIR%\"
if errorlevel 1 (
    echo ERROR: Failed to copy AXF.
    exit /b 1
)

REM ------------------------------------------------------------
REM 5. Sign with STM32 Signing Tool
REM ------------------------------------------------------------
echo.
echo Signing FSBL...

where STM32_SigningTool_CLI.exe >nul 2>&1
if errorlevel 1 (
    echo ERROR: STM32_SigningTool_CLI.exe not found.
    exit /b 1
)

if exist "%FSBL_DIR%\stm32n657xx_fsbl-trusted.bin" (
    del /f /q "%FSBL_DIR%\stm32n657xx_fsbl-trusted.bin" >nul 2>&1
    if exist "%FSBL_DIR%\stm32n657xx_fsbl-trusted.bin" (
        echo ERROR: Cannot remove old signed FSBL image.
        exit /b 1
    )
)

STM32_SigningTool_CLI.exe ^
    -bin "%BIN%" ^
    -nk ^
    -of 0x80000000 ^
    -t fsbl ^
    -o "%FSBL_DIR%\stm32n657xx_fsbl-trusted.bin" ^
    -hv 2.3 ^
    -dump "%FSBL_DIR%\stm32n657xx_fsbl-trusted.bin" ^
    --align

if errorlevel 1 (
    echo ERROR: STM32 Signing Tool failed.
    exit /b 1
)

if not exist "%FSBL_DIR%\stm32n657xx_fsbl-trusted.bin" (
    echo ERROR: Signed FSBL image was not generated.
    exit /b 1
)

echo.
echo ============================================================
echo FSBL build completed successfully.
echo ============================================================
echo.

endlocal
exit /b 0
