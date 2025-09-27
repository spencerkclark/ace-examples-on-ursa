ACE_REPOSITORY=https://github.com/ai2cm/ace.git
ENVIRONMENT_NAME ?= fme

install:
	git clone $(ACE_REPOSITORY) && cd ace && ENVIRONMENT_NAME=$(ENVIRONMENT_NAME) make create_environment
