# Deploy to Google Kubernetes Engine

## 1. Create a Google Cloud account & Kubernetes Project (a blank project)

Go to their website, create an account, create a project, go to Kubernetes engine. 
Enable billing. It won't work without activating billing.

## 2. Create cluster on that project, deploz and verify

**Warning** This will install gcloud, curl, and kubectl if not already present.

Customise with editing the `env` file.

This will:

- Install the required tools (gcloud, kubectl, curl)
- Create a three node cluster for you, on your project
- Deploy Open Bank Project API to the kubernetes cluster 
- Verify the install (by curling the web page via it's ip address)

```
cd automate
./auto-deploy.sh
```


## 3. What done looks like

Visit the ip of your deployed project and view Open Bank Project web interface.

- Get external ip: `kubectl get service obpapi-service`
- Load the ip in your browser or `curl <the ip>` 
