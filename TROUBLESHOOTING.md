# Guia de Troubleshooting Yby

Este guia consolida soluções para problemas comuns encontrados durante o provisionamento e operação do cluster Yby.

## 1. Conectividade e Acesso (SSH)

### Erro: `Host key verification failed`
**Sintoma:** O script de provisionamento falha ao tentar conectar via SSH.
**Causa:** O IP do VPS foi reutilizado ou o servidor foi recriado, mas o arquivo `~/.ssh/known_hosts` local ainda contém a assinatura antiga.
**Solução:**
O projeto agora utiliza configurações que ignoram o `known_hosts` global para IPs efêmeros. Se você estiver rodando comandos manuais fora dos scripts:
```bash
ssh-keygen -R <IP_DO_VPS>
```
Ou use a flag: `-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no`

### Erro: `kex_exchange_identification`
**Sintoma:** A conexão SSH é encerrada abruptamente durante o handshake.
**Causa:** Bloqueio de segurança (Fail2Ban) no servidor devido a múltiplas tentativas falhas.
**Solução:**
Aguarde 10-15 minutos para o banimento expirar ou acesse o console do provedor (VNC) para desbloquear o IP.

## 2. Certificados e TLS

### Erro: `x509: certificate unknown authority`
**Sintoma:** O `kubectl` falha ao conectar no cluster remoto.
**Causa:** O certificado gerado pelo K3s não inclui o IP público do VPS nos SANs (Subject Alternative Names).
**Solução:**
O script de instalação atual já inclui `--tls-san <IP_PUBLICO>`. Se o erro persistir, force a reinstalação do K3s:
```bash
# No servidor
systemctl stop k3s
curl -sfL https://get.k3s.io | sh -s - server --tls-san <SEU_IP>
```

## 3. Argo CD e GitOps

### Status `Unknown` em Aplicações
**Sintoma:** Aplicações no Argo CD ficam cinza (`Unknown`) e mostram erro de autenticação ao tentar sync.
**Causa:** O Argo CD não tem credenciais para acessar o repositório Git privado.
**Solução:**
Certifique-se de ter rodado o bootstrap com as variáveis de ambiente definidas:
```bash
export GITHUB_TOKEN=seu_token
export GITHUB_REPO=sua_url_repo
make bootstrap
```
Isso cria o secret `argocd-repo-creds` automaticamente.

### Erro: `SyncFailed` (CRD missing)
**Sintoma:** O sync falha reclamando que um CRD (ex: `ServiceMonitor`, `Certificate`) não existe.
**Causa:** Condição de corrida. A aplicação tentou criar um recurso antes do CRD ser instalado pelo chart `system`.
**Solução:**
O `make bootstrap` agora inclui uma etapa de espera (`wait-for-crds`). Se ocorrer manualmente:
1. Aguarde alguns instantes.
2. Force um novo sync no Argo CD.
