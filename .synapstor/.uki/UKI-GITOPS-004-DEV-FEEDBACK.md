---
uki_id: UKI-GITOPS-004
title: Otimização de Feedback Loop em Dev
status: active
tags: [gitops, dev-experience, productivity]
creation_date: 2025-11-27
---

# Contexto
O modelo de "Polling" do Argo CD (padrão 3 min) é aceitável para produção, mas introduz uma latência inaceitável para o ciclo de desenvolvimento "Code -> Deploy -> Test".

# Regra
Em ambientes de desenvolvimento, o pipeline de deploy ou scripts de conveniência (`make dev`, `make deploy`) **DEVEM** incluir um gatilho de sincronização forçada (Webhook call ou CLI force-sync) para eliminar a latência de polling. O desenvolvedor não deve ter que esperar ou clicar em "Refresh" manualmente na UI.
