FROM golang:1.25.5-alpine3.21@sha256:b4dbd292a0852331c89dfd64e84d16811f3e3aae4c73c13d026c4d200715aff6 AS builder

ENV CGO_ENABLED=0 \
    GOOS=linux

WORKDIR /src

COPY go.mod go.sum ./
RUN apk add --no-cache git && go mod download

COPY . .
RUN go build -o alertmanager-ntfy ./cmd/alertmanager-ntfy

FROM gcr.io/distroless/static:nonroot@sha256:01e550fdb7ab79ee7be5ff440a563a58f1fd000ad9e0c532e65c3d23f917f1c5

WORKDIR /

COPY --from=builder /src/alertmanager-ntfy /usr/local/bin/alertmanager-ntfy
COPY --from=builder /src/config.example.yml /etc/alertmanager-ntfy/config.yml

EXPOSE 8000

ENTRYPOINT ["/usr/local/bin/alertmanager-ntfy"]
CMD ["--configs", "/etc/alertmanager-ntfy/config.yml"]
