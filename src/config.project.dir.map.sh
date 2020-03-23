#!/bin/sh

THIS_FILE_PATH=$(
  cd $(dirname $0)
  pwd
)
source "$THIS_FILE_PATH/sh-lib-path-resolve.sh"

PROJECT_PATH=$(path_resolve "$THIS_FILE_PATH" "../")
SRC_PATH=$(path_resolve "$PROJECT_PATH" "src")
NOTE_PATH=$(path_resolve "$PROJECT_PATH" "note")
BUILD_PATH=$(path_resolve "$PROJECT_PATH" "build")
PACKAGE_PATH=$(path_resolve "$PROJECT_PATH" "packages")
