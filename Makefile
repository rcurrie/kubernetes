DOCKERHUB_ACCOUNT ?= "robcurrie"

build:
	# Build custom docker image
	docker build -f Dockerfile -t $(USER)-ubuntu .

debug:
	# Run and shell into our custom container
	docker run -it --rm \
		-v `pwd`:/app \
		--user=`id -u`:`id -g` \
		--entrypoint /bin/bash \
		$(USER)-ubuntu

run:
	docker run -it --rm \
		$(USER)-ubuntu -c 3

push:
	# Push our container to dockerhub for running in k8s
	docker tag $(USER)-ubuntu $(DOCKERHUB_ACCOUNT)/ubuntu
	docker push $(DOCKERHUB_ACCOUNT)/ubuntu

run-job:
	TS=`date +"%Y%m%d-%H%M%S"` envsubst < job.yml | kubectl create -f -

delete-jobs:
	# Delete jobs prefixed with USERNAME
	kubectl get jobs -o custom-columns=:.metadata.name \
		| grep '^$(USER)*' | xargs kubectl delete jobs
