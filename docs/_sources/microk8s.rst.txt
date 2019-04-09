.. _microk8s_deploy_tutorial:

***************************************
Using microk8s with Open Bank Project
***************************************

For running locally, install https://microk8s.io/docs/.

1. Start microk8s, enable addons, and deploy
#############################################

    # Start your local microk8s environment (you might prefer to use minikube)
    microk8s.start
    microk8s.enable dns dashboard registry #Only needed once
    microk8s.status

2. Deploy the manifests
########################

    # Deploy open bank project
    kubectl apply -f obpapi_k8s.yaml
    # Output: 
    service/obpapi-service created
    deployment.apps/obp-deployment created
    service/postgres-service created
    deployment.apps/obp-postgres created
    persistentvolumeclaim/postgres created

## Minikube notes
To view OBP interface locally, you must use the command:
`minikube service obpapi-service` which will map ports and open a web browser 
pointing to the obp service.

Additionally, you may need to change the `obpapi-service` type to from 
`LoadBalancer` to `NodePort`, since on your local machine you may not have a 
default loadbalancer defined on your kubernetes instance
