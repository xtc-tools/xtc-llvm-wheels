#!/usr/bin/env bash
set -euo pipefail
set -x
dir="$(realpath -e "$(dirname "$0")")"

BUILD_LLVM_CLEAN_BUILD_DIR="${BUILD_LLVM_CLEAN_BUILD_DIR:-1}"

cd "$dir"

# Note: we build only cp310-manylinux because the genrated package
# is not python version/abi dependent, only platform dependent,
# hence it is not necessary to build one for each python version.
# The setup.py script enforce the py3-none-manylinux* naming.

BUILD_PLATFORM="${BUILD_PLATFORM:-linux}"

CIBW_PLATFORM='linux'
CIBW_ARCHS='x86_64'
CIBW_BUILD='cp310-manylinux*'
CIBW_MANYLINUX_IMAGE='manylinux_2_28'
CIBW_CONTAINER_ENGINE_ARG="" 

BUILD_LLVM_DEBUG_TARGET="${BUILD_LLVM_DEBUG_TARGET:-}"
BUILD_LLVM_CLEAN_BUILD_DIR="${BUILD_LLVM_CLEAN_BUILD_DIR:-1}"
CIBW_DEBUG_KEEP_CONTAINER="${CIBW_DEBUG_KEEP_CONTAINER:-0}"
BUILD_LLVM_COMPONENTS=""

CIBW_BEFORE_BUILD="rm -rf dist build *egg-info"
CIBW_TEST_COMMAND='{package}/test-installed.sh'
CIBW_BEFORE_ALL="env BUILD_PLATFORM=$BUILD_PLATFORM ./install-build-tools.sh && ./build-llvm.sh"

if [ "$BUILD_PLATFORM" = "linux" ]; then
    DOCKER_ARGS=""
    CIBW_CONTAINER_ENGINE_ARG="CIBW_CONTAINER_ENGINE=docker;create_args:$DOCKER_ARGS"

elif [ "$BUILD_PLATFORM" = "darwin" ]; then
    CIBW_PLATFORM='macos'
    CIBW_ARCHS='arm64'
    CIBW_BUILD='cp310-*'
    CIBW_MANYLINUX_IMAGE=""
else
    echo "Error: Unknown BUILD_PLATFORM '$BUILD_PLATFORM'. Must be 'linux' or 'darwin'."
    exit 1
fi

ENV_VARS=(
    CIBW_PLATFORM="$CIBW_PLATFORM"
    CIBW_ARCHS="$CIBW_ARCHS"
    MACOSX_DEPLOYMENT_TARGET=15.0
    CIBW_BUILD="$CIBW_BUILD"
    CIBW_PROJECT_REQUIRES_PYTHON='>=3.10'
    CIBW_MANYLINUX_X86_64_IMAGE="$CIBW_MANYLINUX_IMAGE"
    CIBW_BEFORE_ALL="$CIBW_BEFORE_ALL"
    CIBW_TEST_COMMAND="$CIBW_TEST_COMMAND"
    BUILD_LLVM_CLEAN_BUILD_DIR="$BUILD_LLVM_CLEAN_BUILD_DIR" 
    CIBW_ENVIRONMENT_PASS="BUILD_LLVM_CLEAN_BUILD_DIR" 
    CIBW_BUILD_VERBOSITY=1
    CIBW_DEBUG_KEEP_CONTAINER="$CIBW_DEBUG_KEEP_CONTAINER"
)

if [ -n "$CIBW_CONTAINER_ENGINE_ARG" ]; then
    ENV_VARS+=("$CIBW_CONTAINER_ENGINE_ARG")
fi

env "${ENV_VARS[@]}" \
    cibuildwheel \
    .
