# Kubernetes
Simple example to build a custom docker image, debug it, and run it in a [kubernetes](https://kubernetes.io/docs/tutorials/kubernetes-basics/) [job](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/).

## Requirements
make

[docker](https://docs.docker.com/install/)

A [docker hub](https://hub.docker.com) account

[kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

A kubernetes configuration file for your cluster (in ~/.kube/config)

## Quick Start
Clone this repo and change into its directory:
```
git clone https://github.com/rcurrie/kubernetes.git
cd kubernetes
```
Build a custom image with run.py in it:
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
Run the image in a container locally:
```
$ make run
# Run the image in a container locally
docker run -it --rm \
        rcurrie-ubuntu -c 3 foobar
Calculating magic on block 0 from file foobar
Calculating magic on block 1 from file foobar
Calculating magic on block 2 from file foobar
```
Push your image to docker hub so it is accessible to the cluster:
```
$ DOCKERHUB_ACCOUNT=<your docker hub account> make push
# Push our image to dockerhub for running in k8s
docker tag rcurrie-ubuntu robcurrie/ubuntu
docker push robcurrie/ubuntu
The push refers to repository [docker.io/robcurrie/ubuntu]
2fb7bfc6145d: Layer already exists
...
latest: digest: sha256:d72d572b9f3b7683a1e07a80ac04fdb6076870087ac789d1079d548731a385da size: 2405
```
Run the image in a container in a kubernetes job:
```
$ DOCKERHUB_ACCOUNT=robcurrie make run-job
# Run a kubernetes job with our image, prefix with USERNAME and timestamp
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

## Development
Run the image in a docker container on your local machine with the local run.py mapped and shell into it:
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
Changing run.py will show up in the container immediately as its a mapped file which is handy for editing externally and running in the container locally by exec'ing /bin/bash. The benefit of this pattern is all your dependencies are in the container isolated from the host operating system and codified in the image - if it works locally it will likely work somewhere else. 

REMINDER: Before running in a cluster remember to build and push the container so that the edited run.py is updated. For more dynamic configuration you can customize the command and args in job.yml or have the job itself pull code or configuration from somewhere else. For example [this script](https://github.com/rcurrie/jupyter/blob/master/job.py) pulls a jupyter notebook specified in args into a job from s3, runs it, and pushes it back to s3.

Build, push and launch the image in a job all at once:
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

## Bash Completion
Add:
```
source <(kubectl completion bash)
```
to your ~/.bash_profile for tab completion of job names

## Secrets
The job.yml specifies a shared secret that has been configured in the namespace already. The aws cli is installed in the image and as a result you can use aws cli and/or boto3 when shelled into the container or in run.py:
```
root@rcurrie-20190909-173419-kvwft:/app# aws s3 ls s3://vg-k8s
2019-09-10 00:26:50          7 hello.txt
```

## Job Patterns and Frameworks
This repo demonstrates core close to the metal kubernetes and jobs. There are many other [job patterns](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/#job-patterns) as well as a plethora of higher level frameworks that support kubernetes such as [snakemake](https://snakemake.readthedocs.io/en/stable/), [nextflow](https://www.nextflow.io), [kubeflow](https://www.kubeflow.org), [pachyderm](https://www.pachyderm.io) and [polyaxon](https://polyaxon.com).

## Using Multiple Clusters
Set the [KUBECONFIG environment variable](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#supporting-multiple-clusters-users-and-authentication-mechanisms) to a colon separated list of all your config files. You can then switch clusters in a stateful way via 
```
kubectl config use-context <context name>
```
To automatically reference all config files with the suffix .config add the following to your ~/.bash_profile:
```
export KUBECONFIG=`find $HOME/.kube/ -name "*.config" -printf "%p:"`
```
You can create your own set of cluster and namespaces which will be integrated automatically by kubectl letting you switch and set both at once. See [configuring access to multiple clusters](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/) for more details.
