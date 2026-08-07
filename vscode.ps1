code --install-extension moderndraculalowcontrast.modern-dracula-low-contrast
code --install-extension ms-python.python

# Caminho da pasta e do arquivo
$pastaUser = "$env:APPDATA\Code\User"
$arquivoSettings = "$pastaUser\settings.json"
$arquivoKeybindings = "$pastaUser\keybindings.json"

# Cria a pasta caso não exista
if (!(Test-Path $pastaUser)) {
    New-Item -ItemType Directory -Path $pastaUser -Force
}

# Conteúdo do settings.json
$settingsContent = @'
{
    "editor.insertSpaces": false,
    "editor.tabSize": 4,
    "terminal.integrated.defaultProfile.windows": "Git Bash",
    "workbench.editorAssociations": {
        "*.xml": "default",
    },
    "js/ts.updateImportsOnFileMove.enabled": "always",
    "editor.formatOnSave": true,
    "workbench.colorTheme": "Modern Dracula Low Contrast",
}
'@

# Conteúdo do keybindings.json
$keybindingsContent = @'
[
  {
    "key": "ctrl+n",
    "command": "explorer.newFile",
    "when": "explorerViewletVisible && filesExplorerFocus",
  },
  {
    "key": "ctrl+f",
    "command": "explorer.newFolder",
    "when": "explorerViewletVisible && filesExplorerFocus",
  },
  {
    "key": "ctrl+shift+t",
    "command": "workbench.action.terminal.focus",
    "when": "!terminalFocus",
  },
  {
    "key": "ctrl+shift+t",
    "command": "workbench.action.focusActiveEditorGroup",
    "when": "terminalFocus",
  },
  {
    "key": "ctrl+r",
    "command": "renameFile",
    "when": "explorerViewletVisible && filesExplorerFocus",
  },
  {
    "key": "ctrl+tab",
    "command": "workbench.action.terminal.focusNext",
    "when": "terminalFocus"
  }
]
'@

# Escreve os arquivos (sobrescreve se já existir)
Set-Content -Path $arquivoSettings -Value $settingsContent -Encoding UTF8
Set-Content -Path $arquivoKeybindings -Value $keybindingsContent -Encoding UTF8

Write-Host "Arquivos criados com sucesso em $pastaUser"

# Caminho do arquivo .bash_profile
$arquivoBashProfile = "$env:USERPROFILE\.bash_profile"

# Conteúdo do .bash_profile
$bashProfileContent = @'
gpush() {
    if [ $# -lt 1 ]; then
        echo "Uso: gpush \"mensagem\""
        return 1
    fi

    git add . &&
    git commit -m "$1" &&
    git push origin "$(git branch --show-current)"
}
'@

# Escreve o .bash_profile (sobrescreve se já existir)
[System.IO.File]::WriteAllText($arquivoBashProfile, $bashProfileContent, (New-Object System.Text.UTF8Encoding $false))

Write-Host "Arquivo .bash_profile criado com sucesso em $arquivoBashProfile"
