# 🍃 Guia do Módulo Kepler

Este documento explica como utilizar o **Kepler** (Kubernetes-based Efficient Power Level Exporter) para observabilidade energética no Yby.

## 1. O que é?

O **Kepler** é uma ferramenta de **Ecofuturismo** que utiliza eBPF para medir o consumo de energia de contêineres, pods e nós do Kubernetes. Ele cruza métricas de CPU/Memória/GPU com modelos de aprendizado de máquina para estimar quantos Watts sua aplicação está consumindo.

## 2. Como funciona?

O Kepler roda como um DaemonSet (um agente em cada nó do cluster). Ele coleta métricas de baixo nível do Kernel Linux e as expõe no formato Prometheus.

O Yby já configura automaticamente:
*   O Kepler Exporter.
*   O ServiceMonitor (para o Prometheus raspar os dados, se habilitado).
*   Dashboards no Grafana para visualização.

**Você não precisa alterar o código da sua aplicação** para usar o Kepler. Ele é 100% passivo.

## 3. Configuração Manual em Aplicações Externas

Diferente do KEDA ou MinIO, você não "conecta" sua aplicação ao Kepler. Sua aplicação **É** monitorada pelo Kepler automaticamente assim que o Pod sobe.

No entanto, para garantir que os dados sejam úteis e segmentados corretamente nos Dashboards de Energia, você deve seguir uma boa higiene de **Labels**:

### Boas Práticas de Labels (Etiquetas)

Garanta que seus manifestos de Deployment tenham labels claros. O Kepler usa essas labels para agregar o consumo de energia por Projeto, Time ou Aplicação.

**Exemplo de Deployment Otimizado para Observabilidade:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minha-api
  labels:
    app: minha-api           # Label padrão
    project: financeiro      # Agrupamento por projeto
    environment: production  # Agrupamento por ambiente
    cost-center: "1234"      # Para fins de FinOps
spec:
  template:
    metadata:
      labels:
        app: minha-api
        # Repita as labels relevantes aqui nos Pods também
        project: financeiro
# ...
```

### Acessando os Dados

1.  **Via Grafana:**
    Acesse o Grafana (via `yby access` -> `http://localhost:3000`).
    Busque pelo Dashboard **"Kepler Exporter"** ou **"Yby Energy Metrics"**.
    
2.  **Via Prometheus (Consultas Manuais):**
    Você pode consultar o consumo em Watts de um pod específico:
    
    ```promql
    sum(kepler_container_jul_total{container_name!="POD", pod_name=~"minha-api.*"})
    ```

### Integração com KEDA (Avançado)
Futuramente, você poderá usar métricas do Kepler para escalar (ou deligar) aplicações baseadas em "créditos de carbono" ou consumo energético excessivo, criando um **Carbon-Aware Autoscaling**.
