# Plano de Recuperação: Estabilização do Cluster Casheiro

**Status Atual:** 🚨 Instável / Parcialmente Funcional
**Objetivo:** Parar, respirar e corrigir a infraestrutura de forma estruturada, garantindo que Observabilidade (Prometheus/Grafana), Ingress (Traefik) e UI (Headlamp) funcionem harmonicamente.

## 1. Diagnóstico da Situação

| Componente | Status | Problema Identificado | Causa Raiz |
|------------|--------|-----------------------|------------|
| **Argo CD** | ✅ OK | Funcional e acessível. | - |
| **Headlamp** | ⚠️ Parcial | Erro de permissão ao listar recursos. | Falta de `ClusterRoleBinding` adequado para o ServiceAccount ou Token incorreto. |
| **Traefik** | 💥 Conflito | Duplicidade de Ingress Controller. | O K3s já traz o Traefik (ServiceLB). O Chart `bootstrap` tentou instalar outro via Helm, gerando conflito de portas/recursos. |
| **Prometheus** | ❌ Ausente | Não foi instalado. | A condição `condition: observability.prometheus.enabled` no `Chart.yaml` falhou ou o Argo CD não sincronizou a versão correta do chart após as mudanças no Git. |
| **Grafana** | ❌ Ausente | Depende do Prometheus. | Sem Prometheus, o script `start-local-grafana.sh` falha ao tentar conectar. |

## 2. Estratégia de Correção (Passo a Passo)

Não faremos mais "hotfixes". A abordagem será: **Limpar -> Corrigir Código -> Reaplicar -> Validar**.

### Fase 1: Estabilização do Código (Git)
1.  **Traefik:** Remover *definitivamente* a instalação do Traefik pelo Chart `bootstrap`. Usaremos o Traefik nativo do K3s (que já funciona bem para este cenário).
2.  **Prometheus:** Remover a condicional complexa no `Chart.yaml`. Vamos deixar a dependência fixa e controlar a habilitação via `values.yaml` (enabled: true/false). É mais robusto.
3.  **Headlamp:** Adicionar o manifesto de `ClusterRoleBinding` administrativo diretamente no Chart `bootstrap` ou `cluster-config` para garantir que o token gerado tenha poderes.

### Fase 2: Limpeza do Cluster (Cleanup)
1.  Remover a Application `cluster-config` no Argo CD (com `cascade=false` para não deletar tudo, ou `true` se quisermos reset total - recomendo reset controlado dos componentes problemáticos).
2.  Remover manualmente recursos órfãos do Traefik (Deployments, Services duplicados).
3.  Garantir que não existam CRDs de Prometheus "zumbis" impedindo a nova instalação.

### Fase 3: Reaplicação Controlada
1.  Commitar as correções no branch `feature/ecofuturism-kubernetes`.
2.  Sincronizar o Argo CD apontando explicitamente para este branch.
3.  Aguardar o `Healthy` status de todos os componentes.

### Fase 4: Validação Final
1.  **Acesso:** Testar `make access` novamente.
2.  **Grafana:** Rodar `make dashboard` e verificar se ele encontra o Prometheus no cluster.
3.  **Headlamp:** Acessar com o token e verificar se os erros de permissão sumiram.

## 3. Próximos Passos (Execução)

Aguardo sua aprovação para iniciar a **Fase 1**.
