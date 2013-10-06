#!/bin/bash

# Usage:
#  do_incremental_rsync.sh /some/directory /and/some/other/directory
#  do_incremental_rsync.sh                (will backup /)
#
#  do_incremental_rsync.sh -v /home /     (-v = print verbose rsync output)
#
# rsync uses --one-file-system, so if you have several filesystems under / you need to supply them as separate arguments to the script
#
# More information in the README or http://ekenberg.github.io/linux-timemachine/

function die {
    echo >&2 $@
    exit 1
}

# Go to directory of this script
cd "$( dirname "$0" )"

if [ `id -u` != "0" ]; then
    echo "You need to be root (or sudo) to run system backups"
    exit 1
fi

# Include configuration
source backup.conf || die "You must supply backup.conf"

[ -z "${BACKUP_BASE}" ] && die "BACKUP_BASE not configured in backup.conf"
[ -z "${BACKUP_NAME}" ] && die "BACKUP_NAME not configured in backup.conf"

# check for exclude-file
[ -f backup_exclude.conf ] || die "You must supply backup_exclude.conf (empty is ok)"

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

[ -d "$NEW_BACKUP" ] || die "No such directory: $NEW_BACKUP"    

for backup_item in "${BACKUP_WHAT[@]}"; do
	backup_item_real=`realpath "$backup_item" 2>/dev/null`

    if [ ! -d "$backup_item_real" ]; then
    	echo "$backup_item: Not a directory, skipping!"
		continue
	fi

#	echo "rsync $VERBOSE_ARGS -a --delete --relative --one-file-system --numeric-ids --exclude-from=backup_exclude.conf --link-dest=\"$CURRENT_BACKUP\" \"$backup_item_real\" \"$NEW_BACKUP\""
	rsync $VERBOSE_ARGS -a --delete --relative --one-file-system --numeric-ids --exclude-from=backup_exclude.conf --link-dest="$CURRENT_BACKUP" "$backup_item_real" "$NEW_BACKUP"
done

# Update soft link to current backup
[ -h "$CURRENT_BACKUP" ] && rm -f "$CURRENT_BACKUP"
ln -s "$NEW_BACKUP" "$CURRENT_BACKUP" || die "Cannot create soft link '$NEW_BACKUP' -> '$CURRENT_BACKUP'"

