*****************************
Quickstart Guide
*****************************

Simply deploy the manifests
----------------------------

.. code-block:: shell
    :linenos:

    # Deploy open bank project
    kubectl apply -f obpapi_k8s.yaml
    # Output: 
    service/obpapi-service created
    deployment.apps/obp-deployment created
    service/postgres-service created
    deployment.apps/obp-postgres created
    persistentvolumeclaim/postgres created

For environment spesific options see:

- microk8s see :ref:`microk8s_cloud_deploy_tutorial <microk8s_cloud_deploy_tutorial>`
- google-cloud see :ref:`google_cloud_deploy_tutorial <google_cloud_deploy_tutorial>`
- docker-only see :ref:`docker_deploy_tutorial <docker_deploy_tutorial>`
- with-kafka see :ref:`kafka_deploy_tutorial <kafka_deploy_tutorial>`


