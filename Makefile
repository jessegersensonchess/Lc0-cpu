.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

OWNER=chess
SERVICE=lc0-cpu
# it will take short hash (first 7 symbols) of last git commit.
# Then, we export this variable, so it’s available in commands run by make.
#TAG=$(git rev-list HEAD --max-count=1 --abbrev-commit)
TAG=latest
export TAG

build:	## Build docker image
	docker build -t ${OWNER}/${SERVICE}:$(TAG) \
        --build-arg VCS_REF=`git rev-parse --short HEAD` \
        --build-arg VCS_URL=`git config --get remote.origin.url` \
        --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
        .
run:	## Run built docker image
	docker run -i --rm -v /data/tablebases:/data/tmptablebases ${OWNER}/${SERVICE}:$(TAG)
prune:	## Remove all currently not-running docker images
	docker system prune -af
