# === STAGE 1: BUILD ===
FROM golang:1.22-alpine AS builder
RUN apk add --no-cache git ca-certificates
WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /bin/sentinel ./src/sentinel-core

# === STAGE 2: RUNTIME ===
FROM gcr.io/distroless/static:nonroot@sha256:... # pinned hash
COPY --from=builder /bin/sentinel /sentinel
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY configs/waf/ /etc/sentinel/waf/
USER 65532:65532
EXPOSE 8080 8443
ENTRYPOINT ["/sentinel"]
CMD ["--config=/etc/sentinel/config.yaml", "--mode=guard"]
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD ["/sentinel", "--health"]
