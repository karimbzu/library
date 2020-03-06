#!/bin/bash
source .env
IMAGE_TAG=${RANDOM}

if ! oc get project ${NAMESPACE}; then
  echo project ${NAMESPACE} not found, creating new project ${NAMESPACE}
  oc new-project ${NAMESPACE}
fi

if [ "$APP_KNATIVE" = "true" ]; then
  echo Deploying Serverless Service
  APP_KNATIVE_FLAG="--knative"
fi

appsody deploy   --tag ${NAMESPACE}/${IMAGE_NAME}:${IMAGE_TAG}   --push-url ${IMAGE_REGISTRY}   --pull-url ${INTERNAL_IMAGE_REGISTRY}   -n ${NAMESPACE} ${APP_KNATIVE_FLAG}

if [ "$APP_KNATIVE" = "true" ]; then
  echo Getting Serveless Application URL...
  APP_URL=$(oc get ksvc ${APP_NAME} -n ${NAMESPACE} -o jsonpath="{.status.url}")
else
  echo Getting Application URL...
  APP_URL=http://$(oc get route ${APP_NAME} -n ${NAMESPACE} -o jsonpath="{.spec.host}")
fi

echo App deployed: ${APP_URL}
