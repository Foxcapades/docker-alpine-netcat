IMAGE_NAME   := foxcapades/alpine-netcat
VERSIONS     := $(shell find ./ -maxdepth 1 -type d -not -name '.*' -printf '%P ' | grep -o '[0-9.]\+')
DOCKER_FILES := $(addsuffix /Dockerfile,$(VERSIONS))

.PHONY: default
default:
	@echo "no"

.PHONY: publish
publish: $(DOCKER_FILES)

.PHONY: publish-latest
publish-latest: .published
	@docker image tag $(IMAGE_NAME):$(lastword $(sort $(VERSIONS))) $(IMAGE_NAME):latest
	@docker image push $(IMAGE_NAME):latest

.published: $(DOCKER_FILES)
	@if [ ! -f $@ ]; then $(MAKE) -B publish; fi

$(DOCKER_FILES): %/Dockerfile: %/alpine-tags
	@sed "s/%VERSION%/$(shell sort -Vr $< | head -n1)/" $@ > Dockerfile
	@docker build -t $(IMAGE_NAME):latest --progress=plain .
	@for version in $(shell sort -Vr $<); do \
	  [ -n "$$version" ] && docker image tag $(IMAGE_NAME):latest $(IMAGE_NAME):$$version; \
	done
	@docker image rm $(IMAGE_NAME):latest
	@docker image push --all-tags $(IMAGE_NAME)
	@rm Dockerfile
	@touch .published
