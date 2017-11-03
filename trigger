#!/bin/bash

config=`pwd`/ci.config
log=`pwd`/ci.log

eval set -- $(getopt -l "config: log:" -o "c: l:" -- "$@")
while [ $# -ge 1 ]; do
  case "$1" in
    --)
      shift
      break
      ;;
    -c|--config)
      config="$2"
      shift
      ;;
    -l|--log)
      log="$2"
      shift
      ;;
  esac
  shift
done

function ci_bootstrap {
  return 0
}

function ci_update {
  return 0
}

function ci_analyse {
  return 0
}

function ci_build {
  return 0
}

function ci_unit_test {
  return 0
}

function ci_deploy {
  return 0
}

function ci_test {
  return 0
}

function ci_archive {
  return 0
}

function ci_report {
  return 0
}

function ci_error {
  return 0
}

. $config &&\
  ( \
  ci_bootstrap &&\
  ci_update &&\
  ci_analyse &&\
  ci_build &&\
  ci_unit_test &&\
  ci_deploy &&\
  ci_test &&\
  ci_archive &&\
  ci_report || ci_error
  ) 1>>$log 2>&1
