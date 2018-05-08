#!/bin/sh
cat external/fallback.whitelist | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\:[0-9]\{1,5\}' | tr ':' ',' | while read entry; do ipset add torset $entry; done
