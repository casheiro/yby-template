---
uki_id: UKI-ARCH-006
titulo: Webhooks do Argo Events via NodePort
status: active
criado_em: 2025-11-21
autor: Agent UKI-Capture
tags: [arquitetura, argo-events, rede]
---

# Contexto
O `EventSource` para webhooks (GitHub/GitLab) é exposto via NodePort fixo, com o firewall liberando o intervalo de NodePorts. Valores de porta e tipo de serviço são parametrizados no chart de bootstrap.

# Decisão/Regra
1. Expor webhooks via `NodePort` com porta fixa durante o bootstrap e ambientes sem DNS/TLS.
2. Quando DNS/TLS estiver disponível, migrar a exposição para Ingress com TLS.
3. Manter regras de firewall consistentes com o intervalo de NodePorts.

# Consequências
- Pros: Simplicidade de bootstrap, previsibilidade de porta.
- Cons: Maior superfície de exposição; necessidade de regras de rede bem definidas; migração futura para Ingress.

# Referências
- `charts/bootstrap/templates/events/eventsource.yaml:13-17`
- `charts/bootstrap/values.yaml:16-18`
- `charts/bootstrap/templates/workflows/cluster-self-config.yaml:86`
 - Relacionados: `UKI-DEV-003-HELM-VALUES-CONVENTIONS.md`, `UKI-SEC-002-INTEGRATION-SECRETS.md`