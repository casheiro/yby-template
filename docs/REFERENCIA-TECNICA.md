# Referência Técnica

Este documento fornece detalhes profundos sobre a configuração do cluster (`cluster-values.yaml`) e operações manuais para garantir o princípio de **Zero Lock-in**.

---

## 1. Configuração Centralizada (`cluster-values.yaml`)

Este é o arquivo que define o estado desejado do seu cluster. O `yby init` o gera, mas você pode editá-lo livremente.

### Tabela de Referência Rápida

| Chave | Padrão | Descrição |
|-------|--------|-----------|
| `global.environment` | `dev` | Ambiente (dev, staging, prod) |
| `global.domainBase` | `yby.local` | Domínio raiz do cluster |
| `git.repoURL` | - | URL do seu repositório Git |
| `discovery.enabled` | `true` | Ativa Argo CD ApplicationSet |
| `security.networkPolicy.enabled` | `false` | Bloquear tráfego entre namespaces |
| `ingress.whitelist.enabled` | `false` | Restringir acesso a serviços administrativos |
| `observability.mode` | `prometheus` | Stack de monitoramento (`none` ou `prometheus`) |
| `system.k3s.version` | `v1...` | Versão do K3s usada no bootstrap |

### Whitelist de IPs
Para restringir acesso ao ArgoCD, Grafana e MinIO Console apenas para sua VPN/Escritório:

```yaml
ingress:
  whitelist:
    enabled: true
    sourceRanges:
      - 200.1.2.3/32  # IP do Escritório
      - 10.0.0.0/8    # VPN
```

---

## 2. Guia Zero Lock-in (Operação Manual)

A **Yby CLI** é um facilitador. Tudo o que ela faz pode ser replicado com ferramentas padrão (`kubectl`, `helm`). Abaixo, o "De-para" dos comandos.

### `yby bootstrap cluster`
Equivale a instalar o Argo CD via Helm e aplicar o App of App.

**Manual:**
```bash
# 1. Instalar Argo CD
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd --create-namespace --version 5.51.6

# 2. Aplicar Root App
kubectl apply -f manifests/argocd/root-app.yaml
```

### `yby secret webhook`
Equivale a criar um Secret Kubernetes e sela-lo com `kubeseal`.

**Manual:**
```bash
# 1. Gerar Secret
kubectl create secret generic github-webhook-secret --from-literal=secret=MEU_SEGREDO -n argo-events --dry-run=client -o yaml > secret.yaml

# 2. Selar
kubeseal < secret.yaml > charts/cluster-config/templates/events/sealed-secret-github.yaml
```

### `yby access`
Equivale a rodar múltiplos `kubectl port-forward`.

**Manual:**
```bash
kubectl -n argocd port-forward svc/argocd-server 8080:80
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
```

### `yby validate`
Equivale a rodar linters do Helm.

**Manual:**
```bash
helm lint charts/bootstrap -f config/cluster-values.yaml
helm template charts/bootstrap -f config/cluster-values.yaml
```
