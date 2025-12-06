# Publicação de Aplicações por Tipo (GitOps)

## Objetivo
Publicar aplicações no cluster apenas com `infra/*.yaml` no repositório do app, com HTTPS automático e validações de rede.

## Fluxo GitOps (Zero-Touch)
- Repositório do app com pasta `infra/` na branch `main`.
- **Tópico do GitHub**: `yby-app` (adicionado nas configurações do repo).
- Argo CD descobre automaticamente e sincroniza para o namespace `apps`.
- Traefik é o `IngressClass` com TLS automático via Let’s Encrypt.

⚠️ **Importante:** TLS só será provisionado se `ingress.tls.enabled: true` no `config/cluster-values.yaml`.  
Consulte o [Guia de Produção](PRODUCAO-GUIDE.md) para habilitar TLS.

## Pré‑requisitos
- DNS wildcard `*.seu-dominio.com` apontando para o IP público do servidor.
- Portas 80 e 443 acessíveis até o Traefik.

## Padrão mínimo de manifests
- `infra/deployment.yaml`: `Deployment` do app.
- `infra/service.yaml`: `Service` `ClusterIP` com a porta do app.
- `infra/ingress.yaml`: `Ingress` com `ingressClassName: traefik` e anotações para TLS.
- Opcional: hooks `PreSync`, `PostSync` e `SyncFail` para validação e limpeza.

### Ingress base
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minha-app
  namespace: apps
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
    traefik.ingress.kubernetes.io/router.tls.certresolver: letsencrypt
spec:
  ingressClassName: traefik
  rules:
  - host: app.seu-dominio.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: minha-app-svc
            port:
              number: 80
```

### Hooks de validação
Veja exemplos prontos em `examples/app-k8s/preflight.yaml`, `examples/app-k8s/postsync-validate.yaml` e `examples/app-k8s/cleanup-on-failure.yaml`.

## Tipos de Aplicação

### Java Spring Boot (HTTP)
- Porta padrão: 8080
- Health: `/actuator/health`

`Dockerfile`
```dockerfile
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY target/app.jar /app/app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
```

`infra/deployment.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spring-app
  namespace: apps
spec:
  replicas: 2
  selector:
    matchLabels:
      app: spring-app
  template:
    metadata:
      labels:
        app: spring-app
    spec:
      containers:
      - name: spring-app
        image: ghcr.io/seu-usuario/spring-app:latest
        ports:
        - containerPort: 8080
        readinessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 10
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 30
```

`infra/service.yaml`
```yaml
apiVersion: v1
kind: Service
metadata:
  name: spring-app-svc
  namespace: apps
spec:
  selector:
    app: spring-app
  ports:
  - port: 80
    targetPort: 8080
```

`infra/ingress.yaml`
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: spring-app
  namespace: apps
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
    traefik.ingress.kubernetes.io/router.tls.certresolver: letsencrypt
spec:
  ingressClassName: traefik
  rules:
  - host: spring.seu-dominio.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: spring-app-svc
            port:
              number: 80
```

### Kotlin Quarkus (HTTP)
- Porta padrão: 8080
- Health: `/q/health`

`Dockerfile`
```dockerfile
FROM quay.io/quarkus/quarkus-micro-image:2.16
WORKDIR /work
COPY target/quarkus-app/ /work/
EXPOSE 8080
ENTRYPOINT ["/work/bin/java","-jar","/work/quarkus-run.jar"]
```

Manifests: ajustar nomes e endpoints como no exemplo de Spring, trocando o caminho de health para `/q/health`.

### Python FastAPI (HTTP)
- Porta padrão: 8000

`Dockerfile`
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt /app/requirements.txt
RUN pip install -r requirements.txt
COPY . /app
EXPOSE 8000
ENTRYPOINT ["uvicorn","main:app","--host","0.0.0.0","--port","8000"]
```

`infra/deployment.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fastapi-app
  namespace: apps
spec:
  replicas: 2
  selector:
    matchLabels:
      app: fastapi-app
  template:
    metadata:
      labels:
        app: fastapi-app
    spec:
      containers:
      - name: fastapi-app
        image: ghcr.io/seu-usuario/fastapi-app:latest
        ports:
        - containerPort: 8000
        readinessProbe:
          httpGet:
            path: /
            port: 8000
          initialDelaySeconds: 10
        livenessProbe:
          httpGet:
            path: /
            port: 8000
          initialDelaySeconds: 30
```

`infra/service.yaml`
```yaml
apiVersion: v1
kind: Service
metadata:
  name: fastapi-app-svc
  namespace: apps
spec:
  selector:
    app: fastapi-app
  ports:
  - port: 80
    targetPort: 8000
```

`infra/ingress.yaml`
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: fastapi-app
  namespace: apps
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
    traefik.ingress.kubernetes.io/router.tls.certresolver: letsencrypt
spec:
  ingressClassName: traefik
  rules:
  - host: api.seu-dominio.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: fastapi-app-svc
            port:
              number: 80
```

### NuxtJS SSR
- Porta padrão: 3000

`Dockerfile`
```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
EXPOSE 3000
ENTRYPOINT ["npm","run","start"]
```

Manifests: `Deployment` com `containerPort: 3000`, `Service` `targetPort: 3000`, `Ingress` para o host desejado.

### NuxtJS SPA (estático via Nginx)
- Porta padrão: 80

`Dockerfile`
```dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
FROM nginx:alpine
COPY --from=build /app/.output/public /usr/share/nginx/html
EXPOSE 80
```

Manifests: `Service` com `port: 80`, `Ingress` com TLS como nos exemplos.

### Node.js Express API
- Porta padrão: 3000

`Dockerfile`
```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
EXPOSE 3000
ENTRYPOINT ["node","server.js"]
```

Manifests: ajustar como nos exemplos, trocando `targetPort` para 3000.

### Go (Gin/Fiber)
- Porta padrão: 8080

`Dockerfile`
```dockerfile
FROM golang:1.22-alpine AS build
WORKDIR /src
COPY . .
RUN go build -o app
FROM alpine:3.20
WORKDIR /app
COPY --from=build /src/app /app/app
EXPOSE 8080
ENTRYPOINT ["/app/app"]
```

Manifests: `Service` com `targetPort: 8080` e `Ingress` conforme exemplos.

### Função Python estilo Lambda (no cluster)
- O cluster não possui runtime serverless dedicado.
- Use HTTP com FastAPI ou execute como `Job/CronJob` para tarefas assíncronas.

`infra/job.yaml`
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: funcao-python
  namespace: apps
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: job
        image: ghcr.io/seu-usuario/funcao-python:latest
        command: ["python","main.py"]
```

## Validações e limpeza automáticas
- Inclua os hooks dos exemplos para validar rede e HTTPS e limpar recursos em caso de erro.

## Publicação
- Ajuste `image`, nomes de recursos e `host`.
- Push na branch `main`.
- Verifique que o ApplicationSet sincronizou seu app e que o certificado foi emitido.