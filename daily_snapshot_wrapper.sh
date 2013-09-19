#!/bin/sh

logger -t snapshot "Starting daily snapshot"
nocache ionice -c2 -n5 /usr/local/bin/daily_snapshot_rotate.sh
logger -t snapshot "Completed daily snapshot"
