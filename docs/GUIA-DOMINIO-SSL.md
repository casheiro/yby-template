# Guia: Configurando Domínio Próprio e SSL

Este projeto utiliza **Cert-Manager** com **Let's Encrypt** para gerar certificados SSL automaticamente para seus domínios.

## 1. Pré-requisitos de DNS

Para que o certificado seja gerado e o acesso funcione, você deve configurar o DNS do seu domínio para apontar para o IP do LoadBalancer do seu cluster (Traefik).

Crie entradas A (ou CNAME) wildcard e específicas:

```
*.exemplo.com  ->  A   1.2.3.4 (IP do Cluster)
exemplo.com    ->  A   1.2.3.4 (IP do Cluster)
```

Substitua `1.2.3.4` pelo IP público do seu servidor/cluster.

## 2. Configurando no Yby

Edite o arquivo `config/cluster-values.yaml`:

```yaml
global:
  domainBase: "suaempresa.com"

ingress:
  enabled: true
  tls:
    email: admin@suaempresa.com
    issuer: letsencrypt-prod
```

Isso fará com que o Argo CD, Grafana e MinIO sejam expostos em:
- `argocd.suaempresa.com`
- `grafana.suaempresa.com`
- `minio.suaempresa.com`

> **Dica**: Use `letsencrypt-staging` no `issuer` enquanto estiver testando para não atingir os limites de taxa da Let's Encrypt. Quando tudo estiver funcionando, mude para `letsencrypt-prod`.

## 3. Configurando Apps Externos

Ao fazer o deploy de uma aplicação própria, use o seguinte template de Ingress para garantir HTTPS automático:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minha-app
  annotations:
    # Esta anotação diz ao cert-manager para usar o emissor configurado (Let's Encrypt)
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  ingressClassName: traefik
  tls:
  - hosts:
    - app.suaempresa.com
    # O cert-manager criará este Secret com o certificado automaticamente
    secretName: minha-app-tls
  rules:
  - host: app.suaempresa.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: minha-app-service
            port:
              number: 80
```
