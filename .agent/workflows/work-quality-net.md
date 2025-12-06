---
description: Malha de qualidade e verificação final
---

# Workflow: Work Quality Net

**Objetivo:** Garantir que a entrega atende aos padrões de qualidade antes do merge/conclusão.

## Quando usar
- Ao final da implementação (`work-change-implement`).

## Passos

1. **Checklist de Conformidade**
   - [ ] O código segue o style guide?
   - [ ] Passou em todos os linters?
   - [ ] Não há secrets hardcoded?
   - [ ] Respeita os princípios (GitOps, Reprodutibilidade)?

2. **Validação Funcional**
   - O problema original foi resolvido?
   - Os cenários de borda foram testados?

3. **Limpeza**
   - Remova logs de debug.
   - Remova arquivos temporários.

4. **Entrega**
   - Gere o `walkthrough.md` (evidência de funcionamento).
   - Notifique o usuário para revisão final.
