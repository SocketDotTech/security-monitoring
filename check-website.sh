#!/bin/bash

cd /tmp

# Check if old hash file exists
if [ -e /tmp/hashold_$1 ]
then
    # download website
    wget -r -k -l 7 -p -E -nc -nv https://$1/ 1>&2 2>/dev/null || true

    # Get website hash and store in new file
    find $1 -type f | grep -v robots.txt | xargs md5sum | md5sum | cut -d\  -f1 > /tmp/hashnew_$1

    # Check if website hash generation worked
    if [ $? -ne 0 ]
    then
        curl -H "Content-Type: application/json" -d "{\"username\": \"$MACHINE_NAME\", \"content\": \"Website content hash failed for $1\"}" $DISCORD_WEBHOOK

    else
        # Compare old and new website hash files
        cmp -s /tmp/hashold_$1 /tmp/hashnew_$1

        # If website hash changed, send notification to discord
        if [ $? -ne 0 ]
        then
            hashold=$(<hashold_$1)
            hashnew=$(<hashnew_$1)
            curl -H "Content-Type: application/json" -d "{\"username\": \"$MACHINE_NAME\", \"content\": \"Website content hash changed for $1 \n old: \`$hashold\` \n new: \`$hashnew\`\"}" $DISCORD_WEBHOOK
        fi

        # Copy new website hash file to old website hash file
        cp /tmp/hashnew_$1 /tmp/hashold_$1
    fi

else
    # download website
    wget -r -k -l 7 -p -E -nc -nv https://$1/ 1>&2 2>/dev/null || true

    # Get website hash and store in old file
    find $1 -type f | grep -v robots.txt | xargs md5sum | md5sum | cut -d\  -f1 > /tmp/hashold_$1

    # Check if website hash generation worked
    if [ $? -ne 0 ]
    then
        curl -H "Content-Type: application/json" -d "{\"username\": \"$MACHINE_NAME\", \"content\": \"Website content hash failed for $1\"}" $DISCORD_WEBHOOK

    else
        curl -H "Content-Type: application/json" -d "{\"username\": \"$MACHINE_NAME\", \"content\": \"Website content hash check started for $1\"}" $DISCORD_WEBHOOK
    fi
fi
