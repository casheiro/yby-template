---
uki_id: UKI-OPS-001
titulo: Estrutura de Diretórios (Config vs Delivery)
status: active
criado_em: 2025-11-20
autor: Persona Arquiteto
tags: [operações, estrutura, padronização]
---

# Contexto
Para manter a organização e clareza sobre "o que é a aplicação" vs "como a aplicação é entregue", separamos as definições de recursos das definições de entrega contínua.

# Decisão/Regra
1. **`cluster-config/` (O QUE):** Contém a definição pura dos recursos Kubernetes (Deployments, Services, ConfigMaps).
   - Usa Kustomize (`base/` e `overlays/` se necessário).
   - É agnóstico à ferramenta de CD (poderia ser aplicado com `kubectl apply -k`).
2. **`charts/bootstrap/` (COMO):** Contém a definição de entrega e bootstrap.
   - Substitui o antigo diretório `manifests/applications/`.
   - Gerencia Argo CD Applications, Argo Events e configurações iniciais.
3. **`manifests/` (LEGADO/REMOVIDO):** Antigo diretório de entrega, substituído pelo Helm Chart.

# Consequências
- **Pros:**
  - Separação de responsabilidades.
  - Facilita reutilização de bases Kustomize.
- **Cons:**
  - Navegação entre dois diretórios para entender o fluxo completo de uma app.

# Referências
- Estrutura atual do repositório.
