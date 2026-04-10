# DDTank Settlers of Cucumber

Este repositório contém a versão pré-configurada e extraída dos arquivos de servidor, cliente e banco de dados para a versão **4.1 do DDTank**. Toda a estrutura já foi adaptada para rodar nativamente em servidores Windows.

> **⚠️ Antes de começar:** Os backups do banco de dados (`.bak`) **não são versionados** no repositório. Baixe-os do [Release v4.1.0](https://github.com/MatheusPBC/DDTank-Settlers-of-Cucumber/releases/tag/v4.1.0) e coloque na pasta `Database/`.

## Estrutura de Pastas

*   `Server/`: Contém os binários compilados em **C# (.NET Framework 4.7.2/4.8)** divididos em 3 serviços:
    *   **Center:** Gerenciador central de salas e login (porta 9202).
    *   **Fight:** Backend de lógica de combate e física de projéteis (porta 9208).
    *   **Road:** Servidor primário do jogo — Socket/TCP (porta 9500).
*   `Client/`: Arquivos que devem ser hospedados no IIS (porta 8080).
    *    **Request:** Backend web-based (.NET) utilizado para gerenciar requests HTTP e painéis do jogo.
    *    **Flash:** Os arquivos nativos Flash (SWF), UI, Imagens e resources servidos pelo navegador.
    *    **LauncherSource:** Código fonte base do Launcher Executável (Windows Forms) em C#.
*   `Database/`: Backups `.bak` do Microsoft SQL Server que devem ser restaurados para que o jogo funcione (`Db_Membership`, `Game34`, `Player34`). **Os arquivos `.bak` baixam-se do [Release](https://github.com/MatheusPBC/DDTank-Settlers-of-Cucumber/releases/tag/v4.1.0)** — não são versionados no git.

## Pré-requisitos (Windows)

Para rodar este pacote sem erros, seu servidor (ou Máquina Virtual) precisará de:
- **Windows OS:** O ideal é Windows Server (ou até mesmo Windows 10/11 para fins de testes locais).
- **Microsoft SQL Server:** Express/Developer (Versão 2012 em diante) + SSMS.
- **IIS (Internet Information Services):** Com os módulos/features `ASP.NET 3.5` e `ASP.NET 4.8` instalados e a subcategoria IIS habilitada no Windows Features.
- **.NET Framework 4.8 Runtime.**

## Instalação Rápida e Auto-Script

Para minimizar os passos braçais e facilitar sua vida, existem **4 scripts `.bat`** na raiz do repositório:

### `instalar_dependencias.bat` — Setup do ambiente
**(Execute como Administrador)** Instala automaticamente:
1. Recursos do **IIS e ASP.NET** via DISM
2. Liberação das **4 portas TCP** no Firewall (8080, 9202, 9208, 9500)
3. **Download automático** do SQL Server Express e SSMS via PowerShell (com redirect-follow e TLS 1.2)
4. Instalação semi-silenciosa do SQL Express (`/QS` com TCP+Named Pipes habilitados)
5. Instalação silenciosa do SSMS (`/quiet`)
6. **Limpeza interativa** dos instaladores baixados (~1.2 GB)

### `configurar.bat` — Configuração de IP e senha
Ao executar, o script pede seu **IP** e **Senha do banco** e substitui automaticamente em **todos os 6 arquivos de configuração**:
- `Server/Center/Center.Service.exe.config`
- `Server/Fight/Fighting.Service.exe.config`
- `Server/Road/Road.Service.exe.config`
- `Client/Request/Web.config`
- `Client/Flash/config.xml` (com portas 8080)
- `Client/Flash/crossdomain.xml`

O script também atualiza o **endpoint WCF** do Road e ajusta **caminhos absolutos** para relativos. Possui **validação de IPv4** e é **idempotente** (pode ser executado mais de uma vez).

> ⚠️ **Segurança:** Nunca compartilhe arquivos de configuração com senhas ou chaves reais em repositórios públicos. Os arquivos versionados usam placeholders (`tuasenha`, `YOUR_RSA_PRIVATE_KEY_HERE`, etc.).

### `ligar_servidor.bat` — Inicialização
Inicializa os 3 serviços na ordem correta (Center → Fight → Road) com:
- Verificação de privilégios de administrador
- Verificação de que cada processo realmente iniciou (`tasklist`)
- **Health check** nas portas 9202, 9208 e 9500 via `Test-NetConnection` (timeout de 60s por serviço)
- Se Center falhar, **interrompe** e não inicia os demais
- Tabela resumo com status de cada serviço

### `desligar_servidor.bat` — Desligamento graceful
Para os serviços na ordem reversa (Road → Fight → Center):
- Verificação de privilégios de administrador
- `taskkill /T /F` com verificação posterior
- Status: **OK** (parou), **AVISO** (ainda rodando), **N/A** (não estava rodando)
- Tabela resumo final

### 1. Banco de Dados (SQL Server)
1. Baixe os 3 arquivos `.bak` do [Release v4.1.0](https://github.com/MatheusPBC/DDTank-Settlers-of-Cucumber/releases/tag/v4.1.0) e coloque na pasta `Database/`.
2. Execute `instalar_dependencias.bat` como Administrador para instalar IIS, Firewall e baixar o SQL Server automaticamente.
3. Após a instalação do SQL Server, abra o **SQL Server Management Studio (SSMS)**.
4. Restaure (`Restore Database`) os três arquivos: `Db_Membership`, `Game34` e `Player34`.
5. Verifique o usuário conectável (`sa`). A senha padrão nos arquivos é `tuasenha`. Se for utilizar outra, rode `configurar.bat`.

### 2. Website (IIS)
1. Abra o painel do IIS Manager no Windows.
2. Crie ou emponte um novo `Application/Website` para o diretório `Client/Request` **na porta 8080**. (A porta 80 costuma ser bloqueada por provedores de internet residenciais).
3. Certifique-se de que o **Application Pool** correspondente esteja usando o pipeline "Integrated" do .NET v4.0.
4. Também hospede `Client/Flash` no IIS (mesma porta 8080 ou como aplicação filha).

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
Execute **`ligar_servidor.bat`** como Administrador. O script verifica se cada serviço subiu corretamente e checa as portas automaticamente.

Acesse `http://localhost:8080` (ou o IP do seu servidor/ Hamachi) em um browser com suporte a flash.

Para desligar, execute **`desligar_servidor.bat`**.

### 5. Gerando o Launcher (Aplicativo para os jogadores)
Para não depender de navegadores antigos com Flash, o repositório conta com um Launcher Nativo (.NET 4.0):
1. O host deve abrir a pasta `Client/LauncherSource` usando o **Visual Studio**.
2. Procurar pelas strings de IP genéricas (ou os URLs de exemplo) e alterar para o IP da sua infraestrutura.
3. Compilar (Build) o projeto.
4. Distribuir o `.exe` gerado para seus amigos jogarem com um duplo-clique.

## Portas e Serviços

| Porta | Serviço | Protocolo | Descrição |
|-------|---------|-----------|-----------|
| 8080 | IIS (Website) | HTTP | Site, Flash e Request API |
| 9202 | Center.Service | TCP | Login e gerenciamento de salas |
| 9208 | Fighting.Service | TCP | Combate e física de projéteis |
| 9500 | Road.Service | TCP | Mundo e socket do jogo |
| 2008 | Center WCF | HTTP | Serviço WCF interno do Center |
| 2009 | Center WCF | net.tcp | Endpoint WCF interno |

## Segurança

Os arquivos de configuração versionados usam **placeholders** para dados sensíveis:
- Senha do SQL Server: `tuasenha` → substituída via `configurar.bat`
- Chaves RSA: `YOUR_RSA_PRIVATE_KEY_HERE` → substitua manualmente se necessário
- Chaves de login/charge: `YOUR_LOGIN_KEY_HERE`, `YOUR_CHARGE_KEY_HERE`
- `customErrors` configurado como `RemoteOnly` (não expõe erros para usuários finais)
- `compilation debug="false"` (produção)
- `crossdomain.xml` restrito ao IP do servidor (não wildcard `*`)

**Nunca** commite arquivos `.config` ou `Web.config` com senhas/chaves reais.