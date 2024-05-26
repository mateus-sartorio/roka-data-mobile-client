<p align="center">
  <img src="https://skillicons.dev/icons?i=flutter,dart" /> <br/>
  <a href="https://github.com/mateus-sartorio/roka-data-mobile-client"><kbd>🔵 GitHub</kbd></a>
</p>

# ♻️ Roka Data

### Sistema unificado de dados para o Projeto Roka.

<br/>

## 🔥 Funcionalidades

### 🏡 Gerencie cadastro dos moradores

<div align="center">
  <img src="./assets/documentation/create-resident.png" alt="" width="40%"/>
  <img src="./assets/documentation/all-residents.png" alt="" width="40%"/>
</div>
<br/>

### 🛍️ Gerencie a coleta de resíduos

<div align="center">
  <img src="./assets/documentation/day-collects.png" alt="" width="40%"/>
  <img src="./assets/documentation/all-collects.png" alt="" width="40%"/>
</div>

### 💰 Gerencie a distribuição da moeda social

<div align="center">
  <img src="./assets/documentation/create-currency-receipts.png" alt="" width="40%"/>
  <img src="./assets/documentation/all-currency-receipts.png" alt="" width="40%"/>
</div>

<br>

## 🍄 Filosofia

Este projeto destina-se a ser simples e fácil de usar. As funcionalidades são mantidas mínimas, mas refinadas.

<br/>

## ⚙️ Configurar e executar localmente

### Pré-requisitos:

- Flutter runtime
- Android SDK
- Emulador de Android
- Servidor backend rodando

Antes de começar, certifique-se que tenha todos os pré-requisitos para rodar o projeto.

Para checar a versão do `Flutter` instalada em sua máquina, execute o seguinte comando:

```bash
flutter --version
```

Caso sua versão não seja a 16, recomenda-se utilizar o `nvm`, que permite instalar e gerenciar várias versões do Node.js em sua máquina ([Repositório com instruções para instalação](https://github.com/nvm-sh/nvm)).

Para o Docker, instruções de instalação para cada sistema operacional são encontradas em sua [documentação oficial](https://docs.docker.com/engine/install/).

> [!TIP]
> Ao instalar dependências do Node.js e inicializar os servidores nativamente, sempre certifique-se de estar usando a versão 16 do Node.js
> 
> Para verificar qual versão do Node.js está usando, execute `node --version`
> 
> Caso esteja usando `nvm`, pode-se selectionar a versão 16 do Node.js com o comando `nvm use 16`
> 
> Com o `nvm` é possível também instalar a versão 16 do Node.js, caso ainda não esteja instalada, com o comando `nvm install 16`

### Rodando a aplicação

Clone o repositório localmente, usando `--recuse-submodules`, para garantir que o os repositórios do frontend e do backend sejam clonados corretamente. Em seguida, entre no diretório do respositório clonado:

```bash
git clone https://github.com/mateus-sartorio/corenotes
cd corenotes
```

Além disso, é necessário criar um aquivo de variáveis de ambiente (`.env`) no diretório raíz do backend para configurar as URLs de conexão com o banco de dados:

```bash
cd corenotes-backend
touch .env
```

No arquivo criado, crie as seguintes variáveis ambientes (`baseUrl` é utilizada pela aplicação em funcionamento normal):

```json
{
  baseUrl="url para banco de dados"
}
```

To target local server, run:
```bash
flutter run --dart-define-from-file=lib/configuration/env/dev.json
```

To target AWS server, run:
```bash
flutter run --dart-define-from-file=lib/configuration/env/prod.json
```

To configure icons and splash art, run:
```bash
flutter pub run flutter_launcher_icons
```

Caso prefira rodar a aplicação nativamente, na pasta raíz do backend, instale as dependências do Node.js e depois inicialize o servidor, com os seguintes comandos:

```bash
flutter pub get
flutter run
```

Caso queira gerar uma build de produção para o frontend, execute em sua pasta raíz:

```bash
flutter build android --dart-define-from-file=lib/configuration/env/prod.json
```

<br>

## ⚠️ Limitatações

- O sistema ainda não possui um sistema de cadastro e login de usuários.


## 🐞 Bugs conhecidos

- Dados podem não ser sincronizados com servidor as vezes, e dados que falham em ser sincronizados são descartados.

<br/>

## ⚖️ Licença:

Este programa é um software livre: você pode redistribuí-lo e/ou modificá-lo sob os termos da Licença Pública Geral GNU, conforme publicada pela Free Software Foundation; seja a versão 3 da Licença, ou (a seu critério) qualquer versão posterior.

Este programa é distribuído na esperança de que seja útil, mas SEM QUALQUER GARANTIA; sem mesmo a garantia implícita de COMERCIABILIDADE ou ADEQUAÇÃO A UMA FINALIDADE ESPECÍFICA. Consulte a Licença Pública Geral GNU para mais detalhes.

Você deveria ter recebido uma cópia da Licença Pública Geral GNU juntamente com este programa. Se não recebeu, consulte [www.gnu.org/licenses/](https://www.gnu.org/licenses/).

Este programa é lançado sob a licença GNU GPL v3+.