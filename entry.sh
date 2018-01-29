#!/bin/sh
set -e

echo "Starting container..."

if [ "$RESTIC_REPOSITORY" == "/mnt/restic" ] && [ ! -f "$RESTIC_REPOSITORY/config" ]; then
    echo "Restic repository '${RESTIC_REPOSITORY}' does not exist. Running restic init."
    restic init
fi

echo "${BACKUP_CRON} /usr/local/bin/backup.sh >> /var/log/cron.log 2>&1" > /var/spool/cron/crontabs/root

crond

echo "Container started."

tail -fn0 /var/log/cron.log
