#!/bin/bash

set -xe

SRC_DIR=$1

mkdir -p /src/${REPO_OWNER}

git clone https://github.com/${REPO_OWNER}/${REPO_NAME}.git ${SRC_DIR}/${REPO_OWNER}/${REPO_NAME}

echo Job Name = ${JOB_NAME}

# See https://github.com/kubernetes/test-infra/tree/master/prow#job-evironment-variables
REPO_DIR=${SRC_DIR}/${REPO_OWNER}/${REPO_NAME}
cd ${REPO_DIR}
if [ ! -z ${PULL_NUMBER} ]; then
 git fetch origin  pull/${PULL_NUMBER}/head:pr
 if [ ! -z ${PULL_PULL_SHA} ]; then
 	git checkout ${PULL_PULL_SHA}
 else
 	git checkout pr
 fi

else
 if [ ! -z ${PULL_BASE_SHA} ]; then
 	# Its a post submit; checkout the commit to test.
  	git checkout ${PULL_BASE_SHA}
 fi
fi

# Update submodules.
git submodule init
git submodule update

# Print out the commit so we can tell from logs what we checked out.
echo ${REPO_DIR} is at `git describe --tags --always --dirty`
git submodule
git status
