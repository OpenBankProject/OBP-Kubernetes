.. _docker_deploy_tutorial:

Docker only Build
------------------

If you just want run Open Bank project locally on your machine quickly, you can use this docker image
rather than pulling from docker hub (e.g. you're offline).

See `BuildWarDockerfile` 

.. code-block:: shell
    :linenos:

    # Build it
    docker build --no-cache --tag obpapi -f BuildWarDockerfile
    # Or pull and run it 
    docker run -p 8080:8080 chrisjsimpson/obp:minimal

If you already have a war file, just inject it into the build:

.. code-block:: shell
    :linenos:

    docker build --no-cache -t obpapi-kube .
    docker run --env DB_USER=username --env DB_PASS=password --env DB_NAME=dbname --env DB_HOST=127.0.0.1 --network="host" -p8080:8080 obpapi-kube


Run
#####

.. code-block:: shell
    :linenos:

    docker run -p 8080:8080 obpapi

    Visit http://127.0.0.1:8080/

See also
#########

- https://docs.docker.com/develop/develop-images/multistage-build/ 
- https://www.eclipse.org/jetty/documentation/9.4.x/maven-and-jetty.html


Minikube notes
##############
To view OBP interface locally, you must use the command:
`minikube service obpapi-service` which will map ports and open a web browser 
pointing to the obp service.

Additionally, you may need to change the `obpapi-service` type to from 
`LoadBalancer` to `NodePort`, since on your local machine you may not have a 
default loadbalancer defined on your kubernetes instance
