# Ambiente de Desenvolvimento Local

Este diretório contém configurações para desenvolvimento local usando Vagrant + Docker, proporcionando um ambiente controlado para testar toda a pipeline de GitOps sem afetar o cluster de produção.

## Arquitetura

```
Desenvolvimento Local
├── Vagrant VM (K3s)          # Cluster Kubernetes real
├── Docker Compose            # Serviços auxiliares
└── Host Machine              # kubectl, make, scripts
```

## Pré-requisitos

O ambiente será verificado e configurado automaticamente, mas você pode instalar manualmente:

- **Vagrant** (>= 2.3.0)
- **VirtualBox** (>= 7.0.0) ou **Docker Desktop**
- **kubectl**
- **make**

## Quick Start

```bash
# 1. Configurar ambiente (verifica dependências, instala se necessário)
make tools-install

# 2. Subir ambiente completo
make dev-up

# 3. Ver status
make status
```

## Comandos Disponíveis

### Ambiente Completo
```bash
make dev-env-up      # Subir tudo (VM + serviços Docker)
make dev-env-down    # Parar tudo
make dev-env-clean   # Limpar tudo (destruir VM e containers)
```

### VM Vagrant
```bash
make vagrant-up         # Subir VM
make vagrant-halt       # Parar VM
make vagrant-destroy    # Destruir VM
make vagrant-ssh        # Acessar VM
make vagrant-provision  # Re-provisionar VM
make vagrant-status     # Status da VM
make vagrant-test       # Testar ambiente
```

### Serviços Docker
```bash
make docker-services-up    # Subir MinIO, Grafana, etc.
make docker-services-down  # Parar serviços
make docker-services-logs  # Ver logs
```

### Configuração
```bash
make setup-local       # Configurar ambiente inicial
./scripts/check-dev-requirements.sh --auto-install
```

## Configuração

### Arquivo `vagrant-config.yml`
Configuração principal usando sintaxe `${VAR:default}`:

```yaml
vagrant:
  vm:
    memory: "${VAGRANT_MEMORY:4096}"
    cpus: "${VAGRANT_CPUS:2}"
  network:
    private_ip: "${VAGRANT_IP:192.168.56.100}"
```

### Arquivo `.env.local`
Criado automaticamente com overrides para desenvolvimento:

```bash
# VM Configuration
VAGRANT_MEMORY=4096
VAGRANT_IP=192.168.56.100

# Cluster local
CLUSTER_NAME=yby-dev
ENVIRONMENT=development
LOCAL_MODE=true
```

## Serviços Disponíveis

### Na VM Vagrant
- **Kubernetes API**: https://192.168.56.100:6443
- **K3s Dashboard**: http://192.168.56.100:8080
- **Argo CD**: http://localhost:9080 (port-forward)

### Docker Compose (Host)
- **MinIO**: http://localhost:9000 (minioadmin/minioadmin123)
- **Grafana**: http://localhost:3000 (admin/admin123)
- **Jaeger**: http://localhost:16686
- **PostgreSQL**: localhost:5432 (dev/dev123)

## Workflow de Desenvolvimento

### Desenvolvimento Típico
```bash
# 1. Subir ambiente
make dev-up

# 2. Fazer mudanças no código
# ... editar arquivos ...

# 3. Validar mudanças
make helm-validate

# 4. Pipeline automática
# Push/tag aciona Argo Events; workflows executam validações e deploy

# 5. Ver status
make status
```

### Teste de Provisionamento
```bash
# 1. Destruir e recriar VM (simula VPS limpo)
make vagrant-destroy
make vagrant-up

# 2. Executar bootstrap
make vagrant-ssh
cd /vagrant && ./scripts/bootstrap-gitops.sh

# 3. Validar resultado
kubectl get pods -A
```

### Debugging
```bash
# Logs do cluster
make logs

# Workflow logs
kubectl logs -n argo -l app=workflow-controller -f
```

## Estrutura de Arquivos

```
local/
├── Vagrantfile                # Configuração da VM
├── vagrant-config.yml         # Configuração com ${VAR:default}
├── docker-compose.yaml       # Serviços auxiliares
└── README.md                 # Esta documentação

.kube/
└── config                    # Kubeconfig da VM (gerado automaticamente)

.env.local                   # Configuração local (gerado automaticamente)
```

## Integração com Scripts Existentes

Todos os scripts detectam automaticamente o ambiente Vagrant:

- `provision-vps.sh` → Detecta ambiente e usa configurações locais
- `bootstrap-gitops.sh` → Adapta para recursos limitados
- `template-processor.sh` → Funciona igual
- `check-dev-requirements.sh` → Instala dependências

## Troubleshooting

### VM não inicia
```bash
# Verificar VirtualBox
VBoxManage list vms
VBoxManage showvminfo yby-dev

# Logs do Vagrant
cd local && vagrant up --debug
```

### kubectl não conecta
```bash
# Verificar kubeconfig
export KUBECONFIG=$PWD/.kube/config
kubectl config current-context
kubectl get nodes

# Regenerar kubeconfig
make vagrant-provision
```

### Porta já em uso
```bash
# Verificar portas
netstat -tulpn | grep :6443

# Ajustar no vagrant-config.yml
VAGRANT_IP=192.168.56.101 make vagrant-up
```

### Performance lenta
```bash
# Aumentar recursos
export VAGRANT_MEMORY=8192
export VAGRANT_CPUS=4
make vagrant-destroy && make vagrant-up
```

## Diferenças do Ambiente de Produção

| Aspecto | Desenvolvimento | Produção |
|---------|-----------------|----------|
| **Recursos** | 4GB RAM, 2 CPU | Conforme VPS |
| **Storage** | Local, efêmero | Persistente |
| **Rede** | NAT + Port Forward | IP público |
| **Secrets** | Mock/dev valores | Reais via Sealed Secrets |
| **GitOps** | Local mode opcional | GitHub webhooks |
| **Monitoring** | Opcional | Datadog completo |

## Próximos Passos

Após validar no ambiente local:

1. **Commit** das mudanças
2. **Push** para branch de desenvolvimento
3. **Teste** em staging remoto
4. **Deploy** em produção via GitOps