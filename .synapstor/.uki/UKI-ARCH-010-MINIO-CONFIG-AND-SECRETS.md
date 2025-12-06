---
uki_id: UKI-ARCH-010
titulo: MinIO – Configuração e Segredos
status: active
criado_em: 2025-11-21
autor: Agent UKI-Capture
tags: [arquitetura, storage, minio, secrets]
---

# Contexto
MinIO provê armazenamento S3‑compatível com credenciais via secret `minio-secret` e configuração de endpoints HTTPS. Probes e recursos estão definidos para robustez.

# Decisão/Regra
1. Padronizar `minio-secret` com chaves `root-user` e `root-password` (via SealedSecret).
2. Configurar endpoints HTTPS (`MINIO_SERVER_URL`, `MINIO_BROWSER_REDIRECT_URL`).
3. Persistir dados via PVC e usar probes de liveness/readiness.

# Consequências
- Pros: Segurança e previsibilidade; configuração consistente; observabilidade básica.
- Cons: Requer Ingress/TLS adequado; necessidade de gerenciar segredos selados e PVC.

# Referências
- `cluster-config/base/storage/minio-deployment.yaml:31-42`
- `cluster-config/base/storage/minio-deployment.yaml:49-52`
- `cluster-config/base/storage/minio-deployment.yaml:61-79`
 - Relacionados: `UKI-SEC-001-SEALED-SECRETS.md`