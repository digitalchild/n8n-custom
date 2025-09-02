#!/bin/bash
# Set paths explicitly for cron
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Define backup directory (adjust this path)
BACKUP_DIR="/opt/apps/n8n/backups"
mkdir -p "$BACKUP_DIR"

# Create backup with timestamp
BACKUP_NAME="n8n-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
echo "$(date): Creating backup: $BACKUP_NAME" >> "$BACKUP_DIR/backup.log"

docker run --rm \
  -v n8n_n8n-data:/data \
  -v "$BACKUP_DIR":/backup \
  alpine tar czf /backup/$BACKUP_NAME -C /data .

if [ $? -eq 0 ]; then
    echo "$(date): Backup completed: $BACKUP_NAME" >> "$BACKUP_DIR/backup.log"
    # Keep only last 7 backups
    cd "$BACKUP_DIR" && ls -t n8n-backup-*.tar.gz | tail -n +8 | xargs -r rm --
else
    echo "$(date): Backup failed!" >> "$BACKUP_DIR/backup.log"
fi