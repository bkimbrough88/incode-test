## Build
FROM golang:1.19-alpine3.17 AS build

WORKDIR /app

COPY go.mod ./
COPY go.sum ./

RUN go mod download

COPY *.go ./

ENV GOOS=linux
ENV GOARCH=amd64

RUN go build -o incode-test-back . && chmod +x incode-test-back

## Deploy
FROM alpine:3.17 AS final

RUN apk add ca-certificates

COPY --from=build /app/incode-test-back /incode-test-back

EXPOSE 80

CMD ["/incode-test-back"]