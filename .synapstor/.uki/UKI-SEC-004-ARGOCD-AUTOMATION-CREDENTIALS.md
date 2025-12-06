---
uki_id: UKI-SEC-004
titulo: Credenciais de Automação para Argo CD
status: active
criado_em: 2025-11-21
autor: Agent UKI-Capture
tags: [seguranca, argocd, automacao, sealed-secrets]
---

# Contexto
Workflows utilizam o `argocd-initial-admin-secret` para autenticação. Esse secret é destinado ao bootstrap e não deve permanecer como credencial operacional de longo prazo.

# Decisão/Regra
1. Após bootstrap, criar credencial dedicada (token de usuário restrito ou token de ServiceAccount) para automações.
2. Armazenar a credencial como `SealedSecret` no namespace apropriado e referenciar via volume/variáveis nos Workflows.
3. Adotar princípio de menor privilégio e rotação periódica das credenciais.

# Consequências
- Pros: Reduz riscos, melhora auditoria e separa responsabilidades.
- Cons: Exige etapa adicional de criação/rotação e ajustes nos Workflows.

# Referências
- `workflows/templates/deploy-workflow.yaml:203-209`
- `workflows/templates/deploy-workflow.yaml:133-137`
- `workflows/events/infrastructure-sensor.yaml:169-176`
- `UKI-SEC-001-SEALED-SECRETS.md`
 - Relacionados: `UKI-SEC-003-ARGOCD-INSECURE-GRPCWEB.md`