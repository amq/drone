# docker build --rm -t drone/drone .

FROM golang:1.8 as builder
EXPOSE 8000 80 443

ENV DRONE_UI_BUILD_NUMBER 0.7.0
ENV DATABASE_DRIVER=sqlite3
ENV DATABASE_CONFIG=/var/lib/drone/drone.sqlite
ENV GODEBUG=netdns=go
ENV XDG_CACHE_HOME /var/lib/drone

WORKDIR /go/src
ADD . /go/src/github.com/drone/drone
RUN git clone -b v${DRONE_UI_BUILD_NUMBER} https://github.com/drone/drone-ui github.com/drone/drone-ui \
    && go get github.com/drone/drone-ui/dist \
    && go get golang.org/x/tools/cmd/cover \
    && go get golang.org/x/net/context \
    && go get golang.org/x/net/context/ctxhttp \
    && go get github.com/golang/protobuf/proto \
    && go get github.com/golang/protobuf/protoc-gen-go \
    && go get github.com/drone/drone/store/datastore \
    && go get ./... \
    && go build -ldflags '-extldflags "-static"' -o release/drone github.com/drone/drone/drone \
    && mv release/drone /drone \
    && rm -rf /go/src

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /
COPY --from=builder /drone .
ENTRYPOINT ["/drone"]
CMD ["server"]
