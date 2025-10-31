PACKAGE ?= github.com/paxan/your-credential-helpers
VERSION ?= $(shell ./hack/git-meta version)
REVISION ?= $(shell ./hack/git-meta revision)

GO_PKG = github.com/paxan/your-credential-helpers
GO_LDFLAGS = -s -w -X ${GO_PKG}/credentials.Version=${VERSION} -X ${GO_PKG}/credentials.Revision=${REVISION} -X ${GO_PKG}/credentials.Package=${PACKAGE}

BUILDX_CMD ?= docker buildx
DESTDIR ?= ./bin/build
COVERAGEDIR ?= ./bin/coverage
HELPER_PREFIX ?=
HELPER_LABEL ?=

# 10.11 is the minimum supported version for macoskeychain
export MACOSX_DEPLOYMENT_TARGET = 10.11
ifeq "$(shell go env GOOS)" "darwin"
	export CGO_CFLAGS = -Wno-atomic-alignment -mmacosx-version-min=$(MACOSX_DEPLOYMENT_TARGET)
else
	# prevent warnings; see https://github.com/docker/docker-credential-helpers/pull/340#issuecomment-2437593837
	# gcc_libinit.c:44:8: error: large atomic operation may incur significant performance penalty; the access size (4 bytes) exceeds the max lock-free size (0  bytes) [-Werror,-Watomic-alignment]
	export CGO_CFLAGS = -Wno-atomic-alignment
endif

ifeq "$(shell go env GOOS)/$(shell go env GOARCH)/$(shell go env GOARM)" "linux/arm/6"
	# Neither the CGo compiler, nor the C toolchain automatically link to
	# libatomic when the architecture doesn't support atomic intrinsics, as is
	# the case for arm/v6.
	#
	# Here's the error we get when this is not done (see https://github.com/docker/docker-credential-helpers/pull/340#issuecomment-2437593837):
	#
	# gcc_libinit.c:44:8: error: large atomic operation may incur significant performance penalty; the access size (4 bytes) exceeds the max lock-free size (0  bytes) [-Werror,-Watomic-alignment]
	export CGO_LDFLAGS=-latomic
endif

.PHONY: all
all: cross

.PHONY: clean
clean:
	rm -rf bin

.PHONY: check-prefix
check-prefix:
ifeq ($(HELPER_PREFIX),)
	$(error HELPER_PREFIX must be set. Example: make build-pass HELPER_PREFIX=myapp-credential)
endif
ifeq ($(HELPER_LABEL),)
	$(error HELPER_LABEL must be set. Example: make build-pass HELPER_LABEL="My App Credentials")
endif

.PHONY: build-%
build-%: check-prefix # build, can be one of build-macoskeychain build-pass build-secretservice build-wincred
	go build -trimpath -ldflags='$(GO_LDFLAGS) -X ${GO_PKG}/credentials.Name=$(HELPER_PREFIX)-$* -X "${GO_PKG}/credentials.CredsLabel=$(HELPER_LABEL)" -X ${GO_PKG}/pass.PassFolder=$(HELPER_PREFIX)-helpers' -o "$(DESTDIR)/$(HELPER_PREFIX)-$*" ./$*/cmd/

# aliases for build-* targets
.PHONY: macoskeychain secretservice pass wincred
macoskeychain: build-macoskeychain
secretservice: build-secretservice
pass: build-pass
wincred: build-wincred

.PHONY: cross
cross: check-prefix # cross build all supported credential helpers
	$(BUILDX_CMD) bake --set "*.args.HELPER_PREFIX=$(HELPER_PREFIX)" --set "*.args.HELPER_LABEL=$(HELPER_LABEL)" binaries

.PHONY: release
release: # create release
	./hack/release

.PHONY: test
test:
	mkdir -p $(COVERAGEDIR)
	go test -short -v -coverprofile=$(COVERAGEDIR)/coverage.txt -covermode=atomic ./...
	go tool cover -func=$(COVERAGEDIR)/coverage.txt

.PHONY: lint
lint:
	$(BUILDX_CMD) bake lint

.PHONY: fmt
fmt:
	gofmt -s -l `ls **/*.go`

.PHONY: validate
validate: lint fmt

BUILDIMG:=docker-credential-secretservice-$(VERSION)
.PHONY: deb
deb:
	mkdir -p release
	docker build -f deb/Dockerfile \
		--build-arg VERSION=$(patsubst v%,%,$(VERSION)) \
		--build-arg REVISION=$(REVISION) \
		--tag $(BUILDIMG) \
		.
	docker run --rm --net=none $(BUILDIMG) tar cf - /release | tar xf -
	docker rmi $(BUILDIMG)

.PHONY: print-%
print-%: ; @echo $($*)
