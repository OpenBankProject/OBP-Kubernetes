sudo microk8s.docker build -t localhost:32000/obpapi:latest
sudo microk8s.docker push localhost:32000/obpapi:latest
sudo microk8s.kubectl deploy obpapi --image=localhost:32000/obpapi:latest
sudo microk8s.kubectl expose deployment obpapi --type=NodePort --port=8080
