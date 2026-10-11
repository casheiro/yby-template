# Especificação de UKI (Unidade de Conhecimento Interligada)

## O que é uma UKI?
Uma UKI é um arquivo Markdown que captura uma regra, decisão, padrão ou conhecimento durável do projeto.

## Estrutura do ID
Formato: `UKI-<DOMINIO>-<NUMERO>`
Exemplos:
- `UKI-ARCH-001`: Decisão de Arquitetura
- `UKI-DEV-002`: Padrão de Desenvolvimento
- `UKI-OPS-003`: Procedimento Operacional

## Localização
Todas as UKIs ficam em `.synapstor/.uki/`.

## Template
```markdown
---
uki_id: UKI-DOM-000
titulo: Título Curto e Descritivo
status: [draft | active | deprecated]
criado_em: YYYY-MM-DD
autor: Persona/Nome
tags: [tag1, tag2]
---

# Contexto
Por que essa regra existe? Qual o problema?

# Decisão/Regra
O que foi decidido? O que deve ser seguido?

# Consequências
O que ganhamos e o que perdemos (trade-offs)?

# Referências
Links para docs, issues ou commits.
```
