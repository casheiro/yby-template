# 🤖 Automação de Operações (Ops Automation)

> ℹ️ **Contexto:** Esta funcionalidade transforma este repositório em uma **Plataforma de Autosserviço**.
> Ela deve ser configurada no repositório "pai" (template) para permitir a criação de repositórios "filhos" (clusters).

Este repositório possui automações via GitHub Actions para facilitar a criação de novos clusters (IssueOps).

## 🚀 Fluxo "Click-to-Cluster"

Permite criar um novo repositório de cluster pré-configurado apenas preenchendo um formulário na aba **Issues**.

### Como funciona:
1. Usuário abre uma Issue usando o template **"Solicitar Novo Cluster"**.
2. Preenche Nome, Domínio, Email (TLS) e Configurações de Discovery.
3. Um mantenedor revisa e adiciona a label `ops:approved`.
4. O GitHub Action:
   - Cria o novo repositório baseado neste template.
   - Edita o `config/cluster-values.yaml` com os dados fornecidos.
   - Responde na Issue com o link do novo repo.

---

## ⚙️ Configuração Necessária (Admin)

Para que a automação funcione, é necessário configurar um **Secret** com permissão para criar repositórios.

### 1. Criar Personal Access Token (PAT)
1. Vá em [GitHub Settings > Tokens](https://github.com/settings/tokens).
2. Gere um **Classic Token** (ou Fine-grained se preferir).
3. Escopos necessários:
   - `repo` (Full control of private repositories)
   - `workflow` (Opcional, para disparar actions no novo repo)
   - `delete_repo` (Opcional, se quiser permitir destruição)

### 2. Adicionar Secret no Repositório Template
1. Vá em **Settings > Secrets and variables > Actions**.
2. Clique em **New repository secret**.
3. Nome: `GH_PAT_REPO_CREATION`
4. Valor: (Cole seu token aqui)

### 3. Criar Label de Aprovação
Certifique-se de que a label `ops:approved` existe no repositório:
- Vá em **Issues > Labels > New Label**.
- Name: `ops:approved`
- Color: `0E8A16` (Verde)

---

## 🛡️ Segurança

- O workflow **NÃO** roda automaticamente na abertura da issue.
- Ele exige a label `ops:approved` para evitar spam ou criação de repositórios não autorizados.
- O nome do cluster é validado para conter apenas caracteres seguros (`a-z0-9-`).
