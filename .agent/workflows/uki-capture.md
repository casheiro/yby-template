---
description: Capturar novo conhecimento e transformar em UKI
---

# Workflow: UKI Capture

**Objetivo:** Formalizar uma decisão, padrão ou regra descoberta durante o trabalho.

## Quando usar
- Uma decisão arquitetural foi tomada.
- Um padrão de código foi definido.
- Uma regra de negócio foi esclarecida.

## Passos

1. **Rascunhar**
   - Crie um arquivo em `.synapstor/.uki/UKI-<DOMINIO>-<NUMERO>.md`.
   - Use o template definido em `.synapstor/UKI_SPEC.md`.

2. **Preencher**
   - **Contexto:** O problema que gerou a necessidade.
   - **Decisão:** A regra clara.
   - **Consequências:** Prós e contras.

3. **Validar**
   - Peça revisão do usuário (ou Persona Arquiteto).

4. **Publicar**
   - Mude status para `active`.
   - Adicione ao índice (se houver).
