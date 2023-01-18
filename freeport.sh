#! /bin/bash

# NEWLY ADDED BACKUP FUNCTIONALITY IS NOT FULLY TESTED YET, USE WITH CARE, ESPECIALLY DELETION
# Developed for DSM 6/7. Not tested on other versions.
# Steps to install
# Save this script in one of your shares
# Backup /usr/syno/share/nginx/ as follows:
# # cd /usr/syno/share/
# # tar cvf ~/nginx.tar nginx
# Run this script as root
# Reboot and ensure everything is still working
# If not, restore the backup and post a comment on this script's gist page
# If it did, schedule it to run at boot
#   through Control Panel -> Task Scheduler

HTTP_PORT=81
HTTPS_PORT=444

BACKUP_FILES=true # change to false to disable backups
BACKUP_DIR=/volume1/docker/freeport/backup
DELETE_OLD_BACKUPS=true # change to true to automatically delete old backups.
KEEP_BACKUP_DAYS=30
CURRENT_BACKUP_DIR="$BACKUP_DIR/$DATE"

DATE=$(date +%Y-%m-%d-%H-%M-%S)

if [ "$BACKUP_FILES" == "true" ]; then
  mkdir -p "$CURRENT_BACKUP_DIR"
  cp /usr/syno/share/nginx/*.mustache "$CURRENT_BACKUP_DIR"
fi

if [ "$DELETE_OLD_BACKUPS" == "true" ]; then
  find "$BACKUP_DIR/" -type d -mtime +$KEEP_BACKUP_DAYS -exec rm -r {} \;
fi

sed -i "s/^\([ \t]\+listen[ \t]\+[]:[]*\)80\([^0-9]\)/\1$HTTP_PORT\2/" /usr/syno/share/nginx/*.mustache
sed -i "s/^\([ \t]\+listen[ \t]\+[]:[]*\)443\([^0-9]\)/\1$HTTPS_PORT\2/" /usr/syno/share/nginx/*.mustache

echo "Made these changes:"

diff /usr/syno/share/nginx/ "$CURRENT_BACKUP_DIR" 2>&1 | tee "$CURRENT_BACKUP_DIR"/changes.log

# Perform nginx reload if running on DSM 7.X
#if grep -q 'majorversion="7"' "/etc.defaults/VERSION"; then
#  nginx -s reload
#fi
systemctl restart nginx
echo "Reloaded nginx and done"