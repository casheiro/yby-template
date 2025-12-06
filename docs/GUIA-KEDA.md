# ⚡ Guia do Módulo KEDA

Este documento explica como utilizar o **KEDA** (Kubernetes Event-driven Autoscaling) no Yby.

## 1. O que é?

O **KEDA** é a ferramenta padrão do Yby para **Ecofuturismo** e gerenciamento eficiente de recursos. Ele permite escalar aplicações baseadas em eventos (como mensagens no Kafka, filas RabbitMQ) ou agendamentos (Cron), indo além do HPA padrão do Kubernetes.

## 2. Como funciona?

O KEDA funciona estendendo o Kubernetes com um recurso chamado `ScaledObject`.
1.  Você cria um `ScaledObject` ligando um **Gatilho** (ex: relógio marcando 20h) ao seu **Deployment**.
2.  O KEDA monitora esse gatilho.
3.  Quando o evento ocorre (ex: "hora de dormir"), o KEDA desativa o HPA nativo e força o número de réplicas para zero (ou outro valor).
4.  Quando o evento acaba, ele devolve o controle e escala a aplicação de volta.

## 3. Configuração Manual em Aplicações Externas (Scale-to-Zero)

O padrão mais comum é desligar aplicações à noite para economizar recursos (Scale-to-Zero).

### Como aplicar

### Como aplicar

Você pode gerar este arquivo automaticamente usando a CLI:
```bash
yby generate keda --name scale-to-zero --deployment minha-app --namespace apps --schedule "0 20 * * *"
```

Ou criar manualmente um `ScaledObject` junto com o seu `Deployment` na pasta `infra/` da sua aplicação.

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: scale-to-zero
  namespace: apps # Mesmo namespace da sua app
spec:
  scaleTargetRef:
    name: minha-app-deployment # Nome do seu Deployment
  minReplicaCount: 0  # Permite zerar réplicas
  maxReplicaCount: 1  # Volta para 1 (ou mais) quando ativo
  triggers:
  - type: cron
    metadata:
      timezone: America/Sao_Paulo
      # Formato Cron: Minuto Hora Dia Mês DiaDaSemana
      start: 0 20 * * *        # Desliga as 20:00
      end: 0 8 * * *          # Liga as 08:00
      desiredReplicas: "0"    # Réplicas durante a janela (das 20h às 08h)
```

### Detalhes Importantes
- **Timezone:** Sempre especifique `America/Sao_Paulo` (ou sua região) para evitar confusão com UTC.
- **Janela Invertida:** O KEDA Cron funciona definindo uma "janela de ativação". No exemplo acima, a janela é das 20h às 08h, e durante esse tempo queremos `desiredReplicas: "0"`. Fora dessa janela, ele respeita o `minReplicaCount` / `maxReplicaCount`.

---

## 🚦 Padrão 2: Escalonamento por Tráfego (HTTP)

*Em breve.*
Futuramente, poderemos usar o KEDA com Prometheus para escalar baseado em requisições reais (ex: zero requisições por 1h = desligar), o que é ainda mais eficiente que o Cron fixo.

---

## 📚 Referência

- [Documentação Oficial do KEDA Cron Scaler](https://keda.sh/docs/latest/scalers/cron/)
- [Lista de Timezones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)
