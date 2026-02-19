#!/usr/bin/env bash
set -euo pipefail
set -x

PREFIX="$(python -c 'import llvm;print(llvm.__path__[0])')"
"$PREFIX"/bin/opt --version

echo "ALL TESTS PASSED"
