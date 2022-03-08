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

echo "Token: $token"
echo "Packages: $packages"
echo "Inventory: $inventory"
echo "Tower Host: $tower"
echo "Job ID: $jobid"

# Check for Curl

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

# Build Data
## Get inventory ID
invId=$(echo $inventory | grep -o -P '(?<=\{).*(?=\=)')

## Build array of packages
IFS=, read -ra pkgs <<< "$packages"

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

json=$(echo -e "$yml" | jq)

response=$(curl -s --location --request POST "https://$tower/api/v2/job_templates/$jobid/launch/" \
  --header "Authorization: Bearer $token" \
  --header "Content-Type: application/json" \
  --header "Accept: application/json" \
  --data-raw "$(echo $json)")

echo $response | jq



