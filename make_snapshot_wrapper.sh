#!/bin/sh

logger -t snapshot "Starting backup snapshot"
nocache ionice -c2 -n5 /usr/local/bin/make_snapshot.sh
logger -t snapshot "Completed backup snapshot"
