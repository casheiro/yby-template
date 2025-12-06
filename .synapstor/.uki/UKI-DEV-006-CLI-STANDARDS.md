---
uki_id: UKI-DEV-006
titulo: Padrões de Desenvolvimento da CLI (Yby CLI)
status: active
criado_em: 2025-12-05
autor: Antigravity
tags: [cli, go, ux, padroes]
---

# Contexto
A CLI do Yby (`yby`) está evoluindo para se tornar o ponto central de interação do usuário, substituindo scripts shell dispersos e targets complexos do Makefile. Para garantir uma experiência consistente e de alta qualidade ("Zero Friction"), é necessário padronizar como a CLI é desenvolvida.

# Decisão/Regra

## 1. Bibliotecas Padrão
- **Framework:** `spf13/cobra` para estrutura de comandos e flags.
- **Estilo/UI:** `charmbracelet/lipgloss` para estilização e cores.
- **Interatividade:** `AlecAivazis/survey/v2` ou `charmbracelet/no-huh` (preferencia por survey por enquanto pela maturidade no projeto já existente) para prompts.
- **Logging:** `fmt` para output do usuário (estilizado). Logs de debug devem ser opcionais via flag `--verbose`.

## 2. Princípios de UX (Zero Friction)
- **Idempotência:** Comandos devem poder ser rodados múltiplas vezes sem erro ou efeitos colaterais indesejados.
- **Falha Graciosa:** Erros devem sugerir correções claras. Nunca apresentar apenas um stack trace.
- **Interatividade Opcional:** Todo comando deve funcionar em modo não-interativo (CI/CD) se as flags necessárias forem fornecidas. Se faltar info e for um TTY, pergunte.
- **Dry Run:** Operações destrutivas ou de mudança de estado devem suportar `--dry-run`.

## 3. Estrutura de Comandos
- `yby setup`: Preparação do ambiente local (dependências).
- `yby bootstrap`: Instalação e configuração do cluster.
- `yby doctor`: Diagnóstico.
- `yby access`: Acesso a recursos.

## 4. Tratamento de Erros
- Use `fmt.Errorf("contexto: %w", err)` para empilhar erros.
- Retorne códigos de saída não-zero (ex: `os.Exit(1)`) apenas no `main` ou `root.go`.

# Consequências
- **Pros:** Interface consistente, manutenção facilitada, onboarding mais rápido.
- **Cons:** Necessidade de refatorar códigos antigos que usam apenas `fmt.Println` puro sem estilo.
