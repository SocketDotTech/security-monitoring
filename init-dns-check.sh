#!/bin/bash

cd /tmp

host $1 | grep address | awk '{print $NF}' | sort | uniq | xargs echo > /tmp/dnsold_$1
