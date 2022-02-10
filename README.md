Linux Time Machine
------------------

Rsync incremental backups with hard links. Save time and space. And your data.

Macs have automatic incremental backups built in through [Time Machine](http://en.wikipedia.org/wiki/Time_Machine_%28Mac_OS%29)

![Apple TimeMachine](http://ekenberg.github.io/linux-timemachine/images/mac-timemachine.png)

Linux has rsync, bash and cron. Rsync can use [hard links](http://en.wikipedia.org/wiki/Hard_link) for unchanged files: only files changed since the previous backup are copied. This saves a lot of time and storage space.

A few entries from my personal backup. As you can see, each day gets its own directory. Inside is a complete backup with every file from my workstation. Still, each day takes very little extra space, since only modified files are copied. The rest are hard links. (Don't mind the modification times - they are set by rsync to the last modification time of / on my workstation):

![Linux TimeMachine](http://ekenberg.github.io/linux-timemachine/images/linux-timemachine.png)

### Prerequisites
* Backup to a filesystem which supports hard and soft links. No problem except for FAT or NTFS (Microsoft).
* Mount the backup filesystem locally (NFS, USB-cable etc). I use a QNAP NAS which is mounted to /mnt/backup over NFS

### How To
* Mount your backup target
* Set configuration in backup.conf
* Set exclude paths in backup_exclude.conf
* Test with some small directory and -v: `sudo do_incremental_rsync.sh -v /some/test-directory`
* Do a full system backup: `sudo do_incremental_rsync.sh`. If /home is on a separate partition: `sudo do_incremental_rsync.sh /home /`. The first full backup will take a long time since all files must be copied.
* Finally, set up to run nightly, as root, through cron. I recommend doing a full run early morning or just after midnight, see [Notes](#notes) below.

### Check hard links
To verify that hard linking actually works, use the `stat` command on a file in the latest backup which you know has not been changed for some time. `stat` shows a field `Links: #` which tells how many hard links a file has. My /etc/fstab hasn't changed for a long time:

![Stat output](http://ekenberg.github.io/linux-timemachine/images/stat-verify-hard-links.jpg)

<a name='notes'/>

### Notes
* _Important:_ For hard links to work, the first backup each day must be a full system backup. Why? Because the script updates the current-link when it is run. If the first backup of the day is for /home/user/some/directory, and the current-link is updated. When a full backup is run, it will look for the last backup through the current-link and not find any files except /home/user/some/directory, and it must make a new copy of everything. This will waste a lot of space! Make sure to do a full backup every night just after midnight and you should be fine.
* I do backups nightly, and the script stores them with the current date in the directory name. So any additional backups during the day will end up overwriting the current date's backup. That's fine for me, but if you want to keep more frequent copies, you should look at the `$TODAY` variable in the script. Maybe add hour or hour-minute to the format. Please understand that the first backup to every new date/time should be a full backup, as explained above.
* rsync is run with --one-file-system. If you have several filesystems to backup, you must supply them all as arguments to the script. Example: If /home is mounted on a separate partition you would make a system backup like this: `do_incremental_rsync.sh /home /`

