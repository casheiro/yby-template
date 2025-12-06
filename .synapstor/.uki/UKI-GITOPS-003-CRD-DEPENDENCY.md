---
uki_id: UKI-GITOPS-003
title: Dependência de CRDs em Bootstrap
status: active
tags: [gitops, kubernetes, bootstrap]
creation_date: 2025-11-27
---

# Contexto
Em arquiteturas GitOps, a instalação de CRDs (Custom Resource Definitions) e dos recursos que os utilizam frequentemente ocorre em paralelo, gerando condições de corrida e falhas de sync (`no matches for kind`).

# Regra
Scripts ou pipelines de bootstrap **DEVEM** conter bloqueios explícitos (`kubectl wait`) garantindo que os CRDs estejam no estado `Established` antes de prosseguir para a aplicação dos recursos dependentes.

# Implementação
```bash
kubectl wait --for condition=established --timeout=60s crd/<crd-name>
```
