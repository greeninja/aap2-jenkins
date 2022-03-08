#!/bin/bash

set -e

while getopts t:p:i:h:j: flag
do
    case "${flag}" in
        t) token=${OPTARG};;
        p) packages=${OPTARG};;
        i) inventory=${OPTARG};;
        h) tower=${OPTARG};;
        j) jobid=${OPTARG};;

    esac
done

echo -e "###########\n# Summary #\n###########\n"

echo "Token: $token"
echo "Packages: $packages"
echo "Inventory: $inventory"
echo "Tower Host: $tower"
echo "Job ID: $jobid"

# Check for Curl

echo -e "$(date) - Check Curl & JQ available"

if ! command -v curl &> /dev/null
then
    echo "curl could not be found or is not installed"
    exit
fi

# Check for JQ

if ! command -v jq &> /dev/null
then
    echo "jq could not be found or is not installed"
    exit
fi

echo -e "$(date) - Build data"

echo -e "$(date) - Get inventory ID from flags"
# Build Data
## Get inventory ID
invId=$(echo $inventory | grep -o -P '(?<=\{).*(?=\=)')

echo -e "$(date) - Build package array from flags"
## Build array of packages
IFS=, read -ra pkgs <<< "$packages"

echo -e "$(date) - Build JSON POST data"

## Build Post data
pos=${pkgs[-1]}
yml=$(cat << EOF
{"extra_vars":
  {"pkg_version": [
$(for i in ${pkgs[@]}; do echo "\"$i\""; if [[ $i == $pos ]]; then echo ""; else echo ","; fi; done)
]},
"inventory": $invId
}
EOF
)

 echo -e "$(date) - Confirm POST data is valid"
json=$(echo -e "$yml" | jq '.')

echo -e "$(date) - Send Start Job request"

response=$(curl -s --location --request POST "https://$tower/api/v2/job_templates/$jobid/launch/" \
  --header "Authorization: Bearer $token" \
  --header "Content-Type: application/json" \
  --header "Accept: application/json" \
  --data-raw "$(echo $json)")

echo -e "$(date) - Tower response - Job id $(echo "$response" | jq '.job')"

# Check on job function

echo -e "$(date) - Getting Job Status"
running_job=$(echo "$response" | jq '.job')
max=180
c=1
while [ $c -le $max ]; do
  sleep 10
  echo "$(date) - Check $c/180"
  check_res=$(curl -s --location --request GET "https://$tower/api/v2/jobs/$running_job/" \
    --header "Authorization: Bearer $token" \
    --header "Accept: application/json")
  failed=$(echo "$check_res" | jq '.failed')
  status=$(echo "$check_res" | jq -r '.status')
  if [[ $failed == "false" ]]; then
    echo "$(date) - Job status... $status"
    if [[ $status == "successful" ]]; then
      echo "$(date) - Job completed"
      break
    fi
  else
    echo "$(date) - Job $running_job Failed"
    echo "$(date) - Check https://$tower/#/jobs/playbook/$running_job for further information"
    echo "$(date) - Failed"
    exit 1
  fi
  c=$(( c + 1 ))
done

echo "$(date) - Success"