@echo off
setlocal enabledelayedexpansion

set BASE_DIR=%~dp0
set TARGET=%BASE_DIR%msX1turboZ.BIN
REM set PACKAGE=%BASE_DIR%msX1turbo.d88

set OBJ_DIR=%BASE_DIR%obj
set SRC_DIR=%BASE_DIR%src\msX1turbo
set RES_DIR=%BASE_DIR%res

set CAT_Z80_LIB_ROOT=ext\catZ80lib
set CAT_Z80_LIB=%CAT_Z80_LIB_ROOT%\libCatZ80.lib
set CAT_Z80_LIB_INCLUDE=%CAT_Z80_LIB_ROOT%\include

REM sdcc --version
REM SDCC : mcs51/z80/z180/r2k/r2ka/r3ka/sm83/tlcs90/ez80_z80/z80n/r800/ds390/pic16/pic14/TININative/ds400/hc08/s08/stm8/pdk13/pdk14/pdk15/mos6502/mos65c02/f8 TD- 4.5.1 #15295 (MINGW32)
REM published under GNU General Public License (GPL)
set C=sdcc
set C_FLAGS=-mz80 --debug --asm=asxxxx --std-c23 --disable-warning 110 -I%CAT_Z80_LIB_INCLUDE% -DVRAM_4000=1
set C_OPT_FLAGS=--opt-code-speed --allow-undocumented-instructions

REM sdasz80
REM sdas Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180 / ZX-Next / eZ80 / R800)
REM Copyright (C) 2012  Alan R. Baldwin
set ASM=sdasz80
set ASM_FLAGS=-l -s -I"%BASE_DIR%src\common" -I"%BASE_DIR%src\common\turboZ"

REM AILZ80ASM https://github.com/AILight/AILZ80ASM
REM *** AILZ80ASM *** Z-80 Assembler, version 1.0.1.0
REM Copyright (C) 2022 by M.Ishino (AILight)
set AILZ80ASM=AILZ80ASM.exe

set LINK=sdcc
set LINK_FLAGS=-mz80 --out-fmt-ihx --no-std-crt0 --code-loc 0x1000 --data-loc 0

REM hudisk https://github.com/BouKiCHi/HuDisk
REM HuDisk ver 1.20
set HUDISK=hudisk.exe

echo.
if not "%PACKAGE%" == "" (
    echo [96mPackage     %PACKAGE%[0m
)
echo [96mMakeTarget  %TARGET%[0m
echo [96mSourceFiles %SRC_DIR%[0m
echo.

:main
	pushd %~dp0
    call :clean_up

    if exist "%SRC_DIR%\x1_custom_crt0.S" (
        echo.
        echo =========================================================
        @echo [96mbuild "%SRC_DIR%\x1_custom_crt0.S"[0m
        echo =========================================================
        echo.
        %ASM% %ASM_FLAGS% -o %OBJ_DIR%\x1_custom_crt0.rel %SRC_DIR%\x1_custom_crt0.S
        if %errorlevel% neq 0 (
            echo [41mbuild error[0m
            pause
            exit /b 1
        )
    )

    echo.
    echo =========================================================
    @echo [96massemble[0m
    echo =========================================================
    echo.
    for /r "%SRC_DIR%" %%s in (*.asm) do (
        call :assemble %%s
        if %errorlevel% neq 0 (
            echo [41mAssemble error "%%s"[0m
            pause
            exit /b 1
        )
    )
    for /r "%SRC_DIR%" %%s in (*.z80) do (
        call :assemble_ailz80asm %%s
        if %errorlevel% neq 0 (
            echo [41mAssemble error "%%s"[0m
            pause
            exit /b 1
        )
    )

    echo.
    echo =========================================================
    @echo [96mcompile[0m
    echo =========================================================
    echo.
    for /r "%SRC_DIR%" %%s in (*.c) do (
        call :compile %%s
        if %errorlevel% neq 0 (
            echo [41mCompile error "%%s"[0m
            pause
            exit /b 1
        )
    )

    echo.
    echo =========================================================
    @echo [96mlink[0m
    echo =========================================================
    echo.
    call :link
    if %errorlevel% neq 0 (
        echo [41mLink error "%TARGET%"[0m
        pause
        exit /b 1
    )

    echo.
    echo [92mSuccess "%TARGET%"[0m
    echo.

    if not "%PACKAGE%"=="" (
        echo.
        echo =========================================================
        @echo [96mbuild package[0m
        echo =========================================================
        echo.
        call :package
        if %errorlevel% neq 0 (
            echo [41mPackage error "%PACKAGE%"[0m
            pause
            exit /b 1
        )
        echo.
        echo =========================================================
        echo [92mSuccess "%PACKAGE%"[0m
        echo =========================================================
        echo.
    )

    popd
    ENDLOCAL
pause
exit /b

:clean_up
    if exist "%OBJ_DIR%" (
        del "%OBJ_DIR%\*.o" 2> nul
        del "%OBJ_DIR%\*.rel" 2> nul
        del "%OBJ_DIR%\*.lst" 2> nul
        del "%OBJ_DIR%\*.sym" 2> nul
        del "%OBJ_DIR%\*.asm" 2> nul
        del "%OBJ_DIR%\*.ihx" 2> nul
        del "%OBJ_DIR%\*.lk" 2> nul
        del "%OBJ_DIR%\*.map" 2> nul
        del "%OBJ_DIR%\*.noi" 2> nul
        del "%OBJ_DIR%\*.adb" 2> nul
    ) else (
        mkdir "%OBJ_DIR%"
    )
    if exist "%TARGET%" (
        del "%TARGET%" 2> nul
    )
exit /b

:assemble
    @echo Assemble "%~nx1"
    %ASM% %ASM_FLAGS% -o "%OBJ_DIR%\%~n1.rel" "%1"
exit /b %errorlevel%

:assemble_ailz80asm
    @echo Assemble "%~nx1"
    %AILZ80ASM% --input "%1" --output "%OBJ_DIR%\%~n1.bin" -f
exit /b %errorlevel%

:compile
    @echo Compile "%~nx1"
    %C% %C_FLAGS% %C_OPT_FLAGS% -c "%1" -o "%OBJ_DIR%\%~n1.rel"
exit /b %errorlevel%

:link
    @echo Link "%TARGET%"
    set objFiles="%OBJ_DIR%\x1_custom_crt0.rel"
    for /r "%OBJ_DIR%" %%i in (*.rel) do (
        if "%%i" neq "%OBJ_DIR%\x1_custom_crt0.rel" (
            @echo   "%%i"
            set objFiles=!objFiles! "%%i"
        )
    )
    set objFiles=%objFiles% %CAT_Z80_LIB%
    %LINK% %LINK_FLAGS% %objFiles% -o "%OBJ_DIR%\temp.ihx"
    if %errorlevel% neq 0 (
        exit /b %errorlevel%
    )
    makebin -p -s 65536 -o 4096 "%OBJ_DIR%\temp.ihx" %TARGET%
exit /b %errorlevel%

:package
    @echo package "%PACKAGE%"

    @echo   add "%TARGET%" as boot image
    %HUDISK% "%PACKAGE%" --format  "%TARGET%" --ipl "msX1turbo" > nul
    if %errorlevel% neq 0 (
        exit /b %errorlevel%
    )

    for /r "%RES_DIR%" %%i in (*.ROM) do (
        @echo   add "%%i"
        %HUDISK% "%PACKAGE%" -a "%%i"  --read 4000 --go 4000 > nul
        if %errorlevel% neq 0 (
            exit /b %errorlevel%
        )
    )
    for /r "%RES_DIR%" %%i in (*.0??) do (
        @echo   add "%%i"
        %HUDISK% "%PACKAGE%" -a "%%i"  --read 4000 --go 4000 > nul
        if %errorlevel% neq 0 (
            exit /b %errorlevel%
        )
    )
    for /r "%RES_DIR%" %%i in (*.ips) do (
        @echo   add "%%i"
        %HUDISK% "%PACKAGE%" -a "%%i"  --read C000 --go C000 > nul
        if %errorlevel% neq 0 (
            exit /b %errorlevel%
        )
    )
exit /b %errorlevel%
