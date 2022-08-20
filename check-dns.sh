#!/bin/bash

cd /tmp

# Check if old dns file exists
if [ -e /tmp/dnsold_$1 ]
then
    # Get dns resolution and store in new file
    host $1 | grep address | awk '{print $NF}' | sort | uniq | xargs echo > /tmp/dnsnew_$1

    # Check if dns resolution worked
    if [ $? -ne 0 ]
    then
        curl -H "Content-Type: application/json" -d "{\"username\": \"$MACHINE_NAME\", \"content\": \"DNS resolution failed for $1\"}" $DISCORD_WEBHOOK

    else
        # Compare old and new dns files
        cmp -s /tmp/dnsold_$1 /tmp/dnsnew_$1

        # If dns resolution changed, send notification to discord
        if [ $? -ne 0 ]
        then
            dnsold=$(<dnsold_$1)
            dnsnew=$(<dnsnew_$1)
            curl -H "Content-Type: application/json" -d "{\"username\": \"$MACHINE_NAME\", \"content\": \"DNS resolution changed for $1 \n old: \`$dnsold\` \n new: \`$dnsnew\`\"}" $DISCORD_WEBHOOK
        fi

        # Copy new dns file to old dns file
        cp /tmp/dnsnew_$1 /tmp/dnsold_$1
    fi

else
    # Get dns resolution and store in old file
    host $1 | grep address | awk '{print $NF}' | sort | uniq | xargs echo > /tmp/dnsold_$1

    # Check if dns resolution worked
    if [ $? -ne 0 ]
    then
        curl -H "Content-Type: application/json" -d "{\"username\": \"$MACHINE_NAME\", \"content\": \"DNS resolution failed for $1\"}" $DISCORD_WEBHOOK

    else
        curl -H "Content-Type: application/json" -d "{\"username\": \"$MACHINE_NAME\", \"content\": \"DNS resolution check started for $1\"}" $DISCORD_WEBHOOK
    fi
fi
