---
uki_id: UKI-ARCH-001
titulo: GitOps Radical (Proibição de Deploys Imperativos)
status: active
criado_em: 2025-11-20
autor: Persona Arquiteto
tags: [arquitetura, gitops, segurança]
---

# Contexto
O projeto sofria com "drift" de configuração e falta de rastreabilidade devido ao uso misto de GitOps (Argo CD) e comandos imperativos (`kubectl apply`) no Makefile. Isso permitia que mudanças fossem aplicadas manualmente sem passar pelo Git, violando a fonte única de verdade.

# Decisão/Regra
1. **Proibição de `kubectl apply`:** É estritamente proibido usar `kubectl apply` para recursos de aplicação ou infraestrutura gerenciada, exceto durante o bootstrap inicial (antes do Argo CD existir).
2. **Fluxo Obrigatório:** Toda mudança deve ser commitada no Git (`cluster-config/`) e sincronizada pelo Argo CD.
3. **Makefile:** O Makefile deve fornecer apenas comandos de suporte ao GitOps (`gitops-commit`, `gitops-sync`), nunca comandos de deploy direto.

# Consequências
- **Pros:**
  - Rastreabilidade total (quem mudou o que e quando).
  - Capacidade de rollback instantâneo via Git.
  - Recuperação de desastres facilitada (cluster é descartável).
- **Cons:**
  - Ciclo de feedback ligeiramente mais lento (commit -> push -> sync) comparado ao apply direto.

# Referências
- Refatoração do Makefile (2025-11-20)
- Princípio "GitOps Radical" definido no Bootstrap.
