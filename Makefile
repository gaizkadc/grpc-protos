#
# Makefile for generating gRPC stubs in Go
#

all: lint generate

.PHONY: lint generate clean
lint:
	protoc --lint_out=. */*.proto

generate:
	chmod +x publishProto.sh
	./publishProto.sh

clean:
	rm -rf grpc-*-go && rm -rf */pb-go


