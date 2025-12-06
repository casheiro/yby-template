---
uki_id: UKI-ARCH-011
titulo: Convenção de Nomes das Apps de Infraestrutura (Argo CD)
status: active
criado_em: 2025-11-21
autor: Agent UKI-Capture
tags: [arquitetura, argocd, padroes]
---

# Contexto
Automação de deploy referencia aplicações de infraestrutura por nomes fixos, simplificando sincronizações e verificações.

# Decisão/Regra
1. Padronizar nomes de apps de infraestrutura: `namespaces`, `sealed-secrets`, `traefik`, `datadog`, `minio`, `grafana`.
2. Toda alteração de nomenclatura deve ser refletida em pipelines e documentação.

# Consequências
- Pros: Facilita automações e auditoria; reduz ambiguidade.
- Cons: Acoplamento entre automação e nomenclatura; exige governança em mudanças.

# Referências
- `workflows/events/infrastructure-sensor.yaml:176-193`
- `argo-applications/infrastructure-app.yaml:1-40`
 - Relacionados: `UKI-ARCH-003-APP-OF-APPS.md`, `UKI-ARCH-007-ARGOCD-SYNCPOLICY-STANDARD.md`