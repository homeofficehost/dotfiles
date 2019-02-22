#!/bin/bash

if [ $# -ne 3 ] ; then
  echo -e "Usage: \n npm-login-pass username password email"
  exit 1
fi

username=$1
password=$2
email=$3

expect << EOF
  spawn npm login $1
  expect "Username"
  send "${username}\r"
  expect "Password"
  send "${password}\r"
  expect "Email"
  send "${email}\r"
  expect eof
EOF