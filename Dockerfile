FROM golang:1.23 AS build-env
# The GOPATH in the image is /go.
ADD . /go/src/github.com/sjtug/lug
WORKDIR /go/src/github.com/sjtug/lug
RUN go build github.com/sjtug/lug/cli/lug
RUN curl -L https://github.com/prometheus/node_exporter/releases/download/v1.2.2/node_exporter-1.2.2.linux-amd64.tar.gz --output /tmp/node_exporter-1.2.2.linux-amd64.tar.gz && \
    tar -xzf /tmp/node_exporter-1.2.2.linux-amd64.tar.gz -C /tmp && \
    mv /tmp/node_exporter-1.2.2.linux-amd64/node_exporter /usr/local/bin/

FROM debian:12
RUN apt update && apt install rsync -y
RUN curl https://mirrors.tuna.tsinghua.edu.cn/git/git-repo -o /usr/bin/repo && \
chmod +x /usr/bin/repo && export REPO_URL='https://mirrors.tuna.tsinghua.edu.cn/git/git-repo' && ln -sf /usr/bin/python3 /usr/bin/python
WORKDIR /app
COPY --from=build-env /go/src/github.com/sjtug/lug/lug /app/
COPY --from=build-env /go/src/github.com/sjtug/lug/entrypoint.sh /app/
COPY --from=build-env /usr/local/bin/node_exporter /usr/local/bin/
COPY genisolist.ini /
COPY genisolist.py /
COPY pypi.sh /
ENTRYPOINT ["/bin/bash", "/app/entrypoint.sh"]
