# GKE Custom SSH Script

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

This will be sourced into `gkessh.sh` and then script will check the number pods. If there's only one pod, it will directly exec you into the pod. If there are more than one pods, it will list out all the pods for you to select.

```bash
 ./gkessh nginx
```

If you face any issues with the permissions, please run `chmod +x script.sh`