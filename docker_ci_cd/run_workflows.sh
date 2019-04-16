#!/bin/bash
#
# This script is meant to be the entrypoint for a prow job.
# It checkos out a repo and then looks for prow_config.yaml in that
# repo and uses that to run one or more workflows.
set -ex

# # Checkout the code.
# /usr/local/bin/checkout.sh /src

# # move to helm charts folder
# cd /src/${REPO_OWNER}/${REPO_NAME}/helm-charts
# # create a valid argo workflow name
# workflowname=`echo ${REPO_NAME}-${BUILD_NUMBER} | tr 'A-Z_' 'a-z-'`

# kubectl get po
# # run testing_workflow in the repo
# helm install --set workflowname=${workflowname} --set pull_number=${PULL_NUMBER} --set repo_name=${REPO_NAME} --set repo_owner=${REPO_OWNER} --set build_number=${BUILD_NUMBER} $workflow_chart/

# # wait till workflow completes running
# argo_status=$(argo get  ${workflowname} -o json | jq .status.phase)
# while [ "$argo_status" == '"Running"' ]; do
#   sleep 3;
#   argo_status=$(argo get ${workflowname} -o json | jq .status.phase)
# done


# if [ "$argo_status" == '"Failed"' ]; then
#   echo "testing workflow failed" >&2;
#   argo get ${workflowname};
#   exit 1;
# fi

function start_docker() {
    echo "Docker in Docker enabled, initializing..."
    printf '=%.0s' {1..80}; echo
    # If we have opted in to docker in docker, start the docker daemon,
    service docker start
    # the service can be started but the docker socket not ready, wait for ready
    local WAIT_N=0
    local MAX_WAIT=20
    while true; do
        # docker ps -q should only work if the daemon is ready
        docker ps -q > /dev/null 2>&1 && break
        if [[ ${WAIT_N} -lt ${MAX_WAIT} ]]; then
            WAIT_N=$((WAIT_N+1))
            echo "Waiting for docker to be ready, sleeping for ${WAIT_N} seconds."
            sleep ${WAIT_N}
        else
            echo "Reached maximum attempts, not waiting any longer..."
            exit 1
        fi
    done
    printf '=%.0s' {1..80}; echo
    echo "Done setting up docker in docker."
}

start_docker

sha=`git log -n 1 --pretty=format:'%H'` && until docker ps; do sleep 3; done
docker login --username $docker_username --password $docker_password
docker build . -t docker.io/shekhawatsanjay/flask-app:$sha
docker push docker.io/shekhawatsanjay/flask-app:$sha
