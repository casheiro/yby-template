# Módulos e Recursos Especiais

Este guia cataloga os recursos avançados da plataforma Yby: SSL Automático, Armazenamento e módulos de Ecofuturismo.

---

## 1. Domínios e SSL (Cert-Manager)

O Yby já vem configurado com **Cert-Manager** e **Let's Encrypt**.

### Configuração Global
No arquivo `config/cluster-values.yaml`:

```yaml
global:
  domainBase: "suaempresa.com"
ingress:
  tls:
    enabled: true
    email: admin@suaempresa.com
    issuer: letsencrypt-prod # Use 'letsencrypt-staging' para testes
```

### Usando em sua App
Adicione a anotação do `cluster-issuer` no seu Ingress:

```yaml
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts: [app.suaempresa.com]
    secretName: app-tls
```

---

## 2. Ecofuturismo (Eficiência Energética)

### 🍃 Kepler (Monitoramento de Energia)
O Kepler usa eBPF para medir o consumo de energia (Watts) de cada Pod sem necessidade de alterar o código da aplicação.
*   **Acesso**: Painel Grafana "Yby Energy Metrics".
*   **Boas Práticas**: Use labels (`app`, `project`, `environment`) em seus Deployments para segmentar o consumo energético.

### ⚡ KEDA (Scale-to-Zero)
O KEDA permite desligar aplicações ociosas ou fora do horário comercial.

**Exemplo: Desligar às 20h e ligar às 8h**
Crie um `ScaledObject` na pasta `infra/`:

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata: { name: scale-to-zero }
spec:
  scaleTargetRef: { name: meu-deployment }
  minReplicaCount: 0
  maxReplicaCount: 1
  triggers:
  - type: cron
    metadata:
      timezone: America/Sao_Paulo
      start: 0 20 * * *        # Desliga 20h
      end: 0 8 * * *          # Liga 08h
      desiredReplicas: "0"
```

---

## 3. Armazenamento de Objetos (MinIO)

O MinIO fornece uma API compatível com S3 dentro do cluster.

### Habilitando
No `yby init` ou `config/cluster-values.yaml`:
```yaml
storage:
  minio: { enabled: true }
```

### Conectando sua Aplicação
Use variáveis de ambiente padrão S3.
*   **Endpoint Interno**: `http://minio.storage.svc.cluster.local:9000`
*   **Endpoint Local**: `http://localhost:9000` (via `yby access`)
*   **Credenciais**: Definidas na secret do MinIO (padrão user: `admin`).

**Exemplo (Node.js):**
```javascript
const s3 = new S3Client({
  region: "us-east-1",
  endpoint: process.env.S3_ENDPOINT,
  credentials: { accessKeyId: "...", secretAccessKey: "..." },
  forcePathStyle: true
});
```
