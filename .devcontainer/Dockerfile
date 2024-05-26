ARG VARIANT="1.20-bullseye"
FROM mcr.microsoft.com/vscode/devcontainers/go:0-${VARIANT}

RUN go install --tags extended github.com/gohugoio/hugo@latest
