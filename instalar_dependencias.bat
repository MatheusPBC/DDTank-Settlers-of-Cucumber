@echo off
title DDTank - Instalador de Dependencias e Firewall
echo Verificando privilegios de Administrador...
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo.
    echo ==============================================================
    echo ERRO: Voce precisa rodar este script como ADMINISTRADOR!
    echo Clique nele com o botao direito e selecione "Executar como Administrador".
    echo ==============================================================
    pause
    exit
)

echo.
echo ==============================================================
echo 1. Instalando IIS (Servidor Web) e ASP.NET nativos do Windows
echo ==============================================================
echo Aguarde, esse processo pode demorar alguns minutos.
dism /Online /Enable-Feature /FeatureName:IIS-WebServerRole /All /NoRestart
dism /Online /Enable-Feature /FeatureName:IIS-WebServer /All /NoRestart
dism /Online /Enable-Feature /FeatureName:IIS-CommonHttpFeatures /All /NoRestart
dism /Online /Enable-Feature /FeatureName:IIS-ASPNET45 /All /NoRestart
dism /Online /Enable-Feature /FeatureName:IIS-NetFxExtensibility45 /All /NoRestart

echo.
echo ==============================================================
echo 2. Liberando portas no Firewall do Windows (Anti-Bloqueio)
echo ==============================================================
netsh advfirewall firewall add rule name="DDTank Web (8080)" dir=in action=allow protocol=TCP localport=8080
netsh advfirewall firewall add rule name="DDTank Login Center (9202)" dir=in action=allow protocol=TCP localport=9202
netsh advfirewall firewall add rule name="DDTank Fight (9208)" dir=in action=allow protocol=TCP localport=9208
netsh advfirewall firewall add rule name="DDTank Road/Socket (9500)" dir=in action=allow protocol=TCP localport=9500
echo Portas liberadas com sucesso!

echo.
echo ==============================================================
echo 3. SQL Server (Banco de Dados)
echo ==============================================================
echo Baixando instaladores do SQL Server Express e SSMS...
echo Isso pode demorar alguns minutos dependendo da sua conexao.

set "DOWNLOAD_DIR=%~dp0temp_installers"
if not exist "%DOWNLOAD_DIR%" mkdir "%DOWNLOAD_DIR%"

set "SQL_URL=https://go.microsoft.com/fwlink/p/?linkid=866658"
set "SSMS_URL=https://aka.ms/ssmsfullsetup"
set "SQL_FILE=%DOWNLOAD_DIR%\SQLEXPR_x64.exe"
set "SSMS_FILE=%DOWNLOAD_DIR%\SSMS-Setup.exe"

echo.
echo [1/2] Baixando SQL Server Express...
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue'; try { Invoke-WebRequest -Uri '%SQL_URL%' -OutFile '%SQL_FILE%' -MaximumRedirection 10; Write-Host '  SQL Server Express baixado com sucesso.' } catch { Write-Host '  ERRO: Falha ao baixar SQL Server Express.'; Write-Host $_.Exception.Message }"

echo.
echo [2/2] Baixando SSMS (Management Studio)...
echo Pode demorar (~1 GB)...
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue'; try { Invoke-WebRequest -Uri '%SSMS_URL%' -OutFile '%SSMS_FILE%' -MaximumRedirection 10; Write-Host '  SSMS baixado com sucesso.' } catch { Write-Host '  ERRO: Falha ao baixar SSMS.'; Write-Host $_.Exception.Message }"

echo.
echo ==============================================================
echo Downloads concluidos! Iniciando instaladores...
echo Os instaladores abrirao em janelas separadas.
echo Siga os passos de cada instalador e volte aqui quando terminar.
echo ==============================================================

if exist "%SQL_FILE%" (
    start "" "%SQL_FILE%" /QS /ACTION=Install /FEATURES=SQLEngine /INSTANCENAME=SQLEXPRESS /SQLSYSADMINACCOUNTS="BUILTIN\Administrators" /ADDCURRENTUSERASSQLADMIN /IACCEPTSQLSERVERLICENSETERMS /TCPENABLED=1 /NPENABLED=1
    echo  - SQL Server Express: instalando com opcoes padrao (modo simples)...
) else (
    echo  - AVISO: Instalador do SQL Server nao encontrado. Abra manualmente.
)

if exist "%SSMS_FILE%" (
    start "" "%SSMS_FILE%" /quiet
    echo  - SSMS: instalando em modo silencioso...
) else (
    echo  - AVISO: Instalador do SSMS nao encontrado. Abra manualmente.
)

echo.
echo Aguardando 10 segundos para os instaladores iniciarem...
timeout /t 10 /nobreak >nul

echo.
echo ==============================================================
echo Limpeza: Deseja remover os instaladores baixados para liberar espaco?
echo (Os instaladores ainda podem estar em uso. Pressione qualquer tecla
echo  apos ter certeza de que as instalacoes terminaram.)
echo ==============================================================
pause

set "KEEP_FILES=0"
set /p KEEP_FILES="Digite 1 para MANTER os arquivos ou 0 para REMOVER (padrao: 0): "
if "%KEEP_FILES%"=="1" (
    echo Arquivos mantidos em: "%DOWNLOAD_DIR%"
) else (
    rmdir /s /q "%DOWNLOAD_DIR%" 2>nul
    if exist "%DOWNLOAD_DIR%" (
        echo Alguns arquivos nao puderam ser removidos - estao em uso.
        echo Remova manualmente a pasta: "%DOWNLOAD_DIR%"
    ) else (
        echo Arquivos de instalacao removidos com sucesso.
    )
)

echo.
echo ==============================================================
echo Instalacao de dependencias do Windows completa!
echo O Servidor Web ja deve estar rodando. Teste entrando em http://localhost:8080.
echo ==============================================================
pause
