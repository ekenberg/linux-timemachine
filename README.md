# linux-timemachine
=================

## Rsync incremental backups with hard linking. Save time and space. And your data.

Macs have automatic incremental backups built in through [Time Machine](http://en.wikipedia.org/wiki/Time_Machine_%28Mac_OS%29)

![Apple TimeMachine](http://ekenberg.github.io/linux-timemachine/images/mac-timemachine.png)

On Linux, we can use rsync, bash and cron.

This script is how I make system backups on my Linux workstation. There are some prerequisites:

* Backups are made to a filesystem that supports hard links and symlinks.
* The backup target filesystem is mounted locally (NFS, USB-cable etc). I use a ONAP NAS which is mounted to /mnt/backup over NFS

### Notes:

* 