# Kubernetes
Simple example to build a custom container, debug it, and then run it in a Kubernetes job.

## Requirements
make
docker
A [docker hub](https://hub.docker.com) account
[kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Quick Start
Clone this repo and switch into it:
```
git clone https://github.com/rcurrie/kubernetes.git
cd kubernetes
```
Build a custom container with run.py in it and push to docker hub:
```
make build push
```
Run a job
```
make run-job
```
List all the jobs in the namespace
```
kubectl get jobs
```
Look at the log output from the job
```
kubectl logs -f <name of job from get jobs, or tab complete>
```

## Bash Completion
Add
```
source <(kubectl completion bash)
```
to your ~/.bash_profile for tab completion of job names

## Multiple Clusters
Set the [KUBECONFIG environment variable](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#supporting-multiple-clusters-users-and-authentication-mechanisms) to a colon separated list of all your config files. You can then switch clusters in a stateful way via 
```
kubectl config use-context <context name>
```
To automatically reference all config files with the suffice .config add the following to your ~/.bash_profile:
```
export KUBECONFIG=`find $HOME/.kube/ -name "*.config" -printf "%p:"`
```
