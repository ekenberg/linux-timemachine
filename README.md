Linux Time Machine
------------------

Rsync incremental backups with hard linking. Save time and space. And your data.

Macs have automatic incremental backups built in through [Time Machine](http://en.wikipedia.org/wiki/Time_Machine_%28Mac_OS%29)

![Apple TimeMachine](http://ekenberg.github.io/linux-timemachine/images/mac-timemachine.png)

On Linux, we have rsync, bash and cron. Rsync can use [hard links](http://en.wikipedia.org/wiki/Hard_link) for unchanged files: only files changed since the previous backup are copied. This saves a lot of time and storage space. Still every backup is complete and self contained. Almost like magic.

This script is how I make system backups on my Linux workstation.

### Prerequisites

* Backup to a filesystem which supports hard and soft links. No problem except for FAT or NTFS (Microsoft).
* Mount the backup filesystem locally (NFS, USB-cable etc). I use a QNAP NAS which is mounted to /mnt/backup over NFS

### How To
* Mount your backup target
* Set configuration in backup.conf
* Set exclude paths in backup_exclude.conf
* Test with some small directory and -v: `sudo do_incremental_rsync.sh -v ~/test-directory`
* Test a full system backup: `sudo do_incremental_rsync.sh`. If /home is on a separate partition: `sudo do_incremental_rsync.sh /home /`. See [Notes](#notes) below.
* Finally, set up to run (as root) once a day through cron.

### Check hard linking
To verify that hard linking actually works, use the `stat` command on a file in the latest backup which you know has not been changed for some time. `stat` shows a field `Links: #` which tells how many hard links a file has. My /etc/fstab hasn't changed for a long time:

![Stat output](http://ekenberg.github.io/linux-timemachine/images/stat-verify-hard-links.jpg)

<a name='notes'/>
### Notes
* I do backups nightly, and the script stores them with the current date in the directory name. So any additional backups during the day will end up overwriting the current date's backup. That's fine for me, but if you want to keep more frequent copies, you should look at the `$TODAY` variable in the script. Maybe add hour or hour-minute to the format.
* rsync is run with --one-file-system. If you have several filesystems to backup, you must supply them all as arguments to the script. Example: If /home is mounted on a separate partition you would make a system backup like this: `do_incremental_rsync.sh /home /`

