#!/bin/bash
# find-and-do.sh
# find . -name "${1}" -exec echo {} \; -exec echo {} \;

find . -maxdepth 2 -mindepth 2 -name "${1}" -type f | while read line
do
	# eval "${@:2} ${1}"
	eval "echo "------ ${line} ------"; cat ${line} | jq '.scripts'"
done