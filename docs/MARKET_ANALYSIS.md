# 📊 Análise de Mercado: Plataformas de Engenharia & GitOps

Este documento compara o **Yby** com as principais soluções Open Source de Internal Developer Platforms (IDP) e GitOps disponíveis no mercado.

---

## 🏆 Principais Soluções Identificadas

### 1. Kubefirst
**O que é:** Uma plataforma GitOps instantânea que provisiona clusters (AWS, Civo, Google, etc.) e instala uma stack completa (Argo CD, Vault, Atlantis, Terraform).
- **Similaridade com Yby:** Alta. Ambos focam em entregar um cluster "pronto" com GitOps.
- **Diferença:** Kubefirst é mais opinativo sobre a stack (usa Vault obrigatoriamente, Terraform para infra) e usa uma CLI pesada. Yby é mais leve, focado em K3s/On-premise/VPS e usa Sealed Secrets (mais simples).
- **Ponto Forte:** Automação de infraestrutura de nuvem (Terraform).

### 2. Otomi
**O que é:** Uma camada de PaaS sobre o Kubernetes. Oferece uma UI unificada para gerenciar ferramentas (Keycloak, Harbor, Prometheus, etc.).
- **Similaridade com Yby:** Baixa na arquitetura, média no objetivo. Otomi esconde a complexidade do K8s.
- **Diferença:** Otomi é uma "caixa preta" que instala tudo. Yby é um template transparente onde você vê e edita os manifestos.
- **Ponto Forte:** Experiência de usuário (UI) unificada e SSO integrado.

### 3. Devtron
**O que é:** Um dashboard unificado para Kubernetes, focado em CI/CD e observabilidade.
- **Similaridade com Yby:** Baixa. Devtron foca no "Day 2" (operação) e deploy de apps.
- **Diferença:** Devtron é uma ferramenta que você instala. Yby é a fundação do cluster.
- **Ponto Forte:** Visualização de aplicações e troubleshooting.

### 4. Gimlet
**O que é:** Uma plataforma focada em simplificar o deploy para desenvolvedores, abstraindo Helm/Kubernetes.
- **Similaridade com Yby:** Média. Foca na experiência do desenvolvedor.
- **Diferença:** Gimlet é focado em criar manifestos. Yby foca na infraestrutura do cluster e discovery.

---

## ⚖️ Comparativo: Yby vs Mercado

| Feature | Yby | Kubefirst | Otomi | Devtron |
|---------|-----|-----------|-------|---------|
| **Filosofia** | Template GitOps Radical | Instant GitOps Platform | PaaS sobre K8s | App Dashboard |
| **Complexidade** | Baixa (K3s + Argo) | Alta (Vault + Terraform) | Alta (Muitos componentes) | Média |
| **Discovery** | **Zero-Touch (GitHub Topics)** | Manual / Terraform | UI Wizard | UI Wizard |
| **Infraestrutura** | Agnóstica (VPS/K3s foco) | Cloud-First (AWS/Civo) | Agnóstica | Agnóstica |
| **Custo Cognitivo** | Baixo (Arquivos YAML puros) | Médio (CLI + Terraform) | Baixo (UI) mas difícil de debugar | Baixo (UI) |
| **Customização** | Total (é um repo template) | Limitada pela CLI | Limitada pela UI | Limitada pela UI |

---

## 💡 O Diferencial do Yby (UVP)

O **Yby** se destaca por ser:
1.  **Extremamente Leve:** Roda em um VPS de $5 com K3s. Não exige Vault ou Terraform.
2.  **Zero-Touch Discovery:** A integração nativa com **GitHub Topics** para onboarding de apps é um diferencial único de usabilidade que remove a necessidade de "registrar" apps manualmente ou via CLI.
3.  **Transparente (White-box):** Ao contrário de Otomi ou Devtron, o Yby não esconde o Kubernetes. Ele entrega os manifestos prontos, servindo como uma ferramenta educacional e de base sólida para engenharia de plataforma.

## 🎯 Conclusão

- Use **Kubefirst** se você precisa de infraestrutura de nuvem complexa (AWS/GCP) e quer Terraform gerenciado.
- Use **Otomi** se você quer esconder o Kubernetes dos seus desenvolvedores e prefere uma experiência PaaS (Heroku-like).
- Use **Yby** se você quer uma **base sólida, leve e transparente** para construir sua própria plataforma interna, com foco em simplicidade, baixo custo e automação via GitOps puro.
