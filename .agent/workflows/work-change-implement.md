---
description: Executar a implementação de forma segura e incremental
---

# Workflow: Work Change Implement

**Objetivo:** Traduzir o plano em código funcional.

## Quando usar
- Após aprovação do plano em `work-solution-design`.

## Passos

1. **Setup**
   - Garanta que o ambiente local está limpo (`make clean` se necessário).
   - Crie branch/ambiente isolado se aplicável.

2. **Ciclo de Codificação**
   - Implemente em pequenos incrementos.
   - A cada passo, verifique se quebrou algo básico.

3. **Verificação Local**
   - Rode testes unitários/lints.
   - Use `make dev` ou `make deploy-local` para validar.

4. **Documentação**
   - Atualize comentários no código.
   - Atualize docs de usuário se a feature mudar comportamento.
