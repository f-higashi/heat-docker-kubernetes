#!/bin/bash

if [ -d $CUSTOM_SCRIPTS_PATH ]; then
  for i in $CUSTOM_SCRIPTS_PATH/*.sh; do
    if [ -r $i ]; then
      $i
    fi
  done
  unset i
fi
