# Kubernetes Build

For running locally, install https://microk8s.io/docs/.
Otherwise, use a kubernetes provider (Google Cloud, OpenShift etc)

See docs/kubernetes

    # Start your local microk8s environment (you might prefer to use minikube)
    sudo microk8s.start
    sudo microk8s.enable dns dashboard registry #Only needed once
    sudo microk8s.status

    # Deploy open bank project
    sudo microk8s.kubectl create -f obpapi_k8s.yaml
    # Output: 
    service/obpapi-service created
    deployment.apps/obp-deployment created
    service/postgres-service created
    deployment.apps/obp-postgres created
    persistentvolumeclaim/postgres created

# TODO

 See https://github.com/chrisjsimpson/obp-kubernetes/projects


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
