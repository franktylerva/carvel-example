# atlas-local
This repository is used for setting up Atlas applications in a local development environment for demonstration and testing purposes.  Several tools are used from the Carvel project to demonstrate overlays (ytt) and ordered deployments (kapp).  This project also demonstrates how these tools work with other deployment technologies such as Helm, kustomize, and plain old k8s yaml files.  Currently there are two Atlas applications (observation-crud and crud-aggregator) along with the necessary infrastructure (Kafka, Keycloak, and Postgresql).

Docker, Helm, ytt, kbld, and kapp are required.  You can install these tools using brew.
```
brew install helm

brew tap vmware-tanzu/carvel
brew install ytt
brew install kbld
brew install kapp
```

This project uses Helm Charts from Confluent and Bitnami.  Before running any of these scripts you'll need to add these chart repositories:
```
helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

Start a new minikube cluster:
```
minikube start
```

Start a minikube tunnel in another terminal:
```
minikube tunnel
```

Using Helm, install the Harbor registry in the harbor namespace: 
```
helm install harbor bitnami/harbor --values harbor/values.yaml -n harbor --create-namespace
```

Get the external ip of the harbor service in the harbor namespace and add an entry to your /etc/hosts file:
```
kubectl get svc harbor -n harbor

NAME     TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                                     AGE
harbor   LoadBalancer   10.102.180.15   10.102.180.15   80:31108/TCP,443:32352/TCP,4443:32216/TCP   117s

vi /etc/hosts

127.0.0.1       localhost
10.102.180.15   core.harbor.domain
```

You should now be able to navigate to the Harbor ui via a browser: https://core.harbor.domain/harbor/projects

kubectl create secret docker-registry regcred --docker-server=harbor --docker-username=admin --docker-password=password --docker-email=admin@mail.com
```

## Creating a bundle

This section is here for informational purposes.  The bundle referenced here has already been created and pushed to the KM Harbor repository.  You can skip to step 2 if you want save time and use the existing bundle.  If you do decide to run through these steps, just use a different version when creating and pushing the bundle.

1. Create the new bundle using the provided script.  You can take a look at the script to see the usage of the various tools involved.
    ```
    ./create-atlas-bundle.sh
    ```

2.  Were now ready to move the bundle from our trusted registry to the air-gapped registry.  We'll do this using the imgpkg copy command.  This will pull the bundle, incliding the images into a tar file that can be shipped to the air-gapped environment via any means (diode, dvd, use drive, etc.).
    ```
    imgpkg copy -b harbor.cp.az.km.spaceforce.mil/legos-test/atlas:1.0.0 --to-tar=atlas.tar
    ```

3. Once the tar file is in the air-gapped environment, we'll use the imgpkg copy command to load the bundle (configuration and images) into the OCI compliant registry located in the air-gapped environment.
    ```
    imgpkg copy --tar atlas.tar --to-repo=core.harbor.domain/library/atlas --registry-verify-certs=false
    ```

4.  Now were ready to deploy the bundle to the air-gapped environment.  We'll use the imgpkg pull command to pull the configuration from the registry to a temporary directory.  Then we'll use the kbld command to transform the image references to images referencing the air-gapped registry.
    ```
    imgpkg pull -b core.harbor.domain/library/atlas:1.0.0 -o temp --registry-verify-certs=false

    kbld -f temp/config.yml -f temp/.imgpkg/images.yml | kubectl apply -f-

    kapp deploy -a atlas -f <(kbld -f temp/config.yml -f temp/.imgpkg/images.yml)

    ```

Optionally, you can deploy Prometheus to monitor the cluster.
```
kapp deploy -a prometheus -f <(helm template prometheus bitnami/kube-prometheus)
```
