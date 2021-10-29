FROM golang AS build-env
# The GOPATH in the image is /go.
ADD . /go/src/github.com/sjtug/lug
WORKDIR /go/src/github.com/sjtug/lug
RUN go build github.com/sjtug/lug/cli/lug
RUN curl -L https://github.com/prometheus/node_exporter/releases/download/v1.2.2/node_exporter-1.2.2.linux-amd64.tar.gz --output /tmp/node_exporter-1.2.2.linux-amd64.tar.gz && \
    tar -xzf /tmp/node_exporter-1.2.2.linux-amd64.tar.gz -C /tmp && \
    mv /tmp/node_exporter-1.2.2.linux-amd64/node_exporter /usr/local/bin/

FROM debian:9
RUN apt update && apt install rsync -y
WORKDIR /app
COPY --from=build-env /go/src/github.com/sjtug/lug/lug /app/
COPY --from=build-env /usr/local/bin/node_exporter /usr/local/bin/
# ENTRYPOINT ["./lug","-c","/configs/config.yaml"]
CMD [ "sh", "-c", "'node_exporter --collector.disable-defaults --collector.filesystem --collector.cpu --collector.cpufreq --collector.diskstats --collector.meminfo --collector.netdev --collector.netclass & && ./lug -c /configs/config.yaml'" ]
