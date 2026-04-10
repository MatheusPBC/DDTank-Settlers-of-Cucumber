@echo off
title DDTank Auto-Config
echo ==============================================
echo       Configurador Automatico DDTank
echo ==============================================
echo.
set /p ip="Digite o IP do servidor (ex: 192.168.0.10 ou seu IPv4 Publico): "
set /p senha="Digite a Senha do usuario 'sa' do SQL Server: "

echo.
echo Modificando Center.Service...
powershell -Command "(Get-Content 'Server\Center\Center.Service.exe.config') -replace '127\.0\.0\.1', '%ip%' -replace 'tuasenha', '%senha%' | Set-Content 'Server\Center\Center.Service.exe.config' -Encoding UTF8"

echo Modificando Fight.Service...
powershell -Command "(Get-Content 'Server\Fight\Fighting.Service.exe.config') -replace '127\.0\.0\.1', '%ip%' -replace 'tuasenha', '%senha%' | Set-Content 'Server\Fight\Fighting.Service.exe.config' -Encoding UTF8"

echo Modificando Road.Service...
powershell -Command "(Get-Content 'Server\Road\Road.Service.exe.config') -replace '127\.0\.0\.1', '%ip%' -replace 'tuasenha', '%senha%' | Set-Content 'Server\Road\Road.Service.exe.config' -Encoding UTF8"

echo Modificando Web.config do Client...
powershell -Command "(Get-Content 'Client\Request\Web.config') -replace '127\.0\.0\.1', '%ip%' -replace 'tuasenha', '%senha%' | Set-Content 'Client\Request\Web.config' -Encoding UTF8"

echo.
echo IPs e Senhas injetados com sucesso!
pause
