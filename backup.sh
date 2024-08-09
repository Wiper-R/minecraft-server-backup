#!/usr/bin/env bash

BACKUP_DIR="$PWD"
SERVER_DIR="$HOME/minecraft-server"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

mkdir -p "$BACKUP_DIR"

list_backups() {
    echo "Available Backups:"
    find "$BACKUP_DIR" -maxdepth 1 -type d -name "????-??-??_??-??-??" -printf "%f\n" 2>/dev/null | sort -r
}

create_backup() {
    echo "Creating a backup of the current server state..."
    LAST_BACKUP=$(find "$BACKUP_DIR" -maxdepth 1 -type d -name "????-??-??_??-??-??" -printf "%f\n" 2>/dev/null | sort -r | head -n 1)
    LAST_BACKUP_PATH=""
    if [ -n "$LAST_BACKUP" ]; then
        LAST_BACKUP_PATH="$BACKUP_DIR/$LAST_BACKUP"
    fi

    BACKUP_COMMAND="rsync -av --delete $SERVER_DIR/ $BACKUP_DIR/$TIMESTAMP/"
    if [ -n "$LAST_BACKUP_PATH" ]; then
        BACKUP_COMMAND="$BACKUP_COMMAND --link-dest=$LAST_BACKUP_PATH/"
    fi

    echo "Executing command: $BACKUP_COMMAND"
    eval "$BACKUP_COMMAND"
    echo "Backup created."
}

restore_backup() {
    local backup_name="$1"
    local restore_path="$BACKUP_DIR/$backup_name"

    echo "$restore_path"
    if [ -d "$restore_path" ]; then
        echo "Creating backup before restoring..."
        create_backup
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

create_backup
