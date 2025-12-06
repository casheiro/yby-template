# 🔗 Guia de Webhooks (Argo Events)

Este guia explica como configurar e gerenciar a integração de Webhooks (GitHub/GitLab) no Yby.

## 🎯 Por que configurar Webhooks?

Por padrão, o Argo CD faz **polling** (verifica alterações) no seu repositório Git a cada 3 minutos. Isso significa que pode levar até 3 minutos para que um `git push` seja refletido no cluster.

Com **Webhooks**, o Git avisa o cluster imediatamente após o push. O resultado é um **deploy instantâneo** (segundos após o commit).

---

## 🏗️ Arquitetura

O Yby utiliza o **Argo Events** para receber e processar webhooks.

1.  **EventSource**: Um serviço exposto (via NodePort 30012 por padrão) que escuta requisições HTTP do GitHub/GitLab.
2.  **Sensor**: Processa o evento e gatilha um `git refresh` no Argo CD.
3.  **Segurança**: Um `Secret` compartilhado valida a assinatura do payload para garantir que a requisição veio realmente do seu provedor Git.

---

## 🛠️ Configuração Automática (Recomendado)

Se você usou o comando `yby install`, o segredo já foi gerado para você.

### 1. Obter o Segredo (Cluster)

Para ver o segredo configurado no cluster (se já existir):

```bash
kubectl get secret -n argo-events github-webhook-secret -o jsonpath="{.data.secret}" | base64 -d
```

Ou gere um novo se necessário:

```bash
yby secret webhook github
```

### 2. Configurar no GitHub

1.  Vá em **Settings > Webhooks** do seu repositório.
2.  Clique em **Add webhook**.
3.  Preencha os campos com os dados do cluster.
- **Status**: Se o serviço está acessível.

---

## ⚙️ Configuração Manual no GitHub

1.  Vá ao seu repositório no GitHub.
2.  Clique em **Settings** > **Webhooks** > **Add webhook**.
3.  Preencha os campos com os dados do ```bash
yby webhook show
```:
    *   **Payload URL**: `http://SEU_IP_VPS:30012/github`
    *   **Content type**: `application/json`
    *   **Secret**: (Cole o segredo gerado)
4.  **Which events would you like to trigger this webhook?**
    *   Selecione **Just the push event**.
5.  Clique em **Add webhook**.

> ✅ O GitHub enviará um evento de "Ping". Se ficar verde, a conexão funcionou!

---

## ⚙️ Configuração Manual no GitLab

1.  Vá ao seu repositório no GitLab.
2.  Clique em **Settings** > **Webhooks**.
3.  Preencha os campos:
    *   **URL**: `http://SEU_IP_VPS:30012/gitlab`
    *   **Secret Token**: (Cole o segredo gerado)
4.  **Trigger**:
    *   Marque **Push events**.
    *   Marque **Merge request events**.
5.  **SSL verification**: Desmarque se não estiver usando HTTPS válido.
6.  Clique em **Add webhook**.

---

## 🔄 Gerenciando o Segredo

O segredo do webhook é armazenado no cluster como um `SealedSecret`.

### Recriar o Segredo
Se você quiser mudar o segredo ou se ele foi perdido:

```bash
# Definir novo segredo
export WEBHOOK_SECRET="meu-novo-segredo-super-seguro"

# Atualizar no cluster
make webhook-secret
```

Isso irá:
1.  Gerar um novo manifesto `SealedSecret`.
2.  Salvar em `charts/cluster-config/templates/events/sealed-secret-github.yaml`.
3.  **Importante:** Você deve fazer commit e push desse arquivo para o Git!

---

## 🔍 Troubleshooting

### O Webhook não fica verde no GitHub
1.  **Firewall**: Verifique se a porta `30012` está aberta no firewall do seu VPS (AWS Security Group, DigitalOcean Firewall, etc).
2.  **Argo Events**: Verifique se os pods estão rodando:
    ```bash
    kubectl get pods -n argo-events
    ```
3.  **Logs**: Veja os logs do EventSource para ver se a requisição chegou:
    ```bash
    kubectl logs -l controller=eventsource-controller -n argo-events
    ```

### O Argo CD não atualiza mesmo com Webhook verde
1.  Verifique se o Sensor está ativo:
    ```bash
    kubectl get sensors -n argo-events
    ```
2.  Verifique os logs do Sensor:
    ```bash
    kubectl logs -l controller=sensor-controller -n argo-events
    ```
