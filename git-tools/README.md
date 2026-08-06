# git-tools

Automação para trabalhar com o repositório principal e a subtree `RailForge`
usando Deploy Keys dedicadas, pensada pra usar em PCs que resetam do zero
a cada sessão (ex: PC de laboratório da faculdade).

Depois de configurado, `git push`, `git pull` e `git fetch` funcionam
**normalmente** — sem comando extra, sem variável de ambiente, sem
precisar logar na sua conta pessoal do GitHub.

## Antes da primeira vez (na sua máquina, uma vez só)

Você precisa de **duas** Deploy Keys diferentes — o GitHub não permite
cadastrar a mesma chave pública em dois repositórios.

1. Gere as duas chaves:
   ```bash
   ssh-keygen -t ed25519 -f ./main_deploy_key -C "pc-faculdade-main"
   ssh-keygen -t ed25519 -f ./railforge_deploy_key -C "pc-faculdade-railforge"
   ```
2. Adicione `main_deploy_key.pub` como Deploy Key (com **Allow write
   access**) no repositório **principal** → Settings → Deploy Keys.
3. Adicione `railforge_deploy_key.pub` como Deploy Key (com **Allow write
   access**) em `github.com/Mateus-S-Dotta/RailForge` → Settings → Deploy
   Keys.
4. Guarde o conteúdo das duas chaves **privadas** num gerenciador de
   senhas com campo de nota segura (ex: Bitwarden).

## Toda vez que for usar (na faculdade)

1. Clone o repositório principal normalmente (ou continue de onde parou,
   se o PC ainda não foi limpo nessa sessão).
2. Entre em `git-tools/` e cole o conteúdo de cada chave privada nos
   arquivos correspondentes (sem extensão):
   ```bash
   nano main-key        # cola a chave do repo principal
   nano railforge-key   # cola a chave do RailForge
   ```
3. Rode (só precisa uma vez por sessão/boot):
   ```bash
   chmod +x git.sh
   bash git.sh
   ```
4. A partir daí, use o Git normalmente, sem mais nada especial:
   ```bash
   git push
   git pull
   git fetch
   git subtree pull --prefix=RailForge RailForge main --squash
   git subtree push --prefix=RailForge RailForge main
   ```

## Como funciona

O `git.sh` escreve dois aliases no `~/.ssh/config` da sessão
(`github.com-main` e `github.com-railforge`), cada um apontando pra uma
chave diferente, e ajusta a URL dos remotes `origin` e `RailForge` pra
usar esses aliases. O SSH escolhe a chave certa sozinho dependendo de
qual remote você está usando — por isso não precisa mais de
`GIT_SSH_COMMAND` manual.

## Segurança

- `main-key`, `railforge-key` e `~/.ssh/config` estão no `.gitignore`
  dessa pasta e, além disso, vivem fora do repositório de qualquer forma
  (o `~/.ssh/config` fica na home do usuário, não dentro do repo).
- Cada Deploy Key só tem acesso ao repositório em que foi cadastrada —
  a chave principal não abre o RailForge, e vice-versa.
- Se desconfiar que alguma chave foi exposta, revogue em Settings →
  Deploy Keys do repositório correspondente e gere uma nova.