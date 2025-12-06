# Contribuindo para a Yby CLI

Este guia descreve como configurar seu ambiente de desenvolvimento para contribuir com a CLI do Yby.

## 📋 Pré-requisitos

- **Go 1.22+**: [Instalar Go](https://go.dev/doc/install)
- **Make**: Para rodar tarefas de automação (opcional, mas recomendado).

## 🛠️ Configuração do Ambiente

1.  **Instale o Cobra CLI** (Gerador de código):
    A ferramenta `cobra-cli` é usada para gerar a estrutura de comandos padrão.

    ```bash
    go install github.com/spf13/cobra-cli@latest
    ```

    Certifique-se de que `$GOPATH/bin` está no seu `$PATH`.

2.  **Clone o repositório** (se ainda não fez):
    ```bash
    git clone https://github.com/my-user/yby-template.git
    cd yby
    ```

## 🚀 Build e Execução

O código da CLI reside no diretório `cli/`.

### Compilar binário
```bash
# Compila o binário 'yby' na raiz do projeto
go build -o yby ./cli
```

### Rodar diretamente
```bash
go run ./cli doctor
```

## 🧪 Testes

```bash
go test ./cli/... -v
```

## 🏗️ Criando um Novo Comando

Use o `cobra-cli` para gerar o esqueleto de novos comandos:

```bash
cd cli
cobra-cli add [nome-do-comando]
```

Exemplo:
```bash
cd cli
cobra-cli add access
```
Isso criará `cli/cmd/access.go`.
