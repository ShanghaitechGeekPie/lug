# Build Stage
FROM golang as build-env

# The GOPATH in the image is /go.
ADD . /go/src/github.com/sjtug/lug
WORKDIR /go/src/github.com/sjtug/lug
RUN go build github.com/sjtug/lug/cli/lug
RUN curl -L https://github.com/prometheus/node_exporter/releases/download/v1.4.0/node_exporter-1.4.0.linux-amd64.tar.gz -o /tmp/node_exporter.tar.gz && \
tar -xzf /tmp/node_exporter.tar.gz -C /tmp && mv /tmp/node_exporter-1.4.0.linux-amd64/node_exporter /usr/local/bin/

# Production Stage
FROM debian:sid
RUN apt update && apt install rsync python3 python3-pip git curl proxychains4 libssl1.1 -y
RUN pip install bandersnatch && sed -i '/^socks4/d' /etc/proxychains4.conf && echo "socks5 10.111.111.1 1080" >> /etc/proxychains4.conf

# Repo for AOSP synchronization
RUN curl https://mirrors.tuna.tsinghua.edu.cn/git/git-repo -o /usr/bin/repo && \
chmod +x /usr/bin/repo && export REPO_URL='https://mirrors.tuna.tsinghua.edu.cn/git/git-repo' && ln -sf /usr/bin/python3 /usr/bin/python

# Custom indexer to replace nginx autoindex
RUN curl https://cdn.jsdelivr.net/gh/wenxuanjun/vindex/vindex -o /usr/bin/vindex && chmod +x /usr/bin/vindex

WORKDIR /app
COPY --from=build-env /go/src/github.com/sjtug/lug/lug /app/
COPY --from=build-env /usr/local/bin/node_exporter /usr/local/bin/
COPY scripts/ /
ENTRYPOINT ["/bin/bash", "/app/scripts/entrypoint.sh"]
