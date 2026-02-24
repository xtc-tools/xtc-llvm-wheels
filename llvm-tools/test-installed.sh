#!/usr/bin/env bash
set -euo pipefail
set -x

PREFIX="$(python -c 'import llvm;print(llvm.__path__[0])')"

[ "$("$PREFIX"/bin/llvm-config --prefix)" == "$PREFIX" ]

"$PREFIX"/bin/llvm-config --version
"$PREFIX"/bin/opt --version

echo "ALL TESTS PASSED"
