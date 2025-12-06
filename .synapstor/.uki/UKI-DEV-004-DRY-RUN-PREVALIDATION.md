---
uki_id: UKI-DEV-004
titulo: Pré‑validação com kubectl apply --dry‑run
status: active
criado_em: 2025-11-21
autor: Agent UKI-Capture
tags: [dev, gitops, validacao]
---

# Contexto
O pipeline de infraestrutura executa pré‑validação de manifests com `kubectl apply --dry-run=client -k` em um namespace de staging, sem mutar o estado desejado, alinhando‑se ao princípio de GitOps Radical.

# Decisão/Regra
1. Permitir uso de `kubectl` imperativo somente com `--dry-run` para validação e nunca para aplicar mudanças reais.
2. Pré‑validações devem ocorrer em ambientes isolados de staging e alimentar relatórios.

# Consequências
- Pros: Feedback rápido sem drift; maior confiança antes do sync pelo Argo CD.
- Cons: Pode divergir em casos de validação incompleta; requer disciplina de uso.

# Referências
- `workflows/events/infrastructure-sensor.yaml:151-157`
 - Relacionados: `UKI-ARCH-001-GITOPS-RADICAL.md`