DOCKERHUB_ACCOUNT ?= "robcurrie"

build:
	# Build customer docker image
	docker build -f Dockerfile -t $(USER)-ubuntu .

push:
	# Push our containers to dockerhub for running in k8s
	docker tag $(USER)-ubuntu $(DOCKERHUB_ACCOUNT)/ubuntu
	docker push $(DOCKERHUB_ACCOUNT)/ubuntu

update-secrets:
	# Update secrets from our AWS file so we can access S3 in k8s
	kubectl delete secrets/$(USER)-aws-credentials
	kubectl create secret generic $(USER)-aws-credentials --from-file=../.aws/credentials

create-pod:
	# Create a pod 
	envsubst < pod.yml | kubectl create -f -
	kubectl wait --for=condition=Ready pod/$(USER)-pod --timeout=5m

list-pods:
	# List all pods
	kubectl get pods

delete-pod:
	# Delete a pod
	kubectl delete pod/$(USER)-pod

shell-pod:
	# Open a shell on the pod
	kubectl exec -it $(USER)-pod /bin/bash

aws-ls:
	# Sample command to access AWS on pod/job
	aws --profile $AWS_PROFILE --endpoint $AWS_S3_ENDPOINT s3 ls s3://braingeneers/archive/derived/
