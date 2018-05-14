#!/bin/sh
set -e

cat external/auth_dirs.inc | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\:[0-9]\{1,5\}' | tr ':' ',' | while read entry; do ipset add -exist torset $entry; done
