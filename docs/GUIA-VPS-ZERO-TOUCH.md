# Guia de Provisionamento VPS Zero-Touch

Este guia descreve o processo passo-a-passo para transformar um servidor VPS "cru" (recém-criado) em um cluster Kubernetes de produção totalmente gerenciado pelo Yby, com o mínimo de intervenção manual.

## Pré-requisitos

1.  **Servidor VPS**:
    *   SO: Ubuntu 22.04/24.04 ou Debian 11/12.
    *   Recursos Mínimos: 2 vCPU, 4GB RAM (Recomendado: 4 vCPU, 8GB RAM).
    *   Acesso SSH: Chave pública configurada para o usuário `root` (ou usuário com sudo sem senha).
    *   Portas abertas (Security Group/Firewall da Cloud): 22 (SSH), 80 (HTTP), 443 (HTTPS), 6443 (K8s API).

2.  **Repositório Git**:
    *   Um fork do repositório `yby` (ou clone template).
    *   Token do GitHub (Personal Access Token - Classic) com permissões de `repo` (para o Argo CD acessar/escrever no repo).

3.  **Ambiente Local**:
    *   Linux ou macOS (WSL2 no Windows).
    *   Ferramentas instaladas: `kubectl`, `helm`.
    *   **Yby CLI**: Instale a CLI antes de prosseguir.
    *   *Nota: O comando de provisionamento executará o setup local automaticamente.*

---

## Passo 1: Configuração do Ambiente

Na raiz do seu projeto local, crie um arquivo `.env` com as informações do seu servidor e repositório.

> 💡 **Dica:** Use o modelo abaixo. O arquivo `.env` é ignorado pelo git para segurança.

```bash
# .env

# Dados do Servidor VPS
VPS_HOST=123.456.789.000      # IP Público do seu VPS
VPS_USER=root                 # Usuário SSH (geralmente root)
VPS_PORT=22                   # Porta SSH (padrão 22)

# Dados do Cluster (Opcional - Defaults: yby / v1.33.6+k3s1)
# CLUSTER_NAME=meu-cluster
# K3S_VERSION=v1.29.3+k3s1

# Dados do GitOps (Para o Argo CD)
GITHUB_REPO=https://github.com/SEU_USUARIO/yby
GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Configuração Local (IMPORTANTE)
# Define onde o kubeconfig será salvo/lido para não misturar com seu cluster local
KUBECONFIG=./.kube/config

# Configurações Avançadas de Infraestrutura (Opcional)
# MAX_PODS=250                    # Define limite de pods por nó (default K3s: 110)
```

### Gerenciamento de Configuração (Estratégia Unificada)

O Yby adota uma estratégia de **Single Source of Truth** (Fonte Única da Verdade):

| Arquivo | Função | Exemplo |
| :--- | :--- | :--- |
| **`.env`** | **Acesso & Segredos** (Não versionado) | IP do VPS, Token do GitHub, Senhas Iniciais. |
| **`config/cluster-values.yaml`** | **Configuração do Cluster** (GitOps) | Versão do K3s, Max Pods, Domínios, Apps Ativos. |

> ⚠️ **Importante:** O script de provisionamento lê as configurações (`version`, `maxPods`) diretamente do `cluster-values.yaml`. Não duplique essas configurações no `.env`.

#### Como Customizar (Ponta a Ponta)

**1. Ajustando a Infraestrutura (Ex: Aumentar Capacidade)**
1.  Edite o arquivo `config/cluster-values.yaml`:
    ```yaml
    system:
      k3s:
        version: "v1.29.3+k3s1"
        maxPods: 250
    ```
    ```
2.  **Opção A (Bootstrap - CLI):** Rode `yby bootstrap vps --k3s-version v1.29.3+k3s1`.
    > **Nota:** A flag da CLI tem prioridade sobre o arquivo YAML.
3.  **Opção B (Day 2 / GitOps):** Faça Commit e Push. O **System Upgrade Controller** atualizará o cluster automaticamente.

**2. Ajustando Aplicações (Ex: Mudar Domínio)**
1.  Edite o arquivo `config/cluster-values.yaml`.
2.  Faça Commit e Push. O Argo CD aplicará as mudanças.

---

## Passo 2: Instalação Completa (Zero Touch)

Este comando executa todo o ciclo de vida de provisionamento e configuração em sequência:
1.  **Provisionamento VPS**: Prepara o SO, instala K3s (lendo config do YAML) e baixa o kubeconfig.
2.  **Bootstrap GitOps**: Instala Argo CD e aplica configurações.
3.  **Segredos**: Gera e configura os segredos do Webhook e MinIO.

Execute:
```bash
yby bootstrap vps --install
# ou simplesmente
yby install
```

> **Nota:** Se você habilitou o MinIO, o script solicitará a senha de root.
> **IMPORTANTE:** O processo é automático.

---

## Passo 3: Configuração do Webhook (GitHub)

Ao final da instalação, o comando exibirá as informações necessárias para configurar o Webhook no GitHub. Se precisar ver novamente, execute:

```bash
```bash
yby webhook show
```

1.  Vá no seu repositório GitHub -> **Settings** -> **Webhooks** -> **Add webhook**.
2.  **Payload URL**: Copie a URL exibida (ex: `http://SEU_IP:30012/github`).
3.  **Content type**: Selecione `application/json`.
4.  **Secret**: Copie o segredo exibido.
5.  **Events**: Selecione "Just the push event".
6.  Clique em **Add webhook**.

---

## Passo 4: Acesso e Validação

Agora seu cluster está rodando e se auto-gerenciando via Git.

Para acessar os painéis de controle (Argo CD, Headlamp, Grafana) de forma segura (via Port-Forward), execute:

```bash
```bash
yby access
```

Este comando irá:
1.  Abrir túneis seguros para os serviços.
2.  Exibir as URLs e credenciais de acesso.
3.  Manter a conexão aberta até você pressionar `Ctrl+C`.

---

## Solução de Problemas Comuns

### Erro de Permissão SSH
*   **Sintoma:** `Permission denied (publickey)`.
*   **Solução:** Verifique se sua chave SSH pública está no arquivo `~/.ssh/authorized_keys` do VPS. Teste com `ssh root@SEU_IP`.

### Erro de Kubeconfig
*   **Sintoma:** `The connection to the server localhost:8080 was refused`.
*   **Solução:** Você provavelmente não está usando o `KUBECONFIG` correto. Certifique-se de que `export KUBECONFIG=./.kube/config` foi executado (o `direnv` faz isso automaticamente) ou que a variável está no `.env`.

### Argo CD não sincroniza
*   **Sintoma:** Apps em estado `Unknown` ou `OutOfSync`.
*   **Solução:** Verifique os logs do Argo CD Controller. Geralmente é erro de autenticação no Git (Token inválido) ou o repositório configurado no `cluster-values.yaml` não corresponde ao seu fork.
