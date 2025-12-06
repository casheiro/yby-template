---
uki_id: UKI-SEC-002
titulo: Convenções para Segredos de Integração (Webhooks)
status: draft
criado_em: 2025-11-20
autor: Agent UKI-Capture
tags: [seguranca, secrets, sealed-secrets, argo-events]
---

# Contexto
Argo Events necessita segredos para validar webhooks (GitHub/GitLab). Armazenar segredos em texto plano ou criar via script viola princípios de segurança e GitOps. É necessário um padrão único para nomes, chaves e escopo dos segredos.

# Decisão/Regra
1. **Sealed Secrets:** Todos os segredos de integração são geridos como `SealedSecret` e versionados no Git.
2. **Nomes e Namespace:** Usar `github-webhook-secret` e `gitlab-webhook-secret` no namespace `argo-events` (onde o `EventSource` está).
3. **Chave do Dado:** A chave do dado secreto é sempre `secret` (compatível com `eventsource.yaml`).
4. **Rotação:** Rotacionar segredos via novo commit de `SealedSecret`; não editar direto no cluster.
5. **Proibição:** Não commitar segredos em claro; não criar segredos via `kubectl create secret` sem selagem.

# Consequências
- **Pros:** Confidencialidade, rastreabilidade, consistência com GitOps.
- **Cons:** Requer `kubeseal` e chave do controlador; fluxo de geração precisa acesso ao cluster.
- **Dependências:** Sealed Secrets instalado e configurado.

# Referências
- `/home/neto/projects/yby/charts/bootstrap/templates/events/eventsource.yaml`
- `/home/neto/projects/yby/.synapstor/.uki/UKI-SEC-001-SEALED-SECRETS.md`