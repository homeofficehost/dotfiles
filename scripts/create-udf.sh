#!/usr/bin/env bash

volumeName=${1:-'Untitled'}
identifier=${2:-'disk3'}

# TODO: Detect identifier by name
diskutil list

echo "Creating UDF partition: /Volumes/$volumeName Identifier: $identifier ";
read -n 1 -s -r -p "Press any key to continue"
format-udf $identifier "${volumeName}"
# TODO: Auto unmount

#####################
# Reference:
# diskutil mount disk3
# diskutil list
#####################