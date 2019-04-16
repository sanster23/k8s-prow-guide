#!/bin/bash
#
# This script is meant to be the entrypoint for a prow job.
# It checkos out a repo and then looks for prow_config.yaml in that
# repo and uses that to run one or more workflows.
set -ex

# Checkout the code.
/usr/local/bin/checkout.sh /src

# move to helm charts folder
cd /src/${REPO_OWNER}/${REPO_NAME}/helm-charts
# create a valid argo workflow name
workflowname=`echo ${REPO_NAME}-${BUILD_NUMBER} | tr 'A-Z_' 'a-z-'`

kubectl get po
# run testing_workflow in the repo
helm install --set workflowname=${workflowname} --set pull_number=${PULL_NUMBER} --set repo_name=${REPO_NAME} --set repo_owner=${REPO_OWNER} --set build_number=${BUILD_NUMBER} $workflow_chart/

# wait till workflow completes running
argo_status=$(argo get  ${workflowname} -o json | jq .status.phase)
while [ "$argo_status" == '"Running"' ]; do
  sleep 3;
  argo_status=$(argo get ${workflowname} -o json | jq .status.phase)
done


if [ "$argo_status" == '"Failed"' ]; then
  echo "testing workflow failed" >&2;
  argo get ${workflowname};
  exit 1;
fi
