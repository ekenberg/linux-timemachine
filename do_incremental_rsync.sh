#!/bin/bash

# Usage:
# - mount your backup target (NAS or other remote disk) somewhere in the filesystem.
# - edit CONFIGURATION below
# - edit backup_exclude.conf and keep in the same directory as this script
# - test on some smaller directory. run with -v to see verbose rsync output

# More information in the README or http://ekenberg.github.io/linux-timemachine/

# run without arguments to backup /, or supply list of directories to backup
# rsync uses --one-file-system, so if you have several filesystems under / you need to supply them all as arguments to the script

## CONFIGURATION:
BACKUP_BASE=/path/to/directory/where/backups/are/stored
BACKUP_NAME=your-computername-backup
## END CONFIGURATION

# Go to directory of this script
cd "$( dirname "$0" )"

if [ `id -u` != "0" ]; then
    echo "You need to be root (sudo) to run system backups"
    exit 1
fi

VERBOSE_ARGS=""
if [ "x$1" = "x-v" ]; then
    VERBOSE_ARGS="--progress -v"
    shift
fi

BACKUP_WHAT=("/")
if [ $# -gt 0 ]; then
	BACKUP_WHAT=("$@")
fi

TODAY=`date +"%Y-%m-%d"`

CURRENT_BACKUP="${BACKUP_BASE}/${BACKUP_NAME}-current"
NEW_BACKUP="${BACKUP_BASE}/${BACKUP_NAME}-${TODAY}"

mkdir -p "$NEW_BACKUP"

if [ ! -d "$NEW_BACKUP" ]; then
    echo "No such directory: $NEW_BACKUP"
    exit 1
fi

for backup_item in "${BACKUP_WHAT[@]}"; do
	backup_item_real=`realpath "$backup_item" 2>/dev/null`

    if [ ! -d "$backup_item_real" ]; then
    	echo "$backup_item: Not a directory, skipping!"
		continue
	fi

#	echo "rsync $VERBOSE_ARGS -a --delete --relative --one-file-system --numeric-ids --exclude-from=backup_exclude.conf --link-dest=\"$CURRENT_BACKUP\" \"$backup_item_real\" \"$NEW_BACKUP\""
	rsync $VERBOSE_ARGS -a --delete --relative --one-file-system --numeric-ids --exclude-from=backup_exclude.conf --link-dest="$CURRENT_BACKUP" "$backup_item_real" "$NEW_BACKUP"
done

# Update symbolic link to current
if [ -h "$CURRENT_BACKUP" ]; then
    rm -f "$CURRENT_BACKUP"
    ln -s "$NEW_BACKUP" "$CURRENT_BACKUP"
fi

