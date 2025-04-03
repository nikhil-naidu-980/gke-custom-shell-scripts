#!/bin/bash

source ./envs.sh

for a in "${target[@]}"; do 
  declare -n config="$a"
  pod="${config[0]}"
  ns="${config[3]}"
  break
done

gcloud container clusters get-credentials "${config[1]}" --region "${config[2]}"  --project "$project"

get_pod=`kubectl get pods --all-namespaces | grep $pod | grep $ns | awk {'print $2'}`
total=`wc -l <<< "$get_pod"`

if [[ "$total" == 1 ]]; then
  kubectl exec -it $get_pod -n $ns -- bash
else
  conatienrNum=${2}
  if [ -z "$containerNum" ]; then
    select cont in $get_pod quit
    do 
      case $cont in
        $pod*)
          kubectl exec -it $cont -n $ns -- bash ;;
        quit)
          break;;
      esac
    done 
  else 
    cont=`echo $get_pod | cut -d " " =f $containerNum`
    kubectl exec -it $cont -n $ns -- bash
  fi 
fi 
