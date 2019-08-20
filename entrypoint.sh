#!/bin/sh

## mapping of var from user input or default value

USERNAME=${GITHUB_REPOSITORY%%/*}
REPOSITORY=${GITHUB_REPOSITORY#*/}

ref_tmp=${GITHUB_REF#*/} ## throw away the first part of the ref (GITHUB_REF=refs/heads/master or refs/tags/2019/03/13)
ref_type=${ref_tmp%%/*} ## extract the second element of the ref (heads or tags)
ref_value=${ref_tmp#*/} ## extract the third+ elements of the ref (master or 2019/03/13)

## if needed to filter the branch
if [ -n "${BRANCH_FILTER+set}" ] && [ "$ref_value" != "$BRANCH_FILTER" ]
then
  exit 78 ## exit neutral
fi

GIT_TAG=${ref_value//\//-} ## replace `/` with `-` in ref for docker tag requirement (master or 2019-03-13)
if [ -n "${DOCKER_TAG_APPEND+set}" ] ## right append to tag if specified
then
    GIT_TAG=${GIT_TAG}_${DOCKER_TAG_APPEND}
fi

REGISTRY=${DOCKER_REGISTRY_URL} ## use default Docker Hub as registry unless specified

## login if needed
if [ -n "${DOCKER_PASSWORD+set}" ]
then
  sh -c "docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD $REGISTRY"
fi