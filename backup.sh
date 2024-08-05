#!/usr/bin/env bash

BACKUP_DIR="$HOME/mc-backup"
SERVER_DIR="$HOME/minecraft-server"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

mkdir -p "$BACKUP_DIR"

list_backups() {
    echo "Available Backups:"
    find "$BACKUP_DIR" -maxdepth 1 -type d -name "????-??-??_??-??-??" -printf "%f\n" 2>/dev/null | sort -r
}

restore_backup() {
    local backup_name="$1"
    local restore_path="$BACKUP_DIR/$backup_name"

    echo "$restore_path"
    if [ -d "$restore_path" ]; then
        echo "Restoring from backup: $restore_path"
        rsync -av "$restore_path/" "$SERVER_DIR/"
        echo "Restore Complete."
    else
        echo "Backup $backup_name does not exist."
        exit 1
    fi 
}

while getopts "lr:" opt; do
    case ${opt} in 
        l)
            list_backups
            exit 0
            ;;
        r)
            restore_backup "$OPTARG"
            exit 0
            ;;
        \?)
            echo "Usage: $0 [-l] [-r backup_name]"
            exit 1
            ;;
    esac
done

LAST_BACKUP=$(find "$BACKUP_DIR" -maxdepth 1 -type d -name "????-??-??_??-??-??" -printf "%f\n" 2>/dev/null | sort -r | head -n 1)

if [ -n "$LAST_BACKUP" ]; then
    LAST_BACKUP_PATH="$BACKUP_DIR/$LAST_BACKUP"
else
    LAST_BACKUP_PATH=""
fi

COMMAND="rsync -av --delete $SERVER_DIR/ $BACKUP_DIR/$TIMESTAMP/"

if [ -n "$LAST_BACKUP_PATH" ]; then
    COMMAND="$COMMAND --link-dest=$LAST_BACKUP_PATH/"
fi

echo "Executing command: $COMMAND"

eval "$COMMAND"
