#/bin/bash
if [[ ! ${PROJECT_ID} ]]; then
    echo PROJECT_ID not set!
    exit 1
fi

if [[ $1 -eq "release" ]]; then
    IMAGES="$(docker images)"
    IMAGE_NAME="gcr.io/${PROJECT_ID}/kindle"
    IMAGE_VERSION_FMT="v%s"

    for i in $(seq -w 1 99); do
        IMAGE_VERSION="$(printf ${IMAGE_VERSION_FMT} $i)"
        if [[ ! "$(echo $IMAGES | grep "${IMAGE_NAME}[^ ]*${IMAGE_VERSION}")" ]]; then
            break
        fi
    done

    NEXT_IMAGE="${IMAGE_NAME}:${IMAGE_VERSION}"
    APP_VERSION="${IMAGE_VERSION}-$(date +"%Y%m%d")"

    docker build -t "${NEXT_IMAGE}" . &&
        gcloud docker -- push "${NEXT_IMAGE}" &&
        (yes Y | gcloud preview app deploy app.yaml \
            --promote \
            --image-url "${NEXT_IMAGE}" \
            --version "${APP_VERSION}")
else
    yes Y | gcloud preview app deploy app.yaml \
        --promote \
        --docker-build local
fi
