---
description: Análise inicial de uma demanda complexa
---

# Workflow: Work Discovery

**Objetivo:** Entender profundamente o problema antes de propor solução.

## Quando usar
- Novas features complexas.
- Bugs difíceis de reproduzir.
- Refatorações grandes.

## Passos

1. **Coleta de Dados**
   - Leia a solicitação do usuário.
   - Execute `uki-discover` para contexto.
   - Leia o código atual relacionado.

2. **Análise de Impacto**
   - Quais componentes serão afetados?
   - Existe risco de quebrar algo (regressão)?
   - Fere algum princípio (ex: GitOps)?

3. **Definição do Problema**
   - Reescreva o problema com suas palavras.
   - Confirme com o usuário se o entendimento está correto.

4. **Saída**
   - Um resumo claro do problema e restrições, pronto para o Design de Solução.
