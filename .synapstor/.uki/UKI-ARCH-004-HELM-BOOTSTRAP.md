---
uki_id: UKI-ARCH-004
titulo: Bootstrap via Helm Chart
status: active
criado_em: 2025-11-20
autor: Persona Arquiteto
tags: [arquitetura, helm, bootstrap, gitops]
---

# Contexto
O bootstrap inicial do cluster exige a aplicação de manifestos que dependem de variáveis de ambiente (como a URL do repositório Git). Usar scripts shell com `sed` ou `envsubst` para manipular arquivos YAML é frágil, propenso a erros de sintaxe e difícil de manter.

# Decisão/Regra
1. **Helm para Bootstrap:** O "App of Apps" (root-app), suas dependências iniciais e a configuração de eventos (EventBus, EventSource, Sensor) devem ser empacotados como um Helm Chart (`charts/bootstrap`).
2. **Templating Nativo:** Variáveis dinâmicas (repoURL, branch, clusterName) devem ser injetadas via Helm Values (`--set` ou `-f values.yaml`), aproveitando o motor de template do Helm.
3. **Instalação Declarativa:** O script de bootstrap deve usar `helm upgrade --install` em vez de `kubectl apply` ou scripts imperativos.
4. **Eliminação de Scripts:** Configurações de infraestrutura (como webhooks) devem ser feitas via Helm Templates, não via scripts shell.

# Consequências
- **Pros:**
  - Substituição de variáveis robusta e tipada.
  - Gerenciamento de ciclo de vida (install/upgrade/uninstall) simplificado.
  - Padrão de indústria amplamente conhecido.
- **Cons:**
  - Introduz dependência do binário `helm` no ambiente de execução do bootstrap (o que já é comum).

# Referências
- `charts/bootstrap/`
- `scripts/bootstrap-gitops.sh`
