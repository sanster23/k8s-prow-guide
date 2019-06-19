
GO_APP_BINARY ?= main

DOCKER_REPO ?= shekhawatsanjay
IMAGE ?= go-hello-world
VERSION ?= $(shell date +v%Y%m%d)-$(shell git describe --tags --always --dirty)

all: test build

clean:		## Clear all the .pyc/.pyo files and virtual env files.
	go clean
	rm -f $(GO_APP_BINARY)

test:
	go test -v -race -cover ./...

build:
	go build -v hello.go

run: build
	./$(GO_APP_BINARY)

build-image:
	docker build --cache-from docker.io/$(DOCKER_REPO)/$(IMAGE):latest \
		-t docker.io/$(DOCKER_REPO)/$(IMAGE):$(VERSION) \
		-t docker.io/$(DOCKER_REPO)/$(IMAGE):latest .


push-image:
	docker push docker.io/$(PROJECT)/$(IMAGE):latest
	docker push docker.io/$(PROJECT)/$(IMAGE):$(VERSION)

ci-release: clean test build build-image push-image

.PHONY: clean test build-image push-image ci-release


update-config:
	kubectl create configmap config --from-file=config.yaml=prow/config.yaml --dry-run -o yaml | kubectl replace configmap config -f -

update-plugins:
	kubectl create configmap plugins --from-file=plugins.yaml=prow/plugins.yaml --dry-run -o yaml | kubectl replace configmap plugins -f -

update-jobs:
	kubectl create configmap job-config --from-file=prow/jobs/ --dry-run -o yaml | kubectl replace configmap job-config -f -

deploy-prow: clean test

.PHONY: update-config update-plugins update-jobs deploy-prow
