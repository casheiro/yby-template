# UKI-OPS-004-REMAINING-MIGRATION

**Contexto**
Durante a fase final da migração do projeto `yby`, ainda restam vários scripts shell que não foram convertidos para recursos declarativos. Esses scripts se enquadram em três categorias:

1. **Ferramentas de desenvolvimento** (ex.: `check-dev-requirements.sh`, `setup-local-dev.sh`, `k3d-dev-adapter.sh`).
2. **Operações de cluster** (ex.: `cluster-status-checker.sh`, `diagnose-environment.sh`, `show-webhook-config.sh`).
3. **Testes e validações** (ex.: `test-full-stack-cycle.sh`, `validate-full-stack.sh`, `test-config.sh`).

**Decisão**
> Migrar todos os scripts das categorias 2 e 3 para recursos Kubernetes declarativos (WorkflowTemplates, Jobs ou CronJobs) e manter a categoria 1 como DevTools, integrando‑as ao `Makefile`.

**Consequências**
- **Prós**: aderência total ao modelo GitOps, eliminação de dependências de acesso manual ao cluster, auditabilidade.
- **Contras**: necessidade de criar pipelines CI para validar a execução dos novos recursos.

**Status**
- **active** – a migração está em andamento e será detalhada no `implementation_plan.md`.
