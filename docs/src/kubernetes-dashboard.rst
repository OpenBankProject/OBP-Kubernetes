View Kubernetes Dashboard
--------------------------

If you like, you can view the pretty dashboard showing the deployment load, progess etc:
```
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
```
```
kubectl proxy
```
You can now view the dashboard at: http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview?namespace=default 
