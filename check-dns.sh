#!/bin/bash

cd /tmp

if [ -e /tmp/hashold_$1 ]
then
    host $1 | grep address | awk '{print $NF}' | sort | uniq | xargs echo > /tmp/dnsnew_$1

    if [ $? -ne 0 ]
    then
        curl -H "Content-Type: application/json" -d "{\"username\": \"$MACHINE_NAME\", \"content\": \"DNS resolution failed for $1\"}" $DISCORD_WEBHOOK

    else
        cmp -s /tmp/dnsold_$1 /tmp/dnsnew_$1
        if [ $? -ne 0 ]
        then
            dnsold=$(<dnsold_$1)
            dnsnew=$(<dnsnew_$1)
            curl -H "Content-Type: application/json" -d "{\"username\": \"$MACHINE_NAME\", \"content\": \"DNS resolution changed for $1 \n old: \`$dnsold\` \n new: \`$dnsnew\`\"}" $DISCORD_WEBHOOK
        fi
        cp /tmp/dnsnew_$1 /tmp/dnsold_$1
    fi

else
    host $1 | grep address | awk '{print $NF}' | sort | uniq | xargs echo > /tmp/dnsold_$1

    if [ $? -ne 0 ]
    then
        curl -H "Content-Type: application/json" -d "{\"username\": \"$MACHINE_NAME\", \"content\": \"DNS resolution failed for $1\"}" $DISCORD_WEBHOOK

    else
        curl -H "Content-Type: application/json" -d "{\"username\": \"$MACHINE_NAME\", \"content\": \"DNS resolution check started for $1\"}" $DISCORD_WEBHOOK
    fi
fi
