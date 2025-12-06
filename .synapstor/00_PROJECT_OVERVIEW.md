# Visão Geral do Projeto

## 1. Identidade (Yby)
**Slogan:** GitOps Radical. Zero-Touch. Agnóstico.
**Definição:** O solo fértil para suas aplicações. Transforme qualquer VPS em um cluster Kubernetes de produção em minutos, com descoberta automática de serviços e governança preparada para IA.
**Proposta de Valor:** O Yby não é apenas um instalador. É um **Template de Engenharia de Plataforma** desenhado para escalar. Ele elimina a fadiga de configuração entregando uma stack GitOps completa, segura e auditável.

## 2. Diferenciais Reais
- **Zero-Touch Discovery:** Esqueça a edição manual de manifestos. Crie um repo, adicione a tag e o Yby descobre e faz o deploy.
- **GitOps Puro:** Argo CD no comando. Sem comandos imperativos, sem 'drift'. O estado do cluster é reflexo fiel do Git.
- **DevGovOps & IA:** Estrutura **Synapstor** integrada para que Agentes de IA entendam, operem e evoluam a infraestrutura.
- **Release Automatizado:** Pipeline CI/CD com Conventional Commits, versionamento semântico e changelogs automáticos.
- **Leve & Agnóstico:** Roda liso em VPS simples (K3s) ou Bare Metal. Sem "taxa Enterprise".
- **Open Source de Verdade:** Código transparente, auditável e feito pela comunidade.

## 3. Ecossistema Tecnológico (Metáfora Orgânica)
Uma seleção curada das melhores ferramentas Open Source, orquestradas para trabalharem em harmonia.

- **Atmosfera (Visão, Governança & Automação):**
    - *Tools:* Synapstor, Release Please, GitHub Actions.
- **Tronco (Acesso, Segurança & Identidade):**
    - *Tools:* Traefik, Cert-Manager, Sealed Secrets.
- **Raízes (GitOps, Gerenciamento & Updates):**
    - *Tools:* Argo CD, Argo Workflows, Headlamp, **Kepler** (Energia), **KEDA** (Eficiência).
- **Substrato (Infraestrutura & Runtime):**
    - *Tools:* K3s, Linux, Helm.

## 4. Tribos (Público Alvo)
- **O Explorador:** Entusiastas e indie devs. Busca custo zero e aprendizado acelerado.
- **O Construtor:** Startups e Scale-ups. Busca Zero-Touch e deploys em segundos.
- **O Guardião:** Enterprise e Times de Plataforma. Busca Governança, auditoria e segurança.

## 5. Mapa de Módulos
- `setup/`: Scripts de bootstrap VPS (Legado/Manutenção).
- `cluster-config/`: Definições GitOps (Kustomize) do estado desejado.
- `manifests/`: Recursos Kubernetes raw.
- `workflows/`: Definições de pipelines CI.
- `local/`: Ambiente de desenvolvimento (K3d).
