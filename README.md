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

Para minimizar os passos braçais e facilitar sua vida, eu criei três ferramentas `.bat` na raiz dos arquivos que agem como magia:

*   **`instalar_dependencias.bat`:** **(Execute como Administrador)** Esse script fará todo o trabalho chato do Windows. Ele instala o painel e os recursos do **IIS e ASP.NET** ativando recursos do servidor local, abre as 4 **portas no Firewall** sozinhas e já abre no seu navegador o site de download das dependências do SQL Server. Comece por ele!
*   **`configurar.bat`:** Ao dar dois cliques, ele abre um console preto pedindo para você digitar seu **IP** e sua **Senha do banco de Dados**. Quando você dá "Enter", ele varre automaticamente os arquivos de configuração do jogo e formata em menos de 1 segundo de uma vez só!
*   **`ligar_servidor.bat`:** Inicializa os três arquivos vitais do C# (`Center`, `Fight` e `Road`) nas sequências e intervalos de tempos corretos usando apenas um clique duplo.

### 1. Banco de Dados (SQL Server)
1. Instale o Microsoft SQL Server e abra o SQL Server Management Studio (SSMS).
2. Restaurar (`Restore Database`) os três arquivos presentes na pasta `Database/`: `Db_Membership`, `Game34` e `Player34`.
3. Verifique o usuário conectável (`sa`). A senha padrão configurada nos arquivos é `tuasenha`. Se você for utilizar outra, atualize nos arquivos de configuração do Server.

### 2. Website (IIS)
1. Abra o painel do IIS Manager no Windows.
2. Crie ou emponte um novo `Application/Website` para o diretório `Client/Request` **na porta 8080**. (A porta 80 costuma ser bloqueada por provedores de internet residenciais).
3. Certifique-se de que o **Application Pool** correspondente esteja usando o pipeline "Integrated" do .NET v4.0.

### 3. Liberação de Portas (Rede e Firewall)
Para hospedar na sua própria rede, escolha uma das opções abaixo:

**Opção 1: Abrir portas no Roteador (Público)**
Você obrigatoriamente precisa abrir as portas Inbound/Entrada no "Windows Defender Firewall" (o `instalar_dependencias.bat` faz isso) e também fazer o "Port Forwarding" no seu Roteador para o IPv4 do seu PC. O DDTank requer a liberação destas 4 portas de comunicação TCP:
- **Porta 8080 (TCP):** Onde roda o Site e o Flash (no IIS). Padrão alterado para evitar bloqueios de provedor.
- **Porta 9202 (TCP):** Login / Center Server (sessão logada).
- **Porta 9208 (TCP):** Combat / Fight Server (Trajetória da bala e física).
- **Porta 9500 (TCP):** Mundo e Socket / Road Server (Move pela tela).

**Opção 2: Jogar por VPN Virtual (Recomendada para amigos / Hamachi / Radmin VPN)**
Se você não consegue ou não tem acesso ao roteador (CGNAT), basta criar uma rede no Radmin VPN ou Hamachi e pedir para seus amigos entrarem. O seu IP "Local" passa a ser o IP do Hamachi (ex: `26.x.x.x`). Como a rede virtual local não tem bloqueios externos, o hoster não precisa mexer no roteador. Coloque o IPv4 da VPN no `configurar.bat`!

### 4. Rodando o Jogo
Vá até a base dos arquivos extraídos e rode o arquivo **`ligar_servidor.bat`**.

Acesse `http://localhost:8080` (ou o IP do seu servidor/ Hamachi) em um browser com suporte a flash.

### 4. Gerando o Launcher (Aplicativo para os jogadores)
Para não depender de navegadores antigos com Flash, o repositório conta com um Launcher Nativo (.NET 4.0):
1. O host deve abrir a pasta `Client/LauncherSource` usando o **Visual Studio**.
2. Procurar pelas strings de IP genéricas (ou os URLs de exemplo) e alterar para o IP da sua infraestrutura.
3. Compilar (Build) o projeto.
4. Distribuir o `.exe` gerado para seus amigos jogarem com um duplo-clique.
