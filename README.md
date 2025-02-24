# Documentação - Gerenciamento de Container MongoDB com Podman

## Visão Geral
Este repositório contém um script PowerShell para gerenciar um container MongoDB utilizando o Podman dentro do WSL (Windows Subsystem for Linux). Ele oferece funcionalidades como iniciar, parar, remover e atualizar o container, além de opções para backup e restauração do banco de dados.

## Requisitos
- Windows 10/11 com WSL ativado
- Distribuição Linux instalada no WSL (ex: Ubuntu)
- Podman instalado no WSL
- PowerShell 5.1 ou superior
- MongoDB executável via container

## Instalação e Configuração
1. Clone este repositório:
   ```sh
   git clone https://github.com/seu-usuario/nome-do-repositorio.git
   cd nome-do-repositorio
   ```
2. Certifique-se de que o Podman esteja instalado e funcionando dentro do WSL:
   ```sh
   podman version
   ```
3. Dê permissão de execução ao script:
   ```powershell
   Set-ExecutionPolicy Unrestricted -Scope Process
   ```

## Uso do Script
Para executar o script, abra um terminal PowerShell e navegue até a pasta do repositório. Execute:
```powershell
   .\gerenciar-mongo.ps1
```
O menu interativo será exibido, permitindo selecionar a opção desejada.

### Opções Disponíveis:
1. **Iniciar container MongoDB existente**
2. **Criar novo container MongoDB**
3. **Parar container MongoDB**
4. **Verificar status do container**
5. **Remover container**
6. **Atualizar imagem MongoDB**
7. **Restaurar banco de dados (a partir de backup.zip)**
8. **Configurar pasta backup compartilhada**
9. **Reparar Podman**
10. **Sair**

## Exemplo de Uso
Para criar um novo container MongoDB:
```powershell
   2
```
Se um container já existir, será solicitado se deseja removê-lo e recriar.

## Backup e Restauração
- O backup deve estar na pasta `~/backup` dentro do WSL.
- Para restaurar o banco de dados, forneça o ID do arquivo no Google Drive quando solicitado.

## Solução de Problemas
Se houver problemas com o Podman, utilize a opção **9 - Reparar Podman**.

## Contribuição
Pull requests são bem-vindos! Para grandes alterações, abra uma issue primeiro para discutir o que deseja modificar.

## Licença
Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

