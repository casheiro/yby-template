# CLAUDE.md

Este arquivo fornece orientação ao Claude Code (claude.ai/code) ao trabalhar com código neste repositório.

## Sobre o Projeto

Este é um projeto de infraestrutura Kubernetes usando GitOps com K3s, Argo CD e observabilidade via Datadog. O objetivo é criar um cluster leve, escalável e totalmente versionado.

## Estrutura Planejada

O projeto segue uma arquitetura GitOps com a seguinte estrutura:

- `cluster-config/` - Configurações declarativas usando Kustomize
  - `base/` - Configurações base para componentes (Traefik, Argo CD, Datadog, Sealed Secrets, MinIO)
- `manifests/` - Recursos customizados e ingressos
- `workflows/` - Pipelines CI com Argo Workflows
- `secrets/` - Sealed Secrets criptografados
- `charts/` - Charts Helm customizados (opcional)
- `setup/` - Scripts de bootstrap e instalação
- `local/` - Configurações para desenvolvimento local
  - `k3d-config.yaml` - Configuração do cluster k3d
  - `docker-compose.yaml` - Serviços auxiliares
  - `datadog-mock.conf` - Simulação do Datadog Agent

## Stack Principal

- **K3s** - Distribuição Kubernetes leve
- **Argo CD** - GitOps e deploy automatizado
- **Datadog** - Observabilidade e métricas
- **Sealed Secrets** - Gerenciamento seguro de secrets
- **MinIO** - Armazenamento compatível com S3
- **Argo Workflows** - CI/CD dentro do cluster

## Comandos de Desenvolvimento

O projeto usa Makefile para padronizar comandos. Comandos principais:

### Setup e Configuração
- `make tools-check` - Verificar todas as ferramentas instaladas
- `make tools-install` - Instalar apenas ferramentas faltantes
- `cp .env.example .env` - Criar arquivo de configuração local
- `./setup/bootstrap.sh --check-only` - Verificar detalhadamente o estado das ferramentas
- `./setup/bootstrap.sh` - Executar bootstrap completo manualmente

### Cluster Local
- `make cluster-up` - Criar e iniciar cluster k3d local
- `make cluster-down` - Remover cluster k3d local
- Use `kubectl config use-context <context>` para mudar contextos

### Deploy e Desenvolvimento
- `make dev` - Iniciar ambiente completo (cluster + Argo CD + Headlamp)
- `make helm-bootstrap` - Aplicar charts Helm no cluster
- `make deploy-remote` - Deploy completo em VPS remoto

### Argo CD
- `make bootstrap-argocd` - Instalar Argo CD no cluster
- `make get-argocd-password` - Obter senha inicial do Argo CD
- `make save-argocd-password` - Salvar senha em .env.local
- `make port-forward-argocd` - Port forward para Argo CD (localhost:8080)

### Monitoramento e Debug
- `make status` - Verificar status do cluster e aplicações
- `make logs` - Visualizar logs das aplicações principais
- `make port-forward-minio` - Port forward para MinIO (localhost:9000)

### Testes e Validação
- `make helm-validate` - Validar manifests Helm com kubeconform
- `make helm-render` - Renderizar templates Helm para inspeção
- `./scripts/test-full-stack-cycle.sh` - Teste de ciclo completo da stack
- `kubectl apply --dry-run=client -k cluster-config/base/` - Validação manual
- `kustomize build cluster-config/base/` - Verificar build do Kustomize

### Limpeza
- `make clean` - Limpeza completa (cluster + serviços + imagens)

## Ambiente Local

### Ferramentas Obrigatórias (Instalação Manual)
- **Docker** - Container runtime (obrigatório, deve estar rodando)
- **Git** - Controle de versão (obrigatório para clonar repositório)
- **Make** - Build automation tool (obrigatório para Makefile)
- **GNU Coreutils** - Ferramentas básicas (curl, awk, sed, grep, find, base64)
- **Bash 4.0+** - Shell para execução dos scripts

### Ferramentas Auto-Instaladas pelo Bootstrap
O script `./setup/bootstrap.sh` detecta e instala automaticamente:

#### Categoria Kubernetes
- **kubectl** - CLI do Kubernetes  
- **k3d** - Clusters Kubernetes locais com Docker
- **Helm** - Gerenciador de pacotes Kubernetes

#### Categoria GitOps e Segurança  
- **argocd CLI** - Para gerenciar aplicações GitOps
- **kubeseal** - Para criptografar secrets com Sealed Secrets

#### Categoria Processamento e Validação
- **kustomize** - Customização declarativa de recursos K8s
- **yq** - Processador YAML (equivalente ao jq para YAML)
- **jq** - Processador JSON  
- **kubeconform** - Validação moderna de manifests Kubernetes (sucessor do kubeval)

#### Categoria Armazenamento
- **MinIO client (mc)** - Para gerenciar armazenamento S3 compatível

### Sistema Suportado
- **Ubuntu 24.04** (testado e recomendado)
- **Debian/Ubuntu** com apt (suportado)
- **macOS** com Homebrew (suportado)  
- **Distribuições Linux** com package managers padrão
- **Arquitetura**: x86_64/amd64, ARM64/Apple Silicon

### Configuração Automática
O bootstrap configura automaticamente:
- Contextos kubectl (local vs produção)
- Aliases úteis (k, kgp, kgs, kgd)
- Integração com K3s existente (detecta ~/.kube/k3s.yaml)
- Registry local para desenvolvimento

### Serviços Auxiliares (Docker Compose)
Disponíveis em `local/docker-compose.yaml`:
- **MinIO** - S3 local (localhost:9000)
- **PostgreSQL** - Banco de dados (localhost:5432)
- **Redis** - Cache (localhost:6379)
- **Grafana** - Métricas (localhost:3000)
- **Jaeger** - Tracing (localhost:16686)
- **Datadog Mock** - Simulação de agent (localhost:8125)

## Princípios de Segurança

- Nunca commitar secrets em texto plano
- Sempre usar Sealed Secrets para informações sensíveis
- Manter o repositório privado ou altamente auditado
- Todas as configurações devem ser versionadas e declarativas

## GitOps Workflow

### Fluxo de Desenvolvimento
1. **Setup Local**: `make tools-install && cp .env.example .env` (primeira vez)
2. **Desenvolvimento**: `make dev` (cluster + Argo CD + Headlamp)
3. **Validação**: `make helm-validate` (validação de manifests)
4. **Deploy**: Push para `main` → Argo CD sincroniza automaticamente

### Ambientes
- **Local**: Cluster k3d + serviços Docker Compose
- **Staging/Produção**: Cluster K3s real + Argo CD

### Contextos kubectl
- `k3d-yby-local` - Desenvolvimento local
- `default` - Produção (configurado via K3s)

### Pipeline GitOps
- Branch `main` é observado pelo Argo CD
- Mudanças são aplicadas automaticamente no cluster
- Pipelines de CI executam via Argo Workflows dentro do cluster
- Não há dependência de serviços externos como GitHub Actions

## Solução de Problemas

### Erros Comuns
1. **Docker não está rodando**: `sudo systemctl start docker && sudo usermod -aG docker $USER`
2. **kubectl sem contexto**: Use `kubectl config use-context` para configurar
3. **k3d não encontrado**: Execute `make tools-install` para instalar ferramentas
5. **Repositório kubernetes antigo**: O script usa o novo `pkgs.k8s.io`
6. **kubeconform falha**: Ferramenta moderna para validação, veja logs com `make tools-check`

### Comandos de Diagnóstico
```bash
# Verificar todas as ferramentas detalhadamente
./setup/bootstrap.sh --check-only

# Verificar apenas ferramentas Kubernetes
make tools-check

# Verificar se ambiente local está funcionando
make vagrant-test

# Logs de problemas
make logs
```

### Reset Completo
```bash
# Limpeza total e reinstalação
make clean
make tools-install
make dev

# Reset apenas de ferramentas
rm -rf ~/.local/bin/{kubectl,k3d,helm,argocd,kubeseal,mc,kustomize,kubeconform,yq,jq}
make tools-install
```

## Deploy Remoto Completo

O projeto agora inclui um comando único para deploy completo em servidor remoto.

### Comando Principal
```bash
# Configurar .env com dados do VPS
cp .env.example .env
nano .env

# Deploy completo: servidor → GitOps → pipeline
make deploy-remote
```

### Scripts de Deploy Remoto
- `scripts/deploy-complete.sh` - Script principal que orquestra todo o processo
- `scripts/provision-vps.sh` - Provisiona servidor VPS com K3s
- Comandos kubectl/helm locais - Instala stack GitOps (via make helm-bootstrap)
- `scripts/setup-github-integration.sh` - Configura webhook e pipeline

### Configuração (.env)
Configurações mínimas necessárias:
```bash
VPS_HOST=seu-vps.com              # IP do servidor
VPS_USER=root                     # Usuário SSH
GITHUB_REPO=https://github.com/seu-usuario/yby
```

### Validação e Troubleshooting
```bash
make helm-validate               # Validar configuração
make provision-vps               # Provisionar VPS
make helm-bootstrap              # Aplicar charts no cluster
make show-webhook-config         # Ver configuração do webhook
```

O deploy completo transforma um servidor VPS limpo em cluster Kubernetes funcional com GitOps em 5-10 minutos.