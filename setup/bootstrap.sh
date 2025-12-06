#!/bin/bash

# Yby - Bootstrap para Ambiente de Desenvolvimento
# Detecta ambiente e instala apenas as ferramentas necessárias
#
# FERRAMENTAS INSTALADAS:
# ========================
# 
# Categoria Kubernetes:
# - kubectl: CLI oficial do Kubernetes para gerenciar clusters
# - k3d: Ferramenta para criar clusters K3s locais usando Docker
# - helm: Gerenciador de pacotes para Kubernetes
#
# Categoria GitOps e Segurança:
# - argocd CLI: Interface de linha de comando para Argo CD (GitOps)
# - kubeseal: Ferramenta para criptografar secrets com Sealed Secrets
#
# Categoria Processamento e Validação:
# - kustomize: Ferramenta para customização declarativa de recursos K8s
# - yq: Processador YAML (equivalente ao jq para YAML)
# - jq: Processador JSON para manipulação de dados estruturados
# - kubeconform: Validador moderno de manifests Kubernetes (sucessor do kubeval)
#
# Categoria Armazenamento:
# - MinIO client (mc): Cliente S3 compatível para gerenciar armazenamento
#
# FERRAMENTAS OBRIGATÓRIAS (instalação manual):
# ===============================================
# - Docker: Container runtime (obrigatório)
# - Git: Controle de versão 
# - Make: Build automation tool
# - GNU Coreutils: curl, awk, sed, grep, find, base64
# - Bash 4.0+: Shell para execução dos scripts

set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CHECK_ONLY=false

# Parse argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        --check-only)
            CHECK_ONLY=true
            shift
            ;;
        *)
            echo "Uso: $0 [--check-only]"
            exit 1
            ;;
    esac
done

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Detectar sistema operacional e arquitetura
detect_system() {
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        armv7l) ARCH="arm" ;;
        *) log_error "Arquitetura não suportada: $ARCH"; exit 1 ;;
    esac
    
    case $OS in
        linux*)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                DISTRO=$ID
                VERSION=$VERSION_ID
            else
                log_error "Distribuição Linux não identificada"
                exit 1
            fi
            ;;
        darwin*) DISTRO="macos" ;;
        *) log_error "Sistema operacional não suportado: $OS"; exit 1 ;;
    esac
    
    log_info "Sistema detectado: $DISTRO $VERSION ($OS/$ARCH)"
}

# Verificar se comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Verificar Docker
check_docker() {
    if command_exists docker; then
        if docker info >/dev/null 2>&1; then
            log_success "Docker: $(docker --version | cut -d' ' -f3 | tr -d ',')"
            return 0
        else
            log_warning "Docker instalado mas não está rodando"
            return 1
        fi
    else
        log_error "Docker não encontrado"
        return 1
    fi
}

# Verificar kubectl
check_kubectl() {
    if command_exists kubectl; then
        local version=$(kubectl version --client --short 2>/dev/null | cut -d' ' -f3 || echo "unknown")
        log_success "kubectl: $version"
        
        # Verificar se há contexto configurado
        if kubectl config current-context >/dev/null 2>&1; then
            local context=$(kubectl config current-context)
            log_info "Contexto atual: $context"
        else
            log_warning "Nenhum contexto kubectl configurado"
        fi
        return 0
    else
        log_error "kubectl não encontrado"
        return 1
    fi
}

# Verificar Helm
check_helm() {
    if command_exists helm; then
        local version=$(helm version --short 2>/dev/null | cut -d' ' -f1 || echo "unknown")
        log_success "Helm: $version"
        return 0
    else
        log_warning "Helm não encontrado"
        return 1
    fi
}

# Verificar k3d
check_k3d() {
    if command_exists k3d; then
        local version=$(k3d version | grep k3d | cut -d' ' -f3)
        log_success "k3d: $version"
        return 0
    else
        log_warning "k3d não encontrado"
        return 1
    fi
}

# Verificar kubeseal
check_kubeseal() {
    if command_exists kubeseal; then
        local version=$(kubeseal --version 2>&1 | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
        log_success "kubeseal: $version"
        return 0
    else
        log_warning "kubeseal não encontrado"
        return 1
    fi
}

# Verificar argocd CLI
check_argocd() {
    if command_exists argocd; then
        local version=$(argocd version --client --short 2>/dev/null | cut -d' ' -f2 || echo "unknown")
        log_success "argocd CLI: $version"
        return 0
    else
        log_warning "argocd CLI não encontrado"
        return 1
    fi
}

# Verificar MinIO client
check_minio() {
    if command_exists mc; then
        local version=$(mc --version 2>/dev/null | head -1 | cut -d' ' -f3 || echo "unknown")
        log_success "MinIO client: $version"
        return 0
    else
        log_warning "MinIO client (mc) não encontrado"
        return 1
    fi
}

# Verificar Kustomize
check_kustomize() {
    if command_exists kustomize; then
        local version=$(kustomize version --short 2>/dev/null | cut -d' ' -f1 | sed 's/{kustomize\/v/v/' | sed 's/ .*//' || echo "unknown")
        log_success "Kustomize: $version"
        return 0
    else
        log_warning "Kustomize não encontrado"
        return 1
    fi
}

# Verificar kubeconform
check_kubeconform() {
    if command_exists kubeconform; then
        local version=$(kubeconform -v 2>/dev/null || echo "unknown")
        log_success "kubeconform: $version"
        return 0
    else
        log_warning "kubeconform não encontrado"
        return 1
    fi
}

# Verificar yq
check_yq() {
    if command_exists yq; then
        local version=$(yq --version 2>/dev/null | cut -d' ' -f4 || echo "unknown")
        log_success "yq: $version"
        return 0
    else
        log_warning "yq não encontrado"
        return 1
    fi
}

# Verificar jq
check_jq() {
    if command_exists jq; then
        local version=$(jq --version 2>/dev/null || echo "unknown")
        log_success "jq: $version"
        return 0
    else
        log_warning "jq não encontrado"
        return 1
    fi
}

# Verificar ferramentas GNU coreutils obrigatórias
check_system_tools() {
    log_info "Verificando ferramentas do sistema..."
    local system_ok=true
    
    local required_tools="git make curl awk sed grep find base64"
    for tool in $required_tools; do
        if command_exists $tool; then
            local version=$($tool --version 2>/dev/null | head -1 | cut -d' ' -f2-4 || echo "presente")
            log_success "$tool: $version"
        else
            log_error "$tool não encontrado (obrigatório)"
            system_ok=false
        fi
    done
    
    # Verificar bash version
    if [[ "${BASH_VERSION%%.*}" -ge 4 ]]; then
        log_success "Bash: $BASH_VERSION"
    else
        log_warning "Bash version < 4.0 pode causar problemas"
    fi
    
    return $([ "$system_ok" = true ])
}

# Verificar todas as ferramentas
check_all_tools() {
    log_info "Verificando ferramentas de desenvolvimento..."
    
    local tools_ok=true
    
    # Verificar ferramentas do sistema primeiro
    check_system_tools || tools_ok=false
    echo
    
    # Verificar ferramentas Kubernetes
    check_docker || tools_ok=false
    check_kubectl || tools_ok=false
    check_helm || tools_ok=false
    check_k3d || tools_ok=false
    check_kubeseal || tools_ok=false
    check_argocd || tools_ok=false
    check_minio || tools_ok=false
    check_kustomize || tools_ok=false
    check_kubeconform || tools_ok=false
    check_yq || tools_ok=false
    check_jq || tools_ok=false
    
    if [ "$tools_ok" = true ]; then
        log_success "Todas as ferramentas estão instaladas!"
        return 0
    else
        return 1
    fi
}

# Instalar kubectl (com repositório correto)
install_kubectl() {
    log_info "Instalando kubectl..."
    
    case $DISTRO in
        ubuntu|debian)
            # Usar o novo repositório oficial
            curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
            echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
            sudo apt-get update
            sudo apt-get install -y kubectl
            ;;
        *)
            # Download direto
            local kubectl_url="https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/$OS/$ARCH/kubectl"
            curl -LO "$kubectl_url"
            chmod +x kubectl
            sudo mv kubectl /usr/local/bin/
            ;;
    esac
}

# Instalar Helm
install_helm() {
    log_info "Instalando Helm..."
    
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
}

# Instalar k3d
install_k3d() {
    log_info "Instalando k3d..."
    
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
}

# Instalar kubeseal
install_kubeseal() {
    log_info "Instalando kubeseal..."
    
    local version="v0.24.0"
    
    # Download direto do binário (sem tar.gz)
    local url="https://github.com/bitnami-labs/sealed-secrets/releases/download/$version/kubeseal-$version-$OS-$ARCH"
    
    if curl -sSL "$url" -o kubeseal; then
        chmod +x kubeseal
        sudo mv kubeseal /usr/local/bin/
        log_success "kubeseal instalado com sucesso"
    else
        log_error "Falha ao instalar kubeseal. Tentando método alternativo..."
        
        # Fallback: tentar via Homebrew/apt se disponível
        case $DISTRO in
            ubuntu|debian)
                if command_exists snap; then
                    sudo snap install kubeseal --classic || log_error "Falha no snap install"
                fi
                ;;
            *)
                log_warning "Instalação manual do kubeseal pode ser necessária"
                ;;
        esac
    fi
}

# Instalar argocd CLI
install_argocd() {
    log_info "Instalando argocd CLI..."
    
    # Método oficial: usar nome correto do arquivo
    local url="https://github.com/argoproj/argo-cd/releases/latest/download/argocd-$OS-$ARCH"
    
    # Download com nome temporário
    if curl -sSL "$url" -o argocd-temp; then
        # Verificar se é um arquivo executável válido
        if file argocd-temp | grep -q "executable"; then
            sudo install -m 555 argocd-temp /usr/local/bin/argocd
            rm argocd-temp
            log_success "argocd CLI instalado com sucesso"
        else
            log_error "Arquivo baixado não é um executável válido"
            rm argocd-temp
            return 1
        fi
    else
        log_error "Falha no download do argocd CLI"
        
        # Fallback: tentar método alternativo com versão específica
        log_info "Tentando método alternativo..."
        local version="v2.12.4"
        local fallback_url="https://github.com/argoproj/argo-cd/releases/download/$version/argocd-$OS-$ARCH"
        
        if curl -sSL "$fallback_url" -o argocd-temp; then
            sudo install -m 555 argocd-temp /usr/local/bin/argocd
            rm argocd-temp
            log_success "argocd CLI instalado via fallback"
        else
            log_error "Falha em todos os métodos de instalação do argocd"
            return 1
        fi
    fi
}

# Instalar MinIO client
install_minio() {
    log_info "Instalando MinIO client..."
    
    local url="https://dl.min.io/client/mc/release/$OS-$ARCH/mc"
    
    if curl -L "$url" -o mc; then
        chmod +x mc
        sudo mv mc /usr/local/bin/
        log_success "MinIO client instalado com sucesso"
    else
        log_error "Falha ao instalar MinIO client"
        return 1
    fi
}

# Instalar Kustomize
install_kustomize() {
    log_info "Instalando Kustomize..."
    
    # Usar script oficial do Kustomize
    curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
    sudo mv kustomize /usr/local/bin/
    log_success "Kustomize instalado com sucesso"
}

# Instalar kubeconform
install_kubeconform() {
    log_info "Instalando kubeconform..."
    
    local version="v0.6.4"
    local url="https://github.com/yannh/kubeconform/releases/download/$version/kubeconform-$OS-$ARCH.tar.gz"
    
    if curl -L "$url" -o kubeconform.tar.gz; then
        tar xf kubeconform.tar.gz kubeconform
        sudo mv kubeconform /usr/local/bin/
        rm kubeconform.tar.gz
        log_success "kubeconform instalado com sucesso"
    else
        log_error "Falha ao instalar kubeconform"
        return 1
    fi
}

# Instalar yq
install_yq() {
    log_info "Instalando yq..."
    
    local version="v4.44.3"
    local url="https://github.com/mikefarah/yq/releases/download/$version/yq_${OS}_${ARCH}"
    
    if curl -L "$url" -o yq; then
        chmod +x yq
        sudo mv yq /usr/local/bin/
        log_success "yq instalado com sucesso"
    else
        log_error "Falha ao instalar yq"
        return 1
    fi
}

# Instalar jq
install_jq() {
    log_info "Instalando jq..."
    
    case $DISTRO in
        ubuntu|debian)
            sudo apt-get update && sudo apt-get install -y jq
            ;;
        *)
            # Download direto para outras distribuições
            local url="https://github.com/jqlang/jq/releases/latest/download/jq-$OS-$ARCH"
            if curl -L "$url" -o jq; then
                chmod +x jq
                sudo mv jq /usr/local/bin/
                log_success "jq instalado com sucesso"
            else
                log_error "Falha ao instalar jq"
                return 1
            fi
            ;;
    esac
}

# Configurar kubectl contexts
setup_kubectl_contexts() {
    log_info "Configurando contextos kubectl..."
    
    # Se existe k3s.yaml, configurar
    if [ -f ~/.kube/k3s.yaml ]; then
        log_info "Configurando contexto K3s existente..."
        cp ~/.kube/k3s.yaml ~/.kube/config.k3s
        
        # Mesclar com config existente se houver
        if [ -f ~/.kube/config ]; then
            KUBECONFIG=~/.kube/config:~/.kube/config.k3s kubectl config view --flatten > ~/.kube/config.tmp
            mv ~/.kube/config.tmp ~/.kube/config
        else
            cp ~/.kube/config.k3s ~/.kube/config
        fi
        
        # Corrigir permissões
        chmod 600 ~/.kube/config
        log_success "Contexto K3s configurado"
    fi
}

# Instalar ferramentas faltantes
install_missing_tools() {
    log_info "Instalando ferramentas faltantes..."
    
    # Verificar ferramentas do sistema (não instalar automaticamente)
    if ! check_system_tools; then
        log_error "Algumas ferramentas obrigatórias do sistema estão faltando."
        log_info "Por favor, instale manualmente: git, make, curl, GNU coreutils"
        case $DISTRO in
            ubuntu|debian)
                log_info "Execute: sudo apt-get install -y git make curl gawk sed grep findutils coreutils"
                ;;
            *)
                log_info "Consulte a documentação do seu sistema operacional"
                ;;
        esac
        exit 1
    fi
    
    # Instalar ferramentas Kubernetes uma por vez e verificar
    if ! check_kubectl; then
        install_kubectl
        check_kubectl || log_error "Falha na instalação do kubectl"
    fi
    
    if ! check_helm; then
        install_helm
        check_helm || log_error "Falha na instalação do Helm"
    fi
    
    if ! check_k3d; then
        install_k3d
        check_k3d || log_error "Falha na instalação do k3d"
    fi
    
    if ! check_kubeseal; then
        install_kubeseal
        check_kubeseal || log_warning "kubeseal pode precisar de instalação manual"
    fi
    
    if ! check_argocd; then
        install_argocd
        check_argocd || log_error "Falha na instalação do argocd CLI"
    fi
    
    if ! check_minio; then
        install_minio
        check_minio || log_error "Falha na instalação do MinIO client"
    fi
    
    if ! check_kustomize; then
        install_kustomize
        check_kustomize || log_error "Falha na instalação do Kustomize"
    fi
    
    if ! check_kubeconform; then
        install_kubeconform
        check_kubeconform || log_warning "kubeconform pode precisar de instalação manual"
    fi
    
    if ! check_yq; then
        install_yq
        check_yq || log_error "Falha na instalação do yq"
    fi
    
    if ! check_jq; then
        install_jq
        check_jq || log_error "Falha na instalação do jq"
    fi
    
    log_success "Instalação concluída!"
}

# Criar configuração inicial
setup_initial_config() {
    log_info "Criando configuração inicial..."
    
    # Criar diretório .kube se não existir
    mkdir -p ~/.kube
    
    # Configurar contexts
    setup_kubectl_contexts
    
    # Criar alias úteis
    if ! grep -q "alias k=" ~/.bashrc 2>/dev/null; then
        echo "# Kubernetes aliases" >> ~/.bashrc
        echo "alias k=kubectl" >> ~/.bashrc
        echo "alias kgp='kubectl get pods'" >> ~/.bashrc
        echo "alias kgs='kubectl get svc'" >> ~/.bashrc
        echo "alias kgd='kubectl get deployments'" >> ~/.bashrc
        log_success "Aliases adicionados ao ~/.bashrc"
    fi
}

# Função principal
main() {
    echo "🧠 Yby - Bootstrap do Ambiente de Desenvolvimento"
    echo "================================================================"
    
    detect_system
    
    if [ "$CHECK_ONLY" = true ]; then
        check_all_tools
        exit $?
    fi
    
    # Verificar Docker primeiro (obrigatório)
    if ! check_docker; then
        log_error "Docker é obrigatório. Por favor, instale e configure o Docker primeiro."
        exit 1
    fi
    
    # Verificar se todas as ferramentas estão instaladas
    if check_all_tools; then
        log_success "Todas as ferramentas já estão instaladas!"
        setup_initial_config
    else
        log_info "Algumas ferramentas precisam ser instaladas..."
        install_missing_tools
        setup_initial_config
        
        # Verificar novamente e mostrar resultados
        echo ""
        log_info "Verificando instalação final..."
        
        local final_check=true
        check_system_tools || final_check=false
        check_docker || final_check=false
        check_kubectl || final_check=false  
        check_helm || final_check=false
        check_k3d || final_check=false
        check_kubeseal || log_warning "kubeseal pode precisar instalação manual"
        check_argocd || final_check=false
        check_minio || final_check=false
        check_kustomize || final_check=false
        check_kubeconform || log_warning "kubeconform pode precisar instalação manual"
        check_yq || final_check=false
        check_jq || final_check=false
        
        if [ "$final_check" = true ]; then
            log_success "🎉 Ambiente configurado com sucesso!"
            echo ""
            echo "📋 Ferramentas instaladas:"
            echo "   ✅ Ferramentas do sistema (git, make, curl, GNU coreutils)"
            echo "   ✅ Docker + Kubernetes (kubectl, k3d, helm)"
            echo "   ✅ GitOps (argocd CLI, kubeseal)"
            echo "   ✅ Processamento (kustomize, yq, jq, kubeconform)"
            echo "   ✅ Armazenamento (MinIO client)"
            echo ""
            echo "🚀 Próximos passos:"
            echo "   1. Execute: source ~/.bashrc"
            echo "   2. Execute: make setup (configurar ambiente local)"
            echo "   3. Execute: make dev (iniciar desenvolvimento)"
            echo ""
        else
            log_error "Algumas ferramentas obrigatórias falharam na instalação"
            echo ""
            echo "🔧 Para diagnosticar problemas:"
            echo "   make tools-check    # Ver status detalhado"
            echo "   ./setup/bootstrap.sh --check-only    # Verificar apenas"
            exit 1
        fi
    fi
}

# Executar função principal
main "$@"