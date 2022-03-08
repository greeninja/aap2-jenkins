#!/bin/bash

while getopts t:p:i: flag
do
    case "${flag}" in
        t) token=${OPTARG};;
        p) packages=${OPTARG};;
        i) inventory=${OPTARG};;
    esac
done

echo "Token: $token"
echo "Packages: $packages"
echo "Inventory: $inventory"

