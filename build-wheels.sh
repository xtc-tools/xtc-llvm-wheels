#!/usr/bin/env bash
set -euo pipefail
set -x
dir="$(dirname "$(readlink -f "$0")")"

BUILD_LLVM_REVISION="$(cat "$dir"/llvm_revision.txt)"

cd "$dir"

# Note: we build only cp310-manylinux because the genrated package
# is not python version/abi dependent, only platform dependent,
# hence it is not necessary to build one for each python version.
# The setup.py script enforce the py3-none-manylinux* naming.

BUILD_PLATFORM="${BUILD_PLATFORM:-linux}"

CIBW_PLATFORM="linux"
CIBW_ARCHS="x86_64"
CIBW_BUILD="cp310-manylinux*"
CIBW_MANYLINUX_IMAGE="manylinux_2_28"
CONTAINER_ENGINE_ARG=""

BUILD_LLVM_DEBUG_TARGET="${BUILD_LLVM_DEBUG_TARGET:-}"
BUILD_LLVM_CLEAN_BUILD_DIR="${BUILD_LLVM_CLEAN_BUILD_DIR:-1}"
CIBW_DEBUG_KEEP_CONTAINER="${CIBW_DEBUG_KEEP_CONTAINER:-0}"
BUILD_LLVM_COMPONENTS=""
BUILD_CCACHE_DIR="${BUILD_CCACHE_DIR-}"

CIBW_BEFORE_BUILD="rm -rf dist build *egg-info"
CIBW_TEST_COMMAND="{package}/test-installed.sh"
CIBW_BEFORE_ALL="env BUILD_PLATFORM=$BUILD_PLATFORM ./install-build-tools.sh && ./build-llvm.sh"

MACOSX_DEPLOYMENT_ARGS=""

if [ "$BUILD_PLATFORM" = "linux" ]; then
   DOCKER_ARGS=""
   DOCKER_CCACHE_DIR=""
   if [ -n "$BUILD_CCACHE_DIR" ]; then
       mkdir -p "$BUILD_CCACHE_DIR"
       DOCKER_CCACHE_DIR="/ccache"
       DOCKER_ARGS="$DOCKER_ARGS -v'$BUILD_CCACHE_DIR:$DOCKER_CCACHE_DIR'"
       BUILD_CCACHE_DIR="$DOCKER_CCACHE_DIR"
   fi
   CONTAINER_ENGINE_ARG="CIBW_CONTAINER_ENGINE=docker;create_args:$DOCKER_ARGS"
elif [ "$BUILD_PLATFORM" = "darwin" ]; then
    CIBW_PLATFORM="macos"
    CIBW_ARCHS="arm64"
    CIBW_BUILD="cp310-*"
    CIBW_MANYLINUX_IMAGE=""
    MACOSX_DEPLOYMENT_ARGS="MACOSX_DEPLOYMENT_TARGET=14.0" # supports macos14+
else
    echo "Error: Unknown BUILD_PLATFORM '$BUILD_PLATFORM'. Must be 'linux' or 'darwin'."
    exit 1
fi

ENV_VARS=(
    CIBW_PLATFORM="$CIBW_PLATFORM"
    CIBW_ARCHS="$CIBW_ARCHS"
    CIBW_BUILD="$CIBW_BUILD"
    CIBW_PROJECT_REQUIRES_PYTHON=">=3.10"
    CIBW_MANYLINUX_X86_64_IMAGE="$CIBW_MANYLINUX_IMAGE"
    CIBW_BEFORE_ALL="$CIBW_BEFORE_ALL"
    CIBW_TEST_COMMAND="$CIBW_TEST_COMMAND"
    BUILD_LLVM_CLEAN_BUILD_DIR="$BUILD_LLVM_CLEAN_BUILD_DIR"
    BUILD_LLVM_REVISION="$BUILD_LLVM_REVISION"
    BUILD_PLATFORM="$BUILD_PLATFORM"
    CCACHE_DIR="$BUILD_CCACHE_DIR"
    CIBW_ENVIRONMENT_PASS_LINUX="BUILD_LLVM_CLEAN_BUILD_DIR BUILD_LLVM_REVISION BUILD_PLATFORM CCACHE_DIR"
    CIBW_BUILD_VERBOSITY=1
    CIBW_DEBUG_KEEP_CONTAINER="$CIBW_DEBUG_KEEP_CONTAINER"
)

[ -z "$CONTAINER_ENGINE_ARG" ] || ENV_VARS+=("$CONTAINER_ENGINE_ARG")
[ -z "$MACOSX_DEPLOYMENT_ARGS" ] || ENV_VARS+=("$MACOSX_DEPLOYMENT_ARGS")

env "${ENV_VARS[@]}" \
    cibuildwheel \
    .
