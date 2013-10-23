rsync-snapshot
==============

Filesystem snapshots using rsync and hard links to optimize speed and disk space

Two scripts which can be used to backup your hard drive to another location.  The location can be
be a remote drive as long as cp -l will work on the filesystem.  What I do is make the snapshots to
the same computer and then once a day one central server pulls the latest snapshot from various
machines and stores them locally so I have two sets of my backups in case of disk or machine failure.
This does not account for catastrophic failure (fire) but the resulting latest snapshot can always
be synced to an off-site location, external hard drive, etc.

The original scripts and idea came from this site:  http://www.mikerubel.org/computers/rsync_snapshots/

File descriptions

make_snapshot.sh - Currently configured for four snapshots, or to be ran every 6 hours.  Cleans up
the oldest "hourly" snapshot, moves the remaining snapshots up one slot, leaving the latest snapshot
in place for sync to work against.  Adding more snapshots per day is pretty easy, just adding some
additional sections to the script.

make_snapshot_wrapper.sh - Script using nocache and ionice to reduce the system
load while executeing make_snapshot.sh.  Optional.

daily_snapshot_rotate.sh - Currently configured for five days.  Cleans up the oldest daily snapshot,
moves the remaining daily snapshots up one slot, then Takes the latest "hourly" snapshot and copies
it to the newest daily snapshot.

daily_snapshot_wrapper.sh - Script using nocache and ionice to reduce the system
load while executeing daily_snapshot_rotate.sh.  Optional.

Using this, we have snapshots that are 6, 12, 18, 24, 48, 72, 96, and 120 hours old from which we
can easily do diffs, copies, etc to restore files.

The size requirements are very much dependent upon the data being backed up, but I generally see
about 2 to 2.5 times the backed up space in snapshots for a typical Linux distro which I back up
almost everything (minus my media etc).  I also use the script for media, particularly photos etc,
but the storage can be higher or even LOWER if the media isn't changing, as it's all hard links or
unique files.

Setup:

make_snapshot.sh - Make sure all file paths are valid.  If you want the script to mount a drive
to store to (and unmount it when done) you can set the MOUNT_DEVICE and REMOUNT options appropriately.
Set the SOURCE (what to back up) and the SNAPSHOT_RW (the path where the backups go).  You can also
specify a rsync-compliant (ie:  rsync --exclude-from) exclusion file to exclude files and paths you
do not want to back up.

daily_snapshot_rotate.sh - Same configuration as make_snapshot.sh basically.

Once you've ran both scripts and verified they're working properly, you can add them to your crontab
for make_snapshot to be ran at 0,6,12,18 and daily_snapshot_rotate to be ran once a day.

Hope these scripts are useful to someone.  I've used them for years now and they've saved me from
user error (both large and small!) many times.


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/khaytsus/rsync-snapshot/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

