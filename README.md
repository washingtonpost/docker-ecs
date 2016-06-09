# Docker ECS 
This project provides a Dockerized ECS agent for launching an auto scaling group EC2 Container Service cluster using [Cloud Compose](http://github.com/cloud-compose).

# Quick Start
To use this project do the following:

1. Create a new Github repo for your configuration (e.g. `my-configs`)
1. Create a directory for ecs (e.g. `mkdir my-configs/ecs`)
1. Create a sub-directory for your cluster (e.g. `mkdir my-configs/ecs/foobar`)
1. Clone this project into your Github repo using subtree merge
1. Copy the docker-ecs/cloud-compose/cloud-compose.yml.example to your cluster sub-directory
1. Modify the cloud-compose.yml to fit your needs
1. Create a new cluster using the [Cloud Compose cluster plugin](https://github.com/cloud-compose/cloud-compose-cluster).
```
pip install cloud-compose cloud-compose-cluster
pip freeze -r > requirements.txt
cloud-compose cluster up
```

# FAQ
## How do I manage secrets?
Secrets can be configured using environment variables. [Envdir](https://pypi.python.org/pypi/envdir) is highly recommended as a tool for switching between sets of environment variables in case you need to manage multiple clusters.
At a minimum you will need AWS_ACCESS_KEY_ID, AWS_REGION, and AWS_SECRET_ACCESS_KEY. If you are using a private Docker registry you also need to set ECS_ENGINE_AUTH_DATA and ECS_ENGINE_AUTH_TYPE. See the ECS Agent [configuration guide](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-config.html) for more details.

## How do I share config files?
Since most of the config files are common between clusters, it is desirable to directly share the configuration between projects. The recommend directory structure is to have docker-ecs sub-directory and then a sub-directory for each cluster. For example if I had a test and prod cluster my directory structure would be:

```
ecs/
  docker-ecs/cloud-compose/templates/
  test/cloud-compose.yml
  prod/cloud-compose.yml
  templates/
```

The docker-ecs directory would be a subtree merge of this Git project, the templates directory would be any common templates that only apply to your clusters, the the test and prod directories have the cloud-compose.yml files for your two clusters. Regardless of the directory structure, make sure the search_paths in your cloud-compose.yml reflect all the config directories and the order that you want to load the config files.

## How do I create a subtree merge of this project?
A subtree merge is an alternative to a Git submodules for copying the contents of one Github repo into another. It is easier to use once it is setup and does not require any special commands (unlike submodules) for others using your repo.

### Initial subtree merge
To do the initial merge you will need to create a git remote, then merge it into your project as a subtree and commit the changes

```bash
# change to the cluster sub-directory
cd my-configs/ecs
# add the git remote
git remote add -f docker-ecs git@github.com:washingtonpost/docker-ecs.git
# pull in the git remote, but don't commit it
git merge -s ours --no-commit docker-ecs/master
# make a directory to merge the changes into
mkdir docker-ecs
# actually do the merge
git read-tree --prefix=ecs/docker-ecs/ -u docker-ecs/master
# commit the changes
git commit -m 'Added docker-ecs subtree'
```

### Updating the subtree merge
When you want to update the docker-ecs subtree use the git pull with the subtree merge strategy

```bash
# Add the remote if you don't already have it
git remote add -f docker-ecs git@github.com:washingtonpost/docker-ecs.git
# do the subtree merge again
git pull -s subtree docker-ecs master
```

