#!/bin/sh
THIS_FILE_PATH=$(
  cd $(dirname $0)
  pwd
)

# import base lib
source "$THIS_FILE_PATH/sh-lib-path-resolve.sh"
source "$THIS_FILE_PATH/config.project.dir.map.sh"
source "$THIS_FILE_PATH/k8s-config.sh"

source "$THIS_FILE_PATH/init-k8s-stack-master.sh"
