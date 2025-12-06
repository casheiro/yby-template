# UKI-OPS-008-DOCUMENTACAO-MINIMALISTA

**Status**: `active`
**Domínio**: Operações
**Tags**: `documentacao`, `makefile`, `minimalismo`
**Criado em**: 2025-11-22
**Última atualização**: 2025-11-22

## Contexto
A auditoria radical do Makefile removeu ~50 targets obsoletos, wrappers e comandos que violavam GitOps. A documentação do projeto ainda contém referências a esses targets, gerando inconsistência e confusão para novos usuários.

## Decisão
Documentação deve ser alinhada ao Makefile minimalista, mantendo apenas referências a comandos essenciais e instruções para usar scripts de criação de Sealed Secrets.

## Consequências
- **Pró:** Redução de ruído, clareza nas instruções, menor risco de usuários executarem comandos inexistentes.
- **Contra:** Necessidade de atualizar múltiplos arquivos de docs; usuários habituados a antigos comandos precisarão adaptar-se.

## Ações
1. Atualizar `README.md` e arquivos em `docs/` removendo referências a targets removidos.
2. Inserir notas explicativas sobre uso direto de `git`, `kubectl`, `helm`.
3. Atualizar seções de *Deploy* e *Setup* para refletir novos fluxos (`make dev`, `make helm-bootstrap`, `make deploy-remote`).
4. Referenciar scripts `scripts/create-*-sealed-secret.sh` ao invés de targets `datadog-seal` etc.
5. Revisão por persona Arquiteto antes de merge.
