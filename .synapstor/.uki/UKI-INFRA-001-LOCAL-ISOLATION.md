---
uki_id: UKI-INFRA-001
title: Isolamento de Ambiente Local
status: active
tags: [infra, automation, security]
creation_date: 2025-11-27
---

# Contexto
Scripts de automação que modificam arquivos globais do usuário (como `~/.ssh/known_hosts` ou `~/.kube/config`) causam fricção, conflitos e insegurança.

# Regra
Automações de infraestrutura **DEVEM** usar configurações locais e isoladas dentro do diretório do projeto.
- **Kubeconfig:** Deve apontar para `./.kube/config` (via variável de ambiente `KUBECONFIG`).
- **SSH:** Deve usar `-o UserKnownHostsFile=/dev/null` ou arquivos de config locais para hosts efêmeros.

# Exceção
Ferramentas que exigem instalação global explícita (ex: `brew install`), mas mesmo estas devem ser evitadas em favor de binários locais ou containers sempre que possível.
