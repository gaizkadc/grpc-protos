#
# Makefile for generating gRPC stubs in Go
#


all: lint generate

.PHONY: lint generate dry-generate clean

lint:
	# TODO Lint doesn't work with this version, we must revisit how import the Google API Annotations
	# protoc --lint_out=. */*.proto
	$(info *** lint is skipped ***)

generate:
	chmod +x publishProto.sh
	./publishProto.sh $(service)


dry-generate:
	DRY_RUN=true ./publishProto.sh $(service)

clean:
	rm -rf grpc-*-go && rm -rf */pb-go


