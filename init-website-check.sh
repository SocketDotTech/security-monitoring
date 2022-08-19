#!/bin/bash

cd /tmp

wget -r -k -l 7 -p -E -nc -nv https://$1/ 1>&2 2>/dev/null || true

find $1 -type f | grep -v robots.txt | xargs md5sum | md5sum | cut -d\  -f1 > /tmp/hashold_$1
