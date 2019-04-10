#!/bin/bash
#
# This script is meant to be the entrypoint for a prow job.
# It checkos out a repo and then looks for prow_config.yaml in that
# repo and uses that to run one or more workflows.
set -ex

# Checkout the code.
/usr/local/bin/checkout.sh /src

# move to helm charts folder
cd /src/${REPO_OWNER}/${REPO_NAME}/

pip3 install -r requirements.txt

python3 testapp.py
