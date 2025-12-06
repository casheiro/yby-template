# UKI-OPS-006: Ordem de Bootstrap Helm

**Status**: `active`  
**Domínio**: Operações  
**Tags**: `bootstrap`, `helm`, `makefile`, `ordem-execucao`  
**Criado em**: 2025-11-22  
**Última atualização**: 2025-11-22

## Contexto

Durante a refatoração para adotar Helm como ferramenta única de gerenciamento, descobrimos que o `helm-bootstrap` depende de CRDs (Custom Resource Definitions) do Argo Workflows e Argo Events que não são instalados automaticamente pelo Argo CD.

Sem esses CRDs, o `helm upgrade --install bootstrap` falha com erros como:
```
resource mapping not found for name: "compliance-nightly" namespace: "argocd" from "": 
no matches for kind "CronWorkflow" in version "argoproj.io/v1alpha1"
ensure CRDs are installed first
```

## Decisão

A ordem correta de bootstrap para um cluster do zero é:

1. **`make bootstrap-argocd`**: Instala Argo CD core (deployment, CRDs de Application)
2. **`make bootstrap-workflows`**: Instala Argo Workflows e Argo Events (CRDs de Workflow, EventBus, etc.)
3. **`make helm-bootstrap`**: Instala o chart bootstrap que cria Applications, WorkflowTemplates, etc.

Esta ordem foi codificada no target `make dev`:
```makefile
dev:
    @make cluster-up
    @make bootstrap-argocd
    @make bootstrap-workflows
    @sleep 10
    @make helm-bootstrap
    @make status
```

## Consequências

### Prós
- ✅ Ordem explícita e documentada
- ✅ Evita falhas de "CRD not found"
- ✅ Fluxo reproduzível e previsível
- ✅ Target `dev` funciona "out of the box"

### Contras
- ⚠️ Três comandos separados em vez de um único
- ⚠️ Requer conhecimento da ordem para execução manual

## Alternativas Consideradas

1. **Incluir CRDs no chart bootstrap**: Descartado porque os CRDs do Argo são grandes e versionados independentemente.
2. **Usar Helm hooks**: Descartado porque hooks não garantem ordem entre charts diferentes.
3. **Criar um "super-chart" que inclui tudo**: Descartado por aumentar complexidade e dificultar manutenção.

## Referências
- Teste end-to-end: `/home/neto/.gemini/antigravity/brain/.../walkthrough.md`
- Makefile: `make dev` (linha ~373)
- UKI relacionada: `UKI-ARCH-004-HELM-BOOTSTRAP`
