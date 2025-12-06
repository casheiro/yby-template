# 🛠️ Guia de Desenvolvimento - Yby

Este guia descreve o fluxo de trabalho para desenvolver e testar alterações no cluster de forma eficiente.

## 🚀 Ambiente Local (k3d)

O ambiente de desenvolvimento é uma réplica fiel da produção, rodando localmente via k3d.

### Iniciar Ambiente
```bash
# Instala ferramentas e sobe o cluster completo
yby setup
yby dev
```
*Isso cria um cluster k3d, instala Argo CD, Headlamp e aplica todas as configurações.*

### ⚡ Developer Experience (Direnv)
O projeto utiliza **direnv** para gerenciar o contexto do Kubernetes automaticamente.
1. Instale o direnv (o `yby setup` pode fazer isso por você).
2. Execute `direnv allow` na raiz do projeto.
3. **Pronto!** O `KUBECONFIG` será apontado para `./.kube/config` automaticamente sempre que você entrar na pasta.

> **Sem direnv?** Você precisará rodar `export KUBECONFIG=./.kube/config` manualmente ou usar `kubectl` com `--kubeconfig`.


### Acessar Serviços
### Acessar Serviços
```bash
# Inicia todos os túneis (Argo CD, Headlamp, Grafana)
yby access

# Argo CD: https://localhost:8080 (admin / Senha mostrada no comando)
# Headlamp: http://localhost:4466
```

### Verificar Status
```bash
yby status
```

### Limpar Ambiente
```bash
# Destruir cluster
k3d cluster delete yby-local
```

### 🌍 Gerenciamento de Contexto
Se você estiver trabalhando com múltiplos ambientes (ex: testando scripts de staging localmente), use o sistema de contextos:

```bash
# Ver onde você está
yby context show

# Mudar para staging (assume que existe .env.staging)
yby context use staging
# ATENÇÃO: Isso carregará APENAS as variáveis de .env.staging!
```

---

## 🔄 Workflow de Desenvolvimento (GitOps)

Como o cluster segue o padrão GitOps Radical, o fluxo de trabalho é:

1. **Alterar Código**: Edite charts, templates ou valores localmente.
2. **Validar**: Rode o linter para garantir que não quebrou nada.
   ```bash
   yby validate
   ```
3. **Commit & Push**: Envie as alterações para o repositório.
4. **Sync**: O Argo CD detectará as mudanças e aplicará no cluster (local ou prod).

---

## 🧪 Testando Alterações

### Validar Charts Helm
Antes de commitar, sempre valide se seus templates Helm estão renderizando corretamente:

```bash
yby validate
```
*Isso roda `helm lint` e `helm template` para verificar erros de sintaxe.*

### Testar Workflows (Argo)
Se você estiver mexendo em workflows do Argo:

1. Suba o ambiente local (`yby dev`).
2. Aplique o workflow manualmente para teste rápido (opcional):
   ```bash
   argo submit workflows/meu-workflow.yaml -n argo --watch
   ```
3. Ou faça commit e deixe o Argo CD sincronizar.

---

## 🛡️ Segredos (Sealed Secrets)

Nunca commite senhas em texto plano. Use `kubeseal` (se instalado) ou os scripts auxiliares.

### Criar Webhook Secret
```bash
```bash
yby secret webhook github <token>
```

---

## 🐛 Troubleshooting

### O cluster não sobe
1. Verifique se o Docker está rodando.
2. Verifique se tem recursos livres (RAM/CPU).
3. Tente limpar e subir de novo: `k3d cluster delete yby-local && yby dev`.

### Argo CD não sincroniza
1. Verifique os logs do controller:
   ```bash
   kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller
   ```
2. Verifique se o repoURL no `config/cluster-values.yaml` está correto.

### Erro de Certificado (x509)
O ambiente local usa certificados auto-assinados. É normal o navegador reclamar. Aceite o risco ou configure a CA localmente.