# Status do Projeto Yby (Cluster Casheiro)

**Data:** 26/11/2025
**Objetivo:** Estabilização e Validação do Ambiente de Produção.

## 🏗️ Arquitetura Atual: "Remote Headless"
O cluster de produção roda apenas os serviços essenciais. Interfaces gráficas (UIs) rodam localmente e se conectam via túnel seguro.

| Componente | Local (Dev) | Produção (VPS) | Status Prod |
| :--- | :--- | :--- | :--- |
| **Cluster** | k3d (`yby-local`) | K3s (`154.12.237.219`) | ✅ Online |
| **Ingress** | Traefik (k3s) | Traefik (k3s) | ✅ Online (Port 80/443) |
| **Argo CD** | UI + Server | **Server Only** (Headless) | ⚠️ **UI Quebrada (404)** |
| **Headlamp** | UI + Server | **Removido** | ✅ Removido (Limpo) |
| **Grafana** | Docker Local | Prometheus Only | ✅ Conectado via Túnel |

## 🚫 Problema Atual (Bloqueio)
**Argo CD UI retorna erro 404.**
- **Causa Raiz Identificada:** O diretório de assets estáticos (`/shared/app`) dentro do pod `argocd-server` está vazio.
- **Diagnóstico:** Provável falha na instalação/atualização do Helm Chart que corrompeu os volumes ou init-containers.
- **Consequência:** A API funciona, mas a tela de login não carrega.

## 🎯 Próximos Passos (Plano de Recuperação)
Para retomar a simplicidade e garantir o funcionamento:

1.  **Reset do Argo CD:** Desinstalar completamente o Argo CD do servidor (`helm uninstall`).
2.  **Reinstalação Limpa:** Rodar `make bootstrap` novamente. Isso forçará a recriação correta dos volumes e assets.
3.  **Validação:** Testar acesso local novamente.

---
*Este documento serve como ponto de referência para encerrar loops de debug e focar na resolução estrutural.*
