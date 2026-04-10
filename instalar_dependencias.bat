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
echo A unica coisa que precisa ser instalada manualmente eh o Microsoft SQL Server.
echo Pressione qualquer tecla para abrir as paginas oficiais de download do SQL Express e do SSMS.
pause >nul
start https://go.microsoft.com/fwlink/p/?linkid=866658
start https://aka.ms/ssmsfullsetup

echo.
echo ==============================================================
echo Instalação de dependências do Windows completa!
echo O Servidor Web já deve estar rodando. Teste entrando em http://localhost:8080.
echo ==============================================================
pause
