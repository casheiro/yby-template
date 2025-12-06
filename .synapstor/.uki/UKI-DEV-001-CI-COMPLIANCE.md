---
uki_id: UKI-DEV-001
titulo: CI de Compliance Declarativa
status: draft
criado_em: 2025-11-20
autor: Agent UKI-Capture
tags: [ci, compliance, gitops, argo-workflows, helm]
---

# Contexto
Mudanças no repositório precisam passar por validações automatizadas para garantir conformidade com GitOps e integridade dos manifestos. Scripts imperativos para lint/validação criam divergência do estado desejado e são frágeis. Centralizar validações como objetos K8s/Argo Workflows e como parte do Helm Chart de bootstrap aumenta reprodutibilidade e evita desvios.

# Decisão/Regra
1. **Validações como Workflows:** Definir validações de compliance como `WorkflowTemplate` e `CronWorkflow` dentro do chart `charts/bootstrap`.
2. **Ciclo Periódico:** Executar um `CronWorkflow` noturno para validações recorrentes de templates/manifests.
3. **Gatilho Manual/CI:** Permitir invocação de `WorkflowTemplate` de compliance via CI ou Argo Events, sempre de forma declarativa.
4. **Helm + Kubeconform:** Em CI, usar `helm template` e validadores (ex.: `kubeconform`) apontando para os templates do chart, sem scripts que mutem YAML.
5. **Sem Shell Ad‑hoc:** Não usar scripts fora de controle para validar; todo fluxo deve viver como recursos versionados ou targets de `Makefile` reprodutíveis.

# Consequências
- **Pros:** Reprodutibilidade, auditoria, menor acoplamento a ambiente, padronização de checks.
- **Cons:** Requer Argo Workflows instalado e permissões adequadas; validações podem aumentar tempo de pipeline.
- **Follow‑ups:** Integrar jobs de CI com os templates; padronizar mensagens e artefatos de saída.

# Referências
- `/home/neto/projects/yby/charts/bootstrap/templates/workflows/compliance-validate.yaml`
- `/home/neto/projects/yby/charts/bootstrap/templates/workflows/compliance-cron.yaml`
- `/home/neto/projects/yby/charts/bootstrap/values.yaml`