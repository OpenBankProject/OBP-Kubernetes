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

echo "Wait 20 secconds for loadbalancer to assign public ip before we verify"
sleep 20
echo "Verifying deployment"
./verify.sh
