---
description: Descobrir e entender UKIs relevantes para uma tarefa
---

# Workflow: UKI Discover

**Objetivo:** Antes de iniciar qualquer trabalho, identificar quais Unidades de Conhecimento Inteligente (UKIs) se aplicam ao contexto.

## Quando usar
- Início de qualquer tarefa relevante.
- Dúvidas sobre regras de negócio ou padrões.

## Passos

1. **Buscar Contexto**
   - Leia `.synapstor/00_PROJECT_OVERVIEW.md`.
   - Liste arquivos relacionados à tarefa.

2. **Identificar UKIs**
   - Procure em `.synapstor/.uki/` por arquivos com tags relevantes (ex: `auth`, `deploy`, `k3s`).
   - Se não houver UKIs, verifique `.synapstor/02_BACKLOG_AND_DEBT.md` para ver se há dívida de documentação.

3. **Sintetizar Regras**
   - Liste as regras que devem ser seguidas.
   - Se houver conflito entre o pedido do usuário e uma UKI, alerte o usuário.

4. **Resultado**
   - Um resumo das restrições e guias para a tarefa atual.
