<center> <h1> Katib Example on DigitalOcean </h1> </center>
<center> <h4> Jagan Lakshmipathy <h4> <h4> 10-23-2024 <c/enter> </h4> </center>


### 1. Introduction
This repo contains a hyperparameter tuning example using a Kubeflow component called Katib. Katib is a kubernetes-native project for automated machine learning (AutoML). This repo for now shows only hyperparameter tuning. Here we will focus on how to tune hyperparameters of machine learning models using [Kubeflow Katib](https://www.kubeflow.org/docs/components/katib/overview/).We will use [DigitalOcean](https://cloud.digitalocean.com/) Kubernetes (DOK) to deploy and test this code. So, we will use DOK CLI commands with kubectl commands to control the DOK cluster from our console. So, the steps listed here is not completely cloud provider agnostic. We are going to assume that you are going to follow along using DOK. However, you can follow along with any of your preferred cloud provider for the most part with the exception of DOK CLI commands. 

### 2. Prerequesites

We will be using MacOS to run the kubernetes commands and DOK CLI commands using bash shell. You can follow along with your prefered host, operating system and shell. You refer here to install and configure [DOCTL](https://docs.digitalocean.com/reference/doctl/how-to/install/). We also assume that you have setup an account with preferred cloud provider to follow along.

### 3. What's in this Repo?
This repo has a docker file to build the workload image, training workload in mnist.py, and a manifest random.yaml to deploy this workload.

### 4. What is in the Katib Workload
The Katib workload is in mnist.py. Lets review this file. Between lines 32 and 48 we define a neural network model. Between lines 51 and 65 we define the training code. Between lines 68 and 93 we test the trained model one test sample at a time, we compute the loss and accuracy. We accumalate the losses and accuracy and record the values of loss and accuracy as hypertuning metric. In the main we create an instance of hypertune object and pass it to test function above (between lines 68 and 93) to register the hypertune and finally we run the train and test for n number of epochs.

### 5. Build the workload and Tag it
The first command builds using the Dockerfile and mnist.py. Review the Dockerfile to understand how the image is built.
```
    bash> docker build -f Dockerfile --platform="linux/amd64" -t pytorch-mnist-cpu:latest .
    bash> docker tag pytorch-mnist-cpu:latest registry.digitalocean.com/<your DO container registry name>/pytorch-mnist-cpu:latest
```
The second command tags the local image with the DO container name.

### 6. Tag and push the image to the DO Container Registry
Now we are ready to push the tagged image to DO Container Registry (DOCR). Before we push the image to DOCR, lets make sure we are logged into the registry.
```
    bash> doctl registry login
    bash> docker push registry.digitalocean.com/do-dev-jagan-06022024/pytorch-mnist-cpu:latest
```
### 7. Download DOK configuration file
We assume that the kubernetes cluster is up and running. We will do the following two steps to prepare our console to be authenticated to interact with the DOK cluster remotely.

1. Download the kubernetes config file for your cluster from DOK

2. And use the downloaded file to check if the kubernetes is running using the following command.
```
    bash> kubectl get pods --watch --kubeconfig=<downloaded file>

```
### 8. Install Katib in DOK
Now that our cluster is up and running, let's install Katib in the DOK using the following command. This will install katib version 0.16.0. This was the latest version at the time of this implementation. This command will install Katib in a standalone mode.  Katib could also be run as a part of the kubeflow ecosystem. However, we will run in the standalone mode for this example.
```
    bash> kubectl apply -k "github.com/kubeflow/katib.git/manifests/v1beta1/installs/katib-standalone?ref=v0.16.0" --kubeconfig=/config/file/path/<your-downloaded-config>.yaml
    bash> kubectl get pods --namespace kubeflow --watch --kubeconfig=<downloaded file>
```

### 9. Run experiments to find optimal hyperparameters
Check the status of the implementation using kubectl. Once the katib is installed and running sucessfully. Run the experiment using the following command. The command uses the provided random.yaml. This file refers to the uploaded workload image in the CR, so make sure to edit the reference.
```
    bash> kubectl create -f random.yaml --kubeconfig=/config/file/path/<your-downloaded-config>.yaml
```
Let's review the random.yaml here. At line line 13 we specify "random" algorithm. We have set parallelTrialCount, maxTrialCount, and maxFailledTrialCount respectively in lines 14, 15, and 16 respectively. We also specify the hypertune parameters and their ranges between lines 17 and 27. We also specify the trial parameters in the trialTemplate between lines 30 and 36. Finally we specify the command line arguments betwen lines 48 and 53. Note, how we refer the trial parameters in this block. Rest of the code in this yaml file is self explanatory.
### 10. Watch the Katib Dashboard
Once we started the experiments, do the port forwarding of the Katib UI using the following command so that you can watch the dashboard from your local host. 
```
    bash> kubectl port-forward svc/katib-ui -n kubeflow 8080:80 --kubeconfig=/config/file/path/<your-downloaded-config>.yaml
```
Use this URL to access the Katib UI:
```
    http://localhost:8080/katib/
```
You will see a graph showing the level of validation and training accuracy for various combinations of the hyperparameter values.