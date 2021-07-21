#!/bin/bash -eo pipefail

for ORB in src/*; do
  echo "Validating $ORB ..."
  circleci orb validate $ORB
  exit_code=$?
  if [ $exit_code != 0 ]; then
    echo "There was an error validating $ORB" 1>&2
    exit $exit_code
  fi
done
