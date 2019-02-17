#!/usr/bin/env bash
source ./env

echo "Checking / installing requirements"
./requirements-debian.sh
echo "Init gcloud utility"
./init.sh

echo "Create cluster"
./create-cluster.sh

echo "Deploy onto cluster"
./deploy.sh

echo "Wait 60 secconds for loadbalancer to assign public ip before we verify"
sleep 60
echo "Verifying deployment"
./verify.sh
