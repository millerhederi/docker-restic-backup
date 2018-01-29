## Scheduled Restic Backups with Docker

A docker container for running scheduled backups using [restic](https://restic.net/).

Before building the docker image, edit the `exclude` file to set up glob patterns for any files that you wish not to backup.

Execute the following to build the docker image:
```sh
docker build -t restic-backup .
```

To create a backup that will run every day at 7 UTC, backing up the directory `/source/data/to/backup/` to `/destination/for/local/backup/`, simply execute the following to create a new running docker container:
```sh
docker run --name restic-backup-local \
    -e SLACK_WEBHOOK="https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX" \
    -e RESTIC_PASSWORD="my_password" \
    -e RESTIC_TAG="backup_full" \
    -e BACKUP_CRON="0 7 * * *" \
    -v /source/data/to/backup/:/data:ro \
    -v /destination/for/local/backup/:/mnt/restic \
    -t restic-backup
```

Another example for backing up to Backblaze B2:
```sh
docker run --name restic-backup-b2 \
    -e SLACK_WEBHOOK="https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX" \
    -e RESTIC_PASSWORD="my_password" \
    -e RESTIC_TAG="backup_full" \
    -e RESTIC_REPOSITORY="b2:my-bucket-name" \
    -e B2_ACCOUNT_ID="123456789abc" \
    -e B2_ACCOUNT_KEY="0123456789abcdef0123456789abcdef0123456789" \
    -e BACKUP_CRON="0 7 * * *" \
    -v /source/data/to/backup/:/data:ro \
    -t restic-backup
```

When backing up a a local directory, the restic repository is automatically initialized by running `restic init`, allowing for no required initial setup; however, if running a backup to a remote destination such as B2, you must manually initialize the repository by running `restic init --repo b2:my-bucket-name` or the equivalent depending on the repository. The `SLACK_WEBHOOK` environment variable is optional, see [incoming webhooks](https://api.slack.com/incoming-webhooks) for more information. Any restic options can be configured as environment variables when creating the docker container, allowing you to backup to any natively supported remote destination supported by restic.
