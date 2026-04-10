@echo off
title DDTank - Inicializacao do Servidor
setlocal enabledelayedexpansion

net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo.
    echo ==============================================================
    echo ERRO: Voce precisa rodar este script como ADMINISTRADOR!
    echo Clique nele com o botao direito e selecione "Executar como Administrador".
    echo ==============================================================
    pause
    exit /b 1
)

set "BASEDIR=%~dp0"
set "CENTER_OK=ERRO"
set "FIGHT_OK=ERRO"
set "ROAD_OK=ERRO"

echo.
echo ==============================================================
echo            DDTank - Inicializacao do Servidor
echo ==============================================================
echo.

echo [1/3] Iniciando Center.Service...
pushd "%BASEDIR%Server\Center"
start "" Center.Service.exe
popd

timeout /t 5 /nobreak >nul

tasklist /FI "IMAGENAME eq Center.Service.exe" 2>nul | find /i "Center.Service.exe" >nul
if %errorLevel% NEQ 0 (
    echo.
    echo [ERRO] Center.Service nao iniciou! Verifique logs em Server\Center\logs.
    echo Nao e possivel continuar sem o Center.
    echo.
    pause
    exit /b 1
)

echo Aguardando Center responder na porta 9202...
set "CENTER_PORT_OK=0"
for /l %%i in (1,1,12) do (
    powershell -Command "try { $t = Test-NetConnection -ComputerName 127.0.0.1 -Port 9202 -WarningAction SilentlyContinue -ErrorAction SilentlyContinue; if ($t.TcpTestSucceeded) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>&1
    if !errorLevel! EQU 0 (
        set "CENTER_PORT_OK=1"
        goto :center_ready
    )
    echo   Tentativa %%i/12 - Center ainda nao responde na porta 9202...
    timeout /t 5 /nobreak >nul
)

if "!CENTER_PORT_OK!"=="0" (
    echo.
    echo [AVISO] Center iniciou mas nao respondeu na porta 9202 apos 60s.
    echo Verifique logs em Server\Center\logs.
    set "CENTER_OK=AVISO"
) else (
    set "CENTER_OK=OK"
)

:center_ready
if "!CENTER_OK!"=="OK" (
    echo [OK] Center.Service rodando na porta 9202.
)

if "!CENTER_OK!"=="AVISO" (
    echo.
    echo Deseja continuar mesmo sem confirmacao do Center? (S/N)
    set /p CONTINUAR=
    if /i not "!CONTINUAR!"=="S" (
        echo Inicializacao cancelada.
        pause
        exit /b 1
    )
)

echo.
echo [2/3] Iniciando Fighting.Service...
pushd "%BASEDIR%Server\Fight"
start "" Fighting.Service.exe
popd

timeout /t 5 /nobreak >nul

tasklist /FI "IMAGENAME eq Fighting.Service.exe" 2>nul | find /i "Fighting.Service.exe" >nul
if %errorLevel% NEQ 0 (
    echo [AVISO] Fighting.Service pode nao ter iniciado. Verifique logs.
    set "FIGHT_OK=AVISO"
) else (
    echo Aguardando Fight responder na porta 9208...
    set "FIGHT_PORT_OK=0"
    for /l %%i in (1,1,12) do (
        powershell -Command "try { $t = Test-NetConnection -ComputerName 127.0.0.1 -Port 9208 -WarningAction SilentlyContinue -ErrorAction SilentlyContinue; if ($t.TcpTestSucceeded) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>&1
        if !errorLevel! EQU 0 (
            set "FIGHT_PORT_OK=1"
            goto :fight_ready
        )
        echo   Tentativa %%i/12 - Fight ainda nao responde na porta 9208...
        timeout /t 5 /nobreak >nul
    )
    if "!FIGHT_PORT_OK!"=="0" (
        echo [AVISO] Fight nao respondeu na porta 9208 apos 60s.
        set "FIGHT_OK=AVISO"
    ) else (
        set "FIGHT_OK=OK"
    )
)

:fight_ready
if "!FIGHT_OK!"=="OK" (
    echo [OK] Fighting.Service rodando na porta 9208.
)

echo.
echo [3/3] Iniciando Road.Service...
pushd "%BASEDIR%Server\Road"
start "" Road.Service.exe
popd

timeout /t 5 /nobreak >nul

tasklist /FI "IMAGENAME eq Road.Service.exe" 2>nul | find /i "Road.Service.exe" >nul
if %errorLevel% NEQ 0 (
    echo [AVISO] Road.Service pode nao ter iniciado. Verifique logs.
    set "ROAD_OK=AVISO"
) else (
    echo Aguardando Road responder na porta 9500...
    set "ROAD_PORT_OK=0"
    for /l %%i in (1,1,12) do (
        powershell -Command "try { $t = Test-NetConnection -ComputerName 127.0.0.1 -Port 9500 -WarningAction SilentlyContinue -ErrorAction SilentlyContinue; if ($t.TcpTestSucceeded) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>&1
        if !errorLevel! EQU 0 (
            set "ROAD_PORT_OK=1"
            goto :road_ready
        )
        echo   Tentativa %%i/12 - Road ainda nao responde na porta 9500...
        timeout /t 5 /nobreak >nul
    )
    if "!ROAD_PORT_OK!"=="0" (
        echo [AVISO] Road nao respondeu na porta 9500 apos 60s.
        set "ROAD_OK=AVISO"
    ) else (
        set "ROAD_OK=OK"
    )
)

:road_ready
if "!ROAD_OK!"=="OK" (
    echo [OK] Road.Service rodando na porta 9500.
)

echo.
echo ==============================================================
echo                    Resumo dos Servicos
echo ==============================================================
echo.
echo   Servico             Porta    Status
echo   -------             -----    ------
echo   Center.Service      9202     !CENTER_OK!
echo   Fighting.Service    9208     !FIGHT_OK!
echo   Road.Service        9500     !ROAD_OK!
echo.
echo ==============================================================
echo.
echo Mantenha as janelas dos servicos abertas.
echo Para desligar o servidor, execute desligar_servidor.bat.
echo.
pause