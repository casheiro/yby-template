# 🚀 Setup GitOps - Yby

Este guia detalha como configurar um novo cluster Kubernetes com GitOps usando a abordagem **Agnóstica** e **Zero-Touch** do Yby.

## 📋 Pré-requisitos

1. **Cluster Kubernetes**: Pode ser local (k3d) ou remoto (VPS/Cloud).
2. **Ferramentas**: `kubectl`, `helm`, `git` instalados.
3. **GitHub Token (PAT)**: Necessário para descoberta automática de apps.

---

## 🏗️ Fase 1: Inicialização (Wizard)

Use o script interativo para configurar o repositório para seu novo cluster:

```bash
./scripts/init-new-cluster.sh
```

Este script irá:
1. Perguntar nome da organização, repositório e domínio.
2. Gerar o arquivo `config/cluster-values.yaml`.
3. Configurar os parâmetros de descoberta automática.

---

## 🔑 Fase 2: Segredos Essenciais

Para que o **Zero-Touch Discovery** funcione, o Argo CD precisa de permissão para ler seus repositórios no GitHub.

### 2.1 Criar GitHub Token Secret

1. Gere um **Personal Access Token (PAT)** no GitHub:
   - Vá em: **Settings > Developer settings > Personal access tokens > Tokens (classic)**
   - Escopo: `repo` (Full control of private repositories)
   - Copie o token gerado (ex: `ghp_...`).

2. Crie o Secret no cluster:
```bash
# Certifique-se de que o namespace existe (ou será criado pelo bootstrap)
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Crie o secret
kubectl create secret generic github-token \
  --from-literal=token=SEU_TOKEN_AQUI \
  -n argocd
```

---

## 🚀 Fase 3: Bootstrap do Cluster

Agora que a configuração e os segredos estão prontos, instale a stack GitOps.

### Opção A: Script Automático (Recomendado)
```bash
# Para instalar toda a stack GitOps:
yby bootstrap cluster
```

### Opção B: Manual (Helm Puro)
```bash
# 1. Instalar Argo CD
helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install argocd argo/argo-cd -n argocd --create-namespace --version 5.51.6 --set server.service.type=ClusterIP

# 2. Instalar Argo Workflows & Events (necessário para CI/CD)
kubectl create ns argo && kubectl apply -n argo -f manifests/upstream/argo-workflows.yaml
kubectl create ns argo-events && kubectl apply -f manifests/upstream/argo-events.yaml

# 3. Aplicar App of Apps
helm upgrade --install bootstrap charts/bootstrap -f config/cluster-values.yaml
```

---

## ✨ Fase 4: Zero-Touch Discovery

O cluster agora está monitorando sua organização no GitHub.

### Como adicionar uma aplicação:
1. Crie um repositório no GitHub.
2. Adicione uma pasta `infra/` com seus manifestos.
3. Adicione o tópico `yby-app` no repositório.

O Argo CD detectará automaticamente e criará a aplicação.

### 4. Configurar Github Token (Secret)

Para que o Argo CD ApplicationSet possa descobrir novos repositórios:

1.  Crie o Secret manualmente (se não foi criado pelo bootstrap):
    ```bash
    yby secret webhook github
    ```

---

## 🔐 Fase 5: Webhooks (CI/CD Instantâneo)

Para ativar pipelines de CI/CD (build, testes) e ter deploys instantâneos, configure o segredo do Webhook.

Se você usou `yby install`, isso já foi feito parcialmente.

> 📖 **Consulte o guia completo:** [docs/WEBHOOK-GUIDE.md](docs/WEBHOOK-GUIDE.md) para instruções detalhadas de configuração no GitHub/GitLab.

---

## 🔍 Verificação

```bash
# Verificar Apps
kubectl -n argocd get applications

# Acessar Argo CD
kubectl -n argocd port-forward svc/argocd-server 8080:443
# Login: admin
# Senha: make get-argocd-password
```