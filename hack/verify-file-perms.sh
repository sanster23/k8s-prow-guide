#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

files=$(find . -name "*.sh" \! -perm /a+x)
if [[ -n "${files}" ]]; then
  echo "${files}"
  echo
  echo "Please run hack/update-file-perms.sh"
  exit 1
fi