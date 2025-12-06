---
uki_id: UKI-DEV-003
titulo: Convenções de Helm Values (Bootstrap)
status: draft
criado_em: 2025-11-20
autor: Agent UKI-Capture
tags: [helm, values, configuracao, gitops]
---

# Contexto
Valores inconsistentes e sem padrão dificultam manutenção e integração. O chart `bootstrap` concentra configuração crítica de Argo CD e Argo Events e deve seguir convenções estáveis para chaves e comportamento.

# Decisão/Regra
1. **Chaves Principais:**
   - `repoURL`, `targetRevision`, `project`.
   - `argocd.namespace`, `argocd.project`, `argocd.destinationServer`.
   - `events.eventbus.replicas`, `events.eventbus.storageClass`.
   - `events.webhook.port`, `events.webhook.serviceType`, `events.webhook.nodePort`.
   - `events.sensor.ref`, `events.sensor.repoName`.
2. **Fonte Única:** Toda parametrização do bootstrap deve ocorrer via `values.yaml` ou `--set`; não editar templates diretamente.
3. **Tipos e Defaults:** Manter tipos coerentes (números para portas, strings para refs) e defaults seguros no `values.yaml`.
4. **Documentação Inline:** Comentar valores sensíveis com implicações operacionais (ex.: `NodePort`).

# Consequências
- **Pros:** Previsibilidade, menor risco de drift, fácil automação.
- **Cons:** Eventuais mudanças de layout em valores exigem releases versionados do chart.
- **Ações:** Validar `values.yaml` em CI e documentar exemplos por ambiente.

# Referências
- `/home/neto/projects/yby/charts/bootstrap/values.yaml`
- `/home/neto/projects/yby/charts/bootstrap/templates/root-app.yaml`
- `/home/neto/projects/yby/charts/bootstrap/templates/infrastructure-apps.yaml`