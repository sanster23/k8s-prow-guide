#!/bin/bash
#
# This script is meant to be the entrypoint for a prow job.
# It checkos out a repo and then looks for prow_config.yaml in that
# repo and uses that to run one or more workflows.
set -ex

# # Checkout the code.
/usr/local/bin/checkout.sh /src

cd /src/${REPO_OWNER}/${REPO_NAME}

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

kubectl get po
helm repo update
helm install helm-charts/flask-app

# sha=`git log -n 1 --pretty=format:'%H'` 
# docker login --username shekhawatsanjay --password sanjaySS@23
# docker build . -t docker.io/shekhawatsanjay/flask-app:$sha
# docker push docker.io/shekhawatsanjay/flask-app:$sha
