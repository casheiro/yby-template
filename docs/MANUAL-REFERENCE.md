# 🔓 Guia Zero Lock-in (Operação Manual)

Este guia documenta como operar o template Yby utilizando apenas ferramentas nativas do ecossistema Cloud Native (`kubectl`, `helm`, `git`, `kubeseal`). 
A **Yby CLI** é apenas um facilitador; tudo o que ela faz pode ser feito manualmente.

---

## 🏗️ 1. Bootstrap (Instalação)

### O que a CLI faz (`yby bootstrap cluster`)
Instala ArgoCD, aplica manifestos e configura o App of Apps.

### Equivalente Manual

#### 1. Instalar Argo CD
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Instalar Argo CD (Versão recomendada: verifique .yby/blueprint.yaml)
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --version 5.51.6 \
  --set server.service.type=ClusterIP \
  --set server.insecure=true \
  --wait
```

#### 2. Instalar Argo Events & Workflows
```bash
# Workflows
kubectl create namespace argo --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo-workflows/stable/manifests/install.yaml

# Events
kubectl create namespace argo-events --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install.yaml
```

#### 3. Aplicar Root App (O "Cérebro" do GitOps)
```bash
# Certifique-se de ter editado config/cluster-values.yaml
kubectl apply -f manifests/argocd/root-app.yaml
```

---

## 🔑 2. Gerenciamento de Segredos

### O que a CLI faz (`yby secret webhook`)
Gera um Secret Kubernetes e (opcionalmente) o sela com Sealed Secrets.

### Equivalente Manual

#### Criar Webhook Secret
```bash
# 1. Gerar string aleatória
SECRET=$(openssl rand -hex 20)
echo "Seu segredo: $SECRET"

# 2. Criar manifesto SealedSecret
kubectl create secret generic github-webhook-secret \
  --from-literal=secret=$SECRET \
  -n argo-events \
  --dry-run=client -o yaml | \
  kubeseal \
    --controller-name=sealed-secrets-controller \
    --controller-namespace=kube-system \
    --format=yaml > charts/cluster-config/templates/events/sealed-secret-github.yaml
```

---

## 🌍 3. Acesso Local (Port-Forward)

### O que a CLI faz (`yby access`)
Abre túneis para ArgoCD, Grafana e Headlamp e imprime credenciais.

### Equivalente Manual

#### Acessar Argo CD
```bash
# 1. Obter Senha
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

# 2. Port-Forward
kubectl -n argocd port-forward svc/argocd-server 8080:80
# Acesse em http://localhost:8080
```

#### Acessar Grafana (Prometheus Stack)
```bash
# 1. Obter Senha (se definido no helm values)
# (Se não definido, user: admin, pass: prom-operator)

# 2. Port-Forward
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
# Acesse em http://localhost:3000
```

---

## 🛠️ 4. Validação

### O que a CLI faz (`yby validate`)
Executa lints e prevê o template gerado.

### Equivalente Manual

```bash
# Lint do Chart
helm lint charts/bootstrap -f config/cluster-values.yaml

# Dry-Run (Ver o que será gerado)
helm template bootstrap charts/bootstrap -f config/cluster-values.yaml
```
