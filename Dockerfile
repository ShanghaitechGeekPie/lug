# Build Stage
FROM golang as build-env

# The GOPATH in the image is /go.
ADD . /go/src/github.com/sjtug/lug
WORKDIR /go/src/github.com/sjtug/lug
RUN go build github.com/sjtug/lug/cli/lug

# Production Stage
FROM debian:sid
RUN apt update && apt install rsync python3 python3-pip pipx git curl proxychains4 -y
RUN pipx install bandersnatch && sed -i '/^socks4/d' /etc/proxychains4.conf && echo "socks5 10.15.89.182 1080" >> /etc/proxychains4.conf

# Fetch Node Exporter
RUN curl -L \
    https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz \
    -o /tmp/node_exporter.tar.gz && tar -xzf /tmp/node_exporter.tar.gz -C /tmp && \
    mv /tmp/node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin/

# Repo for AOSP synchronization
RUN curl https://mirrors.shanghaitech.edu.cn/git/git-repo -o /usr/bin/repo && \
    chmod +x /usr/bin/repo && ln -sf /usr/bin/python3 /usr/bin/python && \
    echo "REPO_URL='https://mirrors.shanghaitech.edu.cn/git/git-repo'" > /etc/environment

WORKDIR /app
COPY --from=build-env /go/src/github.com/sjtug/lug/lug /app/
COPY scripts /scripts
ENTRYPOINT ["/bin/bash", "/scripts/entrypoint.sh"]
