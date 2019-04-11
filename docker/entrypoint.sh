#!/bin/bash
#
# This script is meant to be the entrypoint for a prow job.
# It checkos out a repo and then looks for prow_config.yaml in that
# repo and uses that to run one or more workflows.
set -ex

while true; do
  case "$1" in
    --test)
      TEST=1
      shift
      ;;
    --deploy)
      DEPLOY=1
      shift
      ;;
    --release)
      RELEASE=1
      shift
      ;;
    --cleanup)
      CLEANUP=1
      shift
      ;;
    --)
      shift; break;;
    *)
      break;
  esac
done

# Checkout the code.
/usr/local/bin/checkout.sh /src

# move to helm charts folder
cd /src/${REPO_OWNER}/${REPO_NAME}/


helm init --service-account tiller

if [[ ${TEST} -eq 1 ]]; then
  # Run all the test cases.
  echo "Running all the test suites...."
  pip3 install -r requirements.txt
  python3 testapp.py
fi


if [[ ${DEPLOY} -eq 1 ]]; then
  # Deploy the application and check status if it is deployed properly
  echo "Deploying the application...."
  helm install helm_charts/flask-app/
  sleep 5
  check_deployment_status
fi


if [[ ${RELEASE} -eq 1 ]]; then
  # Create a release build/docker image and push to docker hub
  sha=`git log -n 1 --pretty=format:'%H'`
  until docker ps; do sleep 3; done
  docker login --username $docker_username --password $docker_password
  docker build . -t docker.io/shekhawatsanjay/flask-app:$sha
  docker push docker.io/shekhawatsanjay/flask-app:$sha
  docker rmi docker.io/shekhawatsanjay/flask-app:$sha
fi

if [[ ${CLEANUP} -eq 1 ]]; then
  echo "Deleting all the deployments....."
  helm list --all | grep "flask-app" | awk '{print $1}' | xargs helm delete
fi

function check_deployment_status() {
  pod=$(kubectl get po | grep "flask-app" | awk '{print $1}')
  curl http://$pod:5000/
  if [[ $? -eq 0 ]]; then
    return 0
  else
    return 1
  fi
}
