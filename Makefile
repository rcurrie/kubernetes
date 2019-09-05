build:
	# Build custom docker image
	docker build -f Dockerfile -t $(USER)-ubuntu .

debug:
	# Run our image with the local version of the app and shell into it
	docker run -it --rm \
		-v `pwd`:/app \
		--user=`id -u`:`id -g` \
		--entrypoint /bin/bash \
		$(USER)-ubuntu

run:
	# Run the container locally with the app from the image
	docker run -it --rm \
		$(USER)-ubuntu -c 3 foobar

push:
	# Push our container to dockerhub for running in k8s
	docker tag $(USER)-ubuntu $(DOCKERHUB_ACCOUNT)/ubuntu
	docker push $(DOCKERHUB_ACCOUNT)/ubuntu

run-job:
	# Run a kubernetes job with our container, prefix with USERNAME and timestamp
	TS=`date +"%Y%m%d-%H%M%S"` envsubst < job.yml | kubectl create -f -

delete-my-jobs:
	# Delete jobs prefixed with USERNAME
	kubectl get jobs -o custom-columns=:.metadata.name \
		| grep '^$(USER)*' | xargs kubectl delete jobs
