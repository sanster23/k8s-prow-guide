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

HELM_VERSION="v2.9.0"
KUBECTL_VERSION="v1.13.0"

curl -LO curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl &&\
chmod +x ./kubectl &&\
mv ./kubectl /usr/local/bin/kubectl &&\
wget -q https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm &&\
chmod +x /usr/local/bin/helm &&\
#helm init --upgrade --service-account default

kubectl get po
# helm repo update
# helm ls


kubectl create -f flask_app_kube.yaml

sleep 3s


kubectl get service/flask-app-svc | CLUSTER_IP=awk {print $3}

echo "Testing the deployed app..."

res=`curl -s -I $CLUSTER_IP | grep HTTP/1.1 | awk {'print $2'}`

if [ $res -ne 200 ]
then
    echo "Error $res on $CLUSTER_IP, App not deployed properly"
else
   echo "PASSED"
fi

echo "Clearing the app"


kubectl delete deployment.apps/flask-app-dpl

kubectl delete service/flask-app-svc

# helm install helm-charts/flask-app

# sha=`git log -n 1 --pretty=format:'%H'` 
# docker build . -t docker.io/shekhawatsanjay/flask-app:$sha
# docker push docker.io/shekhawatsanjay/flask-app:$sha
