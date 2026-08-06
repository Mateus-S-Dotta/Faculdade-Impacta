#!/bin/bash
# Configura o Git pra usar uma Deploy Key dedicada em CADA remote (o repo
# principal "origin" e o remote "RailForge" da subtree), via aliases no
# SSH config. Depois de rodar esse script uma vez por sessão, você usa o
# Git NORMALMENTE:
#
#   git push / git pull / git fetch                → repo principal
#   git subtree pull --prefix=RailForge RailForge main --squash
#   git subtree push --prefix=RailForge RailForge main
#
# sem precisar de nenhum comando ou variável extra depois disso.
#
# USO:
#   1. Cole a chave privada da Deploy Key do repositório PRINCIPAL em
#      "main-key" (nessa pasta, sem extensão).
#   2. Cole a chave privada da Deploy Key do RailForge em "railforge-key"
#      (nessa pasta, sem extensão).
#   3. Rode: ./setup.sh
#
# IMPORTANTE: precisa ser DUAS chaves diferentes. O GitHub não deixa
# cadastrar a mesma chave pública como Deploy Key em dois repositórios.
 
set -e
 
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_KEY="$SCRIPT_DIR/main-key"
RAILFORGE_KEY="$SCRIPT_DIR/railforge-key"
 
RAILFORGE_REMOTE_NAME="RailForge"
RAILFORGE_REMOTE_PATH="Mateus-S-Dotta/RailForge"
 
for f in "$MAIN_KEY" "$RAILFORGE_KEY"; do
  if [ ! -f "$f" ]; then
    echo "Faltando: $f"
    echo "Cole o conteúdo da chave privada correspondente nesse arquivo (sem extensão) antes de rodar."
    exit 1
  fi
  chmod 600 "$f"
done
 
cd "$(git rev-parse --show-toplevel)"
 
# Descobre owner/repo do remote origin atual, funciona com URL https ou ssh
ORIGIN_URL="$(git remote get-url origin)"
MAIN_REPO_PATH="$(echo "$ORIGIN_URL" | sed -E 's#(https://github.com/|git@[^:]+:)##; s#\.git$##')"
 
mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/config
chmod 600 ~/.ssh/config
 
# Remove bloco de uma execução anterior nessa mesma sessão, pra não duplicar
sed -i '/# BEGIN git-tools/,/# END git-tools/d' ~/.ssh/config
 
cat >> ~/.ssh/config <<EOF
# BEGIN git-tools
Host github.com-main
  HostName github.com
  User git
  IdentityFile $MAIN_KEY
  IdentitiesOnly yes
 
Host github.com-railforge
  HostName github.com
  User git
  IdentityFile $RAILFORGE_KEY
  IdentitiesOnly yes
# END git-tools
EOF
 
git remote set-url origin "git@github.com-main:$MAIN_REPO_PATH.git"
 
if git remote get-url "$RAILFORGE_REMOTE_NAME" >/dev/null 2>&1; then
  git remote set-url "$RAILFORGE_REMOTE_NAME" "git@github.com-railforge:$RAILFORGE_REMOTE_PATH.git"
else
  git remote add "$RAILFORGE_REMOTE_NAME" "git@github.com-railforge:$RAILFORGE_REMOTE_PATH.git"
fi
 
echo "Configurado com sucesso."
echo "origin      -> git@github.com-main:$MAIN_REPO_PATH.git"
echo "$RAILFORGE_REMOTE_NAME  -> git@github.com-railforge:$RAILFORGE_REMOTE_PATH.git"
echo ""
echo "Agora é só usar normalmente:"
echo "  git push / git pull / git fetch"
echo "  git subtree pull --prefix=RailForge RailForge main --squash"
echo "  git subtree push --prefix=RailForge RailForge main"
 