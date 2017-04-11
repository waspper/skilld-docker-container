# skilld-docker-container

---

* [Overview](#overview)
* [Instructions](#instructions)
* [Usage](#usage)

## Overview

This env provide simple docker based env to raise up your new or existing project.
There is no any build or reinstall process. All things should be done manually.
Available services:
* php-fpm to process php scenario (supported PHP versions: 7.x and 5.6.x)
* mysql to store your db
* nginx web server
* mailhog mail manager to catch and check project emails

For more details check `docker-compose.override.yml` and `docker-compose.override.yml` files


## Instructions

1\. Install docker for <a href="https://docs.docker.com/engine/installation/" target="_blank">Linux</a>, <a href="https://docs.docker.com/engine/installation/mac" target="_blank">Mac OS X</a> or <a href="https://docs.docker.com/engine/installation/windows" target="_blank">Windows</a>. __For Mac and Windows make sure you're installing native docker app version 1.12, not docker toolbox.__

For Linux install <a href="https://docs.docker.com/compose/install/" target="_blank">docker compose</a>

2\. Copy __\.env\.default__ to __\.env__.

  2\.1\. Set _COMPOSE_PROJECT_NAME_ variables with values you need.

  2\.2\. Change _PHP_VERSION_ in case you need another one.

3\. Copy __docker-compose\.override\.yml\.default__ to __docker-compose\.override\.yml__.

  This file is used to overwrite container settings and/or add your own. See https://docs.docker.com/compose/extends/#/understanding-multiple-compose-files for details.

4\. Prepare your project.

  4\.1\. Put your project files to __docroot__ folder.

  4\.2\. Load project DB to mysql container if it need.

  4\.3\. Adjust project config files.

5\. Run `make`.

## Usage

* `make` - raise up project environment.
* `make clean` - totally stop and remove docker containers and network (project volumes: files, db, etc will be saved in proper folders).
* `make info` - Show project services IP addresses.
* `make chown` - Change permissions inside container. Use it in case you can not access files in _docroot_. folder from your machine.
* `make exec` - docker exec into php container.
