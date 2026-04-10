@echo off
echo ==============================================================
echo AVISO DE SEGURANCA: Este script substitui senhas e chaves nos
echo arquivos de configuracao. Nunca compartilhe esses arquivos com
echo chaves reais em repositorios publicos.
echo ==============================================================
echo.
title DDTank Auto-Config
setlocal enabledelayedexpansion

echo ==============================================
echo       Configurador Automatico DDTank
echo ==============================================
echo.

set /p ip="Digite o IP do servidor (ex: 192.168.0.10 ou seu IPv4 Publico): "

echo Validando IP...
powershell -Command "if ('%ip%' -match '^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$') { exit 0 } else { exit 1 }"
if %errorLevel% NEQ 0 (
    echo.
    echo [ERRO] IP invalido: "%ip%"
    echo Use o formato IPv4 (ex: 192.168.0.10).
    pause
    exit /b 1
)

set /p senha="Digite a Senha do usuario 'sa' do SQL Server: "
if "%senha%"=="" (
    echo.
    echo [ERRO] Senha不能为空。
    pause
    exit /b 1
)

set "BASEROOT=%~dp0"
set "ERROS=0"

echo.
echo Substituindo placeholders %%SERVERIP%% / 127.0.0.1 e %%DBPASSWORD%% / tuasenha...
echo.

call :ReplaceFile "Server\Center\Center.Service.exe.config" "Center.Service"
call :ReplaceFile "Server\Fight\Fighting.Service.exe.config" "Fight.Service"
call :ReplaceFile "Server\Road\Road.Service.exe.config" "Road.Service"
call :ReplaceFile "Client\Request\Web.config" "Web.config (Request)"

echo.
echo [5/6] Modificando Client\Flash\config.xml (portas 8080)...
powershell -Command "$f='%BASEROOT%Client\Flash\config.xml'; $c=[IO.File]::ReadAllText($f,[Text.Encoding]::UTF8); $c=$c -replace 'http://127\.0\.0\.1/', 'http://%ip%:8080/' -replace 'http://127\.0\.0\.1', 'http://%ip%:8080' -replace 'http://%%SERVERIP%%/', 'http://%ip%:8080/' -replace 'http://%%SERVERIP%%', 'http://%ip%:8080'; [IO.File]::WriteAllText($f,$c,[Text.Encoding]::UTF8); exit 0"
if %errorLevel% NEQ 0 (
    echo   [ERRO] Falha ao modificar config.xml
    set /a ERROS+=1
) else (
    echo   [OK] config.xml atualizado - portas ajustadas para 8080
)

echo.
echo [6/6] Modificando Client\Flash\crossdomain.xml...
powershell -Command "$f='%BASEROOT%Client\Flash\crossdomain.xml'; $c=[IO.File]::ReadAllText($f,[Text.Encoding]::UTF8); $c=$c -replace 'domain=\"127\.0\.0\.1\"', 'domain=\"%ip%\"' -replace 'domain=\"\*\"', 'domain=\"%ip%\"'; [IO.File]::WriteAllText($f,$c,[Text.Encoding]::UTF8); exit 0"
if %errorLevel% NEQ 0 (
    echo   [ERRO] Falha ao modificar crossdomain.xml
    set /a ERROS+=1
) else (
    echo   [OK] crossdomain.xml atualizado
)

echo.
echo Atualizando caminhos absolutos no Web.config...
powershell -Command "$f='%BASEROOT%Client\Request\Web.config'; $c=[IO.File]::ReadAllText($f,[Text.Encoding]::UTF8); $c=$c -replace 'C:\\\\DDTank\\\\Client\\\\Request\\\\', '%BASEROOT%Client\\Request\\'.Replace('\','\\'); $c=$c -replace 'C:\\\\DDTank\\\\GameLog', '%BASEROOT%Server\\logs'; [IO.File]::WriteAllText($f,$c,[Text.Encoding]::UTF8); exit 0"
if %errorLevel% NEQ 0 (
    echo   [AVISO] Nao foi possivel atualizar caminhos. Ajuste manualmente se necessario.
) else (
    echo   [OK] Caminhos absolutos substituidos por caminhos relativos
)

echo.
echo Atualizando endpoint WCF do Road.Service (admingunny porta 8080)...
powershell -Command "$f='%BASEROOT%Server\Road\Road.Service.exe.config'; $c=[IO.File]::ReadAllText($f,[Text.Encoding]::UTF8); $c=$c -replace 'http://127\.0\.0\.1/admingunny/', 'http://%ip%:8080/admingunny/' -replace 'http://%%SERVERIP%%/admingunny/', 'http://%ip%:8080/admingunny/'; [IO.File]::WriteAllText($f,$c,[Text.Encoding]::UTF8); exit 0"
if %errorLevel% NEQ 0 (
    echo   [AVISO] Falha ao atualizar endpoint WCF. Verifique manualmente.
) else (
    echo   [OK] Endpoint WCF atualizado para porta 8080
)

echo.
echo ==============================================================
if !ERROS! EQU 0 (
    echo Configuracao concluida com sucesso!
) else (
    echo Configuracao concluida com !ERROS! erro(s). Verifique acima.
)
echo IPs injetados: %ip%
echo Portas: Web=8080, Center=9202, Fight=9208, Road=9500
echo ==============================================================
echo.
pause
exit /b 0

:ReplaceFile
set "FILE=%~1"
set "LABEL=%~2"
echo [%~2] Modificando %FILE%...
powershell -Command "$f='%BASEROOT%%FILE%'; $c=[IO.File]::ReadAllText($f,[Text.Encoding]::UTF8); $c=$c -replace '%%SERVERIP%%','%ip%' -replace '127\.0\.0\.1','%ip%' -replace '%%DBPASSWORD%%','%senha%' -replace 'tuasenha','%senha%'; [IO.File]::WriteAllText($f,$c,[Text.Encoding]::UTF8); exit 0"
if %errorLevel% NEQ 0 (
    echo   [ERRO] Falha ao modificar %FILE%
    set /a ERROS+=1
) else (
    echo   [OK] %FILE% atualizado
)
goto :eof