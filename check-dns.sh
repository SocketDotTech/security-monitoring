#!/bin/bash

# Check for required input
if [ -z "$1" ]; then
    echo "Domain not provided!"
    exit 1
fi

TMP_DIR="/tmp"
DNS_OLD="${TMP_DIR}/dnsold_$1"
DNS_NEW="${TMP_DIR}/dnsnew_$1"

# Function to send Discord alert
send_alert() {
    curl -H "Content-Type: application/json" -d "{\"username\": \"$MACHINE_NAME\", \"content\": \"$1\"}" $DISCORD_WEBHOOK
}

retry=5

while [ $retry -gt 0 ]; do
    # Retrieve DNS resolution and store in new file
    host $1 | grep address | awk '{print $NF}' | sort | uniq | xargs echo > $DNS_NEW

    if [ $? -ne 0 ]; then
        ((retry--))
        if [ $retry -eq 0 ]; then
            send_alert "DNS resolution failed for $1 after multiple attempts"
            exit 1
        fi
        sleep 5
        continue
    fi

    # If old DNS doesn't exist, this is the first run
    if [ ! -e $DNS_OLD ]; then
        cp $DNS_NEW $DNS_OLD
        send_alert "DNS resolution check started for $1"
        exit 0
    fi

    # Compare old and new DNS resolutions
    if ! cmp -s $DNS_OLD $DNS_NEW; then
        ((retry--))
        if [ $retry -eq 0 ]; then
            dnsold=$(<$DNS_OLD)
            dnsnew=$(<$DNS_NEW)
            send_alert "DNS resolution changed for $1 \n old: \`$dnsold\` \n new: \`$dnsnew\` after multiple checks"
            cp $DNS_NEW $DNS_OLD
            exit 0
        fi
        sleep 5
        continue
    fi

    # If no problems, break out of loop
    break
done
