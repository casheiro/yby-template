---
uki_id: UKI-SEC-003
titulo: Argo CD interno com --insecure e gRPC‑Web
status: active
criado_em: 2025-11-21
autor: Agent UKI-Capture
tags: [seguranca, argocd, grpc-web]
---

# Contexto
O servidor Argo CD está configurado para aceitar tráfego interno sem TLS e habilitar gRPC‑Web para compatibilidade com automações e CLI. Workflows realizam `argocd login` com `--insecure`, montando o secret inicial do Argo CD. Isso simplifica o bootstrap, porém requer controles de exposição.

# Decisão/Regra
1. Permitir `--insecure` e `--enable-grpc-web` apenas para acesso interno no cluster.
2. É proibido expor o serviço Argo CD externamente sem TLS; qualquer acesso externo deve ocorrer via Ingress/TLS.
3. Automação deve usar o endpoint interno `argocd-server.argocd.svc.cluster.local:80` e credenciais dedicadas pós‑bootstrap.
4. Revisar periodicamente a configuração e telemetria de acesso.

# Consequências
- Pros: Facilita automação e compatibilidade do CLI; reduz complexidade de bootstrap.
- Cons: Risco se exposto externamente sem TLS; exige controles de rede, auditoria e revisão.

# Referências
- `cluster-config/base/argocd/kustomization.yaml:33-34`
- `workflows/templates/deploy-workflow.yaml:133-137`
- `workflows/infrastructure/rollback-workflow.yaml:191`
- `charts/bootstrap/templates/events/sensor.yaml:141`
 - Relacionados: `UKI-ARCH-007-ARGOCD-SYNCPOLICY-STANDARD.md`, `UKI-SEC-004-ARGOCD-AUTOMATION-CREDENTIALS.md`