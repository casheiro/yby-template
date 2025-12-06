---
id: uki-CLI-001
type: design-principle
status: active
created_date: 2025-01-23
tags: [cli, design, philosophy, zero-lock-in]
---

# Yby CLI Design Principles

## 1. Visão do Produto
O Yby é uma **Plataforma de Engenharia** composta por:
1.  **Template (GitOps)**: Repositório agnóstico e clonável.
2.  **CLI (Orquestrador)**: Binário único que facilita o uso.
3.  **Blueprint Engine**: Cérebro configurável (`.yby/blueprint.yaml`) que dita o comportamento da `init`.

## 2. Filosofia "Zero Lock-in"
A CLI é um **facilitador**, nunca um requisito obrigatório para operação diária.

*   **Regra de Ouro**: Tudo o que a CLI faz DEVE ser possível de realizar com ferramentas nativas (`kubectl`, `helm`, `git`, `kubeseal`).
*   **Transparência**: A automação não deve ser uma "caixa preta" mágica; o usuário deve entender o que está acontecendo por baixo dos panos (vide documentação `REFERENCIA-TECNICA.md`).

## 3. Blueprint Engine
A configuração inicial não deve ser hardcoded no binário.
*   **Dinamicidade**: O comando `yby init` lê perguntas e alvos de um arquivo YAML no repositório.
*   **Desacoplamento**: Versões de ferramentas e templates vivem no repositório, não na CLI.
