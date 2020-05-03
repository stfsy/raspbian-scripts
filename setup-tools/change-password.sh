#!/bin/bash

declare -r PW=$1

if [ -z "$PW" ]
then
  echo "Please pass password as arg 1"
  exit 1
fi

echo -e "${PW}\n${PW}" | passwd pi
