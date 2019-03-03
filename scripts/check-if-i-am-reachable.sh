#!/bin/bash

# check if my ip is up and reachable
# - requires: curl
# - output: OK if IP is up, KO if not.
IP=`curl -s 'https://api.ipify.org'` && \
  ( curl -s "https://downforeveryoneorjustme.com/$IP" | grep -cq "It's just you" && echo 'yes' ) || echo 'no'
