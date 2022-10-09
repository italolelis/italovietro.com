ARG VARIANT="1.19-bullseye"
FROM mcr.microsoft.com/vscode/devcontainers/go:0-${VARIANT}

RUN go install --tags extended github.com/gohugoio/hugo@latest
