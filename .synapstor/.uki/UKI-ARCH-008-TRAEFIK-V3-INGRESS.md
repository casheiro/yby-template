---
uki_id: UKI-ARCH-008
titulo: Ingress padrão com Traefik v3.1 e ACME
status: active
criado_em: 2025-11-21
autor: Agent UKI-Capture
tags: [arquitetura, ingress, traefik, tls]
---

# Contexto
Traefik v3.1 é adotado como controlador de entrada, com providers Kubernetes CRD/Ingress, IngressClass `traefik`, TLS automático via Let’s Encrypt (HTTP‑01) e `Service` do tipo `LoadBalancer`.

# Decisão/Regra
1. Adotar Traefik v3.1 como ingress principal com CRDs habilitados.
2. Configurar TLS via ACME HTTP challenge e definir IngressClass `traefik`.
3. Em produção, persistir `/data/acme.json` para manter certificados (evitar `emptyDir`).

# Consequências
- Pros: Padrão moderno e flexível; TLS automatizado; integração com CRDs.
- Cons: Depende de `LoadBalancer` do provedor; requer DNS e persistência adequada para ACME.

# Referências
- `cluster-config/base/ingress/traefik-deployment.yaml:21`
- `cluster-config/base/ingress/traefik-deployment.yaml:33-36`
- `cluster-config/base/ingress/traefik-deployment.yaml:39-43`
- `cluster-config/base/ingress/traefik-deployment.yaml:110-120`
 - Relacionados: `UKI-ARCH-007-ARGOCD-SYNCPOLICY-STANDARD.md`