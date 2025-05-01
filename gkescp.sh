#!/bin/bash


source ./envs.sh

for a in "${target[@]}"; do 
  declare -n config="$a"
  pod="${config[0]}"
  ns="${config[3]}"
  break
done

echo "Connecting to cluster"

gcloud container clusters get-credentials "${config[1]}" --region "${config[2]}"  --project "$project"


get_pod=`kubectl get pods --all-namespaces | grep $pod | grep $ns | awk {'print $2'}`
total=`wc -l <<< "$get_pod"`

if [[ $total == 1 ]]; then
  if [[ "$2" == "up" ]]; then
    kubectl cp $3 $ns/$get_pod:$4
  else
    kubectl cp $ns/$get_pod:${3#/} $4
  fi
else
    select cont in $get_pod quit
    do
      case $cont in
        $pod*)
          if [[ "$2" == "up" ]]; then
            kubectl cp $3 $ns/$cont:$path
          else
            kubectl cp $ns/$cont:${3#/} $4
          fi
          break;;
      esac
    done
fi
