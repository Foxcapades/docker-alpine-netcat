IMAGE_NAME   := foxcapades/alpine-netcat
VERSIONS     := $(shell find ./ -maxdepth 1 -type d -not -name '.*' -printf '%P ' | grep -o '[0-9.]\+')
DOCKER_FILES := $(addsuffix /Dockerfile,$(VERSIONS))

.PHONY: default
default:
	@echo "no"

.PHONY: publish
publish: $(DOCKER_FILES)

# MAIN PUBLISH
$(DOCKER_FILES): %/Dockerfile: %/alpine-tags
	@sed "s/%VERSION%/$(shell sort -Vr $< | head -n1)/" $@ > Dockerfile
	@docker build -t $(IMAGE_NAME):latest .
	@for version in $(shell sort -Vr $<); do \
	  [ -n "$$version" ] && docker image tag $(IMAGE_NAME):latest $(IMAGE_NAME):$$MAIN_VERSION; \
	done
	@docker image rm $(IMAGE_NAME):latest
	@docker image push --all-tags $(IMAGE_NAME):$(@D)
	@rm Dockerfile

# PUSH LATEST
.PHONY: publish-latest
publish-latest: LATEST_TAG = $(lastword $(sort $(VERSIONS)))
publish-latest: $(DOCKER_FILES)
	@docker image tag $(IMAGE_NAME):$(LATEST_TAG) $(IMAGE_NAME):latest
	@docker image push $(IMAGE_NAME):latest
