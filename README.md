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
    *    **LauncherSource:** Código fonte base do Launcher Executável (Windows Forms) em C#.
*   `Database/`: Backups `.bak` do Microsoft SQL Server que devem ser restaurados para que o jogo funcione (`Db_Membership`, `Game34`, `Player34`).

## Pré-requisitos (Windows)

Para rodar este pacote sem erros, seu servidor (ou Máquina Virtual) precisará de:
- **Windows OS:** O ideal é Windows Server (ou até mesmo Windows 10/11 para fins de testes locais).
- **Microsoft SQL Server:** Express/Developer (Versão 2012 em diante) + SSMS.
- **IIS (Internet Information Services):** Com os módulos/features `ASP.NET 3.5` e `ASP.NET 4.8` instalados e a subcategoria IIS habilitada no Windows Features.
- **.NET Framework 4.8 Runtime.**

## Instalação Rápida e Auto-Script

Para minimizar os passos braçais e facilitar sua vida, eu criei duas ferramentas `.bat` na raiz dos arquivos que fazem as coisas sozinhas:

*   **`configurar.bat`:** Ao dar dois cliques, ele abre um console preto pedindo para você digitar seu **IP** e sua **Senha do banco de Dados**. Quando você dá "Enter", ele varre automaticamente os 4 arquivos de configuração pesados do jogo e arruma em menos de 1 segundo de uma vez só! Use antes de plugar tudo online.
*   **`ligar_servidor.bat`:** Inicializa os três arquivos vitais do C# (`Center`, `Fight` e `Road`) nas sequências e intervalos de tempos corretos usando apenas dois cliques.

### 1. Banco de Dados (SQL Server)
1. Instale o Microsoft SQL Server e abra o SQL Server Management Studio (SSMS).
2. Restaurar (`Restore Database`) os três arquivos presentes na pasta `Database/`: `Db_Membership`, `Game34` e `Player34`.
3. Verifique o usuário conectável (`sa`). A senha padrão configurada nos arquivos é `tuasenha`. Se você for utilizar outra, atualize nos arquivos de configuração do Server.

### 2. Website (IIS)
1. Abra o painel do IIS Manager no Windows.
2. Crie ou emponte um novo `Application/Website` para o diretório `Client/Request` na porta 80.
3. Certifique-se de que o **Application Pool** correspondente esteja usando o pipeline "Integrated" do .NET v4.0.

### 3. Liberação de Portas (Firewall)
Não importa se está rodando em VPS, AWS ou no seu computador: **Você obrigatoriamente precisa abrir** as portas Inbound/Entrada no "Windows Defender Firewall" e também no Painel de Controle de Redes do servidor em que estiver (ou roteador). O DDTank utiliza estas 4 portas de comunicação estritas:
- **Porta 80 (TCP):** Onde roda o Site e o Flash (no IIS).
- **Porta 9202 (TCP):** Login / Center Server (Mantém a sessão logada ativa).
- **Porta 9208 (TCP):** Combat / Fight Server (Trajetória da bala e física).
- **Porta 9500 (TCP):** Mundo e Socket / Road Server (Anda pela tela global).

### 4. Rodando o Jogo
Vá até a base dos arquivos extraídos e rode o arquivo **`ligar_servidor.bat`**.

Acesse `http://localhost` (ou o IP do seu servidor/IP Publico) em um browser com suporte a flash.

### 4. Gerando o Launcher (Aplicativo para os jogadores)
Para não depender de navegadores antigos com Flash, o repositório conta com um Launcher Nativo (.NET 4.0):
1. O host deve abrir a pasta `Client/LauncherSource` usando o **Visual Studio**.
2. Procurar pelas strings de IP genéricas (ou os URLs de exemplo) e alterar para o IP da sua infraestrutura.
3. Compilar (Build) o projeto.
4. Distribuir o `.exe` gerado para seus amigos jogarem com um duplo-clique.
