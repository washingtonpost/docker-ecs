#!/bin/bash
{% include "cloud.environment.sh" %}
{% include "system.mounts.sh" %}
{% include "docker.config.sh" %}
{% include "docker_compose.run.sh" %}
{% include "system.network_conf.sh" %}
