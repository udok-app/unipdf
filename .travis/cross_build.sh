#!/usr/bin/env bash

# Functions.
function info() {
    echo -e "\033[00;34mi\033[0m $1"
}

function fail() {
    echo -e "\033[00;31m!\033[0m $1"
    exit 1
}

function build() {
    goos=$1
    goarch=$2

    info "Building for $goos $goarch..."
    GOOS=$goos GOARCH=$goarch go build -o $goos_$goarch main.go
    if [[ $? -ne 0 ]]; then
        fail "Could not build for $goos $goarch. Aborting."
    fi
}

# Create build directory.
mkdir -p bin
cd bin

# Create go.mod
cat <<EOF > go.mod
module cross_build
require github.com/rafaelsanzio/unipdf v3.0.0
EOF

echo "replace github.com/rafaelsanzio/unipdf => $TRAVIS_BUILD_DIR" >> go.mod

# Create Go file.
cat <<EOF > main.go
package main

import (
	_ "github.com/rafaelsanzio/unipdf/annotator"
	_ "github.com/rafaelsanzio/unipdf/common"
	_ "github.com/rafaelsanzio/unipdf/common/license"
	_ "github.com/rafaelsanzio/unipdf/contentstream"
	_ "github.com/rafaelsanzio/unipdf/contentstream/draw"
	_ "github.com/rafaelsanzio/unipdf/core"
	_ "github.com/rafaelsanzio/unipdf/core/security"
	_ "github.com/rafaelsanzio/unipdf/core/security/crypt"
	_ "github.com/rafaelsanzio/unipdf/creator"
	_ "github.com/rafaelsanzio/unipdf/extractor"
	_ "github.com/rafaelsanzio/unipdf/fdf"
	_ "github.com/rafaelsanzio/unipdf/fjson"
	_ "github.com/rafaelsanzio/unipdf/model"
	_ "github.com/rafaelsanzio/unipdf/model/optimize"
	_ "github.com/rafaelsanzio/unipdf/model/sighandler"
	_ "github.com/rafaelsanzio/unipdf/ps"
	_ "github.com/rafaelsanzio/unipdf/render"
)

func main() {}
EOF

# Build file.
for os in "linux" "darwin" "windows"; do
    for arch in "386" "amd64"; do
        build $os $arch
    done
done
