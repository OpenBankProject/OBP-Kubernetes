.. _kafka_deploy_tutorial:

************************************
Deploy Open Bank Project With Kafka
************************************

Start with a fresh kubernetes environment. 

### Deploy the kafka manifests

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


# Google Cloud Example

The following creates a three node cluster on Google Cloud with autoscaling enabled. **Warning** it 
enabled preemptible nodes, which mean they could get shutdown at anytime, and *always* within 24 hours.
Why use these? They're much cheaper, and if architected correctly failure of a node should not impact 
the system. Remember a borg master is replicated 5 times, and the kubernetes master is abstracted away (and 
not charged for) on Google's Kubernetes so it's always available. 

## 1. Create a cluster of nodes

> The first time you do this, you will hit quota errors, such as max ip addresses per account. You must 
  request a change to your quota to allow this.

Change 'projectname' to your project name.

```
gcloud beta container \
    --project "<projectname>" \
    clusters create "standard-cluster-1" \
    --zone "europe-north1-a" \
    --username "admin" \
    --cluster-version "1.11.6-gke.2" \
    --machine-type "f1-micro" \
    --image-type "COS" \
    --disk-type "pd-standard" \
    --disk-size "30" \
    --metadata disable-legacy-endpoints=true \
    --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
    --preemptible \
    --num-nodes "3" \ 
    --enable-cloud-logging \
    --enable-cloud-monitoring \ 
    --enable-ip-alias \
    --network "projects/<projectname>/global/networks/default" \
    --subnetwork "projects/projectname/regions/europe-north1/subnetworks/default" \ 
    --default-max-pods-per-node "110" \ 
    --enable-autoscaling \
    --min-nodes "3" \
    --max-nodes "10" \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing,KubernetesDashboard \
    --enable-autoupgrade \
    --enable-autorepair \
    --enable-autoprovisioning \
    --min-cpu 1 --max-cpu 1 \
    --min-memory 1 --max-memory 1 \
```

## 2. Connect to your cluser

From your terminal, connect to your cluser. You can also do this through the Google
'web console' interface if you prefer.

```
gcloud container clusters get-credentials <cluster-name> --zone europe-north1-a --project <project-name>
```

## 3. Deploy OBPAPI to Google Kubernetes

Deploy the `obpapi_k8s.yaml` to your cluster. Kubernetes will read this and deploy the objects within
the document.

```
kubectl apply -f obpapi_k8s.yaml
```

Useful commands to see progress:

```
kubectl get pods
kubectl logs -f <pod-name>
```

## 4. Patching the reclaim policy to `Retain`
https://kubernetes.io/docs/tasks/administer-cluster/change-pv-reclaim-policy/
```
kubectl get pv
kubectl patch pv <your-pv-name> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

## 5. Access the Dashboard

If you like, you can view the pretty dashboard showing the deployment load, progess etc:
```
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
```
```
kubectl proxy
```
You can now view the dashboard at: http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview?namespace=default 
