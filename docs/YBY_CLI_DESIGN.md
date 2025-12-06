# Arquitetura da Solução: Yby CLI & Template

## 1. Visão do Produto
Transformar o **Yby** de apenas um "repositório de infraestrutura" para uma **Plataforma de Engenharia** completa, composta por dois pilares:

1.  **Yby Template:** O repositório GitOps (estado atual), purificado para ser agnóstico e clonável.
2.  **Yby CLI:** O orquestrador que lê o template e executa a automação.
3.  **Blueprint Engine:** O cérebro da CLI. Um arquivo `.yby/blueprint.yaml` no template dita como a CLI deve se comportar.

## 2. Filosofia "Zero Lock-in"

## 2. Filosofia "Zero Lock-in"
A CLI deve funcionar como um **facilitador**, não um **requisito**.
- **Regra de Ouro:** Tudo o que a CLI faz deve ser possível de fazer com comandos nativos (`kubectl`, `helm`, `git`, `kubeseal`).
- **Transparência:** A CLI deve (opcionalmente) mostrar os comandos nativos que está executando (modo `--verbose` ou `--dry-run`).

## 3. Arquitetura da CLI

**Tecnologia Sugerida:** Go (Golang) com Cobra Framework.
**Motivo:** Binário único, estático, rápido, tipado e padrão no ecossistema Cloud Native (Kubernetes, Helm, Argo são feitos em Go).

### Comandos Propostos

| Comando | Função | Substituto Manual (Exemplo) |
| :--- | :--- | :--- |
| `yby init` | Wizard interativo para gerar `config/cluster-values.yaml` | Edição manual do YAML |
| `yby bootstrap` | Provisiona VPS e instala K3s + Argo CD | `ansible-playbook` ou scripts bash |
| `yby doctor` | Valida dependências locais e saúde do cluster | `kubectl get nodes`, `helm version` |
| `yby secret seal` | Cria e sela secrets interativamente | `kubectl create secret ... | kubeseal ...` |
| `yby access` | Abre túneis para Dashboards (Argo, Grafana) | `kubectl port-forward ...` |
| `yby app create` | Scaffold de nova aplicação (Zero-Touch) | `mkdir k8s && touch deployment.yaml` |

### Smart Init (Blueprint Engine)
A `yby init` não é hardcoded. Ela:
1.  Lê o `.yby/blueprint.yaml` do diretório atual.
2.  Constrói perguntas (`prompts`) dinamicamente.
3.  Aplica as respostas via **Patch YAML** no `config/cluster-values.yaml`.
4.  Além disso, o blueprint define versões de infraestrutura (ex: ArgoCD), desacoplando o binário da configuração.

## 4. Estratégia de Migração (Concluída)

### Fase 1: Design & MVP (Atual)
- Definir escopo (este documento).
- Criar estrutura do projeto CLI (`cli/`).

### Fase 2: Refatoração do Template
- Limpar `scripts/` legados.
- Garantir que `Makefile` aponte para a CLI (ex: `make install` -> `yby bootstrap`).

### Fase 3: Implementação da CLI
- Implementar comandos core (`init`, `bootstrap`).
- Substituir scripts Shell complexos por código Go testável.

## 5. Benefícios
1.  **Qualidade:** Validação de input antes de tentar aplicar no cluster.
2.  **Velocidade:** Setup inicial em minutos com wizard guiado.
3.  **Manutenibilidade:** Código Go é mais fácil de manter e testar que scripts Bash gigantes.
4.  **Distribuição:** Usuário baixa um binário e roda, sem precisar instalar 10 dependências (a CLI pode até baixar o `kubectl` se precisar).

## 6. Próximos Passos (Plano de Ação)
1.  Aprovar este Design.
2.  Inicializar módulo Go em `cli/`.
3.  Implementar `yby doctor` como prova de conceito.
