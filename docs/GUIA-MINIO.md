# 🪣 Guia do Módulo MinIO

Este documento explica como utilizar o **MinIO** no Yby para armazenamento de objetos (S3 Compatible).

## 1. O que é?

O **MinIO** é um servidor de armazenamento de objetos de alto desempenho, compatível com a API do AWS S3.
No contexto do Yby, ele serve como nosso **Data Lake local e de produção**, permitindo que suas aplicações armazenem arquivos (imagens, logs, backups, datasets) sem depender de serviços externos caros como AWS S3 ou Google Cloud Storage, mantendo a soberania dos dados.

## 2. Como funciona?

Quando habilitado no `yby init` (ou via `config/cluster-values.yaml`), o Yby implanta:
*   Uma instância do MinIO (Standalone ou Cluster, dependendo do modo).
*   Um serviço interno para comunicação de alta velocidade dentro do cluster.
*   (Opcional) Ingress para acesso externo e console de administração.

O MinIO roda no namespace `storage` (por padrão) e expõe dois endpoints:
*   **API (S3):** Porta 9000
*   **Console (UI):** Porta 9001

## 3. Configuração Manual em Aplicações Externas

Como conectar sua aplicação (Node.js, Python, Go, etc.) ao MinIO do cluster?

### Variáveis de Ambiente Padrão
Recomendamos configurar sua aplicação usando variáveis de ambiente compatíveis com SDKs S3 padrão.

**Para aplicações RODANDO DENTRO do cluster (Pods):**

```env
S3_ENDPOINT=http://minio.storage.svc.cluster.local:9000
S3_ACCESS_KEY=admin        # Ou valor definido na Secret
S3_SECRET_KEY=yby-admin-Secret! # Consulte a Secret real
S3_BUCKET=meu-bucket
S3_USE_SSL=false
S3_REGION=us-east-1        # Padrão do MinIO, mesmo rodando local
```

**Para acesso LOCAL (Do seu computador via Port-Forward):**

Primeiro, abra o túnel: `yby access` (ou `kubectl port-forward -n storage svc/minio 9000:9000`)

```env
S3_ENDPOINT=http://localhost:9000
S3_ACCESS_KEY=admin
S3_SECRET_KEY=yby-admin-Secret!
...
```

### Exemplo de Código (Node.js com AWS-SDK v3)

```javascript
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";

const s3 = new S3Client({
  region: "us-east-1",
  endpoint: process.env.S3_ENDPOINT, // http://minio.storage.svc.cluster.local:9000
  credentials: {
    accessKeyId: process.env.S3_ACCESS_KEY,
    secretAccessKey: process.env.S3_SECRET_KEY,
  },
  forcePathStyle: true, // IMPORTANTE para MinIO
});

const uploadParams = {
  Bucket: process.env.S3_BUCKET,
  Key: "hello.txt",
  Body: "Hello Yby World!",
};

await s3.send(new PutObjectCommand(uploadParams)); // Upload feito!
```

### Criando Buckets
Você pode criar Buckets de duas formas:
1.  **Via Console:** Acesse `http://localhost:9001` (login/senha da secret), navegue até "Buckets" e crie.
2.  **Via Bootstrap (Automático):**
    No arquivo `config/cluster-values.yaml`:

    ```yaml
    storage:
      minio:
        enabled: true
        autoBootstrap:
          enabled: true
          buckets:
            - nome-do-bucket-1
            - nome-do-bucket-2
    ```
