#!/usr/bin/env bash
set -e
source ./env
# Remove cluster
gcloud container clusters delete --project $PROJECT_NAME --zone $ZONE $CLUSTER_NAME
