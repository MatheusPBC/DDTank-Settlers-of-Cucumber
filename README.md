# DDTank Settlers of Cucumber

Este repositório contém a versão pré-configurada e extraída dos arquivos de servidor, cliente e banco de dados para a versão **4.1 do DDTank**. Toda a estrutura já foi adaptada para rodar nativamente em servidores Windows.

## Estrutura de Pastas

*   `Server/`: Contém os binários compilados em **C# (.NET Framework 4.7.2/4.8)** divididos em 3 serviços:
    *   **Center:** Gerenciador central de salas e login.
    *   **Fight:** Backend de lógica de combate e física de projéteis.
    *   **Road:** Servidor primário do jogo (Socket/Tcp).
*   `Client/`: Arquivos que devem ser hospedados no IIS.
    *    **Request:** Backend web-based (.NET) utilizado para gerenciar requests HTTP e painéis do jogo.
    *    **Flash:** Os arquivos nativos Flash (SWF), UI, Imagens e resources servidos pelo navegador.
*   `Database/`: Backups `.bak` do Microsoft SQL Server que devem ser restaurados para que o jogo funcione (`Db_Membership`, `Game34`, `Player34`).

## Pré-requisitos (Windows)

Para rodar este pacote sem erros, seu servidor (ou Máquina Virtual) precisará de:
- **Windows OS:** O ideal é Windows Server (ou até mesmo Windows 10/11 para fins de testes locais).
- **Microsoft SQL Server:** Express/Developer (Versão 2012 em diante) + SSMS.
- **IIS (Internet Information Services):** Com os módulos/features `ASP.NET 3.5` e `ASP.NET 4.8` instalados e a subcategoria IIS habilitada no Windows Features.
- **.NET Framework 4.8 Runtime.**

## Instalação Rápida

### 1. Banco de Dados (SQL Server)
1. Instale o Microsoft SQL Server e abra o SQL Server Management Studio (SSMS).
2. Restaurar (`Restore Database`) os três arquivos presentes na pasta `Database/`: `Db_Membership`, `Game34` e `Player34`.
3. Verifique o usuário conectável (`sa`). A senha padrão configurada nos arquivos é `tuasenha`. Se você for utilizar outra, atualize nos arquivos de configuração do Server.

### 2. Website (IIS)
1. Abra o painel do IIS Manager no Windows.
2. Crie ou emponte um novo `Application/Website` para o diretório `Client/Request` na porta 80.
3. Certifique-se de que o **Application Pool** correspondente esteja usando o pipeline "Integrated" do .NET v4.0.

### 3. Rodando o Jogo
Navegue até as pastas dentro de `Server/` e inicie os executáveis na seguinte ordem:
1. `Center.Service.exe`
2. `Fighting.Service.exe`
3. `Road.Service.exe`

Acesse `http://localhost` (ou o IP do seu servidor) em um browser com suporte a flash.
