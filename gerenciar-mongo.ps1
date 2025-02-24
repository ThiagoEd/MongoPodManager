Write-Host "### GERENCIAMENTO DE CONTAINER MONGODB COM PODMAN ###" -ForegroundColor Green 

function Show-Menu {
    Write-Host "`nO QUE DESEJA FAZER?" -ForegroundColor Yellow
    Write-Host "1 - Iniciar container MongoDB existente" 
    Write-Host "2 - Criar novo container MongoDB" 
    Write-Host "3 - Parar container MongoDB"
    Write-Host "4 - Verificar status do container"
    Write-Host "5 - Remover container"
    Write-Host "6 - Atualizar imagem MongoDB"
    Write-Host "7 - Restaurar banco de dados (a partir de backup.zip)"
    Write-Host "8 - Configurar pasta backup compartilhada"
    Write-Host "9 - Reparar Podman"
    Write-Host "10 - Sair"
    Write-Host "`nEscolha uma opção (1-9): " -NoNewline
}

function Check-Container {
    # Verifica se o container 'mongo' existe (em qualquer estado)
    $result = wsl -d Ubuntu -- bash -c "podman ps -a --format '{{.Names}}'"
    return $result -match "\bmongo\b"
}

function Start-MongoContainer {
    if (Check-Container) {
        Write-Host "`nIniciando container MongoDB..." -ForegroundColor Cyan
        wsl -d Ubuntu -- bash -c "podman start mongo"
        Write-Host "Container iniciado com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "`nContainer 'mongo' não encontrado. Crie um novo container primeiro." -ForegroundColor Red
    }
}

function Create-MongoContainer {
    if (Check-Container) {
        Write-Host "`nJá existe um container com nome 'mongo'!" -ForegroundColor Yellow
        $remove = Read-Host "Deseja remover e criar um novo? (S/N)"
        if ($remove -eq 'S' -or $remove -eq 's') {
            wsl -d Ubuntu -- bash -c "podman rm -f mongo"
        } else {
            return
        }
    }
    
    Write-Host "`nCriando novo container MongoDB..." -ForegroundColor Cyan
    # Cria o container e monta a pasta ~/backup do host no container em /backup
    wsl -d Ubuntu -- bash -c "podman run -d --name mongo -p 27017:27017 -v mongodb_data:/data/db -v ~/backup:/backup docker.io/mongo:latest"
    Write-Host "Container criado com sucesso!" -ForegroundColor Green
}

function Stop-MongoContainer {
    if (Check-Container) {
        Write-Host "`nParando container MongoDB..." -ForegroundColor Cyan
        wsl -d Ubuntu -- bash -c "podman stop mongo"
        Write-Host "Container parado com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "`nContainer 'mongo' não encontrado." -ForegroundColor Red
    }
}

function Show-ContainerStatus {
    Write-Host "`nStatus dos containers:" -ForegroundColor Cyan
    wsl -d Ubuntu -- bash -c "podman ps -a"
}

function Remove-MongoContainer {
    if (Check-Container) {
        $confirm = Read-Host "`nTem certeza que deseja remover o container 'mongo'? (S/N)"
        if ($confirm -eq 'S' -or $confirm -eq 's') {
            Write-Host "Removendo container MongoDB..." -ForegroundColor Cyan
            wsl -d Ubuntu -- bash -c "podman rm -f mongo"
            Write-Host "Container removido com sucesso!" -ForegroundColor Green
        }
    } else {
        Write-Host "`nContainer 'mongo' não encontrado." -ForegroundColor Red
    }
}

function Update-MongoImage {
    Write-Host "`nAtualizando imagem do MongoDB..." -ForegroundColor Cyan
    wsl -d Ubuntu -- bash -c "podman pull docker.io/mongo:latest"
    Write-Host "Imagem atualizada com sucesso!" -ForegroundColor Green
}

# Função de restauração usando backup ZIP do Google Drive
function Restore-Database {
    if (-not (Check-Container)) {
        Write-Host "`nO container 'mongo' não está rodando. Inicie-o primeiro!" -ForegroundColor Red
        return
    }

    Write-Host "`nDeseja baixar o backup do banco de dados? (S/N)" -ForegroundColor Yellow
    $resposta = Read-Host
    
    if ($resposta -eq 'S' -or $resposta -eq 's') {
        Write-Host "`nDigite o ID do arquivo do Google Drive (ex: 1GK3F9OwyvPWqJaErsaer7wEognq160_Y):" -ForegroundColor Cyan
        $fileID = Read-Host

        Write-Host "`nCriando diretório de backup em ~/backup..." -ForegroundColor Cyan
        wsl -d Ubuntu -- bash -c "mkdir -p ~/backup"

        Write-Host "`nBaixando o backup (arquivo ZIP)..." -ForegroundColor Cyan
        wsl -d Ubuntu -- bash -c "wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=$fileID' -O ~/backup/backup.zip"

        Write-Host "`nExtraindo o backup..." -ForegroundColor Cyan
        wsl -d Ubuntu -- bash -c "unzip -o ~/backup/backup.zip -d ~/backup"
    }

    Write-Host "`nRestaurando banco de dados..." -ForegroundColor Cyan
    # Adiciona o parâmetro --gzip e aponta para o diretório correto (/backup/tapps-bets5587)
    wsl -d Ubuntu -- bash -c "podman exec -i mongo mongorestore --drop --gzip --dir /backup/"
    Write-Host "Restauração concluída com sucesso!" -ForegroundColor Green
}


function Download-File {
    Write-Host "`nDigite a URL do arquivo que deseja baixar:" -ForegroundColor Yellow
    $url = Read-Host
    Write-Host "`nBaixando arquivo..." -ForegroundColor Cyan
    wsl -d Ubuntu -- bash -c "wget '$url'"
    Write-Host "Download concluído com sucesso!" -ForegroundColor Green
}

function Setup-BackupFolder {
    Write-Host "`nConfigurando pasta de backup compartilhada..." -ForegroundColor Cyan
    # Cria a pasta ~/backup no WSL (no diretório home do usuário)
    wsl -d Ubuntu -- bash -c "mkdir -p ~/backup"
    Write-Host "Pasta de backup criada em ~/backup." -ForegroundColor Green
    Write-Host "`nDeseja recriar o container MongoDB com montagem da pasta de backup? (S/N)"
    $resp = Read-Host
    if ($resp -eq 'S' -or $resp -eq 's') {
        if (Check-Container) {
            Write-Host "Removendo container existente..." -ForegroundColor Cyan
            wsl -d Ubuntu -- bash -c "podman rm -f mongo"
        }
        Write-Host "Criando container MongoDB com montagem da pasta de backup..." -ForegroundColor Cyan
        wsl -d Ubuntu -- bash -c "podman run -d --name mongo -p 27017:27017 -v mongodb_data:/data/db -v ~/backup:/backup docker.io/mongo:latest"
        Write-Host "Container criado com sucesso com a pasta de backup compartilhada!" -ForegroundColor Green
    } else {
        Write-Host "Operação cancelada. A pasta de backup foi criada, mas o container não foi modificado." -ForegroundColor Yellow
    }
}

function RepairPodman {
    Write-Host "`nIniciando processo de recuperação do Podman..." -ForegroundColor Cyan
    
    # Tenta parar todos os containers primeiro
    Write-Host "Parando todos os containers..." -ForegroundColor Yellow
    wsl -d Ubuntu -- bash -c "podman stop -a"
    
    # Executa limpeza do sistema Podman
    Write-Host "Executando limpeza do sistema Podman..." -ForegroundColor Yellow
    wsl -d Ubuntu -- bash -c "podman system reset --force"
    
    # Executa migração do sistema
    Write-Host "Executando migração do sistema Podman..." -ForegroundColor Yellow
    wsl -d Ubuntu -- bash -c "podman system migrate"
    
    # Verifica e repara volumes
    Write-Host "Verificando volumes..." -ForegroundColor Yellow
    wsl -d Ubuntu -- bash -c "podman volume prune -f"
    
    # Tenta reiniciar o container MongoDB
    if (Check-Container) {
        Write-Host "Tentando reiniciar o container MongoDB..." -ForegroundColor Yellow
        Stop-MongoContainer
        Start-MongoContainer
        Show-ContainerStatus
        
        Write-Host "`nO container está rodando corretamente? (S/N)" -ForegroundColor Cyan
        $resp = Read-Host
        
        if ($resp -eq 'N' -or $resp -eq 'n') {
            Write-Host "`nDeseja remover e recriar o container? (S/N)" -ForegroundColor Yellow
            $remove = Read-Host
            
            if ($remove -eq 'S' -or $remove -eq 's') {
                Write-Host "Removendo container atual..." -ForegroundColor Yellow
                Remove-MongoContainer
                
                Write-Host "Recriando container..." -ForegroundColor Yellow
                Create-MongoContainer
                
                Write-Host "`nVerificando status final..." -ForegroundColor Yellow
                Show-ContainerStatus
            }
        }
    } else {
        Write-Host "`nNenhum container MongoDB encontrado. Deseja criar um novo? (S/N)" -ForegroundColor Yellow
        $create = Read-Host
        
        if ($create -eq 'S' -or $create -eq 's') {
            Create-MongoContainer
        }
    }
    
    Write-Host "`nProcesso de recuperação concluído!" -ForegroundColor Green
}


# Loop principal do menu
do {
    Show-Menu
    $opcao = Read-Host

    switch ($opcao) {
        "1" { Start-MongoContainer }
        "2" { Create-MongoContainer }
        "3" { Stop-MongoContainer }
        "4" { Show-ContainerStatus }
        "5" { Remove-MongoContainer }
        "6" { Update-MongoImage }
        "7" { Restore-Database }
        "8" { Setup-BackupFolder }
        "9" { RepairPodman }
        "10" { Write-Host "`nSaindo..." -ForegroundColor Yellow; break }
        default { Write-Host "`nOpção inválida!" -ForegroundColor Red }
    }

    if ($opcao -ne "9") {
        Write-Host "`nPressione Enter para continuar..."
        $null = Read-Host
    }
} while ($opcao -ne "10")
