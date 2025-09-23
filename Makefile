# Makefile for building $(IMAGE_NAME) images for arm64 and amd64
IMAGE_NAME=dev

.PHONY: all dev-arm64 dev-amd64

all: dev-arm64 dev-amd64
push: parm64 pamd64

dev-arm64:
	podman build \
		--platform linux/arm64 \
		--tag $(IMAGE_NAME)-arm64:$(VERSION) \
		--build-arg ARCH=arm64 \
		.

dev-amd64:
	podman build \
		--platform linux/amd64 \
		--tag $(IMAGE_NAME)-amd64:$(VERSION) \
		--build-arg ARCH=amd64 \
		.

parm64:
	podman push \
		localhost/$(IMAGE_NAME)-arm64:$(VERSION) \
		docker.io/maclighiche/$(IMAGE_NAME)-arm64:$(VERSION)

pamd64:
	podman push \
		localhost/$(IMAGE_NAME)-amd64:$(VERSION) \
		docker.io/maclighiche/$(IMAGE_NAME)-amd64:$(VERSION)
