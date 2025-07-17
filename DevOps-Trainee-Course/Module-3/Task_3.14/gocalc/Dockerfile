FROM golang:1.24-alpine as builder

ENV CGO_ENABLED 0
ENV GOPATH /go

COPY go.mod go.sum ./

RUN go mod download

COPY . .
    
RUN go build -o /app main.go 

FROM alpine:3.10.3
COPY --from=builder /app /app
CMD [./app]

