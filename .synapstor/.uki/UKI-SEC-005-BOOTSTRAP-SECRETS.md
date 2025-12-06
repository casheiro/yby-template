---
uki_id: UKI-SEC-005
title: Bootstrapping de Segredos de Infraestrutura
status: active
tags: [security, gitops, secrets]
creation_date: 2025-11-27
---

# Contexto
O problema do "Ovo e a Galinha" em GitOps: O Argo CD precisa de um segredo (Git Token) para baixar o repositório que contém os segredos (Sealed Secrets).

# Regra
Credenciais de acesso à infraestrutura inicial (Bootstrap Secrets) devem ser injetadas **imperativamente** durante o processo de bootstrap (via variáveis de ambiente ou CLI), e nunca commitadas no repositório, nem mesmo criptografadas, se forem necessárias para o próprio funcionamento do mecanismo de descriptografia ou sync inicial.
