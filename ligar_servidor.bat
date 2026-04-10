@echo off
title Launcher DDTank All-In-One
echo Ligando o servidor Center...
cd Server\Center
start Center.Service.exe

echo Aguardando Center iniciar...
timeout /t 5 /nobreak
echo Ligando o servidor Fight...
cd ..\Fight
start Fighting.Service.exe

echo Aguardando Fight iniciar...
timeout /t 4 /nobreak
echo Ligando o servidor Road...
cd ..\Road
start Road.Service.exe

echo Todos os servicos estao rodando! Mantenha as janelas pretas abertas.
pause
exit
