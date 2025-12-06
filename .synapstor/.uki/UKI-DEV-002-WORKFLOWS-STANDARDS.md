---
uki_id: UKI-DEV-002
titulo: Padrões para Workflows (Argo Workflows)
status: draft
criado_em: 2025-11-20
autor: Agent UKI-Capture
tags: [dev, argo-workflows, padroes, gitops]
---

# Contexto
Workflows heterogêneos dificultam manutenção e auditoria. Adotar um conjunto de padrões para definir `WorkflowTemplate`, `Workflow` e `CronWorkflow` promove legibilidade e previsibilidade, e previne ações imperativas fora do Argo CD.

# Decisão/Regra
1. **Templates Reutilizáveis:** Preferir `WorkflowTemplate` para lógica reutilizável e `CronWorkflow` para rotinas periódicas.
2. **DAG Declarativa:** Usar `dag` com tarefas nomeadas e dependências explícitas; separar `analyze`, `lint`, `test`, `deploy`, `verify`, `notify`.
3. **Labels Padronizados:** Incluir `project`, `workflow-type` e `triggered-by` em `metadata.labels` quando aplicável.
4. **Service Account:** Usar `serviceAccountName: argo-workflow-executor` para execuções padrão.
5. **Parâmetros:** Nomear parâmetros com `git-*` para origem de código e evitar hardcode; usar `arguments.parameters`.
6. **Side Effects:** Operações de deploy devem usar Argo CD (`argocd app sync`) em vez de `kubectl apply` direto sobre apps gerenciados.

# Consequências
- **Pros:** Padronização, melhor troubleshooting, compatibilidade com políticas.
- **Cons:** Leve overhead inicial para adequar workflows existentes.
- **Ações:** Documentar exemplos mínimos e validar com `kubeconform`.

# Referências
- `/home/neto/projects/yby/charts/bootstrap/templates/workflows/cluster-self-config.yaml`
- `/home/neto/projects/yby/charts/bootstrap/templates/test-workflows/test-full-stack.yaml`
- `/home/neto/projects/yby/charts/bootstrap/templates/test-workflows/validate-stack.yaml`