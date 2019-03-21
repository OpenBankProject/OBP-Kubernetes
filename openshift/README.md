# Minishift set-up (rebranded minikube)


- Install virtualbox (or kvm)

```
minikube start
```


### View console
```
minishift console
```

### oc Env (rebranded kubectl)
```
eval $(minishift oc-env)
```

### Docker env
```
eval $(minishift docker-env)
oc login
docker login -u developer -p $(oc whoami -t) $(minishift openshift registry)
```

### Local Docker registry build and push
```
eval $(minishift oc-env)
eval $(minishift docker-env)
oc login
docker login -u developer -p $(oc whoami -t) $(minishift openshift registry)
docker built -t test .
docker tag test $(minishift openshift registry)/myproject/test
docker push $(minishift openshift registry)/myproject/test

# 'Deploy' as new app
oc new-app myproject/test
```
**Note** The 'myproject' tag is needed for minishift docker push to work, otherwise you wil see `unauthorized: authentication required`.  
