# UKI-ARC-002: Observabilidade Agnóstica

## Definição
**Observabilidade Agnóstica** é o padrão arquitetural onde o cluster fornece **dados** de forma padronizada e aberta, mas não impõe a **ferramenta de visualização/armazenamento**. O cluster é o *produtor* soberano de sua telemetria; o usuário é o *consumidor* livre.

## O Problema do Vendor Lock-in
Muitas plataformas Kubernetes "opinativas" forçam uma stack (ex: Prometheus+Grafana ou Datadog ou ELK). Isso cria dois problemas:
1.  **Bloatware:** Quem já paga Datadog não quer rodar um Prometheus pesado no cluster.
2.  **Custo Oculto:** Quem não tem orçamento não quer ser forçado a usar SaaS pago.

## A Solução: "Bring Your Own Observability" (BYOO)

### 1. Camada de Dados (Responsabilidade do Cluster)
O cluster deve garantir que as métricas, logs e traces sejam gerados e expostos em formatos padrão abertos (OpenMetrics, OpenTelemetry).
- **Componente Core:** **Kepler** (para energia).
- **Padrão:** Exposição via `/metrics` (Prometheus format) e Annotations (`prometheus.io/scrape`).

### 2. Camada de Integração (Hooks)
O cluster deve fornecer "ganchos" fáceis para conectar coletores.
- **ServiceMonitors:** Para quem usa Prometheus Operator.
- **ConfigMaps/Sidecars:** Para quem usa Agents (Datadog, New Relic).

O projeto não fornece dashboards "hardcoded" que dependem de uma ferramenta específica para funcionar o *core*. Dashboards são fornecidos como "templates" ou "assets" opcionais (ex: JSONs do Grafana, JSONs do Datadog), mas não são instalados compulsoriamente.

### 4. Padrão "Local Dashboard" (Zero-Overhead)
Para evitar o custo de rodar uma stack de visualização (Grafana/Kibana) em produção apenas para debug ocasional, adotamos o padrão **Local Dashboard**:
1.  **Cluster:** Roda apenas o coletor leve (Prometheus).
2.  **Operador:** Roda o visualizador (Grafana) em sua máquina local (via Docker).
3.  **Conexão:** Um túnel seguro (`kubectl port-forward`) conecta os dois sob demanda.
**Comando:** `make dashboard`

## Decisão de Design
- **Default:** O cluster sobe gerando métricas (Kepler), mas sem persistência de longo prazo.
- **Opt-in:** O usuário habilita a integração que deseja via `values.yaml` ou instala seu próprio agente.
