@echo off

setlocal

for %%D in ("%~dp0..\..\..\..\fsbl") do set "FSBL_DIR=%%~fD"
set "BIN=%FSBL_DIR%\stm32n657xx_fsbl-trusted.bin"
set "FLASH_ADDR=0x70000000"

echo.
echo ============================================
echo STM32N657 FSBL Programming
echo ============================================
echo BIN: %BIN%
echo Address: %FLASH_ADDR%
echo.

if not defined N6570_ExternalLoader (
    echo ERROR: N6570_ExternalLoader is not defined.
    exit /b 1
)

if not exist "%BIN%" (
    echo ERROR: File not found:
    echo %BIN%
    exit /b 1
)

where STM32_Programmer_CLI.exe >nul 2>&1
if errorlevel 1 (
    echo ERROR: STM32_Programmer_CLI.exe not found.
    exit /b 1
)

STM32_Programmer_CLI.exe ^
    -c port=SWD mode=HOTPLUG ap=1 ^
    -el "%N6570_ExternalLoader%" ^
    -hardRst ^
    -w "%BIN%" %FLASH_ADDR%

if errorlevel 1 (
    echo.
    echo ERROR: Programming failed.
    exit /b 1
)

echo.
echo Programming completed successfully.

endlocal
exit /b 0
