# This Makefile is meant to be used by people that do not usually work
# with Go source code. If you know what GOPATH is then you probably
# don't need to bother with make.

.PHONY: gsmc android ios gsmc-cross evm all test clean
.PHONY: gsmc-linux gsmc-linux-386 gsmc-linux-amd64 gsmc-linux-mips64 gsmc-linux-mips64le
.PHONY: gsmc-linux-arm gsmc-linux-arm-5 gsmc-linux-arm-6 gsmc-linux-arm-7 gsmc-linux-arm64
.PHONY: gsmc-darwin gsmc-darwin-386 gsmc-darwin-amd64
.PHONY: gsmc-windows gsmc-windows-386 gsmc-windows-amd64

GOBIN = $(shell pwd)/build/bin
GO ?= latest

gsmc:
	build/env.sh go run build/ci.go install ./cmd/gsmc
	@echo "Done building."
	@echo "Run \"$(GOBIN)/gsmc\" to launch gsmc."

all:
	build/env.sh go run build/ci.go install

android:
	build/env.sh go run build/ci.go aar --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/gsmc.aar\" to use the library."

ios:
	build/env.sh go run build/ci.go xcode --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/Gsmc.framework\" to use the library."

test: all
	build/env.sh go run build/ci.go test

lint: ## Run linters.
	build/env.sh go run build/ci.go lint

clean:
	./build/clean_go_build_cache.sh
	rm -fr build/_workspace/pkg/ $(GOBIN)/*

# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

devtools:
	env GOBIN= go get -u golang.org/x/tools/cmd/stringer
	env GOBIN= go get -u github.com/kevinburke/go-bindata/go-bindata
	env GOBIN= go get -u github.com/fjl/gencodec
	env GOBIN= go get -u github.com/golang/protobuf/protoc-gen-go
	env GOBIN= go install ./cmd/abigen
	@type "npm" 2> /dev/null || echo 'Please install node.js and npm'
	@type "solc" 2> /dev/null || echo 'Please install solc'
	@type "protoc" 2> /dev/null || echo 'Please install protoc'

# Cross Compilation Targets (xgo)

gsmc-cross: gsmc-linux gsmc-darwin gsmc-windows gsmc-android gsmc-ios
	@echo "Full cross compilation done:"
	@ls -ld $(GOBIN)/gsmc-*

gsmc-linux: gsmc-linux-386 gsmc-linux-amd64 gsmc-linux-arm gsmc-linux-mips64 gsmc-linux-mips64le
	@echo "Linux cross compilation done:"
	@ls -ld $(GOBIN)/gsmc-linux-*

gsmc-linux-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/386 -v ./cmd/gsmc
	@echo "Linux 386 cross compilation done:"
	@ls -ld $(GOBIN)/gsmc-linux-* | grep 386

gsmc-linux-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/amd64 -v ./cmd/gsmc
	@echo "Linux amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gsmc-linux-* | grep amd64

gsmc-linux-arm: gsmc-linux-arm-5 gsmc-linux-arm-6 gsmc-linux-arm-7 gsmc-linux-arm64
	@echo "Linux ARM cross compilation done:"
	@ls -ld $(GOBIN)/gsmc-linux-* | grep arm

gsmc-linux-arm-5:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-5 -v ./cmd/gsmc
	@echo "Linux ARMv5 cross compilation done:"
	@ls -ld $(GOBIN)/gsmc-linux-* | grep arm-5

gsmc-linux-arm-6:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-6 -v ./cmd/gsmc
	@echo "Linux ARMv6 cross compilation done:"
	@ls -ld $(GOBIN)/gsmc-linux-* | grep arm-6

gsmc-linux-arm-7:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-7 -v ./cmd/gsmc
	@echo "Linux ARMv7 cross compilation done:"
	@ls -ld $(GOBIN)/gsmc-linux-* | grep arm-7

gsmc-linux-arm64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm64 -v ./cmd/gsmc
	@echo "Linux ARM64 cross compilation done:"
	@ls -ld $(GOBIN)/gsmc-linux-* | grep arm64

gsmc-linux-mips:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips --ldflags '-extldflags "-static"' -v ./cmd/gsmc
	@echo "Linux MIPS cross compilation done:"
	@ls -ld $(GOBIN)/gsmc-linux-* | grep mips

gsmc-linux-mipsle:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mipsle --ldflags '-extldflags "-static"' -v ./cmd/gsmc
	@echo "Linux MIPSle cross compilation done:"
	@ls -ld $(GOBIN)/gsmc-linux-* | grep mipsle

gsmc-linux-mips64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64 --ldflags '-extldflags "-static"' -v ./cmd/gsmc
	@echo "Linux MIPS64 cross compilation done:"
	@ls -ld $(GOBIN)/gsmc-linux-* | grep mips64

gsmc-linux-mips64le:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64le --ldflags '-extldflags "-static"' -v ./cmd/gsmc
	@echo "Linux MIPS64le cross compilation done:"
	@ls -ld $(GOBIN)/gsmc-linux-* | grep mips64le

gsmc-darwin: gsmc-darwin-386 gsmc-darwin-amd64
	@echo "Darwin cross compilation done:"
	@ls -ld $(GOBIN)/gsmc-darwin-*

gsmc-darwin-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/386 -v ./cmd/gsmc
	@echo "Darwin 386 cross compilation done:"
	@ls -ld $(GOBIN)/gsmc-darwin-* | grep 386

gsmc-darwin-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/amd64 -v ./cmd/gsmc
	@echo "Darwin amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gsmc-darwin-* | grep amd64

gsmc-windows: gsmc-windows-386 gsmc-windows-amd64
	@echo "Windows cross compilation done:"
	@ls -ld $(GOBIN)/gsmc-windows-*

gsmc-windows-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/386 -v ./cmd/gsmc
	@echo "Windows 386 cross compilation done:"
	@ls -ld $(GOBIN)/gsmc-windows-* | grep 386

gsmc-windows-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/amd64 -v ./cmd/gsmc
	@echo "Windows amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gsmc-windows-* | grep amd64
