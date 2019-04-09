.. _kafka_deploy_tutorial:

************************************
Deploy Open Bank Project With Kafka
************************************

Start with a fresh kubernetes environment. 

Deploy the kafka manifests
############################

.. code-block:: shell
    :linenos:

    # Zookeeper
    kubectl apply -f zookeeper-no-anti-afinity-no-fault-tolerance.yaml
    # Kafka 
    kubectl apply -f kafka-no-anti-affinity.yaml
    # Open bank project
    kubectl apply -f obpapi_k8s_with_kafka.yaml
    # Output:
    service/zk-svc created
    configmap/zk-cm created
    statefulset.apps/zk created
    service/kafka-svc created
    poddisruptionbudget.policy/kafka-pdb created
    statefulset.apps/kafka created
    secret/postgres-credentials created
    secret/obp-credentials configured
    persistentvolumeclaim/postgres-volume-claim created
    service/obpapi-service created
    deployment.apps/obp-deployment created
    service/postgres-service created
    deployment.apps/postgres created
