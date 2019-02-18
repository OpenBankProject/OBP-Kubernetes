#!/usr/bin/env bash
set -e
source ./env
gcloud beta container \
    --project $PROJECT_NAME \
    clusters create $CLUSTER_NAME \
    --zone $ZONE \
    --username "admin" \
    --cluster-version "1.11.6-gke.2" \
    --machine-type "n1-standard-1" \
    --image-type "COS" \
    --disk-type "pd-standard" \
    --disk-size "29" \
    --metadata disable-legacy-endpoints=true \
    --preemptible \
    --num-nodes "3" \
    --enable-cloud-logging \
    --enable-cloud-monitoring \
    --enable-ip-alias \
    --network "projects/$PROJECT_NAME/global/networks/default" \
    --subnetwork "projects/$PROJECT_NAME/regions/$REGION/subnetworks/default" \
    --default-max-pods-per-node "110" \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing,KubernetesDashboard \
    --enable-autoupgrade \
    --enable-autorepair \
    --enable-autoprovisioning \
    --min-cpu 1 \
    --max-cpu 1 \
    --min-memory 1 \
    --max-memory 1 \
    --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append"
