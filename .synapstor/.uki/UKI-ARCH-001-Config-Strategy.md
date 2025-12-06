---
uki_id: UKI-ARCH-001
domain: architecture
status: active
authors: [antigravity, user]
creation_date: 2025-11-30
tags: [config, gitops, k3s, architecture]
---

# UKI-ARCH-001: Estratégia de Configuração e Ciclo de Vida de Infraestrutura

## Contexto
O projeto enfrentava dificuldades em gerenciar configurações que cruzavam a fronteira entre "Infraestrutura" (nível do nó/OS) e "Aplicação" (nível do Kubernetes). Tentativas anteriores de usar substituição de variáveis de ambiente (`envsubst`) em arquivos de manifesto Kubernetes (`values.yaml`) quebraram o modelo GitOps, pois o Argo CD não tem acesso às variáveis do ambiente local onde o repositório foi clonado. Além disso, a atualização do cluster (ex: versão do K3s, argumentos do kubelet) dependia de re-execução manual de scripts SSH, violando o princípio de "Git como fonte única da verdade".

## Decisão
Adotamos uma estratégia de **Separação Estrita de Responsabilidades** dividida em três fases, eliminando a injeção de variáveis em tempo de deploy para aplicações e adotando o **System Upgrade Controller** para gerenciamento de infraestrutura.

### 1. Bootstrap (Day 0) - Imperativo
*   **Responsável:** Script `provision-vps.sh` + Arquivo `.env`.
*   **Escopo:** Preparação do SO, Instalação inicial do binário K3s, Configuração de Rede Básica.
*   **Mecanismo:** SSH direto.
*   **Idempotência:** O script deve ser capaz de rodar múltiplas vezes sem efeitos colaterais destrutivos, mas seu uso primário é apenas na criação.

### 2. Aplicações (Day 1) - Declarativo Estático
*   **Responsável:** Argo CD + `cluster-values.yaml`.
*   **Escopo:** Deploy de Apps, Ingress, Cert-Manager, Observabilidade.
*   **Mecanismo:** GitOps Puro.
*   **Regra:** Arquivos `values.yaml` NÃO devem conter variáveis de ambiente (`${VAR}`). Devem conter valores estáticos ou referências a Secrets/ConfigMaps já existentes.

### 3. Ciclo de Vida de Infraestrutura (Day 2+) - Declarativo GitOps
*   **Responsável:** System Upgrade Controller (SUC).
*   **Escopo:** Atualização de versão do Kubernetes (K3s), Alteração de argumentos do Kubelet (ex: `max-pods`), Atualização do SO (se suportado).
*   **Mecanismo:** Planos de Upgrade (`Plan` CRD) aplicados via Argo CD.
*   **Fluxo:** O usuário altera a versão/config no Git -> Argo CD aplica o `Plan` -> SUC orquestra a atualização dos nós.

## Consequências

### Positivas
*   **GitOps Verdadeiro:** O estado do cluster (incluindo sua versão) está declarado no Git.
*   **Simplicidade:** Fim da complexidade de `envsubst` e Makefiles geradores de config.
*   **Segurança:** Credenciais de infraestrutura ficam no `.env` (não commitado) e não vazam para manifestos.
*   **Auditabilidade:** Mudanças na infraestrutura ficam registradas no histórico do Git.

### Negativas
*   **Dependência de Componente:** Adiciona o `system-upgrade-controller` como componente crítico.
*   **Latência:** Atualizações de infraestrutura não são imediatas; dependem do ciclo de sync do Argo CD e da orquestração do SUC.
