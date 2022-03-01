FROM golang AS build-env
# The GOPATH in the image is /go.
ADD . /go/src/github.com/sjtug/lug
WORKDIR /go/src/github.com/sjtug/lug
RUN go build github.com/sjtug/lug/cli/lug
RUN curl -L https://github.com/prometheus/node_exporter/releases/download/v1.2.2/node_exporter-1.2.2.linux-amd64.tar.gz --output /tmp/node_exporter-1.2.2.linux-amd64.tar.gz && \
    tar -xzf /tmp/node_exporter-1.2.2.linux-amd64.tar.gz -C /tmp && \
    mv /tmp/node_exporter-1.2.2.linux-amd64/node_exporter /usr/local/bin/

FROM debian
RUN apt update && apt install rsync python3 python3-pip -y && pip install bandersnatch && apt install proxychains4 -y && sed -i '$ d' /etc/proxychains4.conf && echo "socks5 10.111.111.1 1080" >> /etc/proxychains4.conf
WORKDIR /app
COPY --from=build-env /go/src/github.com/sjtug/lug/lug /app/
COPY --from=build-env /go/src/github.com/sjtug/lug/entrypoint.sh /app/
COPY --from=build-env /usr/local/bin/node_exporter /usr/local/bin/
COPY genisolist.ini /
COPY genisolist.py /
COPY pypi.sh /
ENTRYPOINT ["/bin/bash", "/app/entrypoint.sh"]
