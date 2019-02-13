#!/bin/bash

a=$(/usr/sbin/ioreg -c IOHIDSystem | /usr/bin/awk '/HIDIdleTime/ {print int($NF/1000000000); exit}')
b=100
	if [ "$a" -gt "$b" ]

if [ -z "$String" ]
then
  echo "\$Start."
else
  echo "\$Stop."
fi
