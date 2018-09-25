#!/usr/bin/env bash

source config.sh
source helpers.sh

while true; do
    read -p "Are you sure to remove all builds and the checkout?" yn
    case $yn in
        [Yy]* ) cleanup; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

