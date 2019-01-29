# Kubernetes Build

For running locally, install https://microk8s.io/docs/.
Otherwise, use a kubernetes provider (Google Cloud, OpenShift etc)

See docs/kubernetes

    sudo microk8s.start
    sudo microk8s.status
    sudo microk8s.docker build -t localhost:32000/obpapi:latest
    sudo microk8s.docker push localhost:32000/obpapi:latest
    sudo microk8s.kubectl create deployment  obpapi --image=localhost:32000/obpapi:latest
    sudo microk8s.kubectl expose deployment obpapi --type=NodePort --port=8080

# Docker only Build

    docker build --no-cache --tag obpapi .

# Run 

    docker run -p 8080:8080 obpapi

    Visit http://127.0.0.1:8080/

## See also

- https://docs.docker.com/develop/develop-images/multistage-build/ 
- https://www.eclipse.org/jetty/documentation/9.4.x/maven-and-jetty.html
