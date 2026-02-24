#!/usr/bin/env bash
set -euo pipefail
set -x

PREFIX="$(python -c 'import llvm;print(llvm.__path__[0])')"

[ -d "$PREFIX"/include/llvm ] || exit 1
[ -d "$PREFIX"/lib/cmake/llvm ] || exit 1

echo "ALL TESTS PASSED"
