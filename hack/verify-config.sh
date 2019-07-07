#!/usr/bin/env bash

"""
Name: verify-config.sh
Purpose: Verify all the configs for Prow
# config.yaml
# plugins.yaml
# job-config

NOTE: `checkconfig` is set to strict checking (this will exit 1 even with non-fatal warnings)
"""

set -o errexit
set -o nounset
set -o pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"


if [[ -n "${GOPATH}" ]]; then
    go get -v k8s.io/test-infra/prow/cmd/checkconfig
else
    echo "[Error] GOPATH not set."
    exit 1
fi


echo -n "Running checkconfig with strict warnings..." >&2
echo
"${GOPATH}"/bin/checkconfig \
                        --strict \
                        --warnings=mismatched-tide-lenient \
                        --warnings=tide-strict-branch \
                        --warnings=needs-ok-to-test \
                        --warnings=validate-owners \
                        --warnings=missing-trigger \
                        --warnings=validate-urls \
                        --warnings=unknown-fields \
                        --config-path="${ROOT}"/prow/config.yaml \
                        --plugin-config="${ROOT}"/prow/plugins.yaml \
                        --job-config-path="${ROOT}"/prow/jobs/