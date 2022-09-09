# Kubernetes Build (local development)


## Target environments

- [Openshift](openshift)
- Kubernetes (see below)

For running locally, install https://microk8s.io/docs/.
Otherwise, use a kubernetes provider (Google Cloud, OpenShift etc)


## 1. Start microk8s, enable addons, and deploy 

    # Start your local microk8s environment (you might prefer to use minikube)
    microk8s.start
    microk8s.enable dns dashboard registry #Only needed once
    microk8s.status

#### Without kafka

    # Deploy open bank project
    kubectl kustomize base/ | kubectl apply -f - #pipe from stdin
    # Output: 
    service/obpapi-service created
    deployment.apps/obp-deployment created
    service/postgres-service created
    deployment.apps/obp-postgres created
    persistentvolumeclaim/postgres created

#### With kafka

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



## Scale the OBPAPI deployment

Currently only the `obp-deployment` can be scaled. The Postgres instance cannot until we implement 
[Patroni](https://github.com/zalando/patroni), or use a managed service like RDS(AWS) or Cloud SQL 
(Google)

| WARNING: If your cluster is too small and/or autoscaling is disabled, your cluster is the limit! |
| --- |

Steps to scale to more obpapi instances:

```
kubectl scale deployment.v1.apps/obp-deployment --replicas=5
# Monitor progress of scale up
kubectl rollout status deployment.v1.apps/obp-deployment
kubectl describe deployment obp-deployment
```

### DNS Mapping hostname to cluster (Poor mans ingress)

#### HTTP (Done) 
The service `obpapi-service` type is [LoadBalancer](https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer), which means an external load balancer is provisioned (depending on the 
cloud provider being used). We get a public ipv4 address, and can use this to point a DNS A record to the
ip.

```
# Find exernal ip
kubectl get services
# Copy 'external ip'
```

Traffic from the external load balancer will be directed at the backend Pods.
HTTP: https://cloud.google.com/kubernetes-engine/docs/tutorials/http-balancer

#### HTTPS (TODO)
HTTPS requires different steps: https://cloud.google.com/load-balancing/docs/https/



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

Deploy the manifests to your cluster. Kubernetes will read this and deploy the objects within
the document.

```
kubectl kustomize base/ | kubectl apply -f - #pipe from stdin
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


<hr />

# SSL Termination
How do we route http traffic to obp?

We use [cert manager](https://docs.cert-manager.io/en/latest/getting-started/install.html).

```
# GKE (Google Kubernetes Engine) only
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole=cluster-admin \
  --user=$(gcloud config get-value core/account)
# Create a namespace to run cert-manager in
kubectl create namespace cert-manager
# Disable resource validation on the cert-manager namespace
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
# Install the CustomResourceDefinition resources
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml
```

## Docker only Build
If you just want run Open Bank project locally on your machine quickly, you can use this docker image
rather than pulling from docker hub (e.g. you're offline).

See `BuildWarDockerfile` 
    # Build it
    docker build --no-cache --tag obpapi -f BuildWarDockerfile
    # Or pull and run it 
    docker run -p 8080:8080 chrisjsimpson/obp:minimal

If you already have a war file, just inject it into the build:

    ```
    docker build --no-cache -t obpapi-kube .
    docker run --env DB_USER=username --env DB_PASS=password --env DB_NAME=dbname --env DB_HOST=127.0.0.1 --network="host" -p8080:8080 obpapi-kube
    ```


## Run 

    docker run -p 8080:8080 obpapi

    Visit http://127.0.0.1:8080/

## See also

- https://docs.docker.com/develop/develop-images/multistage-build/ 
- https://www.eclipse.org/jetty/documentation/9.4.x/maven-and-jetty.html


## Minikube notes
To view OBP interface locally, you must use the command:
`minikube service obpapi-service` which will map ports and open a web browser 
pointing to the obp service.

Additionally, you may need to change the `obpapi-service` type to from 
`LoadBalancer` to `NodePort`, since on your local machine you may not have a 
default loadbalancer defined on your kubernetes instance
