#!/bin/sh
cat external/auth_dirs.inc | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | while read entry; do wget --timeout=10 $entry/tor/status-vote/current/consensus && break ; done
