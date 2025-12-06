---
uki_id: UKI-OPS-002
titulo: Política de Scripts Mínimos (No-Script Ops)
status: active
criado_em: 2025-11-20
autor: Persona Arquiteto
tags: [operações, automação, padronização, makefile]
---

# Contexto
O uso excessivo de shell scripts para orquestração e provisionamento cria uma "colcha de retalhos" imperativa, difícil de manter, testar e debugar. Scripts tendem a esconder lógica de negócio e violar princípios de GitOps ao realizar alterações diretas no cluster.

# Decisão/Regra
1. **Escopo Restrito:** Scripts shell (`.sh`) são permitidos **apenas** como:
   - **Ferramentas de Desenvolvimento Local (Dev Tools):** Helpers para setup de ambiente local (`k3d`), diagnósticos, ou geração de secrets interativos.
   - **Wrappers de Compatibilidade:** Scripts simples que normalizam comandos complexos para uso em CI/CD, se o `Makefile` não for suficiente.
2. **Proibição de Provisionamento:** Scripts **não devem** conter lógica de provisionamento de recursos Kubernetes (ex: `kubectl apply`, `helm install`). Essa responsabilidade é exclusiva de:
   - **Helm Charts:** Para empacotamento de aplicações e configurações.
   - **Argo CD:** Para entrega contínua e reconciliação.
   - **Terraform/Ansible:** Para infraestrutura base (VPS, DNS), se aplicável.
3. **Orquestração via Makefile:** O ponto de entrada único para operações humanas e de CI deve ser o `Makefile`. Scripts não devem chamar outros scripts em cadeia (evitar "script hell").

# Consequências
- **Pros:**
  - Redução drástica de código imperativo.
  - Centralização da lógica de execução no `Makefile`.
  - Maior aderência ao GitOps (tudo é declarativo).
- **Cons:**
  - Curva de aprendizado para encapsular lógica complexa em Helm/K8s Jobs em vez de scripts.

# Referências
- `Makefile`
- `charts/bootstrap/`
