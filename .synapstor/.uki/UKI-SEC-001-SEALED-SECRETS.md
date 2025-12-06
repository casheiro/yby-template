---
uki_id: UKI-SEC-001
titulo: Gestão de Segredos via Sealed Secrets
status: active
criado_em: 2025-11-20
autor: Persona Arquiteto
tags: [segurança, gitops, secrets]
---

# Contexto
O GitOps exige que todo o estado do cluster esteja no Git, mas commitar Kubernetes Secrets (base64) é inseguro. Precisamos de uma forma de versionar segredos de forma criptografada.

# Decisão/Regra
1. **Proibição:** É proibido commitar manifestos `Kind: Secret` com dados sensíveis reais no repositório.
2. **Obrigatoriedade:** Segredos devem ser criptografados usando `kubeseal` e armazenados como `Kind: SealedSecret`.
3. **Controller:** O controller `sealed-secrets` no cluster é o único capaz de descriptografar esses segredos.
4. **Backup:** A chave mestra do Sealed Secrets deve ter backup seguro fora do cluster (ex: gerenciador de senhas da equipe), pois sem ela os segredos não podem ser recuperados em caso de desastre.

# Consequências
- **Pros:**
  - Segredos versionados no Git com segurança.
  - Fluxo GitOps não é interrompido por gestão manual de secrets.
- **Cons:**
  - Necessidade de ferramenta extra (`kubeseal`) no fluxo de desenvolvimento.
  - Risco de perda de dados se a chave mestra for perdida.

# Referências
- `scripts/create-sealed-secret.sh`
- `cluster-config/base/sealed-secrets/`
