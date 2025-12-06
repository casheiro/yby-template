---
uki_id: UKI-ARCH-007
titulo: Padrão de SyncPolicy no Argo CD
status: active
criado_em: 2025-11-21
autor: Agent UKI-Capture
tags: [arquitetura, argocd, gitops]
---

# Contexto
Aplicações Argo CD adotam políticas de sincronização automatizadas com `prune` e `selfHeal`, criação automática de namespace e políticas de retry com backoff. Padronizar aumenta previsibilidade e segurança de reconciliação.

# Decisão/Regra
1. Adotar `automated` com `prune: true` e `selfHeal: true` como padrão.
2. Incluir `syncOptions: CreateNamespace=true` e políticas de `retry` consistentes.
3. Definir `revisionHistoryLimit` adequado para controle de histórico.

# Consequências
- Pros: Reconciliação consistente; autocorreção de drift; menor intervenção manual.
- Cons: Risco de remoções em cascata com `prune`; requer governança cuidadosa em apps críticos.

# Referências
- `charts/bootstrap/templates/root-app.yaml:24-31`
- `charts/bootstrap/templates/infrastructure-apps.yaml:72-86`
- `argo-applications/workflows-app.yaml:21-26`
 - Relacionados: `UKI-ARCH-003-APP-OF-APPS.md`, `UKI-ARCH-004-HELM-BOOTSTRAP.md`