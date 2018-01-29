FROM alpine:3.7

ENV BACKUP_CRON="* * * * *"
ENV SLACK_WEBHOOK=""

ENV RESTIC_TAG=""
ENV RESTIC_REPOSITORY=/mnt/restic
ENV RESTIC_PASSWORD="password"

RUN apk add --no-cache ca-certificates wget unzip curl \
  && update-ca-certificates
RUN wget https://github.com/restic/restic/releases/download/v0.8.1/restic_0.8.1_linux_amd64.bz2 \
  && bzip2 -d restic_0.8.1_linux_amd64.bz2 \
  && chmod +x restic_0.8.1_linux_amd64 \
  && mv restic_0.8.1_linux_amd64 /usr/local/bin/restic

RUN mkdir /mnt/restic

VOLUME /data
VOLUME /mnt/restic

COPY exclude /etc/restic/exclude

COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

COPY entry.sh /entry.sh

RUN touch /var/log/cron.log \
  && touch /var/lock/restic.lock

WORKDIR "/"

ENTRYPOINT [ "/entry.sh" ]
