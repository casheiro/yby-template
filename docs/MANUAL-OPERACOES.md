# Manual de Operações (Day 2)

Este guia cobre a administração contínua, deployment de aplicações e resolução de problemas no cluster Yby.

## 1. Acesso e Monitoramento

### Acessando Painéis (Seguro)
O comando `yby access` abre túneis seguros para todos os serviços internos.

```bash
yby access
```
*   **Argo CD**: Gestão de GitOps.
*   **Grafana**: Métricas e dashboards.

### Acesso via CLI
Para alternar o contexto do `kubectl` para seu cluster de produção:
```bash
# O yby bootstrap vps já configura isso, mas se precisar:
export KUBECONFIG=~/.kube/config
kubectl config use-context yby-prod
```

---

## 2. Fluxo de GitOps

**Regra de Ouro**: Nunca edite recursos manualmente (`kubectl edit`). Toda mudança deve vir do Git.

### Atualizar Infraestrutura
1.  Edite `config/cluster-values.yaml`.
2.  Commit e Push.
3.  O Argo CD sincronizará automaticamente.

### Publicar Nova Aplicação
O Yby usa **Zero-Touch Discovery**. Para criar um novo app:
1.  Crie um repositório no GitHub.
2.  Adicione a pasta `infra/` com seus manifestos (Deployment, Service, Ingress).
3.  Adicione o tópico `yby-app` nas configurações do repositório (ícone de engrenagem ao lado de "About").
4.  O Argo CD detectará o app e fará o deploy.

---

## 3. Guia de Manifestos (Receitas de Bolo)

Ao criar seu app na pasta `infra/`, siga estes padrões.

### Exemplo Base (Genérico)
```yaml
# infra/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata: { name: meu-app, namespace: apps }
spec:
  replicas: 2
  selector: { matchLabels: { app: meu-app } }
  template:
    metadata: { labels: { app: meu-app } }
    spec:
      containers:
      - name: main
        image: ghcr.io/seu-user/meu-app:latest
        ports: [{ containerPort: 8080 }]
        readinessProbe: { httpGet: { path: /health, port: 8080 } }
        resources:
          limits: { memory: "256Mi", cpu: "500m" }
          requests: { memory: "128Mi", cpu: "100m" }
---
# infra/service.yaml
apiVersion: v1
kind: Service
metadata: { name: meu-app-svc, namespace: apps }
spec:
  ports: [{ port: 80, targetPort: 8080 }]
  selector: { app: meu-app }
---
# infra/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata: 
  name: meu-app
  namespace: apps
  annotations:
    traefik.ingress.kubernetes.io/router.tls: "true"
    traefik.ingress.kubernetes.io/router.tls.certresolver: letsencrypt
spec:
  ingressClassName: traefik
  rules:
  - host: app.seudominio.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend: { service: { name: meu-app-svc, port: { number: 80 } } }
```

> **Linguagens Específicas**: Para exemplos de Java, Node.js, Python e Go, consulte o histórico do repositório template ou adapte as portas (`8080` vs `3000`).

---

## 4. Webhooks e CI/CD Instantâneo

Por padrão, o Argo CD verifica mudanças a cada 3 minutos. Para deploys instantâneos (Push-to-Deploy), configure o Webhook.

### Setup Automático
1.  Obtenha o segredo do webhook:
    ```bash
    yby webhook show
    ```
2.  No GitHub do seu repositório de App (ou Organização):
    *   **Settings -> Webhooks -> Add webhook**
    *   Payload URL: `http://SEU_IP:30012/github`
    *   Content Type: `application/json`
    *   Secret: (Cole o segredo)
    *   Events: `Push events`

---

## 5. Rotinas de Manutenção

### Backup do Etcd (K3s)
O K3s faz snapshots automáticos. Para configurar backup para S3, edite o cronjob em `manifests/backup/etcd-backup-cronjob.yaml` (se disponível no template) ou configure via script.

### Troubleshooting Comum
*   **Argo CD Travado**: `kubectl -n argocd rollout restart deployment argocd-application-controller`
*   **Certificado não renova**: Verifique logs do Cert-Manager: `kubectl logs -n cert-manager -l app=cert-manager`
*   **App não aparece**: Verifique se o repo tem o tópico `yby-app` e se o token do GitHub no cluster é válido (`kubectl get secret github-token -n argocd`).

### IssueOps (Click-to-Cluster)
Este template suporta criação de novos clusters via Issues do GitHub.
1.  Configure o secret `GH_PAT_REPO_CREATION` no repo template.
2.  Abra uma Issue "Solicitar Novo Cluster".
3.  Aprove com a label `ops:approved`.
