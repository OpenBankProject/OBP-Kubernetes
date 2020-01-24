# Minishift set-up (rebranded minikube)

- Install minishift (https://docs.okd.io/latest/minishift/getting-started/index.html)


```
minishift start
```


### View console
```
minishift console
```

### oc Env (rebranded kubectl)
```
eval $(minishift oc-env)
```


### Import the template

Openshift `oc apply` command does **not** appear to automatically run your
manifest because `obpapi_openshift.yaml` is a template object. 
After running this command you must use `oc new-app` to actually run the 
template. This is confusing because with vanilla kubernetes kubectl would run 
the manifest. An openshift template is similar (but not the same) as a Helm 
cart if you're familiar with helm.
```
oc apply -f obpapi_openshift.yaml
```
Now run the template as a new app:
```
oc new-app obp-api-example # App name comes from the template name in yaml file. 
```

Add a route for the service:
``` 

oc expose svc/obpapi-service
```

See if it works:


### Seed the sandbox: Deploy a bootstrap pod

We have a bootstrap node which creates an initial user for you automatically.
This user can then be promoted to a super admin, and used to import demo data.

```
oc apply -f ../../obp-boostrap-user/bootstrap.yaml # Deploy bootstrap node
```

Get boostrap.yaml, and edit the `env` file:

- username
- password

The password policy is very strict. Install will fail if too weak.

```
wget https://raw.githubusercontent.com/chrisjsimpson/obp-kubernetes/master/bootstrap.yaml
```







-----------------Old------------------
### Docker env
```
eval $(minishift docker-env)
oc login # username developer, password password
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
