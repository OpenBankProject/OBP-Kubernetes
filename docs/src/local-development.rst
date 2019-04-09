*****************************
Kubernetes Local Environment
*****************************

Simply deploy the manifests
---------------------

    # Deploy open bank project
    kubectl apply -f obpapi_k8s.yaml
    # Output: 
    service/obpapi-service created
    deployment.apps/obp-deployment created
    service/postgres-service created
    deployment.apps/obp-postgres created
    persistentvolumeclaim/postgres created

For environment spesific options see:

- microk8s see microk8s_deploy_tutorial_ 
- google-cloud see google_cloud_deploy_tutorial_
- docker-only see docker_deploy_tutorial_
- with-kafka see kafka_deploy_tutorial_


