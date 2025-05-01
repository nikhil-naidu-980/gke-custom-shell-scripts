# GKE Custom Scripts

This repo contains a custom shell script which will help you to exec into a GKE  pod.

## Prerequisites

Before using this repository, ensure that you have the following:

- **Google Cloud account** with the appropriate permissions.
- **Google Cloud SDK** installed and authenticated. Follow [Google Cloud SDK installation instructions](https://cloud.google.com/sdk/docs/install).
- **kubectl** latest version.

## Setup and Usage

Create `envs.sh` file with the workloads information in the following format. For ref, check the file in this repo

```bash
  nginx)
    declare -a nginx=("nginx" "my-gke-cluster" "us-west1-a" "default")
    declare -a target=("nginx")
  ;;
  env)
    declare -a var=("var")
  ;;
```

## SSH script

The `envs.sh` will be sourced into `gkessh.sh` and then script will check the number pods. If there's only one pod, it will directly exec you into the pod. If there are more than one pods, it will list out all the pods for you to select.

```bash
 ./gkessh nginx
```

## SCP script

This script can be used to copy the files from local to container and vice versa.

```bash
 ./gkescp nginx up test.txt /tmp/test.txt
 ./gkescp nginx down /tmp/test.txt test.txt
```

If you face any issues with the permissions, please run `chmod +x script.sh`


