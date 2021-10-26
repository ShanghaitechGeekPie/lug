FROM golang:1.23 AS build-env
# The GOPATH in the image is /go.
ADD . /go/src/github.com/sjtug/lug
WORKDIR /go/src/github.com/sjtug/lug
RUN go build github.com/sjtug/lug/cli/lug

FROM debian:12
RUN apt update && apt install rsync -y
WORKDIR /app
COPY --from=build-env /go/src/github.com/sjtug/lug/lug /app/
ENTRYPOINT ["./lug","-c","/configs/config.yaml"]
