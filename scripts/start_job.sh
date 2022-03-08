#!/bin/bash

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


curl -x POST "https://$tower/api/v2/job_templates/$jobid/launch/" \
  --header "Authorization: Bearer $token" \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  --data-raw '{
  "extra_vars": {
    "pkg_version": [
      "greenweb/greenweb-1-3.x86_64.rpm",
      "redweb/redweb-1-1.x86_64.rpm"
    ]
  },
  "inventory": 2
}'

