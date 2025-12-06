# Configuração Centralizada via Helm

Este documento descreve todas as opções configuráveis do arquivo `config/cluster-values.yaml`. Este é o **único** arquivo que você precisa editar para configurar um novo cluster.

## Estrutura do Arquivo

### Tabela de Referência Rápida

| Chave | Valor Padrão | Descrição |
|-------|--------------|-----------|
| `global.environment` | `staging` | Ambiente (`dev`, `staging`, `prod`) |
| `global.domainBase` | `""` | Domínio base (ex: `yby.dev.br`). Se vazio, Ingress é desabilitado |
| `git.repoURL` | `https://github.com/my-user/yby-template` | URL do repositório do cluster |
| `git.branch` | `main` | Branch principal |
| `git.repoName` | `yby` | Nome do repositório (usado para filtros) |
| `discovery.enabled` | `true` | Ativa/desativa descoberta automática |
| `discovery.scmProvider` | `github` | `github` ou `gitlab` |
| `discovery.organization` | `yby` | Nome da org ou usuário |
| `discovery.topic` | `yby-app` | Tópico a ser monitorado |
| `discovery.tokenSecretName` | `github-token` | Nome do secret com o PAT (deve estar no namespace `argocd`) |
| `argocd.enabled` | `true` | Ativa gestão do Argo CD |
| `argocd.url` | `http://localhost:8080` | URL externa do Argo CD |
| `events.enabled` | `true` | Ativa sensor e eventbus para CI/CD |
| `ingress.enabled` | `true` | Ativa Traefik Dashboard e IngressRoutes |
| `ingress.tls.enabled` | `false` | Ativa Cert-Manager (LetsEncrypt) |
| `ingress.tls.email` | `contato@yby.dev.br` | Email para registro no LetsEncrypt |
| `datadog.enabled` | `false` | Ativa agente Datadog |
| `datadog.secretName` | `datadog-secret-staging` | Nome do SealedSecret com a API Key |
| `storage.minio.enabled` | `false` | Ativa MinIO para armazenamento de artefatos |
| `kepler.enabled` | `true` | Ativa coleta de métricas de energia (Ecofuturismo) |
| `keda.enabled` | `true` | Ativa desligamento automático de recursos (Scale-to-Zero) |
| `observability.mode` | `none` | `none`, `datadog` ou `prometheus` (Local) |

### Detalhamento por Seção

### Configurações Globais
- Define ambiente e domínio base do cluster

### Repositório Git (Cluster)
Define de onde o cluster deve puxar suas próprias configurações (GitOps).

### Descoberta Automática (Zero-Touch)
Configura o ApplicationSet para descobrir apps automaticamente.

⚠️ **Importante:** O secret `github-token` deve existir no namespace `argocd` antes de habilitar.

### Argo CD
Configurações do servidor Argo CD.

### Argo Events (Webhooks)
Sistema de eventos para CI/CD e webhooks do GitHub.

### Ingress & TLS

- `ingress.enabled`: Ativa Traefik Dashboard e IngressRoutes
- `ingress.tls.enabled`: Ativa Cert-Manager (LetsEncrypt) **(por padrão está `false`)**
- `ingress.tls.email`: Email para registro no LetsEncrypt

⚙️ Para habilitar TLS, ajuste `ingress.tls.enabled: true` e certifique‑se de que o Cert‑Manager está instalado.

### Observabilidade
- `datadog.enabled`: Ativa agente Datadog
- `datadog.secretName`: Nome do SealedSecret com a API Key

### Ecofuturismo (Sustentabilidade)
- `kepler.enabled`: Coleta métricas de Joules/Watt (Default: `true`).
- `keda.enabled`: Instala CRDs para desligamento automático (Default: `true`).
- `observability.mode`:
    - `none`: Apenas coleta (Kepler), sem persistência (Recomendado para Prod).
    - `prometheus`: Instala Prometheus+Grafana no cluster (Recomendado para Local/Dev).
    - `datadog`: Usa agente Datadog externo.

## Validação
Para validar se sua configuração está correta antes de aplicar:

```bash
yby validate
```
Isso executa `helm lint` e `helm template` usando seu arquivo de valores.