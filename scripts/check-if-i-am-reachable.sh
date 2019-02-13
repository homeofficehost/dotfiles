#!/bin/bash

# check if my ip is up and reachable
# - requires: curl
# - output: OK if IP is up, KO if not.
IP=`curl -s 'https://api.ipify.org'` && \
  ( curl -s "http://www.isup.me/$IP" | grep -cq "It's just you" && echo 'OK' ) || echo 'KO'