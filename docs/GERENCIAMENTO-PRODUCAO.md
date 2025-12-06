# Guia de Gerenciamento de Cluster em Produção

> ℹ️ **Nota de Escopo:** Este documento foca em **operações diárias** (acesso, troubleshooting básico).
> Para o setup inicial, hardening de segurança e checklist de Go-Live, consulte o **[Guia de Produção](PRODUCAO-GUIDE.md)**.

Este guia descreve as operações padrão para gerenciar o **Yby** em ambiente de produção (VPS/Cloud).

## 1. Provisionamento Inicial

### Pré-requisitos
- Servidor VPS com Ubuntu 22.04+ ou Debian 11+
- Acesso SSH root
- Portas 80, 443, 6443 liberadas

### Execução
1. Configure o arquivo `.env` localmente:
   ```bash
   echo "VPS_HOST=x.x.x.x" >> .env
   echo "VPS_USER=root" >> .env
   ```

2. Execute o script de provisionamento:
   ```bash
   ./scripts/provision-vps.sh
   ```
   *Este script instala Docker, K3s, Firewall e configura seu `kubectl` local.*

3. Instale a stack GitOps:
   ```bash
   ./scripts/bootstrap-cluster.sh prod
   ```

---

## 2. Acesso e Operação

### Conectando ao Cluster
O script de provisionamento já configura seu contexto. Para alternar manualmente:
```bash
kubectl config use-context yby
```

### Acessando Painéis (Port-Forward)
Como medida de segurança, os painéis administrativos não são expostos publicamente por padrão. Use port-forward:

**Argo CD:**
```bash
kubectl -n argocd port-forward svc/argocd-server 8080:443
# Acesso: https://localhost:8080
# User: admin
# Admin Password
# Obtida via comando helper
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

## Headlamp (Dashboard)
# Acesso local via proxy
yby access
# http://localhost:4466

---

## 3. Fluxo de Deploy (GitOps)

**NUNCA** faça alterações manuais no cluster (`kubectl edit`, `kubectl apply`).
Toda alteração deve passar pelo Git.

### Atualizar Infraestrutura
1. Edite `config/cluster-values.yaml` ou os charts em `charts/`.
2. Commit e Push para `main`.
3. O Argo CD sincronizará automaticamente (Self-Healing).

### Adicionar Aplicações
1. Crie um novo repositório no GitHub com pasta `infra/`.
2. Adicione o tópico `yby-app`.
3. O Argo CD detectará e fará o deploy (Zero-Touch).

---

## 4. Troubleshooting

### Cluster Inacessível
1. Verifique se o VPS está online: `ping $VPS_HOST`
2. Verifique o serviço K3s via SSH:
   ```bash
   ssh root@$VPS_HOST "systemctl status k3s"
   ```

### Argo CD Fora de Sincronia
Se o Argo CD travar ou não sincronizar:
1. Reinicie o controller:
   ```bash
   kubectl -n argocd rollout restart deployment argocd-application-controller
   ```
2. Force uma sincronização via CLI:
   ```bash
   argocd app sync --all
   ```

### Recuperação de Segredos
Se perder o acesso, recupere a senha de admin do Argo CD:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret ...
```

---

## 5. Restrição de IP (Segurança)

Para restringir o acesso aos Ingress públicos (se houver) apenas para IPs da VPN:

1. Edite `charts/cluster-config/templates/ingress/kustomization.yaml` (ou equivalente no chart).
2. Atualize a lista `ALLOWED_IPS`.
3. Commit e Push.