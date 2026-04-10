@echo off
title DDTank - Desligamento do Servidor
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

echo.
echo ==============================================================
echo           DDTank - Desligamento do Servidor
echo ==============================================================
echo.

set "ROAD_STATUS=---"
set "FIGHT_STATUS=---"
set "CENTER_STATUS=---"

echo [1/3] Parando Road.Service...
tasklist /FI "IMAGENAME eq Road.Service.exe" 2>nul | find /i "Road.Service.exe" >nul
if %errorLevel% NEQ 0 (
    echo   Road.Service nao esta em execucao.
    set "ROAD_STATUS=N/A"
) else (
    taskkill /IM Road.Service.exe /T /F >nul 2>&1
    timeout /t 3 /nobreak >nul
    tasklist /FI "IMAGENAME eq Road.Service.exe" 2>nul | find /i "Road.Service.exe" >nul
    if !errorLevel! EQU 0 (
        echo   [AVISO] Road.Service ainda em execucao apos kill.
        set "ROAD_STATUS=AVISO"
    ) else (
        echo   [OK] Road.Service finalizado.
        set "ROAD_STATUS=OK"
    )
)

echo.
echo [2/3] Parando Fighting.Service...
tasklist /FI "IMAGENAME eq Fighting.Service.exe" 2>nul | find /i "Fighting.Service.exe" >nul
if %errorLevel% NEQ 0 (
    echo   Fighting.Service nao esta em execucao.
    set "FIGHT_STATUS=N/A"
) else (
    taskkill /IM Fighting.Service.exe /T /F >nul 2>&1
    timeout /t 3 /nobreak >nul
    tasklist /FI "IMAGENAME eq Fighting.Service.exe" 2>nul | find /i "Fighting.Service.exe" >nul
    if !errorLevel! EQU 0 (
        echo   [AVISO] Fighting.Service ainda em execucao apos kill.
        set "FIGHT_STATUS=AVISO"
    ) else (
        echo   [OK] Fighting.Service finalizado.
        set "FIGHT_STATUS=OK"
    )
)

echo.
echo [3/3] Parando Center.Service...
tasklist /FI "IMAGENAME eq Center.Service.exe" 2>nul | find /i "Center.Service.exe" >nul
if %errorLevel% NEQ 0 (
    echo   Center.Service nao esta em execucao.
    set "CENTER_STATUS=N/A"
) else (
    taskkill /IM Center.Service.exe /T /F >nul 2>&1
    timeout /t 3 /nobreak >nul
    tasklist /FI "IMAGENAME eq Center.Service.exe" 2>nul | find /i "Center.Service.exe" >nul
    if !errorLevel! EQU 0 (
        echo   [AVISO] Center.Service ainda em execucao apos kill.
        set "CENTER_STATUS=AVISO"
    ) else (
        echo   [OK] Center.Service finalizado.
        set "CENTER_STATUS=OK"
    )
)

echo.
echo ==============================================================
echo                 Resumo do Desligamento
echo ==============================================================
echo.
echo   Servico             Acao     Status
echo   -------             -----    ------
echo   Road.Service        STOP     !ROAD_STATUS!
echo   Fighting.Service    STOP     !FIGHT_STATUS!
echo   Center.Service      STOP     !CENTER_STATUS!
echo.
echo ==============================================================
echo.
echo Servidor desligado com sucesso.
echo.
pause