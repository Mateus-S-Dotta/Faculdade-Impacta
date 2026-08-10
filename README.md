# Como rodar o script

## PowerShell
```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

## CMD
```cmd
powershell -ExecutionPolicy Bypass -File setup.ps1
```

## Git Bash
```bash
powershell -ExecutionPolicy Bypass -File setup.ps1
```

## E reincie o VSCODE

# Para ativar o Docker do Python

```bash
./run-docker.sh
```

# Como atualizar a subTree

> Remote configurado: `RailForge` → https://github.com/Mateus-S-Dotta/RailForge.git
### Foi configurado com esse comando (Substituir RailForge para projetos futuros)
```bash
git remote add RailForge https://github.com/Mateus-S-Dotta/RailForge.git
git fetch RailForge
git subtree add --prefix=RailForge RailForge main --squash
```
> Prefix: `RailForge`

### SubTree com mudanças não aplicadas aqui:
```bash
git fetch RailForge
git subtree pull --prefix=RailForge RailForge main --squash
```

### Subir mudanças locais para subTree
```bash
git subtree push --prefix=RailForge RailForge main
```

Adicionando algo ao final para testar