#!/bin/sh

if [ $RESTIC_TAG == "" ]; then
    echo "Environmental variable 'RESTIC_TAG' not configured."
    echo "Please include '-e RESTIC_TAG=tag_name' when launching the docker container using 'docker run'."
    exit 1
fi

echo "Starting backup."

(
    flock -n 200 || exit 1

    restic_command="restic backup /data --tag=${RESTIC_TAG} --exclude-file=/etc/restic/exclude"

    start=$(date +%s)
    echo "Executing => ${restic_command}"
    eval "${restic_command}"
    restic_status=$?
    end=$(date +%s)

    if [ ! $SLACK_WEBHOOK == "" ]; then
        if [ $restic_status -eq 0 ]; then
            slack_message="Backup completed successfully."
        else
            slack_message=":fire: Backup *failed* with status '${restic_status}'. :fire:"
        fi

        slack_message="${slack_message}\n\`\`\`\nREPOSITORY: ${RESTIC_REPOSITORY}\nTAG:        ${RESTIC_TAG}\nDURATION:   $((end - start)) seconds\n\`\`\`"

        # Check out https://stackoverflow.com/questions/17029902/using-curl-post-with-variables-defined-in-bash-script-functions
        curl -X POST -s -H "Content-type: application/json" \
            -d '{"username":"Restic Backup", "text":"'"${slack_message}"'"}' \
            -o /dev/null \
            ${SLACK_WEBHOOK}
    fi

    if [ $restic_status -eq 0 ]; then
        echo "Backup completed successfully."
    else
        echo "Backup failed with status '${restic_status}'."
    fi
) 200>/var/lock/restic.lock
