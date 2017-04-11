# Read project name from .env file
$(shell cp -n \.env.default \.env)
$(shell cp -n \.\/src\/docker\/docker-compose\.override\.yml\.default \.\/src\/docker\/docker-compose\.override\.yml)
include .env

# Setup PHP Variables based on package version
PHP_IMAGE=php:$(shell printf '%s' "$(PHP_VERSION)" | sed -e 's/\.//')-fpm
export PHP_IMAGE

all: | include net init info

include:
ifeq ($(strip $(COMPOSE_PROJECT_NAME)),projectname)
$(error Project name can not be default, please edit ".env" and set COMPOSE_PROJECT_NAME variable.)
endif

init:
	@echo "Updating containers..."
	docker-compose pull
	@echo "Run containers..."
	docker-compose up -d
	make -s info

info:
ifeq ($(shell docker inspect --format="{{ .State.Running }}" $(COMPOSE_PROJECT_NAME)_web 2> /dev/null),true)
	@echo Project IP: $(shell docker inspect --format='{{.NetworkSettings.Networks.$(COMPOSE_PROJECT_NAME)_front.IPAddress}}' $(COMPOSE_PROJECT_NAME)_web)
endif
ifeq ($(shell docker inspect --format="{{ .State.Running }}" $(COMPOSE_PROJECT_NAME)_mail 2> /dev/null),true)
	@echo Mailhog IP:PORT: $(shell docker inspect --format='{{.NetworkSettings.Networks.$(COMPOSE_PROJECT_NAME)_front.IPAddress}}' $(COMPOSE_PROJECT_NAME)_mail):8025
endif
ifeq ($(shell docker inspect --format="{{ .State.Running }}" $(COMPOSE_PROJECT_NAME)_adminer 2> /dev/null),true)
	@echo Adminer IP: $(shell docker inspect --format='{{.NetworkSettings.Networks.$(COMPOSE_PROJECT_NAME)_front.IPAddress}}' $(COMPOSE_PROJECT_NAME)_adminer)
endif

chown:
# Use this goal to set permissions in docker container
	docker-compose exec php /bin/sh -c "chown $(shell id -u):$(shell id -g) /var/www/html -R"
# Need this to fix files folder
	docker-compose exec php /bin/sh -c "chown www-data: /var/www/html/sites/default/files -R"

exec:
	docker exec -i -t $(COMPOSE_PROJECT_NAME)_php sh -c "cd /var/www/html/ && sh"

clean: info
	@echo "Removing networks for $(COMPOSE_PROJECT_NAME)"
ifeq ($(shell docker inspect --format="{{ .State.Running }}" $(COMPOSE_PROJECT_NAME)_php 2> /dev/null),true)
	docker-compose down;
endif

net:
ifeq ($(strip $(shell docker network ls | grep $(COMPOSE_PROJECT_NAME))),)
	docker network create $(COMPOSE_PROJECT_NAME)_front
endif
	@make -s iprange

iprange:
	$(shell grep -q -F 'IPRANGE=' .env || echo "\nIPRANGE=$(shell docker network inspect $(COMPOSE_PROJECT_NAME)_front --format '{{(index .IPAM.Config 0).Subnet}}')" >> .env)

phpcs:
	# TODO $CUSTOM_MODULES_PATH and $CUSTOM_THEMES_PATH should be properly defined.
	@echo "Checking custom code styles"
	docker run --rm -v $(shell pwd)/docroot/$(CUSTOM_MODULES_PATH):/work skilldlabs/docker-phpcs-drupal phpcs --standard=Drupal --extensions=php,module,inc,install,test,profile,theme,info .
	docker run --rm -v $(shell pwd)/docroot/$(CUSTOM_THEMES_PATH):/work skilldlabs/docker-phpcs-drupal phpcs --standard=Drupal --extensions=php,module,inc,install,test,profile,theme,info .
	docker run --rm -v $(shell pwd)/docroot/$(CUSTOM_MODULES_PATH):/work skilldlabs/docker-phpcs-drupal phpcs --standard=DrupalPractice --extensions=php,module,inc,install,test,profile,theme,info .
	docker run --rm -v $(shell pwd)/docroot/$(CUSTOM_THEMES_PATH):/work skilldlabs/docker-phpcs-drupal phpcs --standard=DrupalPractice --extensions=php,module,inc,install,test,profile,theme,info .

phpcbf:
	# TODO $CUSTOM_MODULES_PATH and $CUSTOM_THEMES_PATH should be properly defined.
	@echo "Fixing custom code styles"
	docker run --rm -v $(shell pwd)/docroot/$(CUSTOM_MODULES_PATH):/work skilldlabs/docker-phpcs-drupal phpcbf --standard=Drupal --extensions=php,module,inc,install,test,profile,theme,info .
	docker run --rm -v $(shell pwd)/docroot/$(CUSTOM_THEMES_PATH):/work skilldlabs/docker-phpcs-drupal phpcbf --standard=Drupal --extensions=php,module,inc,install,test,profile,theme,info .
	docker run --rm -v $(shell pwd)/docroot/$(CUSTOM_MODULES_PATH):/work skilldlabs/docker-phpcs-drupal phpcbf --standard=DrupalPractice --extensions=php,module,inc,install,test,profile,theme,info .
	docker run --rm -v $(shell pwd)/docroot/$(CUSTOM_THEMES_PATH):/work skilldlabs/docker-phpcs-drupal phpcbf --standard=DrupalPractice --extensions=php,module,inc,install,test,profile,theme,info .
