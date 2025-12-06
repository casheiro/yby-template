---
uki_id: UKI-OPS-005
titulo: Estratégia de Rollback com Backup e Verificação
status: active
criado_em: 2025-11-21
autor: Agent UKI-Capture
tags: [operacoes, rollback, workflows]
---

# Contexto
O processo de rollback da infraestrutura realiza backup completo do estado antes da execução, segue ordem de dependências, verifica saúde pós‑rollback e inclui plano de emergência.

# Decisão/Regra
1. Sempre executar backup pré‑rollback (recursos críticos e apps Argo CD).
2. Aplicar rollback conforme revisão Git alvo e dependências.
3. Realizar verificação pós‑rollback e gerar relatório com trilha de auditoria.

# Consequências
- Pros: Resiliência operacional; capacidade de recuperação; auditoria clara.
- Cons: Overhead de tempo e armazenamento; maior complexidade do fluxo.

# Referências
- `workflows/infrastructure/rollback-workflow.yaml:137-166`
- `workflows/infrastructure/rollback-workflow.yaml:47-53`
- `workflows/infrastructure/rollback-workflow.yaml:334-362`
 - Relacionados: `UKI-ARCH-007-ARGOCD-SYNCPOLICY-STANDARD.md`, `UKI-ARCH-003-APP-OF-APPS.md`