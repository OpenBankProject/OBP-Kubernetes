#!/usr/bin/env bash
echo "Getting nodes"
kubectl get nodes
echo "Getting pods"
kubectl get pods
echo "Getting services"
kubectl get services
echo "Get ip(s) of obp service"
kubectl get service obpapi-service

OBPIP=`kubectl get service obpapi-service| awk 'FNR==2' | awk {'print $4'}`
BODY=`curl -s $OBPIP`

echo "Checking http request to GET $OBPIP contains 'Open Bank Project'"
if [[ $BODY == *"Open Bank Project"* ]]; then
    echo "Success"
    exit 10
else
    echo "Fail"
    exit -1
fi
