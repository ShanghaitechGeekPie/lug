# Build Stage
FROM golang as build-env

# The GOPATH in the image is /go.
ADD . /go/src/github.com/sjtug/lug
WORKDIR /go/src/github.com/sjtug/lug
RUN go build github.com/sjtug/lug/cli/lug

# Production Stage
FROM debian:sid
RUN apt update && apt install rsync python3 git curl -y

# Repo for AOSP synchronization
RUN curl https://mirrors.bfsu.edu.cn/git/git-repo -o /usr/bin/repo && \
    chmod +x /usr/bin/repo && ln -sf /usr/bin/python3 /usr/bin/python && \
    echo "REPO_URL='https://mirrors.shanghaitech.edu.cn/git/git-repo'" > /etc/environment

WORKDIR /app
COPY --from=build-env /go/src/github.com/sjtug/lug/lug /app/
COPY scripts /scripts
ENTRYPOINT ["/bin/bash", "/scripts/entrypoint.sh"]
