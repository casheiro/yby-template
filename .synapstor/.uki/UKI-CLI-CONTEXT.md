# UKI: Estratégia de Gerenciamento de Contexto da CLI
**ID**: UKI-CLI-CONTEXT-001
**Status**: ACTIVE
**Contexto**: Evolução da CLI `yby` para suportar múltiplos ambientes com segurança.

## Definição
Um **Contexto** define o conjunto isolado de variáveis e configurações para um ambiente específico.

## Isolamento Estrito
Para evitar acidentes operacionais, o Yby adota o **Isolamento Estrito**:
- **Ambientes não herdam configurações**.
- O Contexto `staging` não lê o arquivo do Contexto `production` ou `default`.
- Cada arquivo de definição de contexto (ex: `.env.staging`) deve ser completo.

## Criação de Contexto (Smart Init)
A forma padrão de criar um novo contexto é através do comando `yby init`.
- Este comando gera simultaneamente a configuração do GitOps (`cluster-values.yaml`) e o arquivo de contexto local (`.env.<env>`).
- Ele garante que segredos como `GITHUB_TOKEN` sejam capturados e persisitidos apenas no contexto local seguro.

## Integração com CI/CD (Pipelines)
O Yby segue a metodologia **12-Factor App**:
- **Ambientes de CI (GitHub Actions)** não possuem arquivos `.env` commitados.
- Nesses ambientes, a CLI utiliza diretamente as **Environment Variables** injetadas (ex: via Repository Secrets).
- A ordem de precedência para resolução de variáveis é:
  1. Variável de Ambiente do Processo (Shell/CI).
  2. Arquivo `.env.<contexto>`.

## Persistência de Estado
O estado local do usuário (qual contexto está ativo) é salvo em **`.yby/state.yaml`**.
- Este arquivo e diretório devem ser adicionados ao `.gitignore`.
- Isso evita que preferências pessoais sejam commitadas no repositório compartilhado.

## Tipos de Contexto
- **Local**: `local/k3d-config.yaml`.
- **Remoto Personalizado**: `.env.<nome>` (ex: `.env.staging`).
- **Default**: `.env`.
