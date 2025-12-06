# 🚀 Zero-Touch Discovery: Apps Externas

O **Yby** utiliza o padrão **Zero-Touch Discovery** para gerenciar aplicações. Isso significa que você não precisa editar arquivos de configuração no cluster para adicionar ou remover aplicações.

Tudo é controlado via **GitHub Topics**.

## 🎯 Como Funciona

1. O **ApplicationSet** (`app-discovery`) roda no cluster e varre sua organização no GitHub a cada 3 minutos.
2. Ele procura por repositórios que tenham:
   - O tópico (tag): `yby-app` (configurável em `config/cluster-values.yaml`)
   - Uma pasta chamada `infra/` na raiz
3. Se encontrar, ele cria automaticamente uma **Application** no Argo CD.
4. Se você remover o tópico ou arquivar o repositório, a aplicação é removida do cluster automaticamente.

---

## 📝 Guia de Onboarding (Nova App)

Para fazer o deploy de uma nova aplicação, siga estes passos:

### 1. Preparar o Repositório
No seu repositório da aplicação (ex: `minha-app-backend`), crie uma pasta `infra/` e adicione seus manifestos Kubernetes (Deployment, Service, Ingress, etc).

Exemplo de estrutura:
```
minha-app-backend/
├── src/
├── Dockerfile
└── infra/
    ├── deployment.yaml
    ├── service.yaml
    └── ingress.yaml
```

### 2. Etiquetar o Repositório
1. Vá para a página principal do repositório no GitHub.
2. No canto superior direito (seção "About"), clique no ícone de engrenagem (⚙️).
3. No campo "Topics", adicione: `yby-app`.
4. Salve.

### 3. Verificar
Aguarde alguns minutos (ou force um refresh no Argo CD).
Sua aplicação aparecerá automaticamente no painel do Argo CD.

---

## ⚙️ Configuração (Cluster)

A configuração deste comportamento é centralizada em `config/cluster-values.yaml`:

```yaml
discovery:
  enabled: true
  scmProvider: github
  organization: yby          # Sua organização ou usuário
  topic: yby-app                  # O tópico mágico
  tokenSecretName: github-token   # Nome do secret com o PAT
```

### Requisito: GitHub Token
Para que o Argo CD consiga listar os repositórios (mesmo os públicos, para evitar rate limits, e obrigatoriamente para privados), é necessário um **Personal Access Token (PAT)**.

Crie o secret no cluster usando o comando helper:
```bash
yby secret github-token ghp_SEU_TOKEN_AQUI
```

Ou manualmente (certifique-se de usar o namespace `argocd`):
```bash
kubectl create secret generic github-token \
  --from-literal=token=ghp_SEU_TOKEN_AQUI \
  -n argocd
```

⚠️ **Importante:** O secret deve estar no namespace `argocd`, pois é onde o ApplicationSet Controller procura.


---

## 🔍 Troubleshooting

**Minha app não aparece no Argo CD:**

1. **Verifique o Tópico**: O repositório tem exatamente o tópico `yby-app`?
2. **Verifique a Pasta**: Existe uma pasta `infra/` na raiz da branch `main`?
3. **Verifique o Token**: O token do GitHub no secret `github-token` é válido e tem permissão de leitura (`repo`)?
4. **Logs do ApplicationSet**:
   ```bash
   kubectl logs -l app.kubernetes.io/name=argocd-applicationset-controller -n argocd
   ```

**Minha app não sincroniza (OutOfSync):**

1. Verifique se os manifestos em `infra/` são válidos.
2. Use `yby validate` localmente para testar seus charts/manifests.