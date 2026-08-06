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
#   3. Rode: bash setup.sh
#
# IMPORTANTE: precisa ser DUAS chaves diferentes. O GitHub não deixa
# cadastrar a mesma chave pública como Deploy Key em dois repositórios.
#
# COMPATÍVEL COM WINDOWS (Git Bash / MINGW):
#   O script detecta automaticamente se o `ssh` que vai ser usado é o
#   OpenSSH nativo do Windows (System32) ou o ssh do próprio Git for
#   Windows, e ajusta formato de caminho e permissões de acordo.

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
done

# --- Detecta ambiente Windows / qual ssh.exe será usado -------------------
IS_WINDOWS=0
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) IS_WINDOWS=1 ;;
esac

SSH_BIN="$(command -v ssh || true)"
NATIVE_WINDOWS_SSH=0
if [ "$IS_WINDOWS" -eq 1 ] && echo "$SSH_BIN" | grep -qi "Windows/System32"; then
  NATIVE_WINDOWS_SSH=1
fi

# --- Ajusta permissões dos arquivos de chave -------------------------------
set_key_permissions() {
  local key_file="$1"
  chmod 600 "$key_file" 2>/dev/null || true

  if [ "$NATIVE_WINDOWS_SSH" -eq 1 ]; then
    # chmod não tem efeito real no NTFS pro OpenSSH nativo do Windows,
    # que valida via ACL. Usa icacls pra restringir o arquivo ao usuário
    # atual, removendo herança e outros acessos.
    if command -v icacls >/dev/null 2>&1; then
      local win_path
      win_path="$(cygpath -w "$key_file" 2>/dev/null || echo "$key_file")"
      icacls "$win_path" //inheritance:r //grant:r "$USERNAME:F" >/dev/null 2>&1 || true
    fi
  fi
}

set_key_permissions "$MAIN_KEY"
set_key_permissions "$RAILFORGE_KEY"

cd "$(git rev-parse --show-toplevel)"

# Descobre owner/repo do remote origin atual, funciona com URL https ou ssh
ORIGIN_URL="$(git remote get-url origin)"
MAIN_REPO_PATH="$(echo "$ORIGIN_URL" | sed -E 's#(https://github.com/|git@[^:]+:)##; s#\.git$##')"

mkdir -p ~/.ssh
chmod 700 ~/.ssh 2>/dev/null || true
touch ~/.ssh/config
chmod 600 ~/.ssh/config 2>/dev/null || true

# Remove bloco de uma execução anterior nessa mesma sessão, pra não duplicar
sed -i '/# BEGIN git-tools/,/# END git-tools/d' ~/.ssh/config

# --- Formato do IdentityFile depende de qual ssh vai ler o config ---------
# O ssh nativo do Windows (System32) espera caminho estilo Windows
# (ex: C:/Users/...). O ssh do Git for Windows entende caminho estilo
# MSYS (ex: /c/Users/...) normalmente sem problema.
if [ "$NATIVE_WINDOWS_SSH" -eq 1 ]; then
  MAIN_KEY_FOR_CONFIG="$(cygpath -w "$MAIN_KEY")"
  RAILFORGE_KEY_FOR_CONFIG="$(cygpath -w "$RAILFORGE_KEY")"
  # normaliza barras invertidas para barras normais (ssh aceita as duas formas)
  MAIN_KEY_FOR_CONFIG="${MAIN_KEY_FOR_CONFIG//\\//}"
  RAILFORGE_KEY_FOR_CONFIG="${RAILFORGE_KEY_FOR_CONFIG//\\//}"
else
  MAIN_KEY_FOR_CONFIG="$MAIN_KEY"
  RAILFORGE_KEY_FOR_CONFIG="$RAILFORGE_KEY"
fi

cat >> ~/.ssh/config <<EOF
# BEGIN git-tools
Host github.com-main
  HostName github.com
  User git
  IdentityFile $MAIN_KEY_FOR_CONFIG
  IdentitiesOnly yes

Host github.com-railforge
  HostName github.com
  User git
  IdentityFile $RAILFORGE_KEY_FOR_CONFIG
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
if [ "$NATIVE_WINDOWS_SSH" -eq 1 ]; then
  echo "(detectado: OpenSSH nativo do Windows — permissões ajustadas via icacls, caminhos em formato Windows)"
elif [ "$IS_WINDOWS" -eq 1 ]; then
  echo "(detectado: ssh do Git for Windows)"
fi
echo "origin      -> git@github.com-main:$MAIN_REPO_PATH.git"
echo "$RAILFORGE_REMOTE_NAME  -> git@github.com-railforge:$RAILFORGE_REMOTE_PATH.git"
echo ""
echo "Agora é só usar normalmente:"
echo "  git push / git pull / git fetch"
echo "  git subtree pull --prefix=RailForge RailForge main --squash"
echo "  git subtree push --prefix=RailForge RailForge main"
