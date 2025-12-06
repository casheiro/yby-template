---
uki_id: UKI-GOV-001
titulo: Governança de Documentação (UKI & Logs)
status: draft
criado_em: 2025-11-20
autor: Agent UKI-Capture
tags: [governanca, documentacao, uki, logs]
---

# Contexto
A memória institucional do projeto vive em `.synapstor/` e precisa de regras claras para criação, revisão e evolução de documentos. Sem governança, decisões são rediscutidas e o conhecimento se perde.

# Decisão/Regra
1. **UKI como Fonte:** Toda decisão/padrão durável deve ser formalizada como UKI seguindo `UKI_SPEC.md`.
2. **Status:** Fluxo `draft -> active -> deprecated` condicionado a revisão por stakeholders (arquitetos/operadores).
3. **Log Append‑Only:** `01_EXECUTION_LOG.md` é append‑only e registra intervenções relevantes; nunca apagar histórico.
4. **Review Obrigatória:** Antes de marcar `active`, solicitar revisão explícita e registrar no log.
5. **Descoberta:** Nomear UKIs com domínio adequado e título descritivo; taggear; referenciar artefatos de código com caminhos absolutos.
6. **Manutenção:** Atualizar/arquivar UKIs quando circunstâncias mudarem; manter relação entre UKIs correlatas.

# Consequências
- **Pros:** Redução de retrabalho, auditabilidade, alinhamento entre código e decisão.
- **Cons:** Demanda disciplina de atualização; pode exigir tempo de revisão.
- **Ações:** Criar índices e catálogos quando a quantidade crescer; automatizar checagens básicas.

# Referências
- `/home/neto/projects/yby/.synapstor/UKI_SPEC.md`
- `/home/neto/projects/yby/.synapstor/01_EXECUTION_LOG.md`