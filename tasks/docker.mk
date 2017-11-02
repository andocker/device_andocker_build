#######
## system root docker image
define build-systemrootdockerimage-target
  $(call pretty,"Target system-root docker image: $(PRIVATE_DOCKER_IMAGE)")
  $(hide) [ ! -d "$(PRIVATE_INTERMEDIATES_DIR)" ] || rm -rf "$(PRIVATE_INTERMEDIATES_DIR)"; \
    mkdir -p "$(PRIVATE_INTERMEDIATES_DIR)"; \
    cp -f $< "$(PRIVATE_INTERMEDIATES_DIR)"; \
    cd "$(PRIVATE_INTERMEDIATES_DIR)"; \
    echo "FROM scratch" > Dockerfile; \
    echo "ADD $(notdir $(INSTALLED_SYSTEMROOTTARBALL_TARGET)) /" >> Dockerfile; \
    $(foreach e,$(PRIVATE_ENVVARS),echo "ENV $(e)=\"$(PRIVATE_ENV_$(e))\"" >> Dockerfile;) \
    $(foreach v,$(PRIVATE_VOLUMES),echo "VOLUME $(v)" >> Dockerfile;) \
    echo 'ENTRYPOINT [$(PRIVATE_ENTRYPOINT)]' >> Dockerfile; \
    docker build --tag $(PRIVATE_DOCKER_IMAGE) .
endef

intermediates := $(call intermediates-dir-for,PACKAGING,systemrootdockerimage)

.PHONY: systemrootdockerimage
systemrootdockerimage: PRIVATE_DOCKER_IMAGE := $(if $(TARGET_DOCKER_IMAGE),$(TARGET_DOCKER_IMAGE),andocker/$(TARGET_DEVICE):$(TARGET_BUILD_VARIANT)-$(BUILD_ID))
systemrootdockerimage: PRIVATE_INTERMEDIATES_DIR := $(intermediates)
systemrootdockerimage: PRIVATE_ENVVARS := $(BOARD_DOCKER_ENVVARS)
$(foreach e,$(BOARD_DOCKER_ENVVARS), \
  $(eval systemrootdockerimage: PRIVATE_ENV_$(e) := $(BOARD_DOCKER_ENV_$(e))))
systemrootdockerimage: PRIVATE_VOLUMES := $(BOARD_DOCKER_VOLUMES)
systemrootdockerimage: PRIVATE_ENTRYPOINT := $(BOARD_DOCKER_ENTRYPOINT)
systemrootdockerimage: $(INSTALLED_SYSTEMROOTTARBALL_TARGET)
	$(build-systemrootdockerimage-target)

