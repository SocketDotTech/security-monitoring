#!/bin/bash

# Check for required input
if [ -z "$1" ]; then
    echo "Domain not provided!"
    exit 1
fi

TMP_DIR="/tmp"
HASH_OLD="${TMP_DIR}/hashold_$1"
HASH_NEW="${TMP_DIR}/hashnew_$1"

# Function to send Discord alert
send_alert() {
    curl -H "Content-Type: application/json" -d "{\"username\": \"$MACHINE_NAME\", \"content\": \"$1\"}" $DISCORD_WEBHOOK
}

retry=5

while [ $retry -gt 0 ]; do
    # Download the website
    wget -r -k -l 7 -p -E -nc -nv --timeout=5 https://$1/ -P $TMP_DIR 1>&2 2>/dev/null

    if [ $? -ne 0 ]; then
        ((retry--))
        if [ $retry -eq 0 ]; then
            send_alert "Failed to download website for $1 after multiple attempts"
            exit 1
        fi
        sleep 5
        continue
    fi

    # Generate website hash
    find ${TMP_DIR}/$1 -type f | grep -v robots.txt | xargs md5sum | md5sum | cut -d\  -f1 > $HASH_NEW

    if [ $? -ne 0 ]; then
        ((retry--))
        if [ $retry -eq 0 ]; then
            send_alert "Website content hash generation failed for $1 after multiple attempts"
            exit 1
        fi
        sleep 5
        continue
    fi

    # If old hash doesn't exist, this is the first run
    if [ ! -e $HASH_OLD ]; then
        cp $HASH_NEW $HASH_OLD
        send_alert "Website content hash check started for $1"
        exit 0
    fi

    # Compare old and new hashes
    if ! cmp -s $HASH_OLD $HASH_NEW; then
        ((retry--))
        if [ $retry -eq 0 ]; then
            hashold=$(<$HASH_OLD)
            hashnew=$(<$HASH_NEW)
            send_alert "Website content hash changed for $1 \n old: \`$hashold\` \n new: \`$hashnew\` after multiple checks"
            cp $HASH_NEW $HASH_OLD
            exit 0
        fi
        sleep 5
        continue
    fi

    # If no problems, break out of loop
    break
done
