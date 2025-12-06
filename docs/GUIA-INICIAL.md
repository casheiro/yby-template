# Guia Inicial: Do Zero ao Cluster GitOps

Este guia descreve o "Caminho Feliz" (Happy Path) para transformar um servidor VPS novo em um cluster Kubernetes de produção totalmente gerenciado pelo Yby.

## 📋 Pré-requisitos

1.  **Servidor VPS**:
    *   Ubuntu 22.04+/Debian 12+.
    *   Mínimo: 2 vCPU, 4GB RAM.
    *   Portas abertas: 22, 80, 443, 6443.
2.  **Localmente**:
    *   `yby` CLI instalada (veja README).
    *   `kubectl` e `helm` instalados.
    *   Um fork do repositório `yby-template`.

---

## Passo 1: Inicialização do Projeto

Em vez de editar YAMLs manualmente, use a CLI para configurar seu projeto:

```bash
yby init
```

O assistente interativo perguntará:
*   URL do seu repositório Git.
*   Domínio base (ex: `meusite.com`).
*   Versão do K3s desejada.
*   Módulos Ecofuturistas (Kepler, KEDA).

Isso gerará o arquivo `config/cluster-values.yaml` com todas as suas preferências.

### Segredos (`.env`)
Crie um arquivo `.env` na raiz (não versionado) para segredos de infraestrutura:  

```bash
VPS_HOST=1.2.3.4
VPS_USER=root
GITHUB_TOKEN=ghp_...
```

---

## Passo 2: Bootstrap do Servidor (Zero Touch)

Com o projeto configurado, execute o provisionamento automático. Este comando conecta no VPS, instala o K3s (na versão escolhida) e baixa o `kubeconfig` para sua máquina.

```bash
yby bootstrap vps
```

> **Nota**: Se você quiser instalar tudo de uma vez (VPS + GitOps), use `yby install`.

---

## Passo 3: Bootstrap do Cluster (GitOps Stack)

Agora que você tem acesso ao Kubernetes (verifique com `kubectl get nodes`), instale a camada de GitOps (Argo CD) e o chart de Sistema:

```bash
yby bootstrap cluster
```

Este comando:
1.  Instala Argo CD e Argo Events.
2.  Instala CRDs de Sistema (Cert-Manager, Prometheus Operator).
3.  Configura Segredos (Git Token, Webhook Secret).
4.  Aplica o "App of Apps" (Root App).

---

## Passo 4: Acesso e Validação

Seu cluster está pronto! Para acessar os dashboards (Argo CD, Grafana, etc) de forma segura:

```bash
yby access
```

Isso abrirá túneis seguros (port-forward) e exibirá as senhas de acesso.

---

## Próximos Passos

*   **Configurar Webhook**: Para CI/CD instantâneo, configure o Webhook no GitHub com o segredo gerado (veja `yby webhook show`).
*   **Operações**: Consulte o [Manual de Operações](MANUAL-OPERACOES.md) para tarefas do dia a dia.
*   **Recursos**: Entenda como usar KEDA e Kepler no [Guia de Recursos](GUIA-RECURSOS.md).
