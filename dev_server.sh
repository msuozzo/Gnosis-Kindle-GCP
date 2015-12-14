#!/bin/bash
# Deploys the current application code to a local Docker container

APPENGINE_DIR=google

function download_appengine_pkg() {
    # Retrieves the Python appengine package code
    # This package code is required and cannot be retrieved from pip.
    rm -rf $APPENGINE_DIR

    DIR_NAME=google_appengine
    VERSION=1.9.30
    ZIP_NAME=${DIR_NAME}_${VERSION}.zip
    URL=https://storage.googleapis.com/appengine-sdks/featured/$ZIP_NAME

    curl -O $URL
    unzip $ZIP_NAME
    rm $ZIP_NAME

    mv $DIR_NAME/$APPENGINE_DIR .
    rm -rf $DIR_NAME
}

if [[ ! -e $APPENGINE_DIR ]]; then
    download_appengine_pkg
fi

MACHINE_NAME=$(docker-machine active)

EXTERNAL_IP=$(docker-machine ip ${MACHINE_NAME})
EXTERNAL_PORT=80
SERVER_PORT=8080

TEST_CONTAINER_NAME="test"
TEST_IMAGE_NAME="test-img"

# Remove previous images
docker rm -f $TEST_CONTAINER_NAME 2> /dev/null
docker rmi -f $TEST_IMAGE_NAME 2> /dev/null

# Build image and deploy container
docker build -t ${TEST_IMAGE_NAME} . && \
    docker run -d -p ${EXTERNAL_PORT}:${SERVER_PORT} --name ${TEST_CONTAINER_NAME} ${TEST_IMAGE_NAME}

echo Container accessible at http://${EXTERNAL_IP}:${EXTERNAL_PORT}
