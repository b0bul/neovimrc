# Makefile for building $(IMAGE_NAME) images for arm64 and amd64
IMAGE_NAME=dev

.PHONY: all dev-arm64 dev-amd64

all: dev-arm64 dev-amd64
push: latestarm64 latestamd64 versionarm64 versionamd64

dev-arm64:
	podman build \
		--platform linux/arm64 \
		--tag $(IMAGE_NAME)-arm64:$(VERSION) \
		--tag $(IMAGE_NAME)-arm64:latest \
		--build-arg ARCH_f1=arm64 \
		--build-arg ARCH_f2=arm64 \
		.

dev-amd64:
	podman build \
		--platform linux/amd64 \
		--tag $(IMAGE_NAME)-amd64:$(VERSION) \
		--tag $(IMAGE_NAME)-amd64:latest \
		--build-arg ARCH_f1=x86_64 \
		--build-arg ARCH_f2=amd64 \
	.

latestarm64: versionarm64
	podman push \
		localhost/$(IMAGE_NAME)-arm64:latest \
		docker.io/maclighiche/$(IMAGE_NAME)-arm64:latest

versionarm64:
	podman push \
		localhost/$(IMAGE_NAME)-arm64:$(VERSION) \
		docker.io/maclighiche/$(IMAGE_NAME)-arm64:$(VERSION)

latestamd64: versionamd64
	podman push \
		localhost/$(IMAGE_NAME)-amd64:latest \
		docker.io/maclighiche/$(IMAGE_NAME)-amd64:latest

versionamd64:
	podman push \
		localhost/$(IMAGE_NAME)-amd64:$(VERSION) \
		docker.io/maclighiche/$(IMAGE_NAME)-amd64:$(VERSION)

