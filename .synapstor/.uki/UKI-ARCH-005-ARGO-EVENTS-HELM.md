---
uki_id: UKI-ARCH-005
titulo: Argo Events gerenciado via Helm
status: draft
criado_em: 2025-11-20
autor: Agent UKI-Capture
tags: [arquitetura, argo-events, helm, gitops]
---

# Contexto
Integrações por webhook (GitHub/GitLab) são responsáveis por acionar pipelines. Antes, scripts criavam componentes e segredos, gerando inconsistências e riscos. Padronizar EventBus, EventSource e Sensor como templates Helm reduz complexidade e reforça GitOps.

# Decisão/Regra
1. **Templates Helm:** `EventBus`, `EventSource` e `Sensor` residem em `charts/bootstrap/templates/events/` e são instalados via Helm.
2. **Parametrização:** Portas, `serviceType`, `nodePort`, `ref` e `repoName` são configurados por `values.yaml` (`.Values.events.*`).
3. **Filtros de Evento:** Sensores filtram por `ref` e `repoName` via valores, evitando execuções indevidas.
4. **Sem Scripts:** Não criar recursos de Argo Events via scripts; toda mudança acontece via commit e `helm upgrade --install`.
5. **Segurança:** Segredos de webhook são geridos por Sealed Secrets no mesmo namespace do `EventSource`.

# Consequências
- **Pros:** Consistência de implantação, facilidade de ajuste por valores, rastreabilidade.
- **Cons:** Requer atenção à compatibilidade de versões Argo Events/Helm; exposição NodePort precisa avaliação de rede.
- **Dependências:** `helm`, Argo Events e Sealed Secrets instalados.

# Referências
- `/home/neto/projects/yby/charts/bootstrap/templates/events/eventbus.yaml`
- `/home/neto/projects/yby/charts/bootstrap/templates/events/eventsource.yaml`
- `/home/neto/projects/yby/charts/bootstrap/templates/events/sensor.yaml`
- `/home/neto/projects/yby/charts/bootstrap/values.yaml`