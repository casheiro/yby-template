# 🚀 Guia Completo de Deploy em Produção

Este guia detalha o processo completo de configuração e deploy do **Yby** em ambiente de produção, cobrindo segurança, observabilidade, backup e escalabilidade.

---

## 📋 Checklist Rápido

- [ ] Ajustar `config/cluster-values.yaml` com domínio e organização
- [ ] Instalar Cert-Manager e habilitar TLS
- [ ] Criar secret `github-token` no namespace `argocd`
- [ ] Configurar backup automático de etcd
- [ ] Habilitar observabilidade (Datadog ou Prometheus)
- [ ] Aplicar NetworkPolicy e whitelist de IPs
- [ ] Configurar recursos e HPA para aplicações críticas
- [ ] Executar `yby validate` antes do deploy
- [ ] Documentar acessos e credenciais em local seguro

---

## 🔧 1. Pré-requisitos

### Ferramentas Necessárias
| Ferramenta | Versão Mínima | Instalação |
|------------|---------------|------------|
| kubectl | 1.25+ | `curl -LO https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl` |
| helm | 3.12+ | `curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \| bash` |
| k3d (dev local) | 5.6+ | `curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh \| bash` |
| argocd CLI | 2.9+ | `curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64` |

### Recursos do Servidor
- **Mínimo:** 2 vCPUs, 4GB RAM, 40GB disco
- **Recomendado:** 4 vCPUs, 8GB RAM, 100GB disco SSD
- **Produção:** 8+ vCPUs, 16GB+ RAM, 200GB+ disco NVMe

---

## 🔐 2. Configuração de Secrets

### 2.1 GitHub Token (Obrigatório para Discovery)

```bash
# Crie um Personal Access Token no GitHub com escopo 'repo'
# https://github.com/settings/tokens

# Use o script helper
./scripts/create-github-token-secret.sh SEU_TOKEN_AQUI

# Ou manualmente:
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic github-token \
  --from-literal=token=ghp_SEU_TOKEN \
  -n argocd
```

### 2.2 Sealed Secrets (Recomendado)

Para armazenar secrets no Git de forma segura:

```bash
# Instalar Sealed Secrets Controller
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml

# Instalar kubeseal CLI
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/kubeseal-0.24.0-linux-amd64.tar.gz
tar -xvzf kubeseal-0.24.0-linux-amd64.tar.gz
sudo install -m 755 kubeseal /usr/local/bin/kubeseal

# Criar sealed secret
kubectl create secret generic my-secret \
  --from-literal=password=mypassword \
  --dry-run=client -o yaml | \
  kubeseal -o yaml > sealed-secret.yaml

# Commit no Git
git add sealed-secret.yaml && git commit -m "Add sealed secret"
```

---

## 🔒 3. Configuração de TLS (HTTPS)

### 3.1 Instalar Cert-Manager

```bash
# Adicionar repositório Helm
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Instalar Cert-Manager
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.13.2 \
  --set installCRDs=true \
  --wait

# Verificar instalação
kubectl get pods -n cert-manager
```

### 3.2 Habilitar TLS no Cluster

Edite `config/cluster-values.yaml`:

```yaml
ingress:
  enabled: true
  tls:
    enabled: true  # ← Mude para true
    certResolver: letsencrypt
    email: seu-email@dominio.com  # ← Email válido

global:
  domainBase: "seu-dominio.com"  # ← Seu domínio real
```

### 3.3 Configurar DNS

Crie um registro DNS wildcard apontando para o IP do servidor:

```
*.seu-dominio.com  A  123.45.67.89
```

### 3.4 Validar Certificado

```bash
# Aguarde até 2 minutos para emissão
kubectl get certificate -A

# Verificar logs do Cert-Manager
kubectl logs -n cert-manager -l app=cert-manager
```

---

## 📊 4. Observabilidade

### 4.1 Opção A: Datadog

```bash
# Criar secret com API Key
kubectl create secret generic datadog-secret \
  --from-literal=api-key=SEU_API_KEY_DATADOG \
  -n datadog --dry-run=client -o yaml | \
  kubeseal -o yaml > charts/cluster-config/templates/datadog-secret.yaml

# Habilitar no cluster-values.yaml
# datadog:
#   enabled: true
#   secretName: datadog-secret
#   site: datadoghq.com
#   tags:
#     - env:production
#     - cluster:yby-prod
```

### 4.2 Opção B: Prometheus + Grafana (Open Source)

```bash
# Instalar kube-prometheus-stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install kube-prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.retention=30d \
  --set grafana.adminPassword=SENHA_SEGURA
```

### 4.3 Opção C: Observabilidade Ecofuturista (Recomendado)
Para manter o cluster leve ("Lightweight by Design"), não instalamos Grafana no cluster. Usamos o padrão **Local Dashboard**.

1.  **No Cluster:** O Prometheus coleta métricas silenciosamente (já incluso no `cluster-config`).
2.  **Na sua Máquina:** Rode o comando abaixo para visualizar:
    ```bash
    yby access
    ```
    Isso abrirá um Grafana local conectado ao cluster remoto via túnel seguro.

---

## 💾 5. Backup e Disaster Recovery

### 5.1 Backup de etcd (K3s)

Crie um CronJob para backup automático:

```yaml
# manifests/backup/etcd-backup-cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: etcd-backup
  namespace: kube-system
spec:
  schedule: "0 2 * * *"  # 2h da manhã, diariamente
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: rancher/k3s:v1.28.3-k3s1
            command:
            - /bin/sh
            - -c
            - |
              k3s etcd-snapshot save --name backup-$(date +%Y%m%d-%H%M%S) \
                --s3 --s3-bucket=yby-backups --s3-region=us-east-1
            volumeMounts:
            - name: etcd-data
              mountPath: /var/lib/rancher/k3s/server/db
          volumes:
          - name: etcd-data
            hostPath:
              path: /var/lib/rancher/k3s/server/db
          restartPolicy: OnFailure
```

### 5.2 Restore de Backup

```bash
# Parar K3s
sudo systemctl stop k3s

# Restaurar snapshot
sudo k3s server \
  --cluster-reset \
  --cluster-reset-restore-path=/var/lib/rancher/k3s/server/db/snapshots/backup-20250123-020000

# Reiniciar K3s
sudo systemctl start k3s
```

---

## 🛡️ 6. Segurança

### 6.1 NetworkPolicy (Isolar Namespaces)

```yaml
# manifests/security/default-deny-all.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: apps
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: apps
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53
```

### 6.2 Whitelist de IPs (Traefik)

Edite `config/cluster-values.yaml`:

```yaml
ingress:
  allowedIPs:
    - "203.0.113.0/24"  # Exemplo: IPs da VPN
    - "198.51.100.42/32"  # IP específico
```

### 6.3 RBAC para Argo CD

Restrinja acesso ao Argo CD apenas para admins:

```yaml
# charts/cluster-config/templates/argocd-rbac.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
data:
  policy.default: role:readonly
  policy.csv: |
    p, role:admin, applications, *, */*, allow
    p, role:admin, clusters, get, *, allow
    g, admin@seu-dominio.com, role:admin
```

---

## ⚡ 7. Escalabilidade e Performance

### 7.1 Resource Limits

Defina limites para todas as aplicações:

```yaml
# infra/deployment.yaml (exemplo)
resources:
  limits:
    cpu: "1000m"
    memory: "512Mi"
  requests:
    cpu: "100m"
    memory: "128Mi"
```

### 7.2 Horizontal Pod Autoscaler

```yaml
# infra/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: minha-app-hpa
  namespace: apps
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: minha-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### 7.3 Eficiência Energética (KEDA)

O **KEDA** já vem instalado para desligar ambientes de desenvolvimento à noite.

**Exemplo de ScaledObject:**
```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: scale-to-zero
spec:
  scaleTargetRef:
    name: my-deployment
  triggers:
  - type: cron
    metadata:
      timezone: America/Sao_Paulo
      start: 0 20 * * *        # Desliga as 20h
      end: 0 8 * * *          # Liga as 08h
      desiredReplicas: "0"
```

---

## 🚀 8. Deploy Final

### 8.1 Validação Pré-Deploy

```bash
# Validar configuração
yby validate

# Testar rendering dos charts
helm template bootstrap charts/bootstrap -f config/cluster-values.yaml | kubectl apply --dry-run=client -f -
```

### 8.2 Executar Bootstrap

```bash
# Produção (VPS remoto)
./scripts/bootstrap-cluster.sh prod

# Ou manualmente
helm upgrade --install bootstrap charts/bootstrap \
  -f config/cluster-values.yaml \
  --namespace argocd \
  --create-namespace \
  --wait
```

### 8.3 Verificar Status

```bash
# Verificar apps do Argo CD
kubectl get applications -n argocd

# Verificar pods
kubectl get pods -A

# Verificar certificados TLS
kubectl get certificate -A

# Acessar Argo CD
kubectl port-forward -n argocd svc/argocd-server 8080:80
# https://localhost:8080 (admin / kubectl -n argocd get secret...)
```

---

