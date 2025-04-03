#!/bin/bash

# Define arrays of envs with names of the workloads/deployments

test=( "nginx" "httpd" )

if [[ " ${test[@]} " =~ " $1 " ]]; then
  project=test-project
  #else
    # if you have more projects, add here accordingly
fi

# List all the workloads in the same format. Add cluster, region, project and namespace accordingly
case "$1" in 

  nginx)
    declare -a nginx=("nginx" "my-gke-cluster" "us-west1-a" "default")
    declare -a target=("nginx")
  ;;

  httpd)
    declare -a httpd=("simple-web-app" "my-gke-cluster" "us-west1-a" "default")
    declare -a target=("httpd")
  ;;

  *)
    echo "Looks like that doesn't exist! Sorry!!"
    exit 1
  ;;
esac