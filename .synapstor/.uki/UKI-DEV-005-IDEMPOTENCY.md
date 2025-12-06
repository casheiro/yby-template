---
uki_id: UKI-DEV-005
title: Idempotência em Scripts de Provisionamento
status: active
tags: [dev, automation, scripting]
creation_date: 2025-11-27
---

# Contexto
Falhas de rede ou interrupções são comuns. Scripts que falham ao serem re-executados ("Resource already exists") aumentam drasticamente o tempo de recuperação e frustração.

# Regra
Todo script de automação deve ser **idempotente** (re-executável infinitas vezes produzindo o mesmo resultado final).
- Use flags como `--dry-run=client -o yaml | kubectl apply -f -` para criação de recursos.
- Verifique existência antes de criar (`if ! command; then ... fi`).
- Use "Force" ou "Replace" apenas quando garantir o estado desejado for crítico.
