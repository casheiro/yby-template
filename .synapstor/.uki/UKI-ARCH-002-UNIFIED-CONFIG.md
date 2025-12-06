---
uki_id: UKI-ARCH-002
titulo: Configuração Unificada via .env
status: active
criado_em: 2025-11-20
autor: Persona Arquiteto
tags: [arquitetura, configuração, simplificação]
---

# Contexto
O projeto utilizava um sistema híbrido de configuração inspirado em Spring Boot, misturando um arquivo YAML (`config/vps-config.yml`) com variáveis de ambiente e scripts de conversão complexos. Isso gerava confusão sobre a precedência de valores, dificultava a manutenção e aumentava a superfície de erros em scripts bash.

# Decisão/Regra
1. **Fonte Única (.env):** O arquivo `.env` é a única fonte de verdade para configurações sensíveis e específicas do ambiente.
2. **Sem Defaults no Git:** Não deve existir arquivo de configuração com valores "default" versionado no Git que seja lido em tempo de execução pelos scripts. O `.env.example` serve apenas como documentação.
3. **Falha Rápida:** Scripts devem validar a existência das variáveis necessárias no início e falhar imediatamente se algo estiver faltando, sem tentar adivinhar ou usar fallbacks complexos.

# Consequências
- **Pros:**
  - Simplicidade extrema: "O que está no .env é o que vale".
  - Redução de código de infraestrutura (scripts de parsing removidos).
  - Menor risco de vazar configurações padrão inseguras.
- **Cons:**
  - Perda da capacidade de ter "defaults em cascata" complexos (o que foi considerado desnecessário para a complexidade atual).

# Referências
- Remoção de `config/vps-config.yml` e `scripts/convert-config-to-env.sh` (2025-11-20).
