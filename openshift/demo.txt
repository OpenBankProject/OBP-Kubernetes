# Create new project (optional)
```
oc new-project demo
```
# Import the deployment template:
```
oc create -f https://raw.githubusercontent.com/chrisjsimpson/obp-kubernetes/master/openshift/obpapi_openshift.yaml
```
# Deploy the template:
```
oc new-app obp-api-example
```
#### Output:
```
--> Deploying template "myproject/obp-api-example" to project myproject

--> Creating resources ...
    secret "postgres-credentials" created
    persistentvolumeclaim "postgres-volume-claim" created
    service "obpapi-service" created
    deployment.extensions "obp-deployment" created
    service "postgres-service" created
    deployment.extensions "postgres" created
--> Success
    Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
     'oc expose svc/obpapi-service' 
     'oc expose svc/postgres-service' 
    Run 'oc status' to view your app.
```
# Verify Deployment is running
View the pods until they're running:
```
oc get pods
NAME                              READY     STATUS              RESTARTS   AGE
obp-deployment-79595dd6b6-56ccw   0/1       ContainerCreating   0          44s
postgres-86bd6f8dd9-gbvv7         0/1       ContainerCreating   0          44s
```
#### Verify 'running' state: 
```
oc get -w pods
NAME                              READY     STATUS    RESTARTS   AGE
obp-deployment-79595dd6b6-56ccw   1/1       Running   0          1m
postgres-86bd6f8dd9-gbvv7         1/1       Running   0          1m
```
# Scale Open Bank Project down / up
The database must be ready before Open Bank Project can run. To ensure this, we must scale down the obp deployment, and back up.
```
oc scale deployment obp-deployment --replicas=0
oc scale deployment obp-deployment --replicas=1 
```

# Create a route to Open Bank Project frontend:
Create a http url to navigate to the Open Bank Project frontend:
```
oc create -f https://raw.githubusercontent.com/chrisjsimpson/obp-kubernetes/master/openshift/route.yaml
```
Get the route by:
```
oc get routes
NAME           HOST/PORT                                        PATH      SERVICES         PORT      TERMINATION   WILDCARD
obp-frontend   obp-frontend-test.apps.openbank-redhat.rhmi.io             obpapi-service   <all>                   None
```
Follow the URL from the output shown, you can now browse to the Open Bank Project hosted on Openshift.

# Inject bootstrap user
The bootstrap user is a tempory account which has enough privileges to seed the Open Bank Project with some dummy data. 
There is a `bootstrap` pod to do most of the work for you. 

## Deploy the bootstap pod:
```
oc create -f https://raw.githubusercontent.com/chrisjsimpson/obp-boostrap-user/master/bootstrap.yaml
deployment.apps/bootstrap-deployment created
```

### Verify bootstrap pod is ready:
```
oc get pods -l app=bootstrap
NAME                                    READY     STATUS              RESTARTS   AGE
bootstrap-deployment-55694df658-r6m56   0/1       ContainerCreating   0          16s
```
Ready:
```
oc get pods -l app=bootstrap
NAME                                    READY     STATUS    RESTARTS   AGE
bootstrap-deployment-55694df658-r6m56   1/1       Running   0          54s
```
# Bootstrap the deployment
We will:
- Run the bootstrap to create a new user, and generate an api key
- Fetch the generated user_id from the application
- Prote this user to a super user
- Use this super user to populate with dummy data

## Run the bootstrap pod command to create a new user, and generate an api key 
```
oc exec -it $(oc get pods -l app=bootstrap -o jsonpath='{.items[0].metadata.name}') -- bash -c "export OBP_API_HOST=http://obpapi-service; python3 bootstrap.py"
```

## Copy assigned user id to local host
```
oc cp $(oc get pods -l app=bootstrap -o jsonpath='{.items[0].metadata.name}'):obp_user_id.txt ./
```
The user id is now used to create a patched for the deployment to inject this user id into the deployment as a super user id.

# Generate patch for deployment with user id as super user
```
sed s/REPLACE_ME/`cat obp_user_id.txt`/g patch-deployment.yaml.example > patch-deployment.yaml;
```

# Patch the deployment with user id
```
oc patch deployment obp-deployment --patch "$(cat patch-deployment.yaml)"
```

# Authenticate against Open Bank Project
Retrieve generated consumer key from bootstrap pod:
```
oc cp $(oc get pods -l app=bootstrap -o jsonpath='{.items[0].metadata.name}'):consumerKey.txt ./
```
View your consumer key:
```
cat consumerKey.txt
```
# Use obp cli to authenticate against the api 
```
obp init
Please enter your API_HOST:  [http://obp-frontend-demo.apps.openbank-redhat.rhmi.io/]: http://obp-frontend-demo.apps.openbank-redhat.rhmi.io/
Please enter your username:  [demo]: demo
Please enter your password: : 
Repeat for confirmation: 
... generating direct login token
Please enter your OBP_CONSUMER_KEY:  [inwpg5vajtt4am2b12zt5pi1zrqgmwtryefcicnz]: inwpg5vajtt4am2b12zt5pi1zrqgmwtryefcicnz
Init complete
```
# Add role CanCreateSandbox to user
```
obp addrole --role-name CanCreateSandbox
{"entitlement_id":"6847575e-b0de-42e0-a10a-d0d5c07c4b04","role_name":"CanCreateSandbox","bank_id":""}
```
# Import sandbox demo data
```
obp sandboximport --input example_import.json
Sandbox import complete
```

You can query the api's to view dummy data from the Open Bank Project sandbox. e.g
- View public data, such as get banks
- Public data such at ATM locations
- Private data such as user accounts (requires login)


## Get banks example output (from OpenShift)
```
obp getbanks
{'banks': [{'bank_routing': {'address': 'psd201-bank-x--uk',
                             'scheme': 'OBP'},
            'full_name': 'The Bank of X',
            'id': 'psd201-bank-x--uk',
            'logo': 'https://static.openbankproject.com/images/sandbox/bank_x.png',
            'short_name': 'Bank X',
            'website': 'https://www.example.com'},
           {'bank_routing': {'address': 'psd201-bank-y--uk',
                             'scheme': 'OBP'},
            'full_name': 'The Bank of Y',
            'id': 'psd201-bank-y--uk',
            'logo': 'https://static.openbankproject.com/images/sandbox/bank_y.png',
            'short_name': 'Bank Y',
            'website': 'https://www.example.com'}]}

```

