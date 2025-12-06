# ⚡ Guia de Eficiência Energética com KEDA

O **KEDA (Kubernetes Event-driven Autoscaling)** é a ferramenta padrão do Yby para gerenciamento eficiente de recursos. Ele substitui o antigo `kube-green` e permite escalar aplicações baseadas em eventos ou agendamentos.

## 🎯 Objetivo: Ecofuturismo Prático

Nossa meta é **reduzir o desperdício**. Ambientes de desenvolvimento e staging não precisam rodar 24/7. O KEDA nos permite desligá-los automaticamente quando não estão em uso.

---

## 🕒 Padrão 1: Scale-to-Zero (Cron)

Este é o padrão mais comum: desligar aplicações à noite e religá-las pela manhã.

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
