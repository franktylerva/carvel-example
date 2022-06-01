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

1. Create a new bundle directory and save your Kubernetes configuration into the root of that directory.  Notice we are using a Helm chart to produce the configuration.
    ```
    mkdir -p kafka-bundle/.imgpkg

    helm template kafka confluentinc/cp-helm-charts --skip-tests --values ./kafka/values.yaml > kafka-bundle/config.yml
    ```

2. Now we'll use the kbld tool to create an image lock file within the bundle directory under the .imgpkg directory called images.yml.

    ```
    kbld -f bundle/config.yml --imgpkg-lock-output kafka-bundle/.imgpkg/images.yml
    ```
    kbld will parse through the configuration and create the image lock file which maps the various images definitions to immutable image references.

3. Next we'll use the imgpkg tools push commmand to push the bundle to our OCI compliant registry.

    ```
    imgpkg push -b harbor.cp.az.km.spaceforce.mil/legos-test/kafka:7.0.1 -f bundle
    ```

4.  Were now ready to move the bundle from our trusted registry to the air-gapped registry.  We'll do this using the imgpkg copy command.  This will pull the bundle, incliding the images into a tar file that can be shipped to the air-gapped environment via any means (diode, dvd, use drive, etc.).
    ```
    imgpkg copy -b harbor.cp.az.km.spaceforce.mil/legos-test/kafka:7.0.1 --to-tar=kafka.tar
    ```

5. Once the tar file is in the air-gapped environment, we'll use the imgpkg copy command to load the bundle (configuration and images) into the OCI compliant registry located in the air-gapped environment.
    ```
    imgpkg copy --tar kafka.tar --to-repo=core.harbor.domain/library/kafka --registry-verify-certs=false
    ```

6.  Now were ready to deploy the bundle to the air-gapped environment.  We'll use the imgpkg pull command to pull the configuration from the registry to a temporary directory.  Then we'll use the kbld command to transform the image references to images referencing the air-gapped registry.
    ```
    imgpkg pull -b core.harbor.domain/library/kafka:7.0.1 -o temp --registry-verify-certs=false

    kbld -f temp/config.yml -f temp/.imgpkg/images.yml | kubectl apply -f-

    kapp -y deploy -a kafka -f <(kbld -f temp/config.yml -f temp/.imgpkg/images.yml)

    ```

Optionally, you can deploy Prometheus to monitor the cluster.
```
kapp deploy -a prometheus -f <(helm template prometheus bitnami/kube-prometheus)
```
