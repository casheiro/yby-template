uki_id: UKI-ARCH-003
titulo: Padrão App of Apps (Argo CD)
status: active
criado_em: 2025-11-20
autor: Persona Arquiteto
tags: [arquitetura, gitops, argocd]

# Contexto
Para gerenciar múltiplas aplicações no Argo CD de forma declarativa, evitamos criar `Application` resources manualmente via UI ou CLI. O projeto consolidou o ponto de entrada único via Helm Chart (`charts/bootstrap`), que define o Root App e os Child Apps.

# Decisão/Regra
1. **Root App via Helm:** O `root-app` é definido como template Helm (`charts/bootstrap/templates/root-app.yaml`) e aponta para o próprio chart `charts/bootstrap`, que contém a definição dos Child Apps.
2. **Child Apps no Chart:** As aplicações do cluster (infraestrutura, observabilidade, serviços) são declaradas como templates Helm dentro do chart de bootstrap (por exemplo, `infrastructure-apps.yaml`).
3. **Hierarquia Declarativa:** O `root-app` sincroniza o chart de bootstrap, que renderiza e gerencia os Child Apps, e estes sincronizam seus recursos (Helm/Kustomize) respectivos.

# Consequências
- Pros:
  - Bootstrap completo do cluster com um único `helm upgrade --install` do chart de bootstrap.
  - Adicionar uma nova app é apenas um PR ajustando templates/values no chart.
- Cons:
  - Se o `root-app` quebrar ou for removido, pode causar efeitos em cascata nos Child Apps (com `prune: true`).
  - Introduz dependência explícita de Helm para bootstrap e parametrização.

# Referências
- `charts/bootstrap/templates/root-app.yaml:17-31`
- `charts/bootstrap/templates/infrastructure-apps.yaml:1-86`
- `UKI-ARCH-004-HELM-BOOTSTRAP.md`
