# Kubernetes
Simple example to build a custom container, debug it, and then run it in a Kubernetes job.

## Requirements
make
docker
A [docker hub](https://hub.docker.com) account
[kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
Kubernetes configuration file for your cluster (in ~/.kube/config)

## Quick Start
Clone this repo and switch into it:
```
git clone https://github.com/rcurrie/kubernetes.git
cd kubernetes
```
Build a custom container with run.py in it:
```
$ make build
# Build custom docker image
docker build -f Dockerfile -t rcurrie-ubuntu .
Sending build context to Docker daemon  123.4kB
Step 1/8 : FROM ubuntu:18.04
 ---> 1d9c17228a9e
...
Step 8/8 : ENTRYPOINT ["python3", "run.py"]
 ---> Using cache
 ---> 3bec533b42cb
Successfully built 3bec533b42cb
Successfully tagged rcurrie-ubuntu:latest
```
Push your container to docker hub so it is accessible to the cluster:
```
$ DOCKERHUB_ACCOUNT=<your docker hub account> make push
# Push our container to dockerhub for running in k8s
docker tag rcurrie-ubuntu robcurrie/ubuntu
docker push robcurrie/ubuntu
The push refers to repository [docker.io/robcurrie/ubuntu]
2fb7bfc6145d: Layer already exists
...
latest: digest: sha256:d72d572b9f3b7683a1e07a80ac04fdb6076870087ac789d1079d548731a385da size: 2405
```
Run the custom container in a job:
```
$ DOCKERHUB_ACCOUNT=robcurrie make run-job
# Run a kubernetes job with our container
TS=`date +"%Y%m%d-%H%M%S"` envsubst < job.yml | kubectl create -f -
job.batch/rcurrie-20190904-171803 created
```
List all the jobs in the namespace:
```
$ kubectl get jobs
NAME                      COMPLETIONS   DURATION   AGE
rcurrie-20190904-171803   0/1           17s        17s
```
Tail the log output from the job
```
$ kubectl logs -f rcurrie-20190904-171803-dwkst
Performing magic block 0 from foobar
Performing magic block 1 from foobar
...
```
NOTE: You can view the logs of completed jobs as well as running jobs

## Running
Shell into a job running in the cluster:
```
$ kubectl exec -it rcurrie-20190904-172125-2cm78 /bin/bash
root@rcurrie-20190904-172125-2cm78:/app# ps -A
   PID TTY          TIME CMD
    1 ?        00:00:00 python3
    8 pts/0    00:00:00 bash
   23 pts/0    00:00:00 ps
```
Do you see the symmetry with docker running local?

Delete all your jobs (prefixed with your username by make run-job):
```
make delete-my-jobs
```
NOTE: This will stop and delete any running jobs as well as the logs from previous jobs

## Development
Run the container on your local machine with the local run.py mapped and shell into it:
```
$ make debug
# Run our image with the local version of the app and shell into it
docker run -it --rm \
        -v `pwd`:/app \
        --user=`id -u`:`id -g` \
        --entrypoint /bin/bash \
        rcurrie-ubuntu
groups: cannot find name for group ID 2000
I have no name!@afa68a3595b2:/app$ python3 run.py foobar
Calculating magic on block 0 from foobar
Calculating magic on block 1 from foobar
...
```
REMINDER: Changing run.py will show up in the container as its mapped which is handy for editing externally and running in the container locally. Before running in a cluster you need to build and push the container so that the edited run.py is updated.

Run the container locally before pushing:
```
make run
```

Build, push and launch a job
```
$ DOCKERHUB_ACCOUNT=<your dockerhub account> make build push run-job
# Build custom docker image
docker build -f Dockerfile -t rcurrie-ubuntu .
Sending build context to Docker daemon  136.2kB
Step 1/8 : FROM ubuntu:18.04
...
docker push robcurrie/ubuntu
The push refers to repository [docker.io/robcurrie/ubuntu]
c59a876203dd: Layer already exists
...
# Run a kubernetes job with our container, prefix with USERNAME and timestamp
TS=`date +"%Y%m%d-%H%M%S"` envsubst < job.yml | kubectl create -f -
job.batch/rcurrie-20190905-062754 created
```

## Bash Completion
Add:
```
source <(kubectl completion bash)
```
to your ~/.bash_profile for tab completion of job names

## Multiple Clusters
Set the [KUBECONFIG environment variable](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#supporting-multiple-clusters-users-and-authentication-mechanisms) to a colon separated list of all your config files. You can then switch clusters in a stateful way via 
```
kubectl config use-context <context name>
```
To automatically reference all config files with the suffix .config add the following to your ~/.bash_profile:
```
export KUBECONFIG=`find $HOME/.kube/ -name "*.config" -printf "%p:"`
```
