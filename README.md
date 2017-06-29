# Docker ECS 
This project provides a Dockerized ECS agent for launching an auto scaling group EC2 Container Service cluster using [Cloud Compose](http://github.com/cloud-compose).

# Quick Start
To use this project do the following:

1. Create a new Github repo for your configuration (e.g. `my-configs`)
1. Create a directory for ecs (e.g. `mkdir my-configs/ecs`)
1. Create a sub-directory for your cluster (e.g. `mkdir my-configs/ecs/foobar`)
1. Clone this project into your Github repo using [subtree merge](#initial-subtree-merge)
1. Copy the docker-ecs/cloud-compose/cloud-compose.yml.example to your cluster sub-directory
1. Rename to cloud-compose.yml and modify to fit your needs
1. Create a new cluster using the [Cloud Compose cluster plugin](https://github.com/cloud-compose/cloud-compose-cluster).
```
pip install cloud-compose cloud-compose-cluster
pip freeze > requirements.txt
cloud-compose cluster up
```
1. Once the cluster is up, monitor its health using the [Cloud Compose datadog plugin](https://github.com/cloud-compose/cloud-compose-datadog).
```
pip install cloud-compose-datadog
cloud-compose datadog monitors up
```

# FAQ
## How do I manage secrets?

The preferred method for managing secrets is to store the encrypted secrets in the `cluster.secrets` object. KMS decryption is built-in to cloud-compose. Simply add your secrets to the secrets section of the cloud-compose.yml and then add the grant Decrypt permissions on the KMS key to the instance_profile section.

```
cluster
  secrets:
    ECS_ENGINE_AUTH_DATA: "AQECAHgq..."
  instance_policy: '{ "Statement": [ { "Action": [ "ec2:CreateSnapshot", "ec2:CreateTags", "ec2:DeleteSnapshot", "ec2:DescribeInstances", "ec2:DescribeSnapshotAttribute", "ec2:DescribeSnapshots", "ec2:DescribeVolumeAttribute", "ec2:DescribeVolumeStatus", "ec2:DescribeVolumes", "ec2:ModifySnapshotAttribute", "ec2:ResetSnapshotAttribute", "logs:CreateLogStream", "logs:PutLogEvents" ], "Effect": "Allow", "Resource": [ "*" ] }, { "Action": ["kms:Decrypt"], "Effect": "Allow", "Resource": ["arn:aws:kms:us-east-1:111111111111:key/22222222-2222-2222-2222-222222222222"] } ] }'
```

Secrets can also be configured using environment variables. [Envdir](https://pypi.python.org/pypi/envdir) is highly recommended as a tool for switching between sets of environment variables in case you need to manage multiple clusters.

If you are using a private Docker registry you also need to set ECS_ENGINE_AUTH_DATA and ECS_ENGINE_AUTH_TYPE. See the ECS Agent [configuration guide](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-config.html) for more details. If you are using the datadog plugin you will also need DATADOG_API_KEY and DATADOG_APP_KEY.

At a minimum you will need AWS_ACCESS_KEY_ID, AWS_REGION, and AWS_SECRET_ACCESS_KEY.  We recommend storing AWS authentication secrets only in the environment.

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
# pull in the git remote, but don't commit it. --allow-unrelated-histories is required for git 2.9+
git merge -s ours --no-commit --allow-unrelated-histories docker-ecs/master
# make a directory to merge the changes into
mkdir docker-ecs
# actually do the merge. note prefix specified the path from the root of the repository
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

