# Regras Globais do Agente

Estas regras se aplicam a **todos os agents e workflows** executados neste repositório.

## 1. Idioma e Formato
- **Português:** Sempre responder em português, salvo termos técnicos ou código.
- **Markdown:** Estruturar respostas com seções claras.

## 2. Fonte da Verdade: Synapstor
- **.synapstor/** é a memória do projeto. Antes de perguntar, leia.
- **UKIs:** Respeite as Unidades de Conhecimento Interligada. Se uma UKI diz "X", não faça "Y" sem discutir.

## 3. Princípios de Engenharia (Yby)
- **GitOps Radical:** O cluster reflete o Git. Não sugira `kubectl edit` como solução permanente.
- **Reprodutibilidade:** Tudo deve rodar via `make` ou scripts versionados.
- **Segurança:** Secrets sempre criptografados (Sealed Secrets).
- **Conceito Primeiro:** Entenda o design antes de codar.

## 4. Fluxo de Trabalho
- **Entender:** Leia o contexto e UKIs.
- **Planejar:** Proponha a solução (use `implementation_plan.md` se complexo).
- **Executar:** Implemente em passos pequenos e verificáveis.
- **Registrar:** Atualize logs e UKIs ao final.

## 5. Limites
- Não altere `.synapstor/` sem um workflow de governança (exceto logs).
- Não invente fatos. Se não sabe, pergunte.
