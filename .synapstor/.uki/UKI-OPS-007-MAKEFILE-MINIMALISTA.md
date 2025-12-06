# UKI-OPS-007: Makefile Minimalista

**Status**: `active`  
**Domínio**: Operações  
**Tags**: `makefile`, `gitops`, `simplicidade`, `minimal-abstraction`  
**Criado em**: 2025-11-22  
**Última atualização**: 2025-11-22

## Contexto

O Makefile do projeto havia crescido para 907 linhas com ~80 targets, muitos dos quais:
- Violavam GitOps Radical criando recursos imperativamente
- Eram wrappers triviais de comandos `git`, `kubectl` ou `helm`
- Duplicavam funcionalidade já existente
- Existiam apenas por "compatibilidade" com código antigo

Isso criava confusão sobre qual comando usar e violava o princípio de **menor abstração necessária**.

## Decisão

O Makefile deve conter **apenas targets essenciais e não-triviais**:

### ✅ Manter SE:
1. **Essencial para ciclo dev local**: `cluster-up`, `dev`, `clean`
2. **Validação sem side-effects**: `helm-validate`, `status`
3. **Utilitário real que economiza tempo**: `port-forward-*`, `get-argocd-password`
4. **Bootstrap inicial** (antes do Argo CD existir): `bootstrap-argocd`, `bootstrap-workflows`

### ❌ Remover SE:
1. **Viola GitOps**: Cria recursos via `kubectl apply` em vez de Git
2. **Wrapper trivial**: Apenas chama `git`, `kubectl` ou `helm` com argumentos simples
3. **Duplica funcionalidade**: Já existe outro target que faz o mesmo
4. **Interativo**: Requer input do usuário (deve ser script separado)

### Exemplos de Remoções

**Wrappers triviais removidos**:
```makefile
# ❌ Removido - wrapper de git
gitops-commit:
    git add . && git commit && git push

# ❌ Removido - wrapper de kubectl
context-local:
    kubectl config use-context k3d-cluster

# ❌ Removido - wrapper de cp
setup-env:
    cp .env.example .env
```

**Usuário deve usar comandos diretos**:
```bash
git add . && git commit -m "msg" && git push
kubectl config use-context k3d-yby-local
cp .env.example .env
```

## Consequências

### Prós
- ✅ **Clareza**: Menos comandos = menos confusão
- ✅ **Manutenibilidade**: Menos código para manter
- ✅ **Alinhamento GitOps**: Sem comandos imperativos
- ✅ **Aprendizado**: Usuários aprendem comandos reais, não abstrações

### Contras
- ⚠️ **Curva de aprendizado**: Usuários precisam conhecer `kubectl`, `helm`, `git`
- ⚠️ **Digitação**: Alguns comandos ficam mais longos
- ⚠️ **Breaking change**: Comandos antigos não funcionam mais

## Métricas

**Redução alcançada**:
- Linhas: 907 → 597 (34%)
- Targets: ~80 → ~30 (62%)

## Targets Mantidos (~30)

### Ciclo Dev
- `cluster-up/down`, `dev`, `clean`
- `bootstrap-argocd`, `bootstrap-workflows`, `helm-bootstrap`

### Validação
- `helm-validate`, `helm-render`, `status`, `lint-yaml`

### Utilitários
- `port-forward-argocd/traefik/minio/webhook`
- `get-argocd-password`, `get-webhook-secret`, `show-webhook-config`

### Deploy Remoto
- `provision-vps`, `deploy-remote`, `remote-status`

### Diagnóstico
- `diagnose`, `diagnose-fix`

## Referências
- UKI-ARCH-001: GitOps Radical
- UKI-OPS-002: Minimal Scripts
- Walkthrough: Auditoria Radical do Makefile (2025-11-22)
