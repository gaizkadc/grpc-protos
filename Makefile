#
# Makefile for generating gRPC stubs in Go
#

all: lint generate


.PHONY: lint generate dry-generate clean

lint:
	protoc --lint_out=. */*.proto

generate:
	chmod +x publishProto.sh
	./publishProto.sh $(service)


dry-generate:
	DRY_RUN=true ./publishProto.sh $(service)

clean:
	rm -rf grpc-*-go && rm -rf */pb-go


