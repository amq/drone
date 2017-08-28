# docker build --rm -t drone/drone .

FROM golang:1.8
EXPOSE 8000 80 443

ENV DRONE_UI_BUILD_NUMBER 0.7.0
ENV DATABASE_DRIVER=sqlite3
ENV DATABASE_CONFIG=/var/lib/drone/drone.sqlite
ENV GODEBUG=netdns=go
ENV XDG_CACHE_HOME /var/lib/drone

COPY . /go/src/github.com/drone/drone
RUN git clone -b v${DRONE_UI_BUILD_NUMBER} https://github.com/drone/drone-ui github.com/drone/drone-ui \
    && go get -d github.com/drone/drone-ui/dist \
    && go build -o release/drone github.com/drone/drone/drone
COPY release/drone /drone
RUN rm -rf /go/src

ENTRYPOINT ["/drone"]
CMD ["server"]
