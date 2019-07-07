#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

find . -name "*.sh" \! -perm /a+x -exec chmod +x {} +