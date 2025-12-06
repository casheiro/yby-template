---
uki_id: UKI-ARCH-009
titulo: Observabilidade com Datadog (Operator + Agent)
status: active
criado_em: 2025-11-21
autor: Agent UKI-Capture
tags: [arquitetura, observabilidade, datadog]
---

# Contexto
O Datadog Operator e o Datadog Agent são adotados para observabilidade, com recursos habilitados para APM, logs, kube state metrics core e orchestrator explorer. Credenciais gerenciadas via Sealed Secret.

# Decisão/Regra
1. Instalar Datadog Operator via Argo CD e configurar Agent com recursos essenciais.
2. Usar tags de `cluster` e `env` padronizadas; credenciais via `datadog-secret`.
3. Habilitar APM e coleta de logs nos nós e containers.

# Consequências
- Pros: Visibilidade abrangente; melhor troubleshooting; integração consolidada.
- Cons: Consumo de recursos e custos; necessidade de configuração cuidadosa.

# Referências
- `cluster-config/base/datadog-operator/datadog-agent.yaml:1`
- `cluster-config/base/datadog-operator/datadog-agent.yaml:17-21`
- `argo-applications/datadog-operator-app.yaml:12-31`
 - Relacionados: `UKI-SEC-001-SEALED-SECRETS.md`