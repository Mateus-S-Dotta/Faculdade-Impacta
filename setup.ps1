Start-Process "$Env:ProgramFiles\Docker\Docker\Docker Desktop.exe"

Write-Host "Aguardando o Docker iniciar..."

# Espera até o Docker responder
while ($true) {
    docker info *> $null
    if ($LASTEXITCODE -eq 0) {
        break
    }
    Start-Sleep -Seconds 2
}

Write-Host "Docker está pronto!"

# Sobe o ambiente de desenvolvimento Python via Docker
docker compose run --rm python-dev bash
