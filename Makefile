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
	# Run the image in a container locally
	docker run -it --rm \
		$(USER)-ubuntu -c 3 foobar

push:
	# Push our image to dockerhub for running in k8s
	docker tag $(USER)-ubuntu $(DOCKERHUB_ACCOUNT)/ubuntu
	docker push $(DOCKERHUB_ACCOUNT)/ubuntu

run-job:
	# Run a kubernetes job with our image, prefix with USERNAME and timestamp
	TS=`date +"%Y%m%d-%H%M%S"` envsubst < job.yml | kubectl create -f -

delete-my-jobs:
	# Delete jobs prefixed with USERNAME
	kubectl get jobs -o custom-columns=:.metadata.name \
		| grep '^$(USER)*' | xargs kubectl delete jobs

update-secrets:
	# Update secrets from our AWS file so we can access S3 in k8s
	kubectl delete secrets/shared-s3-credentials
	kubectl create secret generic shared-s3-credentials --from-file=credentials=../cgl-shared-s3-credentials
